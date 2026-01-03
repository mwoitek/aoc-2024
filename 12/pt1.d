// wc -l day_12.txt
const size_t MAX_ROWS = 140;

struct UnionFind {
    ulong[] parents;
    ulong[] sizes;

    this(in ulong numSets)
    {
        parents = new ulong[](numSets);
        sizes = new ulong[](numSets);
        foreach (i; 0 .. numSets) {
            parents[i] = i;
            sizes[i] = 1;
        }
    }

    ulong find(in ulong i)
    {
        if (i != parents[i])
            parents[i] = find(parents[i]);
        return parents[i];
    }

    // NOTE: "union" is a reserved keyword. So I had to use
    // an alternative name for this operation.
    void merge(in ulong i, in ulong j)
    {
        import std.algorithm.mutation : swap;

        ulong iPar = find(i);
        ulong jPar = find(j);
        if (iPar == jPar)
            return;
        if (sizes[iPar] < sizes[jPar])
            swap(iPar, jPar);
        parents[jPar] = iPar;
        sizes[iPar] += sizes[jPar];
    }

    // Non-standard operation. But this is helpful in
    // this problem.
    ulong[ulong] getSizes()
    {
        import std.range : enumerate;

        ulong[ulong] sizesDict;
        foreach (i, parent; parents.enumerate) {
            if (i == parent)
                sizesDict[i] = sizes[i];
        }
        return sizesDict;
    }
}

struct Map {
    ulong height;
    ulong width;
    string[] map;
    ulong[][] regionsMap;
    ulong[ulong] areas;
    ulong[ulong] perimeters;
    UnionFind uf;

    this(in string inputPath)
    {
        import std.array : appender;
        import std.stdio : File;

        auto arrBuilder = appender!(string[]);
        arrBuilder.reserve(MAX_ROWS);
        auto file = File(inputPath, "r");
        foreach (line; file.byLineCopy)
            arrBuilder.put(line);
        map = arrBuilder.data;
        height = map.length;
        width = map[0].length;
    }

    void findRegions()
    {
        uf = UnionFind(width * height);
        char plant;
        ulong k, l;
        foreach (i; 0 .. height - 1) {
            k = i * width;
            foreach (j; 0 .. width - 1) {
                plant = map[i][j];
                l = k + j;
                if (map[i + 1][j] == plant)
                    uf.merge(l, l + width);
                if (map[i][j + 1] == plant)
                    uf.merge(l, l + 1);
            }
        }
        foreach (i; 0 .. height - 1) {
            if (map[i][width - 1] == map[i + 1][width - 1]) {
                k = (i + 1) * width - 1;
                uf.merge(k, k + width);
            }
        }
        foreach (j; 0 .. width - 1) {
            if (map[height - 1][j] == map[height - 1][j + 1]) {
                k = (height - 1) * width + j;
                uf.merge(k, k + 1);
            }
        }
    }

    void computeAreas()
    {
        areas = uf.getSizes;
    }

    void buildRegionsMap()
    {
        regionsMap = new ulong[][](width, height);
        foreach (i; 0 .. height) {
            foreach (j; 0 .. width)
                regionsMap[i][j] = uf.find(i * width + j);
        }
    }

    void computePerimeters()
    {
        ulong region;
        foreach (i; 0 .. height - 1) {
            foreach (j; 0 .. width - 1) {
                region = regionsMap[i][j];
                if (region !in perimeters)
                    perimeters[region] = 4 * areas[region];
                if (regionsMap[i + 1][j] == region)
                    perimeters[region] -= 2;
                if (regionsMap[i][j + 1] == region)
                    perimeters[region] -= 2;
            }
        }
        foreach (i; 0 .. height - 1) {
            region = regionsMap[i][width - 1];
            if (region !in perimeters)
                perimeters[region] = 4 * areas[region];
            if (regionsMap[i + 1][width - 1] == region)
                perimeters[region] -= 2;
        }
        foreach (j; 0 .. width - 1) {
            region = regionsMap[height - 1][j];
            if (region !in perimeters)
                perimeters[region] = 4 * areas[region];
            if (regionsMap[height - 1][j + 1] == region)
                perimeters[region] -= 2;
        }
    }

    ulong computeTotalPrice()
    {
        findRegions();
        computeAreas();
        buildRegionsMap();
        computePerimeters();
        ulong totalPrice = 0;
        foreach (region; areas.keys)
            totalPrice += areas[region] * perimeters[region];
        return totalPrice;
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
    const ulong totalPrice = inputMap.computeTotalPrice;
    sw.stop;

    writeln("Total price: ", totalPrice);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
