* baseobject: point-table
*             triangle-table (point-oriented)
*             edge-table
*
* triangle-table (edge-oriented)
*
* normal-table (point-oriented)

reverseOption:	=	$00000001

* texturemapped point format
		RSRESET
pointx:		RS.W	1
pointy:		RS.W	1
pointtx:	RS.W	1
pointty:	RS.W	1
pointz:		RS.W	1
pointsize:	RS.B	0

* Internal triangle format (with color & hiddenedge info)
		RSRESET
trianglep1:	RS.W	1
trianglep2:	RS.W	1
trianglep3:	RS.W	1
triangleinfo:	RS.W	1
trianglesize:	RS.B	0

	OUTPUT	D:\CODING\ALIVE\N3D2CONV.TTP

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
	bsr	CONVERT_3D2TOENVFORMAT
	tst.l	d0
	bmi	.error
	move.l	d2,-(sp)
	move.l	d1,-(sp)
	move.l	d0,-(sp)

* Write the buffer with converted data to disk.
	Fcreate	outputfilename_txt(pc)
	move.w	d0,filehandle
	bmi	.error
	move.l	(sp)+,d0
	Fwrite	filehandle(pc),base_buf,d0
	move.l	(sp)+,d1
	Fwrite	filehandle(pc),tri_buf,d1
	move.l	(sp)+,d2
	Fwrite	filehandle(pc),pointnormal_buf,d2
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

* INPUT: a0: destination string
*        a1: source string (null terminated)
* OUTPUT: a0: address of last character in destination string
*         a1: end of source string
COPY_STRING:
.loop:	move.b	(a1)+,(a0)+
	bne.s	.loop
	subq	#1,a0
	rts

COPY_PSTRING:
.loop:	move.b	(a1)+,(a0)+
	dbeq	d0,.loop
	tst.b	-1(a0)
	bne.s	.clr
	subq	#1,a0
	rts
.clr:	clr.b	(a0)
	rts

WRITE_LONGTODECSTRING:
	moveq	#-1,d7
.loop:	moveq	#0,d1
	divu.l	#10,d1:d0
	add.b	#"0",d1
	move.b	d1,-(sp)
	addq.w	#1,d7
	tst.l	d0
	bne.s	.loop
.loop2:	move.b	(sp)+,(a0)+
	dbra	d7,.loop2
	clr.b	(a0)
	rts

* Very fast and accurate squareroot algorithm.
* Quite lengthy, though: 64 bytes.
* INPUT: d1.l: value to calculate the squareroot of (integer)
* OUTPUT: d0.l: squareroot of value (16.16 fixed point)
CALC_ATARISQRT:
	moveq	#1,d2
	ror.l	#2,d2
	moveq	#$F,d3
.loop1:	cmp.l	d2,d1
	bgt.s	.endloop1
	add.l	d1,d1
	lsr.l	#1,d2
	dbf	d3,.loop1
	bra.s	.end
.endloop1:

	sub.l	d2,d1
	move.l	d2,d0
	lsr.l	#1,d2
.loop2:	lsr.l	#1,d2
	add.l	d2,d0
	cmp.l	d0,d1
	bgt.s	.endloop2
	sub.l	d2,d0
	add.l	d1,d1
	dbf	d3,.loop2
	bra.s	.end
.endloop2:

	sub.l	d0,d1
	add.l	d2,d0
	add.l	d1,d1
	dbf	d3,.loop2

.end:	add.l	d0,d0
	addi.l	#$00008000,d0
	rts

* INPUT: a0: address of destination buffer (EARX environmentmapped format)
*        a1: address of source buffer (3D2)
* OUTPUT: d0.l: number of bytes put in outputbuffer
*         d1.l: number of bytes in triangle-table (edge-oriented)
CONVERT_3D2TOENVFORMAT:
	move.l	a0,a6
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
	bpl.s	.posx
	moveq	#1,d2
	neg.l	d0
