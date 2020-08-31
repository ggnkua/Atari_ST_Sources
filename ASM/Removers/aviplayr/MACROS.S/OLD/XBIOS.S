********************
* Constantes XBIOS *
********************

C2:	equ	%000
C4:	equ	%001
C16:	equ	%010
C256:	equ	%011
TC:	equ	%100

COL40:	equ	%0000
COL80:	equ	%1000

TV:	equ	%00000
VGA:	equ	%10000

NTSC:	equ	%000000
PAL:	equ	%100000

OVERSCAN:	equ	%1000000

STCOMP:	equ	%10000000

NONENTRELACE:	equ	%000000000
ENTRELACE:	equ	%100000000

SIMPLELIGNE:	equ	%000000000
DOUBLELIGNE:	equ	%100000000

DMAPLAY:	equ	0
DSPXMIT:	equ	1
EXTINP:		equ	2
ADC:		equ	3

DMAREC:		equ	%0001
DSPRECV:	equ	%0010
EXTOUT:		equ	%0100
DAC:		equ	%1000

LTATTEN:	equ	0
RTATTEN:	equ	1
LTGAIN:		equ	2
RTGAIN:		equ	3
ADDERIN:	equ	4
ADCINPUT:	equ	5
SETPRESCALE:	equ	6

****************
* Macros XBIOS *
****************
Initmous	macro
	pea	\3
	pea	\2
	move.w	\1,-(sp)
	clr.w	-(sp)
	trap	#14
	lea	12(sp),sp
	endm
	
Ssbrk	macro
	move.w	\1,-(sp)
	move.w	#1,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Physbase	macro
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Logbase	macro
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Getrez	macro
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Setscreen	macro
	if	\?4
		move.w	\4,-(sp)
	endif
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	if	\?4
		lea	14(sp),sp
	else
		lea	12(sp),sp
	endif
	endm	

Setpalette	macro
	pea	\1
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Setcolor	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Floprd	macro
	move.w	\6,-(sp)
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	clr.l	-(sp)
	pea	\1
	move.w	#8,-(sp)
	trap	#14
	lea	20(sp),sp
	endm
	
Flopwr	macro
	move.w	\6,-(sp)
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	clr.l	-(sp)
	pea	\1
	move.w	#9,-(sp)
	trap	#14
	lea	20(sp),sp
	endm	
	
Flopfmt	macro
	move.w	\8,-(sp)
	move.l	\7,-(sp)
	move.w	\6,-(sp)
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	clr.l	-(sp)
	pea	\1
	move.w	#10,-(sp)
	trap	#14
	lea	26(sp),sp
	endm
	
Midiws	macro
	pea	\2
	move.w	\1,-(sp)
	move.w	#12,-(sp)
	trap	#14
	addq.l	#8,sp
	endm
	
Mfpint	macro
	pea	\2
	move.w	\1,-(sp)
	move.w	#13,-(sp)
	trap	#14
	addq.l	#8,sp
	endm
	
Iorec	macro
	move.w	\1,-(sp)
	move.w	#14,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Rsconf	macro
	move.w	\6,-(sp)
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#15,-(sp)
	trap	#14
	lea	14(sp),sp
	endm
	
Keytbl	macro
	pea	\3
	pea	\2
	pea	\1
	move.w	#16,-(sp)
	trap	#14
	lea	14(sp),sp
	endm
	
Random	macro
	move.w	#17,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Protobt	macro
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	pea	\1
	move.w	#18,-(sp)
	trap	#14
	lea	14(sp),sp
	endm
	
Flopver	macro
	move.w	\6,-(sp)
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	clr.l	-(sp)
	pea	\1
	move.w	#19,-(sp)
	trap	#14
	lea	20(sp),sp
	endm
	
Scrdmp	macro
	move.w	#20,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Cursconf	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#21,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Settime	macro
	move.l	\1,-(sp)
	move.w	#22,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Gettime	macro
	move.w	#23,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Bioskey	macro
	move.w	#24,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Ikbdws	macro
	pea	\2
	move.w	\1,-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	endm
	
Jdisint	macro
	move.w	\1,-(sp)
	move.w	#26,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Jenabint	macro
	move.w	\1,-(sp)
	move.w	#27,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Giacces	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#28,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Offgibit	macro
	move.w	\1,-(sp)
	move.w	#29,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Ongibit	macro
	move.w	\1,-(sp)
	move.w	#30,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Xbtimer	macro
	pea	\4
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#31,-(sp)
	trap	#14
	lea	12(sp),sp
	endm
	
Dosound	macro
	pea	\1
	move.w	#32,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Setprt	macro
	move.w	\1,-(sp)
	move.w	#33,-(sp)
	trap	#13
	addq.l	#4,sp
	endm

