# Makefile for running Vivado in batch mode with a TCL script

# Variables
VIVADO = vivado
TCL_SCRIPT = tcl/build.tcl
CLEAN_FILES = *.jou *.log

# Target to run the TCL script
run:
	$(VIVADO) -mode batch -source $(TCL_SCRIPT)

# Clean target (optional) to remove the log file
clean:
	rm -f $(CLEAN_FILES)