
*--------------------------------------------------------------------------*

FLI_MAGIC	=	$AF11
FLC_MAGIC	=	$AF12
FLH_MAGIC1	=	$AF43
FLH_MAGIC2	=	$AF44

FRAME_MAGIC	=	$F1FA

*--------------------------------------------------------------------------*

			rsreset
FLC_FH_FileSize	rs.l	1
FLC_FH_Magic	rs.w	1
FLC_FH_Frames	rs.w	1
FLC_FH_ScrWid	rs.w	1
FLC_FH_ScrHig	rs.w	1
FLC_FH_Depth	rs.w	1
FLC_FH_Flags	rs.w	1
FLC_FH_Speed	rs.l	1
FLC_FH_Pad1		rs.w	1
FLC_FH_Created	rs.l	1
FLC_FH_Creator	rs.l	1
FLC_FH_Updated	rs.l	1
FLC_FH_Updator	rs.l	1
FLC_FH_XAspect	rs.w	1
FLC_FH_YAspect	rs.w	1
FLC_FH_Pad2		rs.b	38
FLC_FH_Frame1	rs.l	1
FLC_FH_Frame2	rs.l	1
FLC_FH_Pad3		rs.b	40
FLC_FH_Length	rs.b	0

*--------------------------------------------------------------------------*

			rsreset
FLC_FC_Size		rs.l	1
FLC_FC_Type		rs.w	1
FLC_FC_Chunks	rs.w	1
FLC_FC_Pad1		rs.b	8
FLC_FC_Length	rs.b	0

*--------------------------------------------------------------------------*

movw	macro
	move.w	\1,d0
	ror.w		#8,d0
	move.w	d0,\2
	endm

movl	macro
	move.l	\1,d0
	ror.w		#8,d0
	swap		d0
	ror.w		#8,d0
	move.l	d0,\2
	endm

*--------------------------------------------------------------------------*

OPEN_FLIC:
	move.l	PACK_SCR,FLC_FILEBUFFER
	move.l	sp,FLC_Stack
	bsr		OpenFile
	tst.l		d0
	bpl.s		.Read_FLC_FileHeader
	rts
	
.Read_FLC_FileHeader:
	move.w	d0,FLC_Handle
	move.l	FLC_FILEBUFFER,a0
	move.w	FLC_Handle,d0
	move.l	#FLC_FH_Length,d1
	bsr		ReadFile
	move.l	FLC_FILEBUFFER,a0
	movw		FLC_FH_Magic(a0),FLC_Magic
	move.w	#8,FLC_Depth
	cmp.w		#FLI_MAGIC,FLC_Magic
	beq.s		.ok2
	movw		FLC_FH_Depth(a0),FLC_Depth
	cmp.w		#FLC_MAGIC,FLC_Magic
	beq.s		.ok2
	cmp.w		#FLH_MAGIC2,FLC_Magic
	beq.s		.ok2
	move.w	#15,FLC_Depth
	cmp.w		#FLH_MAGIC1,FLC_Magic
	bne		FLC_Error	
.ok2	movl		FLC_FH_FileSize(a0),FLC_FileSize
	movw		FLC_FH_Frames(a0),d1
	move.w	d1,FLC_Frames
	move.w	d1,FLC_ReadCount
	movw		FLC_FH_ScrWid(a0),FLC_ScrWidth
	move.w	FLC_ScrWidth,d1
	cmp.w		#8,FLC_Depth
	beq.s		.ok
	add.w		d1,d1
.ok	move.w	d1,FLC_LineWidth
	movw		FLC_FH_ScrHig(a0),FLC_ScrHeight
	movw		FLC_FH_Flags(a0),FLC_Flags
	movw		FLC_FH_Speed(a0),d2
	cmp.w		#FLI_MAGIC,FLC_Magic
	beq.s		.fli
.flc	movl		FLC_FH_Speed(a0),d2
	move.l	d2,FLC_Speed
	divu.w	ms,d2
.fli	subq		#1,d2
	bpl.s		.o1
	moveq		#0,d2
.o1	move.w	d2,CURRENT_TIME
	move.l	#128,FLC_Frame1
	cmp.w		#FLI_MAGIC,FLC_Magic
	beq.s		Seek_Frame1
