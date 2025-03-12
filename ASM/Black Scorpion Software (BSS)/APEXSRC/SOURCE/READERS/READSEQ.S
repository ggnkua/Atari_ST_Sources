		IFD	CRAP

<Cyber Paint Sequence>  *.SEQ (low resolution only)

   This format, while fairly complex, yields excellent compression of animated
images while offering reasonably fast decompression times.
 
1 word          magic number [$FEDB or $FEDC]
1 word          version number
1 long          number of frames
1 word          speed (high byte is vblanks per frame)
118 bytes       reserved
---------
128 bytes       total for .SEQ header

for each frame {
1 long          offset to data for this frame, in bytes [basically useless]
}

for each frame {
1 word          type (ignored?)
1 word          resolution [always 0]
16 words*       palette
12 bytes        filename [usually "        .   "]

1 word          color animation limits [not used]
1 word          color animation speed and direction [not used]
1 word          number of color steps [not used]
1 word*         x offset for this frame [0 - 319]
1 word*         y offset for this frame [0 - 199]
1 word*         width of this frame, in pixels (may be 0, see below)
1 word*         height of this frame, in pixels (may be 0, see below)
1 byte*         operation [0 = copy, 1 = exclusive or]
1 byte*         storage method [0 = uncompressed, 1 = compressed]
1 long          length of data in bytes (if the data is compressed, this
                will be the size of the compressed data BEFORE decompression)
60 bytes        reserved                
--------
128 bytes       total for frame header

? bytes         data
}

   Frames are "delta-compressed," meaning that only the changes from one
frame to the next are stored.  On the ST, .SEQ files are always full-screen
low resolution animations, so the sequence resulting from expanding all the
data will be n 320 by 200 pixel low resolution screens, where n is given in
the .SEQ header.
  
   Since only the changes from frame to frame are stored, image data for a
frame will rarely be 320x200 (except for the very first frame, which will 
always be a full screen).  Instead what is stored is the smallest rectangular
region on the screen that contains all the changes from the previous frame to
the current frame.  The x offset and y offset in the frame header determine
where the upper left corner of the "change box" lies, and the width and height
specify the box's size.

   Additionally, each "change box" is stored in one of five ways.  For each
   of these, the screen is assumed to have the full-screen image from the last
   frame on it.
   
   o uncompressed copy:  The data for this frame is uncompressed image data,
     and is simply copied onto the screen at position (x, y) specified
     in the frame header.

   o uncompressed eor:  The data for this frame is exclusive or'ed with the
     screen at position (x, y).

   o compressed copy:  The data for this frame must be decompressed (see 
     below), and then copied onto the screen at position (x, y) specified
     in the frame header.
 
   o compressed eor:  The data for this frame must be decompressed (see 
     below), and then exclusive or'ed with the screen RAM at position (x, y).
 
   o null frame:  The width and/or height of this frame is 0, so this
     frame is the same as the previous frame.
   
   Of the 5 methods above, the one that results in the smallest amount
   of data being stored for a particular is used for that frame.
  
Compression Scheme:

   Compression is similar to that employed by Tiny, but is not quite as
space-efficient.

Control word meanings:

        For a given control word, x:

        x < 0   Absolute value specifies the number of unique words to
                take from the data section (from 1 to 32767).
        x > 0   Specifies the number of times to repeat the next word
                taken from the data section (from 1 to 32767).

        Note that a control word of 0 is possible but meaningless.

Format of expanded data:

   The expanded data is not simply screen memory bitmap data; instead the four
bitplanes are separated, and the data within each bitplane is presented
vertically instead of horizontally.  (This results in better compression.)

   To clarify, data for a full screen would appear in the following order:
   
   bitplane 0, word 0, scanline 0
   bitplane 0, word 0, scanline 1
   ...
   bitplane 0, word 0, scanline 199

   bitplane 0, word 1, scanline 0
   bitplane 0, word 1, scanline 1
   ...
   bitplane 0, word 1, scanline 199
   ... 
   bitplane 0, word 79, scanline 199
   bitplane 1, word 0, scanline 0
   ... 
   bitplane 3, word 79, scanline 199

Note however, that the data does not usually refer to an entire screen, but
rather to the smaller "change box," whose size is given in the frame header.

		ENDC

*--------------------------------------------------------------------------*

SEQ_MAGIC1	=	$FEDB
SEQ_MAGIC2	=	$FEDC

*--------------------------------------------------------------------------*

			rsreset
SEQ_SH_Magic	rs.w	1
SEQ_SH_Version	rs.w	1
SEQ_SH_Frames	rs.l	1
SEQ_SH_Speed	rs.w	1
SEQ_SH_Pad		rs.b	118
SEQ_SH_Length	rs.b	0

			rsreset
