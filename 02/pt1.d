import std.algorithm.iteration : filter, fold, map, splitter;
import std.algorithm.searching : all;
import std.array : array;
import std.conv : to;
import std.math.algebraic : abs;
import std.math.traits : sgn;
import std.range : dropOne, zip;
import std.stdio : File, writeln;

int[][] readLists(in string inputPath)
{
    int[][] lists;
    auto file = File(inputPath, "r");
    foreach (line; file.byLine.filter!(a => a.length > 0)) {
        lists ~= line.splitter().map!(to!int).array();
    }
    return lists;
}

bool sameSign(in int i, in int j)
{
    return sgn(i) == sgn(j);
}

bool inRange(in int val, in int minVal = 1, in int maxVal = 3)
{
    const int absVal = abs(val);
    return absVal >= minVal && absVal <= maxVal;
}

bool isSafe(in int[] list)
{
    const auto diffs = zip(list, list.dropOne()).map!(a => a[0] - a[1]).array();
    return all!(a => sameSign(a[0], a[1]))(zip(diffs, diffs.dropOne())) && (all!inRange)(diffs);
}

void main(string[] args)
{
    const string inputPath = args[1];
    const int[][] lists = readLists(inputPath);
    const auto safeCount = fold!((a, e) => isSafe(e) ? a + 1 : a)(lists, 0);
    writeln("Number of safe reports: ", safeCount);
}
