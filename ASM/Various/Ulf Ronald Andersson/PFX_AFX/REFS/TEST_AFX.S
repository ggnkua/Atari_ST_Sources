;File name:	TEST_AFX.S		Revised:	1992.10.27
;Revised by:	Ulf Ronald Andersson	Revision date:	1992.08.19
;
;
	nolist
	include	URAn_SYS.S
	include	URAn_DOS.S
	include	URAn_XB.S
	nolist
;
;
	text
;
rz:	;relative zero for ref's
start:
	move.l	a0,a5
	move.l	a5,d0
	bne.s	.exit_prog				;must not be ACC here
	move.l	4(a7),a5
	lea	loc_stk(pc),a7
	gemdos	Mshrink,!,(a5),#prog_limit-rz+$100
	gemdos	Fsfirst,my_fspec3(pc),#$3F
.loop_1:
	tst.l	d0
	bmi.s	.exit_prog
	gemdos	Fsnext
	bra.s	.loop_1
;
.exit_prog:
	gemdos	Pterm0
;
;
	data
;
my_fspec1:
	dc.b	'c:\t\afxstate.afx',nul
	even
my_fspec2:
	dc.b	'c:\t\afx_pass.afx',nul
	even
my_fspec3:
	dc.b	'c:\t\pfx_afx\pfxafx.doc',nul
;
	dcb.b	16,0
;
	bss
;
my_dta:
	ds.b	44
	ds.l	$100
loc_stk:
	ds.l	4
prog_limit:
;
;
	end	;of file:	TEST_AFX.S
