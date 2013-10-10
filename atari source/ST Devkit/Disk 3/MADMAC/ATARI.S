	.nlist			; 21-Jul-1987 lmd

;  N	************************************************************
;  O	****	PRELIMINARY ATARI ST EQUATES AND MACROS.	****
;  T	****	THIS FILE IS STILL MISSING DEFINITIONS, AND	****
;  E	****	MAY HAVE BUGS WE HAVEN'T CAUGHT YET.		****
; !!!	************************************************************

	.subttl	'Hardware Locations'
;
;	Atari ST hardware locations
;
memconf		= $ffff8001	; memory controller
dbaseh		= $ffff8201
dbasel		= $ffff8203	; display base low, high
vcounthi	= $ffff8205	; display counter low, medium, high
vcountmid	= $ffff8207
vcountlow	= $ffff8209
syncmode	= $ffff820a	; video	sync mode
color0		= $ffff8240	; color registers 0..15
color1		= $ffff8242
color2		= $ffff8244
color3		= $ffff8246
color4		= $ffff8248
color5		= $ffff824a
color6		= $ffff824c
color7		= $ffff824e
color8		= $ffff8250
color9		= $ffff8252
color10		= $ffff8254
color11		= $ffff8256
color12		= $ffff8258
color13		= $ffff825a
color14		= $ffff825c
color15		= $ffff825e
shiftmd		= $ffff8260	; shifter mode (resolution)

;--- DMA chip
;
diskctl		= $ffff8604	; disk controller data access
fifo		= $ffff8606	; DMA mode control
dmahigh		= $ffff8609	; DMA base high, medium, low
dmamid		= $ffff860b
dmalow		= $ffff860d

;--- 1770 registers
;
cmdreg		= $80		; 1770/FIFO command register select
trkreg		= $82		; 1770/FIFO track register select
secreg		= $84		; 1770/FIFO sector register select
datareg		= $86		; 1770/FIFO data register select

;--- Sound Chip
;
giselect	= $ffff8800	; (W) sound chip register select
giread		= $ffff8800	; (R) sound chip read-data
giwrite		= $ffff8802	; (W) sound chip write-data
gitoneaf	= 0		; channel A fine/coarse tune
gitoneac	= 1
gitonebf	= 2		; channel B
gitonebc	= 3
gitonecf	= 4		; channel C
gitonecc	= 5
ginoise		= 6		; noise generator control
gimixer		= 7		; I/O control/volume control register
giaamp		= 8		; channel A, B, C amplitude
gibamp		= 9
gicamp		= $a
gifienvlp	= $b		; envelope period fine, coarse tune
gicrnvlp	= $c
giporta		= $e		; GI register# for I/O port A
giportb		= $f		; Centronics output register

;--- Bits in "giporta":
;
xrts	= 8			; RTS output
dtr	= $10			; DTR output
strobe	= $20			; Centronics strobe output
gpo	= $40			; "general purpose" output

;--- 68901 (MFP)
;
mfp	= $fffffa00		; mfp base
gpip	= mfp+1			; general purpose I/O
aer	= mfp+3			; active edge reg
ddr	= mfp+5			; data direction reg
iera	= mfp+7			; interrupt enable A & B
ierb	= mfp+9
ipra	= mfp+$b		; interrupt pending A & B
iprb	= mfp+$d
isra	= mfp+$f		; interrupt inService A & B
isrb	= mfp+$11
imra	= mfp+$13		; interrupt mask A & B
imrb	= mfp+$15
vr	= mfp+$17		; interrupt vector base
tacr	= mfp+$19		; timer A control
tbcr	= mfp+$1b		; timer B control
tcdcr	= mfp+$1d		; timer C & D control
tadr	= mfp+$1f		; timer A data
tbdr	= mfp+$21		; timer B data
tcdr	= mfp+$23		; timer C data
tddr	= mfp+$25		; timer D data
scr	= mfp+$27		; sync char
ucr	= mfp+$29		; USART control reg
rsr	= mfp+$2b		; receiver status
tsr	= mfp+$2d		; transmit status
udr	= mfp+$2f		; USART data

;--- 6850s
;
keyctl	= $fffffc00		; keyboard ACIA control
keybd	= $fffffc02		; keyboard data
midictl	= $fffffc04		; MIDI ACIA control
midi	= $fffffc06		; MIDI data

	.subttl	'BIOS Variables'
