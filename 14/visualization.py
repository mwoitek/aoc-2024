import re
from pathlib import Path
from typing import Any, cast

import pygame

ROOT_DIR = Path(__file__).parents[1]
GRID_WIDTH = 101
GRID_HEIGHT = 103
CELL_SIZE = 6
WINDOW_HEIGHT = GRID_HEIGHT * CELL_SIZE
WINDOW_WIDTH = (WINDOW_HEIGHT * 4) // 3
TITLE = "AoC 2024: Day 14, Part 2"
DELTA_TIME = 20
UPDATE_EVENT = pygame.event.custom_type()

BLACK = pygame.Color(2, 2, 2)
GREEN = pygame.Color(10, 149, 72)


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

    def update(self, time: int) -> None:
        self.px = (self.px + time * self.vx) % GRID_WIDTH
        self.py = (self.py + time * self.vy) % GRID_HEIGHT


def get_robots(input_path: Path) -> list[Robot]:
    with input_path.open("r") as file:
        return [Robot(line.strip()) for line in file]


def build_matrix(rows: int, cols: int, val: Any) -> list[list[Any]]:
    matrix: list[list[Any]] = []
    for _ in range(rows):
        row = [val for _ in range(cols)]
        matrix.append(row)
    return matrix


class Grid:
    def __init__(self) -> None:
        self.occupied = build_matrix(GRID_HEIGHT, GRID_WIDTH, val=False)
        self.occupied = cast("list[list[bool]]", self.occupied)
        self.rects = self._build_rectangles()

    def clear(self) -> None:
        for i in range(GRID_HEIGHT):
            for j in range(GRID_WIDTH):
                self.occupied[i][j] = False

    def update(self, robots: list[Robot]) -> None:
        self.clear()
        for robot in robots:
            self.occupied[robot.py][robot.px] = True

    @staticmethod
    def _build_rectangles() -> list[list[pygame.Rect]]:
        rects: list[list[pygame.Rect]] = []
        for i in range(GRID_HEIGHT):
            row: list[pygame.Rect] = []
            top = i * CELL_SIZE
            for j in range(GRID_WIDTH):
                left = j * CELL_SIZE
                rect = pygame.Rect(left, top, CELL_SIZE, CELL_SIZE)
                row.append(rect)
            rects.append(row)
        return rects

    def render(self, screen: pygame.Surface) -> None:
        for i in range(GRID_HEIGHT):
            for j in range(GRID_WIDTH):
                color = GREEN if self.occupied[i][j] else BLACK
                pygame.draw.rect(screen, color, self.rects[i][j])


class Simulation:
    def __init__(self, robots: list[Robot], grid: Grid) -> None:
        self.is_running = False
        self.is_playing = False
        self.time = 0
        self.delta_time = DELTA_TIME
        self.robots = robots
        self.grid = grid
        self.grid.update(self.robots)

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

    def handle_event(self, event: pygame.event.Event) -> None:
        type_ = event.type
        if type_ == UPDATE_EVENT:
            self.update(self.delta_time)
        elif type_ == pygame.KEYDOWN:
            self.handle_keydown(event.key)
        elif type_ == pygame.QUIT:
            self.is_running = False

    def handle_keydown(self, key: int) -> None:
        if key == pygame.K_SPACE:
            if self.is_playing:
                self.pause()
            else:
                self.play()
        elif key == pygame.K_h:
            if not self.is_playing:
                self.update(-1)
        elif key == pygame.K_l:
            if not self.is_playing:
                self.update(1)
        elif key == pygame.K_j:
            if not self.is_playing:
                self.delta_time = max(self.delta_time - 1, 1)
        elif key == pygame.K_k:
            if not self.is_playing:
                self.delta_time += 1
        elif key == pygame.K_q:
            self.is_running = False
        elif key == pygame.K_s:
            self.save_image()

    def update(self, time: int) -> None:
        self.time += time
        print(self.time)  # TODO: remove
        for robot in self.robots:
            robot.update(time)
        self.grid.update(self.robots)

    def play(self) -> None:
        self.is_playing = True
        pygame.time.set_timer(UPDATE_EVENT, 1000)

    def pause(self) -> None:
        self.is_playing = False
        pygame.time.set_timer(UPDATE_EVENT, 0)

    def render(self) -> None:
        self.screen.fill(BLACK)
        self.grid.render(self.screen)
        pygame.display.flip()

    def save_image(self) -> None:
        sub_surf = self.screen.subsurface(0, 0, GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE)
        img_path = ROOT_DIR / "14" / f"grid_{self.time}.png"
        pygame.image.save(sub_surf, img_path)


if __name__ == "__main__":
    input_path = ROOT_DIR / "data" / "day_14.txt"
    robots = get_robots(input_path)
    grid = Grid()
    sim = Simulation(robots, grid)
    sim.run()
