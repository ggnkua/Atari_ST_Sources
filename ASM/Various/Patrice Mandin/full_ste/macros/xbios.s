;	Xbios

BMAP_CHECK	equ	0
BMAP_INQUIRE	equ	-1
BMAP_MAPTAB	equ	-2

BLIT_SOFT	equ	0
BLIT_HARD	equ	1

PLAY_ENABLE	equ	1
PLAY_REPEAT	equ	2
RECORD_ENABLE	equ	4
RECORD_REPEAT	equ	8

CURS_HIDE	equ	0
CURS_SHOW	equ	1
CURS_BLINK	equ	2
CURS_NOBLINK	equ	3
CURS_SETRATE	equ	4
CURS_GETRATE	equ	5

DMAPLAY	equ	0
DSPXMIT	equ	1
EXTINP	equ	2
ADC	equ	3
DMAREC	equ	1
DSPRECV	equ	2
EXTOUT	equ	4
DAC	equ	8
CLK_25M	equ	0
CLK_EXT	equ	1
CLK_32M	equ	2
CLK_COMPAT	equ	0
CLK_50K	equ	1
CLK_33K	equ	2
CLK_25K	equ	3
CLK_20K	equ	4
CLK_16K	equ	5
CLK_12K	equ	7
CLK_10K	equ	9
CLK_8K	equ	11
HANDSHAKE	equ	0
NO_SHAKE	equ	1

SND_RESET	equ	1

DS_INQUIRE	equ	-1

HF_CLEAR	equ	0
HF_SET	equ	1
HF_INQUIRE	equ	-1

ICR_RXDF	equ	0
ICR_TXDE	equ	1
ICR_TRDY	equ	2
ICR_HF2	equ	3
ICR_HF3	equ	4
ICR_DMA	equ	6
ICR_HREQ	equ	7

RTS_OFF	equ	1
RTR_OFF	equ	2

DSPSEND_NOTHING	equ	0
DSP_SEND_ZERO	equ	$ff000000

DSP_TRISTATE	equ	0
DSP_ENABLE	equ	1

FRATE_6	equ	0
FRATE_12	equ	1
FRATE_2	equ	2
FRATE_3	equ	3

FLOP_DRIVEA	equ	0
FLOP_DRIVEB	equ	1

PSG_APITCHLOW	equ	0
PSG_APITCHHIGH	equ	1
PSG_BPITCHLOW	equ	2
PSG_BPITCHHIGH	equ	3
PSG_CPITCHLOW	equ	4
PSG_CPITCHHIGH	equ	5
PSG_NOISEPITCH	equ	6
PSG_MODE	equ	7
PSG_AVOLUME	equ	8
PSG_BVOLUME	equ	9
PSG_CVOLUME	equ	10
PSG_FREQLOW	equ	11
PSG_FREQHIGH	equ	12
PSG_ENVELOPE	equ	13
PSG_PORTA	equ	14
PSG_PORTB	equ	15

GPIO_INQUIRE	equ	0
GPIO_READ	equ	1
GPIO_WRITE	equ	2

IM_DISABLE	equ	0
IM_RELATIVE	equ	1
IM_ABSOLUTE	equ	2
IM_KEYCODE	equ	4

IO_SERIAL	equ	0
IO_KEYBOARD	equ	1
IO_MIDI	equ	2

SNDLOCKED	equ	-129

MFP_PARALLEL	equ	0
MFP_DCD	equ	1
MFP_CTS	equ	2
MFP_BITBLT	equ	3
MFP_TIMERD	equ	4
MFP_TIMERC	equ	5
MFP_ACIA	equ	6
MFP_DISK	equ	7
MFP_TIMERB	equ	8
MFP_TERR	equ	9
MFP_TBE	equ	10
MFP_RERR	equ	11
MFP_RBF	equ	12
MFP_TIMERA	equ	13
MFP_RING	equ	14
MFP_MONODETECT	equ	15

NVM_READ	equ	0
NVM_WRITE	equ	1
NVM_RESET	equ	2

