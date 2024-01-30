
SOURCES = prediction_intf.sv prediction_history.sv branch_predictor_tb.cpp tournament_predictor.sv \
			 predictor.sv history.sv
VERILATOR_FLAGS = -cc --exe --build -j --top-module tournament_predictor --savable $(SOURCES)

ifeq ($(WALL), 1)
	VERILATOR_FLAGS := -Wall $(VERILATOR_FLAGS)
endif

ifeq ($(DEBUG), 1)
	VERILATOR_FLAGS := --debug $(VERILATOR_FLAGS)
endif

all: bp

bp:
	@verilator $(VERILATOR_FLAGS)
	@mv ./obj_dir/Vtournament_predictor tournament_predictor

clean:
	rm -r ./obj_dir
	rm ./tournament_predictor