*
* __ /\\\\\\\\____/\\\\\\\\__________
* \__\///////\\\_ /\\\/////__________\
*  \__ /\\\_\/\\\_\/\\\_ /\\\_________\
*   \__\///__\/\\\_\/\\\_\///_ Digital \
*    \__ /\\\\\\\\__\//\\\\\\\\_ Destiny\
*     \__\////////____\////////__________\
*
*	include.s - hardware registers, system variables and macros
*


* Magic numbers

BOOTMAGIC	equ	$1234		; magic checksum for boot sector
MEMMAGIC	equ	$752019f3	; validates 'memvalid'
MEMMAG2		equ	$237698aa	; validates 'memval2'
MEMMAG3		equ	$5555aaaa	; validates 'memval3'
RAMMAGIC	equ	$1357bd13	; validates 'ramtop'
RESMAGIC	equ	$31415926	; validates 'resvalid'

* Hardware

cartbase	equ $fa0000	; start	of cartridge ROM
cartsize	equ $20000	; size of cartridge (128K)

;--- Shifter
memconf		equ $ffff8001	; memory controller
monitortype	equ $ffff8006	; monitor type (F030)
clkcntl		equ $ffff8007	; Falcon clock control (F030)
dbaseh		equ $ffff8201	; display base high, mid, low
dbasem		equ $ffff8203
dbasel		equ $ffff820d
vcounth		equ $ffff8205	; display counter high, mid, low
vcountm		equ $ffff8207
vcountl		equ $ffff8209
syncmode	equ $ffff820a	; video	sync mode
nloffset	equ $ffff820e	; offset to next line (F030)
vwrapSTE	equ $ffff820f	; scan line width in words-1 (STe)
vwrap		equ $ffff8210	; scan line width in words (F030)
color0		equ $ffff8240	; ST color palette #0
shift		equ $ffff8260	; video	shift mode (ST,Falc)
shift2		equ $ffff8262	; video shift mode (TT)
hscrl		equ $ffff8265	; horizontal scroll register 0-15 (STe)
spshift		equ $ffff8266	;
	; 2 colour mode, True colour mode, ext hsync, ext vsync, bitplane
HHC		equ $ffff8280	; Horizontal Hold Counter
HHT		equ $ffff8282	; Horizontal Hold Timer
HBB		equ $ffff8284	; Horizontal Border Begin
HBE		equ $ffff8286	; Horizontal Border End
HDB		equ $ffff8288	; Horizontal Display Begin
HDE		equ $ffff828a	; Horizontal Display End
HSS		equ $ffff828c	; Horizontal SS
HFS		equ $ffff828e	; Horizontal FS
HEE		equ $ffff8290	; Horizontal EE
VFC		equ $ffff82a0	; Vertical Frequency Counter
VFT		equ $ffff82a2	; Vertical Frequency Timer
VBB		equ $ffff82a4	; Vertical Border Begin
VBE		equ $ffff82a6	; Vertical Border End (count in 1/2 lines)
VDB		equ $ffff82a8	; Vertical Display Begin
VDE		equ $ffff82aa	; Vertical Display End
VSS		equ $ffff82ac	; Vertical SS
VCO		equ $ffff82c0	; Video Control
	; pix quarter, pix halve, interlace, line halve
vmode		equ $ffff82c2	;

ttcolor0	equ $ffff8400	; TT background color reg
ttshiftmd	equ $ffff8262	; TT shift mode

;--- DMA chip
diskctl		equ $ffff8604	; disk controller data access
fifo		equ $ffff8606	; DMA mode control
dmahigh		equ $ffff8609	; DMA base high, mid, low
dmamid		equ $ffff860b
dmalow		equ $ffff860d

;--- 1770 registers
cmdreg		equ $80		; 1770/FIFO command register select
trkreg		equ $82		; 1770/FIFO track register select
secreg		equ $84		; 1770/FIFO sector register select
datareg		equ $86		; 1770/FIFO data register select