;
;	BIOS Variables
;
etv_timer	=	$400	; vector for timer interrupt chain
etv_critic	=	$404	; vector for critical error chain
etv_term	=	$408	; vector for process terminate
etv_xtra	=	$40c	; 5 reserved vectors
memvalid	=	$420	; indicates system state on RESET
memcntlr	=	$424	; mem controller config nibble
resvalid	=	$426	; validates 'resvector'
resvector	=	$42a	; [RESET] bailout vector
phystop		=	$42e	; physical top of RAM
_membot		=	$432	; bottom of available memory;
_memtop		=	$436	; top of available memory;
memval2		=	$43a	; validates 'memcntlr' and 'memconf'
flock		=	$43e	; floppy disk/FIFO lock variable
seekrate	=	$440	; default floppy seek rate
_timr_ms	=	$442	; system timer calibration (in ms)
_fverify	=	$444	; nonzero: verify on floppy write
_bootdev	=	$446	; default boot device
palmode		=	$448	; nonzero ==> PAL mode
defshiftmd	=	$44a	; default video rez (first byte)
sshiftmd	=	$44c	; shadow for 'shiftmd' register
_v_bas_ad	=	$44e	; pointer to base of screen memory
vblsem		=	$452	; semaphore to enforce mutex in	vbl
nvbls		=	$454	; number of deferred vectors
_vblqueue	=	$456	; pointer to vector of deferred	vfuncs
colorptr	=	$45a	; pointer to palette setup (or NULL)
screenpt	=	$45e	; pointer to screen base setup (|NULL)
_vbclock	=	$462	; count	of unblocked vblanks
_frclock	=	$466	; count	of every vblank
hdv_init	=	$46a	; hard disk initialization
swv_vec		=	$46e	; video change-resolution bailout
hdv_bpb		=	$472	; disk "get BPB"
hdv_rw		=	$476	; disk read/write
hdv_boot	=	$47a	; disk "get boot sector"
hdv_mediach	=	$47e	; disk media change detect
_cmdload	=	$482	; nonzero: load COMMAND.COM from boot
conterm		=	$484	; console/vt52 bitSwitches (%%0..%%2)
trp14ret	=	$486	; saved return addr for _trap14
criticret	=	$48a	; saved return addr for _critic
themd		=	$48e	; memory descriptor (MD)
_____md		=	$49e	; (more MD)
savptr		=	$4a2	; pointer to register save area
_nflops		=	$4a6	; number of disks attached (0, 1+)
con_state	=	$4a8	; state of conout() parser
save_row	=	$4ac	; saved row# for cursor X-Y addressing
sav_context	=	$4ae	; pointer to saved processor context
_bufl		=	$4b2	; two buffer-list headers
_hz_200		=	$4ba	; 200hz raw system timer tick
_drvbits	=	$4c2	; bit vector of "live" block devices
_dskbufp	=	$4c6	; pointer to common disk buffer
_autopath	=	$4ca	; pointer to autoexec path (or NULL)
_vbl_list	=	$4ce	; initial _vblqueue (to $4ee)
_dumpflg	=	$4ee	; screen-dump flag
_prtabt		=	$4f0	; printer abort flag
_sysbase	=	$4f2	; -> base of OS
_shell_p	=	$4f6	; -> global shell info
end_os		=	$4fa	; -> end of OS memory usage
exec_os		=	$4fe	; -> address of shell to exec on startup
scr_dump	=	$502	; -> screen dump code
prv_lsto	=	$506	; -> _lstostat()
prv_lst		=	$50a	; -> _lstout()
prv_auxo	=	$50e	; -> _auxostat()
prv_aux		=	$512	; -> _auxout()

	.subttl	'"Line A" Equates'
