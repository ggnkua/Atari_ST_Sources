;
;
;	'arundhati roy'
;
;	128 byte intro, 6th october 1998
;
;	original effect code: azure (amiga)
;	porting/fiddling steve tattersall
;
;

;------------------------------------------------------------------------------
; ASSEMBLY SETTINGS

debug			equ	1	; 1 = big version
MonST			equ	0	; to run correctly under MonST

;------------------------------------------------------------------------------
; the demo is pc-relative to save on the size of the depack code...
;

		ifeq	debug
		 opt	p+			;must be pc-relative
		 opt	nodebug			;to be small
		 output	arund030.tos

		else
		 opt	p-
		 opt	nodebug
		 output	lardarse.tos
		endc

; -------------------------------------------------------------------------

		ifne	debug
		 clr.l	-(a7)
		 move.w	#$20,-(a7)
		 trap	#1
		 move.l	d0,save_stack
		 move.l	$44e.w,save_44e		;ulp
		 move.l	#screen_space,d0
		 sub.b	d0,d0

		 move.w	#$24,-(a7)
		 move.w	#3,-(a7)
		 move.l	d0,-(a7)
		 move.l	d0,-(a7)
		 move.w	#5,-(a7)
		 trap	#14
		 lea	14(a7),a7
		endc

;------------------------------------------------------------------------------
start:

water_size	=	160*100

start_code:
		ifne	MonST
		 move.w	#3,-(a7)		;3 for MonST
		else
		 move.w	#2,-(a7)		;2 for "normal"
		endc
		trap	#14
		addq.l	#2,a7

		add.l	#50*320*2,d0		;"deZign"
		move.l	d0,a6			;a6 = screen phys address

		lea	water_buffer_1(pc),a5	;a5 = buffer 1
		lea.l	(a5,water_size*2.l),a4	;a4 = buffer 2
		move.l	d7,d2			;damping
		move.l	#$004f001f,d3

; I need a colour table that goes from x to y, then stays at y
; blue is the obvious choice. say from $1f to $ffff?
; This table is put on the STACK!!


;------------------------------------------------------------------------------
water_loop:

; draw a random droplet:
; this draws off the end of memory??

		moveq	#11,d5
.loop
		ror.w	d7,d7
		add.w	#$4f37,d7
		add.w	d1,d7

		lea	(a4,d7.l*2),a2
		add.w	d3,(a2)+
		add.w	d3,-160*2(a2)
		add.w	d3,+160*2(a2)
		add.l	d3,(a2)+
		dbf	d5,.loop

		move.l	a6,a3
		move.l	a5,a1
		lea	-2(a4),a2

; can i get away with not setting this value?
		move.w	#water_size-1,d0	;about 64000 ;)

	;----------------------------------------------
.loop2:
		move.w	(a2)+,d1		;from buffer 1
		add.w	-160*2(a2),d1
		add.w	+160*2(a2),d1
		add.w	+2(a2),d1
		asr.w	d1
		sub.w	(a1),d1
		spl	d2
		and.w	d2,d1			;damping
						;must be +ve
		move.w	d1,(a1)+		;into buffer 2

		; draw on screen:
		cmp.w	d3,d1
		ble.s	.ok
		move.w	d3,d1
.ok:
		ror.w	#5,d1
		move.l	d1,(a3)+		;on screen
		swap	d1
	dbf	d0,.loop2
	

	;----------------------------------------------
		exg.l	a4,a5			; swap the buffers

		ifeq	debug
		 bra.s	water_loop
		else
		 cmp.b	#$39,$fffffc02.w
		 bne.s	water_loop
		endc


;------------------------------------------------------------------------------

		ifne	debug
		 move.w	#1,-(a7)
		 move.l	save_44e(pc),-(a7)
		 move.l	save_44e(pc),-(a7)
		 move.w	#5,-(a7)
		 trap	#14
		 lea	12(a7),a7

		 clr.w	-(a7)
		 trap	#1
		endc

endcode:

			;------------------------------------------------------------------------------
			section	bss
;------------------------------------------------------------------------------

			ifne	debug
save_stack:		ds.l	1
save_44e		ds.l	1
			endc

			ds.w	320
water_buffer_1:
			ds.w	65536
			ds.w	65536
			ds.w	320

			ds.b	256
screen_space:		ds.w	320*240