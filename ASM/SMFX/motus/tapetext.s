

	IFD DEMOSYSTEM
		IFD	STANDALONE
		ELSE
STANDALONE 					equ 1
		ENDC
	ELSE
STANDALONE					equ 0
	ENDC

	IFEQ STANDALONE
TRUE	equ	0
FALSE	equ 1
true	equ 0
false	equ 1

	ENDC


useblitter					equ 1

optdraw						equ true


number_of_vertices_text			equ 4
sintable_size_tapetext				equ	512*2				; 512 entries of wordsize

; optimizations
OPT_SMC		equ 0
OPT_C2P		equ	0

OPT_A7		equ	1

TT_EFFECT_WIDTH		equ 128
TT_EFFECT_HEIGHT	equ 128

_sinA		equr d1
_cosA		equr d2
_sinB		equr d3
_cosB		equr d4
_sinC		equr d5
_cosC		equr d6

	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	DATA


PREPTAPETEXT	equ 1

	IFEQ	STANDALONE

			include macro.s
			initAndRun	init_effect

init_effect
	IFEQ	PREPTAPETEXT
		jsr		prepTapeText
	ENDC
	jsr		init_demo
	jsr		init_tapetext
	move.w	#300,effect_vbl_counter
	jsr		tapetext_mainloop



init_demo
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	rts

	ENDC

init_tapetext_pointers
	move.l	screen1,d0
;	move.l	d0,screenpointer
	add.l	#$8000,d0
	IFNE	PREPTAPETEXT
	move.l	d0,tapeBufferPointer
	ENDC
	move.l	screen2,d0
;	move.l	d0,screenpointer2
	add.l	#$10000,d0
	move.l	d0,texturepointer
	add.l	#$11000,d0
	move.l	d0,canvasPointer_text
	add.l	#$10000-$1000,d0
	; add the pointers for the moving tape here
;	move.l	tape

	add.l	#$60000,d0
	move.l	d0,divtablepointer
	add.l	#$10000,d0
	move.l	d0,tapePicBufferPointer

	move.w	#$4e75,init_tapetext_pointers
	rts


init_tapetext
	; pointers
	jsr		init_tapetext_pointers
	move.l	screen1,screenpointer
	move.l	screen2,screenpointer2


;	add.l	#$10000,d0
;	move.l	#canvas,canvasPointer_text
	move.w	#$777,timer_b_open_curtain+2


	jsr		initDivTable
	jsr		initDivTable2
	IFNE	PREPTAPETEXT
	lea		tapetextcrk,a0
	move.l	tapeBufferPointer,a1
	jsr		cranker
	ENDC

	IFNE	STANDALONE
	lea		tapecrk,a0
	move.l	tapePicBufferPointer,a1
	jsr		cranker
	ENDC
	
	jsr		planarToChunky_text
	jsr		generateOptimizedTabs
	jsr		clearCanvas_text

;	jsr		makeBorder
	move.w	#0,vblcount

		move.l	screen1,a0
		move.l	screen2,a1
		add.l	#200*160,a0
		add.l	#200*160,a1
		move.w	#40-1,d7
		moveq	#0,d0
.ll
		REPT 40
			move.l	d0,(a0)+
			move.l	d0,(a1)+
		ENDR
		dbra	d7,.ll

;	movem.l	tapeTextPal+7*32+2,d0-d7
;	movem.l	tapetext+4,d0-d7
;	movem.l	d0-d6,$ffff8242
;	swap	d7
;	move.w	d7,$ffff8240+15*2

	; init div table
;	jsr		initDivTable

	; init music

	move.w	#0,_currentStepX
	move.w	#0,_currentStepY
	move.w	#0,_currentStepZ

;	move.w	#$777,$ffff8240+15*2

	move.w	#TAPETEXT_INTRO_DELAY_VBL,d7
.www		
			wait_for_vbl
		dbra	d7,.www


	move.w	#$2700,sr
	move.l	#tapetext_vbl,$70
	move.w	#$2300,sr
	rts

;genXOR
;	moveq	#0,d1
;;	lea		texture,a0
;	move.l	texturepointer,a0
;	move.l	a0,a1
;	move.w	#256-1,d7				;y 256 height
;	move.w	#$f,d4
;.oloop
;		move.w	#256-1,d6			;x 256 width
;		moveq	#0,d0				;x
;.iloop
;			move.w	d0,d5
;			eor.w	d1,d5
;			IFEQ	OPT_C2P
;				lsl.w	#3,d5
;				addq.w	#6,d5
;			ELSE
;				lsl.w	#2,d5
;			ENDC
;			move.b	d5,(a0)+
;			addq.w	#1,d0
;			and.w	d4,d0
;		dbra	d6,.iloop
;	addq.w	#1,d1
;	and.w	d4,d1
;	dbra	d7,.oloop
;
;	move.w	#16-1,d7
;	move.l	#$06060606,d0
;.l
;	REPT 256
;		move.l	d0,(a0)+
;		move.l	d0,-(a1)
;	ENDR
;	dbra	d7,.l
;
;
;	rts

;makeBorder
;
;	move.l	screenpointer2,a0
;	move.l	screenpointer,a1
;	move.w	#200-1,d7
;	moveq	#-1,d0
;.ol
;	move.w	#20-1,d6
;.il
;		move.l	d0,(a0)+
;		move.l	d0,(a0)+
;		move.l	d0,(a1)+
;		move.l	d0,(a1)+
;		dbra	d6,.il
;	dbra	d7,.ol
;	rts

tapetext_mainloop
	move.w	#0,$466.w
.mainloop
	tst.w	$466.w
	beq		.mainloop
		move.w	#0,$466.w
		addq.w	#1,effectcount

;		move.w	#$030,$ffff8240
		jsr		clearCanvas_text
;		move.w	#$300,$ffff8240
		jsr		calculateRotatedProjection
;		move.w	#$003,$ffff8240
		lea		trianglePointers,a0
		jsr		drawTriangle2

;		lea		trianglePointers+12,a0
		jsr		drawTriangle2
;		move.w	#$500,$ffff8240
		jsr		c2p_2to4_optimized
;		move.w	#$050,$ffff8240
		jsr		copyLines
;		move.w	#$005,$ffff8240

		move.l	screenpointer2,a0
		add.w	#112,a0
		moveq	#0,d0
;		move.w	#-1,d0
;		swap	d0
		REPT 7
			move.l	d0,-(a0)
			move.l	d0,-(a0)
		ENDR

		move.l	screenpointer2,$ffff8200

		move.l	screenpointer2,d0
		move.l	screenpointer,screenpointer2
		move.l	d0,screenpointer
;		move.w	#$300,$ffff8240


		cmp.w	#119,vblcount
		ble		.kkk
			rts
			moveq	#0,d0
			moveq	#0,d1
			move.w	vblcount,d0
			move.w	effectcount,d1
			jmp		tapetext_mainloop2
;			move.b	#0,$ffffc123
.kkk
	tst.w	leaveTapeText
	bne		.end
		jmp		.mainloop
.end
	rts


tapetext_mainloop2
	move.w	#$0,466.w
.mainloop
	tst.w	$466.w
	beq		.mainloop
		move.w	#0,$466.w
		addq.w	#1,effectcount
;		move.w	#-1,doCopyTape

	tst.w	leaveTapeText
	bne		.end
		jmp		.mainloop
.end
	rts

doCopyTape	dc.w	0


tapetext_vbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	addq.w	#1,vblcount
	move.w	#0,$ffff8240


;	clr.b	$fffffa1b.w			;Timer B control (stop)
;	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
;	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
;	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
;	move.l	#timer_b_open_curtain,$120.w
;	bclr	#3,$fffffa17.w			;Automatic end of interrupt
;	move.b	#8,$fffffa1b.w	


		;Start up Timer B each VBL
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_stable,$120.w
		move.b	#191,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt

	subq.w	#1,.fadeC
	bge		.nof
		pushall
		move.w	#5,.fadeC
		sub.w	#32,tapeTextPalOff
		bge		.kkkk
			move.w	#0,tapeTextPalOff
.kkkk
		lea		tapeTextPal,a0
		add.w	tapeTextPalOff,a0	
		movem.l	2(a0),d0-d7
		movem.l	d0-d6,$ffff8240+2
		swap	d7
		move.w	d7,$ffff8240+15*2
		popall
.nof


	subq.w	#1,effect_vbl_counter
	bge		.kkk
		move.w	#-1,leaveTapeText
.kkk
	tst.w	doCopyTape
	beq		.nocopy
		IFNE	STANDALONE
;		move.b	#0,$ffffc123
		move.l	screenpointer,$ffff8200
		swapscreens
		subq.w	#1,.doIt
		blt		.skip
			move.l	screenpointer,a0
			jsr		copyTape
			movem.l	tapePal+2,d0-d7
			movem.l	d0-d6,$ffff8240+2*1
			swap	d7
			move.w	d7,$ffff8240+2*15
.skip
		ENDC
.nocopy
	IFNE	STANDALONE
			pushall
	    jsr	musicPlayer+8
	    	popall
	ENDC
	rte
