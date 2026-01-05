// wc -l day_14.txt
const ulong MAX_ROBOTS = 500;

auto parsePair(in char[] pair)
{
    import std.algorithm.searching : countUntil;
    import std.conv : to;
    import std.typecons : tuple;

    const ulong i = pair.countUntil(',');
    const int x = pair[2 .. i].to!int;
    const int y = pair[i + 1 .. $].to!int;
    return tuple(x, y);
}

auto parseLine(in char[] line)
{
    import std.algorithm.searching : countUntil;
    import std.typecons : tuple;

    const ulong i = line.countUntil(' ');
    const auto pos = line[0 .. i].parsePair;
    const auto vel = line[i + 1 .. $].parsePair;
    return tuple(pos, vel);
}

struct Robot {
    int px;
    int py;
    int vx;
    int vy;

    this(in char[] line)
    {
        const auto t = line.parseLine;
        const auto pos = t[0];
        const auto vel = t[1];
        px = pos[0];
        py = pos[1];
        vx = vel[0];
        vy = vel[1];
    }

    void updatePosition(in int time)
    {
        px += vx * time;
        py += vy * time;
    }
}

Robot[] getRobots(in string inputPath)
{
    import std.array : appender;
    import std.stdio : File;

    auto arrBuilder = appender!(Robot[]);
    arrBuilder.reserve(MAX_ROBOTS);
    auto file = File(inputPath, "r");
    foreach (line; file.byLine)
        arrBuilder.put(Robot(line));
    return arrBuilder.data;
}

int myMod(in int a, in int m)
{
    return (a % m + m) % m;
}

struct Grid {
    int width;
    int height;
    int midX;
    int midY;

    this(in int width, in int height)
    {
        this.width = width;
        this.height = height;
        this.midX = width / 2;
        this.midY = height / 2;
    }

    int getQuadrant(in int x, in int y) const
    {
        if (x == midX || y == midY)
            return 0;
        if (x < midX)
            return y < midY ? 1 : 3;
        else
            return y < midY ? 2 : 4;
    }

    void setRealPosition(ref Robot robot) const
    {
        robot.px = myMod(robot.px, width);
        robot.py = myMod(robot.py, height);
    }
}

int computeSafetyFactor(ref Robot[] robots, in int time, in int gridWidth, in int gridHeight)
{
    import std.algorithm.iteration : reduce;

    int[] robotCounts = [0, 0, 0, 0, 0];
    const auto grid = Grid(gridWidth, gridHeight);
    int quadrant;
    foreach (robot; robots) {
        robot.updatePosition(time);
        grid.setRealPosition(robot);
        quadrant = grid.getQuadrant(robot.px, robot.py);
        robotCounts[quadrant]++;
    }
    return robotCounts[1 .. $].reduce!"a * b";
}

void main(string[] args)
{
    import core.memory : GC;

    GC.disable;

    import std.datetime.stopwatch : AutoStart, StopWatch;
    import std.stdio : writef, writeln;

    const string inputPath = args[1];
    auto sw = StopWatch(AutoStart.no);

    sw.start;
    Robot[] robots = inputPath.getRobots;
    const int safetyFactor = computeSafetyFactor(robots, 100, 101, 103);
    // const int safetyFactor = computeSafetyFactor(robots, 100, 11, 7);
    sw.stop;

    writeln("Safety factor: ", safetyFactor);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
