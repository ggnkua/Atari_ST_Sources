ENABLE_CULL	equ 0
OPT_MULS	equ 0

ENVMAP		equ 0               

verticesnr	equ 24


C2P_1PX		equ 0

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



sintable_size_envmap			equ	512*2				; 512 entries of wordsize

; optimizations
OPT_SMC_ENVMAP		equ 0




	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	DATA

	IFEQ	STANDALONE

			include macro.s
			initAndRun	init_effect



init_effect
	jsr		init_demo
	jsr		init_envmap
	move.w	#32000,effect_vbl_counter
	jsr		envmap_mainloop



init_demo
	move.w	#$000,$ffff8240
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	rts

	ENDC

omgpointer	ds.l	1

init_envmap_pointers
	move.l	screen1,d0
	move.l	d0,d1
	add.l	#$8000,d1
	move.l	d1,omgpointer
	add.l	#$10000,d0
;	move.l	d0,screenpointer
	move.l	screen2,d0
	add.l	#$10000,d0
;	move.l	d0,screenpointer2
;	add.l	#$10000,d0
;	move.l	d0,divtablepointer_env
	add.l	#$10000,d0
	move.l	d0,texturepointer_env
	move.l	d0,d1
	add.l	#$11000,d1
	move.l	d1,c2pPointerEnv
	add.l	#20000,d1
	move.l	d1,canvasPointer_text_env
	add.l	#$20000,d0
	IFEQ	C2P_1PX
	move.l	d0,tab1px_1p_env
	add.l	#$10000,d0
	move.l	d0,tab1px_2p_env
	add.l	#$10000,d0
	move.l	d0,tab1px_3p_env
	add.l	#$10000,d0
	move.l	d0,tab1px_4p_env
	add.l	#$10000,d0
	ENDC
	move.l	d0,d1
	move.l	d1,maskLeftPtr
	add.l	#1280,d1
	move.l	d1,maskRightPtr
	add.l	#1280,d1
	move.l	d1,spandataPtr
	add.l	#$10000,d0
	move.l	d0,divtablepointer_env

	move.w	#$4e75,init_envmap_pointers
	rts

origPointer	ds.l	1

precalc_envmap
	jsr		init_envmap_pointers

	lea		omgcrk,a0
	move.l	omgpointer,a1
	jsr		cranker


	jsr		initDivTable_em
	jsr		initDivTable_em_pivot

	jsr		planarToChunky_text_envmap

	jsr		generatec2p_envmap

	IFEQ	C2P_1PX
		jsr		generate1pxTabsLower
		jsr		clearCanvas_envmap_opt
	ELSE
		jsr		generateOptimizedTabs_em
		jsr		clearCanvas_envmap_opt
	ENDC

	jsr		genMaskLeftRight

	move.w	#$4e75,precalc_envmap
	rts

init_envmap
	; pointers
	jsr		init_envmap_pointers

	jsr		precalc_envmap

;	add.l	#$10000,d0
;	move.l	#canvas,canvasPointer_text_env
	move.w	#$777,timer_b_open_curtain+2



;	move.b	#0,$fffc123
	IFEQ	STANDALONE
	movem.l	omgpal,d0-d7
;	movem.l	orig+4,d0-d7
	movem.l	d0-d7,$ffff8240

;	lea		orig+128+160,a0
	move.l	omgpointer,a0
	add.w	#128+160,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	add.w	#160,a1
	add.w	#160,a2
	move.w	#199-1,d7
.l
	REPT 40
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
	ENDR
	dbra	d7,.l
	ENDC


	move.w	#0,effectcount
	move.w	#0,vblcount
	IFNE	STANDALONE
		move.b	#0,musicPlayer+$b8
	ENDC

	move.w	#$2700,sr
	move.l	#envmap_vbl,$70
	move.w	#$2300,sr
	rts

canvas_y_offset	dc.l	-70*160

	IFEQ	C2P_1PX


generate1pxTabsLower

	jsr		calc1pxTab_lower
	rts

calc1pxTab_lower
	move.l 	tab1px_1p_env,a5
	lea     TAB1,a0
	move.w	#16-1,d7
	moveq   #0,d3
.oloop1
	moveq   #0,d4
	move.l	a5,a6
	move.w	#16-1,d6
.iloop1
			move.l  (a0,d3.w),d2
			and.l   #$80808080,d2
	
			move.l  (a0,d4.w),d5
			and.l   #$40404040,d5
			or.l    d5,d2
	
			move.l  d2,(a6)+
			addq.w  #4,d4
		dbra	d6,.iloop1

		lea     $0400(a5),a5
		addq.w  #4,d3
	dbra	d7,.oloop1
 

	move.l	tab1px_2p_env,a5
	lea     TAB2,a0
	moveq   #0,d3
	move.w	#16-1,d7
.oloop2
        moveq   #0,d4
        move.w	#16-1,d6
        move.l	a5,a6
.iloop2
        	move.l  0(a0,d3.w),d2
        	and.l   #$20202020,d2
 
        	move.l  0(a0,d4.w),d5
        	and.l   #$10101010,d5
        	or.l    d5,d2
 
        	move.l  d2,(a6)+
        	addq.w  #4,d4
        	dbra	d6,.iloop2
        lea     $0400(a5),a5
        addq.w  #4,d3
    dbra	d7,.oloop2

 
	move.l	tab1px_3p_env,a5
	lea     TAB3,a0
	moveq   #0,d3
	move.w	#16-1,d7
.oloop3
		moveq   #0,d4
		move.l	a5,a6
		move.w	#16-1,d6
.iloop3
			move.l  0(a0,d3.w),d2
			and.l   #$08080808,d2
			
			move.l  0(a0,d4.w),d5
			and.l   #$04040404,d5
			or.l    d5,d2

;			cmpa.l  #$00000400,a6
;			blt     .nolsdo22
				move.l  d2,(a6)+
;.nolsdo22:
	        addq.w  #4,d4
	    dbra	d6,.iloop3

        lea     $0400(a5),a5
        addq.w  #4,d3
      	dbra	d7,.oloop3
 


	move.l	tab1px_4p_env,a5
	lea     TAB4,a0
	moveq   #0,d3
	move.w	#16-1,d7
.oloop4
		moveq   #0,d4
		move.l	a5,a6
		move.w	#16-1,d6
.iloop4
			move.l  0(a0,d3.w),d2
			and.l   #$02020202,d2
			
			move.l  0(a0,d4.w),d5
			and.l   #$01010101,d5
			or.l    d5,d2
			
			move.l  d2,(a6)+
			addq.w  #4,d4
		dbra	d6,.iloop4
		lea     $0400(a5),a5
		addq.w  #4,d3
	dbra	d7,.oloop4
 	rts



generatec2p_envmap
	lea		.template,a0
	movem.l	(a0)+,a1-a6			;
	movem.l	(a0)+,d0-d3			

	move.l	c2pPointerEnv,a0

	moveq	#8,d6				; y 
	move.w	#160,d5

	move.w	#6-1,d7
.l1
		move.w	d6,d0				;a set y
		move.l	d1,(a0)+			;lea	16							
		REPT 3
			movem.l	a1-a6,(a0)		
			lea		24(a0),a0
			move.l	d0,(a0)+		; movep
			addq.w	#1,d0
			movem.l	a1-a6,(a0)		
			lea		24(a0),a0
			move.l	d0,(a0)+
			addq.w	#7,d0
		ENDR
		move.l	d2,(a0)+
		add.w	d5,d6				; y set y+160
	dbra	d7,.l1										;		6*(8+(56*3))= 1056*2 + 58(4+(56*5)) = 16472 ==> 18586

	subq.w	#8,d6					; y set y-8

	move.w	#70-12-1,d7
.l2
		move.w	d6,d0
		REPT 5
			movem.l	a1-a6,(a0)
			lea		24(a0),a0
			move.l	d0,(a0)+
			addq.w	#1,d0
			movem.l	a1-a6,(a0)
			lea		24(a0),a0
			move.l	d0,(a0)+
			addq.w	#7,d0
		ENDR
		move.l	d3,(a0)+
		add.w	d5,d6
	dbra	d7,.l2

	addq.w	#8,d6

	move.w	#7-1,d7
.l3
		move.w	d6,d0				;a set y
		move.l	d1,(a0)+			;lea	16
		REPT 3
			movem.l	a1-a6,(a0)		
			lea		24(a0),a0
			move.l	d0,(a0)+		; movep
			addq.w	#1,d0
			movem.l	a1-a6,(a0)		
			lea		24(a0),a0
			move.l	d0,(a0)+
			addq.w	#7,d0
		ENDR
		move.l	d2,(a0)+
		add.w	d5,d6				; y set y+160
	dbra	d7,.l3
	move.w	#$4e75,(a0)+
	rts

.template
	move.w  (a4)+,d0				;a1	
	move.w  (a4)+,d1				;a1
	move.w  (a4)+,d2				;a2
	move.w	(a4)+,d3				;a2
									;
	move.l	d0,a3					;a3
	move.l  (a3),d7					;a3
	move.l	d1,a3					;a4
	or.l    (a3),d7					;a4
	move.l	d2,a3					;a5
	or.l    (a3),d7					;a5
	move.l	d3,a3					;a6
	or.l    (a3),d7					;a6

	movep.l d7,0(a2) 				;d0
	lea		16(a4),a4				;d1
	lea		48+16(a4),a4			;d2
	lea		48(a4),a4				;d3

