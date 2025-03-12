
*--------------------------------------------------------------------------*

CREATE_FLIC:
	move.l	PACK_SCR,FLC_FILEBUFFER
	move.l	sp,FLC_Stack
	jsr		CreateFile
	move.w	d0,FLC_Handle
	bpl.s		Create_FLC_FileHeader
	moveq		#-1,d0
	rts
	
Create_FLC_FileHeader:
	clr.w		FLC_ReadCount
	st		use_brun
	st		changed
	move.l	FLC_FILEBUFFER,a0
	clr.l		FLC_FH_FileSize(a0)
	movw		FLC_Frames,FLC_FH_Frames(a0)
	movw		CUT_WIDTH,FLC_FH_ScrWid(a0)
	movw		CUT_HEIGHT,FLC_FH_ScrHig(a0)
	movw		#FLC_MAGIC,FLC_FH_Magic(a0)
	movw		#8,FLC_FH_Depth(a0)
	tst.b		TRUE_FLAG
	beq.s		.ntc
	movw		#FLH_MAGIC2,FLC_FH_Magic(a0)
	movw		#16,FLC_FH_Depth(a0)
.ntc	clr.w		FLC_FH_Flags(a0)
	moveq		#1,d2
	add.w		CURRENT_TIME,d2
	mulu.w	ms,d2
	movl		d2,FLC_FH_Speed(a0)
	clr.w		FLC_FH_Pad1(a0)
	move.l	#$D2C1812F,FLC_FH_Created(a0)
	move.l	#'APEX',FLC_FH_Creator(a0)
	move.l	#$D2C1812F,FLC_FH_Updated(a0)
	move.l	#'APEX',FLC_FH_Updator(a0)
	movw		#1,FLC_FH_XAspect(a0)
	movw		#1,FLC_FH_YAspect(a0)
	moveq		#(38/2)-1,d0
	lea		FLC_FH_Pad2(a0),a1
.clr2	clr.w		(a1)+
	dbra		d0,.clr2
	movl		#FLC_FH_Length,FLC_FH_Frame1(a0)
	movl		#FLC_FH_Length,FLC_FH_Frame2(a0)
	moveq		#(40/2)-1,d0
	lea		FLC_FH_Pad3(a0),a1
.clr3	clr.w		(a1)+
	dbra		d0,.clr3
	move.l	FLC_FILEBUFFER,a0
	move.w	FLC_Handle,d0
	move.l	#FLC_FH_Length,d1
	jsr		WriteFile
	tst.l		d0
	bmi		FLC_Error
	move.l	#FLC_FH_Length,FLCFILE_SIZE
	rts	

*-----------------------------------------------*
UPDATE_FLC:
*-----------------------------------------------*
	move.w	FLC_Handle,d0
	ble		.done
*-----------------------------------------------*
	move.l	PACK_SCR,a0
	movl		FLCFILE_SIZE,(a0)
	move.w	FLC_Handle,d0
	moveq		#4,d1
	moveq		#FLC_FH_FileSize,d2
	jsr		PatchFile
*-----------------------------------------------*
	move.l	PACK_SCR,a0
	movw		#$0003,(a0)
	move.w	FLC_Handle,d0
	moveq		#2,d1
	moveq		#FLC_FH_Flags,d2
	jsr		PatchFile
*-----------------------------------------------*
	move.l	PACK_SCR,a0
	movl		FLC_Frame1,(a0)
	move.w	FLC_Handle,d0
	moveq		#4,d1
	moveq		#FLC_FH_Frame1,d2
	jsr		PatchFile
*-----------------------------------------------*
	move.l	PACK_SCR,a0
	movl		FLC_Frame2,(a0)
	move.w	FLC_Handle,d0
	moveq		#4,d1
	moveq		#FLC_FH_Frame2,d2
	jsr		PatchFile
*-----------------------------------------------*
	move.w	FLC_Handle,d0
	jsr		CloseFile
.done	clr.w		FLC_Handle
	rts

*-----------------------------------------------*
WRITE_FLIC_FRAME:
*-----------------------------------------------*
*	Search for first and second frames		*
*-----------------------------------------------*
	addq		#1,FLC_ReadCount
	cmp.w		#1,FLC_ReadCount
	bne.s		.nff
	move.l	FLCFILE_SIZE,FLC_Frame1
