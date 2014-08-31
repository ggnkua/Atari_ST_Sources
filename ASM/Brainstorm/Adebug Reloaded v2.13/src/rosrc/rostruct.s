	*************************** rostruct.s *************************
	* Communication structure between a routine (ro) and Adebug.   *
	* to be included at the beginning of your routine.             *
	****************************************************************

	*************************** rostruct.s *************************
	* Structure de communication entre une routine (ro) et Adebug. *
	* a mettre en include au debut du source de la routine.        *
	****************************************************************

RO	rsstruct
adbg_v	rs.w	1
sys_v	rs.w	1
w1	rs.l	1
w2	rs.l	1
w3	rs.l	1
w4	rs.l	1
w5	rs.l	1
text	rs.l	1
data	rs.l	1
bss	rs.l	1
end	rs.l	1
d0_reg	rs.l	1
d1_reg	rs.l	1
d2_reg	rs.l	1
d3_reg	rs.l	1
d4_reg	rs.l	1
d5_reg	rs.l	1
d6_reg	rs.l	1
d7_reg	rs.l	1
a0_reg	rs.l	1
a1_reg	rs.l	1
a2_reg	rs.l	1
a3_reg	rs.l	1
a4_reg	rs.l	1
a5_reg	rs.l	1
a6_reg	rs.l	1
a7_reg	rs.l	1
ssp_reg	rs.l	1
sr_reg	rs.w	1
pc_reg	rs.l	1
reso	rs.w	1
basepage	rs.l	1
ro_addr	rs.l	1
screen	rs.l	1
string	rs.l	1
reserved	rs.l	2
reput_exc	rs.b	1
IPL7	rs.b	1
timer1a	rs.b	1
timer1b	rs.b	1
timer1c	rs.b	1
timer1d	rs.b	1
timer2a	rs.b	1
timer2b	rs.b	1
timer2c	rs.b	1
timer2d	rs.b	1
redraw	rs.b	1
serial	rs.b	1	
	rsend

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