c2p_1to1:
	move.l	screenpointer2,a2
	add.l	canvas_y_offset,a2
    movem.l tab1px_1p_env,d0-d3/a4/a6					; c2p_1px_tab_aligned1
;	move.l 	tab1px_2p_env,d1					; c2p_1px_tab_aligned2
;	move.l 	tab1px_3p_env,d2					; c2p_1px_tab_aligned2
;	move.l 	tab1px_4p_env,d3					; c2p_1px_tab_aligned2
;	move.l	canvasPointer_text_env,a4
;	move.l	c2pPointerEnv,a6
    jmp		(a6)
;c2pt
;.loop
;y set 8
;	REPT 6								
;a               set y
;		lea		16(a4),a4
;    	REPT   (80/16)-2									
;    		move.w  (a4)+,d0				;8	
;    		move.w  (a4)+,d1				;8	
;    		move.w  (a4)+,d2				;8	
;    		move.w	(a4)+,d3				;8		--> 32
;    										;	
;    		move.l	d0,a3					;4
;    		move.l  (a3),d7					;12						
;    		move.l	d1,a3					;4
;    		or.l    (a3),d7					;16						
;    		move.l	d2,a3					;4
;    		or.l    (a3),d7					;16						
;    		move.l	d3,a3					;4
;    		or.l    (a3),d7					;16			16+3*20 = 76			
;    		movep.l d7,a(a2) 				;24			+24				==> 32 + 100 = 132*2 = 
;	;-----------
;   			move.w  (a4)+,d0				;8
;    		move.w  (a4)+,d1				;8
;    		move.w  (a4)+,d2				;8
;    		move.w	(a4)+,d3				;8
;   		
;    		move.l	d0,a3					;4
;    		move.l  (a3),d7					;12
;    		move.l	d1,a3					;4
;    		or.l    (a3),d7					;16
;    		move.l	d2,a3
;    		or.l    (a3),d7					;16
;    		move.l	d3,a3
;    		or.l    (a3),d7			;20
;    		movep.l d7,a+1(a2) 				;24 		32+16+20+60 = 48+80 = 128 => 256 for 16 px => 16 cycles per
;
;a           set a+8
;    endr
;    		lea		48+16(a4),a4
; ;   		lea		160(a2),a2
;;    	dbra	d4,.loop
;y set y+160
;	endr	
;
;y set y-8
;
;	REPT (70-12)												;13312
;a               set y
;    	REPT   80/16									
;    		move.w  (a4)+,d0				;8	
;    		move.w  (a4)+,d1				;8	
;    		move.w  (a4)+,d2				;8	
;    		move.w	(a4)+,d3				;8		--> 32
;    										;	
;    		move.l	d0,a3					;4
;    		move.l  (a3),d7					;12						
;    		move.l	d1,a3					;4
;    		or.l    (a3),d7					;16						
;    		move.l	d2,a3					;4
;    		or.l    (a3),d7					;16						
;    		move.l	d3,a3					;4
;    		or.l    (a3),d7					;16			16+3*20 = 76			
;    		movep.l d7,a(a2) 				;24			+24				==> 32 + 100 = 132*2 = 
;	;-----------
;   			move.w  (a4)+,d0				;8
;    		move.w  (a4)+,d1				;8
;    		move.w  (a4)+,d2				;8
;    		move.w	(a4)+,d3				;8
;   		
;    		move.l	d0,a3					;4
;    		move.l  (a3),d7					;12
;    		move.l	d1,a3					;4
;    		or.l    (a3),d7					;16
;    		move.l	d2,a3
;    		or.l    (a3),d7					;16
;    		move.l	d3,a3
;    		or.l    (a3),d7			;20
;    		movep.l d7,a+1(a2) 				;24 		32+16+20+60 = 48+80 = 128 => 256 for 16 px => 16 cycles per
;
;a           set a+8
;    endr
;    		lea		48(a4),a4
; ;   		lea		160(a2),a2
;;    	dbra	d4,.loop
;y set y+160
;	endr
;
;	REPT 6								
;a               set y+8
;		lea		16(a4),a4
;    	REPT   (80/16)-2									
;    		move.w  (a4)+,d0				;8	
;    		move.w  (a4)+,d1				;8	
;    		move.w  (a4)+,d2				;8	
;    		move.w	(a4)+,d3				;8		--> 32
;    										;	
;    		move.l	d0,a3					;4
;    		move.l  (a3),d7					;12						
;    		move.l	d1,a3					;4
;    		or.l    (a3),d7					;16						
;    		move.l	d2,a3					;4
;    		or.l    (a3),d7					;16						
;    		move.l	d3,a3					;4
;    		or.l    (a3),d7					;16			16+3*20 = 76			
;    		movep.l d7,a(a2) 				;24			+24				==> 32 + 100 = 132*2 = 
;	;-----------
;   			move.w  (a4)+,d0				;8
;    		move.w  (a4)+,d1				;8
;    		move.w  (a4)+,d2				;8
;    		move.w	(a4)+,d3				;8
;   		
;    		move.l	d0,a3					;4
;    		move.l  (a3),d7					;12
;    		move.l	d1,a3					;4
;    		or.l    (a3),d7					;16
;    		move.l	d2,a3
;    		or.l    (a3),d7					;16
;    		move.l	d3,a3
;    		or.l    (a3),d7			;20
;    		movep.l d7,a+1(a2) 				;24 		32+16+20+60 = 48+80 = 128 => 256 for 16 px => 16 cycles per
;
;a           set a+8
;    endr
;    		lea		48+16(a4),a4
; ;   		lea		160(a2),a2
;;    	dbra	d4,.loop
;y set y+160
;	endr	
;
;    rts

 	ENDC

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

envmap_mainloop
	move.w	#0,$466.w
.mainloop
		subq.w	#1,effect_vbl_counter
		blt		.end

		jsr		clearCanvas_envmap_opt
		jsr		calculateRotatedProjection_envmap

	move.l	#75<<16,yTop
;	move.w	#0,yBot

	move.w	number_of_faces,d7
	subq.w	#1,d7
	lea		destFaces,a0
.doFace
		pushd7
		sub.w	#1,(a0)+
		blt		.skip
			jsr		drawTriangle
			popd7
			dbra	d7,.doFace
			jmp		.ttt
.skip
		add.w	#3*4,a0
.cont
		popd7
		dbra	d7,.doFace
.ttt

		subq.w	#2,yTop
		bge		.kkk
			move.w	#0,yTop
.kkk

		IFEQ	C2P_1PX
			jsr		c2p_1to1
		ELSE
			jsr		c2p_2to4_optimized_em
		ENDC

		tst.l	canvas_y_offset
		bgt		.kk
			move.l	screenpointer2,a0
			moveq	#0,d0
			REPT 10
				move.l	d0,(a0)+
			ENDR
.kk

.tt
	tst.w	$466.w
	beq		.tt
		cmp.w	#2,$466.w
;		bgt		.fail
		blt		.tt
;		jmp		.cont2
;.fail
;		move.l	#$700,d0
;		lea		$ffff8240,a0
;		REPT 16
;			move.w	d0,(a0)+
;		ENDR
;		move.b	#0,$ffffc123
;.cont2
	move.w	#0,$466.w

;		move.l	screenpointer2,$ffff8200
		move.l	screenpointer2,d0
		move.l	d0,$ffff8200
		move.l	screenpointer,screenpointer2
		move.l	d0,screenpointer
		add.w	#$8800,.waiter
		bcc		.nn
			add.l	#160,canvas_y_offset
			cmp.l	#32160,canvas_y_offset
			bne		.nn
				move.w	#$4e75,clearCanvas_envmap_opt
				move.w	#$4e75,calculateRotatedProjection_envmap
				move.w	#$4e75,c2p_1to1
				move.w	#$2700,sr
				move.l	screen1,$ffff8200
				move.l	#envmap_out_vbl,$70
				move.w	#$2300,sr
				move.w	#500,effect_vbl_counter
				IFNE	STANDALONE
					move.b	#0,musicPlayer+$b8
				ENDC
				jmp		.herpherp
.nn
	jmp		.mainloop
.herpherp
	tst.w	$466.w
	beq		.herpherp
	move.w	#0,$466.w
	subq.w	#1,effect_vbl_counter
	bge		.herpherp

.end
	rts
.waiter	dc.w	0


envmap_out_vbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	addq.w	#1,vblcount
	move.l	screen1,$ffff8200

	pushall

	move.w	#0,$ffff8240
	subq.w	#1,.env_out
	blt		.static
.special
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_envmap_out,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w	
	jmp		.set
.static
	move.w	#27,effect_vbl_counter
	move.w	#$4e71,.static
	move.w	#$4e71,.static+2
	move.w	#$4e71,.static+4
	move.w	#$4e71,.static+6

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_open_curtain_static,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w	
		jsr		clearrr
		jsr		drawTriangles

.set
		IFNE	STANDALONE
	  		jsr		musicPlayer+8
	  		move.b	musicPlayer+$b8,d0
;	  		cmp.b	#1,d0
	  		beq		.skip
	  			move.b	#0,musicPlayer+$b8
	  			move.l	outPalPtr,a0			; get ptr
	  			move.l	(a0)+,a1
	  				cmp.l	#-1,a1
	  				beq		.ttt
	  				move.w	#1,(a1)
	  				move.l	a0,outPalPtr
	  	  			move.l	(a0),a2
	  	  			cmp.l	#-1,a2
	  	  			bne		.skip