.posx:	divu.w	#100,d0
	move.l	d0,d1
	sub.w	d1,d1
	divu.l	#100,d1
	swap	d0
	move.w	d1,d0
	asr.l	#8,d0
	asr.l	#5,d0
	tst.w	d2
	beq.s	.nonegx
	neg.w	d0
.nonegx:
	move.w	d0,pointx(a0)

	moveq	#0,d2
	move.w	(a1)+,d0
	ext.l	d0
	bpl.s	.posy
	moveq	#1,d2
	neg.l	d0
.posy:	divu.w	#100,d0
	move.l	d0,d1
	sub.w	d1,d1
	divu.l	#100,d1
	swap	d0
	move.w	d1,d0
	asr.l	#8,d0
	asr.l	#5,d0
	tst.w	d2
	beq.s	.nonegy
	neg.w	d0
.nonegy:
	move.w	d0,pointy(a0)

	moveq	#0,d2
	move.w	(a1)+,d0
	ext.l	d0
	bpl.s	.posz
	neg.l	d0
	moveq	#1,d2
.posz:	divu.w	#100,d0
	move.l	d0,d1
	sub.w	d1,d1
	divu.l	#100,d1
	swap	d0
	move.w	d1,d0
	asr.l	#8,d0
	asr.l	#5,d0
	tst.w	d2
	beq.s	.nonegz
	neg.w	d0
.nonegz:
	move.w	d0,pointz(a0)

	lea	pointsize(a0),a0	
	dbra	d6,.convertpointsloop

* Skip triangles..
	move.w	(a1)+,d6
	lea	(a1,d6.w*8),a1

	dbra	d7,.convertobjectloop

	move.l	a0,a1
	clr.w	(a0)+
	moveq	#0,d4

.convertobjectloop2:
	lea	9(a5),a5

	move.w	(a5)+,d0
	move.w	d0,d7
	mulu.w	#6,d0
	adda.l	d0,a5

* Get triangles..
	move.w	(a5)+,d6
	add.w	d6,(a1)
	subq.w	#1,d6

.converttrianglesloop:
	movem.w	(a5)+,d0-d2
	add.w	d4,d0
	add.w	d4,d1
	add.w	d4,d2
	move.w	d0,trianglep1(a0)		* Copy point-index 1.
	move.w	d1,trianglep3(a0)		* Copy point-index 2.
	move.w	d2,trianglep2(a0)		* Copy point-index 3.
	move.w	(a5)+,triangleinfo(a0)		* Copy hiddenedge- and color-info.
	lea	trianglesize(a0),a0		* Proceed to next triangle.
	dbra	d6,.converttrianglesloop

	add.w	d7,d4

	dbra	d5,.convertobjectloop2

.success:
	move.l	a6,-(sp)

	addq	#2,a0
	movea.l	a6,a2
	move.w	(a2)+,d0
	mulu.w	#pointsize,d0
	adda.l	d0,a2
	lea	tri_buf,a3
	bsr	CALCULATE_EDGESNTRIS
	suba.l	a6,a0
	move.l	a0,.basebufsize
	suba.l	#tri_buf,a3
	move.l	a3,.edgetribufsize

	movea.l	(sp),a1
	bsr	CONVERT_TRIS2POLYS

	movea.l	(sp),a1
	lea	pointnormal_buf,a0
	bsr	CALCULATE_POINTNORMALS
	suba.l	#pointnormal_buf,a0
	move.l	a0,.normalbufsize

	movea.l	(sp)+,a0
	lea	pointnormal_buf,a1
	bsr	CALC_TCOORDS

	move.l	.basebufsize(pc),d0
	move.l	.edgetribufsize(pc),d1
	move.l	.normalbufsize(pc),d2
	rts
.error:	moveq	#-1,d0
	rts

.basebufsize:
	DC.L	0
.edgetribufsize:
	DC.L	0
.normalbufsize:
	DC.L	0