.nff	cmp.w		#2,FLC_ReadCount
	bne.s		.nsf
	move.l	FLCFILE_SIZE,FLC_Frame2
*-----------------------------------------------*
*	Create filebuffer for frame-chunk		*
*-----------------------------------------------*
.nsf	move.w	CUT_WIDTH,d0
	mulu.w	CUT_HEIGHT,d0
	tst.b		TRUE_FLAG
	beq.s		.tr
	add.l		d0,d0
.tr:	move.l	d0,d1
	lsr.l		#3,d1
	add.l		d1,d0
	add.l		#8192,d0
	jsr		Add_fast
	tst.l		d0
	bmi		FLC_Error
	move.w	d0,FLC_blockhandle
	jsr		Find_block
	move.l	a0,FLC_FILEBUFFER
*-----------------------------------------------*
*	Create frame-chunk header			*
*-----------------------------------------------*
	move.l	#FLC_FC_Length,FLCFRAME_SIZE
	move.l	FLC_FILEBUFFER,a0
	movw		#FRAME_MAGIC,FLC_FC_Type(a0)
	moveq		#(8/2)-1,d0
	lea		FLC_FC_Pad1(a0),a1
.clr1	clr.w		(a1)+
	dbra		d0,.clr1
	lea		FLC_FC_Length(a0),a0
	move.l	a0,CHUNK_PTR
	clr.w		FLC_Chunks
*-----------------------------------------------*
*	Create image-chunks				*
*-----------------------------------------------*
	tst.b		TRUE_FLAG
	bne.s		.npal
	jsr		Create_color_chunk
	lea		COLOURS,a0
	lea		PALETTE_COPY,a1
	jsr		COPYCOLS
.npal	jsr		Create_image_chunk
*-----------------------------------------------*
*	Update chunk header and add to filesize	*
*-----------------------------------------------*
	move.l	FLCFRAME_SIZE,d1
	move.l	FLC_FILEBUFFER,a0
	movl		d1,FLC_FC_Size(a0)	; store framesize in frame-header
	add.l		d1,FLCFILE_SIZE		; add framesize to filesize
	movw		FLC_Chunks,FLC_FC_Chunks(a0)
*-----------------------------------------------*
*	Write entire buffer out to disk		*
*-----------------------------------------------*
	move.l	FLC_FILEBUFFER,a0
	move.w	FLC_Handle,d0
	move.l	FLCFRAME_SIZE,d1
	jsr		WriteFile
*-----------------------------------------------*
*	Tidy buffers					*
*-----------------------------------------------*
	push.l	d0
	move.w	FLC_blockhandle,d0
	jsr		Remove_block
	pop.l		d0
	tst.l		d0
	bmi		FLC_Error
	rts

*-----------------------------------------------*
Create_image_chunk:
*-----------------------------------------------*
	move.l	CHUNK_PTR,a2
	lea		6(a2),a2
	jsr		Compress_FLC_frame
*-----------------------------------------------*
	tst.b		changed
	beq.s		.rts
	move.l	compressed_size,d1
	addq.l	#6,d1
	add.l		d1,FLCFRAME_SIZE
	move.l	CHUNK_PTR,a0
	move.l	d1,d2
	movl		d1,(a0)
	add.l		d2,a0
	move.l	a0,CHUNK_PTR
.rts	rts
		
*-----------------------------------------------*
Compress_FLC_frame:
*-----------------------------------------------*
	tst.b		use_brun
	beq		Use_SS2

*-----------------------------------------------*
Use_BRUN:
*-----------------------------------------------*
	sf		use_brun
*-----------------------------------------------*
	tst.b		TRUE_FLAG
	bne		.true
*-----------------------------------------------*
	pushall
*-----------------------------------------------*
*	Convert BPL strip into BPP format		*
*-----------------------------------------------*
	move.l	LOG_SCR,a0
	move.w	CUT_Y,d0
	mulu.w	CANVAS_WIDTH,d0
	add.l		d0,a0
	move.w	CANVAS_WIDTH,d0
	move.w	CUT_HEIGHT,d1
	jsr		BPS2BytePerPixel
*-----------------------------------------------*
	lea		COLOURS,a0
	lea		PALETTE_COPY,a1
	jsr		COPYCOLS
	lea		PALETTE_COPY,a0
	move.w	#256-1,d0