;--- Sound Chip
giselect	equ $ffff8800	; (W) sound chip register select
giread		equ $ffff8800	; (R) sound chip read-data
giwrite		equ $ffff8802	; (W) sound chip write-data
gitoneaf	equ 0		; channel A fine/coarse tune
gitoneac	equ 1
gitonebf	equ 2		; channel B
gitonebc	equ 3
gitonecf	equ 4		; channel C
gitonecc	equ 5
ginoise		equ 6		; noise generator control
gimixer		equ 7		; I/O control/volume control register
giaamp		equ 8		; channel A, B, C amplitude
gibamp		equ 9
gicamp		equ $a
gifienvlp	equ $b		; envelope period fine, coarse tune
gicrnvlp	equ $c
giporta		equ $e		; GI register# for I/O port A
giportb		equ $f		; Centronics output register

;--- Bits in "giporta":
xrts		equ 8		; RTS output
dtr		equ $10		; DTR output
strobe		equ $20		; Centronics strobe output
gpo		equ $40		; "general purpose" output

;--- 68901 (MFP)
mfp		equ $fffffa00	; mfp base

gpip		equ mfp+$01	; general purpose I/O
aer		equ mfp+$03	; active edge reg
ddr		equ mfp+$05	; data direction reg
iera		equ mfp+$07	; interrupt enable A & B
ierb		equ mfp+$09
ipra		equ mfp+$0b	; interrupt pending A & B
iprb		equ mfp+$0d
isra		equ mfp+$0f	; interrupt inService A & B
isrb		equ mfp+$11
imra		equ mfp+$13	; interrupt mask A & B
imrb		equ mfp+$15
vr		equ mfp+$17	; interrupt vector base
tacr		equ mfp+$19	; timer A control
tbcr		equ mfp+$1b	; timer B control
tcdcr		equ mfp+$1d	; timer C & D control
tadr		equ mfp+$1f	; timer A data
tbdr		equ mfp+$21	; timer B data
tcdr		equ mfp+$23	; timer C data
tddr		equ mfp+$25	; timer D data
scr		equ mfp+$27	; sync char
ucr		equ mfp+$29	; USART control reg
rsr		equ mfp+$2b	; receiver status
tsr		equ mfp+$2d	; transmit status
udr		equ mfp+$2f	; USART data

;--- TTMFP 68901
ttmfp		equ $fffffa80

ttgpip		equ ttmfp+$01	; general purpose I/O
ttaer		equ ttmfp+$03	; active edge reg
ttddr		equ ttmfp+$05	; data direction reg
ttiera		equ ttmfp+$07	; interrupt enable A & B
ttierb		equ ttmfp+$09
ttipra		equ ttmfp+$0b	; interrupt pending A & B
ttiprb		equ ttmfp+$0d
ttisra		equ ttmfp+$0f	; interrupt inService A & B
ttisrb		equ ttmfp+$11
ttimra		equ ttmfp+$13	; interrupt mask A & B
ttimrb		equ ttmfp+$15
ttvr		equ ttmfp+$17	; interrupt vector base
tttacr		equ ttmfp+$19	; timer A control
tttbcr		equ ttmfp+$1b	; timer B control
tttcdcr		equ ttmfp+$1d	; timer C & D control
tttadr		equ ttmfp+$1f	; timer A data
tttbdr		equ ttmfp+$21	; timer B data
tttcdr		equ ttmfp+$23	; timer C data
tttddr		equ ttmfp+$25	; timer D data
ttscr		equ ttmfp+$27	; sync char
ttucr		equ ttmfp+$29	; USART control reg
ttrsr		equ ttmfp+$2b	; receiver status
tttsr		equ ttmfp+$2d	; transmit status
ttudr		equ ttmfp+$2f	; USART data

;--- 6850s
keyctl		equ $fffffc00	; keyboard ACIA control
keybd		equ $fffffc02	; keyboard data
midictl		equ $fffffc04	; MIDI ACIA control
midi		equ $fffffc06	; MIDI data


* BIOS variables

;--- "extended" trap vectors:
etv_timer	equ $400	; vector for timer interrupt chain
etv_critic	equ $404	; vector for critical error chain
etv_term	equ $408	; vector for process terminate
etv_xtra	equ $40c	; 5 reserved vectors

