
		section	text


;---------------------------------------------------------------------------------------------

conv_24_to_16:		

; converts 24bit palette to 16bit falcon hicolour
;
; in:		a0 = source rgb (3 byte per col)
;		a1 = dest buffer (size=number of colours*2)
;		d0.w = number of colours to convert-1
;
; 	example to convert palette of apex 8bit block (256 cols)
;
;		lea.l	apxpic+20,a0
;		lea.l	dest,a1
;		move.w	#256-1,d0
;		bsr.w	conv_24_to_16


.loop:		moveq.l	#0,d1					;clear dregs
		moveq.l	#0,d2					;
		moveq.l	#0,d3					;

		move.b	(a0)+,d1				;source red
		move.b	(a0)+,d2				;source green
		move.b	(a0)+,d3				;source blue
		lsr.b	#3,d1					;red 8bit->5bit
		ror.w	#5,d1					;red position
		lsr.b	#2,d2					;green 8bit->6bit
		rol.w	#5,d2					;green position
		or.w	d2,d1					;join red+green
		lsr.b	#3,d3					;blue 8bit->5bit
		or.b	d3,d1					;join red+green+blue
		move.w	d1,(a1)+				;store pixel

		dbra	d0,.loop

		rts



;---------------------------------------------------------------------------------------------

make_alphapal:

; fades 16bit pixel to other 16bit pixel with 64 steps
; output is "doubled" for fast doublepixel emulation
; ie: input pal = 256 cols, output = 512 cols
;
; output buffer looks like:
; 
; sourcepal  col0col0 col1col1 col2col2 col3col3 col4col4
;             ||  ||   ||  ||   ||  ||   ||  ||   ||  ||
;             ||  ||   ||  ||   ||  ||   ||  ||   ||  ||
;             ||  ||   ||  ||   ||  ||   ||  ||   ||  ||
; 64 steps    ||  ||   ||  ||   ||  ||   ||  ||   ||  ||
;             ||  ||   ||  ||   ||  ||   ||  ||   ||  ||
;             ||  ||   ||  ||   ||  ||   ||  ||   ||  ||
;             ||  ||   ||  ||   ||  ||   ||  ||   ||  ||
; destpal    col0col0 col1col1 col2col2 col3col3 col4col4
;
;
; in:		a0 = source 16bit palette
;		a1 = dest 16bit palette
;		a2 = start of fade buffer (size=number of colours*2*2*64)
;		d0.w = number of colours to fade-1
;
;	example to make alphapal with 256 colours
;
;		lea.l	sourcepal,a0
;		lea.l	destpal,a1
;		lea.l	buffer,a2
;		move.w	#255,d0
;		bsr.w	make_alphapal


;-------------- copy palettes to buffer ------------------------
		move.l	a2,a3					;buffer first line
		move.l	a2,a4					;
		moveq.l	#0,d1					;
		move.w	d0,d1					;colours
		addq.w	#1,d1					;+1
		lsl.w	#2,d1					;*4=width
		mulu.w	#63,d1					;*steps
		add.l	d1,a4					;buffer last line
		move.w	d0,d1					;number of colours
.copy:		move.w	(a0)+,d2				;copy start colousr
		move.w	(a1)+,d3				;copy end colours
		move.w	d2,(a3)+				;
		move.w	d3,(a4)+				;
		move.w	d2,(a3)+				;
		move.w	d3,(a4)+				;
		dbra	d1,.copy

;-------------- do the actual 64step fade ----------------------
		moveq.l	#0,d1					;calc width of colours
		move.w	d0,d1					;number of cols
		addq.w	#1,d1					;+1
		lsl.w	#2,d1					;*wordperpoint*doublepixel
		move.l	d1,.width				;store

		move.l	a2,a3					;buffer first line
		move.l	a2,a4					;
		mulu.w	#63,d1					;buffer last line calc
		add.l	d1,a4					;

		moveq.l	#0,d1					;clear dregs
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7