.not	not.l		(a0)+
	dbra		d0,.not
*-----------------------------------------------*
	popall
*-----------------------------------------------*
	move.l	LOG_SCR,a0
	move.w	CUT_Y,d2
	mulu.w	CANVAS_WIDTH,d2
	add.l		d2,a0
	add.w		CUT_X,a0
	move.l	a2,a1
	push.l	a1
*-----------------------------------------------*
	move.w	CUT_HEIGHT,d2
	subq.w	#1,d2
.ylp	move.w	CUT_WIDTH,d5
	clr.b		(a1)+
	push.l	a0
	bsr		compress_bytes
	pop.l		a0
	add.w		CANVAS_WIDTH,a0
	dbra		d2,.ylp
*-----------------------------------------------*
	move.w	#15,chunk_id
	bra.s		.done
*-----------------------------------------------*
.true	move.l	LOG_SCR,a0
	move.w	CUT_Y,d2
	mulu.w	CANVAS_WIDTH,d2
	add.l		d2,d2
	add.l		d2,a0
	add.w		CUT_X,a0
	add.w		CUT_X,a0
	move.l	a2,a1
	push.l	a1
*-----------------------------------------------*
	move.w	CUT_HEIGHT,d2
	subq		#1,d2
.ylp2	move.w	CUT_WIDTH,d5
	clr.b		(a1)+
	push.l	a0
	bsr		compress_words
	pop.l		a0
	add.w		CANVAS_WIDTH,a0
	add.w		CANVAS_WIDTH,a0
	dbra		d2,.ylp2
*-----------------------------------------------*
	move.w	#25,chunk_id
*-----------------------------------------------*
.done	move.l	a1,d1
	sub.l		(sp)+,d1
	move.l	d1,compressed_size
	move.w	CUR_DELTAFRAME,last_delta
	move.l	CHUNK_PTR,a2
	movw		chunk_id,4(a2)
	addq		#1,FLC_Chunks
	st		changed
	rts	

*-----------------------------------------------*
Use_SS2:
*-----------------------------------------------*
	pushall
*-----------------------------------------------*
	move.w	last_delta,d0
	jsr		Update_position
	jsr		COPY_FRAME_2_LOG
	move.l	LOG_SCR,delta_source_2
*-----------------------------------------------*
	move.w	CUR_DELTAFRAME,d0
	jsr		Update_position
	move.l	FRAME_SCR,delta_source_1
*-----------------------------------------------*
	tst.b		TRUE_FLAG
	bne.s		.truemode
*-----------------------------------------------*
	jsr		COPY_FRAME_2_PACK
	move.l	PACK_SCR,delta_source_1
*-----------------------------------------------*
	move.l	LOG_SCR,a0
	move.w	CANVAS_WIDTH,d0
	move.w	CANVAS_HEIGHT,d1
	jsr		BPS2BytePerPixel
*-----------------------------------------------*
	move.l	PACK_SCR,a0
	move.w	CANVAS_WIDTH,d0
	move.w	CANVAS_HEIGHT,d1
	jsr		BPS2BytePerPixel
*-----------------------------------------------*
.truemode:
*-----------------------------------------------*
	popall
*-----------------------------------------------*
	move.w	CUT_Y,d6
	mulu.w	CANVAS_WIDTH,d6
	move.w	CUT_X,d7
	ext.l		d7
	add.l		d7,d6
	tst.b		TRUE_FLAG
	beq.s		.nt
	add.l		d6,d6
.nt:	move.l	delta_source_2,a1	; old sourcedata
	move.l	delta_source_1,a0	; new sourcedata
	add.l		d6,a0
	add.l		d6,a1
*-----------------------------------------------*
	move.l	a2,line_counter
	clr.w		(a2)+			; clear line count
	moveq		#0,d6			; reset line-skip counter
*-----------------------------------*
	move.w	CUT_HEIGHT,d7
	subq.w	#1,d7			; scanlines to compress
*-----------------------------------*
.ylp	move.w	CUT_WIDTH,d0
	tst.b		TRUE_FLAG
	bne.s		.ytc
	lsr.w		#1,d0
.ytc:	subq.w	#1,d0
	move.l	a0,a5
	move.l	a1,a6
.chkl	move.w	(a5)+,d1
	cmp.w		(a6)+,d1
	bne.s		.used
	dbra		d0,.chkl
	addq.w	#1,d6
	bra		.cont
