struct Position {
    size_t row;
    size_t col;
}

enum Direction : uint {
    Up,
    Right,
    Down,
    Left
}

char[][] readMap(in string inputPath)
{
    import std.algorithm.iteration : map;
    import std.array : array;
    import std.stdio : File;

    return File(inputPath, "r").byLine.map!(s => s.dup).array;
}

Position findInitialPosition(in char[][] map)
{
    import std.range : enumerate;
    import std.string : indexOf;

    Position initPos;
    long j;
    foreach (i, line; map.enumerate) {
        j = line.indexOf('^');
        if (j >= 0) {
            initPos = Position(i, j);
            break;
        }
    }
    return initPos;
}

bool moveUp(ref char[][] map, ref Position pos)
{
    size_t i = pos.row - 1;
    while (i < map.length && map[i][pos.col] != '#')
        map[i--][pos.col] = 'X';
    if (i < map.length) {
        pos.row = i + 1;
        return false;
    }
    return true; // true means stop moving
}

bool moveRight(ref char[][] map, ref Position pos)
{
    size_t j = pos.col + 1;
    while (j < map[0].length && map[pos.row][j] != '#')
        map[pos.row][j++] = 'X';
    if (j < map[0].length) {
        pos.col = j - 1;
        return false;
    }
    return true;
}

bool moveDown(ref char[][] map, ref Position pos)
{
    size_t i = pos.row + 1;
    while (i < map.length && map[i][pos.col] != '#')
        map[i++][pos.col] = 'X';
    if (i < map.length) {
        pos.row = i - 1;
        return false;
    }
    return true;
}

bool moveLeft(ref char[][] map, ref Position pos)
{
    size_t j = pos.col - 1;
    while (j < map[0].length && map[pos.row][j] != '#')
        map[pos.row][j--] = 'X';
    if (j < map[0].length) {
        pos.col = j + 1;
        return false;
    }
    return true;
}

void simulateWalk(ref char[][] map)
{
    Position pos = map.findInitialPosition;
    map[pos.row][pos.col] = 'X';
    Direction direction = Direction.Up;
    bool stop = false;
    while (!stop) {
        final switch (direction) {
        case Direction.Up:
            stop = moveUp(map, pos);
            direction = Direction.Right;
            break;
        case Direction.Right:
            stop = moveRight(map, pos);
            direction = Direction.Down;
            break;
        case Direction.Down:
            stop = moveDown(map, pos);
            direction = Direction.Left;
            break;
        case Direction.Left:
            stop = moveLeft(map, pos);
            direction = Direction.Up;
            break;
        }
    }
}

void main(string[] args)
{
    import std.algorithm.iteration : map, sum;
    import std.algorithm.searching : count;
    import std.datetime.stopwatch : AutoStart, StopWatch;
    import std.stdio : writef, writeln;

    const string inputPath = args[1];
    auto sw = StopWatch(AutoStart.no);

    sw.start;
    char[][] labMap = readMap(inputPath);
    simulateWalk(labMap);
    const ulong numVisitedPositions = labMap.map!(r => r.count('X')).sum;
    sw.stop;

    writeln("Number of visited positions: ", numVisitedPositions);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
