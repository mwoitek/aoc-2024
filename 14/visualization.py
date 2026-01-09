import re
from pathlib import Path
from typing import Any, cast

GRID_WIDTH = 101
GRID_HEIGHT = 103
LINE_PATTERN = re.compile(r"p=([-0-9]+),([-0-9]+) v=([-0-9]+),([-0-9]+)")


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
        self.occupied = build_matrix(GRID_HEIGHT, GRID_WIDTH, False)
        self.occupied = cast("list[list[bool]]", self.occupied)

    # HERE
