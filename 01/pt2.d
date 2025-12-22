import std.algorithm.iteration : filter, map, sum;
import std.datetime.stopwatch : AutoStart, StopWatch;
import std.format.read : formattedRead;
import std.stdio : File, writef, writeln;

struct Lists {
    ulong[] left;
    ulong[] right;
}

Lists readLists(in string inputPath)
{
    ulong[] left;
    ulong[] right;

    ulong num1;
    ulong num2;

    auto file = File(inputPath, "r");
    foreach (line; file.byLine) {
        formattedRead(line, "%u   %u", &num1, &num2);
        left ~= num1;
        right ~= num2;
    }

    return Lists(left, right);
}

ulong[ulong] getNumberCounts(in ulong[] numbers)
{
    ulong[ulong] counts;
    foreach (number; numbers) {
        if (number in counts) {
            counts[number] += 1;
        } else {
            counts[number] = 1;
        }
    }
    return counts;
}

ulong similarityScore(in ulong[] left, in ulong[] right)
{
    const auto countsLeft = getNumberCounts(left);
    const auto countsRight = getNumberCounts(right);
    return countsLeft.byKeyValue().filter!(a => a.key in countsRight)
        .map!(a => a.key * a.value * countsRight[a.key])
        .sum();
}

void main(string[] args)
{
    const auto inputPath = args[1];
    auto sw = StopWatch(AutoStart.no);

    sw.start();
    const auto lists = readLists(inputPath);
    const auto score = similarityScore(lists.left, lists.right);
    sw.stop();

    writeln("Similarity score: ", score);

    const auto execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