.fadeC	dc.w	2
.doIt	dc.w	2
leaveTapeText	dc.w	0

	IFEQ	STANDALONE
timer_b_open_curtain
	move.w	#$111,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#199,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_close_curtain
	move.w	#$0,$ffff8240
	rte



timer_b_open_curtain_stable
		movem.l	d1-d2/a0,-(sp)
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
	
		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		dcb.w	59-6,$4e71

		move.w	#$777,$ffff8240.w


		movem.l	(sp)+,d1-d2/a0
		move.l	#timer_b_close_curtain_stable,$120.w
		move.b	#198,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte

timer_b_close_curtain_stable:	
		move.w	#$2700,sr
		movem.l	d0/a0,-(sp)

		moveq	#96,d0				;Hardsync with branch offset
		lea	$ffff8209.w,a0
.sync:		cmp.b	(a0),d0
		beq.s	.sync
		move.b	(a0),d0
		move.w	d0,.jump+2			;SMC bra.w below
.jump:		bra.w	timer_b_open_curtain_stable

.wait:		dcb.w	134,$4e71 

		move.w	#$000,$ffff8240.w

		movem.l	(sp)+,d0/a0
		rte

	ENDC


effectcount	dc.w	0

;256 by 256 texture
; 16*8 = 128

planarToChunky_text
;	lea		tapetext+128,a0
	move.l	tapeBufferPointer,a0
;	lea		tapeTextBuffer,a0
	move.l	texturepointer,a1

	move.l	a1,a2

	move.l	#128-1,d6
	move.l	#$06060606,a3
;	REPT 128*3
;		move.l	a3,-(a2)
;	ENDR
.height
	move.l	#8-1,d7
.width
	movem.w	(a0)+,d0-d3		; 4 words
	REPT 16
		moveq	#0,d4
		moveq	#0,d5
		roxl.w	d5
		roxl.w	d3
		roxl.w	d4
		roxl.w	d2
		roxl.w	d4
		roxl.w	d1
		roxl.w	d4
		roxl.w	d0
		roxl.w	d4
		lsl.w	#3,d4
		addq.w	#6,d4
		move.b	d4,(a1)+					; 128 * 8 * 16 = 16k
	ENDR
	dbra	d7,.width

	REPT 32
		move.l	a3,(a1)+
		move.l	a3,-(a2)
	ENDR


	; 320 width is 160 bytes
	; 128 width is 64 bytes 
	; 160-64 added
;	add.w	#160-64,a0
	dbra	d6,.height						; 128 * ( 32*4 + 8*16 ) = 128 * (128+128) = 32768

	; 16384*3 left

;	move.w	#64*3-1,d7
;.llll
;		REPT 64
;			move.l	a3,(a1)+
;		ENDR
;	dbra	d7,.llll
	rts






canvaswidth	equ 128

clearCanvas_text
	move.l	#$06060606,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
;SPACESAVE
;	lea		canvas,a6
	move.l	canvasPointer_text,a6
	; 128 x 128 bytes	= 16384			;d0-a5 = 14*4 = 56 = 16352
.off set 0
	REPT 292
	movem.l	d0-a5,.off(a6)
.off set .off+14*4
	ENDR
	;32 left
	movem.l	d0-d7,.off(a6)
	rts




;void DrawTextureTriangle(vertex * vtx, char * bitmap)
;    vertex * v1 = vtx;
;    vertex * v2 = vtx+1;
;    vertex * v3 = vtx+2;
;	// sort stuff
;    if(v1->y > v2->y) { vertex * v = v1; v1 = v2; v2 = v; }
;    if(v1->y > v3->y) { vertex * v = v1; v1 = v3; v3 = v; }
;    if(v2->y > v3->y) { vertex * v = v2; v2 = v3; v3 = v; }
;    // We start out by calculating the length of the longest scanline.
;    int height = v3->y - v1->y;
;    int temp = ((v2->y - v1->y) << 16) / height;
;    int longest = temp * (v3->x - v1->x) + ((v1->x - v2->x) << 16);
;    if(longest == 0)
;        return;
;
;    // Now that we have the length of the longest scanline we can use that 
;    // to tell us which is left and which is the right side of the triangle.
;
;    if(longest < 0)
;    {
;        // If longest is neg. we have the middle vertex on the right side.
;        // Store the pointers for the right and left edge of the triangle.
;        right_array[0] = v3;
;        right_array[1] = v2;
;        right_array[2] = v1;
;        right_section  = 2;
;        left_array[0]  = v3;
;        left_array[1]  = v1;
;        left_section   = 1;
;
;        // Calculate initial left and right parameters
;        if(LeftSection() <= 0)
;            return;
;        if(RightSection() <= 0)
;        {
;            // The first right section had zero height. Use the next section. 
;            right_section--;
;            if(RightSection() <= 0)
;                return;
;        }
;
;        // Ugly compensation so that the dudx,dvdx divides won't overflow
;        // if the longest scanline is very short.
;        if(longest > -0x1000)
;            longest = -0x1000;     
;    }
;    else
;    {
;        // If longest is pos. we have the middle vertex on the left side.
;        // Store the pointers for the left and right edge of the triangle.
;        left_array[0]  = v3;
;        left_array[1]  = v2;
;        left_array[2]  = v1;
;        left_section   = 2;
;        right_array[0] = v3;
;        right_array[1] = v1;
;        right_section  = 1;
;
;        // Calculate initial right and left parameters
;        if(RightSection() <= 0)
;            return;
;        if(LeftSection() <= 0)
;        {
;            // The first left section had zero height. Use the next section.
;            left_section--;
;            if(LeftSection() <= 0)
;                return;
;        }
;
;        // Ugly compensation so that the dudx,dvdx divides won't overflow
;        // if the longest scanline is very short.
;        if(longest < 0x1000)
;            longest = 0x1000;     
;    }
;
;    // Now we calculate the constant deltas for u and v (dudx, dvdx)
;
;    int dudx = shl10idiv(temp*(v3->u - v1->u)+((v1->u - v2->u)<<16),longest);
;    int dvdx = shl10idiv(temp*(v3->v - v1->v)+((v1->v - v2->v)<<16),longest);
;
;    char * destptr = (char *) (v1->y * 320 + 0xa0000);
;
;    // If you are using a table lookup inner loop you should setup the
;    // lookup table here.
;
;    // Here starts the outer loop (for each scanline)
;
;    for(;;)         
;    {
;        int x1 = left_x >> 16;
;        int width = (right_x >> 16) - x1;
;
;        if(width > 0)
;        {
;            // This is the inner loop setup and the actual inner loop.
;            // If you keep everything else in C that's up to you but at 
;            // least remove this inner loop in C and insert some of 
;            // the Assembly versions.
;
;            char * dest = destptr + x1;
;            int u  = left_u >> 8;
;            int v  = left_v >> 8;
;            int du = dudx   >> 8;            
;            int dv = dvdx   >> 8;
;
;            // Watcom C/C++ 10.0 can't get this inner loop any tighter 
;            // than about 10-12 clock ticks.
;
;            do
;            {
;                *dest++ = bitmap[ (v & 0xff00) + ((u & 0xff00) >> 8) ];
;                u += du;
;                v += dv;
;            }
;            while(--width);
;        }
;
;        destptr += 320;
;
;        // Interpolate along the left edge of the triangle
;        if(--left_section_height <= 0)  // At the bottom of this section?
;        {
;            if(--left_section <= 0)     // All sections done?
;                return;
;            if(LeftSection() <= 0)      // Nope, do the last section
;                return;
;        }
;        else
;        {
;            left_x += delta_left_x;
;            left_u += delta_left_u;
;            left_v += delta_left_v;
;        }
;
;        // Interpolate along the right edge of the triangle
;        if(--right_section_height <= 0) // At the bottom of this section?
;        {
;            if(--right_section <= 0)    // All sections done?
;                return;
;            if(RightSection() <= 0)     // Nope, do the last section
;                return;
;        }
;        else
;        {
;            right_x += delta_right_x;
;        }
;    }
;}

equal equ 0											;					   .	10,30
right equ 0											;
													;
													;
currentVertices_tape	
				dc.w	-40*4,-25*4,0				;  2.................1
				dc.w	41*4,-25*4,0				;	 .....
				dc.w	-40*4,26*4,0					;		  .....     .
													;			   ......3

				dc.w	41*4,26*4,0				;	2...
													;	.  ......        
													;	.        .......
													;  4.................3

;point1	dc.w	22*2,2*2,22*2<<7,2*2<<7
;point2	dc.w	2*2,2*2,2*2<<7,2*2<<7
;point3	dc.w	22*2,22*2,22*2<<7,22*2<<7


point1_t	dc.w	54,4,4<<7,55<<7
point2_t	dc.w	4,4,85<<7,55<<7
point3_t	dc.w	64,54,4<<7,4<<7
point4_t	dc.w	4,54,85<<7,4<<7

