import std.container : Array;

// wc -l day_01.txt
const ulong MAX_NUMS = 1000;

struct Lists {
    Array!long list1;
    Array!long list2;

    long totalDistance() const
    {
        import std.algorithm.iteration : map, sum;
        import std.math.algebraic : abs;
        import std.range : zip;

        return zip(list1[], list2[]).map!(a => abs(a[0] - a[1])).sum;
    }
}

Lists readLists(in string inputPath)
{
    import std.algorithm.sorting : sort;
    import std.format.read : formattedRead;
    import std.stdio : File;

    Array!long list1;
    Array!long list2;
    long num1;
    long num2;
    list1.reserve(MAX_NUMS);
    list2.reserve(MAX_NUMS);
    auto file = File(inputPath, "r");
    foreach (line; file.byLine) {
        formattedRead(line, "%d   %d", &num1, &num2);
        list1.insertBack(num1);
        list2.insertBack(num2);
    }
    list1[].sort;
    list2[].sort;
    return Lists(list1, list2);
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
    const Lists lists = inputPath.readLists;
    const long totalDistance = lists.totalDistance;
    sw.stop;

    writeln("Total distance: ", totalDistance);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
