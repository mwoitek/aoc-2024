import std.container : Array;

// wc -l day_01.txt
const ulong MAX_NUMS = 1000;

struct Lists {
    Array!ulong left;
    Array!ulong right;
}

Lists readLists(in string inputPath)
{
    import std.format.read : formattedRead;
    import std.stdio : File;

    Array!ulong left;
    Array!ulong right;
    ulong num1;
    ulong num2;
    left.reserve(MAX_NUMS);
    right.reserve(MAX_NUMS);
    auto file = File(inputPath, "r");
    foreach (line; file.byLine) {
        formattedRead(line, "%u   %u", &num1, &num2);
        left.insertBack(num1);
        right.insertBack(num2);
    }
    return Lists(left, right);
}

ulong[ulong] getNumberCounts(in Array!ulong numbers)
{
    ulong[ulong] counts;
    foreach (number; numbers) {
        if (number in counts)
            counts[number]++;
        else
            counts[number] = 1;
    }
    return counts;
}

ulong similarityScore(in Array!ulong left, in Array!ulong right)
{
    import std.algorithm.iteration : filter, map, sum;

    const auto countsLeft = left.getNumberCounts;
    const auto countsRight = right.getNumberCounts;
    return countsLeft.byKeyValue
        .filter!(a => a.key in countsRight)
        .map!(a => a.key * a.value * countsRight[a.key])
        .sum;
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
    const ulong score = similarityScore(lists.left, lists.right);
    sw.stop;

    writeln("Similarity score: ", score);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