*-----------------------------------*
.used	tst.w		d6
	beq.s		.nskp			; check for skipped lines
	neg.w		d6
	ror.w		#8,d6
	move.w	d6,(a2)+		; store skip-count
*-----------------------------------*
.nskp	pea		(a0)
	pea		(a1)
	push.w	d7
	move.w	CUT_WIDTH,d0	; delta-words to crunch
	tst.b		TRUE_FLAG
	bne		.true

;	move.l	a0,a5
;	lea		buffer24k_1,a6
;	jsr		bpline2bytepixel
;	move.l	a1,a5
;	lea		buffer24k_2,a6
;	jsr		bpline2bytepixel
;	lea		buffer24k_1,a0
;	lea		buffer24k_2,a1
;	move.w	CUT_WIDTH,d0	; delta-words to crunch

	lsr.w		d0

.true	bsr		compress_FLI_SS2	; compress scanline
	pop.w		d7
	pop.l		a1
	pop.l		a0
	addq.w	#1,([line_counter.l])
	moveq		#0,d6
*-----------------------------------*
.cont	move.w	logwid,a3
	add.l		a3,a0
	add.l		a3,a1
	dbra		d7,.ylp
*-----------------------------------*
.stop	move.l	a2,d1
	move.l	line_counter,a2
	sub.l		a2,d1
	move.l	d1,compressed_size
	sf		changed
	move.w	(a2),d1
	ror.w		#8,d1
	move.w	d1,(a2)
	beq.s		.none	
	move.l	CHUNK_PTR,a2
	movw		#7,4(a2)
	tst.b		TRUE_FLAG
	beq.s		.bpl
	movw		#27,4(a2)
.bpl	addq		#1,FLC_Chunks
	st		changed
.none	move.w	CUR_DELTAFRAME,last_delta
	rts

	rept		0

bpline2bytepixel:
	move.w	CUT_WIDTH,d7
	lsr.w		#4,d7
	subq		#1,d7
.wlp	move.l	(a5)+,d5	; planes 1 & 2
	move.l	(a5)+,d4	; planes 3 & 4
	move.l	(a5)+,d3	; planes 5 & 6
	move.l	(a5)+,d2	; planes 7 & 8
	move.l	d2,d0
	or.l		d3,d0
	or.l		d4,d0
	or.l		d5,d0
	bne.s		.nz
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	bra.s		.olp
.nz	moveq		#16-1,d0
.blp	add.w		d2,d2		; plane 8
	addx.b	d1,d1
	swap		d2
	add.w		d2,d2		; plane 7
	addx.b	d1,d1
	swap		d2
	add.w		d3,d3		; plane 6
	addx.b	d1,d1
	swap		d3
	add.w		d3,d3		; plane 5
	addx.b	d1,d1
	swap		d3
	add.w		d4,d4		; plane 4
	addx.b	d1,d1
	swap		d4
	add.w		d4,d4		; plane 3
	addx.b	d1,d1
	swap		d4
	add.w		d5,d5		; plane 2
	addx.b	d1,d1
	swap		d5
	add.w		d5,d5		; plane 1
	addx.b	d1,d1
	swap		d5
	move.b	d1,(a6)+
	dbra		d0,.blp
.olp	dbra		d7,.wlp
	clr.l		(a6)
	rts

	endr

*-----------------------------*
compress_bytes:			*
*-----------------------------*
	moveq		#0,d4
	moveq		#127,d1	; max packet-size
	subq		#1,d5		; dbf-adjust
	bmi.s		.stop
	move.b	(a0)+,d7	; initial byte
.restart				; need 3 similar bytes to merit a run
	move.l	a0,a3
	cmp.b		(a3)+,d7
	bne.s		.init_copy
	cmp.b		(a3)+,d7
	bne.s		.init_copy
.init_run:
	moveq		#1,d6		; initial byte-count
.run	move.b	(a0)+,d0
	cmp.w		d1,d6
	beq.s		.end_run
	cmp.b		d0,d7
	bne.s		.end_run
	addq		#1,d6
	dbra		d5,.run
.stop_run:
	move.b	d6,(a1)+	; store code
	move.b	d7,(a1)+	; store byte
	addq		#1,d4
	bra.s		.stop