memvalid	equ $420	; indicates system state on RESET
memcntlr	equ $424	; mem controller config nibble
resvalid	equ $426	; validates 'resvector'
resvector	equ $42a	; [RESET] bailout vector
phystop		equ $42e	; physical top of RAM
_membot		equ $432	; bottom of available memory;
_memtop		equ $436	; top of available memory;
memval2		equ $43a	; validates 'memcntlr' and 'memconf'
flock		equ $43e	; floppy disk/FIFO lock variable
seekrate	equ $440	; default floppy seek rate
_timr_ms	equ $442	; system timer calibration (in ms)
_fverify	equ $444	; nonzero: verify on floppy write
_bootdev	equ $446	; default boot device
palmode		equ $448	; nonzero :: PAL mode
defshiftmd	equ $44a	; default video rez (first byte)
sshiftmd	equ $44c	; shadow for 'shiftmd' register
_v_bas_ad	equ $44e	; pointer to base of screen memory
vblsem		equ $452	; semaphore to enforce mutex in	vbl
nvbls		equ $454	; number of deferred vectors
_vblqueue	equ $456	; pointer to vector of deferred	vfuncs
colorptr	equ $45a	; pointer to palette setup (or NULL)
screenpt	equ $45e	; pointer to screen base setup (|NULL)
_vbclock	equ $462	; count	of unblocked vblanks
_frclock	equ $466	; count	of every vblank

hdv_init	equ $46a	; hard disk initialization
swv_vec		equ $46e	; video change-resolution bailout
hdv_bpb		equ $472	; disk "get BPB"
hdv_rw		equ $476	; disk read/write
hdv_boot	equ $47a	; disk "get boot sector"
hdv_mediach	equ $47e	; disk media change detect

_cmdload	equ $482	; nonzero: load COMMAND.COM from boot
conterm		equ $484	; console/vt52 bitSwitches (%%0..%%2)

themd		equ $48e	; memory descriptor (MD)
_____md		equ $49e	; (more MD)
savptr		equ $4a2	; pointer to register save area

_nflops		equ $4a6	; number of disks attached (0, 1+)
con_state	equ $4a8	; state of conout() parser
save_row	equ $4ac	; saved row# for cursor X-Y addressing
sav_context	equ $4ae	; pointer to saved processor context
_bufl		equ $4b2	; two buffer-list headers
_hz_200		equ $4ba	; 200hz raw system timer tick
_drvbits	equ $4c2	; bit vector of "live" block devices
_dskbufp	equ $4c6	; pointer to common disk buffer
_autopath	equ $4ca	; pointer to autoexec path (or NULL)
_vbl_list	equ $4ce	; initial _vblqueue (to $4ee)

_dumpflg	equ $4ee	; screen-dump flag
_prtabt		equ $4f0	; printer abort flag
_sysbase	equ $4f2	; -> base of OS
_shell_p	equ $4f6	; -> global shell info
end_os		equ $4fa	; -> end of OS memory usage
exec_os		equ $4fe	; -> address of shell to exec on startup
scr_dump	equ $502	; -> screen dump code

;--- character-output vectors for _prtblk():
prv_lsto	equ $506	; -> _lstostat()
prv_lst		equ $50a	; -> _lstout()
prv_auxo	equ $50e	; -> _auxostat()
prv_aux		equ $512	; -> _auxout()

pun_ptr		equ $516	; -> hard disk driver phys unit table
memval3		equ $51a	; memory validation

_longframe	equ $59e	; if nonzero, we're on >68000
_p_cookie	equ $5a0	; -> cookie jar
_ramtop		equ $5a4	; top of ram starting at $01000000
_ramvalid	equ $5a8	; _ramtop valid if rammagic ($1357bd13)
bell_hook	equ $5ac	; handler for bell
kcl_hook	equ $5b0	; handler for keyclick

* Trap macros

;--- trap to BIOS
Bios	macro	\1,\2
	move	#\1,-(sp)
	trap	#13
	ifgt	\2-8
	lea	\2(sp),sp
	else
	addq	#\2,sp
	endc
	endm

;--- trap to XBIOS
Xbios	macro	\1,\2
	move	#\1,-(sp)
	trap	#14
	ifgt	\2-8
	lea	\2(sp),sp
	else
	addq	#\2,sp
	endc
	endm

