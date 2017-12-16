
debut_mouse_x:	equ	320
debut_mouse_y:	equ	100

	pea	00.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,physik
	move.l	d0,clear_ptr

	move.w	#debut_mouse_x,mouse_x
	move.w	#debut_mouse_y,mouse_y
	bsr	init_mouse

vbl_loopz:
	lea	vbl_flag,a0
	clr.w	(a0)
vsync_loopz:
	tst.w	(a0)
	beq.s	vsync_loopz

	bsr	clr_curs

	movea.l	physik,a0
	clr.l	d0
	move.w	mouse_x,d0
	move.w	mouse_y,d1
	bsr	aff_curs
	
	btst.b	#1,bouton
	beq.s	vbl_loopz

	bsr	tend_mouse

	clr.w	-(sp)
	trap	#1

init_mouse:
	move.w	#$2700,sr
	move.l	$118,old_kbd
	move.l	#kbd_vect,$118
	move.l	$70,old_vbl
	move.l	#vbl,$70

	lea	init_data,a0
	moveq	#init_data_fin-init_data-1,d7
init_mouse_loopz:
	move.b	(a0)+,d0
	bsr	send_kbd
	dbf	d7,init_mouse_loopz

	move.w	#$2300,sr
	rts
tend_mouse:
	move.w	#$2700,sr
	move.l	old_kbd,$118
	move.l	old_vbl,$70
	move.b	#$80,d0
	bsr	send_kbd
	move.b	#$01,d0
	bsr	send_kbd
wait_kbd:
	btst	#1,$fffffc00.w		
	beq.s	wait_kbd		
	move.w	#$2300,sr
	rts

send_kbd:
	btst	#1,$fffffc00.w		
	beq.s	send_kbd		
	move.b	d0,$fffffc02.w		
	rts

kbd_vect:
	move.w	d0,-(sp)
	move.l	a0,-(sp)

	clr.w	d0
	move.b	$fffffc02.w,d0
	tst.w	mouse_packet
	bne.s	kbd_mouse_depacket
	tst.w	packet
	bne	kbd_depacket
	cmpi.b	#$f8,d0
	blo.s	kbd_no_mouse
	cmpi.b	#$fb,d0
	bls.s	kbd_rel_mouse
kbd_no_mouse:
	cmpi.b	#$fe,d0
	beq.s	kbd_joy0
	cmpi.b	#$ff,d0
	beq.s	kbd_joy1
end:
	move.l	(sp)+,a0
	move.w	(sp)+,d0
	bclr	#6,$fffffa11.w		
	rte
kbd_mouse_depacket
	subq.w	#1,mouse_packet
	ext.w	d0
	movea.l	packet_ptr,a0
	add.w	d0,(a0)+
	move.l	a0,packet_ptr
	bra.s	end
kbd_rel_mouse:
	and.b	#%00000011,d0
	move.b	d0,bouton
	move.w	#2,mouse_packet		
	move.l	#mouse_x,packet_ptr
	bra.s	end
kbd_joy0:
	move.w	#1,packet
	move.l	#joy0,packet_ptr
	bra.s	end
kbd_joy1:
	move.w	#1,packet
	move.l	#joy1,packet_ptr
	bra.s	end
kbd_depacket:				
	subq.w	#1,packet
	move.l	packet_ptr,a0
	move.b	d0,(a0)+
	move.l	a0,packet_ptr
	bra.s	end

vbl:
	st	vbl_flag
	rte
	
aff_curs:
	move.w	#2,$ffff8a20.w
	move.w	#2,$ffff8a22.w
	move.l	#curseur,$ffff8a24
	move.w	#$ffff,$ffff8a28.w	
	move.w	#$ffff,$ffff8a2a.w	
	move.w	#$ffff,$ffff8a2c.w	
	move.w	#4,$ffff8a2e.w	
	move.w	#160-4,$ffff8a30.w	
	move.w	d0,d2
	and.b	#%00001111,d2
	eor.b	d2,d0
	lsr.w	#2,d0
	mulu	#160,d1
	add.l	d0,d1
	adda.l	d1,a0
	move.l	a0,clear_ptr
	move.l	a0,$ffff8a32.w
	move.w	#2,$ffff8a36.w	
	move.w	#15,$ffff8a38.w	
	move.b	#2,$ffff8a3a.w	
	move.b	#3,$ffff8a3b.w
	move.b	d2,$ffff8a3d.w	
	move.b	#%11000000,$ffff8a3c.w	

	rts
clr_curs:
	movea.l	clear_ptr,a0
	moveq	#15-1,d7
clear_loopz:
	clr.w	(a0)
	clr.w	4(a0)
	adda.w	#160,a0
	dbf	d7,clear_loopz
	rts
	Section	Data
curseur:
	incbin	f:\asm\divers.moa\curs.bin
init_data:
	dc.b	$14		* init_joy
	dc.b	$08		* souris en relatif
init_data_fin:
	even
	Section	BSS
clear_ptr:
	ds.l	1
physik:
	ds.l	1
*-------------------------------Mouse Rout BSS----------------------------*
packet:
	ds.w	1
mouse_packet:
	ds.w	1
packet_ptr:
	ds.l	1
old_kbd:
	ds.l	1
old_vbl:
	ds.l	1
vbl_flag:
	ds.w	1
	even
	ds.b	1
bouton:
	ds.b	1
mouse_x:
	ds.w	1
mouse_y:
	ds.w	1
joy0:
	ds.b	1
joy1:
	ds.b	1
