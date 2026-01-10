import re
from pathlib import Path
from typing import Any, cast

import pygame

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

    def update(self, time: int = DELTA_TIME) -> None:
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
        if event.type == UPDATE_EVENT:
            self.update()
        elif event.type == pygame.QUIT:
            self.is_running = False
        elif event.type == pygame.KEYDOWN and event.key == pygame.K_SPACE:
            if self.is_playing:
                self.pause()
            else:
                self.play()

    def update(self, time: int = DELTA_TIME) -> None:
        self.time += time
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


if __name__ == "__main__":
    input_path = Path("~/repos/advent_of_code_2024/data/day_14.txt").expanduser()
    robots = get_robots(input_path)
    grid = Grid()
    sim = Simulation(robots, grid)
    sim.run()