;--- trap to GEMDOS
Gemdos	macro	\1,\2
	move	#\1,-(sp)
	trap	#1
	ifgt	\2-8
	lea	\2(sp),sp
	else
	addq	#\2,sp
	endc
	endm


* BIOS macros

;--- character device numbers
PRT	equ	0	; printer
AUX	equ	1	; RS-232
CON	equ	2	; console (vt-52 emulator)
MIDI	equ	3	; MIDI port
IKBD	equ	4	; ikbd (out only)
RAWCON	equ	5	; console (raw characters)

;--- Get Memory Parameter Block
Getmpb	macro	\1		; buffer.l
	pea	\1
	Bios	0,4
	endm

;--- Get Input Device Status
Bconstat macro	\1		; devnum
	move	\1,-(sp)
	Bios	1,4
	endm


;--- Read a Character
Bconin	macro	\1		; devnum
	move	\1,-(sp)
	Bios	2,4
	endm

;--- Write a Character
Bconout macro	\1,\2		; devnum, char
	move	\1,-(sp)
	move	\2,-(sp)
	Bios	3,6
	endm

;--- Read/Write Disk Sectors
RD	equ	0	; read
WR	equ	1	; write
RDLMCS	equ	2	; read & leave media change status
WRLMCS	equ	3	; write & leave media change status

Rwabs	macro	\1,\2,\3,\4,\5	; drivenum, start, sectors, buffer.l, mode
	move	\1,-(sp)
	move	\2,-(sp)
	move	\3,-(sp)
	pea	\4
	move	\5,-(sp)
	Bios	4,14
	endm

;--- Read/Change Exception Vector
Setexec	macro	\1,\2		; vecaddr.l, vecnum
	pea	\1
	move	\2,-(sp)
	Bios	5,8
	endm

;--- Get Timer Calibration
Tickcal	macro
	Bios	6,2
	endm			; d0.l = ticklen

;--- Get BIOS Parameter Block
Getbpb	macro	\1		; drivenum
	move	\1,-(sp)
	Bios	7,4
	endm

;--- Get Output Device Status
Bcostat	macro	\1		; devnum
	move	\1,-(sp)
	Bios	8,4
	endm

;--- Get Media Change Status
Mediach	macro	\1		; drivenum
	move	\1,-(sp)
	Bios	9,4
	endm

;--- Find Valid Drive Numbers
Drvmap	macro
	Bios	10,2
	endm

;--- Read/Change Keyboard Shift Status
Kbshift	macro	\1		; mode
	move	\1,-(sp)
	Bios	11,4
	endm


* XBIOS macros

;--- Initialize Mouse
Initmous macro	\1,\2,\3	; vector.l, params.l, mode
	pea	\1
	pea	\2
	move	\3,-(sp)
	Xbios	0,12
	endm

;--- Get Screen RAM Physical Base Address
Physbase macro
	Xbios	2,2
	endm

;--- Get Screen RAM Logical Base Address
Logbase	macro
	Xbios	3,2
	endm

;--- Get Screen Resolution Mode
Getrez	macro
	Xbios	4,2
	endm

;--- Set Screen Parameters
Setscreen macro			; res, physaddr.l, logaddr.l
	move	\1,-(sp)
	pea	\2
	pea	\3
	Xbios	5,12
	endm

Vsetscreen macro
	move.w	\1,-(a7)
	move.w	\2,-(a7)
	pea	\3
	pea	\4
	Xbios	5,14
	endm

;--- Set Color Palette
Setpalette macro \1		; palette.l
	pea	\1
	Xbios	6,6
	endm

;--- Set Color Register
Setcolor macro	\1,\2		; newcolor, register
	move	\1,-(sp)
	move	\2,-(sp)
	Xbios	7,6
	endm

;--- Read Floppy Disk Sector
Floprd	macro \1,\2,\3,\4,\5,\6	; numsecs, sidenum, tracknum, secnum,
	move	\1,-(sp)	; devnum, buf.l
	move	\2,-(sp)
	move	\3,-(sp)
	move	\4,-(sp)
	move	\5,-(sp)
	clr.l	-(sp)
	pea	\6
	Xbios	8,20
	endm

