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

BLACK = pygame.Color(2, 2, 2)
GREEN = pygame.Color(10, 149, 72)

LINE_PATTERN = re.compile(r"p=([-0-9]+),([-0-9]+) v=([-0-9]+),([-0-9]+)")
ROBOTS_FILE = Path("~/repos/advent_of_code_2024/data/day_14.txt").expanduser()


def parse_line(line: str) -> tuple[int, int, int, int]:
    m = LINE_PATTERN.match(line)
    m = cast("re.Match", m)
    return tuple(int(i) for i in m.groups())  # pyright: ignore[reportReturnType]


class Robot:
    def __init__(self, line: str) -> None:
        px, py, vx, vy = parse_line(line)
        self.px = px
        self.py = py
        self.vx = vx
        self.vy = vy

    def update(self, time: int = 1) -> None:
        self.px = (self.px + time * self.vx) % GRID_WIDTH
        self.py = (self.py + time * self.vy) % GRID_HEIGHT


def get_robots(input_path: Path = ROBOTS_FILE) -> list[Robot]:
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
        self.time = 0
        self.robots = robots
        self.grid = grid
        self.grid.update(self.robots)

    def update(self, time: int = 1) -> None:
        self.time += time
        for robot in self.robots:
            robot.update(time)
        self.grid.update(self.robots)