.ttt
					move.w	#15,.env_out
.skip
	    ENDC
	popall
	rte
.env_out	dc.w	32000
outPalList
	dc.l	out6offwaiter		;33
	dc.l	out0offwaiter		;33
	dc.l	out1offwaiter		;16
	dc.l	out7offwaiter		;16
	dc.l	out2offwaiter		;33
	dc.l	out3offwaiter		;16
	dc.l	out5offwaiter		;16
	dc.l	out4offwaiter		;33
	dc.l	-1
outPalPtr	dc.l	outPalList



PALOUT_DELAY_SLOW	equ 1
PALOUT_DELAY_QUICK	equ 0

palOutWaiter	macro
	subq.w	#1,out\1offwaiter
	bge		.n\@
		move.w	#\2,out\1offwaiter
		sub.w	#32,out\1off
		bge		.n\@
			move.w	#0,out\1off
.n\@
	endm

palOutWaiter2	macro
	subq.w	#1,out\1offwaiter
	bge		.n\@
		move.w	#\2,out\1offwaiter
		sub.w	#32,out\1off
		cmp.w	#7*32,out\1off
		bge		.n\@
			move.w	#7*32,out\1off
.n\@
	endm

timer_b_open_curtain_static
	move.w	#$777,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#98,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_static_col_pre,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_static_col_pre
	pusha0
	pusha1
		move.w	#$300,$ffff8240+2*8
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#4,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_static_col,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

clearrr
					move.l	screen1,a0
					add.w	#160*98,a0
					move.w	#4-1,d7
					moveq	#0,d0
.x1															;102
					REPT 40
						move.l	d0,(a0)+
					ENDR
					dbra	d7,.x1

					move.w	#20-1,d7						;122
					move.l	#%1111111111111111,d1
.x2
					REPT 20
						move.l	d0,(a0)+
						move.l	d1,(a0)+
					ENDR
					dbra	d7,.x2

					move.w	#77,d7					;
.x3
					REPT 40
						move.l	d0,(a0)+
					ENDR
					dbra	d7,.x3

					move.w	#$4e75,clearrr
					rts

timer_b_static_col
		move.w	#$300,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#20,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_static_col2,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte	

timer_b_static_col2
	pusha0
	pushd0
		lea		$ffff8240,a0
		move.l	#$7770777,d0
;		REPT 8
			move.w	d0,(a0)+
;		ENDR
	popd0
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#52+4,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_envmap_out_post,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte	

timer_b_envmap_out_post
	pusha0
	pushd0
		lea		$ffff8240,a0
		move.l	#$7770777,d0
		REPT 8
			move.l	d0,(a0)+
		ENDR
	popd0
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#25-4,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_envmap_out8,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte	



timer_b_envmap_out
	pusha0
	pusha1
		lea		omgoutpal,a0
		add.w	out0off,a0
		lea		$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#26,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_envmap_out1,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		palOutWaiter 0,PALOUT_DELAY_SLOW
	rte
out0offwaiter	dc.w	32000
out0off			dc.w	15*32

timer_b_envmap_out1
	pusha0
	pusha1
		lea		omgoutpal,a0
		add.w	out1off,a0
		lea		$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#26,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_envmap_out2,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		palOutWaiter 1,PALOUT_DELAY_QUICK
	rte
out1offwaiter	dc.w	32000
out1off			dc.w	15*32


timer_b_envmap_out2
	pusha0
	pusha1
		lea		omgoutpal,a0
		add.w	out2off,a0
		lea		$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#26,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_envmap_out3,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		palOutWaiter 2,PALOUT_DELAY_SLOW
	rte
out2offwaiter	dc.w	32000
out2off	dc.w	15*32

timer_b_envmap_out3
	pusha0
	pusha1
		lea		omgoutpal,a0
		add.w	out3off,a0
		lea		$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#24,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_envmap_out4,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		palOutWaiter 3,PALOUT_DELAY_QUICK
	rte
out3offwaiter	dc.w	32000
out3off	dc.w	15*32

timer_b_envmap_out4
	pusha0
	pusha1
		lea		omgoutpal,a0
		add.w	out4off,a0
		lea		$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#20,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_envmap_out5,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		palOutWaiter2 4,PALOUT_DELAY_SLOW
	rte
out4offwaiter	dc.w	32000
out4off	dc.w	15*32

omgoutpal
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$766,$766,$766,$766,$766,$766,$766,$766,$766,$766,$766,$766,$766,$766,$766,$766
	dc.w	$755,$755,$755,$755,$755,$755,$755,$755,$755,$755,$755,$755,$755,$755,$755,$755
	dc.w	$744,$744,$744,$744,$744,$744,$744,$744,$744,$744,$744,$744,$744,$744,$744,$744
	dc.w	$633,$633,$633,$633,$633,$633,$633,$633,$633,$633,$633,$633,$633,$633,$633,$633
	dc.w	$522,$522,$522,$522,$522,$522,$522,$522,$522,$522,$522,$522,$522,$522,$522,$522
	dc.w	$411,$411,$411,$411,$411,$411,$411,$411,$411,$411,$411,$411,$411,$411,$411,$411
	dc.w	$300,$300,$300,$300,$300,$300,$300,$300,$300,$300,$300,$300,$300,$300,$300,$300
	dc.w	$311,$311,$311,$311,$311,$311,$311,$311,$311,$310,$311,$311,$310,$300,$300,$300
	dc.w	$322,$322,$322,$322,$322,$321,$321,$322,$322,$320,$322,$322,$310,$300,$300,$300
	dc.w	$333,$333,$333,$333,$333,$331,$331,$333,$333,$330,$332,$322,$310,$300,$300,$300
	dc.w	$444,$444,$444,$443,$444,$431,$431,$344,$443,$340,$442,$222,$410,$400,$200,$300
	dc.w	$555,$555,$555,$553,$555,$531,$531,$344,$543,$350,$542,$222,$510,$400,$200,$200
	dc.w	$666,$665,$566,$653,$666,$531,$631,$344,$643,$350,$642,$122,$510,$400,$200,$100
	dc.w	$777,$765,$567,$753,$667,$531,$631,$344,$643,$350,$742,$122,$510,$400,$200,$000
	dc.w	$777,$765,$567,$753,$667,$531,$631,$344,$643,$350,$742,$122,$510,$400,$200,$000

timer_b_envmap_out5
	pusha0
	pusha1
		lea		omgoutpal,a0
		add.w	out5off,a0
		lea		$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#26,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_envmap_out6,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		palOutWaiter 5,PALOUT_DELAY_QUICK
	rte
out5offwaiter	dc.w	32000
out5off	dc.w	15*32

timer_b_envmap_out6
	pusha0
	pusha1
		lea		omgoutpal,a0
		add.w	out6off,a0
		lea		$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#26,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_envmap_out7,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		palOutWaiter 6,PALOUT_DELAY_SLOW
	rte
out6offwaiter	dc.w	32000
out6off	dc.w	15*32

timer_b_envmap_out7
	pusha0
	pusha1
		lea		omgoutpal,a0
		add.w	out7off,a0
		lea		$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#25,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_envmap_out8,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		palOutWaiter 7,PALOUT_DELAY_QUICK
	rte
out7offwaiter	dc.w	32000
out7off	dc.w	15*32

timer_b_envmap_out8
	move.w	#0,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
	rte


	IFEQ	STANDALONE
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
timer_b_open_curtain_stable_col
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

envmap_vbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	addq.w	#1,vblcount

		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_stable,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt


	IFEQ	STANDALONE
	pushall
		movem.l	omgpal+2,d0-d7
		movem.l	d0-d6,$fff8242
		swap	d7
		move.w	d7,$ffff8240+2*15


	    cmp.w	#1000,vblcount
	    bne		.kk
	    	moveq	#0,d0
	    	moveq	#0,d1
	    	move.w	vblcount,d0
	    	move.w	effectcount,d1
	    	move.b	#0,$ffffc123
.kk
	popall
	ENDC

	IFNE	STANDALONE
			pushall


	    jsr		musicPlayer+8
	    move.b	musicPlayer+$b8,d0
	    beq		.zip
	    	move.b	#0,musicPlayer+$b8
	    	add.w	#54,stepXmod+2
.zip
				sub.w	#1,stepXmod+2
				cmp.w	#15,stepXmod+2
				bge		.kk
					move.w	#15,stepXmod+2
.kk
	    	popall
	ENDC
	rte
.stepWaiter	dc.w	1
.doIt	dc.w	2

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

	ENDC



planarToChunky_text_envmap
;	lea		orig+128,a0
	move.l	omgpointer,a0
	add.w	#128,a0
	move.l	texturepointer_env,a1

	move.l	a1,a2
	sub.w	#$1000,a2
	move.w	#4096/4/4/4/4-1,d7
	moveq	#0,d0
.ddd
	REPT 64
		move.l	d0,(a2)+
	ENDR
	dbra	d7,.ddd


	move.l	#200-1,d6
	IFEQ	C2P_1PX
;	lea		orig+128,a0
	move.l	omgpointer,a0
	add.w	#128,a0
	move.l	#$04040404,a3
	ELSE
	move.l	#$06060606,a3
	ENDC
	add.w	#16,a0

.height
	move.l	#16-1,d7
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
		IFEQ	C2P_1PX
		add.w	d4,d4
		add.w	d4,d4
