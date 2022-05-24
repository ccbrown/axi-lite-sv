all: test

.PHONY: test

subordinate_tb.vvp: subordinate.sv subordinate_tb.sv
	iverilog -g2012 -o $@ $^

test: subordinate_tb.vvp
	vvp subordinate_tb.vvp
