; This describes one non-ibm block device

public header
header dd -1
	   dw 2000h
	   dw _strat
	   dw _intr
	   db 1,0,0,0,0,0,0,0

