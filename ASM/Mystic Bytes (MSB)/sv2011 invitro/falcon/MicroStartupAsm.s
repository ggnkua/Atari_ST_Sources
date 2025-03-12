
        ;xdef    ___main
        xdef    ___cxa_pure_virtual
		xref	___CTOR_LIST__
		xref	___DTOR_LIST__
		xdef	__ZSt17__throw_bad_allocv
		xdef	_memcpy

BASEPAGE_SIZE 	equ $100
STACK_SIZE 		equ	$10000		
		
; --------------------------------------------------------------
		move.l	4(sp),a5				;address to basepage
		move.l	$0c(a5),d0				;length of text segment
		add.l	$14(a5),d0				;length of data segment
		add.l	$1c(a5),d0				;length of bss segment
		add.l	#STACK_SIZE+BASEPAGE_SIZE,d0			;length of stackpointer+basepage
		move.l	a5,d1					;address to basepage
		add.l	d0,d1					;end of program
		and.l	#$fffffff0,d1			;align stack
		move.l	d1,sp					;new stackspace

		move.l	d0,-(sp)				;mshrink()
		move.l	a5,-(sp)				;
		clr.w	-(sp)					;
		move.w	#$4a,-(sp)				;
		trap	#1					;
		lea.l	12(sp),sp				;
				
		; clear bss segment
				
		move.l	$18(a5),a0
		move.l	$1c(a5),d0				;length of bss segment
		moveq	#0,d1
.1		move.b	d1,(a0)+
		subq.l	#1,d0
		bne.b	.1
		
		; redirect to serial
		
		move.w #2,-(sp)
		move.w #1,-(sp)
		move.w #$46,-(sp)
		trap #1
		addq.l #6,sp
		
		; execute static constructors
		
		lea	___CTOR_LIST__,a0
		jsr	static
	
		jsr	_main

exit:	
		lea	___DTOR_LIST__,a0
		jsr	static
		
		move.w #1,-(sp)
		trap #1
		addq.l #2,sp
		
		clr.w -(sp)
		trap #1

		
static:	move.l	(a0)+,d0
l1:		move.l	(a0)+,a1
		movem.l	d0/a0,-(sp)
		moveq	#0,d0
		jsr		(a1)
		movem.l	(sp)+,d0/a0
		subq.l	#1,d0
		bne.b	l1
		rts
		
_basepage:	ds.l	1
_len:	ds.l	1

; --------------------------------------------------------------
_memcpy:	
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.l	12(sp),d1

	lsr.l	#4,d1
	move.l	d1,d0
	swap.w	d0
	subq.w	#1,d1	
	bmi.b	.1
.2:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf		d1,.2
.1:
	subq.w	#1,d0
	bpl.b	.2

	move.l	12(sp),d1
	and.w	#$f,d1
	subq.w	#1,d1
	bmi.b	.3
.4:
	move.b	(a1)+,(a0)+
	dbf	d1,.4
.3:
	move.l	4(sp),d0
	rts

; --------------------------------------------------------------
__ZSt17__throw_bad_allocv		
___cxa_pure_virtual:
	
	jmp	exit