.end_run:
	move.b	d6,(a1)+	; store code
	move.b	d7,(a1)+	; store byte
	addq		#1,d4
	move.b	d0,d7		; new initial byte			
	dbra		d5,.restart
	bra.s		.stop
.init_copy:
	move.l	a1,a2
	addq		#1,a1		; skip code
	moveq		#0,d6
	move.b	d7,d0
	bra.s		.keep
.copy	move.b	(a0)+,d0
	cmp.w		d1,d6
	beq.s		.end_copy
	move.l	a0,a3
	cmp.b		(a3)+,d0	; need 4 similar bytes to interrupt copy
	bne.s		.keep
	cmp.b		(a3)+,d0
	bne.s		.keep
	cmp.b		(a3)+,d0
	beq.s		.end_copy
.keep	move.b	d0,(a1)+
	addq		#1,d6
	dbra		d5,.copy
.stop_copy:
	neg.w		d6		; create code
	move.b	d6,(a2)	; store code
	addq		#1,d4
	bra.s		.stop
.end_copy
	neg.w		d6		; create code
	move.b	d6,(a2)	; store code
	addq		#1,d4
	move.b	d0,d7		; new initial byte
	bra.s		.restart
.stop	rts

*-----------------------------*
compress_words:			*
*-----------------------------*
	moveq		#0,d4
	moveq		#127,d1	; max packet-size
	subq		#1,d5		; dbf-adjust
	bmi.s		.stop
	move.w	(a0)+,d7	; initial byte
.restart
	move.l	a0,a3
	cmp.w		(a3)+,d7	; initial type-check
	bne.s		.init_copy
	cmp.w		(a3)+,d7
	bne.s		.init_copy
.init_run:
	moveq		#1,d6		; initial byte-count
.run	move.w	(a0)+,d0
	cmp.w		d1,d6
	beq.s		.end_run
	cmp.w		d0,d7
	bne.s		.end_run
	addq		#1,d6
	dbra		d5,.run
.stop_run:
	move.b	d6,(a1)+	; store code
	move.w	d7,(a1)+	; store byte
	addq		#1,d4
	bra.s		.stop
.end_run:
	move.b	d6,(a1)+	; store code
	move.w	d7,(a1)+	; store byte
	addq		#1,d4
	move.w	d0,d7		; new initial byte			
	dbra		d5,.restart
	bra.s		.stop
.init_copy:
	move.l	a1,a2
	addq		#1,a1		; skip code
	moveq		#0,d6
	move.w	d7,d0
	bra.s		.keep
.copy	move.w	(a0)+,d0
	cmp.w		d1,d6
	beq.s		.end_copy
	move.l	a0,a3
	cmp.w		(a3)+,d0
	bne.s		.keep
	cmp.w		(a3)+,d0
	bne.s		.keep
	cmp.w		(a3)+,d0
	beq.s		.end_copy
.keep	move.w	d0,(a1)+
	addq		#1,d6
	dbra		d5,.copy
.stop_copy:
	neg.w		d6		; create code
	move.b	d6,(a2)	; store code
	addq		#1,d4
	bra.s		.stop
.end_copy
	neg.w		d6		; create code
	move.b	d6,(a2)	; store code
	addq		#1,d4
	move.w	d0,d7		; new initial byte
	bra.s		.restart
.stop	rts

maxpack	=	127

*-----------------------------*
compress_FLI_SS2:			*
*-----------------------------*
*	a0 = new data		*
*	a1 = old data		*
*	a2 = destination		*
*	d0 = words to compress	*
*-----------------------------*
	tst.b		TRUE_FLAG
	bne		compress_FLI_PSS2
	move.l	a2,a4
	clr.w		(a4)+
	moveq		#maxpack,d1	; max packet-size
	subq		#1,d0
*-----------------------------*
.find_skip
*-----------------------------*
	moveq		#0,d6		; current skip-count
.srch	cmp.w		#254,d6
	beq.s		.maxi
	move.w	(a0)+,d7	; word from new source
	cmp.w		(a1)+,d7	; word from old source
	bne.s		.different
	addq		#2,d6
	dbra		d0,.srch
	bra		.exit
*-----------------------------*
.different
*-----------------------------*
	subq.l	#2,a0
	subq.l	#2,a1
.maxi	move.b	d6,(a4)+	; store skip-count
	addq		#1,(a2)	; increment packet-count
