* XBIOS macro definitions
*  by James Ingram, April 1993
*
* may be INCLUDED in files

xbios_definitions	equ	1

trap14	macro
	move.w	#\1,-(a7)
	trap	#14

	IIF	\2<8	addq.l	#\2,a7
	IIF	\2=8	addq.l	#\2,a7
	IIF	\2>8	lea	\2(a7),a7
	endm


init_mouse	macro
* need vector.L, params addr.L and type.W

	IFEQ	NARG=3
	fail	need vector.L, parameters addr.L and type.W
	MEXIT
	endc

	move.l	\1,-(a7)
	move.l	\2,-(a7)
	move.w	\3,-(a7)
	trap14	0,12
	endm


ssbrk	macro

	IFEQ	NARG=1
	fail	need length.W
	MEXIT
	ENDC

	move.w	\1,-(a7)
	trap14	1,4
	endm


get_physbase	macro
	trap14	2,2
	endm

get_logbase	macro
	trap14	3,2
	endm


get_res	macro
	trap14	4,2
	endm


set_screen	macro

	IFEQ	NARG=3
	FAIL	need res.W, physbase.L and logbase.L
	MEXIT
	ENDC

	move.w	\1,-(a7)
	move.l	\2,-(a7)
	move.l	\3,-(a7)
	trap14	5,12
	endm


set_palette	macro
	IFEQ	NARG=1
	FAIL	need palette addr.L
	MEXIT
	ENDC

	move.l	\1,-(a7)
	trap14	6,6
	endm


set_colour	macro
	IFEQ	NARG=2
	FAIL	need RGB.W and col number.W
	MEXIT
	endc

	move.w	\1,-(a7)
	move.w	\2,-(a7)
	trap14	7,6
	endm


floprd	macro
	IFEQ	NARG=6
	FAIL	need count.W side.W track.W sector.W device.W buffer.L
	MEXIT
	ENDC

	move.w	\1,-(a7)
	move.w	\2,-(a7)
	move.w	\3,-(a7)
	move.w	\4,-(a7)
	move.w	\5,-(a7)
	clr.l	-(a7)
	move.l	\6,-(a7)
	trap14	8,20
	endm


flopwr	macro
	IFEQ	NARG=6
	FAIL	need count.W side.W track.W sector.W device.W buffer.L
	MEXIT
	ENDC

	move.w	\1,-(a7)
	move.w	\2,-(a7)
	move.w	\3,-(a7)
	move.w	\4,-(a7)
	move.w	\5,-(a7)
	clr.l	-(a7)
	move.l	\6,-(a7)
	trap14	9,20
	endm

flopfmt	macro
	IFEQ	NARG=8
	FAIL	need virgin.W magig.L interleave.W side.W track.W spt.W dev.W buffer.L
	MEXIT
	ENDC

	move.w	\1,-(a7)
	move.l	\2,-(a7)
	move.w	\3,-(a7)
	move.w	\4,-(a7)
	move.w	\5,-(a7)
	move.w	\6,-(a7)
	move.w	\7,-(a7)
	clr.l	-(a7)
	move.l	\8,-(a7)
	trap14	10,26
	endm


midiws	macro
	IFEQ	NARG=2
	FAIL	need addr.L and count-1.W
	MEXIT
	ENDC

	move.l	\1,-(a7)
	move.w	\2,-(a7)
	trap14	12,6
	endm



mfpint	macro
	IFEQ	NARG=2
	FAIL	need vector.L and int no.W
	MEXIT
	ENDC

	move.l	\1,-(a7)
	move.w	\2,-(a7)
	trap14	13,6
	endm


iorec	macro
	IFEQ	NARG=1
	FAIL	need device.W
	MEXIT
	ENDC

	move.w	\1,-(a7)
	trap14	14,4
	endm


rsconf	macro
	IFEQ	NARG=6
	FAIL	need scr.W tsr.W rsr.W ucr.W ctrl.W baud.W
	MEXIT
	ENDC

	move.w	\1,-(a7)
	move.w	\2,-(a7)
	move.w	\3,-(a7)
	move.w	\4,-(a7)
	move.w	\5,-(a7)
	move.w	\6,-(a7)
	trap14	15,14
	endm

keytbl	macro
	IFEQ	NARG=3
	FAIL	need capslock.L shift.L unshift.L
	MEXIt
	ENDC

	move.l	\1,-(a7)
	move.l	\2,-(a7)
	move.l	\3,-(a7)
	trap14	16,14
	endm


