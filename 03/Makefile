DC = dmd
PARTS = 1 2
INPUT ?= ../data/day_03.txt

all: $(addprefix pt,$(addsuffix .out,$(PARTS)))

%.out: %.d
	$(DC) $< -O -of=$@

run: $(addprefix run-,$(PARTS))

run-%: pt%.out | $(INPUT)
	./$< $(INPUT)

clean:
	$(RM) *.o *.out
