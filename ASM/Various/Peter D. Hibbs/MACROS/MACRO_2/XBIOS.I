* Equates for accessing the Atari XBIOS
* =====================================
* Trap #14 = Vector 46 (address 184 or $B8)
* Can be called from User Mode or Supervisor Mode
* USE REGISTERS D0-D2/A0-A2
* any results are returned in d0

initmous	equ	0	;done
ssbrk	equ	1	;done
physbase	equ	2	;done
logbase	equ	3	;done
getrez	equ	4	;done
setscreen	equ	5	;done
setpallete	equ	6	;done
setpalette	equ	6	;done
setcolor	equ	7	;done
setcolour	equ	7	;done
floprd	equ	8	;done
flopwr	equ	9	;done
flopfmt	equ	10	;done

midiws	equ	12	;done
mfpint	equ	13
iorec	equ	14
rsconf	equ	15
keytbl	equ	16
random	equ	17
protobt	equ	18
flopver	equ	19
scrdmp	equ	20
cursconf	equ	21
settime	equ	22
gettime	equ	23
bioskeys	equ	24
ikbdws	equ	25
jdisint	equ	26
jenabint	equ	27
giaccess	equ	28
offgibit	equ	29
ongibit	equ	30
xbtimer	equ	31
dosound	equ	32
setprt	equ	33
kbdvbase	equ	34
kbrate	equ	35
prtblk	equ	36
vsync	equ	37
supexec	equ	38
puntaes	equ	39

floprate	equ	41
dmaread	equ	42
dmawrite	equ	43
bconmap	equ	44

nvmaccess	equ	46

blitmode	equ	64

esetshift	equ	80
egetshift	equ	81
esetbank	equ	82
esetcolor	equ	83
esetpalette	equ	84
egetpalette	equ	85
esetgray	equ	86
esetsmear	equ	87

vsetmode	equ	88	;done
mon_type	equ	89	;done
vsetsync	equ	90
vgetsize	equ	91	;done

vsetrgb		equ	93	;done
vgetrgb		equ	94	;done

dsp_doblock	equ	96
dsp_blkhandshake	equ	97
dsp_blkunpacked	equ	98
dsp_instream	equ	99
dsp_outstream	equ	100
dsp_iostream	equ	101
dsp_removeinterrupts	equ	102
dsp_getwordsize	equ	103
dsp_lock	equ	104
dsp_unlock	equ	105
dsp_available	equ	106
dsp_reserve	equ	107
dsp_loadprog	equ	108
dsp_execprog	equ	109
dsp_execboot	equ	110
dsp_lodtobinary	equ	111
dsp_triggerhc	equ	112
dsp_requestuniqueability	equ	113
dsp_getprogability	equ	114
dsp_flushsubroutines	equ	115
dsp_loadsubroutine	equ	116
dsp_inqsubrability	equ	117
dsp_runsubroutine	equ	118
dsp_hf0		equ	119
dsp_hf1		equ	120
dsp_hf2		equ	121
dsp_hf3		equ	122
dsp_blkwords	equ	123
dsp_blkbytes	equ	124
dsp_hstat	equ	125
dsp_setvectors	equ	126
dsp_multblocks	equ	127
locksnd		equ	128
unlocksnd	equ	129
soundcmd	equ	130
setbuffer	equ	131
setmode		equ	132	
settracks	equ	133
setmontracks	equ	134
setinterrupt	equ	135
buffoper	equ	136	;done
dsptristate	equ	137
gpio		equ	138
devconnect	equ	139
sndstatus	equ	140
buffptr		equ	141	;done

vsetmask	equ	150	;done

