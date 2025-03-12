*-----------------------------------------------------------------------*
*	Unpack 'GIF' rasterfile : 68000 code by Douglas Little / BS		*
*-----------------------------------------------------------------------*

			rsreset
GIF_Palette_LEN	rs.b	32
GIF_ConvCols_LEN	rs.b	512
GIF_ConvTable_LEN	rs.b	256
GIF_ColourMap_LEN	rs.b	1024
GIF_CodeTable_LEN	rs.b	24576
GIF_Workspace	rs.b	0

GIF_CTSize		=	8192

*-----------------------------------------------------------------------*
*	Pass the address of a buffer of size 'GIF_Workspace' bytes in 'a0'
*	and call the routine 'INIT_GIFTABLES'. (a 32k buffer is fine)
*-----------------------------------------------------------------------*
*	Call the routine 'EXAMINE_GIF' if you wish to extract the info
*	on image height/width/cols before loading. This is optional.
*-----------------------------------------------------------------------*
*	Inputs... (all these labels are pointers, not buffer addresses)
*-----------------------------------------------------------------------*
*	FILENAME_PTR.l		=	GIF filename, terminate with a zero
*	PALETTE_PTR.l		=	place to put $00:RR:GG:BB colours
*	GIF_Unpack_buffer.l	=	image buffer. bytes=(width*height)+1024
*-----------------------------------------------------------------------*
*	Extra inputs required...
*-----------------------------------------------------------------------*
*	GIF_Load_buffer.l		=	temporary file-buffer (above 1k)
*	GIF_Loadsize.l		=	size of the above buffer in bytes
*	COLMASK.l			=	$00:FF:FF:FF colour-mask (for clipping)
*-----------------------------------------------------------------------*
*	Outputs...
*-----------------------------------------------------------------------*
*	GIF_Rawdata.l		=	address of image in image buffer
*	GIF_Colours.w		=	number of colours in image
*	GIF_Width.w			=	width
*	GIF_Height.w		=	height
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*	Example...										*
*-----------------------------------------------------------------------*
*
*	lea		gif_workspace,a0
*	jsr		INIT_GIFTABLES		; init GIF loader
*
*	move.l	#name,FILENAME_PTR
*	jsr		EXAMINE_GIF			; get width/height etc
*	move.w	GIF_Width,image_width
*	move.w	GIF_Height,image_height
*	move.w	GIF_Colours,image_cols
*
*	move.l	#colour_list,PALETTE_PTR
*	move.l	#unpack_space,GIF_Unpack_buffer
*	move.l	#load_buffer,GIF_Load_buffer
*	move.l	#4096,GIF_Loadsize
*	move.l	#$00FFFFFF,COLMASK
*	jsr		READ_GIF			; load image
*	move.l	GIF_Rawdata,a0		; final image in a0
*
*-----------------------------------------------------------------------*

EXAMINE_GIF:
      clr.w		-(sp)
	move.l	FILENAME_PTR,-(sp)
      move.w	#61,-(sp)		; open
      trap		#1
      addq		#8,sp
      tst.l		d0
      bmi		.rts
 	move.w	d0,GIF_Handle
	pea		GIF_Signature
      move.l	#13,-(sp)
      move.w	d0,-(sp)
      move.w	#63,-(sp)		; read
      trap		#1
      lea		12(sp),sp
      tst.l		d0
      ble		.err
      move.b	GIF_BitPixelRes,d0
      and.b		#7,d0
      addq.b	#1,d0
      moveq		#1,d1
      lsl.w		d0,d1
      move.w	d1,GIF_Colours
      mulu		#3,d1
      ext.l		d1
      move.l	d1,GIF_PalSize
      move.b	GIF_BitPixelRes,d0
      and.b		#1<<7,d0
      beq.s		.look
      move.l	GIF_ColourMap_PTR,-(sp)
      move.l	GIF_PalSize,-(sp)
      move.w	GIF_Handle,-(sp)
      move.w	#63,-(sp)		; read
      trap		#1
      lea		12(sp),sp
      tst.l		d0
      ble.s		.err
.look	bsr.s		SKIP_EXTENSION
	pea		GIF_ImageDesc
      move.l	#11,-(sp)
      move.w	GIF_Handle,-(sp)
      move.w	#63,-(sp)		; read
	trap		#1
      lea		12(sp),sp
      tst.l		d0
      ble.s		.err
      move.b	GIF_Height_Hi,d1
      lsl.w		#8,d1
      move.b	GIF_Height_Lo,d1
      move.w	d1,GIF_Height
      move.b	GIF_Width_Hi,d0
      lsl.w		#8,d0
      move.b	GIF_Width_Lo,d0
      move.w	d0,GIF_Width
	move.w      GIF_Handle,-(sp)
      move.w      #62,-(sp)             ;FCLOSE
      trap        #1
      addq.l      #4,sp
	moveq		#0,d0
