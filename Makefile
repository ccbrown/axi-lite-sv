all: test

.PHONY: test

subordinate_tb.vvp: subordinate.sv subordinate_tb.sv
	iverilog -g2012 -o $@ $^

test: subordinate_tb.vvp
	vvp subordinate_tb.vvp

subordinate_prove: subordinate.sv subordinate.sby vendor/faxil_slave.v
	rm -rf $@
	sby -f subordinate.sby prove

subordinate_cover: subordinate.sv subordinate.sby vendor/faxil_slave.v
	rm -rf $@
	sby -f subordinate.sby cover