;	cmp.w		#3,FLC_Flags			; <- not sure about this one
;	bne		FLC_Error
	movw		FLC_FH_XAspect(a0),FLC_XAspect
	movw		FLC_FH_YAspect(a0),FLC_YAspect
	movl		FLC_FH_Frame1(a0),FLC_Frame1
	movl		FLC_FH_Frame2(a0),FLC_Frame2
Seek_Frame1:
	move.w	FLC_Handle,d0
	moveq		#0,d1
	move.l	FLC_Frame1,d2
	bsr		SeekFile
	rts
	
READ_FLIC_FRAME:
	move.l	PACK_SCR,FLC_FILEBUFFER
	move.l	sp,FLC_Stack
	move.l	FLC_FILEBUFFER,a0
	clr.w		FLC_FC_Type(a0)
	move.w	FLC_Handle,d0
	moveq		#FLC_FC_Length,d1
	bsr		ReadFile
	move.l	FLC_FILEBUFFER,a0
	movl		FLC_FC_Size(a0),FLC_FrameSize
	movw		FLC_FC_Type(a0),FLC_ChunkType
	cmp.w		#FRAME_MAGIC,FLC_ChunkType
	bne.s		FLC_Error
	movw		FLC_FC_Chunks(a0),FLC_Chunks
	sf		FLC_ChangeMade
	tst.w		FLC_Chunks
	beq.s		.next_frame
	st		FLC_ChangeMade
	move.l	FLC_FrameSize,d0
	jsr		Add_fast
	tst.l		d0
	bmi.s		FLC_Error
	move.w	d0,FLC_FILEHANDLE
	jsr		Find_block
	move.l	a0,FLC_FILEBUFFER
	move.w	FLC_Handle,d0
	move.l	FLC_FrameSize,d1
	sub.l		#FLC_FC_Length,d1
	bsr		ReadFile
	bsr.s		Decrunch_FLC_Frame	
	move.w	FLC_FILEHANDLE,d0
	jsr		Remove_block
.next_frame	
	moveq		#0,d0
	st		FLC_MoreToCome
	subq.w	#1,FLC_ReadCount
	bne.s		FLC_Exit
FLC_Error:
	move.w	FLC_Handle,d0
	bsr		CloseFile
	sf		FLC_MoreToCome
	moveq		#-1,d0
FLC_Exit:
	move.l	FLC_Stack,sp
	rts
	
CLOSE_FLC:
	move.w	FLC_Handle,d0
	ble.s		.done
	bsr		CloseFile
.done	clr.w		FLC_Handle
	sf		FLC_MoreToCome
	rts

Decrunch_FLC_Frame:
	move.l	FLC_FILEBUFFER,CHUNK_PTR
Next_Chunk:
	move.l	CHUNK_PTR,a0
	movl		FLC_FC_Size(a0),FLC_ChunkSize
	move.w	FLC_FC_Type(a0),d0
	ror.w		#8,d0
	cmp.w		#27,d0
	bgt.s		.skip
	jsr		([Methods.l,d0.w*4])
.skip	move.l	FLC_ChunkSize,d0
	add.l		d0,CHUNK_PTR
	subq		#1,FLC_Chunks
	bne.s		Next_Chunk
NA:	cmp.w		#8,FLC_Depth
	beq.s		.ok
	st		PALETTE_CHANGED
.ok	rts
	
Methods:					; !=tested ?=untested *=unsupported
	dc.l		NA			; ()=method NA=reserved
	dc.l		NA
	dc.l		NA
	dc.l		NA
	dc.l		FLI_COLOR256	; (04) 24-bit palette		!
	dc.l		NA
	dc.l		NA
	dc.l		FLI_SS2		; (07) word delta			!
	dc.l		NA
	dc.l		NA
	dc.l		NA
	dc.l		FLI_COLOR		; (11) 18-bit palette		?
	dc.l		FLI_LC		; (12) byte delta			!
	dc.l		FLI_BLACK		; (13) clear screen		?
	dc.l		NA
	dc.l		FLI_BRUN		; (15) byte/word RLE		!
	dc.l		FLI_COPY		; (16) block copy			?
	dc.l		NA
	dc.l		FLI_PSTAMP		; (18) thumbnail preview	*
	dc.l		NA
	dc.l		NA
	dc.l		NA
	dc.l		NA
	dc.l		NA
	dc.l		NA
	dc.l		FLI_PRUN		; (25) pixel RLE			?
	dc.l		NA
	dc.l		FLI_PSS2		; (27) pixel delta		?
	
