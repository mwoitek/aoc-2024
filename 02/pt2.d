// wc -l day_02.txt
const size_t MAX_ROWS = 1000;

// awk '{print NF}' day_02.txt | sort -nru | head -n1
const size_t MAX_COLS = 8;

int[] parseLine(in char[] line)
{
    import std.algorithm.iteration : map, splitter;
    import std.array : appender;
    import std.conv : to;

    auto arrBuilder = appender!(int[]);
    arrBuilder.reserve(MAX_COLS);
    foreach (num; line.splitter.map!(to!int))
        arrBuilder.put(num);
    return arrBuilder.data;
}

int[][] readLists(in string inputPath)
{
    import std.array : appender;
    import std.stdio : File;

    auto arrBuilder = appender!(int[][]);
    auto file = File(inputPath, "r");
    foreach (line; file.byLine)
        arrBuilder.put(line.parseLine);
    return arrBuilder.data;
}

bool inRange(in int val, in int minVal = 1, in int maxVal = 3)
{
    import std.math.algebraic : abs;

    const int absVal = abs(val);
    return absVal >= minVal && absVal <= maxVal;
}

bool isSafeWithoutRemoval(in int[] list)
{
    import std.math.traits : sgn;

    const int sign = sgn(list[0] - list[1]);
    int diff;
    foreach (i; 0 .. list.length - 1) {
        diff = list[i] - list[i + 1];
        if (diff.sgn != sign || !inRange(diff))
            return false;
    }
    return true;
}

bool isSafeWithRemoval(in int[] list)
{
    import std.range : enumerate;

    auto newList = new int[](list.length - 1);
    size_t i;
    foreach (j; 0 .. list.length) {
        i = 0;
        foreach (k, num; list.enumerate) {
            if (k != j)
                newList[i++] = num;
        }
        if (isSafeWithoutRemoval(newList))
            return true;
    }
    return false;
}

bool isSafe(in int[] list)
{
    return isSafeWithoutRemoval(list) || isSafeWithRemoval(list);
}

void main(string[] args)
{
    import core.memory : GC;

    GC.disable;

    import std.algorithm.searching : count;
    import std.datetime.stopwatch : AutoStart, StopWatch;
    import std.stdio : writef, writeln;

    const string inputPath = args[1];
    auto sw = StopWatch(AutoStart.no);

    sw.start;
    const int[][] lists = inputPath.readLists;
    const ulong safeCount = count!(isSafe)(lists);
    sw.stop;

    writeln("Number of safe reports: ", safeCount);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
