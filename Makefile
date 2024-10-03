# Makefile for running Vivado in batch mode with a TCL script

# Variables
VIVADO = vivado
TCL_SCRIPT = tcl/build.tcl
LOG_FILE = vivado_run.log *.jou *.log

# Target to run the TCL script
run:
	$(VIVADO) -mode batch -source $(TCL_SCRIPT) > $(LOG_FILE)

# Clean target (optional) to remove the log file
clean:
	rm -f $(LOG_FILE)