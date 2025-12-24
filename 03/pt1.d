import std.algorithm.iteration : map, reduce, splitter, sum;
import std.conv : to;
import std.datetime.stopwatch : AutoStart, StopWatch;
import std.regex : matchAll, regex;
import std.stdio : File, writef, writeln;

static re = regex(r"mul\((\d{1,3},\d{1,3})\)");

auto getResultForLine(in char[] line)
{
    // dfmt off
    return matchAll(line, re)
        .map!(m => m
                .captures[1]
                .splitter(',')
                .map!(to!ulong)
                .reduce!"a * b")
        .sum;
    // dfmt on
}

auto getResultForAllLines(in string inputPath)
{
    return File(inputPath, "r").byLine.map!(getResultForLine).sum;
}

void main(string[] args)
{
    auto inputPath = args[1];
    auto sw = StopWatch(AutoStart.no);

    sw.start();
    auto res = getResultForAllLines(inputPath);
    sw.stop();

    writeln("Sum of all products: ", res);

    auto execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
