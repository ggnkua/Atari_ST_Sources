;
; SNDH testprogram
; 
; January 4, 2000
; Anders Eriksson / Odd Skancke
; ae@dhs.nu         ozk@atari.org
; 
; snd_load.s


********************
;Simple routine to check if the filename is ending with .snd.
isit_snd:	movem.l	a0/a4,-(sp)
		move.l	filename,a0			;Address of full filename
.lop1:		tst.b	(a0)+				;Find end
		bne.s	.lop1
		subq.l	#1,a0				;Now A0 points to the null byte
		movea.l	sp,a4				;Use A4
		move.b	-(a0),-(a4)			;Copy the 4 last chars from the fname
		move.b	-(a0),-(a4)			;to the stack. We know that this
		move.b	-(a0),-(a4)			;will be an even address, and
		move.b	-(a0),-(a4)			;then we can compare using
		cmp.l	#'.snd',(a4)			;these instructions
		beq.s	.file_is_snd
		cmp.l	#'.SND',(a4)
		beq.s	.file_is_snd
		and.b	#-2,ccr
		bra.s	.exit
.file_is_snd:	or.b	#1,ccr
.exit:		movem.l	(sp)+,a0/a4
		rts

************************
	;Load file whose full path and filename is in "path_file"
load_song:	movem.l	d0-a1/a3-6,-(sp)
		move.l	a2,-(sp)			;Save a2 so we preserve it when no errors
	
	;Check if the file extender is ".snd" or ".SND"
.check_for_snd:	bsr	isit_snd
		bcs.s	.file_is_snd
		
	;The file extender is not .snd, load address of error msg in A2 and exit
		lea	.not_snd_m(pc),a2
		bra	.fileerror
	
	;Get size of file
.file_is_snd:	move.l	filename,a0
		bsr	getfile_sd			;Get size of and date of file
		bcs.s	.file_is_there			;File was there and size is returned in D0

	;Error, the file was not there.
		lea	.file_nfnd_m(pc),a2		;Load address of error msg..
		bra	.fileerror			;And exit
	
	;Get size of filename string cause we copy this into
	;the buffer containing the song data
.file_is_there:

	;D0 = size of file
	;Load 12 bytes from the file, which we use to check if this is a ICE packed file..
		move.l	d0,-(sp)
		lea	-12(sp),sp
		lea	(sp),a1
		moveq	#12,d0
		move.l	filename,a0
		bsr	load_file
		movem.l	(a1),d3-5
		lea	12(sp),sp
		move.l	(sp)+,d0

		cmp.l	#'ICE!',d3
		bne	.not_packed
	
	;D0 = size of file
	;D4 = Size of file - from ice header, we don't use this.
	;D5 = Size of unpacked file
		move.l	d0,d3				;Size of packed file (filesize on disk)
		add.l	d5,d0				;Size of unpacked data
	
	;D0 = Size of buffer including packed and unpacked filesizes
	;D3 = Size of packed file
	;D5 = Size of unpacked file
	;D6 = Date of file
		
	;Get memory of size unpacked+packed data
		movem.l	d1-2/a0-2,-(sp)
		move.l	d0,-(sp)
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d1-2/a0-2
		
		tst.l	d0				;Memory sucessfully obtained?
		beq.s	.mem_fault			;nope

		move.l	d0,song_address			;Store address of memory
		move.l	d0,a3

	;Load the packed file after where the unpaced data will be, so we can Mshrink()
	;the memory after unpacking...
		lea	(a3,d5.l),a1			;A1 = End of unpacked Data - load packed data here
		move.l	d3,d0				;Size of packed file
		move.l	filename,a0			;Address if filename
		bsr	load_file			;Attempt to load file.
		bcc	.load_fault			;Some error happened if carry clear
	
	;Set up the register A0, A1 and call Ice..
		move.l	a1,a0
		move.l	a3,a1
		bsr	ice_decrunch
		move.l	a3,a1

	;Shrink the memory, we don't need to keep the packed data...
		movem.l	d0-2/a0-2,-(sp)
		move.l	d5,-(sp)
		move.l	a3,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea	12(sp),sp
		movem.l	(sp)+,d0-2/a0-2
	;All done..
		bra.s	.fload_ok

.not_packed:	move.l	d0,d3				;Save size of file in D3

	;Allocate memory for the buffer needed to hold this song
		movem.l	d1-2/a0-2,-(sp)
		move.l	d0,-(sp)
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d1-2/a0-2
		tst.l	d0
		bne.s	.mem_ok

.mem_fault:	lea	.no_mem_m(pc),a2
		bra	.fileerror

.mem_ok:	move.l	d0,song_address			;Start address of buffer
		move.l	d0,a3				;
	
	;Load the songfile into the buffer 
		move.l	filename,a0
		movea.l	a3,a1				;Use offset to get to songstart, where the file will be loaded
		move.l	d3,d0				;Size of song file
		bsr	load_file
		bcs.s	.fload_ok			;File loaded ok, check if it's really a .snd file

.load_fault:	lea	.errdurlod_m(pc),a2		;Some error during load.
	
	;If fileloading didn't work, release the mem just allocated
.fload_error:	move.l	a2,-(sp)
		move.l	a3,-(sp)
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	(sp)+,a2
		clr.l	song_address
                
.fileerror:	addq.l	#4,sp
		and.b	#-2,ccr
		bra.s	.fl_exit
.fload_ok:	move.l	(sp)+,a2
		or.b	#1,ccr
