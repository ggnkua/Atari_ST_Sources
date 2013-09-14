; Apr 11 1989 v3.00'

;------------------------------------------------------------------------
;									:
;	AHDI Hard Disk Driver for the Atari ST				:
;	Copyright 1985,1986,1987,1988,1989 Atari Corp.			:
;	All Rights Reserved						:
;									:
;------------------------------------------------------------------------


;----------------
;
;  Conditional Assembly Switches
;
format		equ	0		; Format code
mdsense		equ	0		; Mode Sense code
ospool		equ	1		; increase size of OS pool for ROM


;
;-------------------- Edit History ------------------------

;------------------
;									:
;  9-Apr-1985 lmd	Hacked it up.  "Gee, it seems to work ..."	:
; 14-Apr-1985 lmd	linked with BIOS (***FOR NOW***)		:
; 20-Apr-1985 lmd	hacked for WD controller (now, wired...)	:
; 24-Jun-1985 jwt	hacked for Adaptec, new kludge board		:
; 01-Jul-1985 jwt	seems to work, add more formatting and more	:
;			 detailed error reporting			:
; 22-Jul-1985 jwt	change timing of wdc/wdl at start of command,	:
;			 added extra move.w $8a,wdl to change A1	:
; 23-Jul-1985 jwt	use a move.l instruction for all wdc/wdl write	:
;			 pairs since it changes A1 quickly enough that	:
;			 the (old) DMA chip does not incorrectly	:
;			 generate two chip selects			:
; 26-Sep-1985 jwt v0.05	support multiple ACSI devices			:
;			separate timeouts for command packet and	:
;			 operation					:
; 01-Oct-1985 jwt v0.06	added some AUXout serial debug messages		:
;			was responding to one more drive than was there	:
; 07-Oct-1985 jwt v0.07	added support for multiple partitions/drive	:
; 11-Oct-1985 jwt v0.08 added delay loop after pread for completion	:
;			 byte						:
; 19-Oct-1985 jwt v0.09	remove format and simple commands from resident :
;			 part						:
;			conditional assembly for default size		:
;			added count parameter to pread			:
; 22-Oct-1985 jwt v0.10	make certain qdone returns d0=-1 on timeout	:
;			add bits to read/write flag for:		:
;			 retry disable (bit 2)				:
;			 physical unit operation (bit 3)		:
;			add pun_ptr to TOS global variables		:
; 24-Oct-1985 jwt v0.11	add critical error call on errors		:
; 30-Jan-1986 lmd v0.12	increase OS pool by 128 chunks for ROM release	:
;			 of 11/20/85					:
;	      jwt	stay resident if any physical units found	:
;			 rather than if any GEM partitions found	:
; 05-Feb-1986 jwt	call critical error handler on errors unless	:
;			 no-retry bit is set				:
;			conditional assembly format code		:
;			remove transfer only to even byte boundary	:
;			 restriction					:
;			remove transfer less than 128K restriction	:
;			check for 0 length transfer			:
; 06-Feb-1986 jwt v0.13	use register based accesses for wdc and wdl	:
; 25-Mar-1986 lmd v0.14 Enforce .005 (200th) sec delay between		:
;			 successive calls to _do_rw().  SCSI adapter	:
;			 board eats the controller's completion byte,	:
;			 so we have to delay for it.			:
; 24-Apr-1986 lmd v1.1	Hack pool_install code to increase pool for	:
;			 other ROM releases of the system.		:
; 24-Apr-1986 lmd v1.4	Print nasty messages for old disk-based and	:
;			 unauthorized ROM-based systems.		:
; 23-Jun-1987 lmd v1.5  Fix date-check in nasty-OS-message code; wrong	:
;			 offset into the OS header (now $1e).		:
; 06-Nov-1987 akp v1.7	Added procedure findpackages and call to it.	:
; 10-Nov-1987 akp	Changed source to MADMAC format.		:
;			Removed format flag from top of file.		:
; 24-Nov-1987 akp	Really made v1.7 work.				:
; 19-Feb-1988 ml	Added format and mode sense code for use in 	:
;			 HDX  (It's conditional, code will only be	:
;			 included for ahdi.prg, and not shdriver.sys).	:
; 26-May-1988 ml	Added request sense code for use in HDX 3.0	:
;			 for SR444 (Syquest drive).			:
; ??-Aug-1988 ml  v2.0	Attempted to add code for removable media.	:
; 07-Sep-1988 ml	Found out that shouldn't move code around too	:
;			 much.  Labels i_sasi and i_sasi1 are used to	:
;			 determine which part of this program will be	:
;			 reserved at Ptermres().  All text and data to	:
;			 be reserved should appear between these two	:
;			 labels.					:
; 31-Oct-1988 ml	It seemed to work well.  Now AHDI can handle	:
;			 both removable and non-removable hard disks.	:
;			It can handle hard disks partitioned in	GEMDOS	:
;			 format or MSDOS 3.x format.  			:
;			Code for executing programs in the AUTO folder 	:
;			 and packages in RAM, and code for bringing up	:
;			 AES have been deleted.  Instead, AHDI returns	:
;			 to TOS ROMs and let them handle those tasks.	:
; 01-Dec-1988 ml	Modified _sasi_rw so that it will look for a 	:
;			 LONG record number after the device number, if :
;			 the WORD record number == -1.  This allows the	:
;			 caller of Rwabs to address pass 32Mb.		:
;			 Though the underlying routine is the same, the	:
;			 caller has to call Lrwabs from the high level,	:
;			 not Rwabs for this to work.			:
; 02-Dec-1988 ml	Modified the way we check whether we should jam	:
;			 d7 for further boot before returning to TOS	:
;			 ROMs.  The system build date is being checked	:
;			 instead of the OS version number.  This is	:
;			 necessary because there seems to be confusion	:
;			 about version numbers of some released ROMS.	:
; 05-Dec-1988 ml	If OS wasn't built before 4/22/1987, when 	:
;			 returning to TOS ROMs, jam d7 with the last 	:
;			 unit that was processed, instead of magic #.	:
; 08-Dec-1988 ml	If ospool code is included, make sure 'poolbuf'	:
;			 is the last label in the program to be kept.	:
;			 The code uses the memory after that label as	:
;			 a buffer.  Whatever is after 'poolbuf' will be :
;			 overwritten.					:
; 04-Jan-1989 ml	Modified to handle more than 4 partitions per	:
;			 physical unit.  The method used is the same as	:
;			 used in MSDOS 3.3 (ie., by implementing a 	:
;			 linked list of logical drives).  There is a 	:
;			 type of partition called the EXTENDED GEMDOS	:
;			 PARTITION which is head of the linked list.	:
;			 This new type of partition is specified by the	:
;			 value "XGM" in the p_id field of the partition	:
;			 map.						:
; 22-Feb-1989 ml v2.07a	Modified _fdone() and _qdone() to use 200 hz	:
;			 clock for timeout loop.  This would keep the	:
;			 timeout constant over different machines.	:
; 02-Mar-1989 ml v2.08a Moved pbuf up with regular declarations.  It	:
;			 should stay resident.  Added a cookie pointer	:
;			 for people to check if they have gotten this	:
;			 new version of ahdi.				:
; 03-Mar-1989 ml	Changed cookie to 'AHDI'.  It will stay that 	:
;			 way.  Added version #, a long, right after	:
;			 cookie ptr.  					:
;			 Example: 19890208				:
;			 	1989 - year 1989;			:
;			 	02 - major version #;			:
;			 	08 - minor version #;			:
; 06-Mar-1989 ml 	Enforced 0.005 sec delay between driver calls.	:
;			 Delay only when neccessary before 1st command	:
;			 byte is sent, and update timer when command is	:
;			 done.  New routine _delay().  Update timer 	:
;			 code is added in _endcmd().			:
; 07-Mar-1989 ml	More optimization done on low-level driver.	:
;			 Use registers instead of wdlwdc when accessing	:
;			 DMA registers, etc...				:
; 09-Mar-1989 ml	Forced driver to stay around even when no drive	:
;			 is found.					:
;			Made number of drive to reserve for each ACSI 	:
;			 Syquest drive patchable.			:
;			 Magic number $f0ad is used to denote a version	:
;			 with patchable variables.			:
;			 Version number (same as one after the cookie	:
;			 pointer) is stored after magic # $f0ad.	:
; 10-Mar-1989 ml	Made number of memory chunks to add to ospool	:
;			 patchable.					:
; 13-Mar-1989 ml v2.09a	If there is no cartridge in a Syquest drive,	:
;			 return drive not ready, and pass to critical	:
;			 error handler.					:
; 29-Mar-1989 ml v2.10a Verion number is now a word, MMmm.		:
;			 (MM - major #; mm - minor #)			:
;			Added in checks to see if enough memory is	:
;			 allocated for ospool installation and big	:
;			 GEMDOS buffer lists.				:
; 30-Mar-1989 ml	If there is not enough memory for big GEMDOS	:
;			 buffer lists, make maximum sector size = 512.	:
;			 This guarantees that the regular partitions 	:
;			 are still accessible.				:
;			If there is not enough memory to install amount	:
;			 of OS pool requested. NONE would be installed. :
;			Variable 'poolbuf' is gone.			:
; 04-Apr-1989 ml	Sped up media change.  Refer to comments at	:
;			_sasi_mediach.					:
; 11-Apr-1989 ml v3.00	Made version # consistent with HDX and HINSTALL.:
;------------------------------------------------------------------------


;
;------------  Equates and Declarations--------------

etv_critic	equ	$404		; critical error handoff vector
phystop		equ	$42e		; physical top of memory
flock		equ	$43e		; FIFO lock variable
_bootdev	equ	$446		; default boot device
hdv_init	equ	$46a		; hdv_init()	** UNUSED **
hdv_bpb		equ	$472		; hdv_bpb(dev)
hdv_rw		equ	$476		; hdv_rw(rw, buf, count, recno, dev)
hdv_boot	equ	$47a		; hdv_boot()	** UNUSED **
hdv_mediach	equ	$47e		; hdv_mediach(dev)
_bufl		equ	$4b2		; 2 buffer-list headers
_hz_200		equ	$4ba		; system 200hz timer
_drvbits	equ	$4c2		; block device bitVector
_dskbufp	equ	$4c6		; pointer to common disk buffer
_sysbase	equ	$4f2		; -> base of OS
pun_ptr		equ	$516		; number of physical units

;+
; Restraints 
;-
MAXUNITS	equ	14		; max # of log units w/o drv A & B
MAXACSI		equ	8		; maximum number of ACSI devices
MAXSECTORS	equ	254		; maximum no. of sectors at one gulp

;+
; Offsets to ...
;-
DOSPM		equ	$1be		; MSDOS boot sect's partition map
DOSSIG		equ	$1fe		; MSDOS boot sect's signature
HDSIZ		equ	$1c2		; offset to GEMDOS root sect's 
					; hard disk size

;+
; Constants and Variables
;-
SIG		equ	$55aa		; signature for valid MSDOS boot sects
NRETRIES	equ	3		; #retries-1
MAXNPART	equ	3		; #partition entries in root sect - 1
BPBLEN		equ	18		; length of bpb entry in bytes
FATLEN		equ	64		; max fat size = 64 sectors
					; (for 16Mb drive, 2 spc, 512 bps)
SERLEN		equ	3		; length of a serial # in bytes
CHKDATE		equ	$19870422	; ROM date for bootstop checking

;+
; BIOS error codes
;-
EDRVNR		equ	-2		; driver not ready
EWRITF		equ	-10		; write fault
EREADF		equ	-11		; read fault
EWRPRO		equ	-13		; write on write-protected media
E_CHNG		equ	-14		; media change detected
CRITRETRY	equ	$00010000	; "retry" return code

;+
; SCSI error codes
;-
DRVNRDY		equ	$4		; drive not ready
WRTPRTD		equ	$27		; write on write-protected media
MDMCHGD		equ	$28		; media change detected

;+
; Number of bytes per Buffer Control Block (excluding the data block itself)
;
; struct_bcb {
; 	struct_bcb	*b_link;	/* 4 bytes */
;	int		b_neg1;		/* 2 bytes */
;	int		b_private[5];	/* 10 bytes */
;	char		*b_bufr;	/* 4 bytes */
; };
;
; For GEMDOS buffer lists.
;-
BCBLEN		equ	20

;+
; for extension of os pool
;-
chunksiz	equ	 66		; #bytes/chunk
chunkno		equ	 4		; chunk# (4 16-byte chunks)


;
;----------------
;
;  Entry points:
;
;	+0   GEMDOS entry point (double-click, or \AUTO folder on floppy)
;	+4   Boot entry point (from driver file off of C:)
;	+8   Reserved for future use
;	+$C  $F0AD magic number
;	+$E  version number
;	+$12 # chunks of ospool to add
;	+$14 # of sqnpart entries that follows
;	+$16 first sqnpart entry
;
;  if bootloaded, d0 = # bytes allocated by boot code.
;
i_sasi:	bra	gboot			; GEMDOS entry-point
	bra	iboot			; Boot entry-point
	bra	iboot			; (unused, reserved)


;----------------
;
;  Patchable variables
;
magicnum:	dc.w	$f0ad		; wasn't here in previous releases
vernum:		dc.w	$0300		; version number
numchunks:	dc.w	128		; # chunks of ospool to add
minbigsect:	dc.w	512		; minimum size of a big sector
numsqnpart:	dc.w	MAXACSI		; number of sqnpart entries to follow
minsqnpart:	dcb.b	MAXACSI,1	; minimum # drives for removable unit
.even

;----------------
;
;  GEMDOS entry;
;    find amount of memory availble and store in d0.l
;
gboot:	movea.l	4(sp),a2		; a2 -> basepage
	move.l	4(a2),d0		; d0 = available memory
	sub.l	(a2),d0			;    = p_hitpa - p_lowtpa - basepage
	sub.l	#$0100,d0
	bra	i_sasi1			; (continue with normal initialization)


;----------------
;
;  Boot entry;
;    set "bootloaded", record base address from boot loader, 
;    and continue with normal boot process.
;
iboot:	st	bootloaded		; boot entry-point, set flag
	sub.l	#$1c,d0			; memory available -= file header
	move.l	a2,baseaddr		; install base address
					; a2 = beginning addr of this block
	bra	i_sasi1			; (continue with normal initialization)


;
;--------------- Driver State --------------------

		dc.b	13,'AHDI : Apr 11 1989 v3.00'
		dc.b	13,10,$bd,'Atari Corp. 1985, 1986, 1987, 1988, 1989'
		dc.b	13,10,0,$1A
.even

_puns:
puns:		dc.w	0		; # of physical units on user's system

dummy1:		dcb.b	2,-1		; dummy pun entries for A and B
_pun:
pun:		dcb.b	MAXUNITS,0	; physical unit table
.even

dummy2:		dcb.l	2,0		; dummy start entries for A and B
_partstart:
start:		dcb.l	MAXUNITS,0	; partition start table

_cookie:				; *** DON'T CHANGE ***
cookie:		dc.l	$41484449	; cookie = 'AHDI'

_cookptr:
cookptr:	dc.l	0		; pointer to cookie

_versn:
versn:		dc.w	$0300		; version number: MMmm

_maxssz:
maxssz:		dc.w	512		; maximum sector size allowed
		dcb.l	16,0		; reserved for future use

bpbs:	dcb.b	BPBLEN,0		; a bpb 
mcflgs:	dcb.b	MAXUNITS,2		; media change flag table
xst:	dcb.b	MAXUNITS,1		; drive existence flag table
serno:	dcb.b	MAXUNITS*SERLEN,0	; serial number table
sratio:	dcb.b	MAXUNITS,1		; log sect size : phys sect size tbl
fatsum:	dcb.b	MAXUNITS*FATLEN,0	; FAT checksum table
fatst:	dcb.w	MAXUNITS,0		; starting sector # of last FAT
fatend:	dcb.w	MAXUNITS,0		; ending sector # of last FAT

bootloaded:	dc.w	0		; nonzero if loaded from boot sector
memalloc:	dc.l	0		; total memory available if bootloaded
baseaddr:	dc.l	0		; -> base addr of .PRG file
tokeep:		dc.l	0		; amount memory to keep
preadret:	dc.w	0		; return code from pread

cpun:		dc.w	0		; current physical unit
npart:		dc.w	0		; number of partitions found
bfat:		dc.w	0		; 0: 12-bit FAT; 1: 16-bit FAT

strec:		dc.l	0		; starting sector to read/write
endrec:		dc.l	0		; last sector to read/write
stbuf:		dc.l	0		; starting address of buffer
rmbits:		dc.b	0		; bit map - 1: unit is removable
scsi:		dc.b	0		; bit map - 1: embedded SCSI drive

_retries:	dc.w	NRETRIES	; number of retries to do
retrycnt:	dc.w	1		; retry counter

o_bpb:		dc.l	1
o_rw:		dc.l	1
o_mediach:	dc.l	1

sendata:	dcb.b	16,0		; buffer for request sense

lastacstm:	dc.l	0		; controller last accessed time
lastmdctm:	dc.l	0		; time media change was last called
pbuf:		dc.l	0		; ptr to start of root sector image
fsiz:		dc.w	0		; FAT size in sectors
fatrec:		dc.w	0		; 2nd FAT starting sector
sizr:		dc.w	1		; ratio of log : phys sector size
temp:		dc.l	0		; temporary storage
savssp:		dc.l	1		; (saved SSP)
mcrw:		dc.b	0		; if TRUE, r/w returns media change
ext:		dc.b	0		; if =0, not processing ext partition

extrt:		dc.l	0		; starting sector of ext DOS partition
extvol:		dc.l	0		; offset wrt ext DOS partition
pbpb:		dc.w	0		; partition # for dev
.even


;
;------------------ Front End ------------------

;----------------
;
;  Return pointer to BPB (or NULL)
;
;    Synopsis:	LONG hbpb(dev)
;		WORD dev;	4(sp).w
;
hbpb:	move.w	4(sp),d0		; d0 = devno
	clr	d1			; d1 = 0, physical op not possible
	movea.l	o_bpb,a0		; a0 -> pass-through vector
	lea	_sasi_bpb(pc),a1	; a1 -> our handler
	bra.s	check_dev		; do it


;----------------
;
;  Read or write logical sectors
;
;    Synopsis:	LONG rw(rw, buf, count, recno, dev)
;		WORD rw;	$4(sp).w
;		char *buf;	$6(sp).l
;		WORD count;	$a(sp).w
;		WORD recno;	$c(sp).w
;		WORD dev;	$e(sp).w
;
hrw:	move.w	$e(sp),d0		; d0 = devno
	move.w	4(sp),d1		; d1 includes physical device flag
	movea.l	o_rw,a0			; a0 -> pass-through vector
	lea	_sasi_rw(pc),a1		; a1 -> our handler
	bra.s	check_dev		; do it


;----------------
;
;  Check for media change
;
;    Synopsis:	LONG mediach(dev)
;		WORD dev;	4(sp).W
;
hmediach:
	move.w	4(sp),d0		; d0 = devno
	clr	d1			; physical operation not possible
	movea.l	o_mediach,a0		; a0 -> pass-through vector
	lea	_sasi_mediach(pc),a1	; a1 -> our handler


;----------------
;
;  check_dev - use handler, or pass vector through
;
;  Passed:	d0.w = device#
;		d1, bit 3  1=physical operation
;		a0 ->  old handler
;		a1 ->  new handler
;		a5 ->  $0000 (zero-page ptr)
;
;  Jumps-to:	(a1) if dev in range for this handler
;		(a0) otherwise
;
check_dev:
	subq	#2,d0			; lowest device is 2 (unit 0 or C:)
	bmi.s	chkd_f			; if lower, not one of ours

	btst	#3,d1			; is this a physical unit operation?
	beq.s	chkd_a			; if not set, go to chkd_a

	cmp	puns,d0			; compare unit num to num units exist
	bge.s	chkd_f			; if unit num too big, not one of ours
	bra.s	chkd_s			; else it IS one of of ours

chkd_a:	lea	pun,a2			; pointer to pun map
	tst.b	0(a2,d0.w)		; must be positive for a real unit
	bmi.s	chkd_f
chkd_s:	movea.l	a1,a0			; yes -- follow success vector
chkd_f:	jmp	(a0)			; do it


;
;------------------ Medium-Level Driver ----------------

;----------------
;
;  Return BPB for logical device
;
;    Synopsis:	LONG _sasi_bpb(dev)
;		WORD dev;	$4(sp).w
;
;    Returns:	NULL, or a pointer to the BPB buffer
;
; 10-21-88	ml.	I am not making a special case for non-removable
;			hard disk, because if a program uses Allan's
;			program to force a media change, the program 
;			should be getting the "Real" AND "New" BPB.
;			(The old (v1.7 and before) AHDI only index into
;			the bpbs table and return the pointer, without
;			actually go and read the boot sector of the dev.)
;
_sasi_bpb:
	subq.w	#2,4(sp)		; dev # excluding drv A and B
bpbst:	move.w	4(sp),d1		; d1 = device number
	lea	pun,a0			; a0 = ptr to pun table
	adda.w	d1,a0			; a0 = ptr to pun @ dev's entry
	clr.w	d2			; coerce byte to word
	move.b	(a0),d2			; d2.w = pun that dev belongs to

	lea	xst,a1			; a0 = ptr to drive existence table
	tst.b	(a1,d1.w)		; does drive exist?
	bne.s	bpbgo			; if it does, go on normally
					; else, see if it really doesn't exist
	movem.w	d1-d2,-(sp)		; else save registers
	move.w	d2,-(sp)		; physical unit number
	bsr	testunit		; verify by doing test unit ready
	addq.l	#2,sp			; cleanup stack
	movem.w	(sp)+,d1-d2		; restore registers
	tst.w	d0			; return good status?
	beq	badbpb			; if yes, ie. medium has not changed
					; therefore, dev still doesn't exist
	moveq	#1,d0			; else medium may have changed
	bsr	s_mc_xst		; set mcflgs and xst flags to 1's
	bra.s	bpbst			; restart procedure

bpbgo:	move.w	d2,cpun			; cpun = pun(dev)
	move.l	_dskbufp,pbuf		; pbuf = ptr to 2nd half of 1K disk buf
	add.l	#512,pbuf

bpb00:	move.l	a0,-(sp)		; save ptr to pun(dev)
	move.w	#1,-(sp)		; return media change if detected
	move.w	cpun,-(sp)		; physical unit number
	move.l	pbuf,-(sp)		; buffer to read into
	move.w	#1,-(sp)		; read in 1 sector
	clr.l	-(sp)			; from sector 0
	bsr	pread			; pread(sectno, cnt, buf, phys#, flag)
	adda	#14,sp
	move.l	(sp)+,a0		; restore ptr to pun(dev)
	tst	d0			; pread successful?
	beq.s	bpb0			; if yes, go on normally

bpberr:	cmpi.w	#E_CHNG,d0		; is media change detected?
	beq.s	bpbchg			; if so, set mcflgs
					; else call up error handler
	move.l	a0,-(sp)		; save ptr to pun(dev)
	move.w	8(sp),d1		; a0 = drive # excluding A: and B:
	bsr	critic			; call up critical error handler
	move.l	(sp)+,a0		; restore ptr to pun(dev)
	cmpi.l	#CRITRETRY,d0		; retry?
	beq.s	bpb00			; if so, go and try again
	bra	badbpb			; else return no BPB

bpbchg:	move.b	#1,d0			; d0.b = media may be changed
	move.w	4(sp),d1		; d1.w = device number
	move.b	cpun+1,d2		; d2.b = physical unit number
	bsr	s_mc_xst		; go set mcflgs and xst flags
	bra	bpbst			; restart procedure

bpb0:	move.w	cpun,d2			; d2 = physical unit number of dev
	move.w	#0,pbpb			; pbpb = partition # dev corresponds
bpb1:	cmp.b	-(a0),d2		; pun that dev belongs to == (a0)?
	bne.s	bpb2
	addq.w	#1,pbpb
	bra.s	bpb1

bpb2:	move.w	#MAXNPART,d1		; do #MAXNPART times
	movea.l	pbuf,a0			; a0 = ptr to beginning of root sector
	cmpi.w	#SIG,DOSSIG(a0)		; is root sector in DOS format?
	bne.s	bpb3			; if not, assume it's in GEMDOS format
	bsr	dosbpb			; else, handle it the DOS way
	bra.s	bpb4			; else, go get the bpb
bpb3:	move.w	#1,bfat			; 16 bit FAT always for GEMDOS
	bsr	gembpb			; handle it the GEMDOS way
bpb4:	tst.w	d0			; successful?
	beq.s	bpbnf			; if =0, no valid BPB found
	bpl.s	bpb5			; if +ive, valid BPB found
	cmpi.w	#E_CHNG,d0		; else media changed?
	beq.s	bpbchg			; if so, restart procedure
	bra.s	badbpb			; else no BPB found
					; partition not found
bpbnf:	lea	xst,a0			; a0 = ptr to drive existence table
	move.w	4(sp),d0		; d0 = dev number
	clr.b	(a0,d0.w)		; dev definitely does not exist
	lea	mcflgs,a0		; a0 = ptr to mcflgs table
	move.b	#2,(a0,d0.w)		; set as medium has changed
	bra.s	badbpb			; can't find such a partition

bpb5:	move.l	d1,-(sp)		; start_sector
	move.w	8(sp),-(sp)		; dev number
	bsr	getbpb			; getbpb(dev, start_sector)
	addq.l	#6,sp			; clean up stack
	tst.l	d0			; getbpb successful?
	bpl.s	retbpb			; if so, return ptr to bpb
	cmpi.w	#E_CHNG,d0		; media changed?
	beq	bpbchg			; if so, restart procedure
badbpb:	moveq	#0,d0			; return no bpb found
retbpb:	rts


;
;+
; dosbpb - find the DOS partition that corresponds to the requested
;	   logical drive
; Passed:
;	a0 = buffer address for root sector
;	d1 = number of entries in partition map
;
; Assumed:
;	pbpbs = partition being looked for
;
; Returns:
;	d0.b = 0		if partition not found
;	     = negative #	some kind of error
;	     = positive #	system indicator of the partition
;	d1.l = starting sector of the partition (if it is found)
;-
dosbpb:	adda.w	#DOSPM,a0		; a0 = ptr to partition map
dbpb0:	movem.l	d1/a0,-(sp)		; save count and offset
	sf	ext			; not dealing with ext partition
	bsr	fdpart			; find a partition
	tst.b	d0			; found any?
	beq.s	dbpba			; not a valid partition
	cmpi.b	#5,d0			; extended partition?
	bne.s	dbpb1			; if not, it's a regular partition
	st	ext			; else, it's an extended partition
	move.l	#0,extvol		; offset from start of partition = 0
	move.l	d1,extrt		; starting sector # of ext partition
dbpbx:	bsr	fdnxt			; find next logical drive
	tst.b	d0			; found any?
	beq.s	dbpba			; no logical drive found
	bmi.s	dbpb2			; error returned
	cmpi.b	#5,d0			; extended volume?
	beq.s	dbpbx			; if so, go find next logical drive
dbpb1:	subq.w	#1,pbpb			; partition that we want?
	bpl.s	dbpb3			; if not, continue the search
dbpb2:	addq.l	#8,sp			; else clean up stack
	move.w	#0,bfat			; assume partition has 12-bit fat
	cmpi.b	#1,d0			; 12-bit fat?
	beq.s	dbpb22			; if so, return
	move.w	#1,bfat			; else bflag = 1 for 16-bit fat
dbpb22:	bra.s	dbpbr			; and return
dbpb3:	tst.b	ext			; clun is in ext partition?
	bne.s	dbpbx			; if so, go find next ext vol
dbpba:	movem.l	(sp)+,d1/a0		; restore count and offset
	adda	#16,a0			; index to next entry in pmap
	dbra	d1,dbpb0
	moveq	#0,d0			; partition not found!
dbpbr:	rts

	
;+
; fdpart - find a DOS partition.
;
; Passed:
;	a0 = address to partition entry
;
; Returns:
;	d0.b = 0		partition is not valid
;	     = positive	#	partition is a valid partition
;	       (this is the system indicator of the partition)
;	d1.l = starting sector # of a valid partition (if d0.b = 1 or 4)
;	     = starting sector # of extended partition (if d0.b = 5)
;-
fdpart:	tst.l	12(a0)			; partition's size?
	beq.s	fdp0			; if =0, not valid

	move.b	4(a0),d0		; d0 = system indicator
	beq.s	fdpr			; if =0, not valid

	cmpi.b	#4,d0			; if =4, valid
	beq.s	fdp1

	cmpi.b	#1,d0			; if =1, valid
	beq.s	fdp1

	cmpi.b	#5,d0			; if =5, valid
	beq.s	fdp1

fdp0:	moveq	#0,d0			; else, not valid
	bra.s	fdpr

fdp1:	move.l	8(a0),d1		; d1.l = swapped starting sector #
	ror.w	#8,d1			; swap hi and lo byte of high word
	swap	d1			; swap hi and lo word
	ror.w	#8,d1			; swap hi and lo byte of low word
fdpr:	rts


;+
; fdnxt - find a logical drive in the extended DOS partition
;
; Passed:
;	d0.b = (= 5 if a new extended volume was found)
;	       (= 0 if nxtdrv was successful for last logical drive found)
;	d1.l = starting sector # of this extended volume
;	d2.b = count down for logical drive entries (if d0.b != 5)
;	a0.l = address of partition entry to be checked (if d0.b != 5)
;
; Assumes:
;	cpun = current physical unit #
;	extrt = starting sector # of extended DOS partition
;	extvol = offset from start of extended DOS partition (in sectors)
;
; Returns:
;	d0.b = 0		no logical drive found
;	     = positive #	valid logical drive found
;	       (this is the system indicator of the logical drive)
;	     = negative #	error occured
;	d1.l = starting sector # of the logical drive (if d0.b = 1 or 4)
;	     = starting sector # of next extended volume (if d0.b = 5)
;-
fdnxt:	cmpi.b	#5,d0		; new extended volume found?
	bne.s	fdnxt0		; if not, search for one
	move.w	#1,-(sp)	; return media change if detected
	move.w	cpun,-(sp)	; physical unit number
	move.l	_dskbufp,-(sp)	; buffer to read into
	move.w	#1,-(sp)	; read in 1 sector
	move.l	d1,-(sp)	; from beginning of extended volume
	bsr	pread		; pread(sectno, cnt, buf, phys#, flag)
	adda	#14,sp		; cleanup stack
	tst.w	d0		; pread successful?
	bne	fdnxtr		; if so, return
	
	movea.l	_dskbufp,a0	; else, 
	cmpi.w	#SIG,DOSSIG(a0)	; boot record valid?
	bne.s	fdnxtr		; if not, return no drive found
				; (d0 already set by pread)
	adda.w	#DOSPM-16,a0	; a0 = ptr to 1st entry in log drive map
	move.w	#MAXNPART+1,d2	; d2 = count for # of log drive entries

fdnxt0:	subq.w	#1,d2		; more entries to search?
	bmi.s	fdnxt1		; if not, return

	adda	#16,a0		; a0 = ptr to entry to be examined
	tst.l	12(a0)		; partition size's?
	beq.s	fdnxt0		; if =0, not valid

	move.b	4(a0),d0	; d0 = system indicator
	beq.s	fdnxt0		; if =0, not valid

	move.l	8(a0),d1	; d1.l = logical start sector of drv or vol
	beq.s	fdnxt0		; if =0, not valid
	ror.w	#8,d1		; swap hi and lo byte of high word
	swap	d1		; swap hi and lo word
	ror.w	#8,d1		; swap hi and lo byte of low word

	cmpi.b	#4,d0		; if =4,
	beq.s	fdnxt2		; valid logical drive found

	cmpi.b	#1,d0		; if =1,
	beq.s	fdnxt2		; valid logical drive found

	cmpi.b	#5,d0		; if =5, valid ptr to next ext volume
	bne.s	fdnxt0		; else, not valid
	move.l	d1, extvol	; offset of ext vol from start of ext DOS
	bra.s	fdnxt3

fdnxt1:	moveq	#0,d0		; return no drive found
	bra.s	fdnxtr

fdnxt2:	add.l	extvol,d1	; d1 = start sector wrt beginning of ext DOS
fdnxt3:	add.l	extrt,d1	; d1 = start sector wrt beginning of disk
fdnxtr:	rts


;
;+
; gembpb - find the GEMDOS partition that corresponds to the requested
;	   logical drive.
; Passed:
;	a0 = buffer address for root sector
;	d1 = number of entries in partition map
;
; Assumed:
;	pbpbs = partition being looked for
;
; Returns:
;	d0.b = 0		if partition not found
;	     = negative #	some kind of error
;	     = positive #	system indicator of the partition
;	d1.l = starting sector of the partition (if it is found)
;-
gembpb:	adda.w	#HDSIZ,a0		; a0 = ptr to hard disk size
	tst.l	(a0)+			; size? (a0 = ptr to start of pmap)
	beq.s	gbpb4			; if =0, no drive will exist
gbpb0:	movem.l	d1/a0,-(sp)		; save count and offset
	sf	ext			; not dealing with ext partition
	bsr	fgpart			; find partitions
	tst.b	d0			; found any?
	beq.s	gbpba			; not a valid partition
	cmpi.b	#'X',d0			; extended partition?
	bne.s	gbpb1			; if not, it's a regular partition
	st	ext			; else, it's an extended partition
	move.l	#0,extvol		; offset from start of partition = 0
	move.l	d1,extrt		; starting sector # of ext partition
gbpbx:	bsr	fgnxt			; find next logical drive
	tst.b	d0			; found any?
	beq.s	gbpba			; no logical drive found
	bmi.s	gbpb2			; error returned
	cmpi.b	#'X',d0			; extended volume?
	beq.s	gbpbx			; if so, go find next logical drive
gbpb1:	subq.w	#1,pbpb			; partition that we want?
	bpl.s	gbpb3			; if not, continue the search
gbpb2:	addq.l	#8,sp			; else BINGO!  Clean up stack
	bra.s	gbpbr			; and return
gbpb3:	tst.b	ext			; clun is in ext partition?
	bne.s	gbpbx			; if so, go find next ext vol
gbpba:	movem.l	(sp)+,d1/a0		; restore count and offset
	adda	#12,a0			; index to next entry in pmap
	dbra	d1,gbpb0
gbpb4:	moveq	#0,d0			; partition not found!
gbpbr:	rts


;+
; fgpart - find a GEMDOS partition.
;
; Passed:
;	a0 = address to partition entry
;
; Returns:
;	d0.b = 0		partition is not valid
;	     = positive	#	partition is a valid partition
;	       (this is the first byte in p_id of the partition)
;	d1.l = starting sector # of a valid partition (if d0.b = 'G' or 'B')
;	     = starting sector # of extended partition (if d0.b = 'X')
;-
fgpart:	tst.b	(a0)			; check the valid partition flag
	beq.s	fgp2			; if =0, not valid

	tst.l	8(a0)			; partition's size?
	beq.s	fgp2			; if =0, not valid

	cmpi.b	#'G',1(a0)		; must find GEM as type
	bne.s	fgp0			; for REGULAR partition
	cmpi.b	#'E',2(a0)		; (ie., partition < 16Mb)
	bne.s	fgp0
	cmpi.b	#'M',3(a0)
	beq.s	fgp3

fgp0:	cmpi.b	#'B',1(a0)		; must find BGM as type
	bne.s	fgp1			; for BIG partition
	cmpi.b	#'G',2(a0)		; (ie., partition >= 16Mb)
	bne.s	fgp1
	cmpi.b	#'M',3(a0)
	beq.s	fgp3

fgp1:	cmpi.b	#'X',1(a0)		; or find XGM as type
	bne.s	fgp2			; for EXTENDED GEMDOS 
	cmpi.b	#'G',2(a0)		; partition
	bne.s	fgp2			; (ie., partition with
	cmpi.b	#'M',3(a0)		;  a linked list of
	beq.s	fgp3			;  logical drives)

fgp2:	moveq	#0,d0			; else, not valid
	bra.s	fgpr

fgp3:	move.l	4(a0),d1		; d1.l = starting sector #
	move.b	1(a0),d0		; d0.b = first byte of p_id
fgpr:	rts


;+
; fgnxt - find a logical drive in the extended GEMDOS partition
;
; Passed:
;	d0.b = (= 'X' if a new extended volume was found)
;	       (= 0 if nxtdrv was successful for last logical drive found)
;	d1.l = starting sector # of this extended volume
;	d2.b = count down for logical drive entries (if d0.b != 'X')
;	a0.l = address of partition entry to be checked (if d0.b != 'X')
;
; Assumes:
;	cpun = current physical unit #
;	extrt = starting sector # of extended GEMDOS partition
;	extvol = offset from start of extended GEMDOS partition (in sectors)
;
; Returns:
;	d0.b = 0		no logical drive found
;	     = positive #	valid logical drive found
;	       (this is the first byte of p_id of the logical drive)
;	     = negative #	error occured
;	d1.l = starting sector # of the logical drive (if d0.b = 'G' or 'B')
;	     = starting sector # of next extended volume (if d0.b = 'X')
;-
fgnxt:	cmpi.b	#'X',d0		; new extended volume found?
	bne.s	fgnxt0		; if not, search for one
	move.w	#1,-(sp)	; return media change if detected
	move.w	cpun,-(sp)	; physical unit number
	move.l	_dskbufp,-(sp)	; buffer to read into
	move.w	#1,-(sp)	; read in 1 sector
	move.l	d1,-(sp)	; from beginning of extended volume
	bsr	pread		; pread(sectno, cnt, buf, phys#, flag)
	adda	#14,sp		; cleanup stack
	tst.w	d0		; pread successful?
	bne	fgnxtr		; if not, return error

	movea.l	_dskbufp,a0	; a0 = ptr to partition map
	adda.w	#HDSIZ+4-12,a0	; a0 = ptr to 1st entry in log drive map
	move.w	#MAXNPART+1,d2	; d2 = count for # of log drive entries

fgnxt0:	subq.w	#1,d2		; more entries to search?
	bmi.s	fgnxt3		; if not, return

	adda	#12,a0		; a0 = ptr to entry to be examined
	tst.l	8(a0)		; partition size's?
	beq.s	fgnxt0		; if =0, not valid.  Try next entry

	tst.b	(a0)		; check the valid partition flag
	beq.s	fgnxt0		; if =0, not valid.  Try next entry

	move.l	4(a0),d1	; d1.l = logical start sector of drv or vol

	cmpi.b	#'G',1(a0)	; must find GEM as type
	bne.s	fgnxt1		; for REGULAR partition
	cmpi.b	#'E',2(a0)	; (ie., partition < 16Mb)
	bne.s	fgnxt1
	cmpi.b	#'M',3(a0)
	beq.s	fgnxt4

fgnxt1:	cmpi.b	#'B',1(a0)	; must find BGM as type
	bne.s	fgnxt2		; for BIG partition
	cmpi.b	#'G',2(a0)	; (ie., partition >= 16Mb)
	bne.s	fgnxt2
	cmpi.b	#'M',3(a0)
	beq.s	fgnxt4

fgnxt2:	cmpi.b	#'X',1(a0)	; or find XGM as type
	bne.s	fgnxt3		; for EXTENDED GEMDOS 
	cmpi.b	#'G',2(a0)	; partition
	bne.s	fgnxt3		; (ie., partition with
	cmpi.b	#'M',3(a0)	;  a linked list of
	bne.s	fgnxt0		;  logical drives)

	move.l	d1, extvol	; offset of ext vol from start of ext GEMDOS
	bra.s	fgnxt5

fgnxt3:	moveq	#0,d0		; return no drive found
	bra.s	fgnxtr

fgnxt4:	add.l	extvol,d1	; d1 = start sector wrt beginning of ext DOS
fgnxt5:	add.l	extrt,d1	; d1 = start sector wrt beginning of disk
	move.b	1(a0),d0	; d0.b = first byte of p_id
fgnxtr:	rts


;
;--------------
;
; getbpb(dev, sectorno)
; WORD dev;		4(sp).w
; LONG sectorno;	6(sp).l
;
; Assume -
;    cpun contains physical unit number of dev
;
getbpb:	move.w	#1,-(sp)		; return media change if detected
	move.w	cpun,-(sp)		; physical unit
	move.l	_dskbufp,-(sp)		; buffer
	move.w	#1,-(sp)		; 1 sector
	move.l	$10(sp),-(sp)		; sector # of boot sector
	bsr	pread			; pread(bootsect, 1, buf, phys#, flag)
	adda	#14,sp			; clean up stack
	tst.w	d0			; any trouble reading?
	beq.s	getb0			; if no, go on normally
	cmpi.w	#EREADF,d0		; was it a read error?
	beq.s	getb9			; if it is, retry
	cmpi.w	#EDRVNR,d0		; was it drive not ready?
	bne	getb8			; if not, return
					; else let user retry
getb9:	move.w	4(sp),d1		; d1 = drive # excluding A: and B:
	bsr	critic
	cmpi.l	#CRITRETRY,d0		; retry?
	bne	getb7			; if not, return
	bra.s	getbpb			; else read again

getb0:	movea.l	_dskbufp,a0		; a0 = ptr to boot sector image
	movea.l	#bpbs,a2		; a2 = ptr to bpb

	move.w	#$0b,d0
	bsr	getlhw
	cmp.w	maxssz,d0		; is sector size too big?
	bhi	getb7			; if it is, can't handle it
	move.w	d0,(a2)+		; =byt/sec
	beq	getb7			; if =0, bad data
	move.w	d0,d1
	divu	#512,d0			; d0.b = ratio log : phys sector size
	move.w	d0,sizr			; save the ratio

	clr.w	d0
	move.b	$d(a0),d0
	move.w	d0,(a2)+		; =sec/cluster
	beq	getb7			; if =0, bad data

	mulu	d1,d0
	move	d0,(a2)+		; =byt/cluster

	move	#$11,d0
	bsr	getlhw			; number of directory entries
	tst	d0			; num o' entries ?= 0
	beq	getb7			; if so, bad data
	mulu	#32,d0			; size of each entry
	divu	d1,d0			; number of sectors required
	move.l	d0,d1
	swap	d1
	tst	d1
	beq.s	getb1
	addq	#1,d0			; round up
getb1:	move	d0,(a2)+		; =rdlen
	move	d0,d2

	move	#$16,d0
	bsr	getlhw
	move	d0,(a2)+		; =FATsize
	beq	getb7			; if =0, bad data
	move	d0,d1
	move	d0,fsiz			; save FAT size

	move	#$e,d0
	bsr	getlhw			; number of reserved sectors
	add	d1,d0
	move	d0,(a2)+		; =2nd FAT start
	move	d0,fatrec		; save 2nd FAT start 

	add	d1,d0			; plus size of second fat
	add	d2,d0			; plus rdlen
	move	d0,(a2)+		; = data start
	move	d0,d2			; save start of data

	move	#$13,d0
	bsr	getlhw			; number of sectors on media
	sub	d2,d0			; subtract # used by FATs,dir,boot
	beq	getb7			; if =0, bad data
	clr.l	d1
	move	d0,d1
	clr	d0
	move.b	$d(a0),d0		; number of sectors/cluster
	divu	d0,d1			; rounding down
	move	d1,(a2)+		; =number of clusters
	move	bfat,(a2)		; =flags, 12 or 16 bit fats

	move.w	sizr,d2			; d2 = current sector size ratio
	lea	sratio,a1		; a1 = ptr to sector size ratio table
	move.w	4(sp),d0		; d0 = drive number
	move.b	d2,(a1,d0.w)		; update sector size ratio in table

	move.w	cpun,d1			; d1 = physical unit #
	btst.b	d1,rmbits		; is unit removable?
	beq	getb6			; if not, can skip the fat checksum

	lea	serno,a1		; a1 = ptr to table of serial #s
	mulu.w	#SERLEN,d0		; dev# * SERLEN to index into table
	adda.l	d0,a1			; a1 = ptr to serial # of dev
	move.w	#SERLEN-1,d1		; length of serial # - 1
getb2:	move.b	$8(a0,d1.w),(a1,d1.w)	; update serial # of dev
	dbra	d1,getb2

	lea	fatsum,a2		; a2 = ptr to FAT check sum table
	move.w	4(sp),d0		; d0 = dev number
	mulu	#FATLEN,d0		; d0*FATLEN = to index into table
	adda.l	d0,a2			; a2 = ptr to FAT check sum tbl of dev

	move.w	fatrec,d0		; d0 = log starting sector of 2nd FAT
	mulu	d2,d0			; (in 512-byte sectors)
	movea.l	$6(sp),a1		; a1 = starting sector of drive
	adda.l	d0,a1			; a1 = phys starting sector of 2nd FAT

	move.w	fsiz,d1			; d1 = # FAT sectors to read
	subq.l	#1,d1			;    = FAT size - 1

getb3:	move.w	sizr,d2			; d2 = count per FAT sector
	subq.w	#1,d2
 	clr.l	temp			; initialize the sum
getb4:	movem.l	d1-d2/a0-a2,-(sp)	; save registers
	move.w	#1,-(sp)		; return media change if detected
	move.w	cpun,-(sp)		; physical unit
	move.l	a0,-(sp)		; buffer (in _dskbufp)
	move.w	#1,-(sp)		; read 1 phys sector
	move.l	a1,-(sp)		; from sector a1
	bsr	pread			; pread()
	adda	#14,sp			; clean up stack
	movem.l	(sp)+,d1-d2/a0-a2	; restore registers
	tst.w	d0			; pread successful?
	beq	getb5			; if so, go on normally
	cmpi.w	#EREADF,d0		; read error?
	beq.s	getba			; if so, retry
	cmpi.w	#EDRVNR,d0		; drive not ready?
	bne	getb8			; if not, return

getba:	movem.l	d1-d2/a0-a2,-(sp)	; save registers
	move.w	24(sp),d1		; d1 = drive # excluding A: and B:
	bsr	critic			; critical error handler
	movem.l	(sp)+,d1-d2/a0-a2	; restore registers
	cmpi.l	#CRITRETRY,d0		; retry?
	beq.s	getb4			; if so, try again
	bra	getb7			; else return

getb5:	bsr	bsum			; add up values in the sector
	addq	#1,a1			; get ready for next sector
	dbra	d2,getb4		; until one logical FAT sector is done

	bsr	csum			; find the checksum
	move.b	d0,(a2)+		; update checksum for this FAT sector
	dbra	d1,getb3		; until all sectors are checked

getb6:	move.w	$4(sp),d0		; d0 = dev number
	lea	mcflgs,a0		; load address of mcflgs table
	clr.b	(a0,d0.w)		; clear mcflg for dev

	lea	xst,a0			; a0 = ptr to drive existence table
	move.b	#2,(a0,d0.w)		; dev definitely exists

	lea	fatst,a0		; a0 = ptr to FAT start sector table
	asl.w	#1,d0			; offset = dev# * 2 (tbl of words)
	move	fatrec,(a0,d0.w)	; update FAT starting sect#

	lea	fatend,a0		; a0 = ptr to FAT end sector table
	move.w	fatrec,d1		; d1 = fatend(dev)
	add.w	fsiz,d1			;    = fatrec + fsiz - 1
	subq.w	#1,d1	
	move.w	d1,(a0,d0.w)		; fatend(dev) = fatrec + fsiz - 1

	lea	start,a0		; a0 = ptr to beginning of start table
	asl.w	#1,d0			; offset = dev# * 2 * 2 (tbl of longs)
	move.l	$6(sp),(a0,d0.w)	; update starting sect# of dev

	move.l	#bpbs,d0		; no errors, return ptr to BPB
	bra.s	getb8			; return

getb7:	moveq	#-1,d0			; error
getb8:	rts


;+
; WORD getlhw(d0=offset)
; returns word (low,high) from 0(D0,A0)
;-

getlhw:	move	d1,-(sp)		; preserve d1
	move.b	1(a0,d0.w),d1
	lsl.w	#8,d1
	move.b	0(a0,d0.w),d1
	move	d1,d0
	move	(sp)+,d1
	rts


;+
; bsum
;
; Passed:
;	a0 = starting address of buffer to be summed
;	temp.l = current sum
;
; Function:
;  	- sum up 512 bytes of a buffer 4 bytes at a time
;	- save the sum in temp.l
;
; Algorithm for check summing the FAT:
;	- add up bytes in the buffer 4 bytes at a time	(in bsum)
;	- if the sum is non-zero, EOR the high word 	(in csum)
;	  with the low word of the 4-byte result
;	- now take this 2-byte result, and EOR its high	(in csum)
;	  byte with its low byte to get the final 1-byte
;	  result
;-
bsum:	movem.l	d1/a0,-(sp)		; save d1, a0
	move.l	temp,d0			; d0 = current sum
	move	#127,d1			; count
bsum0:	add.l	(a0)+,d0		; add 4 bytes to sum
	dbra	d1,bsum0		; until all bytes are added
	move.l	d0,temp			; temp.l = new sum
	movem.l	(sp)+,d1/a0		; restore d1, a0
	rts


;+
; csum
; (a) EOR the high word with the low word of temp.l
; (b) then EOR the high byte with the low byte of result of (a)
;
; Returns:
;	d0.b = checksum
;-
csum:	move.w	temp+2,d0		; d0.w = low word of result
	eor.w	d0,temp			; exclusive-or low and high word
	move.b	temp+1,d0		; d0.b = low byte of xor-ed result
	eor.b	d0,temp			; exclusive-or low and high byte
	move.b	temp,d0
	rts				; d0.b = checksum


;
;----------------
;
;  Read/Write sectors
;
;    Synopsis:	_ahdi_rw(rw, buf, count, recno, dev, lrecno)
;		WORD rw		4(sp).w		; non-zero -> write
;		char buf	6(sp).l
;		WORD count	$a(sp).w
;		WORD recno	$c(sp).w
;		WORD dev	$e(sp).w
;		WORD lrecno	$10(sp).l	; optional
;-

; stack frame offsets
xrw	equ	8
xbuf	equ	10
xcount	equ	14
xrecno	equ	16
xdev	equ	18
xlrecno	equ	20

_sasi_rw:
_ahdi_rw:
	link	a6,#0			; create a frame pointer
	subq.w	#2,xdev(a6)		; drive # excluding A: and B:
	move.w	xrw(a6),d0		; r/w and flags word
	andi.b	#$a,d0			; phys op?  ignore media change?
	bne	ahrw1			; yes, go ahead and do r/w
					; else check for media change
	lea	sratio,a1		; a1 = ptr to sector size ratio table
	adda.w	xdev(a6),a1		; a1 = ptr to dev's sector size ratio
	move.b	(a1),sizr+1		; sizr = current sector size ratio
					;	 (coerced to word)
	lea	mcflgs,a0		; a0 = ptr to mcflgs of drive
	adda.w	xdev(a6),a0		; a0 = ptr to dev's mcflg
	move.b	(a0),d0			; d0 = mcflg of dev
	beq	ahrw1			; if media definitely not, go do r/w

	cmpi.b	#2,d0			; is media definitely changed?
	beq	retmc			; if yes, return media has changed

	sf	mcrw			; mcrw = FALSE
	lea	pun,a1			; a1 = ptr to pun table
	adda.w	xdev(a6),a1		; a1 = ptr to pun dev belongs to
	move.b	(a1),cpun+1		; cpun = pun of dev

chkmc:	lea	start,a1		; a1 = ptr to start table
	move.w	xdev(a6),d0		; d0 = drive #
	add.w	d0,d0			; d0*2*2 (index into tbl of longs)
	add.w	d0,d0
	movea.l	(a1,d0.w),a1		; a1 = dev starting sector

	move.w	#1,-(sp)		; return media change if detected
	move.w	cpun,-(sp)		; physical unit number
	move.l	_dskbufp,-(sp)		; buffer
	move.w	#1,-(sp)		; 1 sector
	move.l	a1,-(sp)		; dev starting sector
	bsr	pread			; try to read dev's boot sector
	adda	#14,sp			; clean up stack
	tst.w	d0			; pread successful?
	beq.s	chkser			; yes, go check serial number

	cmpi.w	#E_CHNG,d0		; media change detected?
	bne.s	rderr1			; if not, assume it's read error

mcchg:	move.b	#1,d0			; d0.b = 1 (may be changed)
	move.w	xdev(a6),d1		; d1.w = drive # excluding A: and B:
	move.b	cpun+1,d2		; d2.b = physical unit number
	bsr	s_mc_xst		; set mcflgs and xst flags for all dev
	bra.s	chkmc			; then try again

rderr1:	move.w	xdev(a6),d1		; device number
	bsr	critic			; call critical error handler
	cmpi.l	#CRITRETRY,d0		; is it the magic RETRY code?
	beq.s	chkmc			; if yes, go back and try it
	bra	ahrw7			; else return

chkser:	lea	serno,a1		; a1 = ptr to serial #s table
	move.w	xdev(a6),d0		; d0 = dev number
	mulu.w	#SERLEN,d0		; *SERLEN for index into table
	adda.l	d0,a1			; a1 = ptr to serial # of dev

	move.l	_dskbufp,a2		; a2 = ptr to buffer
	addq.w	#8,a2			; a2 = ptr to serial # read
 	move.w	#SERLEN-1,d0		; d0 = count for comparison
cmpser:	cmpm.b	(a2)+,(a1)+		; serial # read ?= serial # recorded
	bne	ismc			; no, media has changed
	dbra	d0,cmpser		; compare next byte of serial #
					; serial # hasn't changed, try FAT
	move.w	xdev(a6),d0		; d0 = dev number
	lea	fatsum,a1		; a1 = ptr to fat checksum table
	move.w	#FATLEN,d1		; d1.w = index into table
	mulu	d0,d1
	adda.l	d1,a1			; a1 = ptr to fat checksum of dev

	add.w	d0,d0			; d0*2 = index into table of words
	lea	fatst,a2		; a2 = ptr to FAT start table
	move.w	(a2,d0.w),fatrec	; fatrec = fatst(dev)

	lea	fatend,a2		; a2 = ptr to FAT end table
	move.w	(a2,d0.w),d1		; d1 = counter to scan FAT table
	sub.w	fatrec,d1		;    = fatend(dev) - fatst(dev)

	lea	start,a2		; a2 = ptr to start table
	add.w	d0,d0			; d0*2*2 = index into table of longs
	movea.l	(a2,d0.w),a2		; a2 = start sector of dev
	move.w	fatrec,d2		; d2 = fatst(dev)
	mulu	sizr,d2			; d2 = fatst(dev) in 512-byte sector
	adda.l	d2,a2			; a2 = phys start sector of 2nd FAT

	movea.l	_dskbufp,a0		; a0 = ptr to buffer
cmpfat:	move.w	sizr,d2			; d2 = # reads per FAT sector
	subq.w	#1,d2			; d2 - 1 = counter
	clr.l	temp			; initialize sum
cfat0:	movem.l	d1-d2/a0-a2,-(sp)	; save registers d1, d2, a0, a1, a2
	move.w	#1,-(sp)		; return media change if detected
	move.w	cpun,-(sp)		; physical unit number
	move.l	a0,-(sp)		; buffer
	move.w	#1,-(sp)		; 1 sector
	move.l	a2,-(sp)		; at sector a2
	bsr	pread			; try to read this FAT sector
	adda	#14,sp			; clean up stack
	movem.l	(sp)+,d1-d2/a0-a2	; restore registers d1, a0, a1, a2
	tst.w	d0			; pread successful?
	beq.s	chkfat			; if yes, go check sum FAT sectors
					; else check if it's media change
	cmpi.w	#E_CHNG,d0		; media change detected?
	beq	mcchg			; if so, go test media change again
					; else assume it's read error
	movem.l	d1-d2/a0-a2,-(sp)	; save registers d1, d2, a0, a2
	move.w	xdev(a6),d1		; drive number
	bsr	critic
	movem.l	(sp)+,d1-d2/a0-a2	; restore registers d1, d2, a0, a2
	cmpi.l	#CRITRETRY,d0		; is it the magic RETRY code?
	beq.s	cfat0			; if yes, go back and try it
	bra	ahrw7			; else return

chkfat:	bsr	bsum			; if ok, sum the sector
	addq	#1,a2			; ready for try next sector
	dbra	d2,cfat0		; until one FAT sector is summed

	bsr	csum			; find the checksum
	cmp.b	(a1)+,d0		; checksum recorded ?= checksum found
	bne	ismc			; if no match, media has changed
	dbra	d1,cmpfat		; until all sectors are checked

	lea	mcflgs,a0		; a0 = ptr to mcflgs table
	adda.w	xdev(a6),a0		; a0 = ptr to mcflg of drive
	clr.b	(a0)			; clear mcflg for dev

ahrw1:	tst.w	xcount(a6)		; any sector to r/w?
	beq	ahrw6			; if =0, done

	cmpi.w	#-1,xrecno(a6)		; does recno = -1?
	bne.s	ahrw9			; if not, we have a word record #
	move.l	xlrecno(a6),a1		; a1.l = start record #
	bra.s	ahrwa
ahrw9:	moveq	#0,d0			; coerce to long
	move.w	xrecno(a6),d0		; d0.l = recno
	movea.l	d0,a1			; a1.l = start record #

ahrwa:	move.l	a1,strec		; save first sector to r/w
	moveq	#0,d1			; coerce to long
	move.w	xcount(a6),d1		; d1.l = #sectors to r/w
	adda.l	d1,a1			; a1.l = last sector to r/w
	subq.w	#1,a1			;      = first sector + count - 1
	move.l	a1,endrec		; save last sector to r/w
	move.l	xbuf(a6),stbuf		; save starting buffer address

	move.l	strec,d1		; d1.l = starting sector to r/w
	moveq	#0,d2			; clear d2
	move.w	xcount(a6),d2		; d2.l = # sectors to r/w
	btst.b	#3,xrw+1(a6)		; physical operation?
	bne.s	ahrwb			; if so, go on
					; else log -> phys sector mapping
	mulu	sizr,d1			; d1.l = phys start sector to r/w
	mulu	sizr,d2			; d2.l = # phys 512-byte sects to r/w

ahrwb:	move.l	xbuf(a6),a1		; a1.l = buffer addr to r/w
	cmpi.l	#MAXSECTORS,d2		; more than one DMAfull?
	bgt.s	ahrwc			; if so, only do one DMAfull
	move.w	d2,xcount(a6)		; else xcount(a6) = # sects requested
	bra.s	ahrw2
ahrwc:	move.w	#MAXSECTORS,xcount(a6)	; xcount(a6) = 1 DMAfull of sects
ahrw2:	btst	#0,xbuf+3(a6)		; an odd boundary?
	beq.s	ahrw4			; no, so do normally

	cmpi.w	#2,xcount(a6)		; can only do 2 at a time tops this way
	ble.s	ahrw3
	move.w	#2,xcount(a6)

ahrw3:	move.l	_dskbufp,a1		; use the bios buffer for this transfer

	btst	#0,xrw+1(a6)		; is this a write?
	beq.s	ahrw4			; no, so go fill buffer from disk

	movea.l	xbuf(a6),a2		; source (a1.l = dest)
	move.w	xcount(a6),-(sp)	; # sectors to be moved
	bsr	smove			; move sectors from a2 to a1
	addq.l	#2,sp			; clean up stack

ahrw4:	movem.l	d1-d2,-(sp)		; save total count and start sector
	move.w	xdev(a6),-(sp)
	move.l	d1,-(sp)
	move.w	xcount(a6),-(sp)	; count
	move.l	a1,-(sp)		; buffer
	move.w	xrw(a6),-(sp)
	bsr	_do_rw
	adda	#14,sp
	movem.l	(sp)+,d1-d2		; restore total count and start sector
	tst.l	d0			; any errors there?
	beq.s	ahrw8			; no, go on normally

	cmpi.l	#E_CHNG,d0		; media change detected?
	bne	ahrw7			; if not, give up
	st	mcrw			; else it's mc returned when r/w
	bra	mcchg			; and go check if media has changed

ahrw8:	btst	#0,xbuf+3(a6)		; on odd boundary?
	beq.s	ahrw5			; if not, go on normally
	btst	#0,xrw+1(a6)		; was it a read?
	bne.s	ahrw5			; if it wasn't, go on normally
					; else
	movea.l	xbuf(a6),a1		; must move data read to desired dest
	movea.l	_dskbufp,a2		; from dskbuf
	move.w	xcount(a6),-(sp)	; # of sectors to move
	bsr	smove
	addq.l	#2,sp			; clean up stack

ahrw5:	moveq	#0,d0			; clear d0
	move.w	xcount(a6),d0		; #sectors we did
	sub.l	d0,d2			; #sectors left to do
	add.l	d0,d1			; next starting sector to r/w
	asl.l	#8,d0			; d0 = #bytes we did
	add.l	d0,d0			;    = #sectors * 512
	add.l	d0,xbuf(a6)		; buf += (sectors_done * sector size)
	tst.l	d2			; anything left to r/w?
	bne	ahrwb			; if so, continue
					; check if wrote to boot sector
chkwr:	move.w	xrw(a6),d0		; d0 = r/w and flags word
	btst	#0,d0			; was it a write?
	beq	ahrw6			; if not, done
	btst	#3,d0			; was it a physical operation?
	bne	ahrw6			; if it was, done
	btst	#1,d0			; ignore media change?
	bne.s	wrfat			; if so, update FAT chksums if appl.
	tst.l	strec			; wrote to boot sector?
	bne.s	wrfat			; if not, update FAT chksums if appl.
	lea	mcflgs,a0		; else, a0 = ptr to mcflgs table
	adda.w	xdev(a6),a0		; a0 = ptr to dev's mcflg
	move.b	#2,(a0)			; assume medium has changed

wrfat:	moveq	#0,d0			; clear d0
	move.b	cpun+1,d0		; d0.b = pun of dev
	btst.b	d0,rmbits		; is drive removable?
	beq	ahrw6			; if not, done
					; else check if wrote to FATs
	lea	fatend,a0		; a0 = ptr to fatend table
	move.w	xdev(a6),d0		; d0 = device number
	add.w	d0,d0			; d0*2 = index into table of words
	moveq	#0,d1			; coerce to long
	move.w	(a0,d0.w),d1		; d1 = last FAT's ending sector
	cmp.l	strec,d1		; wrote beyond the last FAT?
	blt	ahrw6			; if so, done

	lea	fatst,a0		; a0 = ptr to fatst table
	moveq	#0,d2			; coerce to long
	move.w	(a0,d0.w),d2		; d2 = last FAT's starting sector
	cmp.l	endrec,d2		; wrote before the last FAT?
	bgt	ahrw6			; if so, done
					; else update FAT sector checksums
	move.l	stbuf,a0		; a0 = ptr to buffer w/ written data
	lea	fatsum,a1		; a1 = ptr to start of fatsum table
	move.w	xdev(a6),d0		; d0 = dev number
	mulu.w	#FATLEN,d0		; d0 = offset to dev's FAT chksum
	adda.l	d0,a1			; a1 = ptr to dev's first FAT chksum
	move.l	strec,d0		; d0 = first sector wrote to
	sub.l	d2,d0			; d0 = strec - start(last FAT)
	beq.s	wrfat2			; if strec = start(last FAT), 
					;     no adjustments needed
 	blt.s	wrfat1			; if strec < start(last FAT)
					;     begin from start(last FAT)
	move.l	strec,d2		; else begin from strec
	adda.l	d0,a1			; a1 = ptr to fatsum to be updated
	bra.s	wrfat2

wrfat1:	neg.l	d0			; d0 = index into stbuf
	asl.l	#8,d0			;    = (start(last FAT) - strec)*512
	add.l	d0,d0
	adda.l	d0,a0			; a0 = pt to addr of buf for update

wrfat2:	cmp.l	endrec,d1		; if end(last FAT) <= endrec
	ble.s	wrfat3			;     stop at end(last FAT)
	move.l	endrec,d1		; else stop at endrec

wrfat3:	sub	d2,d1			; d1 = # sectors to be processed
wrfat4:	move.w	sizr,d2			; d2 = # phys sect per log sect
	subq.w	#1,d2			; dbra likes one less
	clr.l	temp			; initialize sum
wrfat5:	bsr	bsum			; sum up one 512-byte sector
	adda.l	#512,a0			; point to next 512 bytes
	dbra	d2,wrfat5		; until one logical sector is done
	bsr	csum			; obtain checksum
	move.b	d0,(a1)+		; record new fat checksum
	dbra	d1,wrfat4		; do until all are updated

ahrw6:	clr.l	d0			; got here with no errors!
	bra.s	ahrw7

ismc:	tst.b	mcrw			; media change returned by r/w?
	beq	onemc			; no, only dev has changed
	move.b	#2,d0			; d0.b = value to set to
	move.w	xdev(a6),d1		; d1.w = dev number
	move.b	cpun+1,d2		; d2.b = physical unit number
	bsr	s_mc_xst		; set mcflgs and xst flags for devs
	bra.s	retmc			; return media change detected

onemc:	lea	mcflgs,a0		; a0 = ptr to mcflgs table
	adda.w	xdev(a6),a0		; a0 = ptr to dev's mcflg
	move.b	#2,(a0)			; set mcflg for dev to has changed
	lea	xst,a0			; a0 = ptr to drive existence table
	adda.w	xdev(a6),a0		; a0 = ptr to xst flag of dev
	move.b	#2,(a0)			; assume dev exists

retmc:	move.l	#E_CHNG,d0		; yes, return media change error
ahrw7:	unlk	a6
	rts


;----------------
;
;  Copy unaligned sectors
;  (this is *supposed* to be slow!)
;
;    Passed:	d2.w	= # of sectors (known to be 1 or 2)
;		a2	-> source sector
;		a1	-> dest buffer (oddly aligned)
;
smove:	move.w	4(sp),d0		; d0 = # 512-byte sectors to move
	asl.w	#8,d0			; d0 * 512 = # bytes to move
	asl.w	#1,d0
	subq.w	#1,d0			; dbra likes one less
smove1:	move.b	(a2)+,(a1)+
	dbra	d0,smove1
	rts


;
;+
; _do_rw - called to read/write no more than 128K to an even boundary
;
; Passed:	dev	$10(sp).W
;		recno	$c(sp).L
;		count	$a(sp).W
;		buf	6(sp).L
;		rw	4(sp).W		; non-zero -> write
;
;-
_do_rw:
	move.w	d3,-(sp)		; preserve d3

sasrw0:	move.w	_retries,retrycnt	; setup retry counter

	move.w	6(sp),d3		; rw
	btst	#2,d3			; are retries disabled?
	beq.s	sasrw1			; no, act normally
	move.w	#0,retrycnt		; yes, so set retrycnt to zero

sasrw1:	lea	2(sp),a1		; frame pointer
	move.l	$c(a1),d0		; sect.L
	move.w	4(a1),d3		; rw

	btst	#3,d3			; physical unit operation
	beq.s	sasrw2			; no, so do log->phys mapping

	move	$10(a1),cpun		; get unit number
	bra.s	sasrw3			; and use that as the physical unit

sasrw2:	clr	d2			; coerce byte to word
	move.w	$10(a1),d1		; get device
 	lea	pun,a2
	move.b	(a2,d1.w),cpun+1	; get physical unit number
sasrw3:	move.w	cpun,-(sp)		; dev
	move.l	6(a1),-(sp)		; buf
	move.w	$a(a1),-(sp)		; count

	btst	#3,d3			; physical operation?
	bne.s	sasrw4			; yes, so no offset

	add.w	d1,d1			; d1*2*2 = index into table of longs
	add.w	d1,d1
	lea	start,a2
	add.l	(a2,d1.w),d0		; adjust sector number

sasrw4:	move.l	d0,-(sp)		; sect
	btst	#0,d3			; read or write?
	bne.s	sasrw5			; (write)
	bsr	_hread			; read sectors
	bra.s	sasrw6
sasrw5:	bsr	_hwrite			; write sectors
sasrw6:	adda	#12,sp			; (cleanup stack)
	tst.l	d0			; errors?
	beq	sasrwr			; no -- success

	bsr	errcode			; find error code
	cmpi.b	#MDMCHGD,d0		; media change detected?
	beq.s	sasrw7
	cmpi.b	#WRTPRTD,d0		; write on write-protected media?
	beq.s	sasrw9
	cmpi.b	#DRVNRDY,d0		; drive not ready?
	beq.s	sasrwe

	subq.w	#1,retrycnt		; drop retry count and retry
	bpl	sasrw1

	move	6(sp),d1		; get r/w and flags word
	move.l	#EREADF,d0		; read error code
	btst	#0,d1			; is it a write?
	beq.s	sasrwa
	move.l	#EWRITF,d0		; write error code
	bra.s	sasrwa

sasrw7:	move.w	6(sp),d1		; get r/w and flags word
	andi.b	#$a,d1			; no media change/physical operation?
	beq.s	sasrw8			; if not, return media change
	move.b	#1,d0			; d0.b = medium may have changed
	move.w	$12(a6),d1		; d1.w = dev number
	move.b	cpun+1,d2		; d2.b = physical unit number
	bsr	s_mc_xst		; set mcflgs and xst flags for dev
	bra	sasrw0			; start all over
	
sasrw8:	move.l	#E_CHNG,d0		; media change detected
	bra.s	sasrwr			; return

sasrw9:	move.l	#EWRPRO,d0		; write on write-protected media
	bra.s	sasrwf

sasrwe:	move.l	#EDRVNR,d0		; drive not ready
sasrwf:	move.w	6(sp),d1		; get r/w and flags word

sasrwa:	btst	#3,d1			; is this a physical operation?
	beq.s	sasrwc			; no, call critical error handler
					; else find 1st drive of current unit
	lea	pun,a0			; a0 = ptr to pun table
	move.w	cpun,d2			; d1 = current pun
	moveq	#0,d1			; d2 = index into pun table
sasrwb:	cmp.b	(a0,d1.w),d2		; 1st drive of unit?
	beq.s	sasrwd			; if so, get drive number 
	addq.w	#1,d1			; else, get next drive number
	cmpi.w	#MAXUNITS,d1		; reach end of pun table?
	bge.s	sasrwr			; if so, forget it
	bra.s	sasrwb			; else try this next drive

sasrwc:	move.w	$12(sp),d1		; d1 = drive number
sasrwd:	bsr	critic
	cmpi.l	#CRITRETRY,d0		; is it the magic RETRY code?
	beq	sasrw0			; if yes, go retry

sasrwr:	move.w	(sp)+,d3		; remember to restore d3
	rts


;
;----------------
;
; Check for media change on hard disk
; Synopsis:	_sasi_mediach(dev)
;		WORD dev;		4(sp).w
;
; Returns:	0L - media definitely has not changed
;		1L - media _may_ have changed
;		2L - media definitely has changed
;
; Uses:		d0, d1, a0, a1
;
; Comments:
; Apr-4-1989	ml.	Add in grace period between _sasi_mediach()s.
;			If _sasi_mediach() was called less than 1 s
;			(200 _hz_200 clock ticks) ago, and medium was 
;			not changed then, assume medium still has not 
;			changed.
;
_sasi_mediach:
	subq.w	#2,4(sp)		; dev # excluding drv A and B
	move.w	4(sp),d1		; d1 = current drive
	lea	mcflgs,a0		; a0 = pointer to mcflgs
	moveq	#0,d0			; d0 = mcflg for current drive
	move.b	(a0,d1.w),d0	
	tst.b	d0			; has medium changed?
	bne.s	decided			; if yes or maybe, return result
					; else verify that it has not
	move.l	lastmdctm,d2		; time media change was last called
	cmp.l	_hz_200,d2		; while (_hz_200 <= lastmdctm)
	bcc.s	decided			;	assume medium not changed

	lea	pun,a1			; ptr to beginning of pun table
	clr.w	d2			; coerce byte to word
	move.b	(a1,d1.w),d2		; d2 = pun current drive belongs to

	btst.b	d2,rmbits		; is pun removable?
	beq.s	notchngd		; if not, medium has not changed

	movem.w	d1-d2,-(sp)		; else save registers
	move.w	d2,-(sp)		; physical unit number
	bsr	testunit		; verify by doing test unit ready
	addq.l	#2,sp
	movem.w	(sp)+,d1-d2		; restore registers
	move.l	_hz_200,lastmdctm	; update time for last _sasi_mediach()
	addi.l	#200,lastmdctm		; 
	tst.w	d0			; return good status?
	beq.s	notchngd		; if yes, return medium not changed
	moveq	#1,d0			; else return medium may have changed
	bsr	s_mc_xst		; set mcflgs and xst flags to 1's
	bra.s	decided
notchngd:
	moveq	#0,d0			; return medium has not changed
decided:
	rts


;+
; s_mc_xst - set mcflgs and drive existence flags 
;	     for drives belonging to a physical unit 
;	     to value passed
;
; Passed:	d0.b - value to set to
;	 	d1.w - dev number
;		d2.b - physical unit #
;-
s_mc_xst:
	movem.l	a0-a2,-(sp)	; save registers
	move.w	d1,-(sp)	; save dev number
	lea	mcflgs,a0	; a0 = ptr to mcflgs table
	lea	pun,a1		; a1 = ptr to pun table
	lea	xst,a2		; a2 = ptr to drive existence table
back:	cmp.b	(a1,d1.w),d2	; does this drive belongs to this physical unit?
	bne.s	oppdir		; if not, try opposition direction
	move.b	d0,(a0,d1.w)	; else change its mcflg to value passed
	move.b	d0,(a2,d1.w)	; and change its xst to value passed
	dbra	d1,back		; try next one in backward direction
oppdir:	move.w	(sp)+,d1	; get device number again
forth:	addq.w	#1,d1		; try next one in forward direction
	cmp.w	#MAXUNITS,d1	; all units checked?
	bge.s	setr		; if yes, get ready to return
	cmp.b	(a1,d1.w),d2	; does this drive belongs to this physical unit?
	bne.s	setr		; if not, get ready to return
	move.b	d0,(a0,d1.w)	; else change its mcflg to value passed
	move.b	d0,(a2,d1.w)	; and change its xst to value passed
	bra.s	forth		; continue to search
setr:	movem.l	(sp)+,a0-a2	; restore registers
	rts


;
;--------------------- Low-Level Driver -------------------

;----------------
;
;  Hardware definitions
;
wdc		equ	$ffff8604
wdl		equ	$ffff8606
wdcwdl		equ	wdc		; used for long writes
xwdl		equ	wdl-wdc		; offset from wdc to wdl

dmahi		equ	$ffff8609
dmamid		equ	dmahi+2
dmalow		equ	dmamid+2
gpip		equ	$fffffa01


;----------------
;
;  Tunable (delay) values
;
ltimeout		equ	600		; long-timeout (3 S)
stimeout		equ	20		; short-timeout (100 mS)


;----------------
;
; LONG _qdone() - Wait for command byte handshake
; LONG _fdone() - Wait for operation complete
; Passed:	nothing
;
; Returns:	EQ: no timeout
;		MI: timeout condition
;
; Uses:		D0
;
; each pass through the loop takes 6.75 uS
;-
_fdone:	move.l	_hz_200,d0
	add.l	#ltimeout,d0
	bra.s	qd1

_qdone:	move.l	_hz_200,d0
	add.l	#stimeout,d0

qd1:	cmp.l	_hz_200,d0		; timeout?
	bcs.s	qdq			; (i give up, return NE)
	btst	#5,gpip			; interrupt?
	bne.s	qd1			; (not yet)

	moveq	#0,d0			; return EQ (no timeout)
	rts

qdq:	moveq	#-1,d0
	rts


;----------------
;
; Wait for end of SASI command
;
; Passed:	d0 value to be written to wdl
;
; Returns:	EQ: success (error code in D0.W)
;		MI: timeout (-1 in D0.W)
;		NE: failure (SASI error code in D0.W)
;
; Uses:		d0,d1
;-
_endcmd: move	d0,d1			; preserve wdl value

	bsr	_fdone			; wait for operation complete
	bmi.s	endce			; (timed-out, so complain)

	move.w	d1,wdl
	move.w	wdc,d0			; get the result
	and.w	#$00ff,d0		; (clean it up), if non-zero should
					; do a ReadSense command to learn more
endce:	move.l	_hz_200,lastacstm	; update controller last accessed time
	addq.l	#2,lastacstm		; lastacstm = _hz_200 + 2;
	rts				


;+
;  Handle command timeout;
;  Unlock DMA chip and return completion status;
;-
_hto:	moveq	#-1,d0		; indicate timeout
_hdone:	move.w	#$80,wdl	; Landon's code seems to presume we
	tst.w	wdc
	clr	flock		; NOW, signal that we are done
	rts


;+
; delay()
;	5 - 10ms kludge delay for message byte sent back by controller.
;-
_delay:	move.l	lastacstm,d0		; d0 = controller last accessed time
wait:	cmp.l	_hz_200,d0		; while (_hz_200 <= lastacstm)
	bcc.s	wait			;	wait()
	rts


;
;-----------------
;
; _hread(sectno, count, buf, dev)
; LONG sectno;		 4(sp)
; WORD count;		 8(sp)
; LONG buf;		$a(sp)	$b=high, $c=mid, $d=low
; WORD dev;		$e(sp)
;
; Returns:	-1 on timeout
;		0 on success
;		nonzero on error
;
;-
_hread:	bsr	_delay
	movea.l	#wdc,a0			; pointer to DMA chip
	st	flock			; lock FIFO

	move	#$88,xwdl(a0)	;wdl
	clr.l	d0
	move.w	$0e(sp),d0		; get unit number
	lsl.w	#5,d0
	swap	d0
	ori.l	#$0008008a,d0		; 08 wdc, 8a wdl
	move.l	d0,(a0) 	;wdcwdl

	move.l	$a(sp),-(sp)		; set DMA address
	bsr	_setdma
	addq.l	#4,sp

	bsr	_setss			; set sector and size
	bmi	_hto

	move.w	#$190,xwdl(a0)	;wdl
	move.w	#$90,xwdl(a0)	;wdl
	move.w	8(sp),(a0) 	;wdc	; write sector count to DMA chip
	move.w	#$8a,xwdl(a0)	;wdl
	move.l	#$00000000,(a0) ;wdcwdl	; control byte  0 wdc 0 wdl

	move.w	#$8a,d0
	bsr	_endcmd

hrx:	bra	_hdone			; cleanup after IRQ


;
;----------------
;
; _hwrite(sectno, count, buf, dev)
; LONG sectno;		 4(sp)
; WORD count;		 8(sp)
; LONG buf;		$a(sp)	$b=high, $c=mid, $d=low
; WORD dev;		$e(sp)
;
;-
_hwrite:
	bsr	_delay
	movea.l	#wdc,a0			; pointer to DMA chip
	st	flock			; lock FIFO

	move.l	$a(sp),-(sp)		; set DMA address
	bsr	_setdma
	addq.l	#4,sp

	move.w	#$88,xwdl(a0)	;wdl
	clr.l	d0
	move.w	$0e(sp),d0		; get unit number
	lsl.w	#5,d0
	swap	d0
	ori.l	#$000a008a,d0		; 0a wdc 8a wdl
	move.l	d0,(a0) 	;wdcwdl

	bsr	_setss
	bmi	_hto

	move.w	#$90,xwdl(a0)	;wdl
	move.w	#$190,xwdl(a0)	;wdl
	move.w	8(sp),(a0) 	;wdc	; sector count for DMA chip's benefit
	move.w	#$18a,xwdl(a0)
	move.l	#$00000100,(a0) ;wdcwdl

	move.w	#$18a,d0
	bsr	_endcmd

hwx:	bra	_hdone			; cleanup after IRQ


;
;----------------
;
; Set DMA address
;
; void _setdma(addr)
; LONG addr;
;-
_setdma:
	move.b	7(sp),dmalow
	move.b	6(sp),dmamid
	move.b	5(sp),dmahi
	rts


;----------------
;
; Set sector number and number of sectors
;
_setss:	move.w	#$8a,xwdl(a0)

	bsr	_qdone			; wait for controller to take command
	bmi	setsse

	move.b	9(sp),d0		; construct sector#
	swap	d0
	move.w	#$008a,d0
	move.l	d0,(a0) 	;wdcwdl	; write MSB sector# + devno
	bsr	_qdone
	bmi	setsse

	move.b	10(sp),d0		; write MidSB sector#
	swap	d0
	move.w	#$008a,d0
	move.l	d0,(a0) 	;wdcwdl
	bsr	_qdone
	bmi	setsse

	move.b	11(sp),d0		; write LSB sector#
	swap	d0
	move.w	#$008a,d0
	move.l	d0,(a0) 	;wdcwdl
	bsr	_qdone
	bmi	setsse

	move.w	12(sp),d0		; write sector count
	swap	d0
	move.w	#$008a,d0
	move.l	d0,(a0) 	;wdcwdl
	bsr	_qdone

setsse:	rts


;
;----------------
;
;  _inquiry - get device-specific parameters
;
;    Synopsis:	LONG _inquiry(physunit#, parms)
;		WORD physunit#;			4(sp).W
;		char *parms;			6(sp).L
;
; Old driver uses these two lines which do NOT do 
; "d0 = (dev << 5) << 16" because the hi word of
; D0 before the swap (lo word after) is garbage.
;	lsl.b	#5,d0
;	swap	d0
;-
_inquiry:
	bsr	_delay
	st	flock			; lock FIFO
	move.l	6(sp),-(sp)		; -> parameter block address
	bsr	_setdma			; set DMA there
	addq.l	#4,sp
	movea.l	#wdc,a0			; pointer to DMA chip
; write command and phyunit#
	move.w	#$88,xwdl(a0)	;wdl
	move.w	4(sp),d0		; d0 = (physunit# << 5) << 16
	moveq	#21,d1
	lsl.l	d1,d0			
	or.l	#$0012008a,d0		; write physunit# + Inquiry + FIFO bits
	move.l	d0,(a0)		;wdcwdl	; inquiry+physunit# wdc 8a wdl (byte 0)
	bsr	_qdone
	bmi	inq

	move.l	#$8a,d1			; d1 = byte to be sent
	move.l	d1,(a0)		;wdcwdl	; byte 1
	bsr	_qdone
	bmi	inq

	move.l	d1,(a0)		;wdcwdl	; byte 2
	bsr	_qdone
	bmi	inq

	move.l	d1,(a0)		;wdcwdl	; byte 3
	bsr	_qdone
	bmi	inq

	move.l	#$0010008a,(a0)	;wdcwdl	; 16 byte of parameters (byte 4)
	bsr	_qdone
	bmi	inq

	move.w	#$190,xwdl(a0)	;wdl	; reset the DMA chip
	move.w	#$90,xwdl(a0)	;wdl
	move.w	#$01,(a0)	;wdc	; 1 sector of DMA (actually less)
	move.w	#$8a,xwdl(a0)	;wdl
	move.l	#0,(a0)		;wdcwdl	; byte 5 (control byte)
	move.w	#$8a,d0			; wdl value
	bsr	_endcmd			; wait for command completion
inq:	bra	_hdone


;
;---------------
;
;  LONG _rq_sense() - get non-extended sense data from target
;  LONG _rq_xsense() - get extended sense data from target
;
;  Passed:
;	WORD physunit#;			4(sp).W		$6(sp).w
;	char data[];			6(sp).L		$8(sp).l
;
;  Returns:
;	    0 : OK
;	non-0 : ERROR
;
_rq_sense:
	moveq	#3,d2			; do it 4 times
	move.w	#0,-(sp)		; request 4 bytes of sense data
	bra.s	rq0
_rq_xsense:
	moveq	#0,d2			; do it one time
	move.w	#16,-(sp)		; request 16 bytes of sense data
rq0:	bsr	_delay			; kludge delay
	movea.l	#wdc,a0
	st	flock			; lock FIFO
	move.l	8(sp),-(sp)		; -> sense data buffer address
	bsr	_setdma			; set DMA there
	addq.l	#4,sp

 	move.w	#$190,xwdl(a0)	;wdl	; reset the DMA chip
	move.w	#$90,xwdl(a0)	;wdl
	move.w	#$01,(a0)	;wdc	; 1 sector of DMA (actually less)

	moveq	#0,d0
rq1:	move.w	#$88,xwdl(a0)	;wdl
	move.w	6(sp),d0		; d0 = (dev << 5) << 16
	lsl.b	#5,d0
	swap	d0			; in upper word
	or.l	#$0003008a,d0		; write dev#+Request Sense+FIFO bits
	move.l	d0,(a0)		;wdcwdl	; rqsense+dev wdc 8a wdl (byte 0)
	bsr	_qdone
	bmi.s	wdq1

	move.l	#$8a,d1		; byte to be sent
	move.l	d1,(a0)		;wdcwdl	; byte 1
	bsr	_qdone
	bmi.s	wdq1

	move.l	d1,(a0)		;wdcwdl	; byte 2
	bsr	_qdone
	bmi.s	wdq1

	move.l	d1,(a0)		;wdcwdl	; byte 3
	bsr	_qdone
	bmi.s	wdq1

	move.w	(sp),d0			; # bytes of sense data requested
	swap	d0
	or.l	d1,d0
	move.l	d0,(a0)		;wdcwdl	; byte 4
	bsr	_qdone
	bmi.s	wdq1

	move.w	#$8a,xwdl(a0)	;wdl
	move.l	#0,(a0)		;wdcwdl	; byte 5 (control byte)
	move.w	#$8a,d0			; wdl value
	bsr	_endcmd			; wait for command completion
	tst.w	d0
	bmi.s	wdq1
	dbra	d2,rq1			; go back until done
wdq1:	addq.l	#2,sp			; clean up stack
	bra	_hdone


;
;----------------
;
;  testunit - Test Unit Ready
;
;    Synopsis:	LONG testunit(dev)
;		WORD dev;		4(sp).W
;
;    Uses:  d0, d1, and a0
;-
tst:	dc.b	0	; format command + devno (upper 3 bits)
	dc.b	0	; (unused)
	dc.b	0	; (unused)
	dc.b	0	; (unused)
	dc.b	0	; (unused)
	dc.b	0	; (unused)
.even

testunit:
	bsr	_delay
	move.w	4(sp),d0		; set dev#
	lsl.b	#5,d0			; up 5 bits, fill in 0s
	move.b	d0,tst			; stuff into command frame
	lea	tst(pc),a0		; pick up pointer to the command block
	clr.w	d0
	st	flock			; lock FIFO
	move.w	#$88,wdl
	move.b	(a0)+,d0		; get the command byte
	swap	d0
	move.w	#$8a,d0
	move.l	d0,wdc			; byte wdc 8a wdl

	moveq	#(5-1),d1		; write remaining 5 bytes of command
tst1:	bsr	_qdone
	bmi	_hto
	move.b	(a0)+,d0		; next byte of command
	swap	d0
	move.w	#$8a,d0
	move.l	d0,wdcwdl
	dbra	d1,tst1
	bsr	_endcmd			; wait for command completion
	bra	_hdone			; cleanup after IRQ


;
;---------------- Resident Installer -------------------

isasi5:	move.l	#(i_sasi1-i_sasi),tokeep ; at least keep this much

	cmpi.w	#512,maxssz	; maxssz > 512 bytes?
	bls.s	nboot0		; if not, don't need to replace GEMDOS buffers
				; else check if there is enough memory for
chkmem:	bsr	chklstmem	;   new GEMDOS buffer lists
	tst.l	d0		; enough?
	bpl.s	okbig		; if so, build the list
	move.w	minbigsect,d0	; d0 = minimum big sector
	cmp.w	maxssz,d0	; is maxssz >= minimum big sector?
	bcc.s	regsect		; if so, give up
	move.w	d0,maxssz	; else try minimum big sector
	bra.s	chkmem
regsect:
	move.w	#512,maxssz	; else, cannot handle big sectors
	bra.s	nboot0

okbig:	move.l	d1,tokeep	; update amout of memory to be kept
	lea	i_sasi1,a0	; a0 = ptr to beginning of new buffer lists
	moveq	#3,d1		; d1 = count = 4 buffers - 1
	bsr	list_init	; initialize the buffer list
	clr.l	(a0,d0.w)	; cut 1 list of 4 buffers to 2 lists of 2
	move.l	a0,_bufl	; _bufl[0] -> 1st new buffer list
	add.l	d0,d0		; d0 = offset to beginning of 2nd buffer list
	adda.l	d0,a0		; a0 = head of 2nd buffer list
	move.l  a0,_bufl+4	; _bufl[1] -> 2nd new buffer list

nboot0:	bsr	pool_install	; attempt to install more OS pool
	tst.w	bootloaded	; if bootloaded, then already in super mode
	bne.s	nboot1		; (already there)
	move.l	d0,-(sp)	; save size of installed pool
	move.l	savssp,-(sp)	; become a mild mannered user process
	move.w	#$20,-(sp)	; Super(savssp)
	trap	#1
	addq.l	#6,sp
	move.l	(sp)+,d0	; restore size of installed pool

nboot1:	add.l	tokeep,d0	; compute value for Ptermres() or Mshrink
	tst.w	bootloaded	; exit to GEMDOS?
	beq	nboot2		; (yes -- not boot loaded)

;+
;  Return to TOS ROMs
;    - set default boot device to C:
;    - Print silly message
;    - Mshrink() memory that was alloc'd to us
;    - set magic# in D7 for TOS ROMs
;    - RTS back to ROMs
;-
	add.l	#$1c,d0		; for file header
	move.l	d0,-(sp)	; save D0
	pea	msg_loaded(pc)	; print announcement
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	(sp)+,d0

	move.b	d7,d1		; d1.b = physical unit # boot loaded from
	lsr.b	#5,d1		;      = xxx00000 >> 5
	lea	pun,a0		; a0 = ptr to pun table
	move.w	#0,d2		; d2 = boot dev
bd1:	cmp.b	(a0,d2.w),d1	; d2 belongs to physical unit booted from?
	beq	bd2		; if yes, set (d2) as boot device
	addq.w	#1,d2		; else try next logical unit
	bra.s	bd1
bd2:	addq.w	#2,d2		; offset for drive A and B
	move.w	d2,_bootdev	; set default boot device to (d2)

	move.l	d0,-(sp)
	move.l	baseaddr,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)	; Mshrink(...)
	trap	#1
	adda	#12,sp		; (cleanup stack)

	move.w	_bootdev,-(sp)	; set boot dev as default drive
	move.w	#$e,-(sp)	; Dsetdrv(_bootdev)
	trap	#1
	addq.l	#4,sp		; cleanup stack

	move.l	rootpath,-(sp)	; set root as current directory
	move.w	#$3b,-(sp)	; Dsetpath('\')
	trap	#1
	addq.l	#6,sp		; cleanup stack

	move.l	_sysbase,a0	; get the system header address
	move.l	$18(a0),d0	; d0.l = MMDDYYYY of ROM date
	swap	d0		; d0.l = YYYYMMDD of ROM date
	cmp.l	#CHKDATE,d0	; does this version of ROM need bootstop?
	bcs.s	stopall		; yup, if OS is built before 4/22/87
	move.b	puns+1,d7	; else processed units from booting
	subq.b	#1,d7		; unit # = # of units - 1
	lsl.b	#5,d7
	rts			; return to TOS ROMs

stopall:
	move.b	#$100-$20,d7	; prevent any other unit from booting
	rts			; return to TOS ROMs

rootpath:
	dc.b	'\\',0
msg_loaded:
	dc.b	'----------------------',13,10
	dc.b	'Atari Hard Disk Driver',13,10
	dc.b	'AHDI v3.00 Apr-11-1989',13,10
	dc.b	'----------------------',13,10
	dc.b	0
.even

;
;  Terminate and stay resident;
;  installed driver under GEMDOS.
;
nboot2:	add.l	#$0100,d0	; for basepage
	move.w	#0,-(sp)	; exit code
	move.l	d0,-(sp)
	move.w	#$31,-(sp)	; terminate and stay resident
	trap	#1		; should never come back...
	illegal



;+
; list_init - Initialize a GEMDOS buffer list (BCBs are contiguous)
;
; Passed:
; 	a0.l = head of buffer list			(not changed)
;	d0.l = size of each BCB (including data block)	(not changed)
;	d1.w = count
;	     = number of buffers to be installed to the list - 1
;
; Uses:
;	d1, a1
;-
list_init:
	move.l	a0,-(sp)	; save head of buffer list
lin0:	movea.l	a0,a1		; a1 = ptr to next BCB
	adda.l	d0,a1		;    = ptr to curr BCB + size of BCB
	move.l	a1,(a0)		; b_link -> next BCB
	move.w	#-1,4(a0)	; b_neg1 = -1
	adda.w	#BCBLEN,a0	; a0 = ptr to BCB data block
	move.l	a0,-4(a0)	; b_bufr -> b_space
	movea.l	a1,a0
	dbra	d1,lin0
	suba.l	d0,a0		; a0 = ptr to last BCB
	clr.l	(a0)		; lastBCB.b_link = NULL
	move.l	(sp)+,a0	; restore head of buffer list
	rts


;+
; chklstmem - check if enough memory is allocated to replace GEMDOS
;		buffer lists
;
; Returns:
;	d0.l = size of each BCB (including data block)
;	     or -1 if not enough memory is allocated
;
; Uses:
;	d0, d1
;-
chklstmem:
	moveq	#BCBLEN,d0	; d0.l = size of each BCB (inc. data block)
	add.w	maxssz,d0	;      = BCB header len + data block size
	move.l	d0,d1		; d1.l = d0.l * 4 
	lsl.l	#2,d1		;      = total size of buffer lists
	add.l	tokeep,d1	; d1.l = size needed
	cmp.l	memalloc,d1	; enough memory allocated?
	bls.s	chk0		; if so return
	moveq	#-1,d0		; else return error
chk0:	rts


;
;+
; pread(sectno, cnt, buf, physunit, flag)
; LONG sectno;
; BYTE *buf; (word aligned)
; WORD cnt,physunit,flag;
;
; Passed:	flag.w			$10(sp)	
;		dev.w		$a(a0)	$e(sp)
;		&buf.l		$6(a0)	$a(sp)
;		cnt.w		$4(a0)	$8(sp)
;		sectno.l	$0(a0)	$4(sp)
;
; flag = 1 -- return media change if detected
; flag = 0 -- ignore media change
;
; Returns:	-1 if we could not read it
;			(may not exist)
;-
_pread:
pread:	move	_retries,retrycnt
pread1:	lea	4(sp),a0		; frame pointer
	move.w	$a(a0),-(sp)		; push physical unit number
	move.l	$6(a0),-(sp)		; buffer address
	move.w	$4(a0),-(sp)		; number to read
	move.l	(a0),-(sp)		; sector number
	bsr	_hread			; hread()
	adda	#12,sp			; clean up stack
	tst.w	d0			; read successful
	beq	pread8			; if so, return
	bmi.s	pread9			; timeout, does not exist
					; else, it's check condition status
	move.w	$e(sp),cpun		; cpun = current physical unit #
	bsr	errcode			; find error code

	cmpi.b	#DRVNRDY,d0		; drive not ready?
	beq.s	preadd			; if so, return drive not ready

	tst.w	$10(sp)			; ignore media change?
	beq.s	preadc			; if so, next try
					; else see if it's media change error
	cmpi.b	#MDMCHGD,d0		; media change detected?
	beq.s	pread7			; if so, return media change

preadc:	subq	#1,retrycnt		; else try try again
	bpl	pread1

pread9:	moveq	#EREADF,d0		; read error
	rts

pread7:	moveq	#E_CHNG,d0		; return media change detected
	rts

preadd:	moveq	#EDRVNR,d0		; drive not ready
	rts

pread8:	clr.l	d0			; flag no errors
	rts


;
;+
; critic - call up the critical error handler.
;
; Passed:
;	d0.w = error code
;	d1.w = drive # excluding A: and B:
;
; Uses:
;	d0, d1, a0
;
; Returns:
;	d0.l = whatever returned by the critical handler
;		(magic RETRY code or something)
;-
critic:	addq.w	#2,d1			; drive # including A: and B:
	move.w	d1,-(sp)		; drive #
	move.w	d0,-(sp)		; error code
	movea.l	etv_critic,a0		; a0 = address of error handler
	jsr	(a0)			; critic_handler(error, drive)
	addq.l	#4,sp			; clean up stack
	rts				; return


;+
; errcode - find error code for previous Check Condition Status
;
; Assumed:
;	cpun = current physical unit number
;
; Returns:
;	d0.b = error code	(aka additional sense code)
;-
errcode:
	move.w	cpun,d0			; d0 = physical unit number
	move.l	#sendata,-(sp)		; sense data buffer
	move.w	d0,-(sp)		; physical unit number
	btst.b	d0,scsi			; embedded SCSI unit?
	beq.s	err0			; if not, request non-extended sense
	bsr	_rq_xsense		; else request extended sense
	tst.w	d0			; successful?
	bne.s	err1			; if not, return
	movea.l	2(sp),a0		; a0 -> sense data buffer
	move.b	12(a0),d0		; else d0.b = error code
	bra.s	err2			; and return
err0:	bsr	_rq_sense		; find out error code
	tst.w	d0			; successful?
	bne.s	err1			; if not, return
	movea.l	2(sp),a0		; a0 -> sense data buffer
	move.b	(a0),d0			; else d0.b = error code
	andi.b	#$7f,d0			; mask valid bit
	bra.s	err2			; and return
err1:	moveq	#-1,d0			; error occurred
err2:	addq.l	#6,sp			; cleanup stack
	rts


;
;----------------- OS Pool Expansion ------------------

.if ospool
;---------------
;
;  Wire more pool into various ROM releases.
;
;    Passed:	nothing
;    Returns:	D0 = #bytes extra used
;
;-
pool_install:
	move.l	_sysbase,a3		; a3 -> base of OS

; make sure we're in ROM,
; then get address of RAM location to patch:

	cmp.l	#$800000,a3		; better be ROM
	blt	notrom
	lea	pool_tab(pc),a0		; a0 -> table to match
pi_lp:	move.l	(a0)+,d1		; d1 = date to match
	beq	badrom			; (forget it, end of list)
	move.l	(a0)+,a2		; a2 -> _root address for that date
	cmp.l	$18(a3),d1		; match dates?
	bne.s	pi_lp			; (no -- try again)

	move.w	numchunks,d0		; d0 = amount of BSS to be used
	mulu	#chunksiz,d0		;    = # chunks * size of a chunk
	move.l	d0,d1			; d1 = total memory needed
	add.l	tokeep,d1		;    = already keeping + extra OS pool
	cmp.l	memalloc,d1		; enough is allocated?
	bgt.s	bdrom2			; if not, don't add any
					; else install more OS pool
	movea.l	#i_sasi+2,a0		; a0 -> base of first buffer
	adda.l	tokeep,a0		;    = start of file + already keeping
	move.l	a0,-(sp)		; save base of first buffer
	move.w	numchunks,d1		; d0 = count-1
	subq.w	#1,d1
pin_1:	lea	chunksiz(a0),a1		; a1 -> next buffer
	move.l	a1,(a0)			; buffer -> next one
	move.w	#chunkno,-2(a0)		; install chunksiz
	move.l	a1,a0			; a0 -> next buffer
	dbra	d1,pin_1		; (do some more)

	sub.w	#chunksiz,a0		; a0 -> last block
	move.l	chunkno*4(a2),(a0)	; last block -> first in root
	move.l	(sp)+,chunkno*4(a2) 	; root -> first of ours
	rts				; return OK

;+
;  Print warning messages
;  about bogus versions of the
;  operating system.  Assume that
;  every OS past 1-May-1986 has the
;  pool fix installed.
;
;-
ok_date	=	%0000110010100001	; 1-May-1986
notrom:	lea	m_notrom(pc),a0		; ram-based system (5/29!)
	bra.s	bdrom1
badrom:	lea	m_badrom(pc),a0		; illegal ROM system
bdrom1:	cmp.w	#ok_date,$1e(a3)	; if ok_date <= os_dosdate(a3) 
	bcc	bdrom2			; then don't print anything

	move.l	a0,-(sp)		; print nasty message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

; print msg and wait for RETURN
	pea	keymsg(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

bdrom3:	move.w	#2,-(sp)		; wait for [RETURN]
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	cmp.w	#13,d0
	bne	bdrom3

bdrom2:	moveq	#0,d0			; 0 extra bytes used
	rts

keymsg:	dc.b	'Hard disk driver not loaded; hit RETURN',13,10
	dc.b	'key to continue:',13,10
	dc.b	0

m_notrom:
	dc.b	'*** WARNING ***',13,10,7
	dc.b	'This hard disk driver may not work with',13,10,7
	dc.b	'a disk-based version of TOS; files on',13,10,7
	dc.b	'your hard disk may be damaged.',13,10,7
	dc.b	13,10,7
	dc.b	0

m_badrom:
	dc.b	'*** WARNING ***',13,10,7
	dc.b	'You are using an unofficial ROM release',13,10,7
	dc.b	'of the operating system.  This driver',13,10,7
	dc.b	'may not work correctly with it.  Files',13,10,7
	dc.b	'on your hard disk may be damaged.',13,10,7
	dc.b	13,10,7
	dc.b	0
	even


;+
;  Table of ROM release dates / _root addresses
;  update these for new ROM releases that need the patch.
;
;-
pool_tab:
	dc.l	$11201985,$56fa		; USA and UK, 20-Nov-1985
	dc.l	$02061986,$56fa		; Germany, 6-Feb-1986
	dc.l	$04241986,$56fa		; France, 24-Apr-1986
	dc.l	0			; end of list

.endif


;
;------------------ Driver Installation -----------------

;----------------
;
;  Driver Installation
;
i_sasi1:
	move.l	d0,memalloc		; record amount of memory available
	tst.w	bootloaded		; if boot-loaded, don't Super()
	bne	nboot3
	clr.l	-(sp)			; it's a bird...
	move.w	#$20,-(sp)		;    ... it's a plane ...
	trap	#1			;      ... no, its:
	addq.l	#6,sp			; SOOUPERUSER!
	move.l	d0,savssp		; "Faster than a prefetched opcode..."

nboot3:	move	#MAXUNITS-1,d1
	moveq	#-1,d0			; a bad pun
	lea	pun,a0
i_sasi2:
	move.b	d0,(a0)+		; initialize all puns to be bad
	dbra	d1,i_sasi2

	move	#0,clun			; cur log unit# excluding drive A & B
	move.l	#4,cdbit		; current drive bit
	move	#0,cpun			; current physical unit number
	move	#0,puns			; no physical units found
	move	minbigsect,maxssz	; initialize maximum sector size

	move.l	_dskbufp,pbuf		; pbuf = buffer address of
	add.l	#512,pbuf		;	 root sector image
i_sasi3:
	clr.w	-(sp)			; ignore media change
	move.w	cpun,-(sp)		; physical unit number
	move.l	pbuf,-(sp)		; buffer
	move.w	#1,-(sp)		; 1 sector
	move.l	#0,-(sp)		; sectno = 0; root sector
	bsr	pread			; pread()
	adda	#14,sp
	move.w	d0,preadret		; save pread return code

	move.l	#sendata,-(sp)		; buffer for data inquired
	move.w	cpun,-(sp)		; current physical unit
	bsr	_inquiry		; inquiry(physunit, buf)
	addq.l	#6,sp			; clean up stack
	tst.w	d0			; Inquiry successful?
	bne.s	chkret			; if not, unit isn't a SCSI device
					; else unit is a SCSI device
	movea.l	#sendata,a0		; a0 = address of sense data
	tst.b	(a0)			; is unit a hard drive?
	bne.s	i_sasi4			; if not, end of chain
	move.w	cpun,d1			; else d1 = physical unit #
	bset.b	d1,scsi			; mark unit as embedded scsi
	btst.b	#7,1(a0)		; removable drive?
	beq.s	chkret			; if not removable, was read ok?
	bset.b	d1,rmbits		; else mark unit as removable
	bra.s	found1
chkret:	tst.w	preadret		; was pread successful?
	bne.s	i_sasi4			; if not, not an ACSI unit, return
found1:	addq	#1,puns			; else found a physical unit
	bsr	ppu			; find out how it is partitioned
	tst.w	d0			; ppu successful?
	beq.s	nxtpun			; go on normally
					; else find out what's wrong
	cmpi.w	#E_CHNG,d0		; media changed?
	beq	i_sasi3			; if so, retry this unit
					; else try next physical unit
nxtpun:	addq.w	#1,cpun			; next physical unit
	cmpi.w	#MAXACSI,cpun		; last one yet?
	bne	i_sasi3			; if not, continue

i_sasi4:
	clr.l	a5			; zeropage ptr
	move.l	hdv_bpb(a5),o_bpb
	move.l	hdv_rw(a5),o_rw
	move.l	hdv_mediach(a5),o_mediach

	move.l	#hbpb,hdv_bpb(a5)	; install our new ones
	move.l	#hrw,hdv_rw(a5)
	move.l	#hmediach,hdv_mediach(a5)
	move.l	#_puns,pun_ptr(a5)

	move.l	#_cookie,cookptr	; initialize cookie pointer
	bra	isasi5			; must get back into resident part


;
;-----------------
;
; Partition physical unit
;
;
ppu:	move.w	#0,npart		; no partition found for cpun yet
	move.w	cpun,d1			; is cpun removable?
	btst.b  d1,rmbits		;
	beq.s	ppu0			; if not, go on normally
					; else, it's a syquest unit
	tst.w	preadret		; is there a cartridge in there?
	bne.s	squnit			; if not, go reserve #drv letters
					; else find the partitions
ppu0:	moveq	#MAXNPART,d1		; d1 = # partition entries to check
	movea.l	pbuf,a0			; a0 = ptr to root sector image
	cmpi.w	#SIG,DOSSIG(a0)		; is root sector in DOS format?
	bne.s	ppu1			; if not, assume it's in ST format
	bsr	dosppu			; else, handle it the DOS way
	bra.s	ppu2
ppu1:	bsr	gemppu
ppu2:	tst.w	d0			; successful?
	bne.s	ppud			; if not, return

	lea	minsqnpart,a0		; a0 = addr of least # of drives
	move.w	cpun,d1			; d1 = unit #
	move.b	(a0,d1.w),d1		; d0 = least # of drives requested
	sub.w	npart,d1		; enough drives being set up?
	bls.s	ppud			; if so, done
					; else see if it's removable
	move.w	cpun,d0			; d0 = unit #
	btst.b	d0,rmbits		; is cpun removable?
	beq.s	ppud			; if not, done
	bra.s	sq0			; else, set up the rest

squnit:	lea	minsqnpart,a0		; a0 = addr of least # of drives
	move.w	cpun,d1			; d1 = unit #
	move.b	(a0,d1.w),d1		; d0 = least # of drives requested
sq0:	subq.w	#1,d1
ppu3:	move.w	d1,-(sp)		; save count
	bsr	nxtd0
	move.w	(sp)+,d1		; restore count
	tst.w	d0			; a valid unit?
	bmi.s	ppud			; if not, return
	dbra	d1,ppu3
ppud:	rts


;
;+
; dosppu - find the DOS partitions of the drive and set up
;	   appropiate data structures.
; Passed:
;	a0 = buffer address for root sector
;	d1 = number of entries in partition map
;
; Returns:
;	d0 = 0			if no error
;	   = negative #		if error found
;-
dosppu:	adda.w	#DOSPM,a0		; a0 = ptr to partition map
dppu0:	movem.l	d1/a0,-(sp)		; save count and offset
	sf	ext			; not dealing with ext partition
	bsr	fdpart			; find partitions
	tst.b	d0			; found any?
	beq.s	dppua			; not a valid partition
	cmpi.b	#5,d0			; extended partition?
	bne.s	dppu1			; if not, it's a regular partition
	st	ext			; else, it's an extended partition
	move.l	#0,extvol		; offset from start of partition = 0
	move.l	d1,extrt		; starting sector # of ext partition
dppux:	bsr	fdnxt			; find next logical drive
	tst.b	d0			; found any?
	beq.s	dppua			; no logical drive found
	bmi.s	dppu2			; error returned
	cmpi.b	#5,d0			; extended volume?
	beq.s	dppux			; if so, go find next logical drive
dppu1:	movem.l	d1-d2/a0,-(sp)		; save registers
	bsr	nxtdrv			; general set up for clun
	movem.l	(sp)+,d1-d2/a0		; restore registers
	tst.w	d0			; set up successful?
	beq.s	dppu3			; if successful, continue
dppu2:	addq.l	#8,sp			; else clean up stack
	bra.s	dppur			; and return
dppu3:	tst.b	ext			; clun is in ext partition?
	bne.s	dppux			; if so, go find next ext vol
dppua:	movem.l	(sp)+,d1/a0		; restore count and offset
	adda	#16,a0			; index to next entry in pmap
	dbra	d1,dppu0
	moveq	#0,d0			; get here with no error!
dppur:	rts


;
;+
; gemppu - find the GEMDOS partitions of the drive and set up
;	   appropiate data structures.
; Passed:
;	a0 = buffer address for root sector
;	d1 = number of entries in partition map
;
; Returns:
;	d0 = 0			if no error
;	   = negative #		if error found
;-
gemppu:	adda.w	#HDSIZ,a0		; a0 = ptr to hard disk size
	tst.l	(a0)+			; size? (a0 = ptr to start of pmap)
	beq.s	gppu4			; if =0, no drive will exist
gppu0:	movem.l	d1/a0,-(sp)		; save count and offset
	sf	ext			; not dealing with ext partition
	bsr	fgpart			; find partitions
	tst.b	d0			; found any?
	beq.s	gppua			; not a valid partition
	cmpi.b	#'X',d0			; extended partition?
	bne.s	gppu1			; if not, it's a regular partition
	st	ext			; else, it's an extended partition
	move.l	#0,extvol		; offset from start of partition = 0
	move.l	d1,extrt		; starting sector # of ext partition
gppux:	bsr	fgnxt			; find next logical drive
	tst.b	d0			; found any?
	beq.s	gppua			; no logical drive found
	bmi.s	gppu2			; error returned
	cmpi.b	#'X',d0			; extended volume?
	beq.s	gppux			; if so, go find next logical drive
gppu1:	movem.l	d1-d2/a0,-(sp)		; save registers
	bsr	nxtdrv			; general set up for clun
	movem.l	(sp)+,d1-d2/a0		; restore registers
	tst.w	d0			; set up successful?
	beq.s	gppu3			; if so, continue
gppu2:	addq.l	#8,sp			; else clean up stack
	bra.s	gppur			; and return
gppu3:	tst.b	ext			; clun is in ext partition?
	bne.s	gppux			; if so, go find next ext vol
gppua:	movem.l	(sp)+,d1/a0		; restore count and offset
	adda	#12,a0			; index to next entry in pmap
	dbra	d1,gppu0
gppu4:	moveq	#0,d0			; get here with no error!
gppur:	rts


;
;+
; nxtdrv	(of clun, cdbit)
;
; Passed:
;	d1.l = starting sector # of clun
; Returns:
;	d0 = 0			if successful
;	   = negative #		if error occurred
;-
nxtdrv:	cmpi	#MAXUNITS,clun		; have we already hit maximum?
	bge	nxtd9			; yes, so signal error

	move.w	#1,-(sp)		; return media change if detected
	move.w	cpun,-(sp)		; physical unit number
	move.l	#sbuf,-(sp)		; buffer address
	move.w	#1,-(sp)		; 1 sector
	move.l	d1,-(sp)		; logical sector 0 of clun
	bsr	pread			; pread(sectno, cnt, buf, phys#, flag)
	adda	#14,sp			; clean up stack
	tst.w	d0			; pread successful?
	bne	nxtr			; if not, return with error code

	move.l	#sbuf,a0		; a0 = addr of boot sector image
	moveq	#$b,d0			; d0 = offset for bytes per sector
	bsr	getlhw
	tst.w	d0			; bytes per sector = 0?
	beq.s	nxtd1			; if so, assume ratio to be 1

	cmp.w	maxssz,d0		; max sect size >= curr sect size?
	bls.s	nxtd00			; if so, continue
	move.w	d0,maxssz		; else max sect size = curr sect size
nxtd00:	divu	#512,d0			; d0 = sector size ratio
	move.w	d0,sizr			; sizr = sector size ratio
	bra.s	nxtd2			; go on

nxtd0:	cmpi	#MAXUNITS,clun		; have we already hit maximum?
	bge	nxtd9			; yes, so signal error

nxtd1:	move.w	#1,sizr			; sector size ratio assumes to be 1

nxtd2:	move.l	cdbit,d1		; get the bit to turn on
	move.l	_drvbits,d0		; tell TOS we have the drive
	or.l	d1,d0
	move.l	d0,_drvbits

	asl.l	#1,d1			; put in the next bit to turn on
	move.l	d1,cdbit

	move	clun,d0			; d0 = dev number
	lea	pun,a0			; a0 = ptr to pun table
	move.b	cpun+1,(a0,d0.w)	; clun belongs to cpun

	lea	sratio,a0		; a0 = ptr to sector size ratio table
	move.b	sizr+1,(a0,d0.w)	; save sector ratio of clun

	lea	xst,a0			; a0 = ptr to drive existence table
	move.b	#1,(a0,d0.w)		; clun may exist

	lea	mcflgs,a0		; a0 = ptr to mcflgs table
	move.b	#2,(a0,d0.w)		; clun is definitely changed

	addq	#1,clun			; clun = next possible lun
	addq	#1,npart		; one more partition found
	moveq	#0,d0			; gets here with no error
	bra.s	nxtr

nxtd9:	moveq	#-1,d0			; error!
nxtr:	rts


;
.if	format
;----------------
;
;  Parameter Block
;
acfmt:	dc.b	4	; format command + devno (upper 3 bits)
	dc.b	0	; (unused)
	dc.b	0	; (unused) data pattern
ac_in:	dc.b	0,0	; interleave factor MSB, LSB
	dc.b	0	; reserved
.even

;---------------
;
;  _doformat - format hard disk
;
;    Synopsis:	LONG _doformat(dev, interlv)
;		WORD dev;			4(sp).W
;		WORD interlv;			6(sp).W
;
_doformat:
	move.w	4(sp),d0		; set dev#
	lsl.b	#5,d0			; up 5 bits, fill in 0s
	or.b	#4,d0			; OR-in with FORMAT command
	move.b	d0,acfmt		; stuff into command frame
	move.b	6(sp),ac_in		; set interleave
	move.b	7(sp),ac_in+1

	lea	acfmt(pc),a0		; pick up pointer to the command block
	clr.w	d0
	st	flock			; lock FIFO
	move.w	#$88,wdl
	move.b	(a0)+,d0		; get the command byte
	swap	d0
	move.w	#$8a,d0
	move.l	d0,wdc			; byte wdc 8a wdl

	moveq	#(5-1),d1		; write remaining 5 bytes of command
fmt1:	bsr	_qdone
	bmi	_hto
	move.b	(a0)+,d0		; next byte of command
	swap	d0
	move.w	#$8a,d0
	move.l	d0,wdcwdl
	dbra	d1,fmt1
	bsr	_endcmd			; wait for command completion
	bra	_hdone			; cleanup after IRQ


;
;----------------
;
;  _mode_set - set hard disk format parameters
;
;    Synopsis:	LONG _mode_set(dev, len, parms)
;		WORD dev;			4(sp).W
;		WORD len;			6(sp).W
;		char *parms;			8(sp).L
;
_mode_set:
	st	flock			; lock FIFO
	move.l	8(sp),-(sp)		; -> parameter block address
	bsr	_setdma			; set DMA there
	addq.l	#4,sp

; write command and dev#
	move.w	#$88,wdl
	move.w	4(sp),d0		; d0 = (dev << 5) << 16
	lsl.b	#5,d0
	swap	d0			; in upper word
	or.l	#$0015008a,d0		; write dev# + ModeSelect + FIFO bits
	move.l	d0,wdcwdl		; mdsel+dev wdc 8a wdl (byte 0)
	bsr	_qdone
	bmi	wdx

	move.l	#$0000008a,wdcwdl	; byte 1
	bsr	_qdone
	bmi	wdx

	move.l	#$0000008a,wdcwdl	; byte 2
	bsr	_qdone
	bmi	wdx

	move.l	#$0000008a,wdcwdl	; byte 3
	bsr	_qdone
	bmi	wdx

	move.w	6(sp),d0		; # bytes of parameter
	swap	d0			; in upper word
	or.l	#$0000008a,d0
	move.l	d0,wdcwdl		; byte 4
	bsr	_qdone
	bmi	wdx

	move.w	#$90,wdl		; reset the DMA chip
	move.w	#$190,wdl
	move.w	#$01,wdc		; 1 sector of DMA (actually less)
	move.w	#$18a,wdl
	move.l	#$00000100,wdcwdl	; byte 5 (control byte)
	move.w	#$18a,d0		; wdl value
	bsr	_endcmd			; wait for command completion
wdx:	bra	_hdone

.endif  ; format

  
.if    mdsense
;----------------
;
;  _md_sense - get hard disk format parameters
;
;    Synopsis:	LONG _md_sense(dev, parms)
;		WORD dev;			4(sp).W
;		char *parms;			6(sp).L
;
_md_sense:
	st	flock			; lock FIFO
	move.l	6(sp),-(sp)		; -> parameter block address
	bsr	_setdma			; set DMA there
	addq.l	#4,sp

; write command and dev#
	move.w	#$88,wdl
	move.w	4(sp),d0		; d0 = (dev << 5) << 16
	lsl.b	#5,d0
	swap	d0			; in upper word
	or.l	#$001a008a,d0		; write dev# + ModeSense + FIFO bits
	move.l	d0,wdcwdl		; mdsense+dev wdc 8a wdl (byte 0)
	bsr	_qdone
	bmi	wdx1

	move.l	#$0000008a,wdcwdl	; byte 1
	bsr	_qdone
	bmi	wdx1

	move.l	#$0000008a,wdcwdl	; byte 2
	bsr	_qdone
	bmi	wdx1

	move.l	#$0000008a,wdcwdl	; byte 3
	bsr	_qdone
	bmi	wdx1

	move.l	#$0016008a,wdcwdl	; 22 bytes of parameters (byte 4)
	bsr	_qdone
	bmi	wdx1

	move.w	#$190,wdl		; reset the DMA chip
	move.w	#$90,wdl
	move.w	#$01,wdc		; 1 sector of DMA (actually less)
	move.w	#$8a,wdl
	move.l	#0,wdcwdl		; byte 5 (control byte)
	move.w	#$8a,d0			; wdl value
	bsr	_endcmd			; wait for command completion
wdx1:	bra	_hdone

.endif  ; mdsense

	bss
clun:	ds.w	1			; current logical unit
cdbit:	ds.l	1			; current drive bit
sbuf:	ds.b	512			; temporary buffer for i/o
	end