*-----------------------------*
.find_type
*-----------------------------*
	move.w	(a0),d7
	tst.w		d0
	ble.s		.init_copy	; too near end for run-check
	cmp.w		2(a0),d7
	bne.s		.init_copy
*-----------------------------*
.init_run:
*-----------------------------*
	moveq		#0,d6		; initial byte-count
	move.w	(a0)+,d5
	addq.l	#2,a1
	bra.s		.sr
.run	move.w	(a0)+,d5
	cmp.w		(a1)+,d5
	bne.s		.sr
	tst.w		d0
	ble.s		.sr
	move.w	(a0),d4
	cmp.w		(a1),d4
	bne.s		.sr
	cmp.w		#1,d0
	ble.s		.sr
	move.w	2(a0),d4
	cmp.w		2(a1),d4
	beq.s		.term_run	
.sr	cmp.w		d1,d6
	beq.s		.term_run
	cmp.w		d5,d7
	bne.s		.term_run
	addq		#1,d6
	dbra		d0,.run
	neg.w		d6		; create code
	move.b	d6,(a4)+	; store code
	move.w	d7,(a4)+	; store word
	bra.s		.exit
*-----------------------------*
.term_run
*-----------------------------*
	subq.l	#2,a0	
	subq.l	#2,a1
	neg.w		d6		; create code
	move.b	d6,(a4)+	; store code
	move.w	d7,(a4)+	; store word
	bra.s		.find_skip
*-----------------------------*
.init_copy:
*-----------------------------*
	moveq		#0,d6
	move.l	a4,a6
	addq.l	#1,a4		; skip code
	move.w	(a0)+,d5
	addq.l	#2,a1
	bra.s		.sc
.copy	move.w	(a0)+,d5
	cmp.w		(a1)+,d5	; check against delta
	beq.s		.term_copy
.sc	cmp.w		d1,d6
	beq.s		.term_copy
	tst.w		d0		; too near end for run-check
	ble.s		.cont
	cmp.w		(a0),d5
	bne.s		.cont		; check for run
	cmp.w		#1,d0		; too near end for run-check
	ble.s		.cont
	cmp.w		2(a0),d5
	bne.s		.cont		; check for run
	cmp.w		#2,d0		; too near end for run-check
	ble.s		.cont
	cmp.w		4(a0),d5
	beq.s		.term_copy	; check for run
.cont	move.w	d5,(a4)+
	addq		#1,d6
	dbra		d0,.copy
	move.b	d6,(a6)	; store code
	bra.s		.exit
*-----------------------------*
.term_copy
*-----------------------------*
	subq.l	#2,a0
	subq.l	#2,a1
	move.b	d6,(a6)	; store code
	bra		.find_skip
*-----------------------------*
.exit	move.w	(a2),d1
	ror.w		#8,d1
	move.w	d1,(a2)
	move.l	a4,a2
	rts

*-----------------------------*
compress_FLI_PSS2:		*
*-----------------------------*
*	a0 = new data		*
*	a1 = old data		*
*	a2 = destination		*
*	d0 = words to compress	*
*-----------------------------*
	move.l	a2,a4
	clr.w		(a4)+
	moveq		#maxpack,d1	; max packet-size
	subq		#1,d0
*-----------------------------*
.find_skip
*-----------------------------*
	moveq		#0,d6		; current skip-count
.srch	cmp.w		#255,d6
	beq.s		.maxi
	move.w	(a0)+,d7	; word from new source
	cmp.w		(a1)+,d7	; word from old source
	bne.s		.different
	addq		#1,d6
	dbra		d0,.srch
	bra		.exit
*-----------------------------*
.different
*-----------------------------*
	subq.l	#2,a0
	subq.l	#2,a1
.maxi	move.b	d6,(a4)+	; store skip-count
	addq		#1,(a2)	; increment packet-count
*-----------------------------*
.find_type
*-----------------------------*
	move.w	(a0),d7
	tst.w		d0
	ble.s		.init_copy	; too near end for run-check
	cmp.w		2(a0),d7
	bne.s		.init_copy
*-----------------------------*
.init_run:
*-----------------------------*
	moveq		#0,d6		; initial word-count
	move.w	(a0)+,d5
	addq.l	#2,a1
	bra.s		.sr
