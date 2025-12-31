// wc -l day_08.txt
const size_t MAX_ROWS = 50;

struct Position {
    ulong x;
    ulong y;
}

struct Map {
    string[] arr;
    ulong height;
    ulong width;
    bool[] hasAntinode;
    Position[][char] antennaPositions;

    this(in string inputPath)
    {
        import std.array : appender;
        import std.stdio : File;

        auto arrBuilder = appender!(string[]);
        arrBuilder.reserve(MAX_ROWS);
        auto file = File(inputPath, "r");
        foreach (line; file.byLineCopy)
            arrBuilder.put(line);
        this.arr = arrBuilder.data;
        this.height = this.arr.length;
        this.width = this.arr[0].length;
    }

    void findAntennas()
    {
        Position[][char] positions;
        char c;
        foreach (i; 0 .. height) {
            foreach (j; 0 .. width) {
                c = arr[i][j];
                if (c == '.')
                    continue;
                if (c in positions)
                    positions[c] ~= Position(i, j);
                else
                    positions[c] = [Position(i, j)];
            }
        }
        antennaPositions = positions;
    }

    bool contains(in Position pos)
    {
        return pos.x < width && pos.y < height;
    }

    ulong toLinearIndex(in Position pos)
    {
        return pos.x * width + pos.y;
    }

    void placeAntinodes(in Position ant1, in Position ant2)
    {
        auto antinode = Position(2 * ant1.x - ant2.x, 2 * ant1.y - ant2.y);
        if (contains(antinode))
            hasAntinode[toLinearIndex(antinode)] = true;
        antinode.x = 2 * ant2.x - ant1.x;
        antinode.y = 2 * ant2.y - ant1.y;
        if (contains(antinode))
            hasAntinode[toLinearIndex(antinode)] = true;
    }

    void placeAllAntinodesWithSameFrequency(in Position[] antennas)
    {
        import std.range : enumerate;

        foreach (i, ant1; antennas[0 .. $ - 1].enumerate) {
            foreach (ant2; antennas[i + 1 .. $])
                placeAntinodes(ant1, ant2);
        }
    }

    void placeAllAntinodes()
    {
        hasAntinode = new bool[](width * height);
        findAntennas();
        foreach (antennas; antennaPositions.values)
            placeAllAntinodesWithSameFrequency(antennas);
    }

    ulong countAntinodes()
    {
        import std.algorithm.searching : count;

        placeAllAntinodes();
        return count(hasAntinode, true);
    }
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
    auto inputMap = Map(inputPath);
    const ulong numAntinodes = inputMap.countAntinodes;
    sw.stop;

    writeln("Number of antinodes: ", numAntinodes);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