* Converts triangletable to a polygontable. Neighbour triangles that are in
* the same plane are merged toghether. This will be done by looking at
* hiddenline information to seek out which triangles share the same surface.
* Todo: !compare with all points in newly made polygon instead of first three!
*        It still bugs with an add number of triangles in one face!!
* INPUT: a1: address of base-object
CONVERT_TRIS2POLYS:
* Initialize counters and addresses.
	lea	poly_buf+2,a0
	move.w	(a1)+,d0
	mulu.w	#pointsize,d0
	lea	(a1,d0.l),a2
	move.w	(a2)+,d7
	subq.w	#1,d7
	move.w	d7,d6
	lea	.mark_tbl,a4

.makepolyloop:
* IF notMarked(polytable[i])
	tst.b	(a4)+
	bne	.endmakepolyloop
	move.w	d7,d6
	movem.w	(a2),d0-d2
	movea.l	a0,a6
	movem.w	d0-d2,2(a0)
	addq	#6+2,a0
	move.w	#3,(a6)
	lea	trianglesize(a2),a3
	subq.w	#1,d6
	bmi	.endmakepolys
	movea.l	a4,a5
	addq.w	#1,.count

.addtriloop:
* IF notMarked(polytable[j]) AND isNeighbour(polytable[i],polytable[j])
*    AND inPlane(polytable[i], polytable[j])
.testmarked:
	tst.b	(a5)
	bne.s	.endaddtriloop

.testneighbour:

	moveq	#0,d4
	moveq	#3-1,d5
.cmppointloop:
	cmp.w	(a3),d0
	beq.s	.pointsame
	cmp.w	(a3),d1
	beq.s	.pointsame
	cmp.w	(a3),d2
	beq.s	.pointsame
	move.w	(a3),a1
	bra.s	.endcmppointloop
.pointsame:
	tst.w	d4
	beq.s	.newpoint
	addq.w	#1,d4
	swap	d3
	move.w	(a3),d3
	bra.s	.endcmppointloop
.newpoint:
	addq.w	#1,d4
	move.w	(a3),d3
.endcmppointloop:
	addq	#2,a3
	dbra	d5,.cmppointloop

	subq	#3*2,a3
	cmpi.w	#2,d4
	blt.s	.endaddtriloop

* Triangle is a neighbour..
* Now test if it is in the same plane.
.testinplane:
	btst	#2,triangleinfo(a2)
	beq.s	.hiddenab
	btst	#1,triangleinfo(a2)
	beq.s	.hiddenbc
	btst	#0,triangleinfo(a2)
	bne.s	.endaddtriloop
.hiddenca:
	swap	d0
	move.w	d2,d0
	bra.s	.gethidden2
.hiddenab:
	swap	d0
	move.w	d1,d0
	bra.s	.gethidden2
.hiddenbc:
	move.w	d1,d0
	swap	d0
	move.w	d2,d0

.gethidden2:	
	cmp.l	d3,d0
	beq.s	.addtri
	swap	d3
	cmp.l	d3,d0
	bne.s	.endaddtriloop

.addtri:
	move.w	a1,(a0)+		* Add point that wasn't in 1st tri to the thing..
	addq.w	#1,(a6)			* Increase pointcounter of polygon
	move.b	#1,(a5)
	
.endaddtriloop:
	addq	#1,a5
	addq	#trianglesize,a3
	dbra	d6,.addtriloop

.endmakepolyloop:
	addq	#trianglesize,a2
	dbra	d7,.makepolyloop

.endmakepolys:
	move.w	.count(pc),poly_buf
	rts

.count:	DC.W	0

	BSS

.mark_tbl:
	DS.B	10000

	TEXT

* INPUT: a0: address of edgetable to write to +2
*        a2: address of triangletable to read from (point-oriented)
*        a3: address of triangletable to write to (edge-oriented)
* OUTPUT: a0: address of end of edgetable
CALCULATE_EDGESNTRIS:
	move.w	(a2)+,d7
	moveq	#0,d6
	movea.l	a0,a4
	subq.w	#1,d7

