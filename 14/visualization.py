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

DELTA_TIME = 100
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
        new_time = max(self.time + dt, 0)
        dt = new_time - self.time
        self.time = new_time
        for robot in self.robots:
            robot.update(dt)

    def increment_delta_time(self, increment: int) -> None:
        self.delta_time = max(self.delta_time + increment, 1)

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
        self.hud_surf = pygame.Surface((WINDOW_WIDTH, HUD_HEIGHT))
        self.hud_rect = self.hud_surf.get_rect(topleft=(0, WINDOW_HEIGHT - HUD_HEIGHT))
        self.surfs = [
            FONT.render(text, True, GREEN)
            for text in ["Time", "00000", "Delta time", f"{DELTA_TIME:05}"]
        ]
        tls = [(90, 8), (90, 40), (276, 8), (276, 40)]
        self.rects = [s.get_rect(topleft=tl) for s, tl in zip(self.surfs, tls, strict=True)]
        for surf, rect in zip(self.surfs, self.rects, strict=True):
            self.hud_surf.blit(surf, rect)

    def update(self, world: World) -> None:
        self.hud_surf.fill(BLACK, self.rects[1])
        self.hud_surf.fill(BLACK, self.rects[3])
        self.surfs[1] = FONT.render(f"{world.time:05}", True, GREEN)
        self.surfs[3] = FONT.render(f"{world.delta_time:05}", True, GREEN)
        self.hud_surf.blit(self.surfs[1], self.rects[1])
        self.hud_surf.blit(self.surfs[3], self.rects[3])

    def render(self, screen: pygame.Surface) -> None:
        screen.fill(BLACK, self.hud_rect)
        screen.blit(self.hud_surf, self.hud_rect)
        pygame.display.update(self.hud_rect)


class Simulation:
    def __init__(self, world: World, renderer: WorldRenderer, hud: Hud) -> None:
        self.is_running = False
        self.is_playing = False
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

    def play(self) -> None:
        self.is_playing = True
        pygame.time.set_timer(UPDATE_EVENT, 1000)

    def pause(self) -> None:
        self.is_playing = False
        pygame.time.set_timer(UPDATE_EVENT, 0)

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

    # NOTE: I'm not a fan of this solution. But using the state pattern in this
    # simple case seems like overkill.
    def handle_keydown(self, key: int) -> None:
        if self.is_playing:
            match key:
                case pygame.K_SPACE:
                    self.pause()
                case pygame.K_q:
                    self.stop()
                case pygame.K_s:
                    self.save()
                case _:
                    pass
        else:
            match key:
                case pygame.K_SPACE:
                    self.play()
                case pygame.K_q:
                    self.stop()
                case pygame.K_s:
                    self.save()
                case pygame.K_h:
                    self.update(-1)
                case pygame.K_l:
                    self.update(1)
                case pygame.K_j:
                    self.world.increment_delta_time(-1)
                    self.hud.update(self.world)
                case pygame.K_k:
                    self.world.increment_delta_time(1)
                    self.hud.update(self.world)
                case _:
                    pass

    def update(self, dt: int | None = None) -> None:
        self.world.update(dt)
        self.hud.update(self.world)

    def render(self) -> None:
        self.renderer.render(self.screen, self.world)
        self.hud.render(self.screen)

    def save(self) -> None:
        data_path = ROOT_DIR / "14" / f"positions_{self.world.time}.csv"
        saved_data = self.world.save_data(data_path)
        if saved_data:
            print(f"Position data saved to {data_path}")
        else:
            print("Failed to save data!")
        image_path = ROOT_DIR / "14" / f"grid_{self.world.time}.png"
        saved_image = self.renderer.save_image(self.screen, image_path)
        if saved_image:
            print(f"Grid image saved to {image_path}")
        else:
            print("Failed to save image!")


if __name__ == "__main__":
    robots = get_robots(ROBOTS_PATH)
    world = World(robots)
    renderer = WorldRenderer()
    hud = Hud()
    sim = Simulation(world, renderer, hud)
    sim.run()