.rts	move.l	GIF_Signature,d1
	rts
.err	move.w      GIF_Handle,-(sp)
      move.w      #62,-(sp)             ;FCLOSE
      trap        #1
      addq.l      #4,sp
	moveq		#-1,d0
	bra		.rts

SKIP_EXTENSION:
.look	move.l      GIF_Load_buffer,-(sp)
      move.l	#2,-(sp)		; look for extension
      move.w	GIF_Handle,-(sp)
      move.w	#63,-(sp)
	trap		#1
      lea		12(sp),sp
      move.l	GIF_Load_buffer,a0
      cmp.b		#$21,(a0)
     	bne.s		.stop
.bk	move.l      GIF_Load_buffer,-(sp)
      move.l	#1,-(sp)
      move.w	GIF_Handle,-(sp)
      move.w	#63,-(sp)		; read
	trap		#1
      lea		12(sp),sp
      move.l	GIF_Load_buffer,a0
      move.b	(a0),d0
      beq.s		.look
      and.w		#$FF,d0
	ext.l		d0
	move.l      GIF_Load_buffer,-(sp)
      move.l	d0,-(sp)
      move.w	GIF_Handle,-(sp)
      move.w	#63,-(sp)		; read
	trap		#1
      lea		12(sp),sp
	bra.s		.bk
.stop	move.w	#1,-(sp)
	move.w	GIF_Handle,-(sp)
	move.l	#-2,-(sp)
	move.w	#66,-(sp)
	trap		#1
	lea		10(sp),sp
	rts

READ_GIF:
      clr.w		-(sp)
	move.l	FILENAME_PTR,-(sp)
      move.w	#61,-(sp)		; open
      trap		#1
      addq		#8,sp
      move.w	d0,GIF_Handle
      bmi		Error_0
      pea		GIF_Signature
      move.l	#13,-(sp)
      move.w	GIF_Handle,-(sp)
      move.w	#63,-(sp)		; read
      trap		#1
      lea		12(sp),sp
      tst.l		d0
      ble		Error_1
      move.b	GIF_BitPixelRes,d0
      and.b		#7,d0
      addq.b	#1,d0
      moveq		#1,d1
      lsl.w		d0,d1
      move.w	d1,GIF_Colours
      mulu		#3,d1
      ext.l		d1
 	move.l	GIF_ColourMap_PTR,-(sp)
      move.l	d1,-(sp)
      move.w	GIF_Handle,-(sp)
      move.w	#63,-(sp)		; read
      trap		#1
      lea		12(sp),sp
      tst.l		d0
      ble		Error_1
 	move.l	GIF_ColourMap_PTR,a0
	move.l	PALETTE_PTR,a1
      move.w	GIF_Colours,d0
	subq		#1,d0
	move.l	COLMASK,d1
