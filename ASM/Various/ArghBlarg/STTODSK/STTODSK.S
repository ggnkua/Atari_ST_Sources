*
** STTODSK.ttp -- A utility to convert .ST files (disk images suitable
**                for the PacifiST Atari ST emulator) to Atari ST
**                double-density disks.
**
**
** Usage:
**       sttodsk <file>
**
**       The utility deduces the disk format (tracks, sectors/track and
**     number of sides) from the size of the .ST file. This means the
**     file must have NO extra pad bytes on the end or any such silliness!
**       No intelligent error checking is done.
**       This utility is hard-coded to use drive A:. Sorry, make it more
**     flexible yourself if you need it.
**
**       Formats that are considered valid for .ST files are any
**     combination of:
**                      80,81 or 82 tracks
**                      9,10,or 11 sectors/track
**                      1 or 2 sides (what, no three-sided disks? 8-)
**
**       If this utility was useful to you, maybe send me a game I don't
**     have? I'll send you one you need in return!
**
**       Keep ST'ing...    -ArghBlarg (same nick on IRC)
*


  OPT O+

  OUTPUT sttodsk.ttp

  SECTION TEXT

Begin
	move.l	sp,a5		;get stack base
	move.l	4(a5),a5	;basepage in a5
	move.l	$C(a5),d0	;text seg length
	add.l	$14(a5),d0	;add to that the length of the data..
	add.l	$1c(a5),d0	;..and the bss segments
	add.l	#$500,d0	;also add some stack space

	move.l	d0,d1
	add.l	a5,d1		;length + address of basepage
	and.l	#$fffffffc,d1	;ensure stack is at even addr
	move.l	d1,sp		;set our stack address
	move.l	d0,-(sp)	;size of reserved area
	move.l	a5,-(sp)	;start of basepage (reserved area)
	clr.w	-(sp)		;dummy arg
	move.w	#$4a,-(sp)	;MShrink() function (setblock)
	trap	#1			;GEMDOS
	add.l	#12,sp		;fix stack

*
** Now we've shrunk used mem. Find args on command line
*
GetArgs
	lea		$80(a5),a4	;address of command line
	move.b	(a4)+,d7	;command line is PASCAL-type string; length byte
	ext.w	d7

	move.l	d2,-(sp)		;save during XBIOS call (d0-d2/a0-a2 are unsafe)
	pea		titlemsg
	move.w	#$9,-(sp)
	trap	#1				;print out msg
	addq.l	#6,sp
	move.l	(sp)+,d2		;get back regs unsafe during XBIOS call

	tst.w	d7
	beq		Terminate

*
** Assume filename is first arg -- null terminate it
*
	move.l	a4,a3
fname_term
	move.b	(a3)+,d0
	cmpi.b	#' ',d0
	bne.s	fname_term
	clr.b	-1(a3)

	lea		dta_area,a2	;where our DTA will be
	move.l	a2,-(sp)
	move.w	#$1a,-(sp)	;SetDTA()
	trap	#1			;GEMDOS
	addq.l	#6,sp		;fix stack

	move.w	#0,-(sp)	;look for regular files
	move.l	a4,-(sp)	;filename to find..
	move.w	#$4e,-(sp)	;SFirst()
	trap	#1			;GEMDOS
	addq.l	#8,sp		;fix stack
	tst.l	d0			;file found?
	bmi		file_error	;nope, return error

	move.l	26(a2),d6	;d6 should now have file's size in bytes
	move.l	d6,fsize	;store file size for later

	move.w	#0,-(sp)	;read-only access..
	move.l	a4,-(sp)	;filename
	move.w	#$3d,-(sp)	;open()
	trap	#1			;GEMDOS
	addq.l	#8,sp		;fix stack
	tst.l	d0			;error?
	bmi		file_error
fopen_ok
	move.w	d0,fhandle	;store file handle


