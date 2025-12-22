import std.algorithm.iteration : map, sum;
import std.algorithm.sorting : sort;
import std.datetime.stopwatch : AutoStart, StopWatch;
import std.format.read : formattedRead;
import std.math.algebraic : abs;
import std.range : zip;
import std.stdio : File, writef, writeln;

struct Lists {
    long[] list1;
    long[] list2;

    long totalDistance() const
    {
        return zip(list1, list2).map!(a => abs(a[0] - a[1])).sum();
    }
}

Lists readLists(in string inputPath)
{
    long[] list1;
    long[] list2;

    long num1;
    long num2;

    auto file = File(inputPath, "r");
    foreach (line; file.byLine) {
        formattedRead(line, "%d   %d", &num1, &num2);
        list1 ~= num1;
        list2 ~= num2;
    }

    list1.sort();
    list2.sort();

    return Lists(list1, list2);
}

void main(string[] args)
{
    const string inputPath = args[1];
    auto sw = StopWatch(AutoStart.no);

    sw.start();
    const Lists lists = readLists(inputPath);
    const long totalDistance = lists.totalDistance();
    sw.stop();

    writeln("Total distance: ", totalDistance);

    const auto execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
