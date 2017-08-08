;eor1 16(4),11(6),16(8),4(9),60(10),26(8),9(6),6(4),4(2)
;eor2	5(4),3(5),6(6),9(7),5(8),28(9),28(10),26(9),10(8),7(7),6(6),5(5),4(3)
;eor3	;3(3),8(5),15(7),86(9),15(7),9(5),6(3)
;eor4	6(4),8(6),21(8),51(10),18(9),13(8),7(7),6(6),6(5),6(3)


; eor fill culling and marking of edges and drawing lines
linesinlower						equ 	false		; TODO: FIX THIS SHIT
lineloopsize						equ 	7			; SPECIAL MEANING FOR MAX LENGTH OF DRAWABLE LINES

coff	equ 160


	SECTION BSS
clearScreenPointer							ds.l	1
		
currentEorLinesPointer						ds.l	1				; linesList	defined by current 3d object
currentEorFacesPointer						ds.l	1				; edges per face for object, defined by current 3d object
currentFaceNormalsPointer					ds.l	1				; normals per face, defined by current 3d object
currentCullVerticesPointer					ds.l	1
					
bitplaneOffset								ds.w	1				; offset for drawing the stuff, bitplane wise
		
pointer_lines_add_neg						ds.l	1
pointer_lines_add_pos						ds.l	1
pointer_lines_no_add_neg					ds.l	1
pointer_lines_no_add_pos					ds.l	1
		
pointer_lines_add_neg_2lines				ds.l	1
pointer_lines_add_pos_2lines				ds.l	1
pointer_lines_no_add_neg_2lines				ds.l	1
pointer_lines_no_add_pos_2lines				ds.l	1

pointer_lines_add_neg_2lines_1between		ds.l	1
pointer_lines_add_pos_2lines_1between		ds.l	1
pointer_lines_no_add_neg_2lines_1between	ds.l	1
pointer_lines_no_add_pos_2lines_1between	ds.l	1

pointer_lines_add_pos_3lines				ds.l	1
pointer_lines_add_neg_3lines				ds.l	1
pointer_lines_no_add_pos_3lines				ds.l	1
pointer_lines_no_add_neg_3lines				ds.l	1
		
_objectColorValues							ds.l	16

	SECTION TEXT


determineSlope macro
	asl.w	#7,d3													;22			; shift for lookup
	or.w	d2,d3													;8			; -- dy/dx --
	move.l	savedDivPointer,a4													;4			; get divtable
;	move.l	usp,a4													;4			; get divtable
	add.l	d3,a4													;8			; add offset dy/dx, we use .l here for signedless
	move.w	(a4)+,d3												;8			; get integer for division
	endm

determineOffsetIntoCanvas macro
	lea		$123456789,a4											;8			; -- determine offset into canvas --	
	add.w	d0,a4													;8			; add x-start to offset/mask table				this one is required, load table

	add.w	(a4)+,a0												;12			; add x-offset from table to screen									
	move.l	d1,a6													;4			; y value pointer
	add.w	(a6),a0													;12			; add y value to screen

;	move.w	(a4)+,d3												;8			; get x-offset from table						table: x-offset into screen
;	move.l	d1,a6													;4			; use y-value as pointer
;	add.w	(a6),d3													;8			; add y-offset to offset register
;	add.w	d3,a0													;8			; add total offset to screen
	endm


; one more idea, why not determine the end first, modify save,
; then remove the offset from the end, to get to the start?
; not sure if its faster, but could save register
determineOffsetIntoUnrolledCode macro
	IFEQ linesinlower
		move.w	(a4),d3												;8
		move.l	d3,a6												;4
	ELSE
		lea		$12345678,a6										;8			; -- offset into the unrolled code --
		add.w	(a4),a6												;12			; add offset into the linedrawing				; this is the same index by d0
	ENDC
	and.w	#$3c,d0													;8			; mask 111100
	add.w	d0,d2													;4			; determine complete offset
	endm

smcCodeAndDraw macro
	add.l	#$123456789,d2											;12			; does this need to be indirect lookup?
	move.l	d2,a4													;4
	move.l	(a4),a4													;8

	move.w	(a4),d3
	move.w	#$4ED3,(a4)												;12			; move in jmp (a3)								
	sub.w	d1,d1													;4			; clear d1						
	moveq	#%1,d0													;4			; 1 eor = 01, 2 bchg = 10
	moveq	#%100,d2												;4			; 3 eor = 100, 5 bcgh = 10000

	jmp		(a6)													;8		136/144							
	endm


drawLinePoly macro
	cmp.w	d0,d2				; is d2 > d0 ?						;4			; -- determine left and right --				cmp.l	d0,d2		;8	longword is x, lowword is y
	bge.s	noswap													;8/12		; check if we need to swap						
	exg		d0,d2													;8			; 	swap points
	exg		d1,d3													;8			; 												exg		d0,d2		;8
noswap																;
	ext.l	d3														;4			; -- slope --
	sub.w	d0,d2				; d2 is count (dx)					;4			; dx											sub.l	d0,d2		;8
	sub.w	d1,d3				; d3 is dy							;4			; dy											
	bge.s	y_positive												;8													
;--------- dy negative slope ---------------
y_negative															;
	neg.w	d3														;4			; dy is negative, make positive
			determineSlope														; this puts slope in d3
	beq.s	no_add_y_negative										;8/12 		; if 0, then special case (opt)
;--------- dy negative && dy > 1 -----------
add_y_negative														;
	neg.w	d3														;4			; dy is positive but must be negative, thus....
	move.w	d3,a1													;4			; save dy integer
	move.w	(a4),a2													;8			; save dy decimal
one_bpl_add_neg_canvas
			determineOffsetIntoCanvas
_add_y_negative_code
			determineOffsetIntoUnrolledCode
one_bpl_add_neg_draw
			smcCodeAndDraw									

;--------- dy negative && 0 < dy < 1 ------
no_add_y_negative													;
	move.w	(a4),a2													;8
one_bpl_no_add_neg_canvas
			determineOffsetIntoCanvas
_no_add_y_negative_code
			determineOffsetIntoUnrolledCode
one_bpl_no_add_neg_draw
			smcCodeAndDraw

;--------- dy positive ---------------------
y_positive
			determineSlope
	beq		no_add_y_pos
;--------- dy positive && dy > 1 -----------
add_y_positive
	move.w	(a4),a2		;8
	move.w	d3,a1								;8
one_bpl_add_pos_canvas
			determineOffsetIntoCanvas
_add_y_positive_code
			determineOffsetIntoUnrolledCode
one_bpl_add_pos_draw
			smcCodeAndDraw

;--------- dy positive && 0 < dy < 1 -------
no_add_y_pos
	move.w	(a4),a2		;8		; dx > dy
one_bpl_no_add_pos_canvas
			determineOffsetIntoCanvas
_no_add_y_pos_code
			determineOffsetIntoUnrolledCode
one_bpl_no_add_pos_draw
			smcCodeAndDraw

	endm


drawLinePoly2	macro
	cmp.w	d0,d2				; is d2 > d0 ?		;4
	bge		.noswap									;12
	exg		d0,d2									;8
	exg		d1,d3									;8
.noswap
	ext.l	d3
	sub.w	d0,d2				; d2 is count (dx)	;4
	sub.w	d1,d3				; d3 is dy			;4
	bge		y_positive_2lines							;8

y_negative_2lines
	neg.w	d3										;4	
			determineSlope
	beq		no_add_y_negative_2lines
	neg.w	d3										;4
	move.w	(a4),a2									;8
	move.w	d3,a1									;8
add_y_negative_2lines
two_conseq_bpl_add_neg_canvas
			determineOffsetIntoCanvas
_add_y_negative_2lines_code
			determineOffsetIntoUnrolledCode
two_conseq_bpl_add_neg_draw
			smcCodeAndDraw


y_positive_2lines
			determineSlope
	beq		no_add_y_pos_2lines
	move.w	(a4),a2		;8
	move.w	d3,a1								;8
;	doLeftRightClipping	1,1	;add, positive
two_conseq_bpl_add_pos_canvas
			determineOffsetIntoCanvas
_y_positive_2lines_code
			determineOffsetIntoUnrolledCode
two_conseq_bpl_add_pos_draw
			smcCodeAndDraw


no_add_y_pos_2lines
	move.w	(a4),a2
;	doLeftRightClipping	0,1	;no add, positive
two_conseq_bpl_no_add_pos_canvas
			determineOffsetIntoCanvas
_no_add_y_pos_2lines_code
			determineOffsetIntoUnrolledCode
two_conseq_bpl_no_add_pos_draw
			smcCodeAndDraw


no_add_y_negative_2lines
	move.w	(a4),a2		;8
two_conseq_bpl_no_add_neg_canvas
			determineOffsetIntoCanvas
_no_add_y_negative_2lines_code
			determineOffsetIntoUnrolledCode
two_conseq_bpl_no_add_neg_draw
			smcCodeAndDraw
	endm


drawLinePoly2_with1bplbetween	macro
	cmp.w	d0,d2				; is d2 > d0 ?		;4
	bge		.noswap									;12
	exg		d0,d2									;8
	exg		d1,d3									;8
.noswap
	ext.l	d3
	sub.w	d0,d2				; d2 is count (dx)	;4
	sub.w	d1,d3				; d3 is dy			;4
	bge		y_positive_2lines_1between							;8

y_negative_2lines_1between
	neg.w	d3										;4	
			determineSlope
	beq		no_add_y_negative_2lines_1between
	neg.w	d3										;4
	move.w	(a4),a2									;8
	move.w	d3,a1									;8
add_y_negative_2lines_1between
two_1btw_bpl_add_neg_canvas
			determineOffsetIntoCanvas
_add_y_negative_2lines_code_1between
			determineOffsetIntoUnrolledCode
two_1btw_bpl_add_neg_draw
			smcCodeAndDraw


y_positive_2lines_1between
			determineSlope
	beq		no_add_y_pos_2lines_1between
	move.w	(a4),a2		;8
	move.w	d3,a1								;8
;	doLeftRightClipping	1,1	;add, positive
two_1btw_bpl_add_pos_canvas
			determineOffsetIntoCanvas
_y_positive_2lines_code_1between
			determineOffsetIntoUnrolledCode
two_1btw_bpl_add_pos_draw
			smcCodeAndDraw


no_add_y_pos_2lines_1between
	move.w	(a4),a2
;	doLeftRightClipping	0,1	;no add, positive
two_1btw_bpl_no_add_pos_canvas
			determineOffsetIntoCanvas
_no_add_y_pos_2lines_code_1between
			determineOffsetIntoUnrolledCode
two_1btw_bpl_no_add_pos_draw
			smcCodeAndDraw


no_add_y_negative_2lines_1between
	move.w	(a4),a2		;8
two_1btw_bpl_no_add_neg_canvas
			determineOffsetIntoCanvas
_no_add_y_negative_2lines_code_1between
			determineOffsetIntoUnrolledCode
two_1btw_bpl_no_add_neg_draw
			smcCodeAndDraw
	endm






drawLinePoly3	macro
	cmp.w	d0,d2				; is d2 > d0 ?		;4
	bge		.noswap									;12
	exg		d0,d2									;8
	exg		d1,d3									;8
.noswap
	ext.l	d3
	sub.w	d0,d2				; d2 is count (dx)	;4
	sub.w	d1,d3				; d3 is dy			;4
	bge		y_positive_3lines							;8

y_negative_3lines
	neg.w	d3										;4	
			determineSlope
	beq		no_add_y_negative_3lines
	neg.w	d3										;4
	move.w	(a4),a2									;8
	move.w	d3,a1									;8
add_y_negative_3lines
three_conseq_bpl_add_neg_canvas
			determineOffsetIntoCanvas
_add_y_negative_3lines_code
			determineOffsetIntoUnrolledCode
three_conseq_bpl_add_neg_draw
			smcCodeAndDraw


y_positive_3lines
			determineSlope
	beq		no_add_y_pos_3lines
	move.w	(a4),a2		;8
	move.w	d3,a1								;8
;	doLeftRightClipping	1,1	;add, positive
three_conseq_bpl_add_pos_canvas
			determineOffsetIntoCanvas
_y_positive_3lines_code
			determineOffsetIntoUnrolledCode
three_conseq_bpl_add_pos_draw
			smcCodeAndDraw


no_add_y_pos_3lines
	move.w	(a4),a2
;	doLeftRightClipping	0,1	;no add, positive
three_conseq_bpl_no_add_pos_canvas
			determineOffsetIntoCanvas
_no_add_y_pos_3lines_code
			determineOffsetIntoUnrolledCode
three_conseq_bpl_no_add_pos_draw
			smcCodeAndDraw


no_add_y_negative_3lines
	move.w	(a4),a2		;8
three_conseq_bpl_no_add_neg_canvas
			determineOffsetIntoCanvas
_no_add_y_negative_3lines_code
			determineOffsetIntoUnrolledCode
three_conseq_bpl_no_add_neg_draw
			smcCodeAndDraw
	endm




;; calling: doClipping x,y
; where 
;   x = do we have stepping to take into account    1 = stepping
;   y = do we have positive or negative offset      1 = positive
;   a1 = whole stepping (if needed)
;   a2 = is fraction
;
;	d0 is x1
;	d1 is y1
;	d2 is x2
;	d3 is y2
doLeftRightClipping macro
_left
    tst.w   d0							; clipping,check if x < 0
    bge     _right						; if x < 0; then x = 0, but we also need to adjust the y drawing
    neg     d0      					; now d0 is positive
    sub.w   d0,d2						; now we have delta-x
    blt     _nodraw						; if this is < 0; then we dont draw

    lsr.w   #2,d0

    IFNE \1
        move.w  a1,d3       ; move stepping to d3
        mulu    d0,d3       ; number of steps clipped
        add.w   d3,a0       ; add offset to a0
    ENDC

    move.w  a2,d3           ; move the fraction to d3
    mulu    d0,d3           ; number of steps clipped
    swap    d3              ; swap to the whole part
    add.w   d3,d3
    add.w   d3,d3

    IFNE \2
        add.w   (a3,d3.w),a0        ; if positive, add to a0
    ELSE
        sub.w   (a3,d3.w),a0        ; if negative, subtract from a0
    ENDC
    moveq   #0,d0           ; clip d0 to 0
_leftdone
    jmp     _continue
_right
    move.w  d2,d3
    add.w   d0,d3
    cmp.w   #319*4,d3
    ble.w   _continue
    ; here we know that the right point is out of bound, we also have to check for the left point
    cmp.w   #319*4,d0
    bge     _nodraw

    move.w  #319*4,d2
    sub.w   d0,d2
    jmp     _continue

_nodraw
    rts
_continue
    endm  

; this rout generates stuff into a0
;	a0: buffer							\1
;	d0:	pointer into the smccode		\2
;	d2:	normal offset increase			\3
;	d3:	special offset increase			\4
; entries:
;	16 longwords * 20 = 1280 bytes
generateSmcCode	macro
	move.l	\1,a0
	move.l	\2,d0
	move.l	#\3,d2
	move.l	#\4,d3
	jsr		generateSmcCodeRout
	endm

generateSmcCodeRout
	moveq	#20-1,d7
.olx
	REPT 15
		move.l	d0,(a0)+
		add.l	d2,d0
	ENDR
	move.l	d0,(a0)+
	add.l	d3,d0

	dbra	d7,.olx
	rts

; this rout generates stuff into a0
;	a0: buffer							\1
;	d2:	offset size						\2
;	d4: lower pointer value				\3
; form:
;	upper word = offset into screen
;	lower word = offset into jump
; entries:
; 16 longword entries, 20 entries = 1280 bytes (BUT NOW 27*16 = )
generateMaskAndOffset macro
	move.l	\1,a0
	move.l	#\2,d2				; firsthalf
	move.l	\3,d4
	jsr		generateMaskAndOffsetRout
	endm

generateMaskAndOffsetRout
	IF scanLineWidth=160
	moveq	#0,d0
	ELSE
	move.l	#((160*3))<<16,d0				; val 1
	ENDC
	moveq	#0,d1				; val 2
	IF scanLineWidth=160
	moveq	#20-1,d7			; outer
	ELSE
	moveq	#28-1,d7
	ENDC
	move.l	#$10000,a1
	moveq	#7,d5

	swap	d5

.ol
	REPT 8
		move.l	d0,(a0)+		; val
		add.w	d2,d0			; set val+firsthalf
	ENDR
	add.l	a1,d0				; val2+1

	REPT 7
		move.l	d0,(a0)+		; val
		add.w	d2,d0			; set val+secondhalf
	ENDR
	move.l	d0,(a0)+			; val

	IFEQ	linesinlower
		move.w	d4,d0
	ELSE
		move.w	d1,d0
	ENDC
	add.l	d5,d0				; val2 += 7

	dbra	d7,.ol
	rts


failx
	move.b	#0,$ffffc123
	sub.l	a7,a7

initEorPointers
	move.l	y_block_pointer_fs,d0
	move.l	d0,d2
	add.l	#$10000,d2
	add.l	#800,d0
	IF scanLineWidth=160
	move.l	#1280,d1			; 16 * 20 * 4; based on 20x16 pixels, so be careful!
	ELSE
	move.l	#1800,d1
	ENDC
	; 1bpl
	move.l	d0,one_bpl_no_add_pos_canvas+2
	add.l	d1,d0
	move.l	d0,one_bpl_no_add_neg_canvas+2
	add.l	d1,d0
	move.l	d0,one_bpl_no_add_pos_draw+2
	add.l	d1,d0
	move.l	d0,one_bpl_no_add_neg_draw+2
	add.l	d1,d0

	move.l	d0,one_bpl_add_pos_canvas+2
	add.l	d1,d0
	move.l	d0,one_bpl_add_neg_canvas+2
	add.l	d1,d0
	move.l	d0,one_bpl_add_pos_draw+2
	add.l	d1,d0
	move.l	d0,one_bpl_add_neg_draw+2
	add.l	d1,d0

	; 2 conseq bpl
	move.l	d0,two_conseq_bpl_no_add_pos_canvas+2
	add.l	d1,d0
	move.l	d0,two_conseq_bpl_no_add_neg_canvas+2
	add.l	d1,d0
	move.l	d0,two_conseq_bpl_no_add_pos_draw+2
	add.l	d1,d0
	move.l	d0,two_conseq_bpl_no_add_neg_draw+2
	add.l	d1,d0

	move.l	d0,two_conseq_bpl_add_pos_canvas+2
	add.l	d1,d0
	move.l	d0,two_conseq_bpl_add_neg_canvas+2
	add.l	d1,d0
	move.l	d0,two_conseq_bpl_add_pos_draw+2
	add.l	d1,d0
	move.l	d0,two_conseq_bpl_add_neg_draw+2
	add.l	d1,d0				;12 * 1280 = 15360 + 800 = 16160 --> 49376 left

	; 2 bpl 1 between
	move.l	d0,two_1btw_bpl_no_add_pos_canvas+2
	add.l	d1,d0
	move.l	d0,two_1btw_bpl_no_add_neg_canvas+2
	add.l	d1,d0
	move.l	d0,two_1btw_bpl_no_add_pos_draw+2
	add.l	d1,d0
	move.l	d0,two_1btw_bpl_no_add_neg_draw+2
	add.l	d1,d0

	move.l	d0,two_1btw_bpl_add_pos_canvas+2
	add.l	d1,d0
	move.l	d0,two_1btw_bpl_add_neg_canvas+2
	add.l	d1,d0
	move.l	d0,two_1btw_bpl_add_pos_draw+2
	add.l	d1,d0
	move.l	d0,two_1btw_bpl_add_neg_draw+2
	add.l	d1,d0

	; 3 bpl
	move.l	d0,three_conseq_bpl_no_add_pos_canvas+2
	add.l	d1,d0
	move.l	d0,three_conseq_bpl_no_add_neg_canvas+2
	add.l	d1,d0
	move.l	d0,three_conseq_bpl_no_add_pos_draw+2
	add.l	d1,d0
	move.l	d0,three_conseq_bpl_no_add_neg_draw+2
	add.l	d1,d0

	move.l	d0,three_conseq_bpl_add_pos_canvas+2
	add.l	d1,d0
	move.l	d0,three_conseq_bpl_add_neg_canvas+2
	add.l	d1,d0
	move.l	d0,three_conseq_bpl_add_pos_draw+2
	add.l	d1,d0
	move.l	d0,three_conseq_bpl_add_neg_draw+2
	add.l	d1,d0

	;	4 * 8 * 1280 = 40960
	;	4 * 8 * 1728 = 55296


	move.l	alignpointer4,d0

	; here we set the pointers for the line generated code
	IFEQ	linesinlower	
		move.l	#$9600,d0
	ENDC

	; 1 bpl
	IFEQ	linesinlower
	ELSE
		move.l	d0,_add_y_negative_code+2
	ENDC
	move.l	d0,pointer_lines_add_neg
	add.l	#194*lineloopsize,d0												;	1358				

	IFEQ	linesinlower
	ELSE
		move.l	d0,_no_add_y_negative_code+2
	ENDC
	move.l	d0,pointer_lines_no_add_neg
	add.l	#162*lineloopsize,d0												;	1134

	IFEQ	linesinlower
	ELSE
		move.l	d0,_add_y_positive_code+2
	ENDC
	move.l	d0,pointer_lines_add_pos
	add.l	#194*lineloopsize,d0												;	1358

	IFEQ	linesinlower
	ELSE
		move.l	d0,_no_add_y_pos_code+2
	ENDC
;	move.l	one_bpl_no_add_pos_draw,_no_add_y_pos_draw+2
	move.l	d0,pointer_lines_no_add_pos
	add.l	#162*lineloopsize,d0												;	1134			--> 		4984


	; 2 lines, adjecent
	IFEQ	linesinlower
	ELSE
		move.l	d0,_add_y_negative_2lines_code+2
	ENDC
	move.l	d0,pointer_lines_add_neg_2lines
	add.l	#258*lineloopsize,d0												;	1806

	IFEQ	linesinlower
	ELSE
		move.l	d0,_y_positive_2lines_code+2
	ENDC
	move.l	d0,pointer_lines_add_pos_2lines
	add.l	#258*lineloopsize,d0												;	1806

	IFEQ	linesinlower
	ELSE
		move.l	d0,_no_add_y_pos_2lines_code+2
	ENDC
	move.l	d0,pointer_lines_no_add_pos_2lines
	add.l	#226*lineloopsize,d0												;	1582


	IFEQ	linesinlower
	ELSE
		move.l	d0,_no_add_y_negative_2lines_code+2
	ENDC
	move.l	d0,pointer_lines_no_add_neg_2lines
	add.l	#226*lineloopsize,d0												;	1582			-->			6776


	; 2 lines, 1 between
	IFEQ	linesinlower
	ELSE
		move.l	d0,_add_y_negative_2lines_code_1between+2
	ENDC
	move.l	d0,pointer_lines_add_neg_2lines_1between
	add.l	#258*lineloopsize,d0												;	1806

	IFEQ	linesinlower
	ELSE
		move.l	d0,_y_positive_2lines_code_1between+2
	ENDC
	move.l	d0,pointer_lines_add_pos_2lines_1between
	add.l	#258*lineloopsize,d0												;	1806

	IFEQ	linesinlower
	ELSE
		move.l	d0,_no_add_y_pos_2lines_code_1between+2
	ENDC
	move.l	d0,pointer_lines_no_add_pos_2lines_1between
	add.l	#226*lineloopsize,d0												;	1582		


	IFEQ	linesinlower
	ELSE
		move.l	d0,_no_add_y_negative_2lines_code_1between+2
	ENDC
	move.l	d0,pointer_lines_no_add_neg_2lines_1between
	add.l	#226*lineloopsize,d0												;	1582			-->			6776

	
	; 3 bpl, adjecent
	IFEQ	linesinlower
	ELSE
		move.l	d0,_add_y_negative_3lines_code+2
	ENDC
	move.l	d0,pointer_lines_add_neg_3lines
	add.l	#322*lineloopsize,d0				;	2580		--> 5060	-->	7120 + 9580 --> 16600

	IFEQ	linesinlower
	ELSE
		move.l	d0,_y_positive_3lines_code+2
	ENDC
	move.l	d0,pointer_lines_add_pos_3lines
	add.l	#322*lineloopsize,d0				;	2580


	; here we run out of shit
	IFEQ linesinlower
	ELSE
		move.l	explog_logpointer,d0
		add.l	#2048,d0
	ENDC

	IFEQ	linesinlower
	ELSE
		move.l	d0,_no_add_y_pos_3lines_code+2
	ENDC
	move.l	d0,pointer_lines_no_add_pos_3lines
	add.l	#290*lineloopsize,d0				;	2260		--> 4520


	IFEQ	linesinlower
	ELSE
		move.l	d0,_no_add_y_negative_3lines_code+2
	ENDC
	move.l	d0,pointer_lines_no_add_neg_3lines
	add.l	#290*lineloopsize,d0				;	2260




	; this does the basic line generation with 160 and -160 offset on overflow
	; 1 bpl
	move.l	pointer_lines_add_neg,a0
	move.w	#-scanLineWidth,d7
	jsr		generateLineCode_1BPL_yes_integer_slope

	move.l	pointer_lines_add_pos,a0
	move.w	#scanLineWidth,d7
	jsr		generateLineCode_1BPL_yes_integer_slope

	move.l	pointer_lines_no_add_neg,a0
	move.w	#-scanLineWidth,d7
	jsr		generateLineCode_1BPL_no_integer_slope

	move.l	pointer_lines_no_add_pos,a0
	move.w	#scanLineWidth,d7
	jsr		generateLineCode_1BPL_no_integer_slope

	; 2 bpl adjecent
	move.l	pointer_lines_add_neg_2lines,a0
	move.w	#2,a5
	move.w	#-scanLineWidth,d7
	jsr		generateLineCode_2BPL_yes_integer_slope

	move.l	pointer_lines_add_pos_2lines,a0
	move.w	#2,a5
	move.w	#scanLineWidth,d7
	jsr		generateLineCode_2BPL_yes_integer_slope

	move.l	pointer_lines_no_add_neg_2lines,a0
	move.w	#2,a5
	move.w	#-scanLineWidth,d7
	jsr		generateLineCode_2BPL_no_integer_slope

	move.l	pointer_lines_no_add_pos_2lines,a0
	move.w	#2,a5
	move.w	#scanLineWidth,d7
	jsr		generateLineCode_2BPL_no_integer_slope

	; 2bpl 1 between
	move.l	pointer_lines_add_neg_2lines_1between,a0
	move.w	#4,a5
	move.w	#-scanLineWidth,d7
	jsr		generateLineCode_2BPL_yes_integer_slope

	move.l	pointer_lines_add_pos_2lines_1between,a0
	move.w	#4,a5
	move.w	#scanLineWidth,d7
	jsr		generateLineCode_2BPL_yes_integer_slope

	move.l	pointer_lines_no_add_neg_2lines_1between,a0
	move.w	#4,a5
	move.w	#-scanLineWidth,d7
	jsr		generateLineCode_2BPL_no_integer_slope

	move.l	pointer_lines_no_add_pos_2lines_1between,a0
	move.w	#4,a5
	move.w	#scanLineWidth,d7
	jsr		generateLineCode_2BPL_no_integer_slope

	; 3 bpl adjecent
	move.l	pointer_lines_add_neg_3lines,a0
	move.w	#2,a5
	move.w	#-scanLineWidth,d7
	jsr		generateLineCode_3BPL_yes_integer_slope


	move.l	pointer_lines_add_pos_3lines,a0
	move.w	#2,a5
	move.w	#scanLineWidth,d7
	jsr		generateLineCode_3BPL_yes_integer_slope

	move.l	pointer_lines_no_add_neg_3lines,a0
	move.w	#2,a5
	move.w	#-scanLineWidth,d7
	jsr		generateLineCode_3BPL_no_integer_slope

	move.l	pointer_lines_no_add_pos_3lines,a0
	move.w	#2,a5
	move.w	#scanLineWidth,d7
	jsr		generateLineCode_3BPL_no_integer_slope


	; 1 bpl
	generateMaskAndOffset	one_bpl_no_add_neg_canvas+2,10,pointer_lines_no_add_neg
	generateSmcCode			one_bpl_no_add_neg_draw+2,pointer_lines_no_add_neg,10,12

	generateMaskAndOffset	one_bpl_no_add_pos_canvas+2,10,pointer_lines_no_add_pos
	generateSmcCode			one_bpl_no_add_pos_draw+2,pointer_lines_no_add_pos,10,12

	generateMaskAndOffset	one_bpl_add_neg_canvas+2,12,pointer_lines_add_neg
	generateSmcCode			one_bpl_add_neg_draw+2,pointer_lines_add_neg,12,14

	generateMaskAndOffset	one_bpl_add_pos_canvas+2,12,pointer_lines_add_pos
	generateSmcCode			one_bpl_add_pos_draw+2,pointer_lines_add_pos,12,14

	; 2 bpl adjecent
	generateMaskAndOffset	two_conseq_bpl_no_add_neg_canvas+2,14,pointer_lines_no_add_neg_2lines
	generateSmcCode			two_conseq_bpl_no_add_neg_draw+2,pointer_lines_no_add_neg_2lines,14,16

	generateMaskAndOffset	two_conseq_bpl_no_add_pos_canvas+2,14,pointer_lines_no_add_pos_2lines
	generateSmcCode			two_conseq_bpl_no_add_pos_draw+2,pointer_lines_no_add_pos_2lines,14,16

	generateMaskAndOffset	two_conseq_bpl_add_pos_canvas+2,16,pointer_lines_add_pos_2lines
	generateSmcCode			two_conseq_bpl_add_pos_draw+2,pointer_lines_add_pos_2lines,16,18

	generateMaskAndOffset	two_conseq_bpl_add_neg_canvas+2,16,pointer_lines_add_neg_2lines
	generateSmcCode			two_conseq_bpl_add_neg_draw+2,pointer_lines_add_neg_2lines,16,18

	; 2 bpl 1 between
	generateMaskAndOffset	two_1btw_bpl_no_add_neg_canvas+2,14,pointer_lines_no_add_neg_2lines_1between
	generateSmcCode			two_1btw_bpl_no_add_neg_draw+2,pointer_lines_no_add_neg_2lines_1between,14,16

	generateMaskAndOffset	two_1btw_bpl_no_add_pos_canvas+2,14,pointer_lines_no_add_pos_2lines_1between
	generateSmcCode			two_1btw_bpl_no_add_pos_draw+2,pointer_lines_no_add_pos_2lines_1between,14,16

	generateMaskAndOffset	two_1btw_bpl_add_pos_canvas+2,16,pointer_lines_add_pos_2lines_1between
	generateSmcCode			two_1btw_bpl_add_pos_draw+2,pointer_lines_add_pos_2lines_1between,16,18

	generateMaskAndOffset	two_1btw_bpl_add_neg_canvas+2,16,pointer_lines_add_neg_2lines_1between
	generateSmcCode			two_1btw_bpl_add_neg_draw+2,pointer_lines_add_neg_2lines_1between,16,18

	; 3 bpl
	generateMaskAndOffset	three_conseq_bpl_no_add_neg_canvas+2,18,pointer_lines_no_add_neg_3lines
	generateSmcCode			three_conseq_bpl_no_add_neg_draw+2,pointer_lines_no_add_neg_3lines,18,20

	generateMaskAndOffset	three_conseq_bpl_no_add_pos_canvas+2,18,pointer_lines_no_add_pos_3lines
	generateSmcCode			three_conseq_bpl_no_add_pos_draw+2,pointer_lines_no_add_pos_3lines,18,20


	generateMaskAndOffset	three_conseq_bpl_add_pos_canvas+2,20,pointer_lines_add_pos_3lines
	generateSmcCode			three_conseq_bpl_add_pos_draw+2,pointer_lines_add_pos_3lines,20,22

	generateMaskAndOffset	three_conseq_bpl_add_neg_canvas+2,20,pointer_lines_add_neg_3lines
	generateSmcCode			three_conseq_bpl_add_neg_draw+2,pointer_lines_add_neg_3lines,20,22

	rts

newDummy
	rte

stopDraw
	rts

savedDivPointer	ds.l	1
drawEorLines:
	moveq	#0,d0
	moveq	#0,d2
	move.l	divtablepointer,a5										;20
	move.l	a5,savedDivPointer													;4
;	move.l	a5,usp													;4
;	move.l	currentEorLinesPointer,a5								;20
	lea		eorEdgesLower,a5
	move.l	y_block_pointer_fs,d1										;20
	lea		afterDraw,a3													;8		return address

	;d5	= 5
	;d4 = 3
	;d7 = 2
	;d6 = 1
			;%21098765432109876543210987654321
	move.l	screenpointer3,d5
	move.w	#%1000,d5					;12		pixel %1000
	moveq	#%100000,d4					;12		pixel %100000
	moveq	#%1000000,d7					;12		pixel %1000000
	move.l	#%10000000,d6					;12		pixel %10000000
	jmp		doLine



afterDraw
	move.w	d3,(a4)

doLine		
;	move.b	#0,$ffffc123
	move.w	(a5)+,d0			; visibility
	blt		stopDraw
	jmp		.myjmp(pc,d0)

	jmp		stopDraw
.myjmp
	jmp		noDrawNew
	jmp		drawColour1
	jmp		drawColour2
	jmp		drawColour3
	jmp		drawColour4
	jmp		drawColour5
	jmp		drawColour6
	jmp		drawColour7

uselessshit	dc.w	0


drawColour1							; bpl1
	move.l	d5,a0
	sub.w	a0,a0
	add.w	object_y_offset4,a0
	jmp		justDraw

drawColour2							; bpl2
	move.l	d5,a0
	sub.w	a0,a0
	add.w	#2,a0
	add.w	object_y_offset4,a0
	jmp		justDraw

drawColour3							; bpl1+2
	move.l	d5,a0
	sub.w	a0,a0
	add.w	object_y_offset4,a0
	jmp		drawTwo

drawColour4							; bpl3
	move.l	d5,a0
	sub.w	a0,a0
	add.w	#4,a0
	add.w	object_y_offset4,a0
	jmp		justDraw

drawColour5							; bpl1+3
	move.l	d5,a0
	sub.w	a0,a0
	add.w	object_y_offset4,a0
	jmp		drawTwoOnePlaneApart

drawColour6							; bpl2+3
	move.l	d5,a0
	sub.w	a0,a0
	add.w	#2,a0
	add.w	object_y_offset4,a0
	jmp		drawTwo

drawColour7							; bpl1+2+3
	move.l	d5,a0
	sub.w	a0,a0
	add.w	object_y_offset4,a0
	jmp		drawThree				


object_y_offset	dc.w	0



noDrawNew
	add.w	#4,a5
		move.w	(a5)+,d0
		blt		stopDraw
		jmp		.myjmp(pc,d0)

.myjmp
		jmp		noDrawNew
		jmp		drawColour1
		jmp		drawColour2
		jmp		drawColour3
		jmp		drawColour4
		jmp		drawColour5
		jmp		drawColour6
		jmp		drawColour7



noDraw
	add.w	#4,a5													;8	; skip the line offset
;	jmp		doLine	
	move.w	(a5)+,d0			; visibility
	blt		stopDraw
	jmp		.myjmp2(pc,d0)

	jmp		stopDraw
.myjmp2
	jmp		noDrawNew
	jmp		drawColour1
	jmp		drawColour2
	jmp		drawColour3
	jmp		drawColour4
	jmp		drawColour5
	jmp		drawColour6
	jmp		drawColour7

setupStuffForDrawing macro
	move.w	(a5)+,a6												;8		vertex1 pointer									move.w	(a5)+,a6
	move.w	(a6)+,d0												;8		x												move.l	(a6),d0
	move.w	(a6),d1													;8		y into lower word for y_block address			move.w	(a5)+,a6
	move.w	(a5)+,a6												;8		vertex2	pointer									move.l	(a6),d2
	move.w	(a6)+,d2												;8		x
	move.l	d1,d3													;4		y_block pointer
	move.w	(a6),d3													;8		y into lower word for y_block address
	endm


justDraw		
	setupStuffForDrawing												;
;	move.b	#0,$ffffc123
	drawLinePoly											
				
drawTwo
	setupStuffForDrawing
;	move.b	#0,$ffffc123
	drawLinePoly2

drawTwoOnePlaneApart
	setupStuffForDrawing
;	move.b	#0,$ffffc123
	drawLinePoly2_with1bplbetween

drawThree
	setupStuffForDrawing	
;	move.b	#0,$ffffc123
	drawLinePoly3



totalClear 	set 0
totalFill	set 0


generateClear	macro
	move.l	#$21400000+\1+\2*scanLineWidth,d2
	move.w	#200-2*\2-1,d7				
totalClear set totalClear+4*(200-2*\2)
	jsr		generateClearRout2BPL
	endm	

;generateClearRout2BPL
;	move.w	#scanLineWidth,d1
;.loop
;		move.l	d2,(a0)+
;		add.w	d1,d2
;	dbra	d7,.loop
;	rts
;
generateFill	macro
	move.l	#$20280000+\1+\2*scanLineWidth,d2
	move.l	#$B1A80000+\1+\2*scanLineWidth+scanLineWidth,d3
totalFill set totalFill+8*(200-2*\2)
	move.w	#200-2*\2-1,d7
	jsr		generateFillRout
	endm

;generateFillRout
;	move.w	#scanLineWidth,d1
;.loop
;		move.l	d2,(a0)+
;		move.l	d3,(a0)+
;		add.w	d1,d2
;		add.w	d1,d3
;	dbra	d7,.loop
;	rts


totalClear2 	set 0
totalFill2		set 0


generateClear2	macro
	move.l	#$21400000+\1+\2*scanLineWidth,d2
	move.w	#200-2*\2-1,d7				
totalClear2 set totalClear2+4*(200-2*\2)
	jsr		generateClearRout2BPL
	endm	


generateFill2	macro
	move.l	#$20280000+\1+\2*scanLineWidth,d2
	move.l	#$B1A80000+\1+\2*scanLineWidth+scanLineWidth,d3
totalFill2 set totalFill2+8*(200-2*\2)
	move.w	#200-2*\2-1,d7
	jsr		generateFillRout
	endm

;generateClearCode
;	moveq	#-1,d0
;
;
;	move.l	clearScreenPointer,a0
;
;	generateClear	32,58
;	generateClear	40,34
;	generateClear	48,24
;	generateClear	56,12
;	generateClear	64,8
;	generateClear	72,8
;	generateClear	80,8
;	generateClear	88,8
;	generateClear	96,10
;	generateClear	104,20
;	generateClear	112,40
;	generateClear	120,60
;	move.w	#$4e75,(a0)
;
;;	move.l	clearScreenPointer2,a0
;;
;;	generateClear2	40,84
;;	generateClear2	48,54
;;	generateClear2	56,40
;;	generateClear2	64,34
;;	generateClear2	72,24
;;	generateClear2	80,24
;;	generateClear2	88,24
;;	generateClear2	96,34
;;	generateClear2	104,54
;;	generateClear2	112,88
;;	move.w	#$4e75,(a0)
;
;
;	rts




_savedy		ds.l 1

; this rout needs to clear the position of the object from LAST frame, incase the object moves fast;
; so that we dont need to make our mask larger
clear4BPL
	move.l	screenpointer3,a6	
	IF scanLineWidth=160
	ELSE
		add.l	#3*160-33*230,a6
	ENDC
	IFEQ realclear
		move.l	#0,d0
	ELSE
		moveq	#-1,d0
	ENDC

	add.w	object_y_offset,a6

	moveq	#0,d1
	move.w	_oldery,d1
	sub.l	#420,d1

	IF scanLineWidth=160

	add.l	d1,d1		;2
	add.l	d1,d1		;4
	add.l	d1,d1		;8
	move.l	d1,d2		; save 8
	add.l	d1,d1		;16
	add.l	d1,d1		;32
	add.l	d2,d1		;40

	ELSE
	; its already *4 				230 = 128 + 64 + 32 + 6
	move.w	d1,d3	;4
	lsr		d3		;2			
	add.w	d1,d3	;6 = 4+2			
	add.w	d1,d1	;8
	add.w	d1,d1	;16
	add.w	d1,d1	;32
	add.w	d1,d3	;38
	add.w	d1,d1	;64
	add.w	d1,d3	; 64+32+6
	add.w	d1,d1	;128
	add.w	d3,d1		

	ENDC

;	move.l	d1,_savedy
;	add.l	d1,a6

;	sub.l	#40*scanLineWidth,a6

	move.l	d0,d1	;16px																									;1
	move.l	d0,d2																											;1
	move.l	d0,d3	;32px																									;1
	move.l	d0,d4																											;1
	move.l	d0,d5	;48px																									;1
	move.l	d0,d6																											;1
	move.l	d0,d7	;64px																									;1
	move.l	d0,a0																											;1
	move.l	d0,a1	;80px																									;1
	move.l	d0,a2																											;1
	move.l	d0,a3	;96px
	move.l	d0,a4
	move.l	d0,a5	;112px

	lea		x_table_fill,a5
	add.w	_olderx,a5
	add.w	_olderx,a5
	move.l	(a5)+,a4
	add.l	(a5),a6

;o set 0
;	REPT 100
;		move.l	#-1,o(a6)
;o set o+230
;	ENDR


;	rts



	jmp		(a4)

;;; clear 0-3
;;; clear 0-3
;;; clear 0-3
fill1
	move.l	d0,a4
	move.l	d0,a5
	add.l	#172*scanLineWidth,a6

o set -8
	REPT 2
		movem.l	d0-d5,o(a6)
o set o-scanLineWidth
	ENDR

o set o
	REPT 6
		movem.l	d0-d7,o(a6)
o set o-scanLineWidth
	ENDR

o set o-8
	REPT 9
		movem.l	d0-d7/a0-a3,o(a6)
o set o-scanLineWidth
	ENDR

	lea		-17*scanLineWidth+40(a6),a6
	REPT 26-1
		movem.l	d0-d7/a0-a5,-(a6)
		move.l	d0,-(a6)
		move.l	d0,-(a6)
		lea		-scanLineWidth+64(a6),a6
	ENDR
		movem.l	d0-d7/a0-a5,-(a6)
		move.l	d0,-(a6)
		move.l	d0,-(a6)
		lea		-scanLineWidth+72(a6),a6


	REPT 60-1
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d5,-(a6)
		lea		-scanLineWidth+80(a6),a6
	ENDR
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d5,-(a6)
		lea		-scanLineWidth+72(a6),a6

	REPT 4
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d3,-(a6)
		lea		-scanLineWidth+72(a6),a6
	ENDR

	REPT 16-1
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d1,-(a6)
		lea		-scanLineWidth+64(a6),a6
	ENDR
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d1,-(a6)
		lea		-scanLineWidth+8(a6),a6


o set 0
	REPT 11
		movem.l	d0-d7/a0-a3,o(a6)
o set o-scanLineWidth
	ENDR

o set o+8
	REPT 6
		movem.l	d0-d7,o(a6)
o set o-scanLineWidth
	ENDR

	rts
;;; clear 4-7
;;; clear 4-7
;;; clear 4-7
fill2
	move.l	d0,a4
	move.l	d0,a5
	add.l	#174*scanLineWidth,a6
o set 0
	REPT 4
		movem.l	d0-d5,o(a6)
o set o-scanLineWidth
	ENDR

o set o-8
	REPT 5
		movem.l	d0-d7/a0-a1,o(a6)
o set o-scanLineWidth
	ENDR

o set o-8
	REPT 6
		movem.l	d0-d7/a0-a3,o(a6)
o set o-scanLineWidth
	ENDR

	lea		o+56(a6),a6
	REPT 7
		movem.l	d0-d7/a0-a5,-(a6)		;12*4 = 48
		lea		-scanLineWidth+56(a6),a6
	ENDR

	REPT 10-1
		movem.l	d0-d7/a0-a5,-(a6)		;12*4 = 48
		move.l	d0,-(a6)
		move.l	d0,-(a6)
		lea		-scanLineWidth+64(a6),a6
	ENDR
		movem.l	d0-d7/a0-a5,-(a6)		;12*4 = 48
		move.l	d0,-(a6)
		move.l	d0,-(a6)
		lea		-scanLineWidth+72(a6),a6


	REPT 26
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d3,-(a6)
		lea	-scanLineWidth+72(a6),a6
	ENDR

	REPT 28
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d5,-(a6)
		lea	-scanLineWidth+80(a6),a6
	ENDR

	REPT 28-1
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d3,-(a6)
		lea	-scanLineWidth+72(a6),a6
	ENDR
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d3,-(a6)
		lea	-scanLineWidth+64(a6),a6


	REPT 5
		movem.l	d0-d7/a0-a5,-(a6)		;12*4 = 48
		move.l	d0,-(a6)
		move.l	d0,-(a6)
		lea		-scanLineWidth+64(a6),a6
	ENDR


	REPT 9-1
		movem.l	d0-d7/a0-a5,-(a6)		;12*4 = 48
		lea		-scanLineWidth+56(a6),a6
	ENDR
		movem.l	d0-d7/a0-a5,-(a6)		;12*4 = 48
		lea		-scanLineWidth(a6),a6

o set 0
	REPT 6
		movem.l	d0-d7/a0-a3,o(a6)		;12*4 = 48
o set o-scanLineWidth
	ENDR

o set o+8
	REPT 3
		movem.l	d0-d7/a0-a1,o(a6)
o set o-scanLineWidth
	ENDR

	REPT 5
		movem.l	d0-d7,o(a6)
o set o-scanLineWidth
	ENDR



	rts
;;; clear 8-11
;;; clear 8-11
;;; clear 8-11
fill3
	move.l	d0,a4
	move.l	d0,a5
	add.l	#174*scanLineWidth,a6
o set 0
	REPT 6
		movem.l	d0-d5,o(a6)
o set o-scanLineWidth
	ENDR

o set o-8
	REPT 9
		movem.l	d0-d7/a0-a1,o(a6)
o set o-scanLineWidth
	ENDR

o set o-8
	REPT 15
		movem.l	d0-d7/a0-a5,o(a6)
o set o-scanLineWidth
	ENDR

	lea	o+64(a6),a6

	REPT 86
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d3,-(a6)
		lea		-scanLineWidth+72(a6),a6
	ENDR

o set -64
	REPT 15
		movem.l	d0-d7/a0-a5,o(a6)
o set o-scanLineWidth
	ENDR

o set o+8
	REPT 8
		movem.l	d0-d7/a0-a1,o(a6)
o set o-scanLineWidth
	ENDR

o set o+8
	REPT 3
		movem.l	d0-d5,o(a6)
o set o-scanLineWidth
	ENDR


	rts
;;; clear 12-15
;;; clear 12-15
;;; clear 12-15
fill4
	move.l	d0,a4
	move.l	d0,a5
	add.l	#174*scanLineWidth,a6

o set 0
	REPT 6
		movem.l	d0-d5,o(a6)
o set o-scanLineWidth
	ENDR

o set o-8
	REPT 6
		movem.l	d0-d7/a0-a1,o(a6)
o set o-scanLineWidth
	ENDR	


	REPT 6
		movem.l	d0-d7/a0-a3,o(a6)
o set o-scanLineWidth
	ENDR	

o set o-8
	REPT 7
		movem.l	d0-d7/a0-a5,o(a6)
o set o-scanLineWidth
	ENDR

	lea	-25*scanLineWidth+48(a6),a6
	REPT 13
		movem.l	d0-d7/a0-a5,-(a6)
		move.l	d0,-(a6)
		move.l	d0,-(a6)
		lea		-scanLineWidth+64(a6),a6
	ENDR

	REPT 18-1
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d3,-(a6)
		lea		-scanLineWidth+72(a6),a6
	ENDR
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d3,-(a6)
		lea		-scanLineWidth+80(a6),a6

	REPT 52-1
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d5,-(a6)
		lea		-scanLineWidth+80(a6),a6
	ENDR
		movem.l	d0-d7/a0-a5,-(a6)
		movem.l	d0-d5,-(a6)
		lea		-scanLineWidth+72(a6),a6

	REPT 20-1
		movem.l	d0-d7/a0-a5,-(a6)
		move.l	d0,-(a6)
		move.l	d0,-(a6)
		lea		-scanLineWidth+64(a6),a6
	ENDR
		movem.l	d0-d7/a0-a5,-(a6)
		move.l	d0,-(a6)
		move.l	d0,-(a6)
		lea		-scanLineWidth+56(a6),a6

o set -48
	REPT 8
		movem.l	d0-d7/a0-a3,o(a6)
o set o-scanLineWidth
	ENDR		

o set o+8
	REPT 6
		movem.l	d0-d7,o(a6)
o set o-scanLineWidth
	ENDR		



	rts






	; 9 nop per 5 lines	unfilled
	; 5 nop waste 
	;	14 * 4 = 64 cycles per 5 scanlines
	;	4 lines of eorfill in 5 scanlines	--> 102 lines -> 102/4*64		==> 1632 lost + 384 ~ 2100 cycles gone
	;
	; lines of sync code:	102/4*5= 127,5 + 32 = 160 lines of sync
	;	13 nops per line of sync, 160*13*4 = 160*52 = 8320


; 30 lines	with 1:1
; 104 lines with 4:5 => 20 lines in top border


	; center is 80

;f set 28*160+56
;minus set 0
;	REPT 7
;o set f
;		REPT 4
;			move.l	d0,o(a6)
;o set o+8
;		ENDR
;f set f+160
;	ENDR
;
;
;	REPT 5
;o set f
;		REPT 5
;			move.l	d0,o(a6)
;o set o+8
;		ENDR
;f set f+160
;	ENDR
;
;
;
;f set f-8
;	REPT 6
;o set f
;		REPT 6
;			move.l	d0,o(a6)
;o set o+8
;		ENDR
;f set f+160
;	ENDR
;
;	REPT 6
;o set f 
;		REPT 7
;			move.l	d0,o(a6)
;o set o+8
;		ENDR
;f set f+160
;	ENDR
;
;
;f set f-8
;	REPT 9
;o set f 
;		REPT 8
;			move.l	d0,o(a6)
;o set o+8
;		ENDR
;f set f+160
;	ENDR
;
;	REPT 78
;o set f
;		REPT 9
;			move.l	d0,o(a6)
;o set o+8
;		ENDR
;f set f+160
;	ENDR
;
;
;	REPT 10
;o set f
;		REPT 8
;			move.l	d0,o(a6)
;o set o+8
;		ENDR
;f set f+160
;	ENDR
;
;
;f set f+8
;	REPT 4
;o set f 
;		REPT 7
;			move.l	d0,o(a6)
;o set o+8
;		ENDR
;f set f+160
;	ENDR
;
;
;	REPT 9
;o set f 
;		REPT 6
;			move.l	d0,o(a6)
;o set o+8
;		ENDR
;f set f+160
;	ENDR
;
;f set f+8
;	REPT 5
;o set f 
;		REPT 5
;			move.l	d0,o(a6)
;o set o+8
;		ENDR
;f set f+160
;	ENDR
;
;f set f+8
;
;	REPT 4
;o set f 
;		REPT 3
;			move.l	d0,o(a6)
;o set o+8
;		ENDR
;f set f+160
;	ENDR

genXTableFill
	lea		x_table_fill,a0
	move.l	#fill1,d1
	move.l	#fill2,d2
	move.l	#fill3,d3
	move.l	#fill4,d4
	move.l	#-8,d5
	move.w	#30-1,d7
.l
	REPT 4
		move.l	d1,(a0)+
		move.l	d5,(a0)+
	ENDR
	REPT 4
		move.l	d2,(a0)+
		move.l	d5,(a0)+
	ENDR
	REPT 4
		move.l	d3,(a0)+
		move.l	d5,(a0)+
	ENDR
	REPT 4
		move.l	d4,(a0)+
		move.l	d5,(a0)+
	ENDR
	add.l	#8,d5
	dbra	d7,.l


	lea		x_table_eor,a0
	move.l	#eor1,d1
	move.l	#eor2,d2
	move.l	#eor3,d3
	move.l	#eor4,d4
	move.l	#-16,d5
	move.w	#30-1,d7
.l2
	REPT 4
		move.l	d1,(a0)+
		move.l	d5,(a0)+
	ENDR
	REPT 4
		move.l	d2,(a0)+
		move.l	d5,(a0)+
	ENDR
	REPT 4
		move.l	d3,(a0)+
		move.l	d5,(a0)+
	ENDR
	REPT 4
		move.l	d4,(a0)+
		move.l	d5,(a0)+
	ENDR
	add.l	#8,d5
	dbra	d7,.l2
	rts

;this is generated now
	IFEQ STANDALONE
x_table_eor	ds.b	3900
x_table_fill ds.b	3900
	ENDC
;x_table_fill							;60*16*8 = 7680
;off set -8
;	REPT 30
;		dc.l	fill1,off
;		dc.l	fill1,off
;		dc.l	fill1,off
;		dc.l	fill1,off
;		dc.l	fill2,off
;		dc.l	fill2,off
;		dc.l	fill2,off
;		dc.l	fill2,off
;		dc.l	fill3,off
;		dc.l	fill3,off
;		dc.l	fill3,off
;		dc.l	fill3,off
;		dc.l	fill4,off
;		dc.l	fill4,off
;		dc.l	fill4,off
;		dc.l	fill4,off
;off set off+8
;	ENDR
;
;off set -16
;x_table_eor
;	REPT 30
;		dc.l	eor1,off
;		dc.l	eor1,off
;		dc.l	eor1,off
;		dc.l	eor1,off
;		dc.l	eor2,off
;		dc.l	eor2,off
;		dc.l	eor2,off
;		dc.l	eor2,off
;		dc.l	eor3,off
;		dc.l	eor3,off
;		dc.l	eor3,off
;		dc.l	eor3,off
;		dc.l	eor4,off
;		dc.l	eor4,off
;		dc.l	eor4,off
;		dc.l	eor4,off
;off set off+8
;	ENDR


;eorFill4BPL
;	move.l	screenpointer2,a3										;20			5
;	lea		x_table_eor,a0											;8			2
;	add.w	_vertices_xoff,a0										;20			5
;	add.w	_vertices_xoff,a0										;20			5
;	move.l	(a0)+,a1												;12			3
;	add.l	(a0)+,a3												;16			4
;
;	add.l	_savedy,a3												;20			5
;	lea		4*160+scanLineWidth(a3),a4									;8			2
;	jmp		(a1)													;8			2 --> 33 nops

hsLeftBorder	macro
	move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
	move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
	endm
hsRightBorder	macro
	move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
	nop																		;1
	move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
	endm
hsStabilize	macro
	move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
	nop
	move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
	endm

write7 macro
	eor.l	d0,(\1)+
	eor.l	d1,(\1)+
	eor.l	d2,(\1)+
	eor.l	d3,(\1)+
	eor.l	d4,(\1)+
	eor.l	d5,(\1)+
	eor.l	d6,(\1)+
	endm

helpa2	macro
;;;;;;;;;;;;;
	hsLeftBorder
		move.l	#-1,(a2)+
		move.l	#-1,(a2)+
		move.l	#-1,(a2)+
		move.l	#-1,(a2)+
		move.l	#-1,(a2)+
		move.l	#-1,(a2)+
	REPT 90-36
		nop
	ENDR
	hsRightBorder
	REPT 12
		nop
	ENDR
	hsStabilize
	REPT 12
		nop
	ENDR	
	endm

helpa4	macro
;;;;;;;;;;;;;
	hsLeftBorder
		move.l	#-1,(a4)+
		move.l	#-1,(a4)+
		move.l	#-1,(a4)+
		move.l	#-1,(a4)+
		move.l	#-1,(a4)+
		move.l	#-1,(a4)+
	REPT 90-36
		nop
	ENDR
	hsRightBorder
	REPT 12
		nop
	ENDR
	hsStabilize
	REPT 12
		nop
	ENDR	
	endm

terminate	macro
;;;; template
	REPT 142

	hsLeftBorder
	move.w	#$666,$ffff8240
;		REPT 90-4
		REPT 90-4
			nop
		ENDR
	hsRightBorder
		REPT 12
			nop
		ENDR
	hsStabilize
		REPT 12
			nop
		ENDR
	ENDR
	move.w	#$333,$ffff8240
	popall
	rte
	endm

	IF	scanLineWidth=230



	dc.l	eor1label_105
	dc.l	eor1label_106
	dc.l	eor1label_107
	dc.l	eor1label_108
	dc.l	eor1label_109
	dc.l	eor1label_110
	dc.l	eor1label_111
	dc.l	eor1label_112
	dc.l	eor1label_113
	dc.l	eor1label_114
	dc.l	eor1label_115
	dc.l	eor1label_116
	dc.l	eor1label_117
	dc.l	eor1label_118
	dc.l	eor1label_119
	dc.l	eor1label_120
	dc.l	eor1label_121
	dc.l	eor1label_122
	dc.l	eor1label_123
	dc.l	eor1label_124
	dc.l	eor1label_125
	dc.l	eor1label_126
	dc.l	eor1label_127
	dc.l	eor1label_128
	dc.l	eor1label_129
	dc.l	eor1label_130
	dc.l	eor1label_131
	dc.l	eor1label_132
	dc.l	eor1label_133
	dc.l	eor1label_134
	dc.l	eor1label_135
	dc.l	eor1label_136
	dc.l	eor1label_137
	dc.l	eor1label_138
	dc.l	eor1label_139
	dc.l	eor1label_140
	dc.l	eor1label_141
eor1
	ENDC
;;;;;;;;;;	1
	nop
	nop
	nop
	nop
eor1label_001
	hsLeftBorder
		REPT 90-89
			nop
		ENDR
		movem.l	(a3)+,d0-d6							; read 7
		eor.l	d0,(a4)+					
		eor.l	d1,(a4)+					
		eor.l	d2,(a4)+					
		eor.l	d3,(a4)+					
		eor.l	d4,(a4)+					
		eor.l	d5,(a4)+					
		eor.l	d6,(a4)+					
		move.l	(a3)+,d0							; read 8
		eor.l	d0,(a4)+							; write 8
		lea		scanLineWidth-32(a3),a3				; update read
		lea		scanLineWidth-32(a4),a4				; update write
		movem.l	(a3)+,d0-d6							; read 7
		eor.l	d0,(a4)+							; write 1
		move.l	(a3)+,d0							; read 8
	hsRightBorder
		REPT 12-12
			nop
		ENDR
		lea		scanLineWidth-32(a3),a3				; update read
		eor.l	d1,(a4)+							
		eor.l	d2,(a4)+							;write 3
	hsStabilize
		REPT 12-12
			nop
		ENDR
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+							; write 5
		lea		scanLineWidth-32+12(a4),a2			; update write alt
;;;;;;;;;;;;;;;;;;;;;;;;; 2
eor1label_002
	hsLeftBorder
		REPT 90-90
			nop
		ENDR
		eor.l	d5,(a4)+					;5
		eor.l	d6,(a4)+					;10
		eor.l	d0,(a4)+					;15		write 8							;2 write
		movem.l	(a3)+,d0-d6					;32		read 7
		eor.l	d0,(a2)+					;37
		eor.l	d1,(a2)+					;42
		eor.l	d2,(a2)+					;47
		eor.l	d3,(a2)+					;52
		eor.l	d4,(a2)+					;57
		eor.l	d5,(a2)+					;62
		eor.l	d6,(a2)+					;67		write 7
		move.l	(a3)+,d0					;70		read 8						;3 read
		eor.l	d0,(a2)+					;75		write 8						;3 write
		lea		scanLineWidth-32(a3),a3		;77		updtate read
		movem.l	(a3)+,d0-d4					;90		read 5
	hsRightBorder
		REPT 12-12
			nop
		ENDR
		lea		scanLineWidth-32(a2),a4		;2		; update write
		eor.l	d0,(a4)+					;7
		eor.l	d1,(a4)+					;12		; write 2
	hsStabilize
		REPT 12-12
			nop
		ENDR	
		eor.l	d2,(a4)+					;5
		eor.l	d3,(a4)+					;10		; write 4
		lea		scanLineWidth-32+16(a4),a2	;12		; updare write alt


;;;;;;;;;; 3
eor1label_003
	hsLeftBorder
		REPT 90-90
			nop
		ENDR
		eor.l	d4,(a4)+					;5		; write 5
		move.l	(a3)+,d0					;8		read 6
		eor.l	d0,(a4)+					;13		write 6
		move.l	(a3)+,d0					;16		read 7
		move.l	(a3)+,d1					;19		read 8						;4 read
		eor.l	d0,(a4)+					;24
		eor.l	d1,(a4)+					;29		write 8						;4 write
		lea		scanLineWidth-32(a3),a3		;31		update read
		movem.l	(a3)+,d0-d6					;48		read 7
		eor.l	d0,(a2)+					;53	
		eor.l	d1,(a2)+					;58
		eor.l	d2,(a2)+					;63
		eor.l	d3,(a2)+					;68
		eor.l	d4,(a2)+					;73
		eor.l	d5,(a2)+					;78
		eor.l	d6,(a2)+					;83		write 7
		move.l	(a3)+,d6					;86		read 8							;5 read
		lea		scanLineWidth-40(a3),a3		;88		update read
		lea		scanLineWidth-40+4(a2),a4	;90		update write alt

	hsRightBorder
		REPT 12-11
			nop
		ENDR
		eor.l	d6,(a2)+					;5		write 8						;5 write		;;------> NEWNEWNEWNWNEWNEW
		move.l	(a3)+,d0					;3
		move.l	(a3)+,d1					;3		read 2

	hsStabilize
		REPT 12-12
			nop
		ENDR
		eor.l	d0,(a4)+					;5
		eor.l	d1,(a4)+					;10		write 2
		lea		scanLineWidth-40+32(a3),a1	;12		update read
;;;;;;;;4
eor1label_004
	hsLeftBorder
		REPT 90-89
			nop
		ENDR
		movem.l	(a3)+,d0-d6					;17		read 9
		eor.l	d0,(a4)+					;22
		eor.l	d1,(a4)+					;27
		eor.l	d2,(a4)+					;32
		eor.l	d3,(a4)+					;37
		eor.l	d4,(a4)+					;42
		eor.l	d5,(a4)+					;47
		eor.l	d6,(a4)+					;52
		move.l	(a3)+,d0					;55
		eor.l	d0,(a4)+					;60
		move.l	(a3)+,d0					;63
		eor.l	d0,(a4)+					;68
		move.l	(a3)+,d0					;71			read 12					;1 read (2)
		eor.l	d0,(a4)+					;76			write 12				;1 write (2)				write 1, 10 left

		movem.l	(a1)+,d0-d4					;89			read 5

	hsRightBorder
		REPT 12-12
			nop
		ENDR
		lea		scanLineWidth-48(a4),a4		;2			update write
		eor.l	d0,(a4)+					;7			write
		eor.l	d1,(a4)+					;12			write 2
	hsStabilize
		REPT 12-12
			nop
		ENDR
		eor.l	d2,(a4)+					;5
		eor.l	d3,(a4)+					;10			write 4
		lea		scanLineWidth-48+32(a4),a2	;12			update write
;;;;;;;;;;5
eor1label_005

	hsLeftBorder
		eor.l	d4,(a4)+					;5			write 5
		movem.l	(a1)+,d0-d6					;22			read 12					2 read
		eor.l	d0,(a4)+					;27
		eor.l	d1,(a4)+					;32
		eor.l	d2,(a4)+					;37
		eor.l	d3,(a4)+					;42
		eor.l	d4,(a4)+					;47
		eor.l	d5,(a4)+					;52
		eor.l	d6,(a4)+					;57			write 12				2 write						write 2, 9 left
		lea		scanLineWidth-48(a1),a3		;59			
		movem.l	(a3)+,d0-d4					;72			read 5
		eor.l	d0,(a2)+					;77
		eor.l	d1,(a2)+					;82
		eor.l	d2,(a2)+					;87			write 3
		move.l	(a3)+,d5					;90			;read 6

		REPT 90-90
			nop
		ENDR

	hsRightBorder
		REPT 12-12
			nop
		ENDR
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+					; write 5
		lea		scanLineWidth-48+28(a2),a4	;12			update write
	hsStabilize
		REPT 12-11
			nop
		ENDR
		eor.l	d5,(a2)+					;write 6
		move.l	(a3)+,d0					
		move.l	(a3)+,d1					;read 8
;;;;;;;;	6
eor1label_006
	hsLeftBorder
		eor.l	d0,(a2)+					;5
		eor.l	d1,(a2)+					;10				write 8
		movem.l	(a3)+,d0-d3					;21				read 12
		eor.l	d0,(a2)+					;26
		eor.l	d1,(a2)+					;31
		eor.l	d2,(a2)+					;36
		eor.l	d3,(a2)+					;41				write 12											3 write, 8 left
		lea		scanLineWidth-48(a3),a3		;43			read
		movem.l	(a3)+,d0-d6					;60				read 7
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+					;
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+					;90				write 6

		REPT 90-90
			nop
		ENDR
	hsRightBorder
		REPT 12-11
			nop
		ENDR
		movem.l	(a3)+,d0-d3					;11			;read 11
	hsStabilize
		REPT 12-12
			nop
		ENDR
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+					;			; write 8
		lea		scanLineWidth-48+4(a3),a1		;43			read

;;;;;;;7

eor1label_007
	hsLeftBorder	
		eor.l	d1,(a4)+				;5
		eor.l	d2,(a4)+				;10
		eor.l	d3,(a4)+				;15
		move.l	(a3)+,d0				;18; read 12
		eor.l	d0,(a4)+				;23	; write 12							4 write			;23				7l
		lea		scanLineWidth-48(a4),a4		;25
		movem.l	(a1)+,d0-d6					;42 read 7
		eor.l	d0,(a4)+					
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+					;77		write 7
		movem.l	(a1)+,d0-d4					; read 12 90

		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-48(a1),a3		;43			read
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+					; write 11
		lea		scanLineWidth-48+4(a4),a2	
		REPT 12-12
			nop
		ENDR

;;;;;;;;;8
eor1label_008
	hsLeftBorder
		eor.l	d4,(a4)+						; 5 write
		movem.l	(a3)+,d0-d6				; read 7				22
		eor.l	d0,(a2)+					
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+				;57
		movem.l	(a3)+,d0-d4				;70				;read 12
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+				;90
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d4,(a2)+								; write 12					5 write				6l
		lea		scanLineWidth-48(a3),a3		
		lea		scanLineWidth-48(a2),a4
		move.l	(a3)+,d0									; read 1
		REPT 12-12
			nop
		ENDR
	hsStabilize
		movem.l	(a3)+,d1-d4								; read 5
		REPT 12-11
			nop
		ENDR



;;;;;;9
eor1label_009
	hsLeftBorder
		eor.l	d0,(a4)+							;5
		eor.l	d1,(a4)+							;10
		eor.l	d2,(a4)+							;15
		eor.l	d3,(a4)+							;20
		eor.l	d4,(a4)+							;25 write 5		25
		movem.l	(a3)+,d0-d6							;42 read 12		42
		eor.l	d0,(a4)+							;47
		eor.l	d1,(a4)+							;52
		eor.l	d2,(a4)+							;57 
		eor.l	d3,(a4)+							;62
		eor.l	d4,(a4)+							;67
		eor.l	d5,(a4)+							;72
		eor.l	d6,(a4)+							;77		write 12				6 write				5l
		lea		scanLineWidth-48(a3),a3				;79
		movem.l	(a3)+,d0-d3							;90		read 4


		REPT 90-90
			nop
		ENDR
	hsRightBorder
		lea		scanLineWidth-48(a4),a2		;2
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+

		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+							; write 4
		lea		scanLineWidth-48+32(a2),a4		;2
		REPT 12-12
			nop
		ENDR

;;;;;;;;;;10
eor1label_010
	hsLeftBorder
		movem.l	(a3)+,d0-d6						;17 	read 11	
		write7	a2								;52 	write 11
		move.l	(a3)+,d0						;55		r12
		eor.l	d0,(a2)+						;60		w12				;7 write		4l
		lea		scanLineWidth-48(a3),a3			;62
		movem.l	(a3)+,d0-d6						;79		r7
		eor.l	d0,(a4)+						;84
		eor.l	d1,(a4)+						;89
		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+						;w4
		lea		scanLineWidth-48+32(a4),a2		;2
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+						;w6
		lea		scanLineWidth-48+20(a3),a1
		REPT 12-12
			nop
		ENDR


;;11
eor1label_011
	hsLeftBorder
		eor.l	d6,(a4)+						;7
		movem.l	(a3)+,d0-d4						;r12
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+				
		eor.l	d4,(a4)+						;w12 30+13 = 43					8 write 3l
		movem.l	(a1)+,d0-d6						;r7 60
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+						;90 w6

		REPT 90-90
			nop
		ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3						;r11
		REPT 12-11
			nop
		ENDR
	hsStabilize
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+						;w8
		lea		scanLineWidth-48+4(a1),a3
		REPT 12-12
			nop
		ENDR


;;12
eor1label_012
	hsLeftBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+						;w11
		move.l	(a1)+,d0
		eor.l	d0,(a2)+						;w12	23						9 write 2l

		movem.l	(a3)+,d0-d6						;r7		40
		lea		scanLineWidth-48(a2),a4			;2 42
		write7 a4								;w7 77
		movem.l	(a3)+,d0-d4						;r12
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+						;w9
		lea		scanLineWidth-48(a3),a1			
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-48+4(a4),a2	
		REPT 12-12
			nop
		ENDR


;13
eor1label_013
	hsLeftBorder
		eor.l	d4,(a4)+					;w12			5							10w, 2l
		movem.l	(a1)+,d0-d6					;r7	22			22
		write7	a2							;w7 57			
		movem.l	(a1)+,d0-d4					;r12	70
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+					;w11 90
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d4,(a2)+					;w12								11,w	1l
		lea		scanLineWidth-48(a2),a4		
		lea		scanLineWidth-48(a1),a3		
		move.l	(a3)+,d0					;r1
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d0,(a4)+					;w1	5
		move.l	(a3)+,d1
		move.l	(a3)+,d2					;r3
		REPT 12-11
			nop
		ENDR


;;;14
eor1label_014
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+					;w3			10
		movem.l	(a3)+,d0-d6					;r10		27
		write7	a4							;w10		62
		move.l	(a3)+,d0	
		eor.l	d0,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+					;w12		78								12w, 0l
		lea		scanLineWidth-56(a3),a3		;2			80
		lea		scanLineWidth-56(a4),a4		;2			82
		move.l	(a3)+,d0					;r1
		eor.l	d0,(a4)+					;w1

		REPT 90-90
			nop
		ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3					;r5

		REPT 12-11
			nop
		ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+						;w3
		lea		scanLineWidth-64+52(a4),a2		;2			80
		REPT 12-12
			nop
		ENDR
;;;15
eor1label_015	
	hsLeftBorder
		eor.l	d2,(a4)+	
		eor.l	d3,(a4)+						;w5
		movem.l	(a3)+,d0-d6						;r12
		write7	a4								;w12		62

		movem.l	(a3)+,d0-d3						;r16		73
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		
		lea		scanLineWidth-64(a3),a1			;90

		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d3,(a4)+						;w16									1w, 15l
		move.l	(a1)+,d0		
		move.l	(a1)+,d1						;r2				
		REPT 12-11
			nop
		ENDR
	hsStabilize
		lea		scanLineWidth-64(a4),a2
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+						;w2
		REPT 12-12
			nop
		ENDR

;;;16
eor1label_016
	hsLeftBorder
		movem.l	(a1)+,d0-d6						;r9		17
		write7 a2								;w9		52
		movem.l	(a1)+,d0-d6						;r16	69
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+						;w13
		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		lea		scanLineWidth-64(a1),a3
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d6,(a2)+						;w16								2w,14l
		move.l	(a3)+,d0
		move.l	(a3)+,d1						;r2
		REPT 12-11
			nop
		ENDR

;;;;17
eor1label_017
	hsLeftBorder
		lea		scanLineWidth-64(a2),a4			;2
		eor.l	d0,(a4)+
		eor.l	d0,(a4)+						;w2		12
		movem.l	(a3)+,d0-d6						;r9		29
		write7	a4								;54	w	64
		movem.l	(a3)+,d0-d6						;r16	81
		lea		scanLineWidth-64(a3),a1			;83
		eor.l	d0,(a4)+						;w10
		lea		scanLineWidth(a1),a3			;90
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+						;w12
		lea		scanLineWidth-64+16(a4),a2
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+						;w14
		REPT 12-10
			nop
		ENDR

;;;18
eor1label_018
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+					;w16	10										3w,13l
		movem.l	(a1)+,d0-d6					;r7		27
		write7	a2							;w7		62
		movem.l	(a1)+,d0-d6					;r14	79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+					;w9		89

		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-64+20(a2),a4
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d4,(a2)+					;w12
		move.l	(a1)+,d0
		move.l	(a1)+,d1					;r16
		REPT 12-11
			nop
		ENDR

;;;19
eor1label_019
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+					;w16				4w, 12l
		movem.l	(a3)+,d0-d6					;37
		write7	a4							;72	w7
		movem.l	(a3)+,d0-d6					;89	r14
		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-64+8(a3),a1
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+					;w11
		lea		scanLineWidth-64+20(a4),a2
		REPT 12-12
			nop
		ENDR

;;; 20
eor1label_020
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+					;w14
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+					;w16	31			5w,11l
		movem.l	(a1)+,d0-d6					;r7		48
		write7	a2							;w7		83
		move.l	(a1)+,d0
		move.l	(a1)+,d1					;r9

		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+					;w9
		lea		scanLineWidth-64+28(a1),a3
		REPT 12-12
			nop
		ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3					;r13
		REPT 12-11
			nop
		ENDR

;;;;;21
eor1label_021
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		move.l	(a1)+,d0
		eor.l	d0,(a2)+
		move.l	(a1)+,d0
		eor.l	d0,(a2)+
		move.l	(a1)+,d0
		eor.l	d0,(a2)+					;w16	44				6w,10l
		movem.l	(a3)+,d0-d6					;r7		61
		lea		scanLineWidth-64(a2),a4		;2		63
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+					;88
		lea		scanLineWidth-64+44(a4),a2	;90
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		lea		scanLineWidth-64+36(a3),a1
		REPT 12-12
			nop
		ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3					;r11
		REPT 12-11
			nop
		ENDR

;;;;;;;;;;;;;;;;;22
eor1label_022
	hsLeftBorder
		eor.l	d0,(a4)+					;5
		eor.l	d1,(a4)+					;10
		eor.l	d2,(a4)+					;15
		eor.l	d3,(a4)+					;20		w11
		movem.l	(a3)+,d0-d4					;33			r16
		eor.l	d0,(a4)+					;38
		eor.l	d1,(a4)+					;43
		eor.l	d2,(a4)+					;48
		eor.l	d3,(a4)+					;53
		eor.l	d4,(a4)+					;58		w16		7w,9l
		movem.l	(a1)+,d0-d6					;r7 75
		eor.l	d0,(a2)+					;80
		eor.l	d1,(a2)+					;85
		eor.l	d2,(a2)+

		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		lea		scanLineWidth-64+36(a1),a3
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+					;w7
		lea		scanLineWidth-64+36(a2),a4
		REPT 12-12
			nop
		ENDR
;;;;;
;;;;;;;;;;;;;;;;;23
eor1label_023
	hsLeftBorder
		movem.l	(a1)+,d0-d6				;r14	17
		write7	a2						;w14	52
		move.l	(a1)+,d0
		eor.l	d0,(a2)+
		move.l	(a1)+,d0
		eor.l	d0,(a2)+				;w16	68			8w,8l
		movem.l	(a3)+,d0-d6				;r7		85
		eor.l	d0,(a4)+				;80
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d1,(a4)+				;85
		eor.l	d2,(a4)+				;90	w3
		lea		scanLineWidth-64+52(a4),a2
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+				;w5
		lea		scanLineWidth-64+36(a3),a1
		REPT 12-12
			nop
		ENDR
;;;;; 24
eor1label_024
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+				;10	w7
		movem.l	(a3)+,d0-d6				;27	r14
		write7	a4						;62	w14
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+				;78	r16/w16		9w,7l
		movem.l	(a1)+,d0-d3 			;r4				;
		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-64+48(a1),a3

		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-64+48(a2),a4
		REPT 12-12
			nop
		ENDR

;;;;;;;;;;;;;;;;;25

eor1label_025
	hsLeftBorder
		movem.l	(a1)+,d0-d6			;r11
		write7	a2					;52
		movem.l	(a1)+,d0-d4			;r16	65
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+			;90	w16				10,6l
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3			;11	r4
		REPT 12-11
			nop
		ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-64+48(a3),a1
		REPT 12-12
			nop
		ENDR

;;;;;26
eor1label_026
;;;;;;;;;;;;;;;;;
	hsLeftBorder
		eor.l	d2,(a4)+			;			5
		eor.l	d3,(a4)+			;w4			10
		movem.l	(a3)+,d0-d6			;r11		27
		write7	a4					;w11		62

		movem.l	(a3)+,d0-d4			;13			75
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+			;90

		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+			;w16					11,5l
		lea		scanLineWidth-64(a4),a2
		REPT 12-12
			nop
		ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3			;11			;r4
		REPT 12-11		
			nop
		ENDR

;;;;;27
eor1label_027
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;20				w4
		movem.l	(a1)+,d0-d6		;37				r11
		write7	a2				;w11	72
		movem.l	(a1)+,d0-d4		;13		85
		eor.l	d0,(a2)+		;w12
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		lea		scanLineWidth-64(a1),a3
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w16						12,4
		lea		scanLineWidth-64(a2),a4
		REPT 12-12
			nop
		ENDR

;;;;;;;;;;;; 30
eor1label_028
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7	17
		write7	a4				;w7	52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		;74	
		eor.l	d1,(a4)+		;79
		eor.l	d2,(a4)+		;84
		eor.l	d3,(a4)+		;89
		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w13
		lea		scanLineWidth-64+8(a3),a1
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d6,(a4)+		;w14
		move.l	(a3)+,d0	
		move.l	(a3)+,d1		;r16
		REPT 12-11
			nop
		ENDR

;;;;;;;31
eor1label_029
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+			;w16				13,3
		movem.l	(a1)+,d0-d6			;r7		27
		lea		scanLineWidth-64(a4),a2	;29
		write7	a2					;64		w7
		movem.l	(a1)+,d0-d6			;r14	81
		eor.l	d0,(a2)+			;	w8	86
		move.l	(a1)+,d0			;r15
		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		lea		scanLineWidth-64+4(a1),a3
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+				;w12
		lea		scanLineWidth-64+16(a2),a4
		REPT 12-12
			nop
		ENDR
;;;;;;;;32
eor1label_030
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		move.l	(a1)+,d0		;r16	
		eor.l	d0,(a2)+		;w16		23			14,2
		movem.l	(a3)+,d0-d6		;r7			40
		write7	a4				;w7			75
		movem.l	(a3)+,d0-d5		;r13		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-64+12(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-64+20(a4),a2
	REPT 12-12
		nop
	ENDR
;;;;;
;;;;;;;;33
eor1label_031
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+			;34		w16		15,1
		movem.l	(a1)+,d0-d6			;51		r7
		write7	a2					;86		w7
		move.l	(a1)+,d0			;89		r8

	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+			;5	w8
		move.l	(a1)+,d0
		move.l	(a1)+,d1			;r10
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			;w10
		lea		scanLineWidth-72+24(a1),a3
	REPT 12-12
		nop
	ENDR

;;;;;
;;;;;
;;;;;;;;34
eor1label_032
	hsLeftBorder
		movem.l	(a1)+,d0-d5		;r16
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;45		;w16		16,0
		lea		scanLineWidth-72(a2),a4		;47								0,4!
		movem.l	(a3)+,d0-d6		;r7		64
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+	;w7
		lea		scanLineWidth-72+44(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR

;;;;;
;;;;;
;;;;;;;;35
eor1label_033
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+			;20	w11
		movem.l	(a3)+,d0-d6			;r18		37
		write7	a4					;w18		72						1,3
		lea		scanLineWidth-72(a4),a2	;74
		movem.l	(a1)+,d0-d5			;r6
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-72+48(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-72+56(a2),a4
	REPT 12-12
		nop
	ENDR
;;;;;
;;;;;
;;;;;;;;36
eor1label_034
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+			;w6	10
		movem.l	(a1)+,d0-d6			;r13	27
		write7	a2					;w13	62
		movem.l	(a1)+,d0-d4			;r18	75							
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			;85	w15
		eor.l	d2,(a2)+			;90 16
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+			;w18										2,2
		lea		scanLineWidth-72(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3			;11	r4
	REPT 12-11
		nop
	ENDR
;;;;;
;;;;;;;;37
eor1label_035
	hsLeftBorder
		lea		scanLineWidth-72(a2),a4	;2
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+				;22
		movem.l	(a3)+,d0-d6				;r11	39
		write7	a4						;w11	74
		movem.l	(a3)+,d0-d5				;r17	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-72+4(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+			;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
;;;;;
;;;;;
;;;;;;;;38
eor1label_036
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+					;18			;w18				3,1
		movem.l	(a1)+,d0-d6					;r7
		write7	a2							;70	w7
		movem.l	(a1)+,d0-d6					;87	r14
		lea		scanLineWidth-72+16(a1),a3	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+				;w9
		lea		scanLineWidth-72+36(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+				;w11
	REPT 12-10
		nop
	ENDR
;;;;;
;;;;;
;;;;;;;;39
eor1label_037
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+			;w14			15

		movem.l	(a1)+,d0-d3				
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+			;46	w18/r18								4,0!
		lea		scanLineWidth-72(a1),a3		;48
		movem.l	(a3)+,d0-d6					;65
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+					;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+				;w7
		lea		scanLineWidth-72+44(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3				;r11
	REPT 12-11
		nop
	ENDR

;;;;;
;;;;;;;;40
eor1label_038
	hsLeftBorder
		eor.l	d0,(a4)+			
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11	20
		movem.l	(a3)+,d0-d6		;r18	37
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w18	72
		move.l	(a3)+,d0		;		75
		eor.l	d0,(a4)+		;		80
		move.l	(a3)+,d0		;		83
		eor.l	d0,(a4)+		;		88	W20									1,59
		lea		scanLineWidth-80(a3),a1	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+				;w2
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR

;;;;;
;;;;;;;;41
eor1label_039
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;	w4		10
		movem.l	(a1)+,d0-d6		;	r11		27
		write7	a2				;	w11		62
		movem.l	(a1)+,d0-d6		;	r18		79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;	w13		89

	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		; w15
		lea		scanLineWidth-80+8(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+		;w16
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r20
	REPT 12-11
		nop
	ENDR

;;;;;;;;42
eor1label_040
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w20						2,58
		movem.l	(a3)+,d0-d6		;r7			37
		write7	a4				;w7			72
		movem.l	(a3)+,d0-d6		;r14		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-80+44(a4),a2

	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-80+24(a3),a1
	REPT 12-12
		nop
	ENDR
;;;;;

;;;;;;;;43
eor1label_041
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14
		movem.l	(a3)+,d0-d5		;r20
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w20		60				3,57
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;87
		move.l	(a1)+,d0		;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-80+48(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-80+56(a2),a4
	REPT 12-12
		nop
	ENDR
;;;;;
;; lll
;;;;;;;;44
eor1label_042
	hsLeftBorder
		eor.l	d6,(a2)+		;w7			5
		eor.l	d0,(a2)+		;w8			10
		movem.l	(a1)+,d0-d6		;r15		27
		eor.l	d0,(a2)+		;			32
		eor.l	d1,(a2)+		;			37
		eor.l	d2,(a2)+		;			42
		eor.l	d3,(a2)+		;			47
		eor.l	d4,(a2)+		;			52
		eor.l	d5,(a2)+		;			57
		eor.l	d6,(a2)+		;w15		62
		movem.l	(a1)+,d0-d4		;r20		75				4,56
		eor.l	d0,(a2)+		;80
		eor.l	d1,(a2)+		;85
		eor.l	d2,(a2)+		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+		;	;w19
		move.l	(a3)+,d0		;	r1
		move.l	(a3)+,d1		;	r2
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+		;w20
		eor.l	d0,(a4)+		;w1
		lea		scanLineWidth-80+72(a3),a1
	REPT 12-12
		nop
	ENDR
;;;;;

;;;;;;;;45	
eor1label_043
	hsLeftBorder
		eor.l	d1,(a4)+		;w2		5
		movem.l	(a3)+,d0-d6		;r9		22
		write7	a4				;w9		57
		movem.l	(a3)+,d0-d6		;r16	74
		eor.l	d0,(a4)+		;w10	79
		eor.l	d1,(a4)+		;w11	84
		eor.l	d2,(a4)+		;w12	89

	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w14
		lea		scanLineWidth-80+24(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w16
		lea		scanLineWidth-80+80(a1),a0
	REPT 12-12
		nop
	ENDR
;;;;;

;;;;;;;;46	
eor1label_044
	hsLeftBorder
		movem.l	(a3)+,d0-d3		;r20		11
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w20		31			5,55
		movem.l	(a1)+,d0-d6		;r7			48
		write7	a2				;w7			83
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9			
	REPT 12-10
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3	;r13
	REPT 12-11
		nop
	ENDR
;;;;;;;;47
eor1label_045
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w13		20
		movem.l	(a1)+,d0-d6	;r20		37
		write7	a2			;w20		72				6,54
		movem.l	(a0)+,d0-d6	;r7			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		lea		scanLineWidth-80(a2),a4
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w4
		lea		scanLineWidth-80+52(a0),a3
	REPT 12-12
		nop
	ENDR
;;;;;;;;48
eor1label_046
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+	;w7		15
		movem.l	(a0)+,d0-d6	;r14	32
		write7	a4			;w14	67
		movem.l	(a0)+,d0-d5	;r20	82
		eor.l	d0,(a4)+	;w15	87
		move.l	(a3)+,d0	;r1		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+	;w16
		eor.l	d2,(a4)+	;w17
		lea		scanLineWidth-80+76(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+	;w18
		eor.l	d4,(a4)+	;w19
		lea		scanLineWidth-80+4(a4),a2
	REPT 12-12
		nop
	ENDR	

;;;;;;;; 49
eor1label_047
	hsLeftBorder
		eor.l	d5,(a4)+	;w20					7,53
		eor.l	d0,(a2)+	;w1		10
		movem.l	(a3)+,d0-d6	;r8		27
		write7	a2			;w8		62
		movem.l	(a3)+,d0-d6	;r15	79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;89

	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w12
		lea		scanLineWidth-80+32(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+	;w14
		lea		scanLineWidth-80+20(a3),a1
	REPT 12-12
		nop
	ENDR	

;;;;;;;; 50
eor1label_048
	hsLeftBorder
		eor.l	d6,(a2)+	;w15	5
		movem.l	(a3)+,d0-d4	;r20	18
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+	;w20	43				8,52
		movem.l	(a1)+,d0-d6	;r7		60
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d6,(a4)+		;w7
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r9
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-80+44(a1),a3
	REPT 12-12
		nop
	ENDR

;;;;;;;; 51
eor1label_049
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r16		17
		write7	a4				;w16		52
		movem.l	(a1)+,d0-d3		;r20		63	
		eor.l	d0,(a4)+					
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w20		83		9,51
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r2
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		lea		scanLineWidth-80(a4),a2	
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r6
	REPT 12-11
		nop
	ENDR

;;;;;;;;52
eor1label_050
	hsLeftBorder
		eor.l	d0,(a2)+	;w3
		eor.l	d1,(a2)+	;w4
		eor.l	d2,(a2)+	;w5
		eor.l	d3,(a2)+	;w6	;20
		movem.l	(a3)+,d0-d6	;r13	37
		write7	a2			;w13	72
		movem.l	(a3)+,d0-d6	;r20	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w15
		lea		scanLineWidth-80(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w17
		lea		scanLineWidth-80+12(a2),a4
	REPT 12-12
		nop
	ENDR

;;;;;;;;;;53
eor1label_051
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+	;w20						10,50
		movem.l	(a1)+,d0-d6	;r7		32
		write7	a4			;w7		67
		movem.l	(a1)+,d0-d6	;r14	84
		eor.l	d0,(a4)+	;w8
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+	;w10
		lea		scanLineWidth-80+40(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+	;w12
		lea		scanLineWidth-80+24(a1),a3
	REPT 12-12
		nop
	ENDR	

;;;;;;;;54
eor1label_052
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+	;w14
		movem.l	(a1)+,d0-d5	;r20
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	;15+30+10 = 55	w20			11,49
		movem.l	(a3)+,d0-d6	;r7	72
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+	;w3	87
		move.l	(a3)+,d0	;r8		90

	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+	;w5
		lea		scanLineWidth-80+60(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+	;w7
		lea		scanLineWidth-80+48(a3),a1
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;55
eor1label_053
	hsLeftBorder
		eor.l	d0,(a2)+	;w8	5
		movem.l	(a3)+,d0-d6	;r15	22
		write7	a2			;w15	57
		movem.l	(a3)+,d0-d4	;r20	70
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w19	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3	;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+	;w20						12,48
		eor.l	d0,(a4)+	;w1
		lea		scanLineWidth-80+76(a4),a2
	REPT 12-12
		nop
	ENDR
;;;;;;;56
eor1label_054
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w4			15
		movem.l	(a1)+,d0-d6	;r11		32
		write7	a4			;w11		67
		movem.l	(a1)+,d0-d6	;r18		84
		eor.l	d0,(a4)+	;w12		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-80+8(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-80+80(a3),a0
	REPT 12-12
		nop
	ENDR

;;;;;;;;;57
eor1label_055
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w18
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		;w20		26		13;,47
		movem.l	(a3)+,d0-d6		;r7			43
		eor.l	d0,(a2)+		;			48
		eor.l	d1,(a2)+		;			53
		eor.l	d2,(a2)+		;			;58
		eor.l	d3,(a2)+		;			63
		eor.l	d4,(a2)+		;			68
		eor.l	d5,(a2)+		;			73
		eor.l	d6,(a2)+		;w7			78
		movem.l	(a3)+,d0-d3		;r11		89


	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-80+44(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+		;w10
		move.l	(a3)+,d4
		move.l	(a3)+,d5		;r13
	REPT 12-11
		nop
	ENDR

;;;;58
eor1label_056
	hsLeftBorder
		eor.l	d3,(a2)+		;w11
		eor.l	d4,(a2)+		;w12
		eor.l	d5,(a2)+		;w13		15
		movem.l	(a3)+,d0-d6		;r20		32
		write7	a2				;w20		67	14,46
		movem.l	(a0)+,d0-d6		;r7			84
		eor.l	d0,(a4)+		;w1			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-80+52(a0),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-80+60(a4),a2
	REPT 12-12
		nop
	ENDR
;;;;59
eor1label_057
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+	;w7		10
		movem.l	(a0)+,d0-d6	;r14	27
		write7	a4			;w14	62
		movem.l	(a0)+,d0-d5	;r20	77
		eor.l	d0,(a4)+				
		eor.l	d1,(a4)+	;87
		move.l	(a3)+,d0	;r1
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-80+76(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		move.l	(a3)+,d1
		move.l	(a3)+,d2	;r3
	REPT 12-11
		nop
	ENDR

;;;;60
eor1label_058
	hsLeftBorder
		eor.l	d5,(a4)+		;w20			15,45
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w3			20
		movem.l	(a3)+,d0-d6		;r10		37
		write7	a2				;w10		72
		movem.l	(a3)+,d0-d6		;r17		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;12
		lea		scanLineWidth-80+32(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+		;w13
		move.l	(a3)+,d0		;r18
		move.l	(a3)+,d1		;r19
	REPT 12-11
		nop
	ENDR
;;;;61
eor1label_059
	hsLeftBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			;w19
		move.l	(a3)+,d0
		eor.l	d0,(a2)+			;w20			38	16,44
		movem.l	(a1)+,d0-d6			;r7				55
		write7	a4					;w7				90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3			;r11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+			;w9
		lea		scanLineWidth-80+44(a4),a2
	REPT 12-12
		nop
	ENDR
;;;;62
eor1label_060
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+			;w11
		movem.l	(a1)+,d0-d6			;r18		27
		write7	a4					;w18		62
		move.l	(a1)+,d0
		move.l	(a1)+,d1			;r20
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+			;78					17,43
		lea		scanLineWidth-80(a1),a3	;80
		movem.l	(a3)+,d0-d2			;89	r3
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+			;w3	
		move.l	(a3)+,d3
		move.l	(a3)+,d4			;r5	
	REPT 12-11
		nop
	ENDR
;;;;;;;;;;;;;63
eor1label_061
	hsLeftBorder
		eor.l	d3,(a2)+		;						5
		eor.l	d4,(a2)+		;w5			10			10		
		movem.l	(a3)+,d0-d6		;r12		27			27
		write7	a2				;w12		62			62
		movem.l	(a3)+,d0-d6		;r19		79			79
		eor.l	d0,(a2)+		;w13					84
		eor.l	d1,(a2)+		;w14		89			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+		;w15
		eor.l	d3,(a2)+		;w16
		lea		scanLineWidth-80+16(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w18
		lea		scanLineWidth-80+4(a3),a1
	REPT 12-12
		nop
	ENDR

;;;;;;;;;;;;;64
eor1label_062
	hsLeftBorder
		eor.l	d6,(a2)+		;w19
		move.l	(a3)+,d0		;r20
		eor.l	d0,(a2)+		;13				w20			18,42

		movem.l	(a1)+,d0-d6		;30				r7
		write7	a4				;65				w7
		movem.l	(a1)+,d0-d6		;82				r14
		eor.l	d0,(a4)+		;87				w8
		move.l	(a1)+,d0		;90				r15
	REPT 90-90	
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+
		lea		scanLineWidth-80+20(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-80+32(a4),a2
	REPT 12-12
		nop
	ENDR

;;;;;;;;;;;;;65
eor1label_063
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+			;w15
		movem.l	(a1)+,d0-d4			;r20		28
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+			;w20		53			19,41
		movem.l	(a3)+,d0-d6			;r7			70	
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+			;w4
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+			;w6			90
		lea		scanLineWidth-80+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+			;w7
		move.l	(a3)+,d0
		move.l	(a3)+,d1			;r9

	REPT 12-11
		nop
	ENDR

;;;;;;;;;;;;;66
eor1label_064
	hsLeftBorder
		eor.l	d0,(a2)+					;5
		eor.l	d1,(a2)+			;w9		;10
		movem.l	(a3)+,d0-d6			;r16	;27
		write7	a2					;w16	;62
		movem.l	(a3)+,d0-d3			;r20	;73
		eor.l	d0,(a2)+			;		
		eor.l	d1,(a2)+			;		;83
		eor.l	d2,(a2)+			;		88
		lea		scanLineWidth-80(a3),a1
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+			;w20				20,40
		move.l	(a1)+,d0
		move.l	(a1)+,d1			;r2
	REPT 12-11
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d2-d5			;r6
	REPT 12-11
		nop
	ENDR
;;;;;;;;;;;;;

;;;;;;;;;;67
eor1label_065
	hsLeftBorder
		lea		scanLineWidth-80(a2),a4		;2
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+			;w6		;30
		movem.l	(a1)+,d0-d6			;r13	;17		49
		write7	a4					;w13	35		84
		move.l	(a1)+,d0
		move.l	(a1)+,d1			;r15			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+			;w15
		lea		scanLineWidth-80+20(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3			;r19
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;;;

;;;;;;;;;;;;;68
eor1label_066
	hsLeftBorder	
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		move.l	(a1)+,d0
		eor.l	d0,(a4)+			;w20	28			21,39
		lea		scanLineWidth-80(a1),a3	;	30
		movem.l	(a3)+,d0-d6			;r7		47
		write7	a2					;w7		82
		move.l	(a3)+,d0			
		eor.l	d0,(a2)+			;w8		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3			;r12
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			;w10
		lea		scanLineWidth-80+40(a2),a4
	REPT 12-12
		nop
	ENDR

;;;;;;;;;;;;;69
eor1label_067
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+			;w12		10
		movem.l	(a3)+,d0-d6			;r19		27
		write7	a2					;w19		62
		move.l	(a3)+,d0
		eor.l	d0,(a2)+			;w20		70		22,38
		lea		scanLineWidth-80(a3),a1		;	72
		movem.l	(a1)+,d0-d6			;r7			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-80+52(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+			;4
		lea		scanLineWidth-80+64(a4),a2
	REPT 12-12
		nop
	ENDR

;;;;;;;;;;;;;70
eor1label_068
	hsLeftBorder	
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+			;w7
		movem.l	(a1)+,d0-d6			;r14		32
		write7	a4					;w14		67
		movem.l	(a1)+,d0-d5			;r20		82
		eor.l	d0,(a4)+			;w15		87
		lea		scanLineWidth-80+80(a1),a1		;89
	REPT 90-89	
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+			;w19
	REPT 12-10
		nop
	ENDR

;;;;;;;;;;;;;71
eor1label_069
	hsLeftBorder
		eor.l	d5,(a4)+			;w20		5			23,37
		movem.l	(a3)+,d0-d6			;r7			22
		write7	a2					;w7			57
		movem.l	(a3)+,d0-d6			;r14		74
		eor.l	d0,(a2)+			;w8
		eor.l	d1,(a2)+			;w9
		eor.l	d2,(a2)+			;w10		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+			;w12
		lea		scanLineWidth-80+32(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		lea		scanLineWidth-80+24(a3),a1
	REPT 12-12
		nop
	ENDR





;;;;;;;;;;;;;72
eor1label_070
	hsLeftBorder
		movem.l	(a3)+,d0-d5			;r20
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+			;30+15 = 45				24,36
		movem.l	(a1)+,d0-d6			;r7		 62
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+			;87
		move.l	(a1)+,d0			;r8		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+			;w7
		lea		scanLineWidth-80+52(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+			;w8
		move.l	(a1)+,d1
		move.l	(a1)+,d2			;r10
	REPT 12-11
		nop
	ENDR

;;;;;;;;;;;;;73
eor1label_071
	hsLeftBorder
		eor.l	d1,(a4)+	;w9
		eor.l	d2,(a4)+	;w10
		movem.l	(a1)+,d0-d6		;r17	27
		write7	a4			;w17		62
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		move.l	(a1)+,d2	;r20		;71
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w20		;86			25,35
		lea		scanLineWidth-80(a1),a3	;88
		lea		scanLineWidth-80(a4),a2
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
	REPT 12-10
		nop
	ENDR	

;;;;;;;;;;;;;74
eor1label_072

	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4		10
		movem.l	(a3)+,d0-d6		;r11	27
		write7	a2				;w11	62
		movem.l	(a3)+,d0-d6		;r18	79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w15
		lea		scanLineWidth-80+20(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w17
	REPT 12-10
		nop
	ENDR

;;;;;;;;;;;;;75
eor1label_073
	hsLeftBorder
		eor.l	d6,(a2)+		;w18
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a2)+		
		eor.l	d1,(a2)+		;w20						26,34
		lea		scanLineWidth-80(a3),a1		;23
		movem.l	(a1)+,d0-d6		;r7			40
		write7	a4				;w7			75
		movem.l	(a1)+,d0-d5		;r13		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-80+28(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-80+36(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;76
eor1label_074
	hsLeftBorder	

		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w13	10
		movem.l	(a1)+,d0-d6		;r20	27
		write7	a4				;w20	62					27,33
		movem.l	(a3)+,d0-d6		;r7		79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-80+52(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-80+56(a2),a4
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;77
eor1label_075
;zzzz
	hsLeftBorder
		eor.l	d6,(a2)+		;w7
		movem.l	(a3)+,d0-d6		;r14	22
		write7	a2				;w14	57
		movem.l	(a3)+,d0-d5		;r20	72
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10	87
		move.l	(a1)+,d0		;r1
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		lea		scanLineWidth-80+76(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+		;w20						28,32
		eor.l	d0,(a4)+		;w1
		lea		scanLineWidth-80+76(a4),a2
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;78
eor1label_076
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r8	17
		write7	a4				;w8	52
		movem.l	(a1)+,d0-d6		;r15 69
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w12	
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+		;
		eor.l	d5,(a4)+		;w14
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+		;w15
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r17
	REPT 12-11
		nop
	ENDR
;;;;;;;;;;;;;79
eor1label_077
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w17
		move.l	(a1)+,d0
		eor.l	d0,(a4)+
		move.l	(a1)+,d0
		eor.l	d0,(a4)+
		move.l	(a1)+,d0				
		eor.l	d0,(a4)+		;w20	34					29,31
		movem.l	(a3)+,d0-d6		;r7		51
		write7	a2				;w7		86
		lea		scanLineWidth-80+52(a3),a1
		lea		scanLineWidth-80+52(a2),a4
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
	REPT 12-10
		nop
	ENDR
;;;;;;;;;;;;;80
eor1label_078
	hsLeftBorder
		eor.l	d2,(a2)+				;5
		eor.l	d3,(a2)+		;w11	10
		movem.l	(a3)+,d0-d6		;r18	27
		write7	a2				;w18	62
		move.l	(a3)+,d0		;		65
		eor.l	d0,(a2)+		;		70
		move.l	(a3)+,d0		;		73
		eor.l	d0,(a2)+		;w20	78				30,30
		movem.l	(a1)+,d0-d3		;r4		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-80+72(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-80+64(a1),a3
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;81
eor1label_079

	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r11
		write7	a4				;w11	52
		movem.l	(a1)+,d0-d6		;r18	69
		eor.l	d0,(a4)+		;w12
		eor.l	d1,(a4)+		;w13
		eor.l	d2,(a4)+		;w14
		eor.l	d3,(a4)+		;w15	89	
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r20
		eor.l	d4,(a4)+		;w16
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+		;w17
		eor.l	d6,(a4)+		;w18
	REPT 12-10
		nop
	ENDR
;;;;;;;;;;;;;82
eor1label_080
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w20						31,29
		movem.l	(a3)+,d0-d6		;r7		27
		write7	a2				;w7		62
		movem.l	(a3)+,d0-d6		;r14	79
		eor.l	d0,(a2)+		;w8		84
		eor.l	d1,(a2)+		;w9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		lea		scanLineWidth-80+24(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w13
		lea		scanLineWidth-80+28(a2),a4
	REPT 12-12
		nop
	ENDR

;;;;;;;;;;;;;83
eor1label_081
	hsLeftBorder
		eor.l	d6,(a2)+		;w14		5
		movem.l	(a3)+,d0-d5		;r20		20
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+									;32,28
		eor.l	d5,(a2)+			;55
		movem.l	(a1)+,d0-d6		;r7		;67
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;87
		lea		scanLineWidth-80+52(a1),a3	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6
		lea		scanLineWidth-80+56(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+		;w7
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r9
	REPT 12-11
		nop
	ENDR
;;;;;;;;;;;;;84
eor1label_082

	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9		10
		movem.l	(a1)+,d0-d6		;r16	27
		write7	a4				;w16	62
		movem.l	(a1)+,d0-d3		;r20	73
		eor.l	d0,(a4)+			;78
		eor.l	d1,(a4)+			;83
		eor.l	d2,(a4)+			;88
		lea		scanLineWidth-80+80(a3),a1	
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+		;w20						;33,27
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r2
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;85
eor1label_083
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r9	17
		write7	a2				;w7	52
		movem.l	(a3)+,d0-d6		;r16	69
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
	REPT 12-10
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r20
	REPT 12-11
		nop
	ENDR
;;;;;;;;;;;;;86
eor1label_084
	hsLeftBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w20							;34,26
		movem.l	(a1)+,d0-d6		;r7		42
		write7	a4				;w7		77
		movem.l	(a1)+,d0-d4		;r12	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-80+44(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-80+32(a1),a3
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;87
eor1label_085
	hsLeftBorder
		eor.l	d4,(a4)+		;w12	;5
		movem.l	(a1)+,d0-d6		;r19	;22
		write7	a4				;w19	;57
		move.l	(a1)+,d0		;		;60
		eor.l	d0,(a4)+		;w20	;65					;35,25
		movem.l	(a3)+,d0-d6		;r7		;82
		eor.l	d0,(a2)+		;w1		;87
		move.l	(a3)+,d0		;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w3
		lea		scanLineWidth-80+48(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-80+60(a2),a4
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;88
eor1label_086
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+		;w8		15
		movem.l	(a3)+,d0-d6		;r15	32
		write7	a2				;w15	67
		movem.l	(a3)+,d0-d4		;r20	80
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w17
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+		;w18
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r2
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+		;w19
		move.l	(a1)+,d2
		move.l	(a1)+,d3		;r4
	REPT 12-11
		nop
	ENDR

;;;;;;;;;;;;;89
eor1label_087
	hsLeftBorder
		eor.l	d4,(a2)+		;w20						;36,24
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		25
		movem.l	(a1)+,d0-d6		;r11	42
		write7	a4				;w11	77
		movem.l	(a1)+,d0-d4		;r16	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13
		lea		scanLineWidth-80+28(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-80+16(a1),a3
	REPT 12-12
		nop
	ENDR

;;;;;;;;;;;;;90
eor1label_088
	hsLeftBorder
		eor.l	d4,(a4)+		;w16		5
		movem.l	(a1)+,d0-d3		;r20		16
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w20		36				;37,23
		movem.l	(a3)+,d0-d6		;r7			53
		write7	a2				;w7			88
		lea		scanLineWidth-80+52(a3),a1	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r11		11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-80+44(a2),a4
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;91
eor1label_089
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		movem.l	(a3)+,d0-d6		;r18	27
		write7	a2				;w18	62
		move.l	(a3)+,d0		;	
		eor.l	d0,(a2)+
		move.l	(a3)+,d0
		eor.l	d0,(a2)+		;w20	78					;38,22
		movem.l	(a1)+,d0-d3		;r4		89

	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-80+64(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-80+64(a4),a2
	REPT 12-12
		nop
	ENDR

;;;;;;;;;;;;;92
eor1label_090
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r11	17
		write7	a4				;w11	52
		movem.l	(a1)+,d0-d6		;r18	69
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		move.l	(a1)+,d0		;r19
		move.l	(a1)+,d1		;r20
		eor.l	d4,(a4)+		
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
	REPT 12-10
		nop
	ENDR	

;;;;;;;;;;;;;93
eor1label_091
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w20						;39,21
		movem.l	(a3)+,d0-d6		;r7		27
		write7	a2				;w7		62
		movem.l	(a3)+,d0-d6		;r14	79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		lea		scanLineWidth-80+36(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		lea		scanLineWidth-80+24(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;94
eor1label_092
	hsLeftBorder
		eor.l	d6,(a2)+		;w14	5
		movem.l	(a3)+,d0-d5		;r20	20
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w20	;50				;40,20
		movem.l	(a1)+,d0-d6		;r7		;67
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		move.l	(a1)+,d0		;r8		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-80+48(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+		;w8
		lea		scanLineWidth-80+48(a4),a2
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;95
eor1label_093
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r15
		write7	a4				;w15	52
		movem.l	(a1)+,d0-d4		;r20	65
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w20	90				;41,19
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;96
eor1label_094
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		movem.l	(a3)+,d0-d6		;r11	27
		write7	a2				;w11	62
		movem.l	(a3)+,d0-d6		;r18	79
		eor.l	d0,(a2)+		;
		eor.l	d1,(a2)+		;w13
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-80+8(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+		;w16
		move.l	(a3)+,d0		;r19
		move.l	(a3)+,d1		;r20
	REPT 12-11
		nop
	ENDR	

;;;;;;;;;;;;;97
eor1label_095
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;20	w20					;42,18
		movem.l	(a1)+,d0-d6		;r7			37
		write7	a4				;w7			72
		movem.l	(a1)+,d0-d6		;r14		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-80+24(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-80+36(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;;;;;;;;;;;; CHECK
eor1label_096
;;;;;;;;;;;;;98
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14		15
		movem.l	(a1)+,d0-d5		;r20		30
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w20			60			;43,17
		movem.l	(a3)+,d0-d6		;r7				77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		move.l	(a3)+,d0		;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-80+48(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-80+56(a2),a4
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;99
eor1label_097
	hsLeftBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+		;w8
		movem.l	(a3)+,d0-d6		;r15		27
		write7	a2				;w15		62
		movem.l	(a3)+,d0-d4		;r20		75
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w18		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w20					;44,16
		lea		3*scanLineWidth-80(a3),a0									;a3 = 0, a1=+1 a3 = +2, a0 = +3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR	

;;;;;;;;;;;;;100
eor1label_098
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		20
		movem.l	(a1)+,d0-d6		;r11	37
		write7	a4				;w11	72
		movem.l	(a1)+,d0-d6		;r18	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13
		lea		scanLineWidth-80+28(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-80+8(a1),a3
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;101
eor1label_099
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w18	15
		move.l	(a1)+,d0
		eor.l	d0,(a4)+
		move.l	(a1)+,d0
		eor.l	d0,(a4)+		;w20	31					;45,15
		movem.l	(a3)+,d0-d6		;r7		48
		write7	a2				;w7		83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-80+44(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	

;;;;;;;;;;;;;102
eor1label_100
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w13	20
		movem.l	(a3)+,d0-d6		;r20	37
		write7	a2				;w20	72
		movem.l	(a0)+,d0-d6		;r7		89

	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+		;		87
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-80+72(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-80+52(a0),a3
	REPT 12-12
		nop
	ENDR	
;;;;; ERROR FIX IM SAD NOW
eor1label_101
	hsLeftBorder	
		move.l	(a0)+,d0		;r8		3
		eor.l	d4,(a4)+		;w5		5
	REPT 90-8
		nop
	ENDR
	hsRightBorder
	REPT 12
		nop
	ENDR
	hsStabilize
	REPT 12
		nop
	ENDR

;;;;;;;;;;;;;103
eor1label_102
	hsLeftBorder
		eor.l	d5,(a4)+		;w6
		eor.l	d6,(a4)+		;w7
		eor.l	d0,(a4)+		;w8			15
		movem.l	(a0)+,d0-d6		;r15		32
		write7	a4				;w15		67
		movem.l	(a0)+,d0-d4		;r20		80
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w17		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+		;
		eor.l	d3,(a4)+		;w19
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+		;w20					;47,13
		move.l	(a3)+,d0		;r1
		move.l	(a3)+,d1		;r2
	REPT 12-11
		nop
	ENDR	

;;;;;;;;;;;;;104
eor1label_103
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2		10
		movem.l	(a3)+,d0-d6		;r9		27
		write7	a2				;w9		62
		movem.l	(a3)+,d0-d6		;r16	79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w11	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w13
		lea		scanLineWidth-80+28(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w15
		lea		scanLineWidth-80+16(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;105
eor1label_104
	hsLeftBorder
		eor.l	d6,(a2)+		;w16		5
		movem.l	(a3)+,d0-d3		;r20		16
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w20		36				;48,12
		movem.l	(a1)+,d0-d6		;r7			53
		write7	a4				;w7			88
		lea		scanLineWidth-80+52(a1),a3	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r11		
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-80+44(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;106
eor1label_105
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11	
		movem.l	(a1)+,d0-d6		;r18	27
		write7	a4				;w18	62
		move.l	(a1)+,d0		;
		move.l	(a1)+,d1		;		68
		eor.l	d0,(a4)+		;
		eor.l	d1,(a4)+		;w20	78				;49,11
		movem.l	(a3)+,d0-d3		;r4		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-80+64(a3),a1
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;107
eor1label_106
	hsLeftBorder
		movem.l	(a3)+,d0-d6	;r11
		write7	a2			;w11		52
		movem.l	(a3)+,d0-d6	;r18		69
		eor.l	d0,(a2)+	
		eor.l	d1,(a2)+	
		eor.l	d2,(a2)+	
		eor.l	d3,(a2)+	;w15		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+	;w16
		move.l	(a3)+,d0
		move.l	(a3)+,d1	;r20
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+	;w18
		lea		scanLineWidth(a1),a3
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;108
eor1label_107
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w20							;50,10
		movem.l	(a1)+,d0-d6	;r7		27	
		write7	a4			;w7		62
		movem.l	(a1)+,d0-d6	;r14	79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w9
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w11
		lea		scanLineWidth-80+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	;w13
	REPT 12-10
		nop
	ENDR	

;;;;;;;;;;;;;109
eor1label_108
	hsLeftBorder
		eor.l	d6,(a4)+	;w14		5
		movem.l	(a1)+,d0-d5	;r20		20
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	;			50					;51,9
		movem.l	(a3)+,d0-d6	;r7			67
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w4
		move.l	(a3)+,d0	;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+	;w6
		lea		scanLineWidth-80+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+	;w8
		lea		scanLineWidth-80+48(a3),a1
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;110
eor1label_109
	hsLeftBorder
		movem.l	(a3)+,d0-d6	;r15	17
		write7	a2			;w15	52
		movem.l	(a3)+,d0-d4	;r20	65
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+	;w20	90					;52,8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3	;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w2
		lea		scanLineWidth-80+72(a4),a2
	REPT 12-12
		nop
	ENDR	


;;;;;;;;;;;;;111
eor1label_110
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w4		10
		movem.l	(a1)+,d0-d6	;r11	27
		write7	a4			;w11	62
		movem.l	(a1)+,d0-d6	;r18	79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w13	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w15
		lea		scanLineWidth-80+8(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+	;w16
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r20
	REPT 12-11
		nop
	ENDR	

;;;;;;;;;;;;;112
eor1label_111
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w20								;53,7
		movem.l	(a3)+,d0-d6	;r7		37
		write7	a2			;w7		72
		movem.l	(a3)+,d0-d6	;r14	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w9
		lea		scanLineWidth-80+44(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-80+24(a3),a1
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;113
eor1label_112
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+	; w14
		movem.l	(a3)+,d0-d5	; r20
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+	;w20		45+15 = 60				;54,6
		movem.l	(a1)+,d0-d6	;r7			77
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		move.l	(a1)+,d0	;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+	
		eor.l	d3,(a4)+	;w4
		lea		scanLineWidth-80+64(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	;w6
		lea		scanLineWidth-80+48(a1),a3
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;114
eor1label_113
	hsLeftBorder
		eor.l	d6,(a4)+		;w7
		eor.l	d0,(a4)+		;w8
		movem.l	(a1)+,d0-d6		;r15		22
		write7	a4				;w15		57
		movem.l	(a1)+,d0-d4		;r20		70
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w18
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+		;w19		90				;55,5
		move.l	(a3)+,d0		;
		move.l	(a3)+,d1		;r2
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+		;w20
		eor.l	d0,(a2)+		;w1
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;115
eor1label_114
	hsLeftBorder
		eor.l	d1,(a2)+		;w2			;5
		movem.l	(a3)+,d0-d6		;r9			;22
		write7	a2				;w9			;57
		movem.l	(a3)+,d0-d6		;r16		;74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w12		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		lea		scanLineWidth-80+16(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w16
		lea		scanLineWidth-80+16(a2),a4
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;116
eor1label_115
	hsLeftBorder
		movem.l	(a3)+,d0-d3		;r20		11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w20		31			56,4
		movem.l	(a1)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a1)+,d0		;r8			86
		lea		scanLineWidth-80+48(a1),a3	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+		;w8
		move.l	(a1)+,d0		;r9
		move.l	(a1)+,d1		;r10
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w10
		lea		scanLineWidth-80+40(a4),a2
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;117
eor1label_116
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r17		17
		write7	a4				;w17		52
		movem.l	(a1)+,d0-d2		;r20		61
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w20		76			55,3
		movem.l	(a3)+,d0-d4		;r5			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-80+80(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-80+68(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;118
eor1label_117
	hsLeftBorder
		eor.l	d4,(a2)+		;w5		5
		movem.l	(a3)+,d0-d6		;r12	22
		write7	a2				;w12	57
		movem.l	(a3)+,d0-d6		;r19	74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w15	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+	
		move.l	(a3)+,d0		;r20
		move.l	(a1)+,d1		;r1
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+		;w17
		eor.l	d5,(a2)+		;w18
		lea		scanLineWidth-64+60(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;119
eor1label_118
	hsLeftBorder
		eor.l	d6,(a2)+		;w19
		eor.l	d0,(a2)+		;w20					56,2
		eor.l	d1,(a4)+		;w1			15
		movem.l	(a1)+,d0-d6		;r8			32
		write7	a4				;w8			67
		movem.l	(a1)+,d0-d6		;r15		84
		eor.l	d0,(a4)+		;w9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w11
		lea		scanLineWidth-64+20(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w13
	REPT 12-10
		nop
	ENDR	

;;;;;;;;;;;;;120
eor1label_119
	hsLeftBorder
		eor.l	d5,(a4)+		;14	
		eor.l	d6,(a4)+		;15
		move.l	(a1)+,d0		;r16
		eor.l	d0,(a4)+		;w16					18

		movem.l	(a3)+,d0-d6		;r7						35
		write7	a2				;w7						70
		movem.l	(a3)+,d0-d6		;r14					87
		lea		scanLineWidth-64+8(a3),a1				;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-64+28(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+		;w10
		eor.l	d3,(a2)+		;w11		
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;;;121
eor1label_120
	hsLeftBorder
		eor.l	d4,(a2)+		;w12
		eor.l	d5,(a2)+		;w13
		eor.l	d6,(a2)+		;w14
		move.l	(a3)+,d0		;r15
		eor.l	d0,(a2)+		;w15		23
		move.l	(a3)+,d0		;r16		26
		eor.l	d0,(a2)+		;w16		31

		movem.l	(a1)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a1)+,d0		;r8
		move.l	(a1)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-64+28(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	

;;;;;;;;;;;;;122
eor1label_121
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13			20
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		move.l	(a1)+,d2					;	29
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w16		;	44	
		movem.l	(a3)+,d0-d6		;r7				61
		lea		scanLineWidth-64(a4),a2		;	63
		eor.l	d0,(a2)+		
		eor.l	d1,(a2)+		
		eor.l	d2,(a2)+		
		eor.l	d3,(a2)+		
		eor.l	d4,(a2)+		;w5			88
		lea		scanLineWidth-64+36(a3),a1		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		lea		scanLineWidth-64+36(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR	

;;;;;;;;;;;;;123
eor1label_122
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11	20
		movem.l	(a3)+,d0-d4		;r16	33
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w16	58
		movem.l	(a1)+,d0-d6		;r7		75
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w3		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-64+44(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w7
		lea		scanLineWidth-64+36(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;124
eor1label_123
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r14
		write7	a4				;w14		52
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w16		68
		movem.l	(a3)+,d0-d6		;r7			85
		eor.l	d0,(a2)+		;w1
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		lea		scanLineWidth-64+52(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		lea		scanLineWidth-64+36(a3),a1
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;125
eor1label_124
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		movem.l	(a3)+,d0-d6		;r14	27
		write7	a2				;w14	62
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w16	78
		movem.l	(a1)+,d0-d3		;r4		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-64+48(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-64+48(a4),a2
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;126
eor1label_125
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r11	17
		write7	a4				;w11	52
		movem.l	(a1)+,d0-d4		;r16	65
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w16	90
	REPT 90-90	
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		lea		scanLineWidth-64+56(a2),a4
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;127
eor1label_126
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		movem.l	(a3)+,d0-d6		;r11		27
		write7	a2				;w11		62
		movem.l	(a3)+,d0-d4		;r16		75
		eor.l	d0,(a2)+		;w12		80
		eor.l	d1,(a2)+		;w13		85
		eor.l	d2,(a2)+		;w14		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+		;w15
		eor.l	d4,(a2)+		;w16
		lea		scanLineWidth-64(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR	

;;;;;;;;;;;;;128
eor1label_127
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w4			
		movem.l	(a1)+,d0-d6	;r11		37
		write7	a4			;w11		72
		movem.l	(a1)+,d0-d4	;r16		85
		eor.l	d0,(a4)+	;w12
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+	;w14
		lea		scanLineWidth-64+8(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+	;w16
		lea		scanLineWidth-64(a1),a3
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;129
eor1label_128
	hsLeftBorder
		movem.l	(a3)+,d0-d6	;r7
		write7	a2			;w7		52
		movem.l	(a3)+,d0-d6	;r14	69
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w11	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+	;w13
		lea		scanLineWidth-64+12(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+	;w14
		move.l	(a3)+,d0
		move.l	(a3)+,d1	;r16
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;130
eor1label_129
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w16	10
		lea		scanLineWidth-64(a3),a1		;12
		movem.l	(a1)+,d0-d6		;r7			29
		write7	a4				;w7			64
		movem.l	(a1)+,d0-d6		;r14		81
		eor.l	d0,(a4)+		;w8			86
		move.l	(a1)+,d0		;r15		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w10
		lea		scanLineWidth-64+24(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-64+4(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;131
eor1label_130
	hsLeftBorder
		eor.l	d5,(a4)+						;5
		eor.l	d6,(a4)+						;10
		eor.l	d0,(a4)+						;15
		move.l	(a1)+,d0	;r16				;18
		eor.l	d0,(a4)+	;w16		23		;23
		movem.l	(a3)+,d0-d6	;r7			40		;40
		write7	a2			;w7			75		;75
		movem.l	(a3)+,d0-d5	;r13		90		;
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+	;w8
		eor.l	d1,(a2)+	;w9
		lea		scanLineWidth-64+12(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w11
		lea		scanLineWidth-64+20(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;131
eor1label_131
	hsLeftBorder
		eor.l	d4,(a2)+	;12
		eor.l	d5,(a2)+	;13
		movem.l	(a3)+,d0-d2	;r16	19
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+	;w16	34
		movem.l	(a1)+,d0-d6	;r7		51
		write7	a4			;w7		86
		move.l	(a1)+,d0	;r8		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d1-d4	;r12	
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w9
		lea		scanLineWidth-64+28(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;132
eor1label_132
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+	;w12
		movem.l	(a1)+,d0-d3	;r16		26
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w16		46
		lea		scanLineWidth-64(a1),a3	;48
		movem.l	(a3)+,d0-d6	;r7		65
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+	;r5		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		lea		scanLineWidth-64+36(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3	;r11
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;133
eor1label_133
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w11		20
		movem.l	(a3)+,d0-d4	;r16		33
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+	;w16		58
		lea		scanLineWidth-64(a3),a1	;60
		movem.l	(a1)+,d0-d6	;r7			77
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w2	
		move.l	(a1)+,d0	;r8			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w4
		lea		scanLineWidth-64+48(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	;w6
		lea		scanLineWidth-64+32(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;134
eor1label_134

;;;;;;;;;;;;;
	hsLeftBorder
		eor.l	d6,(a4)+	;w7	
		eor.l	d0,(a4)+	;w8			10

		movem.l	(a1)+,d0-d6	;r15		27
		write7	a4			;			62
		move.l	(a1)+,d0	;r16		65
		eor.l	d0,(a4)+	;w16		70
		movem.l	(a3)+,d0-d6	;r7			87
		lea		scanLineWidth-64+36(a3),a1	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-64+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+		;w3
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;135
eor1label_135
	hsLeftBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w9		30
		movem.l	(a3)+,d0-d6	;r16	47
		write7	a2			;w16	82
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		lea		scanLineWidth-64+56(a1),a3	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-64+56(a4),a2	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3	;r6
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;136
eor1label_136
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w6		20
		movem.l	(a1)+,d0-d6	;r13	37
		write7	a4			;w13	72
		move.l	(a1)+,d0	
		eor.l	d0,(a4)+	;w14	80
		move.l	(a1)+,d0
		eor.l	d0,(a4)+	;w15
		lea		scanLineWidth-64+4(a1),a3
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		move.l	(a1)+,d0
		eor.l	d0,(a4)+	;w16
		move.l	(a3)+,d0	;r1
	REPT 12-11
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d1-d4	;r5
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;137
eor1label_137
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+	;25

		movem.l	(a3)+,d0-d6	;r12		42
		write7	a2			;w12		77
		movem.l	(a3)+,d0-d3	;r16		88
		lea		scanLineWidth-64(a3),a1	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+	;w13		88
		eor.l	d1,(a2)+	;w14
		lea		scanLineWidth-64+8(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		move.l	(a1)+,d0
		move.l	(a1)+,d1	;r2
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;138
eor1label_138
	hsLeftBorder
		eor.l	d3,(a2)+	;w16
		eor.l	d0,(a4)+	;w1
		eor.l	d1,(a4)+	;w2
		movem.l	(a1)+,d0-d6		;r9		27
		write7	a4				;w9		62
		movem.l	(a1)+,d0-d6		;r16	79
		eor.l	d0,(a4)+
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+		;w11
		eor.l	d2,(a4)+
		lea		scanLineWidth-64+16(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-64(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;139
eor1label_139
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w16
		movem.l	(a3)+,d0-d6		;r7		27
		write7	a2				;w7		62
		movem.l	(a3)+,d0-d6		;r14	79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+		;w10
		eor.l	d3,(a2)+
		lea		scanLineWidth-64+20(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		lea		scanLineWidth-64+8(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;140
eor1label_140

	hsLeftBorder
		eor.l	d6,(a2)+
		move.l	(a3)+,d0		;r15	89
		eor.l	d0,(a2)+
		move.l	(a3)+,d0
		eor.l	d0,(a2)+		;16		;21
		movem.l	(a1)+,d0-d6		;r7		;38
		write7	a4				;w7		;73
		movem.l	(a1)+,d0-d6		;r14	;82
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+		;w8
		eor.l	d1,(a4)+
		lea		scanLineWidth-64+28(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+		;w10
		eor.l	d3,(a4)+
		lea		scanLineWidth-64+8(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;	141
;;;;;;;;;;;;;
eor1label_141
	hsLeftBorder
		eor.l	d4,(a4)+		;w12
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+	;w14
		move.l	(a1)+,d0				;18
		eor.l	d0,(a4)+				;23
		move.l	(a1)+,d0				;26
		eor.l	d0,(a4)+	;w16		;31
		movem.l	(a3)+,d0-d6		;r7		;48
		write7	a2				;w7		;83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-64+28(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d4		;r14
;	REPT 12-11
;		nop
;	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; terminate filler!!!!!!!!!
;;;;;;;;;;;;;142

;	hsLeftBorder
		eor.l	d0,(a2)+		;w10
		eor.l	d1,(a2)+		;w11
		eor.l	d2,(a2)+		;w12
		eor.l	d3,(a2)+		;w13
		eor.l	d4,(a2)+		;w14
		move.l	(a3)+,d0		;r15
		move.l	(a3)+,d1		;r16
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w16		;35+6 =41
		lea		scanLineWidth-64(a3),a1		;43
		movem.l	(a1)+,d0-d6		;r7		60
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
;	REPT 90-90
;		nop
;	ENDR
;	hsRightBorder
		eor.l	d6,(a4)+		;w7
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r9
;	REPT 12-11
;		nop
;	ENDR
;	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-64+28(a4),a2
;	REPT 12-12
;		nop
;	ENDR	
;;;;;;;;;;

	movem.l	(a1)+,d0-d6
	eor.l	d0,(a4)+
	eor.l	d1,(a4)+
	eor.l	d2,(a4)+
	eor.l	d3,(a4)+
	eor.l	d4,(a4)+
	eor.l	d5,(a4)+
	eor.l	d6,(a4)+
	REPT 2
	lea		scanLineWidth-64(a1),a1
	movem.l	(a1)+,d0-d7					;8
	eor.l	d0,(a2)+
	eor.l	d1,(a2)+
	eor.l	d2,(a2)+
	eor.l	d3,(a2)+
	eor.l	d4,(a2)+
	eor.l	d5,(a2)+
	eor.l	d6,(a2)+
	eor.l	d7,(a2)+
	movem.l	(a1)+,d0-d7					;8
	eor.l	d0,(a2)+
	eor.l	d1,(a2)+
	eor.l	d2,(a2)+
	eor.l	d3,(a2)+
	eor.l	d4,(a2)+
	eor.l	d5,(a2)+
	eor.l	d6,(a2)+
	eor.l	d7,(a2)+
	lea		scanLineWidth-64(a2),a2
	ENDR
	lea		scanLineWidth-64(a1),a1
	movem.l	(a1)+,d0-d7					;8
	eor.l	d0,(a2)+
	eor.l	d1,(a2)+
	eor.l	d2,(a2)+
	eor.l	d3,(a2)+
	eor.l	d4,(a2)+
	eor.l	d5,(a2)+
	eor.l	d6,(a2)+
	eor.l	d7,(a2)+
	movem.l	(a1)+,d0-d7					;8
	eor.l	d0,(a2)+
	eor.l	d1,(a2)+
	eor.l	d2,(a2)+
	eor.l	d3,(a2)+
	eor.l	d4,(a2)+
	eor.l	d5,(a2)+
	eor.l	d6,(a2)+
	eor.l	d7,(a2)+
	lea		scanLineWidth-56(a2),a4
	lea		scanLineWidth-56(a1),a3


	REPT 9-1	;6 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d4
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-48(a3),a3
		lea		scanLineWidth-48(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d4
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-40(a3),a3
		lea		scanLineWidth-40(a4),a4

	REPT 4	;4 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		lea		scanLineWidth-32(a3),a3
		lea		scanLineWidth-32(a4),a4
	ENDR

	REPT 1	;2 blocks
		movem.l	(a3)+,d0-d5
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-24(a3),a3
		lea		scanLineWidth-24(a4),a4
	ENDR

;	move.w	#$222,$ffff8240
	jsr		copyRealTime
	popall
	move.w	#0,filldone
	rte
eor1end


; 5 times 8 regs	(4:32, 1:40)
; 11 times 12 regs	(10:48, 1:56)
; 16 times 16 regs (15:64, 1:72)
; 4 times 18 regs (4:72)
; 

;;;;;
	IF scanLineWidth=160
eor1
	ENDC
;eor 16(4),11(6),16(8),4(9),60(10),26(8),9(6),6(4),4(2)
	REPT 5-1	;4 blocks
		movem.l	(a3)+,d0-d6														;68
		eor.l	d0,(a4)+														;20
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0														;12
		eor.l	d0,(a4)+
		lea		scanLineWidth-32(a3),a3											;8
		lea		scanLineWidth-32(a4),a4											;8
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		eor.l	d7,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		lea		scanLineWidth-40(a3),a3
		lea		scanLineWidth-40(a4),a4



	REPT 11-1	;6 blocks
		movem.l	(a3)+,d0-d6														;68
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d4														;52
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-48(a3),a3
		lea		scanLineWidth-48(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d4
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-56(a3),a3
		lea		scanLineWidth-56(a4),a4

	REPT 16-1	;8 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		lea		scanLineWidth-64(a3),a3
		lea		scanLineWidth-64(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+

		lea		scanLineWidth-72(a3),a3
		lea		scanLineWidth-72(a4),a4


	REPT 4	;9 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d3															;44
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-72(a3),a3
		lea		scanLineWidth-72(a4),a4
	ENDR



	REPT 60-1	;10 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d5															;60
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-80(a3),a3
		lea		scanLineWidth-80(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d5
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-72(a3),a3
		lea		scanLineWidth-72(a4),a4


	REPT 26-1	;8 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		lea		scanLineWidth-64(a3),a3
		lea		scanLineWidth-64(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		lea		scanLineWidth-56(a3),a3
		lea		scanLineWidth-56(a4),a4

	REPT 9-1	;6 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d4
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-48(a3),a3
		lea		scanLineWidth-48(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d4
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-40(a3),a3
		lea		scanLineWidth-40(a4),a4


	REPT 6	;4 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		lea		scanLineWidth-32(a3),a3
		lea		scanLineWidth-32(a4),a4
	ENDR

	REPT 4	;2 blocks
		movem.l	(a3)+,d0-d5
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-24(a3),a3
		lea		scanLineWidth-24(a4),a4
	ENDR
	rts


	dc.l	eor4label_105
	dc.l	eor4label_106
	dc.l	eor4label_107
	dc.l	eor4label_108
	dc.l	eor4label_109
	dc.l	eor4label_110
	dc.l	eor4label_111
	dc.l	eor4label_112
	dc.l	eor4label_113
	dc.l	eor4label_114
	dc.l	eor4label_115
	dc.l	eor4label_116
	dc.l	eor4label_117
	dc.l	eor4label_118
	dc.l	eor4label_119
	dc.l	eor4label_120
	dc.l	eor4label_121
	dc.l	eor4label_122
	dc.l	eor4label_123
	dc.l	eor4label_124
	dc.l	eor4label_125
	dc.l	eor4label_126
	dc.l	eor4label_127
	dc.l	eor4label_128
	dc.l	eor4label_129
	dc.l	eor4label_130
	dc.l	eor4label_131
	dc.l	eor4label_132
	dc.l	eor4label_133
	dc.l	eor4label_134
	dc.l	eor4label_135
	dc.l	eor4label_136
	dc.l	eor4label_137
	dc.l	eor4label_138
	dc.l	eor4label_139
	dc.l	eor4label_140
	dc.l	eor4label_141
eor4
;	nop
;	nop
;	nop
;	nop
		lea		8(a3),a3
		lea		8(a4),a4
;;;;;;;;;;	1
eor4label_001
	hsLeftBorder
		REPT 90-89
			nop
		ENDR
		movem.l	(a3)+,d0-d6							; read 7
		eor.l	d0,(a4)+					
		eor.l	d1,(a4)+					
		eor.l	d2,(a4)+					
		eor.l	d3,(a4)+					
		eor.l	d4,(a4)+					
		eor.l	d5,(a4)+					
		eor.l	d6,(a4)+					
		move.l	(a3)+,d0							; read 8
		eor.l	d0,(a4)+							; write 8
		lea		scanLineWidth-32(a3),a3				; update read
		lea		scanLineWidth-32(a4),a4				; update write
		movem.l	(a3)+,d0-d6							; read 7
		eor.l	d0,(a4)+							; write 1
		move.l	(a3)+,d0							; read 8
	hsRightBorder
		REPT 12-12
			nop
		ENDR
		lea		scanLineWidth-32(a3),a3				; update read
		eor.l	d1,(a4)+							
		eor.l	d2,(a4)+							;write 3
	hsStabilize
		REPT 12-12
			nop
		ENDR
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+							; write 5
		lea		scanLineWidth-32+12(a4),a2			; update write alt
;;;;;;;;;;;;;;;;;;;;;;;;; 2
eor4label_002
	hsLeftBorder
		REPT 90-90
			nop
		ENDR
		eor.l	d5,(a4)+					;5
		eor.l	d6,(a4)+					;10
		eor.l	d0,(a4)+					;15		write 8							;2 write
		movem.l	(a3)+,d0-d6					;32		read 7
		eor.l	d0,(a2)+					;37
		eor.l	d1,(a2)+					;42
		eor.l	d2,(a2)+					;47
		eor.l	d3,(a2)+					;52
		eor.l	d4,(a2)+					;57
		eor.l	d5,(a2)+					;62
		eor.l	d6,(a2)+					;67		write 7
		move.l	(a3)+,d0					;70		read 8						;3 read
		eor.l	d0,(a2)+					;75		write 8						;3 write
		lea		scanLineWidth-32(a3),a3		;77		updtate read
		movem.l	(a3)+,d0-d4					;90		read 5
	hsRightBorder
		REPT 12-12
			nop
		ENDR
		lea		scanLineWidth-32(a2),a4		;2		; update write
		eor.l	d0,(a4)+					;7
		eor.l	d1,(a4)+					;12		; write 2
	hsStabilize
		REPT 12-12
			nop
		ENDR	
		eor.l	d2,(a4)+					;5
		eor.l	d3,(a4)+					;10		; write 4
		lea		scanLineWidth-32+16(a4),a2	;12		; updare write alt


;;;;;;;;;; 3
eor4label_003
	hsLeftBorder
		REPT 90-90
			nop
		ENDR
		eor.l	d4,(a4)+					;5		; write 5
		move.l	(a3)+,d0					;8		read 6
		eor.l	d0,(a4)+					;13		write 6
		move.l	(a3)+,d0					;16		read 7
		move.l	(a3)+,d1					;19		read 8						;4 read
		eor.l	d0,(a4)+					;24
		eor.l	d1,(a4)+					;29		write 8						;4 write
		lea		scanLineWidth-32(a3),a3		;31		update read
		movem.l	(a3)+,d0-d6					;48		read 7
		eor.l	d0,(a2)+					;53	
		eor.l	d1,(a2)+					;58
		eor.l	d2,(a2)+					;63
		eor.l	d3,(a2)+					;68
		eor.l	d4,(a2)+					;73
		eor.l	d5,(a2)+					;78
		eor.l	d6,(a2)+					;83		write 7
		move.l	(a3)+,d6					;86		read 8							;5 read
		lea		scanLineWidth-40(a3),a3		;88		update read
		lea		scanLineWidth-40+4(a2),a4	;90		update write alt

	hsRightBorder
		REPT 12-11
			nop
		ENDR
		eor.l	d6,(a2)+					;5		write 8						;5 write		;;------> NEWNEWNEWNWNEWNEW
		move.l	(a3)+,d0					;3
		move.l	(a3)+,d1					;3		read 2

	hsStabilize
		REPT 12-12
			nop
		ENDR
		eor.l	d0,(a4)+					;5
		eor.l	d1,(a4)+					;10		write 2
		lea		scanLineWidth-40+32(a3),a1	;12		update read
;;;;;;;;4
eor4label_004
	hsLeftBorder
		REPT 90-89
			nop
		ENDR
		movem.l	(a3)+,d0-d6					;17		read 9
		eor.l	d0,(a4)+					;22
		eor.l	d1,(a4)+					;27
		eor.l	d2,(a4)+					;32
		eor.l	d3,(a4)+					;37
		eor.l	d4,(a4)+					;42
		eor.l	d5,(a4)+					;47
		eor.l	d6,(a4)+					;52
		move.l	(a3)+,d0					;55
		eor.l	d0,(a4)+					;60
		move.l	(a3)+,d0					;63
		eor.l	d0,(a4)+					;68
		move.l	(a3)+,d0					;71			read 12					;1 read (2)
		eor.l	d0,(a4)+					;76			write 12				;1 write (2)				write 1, 10 left

		movem.l	(a1)+,d0-d4					;89			read 5

	hsRightBorder
		REPT 12-12
			nop
		ENDR
		lea		scanLineWidth-48(a4),a4		;2			update write
		eor.l	d0,(a4)+					;7			write
		eor.l	d1,(a4)+					;12			write 2
	hsStabilize
		REPT 12-12
			nop
		ENDR
		eor.l	d2,(a4)+					;5
		eor.l	d3,(a4)+					;10			write 4
		lea		scanLineWidth-48+32(a4),a2	;12			update write
;;;;;;;;;;5
eor4label_005
	hsLeftBorder
		eor.l	d4,(a4)+					;5			write 5
		movem.l	(a1)+,d0-d6					;22			read 12					2 read
		eor.l	d0,(a4)+					;27
		eor.l	d1,(a4)+					;32
		eor.l	d2,(a4)+					;37
		eor.l	d3,(a4)+					;42
		eor.l	d4,(a4)+					;47
		eor.l	d5,(a4)+					;52
		eor.l	d6,(a4)+					;57			write 12				2 write						write 2, 9 left
		lea		scanLineWidth-48(a1),a3		;59			
		movem.l	(a3)+,d0-d4					;72			read 5
		eor.l	d0,(a2)+					;77
		eor.l	d1,(a2)+					;82
		eor.l	d2,(a2)+					;87			write 3
		move.l	(a3)+,d5					;90			;read 6
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		REPT 12-12
			nop
		ENDR
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+					; write 5
		lea		scanLineWidth-48+28(a2),a4	;12			update write
	hsStabilize
		REPT 12-11
			nop
		ENDR
		eor.l	d5,(a2)+					;write 6
		move.l	(a3)+,d0					
		move.l	(a3)+,d1					;read 8
;;;;;;;;	6
eor4label_006
	hsLeftBorder
		eor.l	d0,(a2)+					;5
		eor.l	d1,(a2)+					;10				write 8
		movem.l	(a3)+,d0-d3					;21				read 12
		eor.l	d0,(a2)+					;26
		eor.l	d1,(a2)+					;31
		eor.l	d2,(a2)+					;36
		eor.l	d3,(a2)+					;41				write 12											3 write, 8 left
		lea		scanLineWidth-48(a3),a3		;43			read
		movem.l	(a3)+,d0-d6					;60				read 7
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+					;
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+					;90				write 6

		REPT 90-90
			nop
		ENDR
	hsRightBorder
		REPT 12-11
			nop
		ENDR
		movem.l	(a3)+,d0-d3					;11			;read 11
	hsStabilize
		REPT 12-12
			nop
		ENDR
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+					;			; write 8
		lea		scanLineWidth-48+4(a3),a1		;43			read
eor4label_007
;;;;;;;7
	hsLeftBorder	
		eor.l	d1,(a4)+				;5
		eor.l	d2,(a4)+				;10
		eor.l	d3,(a4)+				;15
		move.l	(a3)+,d0				;18; read 12
		eor.l	d0,(a4)+				;23	; write 12							4 write			;23				7l
		lea		scanLineWidth-48(a4),a4		;25
		movem.l	(a1)+,d0-d6					;42 read 7
		eor.l	d0,(a4)+					
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+					;77		write 7
		movem.l	(a1)+,d0-d4					; read 12 90

		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-48(a1),a3		;43			read
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+					; write 11
		lea		scanLineWidth-48+4(a4),a2	
		REPT 12-12
			nop
		ENDR
eor4label_008
;;;;;;;;;8
	hsLeftBorder
		eor.l	d4,(a4)+						; 5 write
		movem.l	(a3)+,d0-d6				; read 7				22
		eor.l	d0,(a2)+					
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+				;57
		movem.l	(a3)+,d0-d4				;70				;read 12
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+				;90
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d4,(a2)+								; write 12					5 write				6l
		lea		scanLineWidth-48(a3),a3		
		lea		scanLineWidth-48(a2),a4
		move.l	(a3)+,d0									; read 1
		REPT 12-12
			nop
		ENDR
	hsStabilize
		movem.l	(a3)+,d1-d4								; read 5
		REPT 12-11
			nop
		ENDR


eor4label_009
;;;;;;9
	hsLeftBorder
		eor.l	d0,(a4)+							;5
		eor.l	d1,(a4)+							;10
		eor.l	d2,(a4)+							;15
		eor.l	d3,(a4)+							;20
		eor.l	d4,(a4)+							;25 write 5		25
		movem.l	(a3)+,d0-d6							;42 read 12		42
		eor.l	d0,(a4)+							;47
		eor.l	d1,(a4)+							;52
		eor.l	d2,(a4)+							;57 
		eor.l	d3,(a4)+							;62
		eor.l	d4,(a4)+							;67
		eor.l	d5,(a4)+							;72
		eor.l	d6,(a4)+							;77		write 12				6 write				5l
		lea		scanLineWidth-48(a3),a3				;79
		movem.l	(a3)+,d0-d3							;90		read 4


		REPT 90-90
			nop
		ENDR
	hsRightBorder
		lea		scanLineWidth-48(a4),a2		;2
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+

		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+							; write 4
		lea		scanLineWidth-48+32(a2),a4		;2
		REPT 12-12
			nop
		ENDR



eor4label_010
;;;;;;;;;;10
	hsLeftBorder
		movem.l	(a3)+,d0-d6						;17 	read 11	
		write7	a2								;52 	write 11
		move.l	(a3)+,d0						;55		r12
		eor.l	d0,(a2)+						;60		w12				;7 write		4l
		lea		scanLineWidth-48(a3),a3			;62
		movem.l	(a3)+,d0-d6						;79		r7
		eor.l	d0,(a4)+						;84
		eor.l	d1,(a4)+						;89
		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+						;w4
		lea		scanLineWidth-48-8+32(a4),a2		;2
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+						;w6
		lea		scanLineWidth-48-8+20(a3),a1
		REPT 12-12
			nop
		ENDR
eor4label_011
;;;;;;;;;;
	hsLeftBorder
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d4		;r12	
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12	;43
		movem.l	(a1)+,d0-d6		;r7		;60
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+		;w7
		eor.l	d0,(a2)+		;w8
		lea		scanLineWidth-64+32(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;
eor4label_012
;;;;;;;;;;;;;
	hsLeftBorder
		eor.l	d1,(a2)+		;w9
		eor.l	d2,(a2)+		;w10
		eor.l	d3,(a2)+		;w11
		movem.l	(a1)+,d0-d4		;r16		
		eor.l	d0,(a2)+		;w12
		eor.l	d1,(a2)+		;w13
		eor.l	d2,(a2)+		;w14
		eor.l	d3,(a2)+		;w15
		eor.l	d4,(a2)+		;w16		53
		lea		scanLineWidth-64(a1),a3		;55
		movem.l	(a3)+,d0-d6		;r7			72
		lea		scanLineWidth-64(a2),a4		;74
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w3			;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w5
		lea		scanLineWidth-64+44(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		lea		scanLineWidth-64+36(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;




eor4label_013
;;;;;;;;;;;;;;;;;23
	hsLeftBorder
		movem.l	(a3)+,d0-d6				;r14	17
		write7	a4						;w14	52
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+				;w16	68			8w,8l
		movem.l	(a1)+,d0-d6				;r7		85
		eor.l	d0,(a2)+				;80
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d1,(a2)+				;85
		eor.l	d2,(a2)+				;90	w3
		lea		scanLineWidth-64+52(a2),a4
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+				;w5
		lea		scanLineWidth-64+36(a1),a3
		REPT 12-12
			nop
		ENDR
eor4label_014
;;;;; 24
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+				;10	w7
		movem.l	(a1)+,d0-d6				;27	r14
		write7	a2						;62	w14
		move.l	(a1)+,d0
		eor.l	d0,(a2)+
		move.l	(a1)+,d0
		eor.l	d0,(a2)+				;78	r16/w16		9w,7l
		movem.l	(a3)+,d0-d3 			;r4				;
		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-64+48(a3),a1

		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-64+48(a4),a2
		REPT 12-12
			nop
		ENDR


; HERE LEFT
eor4label_015
;;;;;;;;;;;;;;;;;25
	hsLeftBorder
		movem.l	(a3)+,d0-d6			;r11
		write7	a4					;52
		movem.l	(a3)+,d0-d4			;r16	65
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+			;90	w16				10,6l
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3			;11	r4
		REPT 12-11
			nop
		ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-64+48(a1),a3
		REPT 12-12
			nop
		ENDR

;;;;;26
eor4label_016
;;;;;;;;;;;;;;;;;
	hsLeftBorder
		eor.l	d2,(a2)+			;			5
		eor.l	d3,(a2)+			;w4			10
		movem.l	(a1)+,d0-d6			;r11		27
		write7	a2					;w11		62

		movem.l	(a1)+,d0-d4			;13			75
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+			;90

		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+			;w16					11,5l
		lea		scanLineWidth-64(a2),a4
		REPT 12-12
			nop
		ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3			;11			;r4
		REPT 12-11		
			nop
		ENDR

eor4label_017
;;;;;27
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;20				w4
		movem.l	(a3)+,d0-d6		;37				r11
		write7	a4				;w11	72
		movem.l	(a3)+,d0-d4		;13		85
		eor.l	d0,(a4)+		;w12
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-64(a3),a1
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w16						12,4
		lea		scanLineWidth-64(a4),a2
		REPT 12-12
			nop
		ENDR

eor4label_018
;;;;;;;;;;;; 30
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r7	17
		write7	a2				;w7	52
		movem.l	(a1)+,d0-d6		;r14	69
		eor.l	d0,(a2)+		;74	
		eor.l	d1,(a2)+		;79
		eor.l	d2,(a2)+		;84
		eor.l	d3,(a2)+		;89
		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w13
		lea		scanLineWidth-64+8(a1),a3
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d6,(a2)+		;w14
		move.l	(a1)+,d0	
		move.l	(a1)+,d1		;r16
		REPT 12-11
			nop
		ENDR

;;;;;;; xxx

eor4label_019
;;;;;;;31
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			;w16				13,3
		movem.l	(a3)+,d0-d6			;r7		27
		lea		scanLineWidth-64(a2),a4	;29
		write7	a4					;64		w7
		movem.l	(a3)+,d0-d6			;r14	81
		eor.l	d0,(a4)+			;	w8	86
		move.l	(a3)+,d0			;r15
		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-64+4(a3),a1
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+				;w12
		lea		scanLineWidth-64+16(a4),a2
		REPT 12-12
			nop
		ENDR
;;;;;;;;32
eor4label_020
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+
		move.l	(a3)+,d0		;r16	
		eor.l	d0,(a4)+		;w16		23			14,2
		movem.l	(a1)+,d0-d6		;r7			40
		write7	a2				;w7			75
		movem.l	(a1)+,d0-d5		;r13		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-64+12(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		lea		scanLineWidth-64+20(a2),a4
	REPT 12-12
		nop
	ENDR
;;;;;
eor4label_021
;;;;;;;;33
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		move.l	(a1)+,d0
		eor.l	d0,(a2)+
		move.l	(a1)+,d0
		eor.l	d0,(a2)+
		move.l	(a1)+,d0
		eor.l	d0,(a2)+			;34		w16		15,1
		movem.l	(a3)+,d0-d6			;51		r7
		write7	a4					;86		w7
		move.l	(a3)+,d0			;89		r8

	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+			;5	w8
		move.l	(a3)+,d0
		move.l	(a3)+,d1			;r10
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+			;w10
		lea		scanLineWidth-64+24(a3),a1
	REPT 12-12
		nop
	ENDR

;;;;;
;;;;;
eor4label_022
;;;;;;;;34
	hsLeftBorder
		movem.l	(a3)+,d0-d5		;r16
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;45		;w16		16,0
		lea		scanLineWidth-64(a4),a2		;47
		movem.l	(a1)+,d0-d6		;r7			64
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		lea		scanLineWidth-64+36(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;;;
eor4label_023
;;;;;;;;;;;;;
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11		;20
		movem.l	(a1)+,d0-d4		;r16		;33
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+					
		eor.l	d4,(a2)+		;w16		58
		lea		scanLineWidth-64(a1),a3		;60
		movem.l	(a3)+,d0-d6		;r7			;77
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
	REPT 90-87
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-64+48(a4),a2	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-64+36(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_024
;;;;;;;;;;;;;
	hsLeftBorder
		eor.l	d6,(a4)+		;w7
		movem.l	(a3)+,d0-d6		;r14		22
		write7	a4				;w14		57
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r16
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w16		73
		movem.l	(a1)+,d0-d6		;r7			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		lea		scanLineWidth-64+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-64+36(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_025
;;;;;;;;;;;;;
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		movem.l	(a1)+,d0-d6		;r14		32
		write7	a2				;w14		67
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r16		73
		movem.l	(a3)+,d2-d6		;r5			86
	REPT 90-86
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w16
		lea		scanLineWidth-64+44(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w2
		lea		scanLineWidth-64+56(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_026
;;;;;;;;;;;;;
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w5
		movem.l	(a3)+,d0-d6		;r12		32
		write7	a4				;w12		67
		movem.l	(a3)+,d3-d6		;r16		78
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w14		88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w16
		lea		scanLineWidth-64+44(a1),a3
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_027
;;;lalalalla
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;20				w4
		movem.l	(a1)+,d0-d6		;37				r11
		write7	a2				;w11	72
		movem.l	(a1)+,d0-d4		;13		85
		eor.l	d0,(a2)+		;w12
		REPT 90-90
			nop
		ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		lea		scanLineWidth-64(a1),a3
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w16						12,4
		lea		scanLineWidth-64(a2),a4
		REPT 12-12
			nop
		ENDR
eor4label_028
;;;;;;;;;;;; 30
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7	17
		write7	a4				;w7	52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		;74	
		eor.l	d1,(a4)+		;79
		eor.l	d2,(a4)+		;84
		eor.l	d3,(a4)+		;89
		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w13
		lea		scanLineWidth-64+8(a3),a1
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d6,(a4)+		;w14
		move.l	(a3)+,d0	
		move.l	(a3)+,d1		;r16
		REPT 12-11
			nop
		ENDR

;;;;;;; xxx
eor4label_029

;;;;;;;31
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+			;w16				13,3
		movem.l	(a1)+,d0-d6			;r7		27
		lea		scanLineWidth-64(a4),a2	;29
		write7	a2					;64		w7
		movem.l	(a1)+,d0-d6			;r14	81
		eor.l	d0,(a2)+			;	w8	86
		move.l	(a1)+,d0			;r15
		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		lea		scanLineWidth-64+4(a1),a3
		REPT 12-12
			nop
		ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+				;w12
		lea		scanLineWidth-64+16(a2),a4
		REPT 12-12
			nop
		ENDR
;;;;;;;;32
eor4label_030
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		move.l	(a1)+,d0		;r16	
		eor.l	d0,(a2)+		;w16		23			14,2
		movem.l	(a3)+,d0-d6		;r7			40
		write7	a4				;w7			75
		movem.l	(a3)+,d0-d5		;r13		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-64+12(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-64+20(a4),a2
	REPT 12-12
		nop
	ENDR
;;;;;
eor4label_031
;;;;;;;;33
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+			;34		w16		15,1
		movem.l	(a1)+,d0-d6			;51		r7
		write7	a2					;86		w7
		move.l	(a1)+,d0			;89		r8

	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+			;5	w8
		move.l	(a1)+,d0
		move.l	(a1)+,d1			;r10
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			;w10
		lea		scanLineWidth-64+24(a1),a3
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;
;;;;;
;;;;;
eor4label_032
;;;;;;;;34
	hsLeftBorder
		movem.l	(a1)+,d0-d5		;r16
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;45		;w16		16,0
		lea		scanLineWidth-64(a2),a4		;47
		movem.l	(a3)+,d0-d6		;r7			64
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w5		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w7
		lea		scanLineWidth-64-8+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;;;
eor4label_033
;;;;;;;;;;;;;
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11		;20
		movem.l	(a3)+,d0-d4		;r16		;33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+					
		eor.l	d4,(a4)+		;w16		58
		lea		scanLineWidth-64-8(a3),a1		;60
		movem.l	(a1)+,d0-d6		;r7			;77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
	REPT 90-87
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-80+64(a2),a4	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-80+52(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;;;
;HAX
;;;;
;	hsLeftBorder
;		eor.l	d6,(a2)+		;w7
;		movem.l	(a1)+,d0-d6		;r14		22
;		write7	a2				;w14		57
;		movem.l	(a1)+,d0-d5		;r20		72
;		eor.l	d0,(a2)+		;w15
;		eor.l	d1,(a2)+		;w16
;		eor.l	d2,(a2)+		;w17		87
;	REPT 90-87
;		nop
;	ENDR
;	hsRightBorder
;	REPT 12
;		nop
;	ENDR
;	hsStabilize
;	REPT 12
;		nop
;	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;77
eor4label_034
;zzzz
	hsLeftBorder
		eor.l	d6,(a2)+		;w7
		movem.l	(a1)+,d0-d6		;r14	22
		write7	a2				;w14	57
		movem.l	(a1)+,d0-d5		;r20	72
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10	87
		move.l	(a3)+,d0		;r1
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		lea		scanLineWidth-80+76(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+		;w20						28,32
		eor.l	d0,(a4)+		;w1
		lea		scanLineWidth-80+76(a4),a2
	REPT 12-12
		nop
	ENDR
eor4label_035
;;;;;;;;;;;;;78
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r8	17
		write7	a4				;w8	52
		movem.l	(a3)+,d0-d6		;r15 69
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w12	
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+		;
		eor.l	d5,(a4)+		;w14
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+		;w15
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r17
	REPT 12-11
		nop
	ENDR
eor4label_036
;;;;;;;;;;;;;79
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w17
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		move.l	(a3)+,d0				
		eor.l	d0,(a4)+		;w20	34					29,31
		movem.l	(a1)+,d0-d6		;r7		51
		write7	a2				;w7		86
		lea		scanLineWidth-80+52(a1),a3
		lea		scanLineWidth-80+52(a2),a4
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
	REPT 12-10
		nop
	ENDR
eor4label_037
;;;;;;;;;;;;;80
	hsLeftBorder
		eor.l	d2,(a2)+				;5
		eor.l	d3,(a2)+		;w11	10
		movem.l	(a1)+,d0-d6		;r18	27
		write7	a2				;w18	62
		move.l	(a1)+,d0		;		65
		eor.l	d0,(a2)+		;		70
		move.l	(a1)+,d0		;		73
		eor.l	d0,(a2)+		;w20	78				30,30
		movem.l	(a3)+,d0-d3		;r4		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-80+72(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-80+64(a3),a1
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;81
eor4label_038
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r11
		write7	a4				;w11	52
		movem.l	(a3)+,d0-d6		;r18	69
		eor.l	d0,(a4)+		;w12
		eor.l	d1,(a4)+		;w13
		eor.l	d2,(a4)+		;w14
		eor.l	d3,(a4)+		;w15	89	
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r20
		eor.l	d4,(a4)+		;w16
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+		;w17
		eor.l	d6,(a4)+		;w18
	REPT 12-10
		nop
	ENDR
;;;;;;;;;;;;;82
eor4label_039
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w20						31,29
		movem.l	(a1)+,d0-d6		;r7		27
		write7	a2				;w7		62
		movem.l	(a1)+,d0-d6		;r14	79
		eor.l	d0,(a2)+		;w8		84
		eor.l	d1,(a2)+		;w9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		lea		scanLineWidth-80+24(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w13
		lea		scanLineWidth-80+28(a2),a4
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;83
eor4label_040
	hsLeftBorder
		eor.l	d6,(a2)+		;w14		5
		movem.l	(a1)+,d0-d5		;r20		20
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+									;32,28
		eor.l	d5,(a2)+			;55
		movem.l	(a3)+,d0-d6		;r7		;67
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;87
		lea		scanLineWidth-80+52(a3),a1	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6
		lea		scanLineWidth-80+56(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+		;w7
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9
	REPT 12-11
		nop
	ENDR
;;;;;;;;;;;;;84
eor4label_041
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9		10
		movem.l	(a3)+,d0-d6		;r16	27
		write7	a4				;w16	62
		movem.l	(a3)+,d0-d3		;r20	73
		eor.l	d0,(a4)+			;78
		eor.l	d1,(a4)+			;83
		eor.l	d2,(a4)+			;88
		lea		scanLineWidth-80+80(a1),a3	
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+		;w20						;33,27
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r2
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;85
eor4label_042
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r9	17
		write7	a2				;w7	52
		movem.l	(a1)+,d0-d6		;r16	69
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
	REPT 12-10
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r20
	REPT 12-11
		nop
	ENDR
;;;;;;;;;;;;;86
eor4label_043
	hsLeftBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w20							;34,26
		movem.l	(a3)+,d0-d6		;r7		42
		write7	a4				;w7		77
		movem.l	(a3)+,d0-d4		;r12	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-80+44(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-80+32(a3),a1
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;87
eor4label_044
	hsLeftBorder
		eor.l	d4,(a4)+		;w12	;5
		movem.l	(a3)+,d0-d6		;r19	;22
		write7	a4				;w19	;57
		move.l	(a3)+,d0		;		;60
		eor.l	d0,(a4)+		;w20	;65					;35,25
		movem.l	(a1)+,d0-d6		;r7		;82
		eor.l	d0,(a2)+		;w1		;87
		move.l	(a1)+,d0		;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w3
		lea		scanLineWidth-80+48(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-80+60(a2),a4
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;88
eor4label_045
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+		;w8		15
		movem.l	(a1)+,d0-d6		;r15	32
		write7	a2				;w15	67
		movem.l	(a1)+,d0-d4		;r20	80
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w17
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+		;w18
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r2
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+		;w19
		move.l	(a3)+,d2
		move.l	(a3)+,d3		;r4
	REPT 12-11
		nop
	ENDR

;;;;;;;;;;;;;89
eor4label_046
	hsLeftBorder
		eor.l	d4,(a2)+		;w20						;36,24
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		25
		movem.l	(a3)+,d0-d6		;r11	42
		write7	a4				;w11	77
		movem.l	(a3)+,d0-d4		;r16	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13
		lea		scanLineWidth-80+28(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-80+16(a3),a1
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;90
eor4label_047
	hsLeftBorder
		eor.l	d4,(a4)+		;w16		5
		movem.l	(a3)+,d0-d3		;r20		16
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w20		36				;37,23
		movem.l	(a1)+,d0-d6		;r7			53
		write7	a2				;w7			88
		lea		scanLineWidth-80+52(a1),a3	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r11		11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-80+44(a2),a4
	REPT 12-12
		nop
	ENDR
;;;;;;;;;;;;;91
eor4label_048
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		movem.l	(a1)+,d0-d6		;r18	27
		write7	a2				;w18	62
		move.l	(a1)+,d0		;	
		eor.l	d0,(a2)+
		move.l	(a1)+,d0
		eor.l	d0,(a2)+		;w20	78					;38,22
		movem.l	(a3)+,d0-d3		;r4		89

	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-80+64(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-80+64(a4),a2
	REPT 12-12
		nop
	ENDR

;;;;;;;;;;;;;92
eor4label_049
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r11	17
		write7	a4				;w11	52
		movem.l	(a3)+,d0-d6		;r18	69
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		move.l	(a3)+,d0		;r19
		move.l	(a3)+,d1		;r20
		eor.l	d4,(a4)+		
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
	REPT 12-10
		nop
	ENDR	

;;;;;;;;;;;;;93
eor4label_050
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w20						;39,21
		movem.l	(a1)+,d0-d6		;r7		27
		write7	a2				;w7		62
		movem.l	(a1)+,d0-d6		;r14	79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		lea		scanLineWidth-80+36(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		lea		scanLineWidth-80+24(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;94
eor4label_051
	hsLeftBorder
		eor.l	d6,(a2)+		;w14	5
		movem.l	(a1)+,d0-d5		;r20	20
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w20	;50				;40,20
		movem.l	(a3)+,d0-d6		;r7		;67
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		move.l	(a3)+,d0		;r8		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-80+48(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+		;w8
		lea		scanLineWidth-80+48(a4),a2
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;95
eor4label_052
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r15
		write7	a4				;w15	52
		movem.l	(a3)+,d0-d4		;r20	65
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w20	90				;41,19
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;96
eor4label_053
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		movem.l	(a1)+,d0-d6		;r11	27
		write7	a2				;w11	62
		movem.l	(a1)+,d0-d6		;r18	79
		eor.l	d0,(a2)+		;
		eor.l	d1,(a2)+		;w13
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-80+8(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+		;w16
		move.l	(a1)+,d0		;r19
		move.l	(a1)+,d1		;r20
	REPT 12-11
		nop
	ENDR	

;;;;;;;;;;;;;97
eor4label_054
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;20	w20					;42,18
		movem.l	(a3)+,d0-d6		;r7			37
		write7	a4				;w7			72
		movem.l	(a3)+,d0-d6		;r14		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-80+24(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-80+36(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;;;;;;;;;;;; CHECK
;;;;;;;;;;;;;98
eor4label_055
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14		15
		movem.l	(a3)+,d0-d5		;r20		30
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w20			60			;43,17
		movem.l	(a1)+,d0-d6		;r7				77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		move.l	(a1)+,d0		;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-80+48(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-80+56(a2),a4
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;99
eor4label_056
	hsLeftBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+		;w8
		movem.l	(a1)+,d0-d6		;r15		27
		write7	a2				;w15		62
		movem.l	(a1)+,d0-d4		;r20		75
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w18		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w20					;44,16
		lea		3*scanLineWidth-80(a1),a0									;a3 = 0, a1=+1 a3 = +2, a0 = +3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;;;100
eor4label_057
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		20
		movem.l	(a3)+,d0-d6		;r11	37
		write7	a4				;w11	72
		movem.l	(a3)+,d0-d6		;r18	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13
		lea		scanLineWidth-80+28(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-80+8(a3),a1
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;101
eor4label_058
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w18	15
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+		;w20	31					;45,15
		movem.l	(a1)+,d0-d6		;r7		48
		write7	a2				;w7		83
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-80+44(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	

;;;;;;;;;;;;;102
eor4label_059
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w13	20
		movem.l	(a1)+,d0-d6		;r20	37
		write7	a2				;w20	72
		movem.l	(a0)+,d0-d6		;r7		89

	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+		;		87
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-80+72(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-80+52(a0),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CONTINUE
;;;;; ERROR FIX IM SAD NOW
eor4label_060
	hsLeftBorder	
		move.l	(a0)+,d0		;r8		3
		eor.l	d4,(a4)+		;w5		5
	REPT 90-8
		nop
	ENDR
	hsRightBorder
	REPT 12
		nop
	ENDR
	hsStabilize
	REPT 12
		nop
	ENDR
;;;;;;;;;;;;;103
eor4label_061
	hsLeftBorder
		eor.l	d5,(a4)+		;w6
		eor.l	d6,(a4)+		;w7
		eor.l	d0,(a4)+		;w8			15
		movem.l	(a0)+,d0-d6		;r15		32
		write7	a4				;w15		67
		movem.l	(a0)+,d0-d4		;r20		80
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w17		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+		;
		eor.l	d3,(a4)+		;w19
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+		;w20					;47,13
		move.l	(a3)+,d0		;r1
		move.l	(a3)+,d1		;r2
	REPT 12-11
		nop
	ENDR	

;;;;;;;;;;;;;104
eor4label_062
	hsLeftBorder	
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2		10
		movem.l	(a3)+,d0-d6		;r9		27
		write7	a2				;w9		62
		movem.l	(a3)+,d0-d6		;r16	79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w11	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w13
		lea		scanLineWidth-80+28(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w15
		lea		scanLineWidth-80+16(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;105
eor4label_063
	hsLeftBorder
		eor.l	d6,(a2)+		;w16		5
		movem.l	(a3)+,d0-d3		;r20		16
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w20		36				;48,12
		movem.l	(a1)+,d0-d6		;r7			53
		write7	a4				;w7			88
		lea		scanLineWidth-80+52(a1),a3	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r11		
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-80+44(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;106
eor4label_064
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11	
		movem.l	(a1)+,d0-d6		;r18	27
		write7	a4				;w18	62
		move.l	(a1)+,d0		;
		move.l	(a1)+,d1		;		68
		eor.l	d0,(a4)+		;
		eor.l	d1,(a4)+		;w20	78				;49,11
		movem.l	(a3)+,d0-d3		;r4		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-80+64(a3),a1
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;107
eor4label_065
	hsLeftBorder
		movem.l	(a3)+,d0-d6	;r11
		write7	a2			;w11		52
		movem.l	(a3)+,d0-d6	;r18		69
		eor.l	d0,(a2)+	
		eor.l	d1,(a2)+	
		eor.l	d2,(a2)+	
		eor.l	d3,(a2)+	;w15		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+	;w16
		move.l	(a3)+,d0
		move.l	(a3)+,d1	;r20
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+	;w18
		lea		scanLineWidth(a1),a3
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;108
eor4label_066
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w20							;50,10
		movem.l	(a1)+,d0-d6	;r7		27	
		write7	a4			;w7		62
		movem.l	(a1)+,d0-d6	;r14	79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w9
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w11
		lea		scanLineWidth-80+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	;w13
	REPT 12-10
		nop
	ENDR	

;;;;;;;;;;;;;109
eor4label_067
	hsLeftBorder
		eor.l	d6,(a4)+	;w14		5
		movem.l	(a1)+,d0-d5	;r20		20
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	;			50					;51,9
		movem.l	(a3)+,d0-d6	;r7			67
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w4
		move.l	(a3)+,d0	;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+	;w6
		lea		scanLineWidth-80+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+	;w8
		lea		scanLineWidth-80+48(a3),a1
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;110
eor4label_068
	hsLeftBorder
		movem.l	(a3)+,d0-d6	;r15	17
		write7	a2			;w15	52
		movem.l	(a3)+,d0-d4	;r20	65
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+	;w20	90					;52,8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3	;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w2
		lea		scanLineWidth-80+72(a4),a2
	REPT 12-12
		nop
	ENDR	


;;;;;;;;;;;;;111
eor4label_069
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w4		10
		movem.l	(a1)+,d0-d6	;r11	27
		write7	a4			;w11	62
		movem.l	(a1)+,d0-d6	;r18	79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w13	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w15
		lea		scanLineWidth-80+8(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+	;w16
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r20
	REPT 12-11
		nop
	ENDR	

;;;;;;;;;;;;;112
eor4label_070
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w20								;53,7
		movem.l	(a3)+,d0-d6	;r7		37
		write7	a2			;w7		72
		movem.l	(a3)+,d0-d6	;r14	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w9
		lea		scanLineWidth-80+44(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-80+24(a3),a1
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;113
eor4label_071
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+	; w14
		movem.l	(a3)+,d0-d5	; r20
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+	;w20		45+15 = 60				;54,6
		movem.l	(a1)+,d0-d6	;r7			77
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		move.l	(a1)+,d0	;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+	
		eor.l	d3,(a4)+	;w4
		lea		scanLineWidth-80+64(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	;w6
		lea		scanLineWidth-80+48(a1),a3
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;114
eor4label_072
	hsLeftBorder
		eor.l	d6,(a4)+		;w7
		eor.l	d0,(a4)+		;w8
		movem.l	(a1)+,d0-d6		;r15		22
		write7	a4				;w15		57
		movem.l	(a1)+,d0-d4		;r20		70
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w18
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+		;w19		90				;55,5
		move.l	(a3)+,d0		;
		move.l	(a3)+,d1		;r2
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+		;w20
		eor.l	d0,(a2)+		;w1
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;115
eor4label_073
	hsLeftBorder
		eor.l	d1,(a2)+		;w2			;5
		movem.l	(a3)+,d0-d6		;r9			;22
		write7	a2				;w9			;57
		movem.l	(a3)+,d0-d6		;r16		;74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w12		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		lea		scanLineWidth-80+16(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w16
		lea		scanLineWidth-80+16(a2),a4
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;116
eor4label_074
	hsLeftBorder
		movem.l	(a3)+,d0-d3		;r20		11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w20		31			56,4
		movem.l	(a1)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a1)+,d0		;r8			86
		lea		scanLineWidth-80+48(a1),a3	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+		;w8
		move.l	(a1)+,d0		;r9
		move.l	(a1)+,d1		;r10
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w10
		lea		scanLineWidth-80+40(a4),a2
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;;;117
eor4label_075
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r17		17
		write7	a4				;w17		52
		movem.l	(a1)+,d0-d2		;r20		61
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w20		76			55,3
		movem.l	(a3)+,d0-d4		;r5			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-80+60(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;118
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_076
	hsLeftBorder
		eor.l	d4,(a2)+		;w5		5
		movem.l	(a3)+,d0-d6		;r11	22
		write7	a2				;w11	57
		movem.l	(a3)+,d0-d4		;r16	70
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		
		eor.l	d3,(a2)+		;w15	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r20
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d0,(a2)+		;w17
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_077
	hsLeftBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w20	15
		movem.l	(a1)+,d0-d6		;r7		32
		write7	a4				;w7		67
		movem.l	(a1)+,d0-d6		;r14	84
		eor.l	d0,(a4)+		;w8		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w10
		lea		scanLineWidth-80+40(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-80+24(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;

;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_078
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14		10
		movem.l	(a1)+,d0-d5		;r20		25
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w20		55
		movem.l	(a3)+,d0-d6		;r7			72
		eor.l	d0,(a2)+		
		eor.l	d1,(a2)+		
		eor.l	d2,(a2)+		;w3			87
	REPT 90-87
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		lea		scanLineWidth-80+52(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		lea		scanLineWidth-80+52(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_079
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r14
		write7	a2				;w14		52
		movem.l	(a3)+,d0-d5		;r20		67
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		87
		move.l	(a1)+,d0		;r1			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+		;w19
		eor.l	d5,(a2)+		;w20
	REPT 12-10
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d1-d4		;r5
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;

;;;;;;;;;;;;;
eor4label_080
	hsLeftBorder
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		
		eor.l	d4,(a4)+		;w5		25
		movem.l	(a1)+,d0-d6		;r12	42
		write7	a4				;w12	77
		movem.l	(a1)+,d0-d4		;r17	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w14
		lea		scanLineWidth-80+24(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w16
		lea		scanLineWidth-80+12(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;

;;;;;;;;;;;;;

;;;;;;;;;;;;;
eor4label_081
	hsLeftBorder
		eor.l	d4,(a4)+		;w17	;5
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		move.l	(a1)+,d2		;r20	14
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+				;29
		movem.l	(a3)+,d0-d6		;r7			;46
		write7	a2				;w7			;81
	REPT 90-81
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-80+44(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;

;;;;;;;;;;;;;
eor4label_082
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		movem.l	(a3)+,d0-d6		;r18
		write7	a2				;w18		62
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w20		78
		lea		scanLineWidth-80(a3),a1		;80
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		move.l	(a1)+,d2		;r3
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d3-d6		;r7
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-80+72(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;

;;;;;;;;;;;;;
eor4label_083
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w7		25
		movem.l	(a1)+,d0-d6		;r14	42
		write7	a4				;w14	77
		movem.l	(a1)+,d0-d4		;r19	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w16
		lea		scanLineWidth-80+4(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w18
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;

;;;;;;;;;;;;;
eor4label_084
	hsLeftBorder
		eor.l	d4,(a4)+
		move.l	(a1)+,d0
		eor.l	d0,(a4)+	;w20		13
		movem.l	(a3)+,d0-d6		;r7		30
		write7	a2				;w7		65
		movem.l	(a3)+,d0-d6		;r14	82
		eor.l	d0,(a2)+		;w8		87
		move.l	(a3)+,d0		;r15	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10
		lea		scanLineWidth-80+40(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-80+20(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;

;;;;;;;;;;;;;
eor4label_085
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+		;w15
		movem.l	(a3)+,d0-d4		;r20		28
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w20	53
		movem.l	(a1)+,d0-d6		;r7		70
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+		;w5
		eor.l	d5,(a4)+		;w6
		lea		scanLineWidth-80+56(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;

;;;;;;;;;;;;;
eor4label_086
	hsLeftBorder
		eor.l	d6,(a4)+		;w7
		eor.l	d0,(a4)+		;w8
		eor.l	d1,(a4)+		;w9
		eor.l	d2,(a4)+		;w10
		eor.l	d3,(a4)+		;w11
		movem.l	(a1)+,d0-d6		;r18		;37
		write7	a4				;w18		;72
		move.l	(a1)+,d0
		move.l	(a1)+,d4		;r20		;78
		eor.l	d0,(a4)+
		lea		scanLineWidth-80(a1),a3		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+		;88
		eor.l	d0,(a2)+		;w1
		lea		scanLineWidth-80+76(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_087
	hsLeftBorder
		eor.l	d1,(a2)+		;w2
		eor.l	d2,(a2)+		;w3
		eor.l	d3,(a2)+		;w4
		movem.l	(a3)+,d0-d6		;r11
		write7	a2				;w11		67
		movem.l	(a3)+,d0-d6		;r18		84
		eor.l	d0,(a2)+		;w12		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+		;w13
		eor.l	d2,(a2)+		;w14
		lea		scanLineWidth-80+8(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w16
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_088
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w18
		move.l	(a3)+,d0
		move.l	(a3)+,d1		
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w20		26
		movem.l	(a1)+,d0-d6		;r7			43
		write7	a4				;w7			78
		movem.l	(a1)+,d0-d3		;r11		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-80+44(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-80+36(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;

;;;;;;;;;;;;;
eor4label_089
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r18
		write7	a4				;w18	52
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w20	68
		movem.l	(a3)+,d0-d6		;r7		85
		eor.l	d0,(a2)+		;w1		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w3		
		lea		scanLineWidth-80+68(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-80+52(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;

;;;;;;;;;;;;;
eor4label_090
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+	;w7
		movem.l	(a3)+,d0-d6		;r14
		write7	a2				;w14		62
		movem.l	(a3)+,d0-d5		;r20		77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w16		87
		move.l	(a1)+,d0		;r1			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18
		lea		scanLineWidth-80+76(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w20
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;;

;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_091	
	hsLeftBorder
		eor.l	d0,(a4)+		;w1
		movem.l	(a1)+,d0-d6		;r8
		write7	a4				;w8		57
		movem.l	(a1)+,d0-d6		;r15	74
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w11	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w13
		lea		scanLineWidth-80+28(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;15
		lea		scanLineWidth(a3),a0
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;

;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_092
	hsLeftBorder
		movem.l	(a1)+,d0-d4		;r20
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w20	38
		movem.l	(a3)+,d0-d6		;r7		55
		write7	a2				;w7
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-80+44(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;


;;;;;;;;;;;;;
eor4label_093
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11		10
		movem.l	(a3)+,d0-d6		;r18		27
		write7	a2				;w18	62	
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w20	78
		movem.l	(a0)+,d0-d3		;r4		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-80+72(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;W4
		lea		scanLineWidth-80+64(a0),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;

;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_094
	hsLeftBorder
		movem.l	(a0)+,d0-d6		;r11		
		write7	a4				;w11	52
		movem.l	(a0)+,d0-d6		;r18	69
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w17
	REPT 12-10
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_095
	hsLeftBorder
		eor.l	d6,(a4)+		;w18
		move.l	(a0)+,d6	
		eor.l	d6,(a4)+		;w19
		move.l	(a0)+,d6		;
		eor.l	d6,(a4)+		;w20	21
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4		41
		movem.l	(a3)+,d0-d6		;r11	58
		eor.l	d0,(a2)+		;w5
		eor.l	d1,(a2)+		;w6
		eor.l	d2,(a2)+		;w7
		eor.l	d3,(a2)+		;w8
		eor.l	d4,(a2)+		;w9
		eor.l	d5,(a2)+		;w10	88
		lea		scanLineWidth-80+40(a2),a4
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;w15
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+		;w11
		eor.l	d0,(a2)+		;w12
		lea		scanLineWidth-80+20(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;

;;;;;;;;;;;;;
eor4label_096
	hsLeftBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w15		15
		movem.l	(a3)+,d0-d4		;r20		28
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	
		eor.l	d4,(a2)+		;w20		53
		movem.l	(a1)+,d0-d6		;r7			70
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+		;w5			90
		eor.l	d5,(a4)+
		lea		scanLineWidth-80+52(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_097
	hsLeftBorder
		eor.l	d6,(a4)+		;w7
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11	25
		movem.l	(a1)+,d0-d6		;r18	42
		write7	a4				;w18	77
		move.l	(a1)+,d0	
		move.l	(a1)+,d4		;83
		eor.l	d0,(a4)+		;88	w19
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+		;w20
		lea		scanLineWidth-80(a4),a2
		eor.l	d0,(a2)+		;w1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;

;;;;;;;;;;;;;
eor4label_098
	hsLeftBorder
		eor.l	d1,(a2)+		;w2
		eor.l	d2,(a2)+		;w3
		eor.l	d3,(a2)+		;w4
		movem.l	(a3)+,d0-d6		;r11
		write7	a2				;w11	67
		movem.l	(a3)+,d0-d6		;r18	84
		eor.l	d0,(a2)+
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+		;w13
		eor.l	d2,(a2)+
		lea		scanLineWidth-80+8(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+		;w15
		eor.l	d4,(a2)+
		lea		scanLineWidth-80+16(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_099
	hsLeftBorder
		eor.l	d5,(a2)+		;w17
		eor.l	d6,(a2)+		;w18		10
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;			16
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w20		26
		movem.l	(a1)+,d0-d6		;r7			43
		write7	a4				;w7			78
		movem.l	(a1)+,d0-d3		;r11		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-80+44(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-80+36(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_100
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r18
		write7	a4				;w18		52
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w20		68
		movem.l	(a3)+,d0-d6		;r7			85
		eor.l	d0,(a2)+		;w1			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;3
		lea		scanLineWidth-80+68(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-80+52(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_101
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		movem.l	(a3)+,d0-d6		;r14
		write7	a2				;w14		62
		movem.l	(a3)+,d0-d5		;r20		77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w16		87
	REPT 90-87
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w20
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;

;;;;;;;;;;;;;
eor4label_102
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r7
		write7	a4				;w7		52
		movem.l	(a1)+,d0-d6		;r14	69
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w13	
		lea		scanLineWidth-80+28(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r18
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_103
	hsLeftBorder
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w18
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+				;41
		lea		scanLineWidth-80(a1),a3	;43
		movem.l	(a3)+,d0-d6		;r7		;60
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6		
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+		;w8
		lea		scanLineWidth-80+48(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_104
	hsLeftBorder
		eor.l	d1,(a2)+								;5
		eor.l	d2,(a2)+								;10
		eor.l	d3,(a2)+		;w11		15			;15
		movem.l	(a3)+,d0-d6		;r18		32			;32
		write7	a2				;w18		67			;67
		move.l	(a3)+,d0								;70
		move.l	(a3)+,d1					;73			;73
		eor.l	d0,(a2)+								;78
		eor.l	d1,(a2)+		;w20		83			;83
		lea		scanLineWidth-80(a3),a1		;85			;85
		move.l	(a1)+,d0		;r1						;88
		lea		scanLineWidth-72+68(a1),a3	;90			;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d1-d4		;r6
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
	
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_105
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w5
		eor.l	d4,(a4)+		;w6
		movem.l	(a1)+,d0-d6		;r13
		write7	a4				;w13		67
		movem.l	(a1)+,d0-d5		;r18		82
		eor.l	d0,(a4)+
	REPT 90-87
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+		;w14	
		eor.l	d2,(a4)+		;w15
		lea		scanLineWidth-72(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_106
	hsLeftBorder
		eor.l	d5,(a4)+		;w18
		movem.l	(a3)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a3)+,d0-d6		;r14	74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;12	
		lea		scanLineWidth-72+16(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_107
	hsLeftBorder
		movem.l	(a3)+,d0-d3		;r18		11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a1)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a1)+,d0		;r8			86
		lea		scanLineWidth-72+40(a1),a3	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d1-d4		;r12		
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;

;;;;;;;;;;;;;
eor4label_108
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+	;w12		15
		movem.l	(a1)+,d0-d5	;r18		30
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	;w18		60
		movem.l	(a3)+,d0-d6		;r7		77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2	87
	REPT 90-87
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-72+56(a2),a4	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-72+44(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_109
	hsLeftBorder
		eor.l	d6,(a2)+		;w7		5
		movem.l	(a3)+,d0-d6		;r14	
		write7	a2				;w14	57
		movem.l	(a3)+,d0-d3		;r18	68
		eor.l	d0,(a2)+		
		eor.l	d1,(a2)+		
		eor.l	d2,(a2)+		
		eor.l	d3,(a2)+		;w18	88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-72+56(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_110
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		movem.l	(a1)+,d0-d6		;r11
		write7	a4				;w11	62
		movem.l	(a1)+,d0-d6		;r18	79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_111
	hsLeftBorder
		eor.l	d6,(a4)+		;w18			5				5
		movem.l	(a3)+,d0-d6		;r7								22
		write7	a2				;w7		57		57				57
		movem.l	(a3)+,d0-d6		;r14	74						74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12	89
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_112
	hsLeftBorder
		eor.l	d5,(a2)+		;w13
	REPT 90-5
		nop
	ENDR
	hsRightBorder
	REPT 12
		nop
	ENDR
	hsStabilize
	REPT 12
		nop
	ENDR
;;;;;;;;;;;;;
eor4label_113
	hsLeftBorder
		eor.l	d6,(a2)+		;w14
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+			;20		w18
		lea		scanLineWidth-72(a3),a1		;22
		movem.l	(a1)+,d0-d6		;r7		39
		write7	a4				;w7		79
		movem.l	(a1)+,d0-d3		;r11	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w11
		lea		scanLineWidth-72+28(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_114
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r18
		write7	a4				;w18		52
		movem.l	(a3)+,d0-d6		;r7			69
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-72+48(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_115
	hsLeftBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11		25
		movem.l	(a3)+,d0-d6		;r18		42
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		
		eor.l	d6,(a2)+		;w18		77
		lea		scanLineWidth-72(a3),a1		;79
		movem.l	(a1)+,d0-d3		;r4
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-72+56(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_116
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r11
		write7	a4				;w11	52
		movem.l	(a1)+,d0-d6		;r18	69
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w17	
		lea		scanLineWidth-72+56(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_117
	hsLeftBorder
		eor.l	d6,(a4)+		;w18
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4		25
		movem.l	(a3)+,d0-d6		;r11
		write7	a2				;w11	77
		movem.l	(a3)+,d0-d4		;r16	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w13
		lea		scanLineWidth-72+20(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w15
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_118
	hsLeftBorder
		eor.l	d4,(a2)+		;w16
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r18
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+					;21
		movem.l	(a1)+,d0-d6		;r7
		write7	a4				;w7		73
		movem.l	(a1)+,d0-d6		;r14	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_119
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;W14		15
		movem.l	(a1)+,d0-d3		;r18		26
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w18		46
		movem.l	(a3)+,d0-d6		;r7			63
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5			88
		lea		scanLineWidth-72+44(a3),a1	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		lea		scanLineWidth-72+44(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_120
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		movem.l	(a3)+,d0-d6		;r18
		write7	a2				;w18		72
		movem.l	(a1)+,d0-d6		;r7			;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+		;w1
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+		;w3
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-72+44(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;

;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_121
	hsLeftBorder
		eor.l	d4,(a4)+		;w5
		eor.l	d5,(a4)+	;w6
		eor.l	d6,(a4)+	;w7		;15
		movem.l	(a1)+,d0-d6	;r14	
		write7	a4			;w14	67
		movem.l	(a1)+,d3-d6	;r18	78
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+	;w16	88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3	;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+	;w18
		lea		scanLineWidth-72+56(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_122
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4		20
		movem.l	(a3)+,d0-d6		;r11	
		write7	a2				;w11	72
		movem.l	(a3)+,d0-d6		;r18	
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w13
		lea		scanLineWidth-72+20(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w15
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_123
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a4				;w7		67
		movem.l	(a1)+,d0-d6		;r14	84
		eor.l	d0,(a4)+		;w8		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w10
		lea		scanLineWidth-72+32(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_124
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14
		movem.l	(a1)+,d0-d3		;r18
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w18		;41
		movem.l	(a3)+,d0-d6		;r7			;58
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6			;88
		lea		scanLineWidth-72+44(a3),a1	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+		;w7
		eor.l	d0,(a2)+		;w8
		lea		scanLineWidth-72+40(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_125
	hsLeftBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		movem.l	(a3)+,d0-d6		;r18
		write7	a2				;w18		67
		movem.l	(a1)+,d0-d6		;r7			84
		eor.l	d0,(a4)+		;w1
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w3
		lea		scanLineWidth-72+60(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w5
		lea		scanLineWidth-72+44(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_126
	hsLeftBorder
		eor.l	d5,(a4)+		;w6
		eor.l	d6,(a4)+		;w7
		movem.l	(a1)+,d0-d6		;r14
		write7	a4				;w14		62
		movem.l	(a1)+,d3-d6		;r18		73
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w17		;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r5
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+		;w18
		eor.l	d0,(a2)+		;w1
		lea		scanLineWidth-64+68(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_127
	hsLeftBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4		15
		movem.l	(a3)+,d0-d6		;r11	32
		write7	a2				;w11	67
		movem.l	(a3)+,d0-d6		;r18	84
		eor.l	d0,(a2)+		;w12	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+		;w13
		eor.l	d2,(a2)+
		lea		scanLineWidth-64(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+		;w15
		eor.l	d4,(a2)+
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_128
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w18		10
		movem.l	(a1)+,d0-d6		;r7			
		write7	a4				;w7		62	
		movem.l	(a1)+,d0-d6		;r14	79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11	89
		lea		scanLineWidth-64+20(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+		;12
		eor.l	d5,(a4)+		;13
		lea		scanLineWidth-64+8(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_129
	hsLeftBorder
		eor.l	d6,(a4)+		;14
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r16
		eor.l	d0,(a4)+		;w14
		eor.l	d1,(a4)+		;w16		;21	
		movem.l	(a3)+,d0-d6		;r7			
		write7	a2				;w7			73
		movem.l	(a3)+,d0-d6		;r14		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9		
		lea		scanLineWidth-64+28(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		lea		scanLineWidth-64+8(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_130
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+			;w14		15
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			;w16		31
		movem.l	(a1)+,d0-d6			;r7			48
		write7	a4					;w7			83
		move.l	(a1)+,d0			
		move.l	(a1)+,d1			;r9			;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d2-d5			;r13
	REPT 12-11
		nop
	ENDR
	hsStabilize
	REPT 12
		nop
	ENDR	
;;;;;;;;;;;;
	;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_131
	hsLeftBorder
		eor.l	d0,(a4)+		;w8
		eor.l	d1,(a4)+		;w9
		eor.l	d2,(a4)+		;w10
		eor.l	d3,(a4)+		;w11
		eor.l	d4,(a4)+		;w12
		eor.l	d5,(a4)+		;w13		30
		movem.l	(a1)+,d0-d2		;r16		39
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w16		54
		lea		scanLineWidth-64(a1),a3		;56
		movem.l	(a3)+,d0-d6		;r7			73
		lea		scanLineWidth-64(a4),a2		;75
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-64+44(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		lea		scanLineWidth-64+36(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
	;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_132
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r14
		write7	a2				;w14		52
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r16
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w16		68
		movem.l	(a1)+,d0-d6		;r7			85
		eor.l	d0,(a4)+		;w1
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w3			
		lea		scanLineWidth-64+52(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-64+36(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
	;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_133
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w7
		movem.l	(a1)+,d0-d6		;r14		
		write7	a4				;w14	62
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;	68
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w16	78
		movem.l	(a3)+,d0-d3		;r4		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-64+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-64+48(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
	;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_134
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r11
		write7	a2				;w11		52
		movem.l	(a3)+,d0-d4		;r16		65
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w16		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-64+56(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;
	;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_135
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		movem.l	(a1)+,d0-d6		;r11
		write7	a4				;w11	62
		movem.l	(a1)+,d0-d4		;r16	75
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+		;w15	90
		eor.l	d4,(a4)+		;w16
		lea		scanLineWidth-64(a1),a3	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;;

	;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_136
	hsLeftBorder
		move.l	(a3)+,d4					;3
		lea		scanLineWidth-64(a4),a2		;5	
		eor.l	d0,(a2)+					;10
		eor.l	d1,(a2)+					;15
		eor.l	d2,(a2)+					;20
		eor.l	d3,(a2)+					;25
		eor.l	d4,(a2)+		;w5			;30
		movem.l	(a3)+,d0-d6		;r12		;47
		write7	a2				;w12	77	82
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r14	;88
		lea		scanLineWidth-64+8(a3),a1
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-64+8(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		move.l	(a3)+,d2
		move.l	(a3)+,d3		;r16		6
		eor.l	d2,(a2)+
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;;
	;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_137
	hsLeftBorder
		eor.l	d3,(a2)+	;w16			5
		movem.l	(a1)+,d0-d6		;r7			;22
		write7	a4							;57
		movem.l	(a1)+,d0-d6		;r14		;74
		eor.l	d0,(a4)+		;w8
		eor.l	d1,(a4)+		;w9
		eor.l	d2,(a4)+		;w10		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-64+16(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14
		lea		scanLineWidth-64+8(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;;
;;;;;;;;;;;;
	;;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_138
	hsLeftBorder
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;16
		movem.l	(a3)+,d0-d6		;r7
		write7	a2				;w7		68
		movem.l	(a3)+,d0-d6		;r14	85
		eor.l	d0,(a2)+		;w8		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10
		lea		scanLineWidth-64+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-64+8(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_139
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w14
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r16
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w16	26
		movem.l	(a1)+,d0-d6		;r7	
		write7	a4				;w7		78
		movem.l	(a1)+,d0-d3		;r11	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-64+28(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-64+20(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_140
	hsLeftBorder
		movem.l	(a1)+,d0-d4		;r16
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w16		38
		movem.l	(a3)+,d0-d6		;r7
		write7	a2				;w7			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3	
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w9
		lea		scanLineWidth-64+28(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_141
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		movem.l	(a3)+,d0-d4		;r16
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w16		48
		lea		scanLineWidth-64(a3),a1		;50
		movem.l	(a1)+,d0-d6		;r7		67
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4	87
		move.l	(a1)+,d0		;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6
		lea		scanLineWidth-64+40(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+		;w7
		eor.l	d0,(a4)+		;w8
		lea		scanLineWidth-64+32(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;;
;;;;;;;;;;;;;
eor4label_142
;	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r15
		write7	a4				;w15	52
		move.l	(a1)+,d0		;r16
		eor.l	d0,(a4)+		;w16	60
		movem.l	(a3)+,d0-d6		;r7		77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		move.l	(a3)+,d0		;r8		90
	REPT 90-90
		nop
	ENDR
;	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-64+48(a2),a4
	REPT 12-12
		nop
	ENDR
;	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-64+32(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
		eor.l	d6,(a2)+	;w7
		eor.l	d0,(a2)+	;w8
		movem.l	(a3)+,d0-d5	;r14
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+	;w14			;;; DONE

		lea		scanLineWidth-56(a2),a4
		lea		scanLineWidth-56(a3),a3

	REPT 7-2
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a3),a3
		lea		scanLineWidth-56(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		lea		scanLineWidth-48(a3),a3
		lea		scanLineWidth-48(a4),a4

	REPT 6
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d4
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-48(a3),a3
		lea		scanLineWidth-48(a4),a4
	ENDR

	REPT 6-2
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d2
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-40(a3),a3
		lea		scanLineWidth-40(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d2
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-32(a3),a3
		lea		scanLineWidth-32(a4),a4

	REPT 1
		movem.l	(a3)+,d0-d5
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-24(a3),a3
		lea		scanLineWidth-24(a4),a4
	ENDR
	jsr		copyRealTime
	popall
	move.w	#0,filldone
	rte
eor4end

;	lea		8(a3),a3
;	lea		8(a4),a4
;;eor4	6(4),8(6),21(8),51(10),18(9),13(8),7(7),6(6),6(5),6(3)
;	REPT 5-1
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		move.l	(a3)+,d0
;		eor.l	d0,(a4)+
;		lea		scanLineWidth-32(a3),a3
;		lea		scanLineWidth-32(a4),a4
;	ENDR
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		move.l	(a3)+,d0
;		eor.l	d0,(a4)+
;		lea		scanLineWidth-40(a3),a3
;		lea		scanLineWidth-40(a4),a4
;
;	REPT 8-1
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d4
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		lea		scanLineWidth-48(a3),a3
;		lea		scanLineWidth-48(a4),a4
;	ENDR
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d4
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		lea		scanLineWidth-56(a3),a3
;		lea		scanLineWidth-56(a4),a4
;
;	REPT 20-1
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		move.l	(a3)+,d0
;		eor.l	d0,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		move.l	(a3)+,d0
;		eor.l	d0,(a4)+
;		lea		scanLineWidth-64(a3),a3
;		lea		scanLineWidth-64(a4),a4
;	ENDR
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		move.l	(a3)+,d0
;		eor.l	d0,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		move.l	(a3)+,d0
;		eor.l	d0,(a4)+
;		lea		scanLineWidth-72(a3),a3
;		lea		scanLineWidth-72(a4),a4
;
;	REPT 52
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d5
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		lea		scanLineWidth-80(a3),a3
;		lea		scanLineWidth-80(a4),a4
;	ENDR
;
;	REPT 18-1
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d3
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		lea		scanLineWidth-72(a3),a3
;		lea		scanLineWidth-72(a4),a4
;	ENDR
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d3
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		lea		scanLineWidth-64(a3),a3
;		lea		scanLineWidth-64(a4),a4
;
;	REPT 13
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		move.l	(a3)+,d0
;		move.l	(a3)+,d1
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		lea		scanLineWidth-64(a3),a3
;		lea		scanLineWidth-64(a4),a4
;	ENDR
;
;
;	REPT 7-1
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		lea		scanLineWidth-56(a3),a3
;		lea		scanLineWidth-56(a4),a4
;	ENDR
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		lea		scanLineWidth-48(a3),a3
;		lea		scanLineWidth-48(a4),a4
;
;	REPT 6
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d4
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		lea		scanLineWidth-48(a3),a3
;		lea		scanLineWidth-48(a4),a4
;	ENDR
;
;	REPT 6-1
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d2
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		lea		scanLineWidth-40(a3),a3
;		lea		scanLineWidth-40(a4),a4
;	ENDR
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d2
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		lea		scanLineWidth-32(a3),a3
;		lea		scanLineWidth-32(a4),a4
;
;	REPT 6
;		movem.l	(a3)+,d0-d5
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		lea		scanLineWidth-24(a3),a3
;		lea		scanLineWidth-24(a4),a4
;	ENDR
;
;	rts


	dc.l	eor3label_105
	dc.l	eor3label_106
	dc.l	eor3label_107
	dc.l	eor3label_108
	dc.l	eor3label_109
	dc.l	eor3label_110
	dc.l	eor3label_111
	dc.l	eor3label_112
	dc.l	eor3label_113
	dc.l	eor3label_114
	dc.l	eor3label_115
	dc.l	eor3label_116
	dc.l	eor3label_117
	dc.l	eor3label_118
	dc.l	eor3label_119
	dc.l	eor3label_120
	dc.l	eor3label_121
	dc.l	eor3label_122
	dc.l	eor3label_123
	dc.l	eor3label_124
	dc.l	eor3label_125
	dc.l	eor3label_126
	dc.l	eor3label_127
	dc.l	eor3label_128
	dc.l	eor3label_129
	dc.l	eor3label_130
	dc.l	eor3label_131
	dc.l	eor3label_132
	dc.l	eor3label_133
	dc.l	eor3label_134
	dc.l	eor3label_135
	dc.l	eor3label_136
	dc.l	eor3label_137
	dc.l	eor3label_138
	dc.l	eor3label_139
	dc.l	eor3label_140
	dc.l	eor3label_141
eor3
;		;3(3),8(5),15(7),86(9),15(7),9(5),6(3)
;;;;;;;;;;;;;
;;;;;;;;;;;;;1
	nop
	nop
	nop
	nop
eor3label_001
	hsLeftBorder
		lea		8(a3),a3			;2
		lea		8(a4),a4			;2
		movem.l	(a3)+,d0-d5		;r6	;15
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6								;1
		lea		scanLineWidth-24(a3),a1
		lea		scanLineWidth-24(a4),a2		;53
		movem.l	(a1)+,d0-d5		;r6		68
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;88
		lea		scanLineWidth-24+8(a2),a4	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6								;2
		lea		scanLineWidth-24(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;2
eor3label_002
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w6		;36						;3
		lea		scanLineWidth-32(a4),a2
		lea		scanLineWidth-32(a3),a1		;40
		movem.l	(a1)+,d0-d6		;r7		;57
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;87	w6
		move.l	(a1)+,d0		;90	r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		lea		scanLineWidth-40+8(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		move.l	(a1)+,d0	
		move.l	(a1)+,d1		;r10
		eor.l	d0,(a2)+		;w9
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;3
eor3label_003
	hsLeftBorder
		eor.l	d1,(a2)+		;w10							;1
		lea		scanLineWidth-40(a1),a3		;7
		movem.l	(a3)+,d0-d6		;r7	
		write7	a4				;w7			59
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		move.l	(a3)+,d2		;r10		68
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w10		83					;2
		lea		scanLineWidth-40(a4),a2		;85
		lea		scanLineWidth-40(a3),a1		;87
		move.l	(a1)+,d0		;r1
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d1-d4		;r5
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+		;w1
		eor.l	d1,(a2)+		;w2
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;4
eor3label_004
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5			15
		movem.l	(a1)+,d0-d4		;r10		28
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w10		53					;3
		lea		scanLineWidth-40(a2),a4		;55
		lea		scanLineWidth-40(a1),a3		;57
		movem.l	(a3)+,d0-d6		;r7			;74
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w3			;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w5
		lea		scanLineWidth-40+20(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w7
		lea		scanLineWidth-40+12(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;
;;;;;;;;;;;;;5
eor3label_005
	hsLeftBorder
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		move.l	(a3)+,d2		;9
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;24								;4
		movem.l	(a1)+,d0-d6		;r7		41
		write7	a2				;w7		76
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		move.l	(a1)+,d2		;r10	85
		eor.l	d0,(a2)+		;w8		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10							;5
		lea		scanLineWidth-40(a1),a3	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r4	-
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;
;;;;;;;;;;;;;6
eor3label_006
	hsLeftBorder
		move.l	(a3)+,d4		;r5		
		lea		scanLineWidth-40(a2),a4		;5
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+					;30
		movem.l	(a3)+,d0-d4		;r10		;43
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w10		;68					;6
		lea		scanLineWidth-40(a4),a2		;70
		lea		scanLineWidth-40(a3),a1		;72
		movem.l	(a1)+,d0-d6		;r7			;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			;w2
		lea		scanLineWidth-40+32(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-40+12(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;7
eor3label_007
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		movem.l	(a1)+,d0-d2		;r10
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10		39				;7
		movem.l	(a3)+,d0-d6		;r7			56
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6			86
		move.l	(a3)+,d0		;r8			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+		;w8
		lea		scanLineWidth-48+8(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a4)+		;w9
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;8
;;;;;;;;;;;;;
eor3label_008
	hsLeftBorder
		eor.l	d1,(a4)+		;w10
		movem.l	(a1)+,d0-d6		;r7			
		lea		scanLineWidth-48(a4),a2		;24
		write7	a2				;w7			;59
		movem.l	(a1)+,d0-d6		;r14		;76
		eor.l	d0,(a2)+		;w8
		eor.l	d1,(a2)+		;w9			;86
		lea		scanLineWidth-56(a1),a3		;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		lea		scanLineWidth-56+12(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w13
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;9
eor3label_009
	hsLeftBorder
		eor.l	d6,(a2)+		;w14
		movem.l	(a3)+,d0-d6		;r7		
		write7	a4				;w7		57
		movem.l	(a3)+,d0-d6		;r14	74
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-56+8(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14
		lea		scanLineWidth-56(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;10
eor3label_010
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7
		movem.l	(a1)+,d0-d6		;r14		69
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w13
		lea		scanLineWidth-56(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+		;w14
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r2
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;11
eor3label_011
	hsLeftBorder
		movem.l	(a3)+,d2-d6		;r7		13
		lea		scanLineWidth-56(a2),a4		;15
		write7	a4				;w7			;50
		movem.l	(a3)+,d0-d6		;r14		67
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11		87
		lea		scanLineWidth-56+12(a4),a2	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w13
		lea		scanLineWidth-56(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;		THIS BLOCK REPEATS	1
;;;;;;;;;;;;;12
eor3label_012
	hsLeftBorder
		eor.l	d6,(a4)+		;w14
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4		;25
		movem.l	(a1)+,d0-d6		;r11	
		write7	a2				;w11	77
		move.l	(a1)+,d4
		move.l	(a1)+,d5
		move.l	(a1)+,d6		;r14	86
		lea		scanLineWidth-56(a1),a3	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w13
		lea		scanLineWidth-56+4(a2),a4	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;13
eor3label_013
	hsLeftBorder
		eor.l	d6,(a2)+		;w14
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		;25
		movem.l	(a3)+,d0-d6		;r11
		write7	a4				;w11	77
		move.l	(a3)+,d4
		move.l	(a3)+,d5
		move.l	(a3)+,d6		;r14	86
		lea		scanLineWidth-56(a3),a1	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-56+4(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;
;;;;;;;;;;;;;		THIS BLOCK REPEATS	2
;;;;;;;;;;;;;14
eor3label_014
	hsLeftBorder
		eor.l	d6,(a4)+		;w14
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4		;25
		movem.l	(a1)+,d0-d6		;r11	
		write7	a2				;w11	77
		move.l	(a1)+,d4
		move.l	(a1)+,d5
		move.l	(a1)+,d6		;r14	86
		lea		scanLineWidth-56(a1),a3	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w13
		lea		scanLineWidth-56+4(a2),a4	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;15
eor3label_015
	hsLeftBorder
		eor.l	d6,(a2)+		;w14
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		;25
		movem.l	(a3)+,d0-d6		;r11
		write7	a4				;w11	77
		move.l	(a3)+,d4
		move.l	(a3)+,d5
		move.l	(a3)+,d6		;r14	86
		lea		scanLineWidth-56(a3),a1	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-56+4(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;
;;;;;;;;;;;;;		THIS BLOCK REPEATS	3
;;;;;;;;;;;;;16
eor3label_016
	hsLeftBorder
		eor.l	d6,(a4)+		;w14
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4		;25
		movem.l	(a1)+,d0-d6		;r11	
		write7	a2				;w11	77
		move.l	(a1)+,d4
		move.l	(a1)+,d5
		move.l	(a1)+,d6		;r14	86
		lea		scanLineWidth-56(a1),a3	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w13
		lea		scanLineWidth-56+4(a2),a4	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;17
;;;;;;;;;;;;;
eor3label_017
	hsLeftBorder
		eor.l	d6,(a2)+		;w14
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		;25
		movem.l	(a3)+,d0-d6		;r11
		write7	a4				;w11	77
		move.l	(a3)+,d4
		move.l	(a3)+,d5
		move.l	(a3)+,d6		;r14	86
		lea		scanLineWidth-56(a3),a1	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-56+4(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;
;;;;;;;;;;;;;		THIS BLOCK REPEATS	4
;;;;;;;;;;;;;18
eor3label_018
	hsLeftBorder
		eor.l	d6,(a4)+		;w14
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4		;25
		movem.l	(a1)+,d0-d6		;r11	
		write7	a2				;w11	77
		move.l	(a1)+,d4
		move.l	(a1)+,d5
		move.l	(a1)+,d6		;r14	86
		lea		scanLineWidth-56(a1),a3	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w13
		lea		scanLineWidth-56+4(a2),a4	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;19
eor3label_019
	hsLeftBorder
		eor.l	d6,(a2)+		;w14
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		;25
		movem.l	(a3)+,d0-d6		;r11
		write7	a4				;w11	77
		move.l	(a3)+,d4
		move.l	(a3)+,d5
		move.l	(a3)+,d6		;r14	86
		lea		scanLineWidth-56(a3),a1	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-56+4(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;
;;;;;;;;;;;;;		THIS BLOCK REPEATS	5
;;;;;;;;;;;;;20
eor3label_020
	hsLeftBorder
		eor.l	d6,(a4)+		;w14
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4		;25
		movem.l	(a1)+,d0-d6		;r11	
		write7	a2				;w11	77
		move.l	(a1)+,d4
		move.l	(a1)+,d5
		move.l	(a1)+,d6		;r14	86
		lea		scanLineWidth-56(a1),a3	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w13
		lea		scanLineWidth-56+4(a2),a4	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;21
eor3label_021
	hsLeftBorder
		eor.l	d6,(a2)+		;w14
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		;25
		movem.l	(a3)+,d0-d6		;r11
		write7	a4				;w11	77
		move.l	(a3)+,d4
		move.l	(a3)+,d5
		move.l	(a3)+,d6		;r14	86
		lea		scanLineWidth-56(a3),a1	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-56+4(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;22
;;;;;;;;;;;;;
eor3label_022
	hsLeftBorder
		eor.l	d6,(a4)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		movem.l	(a1)+,d0-d6		;r11
		write7	a2				;w11
		move.l	(a1)+,d4
		move.l	(a1)+,d5
		move.l	(a1)+,d6		;r14
		lea		scanLineWidth-64(a1),a3
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		lea		scanLineWidth-64+4(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;	
;;;;;;;;;;;;;23
eor3label_023
	hsLeftBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		movem.l	(a3)+,d0-d6		;r11
		write7	a4				;w11	77
		movem.l	(a3)+,d0-d4		;r16	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+		;w12
		eor.l	d1,(a4)+		;w13
		lea		scanLineWidth-72+20(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+		;w14
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-72+8(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;	
;;;;;;;;;;;;;24
eor3label_024
	hsLeftBorder
		eor.l	d4,(a4)+		;w16
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w18		21
		movem.l	(a1)+,d0-d6		;r7			38
		write7	a2				;w7			73
		movem.l	(a1)+,d0-d6		;r14		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-72+36(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;25
;;;;;;;;;;;;;
eor3label_025
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w14
		movem.l	(a1)+,d0-d3		;r18
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		35+11 = 46
		movem.l	(a3)+,d0-d6		;r7			63
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w5		88
		lea		scanLineWidth-72+44(a3),a1	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+			;w7
		lea		scanLineWidth-72+44(a4),a2	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3			;r11
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;26
;;;;;;;;;;;;;
eor3label_026
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+			;w11	20
		movem.l	(a3)+,d0-d6			;r18	37
		write7	a4					;w18	72
		movem.l	(a1)+,d0-d6			;r7		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			;w2
		lea		scanLineWidth-72+64(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-72+44(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
	
;;;;;;;;;;;;;
;;;;;;;;;;;;;27
eor3label_027
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;15		w7
		movem.l	(a1)+,d0-d6		;r14		67
		write7	a2				;w14		
		movem.l	(a1)+,d3-d6		;r18		78
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w16		88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4		
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w18
		lea		scanLineWidth-72+56(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;28
;;;;;;;;;;;;;
eor3label_028
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		20
		movem.l	(a3)+,d0-d6		;r11
		write7	a4				;w11	72
		movem.l	(a3)+,d0-d6		;r18	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13
		lea		scanLineWidth-72+20(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;29
;;;;;;;;;;;;;
eor3label_029
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w18	15
		movem.l	(a1)+,d0-d6		;r7		32
		write7	a2				;w7		67
		movem.l	(a1)+,d0-d6		;r14	84
		eor.l	d0,(a2)+		;w8		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+	;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;	30
eor3label_030
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+	;w14		10
		movem.l	(a1)+,d0-d3	;r18		21
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w18		41
		movem.l	(a3)+,d0-d6	;r7			58
		eor.l	d0,(a4)+	;w1
		eor.l	d1,(a4)+	;w2
		eor.l	d2,(a4)+	;w3
		eor.l	d3,(a4)+	;w4
		eor.l	d4,(a4)+	;w5
		eor.l	d5,(a4)+	;w6			88
		lea		scanLineWidth-72+44(a3),a1		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3	;r11		
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+	;w8
		lea		scanLineWidth-72+40(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;31
;;;;;;;;;;;;;
eor3label_031
	hsLeftBorder
		eor.l	d1,(a4)+	;
		eor.l	d2,(a4)+	;
		eor.l	d3,(a4)+	;w11		15
		movem.l	(a3)+,d0-d6	;r18		32
		write7	a4			;w18		67
		movem.l	(a1)+,d0-d6	;r7			84
		eor.l	d0,(a2)+	;w1			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		lea		scanLineWidth-72+60(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		lea		scanLineWidth-72+44(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;32
eor3label_032
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+	;w7		10
		movem.l	(a1)+,d0-d6	;r14	27	
		write7	a2			;w14	62
		movem.l	(a1)+,d3-d6	;r18	73
		eor.l	d3,(a2)+	;w15
		eor.l	d4,(a2)+	;w16
		eor.l	d5,(a2)+	;w17	88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+	;w18
		eor.l	d0,(a4)+	;w1
		lea		scanLineWidth-72+68(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;33
eor3label_033
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w4		15
		movem.l	(a3)+,d0-d6	;r11	
		write7	a4			;w11	67
		movem.l	(a3)+,d0-d6	;r18	84
		eor.l	d0,(a4)+	;w12
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+	;w16
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;34
;;;;;;;;;;;;;
eor3label_034
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+	;w18
		movem.l	(a1)+,d0-d6	;r7
		write7	a2			;w7		62
		movem.l	(a1)+,d0-d6	;r14	79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w11
		lea		scanLineWidth-72+28(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+	;w13
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;35

;;;;;;;;;;;;;
eor3label_035
	hsLeftBorder
		eor.l	d6,(a2)+	;14				5
		movem.l	(a1)+,d0-d3	;r18		
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w18	36
		movem.l	(a3)+,d0-d6	;r7		53
		write7	a4			;w7		88
		lea		scanLineWidth-72+44(a4),a2
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3	;r11	89
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w9
		lea		scanLineWidth-72+28(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;36
;;;;;;;;;;;;;
eor3label_036
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w11
		movem.l	(a3)+,d0-d6		;r18
		write7	a4				;w18		62
		movem.l	(a1)+,d0-d6		;r7			79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4			
		lea		scanLineWidth-72+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-72+44(a1),a3		;
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;37
;;;;;;;;;;;;;
eor3label_037
	hsLeftBorder	
		eor.l	d6,(a2)+			;		5
		movem.l	(a1)+,d0-d3		;r11		16
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11		36
		movem.l	(a1)+,d0-d6		;r18		53
		write7	a2				;w18		88
		lea		2*scanLineWidth-72(a3),a1		;12
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4			;90
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;38
;;;;;;;;;;;;;
eor3label_038
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		movem.l	(a3)+,d0-d6		;r11	
		write7	a4				;w11	62
		movem.l	(a3)+,d0-d6		;r18	79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w17
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;39
;;;;;;;;;;;;;
eor3label_039
	hsLeftBorder
		eor.l	d6,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+		;w13
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;40
eor3label_040
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;41
eor3label_041
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13		20
		movem.l	(a3)+,d0-d4		;r18		33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18		58
		lea		scanLineWidth-72(a3),a1		;60
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2			87
		move.l	(a1)+,d0		;r8			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-72+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-72+40(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;42
eor3label_042
	hsLeftBorder
		eor.l	d6,(a2)+		;w7
		eor.l	d0,(a2)+		;w8
		movem.l	(a1)+,d0-d6		;r15
		write7	a2				;w15		62
		move.l	(a1)+,d4
		move.l	(a1)+,d5
		move.l	(a1)+,d6		;r18		71
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w18		86
		move.l	(a3)+,d0		;r1			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d1-d4		;r5			
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;43
eor3label_043
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w5		15
		movem.l	(a3)+,d0-d6		;r12	32
		write7	a4				;w12	67
		movem.l	(a3)+,d0-d5		;r18	82
		eor.l	d0,(a4)+		;w13	87
		lea		scanLineWidth-72(a3),a1	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w15
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w17
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;44
eor3label_044
	hsLeftBorder
		eor.l	d5,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+		;w8
		eor.l	d1,(a2)+		;w9
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+		;w11
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+		;w13
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;45
eor3label_045
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;46
eor3label_046
	hsLeftBorder
		eor.l	d0,(a4)+		;w10
		eor.l	d1,(a4)+		;w11
		eor.l	d2,(a4)+		;w12
		eor.l	d3,(a4)+		;w13	20
		movem.l	(a3)+,d0-d4		;r18	33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18	58
		lea		scanLineWidth-72(a3),a1	;60
		movem.l	(a1)+,d0-d5		;r6		75
		eor.l	d0,(a2)+		;w1
		eor.l	d1,(a2)+		;w2
		eor.l	d2,(a2)+		;w3
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-72+52(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r10
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;47
eor3label_047
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w10	25
		movem.l	(a1)+,d0-d6		;r17	42
		write7	a2				;w17	77
		move.l	(a1)+,d0		;r18	80
		eor.l	d0,(a2)+		;w18	85
		lea		scanLineWidth-72(a1),a3		;87
		lea		scanLineWidth-72(a2),a4		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		move.l	(a3)+,d4		
		move.l	(a3)+,d5		;r6
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;48
eor3label_048
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6	25
		movem.l	(a3)+,d0-d6		;r13		42
		write7	a4				;w13		77
		movem.l	(a3)+,d0-d4		;r18		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w17
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;49
eor3label_049
	hsLeftBorder
		eor.l	d4,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;50
eor3label_050
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		;11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;51
eor3label_051
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w11
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13			20
		movem.l	(a3)+,d0-d4		;r18			33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18		45+11 = 58
		lea		scanLineWidth-72(a3),a1		;	60
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			
		move.l	(a1)+,d0		;r8			
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4			88
		lea		scanLineWidth-72+56(a2),a4	;90
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;52
eor3label_052
	hsLeftBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+		;w8			10
		movem.l	(a1)+,d0-d6		;r15		27
		write7	a2				;w15		62
		movem.l	(a1)+,d0-d2		;r18		71
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w18
		lea		scanLineWidth-72(a2),a4		;88
		lea		scanLineWidth-72(a1),a3		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		move.l	(a3)+,d4
		move.l	(a3)+,d5		;r6
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;53
eor3label_053
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6		25
		movem.l	(a3)+,d0-d6		;r13	42
		write7	a4				;w13	77
		movem.l	(a3)+,d0-d4		;r18	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w17
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;54
eor3label_054
	hsLeftBorder
		eor.l	d4,(a4)+		;w18		5
		movem.l	(a1)+,d0-d6		;r7			22
		write7	a2				;w7			57
		movem.l	(a1)+,d0-d6		;r14		74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;55
eor3label_055
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18	11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18	31
		movem.l	(a3)+,d0-d6		;r7		48
		write7	a4				;w7		83
		move.l	(a3)+,d0		
		move.l	(a3)+,d1		;r9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d2-d5		;r13	
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w8
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;56
eor3label_056
	hsLeftBorder
		eor.l	d2,(a4)+		;w10
		eor.l	d3,(a4)+		;w11
		eor.l	d4,(a4)+		;w12
		eor.l	d5,(a4)+		;w13	20

		movem.l	(a3)+,d0-d4		;r18	33
		eor.l	d0,(a4)+		;w14
		eor.l	d1,(a4)+		;w15
		eor.l	d2,(a4)+		;w16
		eor.l	d3,(a4)+		;w17	53
		eor.l	d4,(a4)+		;w18	58
		lea		scanLineWidth-72(a3),a1	;60
		movem.l	(a1)+,d0-d6		;r7		77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;87
		lea		2*scanLineWidth-72(a3),a3		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+		;87
		eor.l	d3,(a2)+		;w4		90
		lea		scanLineWidth-72+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;57
eor3label_057
	hsLeftBorder
		eor.l	d4,(a2)+		;w5
		eor.l	d5,(a2)+		;w6
		eor.l	d6,(a2)+		
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;	w11				30
		movem.l	(a1)+,d0-d6	;	r18				47
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w17			;82
		eor.l	d6,(a2)+		;w18			87
		lea		scanLineWidth-72(a2),a4			;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-72+56(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
eor3label_058
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		movem.l	(a3)+,d0-d6		;r11	
		write7	a4				;w11	62
		movem.l	(a3)+,d0-d6		;r18	79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w17
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;; PATTERN
;;;;;;;;;;
;;;;;;;;;;;;;39
;;;;;;;;;;;;;
eor3label_059
	hsLeftBorder
		eor.l	d6,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+		;w13
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;40
eor3label_060
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;41
eor3label_061
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13		20
		movem.l	(a3)+,d0-d4		;r18		33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18		58
		lea		scanLineWidth-72(a3),a1		;60
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2			87
		move.l	(a1)+,d0		;r8			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-72+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-72+40(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;42
eor3label_062
	hsLeftBorder
		eor.l	d6,(a2)+		;w7
		eor.l	d0,(a2)+		;w8
		movem.l	(a1)+,d0-d6		;r15
		write7	a2				;w15		62
		move.l	(a1)+,d4
		move.l	(a1)+,d5
		move.l	(a1)+,d6		;r18		71
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w18		86
		move.l	(a3)+,d0		;r1			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d1-d4		;r5			
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;43
eor3label_063
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w5		15
		movem.l	(a3)+,d0-d6		;r12	32
		write7	a4				;w12	67
		movem.l	(a3)+,d0-d5		;r18	82
		eor.l	d0,(a4)+		;w13	87
		lea		scanLineWidth-72(a3),a1	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w15
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w17
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;44
eor3label_064
	hsLeftBorder
		eor.l	d5,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+		;w8
		eor.l	d1,(a2)+		;w9
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+		;w11
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+		;w13
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;45
eor3label_065
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;46
eor3label_066
	hsLeftBorder
		eor.l	d0,(a4)+		;w10
		eor.l	d1,(a4)+		;w11
		eor.l	d2,(a4)+		;w12
		eor.l	d3,(a4)+		;w13	20
		movem.l	(a3)+,d0-d4		;r18	33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18	58
		lea		scanLineWidth-72(a3),a1	;60
		movem.l	(a1)+,d0-d5		;r6		75
		eor.l	d0,(a2)+		;w1
		eor.l	d1,(a2)+		;w2
		eor.l	d2,(a2)+		;w3
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-72+52(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r10
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;47
eor3label_067
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w10	25
		movem.l	(a1)+,d0-d6		;r17	42
		write7	a2				;w17	77
		move.l	(a1)+,d0		;r18	80
		eor.l	d0,(a2)+		;w18	85
		lea		scanLineWidth-72(a1),a3		;87
		lea		scanLineWidth-72(a2),a4		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		move.l	(a3)+,d4		
		move.l	(a3)+,d5		;r6
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;48
eor3label_068
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6	25
		movem.l	(a3)+,d0-d6		;r13		42
		write7	a4				;w13		77
		movem.l	(a3)+,d0-d4		;r18		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w17
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;49
eor3label_069
	hsLeftBorder
		eor.l	d4,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;50
eor3label_070
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		;11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;51
eor3label_071
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w11
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13			20
		movem.l	(a3)+,d0-d4		;r18			33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18		45+11 = 58
		lea		scanLineWidth-72(a3),a1		;	60
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			
		move.l	(a1)+,d0		;r8			
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4			88
		lea		scanLineWidth-72+56(a2),a4	;90
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;52
eor3label_072
	hsLeftBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+		;w8			10
		movem.l	(a1)+,d0-d6		;r15		27
		write7	a2				;w15		62
		movem.l	(a1)+,d0-d2		;r18		71
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w18
		lea		scanLineWidth-72(a2),a4		;88
		lea		scanLineWidth-72(a1),a3		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		move.l	(a3)+,d4
		move.l	(a3)+,d5		;r6
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;53
eor3label_073
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6		25
		movem.l	(a3)+,d0-d6		;r13	42
		write7	a4				;w13	77
		movem.l	(a3)+,d0-d4		;r18	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w17
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;54
eor3label_074
	hsLeftBorder
		eor.l	d4,(a4)+		;w18		5
		movem.l	(a1)+,d0-d6		;r7			22
		write7	a2				;w7			57
		movem.l	(a1)+,d0-d6		;r14		74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;55
eor3label_075
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18	11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18	31
		movem.l	(a3)+,d0-d6		;r7		48
		write7	a4				;w7		83
		move.l	(a3)+,d0		
		move.l	(a3)+,d1		;r9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d2-d5		;r13	
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w8
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;56
eor3label_076
	hsLeftBorder
		eor.l	d2,(a4)+		;w10
		eor.l	d3,(a4)+		;w11
		eor.l	d4,(a4)+		;w12
		eor.l	d5,(a4)+		;w13	20

		movem.l	(a3)+,d0-d4		;r18	33
		eor.l	d0,(a4)+		;w14
		eor.l	d1,(a4)+		;w15
		eor.l	d2,(a4)+		;w16
		eor.l	d3,(a4)+		;w17	53
		eor.l	d4,(a4)+		;w18	58
		lea		scanLineWidth-72(a3),a1	;60
		movem.l	(a1)+,d0-d6		;r7		77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;87
		lea		2*scanLineWidth-72(a3),a3		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+		;87
		eor.l	d3,(a2)+		;w4		90
		lea		scanLineWidth-72+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;57
eor3label_077
	hsLeftBorder
		eor.l	d4,(a2)+		;w5
		eor.l	d5,(a2)+		;w6
		eor.l	d6,(a2)+		
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;	w11				30
		movem.l	(a1)+,d0-d6	;	r18				47
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w17			;82
		eor.l	d6,(a2)+		;w18			87
		lea		scanLineWidth-72(a2),a4			;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-72+56(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
eor3label_078
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		movem.l	(a3)+,d0-d6		;r11	
		write7	a4				;w11	62
		movem.l	(a3)+,d0-d6		;r18	79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w17
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;; PATTERN
;;;;;;;;;;
;;;;;;;;;;;;;39
;;;;;;;;;;;;;
eor3label_079
	hsLeftBorder
		eor.l	d6,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+		;w13
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;40
eor3label_080
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;41
eor3label_081
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13		20
		movem.l	(a3)+,d0-d4		;r18		33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18		58
		lea		scanLineWidth-72(a3),a1		;60
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2			87
		move.l	(a1)+,d0		;r8			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-72+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-72+40(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;42
eor3label_082
	hsLeftBorder
		eor.l	d6,(a2)+		;w7
		eor.l	d0,(a2)+		;w8
		movem.l	(a1)+,d0-d6		;r15
		write7	a2				;w15		62
		move.l	(a1)+,d4
		move.l	(a1)+,d5
		move.l	(a1)+,d6		;r18		71
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w18		86
		move.l	(a3)+,d0		;r1			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d1-d4		;r5			
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;43
eor3label_083
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w5		15
		movem.l	(a3)+,d0-d6		;r12	32
		write7	a4				;w12	67
		movem.l	(a3)+,d0-d5		;r18	82
		eor.l	d0,(a4)+		;w13	87
		lea		scanLineWidth-72(a3),a1	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w15
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w17
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;44
eor3label_084
	hsLeftBorder
		eor.l	d5,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+		;w8
		eor.l	d1,(a2)+		;w9
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+		;w11
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+		;w13
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;45
eor3label_085
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;46
eor3label_086
	hsLeftBorder
		eor.l	d0,(a4)+		;w10
		eor.l	d1,(a4)+		;w11
		eor.l	d2,(a4)+		;w12
		eor.l	d3,(a4)+		;w13	20
		movem.l	(a3)+,d0-d4		;r18	33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18	58
		lea		scanLineWidth-72(a3),a1	;60
		movem.l	(a1)+,d0-d5		;r6		75
		eor.l	d0,(a2)+		;w1
		eor.l	d1,(a2)+		;w2
		eor.l	d2,(a2)+		;w3
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-72+52(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r10
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;47
eor3label_087
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w10	25
		movem.l	(a1)+,d0-d6		;r17	42
		write7	a2				;w17	77
		move.l	(a1)+,d0		;r18	80
		eor.l	d0,(a2)+		;w18	85
		lea		scanLineWidth-72(a1),a3		;87
		lea		scanLineWidth-72(a2),a4		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		move.l	(a3)+,d4		
		move.l	(a3)+,d5		;r6
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;48
eor3label_088
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6	25
		movem.l	(a3)+,d0-d6		;r13		42
		write7	a4				;w13		77
		movem.l	(a3)+,d0-d4		;r18		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w17
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;49
eor3label_089
	hsLeftBorder
		eor.l	d4,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;50
eor3label_090
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		;11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;51
eor3label_091
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w11
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13			20
		movem.l	(a3)+,d0-d4		;r18			33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18		45+11 = 58
		lea		scanLineWidth-72(a3),a1		;	60
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			
		move.l	(a1)+,d0		;r8			
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4			88
		lea		scanLineWidth-72+56(a2),a4	;90
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;52
eor3label_092
	hsLeftBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+		;w8			10
		movem.l	(a1)+,d0-d6		;r15		27
		write7	a2				;w15		62
		movem.l	(a1)+,d0-d2		;r18		71
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w18
		lea		scanLineWidth-72(a2),a4		;88
		lea		scanLineWidth-72(a1),a3		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		move.l	(a3)+,d4
		move.l	(a3)+,d5		;r6
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;53
eor3label_093
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6		25
		movem.l	(a3)+,d0-d6		;r13	42
		write7	a4				;w13	77
		movem.l	(a3)+,d0-d4		;r18	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w17
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;54
eor3label_094
	hsLeftBorder
		eor.l	d4,(a4)+		;w18		5
		movem.l	(a1)+,d0-d6		;r7			22
		write7	a2				;w7			57
		movem.l	(a1)+,d0-d6		;r14		74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;55
eor3label_095
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18	11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18	31
		movem.l	(a3)+,d0-d6		;r7		48
		write7	a4				;w7		83
		move.l	(a3)+,d0		
		move.l	(a3)+,d1		;r9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d2-d5		;r13	
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w8
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;56
eor3label_096
	hsLeftBorder
		eor.l	d2,(a4)+		;w10
		eor.l	d3,(a4)+		;w11
		eor.l	d4,(a4)+		;w12
		eor.l	d5,(a4)+		;w13	20

		movem.l	(a3)+,d0-d4		;r18	33
		eor.l	d0,(a4)+		;w14
		eor.l	d1,(a4)+		;w15
		eor.l	d2,(a4)+		;w16
		eor.l	d3,(a4)+		;w17	53
		eor.l	d4,(a4)+		;w18	58
		lea		scanLineWidth-72(a3),a1	;60
		movem.l	(a1)+,d0-d6		;r7		77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;87
		lea		2*scanLineWidth-72(a3),a3		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+		;87
		eor.l	d3,(a2)+		;w4		90
		lea		scanLineWidth-72+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;57
eor3label_097
	hsLeftBorder
		eor.l	d4,(a2)+		;w5
		eor.l	d5,(a2)+		;w6
		eor.l	d6,(a2)+		
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;	w11				30
		movem.l	(a1)+,d0-d6	;	r18				47
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w17			;82
		eor.l	d6,(a2)+		;w18			87
		lea		scanLineWidth-72(a2),a4			;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-72+56(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
eor3label_098
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		movem.l	(a3)+,d0-d6		;r11	
		write7	a4				;w11	62
		movem.l	(a3)+,d0-d6		;r18	79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w17
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;; PATTERN
;;;;;;;;;;
;;;;;;;;;;;;;39
;;;;;;;;;;;;;
eor3label_099
	hsLeftBorder
		eor.l	d6,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+		;w13
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;40
eor3label_100
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;41
eor3label_101
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13		20
		movem.l	(a3)+,d0-d4		;r18		33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18		58
		lea		scanLineWidth-72(a3),a1		;60
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2			87
		move.l	(a1)+,d0		;r8			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-72+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-72+40(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;42
eor3label_102
	hsLeftBorder
		eor.l	d6,(a2)+		;w7
		eor.l	d0,(a2)+		;w8
		movem.l	(a1)+,d0-d6		;r15
		write7	a2				;w15		62
		move.l	(a1)+,d4
		move.l	(a1)+,d5
		move.l	(a1)+,d6		;r18		71
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w18		86
		move.l	(a3)+,d0		;r1			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d1-d4		;r5			
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;43
eor3label_103
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w5		15
		movem.l	(a3)+,d0-d6		;r12	32
		write7	a4				;w12	67
		movem.l	(a3)+,d0-d5		;r18	82
		eor.l	d0,(a4)+		;w13	87
		lea		scanLineWidth-72(a3),a1	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w15
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w17
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;44
eor3label_104
	hsLeftBorder
		eor.l	d5,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+		;w8
		eor.l	d1,(a2)+		;w9
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+		;w11
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+		;w13
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;45
eor3label_105
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;46
eor3label_106
	hsLeftBorder
		eor.l	d0,(a4)+		;w10
		eor.l	d1,(a4)+		;w11
		eor.l	d2,(a4)+		;w12
		eor.l	d3,(a4)+		;w13	20
		movem.l	(a3)+,d0-d4		;r18	33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18	58
		lea		scanLineWidth-72(a3),a1	;60
		movem.l	(a1)+,d0-d5		;r6		75
		eor.l	d0,(a2)+		;w1
		eor.l	d1,(a2)+		;w2
		eor.l	d2,(a2)+		;w3
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-72+52(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r10
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;47
eor3label_107
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w10	25
		movem.l	(a1)+,d0-d6		;r17	42
		write7	a2				;w17	77
		move.l	(a1)+,d0		;r18	80
		eor.l	d0,(a2)+		;w18	85
		lea		scanLineWidth-72(a1),a3		;87
		lea		scanLineWidth-72(a2),a4		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		move.l	(a3)+,d4		
		move.l	(a3)+,d5		;r6
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;48
eor3label_108
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6	25
		movem.l	(a3)+,d0-d6		;r13		42
		write7	a4				;w13		77
		movem.l	(a3)+,d0-d4		;r18		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w17
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;49
eor3label_109
	hsLeftBorder
		eor.l	d4,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;50
eor3label_110
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		;11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;51
eor3label_111
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w11
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13			20
		movem.l	(a3)+,d0-d4		;r18			33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18		45+11 = 58
		lea		scanLineWidth-72(a3),a1		;	60
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+			
		move.l	(a1)+,d0		;r8			
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4			88
		lea		scanLineWidth-72+56(a2),a4	;90
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;52
eor3label_112
	hsLeftBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+		;w8			10
		movem.l	(a1)+,d0-d6		;r15		27
		write7	a2				;w15		62
		movem.l	(a1)+,d0-d2		;r18		71
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w18
		lea		scanLineWidth-72(a2),a4		;88
		lea		scanLineWidth-72(a1),a3		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		move.l	(a3)+,d4
		move.l	(a3)+,d5		;r6
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;53
eor3label_113
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6		25
		movem.l	(a3)+,d0-d6		;r13	42
		write7	a4				;w13	77
		movem.l	(a3)+,d0-d4		;r18	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w17
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;54
eor3label_114
	hsLeftBorder
		eor.l	d4,(a4)+		;w18		5
		movem.l	(a1)+,d0-d6		;r7			22
		write7	a2				;w7			57
		movem.l	(a1)+,d0-d6		;r14		74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;55
eor3label_115
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18	11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18	31
		movem.l	(a3)+,d0-d6		;r7		48
		write7	a4				;w7		83
		move.l	(a3)+,d0		
		move.l	(a3)+,d1		;r9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d2-d5		;r13	
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w8
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;56
eor3label_116
	hsLeftBorder
		eor.l	d2,(a4)+		;w10
		eor.l	d3,(a4)+		;w11
		eor.l	d4,(a4)+		;w12
		eor.l	d5,(a4)+		;w13	20

		movem.l	(a3)+,d0-d4		;r18	33
		eor.l	d0,(a4)+		;w14
		eor.l	d1,(a4)+		;w15
		eor.l	d2,(a4)+		;w16
		eor.l	d3,(a4)+		;w17	53
		eor.l	d4,(a4)+		;w18	58
		lea		scanLineWidth-72(a3),a1	;60
		movem.l	(a1)+,d0-d6		;r7		77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;87
		lea		2*scanLineWidth-72(a3),a3		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+		;87
		eor.l	d3,(a2)+		;w4		90
		lea		scanLineWidth-72+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;

;;;;;;;;;;;;;57
eor3label_117
	hsLeftBorder
		eor.l	d4,(a2)+		;w5
		eor.l	d5,(a2)+		;w6
		eor.l	d6,(a2)+		
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;	w11				30
		movem.l	(a1)+,d0-d6	;	r18				47
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w17			;82
		eor.l	d6,(a2)+		;w18			87
		lea		scanLineWidth-72(a2),a4			;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-72+56(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
eor3label_118
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		movem.l	(a3)+,d0-d6		;r11	
		write7	a4				;w11	62
		movem.l	(a3)+,d0-d6		;r18	79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w17
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;; PATTERN
;;;;;;;;;;
;;;;;;;;;;;;;39
;;;;;;;;;;;;;
eor3label_119
	hsLeftBorder
		eor.l	d6,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+		;w13
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;40
eor3label_120
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;41
eor3label_121
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13		20
		movem.l	(a3)+,d0-d4		;r18		33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18		58
		lea		scanLineWidth-72(a3),a1		;60
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2			87
		move.l	(a1)+,d0		;r8			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-72+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-72+40(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;42
eor3label_122
	hsLeftBorder
		eor.l	d6,(a2)+		;w7
		eor.l	d0,(a2)+		;w8
		movem.l	(a1)+,d0-d6		;r15
		write7	a2				;w15		62
		move.l	(a1)+,d4
		move.l	(a1)+,d5
		move.l	(a1)+,d6		;r18		71
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w18		86
		move.l	(a3)+,d0		;r1			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d1-d4		;r5			
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;43
eor3label_123
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w5		15
		movem.l	(a3)+,d0-d6		;r12	32
		write7	a4				;w12	67
		movem.l	(a3)+,d0-d5		;r18	82
		eor.l	d0,(a4)+		;w13	87
		lea		scanLineWidth-72(a3),a1	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w15
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w17
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;44
eor3label_124
	hsLeftBorder
		eor.l	d5,(a4)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+		;w8
		eor.l	d1,(a2)+		;w9
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+		;w11
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+		;w13
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;45
eor3label_125
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a4				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;46
eor3label_126
	hsLeftBorder
		eor.l	d0,(a4)+		;w10
		eor.l	d1,(a4)+		;w11
		eor.l	d2,(a4)+		;w12
		eor.l	d3,(a4)+		;w13	20
		movem.l	(a3)+,d0-d4		;r18	33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18	58
		lea		scanLineWidth-72(a3),a1	;60
		movem.l	(a1)+,d0-d5		;r6		75
		eor.l	d0,(a2)+		;w1
		eor.l	d1,(a2)+		;w2
		eor.l	d2,(a2)+		;w3
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-72+52(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r10
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;47
eor3label_127
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w10	25
		movem.l	(a1)+,d0-d6		;r17	42
		write7	a2				;w17	77
		move.l	(a1)+,d0		;r18	80
		eor.l	d0,(a2)+		;w18	85
		lea		scanLineWidth-72(a1),a3		;87
		lea		scanLineWidth-72(a2),a4		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w1
		move.l	(a3)+,d4		
		move.l	(a3)+,d5		;r6
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;48
eor3label_128
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6	25
		movem.l	(a3)+,d0-d6		;r13		42
		write7	a4				;w13		77
		movem.l	(a3)+,d0-d4		;r18		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w15
		lea		scanLineWidth-64+12(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w17
		lea		scanLineWidth-64(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;;;
eor3label_129
	hsLeftBorder
		eor.l	d4,(a4)+		;18
		movem.l	(a1)+,d0-d6		;r7		22
		write7	a2				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-56+8(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-56(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;;;;;;;
eor3label_130
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
	REPT 12-7
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;
eor3label_131
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
	REPT 12-7
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;
eor3label_132
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
	REPT 12-7
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;
eor3label_133
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
	REPT 12-7
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;
eor3label_134
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
	REPT 12-7
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;
eor3label_135
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
	REPT 12-7
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;
eor3label_136
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
	REPT 12-7
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;
eor3label_137
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
	REPT 12-7
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;
eor3label_138
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
	REPT 12-7
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;
eor3label_139
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
	REPT 12-7
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;
eor3label_140
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
	REPT 12-7
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;
eor3label_141
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
	REPT 12-7
		nop
	ENDR	
;;;;;;;;;;
;;;;;;;
eor3label_142
;	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
	REPT 90-89
		nop
	ENDR
;	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
	REPT 12-12
		nop
	ENDR
;	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
	REPT 12-7
		nop
	ENDR	

;;;;;;;;;;
;;;;;;;
;eor3label_143
;	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7		17
		write7	a4				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		
		eor.l	d3,(a4)+		;89
;	REPT 90-89
;		nop
;	ENDR
;	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	
		lea		scanLineWidth-56(a3),a3
;	REPT 12-12
;		nop
;	ENDR
;	hsStabilize
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a4),a4
;	REPT 12-7
;		nop
;	ENDR	
;;;;;;;;;;
	lea		8(a3),a3
	lea		8(a4),a4

	REPT 8-1
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d2
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-40(a3),a3
		lea		scanLineWidth-40(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d2
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-32(a3),a3
		lea		scanLineWidth-32(a4),a4

	REPT 1
		movem.l	(a3)+,d0-d5
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-24(a3),a3
		lea		scanLineWidth-24(a4),a4
	ENDR

	jsr		copyRealTime
	popall
	move.w	#0,filldone
	rte
eor3end

;;;;;;;;;;

;	lea		8(a3),a3
;	lea		8(a4),a4
;;3(3),8(5),15(7),86(9),15(7),9(5),6(3)
;	REPT 3-1
;		movem.l	(a3)+,d0-d5
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		lea		scanLineWidth-24(a3),a3
;		lea		scanLineWidth-24(a4),a4
;	ENDR
;		movem.l	(a3)+,d0-d5
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		lea		scanLineWidth-32(a3),a3
;		lea		scanLineWidth-32(a4),a4
;
;	REPT 8-1
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d2
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		lea		scanLineWidth-40(a3),a3
;		lea		scanLineWidth-40(a4),a4
;	ENDR
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d2
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		lea		scanLineWidth-48(a3),a3
;		lea		scanLineWidth-48(a4),a4
;
;	REPT 15-1
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		lea		scanLineWidth-56(a3),a3
;		lea		scanLineWidth-56(a4),a4
;	ENDR
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		lea		scanLineWidth-64(a3),a3
;		lea		scanLineWidth-64(a4),a4
;
;	REPT 86-1
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d3
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		lea		scanLineWidth-72(a3),a3
;		lea		scanLineWidth-72(a4),a4
;	ENDR
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d3
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		lea		scanLineWidth-64(a3),a3
;		lea		scanLineWidth-64(a4),a4
;
;	REPT 15-1
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		lea		scanLineWidth-56(a3),a3
;		lea		scanLineWidth-56(a4),a4
;	ENDR
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		lea		scanLineWidth-48(a3),a3
;		lea		scanLineWidth-48(a4),a4
;
;	REPT 8-1
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d2
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		lea		scanLineWidth-40(a3),a3
;		lea		scanLineWidth-40(a4),a4
;	ENDR
;		movem.l	(a3)+,d0-d6
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		eor.l	d6,(a4)+
;		movem.l	(a3)+,d0-d2
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		lea		scanLineWidth-32(a3),a3
;		lea		scanLineWidth-32(a4),a4
;
;	REPT 6
;		movem.l	(a3)+,d0-d5
;		eor.l	d0,(a4)+
;		eor.l	d1,(a4)+
;		eor.l	d2,(a4)+
;		eor.l	d3,(a4)+
;		eor.l	d4,(a4)+
;		eor.l	d5,(a4)+
;		lea		scanLineWidth-24(a3),a3
;		lea		scanLineWidth-24(a4),a4
;	ENDR
;
;	rts


	dc.l	eor2label_105
	dc.l	eor2label_106
	dc.l	eor2label_107
	dc.l	eor2label_108
	dc.l	eor2label_109
	dc.l	eor2label_110
	dc.l	eor2label_111
	dc.l	eor2label_112
	dc.l	eor2label_113
	dc.l	eor2label_114
	dc.l	eor2label_115
	dc.l	eor2label_116
	dc.l	eor2label_117
	dc.l	eor2label_118
	dc.l	eor2label_119
	dc.l	eor2label_120
	dc.l	eor2label_121
	dc.l	eor2label_122
	dc.l	eor2label_123
	dc.l	eor2label_124
	dc.l	eor2label_125
	dc.l	eor2label_126
	dc.l	eor2label_127
	dc.l	eor2label_128
	dc.l	eor2label_129
	dc.l	eor2label_130
	dc.l	eor2label_131
	dc.l	eor2label_132
	dc.l	eor2label_133
	dc.l	eor2label_134
	dc.l	eor2label_135
	dc.l	eor2label_136
	dc.l	eor2label_137
	dc.l	eor2label_138
	dc.l	eor2label_139
	dc.l	eor2label_140
	dc.l	eor2label_141
eor2
;;;;;;;;1
	nop
	nop
	nop
	nop
eor2label_001
	hsLeftBorder
		REPT 90-89
			nop
		ENDR
		movem.l	(a3)+,d0-d6							; read 7
		write7	a4
		move.l	(a3)+,d0							; read 8
		eor.l	d0,(a4)+							; write 8
		lea		scanLineWidth-32(a3),a3				; update read
		lea		scanLineWidth-32(a4),a4				; update write
		movem.l	(a3)+,d0-d6							; read 7
		eor.l	d0,(a4)+							; write 1
		move.l	(a3)+,d0							; read 8
	hsRightBorder
		REPT 12-12
			nop
		ENDR
		lea		scanLineWidth-32(a3),a3				; update read
		eor.l	d1,(a4)+							
		eor.l	d2,(a4)+							;write 3
	hsStabilize
		REPT 12-12
			nop
		ENDR
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+							; write 5
		lea		scanLineWidth-32+12(a4),a2			; update write alt
;;;;;;;;;;;;;;;;;;;;;;;;; 2
eor2label_002
	hsLeftBorder
		REPT 90-90
			nop
		ENDR
		eor.l	d5,(a4)+					;5
		eor.l	d6,(a4)+					;10
		eor.l	d0,(a4)+					;15		write 8							;2 write
		movem.l	(a3)+,d0-d6					;32		read 7
		eor.l	d0,(a2)+					;37
		eor.l	d1,(a2)+					;42
		eor.l	d2,(a2)+					;47
		eor.l	d3,(a2)+					;52
		eor.l	d4,(a2)+					;57
		eor.l	d5,(a2)+					;62
		eor.l	d6,(a2)+					;67		write 7
		move.l	(a3)+,d0					;70		read 8						;3 read
		eor.l	d0,(a2)+					;75		write 8						;3 write
		lea		scanLineWidth-32(a3),a3		;77		updtate read
		movem.l	(a3)+,d0-d4					;90		read 5
	hsRightBorder
		REPT 12-12
			nop
		ENDR
		lea		scanLineWidth-32(a2),a4		;2		; update write
		eor.l	d0,(a4)+					;7
		eor.l	d1,(a4)+					;12		; write 2
	hsStabilize
		REPT 12-12
			nop
		ENDR	
		eor.l	d2,(a4)+					;5
		eor.l	d3,(a4)+					;10		; write 4
		lea		scanLineWidth-32+16(a4),a2	;12		; updare write alt


;;;;;;;;;; 3
eor2label_003
	hsLeftBorder
		eor.l	d4,(a4)+					;5		; write 5
		move.l	(a3)+,d0					;8		read 6
		eor.l	d0,(a4)+					;13		write 6
		move.l	(a3)+,d0					;16		read 7
		move.l	(a3)+,d1					;19		read 8						;4 read
		eor.l	d0,(a4)+					;24
		eor.l	d1,(a4)+					;29		write 8						;4 write
		lea		scanLineWidth-32(a3),a3		;31		update read
		movem.l	(a3)+,d0-d6					;48		read 7
		write7	a2							;83
		move.l	(a3)+,d0					;86		r8							;5 read
		move.l	(a3)+,d1					;89		r9
		REPT 90-89
			nop
		ENDR
	hsRightBorder
		eor.l	d0,(a2)+					;w8
		eor.l	d1,(a2)+					;w9
		lea		scanLineWidth-40+4(a2),a4
		REPT 12-12
			nop
		ENDR
	hsStabilize
		move.l	(a3)+,d0
		eor.l	d0,(a2)+					;w10
		lea		scanLineWidth-40(a3),a1
		REPT 12-10
			nop
		ENDR
;;;;;;;;4
;;;;;;;;;;;;;
eor2label_004
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r7			17
		write7	a4				;w7			52
		movem.l	(a1)+,d0-d2		;r10		61
		eor.l	d0,(a4)+		;w8
		eor.l	d1,(a4)+		;w9
		eor.l	d2,(a4)+		;w10		76
		lea		scanLineWidth-40(a1),a3		;78
		lea		scanLineWidth-40(a4),a2		;80
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		move.l	(a3)+,d2		;r3
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-48+32(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+		;w3
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r5
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;5
;;;;;;;;;;;;;
eor2label_005
	hsLeftBorder
		eor.l	d0,(a2)+		;w4
		eor.l	d1,(a2)+		;w5	
		movem.l	(a3)+,d0-d4		;r10		23
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w10		;48
		lea		scanLineWidth-48(a3),a1		;50
		movem.l	(a1)+,d0-d6		;r7			;67
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		87
		move.l	(a1)+,d0		;r8			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6
		lea		scanLineWidth-48+24(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+		;w8
		lea		scanLineWidth-48+16(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;6
;;;;;;;;;;;;;
eor2label_006
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r12		11
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w12		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a2				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-48+12(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		move.l	(a3)+,d0		;r10
		move.l	(a3)+,d1		;r11
		eor.l	d0,(a2)+		;w10
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;7
;;;;;;;;;;;;;
eor2label_007
	hsLeftBorder
		eor.l	d1,(a2)+		;w11
		move.l	(a3)+,d0
		eor.l	d0,(a2)+		;w12
		lea		scanLineWidth-48(a3),a1		;15
		movem.l	(a1)+,d0-d6		;r7			;32
		write7	a4				;w7			;67
		movem.l	(a1)+,d0-d4		;r12		;80
		eor.l	d0,(a4)+		;w8
		eor.l	d1,(a4)+		;w9
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-48(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+		;w12
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r2
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;8
eor2label_008
	hsLeftBorder
		lea		scanLineWidth-48(a4),a2
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2			;12
		movem.l	(a3)+,d0-d6		;r9			;29
		write7	a2				;w9			;64
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		move.l	(a3)+,d2		;r12		73
		eor.l	d0,(a2)+		;w10		78
		eor.l	d1,(a2)+		;w11		83
		eor.l	d2,(a2)+		;w12		88
		lea		scanLineWidth-48(a3),a1		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		lea		scanLineWidth-48(a2),a4
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;9
eor2label_009
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		movem.l	(a1)+,d0-d6		;r11		27
		write7	a4				;w11		62
		move.l	(a1)+,d0
		eor.l	d0,(a4)+		;w12		70
		lea		scanLineWidth-48(a1),a3		;72
		movem.l	(a3)+,d0-d6		;r7			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		lea		scanLineWidth-48(a4),a2		;2
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-48+32(a2),a4
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;10
eor2label_010
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7			;15
		movem.l	(a3)+,d0-d6		;r14		;32
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12		;53
		eor.l	d5,(a2)+		;w12		;53
		eor.l	d6,(a2)+		;w12		;67
		lea		scanLineWidth-56(a3),a1		;69
		movem.l	(a1)+,d0-d6		;r7			;86
		lea		scanLineWidth-56+28(a1),a3	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-56+48(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;;;11
eor2label_011
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w7
		movem.l	(a1)+,d0-d6		;r14		32
		write7	a4				;w14		67
		movem.l	(a3)+,d0-d6		;r7			84
		eor.l	d0,(a2)+		;w1			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;3
		lea		scanLineWidth-56+44(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-56+28(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;12
eor2label_012
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		movem.l	(a3)+,d0-d6		;r14		27
		write7	a2				;w14		62
		movem.l	(a1)+,d0-d6		;r7			79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-56+40(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6
		lea		scanLineWidth-56+28(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;13
eor2label_013
	hsLeftBorder
		eor.l	d6,(a4)+
		movem.l	(a1)+,d0-d6		;r14		22
		write7	a4				;w14		57
		movem.l	(a3)+,d0-d6		;r7			74
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w3
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-56+36(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		lea		scanLineWidth-56+28(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;14
eor2label_014
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r14
		write7	a2				;w14		52
		movem.l	(a1)+,d0-d6		;r7			69
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6
		lea		scanLineWidth-56+32(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+		;w7
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r9
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;15
eor2label_015
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		movem.l	(a1)+,d0-d4		;r14		23
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w14		;48
		lea		scanLineWidth-56(a1),a3		;50
		movem.l	(a3)+,d0-d6		;r7			;67
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		move.l	(a3)+,d0		;r8			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+	;w6
		lea		scanLineWidth-56+32(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+	;w8
		lea		scanLineWidth-56+24(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;16
eor2label_016
	hsLeftBorder
		movem.l	(a3)+,d0-d5		;r14	15
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w14	45
		movem.l	(a1)+,d0-d6		;r7		62
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w5
		move.l	(a1)+,d0		;r8		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w7
		lea		scanLineWidth-56+28(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w8
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r10
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;17
eor2label_017
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w10			10
		movem.l	(a1)+,d0-d3		;r14		21
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+	
		eor.l	d3,(a4)+		;w14		41
		lea		scanLineWidth-56(a1),a3		;43
		movem.l	(a3)+,d0-d6		;r7			;60
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;
		eor.l	d5,(a2)+		;
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d6,(a2)+
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-56+20(a2),a4
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;18
eor2label_018
	hsLeftBorder
		movem.l	(a3)+,d0-d4		;13		;r14
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;38		;w14
		lea		scanLineWidth-56(a3),a1	;40
		movem.l	(a1)+,d0-d6		;r7		57
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6		;87
		move.l	(a1)+,d0		;r8		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d6,(a4)+		;w7
		eor.l	d0,(a4)+		;w7
		lea		scanLineWidth-68+28(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d1-d4		;r12
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;19
eor2label_019
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w14		;36
		lea		scanLineWidth-64(a1),a3		;38
		movem.l	(a3)+,d0-d6		;r7			;45
		write7	a2
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r11		
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-64+28(a2),a4
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;20
eor2label_020
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w11		10
		movem.l	(a3)+,d0-d4	;r16		23
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+	;w16		48
		lea		scanLineWidth-64(a3),a1	;50
		movem.l	(a1)+,d0-d6	;r7			;67
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w4		;87
		move.l	(a1)+,d0	;r8		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	;w6
		lea		scanLineWidth-64+40(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+	
		eor.l	d0,(a4)+	;w8
		lea		scanLineWidth-64+32(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;	21
eor2label_021
	hsLeftBorder
		movem.l	(a1)+,d0-d6	;r15		17
		write7	a4			;w15		52
		move.l	(a1)+,d0		;		55
		eor.l	d0,(a4)+	;w16		60
		movem.l	(a3)+,d0-d6	;r7			77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w2			87
		move.l	(a3)+,d0	;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w4
		lea		scanLineWidth-64+48(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		lea		scanLineWidth-64+32(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;22
eor2label_022
	hsLeftBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+	;w8		;10	
		movem.l	(a3)+,d0-d6	;r15	;27
		write7	a2					;62
		move.l	(a3)+,d0			;65
		eor.l	d0,(a2)+			;70
		movem.l	(a1)+,d0-d6	;r7		;87
		lea		scanLineWidth-64+36(a1),a3	;89	
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-64+56(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize	
		eor.l	d2,(a4)+		;w3
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r9
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;23
eor2label_023
	hsLeftBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9		30
		movem.l	(a1)+,d0-d6		;r16	47
		write7	a4				;w16	82
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r2
		lea		scanLineWidth-64+56(a3),a1	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		lea		scanLineWidth-64+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r6	
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;24
eor2label_024
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w6		20
		movem.l	(a3)+,d0-d6		;r13	37
		write7	a2				;w13	72
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		move.l	(a3)+,d2		;r16
		eor.l	d0,(a2)+		;w14	86
		lea		scanLineWidth-64(a3),a1	;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w16
	REPT 12-10
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;25
eor2label_025
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+				;20
		movem.l	(a1)+,d0-d6		;r11	;37
		write7	a4				;w11	;72
		movem.l	(a1)+,d0-d6		;r18	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13
		lea		scanLineWidth-72+20(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-72(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;26
eor2label_026
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w18	15
		movem.l	(a3)+,d0-d6		;r7		32
		write7	a2				;		67
		movem.l	(a3)+,d0-d6		;r14	84
		eor.l	d0,(a2)+		;w8		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10
		lea		scanLineWidth-72+32(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		lea		scanLineWidth-72+16(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;27
eor2label_027
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;14	10
		movem.l	(a3)+,d0-d3		;r18		21
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		41
		movem.l	(a1)+,d0-d6		;r7			58
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6			88
		lea		scanLineWidth-72+48(a4),a2	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+		;w8
		lea		scanLineWidth-72+28(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;28
eor2label_028
	hsLeftBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11	15
		movem.l	(a1)+,d0-d6		;r18	32
		write7	a4				;w18	67
		movem.l	(a3)+,d0-d6		;r7		84
		eor.l	d0,(a2)+		;w1		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		lea		scanLineWidth-72+60(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-72+44(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;29
eor2label_029
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7	10
		movem.l	(a3)+,d0-d6		;r14	27
		write7	a2				;w14	62
		movem.l	(a3)+,d0-d3		;r18	73
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w17	88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+		;w18
		move.l	(a1)+,d0	
		move.l	(a1)+,d1		;r2
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;30
eor2label_030
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r9
		write7	a4				;w9		52
		movem.l	(a1)+,d0-d6		;r16	69
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w15
		lea		scanLineWidth-72+8(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+		;w16
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r18
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;31
eor2label_031
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w18
		movem.l	(a3)+,d0-d6		;r7		27
		write7	a2				;w7		62
		movem.l	(a3)+,d0-d6		;r14	79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		lea		scanLineWidth-72+28(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w13
		lea		scanLineWidth-72+16(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;32
eor2label_032
	hsLeftBorder
		eor.l	d6,(a2)+		;w14
		movem.l	(a3)+,d0-d3		;r18	16
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18	36
		movem.l	(a1)+,d0-d6		;r7		53
		write7	a4				;w7		88
		lea		scanLineWidth-72+44(a1),a3	
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;33
eor2label_033
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		movem.l	(a1)+,d0-d6		;r18		;27
		write7	a4				;w18		;62
		movem.l	(a3)+,d0-d6		;r7			;79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2			89

	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-72+56(a2),a4	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-72+44(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;34
eor2label_034
	hsLeftBorder	
		eor.l	d6,(a2)+		;w7	
		movem.l	(a3)+,d0-d6		;r14		22
		write7	a2				;w14		57
		movem.l	(a3)+,d0-d3		;r18		68
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		88
		lea		scanLineWidth(a1),a3
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;35
eor2label_035
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		movem.l	(a1)+,d0-d6		;r11
		write7	a4				;w11	62
		movem.l	(a1)+,d0-d6		;r18	79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w17
		lea		3*scanLineWidth-72(a1),a0
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;36
eor2label_036
	hsLeftBorder
		eor.l	d6,(a4)+		;w18
		movem.l	(a3)+,d0-d6		;r7		22
		write7	a2				;w7		57
		movem.l	(a3)+,d0-d6		;r14	74
		eor.l	d0,(a2)+		
		eor.l	d1,(a2)+		
		eor.l	d2,(a2)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-72+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w14
		lea		scanLineWidth-72+16(a3),a1		;a0-1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;37
eor2label_037
	hsLeftBorder
		movem.l	(a3)+,d0-d3		;r18	11
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18	31
		movem.l	(a1)+,d0-d6		;r7		48
		write7	a4				;w7		83
		move.l	(a1)+,d0		
		move.l	(a1)+,d1		;r9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;38
eor2label_038
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13		20
		movem.l	(a1)+,d0-d4		;r18		33		
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18		58	
		;;;;;;; BUG; 3 not init							
		movem.l	(a0)+,d0-d6		;r7			75
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w3			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5
		lea		scanLineWidth-72+52(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		lea		scanLineWidth-72+44(a0),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;39
eor2label_039
	hsLeftBorder
		movem.l	(a0)+,d0-d6		;r14		17
		write7	a2				;w14		52
		movem.l	(a0)+,d0-d3		;r18		63
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w18		;83
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r2		
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r6
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;40
eor2label_040
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w6	20
		movem.l	(a1)+,d0-d6		;r13	37
		write7	a4				;w13	72
		movem.l	(a1)+,d0-d4		;r18	85
		eor.l	d0,(a4)+		;w14
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w16
		lea		scanLineWidth-72(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18
		lea		2*scanLineWidth-72(a4),a4	
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;41
eor2label_041
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7
		write7	a2				;w7		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		
		lea		scanLineWidth-72+16(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+		;w14
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r16
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;42
eor2label_042
	hsLeftBorder
		eor.l	d0,(a2)+		;w15
		eor.l	d1,(a2)+		;w16
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w18		26
		movem.l	(a1)+,d0-d6		;r7			43
		write7	a4				;w7			78
		movem.l	(a1)+,d0-d3		;r11		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+	
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-72+28(a1),a3
	REPT 12-12		
		nop
	ENDR		
;;;;;;;;;;;

;;;;;;;;;;;;;43
eor2label_043
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r18
		write7	a4				;w18		52
		movem.l	(a3)+,d0-d6		;r7			69
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-72+48(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;

;;;;;;;;;;;;;44
eor2label_044
	hsLeftBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11		25
		movem.l	(a3)+,d0-d6		;r18		42
		write7	a2				;w18		77
		lea		scanLineWidth-72(a3),a1	;	79
		movem.l	(a1)+,d0-d3		;r4
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-72+56(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;45
eor2label_045
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r11
		write7	a4				;w11		52
		movem.l	(a1)+,d0-d6		;r18		69
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r2
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w18
		lea		scanLineWidth-72+64(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;46
eor2label_046
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		movem.l	(a3)+,d0-d6		;r9		
		write7	a2				;w9		62
		movem.l	(a3)+,d0-d6		;r16	79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w11
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w13
		lea		scanLineWidth-72+20(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+		;w14
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r18
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;47
eor2label_047
	hsLeftBorder
		eor.l	d5,(a2)+		;15
		eor.l	d6,(a2)+		;15
		eor.l	d0,(a2)+		;15
		eor.l	d1,(a2)+		;w18	20
		movem.l	(a1)+,d0-d6		;r7		37
		write7	a4				;w7		72
		movem.l	(a1)+,d0-d6		;r14	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;

;;;;;;;;;;;;;48
eor2label_048
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14		15
		movem.l	(a1)+,d0-d3		;r18		26
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w18		46
		movem.l	(a3)+,d0-d6		;r7			63
		eor.l	d0,(a2)+		;
		eor.l	d1,(a2)+		;
		eor.l	d2,(a2)+		;
		eor.l	d3,(a2)+		;
		eor.l	d4,(a2)+		;	88
		lea		scanLineWidth-72+44(a3),a1	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		lea		scanLineWidth-72+44(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;49
eor2label_049
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11		20
		movem.l	(a3)+,d0-d6		;r18		37
		write7	a2				;w18		72
		movem.l	(a1)+,d0-d6		;r7			
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-72+64(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-72+44(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;50
eor2label_050
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w7
		movem.l	(a1)+,d0-d6		;r14	32
		write7	a4				;w14	67
		movem.l	(a1)+,d0-d3		;r18	78
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		;w16	88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w18
	REPT 12-10
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;51
eor2label_051
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4		20
		movem.l	(a3)+,d0-d6		;r11	37
		write7	a2				;		72
		movem.l	(a3)+,d0-d6		;r18	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w13
		lea		scanLineWidth-72+20(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;52
eor2label_052
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w18	15
		movem.l	(a1)+,d0-d6		;r7		32
		write7	a4				;w7		67
		movem.l	(a1)+,d0-d6		;r14	84
		eor.l	d0,(a4)+		;w8
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w10
		lea		scanLineWidth-72+32(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;53
eor2label_053
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14
		movem.l	(a1)+,d0-d3		;r18
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w18		41
		movem.l	(a3)+,d0-d6		;r7			58
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-72+48(a2),a4	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+		;w7
		eor.l	d0,(a2)+		;w8
		lea		scanLineWidth-72+28(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;54
eor2label_054
	hsLeftBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11		15
		movem.l	(a3)+,d0-d6		;r18		32
		write7	a2				;w18		67
		movem.l	(a1)+,d0-d6		;r7			84
		eor.l	d0,(a4)+		;w1			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w3
		lea		scanLineWidth-72+60(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w5
		lea		scanLineWidth-72+44(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;55
eor2label_055
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w7
		movem.l	(a1)+,d0-d6		;r14
		write7	a4				;w14		62
		movem.l	(a1)+,d0-d3		;r18		73
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w17		;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+		;w18
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r2
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		lea		scanLineWidth-72+64(a2),a4
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;56
eor2label_056
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r9
		write7	a2				;w9		52
		movem.l	(a3)+,d0-d6		;r16	69
		eor.l	d0,(a2)+	
		eor.l	d1,(a2)+	
		eor.l	d2,(a2)+	
		eor.l	d3,(a2)+		;w13	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w15
		lea		scanLineWidth-72+8(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r18
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;

;;;;;;;;;;;;;57
eor2label_057
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w18		10
		movem.l	(a1)+,d0-d6		;r7			27
		write7	a4				;w7			62
		movem.l	(a1)+,d0-d6		;r14		79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9	
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-72+28(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w13
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;

;;;;;;;;;;;;;58
eor2label_058
	hsLeftBorder
		eor.l	d6,(a4)+		;w14
		movem.l	(a1)+,d0-d3		;r18
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w18		36
		movem.l	(a3)+,d0-d6		;r7			53
		write7	a2				;w7			88
		lea		scanLineWidth-80+44(a3),a1	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w9
		lea		scanLineWidth-80+36(a2),a4
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;59
eor2label_059
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w11
		movem.l	(a3)+,d0-d6	;r18
		write7	a2			;w18		62
		movem.l	(a1)+,d0-d6	;r7			79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w2
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w4
		lea		scanLineWidth-80+64(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	;w6
		lea		scanLineWidth-80+52(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;60
eor2label_060
	hsLeftBorder
		eor.l	d6,(a4)+		;w7		
		movem.l	(a1)+,d0-d6		;r14
		write7	a4				;w14	57
		movem.l	(a1)+,d0-d5		;r20	72
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;87
		move.l	(a3)+,d0		;r1
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-80+76(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		move.l	(a3)+,d1
		move.l	(a3)+,d2		;r3
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;61
eor2label_061
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w3
		movem.l	(a3)+,d0-d6		;r10
		write7	a2				;w10		67
		movem.l	(a3)+,d0-d6		;r17		84
		eor.l	d0,(a2)+		;w11		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w13
		lea		scanLineWidth-80+28(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r19
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;62
eor2label_062
	hsLeftBorder
		eor.l	d4,(a2)+		;w15
		eor.l	d5,(a2)+		;w16
		eor.l	d6,(a2)+		;w17
		eor.l	d0,(a2)+		;w18
		eor.l	d1,(a2)+		;w19
		move.l	(a3)+,d0
		eor.l	d0,(a2)+		;w20		33
		movem.l	(a1)+,d0-d6		;r7			50
		write7	a4				;w7			85
		move.l	(a1)+,d0		;r8
		lea		scanLineWidth-80+48(a1),a3	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d1-d4		;r12
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+		;w8
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-80+44(a4),a2
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;63
eor2label_063
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12	15
		movem.l	(a1)+,d0-d6		;r19	32
		write7	a4				;w19	67
		move.l	(a1)+,d0
		eor.l	d0,(a4)+		;w20	75
		movem.l	(a3)+,d0-d5		;r6		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;r4
		lea		scanLineWidth-80+56(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;64
eor2label_064
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6		10
		movem.l	(a3)+,d0-d6		;r13	27
		write7	a2				;w13	62
		movem.l	(a3)+,d0-d6		;r20	79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w15	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w19
	REPT 12-10
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;65
eor2label_065
	hsLeftBorder
		eor.l	d6,(a2)+		;w20	5
		movem.l	(a1)+,d0-d6		;r7		22
		write7	a4				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-80+32(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14
		lea		scanLineWidth-80+24(a1),a3	
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;66
eor2label_066
	hsLeftBorder
		movem.l	(a1)+,d0-d5		;r20	15
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w20	45
		movem.l	(a3)+,d0-d6		;r7		62
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5		
		move.l	(a3)+,d0		;r8		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		lea		scanLineWidth-80+52(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+		;w8
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r10
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;67
eor2label_067
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w10		10
		movem.l	(a3)+,d0-d6		;r17		27
		write7	a2				;w17		62
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		move.l	(a3)+,d2		;r20		71
		lea		scanLineWidth-80(a3),a1		;73
		eor.l	d0,(a2)+	
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w20		;88
	REPT 90-88
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r4		
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-80+72(a4),a2
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;68
eor2label_068
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		10	
		movem.l	(a1)+,d0-d6		;r11	27
		write7	a4				;w11	62
		movem.l	(a1)+,d0-d6		;r18	79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-80+20(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-80+8(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;69
eor2label_069
	hsLeftBorder
		eor.l	d6,(a4)+		;w18		5
		move.l	(a1)+,d0
		move.l	(a1)+,d1	
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w20		;21
		movem.l	(a3)+,d0-d6		;r7			;38
		write7	a2				;w7			;73
		movem.l	(a3)+,d0-d6		;r14		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-80+44(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-80+24(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;70
eor2label_070
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w14		15
		movem.l	(a3)+,d0-d5		;r20		30
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w20		60
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2			87
		move.l	(a1)+,d0		;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-80+64(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-80+48(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;71
eor2label_071
	hsLeftBorder
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+		;w8
		movem.l	(a1)+,d0-d6		;r15
		write7	a4				;w15		62
		movem.l	(a1)+,d0-d4		;r20		75
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w18		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w20
		lea		scanLineWidth-80+80(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;72
eor2label_072
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4		20
		movem.l	(a3)+,d0-d6		;r11	37
		write7	a2				;w11	72
		movem.l	(a3)+,d0-d6		;r18
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w13
		lea		scanLineWidth-80+28(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
	REPT 12-10
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;73
eor2label_073
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+	;w18
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w20		;31
		movem.l	(a1)+,d0-d6		;r7		;48
		write7	a4				;w7		83
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r9		899
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-80+44(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;74
eor2label_074
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13		20
		movem.l	(a1)+,d0-d6		;r20		37
		write7	a4				;w20		72
		lea		scanLineWidth-80(a1),a3		;74
		movem.l	(a3)+,d0-d5		;r6			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-80+56(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;75
eor2label_075
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		movem.l	(a3)+,d0-d6		;r13
		write7	a2				;w13		62
		movem.l	(a3)+,d0-d6		;r20		79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w15		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w17
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
	REPT 12-10
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;76
eor2label_076
	hsLeftBorder
		eor.l	d6,(a2)+		;w20	5
		movem.l	(a1)+,d0-d6		;r7		22
		write7	a4				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a4)+		;w8
		eor.l	d1,(a4)+		;w9
		eor.l	d2,(a4)+		;w10
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-80+32(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14
		lea		scanLineWidth-80+24(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;77
eor2label_077
	hsLeftBorder
		movem.l	(a1)+,d0-d5		;r20	15
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+	;30	w20	45
		movem.l	(a3)+,d0-d6		;r7		62
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;87
		move.l	(a3)+,d0		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		lea		scanLineWidth-80+52(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d1-d4		;r12
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;78
eor2label_078
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		
		eor.l	d4,(a2)+		;w12		25
		movem.l	(a3)+,d0-d6		;r19		42
		write7	a2				;w19		77
		move.l	(a3)+,d0
		eor.l	d0,(a2)+		;20			85
		lea		scanLineWidth-80(a3),a1	;	87
		move.l	(a1)+,d0		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+		;w1
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r3
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w3
		lea		scanLineWidth-80+68(a4),a2
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;79
eor2label_079
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r10
		write7	a4				;w10	52
		movem.l	(a1)+,d0-d6		;r17	69
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	
		eor.l	d2,(a4)+	
		eor.l	d3,(a4)+		;w14	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w17
		lea		scanLineWidth-80+12(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+		;5
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r19
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;80
eor2label_080
	hsLeftBorder
		move.l	(a1)+,d2
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w20		18
		movem.l	(a3)+,d0-d6		;r7			35
		write7	a2				;w7			70
		movem.l	(a3)+,d0-d6		;r14		87
		lea		scanLineWidth-80+24(a3),a1	;899
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-80+44(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+		;w10
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r16
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;81
eor2label_081
	hsLeftBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;30
		movem.l	(a3)+,d0-d3		;r20
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;30+20+11 = 61
		movem.l	(a1)+,d0-d6		;r7		78
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2		88
		lea		scanLineWidth-80+72(a4),a2	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-80+52(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;82
eor2label_082
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11		35
		movem.l	(a1)+,d0-d6		;r18		52
		write7	a4				;w18		87
		move.l	(a1)+,d0		;r19
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		move.l	(a1)+,d6
		move.l	(a3)+,d0
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+		;w20
		eor.l	d0,(a2)+		;w1
		lea		scanLineWidth-80+76(a2),a4
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;83
eor2label_083
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r8
		write7	a2				;w8		52
		movem.l	(a3)+,d0-d6		;r15	69
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w12	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		lea		scanLineWidth-80+20(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r19
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;84
eor2label_084
	hsLeftBorder
		eor.l	d6,(a2)+		;15
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		move.l	(a3)+,d0
		eor.l	d0,(a2)+		;w20		;33
		movem.l	(a1)+,d0-d6		;r7			;50
		write7	a4				;w7			;85
		move.l	(a1)+,d0		;r8
		lea		scanLineWidth-80+48(a1),a3	;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d1-d4		;r12
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-80+44(a4),a2
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;85
eor2label_085
	hsLeftBorder
		eor.l	d2,(a4)+	
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12		15	
		movem.l	(a1)+,d0-d6		;r19		32
		write7	a4				;w19		67
		move.l	(a1)+,d0		;			70
		eor.l	d0,(a4)+		;w20		75
		movem.l	(a3)+,d0-d5		;r6			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-80+72(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-80+56(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;86
eor2label_086
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		movem.l	(a3)+,d0-d6		;r13
		write7	a2				;w13		62
		movem.l	(a3)+,d0-d6		;r20		79
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w15		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+		;w16
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r2
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+		;w17
		move.l	(a1)+,d2
		move.l	(a1)+,d3		;r4
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;87
eor2label_087
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w20
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4			35
		movem.l	(a1)+,d0-d6		;r11		52
		write7	a4				;w11		87
		move.l	(a1)+,d0			;r12
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d1-d4		;r16
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13
		lea		scanLineWidth-80+16(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;88
eor2label_088
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w16		15
		movem.l	(a1)+,d0-d3		;r20		26
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w20		46
		lea		scanLineWidth-80(a4),a2	;	48
		movem.l	(a3)+,d0-d6		;r7			65
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w7
		lea		scanLineWidth-80+52(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;89
eor2label_089
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11
		movem.l	(a3)+,d0-d6		;r18
		write7	a2				;w18		62
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w20		78
		lea		scanLineWidth-80(a3),a1	;80
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3		;r4
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-80+72(a4),a2
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;90
eor2label_090
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		movem.l	(a1)+,d0-d6		;r11
		write7	a4				;w11		62
		movem.l	(a1)+,d0-d6		;r18		79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-80+8(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+		;w16
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r20
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;91
eor2label_091
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;20
		movem.l	(a3)+,d0-d6	;r7
		write7	a2			;w7		72
		movem.l	(a3)+,d0-d6	;r14	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w9
		lea		scanLineWidth-80+44(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w11
		lea		scanLineWidth-80+24(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;92
eor2label_092
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+	;W14		15
		movem.l	(a3)+,d0-d5		;r20
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+	;w20	;45 + 15. =60
	REPT 90-60
		nop
	ENDR
	hsRightBorder
		movem.l	(a1)+,d0-d3	;r4
	REPT 12-11	
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-80+64(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;93
eor2label_093
	hsLeftBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w4
		movem.l	(a1)+,d0-d6		;r11
		write7	a4				;w11		62
		movem.l	(a1)+,d0-d6		;r18		79
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w15
		lea		scanLineWidth-80+20(a4),a2	
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+		;w16
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r20
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;94
eor2label_094
	hsLeftBorder
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w20		20
		movem.l	(a3)+,d0-d6		;r7			37
		write7	a2				;w7			72
		movem.l	(a3)+,d0-d6		;r14		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-80+44(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+	
		eor.l	d3,(a2)+		;w11
		lea		scanLineWidth-80+24(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;95
eor2label_095
	hsLeftBorder
		eor.l	d4,(a2)+		;w12		;5
		eor.l	d5,(a2)+		;w13		;10
		eor.l	d6,(a2)+		;w14		;15
		movem.l	(a3)+,d0-d5		;r20		;30
		eor.l	d0,(a2)+					;35
		eor.l	d1,(a2)+					;40
		eor.l	d2,(a2)+					;45
		eor.l	d3,(a2)+					;50
		eor.l	d4,(a2)+					;55
		eor.l	d5,(a2)+		;w20		60
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		move.l	(a1)+,d0		;r8			
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-80+64(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6
		lea		scanLineWidth-80+48(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;96
eor2label_096
	hsLeftBorder
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+		;w8
		movem.l	(a1)+,d0-d6		;r15
		write7	a4				;w15	62
		movem.l	(a1)+,d0-d4		;r20	75
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w18	90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		move.l	(a3)+,d0
		move.l	(a3)+,d1
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+		;w20
		move.l	(a3)+,d2
		move.l	(a3)+,d3		;r4
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;97
eor2label_097
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4		20
		movem.l	(a3)+,d0-d6		;r11	37
		write7	a2				;w11	72
		movem.l	(a3)+,d0-d6		;r18	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-80+28+8(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		lea		scanLineWidth-80+8+8(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;98
eor2label_098
	hsLeftBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w20	;31
		movem.l	(a1)+,d0-d6		;r7		;48
		write7	a4				;w7		83
		move.l	(a1)+,d0
		move.l	(a1)+,d1		;r9

	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+		
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-72+36(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;99
eor2label_099
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w13		20
		movem.l	(a1)+,d0-d4		;r18		33
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w18		58
		lea		scanLineWidth-72(a1),a3		;60
		movem.l	(a3)+,d0-d6		;r7			77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		move.l	(a3)+,d0		;r8			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-72+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w6
		lea		scanLineWidth-72+40(a3),a1
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;100
eor2label_100
	hsLeftBorder
		eor.l	d6,(a2)+
		eor.l	d0,(a2)+		;w8		10
		movem.l	(a3)+,d0-d6		;r15	27
		write7	a2				;w15	62
		movem.l	(a3)+,d0-d4		;r20	75
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w20	90
	REPT 12-10
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;101
eor2label_101
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		20
		movem.l	(a1)+,d0-d6		;r11	37
		write7	a4				;w11	72
		movem.l	(a1)+,d0-d6		;r18	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w13	89
		lea		scanLineWidth-72(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-72+12(a4),a2
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;102
eor2label_102
	hsLeftBorder
		eor.l	d4,(a4)+	;w16
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a1)+,d0
		move.l	(a1)+,d1	;r20
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w20		31
		movem.l	(a3)+,d0-d6	;r7			48
		write7	a2			;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1	;r9
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w9
		lea		scanLineWidth-72+36(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3	;r13
	REPT 12-11
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;103
eor2label_103
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w13		20
		movem.l	(a3)+,d0-d4		;r18	33
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w18		58
		lea		scanLineWidth-72(a3),a1		;60
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2			87
		move.l	(a1)+,d0		;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-72+40(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6
		lea		scanLineWidth-72+48(a4),a2
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;104
eor2label_104
	hsLeftBorder
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+		;w8
		movem.l	(a1)+,d0-d6		;r15
		write7	a4				;w15	62
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		move.l	(a1)+,d2		;r18	71
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w18	86
		move.l	(a3)+,d0		;r1		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d1-d4		;r5
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		lea		scanLineWidth-72+64(a2),a4
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;105
eor2label_105
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5			15
		movem.l	(a3)+,d0-d6		;r12		32
		write7	a2				;w12		67
		movem.l	(a3)+,d0-d5		;r18		82
		eor.l	d0,(a2)+		;w13		87
		lea		scanLineWidth-72(a3),a1		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w17
	REPT 12-10
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;106
eor2label_106
	hsLeftBorder
		eor.l	d5,(a2)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a4				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-72+24(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;

;;;;;;;;;;;;;107
eor2label_107
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18	11
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w18	31
		movem.l	(a3)+,d0-d6		;r7		48
		write7	a2				;w7		83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d2-d5		;r13	
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-72+36(a2),a4
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;
;;;;;;;;;;;;;108
eor2label_108
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w13		20
		movem.l	(a3)+,d0-d4		;r18		33
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w18	;58
		lea		scanLineWidth-72(a3),a1		;60
		movem.l	(a1)+,d0-d6		;r7		;77
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2
		move.l	(a1)+,d0		;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-72+56(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6
		lea		scanLineWidth-72+40(a1),a3
	REPT 12-12
		nop
	ENDR		
;;;;;;;;;;;

;;;;;;;;;;;
;;;;;;;;;;;;;109
eor2label_109
	hsLeftBorder
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+	;w8			10
		movem.l	(a1)+,d0-d6		;r15	27
		write7	a4				;w15	62
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		move.l	(a1)+,d2		;71
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w18	86
		move.l	(a3)+,d0		;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d1-d4		;r5
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		lea		scanLineWidth-72+64(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;;;110
eor2label_110
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5		15
		movem.l	(a3)+,d0-d6		;r12	32
		write7	a2				;w12	67
		movem.l	(a3)+,d0-d5		;r17	82
		eor.l	d0,(a2)+		;w13	87
	REPT 90-87
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+		;w14
		eor.l	d2,(a2)+		;w15
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+		;w16
		eor.l	d4,(a2)+		;w17
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;

;;;;;;;;;;;
;;;;;;;;;;;;;111
eor2label_111
	hsLeftBorder
		eor.l	d5,(a2)+		;w18		5
		movem.l	(a1)+,d0-d6		;r7			22
		write7	a4				;w7			57
		movem.l	(a1)+,d0-d6		;r14		74
		eor.l	d0,(a4)+		;w8			79
		eor.l	d1,(a4)+		;w9
		eor.l	d2,(a4)+		;w10
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-72+24(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;;;112
eor2label_112
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w18		;31
		movem.l	(a3)+,d0-d6		;r7			;48
		write7	a2				;w7			;83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-72+36(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;;;113
eor2label_113
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w13		20
		movem.l	(a3)+,d0-d4		;r18		33
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w18		58
		lea		scanLineWidth-72(a3),a1		;60
		movem.l	(a1)+,d0-d6		;r7			;77
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2			;87
		move.l	(a1)+,d0		;r8		
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-72+56(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-72+40(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;;;114
eor2label_114
	hsLeftBorder
		eor.l	d6,(a4)+	
		eor.l	d0,(a4)+		;w8
		movem.l	(a1)+,d0-d6		;r15
		write7	a4				;w15		62
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		move.l	(a1)+,d2		;r18		71
		eor.l	d0,(a4)+		;76
		eor.l	d1,(a4)+		;81
		eor.l	d2,(a4)+		;86	w18
		move.l	(a3)+,d0		;r1
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d1-d4		;r5
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		lea		scanLineWidth-72+64(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;;;115
eor2label_115
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		eor.l	d4,(a2)+		;w5		;15
		movem.l	(a3)+,d0-d6		;r12	;32
		write7	a2				;w12	;67
		movem.l	(a3)+,d0-d5		;r18	;82
		eor.l	d0,(a2)+		;w13	;87
		lea		scanLineWidth-72(a3),a1	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w17
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;;;116
eor2label_116
	hsLeftBorder
		eor.l	d5,(a2)+		;w18
		movem.l	(a1)+,d0-d6		;r7		22
		write7	a4				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-72+24(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;117

;;;;;;;;;;;;;
eor2label_117
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		11
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a2				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-72+36(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;118

;;;;;;;;;;;;;
eor2label_118
	hsLeftBorder
		eor.l	d0,(a2)+			
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;20	w13
		movem.l	(a3)+,d0-d4		;r18		33
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w18		58
		lea		scanLineWidth-72(a3),a1		;60
		movem.l	(a1)+,d0-d6		;r7			77
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2		87
		move.l	(a1)+,d0		;r8		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-72+40(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6
		lea		scanLineWidth-72+48(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;119
;;;;;;;;;;;;;
eor2label_119
	hsLeftBorder
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+		;w8
		movem.l	(a1)+,d0-d6		;r15
		write7	a4				;w15		62
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		move.l	(a1)+,d2		;r18		71
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w18		86
		move.l	(a3)+,d0		;r1			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d1-d4		;r5
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		lea		scanLineWidth-72+64(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;120
;;;;;;;;;;;;;
eor2label_120
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5		15
		movem.l	(a3)+,d0-d6		;r12	32
		write7	a2				;w12	67
		movem.l	(a3)+,d0-d5		;r18	82
		eor.l	d0,(a2)+		;w13	87
	REPT 90-87
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+	
		lea		scanLineWidth-72(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;17
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;;;121
eor2label_121
	hsLeftBorder
		eor.l	d5,(a2)+		;w18
		movem.l	(a1)+,d0-d6		;r7
		write7	a4				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a4)+			
		eor.l	d1,(a4)+		
		eor.l	d2,(a4)+		;w10	89		
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-72+24(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;122
;;;;;;;;;;;;;
eor2label_122
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;31	w18
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a2				;w7			83
		move.l	(a3)+,d0		
		move.l	(a3)+,d1		;r9			89				
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-72+36(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;123
;;;;;;;;;;;
;;;;;;;;;;;;;
eor2label_123
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w13		20
		movem.l	(a3)+,d0-d4		;r18		33
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w18		58
		lea		scanLineWidth-72(a3),a1		;60
		movem.l	(a1)+,d0-d6		;r7			;77
		eor.l	d0,(a4)+		;w1		82
		eor.l	d1,(a4)+		;w2		87
		move.l	(a1)+,d0		;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-72+56(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6
		lea		scanLineWidth-72+40(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;124

;;;;;;;;;;;;;
eor2label_124
	hsLeftBorder
		eor.l	d6,(a4)+		;						5
		eor.l	d0,(a4)+		;w8						10
		movem.l	(a1)+,d0-d6		;r15					27
		write7	a4				;w15	62				62
		move.l	(a1)+,d0						;		65
		move.l	(a1)+,d1						;		68
		move.l	(a1)+,d2		;r18	71		;		71
		eor.l	d0,(a4)+						;		76
		eor.l	d1,(a4)+						;		81
		eor.l	d2,(a4)+		;w18	86		;		86
		move.l	(a3)+,d0		;r1				;
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d1-d4		;r5
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		lea		scanLineWidth-72+64(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;125
;;;;;;;;;;;;;
eor2label_125
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5		15
		movem.l	(a3)+,d0-d6		;r12	32
		write7	a2				;w12	67
		movem.l	(a3)+,d0-d5		;r18	82
		eor.l	d0,(a2)+		;w13	87
		lea		scanLineWidth-72(a3),a1	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;126
;;;;;;;;;;;;;
eor2label_126

	hsLeftBorder
		eor.l	d5,(a2)+	;w18
		movem.l	(a1)+,d0-d6		;r7		
		write7	a4				;w7		57
		movem.l	(a1)+,d0-d6		;r14	74
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w10	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-72+24(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+		;w14
		lea		scanLineWidth-72+16(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;

;;;;;;;;;;;127
;;;;;;;;;;;;;
eor2label_127
	hsLeftBorder
		movem.l	(a1)+,d0-d3		;r18		11
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w18		31
		movem.l	(a3)+,d0-d6		;r7			48
		write7	a2				;w7			83
		move.l	(a3)+,d0
		move.l	(a3)+,d1		;r9			89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-72+36(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3		;r13
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;

;;;;;;;;;;;128
;;;;;;;;;;;;;
eor2label_128
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+			;20
		movem.l	(a3)+,d0-d4		;r18
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w18		45+13 = 58
		lea		scanLineWidth-72(a3),a1		;60
		movem.l	(a1)+,d0-d6		;r7			;77
		eor.l	d0,(a4)+		;w1	
		eor.l	d1,(a4)+		;w2			;87
		lea		scanLineWidth-72+44(a1),a3	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4
		lea		scanLineWidth-72+56(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;

;;;;;;;;;;;129
;;;;;;;;;;;;;
eor2label_129
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11		;35
		movem.l	(a1)+,d0-d6		;r18		52
		write7	a4				;w18		87
		move.l	(a3)+,d0		;r1			90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d1-d4		;r5
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		lea		scanLineWidth-72+64(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;130
;;;;;;;;;;;;;
eor2label_130
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w5		15
		movem.l	(a3)+,d0-d6		;r12	32
		write7	a2				;w12	67
		movem.l	(a3)+,d0-d5		;r18	82
		eor.l	d0,(a2)+		;w13	87
		lea		scanLineWidth-72(a3),a1	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w15
	REPT 12-10
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w17
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;131
;;;;;;;;;;;;;
eor2label_131
	hsLeftBorder
		eor.l	d5,(a2)+		;w18			5
		movem.l	(a1)+,d0-d6		;r7								;;;;;;;;;16 from here on
		write7	a4				;w7				57
		movem.l	(a1)+,d0-d6		;r14			74
		eor.l	d0,(a4)+		;w8
		eor.l	d1,(a4)+		;w8
		eor.l	d2,(a4)+		;w10
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-64+16(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		lea		scanLineWidth-64+8(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;132
;;;;;;;;;;;;;
eor2label_132
	hsLeftBorder
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w16	;16
		movem.l	(a3)+,d0-d6		;r7
		write7	a2				;w7		68
		movem.l	(a3)+,d0-d6		;r14	85
		eor.l	d0,(a2)+		;w8		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+		;w10
		lea		scanLineWidth-64+24(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+		;w12
		lea		scanLineWidth-64+8(a3),a1
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;
;;;;;;;;;;;133
;;;;;;;;;;;;;
eor2label_133
	hsLeftBorder
		eor.l	d5,(a2)+
		eor.l	d6,(a2)+		;w14
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w16		26
		movem.l	(a1)+,d0-d6		;r7			
		write7	a4				;w7			78
		movem.l	(a1)+,d0-d3		;r11		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w9
		lea		scanLineWidth-64+28(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w11
		lea		scanLineWidth-64+20(a1),a3
	REPT 12-12
		nop
	ENDR	

;;;;;;;;;;;
;;;;;;;;;;;134
;;;;;;;;;;;;;
eor2label_134
	hsLeftBorder
		movem.l	(a1)+,d0-d4		;r16	
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w16			;38
		movem.l	(a3)+,d0-d6		;r7	
		write7	a2				;w7				90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		movem.l	(a3)+,d0-d3		;r11
	REPT 12-11
		nop
	ENDR
	hsStabilize
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w9
		lea		scanLineWidth-64+28(a2),a4
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;135
;;;;;;;;;;;;;
eor2label_135
	hsLeftBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w11		10
		movem.l	(a3)+,d0-d4		;r16	23
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+
		eor.l	d4,(a2)+	;w16		;48
		lea		scanLineWidth-64(a3),a1	;50
		movem.l	(a1)+,d0-d6		;r7		;67
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+		;w4		;87
		move.l	(a1)+,d0		;r8		;90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+		;w6
		lea		scanLineWidth-64+40(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a4)+
		eor.l	d0,(a4)+		;w8
		lea		scanLineWidth-64+32(a1),a3
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;;;136
eor2label_136
	hsLeftBorder
		movem.l	(a1)+,d0-d6		;r15
		write7	a4				;w15		52
		move.l	(a1)+,d0
		eor.l	d0,(a4)+		;w16		60
		movem.l	(a3)+,d0-d6		;r7			77
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+		;w2
		move.l	(a3)+,d0		;r8
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w4
		lea		scanLineWidth-64+48(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+
		lea		scanLineWidth-64+32(a3),a1
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;;;137
eor2label_137
	hsLeftBorder
		eor.l	d6,(a2)+		;w7
		eor.l	d0,(a2)+		;w8		;10
		movem.l	(a3)+,d0-d6		;r15	
		write7	a2				;w15	62
		move.l	(a3)+,d0
		eor.l	d0,(a2)+		;w16	70
		movem.l	(a1)+,d0-d6		;r7		87
		lea		scanLineWidth-64+36(a1),a3	;89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+		;w2
		lea		scanLineWidth-64+56(a4),a2
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
	REPT 12-10
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;;;138
eor2label_138
	hsLeftBorder
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+	;w7		15
		movem.l	(a1)+,d0-d6	;r14	
		write7	a4			;w14	67
		move.l	(a1)+,d0
		move.l	(a1)+,d1	;		73
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+	;w16	83
		move.l	(a3)+,d0
		move.l	(a3)+,d1	;r2		89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+	;w2
		lea		scanLineWidth-64+56(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a3)+,d0-d3	;r6
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;;;139
eor2label_139
	hsLeftBorder
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+	;w6			20
		movem.l	(a3)+,d0-d6	;r13	
		write7	a2			;w13		72
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		move.l	(a3)+,d2	;r16	81
		eor.l	d0,(a2)+	;w14	86
	REPT 90-86
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+	;w16
		lea		scanLineWidth-64(a3),a1
	REPT 12-12
		nop
	ENDR
	hsStabilize
		movem.l	(a1)+,d0-d3	;r4
	REPT 12-11
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;140
;;;;;;;;;;;;;
eor2label_140
	hsLeftBorder
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+	;w4
		movem.l	(a1)+,d0-d6	;r11	
		write7	a4			;w11		72
		movem.l	(a1)+,d0-d4	;w16		85
		eor.l	d0,(a4)+	;w12		90
	REPT 90-90
		nop
	ENDR
	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-64(a1),a3
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-64(a4),a2
	REPT 12-12
		nop
	ENDR	
;;;;;;;;;;;
;;;;;;;;;;;;;141
eor2label_141
	hsLeftBorder
		movem.l	(a3)+,d0-d6		;r7
		write7	a2				;w8		52
		movem.l	(a3)+,d0-d6		;r14	69
		eor.l	d0,(a2)+
		eor.l	d1,(a2)+
		eor.l	d2,(a2)+
		eor.l	d3,(a2)+		;w11	89
	REPT 90-89
		nop
	ENDR
	hsRightBorder
		eor.l	d4,(a2)+
		eor.l	d5,(a2)+		;w13
		lea		scanLineWidth-64+8+8+4(a2),a4
	REPT 12-12
		nop
	ENDR
	hsStabilize
		eor.l	d6,(a2)+		;w14
		move.l	(a3)+,d0		;r15
		lea		scanLineWidth-64+8+4(a3),a1
	REPT 12-10
		nop
	ENDR	

;;;;;;;;;;;
;;;;;;;;;;;;;142
eor2label_142
;	hsLeftBorder
		eor.l	d0,(a2)+		;w15		
		move.l	(a3)+,d0		;r16
		eor.l	d0,(a2)+		;w16		13

		movem.l	(a1)+,d0-d6		;r7			
		write7	a4				;w7			65
		movem.l	(a1)+,d0-d6		;r14		82
		eor.l	d0,(a4)+		;w8			;87

	REPT 90-87
		nop
	ENDR
;	hsRightBorder
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+		;w10
		lea		scanLineWidth-56+16(a4),a2		
	REPT 12-12
		nop
	ENDR
;	hsStabilize
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+		;w12
		lea		scanLineWidth-56(a1),a3
	REPT 12-12
		nop
	ENDR
	;;;;;;;;;; END HARDSYNC
	eor.l	d5,(a4)+
	eor.l	d6,(a4)+			;;;; LINE DONE

	REPT 5
	movem.l	(a3)+,d0-d6		;7
	write7	a2
	movem.l	(a3)+,d0-d6
	write7	a2
	lea		scanLineWidth-56(a3),a3
	lea		scanLineWidth-56(a2),a2
	ENDR
	movem.l	(a3)+,d0-d6		;7
	write7	a2
	movem.l	(a3)+,d0-d6
	write7	a2
	lea		scanLineWidth-56(a3),a3
	lea		scanLineWidth-56(a2),a4





	REPT 6-1	;8 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d4
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-48(a3),a3
		lea		scanLineWidth-48(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d4
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-40(a3),a3
		lea		scanLineWidth-40(a4),a4


	REPT 5-4	;8 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d2
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-40(a3),a3
		lea		scanLineWidth-40(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d2
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-32(a3),a3
		lea		scanLineWidth-32(a4),a4

	REPT 1	;8 blocks
		movem.l	(a3)+,d0-d5
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-24(a3),a3
		lea		scanLineWidth-24(a4),a4
	ENDR

		jsr	copyRealTime
	popall
	move.w	#0,filldone
	rte
eor2end

	IF scanLineWidth=160
;eor2
;5(4),3(5),6(6),9(7),5(8),28(9),28(10),26(9),10(8),7(7),6(6),5(5),4(3)
	REPT 5-1	;4 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0
		eor.l	d0,(a4)+
		lea		scanLineWidth-32(a3),a3
		lea		scanLineWidth-32(a4),a4
	ENDR

	REPT 3-1	;4 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d2
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-40(a3),a3
		lea		scanLineWidth-40(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d2
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-48(a3),a3
		lea		scanLineWidth-48(a4),a4



	REPT 6	;4 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d4
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-48(a3),a3
		lea		scanLineWidth-48(a4),a4
	ENDR


	REPT 9-1	;7 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a3),a3
		lea		scanLineWidth-56(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		lea		scanLineWidth-64(a3),a3
		lea		scanLineWidth-64(a4),a4

	REPT 5	;8 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-64(a3),a3
		lea		scanLineWidth-64(a4),a4
	ENDR	

	REPT 28-1	;8 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d3
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-72(a3),a3
		lea		scanLineWidth-72(a4),a4
	ENDR	
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d3
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-80(a3),a3
		lea		scanLineWidth-80(a4),a4


	REPT 28-1	;8 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d5
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-80(a3),a3
		lea		scanLineWidth-80(a4),a4
	ENDR	
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d5
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-72(a3),a3
		lea		scanLineWidth-72(a4),a4

	REPT 26	;8 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d3
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		lea		scanLineWidth-72(a3),a3
		lea		scanLineWidth-72(a4),a4
	ENDR	

	REPT 10-1	;8 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-64(a3),a3
		lea		scanLineWidth-64(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		move.l	(a3)+,d0
		move.l	(a3)+,d1
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		lea		scanLineWidth-56(a3),a3
		lea		scanLineWidth-56(a4),a4

	REPT 7	;8 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		lea		scanLineWidth-56(a3),a3
		lea		scanLineWidth-56(a4),a4
	ENDR


	REPT 6-1	;8 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d4
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-48(a3),a3
		lea		scanLineWidth-48(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d4
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		lea		scanLineWidth-40(a3),a3
		lea		scanLineWidth-40(a4),a4


	REPT 5-1	;8 blocks
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d2
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-40(a3),a3
		lea		scanLineWidth-40(a4),a4
	ENDR
		movem.l	(a3)+,d0-d6
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		eor.l	d6,(a4)+
		movem.l	(a3)+,d0-d2
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		lea		scanLineWidth-32(a3),a3
		lea		scanLineWidth-32(a4),a4

	REPT 4	;8 blocks
		movem.l	(a3)+,d0-d5
		eor.l	d0,(a4)+
		eor.l	d1,(a4)+
		eor.l	d2,(a4)+
		eor.l	d3,(a4)+
		eor.l	d4,(a4)+
		eor.l	d5,(a4)+
		lea		scanLineWidth-24(a3),a3
		lea		scanLineWidth-24(a4),a4
	ENDR
	rts
	endc


initDivTable
	move.l	divtablepointer,a0
	moveq	#0,d7
	moveq	#0,d6
	moveq	#0,d5
	moveq	#0,d4
	move.l	#128,d0
	move.w	#128,d2

; encoding: upper 8 bits is x
;			lower 8 bits is y
; offset is longword per item
.outerloop:
	moveq	#0,d6		; y
.innerloop:
	REPT 8
		moveq	#0,d1
		move.l	d7,d5	; x																			;	4
		cmp.w	d2,d6
		bgt.w	*+34

		asl.l	#8,d5					; make my value 2^8; 8 bits more 

		divu	d6,d5					; divide
		move.w	d5,d1					; put whole in lower word
		clr.w	d5						; clear lower word
		swap	d5						; put remainder in lower word
		asl.l	#8,d5					; shift up 8 positions
		divu	d6,d5					; divide again
		swap	d1						; swap words, so fraction is in lower
		asr.l	#8,d1					; shift down the value 8 bites, so we have the normal size
		or.w	d5,d1					; OR into the bits
		swap	d1						; fraction, 

		IF scanLineWidth=160
		asl.w	#5,d1			;32
		move.w	d1,d3
		add.w	d1,d1			;64
		add.w	d1,d1			;128
		add.w	d3,d1			;---> 32 										; 177 vbl

		ELSE
					;230 = 128 + 64 + 32 + 16
		add.w	d1,d1		;2				230 = 2 + 4 + 32 + 64 + 128
		move.w	d1,d3		;2
		add.w	d1,d1
		add.w	d1,d3		;6

		add.w	d1,d1		;8
		add.w	d1,d1		;16
		add.w	d1,d1		;32
		add.w	d1,d3		;6+32
		add.w	d1,d1		;64
		add.w	d1,d3		;6+32+64
		add.w	d1,d1		;128
		add.w	d3,d1	

		ENDC

		swap	d1
		move.l	d1,(a0)+

		;end actual calc
		addq	#1,d6	
	ENDR
																					;	4
		cmp		d0,d6																				;	8
		blt		.innerloop																			; ----> +12 ==> 426
	addq	#1,d7																					;	4
	cmp		d2,d7																					;	8
	blt		.outerloop																				; ---> 256*256*426 + 256*16 = 3.5sec precalc
	move.w	#$4e75,initDivTable
	rts










; this rout generates 2 bitplane linedrawing
;	- no integer part for the y-increase
;
; a0: generated code pointer
; a5; offset for 2nd bitplane to color
; d7: y-offset increase/decrease
generateLineCode_2BPL_no_integer_slope
;	move.l	\1,a0
	move.l	#$BD10BD28,a2		; eor.b	d6,(a0)	eor.b,d6,x(a0)
	move.l	#$BF10BF28,d1		; eor.b	d7,x(a0)
	move.l	#$B910B928,d2		; eor.b	d4,x(a0)
	move.l	#$05500568,d3		; bchg	d2,x(a0)
	move.l	#$BB10BB28,d4		; eor.b	d5,x(a0)
	move.l	#$B510B528,d5		; eor.b	d2,x(a0)
	move.l	#$01500168,d6		; eor.b	d2,x(a0)
	move.l	#$B118B128,a6		; eor.b	d0,1(a0)				b118 = eor.b	d0,(a0)+	b128 = eor.b	d0,x(a0)		
	move.l	#$B110B128,a3		; eor.b d0,2(a0)				

	move.l	#$D24A6404,a1		; add.w	a2,d1
;	move.w	#$6404,a4			; bcc +4
	move.l	#$41E8FF60,d0		; lea	x(a0),a0
	move.w	d7,d0

	move.l	#lineloopsize-1,d7
.loop
		move.l	a2,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+		

		move.l	d1,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	a6,(a0)+			; this one does +1 to the screen buffer
		subq.w	#1,a5
		move.w	a5,(a0)+			; so we have -1 here, because we cool
		addq.w	#1,a5
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+
;;;;
		move.l	a2,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d1,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	a3,(a0)+				;	eor.b	d0,(a0) ; eor.b d0,x(a0)
		move.w	a5,(a0)+				;	#2
		move.w	#$5E48,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+
	dbra	d7,.loop
	rts

; this rout generates 2 bitplane linedrawing, where the bitplanes are adjecent
;	- integer part for slope increase
; a0: generated code pointer
; a5: offset to 2nd bitplane
; d7: y-offset increase/decrease
generateLineCode_2BPL_yes_integer_slope
	move.l	#$BD10BD28,a2		;	eor.b	d6,(a0) ; eor.b,d6,x(a0)
	move.l	#$BF10BF28,d1		;	eor.b	d7,(a0)	; eor.b	d7,x(a0)
	move.l	#$B910B928,d2		;	eor.b	d4,(a0) ; eor.b	d4,x(a0)
	move.l	#$05500568,d3		;	bchg	d2,(a0)	; bchg	d2,x(a0)
	move.l	#$BB10BB28,d4		;	eor.b	d5,(a0)	; eor.b	d5,x(a0)
	move.l	#$B510B528,d5		;	eor.b	d2,(a0)	; eor.b	d2,x(a0)
	move.l	#$01500168,d6		;	bchg	d0,(a0)	; eor.b	d2,x(a0)
	move.l	#$B118B128,a6		;	eor.b	d0,(a0)+	; eor.b	d0,1(a0)

	move.l	#$B110B128,a3		;	eor.b	d0,(a0) ; eor.b d0,2(a0)

	move.l	#$D0C9D24A,a1		;	add		a1,a0	;	add.w	a2,d1
	move.w	#$6404,a4			;	bcc.s	*+6
	move.l	#$41E8FF60,d0		;	add.w	#x,a0
	move.w	d7,d0
	move.l	#lineloopsize-1,d7
.loop
		move.l	a2,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+		
		move.w	a4,(a0)+
		move.l	d0,(a0)+		

		move.l	d1,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	a6,(a0)+	
		subq.w	#1,a5	
		move.w	a5,(a0)+
		addq.w	#1,a5
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+
;;;;
		move.l	a2,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d1,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+		
		move.w	a5,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	a3,(a0)+				;	eor.b	d0,(a0) ; eor.b d0,x(a0)
		move.w	a5,(a0)+				;	#2
		move.w	#$5E48,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+
	dbra	d7,.loop
	rts




;	d6	eor		pixel 10000000	
;	d7	eor		pixel 01000000
;	d4	eor 	pixel 00100000
;	d2	bchg	pixel 00010000	bit 4
;	d5	eor		pixel 00001000
;	d2	eor		pixel 00000100
;	d0	bchg	pixel 00000010	bit 1
;	d0	eor		pixel 00000001

;	d0
;	d2
;	d4
;	d5
;	d6
;	d7

; this does the basic line generation with 160 and -160 offset on overflow, but has MINOR dy/dx
;	eor.b 	reg,(a0)		;12
;	add.w	a2,d1			;4
;	bcc.s	*+6				;8/12
;	lea		160(a0),a0		;8
;
; without removing the branch, we cannot further optimize this
;
;	FOR STE:
;		slope:
;	----YYyy	= word		slope													a0
;	----YYyy	= current Y position, 64kb											d1
;	------xx	= X word position, byte												d6
;	--SSYYxx	= screen address 64k aligned										d3

;	add.w	a0,d1			;4
;	move.w	d1,d3			;4
;	move.b	d6,d3			;4
;	move.l	d3,a6			;4
;	eor.b	#$7,(a6)		;16
;
;	add.w	a0,d1			;4
;	move.w	d1,d3			;4
;	move.b	d6,d3			;4
;	move.l	d3,a6			;4
;	eor.b	d7,(a6)			;12				--> for 16 => 32*2 + 28*14 + 8 = 64 + 392 + 8 = 464 
;	
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	eor.b	d4,(a6)
;
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	bchg	d2,(a6)
;
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	eor.b	d5,(a6)
;
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	eor.b	d2,(a6)
;
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	bchg	d0,(a6)
;
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	eor.b	d0,(a6)
;
;	addq.w	#1,d6
;
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	eor.b	#$7,(a6)
;
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	eor.b	d7,(a6)
;	
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	eor.b	d4,(a6)
;
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	bchg	d2,(a6)
;
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	eor.b	d5,(a6)
;
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	eor.b	d2,(a6)
;
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	bchg	d0,(a6)
;
;	add.w	a0,d1
;	move.w	d1,d3
;	move.b	d6,d3
;	move.l	d3,a6
;	eor.b	d0,(a6)
;
;	addq.w	#7,d6





generateLineCode_1BPL_no_integer_slope
	move.l	#$BD10D24A,a2		;	eor.b	d6,(a0) ; add.w a2,d1
	move.l	#$BF10D24A,d1		;	eor.b	d7,(a0)	; add.w a2,d1
	move.l	#$B910D24A,d2		;	eor.b	d4,(a0) ; add.w a2,d1
	move.l	#$0550D24A,d3		;	bchg	d2,(a0)	; add.w a2,d1
	move.l	#$BB10D24A,d4		;	eor.b	d5,(a0)	; add.w a2,d1
	move.l	#$B510D24A,d5		;	eor.b	d2,(a0)	; add.w a2,d1
	move.l	#$0150D24A,d6		;	bchg	d0,(a0)	; add.w a2,d1
	move.l	#$B118D24A,a6		;	eor.b	d0,(a0)	; add.w a2,d1

	move.w	#$6404,a1			;	bcc.s	*+6
	move.l	#$41E8FF60,d0		;	add.w	#x,a0
	move.w	d7,d0				;	
	move.l	#$B1105E48,a5		;	

	move.l	#lineloopsize-1,d7
.loop
		move.l	a2,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d1,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	a6,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+
;;;;
		move.l	a2,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d1,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	a5,(a0)+
		move.w	d1,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

	dbra	d7,.loop
	rts



;	d6	eor		pixel 10000000	
;	d7	eor		pixel 01000000
;	d4	eor 	pixel 00100000
;	d2	bchg	pixel 00010000	bit 4
;	d5	eor		pixel 00001000
;	d2	eor		pixel 00000100
;	d0	bchg	pixel 00000010	bit 1
;	d0	eor		pixel 00000001

; this does the basic line generation with 160 and -160 offset on overflow, but has MAJOR dy/dx
;	eor.b 	reg,(a0)		;12				
;	add.w	a1,a0			;8
;	add.w	a2,d1			;4
;	bcc.s	*+6				;8/12
;	lea		160(a0),a0		;8

; optimized; -> needs 2 more registers
;	move.l	d7,a0			;4
;	eor.b	reg,(a0)		;12
;	add.w	a1,d7			;4
;	add.w	a2,d1			;4
;	bcc.s	*+6				;8/12
;	add.w	reg,d7			;4

generateLineCode_1BPL_yes_integer_slope
	move.l	#$BD10D0C9,a2		;	eor.b	d6,(a0) 	;	add.w 	a1,a0	
	move.l	#$BF10D0C9,d1		;	eor.b	d7,(a0)		; 	add.w 	a1,a0
	move.l	#$B910D0C9,d2		;	eor.b	d4,(a0) 	; 	add.w	a1,a0
	move.l	#$0550D0C9,d3		;	bchg	d2,(a0)		; 	add.w	a1,a0
	move.l	#$BB10D0C9,d4		;	eor.b	d5,(a0)		; 	add.w	a1,a0
	move.l	#$B510D0C9,d5		;	eor.b	d2,(a0)		; 	add.w	a1,a0
	move.l	#$0150D0C9,d6		;	bchg	d0,(a0)		; 	add.w	a1,a0
	move.l	#$B118D0C9,a6		;	eor.b	d0,(a0)+	; 	add.w	a1,a0
	move.l	#$D24A6404,a1		;	add.w	a2,d1		; 	bcc.s 	*+6
	move.l	#$41E8FF60,d0		;	lea		x(a0),a0
	move.w	d7,d0				;	x
	move.l	#$B1105E48,a5		;	eor.b	d0,(a0)		;	addq.w	#7,a0

	move.l	#lineloopsize-1,d7
.loop
		move.l	a2,(a0)+	
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d1,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	a6,(a0)+		; +1 screen address
		move.l	a1,(a0)+
		move.l	d0,(a0)+
;;;;;
		move.l	a2,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d1,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+	

		move.l	a5,(a0)+
		move.w	d1,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

	dbra	d7,.loop
	rts


; this rout generates 3 bitplane linedrawing
;	- no integer part for the y-increase
;
; a0: generated code pointer
; a5; offset for 2nd bitplane to color
; 
; d7: y-offset increase/decrease

generateLineCode_3BPL_no_integer_slope
;	move.l	\1,a0
	move.l	#$BD10BD28,a2		; eor.b	d6,(a0)	eor.b,d6,x(a0)
	move.l	#$BF10BF28,d1		; eor.b	d7,x(a0)
	move.l	#$B910B928,d2		; eor.b	d4,x(a0)
	move.l	#$05500568,d3		; bchg	d2,x(a0)
	move.l	#$BB10BB28,d4		; eor.b	d5,x(a0)
	move.l	#$B510B528,d5		; eor.b	d2,x(a0)
	move.l	#$01500168,d6		; eor.b	d2,x(a0)
	move.l	#$B118B128,a6		; eor.b	d0,1(a0)				b118 = eor.b	d0,(a0)+	b128 = eor.b	d0,x(a0)		
	move.l	#$B110B128,a3		; eor.b d0,2(a0)				

	move.l	#$D24A6404,a1		; add.w	a2,d1
;	move.w	#$6404,a4			; bcc +4
	move.l	#$41E8FF60,d0		; lea	x(a0),a0
	move.w	d7,d0

	move.l	#lineloopsize-1,d7
.loop
		move.l	a2,(a0)+		;20	
		move.w	a5,(a0)+
		move.w	a2,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+		

		move.l	d1,(a0)+		
		move.w	a5,(a0)+
		move.w	d1,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+		
		move.w	a5,(a0)+
		move.w	d2,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+		
		move.w	a5,(a0)+
		move.w	d3,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+		
		move.w	a5,(a0)+
		move.w	d4,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+		
		move.w	a5,(a0)+
		move.w	d5,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+		
		move.w	a5,(a0)+
		move.w	d6,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	a6,(a0)+			; this one does +1 to the screen buffer
		subq.w	#1,a5
		move.w	a5,(a0)+			; so we have -1 here, because we cool
		addq.w	#1,a5
		move.w	a6,(a0)+
		move.w	#3,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+
;;;;
		move.l	a2,(a0)+		
		move.w	a5,(a0)+
		move.w	a2,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d1,(a0)+		
		move.w	a5,(a0)+
		move.w	d1,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+		
		move.w	a5,(a0)+
		move.w	d2,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+		
		move.w	a5,(a0)+
		move.w	d3,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+		
		move.w	a5,(a0)+
		move.w	d4,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+		
		move.w	a5,(a0)+
		move.w	d5,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+		
		move.w	a5,(a0)+
		move.w	d6,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	a3,(a0)+				;	eor.b	d0,(a0) ; eor.b d0,x(a0)
		move.w	a5,(a0)+				;	#2
		move.w	a3,(a0)+
		move.w	#4,(a0)+
		move.w	#$5E48,(a0)+
		move.l	a1,(a0)+		
;		move.w	a4,(a0)+
		move.l	d0,(a0)+
	dbra	d7,.loop
	rts

; this rout generates 3 bitplane linedrawing, where the bitplanes are adjecent
;	- integer part for slope increase
; a0: generated code pointer
; a5: offset to 2nd bitplane
; d7: y-offset increase/decrease
generateLineCode_3BPL_yes_integer_slope
;	eor.l	d0,(a0)				;	20
;	eor.l	d0,2(a0)			;	24
;	eor.l	#$1,2(a0)			;	0AA8 xxxx xxxx offf			;32
;	eor.l	#$1,(a0)			;	0A90 xxxx xxxx				;28
;	bchg	d2,(a0)				;	12
;	bchg	d2,2(a0)			;	16
;	eor.b	d2,(a0)				;	12
;	eor.b	d2,2(a0)			;	16

	;d5	= 4
	;d4 = 6
	;d7 = 7
	;d6 = 8

	; 3 bpl:
	;		12, 16, 16
	;		20, 16

	move.l	#$BD10BD28,a2		;	eor.b	d6,(a0) ; eor.b,d6,x(a0)
	move.l	#$BF10BF28,d1		;	eor.b	d7,(a0)	; eor.b	d7,x(a0)
	move.l	#$B910B928,d2		;	eor.b	d4,(a0) ; eor.b	d4,x(a0)
	move.l	#$05500568,d3		;	bchg	d2,(a0)	; bchg	d2,x(a0)
	move.l	#$BB10BB28,d4		;	eor.b	d5,(a0)	; eor.b	d5,x(a0)
	move.l	#$B510B528,d5		;	eor.b	d2,(a0)	; eor.b	d2,x(a0)
	move.l	#$01500168,d6		;	bchg	d0,(a0)	; eor.b	d2,x(a0)
	move.l	#$B118B128,a6		;	eor.b	d0,(a0)+	; eor.b	d0,1(a0)

	move.l	#$B110B128,a3		;	eor.b	d0,(a0) ; eor.b d0,2(a0)

	move.l	#$D0C9D24A,a1		;	add		a1,a0	;	add.w	a2,d1
	move.w	#$6404,a4			;	bcc.s	*+6
	move.l	#$41E8FF60,d0		;	add.w	#x,a0
	move.w	d7,d0
	move.l	#lineloopsize-1,d7
.loop
		move.l	a2,(a0)+		;	eor.b	d6,(a0)	; eor.b d6,off(a0)	
		move.w	a5,(a0)+		;	off = 2
		move.w	a2,(a0)+		;	eor.b	d6,off(a0)
		move.w	#4,(a0)+		;	off = 4
		move.l	a1,(a0)+		;	add.w	a1,a0  ; add.w	a2,d1
		move.w	a4,(a0)+		;	bcc.s *+6
		move.l	d0,(a0)+		;	add.w	#160,a0

		move.l	d1,(a0)+		
		move.w	a5,(a0)+
		move.w	d1,(a0)+
		move.w	#4,(a0)+		
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+		
		move.w	a5,(a0)+
		move.w	d2,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+		
		move.w	a5,(a0)+
		move.w	d3,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+		
		move.w	a5,(a0)+
		move.w	d4,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+		
		move.w	a5,(a0)+
		move.w	d5,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+		
		move.w	a5,(a0)+
		move.w	d6,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	a6,(a0)+				; no add
		subq.w	#1,a5	
		move.w	a5,(a0)+				; absolute is the same
		addq.w	#1,a5
		move.w	a6,(a0)+
		move.w	#3,(a0)+				; absolute is the same
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+
;;;;
		move.l	a2,(a0)+		; eor.l	d6,(a0)	; bch	d6,5(a0)		-4 size		8 cycle profit
		move.w	a5,(a0)+		; 
		move.w	a2,(a0)+
		move.w	#4,(a0)+	
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d1,(a0)+		; eor.l	d7,(a0) ; eor.b	d7,5(a0)		-4 size		8 cycle profit
		move.w	a5,(a0)+
		move.w	d1,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+		; eor.l	d4,(a0)	; eor.b	d4,5(a0)		-4 size		8 cycles profit
		move.w	a5,(a0)+		; lea 1(a0),a0
		move.w	d2,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+		; eor.w	#imm,(a0);	16		-4 cycles
		move.w	a5,(a0)+		; eor.l	#imm,x(a0);	32
		move.w	d3,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+		; eor.l	d5,(a0)	; eor.b	
		move.w	a5,(a0)+
		move.w	d4,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+		
		move.w	a5,(a0)+
		move.w	d5,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+		
		move.w	a5,(a0)+
		move.w	d6,(a0)+
		move.w	#4,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	a3,(a0)+				;	eor.b	d0,(a0) ; eor.b d0,x(a0)
		move.w	a5,(a0)+				;	#2
		move.w	a3,(a0)+
		move.w	#4,(a0)+
		move.w	#$5E48,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+
	dbra	d7,.loop
	rts