;
;;50,0
;;10,5
;;40,45
;
;
;	IFEQ	equal
;		IFEQ	right
;point1	dc.w	60,05,65<<7,15<<7
;point2	dc.w	05,05,15<<7,15<<7
;point3	dc.w	40,50,50<<7,65<<7
;
;		ELSE
;point1	dc.w	10,05,10<<7,05<<7
;point2	dc.w	50,05,50<<7,05<<7
;point3	dc.w	40,50,40<<7,50<<7
;		ENDC
;
;	ELSE
;		IFEQ	right
;				;Px	 ,Py	,Tx	  ,Ty
;point1	dc.w	10,50,10<<7,50<<7
;point2	dc.w	50,40,50<<7,40<<7
;point3	dc.w	30,05,30<<7,05<<7
;		ELSE
;point1	dc.w	10,10,10,10
;point2	dc.w	10,40,10,40
;point3	dc.w	60,60,60,60
;		ENDC
;	ENDC
trianglePointers	dc.l	point3_t,point2_t,point1_t		; --> proper order top-> bot = p3,p2,p1
					dc.l	point2_t,point3_t,point4_t		; --> proper order top-> bot = p3,p2,p1


;y_factor	dc.l	0
;x_factor	dc.l	0
y1_y3		dc.w	0
y1_y2		dc.w	0
y2_y3		dc.w	0


;testtimes	dc.w	400
; optimization 1:	divs/muls gone
; optimization 2: 	innerloop construction smc using addx
; optimization 3:	order of registers, and using them smart
drawTriangle2
	move.l	texturepointer,d6
	move.l	divtablepointer,a5			;20
	move.l	a5,usp	
	movem.l	(a0)+,a1-a3					;36		;a1,a2,a3							; get points
	move.l	a0,-(sp)
;;;;;;;;;;; sort points 	; determine order
	move.w	2(a2),d0					;12
	cmp.w	2(a1),d0					;12
	bge		.point1_lt_point2			;8
		exg		a1,a2					;8		*3
.point1_lt_point2
	move.w	2(a3),d0					
	cmp.w	2(a1),d0					
	bge		.point1_lt_point3
		exg		a1,a3
.point1_lt_point3
	move.w	2(a3),d0
	cmp.w	2(a2),d0
	bge		.point2_lt_point3
		exg		a2,a3
.point2_lt_point3
;;;;;;;;;;; done sorting
;;;;;;;;;;; determine max span
	; points sorted, top to bottom a1,a2,a3	
;------------------------------------------------------- determine y segments 
	move.w	2(a3),d5					;12		y3									move.w	(a3)+,d5		-4			;$39
	move.w	d5,d7						;4		
	move.w	2(a1),d4					;12		y1									move.w	(a1)+,d4		-4			;$06
	sub.w	d4,d7						;4		y3-y1																	;$33
	beq		.end						;		if 0, then quit
	move.w	d7,y1_y3					;		save
	move.w	2(a2),d2					;12		y2									move.w	(a2)+,d2		-4			;$06
	move.w	d2,d3						;4		
	sub.w	d4,d2						;4		y2-y1
	move.w	d2,y1_y2					;		save
	sub.w	d3,d5						;4		y3-y2
	move.w	d5,y2_y3					;		save																	;$33
;------------------------------------------------------- determine max x span
	move.l	usp,a5

	ext.l	d2							;4
	asl.l	#7,d2						;20		
	or.w	d7,d2						;4
	add.l	d2,d2						;4
	add.l	d2,d2						;4
	move.l	(a5,d2.l),d2				;20											
	asr.l	#8,d2						;24	=> 80		y2-y1 / y3-y1													;0

	move.w	(a1),d0						;8		x1									move.w	(a1)+,d0		0			;$17 = 23
	move.w	(a3),d7						;8		x3									move.w	(a3)+.d7		0			;$68
	sub.w	d0,d7						;4		x3-x1																	;$51

	muls	d2,d7						;56		(x3-x1) * (y2-y1)/(y3-y1)
	asr.l	#8,d7						;24

	add.w	d0,d7						;4		(x3-x1) * (y2-y1)/(y3-y1) + x1
	sub.w	(a2),d7						;8		max span	((x3-x1) * (y2-y1)/(y3-y1)) + x1 - x2		sub.w	(a2)+,d7
	bne		.nozeromaxwidth
		move.w	#1,d7
.nozeromaxwidth
;------------------------------------------------------- determine uv stepping
	move.w	4(a1),d1					;12		u1									move.w	(a1)+,d1		-4
	move.w	4(a3),d0					;12		u3									move.w	(a3)+,d0		-4
	sub.w	d1,d0						;4		u3-u1
	add.w	d0,d0						;4
	muls	d2,d0						;56		((u3-u1) * (y2-y1)/(y3-y1)) 

	sub.w	4(a2),d1					;12		u1-u2								move.w	(a2)+,d1		-4
	asr.w	#7,d1						;20
	swap	d1							;4
	sub.w	d1,d1						;4

	add.l	d1,d0						;8		((u3-u1) * (y2-y1)/(y3-y1)) + (u1-u2)

	lea		divTablePivot,a4			;8
	add.w	d7,d7						;4
	move.w	(a4,d7.w),d6				;20		1/width
	swap	d0							;4
	muls	d6,d0						;56		8   ( (u3-u1) * (y2-y1)/(y3-y1)) + (u1-u2) / width

	move.w	6(a1),d4					;12		v1									move.w	(a1),d4			-4	
	move.w	6(a3),d1					;12		v3									move.w	(a3),d1			-4
	sub.w	d4,d1						;4		v3-v1
	add.w	d1,d1						;4		
	muls	d2,d1						;56		(v3-v1) * (y2-y1)/(y3-y1)

	sub.w	6(a2),d4					;12		v1-v2								sub.w	(a2),d4			-4
	asr.w	#7,d4						;20	

	swap	d1							;4
	add.w	d4,d1						;4		(((v3-v1) * (y2-y1)/(y3-y1)) + (v1-v2)) / width

	muls	d6,d1						;56
	asr.l	#7,d1						;20
;--------------------------------------------------------- smc unrolled innerloop code with stepping offsets
	IFEQ	OPT_SMC
		add.l	d0,d0					;8		to correct from the <<7 from the 1/x muls
		swap	d0						;
		sub.w	d5,d5
	ELSE
		add.l	d0,d0
		swap	d1
	ENDC

	move.l	d0,d2		; local du
	move.l	d1,d3		; local dv
	moveq	#0,d4

	IFEQ	OPT_SMC		; 8 or 16 bit precision for x?
smcLoopSize	equ -14
	ELSE
smcLoopSize	equ -18
	ENDC

	move.w	d7,d6
	bge		.noneg
		neg.w	d6
.noneg
;	muls	#smcLoopSize,d6
	move.w	d6,a6	
	asl.w	#3,d6
	IFEQ	OPT_SMC
		sub.w	a6,d6
	ELSE
		add.w	a6,d6
	ENDC
	neg.w	d6
.kkk
	lea		.doSMCLoopEnd+2*smcLoopSize,a6	; 2 more than needed, because this way we prevent reading outside the texture, hax...
	lea		myTable2+2+127*4,a4				; first load the end of the canvas table
	sub.w	2(a6,d6.w),a4					; then we rectify the table offset
	jmp		(a6,d6.w)						; and we need to load the proper address to a4, combined with the offset of the width span

.doSMCLoop
.offset set 0								; offset into the unrolled loop of 		move.b textoff(a0),-(a1)
	REPT 128
		IFEQ	OPT_SMC
			move.w	d4,.offset(a4)			;12
			move.w	d3,d4					;4			; 0.16 -> 0. 8.8 dv.du	
			move.b	d2,d4					;4			; 0.16 -> 0. 8.8 
			add.l	d0,d2		;8....8		;8
			addx.b	d5,d2					;4
			add.w	d1,d3		;... 8.8	;4
		ELSE								;---> 36
			move.w	d4,.offset(a4)			;12	4	smc the offset into the writing to canvas code
			move.l	d3,d4					;4	2	local dv
			swap	d4						;4	2	int lower word
			swap	d2						;4	2	local du
			move.b	d2,d4					;4	2	move du in so that VVVV UUUU
			swap	d2						;4	2	swap back
			add.l	d0,d2					;8	2	increment							; if xxxx ---- ---- XXXX, then add.l	d0,d2  add.x DX,d2	move.b	d2,d4
			add.l	d1,d3					;8	2	increment
		ENDC								;---> 48
.offset set .offset-4						
	ENDR
.doSMCLoopEnd
;--------------------------------------------------------- time to draw triangles
;	lea		canvas,a6						;8 		load canvas
	move.l	canvasPointer_text,a6
	move.w	2(a1),d0						;8		get top y							move.w	-6(a1),d0
	asl.w	#7,d0							;18		canvas *128
	add.w	d0,a6							;8		add y offset to canvas
	tst.w	d7								;4		d7 is still span, but negative and positive determine where the 2nd point is
	blt		.middleRight
.middleLeft
	move.w	y1_y2,d0		; y1_y2
	beq		.two_top_left		; if 0 ==> then p1 and p2 top