;
;	"Line A" Equates
;
VPLANES	= 0
VWRAP	= 2
CONTRL	= 4
INTIN	= 8
PTSIN	= 12
INTOUT	= 16
PTSOUT	= 20
COLBIT0	= 24
COLBIT1	= 26
COLBIT2	= 28
COLBIT3	= 30
LSTLIN	= 32
LNMASK	= 34
WMODE	= 36
X1	= 38
Y1	= 40
X2	= 42
Y2	= 44
PATPTR	= 46
PATMSK	= 50
MFILL	= 52
CLIP	= 54
XMINCL	= 56
YMINCL	= 58
XMAXCL	= 60
YMAXCL	= 62
XDDA	= 64
DDAINC	= 66
SCALDIR	= 68
MONO	= 70
SRCX	= 72
SRCY	= 74
DSTX	= 76
DSTY	= 78
DELX	= 80
DELY	= 82
FBASE	= 84
FWIDTH	= 88
STYLE	= 90
LITEMSK	= 92
SKEWMSK	= 94
WEIGHT	= 96
ROFF	= 98
LOFF	= 100
SCALE	= 102
CHUP	= 104
TEXTFG	= 106
SCRTCHP	= 108
SCRPT2	= 112
TEXTBG	= 114
COPYTRAN = 116
SEEDABORT = 118

	.subttl	'"Line A" Macros'
;
;	"Line A" macros
;
.macro A_init
	dc.w	$a000
.endm
.macro A_putpix
	dc.w	$a001
.endm
.macro A_getpix
	dc.w	$a002
.endm
.macro A_abline
	dc.w	$a003
.endm
.macro A_habline
	dc.w	$a004
.endm
.macro A_rectfill
	dc.w	$a005
.endm
.macro A_polyfill
	dc.w	$a006
.endm
.macro A_bitblt
	dc.w	$a007
.endm
.macro A_textblt
	dc.w	$a008
.endm
.macro A_showcur
	dc.w	$a009
.endm
.macro A_hidecur
	dc.w	$a00a
.endm
.macro A_chgcur
	dc.w	$a00b
.endm
.macro A_drsprite
	dc.w	$a00c
.endm
.macro A_unsprite
	dc.w	$a00d
.endm
.macro A_copyrstr
	dc.w	$a00e
.endm
.macro A_seedfill
	dc.w	$a00f
.endm

	.subttl 'Operating System Macros'

.macro Bios trpno, clean		; trap to BIOS
	move.w	#\trpno,-(sp)
	trap	#13
	.if \clean <= 8
	addq	#\clean,sp
	.else
	add.w	#\clean,sp
	.endif
.endm

.macro Xbios trpno, clean		; trap to XBIOS
	move.w	#\trpno,-(sp)
	trap	#14
	.if \clean <= 8
	addq	#\clean,sp
	.else
	add.w	#\clean,sp
	.endif
.endm

.iif !(^^defined GEMDOS), GEMDOS = 1
.macro Gemdos trpno, clean		; trap to GEMDOS
	move.w	#\trpno,-(sp)
	trap	#GEMDOS
	.if \clean <= 8
	addq	#\clean,sp
	.else
	add.w	#\clean,sp
	.endif
.endm

;
;    String "foobar"		(push onto stack)
;    String "foobar",a0		move address of string somewhere
;
.macro String str,loc
	.if \?loc
	move.l	#.\~,\loc
	.else
	pea	.\~
	.endif
	.data
.\~:	dc.b	\str,0
	.text
.endm

	.subttl	'Bios Traps'

;--- Character Device Numbers
;
PRT = 0		; printer
AUX = 1		; RS-232
CON = 2		; console (vt-52 emulator)
MIDI = 3	; MIDI port
IKBD = 4	; ikbd (out only)
RAWCON = 5	; console (raw characters)

.macro Getmbp ptr
	move.l	\ptr,-(sp)
	Bios 0,4
.endm
.macro Bconstat dev
	move.w	\dev,-(sp)
	Bios 1,4
.endm
.macro Bconin dev
	move.w	\dev,-(sp)
	Bios 2,4
.endm
.macro Bconout dev, char
	move.w	\char,-(sp)
	move.w	\dev,-(sp)
	Bios 3,6
.endm
.macro Rwabs rwflag, buf, count, recno, dev
	move.w	\dev,-(sp)
	move.w	\recno,-(sp)
	move.w	\count,-(sp)
	move.l	\buf,-(sp)
	move.w	\rwflag,-(sp)
	Bios 4,14
.endm
.macro Setexc vecnum, vec
	move.l	\vec,-(sp)
	move.w	\vecnum,-(sp)
	Bios 5,8