.colour:

		move.l	a3,a5					;dest

		move.w	(a3),d1
		addq.l	#4,a3
		bfextu	d1{16:5},d2				;source red
		bfextu	d1{21:6},d3				;source green
		bfextu	d1{27:5},d4				;source blue

		move.w	(a4),d1
		addq.l	#4,a4
		bfextu	d1{16:5},d5				;dest red
		bfextu	d1{21:6},d6				;dest green
		bfextu	d1{27:5},d7				;dest blue

		fmove.x	#0,fp0					;clr fregs
		fmove.x	fp0,fp5					;
		fmove.l	d2,fp2					;blue start col
		fmove.l	d5,fp0					;blue end col
		fsub.x	fp2,fp0					;get steps that need fading
		beq.s	.blueok					;if zero -> done
		fdiv.x	#31,fp0					;number of steps we want
		fmove.x	fp0,fp5					;blue add value
.blueok:		
		fmove.x	#0,fp0					;clr fregs
		fmove.x	fp0,fp6					;
		fmove.l	d3,fp3					;green start col
		fmove.l	d6,fp0					;green end col
		fsub.x	fp3,fp0					;get steps that need fading
		beq.s	.greenok				;if zero -> done
		fdiv.x	#63,fp0					;number of steps we want
		fmove.x	fp0,fp6					;green add value
.greenok:		
		fmove.x	#0,fp0					;clr fregs
		fmove.x	fp0,fp7					;
		fmove.l	d4,fp4					;red start col
		fmove.l	d7,fp0					;red end col
		fsub.x	fp4,fp0					;get steps that need fading
		beq.s	.redok					;if zero -> done
		fdiv.x	#31,fp0					;number of steps we want
		fmove.x	fp0,fp7					;red add value
.redok:		
		swap	d0
		move.w	#62-1,d0				;steps-2 (start/end pals excluded)
.step:

.red:		tst.w	.var					;set? onle green this round
		bne.s	.green					;
		fadd.x	fp5,fp2					;add red
		fmove.b	fp2,d2					;store red
.green:		fadd.x	fp6,fp3					;add green
		fmove.b	fp3,d3					;store green
.blue:		tst.w	.var					;set? only green this round
		bne.s	.mix					;
		fadd.x	fp7,fp4					;add blue
		fmove.b	fp4,d4					;store blue

.mix:		bfins	d2,d1{16:5}				;mix red
		bfins	d3,d1{21:6}				;mix green
		bfins	d4,d1{27:5}				;mix blue

		move.l	d0,-(sp)				;save d0
		move.l	.width,d0				;get width of colours
		move.w	d1,(a5,d0.w)				;store 
		move.w	d1,(a5,d0+2.w)				;store doublepixel
		lea.l	(a5,d0.w),a5 				;next step
		move.l	(sp)+,d0				;restore d0

		not.w	.var					;enable/disable red/blue

		dbra	d0,.step
		swap	d0
		dbra	d0,.colour

		rts

.var:		ds.w	1					;skip red/blue if set
.width:		ds.l	1					;converted colours width




;---------------------------------------------------------------------------------------------

make_alphapic:

; 8bit chunky zoomed to 1024byte steps (1=1024 2=2048 etc)
;
; in:		a0 = source/dest pic (64 grey levels)
;		d0.w = xres-1
;		d1.w = yres-1
;
; out:		output is twice as large as input, so be sure that
;		there are space after the source!!
;
;	example to convert a 256*256 texture
;
;		lea.l	texture,a0
;		move.w	#256-1,d0
;		move.w	#256-1,d1
;		bsr.w	make_alphapic

		moveq.l	#0,d2					;
		move.w	d0,d2					;x
		addq.w	#1,d2
		move.w	d1,d3
		addq.w	#1,d3
		mulu.w	d3,d2					;*y
		add.l	d2,a0
		move.l	a0,a1
		add.l	d2,a1

.yloop:		move.w	d0,d2					;x counter
.xloop:		moveq.l	#0,d3					;clear dreg
		move.b	-(a0),d3				;get 8bit source
		mulu.w	#256,d3
		move.w	d3,-(a1)				;store word pixel
		dbra	d2,.xloop
		dbra	d1,.yloop

		rts