FLI_COLOR256:
	move.l	CHUNK_PTR,a0
	addq		#6,a0
	movw		(a0)+,FLC_ColPacks
	move.l	PALETTE_PTR,a1
.next	moveq		#0,d0
	move.b	(a0)+,d0
	lea		(a1,d0.w*4),a1
	move.b	(a0)+,d0
	subq		#1,d0
	and.w		#$FF,d0
	move.l	COLMASK,d1
.rgb	clr.b		(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	and.l		d1,-4(a1)
	dbra		d0,.rgb
	subq		#1,FLC_ColPacks
	bne.s		.next
	st		PALETTE_CHANGED
	rts

FLI_SS2:
	move.l	CHUNK_PTR,a0
	addq		#6,a0
	move.l	FLC_ANIMBUFFER,a1
	move.l	a1,a2
	movw		(a0)+,d7
	subq		#1,d7
	bmi.s		.err
.vert	moveq		#0,d6
.look	move.w	(a0)+,d0
	ror.w		#8,d0
	tst.w		d0
	bmi.s		.code
	subq		#1,d0
	bmi.s		.err
	bra.s		.dcod
.code	move.w	d0,d1
	and.w		#%01000000<<8,d1
	beq.s		.term
	neg.w		d0
	mulu		FLC_LineWidth,d0
	add.l		d0,a2
	move.l	a2,a1
	bra.s		.look
.term	move.b	d0,d5			; byte to finish with
	moveq		#-1,d6		; set term flag
	bra.s		.look
.dcod	moveq		#0,d1
	move.b	(a0)+,d1
	lea		(a1,d1.w),a1
	move.b	(a0)+,d1
	ext.w		d1
	bpl.s		.copy
.run	neg.w		d1
	subq		#1,d1
	move.w	(a0)+,d2
.rlp	move.w	d2,(a1)+
	dbra		d1,.rlp
	bra.s		.line
.copy	subq		#1,d1
	bmi.s		.line
.clp	move.w	(a0)+,(a1)+
	dbra		d1,.clp
.line	dbra		d0,.dcod
	tst.w		d6
	beq.s		.next
	move.w	FLC_LineWidth,d1
	move.b	d5,-1(a2,d1.w)
.next	add.w		FLC_LineWidth,a2
	move.l	a2,a1
	dbra		d7,.vert
.err	rts

FLI_COLOR:
	move.l	CHUNK_PTR,a0
	addq		#6,a0
	movw		(a0)+,FLC_ColPacks
	move.l	PALETTE_PTR,a1
.next	moveq		#0,d0
	move.b	(a0)+,d0
	lea		(a1,d0.w*4),a1
	move.b	(a0)+,d0
	subq		#1,d0
	and.w		#$FF,d0
	move.l	COLMASK,d3
.rgb	clr.b		(a1)+
	move.b	(a0)+,d2
	lsl.w		#2,d2
	move.b	d2,(a1)+
	move.b	(a0)+,d2
	lsl.w		#2,d2
	move.b	d2,(a1)+
	move.b	(a0)+,d2
	lsl.w		#2,d2
	move.b	d2,(a1)+
	and.l		d3,-4(a1)
	dbra		d0,.rgb
	subq		#1,FLC_ColPacks
	bne.s		.next
	st		PALETTE_CHANGED
	rts

FLI_LC:
	move.l	CHUNK_PTR,a0
	addq		#6,a0
	move.l	FLC_ANIMBUFFER,a1
	movw		(a0)+,d7
	mulu		FLC_LineWidth,d7
	add.l		d7,a1
	move.l	a1,a2
	movw		(a0)+,d7
	subq		#1,d7
	bmi.s		.err
.vert	moveq		#0,d0
	move.b	(a0)+,d0
	bra.s		.line
.dcod	moveq		#0,d1
	move.b	(a0)+,d1
	lea		(a1,d1.w),a1
	move.b	(a0)+,d1
	ext.w		d1
	bpl.s		.copy
.run	neg.w		d1
	subq		#1,d1
	bmi.s		.err
	move.b	(a0)+,d2
.rlp	move.b	d2,(a1)+
	dbra		d1,.rlp
	bra.s		.line
.copy	subq		#1,d1
	bmi.s		.err
.clp	move.b	(a0)+,(a1)+
.err2	dbra		d1,.clp
.line	dbra		d0,.dcod
	add.w		FLC_LineWidth,a2
	move.l	a2,a1
	dbra		d7,.vert
.err	rts


FLI_BLACK:
	move.l	FLC_ANIMBUFFER,a1
	moveq		#0,d5
	move.w	FLC_ScrWidth,d5
	moveq		#0,d4
	move.w	FLC_LineWidth,d4
	subq.w	#1,d5
	move.w	FLC_ScrHeight,d7
	subq.w	#1,d7
	cmp.w		#16,FLC_Depth
	beq.s		.b16
	cmp.w		#24,FLC_Depth
	beq.s		.b16
.b08:	moveq		#0,d1
.ylp:	move.l	a1,a2
	move.w	d5,d6
.xlp:	move.b	d1,(a2)+
	dbra		d6,.xlp
	add.l		d4,a1
	dbra		d7,.ylp	
	rts
.b16:	moveq		#0,d1
.yl2:	move.l	a1,a2
	move.w	d5,d6
.xl2:	move.w	d1,(a2)+
	dbra		d6,.xl2
	add.l		d4,a1
	dbra		d7,.yl2
	rts

FLI_BRUN:
	cmp.w		#16,FLC_Depth
	beq		FLI_WRUN
	move.l	CHUNK_PTR,a0
	addq		#6,a0
	move.l	FLC_ANIMBUFFER,a1
	move.l	a1,a2
	move.w	FLC_ScrHeight,d7
	subq		#1,d7
	bmi.s		.err
.vert	move.w	FLC_ScrWidth,d6
	addq		#1,a0
.dcod	move.b	(a0)+,d1
	ext.w		d1
	bmi.s		.copy
.run	subq		#1,d1
	bmi.s		.err
	move.b	(a0)+,d2
.rlp	move.b	d2,(a1)+
	subq		#1,d6
	beq.s		.line
	dbra		d1,.rlp
	bra.s		.dcod
.copy	neg.w		d1
	subq		#1,d1
	bmi.s		.err
.clp	move.b	(a0)+,(a1)+
	subq		#1,d6
	beq.s		.line
	dbra		d1,.clp
	bra.s		.dcod
.line	add.w		FLC_LineWidth,a2
	move.l	a2,a1
	dbra		d7,.vert
.err	rts

FLI_PRUN_16:
FLI_WRUN:
	move.l	CHUNK_PTR,a0
	addq		#6,a0
	move.l	FLC_ANIMBUFFER,a1
	move.l	a1,a2
	move.w	FLC_ScrHeight,d7
	subq		#1,d7
	bmi.s		.err
.vert	move.w	FLC_ScrWidth,d6
	addq		#1,a0
.dcod	move.b	(a0)+,d1
	ext.w		d1
	bmi.s		.copy
.run	subq		#1,d1
	bmi.s		.err
	move.w	(a0)+,d2
.rlp	move.w	d2,(a1)+
	subq		#1,d6
	beq.s		.line
	dbra		d1,.rlp
	bra.s		.dcod
.copy	neg.w		d1
	subq		#1,d1
	bmi.s		.err
.clp	move.w	(a0)+,(a1)+
	subq		#1,d6
	beq.s		.line
	dbra		d1,.clp
	bra.s		.dcod
.line	add.w		FLC_LineWidth,a2
	move.l	a2,a1
	dbra		d7,.vert
.err	rts

FLI_COPY:
	move.l	CHUNK_PTR,a0
	addq		#6,a0
	move.l	FLC_ANIMBUFFER,a1
	move.w	FLC_Depth,d2
	cmp.b		#16,d2
	beq.s		.b16
	cmp.b		#24,d2
	beq.s		.b24
.b08:	moveq		#0,d3
	move.w	FLC_ScrWidth,d3
	moveq		#0,d4
	move.w	FLC_LineWidth,d4
	moveq		#0,d1
	move.w	FLC_ScrHeight,d7
	subq.w	#1,d7
	move.l	d3,d5
	subq.w	#1,d5
.ylp:	move.l	a1,a2
	move.w	d5,d6
.xlp:	move.b	(a0)+,(a2)+
	dbra		d6,.xlp
	add.l		d4,a1
	dbra		d7,.ylp	
	rts
.b16:	move.w	FLC_ScrWidth,d5
	moveq		#0,d4
	move.w	FLC_LineWidth,d4
	subq.w	#1,d5
	move.w	FLC_ScrHeight,d7
	subq.w	#1,d7
.yl2:	move.l	a1,a2
	move.w	d5,d6
.xl2:	move.w	(a0)+,(a2)+
	dbra		d6,.xl2
	add.l		d4,a1
	dbra		d7,.yl2
	rts
.b24:	move.w	FLC_ScrWidth,d5
	moveq		#0,d4
	move.w	FLC_LineWidth,d4
	subq.w	#1,d5
	move.w	FLC_ScrHeight,d7
	subq.w	#1,d7
.yl3:	move.l	a1,a2
	move.w	d5,d6
.xl3:	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	bfins		d1,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d3,d0{27:8}
	move.w	d0,(a2)+
	dbra		d6,.xl3
	add.l		d4,a1
	dbra		d7,.yl3	
	rts

FLI_PSTAMP:
	rts

FLI_PRUN:
	cmp.w		#16,FLC_Depth
	beq		FLI_PRUN_16
	cmp.w		#24,FLC_Depth
	beq		FLI_PRUN_24
PRUN_error:
	rts

FLI_PRUN_24:
	move.l	CHUNK_PTR,a0
	addq		#6,a0
	move.l	FLC_ANIMBUFFER,a1
	move.l	a1,a2
	move.w	FLC_ScrHeight,d7
	subq		#1,d7
	bmi.s		.err
.vert	move.w	FLC_ScrWidth,d6
	addq		#1,a0
.dcod	move.b	(a0)+,d1
	ext.w		d1
	bmi.s		.copy
.run	subq		#1,d1
	bmi.s		.err
	move.b	(a0)+,d3
	move.b	(a0)+,d4
	move.b	(a0)+,d5
	bfins		d3,d2{16:8}
	bfins		d4,d2{21:8}
	bfins		d5,d2{27:8}
.rlp	move.w	d2,(a1)+
	subq		#1,d6
	beq.s		.line
	dbra		d1,.rlp
	bra.s		.dcod
.copy	neg.w		d1
	subq		#1,d1
	bmi.s		.err
.clp	move.b	(a0)+,d3
	move.b	(a0)+,d4
	move.b	(a0)+,d5
	bfins		d3,d2{16:8}
	bfins		d4,d2{21:8}
	bfins		d5,d2{27:8}
	move.w	d2,(a1)+
	subq		#1,d6
	beq.s		.line
	dbra		d1,.clp
	bra.s		.dcod
.line	add.w		FLC_LineWidth,a2
	move.l	a2,a1
	dbra		d7,.vert
.err	rts

FLI_PSS2:
	cmp.w		#16,FLC_Depth
	beq		FLI_PSS2_16
	cmp.w		#24,FLC_Depth
	beq		FLI_PSS2_24
PSS2_error:
	rts

FLI_PSS2_16:
	move.l	CHUNK_PTR,a0
	addq		#6,a0
	move.l	FLC_ANIMBUFFER,a1
	move.l	a1,a2
	movw		(a0)+,d7
	subq		#1,d7
	bmi.s		.err
.look	move.w	(a0)+,d0
	ror.w		#8,d0
	tst.w		d0
	bmi.s		.code
	subq		#1,d0
	bmi.s		.err
	bra.s		.dcod
.code	move.w	d0,d1
	and.w		#%01000000<<8,d1
	beq.s		.look			; invalid code (can't have half-pixels)
.vgap	neg.w		d0			; vertical gap
	mulu		FLC_LineWidth,d0
	add.l		d0,a2
	move.l	a2,a1
	bra.s		.look
.dcod	moveq		#0,d1
	move.b	(a0)+,d1
	lea		(a1,d1.w*2),a1	; skip d1 pixels
	move.b	(a0)+,d1
	ext.w		d1
	bpl.s		.copy
.run	neg.w		d1
	subq		#1,d1
	move.w	(a0)+,d2
.rlp	move.w	d2,(a1)+
	dbra		d1,.rlp
	bra.s		.line
.copy	subq		#1,d1
	bmi.s		.line
.clp	move.w	(a0)+,(a1)+
	dbra		d1,.clp
.line	dbra		d0,.dcod
.next	add.w		FLC_LineWidth,a2
	move.l	a2,a1
	dbra		d7,.look
.err	rts

FLI_PSS2_24:
	move.l	CHUNK_PTR,a0
	addq		#6,a0
	move.l	FLC_ANIMBUFFER,a1
	move.l	a1,a2
	movw		(a0)+,d7
	subq		#1,d7
	bmi.s		.err
.look	move.w	(a0)+,d0
	ror.w		#8,d0
	tst.w		d0
	bmi.s		.code
	subq		#1,d0
	bmi.s		.err
	bra.s		.dcod
.code	move.w	d0,d1
	and.w		#%01000000<<8,d1
	beq.s		.look			; invalid code (can't have half-pixels)
.vgap	neg.w		d0			; vertical gap
	mulu		FLC_LineWidth,d0
	add.l		d0,a2
	move.l	a2,a1
	bra.s		.look
.dcod	moveq		#0,d1
	move.b	(a0)+,d1
	lea		(a1,d1.w*2),a1	; skip d1 pixels
	move.b	(a0)+,d1
	ext.w		d1
	bpl.s		.copy
.run	neg.w		d1
	subq		#1,d1
	move.b	(a0)+,d3
	move.b	(a0)+,d4
	move.b	(a0)+,d5
	bfins		d3,d2{16:8}
	bfins		d4,d2{21:8}
	bfins		d5,d2{27:8}
.rlp	move.w	d2,(a1)+
	dbra		d1,.rlp
	bra.s		.line
.copy	subq		#1,d1
	bmi.s		.line
.clp	move.b	(a0)+,d3
	move.b	(a0)+,d4
	move.b	(a0)+,d5
	bfins		d3,d2{16:8}
	bfins		d4,d2{21:8}
	bfins		d5,d2{27:8}
	move.w	d2,(a1)+
	dbra		d1,.clp
.line	dbra		d0,.dcod
.next	add.w		FLC_LineWidth,a2
	move.l	a2,a1
	dbra		d7,.look
.err	rts
	
*--------------------------------------------------------------------------*
			BSS
*--------------------------------------------------------------------------*

CHUNK_PTR:		ds.l	1
FLC_Stack:		ds.l	1
FLC_Handle:		ds.w	1
FLC_MoreToCome:	ds.b	1
FLC_ChangeMade:	ds.b	1
			even

FLC_FileSize:	ds.l	1
FLC_Magic:		ds.w	1
FLC_ReadCount:	ds.w	1
FLC_Frames:		ds.w	1
FLC_LineWidth:	ds.w	1
FLC_ScrWidth:	ds.w	1
FLC_ScrHeight:	ds.w	1
FLC_Flags:		ds.w	1
FLC_Speed:		ds.l	1
FLC_XAspect:	ds.w	1
FLC_YAspect:	ds.w	1
FLC_Frame1:		ds.l	1
FLC_Frame2:		ds.l	1
FLC_FrameSize:	ds.l	1
FLC_ColPacks:	ds.w	1
FLC_ChunkType:	ds.w	1
FLC_ChunkSize:	ds.l	1
FLC_Chunks:		ds.w	1
FLC_Depth:		ds.w	1

FLC_FILEHANDLE:	ds.w	1
FLC_FILEBUFFER:	ds.l	1
FLC_ANIMBUFFER:	ds.l	1
FLC_SCREEN:		ds.l	1


*--------------------------------------------------------------------------*
			TEXT
*--------------------------------------------------------------------------*
