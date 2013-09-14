* bootsect.s
* $Header$

*------------------------------------------------------------------------
*									:
*	Hard disk partition boot sector;				:
*	Loads SHDRIVER.SYS and executes it.				:
*									:
*	Copyright 1986, 1987, 1988 Atari Corp.				:
*	All Rights Reserved.						:
*									:
*------------------------------------------------------------------------

* $Log$


*+
*  OS variables:
*-
_sysbase	equ	$4f2	; (L) -> OS header


*+
*  Branch to executable code (following BPB stuff);
*  OEM name (which really doesn't matter);
*  24 bits of (ignored) serial number.
*
*-
_bootstart::
base:	bra.s	start		; branch to code

*+
*  Space for BPB information
*  (this is skipped, none of it is written to
*   the partition's boot sector).
*
*  Labels are used as pointers to real bpb info.
*-
	dc.b	'SH'		; some kind of name (2 bytes for PC)
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

odd:	dc.b	0		; 1's - odd cluster #; 0's - even cluster
	.even


*+
*  Load driver from hard disk:
*
*    Passed:	D7.B = devno << 5
*		D6.L = base sector#
*
*    - Compute disk parameters (FAT start + length, root
*      directory start + length).
*
*    - Search for driver image in root directory, if
*      not found then exit.
*
*    - Load the driver and execute it.
*
*-
start:	move.l	#-1,-(sp)	; D0 = Malloc(-1L);
	move.w	#$48,-(sp)	;    = size of largest free block
	trap	#1
	move.l	d0,d4		; # bytes returned (assume >= 512)
	move.l	d0,2(sp)	; alloc that many bytes
	move.w	#$48,(sp)	; Malloc(that many bytes)
	trap	#1
	addq.l	#6,sp		; (cleanup stack)
	movea.l	d0,a4		; test pointer to block; a4 -> buffer
	beq	bs_r		; if D0 == NULL, couldn't Malloc(), so quit
	move.l	d0,-(sp)	; save address of buffer (for later)
	move.l	d4,-(sp)	; save # bytes allocated

*+
*  Compute disk configuration values
*
*  Register usage:
*    D0     temp in dmaread()
*    D1     temp in dmaread()
*    D2.W = # of directory entries;
*    D3.L = starting sector# of FAT0;
*    D4     number of bytes allocated
*    D5     count (=1)
*    D6.L = starting sector# of root directory.
*    D7     devno << 5 (ACSI device number)
*
*    A0     temp in dmaread()
*    A1.L = starting sector# of cluster 2 (the first cluster).
*    A2     -> buffer for driver 
*    A3     -> disk read procedure
*    A4     -> buffer (scratch memory)
*    A5     temp in dmaread()
*    A6     temp in dmaread()
*    A7     [stack]
*
*-
	moveq	#0,d1		; clear D1
	move.b	BPS+1(pc),d1	; D1 = log sector size : phys sector size 
	ror.w	#8,d1		;    = log sector size / 512
	move.b	BPS(pc),d1	
	lsr.l	#8,d1
	lsr.l	#1,d1
	move.w	d1,-(sp)	; save sector size ratio

	moveq	#0,d2		; D2 = 8086word(NDIRS)
	move.b	NDIRS+1(pc),d2	;    = number of root directory entries
	ror.w	#8,d2
	move.b	NDIRS(pc),d2

	moveq	#0,d3		; D3 = D6 + 8086word(RES)
	move.w	RES(pc),d3	;    = logical starting sector of FAT0
	ror.w	#8,d3
	mulu	d1,d3		; D3 = physical starting sector of FAT0
	add.l	d6,d3		; (D3 += base sector addr)

	move.w	SPF(pc),d0	; D0 = # of logical sectors per FAT
	ror.w	#8,d0
	mulu	d1,d0		; D0 = # of physical sectors per FAT
	move.l	d3,d6		; D6 = D3 + 8086word(SPF) * sector ratio * 2
	add.l	d0,d6		;    = physical sector of root directory
	add.l	d0,d6

	move.l	d2,d0		; A1 = D6 + D2 >> 4
	asr.l	#4,d0		;    = sector# of cluster 2 (the first cluster)
	add.l	d6,d0
	move.l	d0,a1

*+
*  Read in directory sectors, searching for the
*  FCB describing the driver file.
*
*-
bs_d1:	moveq	#1,d5		; read 1 sector
	jsr	(a3)		; read (next) dir sector
	addq.l	#1,d6		; ++dir sector number
	movea.l	a4,a0		; a0 -> first FCB
	moveq	#15,d1		; d1 = number of FCBS - 1 in a directory sector

bs_d2:	moveq	#10,d0		; d0 = #chars-1 in filename
bs_d3:	move.b	(a0,d0.w),d5	; get char from FCB
	cmp.b	fname(pc,d0.w),d5 ; compare with fname here
	bne.s	bs_d4		; (no match)
	dbra	d0,bs_d3	; try for another matching char

*
*  Find out what kind of FATs (12-bit or 16-bit)
*  Get starting cluster of file, go read it
*
	move.l	28(a0),d5	; d5 = memory needed 
	ror.w	#8,d5		;    = size of driver + 1.5k scratch memory
	swap	d5
	ror.w	#8,d5
	addi.l	#$600,d5	
	cmp.l	d5,d4		; enough is allocated?
	blt.s	bs_rp		; if not, quit
	movea.l	a4,a2		; a2 -> buffer for driver file
	adda.l	d4,a4		; a4 -> 1.5k scratch memory
	suba.l	#$600,a4	
	moveq	#0,d2		; clear D2
	move.w	26(a0),d2	; D2 = starting cluster# from FCB
	ror.w	#8,d2		; (8086 wordswap)
	bra.s	bsf_rd		; go read file


****************'nnnnnnnneee'
fname:	dc.b	'SHDRIVERSYS'	; name of driver file
	.even

*+
*  try next filename in directory sector
*-
bs_d4:	adda.w	#$20,a0		; (bump A0 to next FCB)
	subq.w	#1,d2		; (drop FCB count)
	beq.s	bs_rp		; (no more dir entries --- file not found)
	dbra	d1,bs_d2	; (do more FCBs in current sector)
	bra.s	bs_d1		; read in another directory sector


*+
*  Return to TOS ROM boot loader
*    - load D7 with magic value to prevent TOS ROMs
*      from doing any further DMA bus activity.
*
*  Modified 9-Aug-1988 by ML to stuff D7 (and stop looking on the DMA bus)
*  ONLY on 11/20-derived ROMs.  Newer ROMs have this bug fixed.
*-
bs_rp:	addq	#6,sp		; clean up stack
	move.w	#$49,-(sp)	; Mfree(-> buffer allocated)
	trap	#1
	addq	#6,sp		; cleanup stack
bs_r:	move.l	_sysbase,a0	; get the system header address
	move.l	$18(a0),d0	; d0.l = MMDDYYYY of ROM date
	swap	d0		; d0.l = YYYYMMDD of ROM date
	cmp.l	#$19870422,d0	; does this version of ROM need bootstop?
	bcc.s	dontstop	; nope, if OS is built on or after 4/22/87
	move.w	#$100-$20,d7	; prevent further TOS ROM reads
dontstop:
	rts


*+
*  Load file into memory
*    -  allocate HUGE chunk of memory for it
*    -  read the file in, one cluster at a time
*
*-
bsf_rd:	moveq	#-1,d4		; no FAT sector cached in memory yet

*+
*  Read (next) cluster
*
*  Modified 9-Aug-88 by ML so that the boot code does not rely
*  on number of sectors per cluster being 2.
*
*  Modified 21-Nov-88 by ML to handle partitions with 12-bit FATs
*
*-
bsf_1:	moveq	#0,d5		; D5 = # physical sectors in a cluster
	move.b	SPC(pc),d5	;    = # logical sectors in a cluster 
	mulu	(sp),d5		;      * sector ratio
	move.l	d2,d6		; D6 = sector# to read (from cluster#)
	subq.l	#2,d6		;    = (D2 - 2) * D5 + A1
	mulu	d5,d6
	add.l	a1,d6
	exg	a2,a4		; swap buffer/file read pointers
	jsr	(a3)		; read cluster
	bne.s	bs_rp		; (pop, then quit on read failure)
	exg	a2,a4		; swap buffer/file read pointers again
	mulu	#512,d5		; D5 = clustersize in bytes = D5 * 512
	adda.l	d5,a2		; bump file read pointer [clustersize]
	move.l	d2,d6		; D6 = current cluster number

*
*  Read in rest of file.
*  First, have to determine whether it's a 12-bit or 16-bit FAT
*  For a 12-bit FAT, there are (512 * 8 / 12 = 341) FAT entries per
*	sector of FAT.
*  For a 16-bit FAT, there are (512 * 8 / 16 = 256) FAT entries per
*	sector of FAT.
*
	btst.b	#2,base-$4-$200+$6(pc) ; 16-bit FAT?
	bne	bsf_16		; if so, handle it the usual way
				; else have to twist around for 12-bit FAT
	divu	#341,d6		; d6 = sector # for cluster entry
				;    = (cluster # / 341)
	moveq	#0,d0		; clear d0
	move.w	d6,d0		; d0 = offset from sector to be read
	divu	#3,d0		;    = sector # for cluster entry % 3
	swap	d0
	ext.l	d6		; clobber remainder
	sub.w	d0,d6		; d6 = physical sector to be read
	add.l	d3,d6
	cmp.l	d4,d6		; FAT sector already in buffer?
	beq.s	bsf_3		; (yes -- get link)

	moveq	#3,d5		; d5 = read count (3 sectors)
	move.l	d6,d4		; d4 = sector# cached in buffer
	jsr	(a3)		; read FAT sector
	bne.s	bs_rp		; (pop, then quit on read failure)
	
*
*  Compute next cluster number;
*  stop reading on end-of-file.
*
bsf_3:	lea	odd(pc),a0	; a0 = addr of odd variable
	btst	#$0,d2		; odd cluster #?
	sne	(a0)
	mulu	#$3,d2		; d2 = index into FAT for cluster entry
	lsr.l	#$1,d2		;    = cluster# * 3 / 2
	sub.l	d3,d6		; d6 = index to cached FAT sector
	lsl.l	#$8,d6		;    = cached FAT sector # * 512
	lsl.l	#$1,d6
	sub.l	d6,d2		; d2 = offset to cluster entry wrt 
				;      to cached FAT sector
	move.l	d2,d6
	move.b	1(a4,d6.w),d2	; low byte of word
	lsl.w	#$8,d2		; shift it to position
	move.b	(a4,d6.w),d2	; high byte of word
	tst.b	(a0)		; was cluster # odd?
	beq.s	bsf_5		; if not, it's even (of course)
	lsr.w	#$4,d2		; shift it into position
bsf_5:	andi.w	#$0fff,d2	; even - keep the low-order 12 bits
	beq	bs_rp		; if (D2 == UNALLOCATED) then quit;
	ext.l	d2		; clobber upper bits
	moveq	#11,d0		; bit to be tested
	btst.l	d0,d2		; end of file yet?
	beq	bsf_1		; if (D2 != EOF) then read_another_cluster;
	bra.s	mrl_0

*
*  Get correct FAT cluster into sector buffer
*
bsf_16:	lsr.l	#8,d6		; d6 = sector # for cluster entry
	add.l	d3,d6		;    = (cluster / 256) + starting sector
	cmp.l	d4,d6		; FAT sector already in buffer?
	beq.s	bsf_2		; (yes -- get link)

	moveq	#1,d5		; d5 = read count (1 sector)
	move.l	d6,d4		; d4 = sector# cached in buffer
	jsr	(a3)		; read FAT sector
	bne	bs_rp		; (pop, then quit on read failure)

*
*  Compute next cluster number;
*  stop reading on end-of-file.
*
bsf_2:	andi.w	#$00ff,d2	; D2 = cluster # from beginning of FAT sector
	add.w	d2,d2		; *2 to index into table of words
	ext.l	d2		; (clobber upper bits)
	move.w	(a4,d2.w),d2
	ror.w	#8,d2
	bpl	bsf_1		; if (D2 != EOF) then read_another_cluster;


*
*  Validate and execute file
*    -  check introductory magic in the .PRG header
*    -  fixup longwords, using the fixup information
*    -  start execution at `base + 0x20'
*
mrl_0:	movea.l	6(sp),a2	; a2 -> .PRG header
	movea.l	a2,a0		; a0 -> there, too
	cmp.w	#$601a,(a0)+	; if (*a0++ != MAGIC)
	bne	bs_rp		;	then forget_it;

*
*  Compute start of fixup information
*
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

mrl_1:	move.l	2(sp),d0	; pass #bytes allocated to driver
	adda.l	#10,sp		; clean up stack
	jmp	$20(a2)		; execute file we loaded
_bootend::
