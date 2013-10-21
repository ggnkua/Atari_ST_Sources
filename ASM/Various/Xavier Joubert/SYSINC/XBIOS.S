;	Xbios

BMAP_CHECK	=	0
BMAP_INQUIRE	=	-1
BMAP_MAPTAB	=	-2

BLIT_SOFT	=	0
BLIT_HARD	=	1

PLAY_ENABLE	=	1
PLAY_REPEAT	=	2
RECORD_ENABLE	=	4
RECORD_REPEAT	=	8

CURS_HIDE	=	0
CURS_SHOW	=	1
CURS_BLINK	=	2
CURS_NOBLINK	=	3
CURS_SETRATE	=	4
CURS_GETRATE	=	5

DMAPLAY	=	0
DSPXMIT	=	1
EXTINP	=	2
ADC	=	3
DMAREC	=	1
DSPRECV	=	2
EXTOUT	=	4
DAC	=	8
CLK_25M	=	0
CLK_EXT	=	1
CLK_32M	=	2
CLK_COMPAT	=	0
CLK_50K	=	1
CLK_33K	=	2
CLK_25K	=	3
CLK_20K	=	4
CLK_16K	=	5
CLK_12K	=	7
CLK_10K	=	9
CLK_8K	=	11
HANDSHAKE	=	0
NO_SHAKE	=	1

SND_RESET	=	1

DS_INQUIRE	=	-1

HF_CLEAR	=	0
HF_SET	=	1
HF_INQUIRE	=	-1

ICR_RXDF	=	0
ICR_TXDE	=	1
ICR_TRDY	=	2
ICR_HF2	=	3
ICR_HF3	=	4
ICR_DMA	=	6
ICR_HREQ	=	7

RTS_OFF	=	1
RTR_OFF	=	2

DSPSEND_NOTHING	=	0
DSP_SEND_ZERO	=	$ff000000

DSP_TRISTATE	=	0
DSP_ENABLE	=	1

FRATE_6	=	0
FRATE_12	=	1
FRATE_2	=	2
FRATE_3	=	3

FLOP_DRIVEA	=	0
FLOP_DRIVEB	=	1

PSG_APITCHLOW	=	0
PSG_APITCHHIGH	=	1
PSG_BPITCHLOW	=	2
PSG_BPITCHHIGH	=	3
PSG_CPITCHLOW	=	4
PSG_CPITCHHIGH	=	5
PSG_NOISEPITCH	=	6
PSG_MODE	=	7
PSG_AVOLUME	=	8
PSG_BVOLUME	=	9
PSG_CVOLUME	=	10
PSG_FREQLOW	=	11
PSG_FREQHIGH	=	12
PSG_ENVELOPE	=	13
PSG_PORTA	=	14
PSG_PORTB	=	15

GPIO_INQUIRE	=	0
GPIO_READ	=	1
GPIO_WRITE	=	2

IM_DISABLE	=	0
IM_RELATIVE	=	1
IM_ABSOLUTE	=	2
IM_KEYCODE	=	4

IO_SERIAL	=	0
IO_KEYBOARD	=	1
IO_MIDI	=	2

SNDLOCKED	=	-129

MFP_PARALLEL	=	0
MFP_DCD	=	1
MFP_CTS	=	2
MFP_BITBLT	=	3
MFP_TIMERD	=	4
MFP_TIMERC	=	5
MFP_ACIA	=	6
MFP_DISK	=	7
MFP_TIMERB	=	8
MFP_TERR	=	9
MFP_TBE	=	10
MFP_RERR	=	11
MFP_RBF	=	12
MFP_TIMERA	=	13
MFP_RING	=	14
MFP_MONODETECT	=	15

NVM_READ	=	0
NVM_WRITE	=	1
NVM_RESET	=	2

GI_FLOPPYSIDE	=	1
GI_FLOPPYA	=	2
GI_FLOPPYB	=	4
GI_RTS	=	8
GI_DTR	=	16
GI_STROBE	=	32
GI_GPO	=	64
GI_SCCPORT	=	128

INT_TIMERA	=	0
INT_I7	=	1
INT_DISABLE	=	0
INT_PLAY	=	1
INT_RECORD	=	2
INT_BOTH	=	3

MODE_STEREO8	=	0
MODE_STEREO16	=	1
MODE_MONO	=	2

SNDINQUIRE	=	-1
LTATTEN	=	0
RTATTEN	=	1
LTGAIN	=	2
RTGAIN	=	3
ADDERIN	=	4
ADCINPUT	=	5
SETPRESCALE	=	6
ADDR_ADC	=	1
ADDR_MATRIX	=	2
LEFT_MIC	=	0
LEFT_PSG	=	1
RIGHT_MIC	=	0
RIGHT_PSG	=	2
CCLK_6K	=	0
CCLK_12K	=	1
CCLK_25K	=	2
CCLK_50K	=	3

SNDNOTLOCK	=	-128

MON_MONO	=	0
MON_COLOR	=	1
MON_VGA	=	2
MON_TV	=	3

OVERLAY_ON	=	1
OVERLAY_OFF	=	0

BPS1	=	0
BPS2	=	1
BPS4	=	2
BPS8	=	3
BPS16	=	4
COL80	=	8
COL40	=	0
VGA	=	16
TV	=	0
PAL	=	32
NTSC	=	0
OVERSCAN	=	64
STMODES	=	128
VERTFLAG	=	256

;_interlace	=	256
;_stcompatible	=	128
;_overscan	=	64
;_pal	=	32
;_vga	=	16
;_columns80	=	8
;_colortrue	=	4
;_color256	=	3
;_color16	=	2
;_color4	=	1
;_color2	=	0

VCLK_EXTERNAL	=	1
VCLK_EXTVSYNC	=	2
VCLK_EXTHSYNC	=	4

WP_MONO	=	0
WP_STEREO	=	1
WP_8BIT	=	0
WP_16BIT	=	2
WP_MACRO	=	256
AG_FIND	=	0
AG_REPLACE	=	1
AG_CUT	=	2
AG_COPY	=	3
AG_PASTE	=	4
AG_DELETE	=	5
AG_HELP	=	6
AG_PRINT	=	7
AG_SAVE	=	8
AG_ERROR	=	9
AG_QUIT	=	10

XB_TIMERA	=	0
XB_TIMERB	=	1
XB_TIMERC	=	2
XB_TIMERD	=	3

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
		
SETSCREEN	macro	logadr,physadr,rez,modecode
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