;--- Write Floppy Disk Sector
Flopwr	macro \1,\2,\3,\4,\5,\6	; numsecs, sidenum, tracknum, secnum,
	move	\1,-(sp)	; devnum, buf.l
	move	\2,-(sp)
	move	\3,-(sp)
	move	\4,-(sp)
	move	\5,-(sp)
	clr.l	-(sp)
	pea	\6
	Xbios	9,20
	endm

;--- Format Floppy Disk Track
FMTINITIAL	equ	$e5e5		; data value on Flopfmt
FMTMAGIC	equ	$87654321	; validates Flopfmt

Flopfmt	macro	\1,\2,\3,\4,\5,\6,\7	; intrlev, sidenum, tracknum,
	move	#FMTINITIAL,-(sp)	; spt, devnum, skewtabl.l,
	move.l	#FMTMAGIC,-(sp)		; buffer.l
	move	\1,-(sp)
	move	\2,-(sp)
	move	\3,-(sp)
	move	\4,-(sp)
	move	\5,-(sp)
	pea	\6
	pea	\7
	Xbios	10,26
	endm

;--- Write String to MIDI Port
Midiws	macro	\1,\2		; buffer.l, bytes
	pea	\1
	move	\2,-(sp)
	Xbios	12,8
	endm

;--- Change MFP Interrupt Vector
Mfpint	macro	\1,\2		; vector.l, number
	pea	\1
	move	\2,-(sp)
	Xbios	13,8
	endm

;--- Get I/O Buffer Record
Iorec	macro	\1		; dev
	move	\1,-(sp)
	Xbios	14,4
	endm

;--- Configure RS-232 Port
Rsconf	macro	\1,\2,\3,\4,\5,\6	; scr, trs, rsr, ucr, handshake,
	move	\1,-(sp)		; speed
	move	\2,-(sp)
	move	\3,-(sp)
	move	\4,-(sp)
	move	\5,-(sp)
	move	\6,-(sp)
	Xbios	15,14
	endm

;--- Get/Set Keyboard Mapping Tables
Keytbl	macro	\1,\2,\3	; capslock.l, shift.l, unshift.l
	pea	\1
	pea	\2
	pea	\3
	Xbios	16,14
	endm

;--- Get Keyboard Vector Table Base Address
Kbdvbase macro
	Xbios	34,2
	endm

Vsetmode macro 			returns d0
	move.w	\1,-(sp)
	Xbios	$58,4
	endm


* GEMDOS macros

;--- End Process and Return to Parent
Pterm0	macro
	Gemdos	0,2
	endm

;--- Read Character from Standard Input & Echo
Cconin	macro
	Gemdos	1,2
	endm

;--- Write Character to Standard Output
Cconout	macro	\1
	move	\1,-(sp)
	Gemdos	2,4
	endm

;--- Read Character from Auxiliary Port
Cauxin	macro
	Gemdos	3,2
	endm

;--- Write Character to Standard Aux Port
Cauxout	macro	\1
	move	\1,-(sp)
	Gemdos	4,4
	endm

;--- Write Character to Standard print device
Cprnout	macro	\1
	move	\1,-(sp)
	Gemdos	5,4
	endm

;--- Raw I/O to standard input/output	$00ff as \1 means read, else write
Crawio	macro	\1
	move	\1,-(sp)
	Gemdos	6,4
	endm

;--- Raw Input from standard port
Crawin	macro
	Gemdos	7,2
	endm

;--- Read a character from standard input
Cnecin	macro
	Gemdos	8,2
	endm

;--- Write string to standard output
Cconws	macro	\1
	pea	\1
	Gemdos	9,6
	endm

;--- Read Edited String to Standard output
Cconrs	macro	\1
	pea	\1
	Gemdos	10,5
	endm

;--- Set User/Supervisor Mode
Super	macro	\1		; stack.l
	pea	\1
	Gemdos	$20,6
	endm

;--- Get Disk Transfer Address
dta_time_stamp	equ	22	offsets in DTA
dta_date_stamp	equ	24
dta_file_size	equ	26
dta_file_name	equ	30

Fgetdta	macro
	Gemdos	$2f,2
	endm