GI_FLOPPYSIDE	equ	1
GI_FLOPPYA	equ	2
GI_FLOPPYB	equ	4
GI_RTS	equ	8
GI_DTR	equ	16
GI_STROBE	equ	32
GI_GPO	equ	64
GI_SCCPORT	equ	128

INT_TIMERA	equ	0
INT_I7	equ	1
INT_DISABLE	equ	0
INT_PLAY	equ	1
INT_RECORD	equ	2
INT_BOTH	equ	3

MODE_STEREO8	equ	0
MODE_STEREO16	equ	1
MODE_MONO	equ	2

SNDINQUIRE	equ	-1
LTATTEN	equ	0
RTATTEN	equ	1
LTGAIN	equ	2
RTGAIN	equ	3
ADDERIN	equ	4
ADCINPUT	equ	5
SETPRESCALE	equ	6
ADDR_ADC	equ	1
ADDR_MATRIX	equ	2
LEFT_MIC	equ	0
LEFT_PSG	equ	1
RIGHT_MIC	equ	0
RIGHT_PSG	equ	2
CCLK_6K	equ	0
CCLK_12K	equ	1
CCLK_25K	equ	2
CCLK_50K	equ	3

SNDNOTLOCK	equ	-128

MON_MONO	equ	0
MON_COLOR	equ	1
MON_VGA	equ	2
MON_TV	equ	3

OVERLAY_ON	equ	1
OVERLAY_OFF	equ	0

BPS1	equ	0
BPS2	equ	1
BPS4	equ	2
BPS8	equ	3
BPS16	equ	4
COL80	equ	8
COL40	equ	0
VGA	equ	16
TV	equ	0
PAL	equ	32
NTSC	equ	0
OVERSCAN	equ	64
STMODES	equ	128
VERTFLAG	equ	256

;_interlace	equ	256
;_stcompatible	equ	128
;_overscan	equ	64
;_pal	equ	32
;_vga	equ	16
;_columns80	equ	8
;_colortrue	equ	4
;_color256	equ	3
;_color16	equ	2
;_color4	equ	1
;_color2	equ	0

VCLK_EXTERNAL	equ	1
VCLK_EXTVSYNC	equ	2
VCLK_EXTHSYNC	equ	4

WP_MONO	equ	0
WP_STEREO	equ	1
WP_8BIT	equ	0
WP_16BIT	equ	2
WP_MACRO	equ	256
AG_FIND	equ	0
AG_REPLACE	equ	1
AG_CUT	equ	2
AG_COPY	equ	3
AG_PASTE	equ	4
AG_DELETE	equ	5
AG_HELP	equ	6
AG_PRINT	equ	7
AG_SAVE	equ	8
AG_ERROR	equ	9
AG_QUIT	equ	10

XB_TIMERA	equ	0
XB_TIMERB	equ	1
XB_TIMERC	equ	2
XB_TIMERD	equ	3

;	ST functions

	TEXT

INITMOUS	macro	type,parametres,vecteur
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	clr	-(sp)
	trap	#14
	lea	12(sp),sp
	endm
		
SSBRK	macro	nombre
	move	\1,-(sp)
	move	#1,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

PHYSBASE	macro	
	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

LOGBASE	macro
	move	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
		
GETREZ	macro
	move	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
		
SETSCREEN	macro	logadr,physadr,rez
	IFEQ	NARG-4
	move	\4,-(sp)
	ENDC
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#5,-(sp)
	trap	#14
	IFEQ	NARG-4
	lea	14(sp),sp
	ELSE
	lea	12(sp),sp
	ENDC
	endm

SETPALETTE	macro	paletteptr
	move.l	\1,-(sp)
	move	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
		
SETCOLOR	macro	colornum,color
	move	\2,-(sp)
	move	\1,-(sp)
	move	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
		
FLOPRD	macro	buffer,filler,dev,secteur,piste,face,count
	move	\7,-(sp)
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#8,-(sp)
	trap	#14
	lea	20(sp),sp
	endm

FLOPWR	macro	buffer,filler,dev,secteur,piste,face,count
	move	\7,-(sp)
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#9,-(sp)
	trap	#14
	lea	20(sp),sp
	endm