.first_slice_p1_p2_middle_left
		move.l	a2,-(sp)					;16		save a2
		move.l	a3,-(sp)					;16		save a3
		move.w	(a1),d1						;8		startx								move.w	-6(a1),d1			+4
		move.w	(a3),d7						;8 		x3									move.w	-6(a3),d7			+4

		move.w	4(a1),d5					;12		u1 global							move.w	-2(a1),d5			0
		move.w	4(a2),d2					;12		u2 									move.w	-2(a2),d2			0
		sub.w	d5,d2						;4		u2-u1
		ext.l	d2
		or.w	d0,d2						;4						
		add.w	d2,d2						;4
		add.w	d2,d2						;4		
		move.l	(a5,d2.l),a3				;20		a3 = du/dy	u2-u1 / y2-y1

		move.w	6(a1),d4					;12		v1 global							move.w	(a1),d4				-4
		move.w	6(a2),d2					;12		v2									move.w	(a2),d2				-4
		sub.w	d4,d2						;4		v2-v1
		ext.l	d2
		or.w	d0,d2						;4
		add.w	d2,d2						;4
		add.w	d2,d2						;4
		move.l	(a5,d2.l),d2				;20		v2-v1 / y2-y1
		asr.l	#8,d2						;24		>>8
		move.w	d2,a4						;4		a4 = dv/dy	

		asr.w	#7,d5						;20		>>7
		swap	d5							;4
		sub.w	d5,d5						;4		u1 global 16.16 format

		move.w	(a2),d3						;8		x2									move.w	-6(a2),d4			+4
		sub.w	d1,d3						;4 		x2-x1
		ext.l	d3
		asl.l	#7,d3						;20		>>7
		or.w	d0,d3						;4
		add.l	d3,d3						;4
		add.l	d3,d3						;4
		move.l	(a5,d3.l),a1				;20		a1 = dx/dy left	x2-x1 / y2-y1 

		sub.w	d1,d7						;4		x3-x1
		ext.l	d7
		asl.l	#7,d7						;20		>> 7
		or.w	y1_y3(pc),d7				;16		
		add.l	d7,d7						;4
		add.l	d7,d7						;4
		move.l	(a5,d7.l),a5				;20		a5 = dx/dy right x3-x1 / y3-y1

		add.w	d4,d4						;4
		swap	d1							;4
		sub.w	d1,d1						;4
		move.l	d1,d2						;4

		subq.w	#1,d0						;4			94 nop

		jsr		drawHLine2
		; d0, loopvar					
		; d1, x_start
		; d2, x_end
		; d3, x_end LOCAL
		; d4, dv_global
		; d5, du_global
		; d6, texture_aligned_pointer
		; d7, addx
		; a0, texture
		; a1, dx_left
		; a2, --
		; a3, du/dy
		; a4, dv/dy
		; a5, dx_right
		; a6, canvas
		move.l	(sp)+,a3					;12
		move.l	(sp)+,a2					;12
.second_slice_p2_p3_middle_left
; p3.y - p2.y
		move.w	y2_y3,d0					;12		y3-y2				height
		move.l	usp,a4
; sx
		move.w	(a2),d1						;8		x2 set x_start							move.w	-6(a2),d1			+4	
		move.w	(a3),d3						;8		x3										move.w	-6(a3),d3			+4
		sub.w	d1,d3						;4		x3-x2
		ext.l	d3
		asl.l	#7,d3						;20
		or.w	d0,d3						;4
		add.l	d3,d3						;4
		add.l	d3,d3						;4
		move.l	(a4,d3.l),a1				;20		a1 = x3-x2 / y3-y2
; dv global
		move.w	6(a2),d4					;12		v2										move.w	(a2),d4				-4
		move.w	6(a3),d3					;12		v3										move.w	(a3),d3				-4
		sub.w	d4,d3						;4		v3-v2
		ext.l	d3
		or.w	d0,d3						;4
		add.w	d3,d3						;4
		add.w	d3,d3						;4
		move.l	(a4,d3.l),d3				;20		v3-v2  / y3-y2
		asr.l	#8,d3						;24
;; du/dy
		move.w	4(a2),d5					;12		u2										move.w	-2(a2),d5			0
		move.w	4(a3),d7					;12		u3										move.w	-2(a3),d7			0
		sub.w	d5,d7 						;4		u3-u2
		ext.l	d7
		or.w	d0,d7						;4
		add.w	d7,d7						;4
		add.w	d7,d7						;4
		move.l	(a4,d7.l),a3				;20		a3 = u3-u2 / y3-y2

		asr.w	#7,d5						;20
		swap	d5							;4
		sub.w	d5,d5						;4

		move.w	d3,a4						;4		a4 = v3-v2 / y3-y2

		swap	d1							;4
		sub.w	d1,d1						;4
		add.w	d4,d4						;4

		jsr		drawHLine2
		; d0, loopvar					
		; d1, x_start
		; d2, x_end
		; d3, x_end LOCAL
		; d4, dv_global
		; d5, du_global
		; d6, texture_aligned_pointer
		; d7, addx
		; a0, texture
		; a1, dx_left
		; a2, --
		; a3, du/dy
		; a4, dv/dy
		; a5, dx_right
		; a6, canvas
		move.l	(sp)+,a0					;12
		rts
.two_top_left
; 2 ---------- 1
;   \        /
;    \.     / 
;     \.   /
;      \. /
;       \/
;       3
	move.w	(a2),d1							;8		x2 startx
	move.w	(a1),d2							;8		x1 endx

	move.w	(a3),d3							;8		x3 xleft
	move.w	d3,d7							;4		x3 xright

	move.w	y2_y3,d0						;16		y3-y2. height

	sub.w	d1,d3							;4		x3-x1
	ext.l	d3
	asl.l	#7,d3							;20
	or.w	d0,d3							;4
	add.l	d3,d3							;4
	add.l	d3,d3							;4
	move.l	(a5,d3.l),a1					;20		a1 = x3-x1 / y3-y2 dx/dy left

	sub.w	d2,d7							;4
	ext.l	d7
	asl.l	#7,d7							;20
	or.w	d0,d7							;4
	add.l	d7,d7							;4
	add.l	d7,d7							;4

	move.w	6(a2),d4						;12		v2
	move.w	6(a3),d3						;12		v3
	sub.w	d4,d3							;4		v3-v2
	ext.l	d3
	or.w	d0,d3							;4
	add.w	d3,d3							;4
	add.w	d3,d3							;4
	move.l	(a5,d3.l),d3					;20		v3-v2 / y3-y2
	asr.l	#8,d3							;24 		<< 8
	move.l	d3,a4							;4		a4 = dv/dy

	move.w	4(a2),d5						;12		u2
	move.w	4(a3),d3						;12		u3
	sub.w	d5,d3							;4		u3-u2
	ext.l	d3
	or.w	d0,d3							;4
	add.w	d3,d3							;4
	add.w	d3,d3							;4
	move.l	(a5,d3.l),a3					;20		a3 = u3-u2 / y3-y2

	add.w	d4,d4							;4
	asr.w	#7,d5							;20	
	swap	d5								;4
	sub.w	d5,d5							;4
	move.l	(a5,d7.l),a5					;20		a5 = dx/dy right

	subq.w	#1,d0							;4
	swap	d1								;4
	swap	d2								;4
	sub.w	d1,d1							;4
	sub.w	d2,d2							;4

	jsr		drawHLine2
	move.l	(sp)+,a0	
	; d0, loopvar					
	; d1, x_start
	; d2, x_end
	; d3, x_end LOCAL
	; d4, dv_global
	; d5, du_global
	; d6, texture_aligned_pointer
	; d7, addx
	; a0, texture
	; a1, dx_left
	; a2, --
	; a3, du/dy
	; a4, dv/dy
	; a5, dx_right
	; a6, screen	move.l	(sp)+,a0
	rts
.middleRight
	move.w	y1_y2,d0						;16		y1_y2
	beq		.two_top_right					; if 0 ==> then p1 and p2 top
		move.l	a2,-(sp)					;16		save a2
		move.l	a3,-(sp)					;16		save a3

		move.w	y1_y3,d7					;16		height y1_y3												;15
		move.w	(a1),d1						;8		x1, startx
		move.w	(a3),d3						;8		x3

		move.w	6(a1),d4					;12		v1
		move.w	6(a3),d2					;12		v3 p3.v
		sub.w	d4,d2						;4		v3-v1
		ext.l	d2
		or.w	d7,d2						;4
		add.w	d2,d2						;4
		add.w	d2,d2						;4
		move.l	(a5,d2.l),d2				;20		v3-v1 / y3-y1
		asr.l	#8,d2						;24
		move.w	d2,a4						;4
; du/dy
		move.w	4(a1),d5					;12		u1
		move.w	4(a3),d2					;12		u3
		sub.w	d5,d2						;4		u3-u1
		ext.l	d2
		or.w	d7,d2						;4
		add.w	d2,d2						;4
		add.w	d2,d2						;4
		move.l	(a5,d2.l),a3				;20		a3 = u3-u1 / y3-y1

		asr.w	#7,d5						;20
		swap	d5							;4
		sub.w	d5,d5						;4