;			bne		*+4
;				moveq	#4,d4
		ELSE
		lsl.w	#3,d4
		addq.w	#6,d4
		ENDC
		move.b	d4,(a1)+					; 128 * 8 * 16 = 16k
	ENDR
	dbra	d7,.width



	; 320 width is 160 bytes
	; 128 width is 64 bytes 
	; 160-64 added
	add.w	#160-128,a0
	dbra	d6,.height						; 128 * ( 32*4 + 8*16 ) = 128 * (128+128) = 32768

	tst.w	.cont
	bne		.end
		move.w	#-1,.cont
		move.w	#56-1,d6
;		lea		orig+128,a0
		move.l	omgpointer,a0
		add.w	#128,a0
		jmp		.height

.end
	moveq	#0,d0
	move.w	#100-1,d7
.xxx
	REPT 32
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.xxx


	rts
.cont	dc.w	0





canvaswidth_envmap	equ 128

;clearCanvas_envmap
;	move.l	#$06060606,d0
;;	move.l	#$0e0e0e0e,d0
;	move.l	d0,d1
;	move.l	d0,d2
;	move.l	d0,d3
;	move.l	d0,d4
;	move.l	d0,d5
;	move.l	d0,d6
;	move.l	d0,d7
;	move.l	d0,a0
;	move.l	d0,a1
;	move.l	d0,a2
;	move.l	d0,a3
;	move.l	d0,a4
;	move.l	d0,a5
;
;;	lea		canvas,a6
;	move.l	canvasPointer_text_env,a6
;	; 128 x 128 bytes	= 16384			;d0-a5 = 14*4 = 56 = 16352
;.off set 0
;	REPT 292
;	movem.l	d0-a5,.off(a6)
;.off set .off+14*4
;	ENDR
;	;32 left
;	movem.l	d0-d7,.off(a6)
;	rts

clearCanvas_envmap_opt





	move.l	canvasPointer_text_env,a6
	move.w	yBot,d7		; finish
	move.w	yTop,d0		; start 
	sub.w	d0,d7		; number of lines =
	asl.w	#7,d0
	add.w	d0,a6
	move.w	d7,d0


	add.w	d0,d0	;2
	add.w	d0,d0	;4
	move.w	d0,d1			;6
	add.w	d0,d0	;8
	add.w	d1,d0			;14
	neg.w	d0
	add.w	#75*12,d0

	neg.w	d7
	add.w	#75,d7
	asl.w	#7,d7
	sub.w	d7,a6


	IFEQ	C2P_1PX
;		move.l	#$20202002,d1
		move.l	#$0,d1
	ELSE
	;	move.l	#$06060606,d1
		move.l	#$0e0e0e0e,d1
	ENDC
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	move.l	d1,a0
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5				; 14*4 = 56

;	lea		canvas,a6
	; 128 x 128 bytes	= 16384			;d0-a5 = 14*4 = 56 = 16352 128 bytes per line

;	move.b	#0,$ffffc123
	; d0 = number of loops
	jmp		.xx-2(pc,d0)
	nop
.xx	
.y set 0
	REPT 76
.x set .y
	movem.l	d1-a5,.x(a6)			;56			;4
	movem.l	d1-a5,.x+52(a6)			;112		;6
.y set .y+128
	ENDR

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

;equal equ 0											;					   .	10,30
;right equ 0											;
													;
													;
													;  \				 /
													;	2...............1
													;	.				.
													;	.				.
													;	.				.
													;	4...............3
													;  /				 \
; face normals	->


; fn(p1,p2,p3)
;	fx,fy,fz,p1*,p2*,p3*





; we have nonProjected and projected
; nonProjected:
;	face -> nonProjectedFaceNormal, nonProjectedVertex1,nonProjectedVertex2,nonProjectedVertex3
;
;	x	ds.w
;	y	ds.w
;	z	ds.w
;	v1	ds.l
;	v2	ds.l
;	v3	ds.l
;


;	projectedFace -> visibility, projectedVertex1, projectedVertex2, projectedVertex3

; nonProjectedVertex -> visibility,x,y,z
; projectedVertex -> x,y,u,v

; for rotation:
;	cull First
; a. create rotation matrix
; b. inverse rotation matrix for the face normals
; c. foreach facenormal
;	
;





yTop	dc.w	0
yBot	dc.w	75



;testtimes	dc.w	400
; optimization 1:	divs/muls gone
; optimization 2: 	innerloop construction smc using addx
; optimization 3:	order of registers, and using them smart
drawTriangle
	move.l	texturepointer_env,d6
	move.l	divtablepointer_env,a5			;20
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
dt_determineSpan
;;;;;;;;;;; determine max span
	; points sorted, top to bottom a1,a2,a3	
;------------------------------------------------------- determine y segments 
	move.w	2(a3),d5					;12		y3									move.w	(a3)+,d5		-4			;$39
	cmp.w	yBot,d5
	ble		.noNewBot
		move.w	d5,yBot
.noNewBot
	move.w	d5,d7						;4		
	move.w	2(a1),d4					;12		y1									move.w	(a1)+,d4		-4			;$06
	cmp.w	yTop,d4
	bge		.noNewTop
		move.w	d4,yTop
.noNewTop
	sub.w	d4,d7						;4		y3-y1																	;$33
	beq		.end						;		if 0, then quit
	move.w	d7,.y1_y3					;		save
	move.w	2(a2),d2					;12		y2									move.w	(a2)+,d2		-4			;$06
	move.w	d2,d3						;4		
	sub.w	d4,d2						;4		y2-y1
	move.w	d2,.y1_y2					;		save
	sub.w	d3,d5						;4		y3-y2
	move.w	d5,.y2_y3					;		save																	;$33
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

	lea		divTablePivot_env,a4			;8
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
	IFEQ	OPT_SMC_ENVMAP
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

	IFEQ	OPT_SMC_ENVMAP		; 8 or 16 bit precision for x?
smcLoopSize_t	equ -14
	ELSE
smcLoopSize_t	equ -18
	ENDC

	move.w	d7,d6
	bge		.noneg
		neg.w	d6
.noneg
;	muls	#smcLoopSize_t,d6
	move.w	d6,a6	
	asl.w	#3,d6
	IFEQ	OPT_SMC_ENVMAP
		sub.w	a6,d6
	ELSE
		add.w	a6,d6
	ENDC
	neg.w	d6
.kkk
	lea		.doSMCLoopEnd+0*smcLoopSize_t,a6	; 2 more than needed, because this way we prevent reading outside the texture, hax...
	lea		textMap+2+127*4,a4				; first load the end of the canvas table
	sub.w	2(a6,d6.w),a4					; then we rectify the table offset
	jmp		(a6,d6.w)						; and we need to load the proper address to a4, combined with the offset of the width span
.y1_y3		dc.w	0
.y1_y2		dc.w	0
.y2_y3		dc.w	0


.doSMCLoop
.offset set 0								; offset into the unrolled loop of 		move.b textoff(a0),-(a1)
	REPT 128
		IFEQ	OPT_SMC_ENVMAP
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
	move.l	canvasPointer_text_env,a6
	move.w	2(a1),d0						;8		get top y							move.w	-6(a1),d0
	asl.w	#7,d0							;18		canvas *128
	add.w	d0,a6							;8		add y offset to canvas
	tst.w	d7								;4		d7 is still span, but negative and positive determine where the 2nd point is
	blt		.middleRight
.middleLeft
	move.w	.y1_y2,d0		; y1_y2
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
		or.w	.y1_y3(pc),d7				;16		
		add.l	d7,d7						;4
		add.l	d7,d7						;4
		move.l	(a5,d7.l),a5				;20		a5 = dx/dy right x3-x1 / y3-y1

		add.w	d4,d4						;4
		swap	d1							;4
		sub.w	d1,d1						;4
		move.l	d1,d2						;4

		subq.w	#1,d0						;4			94 nop

		jsr		drawHLine_env
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
		move.w	.y2_y3,d0					;12		y3-y2				height
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

		jsr		drawHLine_env
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

	move.w	.y2_y3,d0						;16		y3-y2. height

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

	jsr		drawHLine_env
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
	move.w	.y1_y2,d0						;16		y1_y2
	beq		.two_top_right					; if 0 ==> then p1 and p2 top
		move.l	a2,-(sp)					;16		save a2
		move.l	a3,-(sp)					;16		save a3

		move.w	.y1_y3,d7					;16		height y1_y3												;15
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

		jsr		drawHLine_env
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

		move.w	.y2_y3,d0					;16		y3-y2
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
		jsr		drawHLine_env
.end
		move.l	(sp)+,a0
	rts
.two_top_right
	move.w	(a1),d1							;8		x1	startx left
	move.w	(a2),d2							;8		x2	endx right
	move.w	(a3),d6							;8		x3	
	move.w	d6,d7							;8		save

	move.w	.y1_y3,d0						;16		y3-y1
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

	jsr		drawHLine_env
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

drawHLine_env
	move.l	a6,d7													
	lea		textMap+127*4,a2
loop_env
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
textMap
		REPT 128
			move.b $1(a0),-(a6)
		ENDR
		add.w	#canvaswidth_envmap,d7				;8		
		add.l	a1,d1						;8		; 16.16 dx_left	
		add.l	a5,d2						;8		; 16.16 dx_right
		add.w	a4,d4						;4		; dv	x.8-8									
		add.l	a3,d5						;8		; dx	16.16			28 nop
	dbra	d0,loop_env
	move.l	d7,a6
	rts

