*	Assembly language module to handle low level screen operations
*
*
	.globl	_stuffpt
	.globl  _lineai
	.globl  _lineav
	.globl	_setvdi
	.globl  _fixvdi
	.globl  _f_move
	.globl  _r_move
	.globl	_Lf_move

*
_stuffpt:
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.l 	(a0),(a1)
	rts

*
*	Line A init code 
*
*
_lineai:
	dc.w	$a000			* Init lineA
	move.l	a0,_lineav
	rts
*
*   Set up vdi variables for making image mask
*
*		4(sp)	- width of new screen
*		6(sp)	- height of new screen
*		8(sp)   - width of screen in bytes
_setvdi:
	move.l	_lineav,a0
	lea	save_vars,a1
	move.w	-780(a0),(a1)+
	move.w	-774(a0),(a1)+
	move.w	-772(a0),(a1)+
	move.w	-692(a0),(a1)+
	move.w	-690(a0),(a1)+
	move.w	-666(a0),(a1)+
	move.w	-622(a0),(a1)+
	move.w	-614(a0),(a1)+
	move.w	 -12(a0),(a1)+
	move.w	  -4(a0),(a1)+
	move.w	  -2(a0),(a1)+
	move.w	    (a0),(a1)+
	move.w	   2(a0),(a1)
*
	move.w	#1,-780(a0)
	move.w	#1,-774(a0)
	move.w	#0,-772(a0)
	move.w	4(sp),-692(a0)
	sub.w	#1,-692(a0)
	move.w	6(sp),-690(a0)
	sub.w	#1,-690(a0)
	move.w	#2,-666(a0)
	move.w	#0,-622(a0)
	move.w	#0,-614(a0)
	move.w	 4(sp),-12(a0)
	move.w	 6(sp),-4(a0)
	move.w	 8(sp),-2(a0)
	move.w	 #1,(a0)
	move.w	 8(sp),2(a0)
        rts
*
_fixvdi:
	move.l	_lineav,a0
	lea	save_vars,a1
	move.w	(a1)+,-780(a0)
	move.w	(a1)+,-774(a0)
	move.w	(a1)+,-772(a0)
	move.w	(a1)+,-692(a0)
	move.w	(a1)+,-690(a0)
	move.w	(a1)+,-666(a0)
	move.w	(a1)+,-622(a0)
	move.w	(a1)+,-614(a0)
	move.w	(a1)+,-12(a0)
	move.w	(a1)+,-4(a0)
	move.w	(a1)+,-2(a0)
	move.w	(a1)+,(a0)
	move.w	(a1)+,2(a0)
	rts
*
*
_f_move:
	move.l	4(a7),a0
	move.l	8(a7),a1
	move.w	12(a7),d0
	subq.w	#1,d0
	bmi	f_mvexit
f_mvlp:
	move.b	(a0)+,(a1)+
	dbra	d0,f_mvlp
f_mvexit:
	rts
*
*
_r_move:
	move.l	4(a7),a0
	move.l	8(a7),a1
	move.w	12(a7),d0
	subq.w	#1,d0
	bmi	r_mvexit
	adda.l	#1,a0
	adda.l	#1,a1
r_mvlp:
	move.b	-(a0),-(a1)
	dbra	d0,r_mvlp
r_mvexit:
	rts


*
_Lf_move:
	movea.l	$4(a7),a0	* Source
	movea.l	$8(a7),a1	* Destination
	move.l	$C(a7),d0	* count

lf_next:
	tst.l	d0
	beq.b	lf_exit
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bra.b	lf_next
lf_exit:
	rts

*
.bss
save_vars:	.ds.w	14
.end
