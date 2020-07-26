all: synth clean_synth

size?=8x8

synth:
	design_vision -64bit -f synth_$(size).cmd

clean_synth:
	\rm -rf *.syn *.pvl *.mr *.svf command.log 

clean:
	\rm -rf csrc DVEFiles simv.daidir simv ucli.key vcdplus.vpd *.syn *.pvl *.mr *.svf command.log *.txt