**************
* Kbdvbase() *
**************
KBDVECS	rsstruct
midivec		rs.l	1
vkbderr		rs.l	1
vmiderr		rs.l	1
statvec		rs.l	1
mousevec	rs.l	1
clockvec	rs.l	1
joyvec		rs.l	1
midisys		rs.l	1
ikbdsys		rs.l	1
ikbdstate	rs.b	1
sizeof		rs.b	0
	rsend
	
Kbdvbase	macro
	move.w	#34,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Kbrate	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#35,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Prtblk	macro
	pea	\1
	move.w	#36,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Vsync	macro
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Supexec	macro
	pea	\1
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Puntaes	macro
	move.w	#39,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Dmaread	macro
	move.w	\4,-(sp)
	pea	\3
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#42,-(sp)
	trap	#14
	lea	14(sp),sp
	endm
	
Dmawrite	macro
	move.w	\4,-(sp)
	pea	\3
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#43,-(sp)
	trap	#14
	lea	14(sp),sp
	endm
	
********************
* Bconmap(devno.w) *
********************
BMAP_CHECK	equ	0
BMAP_INQUIRE	equ	-1
BMAP_MAPTAB	equ	-2

MAPTAB	rsstruct
Bconstat	rs.l	1
Bconin		rs.l	1
Bcostat		rs.l	1
Bconout		rs.l	1
Rsconf		rs.l	1
iorec		rs.l	1
sizeof		rs.b	0
	rsend

BCONMAP	rsstruct
maptab		rs.l	1
maptabsize	rs.w	1
sizeof		rs.b	0
	rsend
	
Bconmap	macro
	move.w	\1,-(sp)
	move.w	#44,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Nvmacces	macro
	pea	\4
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#46,-(sp)
	trap	#14
	lea	12(sp),sp
	endm
	
Metainit	macro
	pea	\1
	move.w	#48,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
********************
* Blitmode(mode.w) *
********************
BLIT_SOFT	equ	0
BLIT_HARD	equ	1

Blitmode	macro
	move.w	\1,-(sp)
	move.w	#64,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Floprate	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#65,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Esetshift	macro
	move.w	\1,-(sp)
	move.w	#80,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Egetshift	macro
	move.w	#81,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Esetbank	macro
	move.w	\1,-(sp)
	move.w	#82,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Esetcolor	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#83,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Esetpalette	macro
	pea	\3
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#84,-(sp)
	trap	#14
	lea	10(sp),sp
	endm
	
Egetpalette	macro
	pea	\3
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#85,-(sp)
	trap	#14
	lea	10(sp),sp
	endm
		
Esetgray	macro
	move.w	\1,-(sp)
	move.w	#86,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Esetsmear	macro
	move.w	\1,-(sp)
	move.w	#87,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Vsetmode	macro
	move.w	\1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Mon_type	macro
	move.w	#89,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Vsetsync	macro
	move.w	\1,-(sp)
	move.w	#90,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Vgetsize	macro
	move.w	\1,-(sp)
	move.w	#91,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Vsetrgb	macro
	pea	\3
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#93,-(sp)
	trap	#14
	lea	10(sp),sp
	endm
	
Vgetrgb	macro
	pea	\3
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#94,-(sp)
	trap	#14
	lea	10(sp),sp
	endm
	
Dsp_doblock	macro
	move.l	\4,-(sp)
	pea	\3
	move.l	\2,-(sp)
	pea	\1
	move.w	#96,-(sp)
	trap	#14
	lea	18(sp),sp
	endm
	
Dsp_blkhandshake	macro
	move.l	\4,-(sp)
	pea	\3
	move.l	\2,-(sp)
	pea	\1
	move.w	#97,-(sp)
	trap	#14
	lea	18(sp),sp
	endm
	
Dsp_blkunpacked	macro
	move.l	\4,-(sp)
	pea	\3
	move.l	\2,-(sp)
	pea	\1
	move.w	#98,-(sp)
	trap	#14
	lea	18(sp),sp
	endm
	
Dsp_instream	macro
	pea	\4
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	pea	\1
	move.w	#99,-(sp)
	trap	#14
	lea	18(sp),sp
	endm
	
Dsp_outstream	macro
	pea	\4
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	pea	\1
	move.w	#100,-(sp)
	trap	#14
	lea	18(sp),sp
	endm
	
Dsp_iostream	macro
	pea	\6
	move.l	\5,-(sp)
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	pea	\2
	pea	\1
	move.w	#101,-(sp)
	trap	#14
	lea	26(sp),sp
	endm
	
Dsp_removeinterrupts	macro
	move.w	\1,-(sp)
	move.w	#102,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Dsp_getwordsize	macro
	move.w	#103,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Dsp_lock	macro
	move.w	#104,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Dsp_unlock	macro
	move.w	#105,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Dsp_available	macro
	pea	\2
	pea	\1
	move.w	#106,-(sp)
	trap	#14
	lea	10(sp),sp
	endm
	
Dsp_reserve	macro
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#107,-(sp)
	trap	#14
	lea	10(sp),sp
	endm
	
