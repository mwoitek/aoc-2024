DC = dmd
DFLAGS = -O -boundscheck=off -inline -release

PARTS = 1 2
INPUT ?= ../data/day_12.txt

all: $(addprefix pt,$(addsuffix .out,$(PARTS)))

%.out: %.d
	$(DC) $< $(DFLAGS) -of=$@

run: $(addprefix run-,$(PARTS))

run-%: pt%.out | $(INPUT)
	./$< $(INPUT)

clean:
	$(RM) *.o *.out
