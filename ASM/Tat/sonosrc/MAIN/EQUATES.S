
* Obvious things:
OFF		equ	0
ON		equ	1


* Trap #6 Values:
T6_Load		EQU	0	;Load file.  A0 - Name, A1 - Address
T6_SetRes	EQU	1	;Set Resol.  A0 - Addr of SCP-file
T6_InstallDSP	EQU	2	;DSP Rout.   A0 - Addr of routine
T6_RunDSP	EQU	3	;Run .DSP.   A0 - Addr of routine
T6_Unpack	EQU	4	;Unpack file A0 - Addr of file
T6_GetMusic	EQU	5	;Get MusData A0 - RETVAL
T6_InstallVbl	EQU	6	;Set vbl ro  A0 - vbl routine (0=none)
T6_GetFeed	EQU	7	;Get feedback table address (A0)
T6_GetColour	EQU	8	;Get colour fade table address (A0)
T6_GetScreens	EQU	9	;get scrn pos addresses (a0.list)
T6_UpdateScreens EQU	10	;update scrns a0/a1/a2/a3
trap_6_maximum	EQU	11

* Main Script Offsets:
		RSRESET
prog_loadaddr	RS.L	1
prog_activeflag	RS.W	1
prog_filename	RS.B	1

* Aon_Data Offsets
			rsreset
aon_pos			rs.b	1	;actual pos while replaying 
aon_framecnt		rs.b	1	;0-aon_speed
aon_patcnt		rs.w	1	;-1= break pat
aon_looppoint		rs.b	1
aon_loopcnt		rs.b	1
aon_loopflag		rs.b	1
aon_statdata		rs.l	1	;address of static data in module
aon_arpdata		rs.l	1	;Pointer on arpeggio lists
aon_posdata		rs.l	1	;address of position tab
aon_pattdata		rs.l	1	;Pointer on patterns	(1st)
aon_patdelaycnt		rs.w	1
aon_wavestarts		rs.b	256	;adrs of waveforms (0-63)
aon_instrstarts		rs.b	256	;adrs of instruments (1-61)
aon_modulestart		rs.l	1	;Start of module
aon_replayMode		rs.b	1	;0=VBI,1=CIA A&B
aon_tempo		rs.b	1	;tempo 32-255 (bei cia-use speed=6)
aon_noiseavoid		rs.b	1
aon_oversize		rs.b	1
aon_dmaflag		rs.b	1+1
aon_dmacon		rs.w	1
aon_speed		rs.b	1	;0=off , 1-255
oldaudio		rs.l	1

; Falc additions:
aon_namedata		rs.l	1	;address of modname
aon_authdata		rs.l	1	;address of tommy... oops author
aon_datedata		rs.l	1	;address of date

aon_trackcount		rs.w	1	;number of tracks
aon_patternmultiplier	rs.w	1	;bytes/pattern
aon_stepmultiplier	rs.w	1	;bytes/step

aon_datasize		rs.w	1



blitter		equ	$ffff8a00
bl_htr		equ	blitter+0
bl_sxi		equ	blitter+$20
bl_syi		equ	blitter+$22
bl_saddr	equ	blitter+$24	;long
bl_eml		equ	blitter+$28
bl_emm		equ	blitter+$2a
bl_emr		equ	blitter+$2c
bl_dxi		equ	blitter+$2e
bl_dyi		equ	blitter+$30
bl_daddr	equ	blitter+$32	;long
bl_xcount	equ	blitter+$36
bl_ycount	equ	blitter+$38
bl_hop		equ	blitter+$3a	;byte
bl_logic	equ	blitter+$3b	;byte
bl_multi	equ	blitter+$3c	;byte
bl_shift	equ	blitter+$3d	;byte



*--------------------------- Macros ---------------------------
wait_transmit	macro
	btst	#1,$ffffa202.w
	beq.s	*-6
	endm

wait_receive	macro
	btst	#0,$ffffa202.w
	beq.s	*-6
	endm