;	d3 = dx_left / dy
		sub.w	d1,d3						;4		x3-x1
		ext.l	d3
		asl.l	#7,d3						;20
		or.w	d7,d3						;4
		add.l	d3,d3						;4
		add.l	d3,d3						;4
		move.l	(a5,d3.l),a1				;20		a1 = x3-x1 / y3-y1

		move.w	(a2),d2						;8		x2
		sub.w	d1,d2						;4		x2-x1
		ext.l	d2
		asl.l	#7,d2						;20
		or.w	d0,d2						;4
		add.l	d2,d2						;4
		add.l	d2,d2						;4
		move.l	(a5,d2.l),a5				;20		a5 = x2-x1 / y2-y1

		add.w	d4,d4						;4
		subq.w	#1,d0						;4
		swap	d1							;4	
		sub.w	d1,d1						;4
		move.l	d1,d2						;4

		jsr		drawHLine2
		; d0, loopvar					
		; d1, x_start
		; d2, x_end
		; d3, x_end LOCAL
		; d4, dv_global
		; d5, du_global
		; d6, texture_aligned_pointer
		; d7, addx
		; a0, texture
		; a1, dx_left
		; a2, --
		; a3, du/dy
		; a4, dv/dy
		; a5, dx_right
		; a6, screen		
		move.l	a3,d7						;4 		save a3
		move.l	(sp)+,a3					;12
		move.l	(sp)+,a2					;12
.middleRight_sliceTwo		
		move.w	(a2),d2						;8		x2	
		move.w	(a3),d3						;8		x3

		move.l	usp,a5

		move.w	y2_y3,d0					;16		y3-y2
		sub.w	d2,d3						;4		x3-x2 determine new right dx x3-x2
		ext.l	d3
		asl.l	#7,d3						;20
		or.w	d0,d3						;4
		add.l	d3,d3						;4
		add.l	d3,d3						;4
		move.l	(a5,d3.l),a5				;20		a5 = dx/dy right

		swap	d2							;4
		sub.w	d2,d2						;4
		move.l	d7,a3						;4		restore a3
		jsr		drawHLine2
.end
		move.l	(sp)+,a0
	rts
.two_top_right
	move.w	(a1),d1							;8		x1	startx left
	move.w	(a2),d2							;8		x2	endx right
	move.w	(a3),d6							;8		x3	
	move.w	d6,d7							;8		save

	move.w	y1_y3,d0						;16		y3-y1
	sub.w	d1,d6							;4		x3-x1

	asl.w	#7,d6							;20
	or.w	d0,d6							;4
;	add.l	d6,d6							;4
;	add.l	d6,d6							;4

	sub.w	d2,d7							;4		x3-x2
	ext.l	d7
	asl.l	#7,d7							;20
	or.w	d0,d7							;4
	add.l	d7,d7							;4
	add.l	d7,d7							;4

	move.w	6(a1),d4						;12 	v1



	move.w	6(a3),d3						;12		v3
	sub.w	d4,d3							;4		v3-v1
	ext.l	d3
	or.w	d0,d3							;4
	add.w	d3,d3							;4
	add.w	d3,d3							;4
	move.l	(a5,d3.l),d3					;20
	asr.l	#8,d3							;24
	move.l	d3,a4							;4		a4 = dv/dy

	add.w	d4,d4							;4

	move.w	4(a1),d5						;12		u1
	move.w	4(a3),d3						;12		u3
	sub.w	d5,d3							;4		u3-u1
	ext.l	d3
	or.w	d0,d3							;4
	add.w	d3,d3							;4
	add.w	d3,d3							;4	
	move.l	(a5,d3.l),a3					;20		a3 = du/dy

	asr.w	#7,d5							;20
	swap	d5								;4
	sub.w	d5,d5		

	move.w	d6,a1
	add.l	a1,a1
	add.l	a1,a1

						;4
	move.l	(a5,a1.l),a1					;20		a1 = dx/dy	left
	move.l	(a5,d7.l),a5					;20		a5 = dx/dy	right

	subq.w	#1,d0							;4
	swap	d1								;4
	swap	d2								;4
	sub.w	d1,d1							;4
	sub.w	d2,d2							;4

	jsr		drawHLine2
	move.l	(sp)+,a0
	; d0, loopvar					
	; d1, x_start
	; d2, x_end
	; d3, x_end LOCAL
	; d4, dv_global
	; d5, du_global
	; d6, texture_aligned_pointer
	; d7, addx
	; a0, texture
	; a1, dx_left
	; a2, --
	; a3, du/dy
	; a4, dv/dy
	; a5, dx_right
	; a6, screen	
	rts



;x_start			equr	d1
;x_end_global		equr	d2
;x_end_local		equr	d3
;dv_global			equr	d4
;du_global			equr	d5
;txtp				equr	d6
;
;txtr				equr	a0
;dx_l				equr	a1
;du_dy				equr	a3
;dv_dy				equr	a4
;dx_r				equr	a5
;cvs				equr	a6

drawHLine2
	move.l	a6,d7
	lea		myTable2+127*4,a2
loop
		move.w	d4,d6						;4		; dv local
		swap	d5							;4		
		move.b	d5,d6						;4		; du local
		swap	d5							;4

		move.l	d7,a6						;4		canvas
		swap	d2							;4												
		move.l	d1,d3						;4		; x_start local							
		swap	d3							;4
		sub.w	d2,d3						;4		; x_start - x_end
		add.w	d2,a6						;8		
		swap	d2							;4												

		move.l	d6,a0						;4		; texture pointer
		add.w	d3,d3						;4		; 
		add.w	d3,d3						;4		; 	
		jmp		(a2,d3.w)					;16
myTable2
		REPT 128
			move.b $1(a0),-(a6)
		ENDR
		add.w	#canvaswidth,d7				;8		
		add.l	a1,d1						;8		; 16.16 dx_left	
		add.l	a5,d2						;8		; 16.16 dx_right
		add.w	a4,d4						;4		; dv	x.8-8									
		add.l	a3,d5						;8		; dx	16.16			28 nop
	dbra	d0,loop
	move.l	d7,a6
	rts


; a0 table
; d0 x
; d1 1/x
;	lea		divTablePivot,a0
;	add.w	d0,d0
;	move.w	(a0,d0.w),d1
;	

initDivTable2
	lea		divTablePivot,a0		;pos
	move.l	a0,a1					;neg
	moveq	#1,d0
	move.w	#-1,d1
	move.l	#$7fff,d6					;pos
	move.l	#-1,d5					;neg
	move.w	#256/2-1,d7
	move.w	d6,(a0)+
.loop
		; pos
		move.l	d6,d4
		divu	d0,d4
		move.w	d4,(a0)+
		; neg
		neg.w	d4
		move.w	d4,-(a1)

		addq.w	#1,d0
		subq.w	#1,d1

	dbra	d7,.loop
	move.w	#$4e75,initDivTable2
	rts



dodiv	macro
		moveq	#0,d1
		move.l	d7,d5	; x																			;	4
		cmp.w	d2,d6
		bgt.w	.skipdiv\@

		asl.l	#8,d5

		divu	d6,d5
		move.w	d5,d1		; whole
		clr.w	d5
		swap	d5
		asl.l	#8,d5
		divu	d6,d5
		swap	d1			
		asr.l	#8,d1
		or.w	d5,d1
;		asr.l	#8,d1

		move.l	d7,d5
		neg.l	d5
		asl.l	#7,d5
		or.w	d6,d5
		add.l	d5,d5
		add.l	d5,d5

.skipdiv\@
		move.l	d1,(a0)+
		neg.l	d1
		move.l	d1,(a1,d5.l)

		addq	#1,d6	
	endm
        

initDivTable
	move.l	divtablepointer,a0
	move.l	a0,a1
	moveq	#0,d1
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
		dodiv
	ENDR
		cmp		d0,d6																				;	8
		blt		.innerloop																			; ----> +12 ==> 426

	addq	#1,d7																					;	4
	cmp		d2,d7																					;	8
	blt		.outerloop																				; ---> 256*256*426 + 256*16 = 3.5sec precalc
	move.w	#$4e75,initDivTable
	rts


	IFEQ	OPT_A7
savedA7	dc.l	0
	ENDC


;SPACESAVE
c2p_2to4_optimized													;16kbv

;	lea		canvas,a0
	move.l	canvasPointer_text,a0
	move.l	screenpointer2,a6
;	add.w	#20*160,a6
	move.l	a6,usp
	IFEQ	OPT_A7
		move.l	a7,savedA7
	ENDC
.off set 4*8
	REPT 75															;17kb, generate!
