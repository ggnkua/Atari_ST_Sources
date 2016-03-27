# *************************** Development Tools ***************************

LINKER =	ld.ttp
CLIB	 =	libc.a

# ************************* Object Files **********************************

OBJECT	=		INIT.O \
					MAIN.O \
					EVENT.O \
					PROTECT.O \
					CNFTOCNX.O \
					FILE.O \
					GR.O \
					CNX.O \
					FORMDO.O \
					HSW.O \
					CNXEDIT.O \
					CNXINTER.O \
					GEM.O \
					MACRO.O \
					TEM.O \
					CNXTOKEN.O \
					TEMDRAW.O \
					DISK.O \
					MEM.O \
					TEMEDIT.O \
					DISP.O \
					MIDI.O \
					TEMMODFY.O \
					MIDIPLEX.O \
					EBDT.O \
					MISC.O \
					TEMREGN.O \
					EDIT1.O \
					MONITOR.O \
					WINDOW.O \
					EDIT2.O \
					MULTI.O \
					EDIT3.O \
					PATCH.O

# ********************** Program Build Instructions ***********************
genedit.prg : $(OBJECT
	@$(LINKER) $(OBJECT) $(CLIB) -O genedit.prg
