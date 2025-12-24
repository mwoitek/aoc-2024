DC = dmd
PARTS = 1 2
INPUT ?= ../data/day_01.txt

all: $(addprefix pt,$(addsuffix .out,$(PARTS)))

%.out: %.d
	$(DC) $< -O -of=$@

run: $(addprefix run-,$(PARTS))

run-%: pt%.out | $(INPUT)
	./$< $(INPUT)

clean:
	$(RM) *.o *.out