; a0 table
; d0 x
; d1 1/x
;	lea		divTablePivot,a0
;	add.w	d0,d0
;	move.w	(a0,d0.w),d1
;	

initDivTable_em_pivot
	lea		divTablePivot_env,a0		;pos
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
        

initDivTable_em
	move.l	divtablepointer_env,a0
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
	move.w	#$4e75,initDivTable_em
	rts







;c2p_2to4_optimized_em													;16kbv
;
;;	lea		canvas,a0
;	move.l	canvasPointer_text_env,a0
;	move.l	screenpointer2,a6
;;	sub.w	#8,a6
;;	add.w	#20*160,a6
;	move.w	yBot,d7
;	move.w	yTop,d0
;	sub.w	d0,d7
;	move.w	d7,.counter
;	move.w	d0,d1
;	lsl.w	#7,d0
;	muls	#320,d1
;	add.w	d0,a0
;	add.w	d1,a6
;	lea		160(a6),a6
;
;
;	move.l	a6,usp
;;	move.w	#75,.counter
;.loop
;.off set 0
;;	REPT 75															;17kb, generate!
;			movem.w	(a0)+,a1-a6			;36				;6				;6 + 12 + 24. = 42 per 8 320 = 40 = 40*42*50		84000 cycles
;
;			move.l	(a1),d0				;12
;			or.l	-(a2),d0			;20		32
;
;			move.l	(a3),d1				;12
;			or.l	-(a4),d1			;20
;
;			move.l	(a5),d2				;12
;			or.l	-(a6),d2			;20				36 + 3*32
;
;			movem.w	(a0)+,a1-a6			;36
;
;			move.l	(a1),d3				;12
;			or.l	-(a2),d3			;20
;
;			move.l	(a3),d4				;12
;			or.l	-(a4),d4			;20
;
;			move.l	(a5),d5				;12	
;			or.l	-(a6),d5			;20				36 + 3*32	--> 264
;
;			movem.w	(a0)+,a1-a6			;36
;
;			move.l	(a1),d6				;12
;			or.l	-(a2),d6			;20
;
;			move.l	(a3),d7				;12
;			or.l	-(a4),d7			;20				;8*32 + 3*36 + 8*24 = 256+108+192=556 	--> 560 for 8*4 1:2 pixels 32
;
;			move.l	usp,a1				;4								104
;
;			movep.l	d0,.off+0(a1)		;24
;			movep.l	d1,.off+1(a1)		;24
;			movep.l	d2,.off+8(a1)		;24
;			movep.l	d3,.off+9(a1)		;24
;			movep.l	d4,.off+16(a1)		;24
;			movep.l	d5,.off+17(a1)		;24
;			movep.l	d6,.off+24(a1)		;24
;			movep.l	d7,.off+25(a1)		;24				8*24 = 			192
;
;			move.l	(a5),d0				;12
;			or.l	-(a6),d0			;20				32
;			movep.l	d0,.off+32(a1)		;24				24				56
;
;			movem.w	(a0)+,a1-a6			;36
;
;			move.l	(a1),d0				;12
;			or.l	-(a2),d0			;20
;
;			move.l	(a3),d1				;12
;			or.l	-(a4),d1			;20
;
;			move.l	(a5),d2				;12
;			or.l	-(a6),d2			;20				36 + 3*32		132
;
;			movem.w	(a0)+,a1-a6			;36
;
;			move.l	(a1),d3				;12
;			or.l	-(a2),d3			;20
;
;			move.l	(a3),d4				;12
;			or.l	-(a4),d4			;20
;
;			move.l	(a5),d5				;12
;			or.l	-(a6),d5			;20				36 + 3*32 		132
;
;			move.w	(a0)+,a1			;8
;			move.w	(a0)+,a2			;8
;
;			move.l	(a1),d6				;12
;			or.l	-(a2),d6			;20
;
;			move.l	usp,a1				;4								52
;
;			movep.l	d0,.off+33(a1)		;24
;			movep.l	d1,.off+40(a1)		;24
;			movep.l	d2,.off+41(a1)		;24		
;			movep.l	d3,.off+48(a1)		;24
;			movep.l	d4,.off+49(a1)		;24		
;			movep.l	d5,.off+56(a1)		;24
;			movep.l	d6,.off+57(a1)		;24				7*24			168		===> 1100 / 128 = 8,59375			68,75 per 8		
;
;.off set .off+64
;			movem.w	(a0)+,a1-a6			;36				;6				;6 + 12 + 24. = 42 per 8 320 = 40 = 40*42*50		8400
;			move.l	(a1),d0				;12
;			or.l	-(a2),d0			;20		32
;			move.l	(a3),d1				;12
;			or.l	-(a4),d1			;20
;			move.l	(a5),d2				;12
;			or.l	-(a6),d2			;20				36 + 3*32
;			movem.w	(a0)+,a1-a4			;36
;			move.l	(a1),d3				;12
;			or.l	-(a2),d3			;20
;			move.l	(a3),d4				;12
;			or.l	-(a4),d4			;20
;;			move.l	(a5),d5				;12	
;;			or.l	-(a6),d5			;20				36 + 3*32	--> 264
;;			movem.w	(a0)+,a1-a6			;36													
;;			move.w	(a0)+,a1
;;			move.w	(a0)+,a2
;;			move.l	(a1),d6				;12
;;			or.l	-(a2),d6			;20
;;			move.l	(a3),d7				;12
;;			or.l	-(a4),d7			;20		
;			move.l	usp,a1				;4								104
;			movep.l	d0,.off+0(a1)		;24
;			movep.l	d1,.off+1(a1)		;24
;			movep.l	d2,.off+8(a1)		;24
;			movep.l	d3,.off+9(a1)		;24
;			movep.l	d4,.off+16(a1)		;24
;;			movep.l	d5,.off+17(a1)		;24
;;			movep.l	d6,.off+24(a1)		;24
;			lea		44(a0),a0
;
;		movem.l	(a1)+,d0-d7/a2/a3/a4/a5		; 14 			;-4				;124
;		movem.l	d0-d7/a2/a3/a4/a5,-48+160(a1)									;124
;		movem.l	(a1)+,d0-d7/a2/a3		;60
;		movem.l	d0-d7/a2/a3,-40+160(a1)		;60
;
;
;.off set .off+160+160-64
;;	ENDR
;			add.w	#320-88,a1
;			move.l	a1,usp
;		subq.w	#1,.counter
;		bge		.loop
;
;	rts
;.counter 	dc.w 	0


;96 read
; 3* 92 write ==> 96+3*92 = 372 per line and this *4 = 1488 per unique line and we got 50 of them 74400


;copyLines_em
;	move.l	screenpointer2,a6
;	add.w	#160,a6
;;	add.w	#16,a6
;	move.b	#0,$ffffc123
;	REPT 	75																		;1.6k
;		movem.l	(a6)+,d0-d6/a0-a5		; 14 			;-4				;124
;		movem.l	d0-d6/a0-a5,-52+160(a6)									;124
;		movem.l	(a6)+,d0-d7/a0		;60
;		movem.l	d0-d7/a0,-36+160(a6)		;60
;		lea		160+160-88(a6),a6										;8		304 * 64 = 19456
;	ENDR
;	rts
;
;
;genCopyLines
;;	move.l	encCopyLinesPointer,a0
;	movem.l	.template,d0-d5
;	move.w	#75-1,d7
;.cp
;	movem.l	d0-d6,(a0)
;	lea		24(a0),a0
;	dbra	d7,.cp
;	move.w	#$4e75,(a0)+
;	rts
;
;.template
;		movem.l	(a6)+,d0-d6/a0-a5		; 14 			;-4				;124
;		movem.l	d0-d6/a0-a5,-52+160(a6)									;124
;		movem.l	(a6)+,d0-d7/a0		;60
;		movem.l	d0-d7/a0,-36+160(a6)		;60
;		lea		160+160-88(a6),a6	

; this generates a table using $602 and up
;
;	
generateOptimizedTabs_em
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

			lea		8(a0),a0				; 128 bytes each
			addq.w	#4,d0
		dbra	d6,.il
		addq.w	#4,d1
		lea     $0800-16*8(a0),a0				; $606 + 15*2048 = 31326
	dbra	d7,.ol
	rts


ymove	include	data/texture/ymove.s

	; normal:
	;	|	cosBcosC		cosCsinAsinB - cosAsinC		cosAcosCsinB + sinAsinC
	;	|	cosBsinC		cosAcosC + sinAsinBsinC		cosAsinBsinC - cosCsinA
	;	|	-sinB			cosBsinA					cosAcosB 

calculateRotatedProjection_envmap
	lea		_sintable512,a0
	lea		_sintable512+(sintable_size_envmap/4),a1

stepXmod
	add.w	#15,_currentStepX_env
	add.w	#11,_currentStepY_env
	add.w	#9,_currentStepZ_env
   
	move.w	_currentStepX_env,d2
	move.w	_currentStepY_env,d4
	move.w	_currentStepZ_env,d6



	and.w	#%1111111110,d2
	and.w	#%1111111110,d4
	and.w	#%1111111110,d6


;	move.w	#$AC,_currentStepX
;	add.w	#2,_currentStepY
;	add.w	#6,_currentStepZ


	move.w	(a0,d2.w),d1					; sinA	;around z axis		16
	move.w	(a1,d2.w),d2					; cosA						16

	move.w	(a0,d4.w),d3					; sinB	;around y axis		16
	move.w	(a1,d4.w),d4					; cosB						16

	move.w	(a0,d6.w),d5					; sinC	;around x axis		16
	move.w	(a1,d6.w),d6					; cosC						16