;		REPT 8
		IFEQ	OPT_A7
			movem.w	(a0)+,a1-a7

			move.l	(a1),d0				
			or.l	-(a2),d0			
			move.l	(a3),d1				
			or.l	-(a4),d1			
			move.l	(a5),d2				
			or.l	-(a6),d2			
			move.l	(a7),d3

			movem.w	(a0)+,a1-a7
			or.l	-(a1),d3
			move.l	(a2),d4
			or.l	-(a3),d4
			move.l	(a4),d5
			or.l	-(a5),d5
			move.l	(a6),d6
			or.l	-(a7),d6

			movem.w	(a0)+,a1-a7
			move.l	(a1),d7
			or.l	-(a2),d7

			move.l	usp,a1
			movep.l	d0,.off+0(a1)		;24
			movep.l	d1,.off+1(a1)		;24
			movep.l	d2,.off+8(a1)		;24
			movep.l	d3,.off+9(a1)		;24
			movep.l	d4,.off+16(a1)		;24
			movep.l	d5,.off+17(a1)		;24
			movep.l	d6,.off+24(a1)		;24
			movep.l	d7,.off+25(a1)		;24				8*24 = 			192

			move.l	(a3),d0
			or.l	-(a4),d0
			move.l	(a5),d1				
			or.l	-(a6),d1			
			move.l	(a7),d2
			movem.w	(a0)+,a2-a7
			or.l	-(a2),d2				
			move.l	(a3),d3			
			or.l	-(a4),d3				
			move.l	(a5),d4			
			or.l	-(a6),d4


			movep.l	d0,.off+32(a1)
			movep.l	d1,.off+33(a1)
			movep.l	d2,.off+40(a1)
			movep.l	d3,.off+41(a1)
			movep.l	d4,.off+48(a1)

			movem.w	(a0)+,a2-a6
			move.l	(a7),d5
			or.l	-(a2),d5
			move.l	(a3),d6
			or.l	-(a4),d6
			move.l	(a5),d7
			or.l	-(a6),d7			

			movep.l	d5,.off+49(a1)
			movep.l	d6,.off+56(a1)
			movep.l	d7,.off+57(a1)
		ELSE	;		9602/64 = 150
			movem.w	(a0)+,a1-a6			;36				;6				;6 + 12 + 24. = 42 per 8 320 = 40 = 40*42*50		84000 cycles

			move.l	(a1),d0				;12
			or.l	-(a2),d0			;20		32

			move.l	(a3),d1				;12
			or.l	-(a4),d1			;20

			move.l	(a5),d2				;12
			or.l	-(a6),d2			;20				36 + 3*32

			movem.w	(a0)+,a1-a6			;36

			move.l	(a1),d3				;12
			or.l	-(a2),d3			;20

			move.l	(a3),d4				;12
			or.l	-(a4),d4			;20

			move.l	(a5),d5				;12	
			or.l	-(a6),d5			;20				36 + 3*32	--> 264

			movem.w	(a0)+,a1-a6			;36

			move.l	(a1),d6				;12
			or.l	-(a2),d6			;20

			move.l	(a3),d7				;12
			or.l	-(a4),d7			;20		

			move.l	usp,a1				;4								104

			movep.l	d0,.off+0(a1)		;24
			movep.l	d1,.off+1(a1)		;24
			movep.l	d2,.off+8(a1)		;24
			movep.l	d3,.off+9(a1)		;24
			movep.l	d4,.off+16(a1)		;24
			movep.l	d5,.off+17(a1)		;24
			movep.l	d6,.off+24(a1)		;24
			movep.l	d7,.off+25(a1)		;24				8*24 = 			192

			move.l	(a5),d0				;12
			or.l	-(a6),d0			;20				32
			movep.l	d0,.off+32(a1)		;24				24				56

			movem.w	(a0)+,a1-a6			;36

			move.l	(a1),d0				;12
			or.l	-(a2),d0			;20

			move.l	(a3),d1				;12
			or.l	-(a4),d1			;20

			move.l	(a5),d2				;12
			or.l	-(a6),d2			;20				36 + 3*32		132

			movem.w	(a0)+,a1-a6			;36

			move.l	(a1),d3				;12
			or.l	-(a2),d3			;20

			move.l	(a3),d4				;12
			or.l	-(a4),d4			;20

			move.l	(a5),d5				;12
			or.l	-(a6),d5			;20				36 + 3*32 		132

			move.w	(a0)+,a1			;8
			move.w	(a0)+,a2			;8

			move.l	(a1),d6				;12
			or.l	-(a2),d6			;20

			move.l	usp,a1				;4								52

			movep.l	d0,.off+33(a1)		;24
			movep.l	d1,.off+40(a1)		;24
			movep.l	d2,.off+41(a1)		;24		
			movep.l	d3,.off+48(a1)		;24
			movep.l	d4,.off+49(a1)		;24		
			movep.l	d5,.off+56(a1)		;24
			movep.l	d6,.off+57(a1)		;24				7*24			168		===> 1100 / 128 = 8,59375			68,75 per 8		

.off set .off+64
			movem.w	(a0)+,a1-a6			;36				;6				;6 + 12 + 24. = 42 per 8 320 = 40 = 40*42*50		8400
			move.l	(a1),d0				;12
			or.l	-(a2),d0			;20		32
			move.l	(a3),d1				;12
			or.l	-(a4),d1			;20
			move.l	(a5),d2				;12
			or.l	-(a6),d2			;20				36 + 3*32
			movem.w	(a0)+,a1-a6			;36
			move.l	(a1),d3				;12
			or.l	-(a2),d3			;20
			move.l	(a3),d4				;12
			or.l	-(a4),d4			;20
			move.l	(a5),d5				;12	
			or.l	-(a6),d5			;20				36 + 3*32	--> 264
;			movem.w	(a0)+,a1-a6			;36													
			move.w	(a0)+,a1
			move.w	(a0)+,a2
			move.l	(a1),d6				;12
			or.l	-(a2),d6			;20
;			move.l	(a3),d7				;12
;			or.l	-(a4),d7			;20		
			move.l	usp,a1				;4								104
			movep.l	d0,.off+0(a1)		;24
			movep.l	d1,.off+1(a1)		;24
			movep.l	d2,.off+8(a1)		;24
			movep.l	d3,.off+9(a1)		;24
			movep.l	d4,.off+16(a1)		;24
			movep.l	d5,.off+17(a1)		;24
			movep.l	d6,.off+24(a1)		;24
;			movep.l	d7,.off+25(a1)		;24				8*24 = 			192
;			move.l	(a5),d0				;12
;			or.l	-(a6),d0			;20				32
;			movep.l	d0,.off+32(a1)		;24				24				56
			lea		36(a0),a0
;			movem.w	(a0)+,a1-a6			;36													12
;			move.l	(a1),d0				;12
;			or.l	-(a2),d0			;20
;			move.l	(a3),d1				;12
;			or.l	-(a4),d1			;20
;			move.l	(a5),d2				;12
;			or.l	-(a6),d2			;20				36 + 3*32		132
;			movem.w	(a0)+,a1-a6			;36													12
;			move.l	(a1),d3				;12
;			or.l	-(a2),d3			;20
;			move.l	(a3),d4				;12
;			or.l	-(a4),d4			;20
;			move.l	(a5),d5				;12
;			or.l	-(a6),d5			;20				36 + 3*32 		132
;			move.w	(a0)+,a1			;8													2
;			move.w	(a0)+,a2			;8													2
;			move.l	(a1),d6				;12
;			or.l	-(a2),d6			;20
;			move.l	usp,a1				;4								52
;			movep.l	d0,.off+33(a1)		;24
;			movep.l	d1,.off+40(a1)		;24
;			movep.l	d2,.off+41(a1)		;24		
;			movep.l	d3,.off+48(a1)		;24
;			movep.l	d4,.off+49(a1)		;24		
;			movep.l	d5,.off+56(a1)		;24
;			movep.l	d6,.off+57(a1)		;24				7*24			168		===> 1100 / 128 = 8,59375			68,75 per 8	

		ENDC



;.off set .off+8
;		ENDR
.off set .off+160+160-64
	ENDR

	IFEQ	OPT_A7
		move.l	savedA7,a7
	ENDC

	rts



;96 read
; 3* 92 write ==> 96+3*92 = 372 per line and this *4 = 1488 per unique line and we got 50 of them 74400

;SPACESAVE
copyLines
	move.l	screenpointer2,a6
	add.w	#16,a6

	REPT 	75																		;1.6k
		movem.l	(a6)+,d0-d7/a0-a5		; 14 			;-4				;124
		movem.l	d0-d7/a0-a5,-56+160(a6)									;124
		movem.l	(a6)+,d0-d7/a0-a5				;60
		movem.l	d0-d7/a0-a5,-56+160(a6)		;60
		lea		160+160-112(a6),a6										;8		304 * 64 = 19456
	ENDR

	rts



generateOptimizedTabs
	lea		$606,a0
	lea		TAB1,a1
	lea		TAB2,a2
	lea		TAB3,a3
	lea		TAB4,a4
	moveq	#0,d1
	move.w	#16-1,d7
.ol
		move.l	(a1,d1.w),d2
		move.l	(a3,d1.w),d3
		move.w	#16-1,d6
		moveq	#0,d0
.il
			move.l	d2,d4
			move.l	d3,d5

			or.l	(a2,d0.w),d4
			or.l	(a4,d0.w),d5

			move.l	d4,(a0)
			move.l	d5,-4(a0)

			lea		8(a0),a0
			addq.w	#4,d0
	
		dbra	d6,.il
		addq.w	#4,d1

		lea     $0800-16*8(a0),a0


	dbra	d7,.ol
	rts

