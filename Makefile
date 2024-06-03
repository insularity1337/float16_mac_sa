FPU_SRC = ./src
QA_DIR = ./qa
IVERILOG_FLAGS = -g2012 -W all

fpu_files := $(FPU_SRC)/categorizer.sv $(FPU_SRC)/sig_mul.sv $(FPU_SRC)/extreme_value_detector.sv $(FPU_SRC)/norm_calc.sv $(FPU_SRC)/subnorm_calc.sv $(FPU_SRC)/multiplier.sv
fpu_tb_files := $(QA_DIR)/multiplier_tb.sv

fpu_test:
	rm *.vcd *.vvp; clear; iverilog $(IVERILOG_FLAGS) $(fpu_tb_files) $(fpu_files) -o fpu.vvp; vvp fpu.vvp; gtkwave fpu.vcd

.DEFAULT_GOAL := fpu_test