.endm
.macro Tickcal
	Bios 6,2
.endm
.macro Getbpb devno
	move.w	\devno,-(sp)
	Bios 7,4
.endm
.macro Bcostat devno
	move.w \devno,-(sp)
	Bios 8,4
.endm
.macro Mediach devno
	move.w \devno,-(sp)
	Bios 9,4
.endm
.macro Drvmap
	Bios 10,2
.endm
.macro Kbshift mode
	move.w	\mode,-(sp)
	Bios 11,4
.endm

	.subttl	'Extended BIOS Traps'
.macro Initmous type, param, vec
	move.l	\vec,-(sp)
	move.l	\param,-(sp)
	move.w	\type,-(sp)
	Xbios 0,12
.endm
.macro Physbase
	Xbios 2,2
.endm
.macro Logbase
	Xbios 3,2
.endm
.macro Getrez
	Xbios 4,2
.endm
.macro Setscreen logloc, physloc, rez
	move.w	\rez,-(sp)
	move.l	\physloc,-(sp)
	move.l	\logloc,-(sp)
	Xbios	5,12
.endm
.macro Setpallete ptr
	move.l	\ptr,-(sp)
	Xbios	6,6
.endm
.macro Setcolor colnum, color
	move.w	\color,-(sp)
	move.w	\colnum,-(sp)
	Xbios	7,6
.endm
.macro Floprd buf, devno, sectno, trackno, sideno, count
	move.w	\count,-(sp)
	move.w	\sideno,-(sp)
	move.w	\trackno,-(sp)
	move.w	\sectno,-(sp)
	move.w	\devno,-(sp)
	clr.l	-(sp)	; (filler)
	move.l	\buf,-(sp)
	Xbios 8,20
.endm
.macro Flopwr buf, devno, sectno, trackno, sideno, count
	move.w	\count,-(sp)
	move.w	\sideno,-(sp)
	move.w	\trackno,-(sp)
	move.w	\sectno,-(sp)
	move.w	\devno,-(sp)
	clr.l	-(sp)	; (filler)
	move.l	\buf,-(sp)
	Xbios 9,20
.endm
.macro Flopfmt buf,devno,spt,trackno,sideno,interlv,magic,virgin
	move.w	\virgin,-(sp)
	move.l	\magic,-(sp)
	move.w	\interlv,-(sp)
	move.w	\sideno,-(sp)
	move.w	\trackno,-(sp)
	move.w	\spt,-(sp)
	move.w	\devno,-(sp)
	clr.l	-(sp)	; (filler)
	move.l	\buf,-(sp)
	Xbios $a,26
.endm
.macro Midiws cnt1,ptr
	move.l	\ptr,-(sp)
	move.w	\cnt1,-(sp)
	Xbios $c,8
.endm
.macro Random
	Xbios $11,2
.endm
.macro Protobt buf,serialno,disktype,execflag
	move.w	\execflag,-(sp)
	move.w	\disktype,-(sp)
	move.l	\serialno,-(sp)
	move.l	\buf,-(sp)
	Xbios $12,14
.endm
.macro Flopver buf, devno, sectno, trackno, sideno, count
	move.w	\count,-(sp)
	move.w	\sideno,-(sp)
	move.w	\trackno,-(sp)
	move.w	\sectno,-(sp)
	move.w	\devno,-(sp)
	clr.l	-(sp)	; (filler)
	move.l	\buf,-(sp)
	Xbios $13,20
.endm

CURS_HIDE	=	0
CURS_SHOW	=	1
CURS_BLINK	=	2
CURS_NOBLINK	=	3
CURS_SETRATE	=	4
CURS_GETRATE	=	5

.macro Cursconf func,op
	move.w	\op,-(sp)
	move.w	\func,-(sp)
	Xbios $15,6
.endm
.macro Settime datetime
	move.l	\datetime,-(sp)
	Xbios $16,6
.endm
.macro Gettime
	Xbios $17,2
.endm
.macro Kbdvbase
	Xbios $22,2
.endm
.macro Vsync
	Xbios $24,2
.endm
.macro Supexec where
	move.l	\where,-(sp)
	Xbios $26,6
.endm
	.subttl	'Gemdos Traps'