;--- Get Disk Free Space
Dfree	macro	\1,\2		; drivenum, buffer.l
	move	\1,-(sp)
	pea	\2
	Gemdos	$36,8
	endm

;--- Create Directory
Dcreate	macro	\1		; pathname.l
	pea	\1
	Gemdos	$39,6
	endm

;--- Delete Directory
Ddelete	macro	\1		; pathname.l
	pea	\1
	Gemdos	$3a,6
	endm

;--- Set Default Directory Path
Dsetpath macro	\1		; path.l
	pea	\1
	Gemdos	$3b,6
	endm

;--- Create File
Fcreate	macro	\1,\2		; attr, fname.l
	move	\1,-(sp)
	pea	\2
	Gemdos	$3c,8
	endm

;--- Open File
RDWR	equ	2

Fopen	macro	\1,\2		; mode, fname.l
	move	\1,-(sp)
	pea	\2
	Gemdos	$3d,8
	endm

;--- Close File
Fclose	macro	\1		; handle
	move	\1,-(sp)
	Gemdos	$3e,4
	endm

;--- Read File
Fread	macro	\1,\2,\3	; buffer.l, count.l, handle
	pea	\1
	move.l	\2,-(sp)
	move	\3,-(sp)
	Gemdos	$3f,12
	endm

;--- Write File
Fwrite	macro	\1,\2,\3	; buffer.l, count.l, handle
	pea	\1
	move.l	\2,-(sp)
	move	\3,-(sp)
	Gemdos	$40,12
	endm

;--- Delete File
Fdelete	macro	\1		; filename.l
	pea	\1
	Gemdos	$41,6
	endm

;--- Seek File
Fseek	macro	\1,\2,\3	; seekmode, handle, offset.l
	move	\1,-(sp)
	move	\2,-(sp)
	pea	\3
	Gemdos	$42,10
	endm

;--- Get/Set File Attributes
Fattrib	macro	\1,\2,\3	; newattr, mode, filename.l
	move	\1,-(sp)
	move	\2,-(sp)
	pea	\3
	Gemdos	$43,10
	endm

;--- Duplicate Standard File Handle
Fdup	macro	\1		; handle
	move	\1,-(sp)
	Gemdos	$45,4
	endm

;--- Replace Standard File Handle
Fforce	macro	\1,\2		; user, standard
	move	\1,-(sp)
	move	\2,-(sp)
	Gemdos	$46,6
	endm

;--- Get Default Directory Path
Dgetpath macro	\1,\2		; drivenum, buffer.l
	move	\1,-(sp)
	pea	\2
	Gemdos	$47,8
	endm

;--- Allocate Memory Block
Malloc	macro	\1		; bytes.l
	move.l	\1,-(sp)
	Gemdos	$48,6
	endm

;--- Free Memory Block
Mfree	macro	\1		; address.l
	pea	\1
	Gemdos	$49,6
	endm

;--- Shrink Memory Block
Mshrink	macro	\1,\2		; size.l, address.l
	move.l	\1,-(sp)
	pea	\2
	clr	-(sp)
	Gemdos	$4a,12
	endm

;--- Execute Process
Pexec	macro	\1,\2,\3,\4	; env.l, command.l, file.l, mode
	pea	\1
	pea	\2
	pea	\3
	move	\4,-(sp)
	Gemdos	$4b,14
	endm

;--- Terminate Process with Return Code
Pterm	macro	\1		; retcode
	move	\1,-(sp)
	move	#$4c,-(sp)
	trap	#1
	endm

;--- Find First File in Directory Chain
Fsfirst	macro	\1,\2		; attribs, filespec.l
	move	\1,-(sp)
	pea	\2
	Gemdos	$4e,8
	endm
 
;--- Find Next File in Directory Chain
Fsnext	macro
	Gemdos	$4f,2
	endm

;--- Rename File
Frename	macro	\1,\2		; newname.l, oldname.l
	pea	\1
	pea	\2
	clr	-(sp)
	Gemdos	$56,12
	endm

;--- Get/Set Date/Time Stamp
Fdatime	macro	\1,\2,\3	; mode, handle, timeptr.l
	move	\1,-(sp)
	move	\2,-(sp)
	pea	\3
	Gemdos	$57,10
	endm