.loop:	move.l	(a2),d0
	move.l	2(a2),d1
	move.w	4(a2),d2
	swap	d2
	move.w	(a2),d2
	addq	#trianglesize,a2

.1:	movea.l	a0,a4
	move.w	d6,d5
	subq.w	#1,d5
	bmi.s	.foundnew1
	move.l	d0,d3
	swap	d3
.1loop:	cmp.l	(a4),d0
	beq.s	.2
	cmp.l	(a4)+,d3
	beq.s	.2
	dbra	d5,.1loop	
.foundnew1:
	move.l	d0,(a0,d6.l*4)
	moveq	#0,d5
	addq.w	#1,d6

.2:	movea.l	a0,a4
	addq.w	#1,d5
	sub.w	d6,d5
	neg.w	d5
	move.w	d5,(a3)+

	move.w	d6,d5
	subq.w	#1,d5
	bmi.s	.foundnew2
	move.l	d1,d3
	swap	d3
.2loop:	cmp.l	(a4),d1
	beq.s	.3
	cmp.l	(a4)+,d3
	beq.s	.3
	dbra	d5,.2loop
.foundnew2:
	move.l	d1,(a0,d6.l*4)
	moveq	#0,d5
	addq.w	#1,d6

.3:	movea.l	a0,a4
	addq.w	#1,d5
	sub.w	d6,d5
	neg.w	d5
	move.w	d5,(a3)+

	move.w	d6,d5
	subq.w	#1,d5
	bmi.s	.foundnew3
	move.l	d2,d3
	swap	d3
.3loop:	cmp.l	(a4),d2
	beq.s	.endloop
	cmp.l	(a4)+,d3
	beq.s	.endloop
	dbra	d5,.3loop
.foundnew3:
	move.l	d2,(a0,d6.l*4)
	moveq	#0,d5
	addq.w	#1,d6

.endloop:
	addq.w	#1,d5
	sub.w	d6,d5
	neg.w	d5
	move.w	d5,(a3)+

	dbra	d7,.loop

	move.w	d6,-2(a0)
	lea	(a0,d6.w*4),a0
	rts

* INPUT: a0: address of normalbuffer
*        a1: address of base-object
CALCULATE_POINTNORMALS:
	movem.l	a0-a1,-(sp)
	bsr	CALCULATE_FACENORMALS
	movem.l	(sp)+,a0-a1

	move.l	a0,-(sp)
	lea	.temp_buf,a0
	lea	facenormal_buf,a2
	move.w	(a1)+,d0
	moveq	#0,d6
	move.w	d0,-(sp)
	lea	poly_buf,a1		;mulu.w	#pointsize,d0
					;adda.l	d0,a1
	move.w	(a1)+,d7
	subq.w	#1,d7

.calcnormloop:
	movem.l	(a2)+,d3-d5
	move.w	(a1)+,d6
	subq.w	#1,d6
.addpointloop:
	move.w	(a1)+,d0
	mulu.w	#12,d0
	lea	(a0,d0.l),a3
	add.l	d3,(a3)+
	add.l	d4,(a3)+
	add.l	d5,(a3)+
	dbra	d6,.addpointloop
	;addq	#trianglesize-triangleinfo,a1
	dbra	d7,.calcnormloop

	move.w	(sp)+,d7
	subq.w	#1,d7
	movea.l	(sp)+,a0
	lea	.temp_buf,a1

.calcnormloop2:
	movem.l	(a1),d0-d2
	move.l	d0,d3
	move.l	d1,d4
	move.l	d2,d5
	muls.l	d3,d3
	muls.l	d4,d4
	muls.l	d5,d5
	add.l	d3,d5
	add.l	d4,d5
	move.l	d5,d1
	bsr	CALC_ATARISQRT
	swap	d0
	addq.w	#1,d0
	ext.l	d0
	move.l	#$00ffffff,d3
	divs.l	d0,d3
	movem.l	(a1)+,d0-d2
	muls.l	d3,d0
	muls.l	d3,d1
	muls.l	d3,d2
	swap	d0				* / Scale the vector
	swap	d1				* | for working with
	swap	d2				* \ 256*256 textures.
	move.w	d0,(a0)+			* / Store
	move.w	d1,(a0)+			* | the
	move.w	d2,(a0)+			* \ vector.
	dbra	d7,.calcnormloop2

	rts

	BSS