SEQ_FH_Type		rs.w	1
SEQ_FH_Res		rs.w	1
SEQ_FH_Palette	rs.w	16
SEQ_FH_Name		rs.b	12
SEQ_FH_CAL		rs.w	1
SEQ_FH_CASD		rs.w	1
SEQ_FH_CS		rs.w	1
SEQ_FH_Xoff		rs.w	1
SEQ_FH_Yoff		rs.w	1
SEQ_FH_Width	rs.w	1
SEQ_FH_Height	rs.w	1
SEQ_FH_Oper		rs.b	1
SEQ_FH_Comp		rs.b	1
SEQ_FH_Datasize	rs.l	1
SEQ_FH_Pad		rs.b	60
SEQ_FH_Length	rs.b	0

*--------------------------------------------------------------------------*

OPEN_SEQ:
	move.l	PACK_SCR,FLC_FILEBUFFER
	move.l	sp,FLC_Stack
	bsr		OpenFile
	move.w	d0,FLC_Handle
	bpl.s		Read_SEQ_FileHeader
	moveq		#-1,d0
	rts
	
Read_SEQ_FileHeader:
	move.l	FLC_FILEBUFFER,a0
	move.w	FLC_Handle,d0
	move.l	#SEQ_SH_Length,d1
	bsr		ReadFile
	tst.l		d0
	bmi.s		.rts
	move.l	FLC_FILEBUFFER,a0
	move.w	SEQ_SH_Magic(a0),FLC_Magic
	move.l	SEQ_SH_Frames(a0),d1
	move.w	d1,FLC_Frames
	move.w	d1,FLC_ReadCount
	move.w	SEQ_SH_Speed(a0),FLC_Speed
	cmp.w		#SEQ_MAGIC1,FLC_Magic
	beq.s		.seek
	cmp.w		#SEQ_MAGIC2,FLC_Magic
	beq.s		.seek
	moveq		#-1,d0
	bra.s		.rts
.seek	moveq		#0,d1
	move.w	FLC_Frames,d1
	add.l		d1,d1
	add.l		d1,d1
	move.w	FLC_Handle,d0
	move.l	FLC_FILEBUFFER,a0
	jsr		ReadFile
	tst.l		d0
	bmi.s		.rts
	moveq		#0,d0	
.rts	rts
	
READ_SEQ_FRAME:
	move.l	PACK_SCR,FLC_FILEBUFFER
	move.l	sp,FLC_Stack
	move.l	FLC_FILEBUFFER,a0
	move.w	FLC_Handle,d0
	move.l	#SEQ_FH_Length,d1
	bsr		ReadFile
	tst.l		d0
	bmi		SEQ_Error
	move.l	FLC_FILEBUFFER,a0
	move.l	SEQ_FH_Datasize(a0),FLC_FrameSize
	move.w	SEQ_FH_Xoff(a0),SEQ_Xoff
	move.w	SEQ_FH_Yoff(a0),SEQ_Yoff
	move.w	SEQ_FH_Width(a0),SEQ_Width
	move.w	SEQ_FH_Height(a0),SEQ_Height
	move.b	SEQ_FH_Oper(a0),SEQ_Oper
	move.b	SEQ_FH_Comp(a0),SEQ_Comp
	lea		SEQ_FH_Palette(a0),a0
	jsr		convert_cols
	sf		FLC_ChangeMade
	tst.w		SEQ_Width
	beq.s		.next_frame
	tst.w		SEQ_Height
	beq.s		.next_frame
	st		FLC_ChangeMade
	move.l	FLC_FrameSize,d0
	jsr		Add_fast
	tst.l		d0
	bmi.s		SEQ_Error
	move.w	d0,FLC_FILEHANDLE
	jsr		Find_block
	move.l	a0,FLC_FILEBUFFER
	move.w	FLC_Handle,d0
	move.l	FLC_FrameSize,d1
	bsr		ReadFile
	tst.l		d0
	bpl.s		.cont
	move.w	FLC_FILEHANDLE,d0
	jsr		Remove_block
	bra		SEQ_Error
.cont	bsr		Decrunch_SEQ_Frame	
	move.w	FLC_FILEHANDLE,d0
	jsr		Remove_block
.next_frame	
	moveq		#0,d0
	st		FLC_MoreToCome
	subq.w	#1,FLC_ReadCount
	bne.s		SEQ_Exit
SEQ_Error:
	move.w	FLC_Handle,d0
	bsr		CloseFile
	sf		FLC_MoreToCome
	moveq		#-1,d0
SEQ_Exit:
	move.l	FLC_Stack,sp
	rts
	
CLOSE_SEQ:
	move.w	FLC_Handle,d0
	ble.s		.done
	bsr		CloseFile
.done	clr.w		FLC_Handle
	sf		FLC_MoreToCome
	rts

Decrunch_SEQ_Frame:
	bsr		create_changebox
	tst.l		d0
	bmi.s		.rts
	bsr		decode_changebox
	bsr		reformat_changebox
	bsr		draw_changebox
	bsr		remove_changebox
.rts	rts
	