.macro Dsetdrv drive
	move.w	\drive,-(sp)
	Gemdos $e,4
.endm
.macro Pterm0
	clr.w	-(sp)
	trap	#GEMDOS
	illegal
.endm
.macro Pterm code
	.if \?code
	move.w	\code,-(sp)
	.else
	clr.w	-(sp)
	.endif
	move.w	#$4c,-(sp)
	trap	#GEMDOS
	illegal
.endm
.macro Super
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#GEMDOS
	addq	#6,sp
	move.l	d0,-(sp)
	move.w	#$20,-(sp)
.endm
.macro User
	trap	#GEMDOS
	addq	#6,sp
.endm
.macro Puts string
	move.l	\string,-(sp)
	Gemdos 9,6
.endm
.macro Tgetdate
	Gemdos $2a,2
.endm
.macro Tsetdate date
	move.w	\date,-(sp)
	Gemdos $2b,4
.endm
.macro Tgettime
	Gemdos $2c,2
.endm
.macro Tsettime time
	move.w	\time,-(sp)
	Gemdos $2d,4
.endm
.macro Fgetdta
	Gemdos $2f,0
.endm
.macro Sversion
	Gemdos $30,2
.endm
.macro Dfree buf,drive
	move.w	\drive,-(sp)
	move.l	\buf,-(sp)
	Gemdos $36,8
.endm
.macro Fopen file, mode
	move.w	\mode,-(sp)
	move.l	\file,-(sp)
	Gemdos $3d,8
.endm
.macro Fcreate file, mode
	move.w	\mode,-(sp)
	move.l	\file,-(sp)
	Gemdos $3c,8
.endm
.macro Fread handle, count, buf
	move.l	\buf,-(sp)
	move.l	\count,-(sp)
	move.w	\handle,-(sp)
	Gemdos $3f,12
.endm
.macro Fwrite handle, count, buf
	move.l	\buf,-(sp)
	move.l	\count,-(sp)
	move.w	\handle,-(sp)
	Gemdos $40,12
.endm
.macro Fclose handle
	move.w	\handle,-(sp)
	Gemdos $3e,4
.endm
.macro Fdelete file
	move.l	\file,-(sp)
	Gemdos $41,6
.endm
.macro Fseek offset, handle, mode
	move.w	\mode,-(sp)
	move.w	\handle,-(sp)
	move.l	\offset,-(sp)
	Gemdos $42,10
.endm
.macro Fsetdta addr
	move.l	\addr,-(sp)
	Gemdos $1a,6
.endm
.macro Ptermres count, retcode
	move.w	\retcode,-(sp)
	move.l	\count,-(sp)
	Gemdos $31,8
.endm
.macro Mshrink block, newsiz
	move.l	\newsiz,-(sp)
	move.l	\block,-(sp)
	clr.w	-(sp)
	Gemdos $4a,12
.endm
.macro Malloc amount
	move.l	\amount,-(sp)
	Gemdos $48,6
.endm
.macro Mfree addr
	move.l	\addr,-(sp)
	Gemdos $49,6
.endm
.macro Pexec mode, p1, p2, p3
	move.l	\p3,-(sp)
	move.l	\p2,-(sp)
	move.l	\p1,-(sp)
	move.w	\mode,-(sp)
	Gemdos $4b,16
.endm
.macro Fsfirst fspec, attr
	move.w	\attr,-(sp)
	move.l	\fspec,-(sp)
	Gemdos $4e,8
.endm
.macro Fsnext
	Gemdos $4f,2
.endm

	.subttl 'Structures'
;
;	Basepage Format
;
		.ABS
Plowtpa:	ds.l	1
Phitpa:		ds.l	1
Ptbase:		ds.l	1
Ptlen:		ds.l	1
Pdbase:		ds.l	1
Pdlen:		ds.l	1
Pbbase:		ds.l	1
Pblen:		ds.l	1
Pxdta:		ds.l	1
Pparent:	ds.l	1
;
;	  Searchfirst/Searchnext DTA structure
;
		.ABS
		ds.b	21
DTA_attr:	ds.b	1
DTA_time:	ds.w	1
DTA_date:	ds.w	1
DTA_size:	ds.l	1
DTA_name:	ds.b	14

	.TEXT
	.eject
	.list
