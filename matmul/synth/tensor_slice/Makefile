all: synth clean_synth

synth:
	design_vision -64bit -f synth_8x8int8_4x4fp16.cmd

synth_unopt:
	design_vision -64bit -f synth_8x8int8_4x4fp16.unoptimized.cmd

clean_synth:
	\rm -rf *.syn *.pvl *.mr *.svf command.log 

clean:
	\rm -rf csrc DVEFiles simv.daidir simv ucli.key vcdplus.vpd *.syn *.pvl *.mr *.svf command.log *.txt

