// wc -l day_10.txt
const size_t MAX_ROWS = 47;

// head -n1 day_10.txt | tr -d '\n' | wc -m
const size_t MAX_COLS = 47;

// fold -w1 day_10.txt | grep 0 | wc -l
const size_t MAX_TRAILHEADS = 224;

struct Position {
    int x;
    int y;
}

int[] parseLine(in char[] line)
{
    import std.algorithm.iteration : map;
    import std.array : appender;

    auto arrBuilder = appender!(int[]);
    arrBuilder.reserve(MAX_COLS);
    foreach (num; line.map!(c => c - '0'))
        arrBuilder.put(num);
    return arrBuilder.data;
}

int[][] readMap(in string inputPath)
{
    import std.array : appender;
    import std.stdio : File;

    auto arrBuilder = appender!(int[][]);
    arrBuilder.reserve(MAX_ROWS);
    auto file = File(inputPath, "r");
    foreach (line; file.byLine)
        arrBuilder.put(line.parseLine);
    return arrBuilder.data;
}

struct Map {
    int[][] arr;
    int height;
    int width;
    Position[] trailheads;

    this(in string inputPath)
    {
        this.arr = inputPath.readMap;
        this.height = cast(int)this.arr.length;
        this.width = cast(int)this.arr[0].length;
    }

    void findTrailheads()
    {
        import std.array : appender;

        auto arrBuilder = appender!(Position[]);
        arrBuilder.reserve(MAX_TRAILHEADS);
        foreach (i; 0 .. height) {
            foreach (j; 0 .. width) {
                if (arr[i][j] == 0)
                    arrBuilder.put(Position(i, j));
            }
        }
        trailheads = arrBuilder.data;
    }

    bool contains(in Position pos)
    {
        return pos.x >= 0 && pos.x < width && pos.y >= 0 && pos.y < height;
    }

    ulong computeRating(in Position trailhead)
    {
        ulong rating = 0;

        void rec(in int val, in Position pos)
        {
            if (!contains(pos))
                return;
            const int newVal = arr[pos.x][pos.y];
            if (newVal != val + 1)
                return;
            if (newVal == 9) {
                rating++;
                return;
            }
            rec(newVal, Position(pos.x - 1, pos.y));
            rec(newVal, Position(pos.x + 1, pos.y));
            rec(newVal, Position(pos.x, pos.y - 1));
            rec(newVal, Position(pos.x, pos.y + 1));
        }

        rec(-1, trailhead);
        return rating;
    }

    ulong computeTotalRating()
    {
        findTrailheads();
        ulong total = 0;
        foreach (trailhead; trailheads)
            total += computeRating(trailhead);
        return total;
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
    const ulong rating = inputMap.computeTotalRating;
    sw.stop;

    writeln("Total rating: ", rating);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