create_changebox:
	move.w	SEQ_Width,d6
	add.w		#15,d6
	lsr.w		#4,d6
	move.w	d6,SEQ_linewords
	lsl.w		#4,d6
	move.w	d6,SEQ_linebytes
	mulu		SEQ_Height,d6
	move.l	d6,d0
	move.l	d0,filebytes
	jsr		Add_fast
	tst.l		d0
	bmi.s		.rts
	move.w	d0,abuff1_handle
	jsr		Find_block
	move.l	a0,changebox
	move.l	filebytes,d0
	jsr		memclr
	moveq		#0,d0
.rts	rts

remove_changebox:
	move.w	abuff1_handle,d0
	jsr		Remove_block
	rts

decode_changebox:
	move.l	FLC_FILEBUFFER,a0
	move.l	changebox,a1
	move.w	SEQ_Height,d7	; rows
	move.w	SEQ_linewords,d6	; columns
	moveq		#4,d5			; bitplanes
	move.l	a1,a2
	move.l	a2,a3
	tst.b		SEQ_Comp
	beq.s		.raw
*-------------------------------------*
.next	move.w	(a0)+,d0
	bmi.s		.copy
*-------------------------------------*
.same	subq		#1,d0
	move.w	(a0)+,d1
.slp	move.w	d1,(a3)
	add.w		SEQ_linebytes,a3
	subq		#1,d7
	bne.s		.skip
	move.w	SEQ_Height,d7	; rows
	lea		16(a2),a2
	move.l	a2,a3
	subq		#1,d6
	bne.s		.skip
	move.w	SEQ_linewords,d6	; columns
	addq.l	#2,a1
	move.l	a1,a2
	move.l	a2,a3
	subq		#1,d5
	beq		.stop
.skip	dbra		d0,.slp
	bra.s		.next
*-------------------------------------*
.copy	and.w		#$7FFF,d0
	subq		#1,d0
.clp	move.w	(a0)+,(a3)
	add.w		SEQ_linebytes,a3
	subq		#1,d7
	bne.s		.ski2
	move.w	SEQ_Height,d7	; rows
	lea		16(a2),a2
	move.l	a2,a3
	subq		#1,d6
	bne.s		.ski2
	move.w	SEQ_linewords,d6	; columns
	addq.l	#2,a1
	move.l	a1,a2
	move.l	a2,a3
	subq		#1,d5
	beq.s		.stop
.ski2	dbra		d0,.clp
	bra.s		.next
*-------------------------------------*
.raw	move.w	(a0)+,(a3)
	add.w		SEQ_linebytes,a3
	subq		#1,d7
	bne.s		.ski3
	move.w	SEQ_Height,d7	; rows
	lea		16(a2),a2
	move.l	a2,a3
	subq		#1,d6
	bne.s		.ski3
	move.w	SEQ_linewords,d6	; columns
	addq.l	#2,a1
	move.l	a1,a2
	move.l	a2,a3
	subq		#1,d5
	beq.s		.stop
.ski3	bra.s		.raw
*-------------------------------------*
.stop	rts

reformat_changebox:
	move.w	SEQ_Width,d0
	add.w		#15,d0
	and.w		#-16,d0
	move.w	SEQ_Height,d1
	move.l	changebox,a0
	jsr		BPS2BytePerPixel
	rts

draw_changebox:
	move.l	FLC_ANIMBUFFER,a1
	move.w	SEQ_Yoff,d0
	mulu		#320,d0
	add.l		d0,a1
	add.w		SEQ_Xoff,a1
	move.l	changebox,a0
	tst.b		SEQ_Oper
	bne.s		.eor
	pushall
	move.l	FLC_ANIMBUFFER,a0
	move.l	#(320*200),d0
	jsr		memclr
	popall
.copy	move.w	SEQ_Height,d7
	subq		#1,d7
.ylp	move.l	a0,a2
	move.l	a1,a3
	move.w	SEQ_Width,d6
	subq		#1,d6
.xlp	move.b	(a2)+,(a3)+
	dbra		d6,.xlp
	add.w		SEQ_linebytes,a0
	lea		320(a1),a1
	dbra		d7,.ylp
	rts
.eor	move.w	SEQ_Height,d7
	subq		#1,d7
.ylp2	move.l	a0,a2
	move.l	a1,a3
	move.w	SEQ_Width,d6
	subq		#1,d6
.xlp2	move.b	(a2)+,d0
	eor.b		d0,(a3)+
	dbra		d6,.xlp2
	add.w		SEQ_linebytes,a0
	lea		320(a1),a1
	dbra		d7,.ylp2
	rts
	
*--------------------------------------------------------------------------*
			BSS
*--------------------------------------------------------------------------*

changebox:		ds.l	1
SEQ_linebytes:	ds.w	1
SEQ_linewords:	ds.w	1
SEQ_Xoff:		ds.w	1
SEQ_Yoff:		ds.w	1
SEQ_Width:		ds.w	1
SEQ_Height:		ds.w	1
SEQ_Oper:		ds.b	1
SEQ_Comp:		ds.b	1
			even

*--------------------------------------------------------------------------*
			TEXT
*--------------------------------------------------------------------------*