.run	move.w	(a0)+,d5
	cmp.w		(a1)+,d5
	bne.s		.sr
	tst.w		d0
	ble.s		.sr
	move.w	(a0),d4
	cmp.w		(a1),d4
	bne.s		.sr
	cmp.w		#1,d0
	ble.s		.sr
	move.w	2(a0),d4
	cmp.w		2(a1),d4
	beq.s		.term_run	
.sr	cmp.w		d1,d6
	beq.s		.term_run
	cmp.w		d5,d7
	bne.s		.term_run
	addq		#1,d6
	dbra		d0,.run
	neg.w		d6		; create code
	move.b	d6,(a4)+	; store code
	move.w	d7,(a4)+	; store word
	bra.s		.exit
*-----------------------------*
.term_run
*-----------------------------*
	subq.l	#2,a0	
	subq.l	#2,a1
	neg.w		d6		; create code
	move.b	d6,(a4)+	; store code
	move.w	d7,(a4)+	; store word
	bra.s		.find_skip
*-----------------------------*
.init_copy:
*-----------------------------*
	moveq		#0,d6
	move.l	a4,a6
	addq.l	#1,a4		; skip code
	move.w	(a0)+,d5
	addq.l	#2,a1
	bra.s		.sc
.copy	move.w	(a0)+,d5
	cmp.w		(a1)+,d5	; check against delta
	beq.s		.term_copy
.sc	cmp.w		d1,d6
	beq.s		.term_copy
	tst.w		d0		; too near end for run-check
	ble.s		.cont
	cmp.w		(a0),d5
	bne.s		.cont		; check for run
	cmp.w		#1,d0		; too near end for run-check
	ble.s		.cont
	cmp.w		2(a0),d5
	bne.s		.cont		; check for run
	cmp.w		#2,d0		; too near end for run-check
	ble.s		.cont
	cmp.w		4(a0),d5
	beq.s		.term_copy	; check for run
.cont	move.w	d5,(a4)+
	addq		#1,d6
	dbra		d0,.copy
	move.b	d6,(a6)	; store code
	bra.s		.exit
*-----------------------------*
.term_copy
*-----------------------------*
	subq.l	#2,a0
	subq.l	#2,a1
	move.b	d6,(a6)	; store code
	bra		.find_skip
*-----------------------------*
.exit	move.w	(a2),d1
	ror.w		#8,d1
	move.w	d1,(a2)
	move.l	a4,a2
	rts

*-----------------------------------------------*
Create_color_chunk:
*-----------------------------------------------*
	move.l	CHUNK_PTR,a2
	lea		6(a2),a2
	jsr		Compress_FLC_colors
*-----------------------------------------------*
	tst.b		changed
	beq.s		.rts
	move.l	compressed_size,d1
	addq.l	#6,d1
	add.l		d1,FLCFRAME_SIZE
	move.l	CHUNK_PTR,a0
	move.l	d1,d2
	movl		d1,(a0)
	add.l		d2,a0
	move.l	a0,CHUNK_PTR
.rts	rts

*-----------------------------------------------*
Compress_FLC_colors:
*-----------------------------------------------*
	sf		changed
	clr.l		compressed_size
	lea		COLOURS,a0
	lea		PALETTE_COPY,a1
	cmp.w		#1,FLC_ReadCount
	beq.s		.chng
	move.w	#256-1,d1
	move.l	a0,a5
	move.l	a1,a6
.look	move.l	(a5)+,d3
	move.l	(a6)+,d4
	and.l		COLMASK,d3
	and.l		COLMASK,d4
	cmp.l		d3,d4
	bne.s		.chng
	dbra		d1,.look
	rts
.chng	move.w	#$0100,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.w	#256-1,d0
.copy	addq.l	#1,a0
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	dbra		d0,.copy
	move.l	#(256*3)+4,compressed_size
	move.l	CHUNK_PTR,a2
	movw		#4,4(a2)
	addq		#1,FLC_Chunks
	st		changed
	rts	

*-----------------------------------------------*

delta_source_1:	ds.l	1
delta_source_2:	ds.l	1

line_counter:	ds.l	1
compressed_size:	ds.l	1
FLC_blockhandle:	ds.w	1

FLCFRAME_SIZE:	ds.l	1
FLCFILE_SIZE:	ds.l	1

chunk_id:		ds.w	1
last_delta:		ds.w	1

changed:		ds.b	1
use_brun:		ds.b	1
			even