calculateRotatedProjection
	lea		_sintable512,a0
	lea		_sintable512+(sintable_size_tapetext/4),a1
   
	move.w	_currentStepX,d2
	move.w	_currentStepY,d4
	move.w	_currentStepZ,d6


	and.w	#%1111111110,d2
	and.w	#%1111111110,d4
	and.w	#%1111111110,d6


	add.w	#2,myZoomOffset
	cmp.w	#78*2,myZoomOffset
	ble		.okh
		move.w	#78*2,myZoomOffset
		move.w	#0,_currentStepX
		move.w	#-1,.skipZoom
		jmp		.tttt
.okh

	add.w	#26,_currentStepX
.tttt
;	move.w	#$AC,_currentStepX
;	add.w	#2,_currentStepY
;	add.w	#6,_currentStepZ


	move.w	(a0,d2.w),d1					; sinA	;around z axis		16
	move.w	(a1,d2.w),d2					; cosA						16

	move.w	(a0,d4.w),d3					; sinB	;around y axis		16
	move.w	(a1,d4.w),d4					; cosB						16

	move.w	(a0,d6.w),d5					; sinC	;around x axis		16
	move.w	(a1,d6.w),d6					; cosC						16

;	xx = [cosA * cosB]
	move.w	_cosA,d7
	muls	_cosB,d7
;	lsl.l	#2,d7
	swap	d7
;	move.w	d7,_xx
	move.w	d7,a0
;	xy = [sinA * cosB]
	move.w	_sinA,d7
	muls	_cosB,d7
;	lsl.l	#2,d7
	swap	d7
;	move.w	d7,_xy
	move.w	d7,a1
;	xz = [sinB]	
;	move.w	_sinB,_xz
	move.w	_sinB,d7
	asr.w	#1,d7
	move.w	d7,a2
;	yx = [sinA * cosC + cosA * sinB * sinC]
	move.w	_sinA,d7
	muls	_cosC,d7
	move.w	_cosA,d0
	muls	_sinB,d0
	lsl.l	#1,d0
	swap	d0
	muls	_sinC,d0
	add.l	d7,d0
;	lsl.l	#2,d0
	swap	d0
;	move.w	d0,_yx	; sinA * cosC + cosA * sinB * sinC
	move.w	d0,a3
;	yy = [-cosA * cosC + sinA * sinB * sinC]
	move.w	_cosA,d7
	neg		d7
	muls	_cosC,d7
	move.w	_sinA,d0
	muls	_sinB,d0
	lsl.l	#1,d0
	swap	d0
	muls	_sinC,d0
	add.l	d7,d0
;	lsl.l	#2,d0
	swap	d0
;	move.w	d0,_yy
	move.w	d0,a4
;	yz = [-cosB * sinC]
	move.w	_cosB,d7
	neg.w	d7
	muls	_sinC,d7
;	lsl.l	#2,d7
	swap	d7
	move.w	d7,_yz
	move.w	d7,.smc_yz1+2
	move.w	d7,.smc_yz2+2

;;	zx = [sinA * sinC - cosA * sinB * cosC]
	move.w	_sinA,d7
	muls	_sinC,d7
	move.w	_cosA,d0
	muls	_sinB,d0
	lsl.l	#1,d0
	swap	d0
	muls	_cosC,d0
	sub.l	d0,d7
	move.l	d7,_zx
;	lsl.l	#2,d7
	swap	d7
;	move.w	d7,_zx
;
;;	zy = [-cosA * sinC - sinA * sinB * cosC]
	move.w	_cosA,d7
	muls	_sinC,d7
	neg.l	d7
	move.w	_sinA,d0
	muls	_sinB,d0
	lsl.l	#1,d0
	swap	d0
	muls	_cosC,d0
	sub.l	d0,d7
	move.l	d7,_zy
;	lsl.l	#2,d7
	swap	d7
;	move.w	d7,_zy
;
;;	zz = [cosB * cosC]
	move.w	_cosB,d7
	muls	_cosC,d7
	move.l	d7,_zz
;	lsl.l	#2,d7
	swap	d7
;	move.w	d7,_zz

	lea		myZoomTable,a6
	add.w	myZoomOffset,a6
	move.w	(a6),myFactor



	lea		currentVertices_tape,a5					;8	
	lea		point1_t,a6



	move.w	#4,d7
	subq.w	#1,d7
	move.w	#51,d5
	move.w	#33,d6
	tst.w	.skipZoom
	bne		.rotate2
	; now determine the multiply value

.rotate
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2		;24									movem.w	(a5)+,d0-d2

;		add.w	d0,d0
;		add.w	d0,d0
;		add.w	d0,d0
;		add.w	d1,d1
;		add.w	d1,d1
;		add.w	d1,d1

;	x'' = x * xx + y * xy + z * xz									lea		xxtozz,a4
		move.w	a0,d3			;4									move.w	d0,d3			
		muls	d0,d3			;44									muls	(a4)+,d3		
		move.w	a1,d4			;4									move.w	d1,d4			
		muls	d1,d4			;44									muls	(a4)+,d4
		add.l	d4,d3			;8									add.l	d3,d4
		move.w	a2,d4			;4									move.w	d2,d3
		muls	d2,d4			;44									muls	(a4)+,d3
		add.l	d4,d3			;8									add.l	d3,d4
		swap	d3				;4									swap	d4
		muls.w	myFactor,d3
		swap	d3
		add.w	d3,d3
		add.w	d5,d3			;4									add.w	d5,d4
		move.w	d3,(a6)+		;8		-> 44*4 = 176				move.w	d4,(a6)+

;	y'' = x * yx + y * yy + z * yz
		move.w	a3,d3			;4									move.w	d0,d3
		muls	d0,d3			;44									muls	(a4)+,d3
		move.w	a4,d4			;4									move.w	d1,d4
		muls	d1,d4			;44									muls 	(a4)+,d4
		add.l	d4,d3			;8									add.l	d3,d4
.smc_yz1
		muls	#$1234,d2
		add.l	d2,d3			;8									add.l	d3,d4
		swap	d3				;4									swap	d4
		muls.w	myFactor,d3
		swap	d3
		add.w	d3,d3
		add.w	d6,d3			;4									add.w	d6,d4
		move.w	d3,(a6)+		;8		-> 46*4 = 184
		lea		4(a6),a6
	dbra	d7,.rotate
	rts
;	lea		projectedVertices,a0
;	lea		canvas,a1
;	REPT 3
;	move.w	(a0)+,d0
;	move.w	(a0)+,d1
;	lsl.w	#6,d1
;	add.w	d1,d0
;	move.b	#8,(a1,d0.w)
;	ENDR
;	rts


.rotate2
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2		;24									movem.w	(a5)+,d0-d2

;	x'' = x * xx + y * xy + z * xz									lea		xxtozz,a4
		move.w	a0,d3			;4									move.w	d0,d3			
		muls	d0,d3			;44									muls	(a4)+,d3		
		move.w	a1,d4			;4									move.w	d1,d4			
		muls	d1,d4			;44									muls	(a4)+,d4
		add.l	d4,d3			;8									add.l	d3,d4
		move.w	a2,d4			;4									move.w	d2,d3
		muls	d2,d4			;44									muls	(a4)+,d3
		add.l	d4,d3			;8									add.l	d3,d4
		swap	d3				;4									swap	d4
		add.w	d5,d3			;4									add.w	d5,d4
		move.w	d3,(a6)+		;8		-> 44*4 = 176				move.w	d4,(a6)+

;	y'' = x * yx + y * yy + z * yz
		move.w	a3,d3			;4									move.w	d0,d3
		muls	d0,d3			;44									muls	(a4)+,d3
		move.w	a4,d4			;4									move.w	d1,d4
		muls	d1,d4			;44									muls 	(a4)+,d4
		add.l	d4,d3			;8									add.l	d3,d4
.smc_yz2
		muls	#$1234,d2
		add.l	d2,d3			;8									add.l	d3,d4
		swap	d3				;4									swap	d4
		add.w	d6,d3			;4									add.w	d6,d4
		move.w	d3,(a6)+		;8		-> 46*4 = 184
		lea		4(a6),a6
	dbra	d7,.rotate2
	rts
.skipZoom	dc.w	0
myFactor	ds.l	1

myZoomOffset	dc.w	0