.norm_buf:
	DS.L	3*10000
.temp_buf:
	DS.L	50000

	TEXT

* INPUT: a1: address of baseobject
CALCULATE_FACENORMALS:
	lea	facenormal_buf,a0
	move.w	(a1)+,d0
	lea	poly_buf,a2	;mulu.w	#pointsize,d0
				;lea	(a1,d0.l),a2

	move.w	(a2)+,d7
	subq.w	#1,d7

.loop:	move.w	(a2)+,d3
	add.w	d3,d3
	movem.w	(a2),d0-d2			* Get pointindexes in triangle.
	adda.w	d3,a2
	;addq	#trianglesize,a2
	mulu.w	#pointsize,d0
	mulu.w	#pointsize,d1
	mulu.w	#pointsize,d2
	lea	(a1,d0.l),a3			* a3 := point1 address
	lea	(a1,d1.l),a4			* a4 := point2 address
	lea	(a1,d2.l),a5			* a5 := point3 address
	move.w	(a3),d2
	move.w	(a4),d0
	move.w	(a5),d1
	sub.w	d2,d0				* RX1 := X1-X0
	sub.w	d2,d1				* RX2 := X2-X0
	move.w	pointy(a3),d4
	move.w	pointy(a4),d2
	move.w	pointy(a5),d3
	sub.w	d4,d2				* RY1 := Y1-Y0
	sub.w	d4,d3				* RY2 := Y2-Y0
	move.w	pointz(a3),a6
	move.w	pointz(a4),d4
	move.w	pointz(a5),d5
	sub.w	a6,d4				* RZ1 := Z1-Z0
	sub.w	a6,d5				* RZ2 := Z2-Z0

	movem.w	d4-d5,-(sp)
	muls.w	d2,d5				* RY1*RZ2
	muls.w	d3,d4				* RY2*RZ1
	sub.l	d4,d5				* RY1*RZ2-RY2*RZ1
	asr.l	#6,d5
	move.l	d5,(a0)+			* Store normal.x
	movem.w	(sp)+,d4-d5
	movem.w	d0-d1,-(sp)
	muls.w	d4,d1				* RZ1*RX2
	muls.w	d5,d0				* RZ2*RX1
	sub.l	d0,d1				* RZ1*RX2-RZ2*RX1
	asr.l	#6,d1
	move.l	d1,(a0)+			* Store normal.y
	movem.w	(sp)+,d0-d1
	muls.w	d0,d3				* RX1*RY2
	muls.w	d1,d2				* RX2*RY1
	sub.l	d3,d2				* RX1*RY2-RX2*RY1
	asr.l	#6,d2
	move.l	d2,(a0)+			* Store normal.z
	dbra	d7,.loop	
	rts

* INPUT: a0: address of baseobject (destination)
*        a1: address of pointnormal-table
CALC_TCOORDS:
	move.w	(a0)+,d7
	subq.w	#1,d7
	addq	#pointtx,a0

.loop:	move.l	(a1),(a0)
	lea	pointsize(a0),a0
	addq	#6,a1
	dbra	d7,.loop
	rts

******** GLOBAL DATA ********

	DATA

noinput_txt:
	DC.B	"Error: no file was specified!",$d,$a,0
outputfilename_txt:
	DC.B	"NOBJ3D.DAT",0

********* RESERVED MEMORY ********

	BSS

	EVEN

options:
	DS.L	1
filename_txt:
	DS.B	256
input_buf:
	DS.W	50000
base_buf:
	DS.W	100000
tri_buf:
	DS.W	50000
poly_buf:
	DS.W	50000
facenormal_buf:
	DS.L	50000
pointnormal_buf:
	DS.W	50000