random	macro
	trap14	17,2
	endm


protobt	macro
	IFEQ	NARG=4
	FAIL	need execflag.W disktype.W serialno.L buffer.L
	MEXIT
	ENDC

	move.w	\1,-(a7)
	move.w	\2,-(a7)
	move.l	\3,-(a7)
	move.l	\4,-(a7)
	trap14	18,14
	endm

flopver	macro
	IFEQ	NARG=6
	FAIL	need count.W side.W track.W sector.W dev.W buffer.L
	MEXIt
	ENDC

	move.w	\1,-(a7)
	move.w	\2,-(a7)
	move.w	\3,-(a7)
	move.w	\4,-(a7)
	move.w	\5,-(a7)
	clr.l	-(a7)
	move.l	\6,-(a7)
	trap14	19,20
	endm


scrdmp	macro
	trap14	20,2
	endm


cursconf	macro
	IFEQ	NARG=2
	FAIL	need rate.W function.W
	MEXIT
	ENDC

	move.w	\1,-(a7)
	move.w	\2,-(a7)
	trap14	21,6
	endm


settime	macro
	IFEQ	NARG=1
	FAIL	need time.L
	MEXIT
	ENDC

	move.l	\1,-(a7)
	trap14	22,6
	endm


gettime	macro
	trap14	23,2
	endm


bioskeys	macro
	trap14	24,2
	endm


ikbdws	macro
	IFEQ	NARG=2
	FAIL	need addr of data.W count-1.W
	MEXIT
	ENDC

	move.l	\1,-(a7)
	move.w	\2,-(a7)
	trap14	25,8
	endm


jdisint	macro
	IFEQ	NARG=1
	FAIL	need interrupt no.W
	MEXIT
	ENDC


	move.w	\1,-(a7)
	trap14	26,4
	endm


jenabint	macro
	IFEQ	NARG=1
	FAIL	need interrupt no.W
	MEXIT
	ENDC


	move.w	\1,-(a7)
	trap14	27,4
	endm


giaccess	macro
	IFEQ	NARG=2
	FAIL	need register.W data.W
	MEXIT
	ENDC

	move.w	\1,-(a7)
	move.w	\2,-(a7)
	trap14	28,6
	endm


offgibit	macro
	IFEQ	NARG=1
	FAIL	need bitnumber.W
	MEXIT
	ENDC

	move.w	\1,-(a7)
	trap14	29,4
	endm


ongibit	macro
	IFEQ	NARG=1
	FAIL	need bitnumber.W
	MEXIT
	ENDC

	move.w	\1,-(a7)
	trap14	30,4
	endm



xbtimer	macro
	IFEQ	NARG=4
	FAIL	need vector.L data.W control.W timer.W
	MEXIT
	ENDC

	move.l	\1,-(a7)
	move.w	\2,-(a7)
	move.w	\3,-(a7)
	move.w	\4,-(a7)
	trap14	31,12
	endm


dosound	macro
	IFEQ	NARG=1
	FAIL	need pointer.L
	MEXIT
	ENDC

	move.l	\1,-(a7)
	trap14	32,6
	endm


setprt	macro
	IFEQ	NARG=1
	FAIL	need config.W
	MEXIT
	ENDC

	move.w	\1,-(a7)
	trap14	33,4
	endm


kbdvbase	macro
	IFEQ	NARG=0
	FAIL	no parameters please!
	ENDC

	trap14	34,2
	endm

kbrate	macro
	IFEQ	NARG=2
	FAIL	need repeat.w and delay.w
	MEXIT
	ENDC

	move.w	\1,-(a7)
	move.w	\2,-(a7)
	trap14	35,5

	endm


prtblk	macro
	IFEQ	NARG=1
	FAIL	need pointer to param list.L
	MEXIT
	ENDC

	move.l	\1,-(a7)
	trap14	36,6
	endm


vsync	macro
	trap14	37,2
	endm


supexec	macro
	IFEQ	NARG=1
	FAIL	need addr or routine.L
	MEXIT
	ENDC

	move.l	\1,-(a7)
	trap14	38,6
	endm


puntaes	macro
	trap14	39,2
	endm


blitmode	macro
	IFEQ	NARG=1
	FAIL	need flag.W
	MEXIT
	ENDC

	move.w	\1,-(a7)
	trap14	64,4
	endm