_sinA_em		equr d1
_cosA_em		equr d2
_sinB_em		equr d3
_cosB_em		equr d4
_sinC_em		equr d5
_cosC_em		equr d6

;	xx = [cosA * cosB]
	move.w	_cosA_em,d7
	muls	_cosB_em,d7
	swap	d7
	move.w	d7,a0
;	IFEQ	OPT_MULS
;		move.w	d7,.smc_xx+2
;	ENDC
;	xy = [sinA * cosB]
	move.w	_sinA_em,d7
	muls	_cosB_em,d7
;	lsl.l	#2,d7
	swap	d7
;	move.w	d7,_xy
	move.w	d7,a1
;	IFEQ	OPT_MULS
;		move.w	d7,.smc_xy+2
;	ENDC

;	xz = [sinB]	
;	move.w	_sinB,_xz
	move.w	_sinB_em,d7
	asr.w	#1,d7
	move.w	d7,a2
;	IFEQ	OPT_MULS
;		move.w	d7,.smc_xz+2
;	ENDC
;	yx = [sinA * cosC + cosA * sinB * sinC]
	move.w	_sinA_em,d7
	muls	_cosC_em,d7
	move.w	_cosA_em,d0
	muls	_sinB_em,d0
	add.l	d0,d0			;lsl 1
	swap	d0
	muls	_sinC_em,d0
	add.l	d7,d0
;	lsl.l	#2,d0
	swap	d0
;	move.w	d0,_yx	; sinA * cosC + cosA * sinB * sinC
	move.w	d0,a3
	IFEQ	OPT_MULS
;		move.w	d0,.smc_yx+2
	ENDC	
;	yy = [-cosA * cosC + sinA * sinB * sinC]
	move.w	_cosA_em,d7
	neg		d7
	muls	_cosC_em,d7
	move.w	_sinA_em,d0
	muls	_sinB_em,d0
	add.l	d0,d0			;lsl 1
	swap	d0
	muls	_sinC_em,d0
	add.l	d7,d0
;	lsl.l	#2,d0
	swap	d0
;	move.w	d0,_yy
	move.w	d0,a4
	IFEQ	OPT_MULS
		move.w	d0,.smc_yy+2
		IFEQ	ENVMAP
		move.w	d0,.smc_yy2+2
		ENDC
	ENDC	

;	yz = [-cosB * sinC]
	move.w	_cosB_em,d7
	neg.w	d7
	muls	_sinC_em,d7
;	lsl.l	#2,d7
	swap	d7
	IFEQ	OPT_MULS
		move.w	d7,.smc_yz+2
		IFEQ	ENVMAP
		move.w	d7,.smc_yz2+2
		ENDC
	ENDC	

;;	zx = [sinA * sinC - cosA * sinB * cosC]
	move.w	_sinA_em,d7
	muls	_sinC_em,d7
	move.w	_cosA_em,d0
	muls	_sinB_em,d0
	add.l	d0,d0			;lsl 1
	swap	d0
	muls	_cosC_em,d0
	sub.l	d0,d7
	swap	d7
	move.w	d7,_zx_env
;
;;	zy = [-cosA * sinC - sinA * sinB * cosC]
	move.w	_cosA_em,d7
	muls	_sinC_em,d7
	neg.l	d7
	move.w	_sinA_em,d0
	muls	_sinB_em,d0
	add.l	d0,d0			;lsl 1
	swap	d0
	muls	_cosC_em,d0
	sub.l	d0,d7
	swap	d7
	move.w	d7,_zy_env
;
;;	zz = [cosB * cosC]
	move.w	_cosB_em,d7
	muls	_cosC_em,d7
	swap	d7
	move.w	d7,_zz_env

	movem.l	a0-a2,_matrix
;	pushall
		jsr		cullFaces
;	popall
	movem.l	_matrix,a0-a2


	lea		ymove,a4
	move.l	canvas_y_offset,d0
	blt		.skipp
		divs	#80,d0
		add.w	d0,a4
.skipp
	move.w	(a4),.smc_text_y+2


	lea		currentNormals,a4
	lea		currentVertices,a5					;8	
	lea		points,a6

	move.w	number_of_vertices_env,d7
	subq.w	#1,d7
	move.w	#43,d5
	move.w	#37,d6




	; now determine the multiply value
	; a0	=	xx
	; a1	=	xy
	; a2	=	xz
	; a3	=	yx
	; a4	=	yy
	; _yz	=	yz
	; a5	=	vertices
	; a6	=	projected vertices
	; d0	=	x
	; d1	=	y
	; d2	=	z
	; d3	=	local
	; d4	=	local
	; d5	=	offsetx
	; d6	=	offsety
	; d7	=	loop counter

.rotate
		subq.w	#1,(a5)+
		blt		.skipvertex
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2		;24									movem.w	(a5)+,d0-d2

;	x'' = x * xx + y * xy + z * xz									lea		xxtozz,a4
		move.w	a0,d3			;4
		muls	d0,d3		;52
		move.w	a1,d4			;4
		muls	d1,d4		;52
		add.l	d4,d3			;8
		move.w	a2,d4			;4
		muls	d2,d4		;60
		add.l	d4,d3			;8
		swap	d3				;4							; can be removed	
		add.w	d5,d3			;4							; can be removed
		move.w	d3,(a6)+		;8			208				; can be removed

;	y'' = x * yx + y * yy + z * yz
		move.w	a3,d3
		muls	d3,d0		;54
;		move.w	a4,d3
.smc_yy
		muls	#$1234,d1		;50
.smc_yz	
		muls	#$1234,d2		;52
		add.l	d1,d0			;8
		add.l	d2,d0			;8

		swap	d0				;4
		add.w	d6,d0			;4
		move.w	d0,(a6)+		;8	--> 	188 --> 396
	IFEQ	ENVMAP
;;;;;;; DO NORMALS NOW

		move.w	(a4)+,d0
		move.w	(a4)+,d1
		move.w	(a4)+,d2		;24									movem.w	(a5)+,d0-d2

;	x'' = x * xx + y * xy + z * xz									lea		xxtozz,a4
		move.w	a0,d3			;4
		muls	d0,d3		;52

		move.w	a1,d4			;4
		muls	d1,d4		;52
		add.l	d4,d3			;8

		move.w	a2,d4			;4
		muls	d2,d4		;60
		add.l	d4,d3			;8
		asr.l	#1,d3

		swap	d3				;4							; can be removed	
		add.w	#138<<7,d3			;4							; can be removed
		and.w	#%1111111110000000,d3
		move.w	d3,(a6)+		;8			208				; can be removed

;	y'' = x * yx + y * yy + z * yz
		move.w	a3,d3
		muls	d3,d0		;54
.smc_yy2
		muls	#$1234,d1		;50
.smc_yz2
		muls	#$1234,d2		;52
		add.l	d1,d0			;8
		add.l	d2,d0			;8
		asr.l	#1,d0

		swap	d0				;4
.smc_text_y
		add.w	#128<<7,d0			;4
		and.w	#%1111111110000000,d0
		move.w	d0,(a6)+		;8	--> 	188 --> 396
	ELSE
		lea		4(a6),a6
	ENDC
	dbra	d7,.rotate
	jmp		.cont
.skipvertex
	IFEQ	ENVMAP
		lea		6(a4),a4
	ENDC
		lea		8(a6),a6
		lea		6(a5),a5
	dbra	d7,.rotate

.cont
	rts
_zx_env								ds.l	1
_zy_env								ds.l	1
_zz_env								ds.l	1
_matrix								ds.l	5

; this takes the rotation matrix, and inverts it, so we have an inverted camera matrix
	; normal:
	;	|	cosBcosC		cosCsinAsinB - cosAsinC		cosAcosCsinB + sinAsinC
	;	|	cosBsinC		cosAcosC + sinAsinBsinC		cosAsinBsinC - cosCsinA
	;	|	-sinB			cosBsinA					cosAcosB 

	; inverse:
	;	|	cosBcosC					cosBsinC					-sinB
	;	|	cosCsinAsinB - cosAsinC		cosAcosC + sinAsinBsinC		cosBsinA	
	;	|	cosAcosCsinB + sinAsinC		cosAsinBsinC - cosCsinA		cosAcosB 

	; thus now:
	;	x * xx + y * yx + z*zx
	;	x * xy + y * yy + z*zy
	;	x * xz + y * yz + z*zz

	; with:
	; a0	=	xx
	; a1	=	xy
	; a2	=	xz
	; a3	=	yx
	; a4	=	yy

	; camera can be modelled as -2048 = z

cullFaces
	move.w	#31*-1024,d5			;z
	move.w	_zx_env,d6
	muls.w	d5,d6
	swap	d6

	move.w	_zy_env,d4
	muls.w	d5,d4				;zy
	swap	d4
	move.w	d4,a5				; save

	move.w	_zz_env,d4
	muls.w	d5,d4				;zz
	swap	d4

	; d6 = z*zx
	; a5 = z*zy
	; d4 = z*zz
	lea		sourceFaces,a0
	lea		destFaces,a1
	moveq	#1,d7
	move.w	number_of_faces,d3
	subq.w	#1,d3
