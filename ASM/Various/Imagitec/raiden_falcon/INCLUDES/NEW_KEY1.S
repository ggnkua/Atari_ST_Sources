	Ifnd	Andy
	even
hbl_on	lea	hbl_off(pc),a0
	bsr	start_mouse
	move.l	$120.w,oldtb-hbl_off(a0)
;	move.l	$70.w,old4-hbl_off(a0)
	move.l	$118.w,oldkey-hbl_off(a0)
	move.b	$fffffa07.w,old07-hbl_off(a0)
	move.b	$fffffa09.w,old09-hbl_off(a0)
	move.b	$fffffa0f.w,old0f-hbl_off(a0)
	move.b	$fffffa11.w,old11-hbl_off(a0)
	move.b	$fffffa1b.w,old1b-hbl_off(a0)
	move.b	$fffffa13.w,old13-hbl_off(a0)
	move.b	$fffffa15.w,old15-hbl_off(a0)
	clr.l	$fffffa06.w
;	move.l	#new4,$70.w
	move.l	#newkey,$118.w
	move.l	#newtb,$120.w
	or.b	#$40,$fffffa09.w
	or.b	#1,$fffffa13.w
	or.b	#1,$fffffa07.w
	move.b	#1,$fffffa21.w
	bclr.b	#3,$fffffa17.w
	rts

hbl_off	move.w	sr,-(sp)
	move.w	#$2700,sr
labela	move.b	#8,$fffffa07.w
old07	equ	labela+3
labelb	move.b	#8,$fffffa09.w
old09	equ	labelb+3
labelc	move.b	#8,$fffffa0f.w
old0f	equ	labelc+3
labeld	move.b	#8,$fffffa11.w
old11	equ	labeld+3
labele	move.b	#8,$fffffa1b.w
old1b	equ	labele+3
labelf	move.b	#8,$fffffa13.w
old13	equ	labelf+3
labelg	move.b	#8,$fffffa15.w
old15	equ	labelg+3
labelh	move.l	#8,$120.w
oldtb	equ	labelh+2
labeli	move.l	#8,$70.w
old4	equ	labeli+2
labelj	move.l	#8,$118.w
oldkey	equ	labelj+2
	move.w	(sp)+,sr
	bsr	end_mouse
	rts

start_mouse
	move.b	#$1a,d0
	bsr	write_ikbd
;	move.b	#$12,d0
;	bsr	write_ikbd
	move.b	#$09,d0
	bsr	write_ikbd
	move.b	#1,d0
	bsr	write_ikbd
	move.b	#320-256-1,d0
	bsr	write_ikbd
	move.b	#0,d0
	bsr	write_ikbd
	move.b	#200-1,d0
	bsr	write_ikbd
	rts
end_mouse
;	move.b	#$12,d0
;	bsr	write_ikbd
	move.b	#$1a,d0
	bsr	write_ikbd
	move.b	#$15,d0
	bsr	write_ikbd
	move.b	#$08,d0
	bsr	write_ikbd
	rts
	
read_mouse
	move.b	#$0d,d0
write_ikbd
	btst	#1,$fffc00
	beq.s	write_ikbd
	move.b	d0,$fffc02
	rts

;d6-d7 xy to set
Init_Mouse_Coards
	Bsr	.Jump
.Jump	
	Move.b	#$e,d0
	Bsr	Write_Ikbd
	Move.b	#$0,d0
	Bsr	Write_Ikbd
	Ror.w	#8,d6
	Move.b	d6,d0
	Bsr	Write_Ikbd
	Ror.w	#8,d6
	Move.b	d6,d0
	Bsr	Write_Ikbd
	Ror.w	#8,d7
	Move.b	d7,d0
	Bsr	Write_Ikbd
	Ror.w	#8,d7
	Move.b	d7,d0
	Bsr	Write_Ikbd
	Rts

newkey	movem.l	d0/a0,-(sp)
	move.b	$fffffc00.w,d0
	bpl.s	l11202a
	btst	#0,d0
	beq.s	l11202a
	moveq	#0,d0
	move.b	$fffffc02.w,d0
	tst.b	left_to_read
	beq.s	start_key
	move.l	sheep(pc),a0
	move.b	d0,(a0)+
	move.l	a0,sheep
	subq.b	#1,left_to_read
not_end	movem.l	(sp)+,d0/a0
	rte

start_key
	cmp.w	#$f6,d0
	blt.s	key_read
	move.l	#ikbd_buffer,sheep
	move.b	#5,left_to_read
l11202a	movem.l	(sp)+,d0/a0
	rte

sheep	dc.l	ikbd_buffer

clear_key
	clr.b	key_code
	movem.l	(sp)+,d0/a0
	rte

key_read
	tst.b	d0
	bmi.s	clear_key
	move.b	d0,key_code
	movem.l	(sp)+,d0/a0
	rte

Newtb	Rte
;New4	Rte


key_code		ds.b	1
left_to_read		ds.b	1
ikbd_buffer		ds.b	7
	EVEN
	Else
	
	Rts
	
	Endc
	