FLOPFMT	macro	buffer,filler,dev,spt,piste,face,interleave,magic,virgin
	move	\9,-(sp)
	move.l	\8,-(sp)
	move	\7,-(sp)
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#10,-(sp)
	trap	#14
	lea	26(sp),sp
	endm
		
MIDIWS	macro	count,ptr
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#12,-(sp)
	trap	#14
	addq.l	#8,sp
	endm
		
MFPINT	macro	numero,vecteur
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#13,-(sp)
	trap	#14
	addq.l	#8,sp
	endm
		
IOREC	macro	dev
	move	\1,-(sp)
	move	#14,-(sp)
	trap	#14
	addq.l	#4,sp
	endm
		
RSCONF	macro	baud,ctrl,ucr,rsr,tsr,scr
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#15,-(sp)
	trap	#14
	lea	14(sp),sp
	endm

KEYTBL	macro	unshift,shift,capslock
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#16,-(sp)
	trap	#14
	lea	14(sp),sp
	endm

RANDOM	macro
	move	#17,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
		
PROTOBT	macro	buffer,serialnr,typedisque,execflag
	move	\4,-(sp)
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#18,-(sp)
	trap	#14
	lea	14(sp),sp
	endm
		
FLOPVER	macro	buffer,filler,dev,secteur,piste,face,count
	move	\7,-(sp)
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#19,-(sp)
	trap	#14
	lea	16(sp),sp
	endm
		
SCRDMP	macro
	move	#20,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
		
CURSCONF	macro	fonction,rate
	move	\2,-(sp)
	move	\1,-(sp)
	move	#21,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

SETTIME	macro	time
	move.l	\1,-(sp)
	move	#22,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

GETTIME	macro
	move	#23,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

BIOSKEYS	macro
	move	#24,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

IKBDWS	macro	nombre,pointeur
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	endm

JDISINT	macro	numero
	move	\1,-(sp)
	move	#26,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

JENABINT	macro	numero
	move	\1,-(sp)
	move	#27,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

GIACCESS	macro	donnees,registre
	move	\2,-(sp)
	move	\1,-(sp)
	move	#28,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

OFFGIBIT	macro	masquebits
	move	\1,-(sp)
	move	#29,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

ONGIBIT	macro	masquebits
	move	\1,-(sp)
	move	#30,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

XBTIMER	macro	timer,control,data,vector
	move.l	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#31,-(sp)
	trap	#14
	lea	12(sp),sp
	endm

DOSOUND	macro	pointeur
	move.l	\1,-(sp)
	move	#32,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
		
SETPRT	macro	config
	move	\1,-(sp)
	move	#33,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

KBDVBASE	macro
	move	#34,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

KBRATE	macro	kbrate
	move	\2,-(sp)
	move	\1,-(sp)
	move	#35,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

PRTBLK	macro	parametres
	move.l	\1,-(sp)
	move	#36,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

VSYNC	macro
	move	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

SUPEXEC	macro	adresse
	move.l	\1,-(sp)
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

PUNTAES	macro
	move	#39,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

BLITMODE	macro	flag
	move	\1,-(sp)
	move	#64,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

FLOPRATE	macro	dev,newrate
	move	\2,-(sp)
	move	\1,-(sp)
	move	#65,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
;	Falcon functions

BCONMAP	macro	devno
	move	\1,-(sp)
	move	#44,-(sp)
	trap	#14
	addq	#4,sp
	endm

VSETMODE	macro	mode
	move	\1,-(sp)
	move	#88,-(sp)
	trap	#14
	addq	#4,sp
	endm

VGETMONITOR	macro
	move	#89,-(sp)
	trap	#14
	addq	#2,sp
	endm
	
VSETSYNC	macro	external
	move	\2,-(sp)
	move	#90,-(sp)
	trap	#14
	addq	#4,sp
	endm
	
VGETSIZE	macro	mode
	move	\1,-(sp)
	move	#91,-(sp)
	trap	#14
	addq	#4,sp
	endm
	