.determineCull
	move.w	(a0)+,d0	;source x
	move.w	(a0)+,d1	;source y
	move.w	(a0)+,d2	;source z

	sub.w	d6,d0		;camera z*zx
	sub.w	a5,d1		;camera	z*zy
	sub.w	d4,d2		;camera z*zz

	muls	(a0)+,d0
	muls	(a0)+,d1
	muls	(a0)+,d2

	add.l	d1,d0
	add.l	d2,d0
	blt		.notVisible
.visible
		move.l	(a0)+,a2
		move.w	d7,(a2)
		move.l	(a0)+,a2
		move.w	d7,(a2)
		move.l	(a0)+,a2
		move.w	d7,(a2)
		move.w	d7,(a1)
		lea		14(a1),a1

		dbra	d3,.determineCull
		rts

.notVisible
		lea		3*4(a0),a0
		lea		14(a1),a1
		dbra	d3,.determineCull
		rts

;number_of_faces		dc.w	2
;
;sourceFaces
;	dc.w	-40*4,-25*4,0		; vertex for comparison
;	dc.w	0,0,-32000			; face normal
;	dc.l	currentVertices		; source vertex for marking 1
;	dc.l	currentVertices+8	; source vertex for marking 1
;	dc.l	currentVertices+16	; source vertex for marking 1
;
;	dc.w	-40*4,-25*4,0		; vertex for comparison
;	dc.w	0,0,-32000			; face normal
;	dc.l	currentVertices+8	; source vertex for marking 1
;	dc.l	currentVertices+16	; source vertex for marking 1
;	dc.l	currentVertices+24	; source vertex for marking 1
;
;destFaces
;	dc.w	0
;	dc.l	point3,point2,point1		; --> proper order top-> bot = p3,p2,p1
;	dc.w	0
;	dc.l	point2,point3,point4		; --> proper order top-> bot = p3,p2,p1
;
;
;ddd equ	32768-1
;
;currentNormals	
;
;				dc.w	-ddd,-ddd,-ddd		;1
;				dc.w	ddd,-ddd,-ddd		;2
;				dc.w	-ddd,ddd,-ddd		;3
;				dc.w	ddd,ddd,-ddd		;4
;
;currentVertices	
;
;				dc.w	0,-40*4,-25*4,8				;  1.................2
;				dc.w	0,41*4,-25*4,8				;	 .....
;				dc.w	0,-40*4,26*4,8				;		  .....     .
;												;			   ......3
;
;				dc.w	0,41*4,26*4,8				;	1...
;													;	.  ......        
;													;	.        .......
;													;  4.................3
;
;
;points
;point1	dc.w	54,4,84<<7,115<<7
;point2	dc.w	4,4,175<<7,115<<7
;point3	dc.w	64,54,84<<7,64<<7
;point4	dc.w	4,54,175<<7,64<<7
;
;
;trianglePointers	dc.l	point3,point2,point1		; --> proper order top-> bot = p3,p2,p1
;					dc.l	point2,point3,point4		; --> proper order top-> bot = p3,p2,p1


;nr_of_vertices	dc.w	verticesnr

	include	gfx/textmap/object2-23.s
;	include	gfx/textmap/object4.s
;	include	gfx/textmap/object2z.s



fadePall
	dc.w	$777
	dc.w	$766
	dc.w	$755
	dc.w	$744
	dc.w	$644
	dc.w	$633
	dc.w	$533
	dc.w	$522
	dc.w	$422
	dc.w	$411
	dc.w	$311
	dc.w	$300
	dc.w	$300
fadePallOff
	dc.w	22


drawTriangles
	lea		fadePall,a0
	add.w	fadePallOff,a0
	move.w	(a0),timer_b_static_col+2
	subq.w	#2,fadePallOff
	bge		.kkkk
		move.w	#0,fadePallOff
.kkkk
	

    lea		pointsa,a6
    movem.l	(a6),d0-d2
    jsr		drawTrianglea
    jsr		drawLinesA

    sub.w	#1,points0a+2
    cmp.w	#98,points0a+2
    bge		.k2
    	move.w	#98,points0a+2
.k2


    lea		points0a,a6
    movem.l	(a6),d0-d2
    jsr		drawTrianglea
    jsr		drawLinesA

    add.w	#4,pointsa+10
    cmp.w	#170,pointsa+10
    ble		.k1
    	move.w	#170,pointsa+10
.k1


    lea		points2a,a6
    movem.l	(a6),d0-d2
    jsr		drawTrianglea
    jsr		drawLinesA

    add.w	#4,points2a+10
    cmp.w	#170,points2a+10
    ble		.k13
    	move.w	#170,points2a+10
    	move.w	#$4e75,drawTriangles
.k13



    lea		points1a,a6
    movem.l	(a6),d0-d2
    jsr		drawTrianglea
    jsr		drawLinesA

    sub.w	#1,points1a+2
    cmp.w	#98,points1a+2
    bge		.k233
    	move.w	#98,points1a+2
.k233

    rts


points0a
	dc.w	0,102	;99
	dc.w	0,103
	dc.w	118,103

pointsa
	dc.w	0,121
	dc.w	118,121				; dy = 49, dx = 118		dx/dy = 2,428571428571429
	dc.w	0,122	;170

points1a
	dc.w	319,102
	dc.w	203,103
	dc.w	319,103

points2a
	dc.w	203,121
	dc.w	319,121
	dc.w	319,122	;170

; we always traverse from top to bottom, its a triangle
drawTrianglea
;	lea		point1,a0
;	lea		point2,a1
;	lea		point3,a2
; sort from top to bot
;	move.l	(a0),d0
;	move.l	(a1),d1
;	move.l	(a2),d2

.go
	moveq	#0,d4
	cmp.w	d0,d1
	bge		.ok1
		exg		d0,d1
		moveq	#-1,d4
.ok1
	cmp.w	d1,d2
	bge		.ok2
		exg		d1,d2
		moveq	#-1,d4
.ok2
	tst.w	d4
	bne		.go
.sorted
; determine case, two top, or two bot
	cmp.w	d0,d1
	beq		.twotop
.onetop
; make d1 left
	cmp.l	d1,d2
	bge		.okx2
		exg		d1,d2
.okx2

	move.l	d0,a0		;top
	move.l	d1,a1		;left bot
	move.l	d2,a2		;right bot
;--------------------------------
; determine dy height
		move.l	a1,d6			; left
		ext.l	d6				; take y
		sub.w	a0,d6			; height
		ext.l	d6
;--------------------------------
; determine dx left
		move.l	a0,d5			; topd5
		swap	d5				; get x
		move.l	a1,d4			; left bottom
		swap	d4				; get x
		sub.w	d5,d4			; left dx			
		ext.l	d4				; dx left
;--------------------------------
; calc slopes dx_left / dy
		asl.l	#8,d4			; left dx<<8
		divs	d6,d4			; dx/dy left
		ext.l	d4
		asl.l	#8,d4			; left dx<<8		16.16
;--------------------------------
; determine dx right
		move.l	a2,d3			; right
		swap	d3				; right x
		sub.w	d5,d3			; 
		ext.l	d3
;--------------------------------
; calc slopes dx_left / dy_left
		asl.l	#8,d3			; left dx<<8
		divs	d6,d3			; dx/dy left
		ext.l	d3				;
		asl.l	#8,d3			; left dx<<8		16.16
;----------------------------------
	; d6 = dy
	; d3 = dx - right
	; d4 = dx - left
	subq.w	#1,d6
	blt		.end
	move.w	a0,d5
	muls	#160,d5			; y off

	move.l	a0,d0
	sub.w	d0,d0			; d0 is position for left
	move.l	d0,d1			; d1 is position for right
	move.l	spandataPtr,a0
;	lea		spandata,a0		; span for left	
	move.w	d5,(a0)+
.loop
		swap	d0
		swap	d1
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		swap	d0
		swap	d1
		add.l	d4,d0
		add.l	d3,d1
	dbra	d6,.loop
	move.l	#-1,(a0)+
	rts

.twotop
; make d0 left
	cmp.l	d0,d1
	bge		.okx
		exg		d0,d1
.okx
	; so we have 2 top now, determine dy
	move.l	d0,a0		;top
	move.l	d1,a1		;left bot
	move.l	d2,a2		;right bot
;--------------------------------
; determine dy height
		move.l	a2,d6			; bottom
		ext.l	d6				; take y
		sub.w	a0,d6			; height
		ext.l	d6								; dy
;--------------------------------
; determine dx left
		move.l	a0,d5			; top
		swap	d5				; get x
		move.l	a2,d4			; left bottom
		swap	d4				; get x
		sub.w	d5,d4			; left dx			
		ext.l	d4				; dx left
;--------------------------------
; calc slopes dx_left / dy
		asl.l	#8,d4			; left dx<<8
		divs	d6,d4			; dx/dy left
		ext.l	d4
		asl.l	#8,d4			; left dx<<8		16.16
;--------------------------------
; determine dx right
		move.l	a2,d3			; right
		swap	d3				; right x
		move.l	a1,d5
		swap	d5
		sub.w	d5,d3			; 
		ext.l	d3
;--------------------------------
; calc slopes dx_left / dy_left
		asl.l	#8,d3			; left dx<<8
		divs	d6,d3			; dx/dy left
		ext.l	d3				;
		asl.l	#8,d3			; left dx<<8		16.16
