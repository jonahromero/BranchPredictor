
SOURCES = branch_predictor.sv branch_predictor_tb.cpp
VERILATOR_FLAGS = -cc --exe --build -j --top-module branch_predictor --savable $(SOURCES)

ifeq ($(WALL), 1)
	VERILATOR_FLAGS := -Wall $(VERILATOR_FLAGS)
endif

ifeq ($(DEBUG), 1)
	VERILATOR_FLAGS := --debug $(VERILATOR_FLAGS)
endif

all: bp

bp:
	@verilator $(VERILATOR_FLAGS)
	@mv ./obj_dir/Vbranch_predictor branch_predictor

clean:
	rm -r ./obj_dir
	rm ./branch_predictor