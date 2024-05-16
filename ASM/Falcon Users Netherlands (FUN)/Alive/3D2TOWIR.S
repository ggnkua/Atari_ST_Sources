*          \\\\== Convert 3D2 -->> EARX wireframe models ==////

* texturemapped point format
		RSRESET
pointx:		RS.W	1
pointy:		RS.W	1
pointz:		RS.W	1
pointsize:	RS.W	0

* Internal triangle format (with color & hiddenedge info)
		RSRESET
trianglep1:	RS.W	1
trianglep2:	RS.W	1
trianglep3:	RS.W	1
triangleinfo:	RS.W	1
trianglesize:	RS.W	0

	OUTPUT	D:\CODING\DEMOS1\3D2TOWIR.TTP

	COMMENT HEAD=%111
;	OPT	D-

Cconws	MACRO
	pea	\1
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

Fseek	MACRO
	move.w	\1,-(sp)			* Mode
	move.w	\2,-(sp)			* Handle
	move.l	\3,-(sp)			* Offset
	move.w	#$42,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

; Fcreate fname  (ret: d0.w handle)
Fcreate	MACRO
	clr	-(sp)
	pea	\1
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
;	error_w
	ENDM

; Fwrite handle,source,len  (ret: d0.l Tats„chliche Anzahl geschriebener Bytes)
Fwrite	MACRO
	pea	\2
	move.l	\3,-(sp)
	move.w	\1,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	$c(sp),sp
;	error_l
	ENDM
	
; Fclose handle
Fclose	MACRO
	move.w	\1,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
;	error_w
	ENDM

START:	move.l	4(a7),a5
	lea	$80(a5),a5
	moveq	#0,d0
	move.b	(a5)+,d0
	bne.s	.doshit
	pea	noinput_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bra	OUT
.doshit:
	cmpi.b	#4,d0
	bhi.s	.on
	pea	noinput_txt
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bra	OUT
.on:	lea	filename_txt,a0
	movea.l	a0,a6
	subq.w	#1,d0
.movlp:	move.b	(a5)+,(a0)+
	dbra	d0,.movlp
	clr.b	(a0)
	movea.l	a6,a1
	lea	input_buf,a0
	moveq	#-1,d0
	bsr	LOAD_FILE
	tst.l	d0
	bmi	OUT

* Convert the loaded 3D2 file to environmentmapped format.
	lea	input_buf,a1
	lea	base_buf,a0
	bsr	CONVERT_3D2TOWIREFORMAT
	tst.l	d0
	bmi	.error
	move.l	d0,-(sp)

* Write the buffer with converted data to disk.
	Fcreate	outputfilename_txt(pc)
	move.w	d0,filehandle
	bmi	.error
	move.l	(sp)+,d0
	Fwrite	filehandle(pc),base_buf,d0
	Fclose	filehandle(pc)

.error:	

OUT:	clr.w	-(sp)
	trap	#1

filehandle:
	DC.W	0

******** SUBROUTINES ********

* INPUT: a0: address of buffer to load to
*        a1: address of filename
*        d0.l: number of bytes to load (-1= entire file!)
* OUPUT: d0.l: number of bytes loaded (negative= error!)
LOAD_FILE:
	move.l	d0,.loadsize
	move.l	a0,-(sp)
	clr.w	-(sp)				* Fopen
	move.l	a1,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq	#8,sp
	move.w	d0,.filehandle
	bpl.s	.load
	addq	#4,sp
	rts
.load:	move.l	.loadsize(pc),-(sp)		* Fread
	move.w	d0,-(sp)
	move.w	#63,-(sp)
	trap	#1
	lea	12(sp),sp
	move.l	d0,-(sp)
	move.w	.filehandle(pc),-(sp)		* Fclose
	move.w	#62,-(sp)
	trap	#1
	addq	#4,sp
	move.l	(sp)+,d0
	rts

.filehandle:
	DC.W	0
.loadsize:
	DC.L	0

* INPUT: d0.l: filelength
*        a0: address of buffer to save
*        a1: address of filename
* OUTPUT: d0.l: pos=filelength
*               neg=error
SAVE_FILE:
	move.l	a0,.bufferadr
	move.l	d0,d6
	Fcreate	(a1)
	move.w	d0,d7
	bmi.s	.e
	movea.l	.bufferadr(pc),a0
	Fwrite	d7,(a0),d6
	move.l	d0,d6
	bmi.s	.e
	Fclose	d7
	tst.l	d0
	bmi.s	.e
	move.l	d6,d0
.e:	rts

.bufferadr:
	DC.L	0

* INPUT: a0: address of destination buffer (EARX wireframe format)
*        a1: address of source buffer (3D2)
* OUTPUT: d0.l: number of bytes put in outputbuffer
CONVERT_3D2TOWIREFORMAT:
	move.l	a0,a6				* Backup start of outputbuffer
	cmpi.w	#$3d02,(a1)+
	bne	.error
	move.w	(a1)+,d7			* Get number of objects.
	subq.w	#1,d7
	move.w	d7,d5

	lea	$100-4(a1),a1
	movea.l	a1,a5
	movea.l	a0,a2
	clr.w	(a0)+