;----------------------------------
	; d6 = dy
	; d3 = dx - right
	; d4 = dx - left
	subq.w	#1,d6
	blt		.end
	move.w	a0,d5
	muls	#160,d5			; y off

	move.l	a0,d0
	sub.w	d0,d0			; d0 is position for left
	move.l	a1,d1
	sub.w	d1,d1
;	lea		spandata,a0		; span for left	
	move.l	spandataPtr,a0
	move.w	d5,(a0)+
.loop2
		swap	d0
		swap	d1
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		swap	d0
		swap	d1
		add.l	d4,d0
		add.l	d3,d1
	dbra	d6,.loop2
	move.l	#-1,(a0)+
	rts

.end
	move.l	#-1,(a0)+
	rts
	

drawLinesA
	lea		hLines,a3
	move.l	screen1,a5
	add.w	#6,a5
;	lea		spandata,a1
	move.l	spandataPtr,a1
	move.l	maskRightPtr,d1
	move.l	maskLeftPtr,d2

	add.w	(a1)+,a5
	moveq	#-1,d0
.next
	move.w	(a1)+,d4	;left
	blt		.end
	move.w	(a1)+,d3	;right

		move.l	a5,a6

		add.w	d4,d4
		add.w	d4,d4		;4

		add.w	d3,d3
		add.w	d3,d3		;4

;		lea		maskLeft,a2		; get mask table
		move.l	d2,a2
		add.w	d4,a2			; add x left to mask table
		move.w	(a2)+,d6		; get offset x left
		add.w	d6,a6			; add offset to screen
		move.w	(a2)+,d5		; left mask
;		lea		maskRight,a2
		move.l	d1,a2
		add.w	d3,a2
		move.w	(a2)+,d7	; offset
		move.w	(a2)+,d3		; mask right
		sub.w	d6,d7		; difference in steps
		move.l	(a3,d7),a4
		jsr		(a4)
		jmp		.next




.end
	rts

	


hLines
	dc.l	zhlineCode0,zhlineCode0
	dc.l	zhlineCode1,zhlineCode1
	dc.l	zhlineCode2,zhlineCode2
	dc.l	zhlineCode3,zhlineCode3
	dc.l	zhlineCode4,zhlineCode4
	dc.l	zhlineCode5,zhlineCode5
	dc.l	zhlineCode6,zhlineCode6
	dc.l	zhlineCode7,zhlineCode7
	dc.l	zhlineCode8,zhlineCode8
	dc.l	zhlineCode9,zhlineCode9
	dc.l	zhlineCode10,zhlineCode10
	dc.l	zhlineCode11,zhlineCode11
	dc.l	zhlineCode12,zhlineCode12
	dc.l	zhlineCode13,zhlineCode13
	dc.l	zhlineCode14,zhlineCode14
	dc.l	zhlineCode15,zhlineCode15
	dc.l	zhlineCode16,zhlineCode16

postLineCode	macro
	lea		160(a5),a5
	rts
	endm

zhlineCode0
	and.w	d5,d3
	or.w	d3,(a6)
			postLineCode

zhlineCode1
	or.w	d5,(a6)
	or.w	d3,8(a6)
			postLineCode

zhlineCode2
	or.w	d5,(a6)
	move.w	d0,8(a6)
	or.w	d3,16(a6)
			postLineCode

zhlineCode3
	or.w	d5,(a6)
	move.w	d0,8(a6)
	move.w	d0,16(a6)
	or.w	d3,24(a6)
			postLineCode

zhlineCode4
	or.w	d5,(a6)
.x set 8
	REPT 3
	move.w	d0,.x(a6)
.x set .x+8
	ENDR
	or.w	d3,.x(a6)
			postLineCode

zhlineCode5
	or.w	d5,(a6)
.x set 8
	REPT 4
	move.w	d0,.x(a6)
.x set .x+8
	ENDR
	or.w	d3,.x(a6)
			postLineCode

zhlineCode6
	or.w	d5,(a6)
.x set 8
	REPT 5
	move.w	d0,.x(a6)
.x set .x+8
	ENDR
	or.w	d3,.x(a6)
			postLineCode

zhlineCode7
	or.w	d5,(a6)
.x set 8
	REPT 6
	move.w	d0,.x(a6)
.x set .x+8
	ENDR
	or.w	d3,.x(a6)
			postLineCode

zhlineCode8
	or.w	d5,(a6)
.x set 8
	REPT 7
	move.w	d0,.x(a6)
.x set .x+8
	ENDR
	or.w	d3,.x(a6)
			postLineCode

zhlineCode9
	or.w	d5,(a6)
.x set 8
	REPT 8
	move.w	d0,.x(a6)
.x set .x+8
	ENDR
	or.w	d3,.x(a6)
			postLineCode

zhlineCode10
	or.w	d5,(a6)
.x set 8
	REPT 9
	move.w	d0,.x(a6)
.x set .x+8
	ENDR
	or.w	d3,.x(a6)
			postLineCode

zhlineCode11
	or.w	d5,(a6)
.x set 8
	REPT 10
	move.w	d0,.x(a6)
.x set .x+8
	ENDR
	or.w	d3,.x(a6)
			postLineCode

zhlineCode12
	or.w	d5,(a6)
.x set 8
	REPT 11
	move.w	d0,.x(a6)
.x set .x+8
	ENDR
	or.w	d3,.x(a6)
			postLineCode

zhlineCode13
	or.w	d5,(a6)
.x set 8
	REPT 12
	move.w	d0,.x(a6)
.x set .x+8
	ENDR
	or.w	d3,.x(a6)
			postLineCode

zhlineCode14
	or.w	d5,(a6)
.x set 8
	REPT 13
	move.w	d0,.x(a6)
.x set .x+8
	ENDR
	or.w	d3,.x(a6)
			postLineCode

zhlineCode15
	or.w	d5,(a6)
.x set 8
	REPT 14
	move.w	d0,.x(a6)
.x set .x+8
	ENDR
	or.w	d3,.x(a6)
			postLineCode

zhlineCode16
	or.w	d6,(a6)
.x set 8
	REPT 3
	move.w	d0,.x(a6)
.x set .x+8
	ENDR
	or.w	d2,.x(a6)
			postLineCode

maskLeftA
.x set 0
	REPT 20
	dc.w	.x,%1111111111111111
	dc.w	.x,%111111111111111
	dc.w	.x,%11111111111111
	dc.w	.x,%1111111111111
	dc.w	.x,%111111111111
	dc.w	.x,%11111111111
	dc.w	.x,%1111111111
	dc.w	.x,%111111111
	dc.w	.x,%11111111
	dc.w	.x,%1111111
	dc.w	.x,%111111
	dc.w	.x,%11111
	dc.w	.x,%1111
	dc.w	.x,%111
	dc.w	.x,%11
	dc.w	.x,%1
.x set .x+8
	ENDR				;20*16*4 = 80

maskRightA
.x set 0
	REPT 20
	dc.w	.x,%1000000000000000
	dc.w	.x,%1100000000000000
	dc.w	.x,%1110000000000000
	dc.w	.x,%1111000000000000
	dc.w	.x,%1111100000000000
	dc.w	.x,%1111110000000000
	dc.w	.x,%1111111000000000
	dc.w	.x,%1111111100000000
	dc.w	.x,%1111111110000000
	dc.w	.x,%1111111111000000
	dc.w	.x,%1111111111100000
	dc.w	.x,%1111111111110000
	dc.w	.x,%1111111111111000
	dc.w	.x,%1111111111111100
	dc.w	.x,%1111111111111110
	dc.w	.x,%1111111111111111
.x set .x+8
	ENDR

maskLeftPtr		ds.l	1
maskRightPtr	ds.l	1
spandataPtr		ds.l	1

genMaskLeftRight
	move.l	maskLeftPtr,a0
	moveq	#0,d0
	move.w	#20-1,d7
.oloop
	moveq	#-1,d1
	REPT 16
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		lsr.w	d1
	ENDR
	addq.w	#8,d0
	dbra	d7,.oloop

	move.l	maskRightPtr,a0
	moveq	#0,d0
	move.w	#20-1,d7
	move.w	#%1<<15,d2
.oloop2
	move.w	d2,d1
	REPT 16
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		asr.w	d1
	ENDR
	addq.w	#8,d0
	dbra	d7,.oloop2
	rts


	SECTION DATA
	IFEQ	STANDALONE
_sintable512	include	"data/sintable_amp32768_steps512.s"
	ENDC

omgpal	
	dc.w	$777,$765,$567,$753,$667,$531,$631,$344,$643,$350,$742,$122,$510,$400,$200,$000

omgcrk	incbin	"gfx/omg!/omg80px2.crk"
	even
;--------------
;DEMOPAL - palette from neo is loaded
;--------------		
;orig	incbin	"gfx/omg!/omg! 80px free.neo"				;runched 32128 to 18519 bytes

	IFEQ STANDALONE
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

texturepointer_env		ds.l	1
divtablepointer_env		ds.l	1

tab1px_1p_env					ds.l	1
tab1px_2p_env					ds.l	1	
tab1px_3p_env					ds.l	1	
tab1px_4p_env					ds.l	1	
canvasPointer_text_env			ds.l	1
c2pPointerEnv					ds.l	1		;18586


_currentStepX_env		ds.w	1
_currentStepY_env		ds.w	1
_currentStepZ_env		dc.w	64



	ds.w	128
divTablePivot_env	
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
effectcount			ds.w	1
cummulativeCount	ds.w	1
	ENDC

