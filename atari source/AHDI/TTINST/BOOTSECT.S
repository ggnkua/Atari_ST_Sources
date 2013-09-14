; bootsect.s

;------------------------------------------------------------------------
;									:
; Hard disk partition boot sector					:
; Loads SHDRIVER.SYS and executes it.					:
;									:
; Copyright 1986, 1987, 1988, 1989, 1990 Atari Corp.			:
; All Rights Reserved.							:
;									:
; Jul-24-1989	ml.	Modified this for the TT.			:
; Feb-06-1990	ml.	Removed code that handles MSDOS format drive.	:
;									:
;------------------------------------------------------------------------


;---- OS variables:
_sysbase	equ	$4f2	; (L) -> OS header


;+
;  Branch to executable code (following BPB stuff);
;  OEM name (which really doesn't matter);
;  24 bits of (ignored) serial number.
;
;-
_bootstart::
base:	bra.s	start		; branch to code

;+
;  Space for BPB information
;  (this is skipped, none of it is written to
;   the partition's boot sector).
;
;  Labels are used as pointers to real bpb info.
;-
	dc.b	'OEMxxx'	; filler (OEM cruft)
	dc.b	$00,$00,$00	; 24-bit serial number (unused)
BPS:	dc.b	$00,$02		; #bytes/sector
SPC:	dc.b	$02		; #sectors/cluster
RES:	dc.b	$01,$00		; #reserved sectors
NFATS:	dc.b	$02		; #of FATs
NDIRS:	dc.b	$70,$00		; #of root directory entries
NSECTS:	dc.b	$d0,$02		; #of sectors on media
MEDIA:	dc.b	$f8		; media descriptor byte
SPF:	dc.b	$05,$00		; #sectors/FAT
SPT:	dc.b	$09,$00		; #sectors/track
NSIDES:	dc.b	$01,$00		; #sides on media
NHID:	dc.b	$00,$00		; #hidden sectors


;+
;  Load driver from hard disk:
;
;    Passed:	a3.l -> disk read routine
;		a5.l -> bootstop code
;		d4.w = devno (if DMAread() is in ROM)
;			or -1 (if DMAread() is not in ROM)
;		d6.l = base sector#
;		d7.b = devno << 5 (if DMAread() doesn't exist in ROM)
;
;    - Compute disk parameters (FAT start + length, root
;      directory start + length).
;
;    - Search for driver image in root directory, if
;      not found then exit.
;
;    - Load the driver and execute it.
;-
start:	moveq	#$48,d3		; d3 = opcode for Malloc
	moveq	#-1,d0		; d0 = Malloc(-1L)
	move.l	d0,-(sp)	;    = size of largest free block
	move.w	d3,-(sp)
	trap	#1
	move.l	d0,d5		; d5 = # bytes returned (assume >= 512)
	move.l	d0,2(sp)	; alloc that many bytes
	move.w	d3,(sp)		; Malloc(that many bytes)
	trap	#1
	addq.w	#6,sp		; (cleanup stack)
	tst.l	d0		; successful?
	beq.s	bs_r		; if not, return
	movea.l	d0,a4		; a4 -> buffer

;+
;  Compute disk configuration values
;
;  Register usage:
;    d0     temp in dmaread()
;    d1     temp in dmaread()
;    d2.w = # of directory entries;
;    d3.l = physical starting sector# of FAT0;
;    d4.w = physical unit # (if DMAread() is in ROM)
;		or -1 (if DMAread() is not in ROM)
;    d5     count (=1)
;    d6.l = physical starting sector# of root directory.
;    d7.b = devno << 5 (ACSI device number)
;
;    a0     temp in dmaread()
;    a1.l = starting sector# of cluster 2 (the first cluster).
;    a2.l -> buffer for driver 
;    a3.l -> disk read procedure
;    a4.l -> buffer (scratch memory)
;    a5     temp in dmaread() (if ACSI)
;    a6     temp in dmaread() (if ACSI)
;    a7.l   [stack]
;-
	move.b	BPS+1(pc),d1	; d1 = log sector size : phys sector size 
	ror.w	#8,d1		;    = log sector size / 512
	move.b	BPS(pc),d1	
	lsr.w	#8,d1
	lsr.w	#1,d1

	moveq	#0,d2		; d2.l = 8086word(NDIRS)
	move.b	NDIRS+1(pc),d2	;      = number of root directory entries
	ror.w	#8,d2
	move.b	NDIRS(pc),d2

	move.w	RES(pc),d3	; d3.l = physical starting sector of FAT0
	ror.w	#8,d3		;      = logical starting sector of FAT0
	mulu	d1,d3		;	* sector ratio + base sector
	add.l	d6,d3		;      = 8086word(RES) * d1 + d6

	move.w	SPF(pc),d6	; d6.l = physical starting sector of root dir
	ror.w	#8,d6		;      = d3 + size of 2 FATs in sectors
	mulu	d1,d6		;      = d3 + 8086word(SPF) * sector ratio * 2
	add.l	d6,d6
	add.l	d3,d6

	lsr.l	#4,d2		; a1 = physical starting sector of 1st cluster
	add.l	d6,d2		;    = physical starting sector of root dir
	movea.l	d2,a1		;	+ size of root dir in sectors
				;    = d6 + (d2 / 16)

;+
; Saving the following registers:
;	d0.l  -> address of buffer allocated		$0(sp).l
;	d1.lw -> sector size ratio			$6(sp).w
;	d3.l  = physical starting sector of FAT0	$8(sp).l
;	d5.l  = # bytes allocated for driver		$c(sp).l
;-
	movem.l	d0/d1/d3/d5,-(sp) ; save registers (for later)

;+
;  Read in directory sectors, searching for the
;  FCB describing the driver file.
;-
bs_d1:	moveq	#1,d5		; read 1 sector
	movem.l	a1/a5,-(sp)	; save a1 and a5
	jsr	(a3)		; read (next) dir sector
	movem.l	(sp)+,a1/a5	; restore a1 and a5
	tst.w	d0		; read successful?
	beq.s	bs_d4		; if so, go try to find the file
bs_d3:	add.l	d5,d6		; else ++dir sector number
	cmp.l	a1,d6		; more directory sector available?
	bcs.s	bs_d1		; if so, read the next directory sector
				; else
;+
;  Return to TOS ROM boot loader
;    - load D7 with magic value to prevent TOS ROMs
;      from doing any further DMA bus activity.
;-
bs_rp:	move.w	#$49,-(sp)	; Mfree(-> buffer allocated)
	trap	#1
	add.w	#$12,sp	
bs_r:	jmp	(a5)

;***************'nnnnnnnneee'
fname:	dc.b	'SHDRIVERSYS'	; name of driver file
	.even

bs_d4:	movea.l	a4,a0		; a0 -> first FCB
	moveq	#15,d1		; d1 = number of FCBS - 1 in a directory sector
bs_d5:	moveq	#10,d0		; d0 = #chars in filename - 1
bs_d6:	move.b	(a0,d0.w),d3	; get char from FCB
	cmp.b	fname(pc,d0.w),d3 ; compare with fname here
	beq.s	bs_d7		; if match, try next char
	adda.w	#$20,a0		; else bump a0 to next FCB
	dbra	d1,bs_d5	; do more FCBs in current sector if any
	bra.s	bs_d3		; else try next directory sector
bs_d7:	dbra	d0,bs_d6	; try for another matching char
				; all characters match; Check for enuff memory
	move.l	28(a0),d5	; d5 = memory needed 
	ror.w	#8,d5		;    = ceil(size of driver) + 1.5k scratch 
	swap	d5		;    = size of driver + 0.5k + 1.5k scratch
	ror.w	#8,d5
	addi.l	#$0800,d5	
	cmp.l	$c(sp),d5	; enough is allocated?
	bhi.s	bs_rp		; if not, quit
	movea.l	a4,a2		; a2 -> buffer for driver file
	adda.l	$c(sp),a4	; a4 -> 1.5k scratch memory
	suba.w	#$600,a4	
	move.w	26(a0),d2	; D2 = starting cluster# from FCB
	ror.w	#8,d2		; (8086 wordswap)

;+
;  Load file into memory
;    -  read the file in, one cluster at a time
;-
bsf_rd:	moveq	#-1,d3		; no FAT sector cached in memory yet

;+
;  Read (next) cluster
;
;  Modified 9-Aug-88 by ML so that the boot code does not rely
;  on number of sectors per cluster being 2.
;
;  Modified 21-Nov-88 by ML to handle partitions with 12-bit FATs
;  Modified 06-Feb-90 by ML to remove code in handling 12-bit FATs
;-
bsf_1:	moveq	#0,d5		; d5 = # physical sectors in a cluster
	move.b	SPC(pc),d5	;    = # logical sectors in a cluster 
	mulu	$6(sp),d5	;	* sector ratio
	move	d2,d6		; d6 = sector# to read (from cluster#)
	subq	#2,d6		;    = clust# * spc + starting sector of data
	mulu	d5,d6		;    = (d2 - 2) * d5 + a1
	add.l	a1,d6
	exg	a2,a4		; swap buffer/file read pointers

	movem.l	d2/a1-a2/a5,-(sp) ; save these registers
	jsr	(a3)		; read (next) dir sector
	movem.l	(sp)+,d2/a1-a2/a5 ; restore these registers
	tst.w	d0		; read successful?
	bne	bs_rp		; (pop, then quit on read failure)
	exg	a2,a4		; swap buffer/file read pointers again
	lsl.l	#8,d5		; d5 = clustersize in bytes = d5 * 512
	add.l	d5,d5
	adda.l	d5,a2		; bump file read pointer [clustersize]
	move.w	d2,d6		; d6 = current cluster number
	ext.l	d6		; coerce to long

;+
;  Read in rest of file.
;  For a 16-bit FAT, there are (512 * 8 / 16 = 256) FAT entries per
;	sector of FAT.
;  Get correct FAT cluster into sector buffer
;-
bsf_16:	lsr.l	#8,d6		; d6 = sector # for cluster entry
	add.l	8(sp),d6	;    = (cluster / 256) + starting sector
	cmp.l	d3,d6		; FAT sector already in buffer?
	beq.s	bsf_2		; (yes -- get link)

	moveq	#1,d5		; d5 = read count (1 sector)
	move.l	d6,d3		; d3 = sector# cached in buffer
	movem.l	d2/a1-a2/a5,-(sp) ; save these registers
	jsr	(a3)		; read (next) dir sector
	movem.l	(sp)+,d2/a1-a2/a5 ; restore these registers
	tst.w	d0		; read successful?
	bne	bs_rp		; (pop, then quit on read failure)

;+
;  Compute next cluster number;
;  stop reading on end-of-file.
;-
bsf_2:	andi.w	#$00ff,d2	; D2 = cluster # from beginning of FAT sector
	add.w	d2,d2		; *2 to index into table of words
	move.w	(a4,d2.w),d2
	ror.w	#8,d2
	bpl	bsf_1		; if (D2 != EOF) then read_another_cluster;


;+
;  Validate and execute file
;    -  check introductory magic in the .PRG header
;    -  fixup longwords, using the fixup information
;    -  start execution at `base + 0x20'
;-
mrl_0:	movea.l	$0(sp),a2	; a2 -> .PRG header
	movea.l	a2,a0		; a0 -> there, too
	cmp.w	#$601a,(a0)+	; if (*a0++ != MAGIC)
	bne	bs_rp		;	then forget_it;

;+
;  Compute start of fixup information
;-
	lea	$1c(a2),a1	;   a1 -> base of text
	add.l	(a0)+,a1	;   a1 += tsize
	add.l	(a0)+,a1	;   a1 += dsize
	add.l	4(a0),a1	;   a1 += symsize
	tst.l	(a1)		; if (*a1 == NULL)
	beq.s	mrl_1		;	then no_fixups_to_do;

	lea	$1c(a2),a0	; a0 -> base of text segment
	move.l	a0,d1		; d1 -> there, too
	moveq	#0,d0		; wipe-out upper bits of d0
	add.l	(a1)+,a0	; a0 -> first fixup

mrl_2:	add.l	d1,(a0)		; add text base to longword at a0
mrl_4:	move.b	(a1)+,d0	; get next fixup byte
	beq.s	mrl_1		; if (d0 == 0) we're finished;
	cmp.b	#1,d0		; if (d0 == 1) a0 += 0xfe;
	bne.s	mrl_3
	add.w	#$00fe,a0
	bra.s	mrl_4
mrl_3:	add.w	d0,a0		; a0 += d0
	bra.s	mrl_2		; fixup longword at a

mrl_1:	move.l	$c(sp),d0	; pass #bytes allocated to driver
	adda.w	#$10,sp		; clean up stack
	jmp	$20(a2)		; execute file we loaded
_bootend::
