import re
from pathlib import Path
from typing import cast

import pygame

ROOT_DIR = Path(__file__).parents[1]
ROBOTS_PATH = ROOT_DIR / "data" / "day_14.txt"

FONT_PATH = ROOT_DIR / "14" / "PressStart2P-Regular.ttf"
FONT_SIZE = 24

GRID_WIDTH = 101
GRID_HEIGHT = 103
CELL_SIZE = 6
WINDOW_WIDTH = GRID_WIDTH * CELL_SIZE
HUD_HEIGHT = 3 * FONT_SIZE
WINDOW_HEIGHT = GRID_HEIGHT * CELL_SIZE + HUD_HEIGHT
TITLE = "AoC 2024: Day 14, Part 2"

pygame.font.init()
FONT = pygame.font.Font(FONT_PATH, FONT_SIZE)

BLACK = pygame.Color(2, 2, 2)
GREEN = pygame.Color(10, 149, 72)

DELTA_TIME = 20
UPDATE_EVENT = pygame.event.custom_type()


class Robot:
    def __init__(self, line: str) -> None:
        px, py, vx, vy = self._parse_line(line)
        self.px = px
        self.py = py
        self.vx = vx
        self.vy = vy

    @staticmethod
    def _parse_line(line: str) -> tuple[int, int, int, int]:
        m = re.match(r"p=([-0-9]+),([-0-9]+) v=([-0-9]+),([-0-9]+)", line)
        m = cast("re.Match", m)
        return tuple(int(i) for i in m.groups())  # pyright: ignore[reportReturnType]

    def update(self, dt: int) -> None:
        self.px = (self.px + dt * self.vx) % GRID_WIDTH
        self.py = (self.py + dt * self.vy) % GRID_HEIGHT


def get_robots(input_path: Path) -> list[Robot]:
    with input_path.open("r") as file:
        return [Robot(line.strip()) for line in file]


class World:
    def __init__(self, robots: list[Robot]) -> None:
        self.time = 0
        self.robots = robots
        self.delta_time = DELTA_TIME

    def update(self, dt: int | None = None) -> None:
        if dt is None:
            dt = self.delta_time
        self.time += dt
        for robot in self.robots:
            robot.update(dt)

    def save_data(self, out_path: Path) -> bool:
        with out_path.open("w") as file:
            for robot in self.robots:
                file.write(f"{robot.px},{robot.py}\n")
        return out_path.exists() and out_path.is_file()


class WorldRenderer:
    def __init__(self) -> None:
        self.world_rect = pygame.Rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT - HUD_HEIGHT)
        self.robot_surf = self._get_robot_surface(CELL_SIZE, GREEN)

    @staticmethod
    def _get_robot_surface(cell_size: int, color: pygame.typing.ColorLike) -> pygame.Surface:
        surf = pygame.Surface((cell_size, cell_size))
        surf.fill(color)
        return surf

    def render(self, screen: pygame.Surface, world: World) -> None:
        screen.fill(BLACK, self.world_rect)
        for robot in world.robots:
            x = robot.px * CELL_SIZE
            y = robot.py * CELL_SIZE
            screen.blit(self.robot_surf, (x, y))
        pygame.display.update(self.world_rect)

    def save_image(self, screen: pygame.Surface, out_path: Path) -> bool:
        sub_surf = screen.subsurface(self.world_rect)
        pygame.image.save(sub_surf, out_path)
        return out_path.exists() and out_path.is_file()


class Hud:
    def __init__(self) -> None:
        # TODO
        pass

    def update(self, world: World) -> None:
        # TODO
        return

    def render(self, screen: pygame.Surface) -> None:
        # TODO
        return


class Simulation:
    def __init__(self, world: World, renderer: WorldRenderer, hud: Hud) -> None:
        self.is_running = False
        self.world = world
        self.renderer = renderer
        self.hud = hud

    def run(self) -> None:
        pygame.init()
        self.screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT))
        pygame.display.set_caption(TITLE)
        self.is_running = True
        while self.is_running:
            for event in pygame.event.get():
                self.handle_event(event)
            self.render()
        pygame.quit()

    def stop(self) -> None:
        self.is_running = False

    def handle_event(self, event: pygame.event.Event) -> None:
        match event.type:
            case t if t == UPDATE_EVENT:
                self.update()
            case pygame.KEYDOWN:
                self.handle_keydown(event.key)
            case pygame.QUIT:
                self.stop()
            case _:
                pass

    # FIXME
    def handle_keydown(self, key: int) -> None:
        if key == pygame.K_SPACE:
            if self.is_playing:
                self.pause()
            else:
                self.play()
        elif key == pygame.K_q:
            self.stop()
        elif key == pygame.K_s:
            self.save()
        # elif self.is_playing:
        #     return
        # elif key == pygame.K_h:
        #     self.update(-1)
        # elif key == pygame.K_l:
        #     self.update(1)
        # elif key == pygame.K_j:
        #     self.delta_time = max(self.delta_time - 1, 1)
        # elif key == pygame.K_k:
        #     self.delta_time += 1

    def update(self, delta_time: int) -> None:
        self.world.update(delta_time)
        self.hud.update(self.world)

    def render(self) -> None:
        self.hud.render(self.screen)


if __name__ == "__main__":
    robots = get_robots(ROBOTS_PATH)
    hud = Hud()
    sim = Simulation(hud)
    sim.run()