Dsp_loadprog	macro
	pea	\3
	move.w	\2,-(sp)
	pea	\1
	move.w	#108,-(sp)
	trap	#14
	lea	12(sp),sp
	endm
	
Dsp_execprog	macro
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	pea	\1
	move.w	#109,-(sp)
	trap	#14
	lea	12(sp),sp
	endm
	
Dsp_execboot	macro
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	pea	\1
	move.w	#110,-(sp)
	trap	#14
	lea	12(sp),sp
	endm
	
Dsp_lodtobinary	macro
	pea	\2
	pea	\1
	move.w	#111,-(sp)
	trap	#14
	lea	10(sp),sp
	endm
	
Dsp_triggerhc	macro
	move.w	\1,-(sp)
	move.w	#112,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Dsp_requestuniqueability	macro
	move.w	#113,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Dsp_getprogability	macro
	move.w	#114,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Dsp_flushsubroutines	macro
	move.w	#115,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Dsp_loadsubroutine	macro
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	pea	\1
	move.w	#116,-(sp)
	trap	#14
	lea	12(sp),sp
	endm
	
Dsp_inqsubrability	macro
	move.w	\1,-(sp)
	move.w	#117,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Dsp_runsubroutine	macro
	move.w	\1,-(sp)
	move.w	#118,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Dsp_hf0	macro
	move.w	\1,-(sp)
	move.w	#119,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
Dsp_hf1	macro
	move.w	\1,-(sp)
	move.w	#120,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Dsp_hf2	macro
	move.w	#121,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Dsp_hf3	macro
	move.w	#122,-(sp)
	trap	#14
	addq.l	#2,sp
	endm	

Dsp_blkwords	macro
	move.l	\4,-(sp)
	pea	\3
	move.l	\2,-(sp)
	pea	\1
	move.w	#123,-(sp)
	trap	#14
	lea	18(sp),sp
	endm
	
Dsp_blkbytes	macro
	move.l	\4,-(sp)
	pea	\3
	move.l	\2,-(sp)
	pea	\1
	move.w	#124,-(sp)
	trap	#14
	lea	18(sp),sp
	endm
	
Dsp_hstat	macro
	move.w	#125,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Dsp_setvectors	macro
	pea	\2
	pea	\1
	move.w	#126,-(sp)
	trap	#14
	lea	10(sp),sp
	endm
	
Dsp_multblocks	macro
	pea	\4
	pea	\3
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#127,-(sp)
	trap	#14
	lea	18(sp),sp
	endm
	
Locksnd	macro
	move.w	#128,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Unlocksnd	macro
	move.w	#129,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
Soundcmd	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Setbuffer	macro
	IFC	'\3','d0'
	move.l	d0,-(sp)
	ELSE
		IFC	'\3','d1'
		move.l	d1,-(sp)
		ELSE
			IFC	'\3','d2'
			move.l	d2,-(sp)
			ELSE
				IFC	'\3','d3'
				move.l	d3,-(sp)
				ELSE
					IFC	'\3','d4'
					move.l	d4,-(sp)
					ELSE
						IFC	'\3','d5'
						move.l	d5,-(sp)
						ELSE
							IFC	'\3','d6'
							move.l	d6,-(sp)
							ELSE
								IFC	'\3','d7'
								move.l	d7,-(sp)
								ELSE
								pea	\3
								ENDC
							ENDC
						ENDC
					ENDC
				ENDC
			ENDC
		ENDC
	ENDC
	IFC	'\2','d0'
	move.l	d0,-(sp)
	ELSE
		IFC	'\2','d1'
		move.l	d1,-(sp)
		ELSE
			IFC	'\2','d2'
			move.l	d2,-(sp)
			ELSE
				IFC	'\2','d3'
				move.l	d3,-(sp)
				ELSE
					IFC	'\2','d4'
					move.l	d4,-(sp)
					ELSE
						IFC	'\2','d5'
						move.l	d5,-(sp)
						ELSE
							IFC	'\2','d6'
							move.l	d6,-(sp)
							ELSE
								IFC	'\2','d7'
								move.l	d7,-(sp)
								ELSE
								pea	\2
								ENDC
							ENDC
						ENDC
					ENDC
				ENDC
			ENDC
		ENDC
	ENDC
	move.w	\1,-(sp)
	move.w	#131,-(sp)
	trap	#14
	lea	12(sp),sp
	endm
	
Setmode	macro
	move.w	\1,-(sp)
	move.w	#132,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Settracks	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#133,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Setmontracks	macro
	move.w	\1,-(sp)
	move.w	#134,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Setinterrupt	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#135,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Buffoper	macro
	move.w	\1,-(sp)
	move.w	#136,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Dsptristate	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#137,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Gpio	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#138,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
Devconnect	macro
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#139,-(sp)
	trap	#14
	lea	12(sp),sp
	endm
	
Sndstatus	macro
	move.w	\1,-(sp)
	move.w	#140,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
	
Buffptr	macro
	pea	\1
	move.w	#141,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	 