.convertobjectloop:
	lea	9(a1),a1

* Convert points..
	move.w	(a1)+,d6
	add.w	d6,(a2)
	subq.w	#1,d6

.convertpointsloop:
	moveq	#0,d2
	move.w	(a1)+,d0
	ext.l	d0
	bpl.s	.xpos
	moveq	#1,d2
	neg.l	d0
.xpos:	divu.w	#100,d0
	move.l	d0,d1
	sub.w	d1,d1
	divu.l	#100,d1
	swap	d0
	move.w	d1,d0
	asr.l	#8,d0
	asr.l	#5,d0
	tst.w	d2
	beq.s	.xnoneg
	neg.w	d0
.xnoneg:
	move.w	d0,(a0)+

	moveq	#0,d2
	move.w	(a1)+,d0
	ext.l	d0
	bpl.s	.ypos
	moveq	#1,d2
	neg.l	d0
.ypos:	divu.w	#100,d0
	move.l	d0,d1
	sub.w	d1,d1
	divu.l	#100,d1
	swap	d0
	move.w	d1,d0
	asr.l	#8,d0
	asr.l	#5,d0
	tst.w	d2
	beq.s	.ynoneg
	neg.w	d0
.ynoneg:
	move.w	d0,(a0)+

	moveq	#0,d2
	move.w	(a1)+,d0
	ext.l	d0
	bpl.s	.zpos
	moveq	#1,d2
	neg.l	d0
.zpos:	divu.w	#100,d0
	move.l	d0,d1
	sub.w	d1,d1
	divu.l	#100,d1
	swap	d0
	move.w	d1,d0
	asr.l	#8,d0
	asr.l	#5,d0
	tst.w	d2
	beq.s	.znoneg
	neg.w	d0
.znoneg:
	move.w	d0,(a0)+

	dbra	d6,.convertpointsloop

* Skip triangles..
	move.w	(a1)+,d6
	lea	(a1,d6.w*trianglesize),a1

	dbra	d7,.convertobjectloop

	movea.l	a0,a3
	lea	.tri_tbl,a0
	movea.l	a0,a1
	clr.w	(a0)+
	moveq	#0,d4

.convertobjectloop2:
	lea	9(a5),a5

	move.w	(a5)+,d0
	move.w	d0,d7
	mulu.w	#pointsize,d0
	adda.l	d0,a5

* Get triangles..
	move.w	(a5)+,d6
	add.w	d6,(a1)
	subq.w	#1,d6

.converttrianglesloop:
	REPT	3
	move.w	(a5)+,d0
	add.w	d4,d0
	move.w	d0,(a0)+
	ENDR
	move.w	(a5)+,(a0)+
	dbra	d6,.converttrianglesloop

	add.w	d7,d4

	dbra	d5,.convertobjectloop2

.success:

.makelinetable:
	lea	2(a3),a4
	move.w	(a1)+,d7
	subq.w	#1,d7
	moveq	#0,d6

.makelinesloop:
	move.b	triangleinfo(a1),d0
.check_ab:
	btst	#2,d0
	beq.s	.end_ab
	move.l	(a1),d1
	movea.l	a4,a0
	bsr.s	ADD_LINE
.end_ab:
.check_bc:
	btst	#1,d0	
	beq.s	.end_bc
	move.l	2(a1),d1
	movea.l	a4,a0
	bsr.s	ADD_LINE
.end_bc:
.check_ca:
	btst	#0,d0
	beq.s	.end_ca
	move.w	(a1),d1
	swap	d1
	move.w	4(a1),d1
	movea.l	a4,a0
	bsr.s	ADD_LINE
.end_ca:
	addq	#trianglesize,a1
	dbra	d7,.makelinesloop

	move.w	d6,(a3)
	lea	2(a3,d6.w*4),a0
	suba.l	a6,a0
	move.l	a0,d0
	rts

.error:	moveq	#-1,d0
	rts

	BSS

.tri_tbl:
	DS.B	10000*trianglesize

	TEXT

* INPUT: d1.l: linedata (highword = p0, lowword = p1)
*        d6.w: number of lines in table
*        a0: start of linebuffer
* OUTPUT: d6.w: number of lines
ADD_LINE:
	move.w	d6,d5
	beq.s	.new
	move.l	d1,d2
	swap	d2
	subq.w	#1,d5
.loop:	cmp.l	(a0),d1
	beq.s	.old
	cmp.l	(a0)+,d2
	beq.s	.old
	dbra	d5,.loop
.new:	move.l	d1,(a0)
	addq.w	#1,d6
	rts
.old:	
.rts:	rts

******** GLOBAL DATA ********

	DATA

noinput_txt:
	DC.B	"Error: no file was specified!",$d,$a,0
outputfilename_txt:
	DC.B	"WIRE.WIR",0
	EVEN

********* RESERVED MEMORY ********

	BSS

filename_txt:
	DS.B	256
input_buf:
	DS.W	50000
base_buf:
	DS.W	100000