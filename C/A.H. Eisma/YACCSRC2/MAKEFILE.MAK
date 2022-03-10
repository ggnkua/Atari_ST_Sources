#
# MAKEFILE for YACC.EXE for IBM-PC Turbo-C 2.0
#
# Execute this file by entering one of the next commands:
#    MAKE -a
#    MAKE -a yacc.exe
#    MAKE clean
#
# The following files are required on the current dir:
#
#    TURBOC.CFG		- the proper options for the compiler
#    YACC.FIL		- input file for TLINK to create YACC.EXE.
#
# These files contain references to the include and library
# directories of Turbo-C,.OBJ \TC\INCLUDE and.OBJ \TC\LIB on my system. You
# may have to change that.
#

.c.obj:
	tcc -c $<

yacc.exe:       chk.chk \
		YARYFL.OBJ \
		YCEMTY.OBJ \
		YCHCPY.OBJ \
		YCLSUR.OBJ \
		YCPFIR.OBJ \
		YCPRES.OBJ \
		YERROR.OBJ \
		YFLSET.OBJ \
		YMAIN.OBJ \
		YDATA.OBJ \
		YOTHRS.OBJ \
		YPRLOK.OBJ \
		YPTITM.OBJ \
		YSMNAM.OBJ \
		YSTAGN.OBJ \
		YSTATE.OBJ \
		YSTUNI.OBJ \
		YSUMRY.OBJ \
		YWRITM.OBJ \
		YCHFND.OBJ \
		YCPACT.OBJ \
		YCPUNI.OBJ \
		YCPYCD.OBJ \
		YCSTSH.OBJ \
		YDEFIN.OBJ \
		YDFOUT.OBJ \
		YFDTYP.OBJ \
		YFNACT.OBJ \
		YGTTOK.OBJ \
		YSETUP.OBJ \
		YSKPCM.OBJ \
		YAPACK.OBJ \
		YG2GEN.OBJ \
		YG2OUT.OBJ \
		YHDPRD.OBJ \
		YOUTPT.OBJ \
		YPRCFT.OBJ \
		YWARRY.OBJ \
		YWRACT.OBJ \
		YWSTAT.OBJ \
		YAOPUT.OBJ \
		YCLOPT.OBJ \
		YGIN.OBJ \
		YGTNM.OBJ \
		YNXTI.OBJ \
		YOSMRY.OBJ \
		YSTIN.OBJ \
		YAROUT.OBJ
	tlink @yacc.fil

chk.chk:	turboc.cfg
	copy turboc.cfg chk.chk
	-tcc -c *.c

clean:
	del chk.chk
	del *.obj
	del yacc.exe
	del *.map
	del *.bak
