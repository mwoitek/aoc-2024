// NOTE: This solution is almost identical to the
// one for the first part. Only a single line had to
// be changed.

struct Input {
    uint[][uint] adjacencyList;
    uint[][] pageLists;
}

Input readInput(in string inputPath)
{
    import std.algorithm.iteration : map, splitter;
    import std.algorithm.searching : countUntil;
    import std.array : array;
    import std.conv : to;
    import std.file : readText;
    import std.format.read : formattedRead;
    import std.string : stripRight;

    string[] lines = inputPath.readText.stripRight.splitter('\n').array;
    const size_t idxBlank = lines.countUntil("");

    uint[][uint] adjacencyList;
    uint node1, node2;
    foreach (i; 0 .. idxBlank) {
        formattedRead(lines[i], "%d|%d", &node1, &node2);
        if (node1 in adjacencyList)
            adjacencyList[node1] ~= node2;
        else
            adjacencyList[node1] = [node2];
    }

    uint[][] pageLists;
    pageLists.reserve(lines.length - idxBlank - 1);
    foreach (i; idxBlank + 1 .. lines.length)
        pageLists ~= lines[i].splitter(',').map!(to!uint).array;

    return Input(adjacencyList, pageLists);
}

uint[][uint] getSubgraph(in uint[][uint] graph, in uint[] nodes)
{
    import std.algorithm.iteration : filter, map;
    import std.algorithm.searching : canFind;
    import std.array : array;
    import std.conv : to;

    uint[][uint] subgraph;
    foreach (node; nodes.filter!(n => n in graph))
        subgraph[node] = graph[node].filter!(n => canFind(nodes, n))
            .map!(to!uint)
            .array;
    return subgraph;
}

uint[] topologicalSort(in uint[][uint] adjacencyList, in uint[] nodes)
{
    const size_t numNodes = nodes.length;
    uint[] sorted = new uint[](numNodes);
    size_t idx = numNodes - 1;
    bool[uint] visited;

    void dfs(in uint node)
    {
        visited[node] = true;
        if (node !in adjacencyList) {
            sorted[idx--] = node;
            return;
        }
        foreach (neighbor; adjacencyList[node]) {
            if (neighbor !in visited)
                dfs(neighbor);
        }
        sorted[idx--] = node;
    }

    foreach (node; nodes) {
        if (node !in visited)
            dfs(node);
    }

    return sorted;
}

uint sumMiddlePageNumbers(in Input input)
{
    uint sum = 0;
    foreach (pageList; input.pageLists) {
        const uint[][uint] subgraph = getSubgraph(input.adjacencyList, pageList);
        const uint[] sorted = topologicalSort(subgraph, pageList);
        if (sorted != pageList) // only different line
            sum += sorted[sorted.length / 2];
    }
    return sum;
}

void main(string[] args)
{
    import std.datetime.stopwatch : AutoStart, StopWatch;
    import std.stdio : writef, writeln;

    const string inputPath = args[1];
    auto sw = StopWatch(AutoStart.no);

    sw.start;
    const Input input = readInput(inputPath);
    const uint sum = sumMiddlePageNumbers(input);
    sw.stop;

    writeln("Sum of middle page numbers: ", sum);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