VSETRGB	macro	index,count,array
	move.l	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#93,-(sp)
	trap	#14	
	lea	10(sp),sp
	endm
	
VGETRGB	macro	index,count,array
	move.l	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#94,-(sp)
	trap	#14	
	lea	10(sp),sp
	endm

DSP_DOBLOCK	macro	data_in,size_in,data_out,size_out
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#96,-(sp)
	trap	#14
	lea	18(sp),sp
	endm

DSP_BLKHANDSHAKE	macro	data_in,size_in,data_out,size_out
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#97,-(sp)
	trap	#14
	lea	18(sp),sp
	endm

DSP_BLKUNPACKED	macro	data_in,size_in,data_out,size_out
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#98,-(sp)
	trap	#14
	lea	18(sp),sp
	endm
	
DSP_INSTREAM	macro	data_in,block_size,num_blocks,blocks_done
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#99,-(sp)
	trap	#14
	lea	18(sp),sp
	endm

DSP_OUTSTREAM	macro	data_out,block_size,num_blocks,blocks_done
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#100,-(sp)
	trap	#14
	lea	18(sp),sp
	endm

DSP_IOSTREAM	macro	data_in,data_out,block_insize,block_outsize,num_blocks,blocksdone
	move.l	\6,-(sp)
	move.l	\5,-(sp)
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#101,-(sp)
	trap	#14
	lea	26(sp),sp
	endm

DSP_REMOVEINTERRUPTS	macro	mask
	move	\1,-(sp)
	move	#102,-(sp)
	trap	#14
	addq	#4,sp
	endm

DSP_GETWORDSIZE	macro
	move	#103,-(sp)
	trap	#14
	addq	#2,sp
	endm

DSP_LOCK	macro
	move	#104,-(sp)
	trap	#14
	addq	#2,sp
	endm

DSP_UNLOCK	macro
	move	#105,-(sp)
	trap	#14
	addq	#2,sp
	endm

DSP_AVAILABLE	macro	xavailable,yavailable
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#106,-(sp)
	trap	#14
	lea	10(sp),sp
	endm
	
DSP_RESERVE	macro	xreserve,yreserve
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#107,-(sp)
	trap	#14
	lea	10(sp),sp
	endm
	
DSP_LOADPROG	macro	file,ability,buffer
	move.l	\3,-(sp)
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#108,-(sp)
	trap	#14
	lea	12(sp),sp
	endm
	
DSP_EXECPROG	macro	codeptr,codesize,ability
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#109,-(sp)
	trap	#14
	lea	12(sp),sp
	endm

DSP_EXECBOOT	macro	codeptr,codesize,ability
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#110,-(sp)
	trap	#14
	lea	12(sp),sp
	endm

DSP_LODTOBINARY	macro	file,codeptr
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#111,-(sp)
	trap	#14
	lea	10(sp),sp
	endm

DSP_TRIGGERHC	macro	vector
	move	\1,-(sp)
	move	#112,-(sp)
	trap	#14
	addq	#4,sp
	endm

DSP_REQUESTUNIQUEABILITY	macro
	move	#113,-(sp)
	trap	#14
	addq	#2,sp
	endm

DSP_GETPROGABILITY	macro
	move	#114,-(sp)
	trap	#14
	addq	#2,sp
	endm

DSP_FLUSHSUBROUTINES	macro
	move	#115,-(sp)
	trap	#14
	addq	#2,sp
	endm

DSP_LOADSUBROUTINE	macro	ptr,size,ability
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#116,-(sp)
	trap	#14
	lea	12(sp),sp
	endm

DSP_INQSUBRABILITY	macro	ability
	move	\1,-(sp)
	move	#117,-(sp)
	trap	#14
	addq	#4,sp
	endm

DSP_RUNSUBROUTINE	macro	handle
	move	\1,-(sp)
	move	#118,-(sp)
	trap	#14
	addq	#4,sp
	endm

DSP_HF0	macro	flag
	move	\1,-(sp)
	move	#119,-(sp)
	trap	#14
	addq	#4,sp
	endm