*
** OK, now we have the file's size. Do some math on it to see which
** disk format it is.
**   Sizes that are considered are: 80, 81 and 82 tracks
**                                  9,10, or 11 sectors/track
**                                  1 or 2 sides
*
Deduce_format
	pea		deducemsg
	move.w	#$9,-(sp)
	trap	#1				;print out deducemsg
	addq.l	#6,sp

	move.l	d6,d5
	move.w	#82,d4
	divu.w	d4,d5			;see if fsize evenly divides by 79 tracks
	swap	d5				;check remainder
	tst.w	d5
	beq		found_tracks	;OK, it's probably 79 tracks
	move.l	d6,d5
	move.w	#81,d4
	divu.w	d4,d5			;see if fsize evenly divides by 80 tracks
	swap	d5				;check remainder
	tst.w	d5
	beq		found_tracks	;OK, it's probably 80 tracks
	move.l	d6,d5
	move.w	#80,d4
	divu.w	d4,d5			;see if fsize evenly divides by 81 tracks
	swap	d5				;check remainder
	tst.w	d5
	beq		found_tracks	;OK, it's probably 81 tracks
*
** Huh?! Not a usual ST format.
*
	bra		size_error
found_tracks
	swap	d5				;get quotient (# of tracks) LSW of d5
	subq.w	#1,d4
	move.w	d4,trks			;save max track number (e.g., 79 = an 80 track disk)
	ext.l	d5
	move.l	d5,d6
	move.w	#9,d4
	divu.w	d4,d5			;9 sectors per track?
	swap	d5
	tst.w	d5
	beq		found_sectors
	move.l	d6,d5
	move.w	#10,d4
	divu.w	d4,d5			;10 sectors per track?
	swap	d5
	tst.w	d5
	beq		found_sectors
	move.l	d6,d5
	move.w	#11,d4
	divu.w	d4,d5			;11 sectors per track?
	swap	d5
	tst.w	d5
	beq		found_sectors
*
** Huh?! Not a usual ST format.
*
	bra		size_error
found_sectors
	swap	d5				;get quotient (sectors/track) in LSW of d5
	move.w	d4,sct			;save sectors/track
	cmpi.w	#512,d5			;single-sided disk?
	bne.s	maybe_double
	move.w	#1,sides
	bra		found_sides
maybe_double
	cmpi.w	#1024,d5		;double-sided disk?
	bne	size_error			;nope?!? wierd disk.
	move.w	#2,sides
found_sides

*
** Now we've determined the whole disk's format.
**
** Request memory for reading in whole disk image..
** Read in whole disk image..
** Format & copy file to disk in A:
*

*
** Get memory for file
*
	move.l	fsize,-(sp)
	move.w	#$48,-(sp)		;Malloc()
	trap	#1				;GEMDOS
	addq.l	#6,sp			;fix stack
	tst.l	d0				;error getting mem?
	bmi		mem_err
	move.l	d0,memptr
	move.l	d0,a3

*
** Read in entire file
*
	pea		loadmsg
	move.w	#$9,-(sp)
	trap	#1				;print out msg
	addq.l	#6,sp

	move.l	memptr,-(sp)	;buffer for read data
	move.l	fsize,-(sp)		;size of file
	move.w	fhandle,-(sp)	;file handle
	move.w	#$3f,-(sp)		;Read()
	trap	#1				;GEMDOS
	lea		12(sp),sp		;fix stack
	tst.l	d0				;error?
	bmi		file_error

*
** Format each track (side 0, then side 1 if needed)
** Then write all sectors for that track
*
	move.w	trks,d2
track_loop
	move.w	sides,d4
	subq.w	#1,d4
fmt_side
	move.l	d2,-(sp)		;save during XBIOS call (d0-d2/a0-a2 are unsafe)
	pea		formatmsg
	move.w	#$9,-(sp)
	trap	#1				;print out msg
	addq.l	#6,sp
	move.l	(sp)+,d2		;get back regs unsafe during XBIOS call

	move.l	d2,-(sp)		;save during XBIOS call (d0-d2/a0-a2 are unsafe)
	move.w	#$e5e5,-(sp)		;blank pattern
	move.l	#$87654321,-(sp)	;magic code
	move.w	#1,-(sp)			;interleave
	move.w	d4,-(sp)			;side to format
	move.w	d2,d1
	sub.w	trks,d1				;-(current_track - trks) = track to write
	neg.w	d1
	move.w	d1,-(sp)
	move.w	sct,-(sp)			;sectors per track
	move.w	#0,-(sp)			;drive A:
	move.l	#0,-(sp)			;filler, unused
	pea		fmtbuff				;address of data to write
	move.w	#10,-(sp)			;Flopfmt()
	trap	#14					;XBIOS
	lea		26(sp),sp
	move.l	(sp)+,d2		;get back regs unsafe during XBIOS call
	tst.w	d0
	bmi		file_error

	dbra	d4,fmt_side			;double sided disk?

	moveq	#0,d5
	move.w	sides,d4
side_loop
	move.w	sct,d3
;	subq.w	#1,d3

	move.l	d2,-(sp)		;save during XBIOS call (d0-d2/a0-a2 are unsafe)
	pea		writemsg
	move.w	#$9,-(sp)
	trap	#1				;print out msg
	addq.l	#6,sp
	move.l	(sp)+,d2		;get back regs unsafe during XBIOS call

	move.l	d2,-(sp)		;save during XBIOS call (d0-d2/a0-a2 are unsafe)
	move.w	d3,-(sp)			;write all sectors on this side
	move.w	d5,-(sp)			;side to write
	move.w	d2,d1
	sub.w	trks,d1				;-(current_track - trks) = track to write
	neg.w	d1
	move.w	d1,-(sp)
	move.w	#1,-(sp)			;sector to start writing
	move.w	#0,-(sp)			;drive A:
	clr.l	-(sp)				;unused parameter
	move.l	a3,-(sp)			;address of data to write
	move.w	#9,-(sp)			;Flopwr()
	trap	#14					;XBIOS
	lea		20(sp),sp			;fix stack
	move.l	(sp)+,d2		;get back regs unsafe during XBIOS call
	tst.w	d0
	bmi		file_error

	move.w	sct,d1
	mulu.w	#512,d1				;total bytes on this side of track
	lea		(a3,d1.w),a3		;skip data just written

	subq.w	#1,d4				;double sided disk?
	beq.s	sides_done			;done 1 (or both) sides
	moveq	#1,d5
	bra.s	side_loop			;do it again for other side

sides_done

	dbra	d2,track_loop

*
** Close the input file
** (Probably not needed, but just to be safe)
*
	move.w	fhandle,-(sp)
	move.w	#$3e,-(sp)			;close()
	trap	#1					;GEMDOS
	addq.l	#4,sp				;fix stack
	tst.l	d0
	bmi		file_error
*
** Return malloc()ed memory
*
	move.l	memptr,-(sp)
	move.w	#$49,-(sp)
	trap	#1					;GEMDOS
	addq.l	#6,sp
	tst.l	d0
	bmi		mem_err
*
** Terminate
*
	pea		donemsg
	move.w	#$9,-(sp)
	trap	#1				;print out msg
	addq.l	#6,sp
Terminate
	moveq	#0,d0
	move.w	#$4c,-(sp)	;Term()
	trap	#1
*--------------------------------------------------------------------------
file_error
	move.w	d0,-(sp)
	pea		fileerrmsg
	move.w	#$9,-(sp)	;Cconws() (write line)
	trap	#1			;GEMDOS
	addq.l	#6,sp
;	move.w	(sp)+,d0
	move.w	d0,-(sp)	;error number
	move.w	#$4c,-(sp)	;Term()
	trap	#1			;GEMDOS

param_err
	move.w	d0,-(sp)
	pea		paramerrmsg
	move.w	#$9,-(sp)	;Cconws() (write line)
	trap	#1			;GEMDOS
	addq.l	#6,sp
;	move.w	(sp)+,d0
	move.w	d0,-(sp)	;error number
	move.w	#$4c,-(sp)	;Term()
	trap	#1			;GEMDOS

mem_err
	move.w	d0,-(sp)
	pea		memerrmsg
	move.w	#$9,-(sp)	;Cconws() (write line)
	trap	#1			;GEMDOS
	addq.l	#6,sp
;	move.w	(sp)+,d0
	move.w	d0,-(sp)	;error number
	move.w	#$4c,-(sp)	;Term()
	trap	#1			;GEMDOS

size_error
	move.w	d0,-(sp)
	pea		sizeerrmsg
	move.w	#$9,-(sp)	;Cconws() (write line)
	trap	#1			;GEMDOS
	addq.l	#6,sp
;	move.w	(sp)+,d0
	move.w	#-1,-(sp)
	move.w	#$4c,-(sp)	;Term()
	trap	#1			;GEMDOS

*
** getdrive -- converts a drive specifier into a device number
**             (A: => 0, B: => 1)
**
** INPUT: (a0) - drive specifier string (one char)
**                 The first char is the only one listened to: E.g., 'A'
**               will be accepted as well as 'A:', 'Apple', etc.
**                 Only 'A' or 'B' give valid results.
**
** RETURN: d0.w - drive device number, Carry set and -1 for error
**
** EFFECTS: Affects d0.l
*
getdrive
	moveq	#'A',d0
	cmp.b	(a0),d0
	bne.s	.not_a
	moveq	#0,d0
	bra.s	getdrive_done
.not_a
	moveq	#'B',d0
	cmp.b	(a0),d0
	bne.s	.not_b
	moveq	#1,d0
	bra.s	getdrive_done
.not_b
	moveq	#-1,d0
	ori.b	#1,ccr
getdrive_done
	rts

*
** getdec -- converts an ASCII string (nondigit delimited) into a number
**
** INPUT: (a0) - drive specifier string (one char)
**                 The first char is the only one listened to: E.g., 'A'
**               will be accepted as well as 'A:', 'Apple', etc.
**                 Only 'A' or 'B' give valid results.
**
** RETURN: d0.w - decimal number, Carry set if non-space encountered
**
** EFFECTS: Affects d0.l
**          (a0) is updated past end of a valid number string
*
getdec
	move.l	d1,-(sp)
	moveq	#0,d0
getdec_loop
	move.b	(a0)+,d1
	cmpi.b	#'0',d1
	bcs.s	.getdec_end
	cmpi.b	#':',d1
	bcc.s	.getdec_end
	mulu.w	#10,d0
	subi.b	#'0',d1
	ext.w	d1
	add.w	d1,d0
	bra.s	getdec_loop
.getdec_end
	cmpi.b	#' ',d1
	beq.s	getdec_done
getdec_err
	moveq	#-1,d0
	ori.b	#1,ccr
getdec_done
	move.l	(sp)+,d1
	rts


  SECTION DATA
ESC		equ	27
titlemsg	dc.b	13,10,ESC,'bO'
			dc.b	"-=-=-= ArghBlarg's .ST to Disk Utility =-=-=-",13,10
			dc.b	"Usage: sttodsk <file>",13,10
			dc.b	"----------------------",13,10
			dc.b	ESC,'b1',"CAUTION",ESC,'bO',": This utility ",ESC,'b1',"FORMATS and OVERWRITES"
			dc.b	ESC,'bO',13,10
			dc.b	"the disk in drive A: immediately upon startup if <file> is",13,10
			dc.b	"found and validated as a real .ST file!",13,10
			dc.b	"  I take no responsibility for damage caused to your",13,10
			dc.b	" floppies by this utility. -ArghBlarg May 12, 1997",13,10
			dc.b	ESC,'bO',13,10
			dc.b	0

loadmsg		dc.b	13,10,ESC,'l'
			dc.b	"Reading input file",13,10,0

deducemsg	dc.b	"Deducing disk format..",13,10,0

formatmsg	dc.b	ESC,'l',ESC,'b2'
			dc.b	"Formatting track-",0

writemsg	dc.b	ESC,'l',ESC,'b1'
			dc.b	"Writing track-  ",0

donemsg		dc.b	ESC,'l',ESC,'bO'
			dc.b	"Done.",13,10,0

sizeerrmsg	dc.b	ESC,'l',ESC,'bO'
			dc.b	"Unknown disk image format!",13,10,0

fileerrmsg	dc.b	ESC,'l',ESC,'bO'
			dc.b	"File operation error!",13,10,0

paramerrmsg	dc.b	ESC,'l',ESC,'bO'
			dc.b	"Parameter error!",13,10,0

memerrmsg	dc.b	ESC,'l',ESC,'bO'
			dc.b	"Memory allocation error!",13,10,0

  SECTION BSS
fhandle		ds.w	1
fsize		ds.l	1
memptr		ds.l	1
trks		ds.w	1		;tracks in the disk
sct			ds.w	1		;sectors per track
sides		ds.w	1		;sides of the disk
dta_area	ds.b	44		;space for DTA
fmtbuff		ds.b	512*11*2
  END
