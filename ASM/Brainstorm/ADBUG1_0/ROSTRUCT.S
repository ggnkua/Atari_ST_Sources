	*************************** rostruct.s *************************
	* Communication structure between a routine (ro) and Adebug.   *
	* to be included at the end of your routine.                   *
	****************************************************************

	*************************** rostruct.s *************************
	* Structure de communication entre une routine (ro) et Adebug. *
	* a mettre en include a la fin du source de la routine.        *
	****************************************************************

;+flag rebegin
;+char recu et a attendre

	offset	0
ro_struct:
v_number:
	ds.w	1
tos_number:
	ds.w	1
window_1:
	ds.l	1
window_2:
	ds.l	1
window_3:
	ds.l	1
window_4:
	ds.l	1
window_5:
	ds.l	1
TEXT:
	ds.l	1
DATA:
	ds.l	1
BSS:
	ds.l	1
END:
	ds.l	1
registers:
d0_reg:
	ds.l	1
d1_reg:
	ds.l	1
d2_reg:
	ds.l	1
d3_reg:
	ds.l	1
d4_reg:
	ds.l	1
d5_reg:
	ds.l	1
d6_reg:
	ds.l	1
d7_reg:
	ds.l	1
a0_reg:
	ds.l	1
a1_reg:
	ds.l	1
a2_reg:
	ds.l	1
a3_reg:
	ds.l	1
a4_reg:
	ds.l	1
a5_reg:
	ds.l	1
a6_reg:
	ds.l	1
a7_reg:
	ds.l	1
ssp_reg:
	ds.l	1
sr_reg:
	ds.w	1
pc_reg:
	ds.l	1
reso:
	ds.w	1
basepage_addr:
	ds.l	1
ro_addr:
	ds.l	1
logic_screen_addr:
	ds.l	1
string_addr:
	ds.l	1
coord:
	ds.w	2
character:
	ds.l	1
reput_exc:
	ds.b	1
IPL7:
	ds.b	1
timera:
	ds.b	1
timerb:
	ds.b	1
timerc:
	ds.b	1
timerd:
	ds.b	1
redraw_screen:
	ds.b	1
rs232_output:
	ds.b	1	
re_exec_ro:
	ds.b	1	

	;REMEMBER:
	;routines are relocated. They can have a bss and be non pc-relative.
	;they must be fully debugged before executed in ro form
	;(you can use the run routine command to test it from within Adebug).
	;they are called in SUPER mode, with their USP and SSP.
	;(they can be called in USER mode to by:
;Main:
;	bra.s	start
;	dc.l	'CODE'
;	dc.l	'USER'
;start:
;	... routine called in USER mode
	;they end with an RTS
	;(so they must also be in the same mode when terminating).

	;parameters:
	;a0 points to the ro structure
	;a1 points to the parameters structure
	;d0 is the parameters number
	
	end