.fl_exit:	movem.l	(sp)+,d0-a1/a3-6	
		rts

		data
.not_snd_m:	dc.b "Not a .snd file!",0
.file_nfnd_m:	dc.b "Could not locate file",0
.no_mem_m:	dc.b "Not enough memory!",0
.errdurlod_m:	dc.b "Error During file load",0
		text
;--------------------------------------------------------------------------------------------
gsizfil:	reg	d2-7/a0-4
getfile_sd:	movem.l	gsizfil,-(sp)

		tst.b	MiNT_domain				;MiNT domain?
		beq.s	.no_mint				;Nope, then use Ffirst/next()

	;Running in the MiNT domain, use Fxattr() to get file info...
		lea	-xattr_ssize(sp),sp
		movea.l	a0,a1
		lea	(sp),a0
		moveq	#0,d0
		bsr	Fxattr
		bmi.s	.gfs_mnterr
		move.l	xattr_size(a0),d0
		move.l	xattr_ctime(a0),d1
		lea	xattr_ssize(sp),sp
		or.b	#1,ccr
		bra.s	.gfs_return
.gfs_mnterr:	lea	xattr_ssize(sp),sp
		and.b	#-2,ccr
		bra.s	.gfs_return
		
	;Search directory for the file
.no_mint:	moveq	#0,d0					;Attributes
		bsr	Fsfirst					;Search for entry
		tst.l	d0					;Error?
		bpl.s	.gfs_found				;No

	;GEMDOS delivered an error code in D0
.gfs_error:	and.b	#-2,ccr					;Clear carry = ERROR OCCURED!
		bra.s	.gfs_return

	;Return filesize in D0 and file date/time in D1
.gfs_found:	lea	dta,a0					;Address of the DTA
		move.l	d_lenght(a0),d0				;Get size of file in D0
		move.l	d_time(a0),d1				;Get date and time of file in D1

	;The file was found and it's size is now in D0 - ALL OK
.gfs_exit:	ori.b	#1,ccr					;Set carry = no error
.gfs_return:	movem.l	(sp)+,gsizfil
		rts

;------------------------------------------------------------------------------------------------
lfreg:		reg d1-7/a0-4
load_file:	movem.l	lfreg,-(sp)

		move.l	d0,d6					;Size of file in D6

		moveq	#0,d0					;Mode for open (read only access)
		bsr	Fopen					;Open the file (A0 = address to path/file)
		move.l	d0,d7					;Put handle in D7
		bmi.s	.lf_error				;Negative return = error

		movea.l	a1,a0					;Address of buffer to load file into
		move.l	d6,d1			;Size of file (bytes to load)
		bsr	Fread			;Read it
		move.l	d0,d6			;Number of bytes actually read
		bpl.s	.lf_readok		;A positive value = no error

	;GEMDOS delivered an error..
.lf_error:	and.b	#-2,ccr
		bra.s	.lf_exit

.lf_readok:	move.l	d7,d0			;Handle back into D0
		bsr	Fclose			;Close the file

	;Load completed successfully, put size of file into D7, set carry and exit
		move.l	d6,d0
		ori.b	#1,ccr
.lf_exit:	movem.l	(sp)+,lfreg
		rts

;---------------------------------------------------------------------------------------------------
	;A0 = Address of filename
	;D0 = Mode
Fopen:		movem.l	d1-2/a0-2,-(sp)
 		move.w	d0,-(sp)
		move.l	a0,-(sp)
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

	;D0 = Handle number
Fclose:		movem.l	d1-2/a0-2,-(sp)
		move.w	d0,-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

	;A0 = Address of data buffer
	;D0 = File handle
	;D1 = Number of bytes
Fread:		movem.l	d1-2/a0-2,-(sp)
		move.l	a0,-(sp)
		move.l	d1,-(sp)
		move.w	d0,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea	12(sp),sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts
	;A0 = Address of filename
	;d0 = File attribute
Fsfirst:	movem.l	d1-2/a0-2,-(sp)
		move.w	d0,-(sp)
		move.l	a0,-(sp)
		move.w	#$4e,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts
	;A0 = Buffer where xattribs will be stored
	;A1 = Address of filename
	;D0 = Flag
Fxattr:		movem.l	d1-2/a0-2,-(sp)
		move.l	a0,-(sp)
		move.l	a1,-(sp)
		move.w	d0,-(sp)
		move.w	#$12c,-(sp)
		trap	#1
		lea	12(sp),sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts


*** XATTR structure ***
	rsreset
xattr_mode:	rs.w	1
xattr_index:	rs.l	1
xattr_dev:	rs.w	1
xattr_reserved1:rs.w	1
xattr_nlink:	rs.w	1
xattr_uid:	rs.w	1
xattr_gid:	rs.w	1
xattr_size:	rs.l	1
xattr_blksize:	rs.l	1
xattr_nblocks:	rs.l	1
xattr_mtime:	rs.w	1
xattr_mdate:	rs.w	1
xattr_atime:	rs.w	1
xattr_adate:	rs.w	1
xattr_ctime:	rs.w	1
xattr_cdate:	rs.w	1
xattr_attr:	rs.w	1
xattr_reserved2:rs.w	1
xattr_reserved3:rs.l	1
xattr_reserved4:rs.l	1
xattr_ssize	= __RS

*** Structure DTA ***
	rsset 0
d_reserved	rs.b	21
d_attrib	rs.b	1
d_time		rs.w	1
d_date		rs.w	1
d_lenght	rs.l	1
d_fname		rs.b	14