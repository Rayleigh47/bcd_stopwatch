# make -> make run -> make view -> make clean

# Variables
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
SRC = ../Clock_Generator/Clock_Generator.sv ../Clock_Generator/debouncer.v ../Counter/Counter.sv ../Seven_Seg/Seven_Seg_Nexys.v Top_Nexys.v tb.sv
OUT = tb.vvp
WAVEFORM = tb.vcd

# Default target
all: run

# Compile the Verilog files
$(OUT): $(SRC)
  # -g2012 for SV support
	$(IVERILOG) -g2012 -o $(OUT) $(SRC)

# Run the simulation
run: $(OUT)
	$(VVP) $(OUT)

# View the waveform
view: $(WAVEFORM)
	$(GTKWAVE) $(WAVEFORM)

# Clean up generated files
clean:
	rm -f $(OUT) $(WAVEFORM)