.copy	clr.b		(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	and.l		d1,-4(a1)
	dbra		d0,.copy
 	move.l	GIF_ColourMap_PTR,a0
 	move.l	GIF_ConvCols_PTR,a1
      move.w	GIF_Colours,d7
.loop	subq.w	#1,d7
      blt.s		.exit
      moveq		#0,d0
      move.b	(a0),d0
      clr.b		(a0)+
      lsl.w		#3,d0
      move.b	(a0),d0
      clr.b		(a0)+
      and.b		#-32,d0
      lsr.b		#1,d0
      move.b	(a0),d1
      clr.b		(a0)+
      lsr.b		#5,d1
      or.b		d1,d0
      move.w	d0,(a1)+
      bra.s		.loop
.exit	bsr		SKIP_EXTENSION
	pea		GIF_ImageDesc
      move.l	#11,-(sp)
      move.w	GIF_Handle,-(sp)
      move.w	#63,-(sp)		; read
	trap		#1
      lea		12(sp),sp
      tst.l		d0
      ble		Error_1
      move.b	GIF_Height_Hi,d1
      lsl.w		#8,d1
      move.b	GIF_Height_Lo,d1
      move.w	d1,GIF_Height
      move.b	GIF_Width_Hi,d0
      lsl.w		#8,d0
      move.b	GIF_Width_Lo,d0
      move.w	d0,GIF_Width
      move.w	d0,d5
      move.w	d0,d2
      move.w	d0,d3
      and.w		#-16,d2
      lsr.w		#1,d2
      and.w		#15,d3
      beq.s		.skip
      addq.w	#8,d2
.skip	move.w	d2,GIF_WordCount
	move.l	GIF_Unpack_buffer,d0

;	addq.l	#8,d0

	movea.l	d0,a4
	move.l	d0,GIF_Rawdata
      move.w	GIF_Height,GIF_LineCount
      btst		#6,GIF_Format
      beq.s		.nint
      move.w	GIF_Width,d1
      move.w	d1,d0
      clr.w		LacePos_0
      move.w	d0,LacePos_3
      move.w	d0,LacePos_7
      add.w		d0,d0
      move.w	d0,LacePos_2
      add.w		d1,d0
      move.w	d0,LacePos_6
      add.w		d1,d0
      move.w	d0,LacePos_1
      add.w		d0,d0
      sub.w		d1,d0
      move.w	d0,LacePos_5
      move.w	d0,LacePos_4
      move.l	#LacePos_0,LACETABLE_PTR
.nint	suba.l	a6,a6
      suba.l	a5,a5
      move.b	GIF_Bits,d0
      moveq		#1,d1
      lsl.w		d0,d1
      move.w	d1,GIF_Code1
      addq.l	#1,d1
      move.w	d1,GIF_Code2
      addq.l	#1,d1
      move.w	d1,GIF_Code3
      subq.w	#3,d1
	move.l	GIF_CodeTable_PTR,a0
	lea		GIF_CTSize(a0),a1
	lea		GIF_CTSize(a1),a2
.init	move.b	d1,(a1,d1)
	add.w		d1,d1
      move.w	#-1,(a0,d1)
      lsr.w		d1
      subq.w	#1,d1
      bge.s		.init
      bsr		READ_GIFCODES
      clr.w		d6
      move.b	d0,d6
      clr.l		d4
      swap		d5
      clr.w		d5
      move.l	GIF_ColourMap_PTR,a3
      move.w	#256-1,d0
.wipe	clr.l		(a3)+
      dbra		d0,.wipe
      move.l	GIF_ColourMap_PTR,a3
.mlop	swap		d7
      move.b	GIF_Bits,d7
      addq.l	#1,d7
      move.l	#$FFF00000,d0
      rol.l		d7,d0
      swap		d6
      move.w	d0,d6
      swap		d6
      swap		d7
      move.w	GIF_Code3,d7
      bsr		READ_BLOCK
      clr.l		d3
      move.w	d0,d3
      cmp.w		GIF_Code1,d3
      beq.s		.mlop
      swap		d3
      swap		d5
      moveq		#0,d1
      subq.w	#1,d7
      bra.s		.in
.read	bsr         READ_BLOCK
      move.w      d0,d3
      cmp.w       GIF_Code1,d0
      beq.s       .mlop
      cmp.w       GIF_Code2,d0
      beq         Remap
      cmp.w       d7,d0
      beq.s       .icod
      clr.w       d1
      move.b      0(a1,d0.w),0(a2,d1.w)
.hash	add.w       d0,d0
      move.w      0(a0,d0.w),d0
      bmi.s       .ehsh
      addq.w      #1,d1
      move.b      0(a1,d0.w),0(a2,d1.w)
      bra.s       .hash
.ehsh	swap        d3
      bra.s       .cop2
.icod	move.w      #1,d1
      swap        d3
      move.w      d3,d0
      move.b      0(a1,d0.w),0(a2,d1.w)
.hsh2	add.w       d0,d0
      move.w      0(a0,d0.w),d0
      bmi.s       .copc
      addq.w      #1,d1
      move.b      0(a1,d0.w),0(a2,d1.w)
      bra.s       .hsh2
.copc	move.b      0(a2,d1.w),(a2)
.cop2	move.b      0(a2,d1.w),0(a1,d7.w)
      add.w       d7,d7
      move.w      d3,0(a0,d7.w)
      lsr.w       #1,d7
      swap        d5
.rcod	clr.w       d0
      move.b      0(a2,d1.w),d0
.in	move.b      d0,(a4)+
	add.w		d0,d0
	add.w		d0,d0
      addq.l      #1,0(a3,d0.w)
      subq.w      #1,d5
      beq.s       .glac
.nxt1	dbra        d1,.rcod
      addq.w      #1,d7
      swap        d5
      bra         .read
.glac	move.w      GIF_Width,d5
      btst        #6,GIF_Format
      beq.s       .nxt1
      clr.l       d0
      movea.l     LACETABLE_PTR,a3
      move.w      8(a3),d0
      adda.l      d0,a4
      move.w      24(a3),d0
      sub.w       d0,GIF_LineCount
      bgt.s       .rcol
      move.l	GIF_Rawdata,a4
      adda.w      2(a3),a4
      move.w      18(a3),d0
      neg.w       d0
      add.w       GIF_Height,d0
      move.w      d0,GIF_LineCount
      addq.l      #2,LACETABLE_PTR
.rcol	move.l	GIF_ColourMap_PTR,a3
      bra.s       .nxt1
Remap

	rept		0
	
	move.l	GIF_Palette_PTR,a0
      moveq       #0,d2
      moveq       #0,d3
      movem.l     d2-d3,(a0)
      movem.l     d2-d3,8(a0)
      movem.l     d2-d3,16(a0)
      movem.l     d2-d3,24(a0)
      move.l	GIF_ConvCols_PTR,a1
      move.l	GIF_ColourMap_PTR,a2
      move.w      GIF_Colours,d7
.irm	moveq       #0,d0
      moveq       #0,d1
      move.w      GIF_Colours,d6
.fetc	cmp.l       0(a2,d1.w),d0
      bgt.s       .adjc
      move.w      d1,d2
      move.l      0(a2,d1.w),d0
.adjc	addq.w      #4,d1
      subq.w      #1,d6
      bgt.s       .fetc
      move.l      #-1,0(a2,d2.w)
      lsr.w       #1,d2
      move.w      0(a1,d2.w),d0
      move.l	GIF_Palette_PTR,a0
      move.w      d3,d1
.strc	tst.w       d1
      beq.s       .keep
      cmp.w       (a0)+,d0
      beq.s       .gotc
      dbra        d1,.strc
.keep	move.w      d0,(a0)
      addq.b      #1,d3
      cmpi.b      #16,d3
      beq.s       .endc
.gotc	subq.w      #1,d7
      bgt.s       .irm
.endc	move.l	GIF_Palette_PTR,a0
      move.w      #16-1,d0
.look	tst.w       (a0)+
      beq.s       .elok
      dbra        d0,.look
      bra.s       .slok
.elok	move.l	GIF_Palette_PTR,a3
	move.w      (a3),-2(a0)			; force black to colour 0
      clr.w       (a3)
.slok	move.l	GIF_Palette_PTR,a0
      move.l	GIF_ConvCols_PTR,a1
      move.l	GIF_ConvTable_PTR,a2
      move.w      GIF_Colours,d7
      add.w       d7,d7
.clop	moveq       #0,d6
      move.w      #1024,d0
.iclp	moveq       #0,d1
      move.w      0(a0,d6.w),d3
      move.w      -2(a1,d7.w),d4
      lsl.l       #4,d3
      lsl.l       #4,d4
      moveq		#3-1,d5
.ibit	lsr.b       #4,d3
      lsr.b       #4,d4
      sub.b       d4,d3
      move.b      d3,d2
      ext.w       d2
      muls        d2,d2
      add.w       d2,d1
      lsr.w       #4,d3
      lsr.w       #4,d4
      dbra        d5,.ibit
      cmp.w       d1,d0
      ble.s       .skip
      move.w      d1,d0
      lsr.w       #1,d6
      lsr.w       #1,d7
      move.b      d6,-1(a2,d7.w)
      add.w       d6,d6
      add.w       d7,d7
.skip	addq.w      #2,d6
      cmpi.w      #32,d6
      blt.s       .iclp
      subq.w      #2,d7
      bne.s       .clop

	endr

	move.w      GIF_Handle,-(sp)
      move.w      #62,-(sp)             ;FCLOSE
      trap        #1
      addq.l      #4,sp
	moveq		#0,d0
	rts
Error_1:
	move.w      GIF_Handle,-(sp)
      move.w      #62,-(sp)             ;FCLOSE
      trap        #1
      addq.l      #4,sp
Error_0:
	moveq		#-1,d0
	rts

READ_BLOCK:
      swap        d7
.strt	cmp.b       d7,d5
      bgt.s       .skip
.read	bsr.s       READ_GIFCODES
      tst.l       d0
      bmi.s       .exit
      subq.w      #1,d6
      bge.s       .cont
      tst.b       d0
      beq.s       .exit
      move.w      d0,d6
      bra.s       .read
.cont	lsl.l       d5,d0
      add.l       d0,d4
      addq.b      #8,d5
      bra.s       .strt
.skip	swap        d6
      move.w      d4,d0
      lsr.l       d7,d4
      and.w       d6,d0
      sub.b       d7,d5
      swap        d7
      cmp.w       d6,d7
      bne.s       .end2
      swap        d7
      cmpi.b      #12,d7
      beq.s       .end1
      addq.b      #1,d7
      add.w       d6,d6
      bset        #0,d6
.end1	swap        d7
.end2	swap        d6
      rts
.exit	addq.l      #4,sp
      bra         Remap

READ_GIFCODES:
      cmpa.l      a5,a6
      bne.s		.err
      movem.l     d1-d2/a0-a2,-(sp)
      move.l      GIF_Load_buffer,-(sp)
      move.l      GIF_Loadsize,-(sp)
      move.w      GIF_Handle,-(sp)
      move.w      #63,-(sp)             ;FREAD
      trap        #1
      lea         12(sp),sp
      movem.l     (sp)+,d1-d2/a0-a2
      move.l	GIF_Load_buffer,a5
      move.l	a5,a6
      adda.l      d0,a6
      tst.l       d0
      bne.s		.err
      moveq       #-1,d0
      rts
.err	clr.l       d0
      move.b      (a5)+,d0
      rts

INIT_GIFTABLES:
;	a0		GIF conversion buffer (size : GIF_Workspace)
	lea		GIF_Palette_LEN(a0),a1		
	move.l	a1,GIF_Palette_PTR
	lea		GIF_ConvCols_LEN(a0),a1		
	move.l	a1,GIF_ConvCols_PTR
	lea		GIF_ConvTable_LEN(a0),a1		
	move.l	a1,GIF_ConvTable_PTR
	lea		GIF_ColourMap_LEN(a0),a1		
	move.l	a1,GIF_ColourMap_PTR
	lea		GIF_CodeTable_LEN(a0),a1		
	move.l	a1,GIF_CodeTable_PTR
	rts

*-----------------------*

LacePos_0:	ds.w	1
LacePos_1:	ds.w	1
LacePos_2:	ds.w	1
LacePos_3:	ds.w	1
LacePos_4:	ds.w	1
LacePos_5:	ds.w	1
LacePos_6:	ds.w	1
LacePos_7:	ds.w	1
		dc.w	0
		dc.w	4
		dc.w	2
		dc.w	1
		dc.w	8
		dc.w	8
		dc.w	4
		dc.w	2

*-----------------------*
			bss
*-----------------------*

LACETABLE_PTR:	ds.l	1
GIF_PalSize:	ds.l	1
GIF_Rawdata:	ds.l	1

*-----------------------*

GIF_Handle:		ds.w	1

*-----------------------*

GIF_Colours:	ds.w	1	; << these are the important output vars
GIF_Width:		ds.w	1
GIF_Height:		ds.w	1

*-----------------------*

GIF_LineCount:	ds.w	1
GIF_WordCount:	ds.w	1

*-----------------------*

GIF_Code1:		ds.w	1
GIF_Code2:		ds.w	1
GIF_Code3:		ds.w	1

*-----------------------*

GIF_Signature:	ds.b	6		; signature
GIF_SD_Width:	ds.b	2
GIF_SD_Height:	ds.b	2
GIF_BitPixelRes:	ds.b	1
GIF_Backgrnd:	ds.b	1
GIF_SD_Sep:		ds.b	1		; 13 bytes
			even

GIF_ImageDesc:
GIF_ID_Sep:		ds.b	1
GIF_Xpos		ds.b	2
GIF_Ypos		ds.b	2
GIF_Width_Lo:	ds.b	1
GIF_Width_Hi:	ds.b	1
GIF_Height_Lo:	ds.b	1
GIF_Height_Hi:	ds.b	1
GIF_Format:		ds.b	1
GIF_Bits:		ds.b	1		; 11 bytes
			even	

GIF_Sortbank:	ds.w	256

*-----------------------*
		
GIF_Palette_PTR	ds.l	1
GIF_ConvCols_PTR	ds.l	1
GIF_ConvTable_PTR	ds.l	1
GIF_ColourMap_PTR	ds.l	1
GIF_CodeTable_PTR	ds.l	1

GIF_Unpack_buffer:ds.l	1
GIF_Load_buffer:	ds.l	1
GIF_Loadsize:	ds.l	1

*-----------------------*
			text
*-----------------------*