DSP_HF1	macro	flag
	move	\1,-(sp)
	move	#120,-(sp)
	trap	#14
	addq	#4,sp
	endm

DSP_HF2	macro
	move	#121,-(sp)
	trap	#14
	addq	#2,sp
	endm

DSP_HF3	macro
	move	#122,-(sp)
	trap	#14
	addq	#2,sp
	endm

DSP_BLKWORDS	macro	data_in,size_in,data_out,size_out
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#123,-(sp)
	trap	#14
	lea	18(sp),sp
	endm

DSP_BLKBYTES	macro	data_in,size_in,data_out,size_out
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#124,-(sp)
	trap	#14
	lea	18(sp),sp
	endm

DSP_HSTAT	macro
	move	#125,-(sp)
	trap	#14
	addq	#2,sp
	endm

DSP_SETVECTORS	macro	receiver,transmitter
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#126,-(sp)
	trap	#14
	lea	10(sp),sp
	endm

DSP_MULTBLOCKS	macro	numsend,numreceive,sendblocks,receiveblocks	
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#127,-(sp)
	trap	#14
	lea	18(sp),sp
	endm

LOCKSND	macro
	move	#128,-(sp)
	trap	#14
	addq	#2,sp
	endm

UNLOCKSND	macro
	move	#129,-(sp)
	trap	#14
	addq	#2,sp
	endm
	
SOUNDCMD	macro	mode,data
	move	\2,-(sp)
	move	\1,-(sp)
	move	#130,-(sp)
	trap	#14
	addq	#6,sp
	endm
	
SETBUFFER	macro	reg,begaddr,endaddr
	move.l	\3,-(sp)	
	move.l	\2,-(sp)	
	move	\1,-(sp)	
	move	#131,-(sp)
	trap	#14
	lea	12(sp),sp
	endm
	
SETMODE	macro	mode
	move	\1,-(sp)
	move	#132,-(sp)
	trap	#14
	addq	#4,sp
	endm

SETTRACKS	macro	playtracks,rectracks
	move	\2,-(sp)
	move	\1,-(sp)
	move	#133,-(sp)
	trap	#14
	addq	#6,sp
	endm

SETMONTRACKS	macro	montrack
	move	\1,-(sp)
	move	#134,-(sp)
	trap	#14
	addq	#4,sp
	endm

SETINTERRUPT	macro	src_inter,cause
	move	\2,-(sp)
	move	\1,-(sp)
	move	#135,-(sp)
	trap	#14
	addq	#6,sp
	endm

BUFFOPER	macro	mode
	move	\1,-(sp)
	move	#136,-(sp)
	trap	#14
	addq	#4,sp
	endm

DSPTRISTATE	macro	dspxmit,dsprec
	move	\2,-(sp)
	move	\1,-(sp)
	move	#137,-(sp)
	trap	#14
	addq	#6,sp
	endm

GPIO	macro	mode,data
	move	\2,-(sp)
	move	\1,-(sp)
	move	#138,-(sp)
	trap	#14
	addq	#6,sp
	endm
	
DEVCONNECT	macro	src,dst,srcclk,prescale,protocol
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#139,-(sp)
	trap	#14
	lea	12(sp),sp
	endm

SNDSTATUS	macro	reset
	move	\1,-(sp)
	move	#140,-(sp)
	trap	#14
	addq	#4,sp
	endm

BUFFPTR	macro	pointer
	move.l	\1,-(sp)
	move	#141,-(sp)
	trap	#14
	addq	#6,sp
	endm

VSETMASK	macro	andmask,ormask
	move	\2,-(sp)
	move	\1,-(sp)
	move	#150,-(sp)
	trap	#14
	addq	#6,sp
	endm

DSPWAITINPUT	macro	adresse_dsp
.waitinput\@	btst	#1,\1
	beq.s	.waitinput\@
	endm

DSPWAITOUTPUT	macro	adresse_dsp
.waitoutput\@	btst	#0,\1
	beq.s	.waitoutput\@
	endm

BLTWAIT	macro	adresse_blitter
.waitblitter\@	tas	\1
	bmi.s	.waitblitter\@
	endm