myZoomTable	
;	dc.w	0
	dc.w	5
	dc.w	21
	dc.w	47
	dc.w	84
	dc.w	131
	dc.w	189
	dc.w	257
	dc.w	336
	dc.w	425
	dc.w	524
	dc.w	634
	dc.w	755
	dc.w	886
	dc.w	1028
	dc.w	1180
	dc.w	1342
	dc.w	1515
	dc.w	1699
	dc.w	1893
	dc.w	2097
	dc.w	2312
	dc.w	2538
	dc.w	2773
	dc.w	3020
	dc.w	3277
	dc.w	3544
	dc.w	3822
	dc.w	4110
	dc.w	4409
	dc.w	4719
	dc.w	5038
	dc.w	5369
	dc.w	5709
	dc.w	6061
	dc.w	6423
	dc.w	6795
	dc.w	7178
	dc.w	7571
	dc.w	7974
	dc.w	8389
	dc.w	8813
	dc.w	9248
	dc.w	9694
	dc.w	10150
	dc.w	10617
	dc.w	11094
	dc.w	11582
	dc.w	12080
	dc.w	12588
	dc.w	13107
	dc.w	13637
	dc.w	14177
	dc.w	14727
	dc.w	15288
	dc.w	15860
	dc.w	16442
	dc.w	17034
	dc.w	17637
	dc.w	18250
	dc.w	18874
	dc.w	19509
	dc.w	20154
	dc.w	20809
	dc.w	21475
	dc.w	22151
	dc.w	22838
	dc.w	23535
	dc.w	24243
	dc.w	24961
	dc.w	25690
	dc.w	26429
	dc.w	27179
	dc.w	27939
	dc.w	28710
	dc.w	29491
	dc.w	30283
	dc.w	31085
	dc.w	31898
	dc.w	$7fff
	dc.w	$7fff


preshiftTape
	move.l	tapePicBufferPointer,a0
	move.l	a0,a1
	add.l	#107*12*8,a1			;10272 per screen
	move.w	#107*15-1,.lines
.doShift
;		REPT 6
				moveq	#0,d0
				roxr.w	d0
.x set 0
			REPT 12
				move.w	.x(a0),d0		;	1
				roxr.w	d0
				move.w	d0,.x(a1)
.x set .x+8
			ENDR
				moveq	#0,d0
				roxr.w	d0
.x set 2
			REPT 12
				move.w	.x(a0),d0		;	1
				roxr.w	d0
				move.w	d0,.x(a1)
.x set .x+8
			ENDR

				moveq	#0,d0
				roxr.w	d0
.x set 4
			REPT 12
				move.w	.x(a0),d0		;	1
				roxr.w	d0
				move.w	d0,.x(a1)
.x set .x+8
			ENDR

				moveq	#0,d0
				roxr.w	d0
.x set 6
			REPT 12
				move.w	.x(a0),d0		;	1
				roxr.w	d0
				move.w	d0,.x(a1)
.x set .x+8
			ENDR

			lea		12*8(a0),a0
			lea		12*8(a1),a1

;		ENDR
	subq.w	#1,.lines
	bge		.doShift
	rts
.lines	dc.w	0

	SECTION DATA
	IFEQ	STANDALONE
_sintable512		
	include	data/texture/sintable_amp32768_steps512.s
	ENDC

	IFEQ	PREPTAPETEXT
tapetext incbin	"data/tape/tapetext.neo"
tapeTextBuffer	ds.b	128*8*8
tapeBufferPointer	dc.l	tapeTextBuffer

prepTapeText
	lea		tapetext+128,a0
	lea		tapeTextBuffer,a1
.y set 0
	REPT 128
.x set .y
		REPT 8
			move.l	.x(a0),(a1)+
			move.l	.x+4(a0),(a1)+
.x set .x+8
		ENDR
.y set .y+160
	ENDR
	lea		tapeTextBuffer,a0
	move.b	#0,$ffffc123
	rts
	ELSE
tapeBufferPointer	ds.l	1
tapetextcrk		incbin	"data/tape/tapetext.crk"
	even
	ENDC

;--------------
;DEMOPAL - tape texture palette
;--------------		
tapeTextPal
	dc.w	$777,$775,$666,$566,$555,$740,$640,$444,$531,$322,$222,$111,$101,$100,$001,$000	;0

	dc.w	$777,$775,$666,$566,$555,$741,$641,$444,$531,$322,$222,$111,$111,$111,$111,$111
	dc.w	$777,$775,$666,$566,$555,$742,$642,$444,$532,$322,$222,$222,$222,$222,$222,$222
	dc.w	$777,$775,$666,$566,$555,$743,$643,$444,$533,$322,$333,$333,$333,$333,$333,$333
	dc.w	$777,$775,$666,$566,$555,$744,$644,$444,$444,$444,$444,$444,$444,$444,$444,$444
	dc.w	$777,$775,$666,$566,$555,$755,$655,$555,$555,$555,$555,$555,$555,$555,$555,$555
	dc.w	$777,$776,$666,$666,$666,$766,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
tapeTextPalOff	dc.w	7*32

	IFEQ	STANDALONE
; if we want to be really anal, we can generate these things
TAB1:
	DC.B $00,$00,$00,$00		;0
	DC.B $C0,$00,$00,$00		;4
	DC.B $00,$C0,$00,$00		;8
	DC.B $C0,$C0,$00,$00		;12
	DC.B $00,$00,$C0,$00		;16
	DC.B $C0,$00,$C0,$00		;20
	DC.B $00,$C0,$C0,$00		;24
	DC.B $C0,$C0,$C0,$00		;28
	DC.B $00,$00,$00,$C0		;32
	DC.B $C0,$00,$00,$C0		;36
	DC.B $00,$C0,$00,$C0		;40
	DC.B $C0,$C0,$00,$C0		;44
	DC.B $00,$00,$C0,$C0		;48
	DC.B $C0,$00,$C0,$C0		;52
	DC.B $00,$C0,$C0,$C0		;56
	DC.B $C0,$C0,$C0,$C0		;60
TAB2:
	DC.B $00,$00,$00,$00		;0
	DC.B $30,$00,$00,$00		;4
	DC.B $00,$30,$00,$00		;8
	DC.B $30,$30,$00,$00		;12
	DC.B $00,$00,$30,$00		;16
	DC.B $30,$00,$30,$00		;20
	DC.B $00,$30,$30,$00		;24
	DC.B $30,$30,$30,$00		;28
	DC.B $00,$00,$00,$30		;32
	DC.B $30,$00,$00,$30		;36
	DC.B $00,$30,$00,$30		;40
	DC.B $30,$30,$00,$30		;44
	DC.B $00,$00,$30,$30		;48
	DC.B $30,$00,$30,$30		;52
	DC.B $00,$30,$30,$30		;56
	DC.B $30,$30,$30,$30		;60
TAB3:
	DC.B $00,$00,$00,$00		;0
	DC.B $0C,$00,$00,$00		;4
	DC.B $00,$0C,$00,$00		;8
	DC.B $0C,$0C,$00,$00		;12
	DC.B $00,$00,$0C,$00		;16
	DC.B $0C,$00,$0C,$00		;20
	DC.B $00,$0C,$0C,$00		;24
	DC.B $0C,$0C,$0C,$00		;28
	DC.B $00,$00,$00,$0C		;32
	DC.B $0C,$00,$00,$0C		;36
	DC.B $00,$0C,$00,$0C		;40
	DC.B $0C,$0C,$00,$0C		;44
	DC.B $00,$00,$0C,$0C		;48
	DC.B $0C,$00,$0C,$0C		;52
	DC.B $00,$0C,$0C,$0C		;56
	DC.B $0C,$0C,$0C,$0C		;60
TAB4:
	DC.B $00,$00,$00,$00		;0
	DC.B $03,$00,$00,$00		;4
	DC.B $00,$03,$00,$00		;8
	DC.B $03,$03,$00,$00		;12
	DC.B $00,$00,$03,$00		;16
	DC.B $03,$00,$03,$00		;20
	DC.B $00,$03,$03,$00		;24
	DC.B $03,$03,$03,$00		;28
	DC.B $00,$00,$00,$03		;32
	DC.B $03,$00,$00,$03		;36
	DC.B $00,$03,$00,$03		;40
	DC.B $03,$03,$00,$03		;44
	DC.B $00,$00,$03,$03		;48
	DC.B $03,$00,$03,$03		;52
	DC.B $00,$03,$03,$03		;56
	DC.B $03,$03,$03,$03		;60
	ENDC
;pal_text
;	dc.w	$000,$776,$766,$765,$763,$763,$752,$741,$731,$722,$512,$501,$401,$301,$201,$100	
	IFEQ	STANDALONE
		include		lib/lib.s
		include		lib/cranker.s
	ENDC

tapecrk		incbin	"data/tape/tapepic3.crk"
	even 

texturepointer		ds.l	1
divtablepointer		ds.l	1
canvasPointer_text	ds.l	1


_vertices_xoff		ds.w	1
_vertices_yoff		ds.w	1
_stepSpeedX			ds.w	1
_stepSpeedY			ds.w	1
_stepSpeedZ			ds.w	1

_currentStepX		ds.w	1
_currentStepY		ds.w	1
_currentStepZ		ds.w	1

_zx								ds.l	1
_zy								ds.l	1
_zz								ds.l	1
_yz								ds.l	1

projectedVertices				ds.w	300
tapePicBufferPointer			ds.l	1

	ds.w	128
divTablePivot	
	ds.w	128


; general stuff
    IFEQ	STANDALONE
	SECTION BSS
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
vblcount			ds.w	1
cummulativeCount	ds.w	1
	ENDC



