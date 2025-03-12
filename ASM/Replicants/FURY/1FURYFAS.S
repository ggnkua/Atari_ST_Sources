screen	equ	$f8000

	opt	d+
	
	section text
	
	pea	0
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	
	clr.b	$ffff8260.w
	move.l	#screen,d0
	lea	$ffff8200.w,a0
	lsr.l	#8,d0
	movep	d0,1(a0)
		
	lea	pic_dat,a0
	lea	screen,a1
	move	#(200*40)-1,d0
aff	clr.l	(a1)+	move.l	(a0)+,(a1)+
	dbra	d0,aff
	
	lea	pic_dat,a0
	lea	scro_buf_a,a1
	moveq	#27,d0
cfd	moveq	#1,d1
cfg	move	(a0),(a1)+
	move	8(a0),(a1)+
	move	16(a0),(a1)+
	move	24(a0),(a1)+
	move	32(a0),(a1)+
	move	40(a0),(a1)+
	move	48(a0),(a1)+
	move	56(a0),(a1)+
	dbra	d1,cfg
	lea	16(a1),a1
	lea	160(a0),a0
	dbra	d0,cfd
	
	move.l	#scroll_pos,last_scro
	move.l	#scro_buf_a,scro_a
	move.l	#scro_buf_a,scro_b
	
main	move	#$25,-(a7)
	trap	#14
	addq	#2,a7
	
	clr	$ffff8240.w
	
	bsr	scroll
	
	move	#$777,$ffff8240.w
	
	cmp.b	#$39,$fffffc02.w
	bne.s	main
	
	pea	0
	trap	#1
		
scroll	move.l	scro_a,a0
	move.l	scro_b,scro_a
	move.l	a0,scro_b
	
	move.l	last_scro,a1
	move.l	(a1)+,a2
	tst	(a1)
	bpl.s	zlot
	
	
	lea	scroll_pos,a1
zlot	move.l	a1,last_scro
	
	
	lea	screen+160*100,a1
	moveq	#27,d0	* Hauteur
	jmp	(a2)
	
scro_0	movem	(a0)+,d1-d7/a2-a6
	move	D1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	move	a2,56(a1)
	move	a3,64(a1)
	move	a4,72(a1)
	move	a5,80(a1)
	move	a6,88(a1)
	movem	(a0)+,d1-d7/a6
	move	d1,96(a1)
	move	d2,104(a1)
	move	d3,112(a1)
	move	d4,120(a1)
	move	d5,128(a1)
	move	d6,136(a1)
	move	d7,144(a1)
	move	a6,152(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_0
	
	rts
	
scro_1	move	(a0)+,152(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	move	a2,56(a1)
	move	a3,64(a1)
	move	a4,72(a1)
	move	a5,80(a1)
	move	a6,88(a1)
	movem	(a0)+,d1-d7
	move	d1,96(a1)
	move	d2,104(a1)
	move	d3,112(a1)
	move	d4,120(a1)
	move	d5,128(a1)
	move	d6,136(a1)
	move	d7,144(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_1
	
	rts

scro_2	move	(a0)+,144(a1)
	move	(a0)+,152(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	move	a2,56(a1)
	move	a3,64(a1)
	move	a4,72(a1)
	move	a5,80(a1)
	move	a6,88(a1)
	movem	(a0)+,d1-d6
	move	d1,96(a1)
	move	d2,104(a1)
	move	d3,112(a1)
	move	d4,120(a1)
	move	d5,128(a1)
	move	d6,136(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_2
	
	rts

scro_3	move	(a0)+,136(a1)
	move	(a0)+,144(a1)
	move	(a0)+,152(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	move	a2,56(a1)
	move	a3,64(a1)
	move	a4,72(a1)
	move	a5,80(a1)
	move	a6,88(a1)
	movem	(a0)+,d1-d5
	move	d1,96(a1)
	move	d2,104(a1)
	move	d3,112(a1)
	move	d4,120(a1)
	move	d5,128(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_3
	
	rts

scro_4	movem	(a0)+,d1-d4
	move	d1,128(a1)
	move	d2,136(a1)
	move	d3,144(a1)
	move	d4,152(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	move	a2,56(a1)
	move	a3,64(a1)
	move	a4,72(a1)
	move	a5,80(a1)
	move	a6,88(a1)
	movem	(a0)+,d1-d4
	move	d1,96(a1)
	move	d2,104(a1)
	move	d3,112(a1)
	move	d4,120(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_4
	
	rts

scro_5	movem	(a0)+,d1-d5
	move	d1,120(a1)
	move	d2,128(a1)
	move	d3,136(a1)
	move	d4,144(a1)
	move	d5,152(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	move	a2,56(a1)
	move	a3,64(a1)
	move	a4,72(a1)
	move	a5,80(a1)
	move	a6,88(a1)
	move	(a0)+,96(a1)
	move	(a0)+,104(a1)
	move	(a0)+,112(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_5
	
	rts
	
scro_6	movem	(a0)+,d1-d6
	move	d1,112(a1)
	move	d2,120(a1)
	move	d3,128(a1)
	move	d4,136(a1)
	move	d5,144(a1)
	move	d6,152(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	move	a2,56(a1)
	move	a3,64(a1)
	move	a4,72(a1)
	move	a5,80(a1)
	move	a6,88(a1)
	move	(a0)+,96(a1)
	move	(a0)+,104(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_6
	
	rts

scro_7	movem	(a0)+,d1-d7
	move	d1,104(a1)
	move	d2,112(a1)
	move	d3,120(a1)
	move	d4,128(a1)
	move	d5,136(a1)
	move	d6,144(a1)
	move	d7,152(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	move	a2,56(a1)
	move	a3,64(a1)
	move	a4,72(a1)
	move	a5,80(a1)
	move	a6,88(a1)
	move	(a0)+,96(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_7
	
	rts

scro_8	movem	(a0)+,d1-d7/a2
	move	d1,96(a1)
	move	d2,104(a1)
	move	d3,112(a1)
	move	d4,120(a1)
	move	d5,128(a1)
	move	d6,136(a1)
	move	d7,144(a1)
	move	a2,152(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	move	a2,56(a1)
	move	a3,64(a1)
	move	a4,72(a1)
	move	a5,80(a1)
	move	a6,88(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_8
	
	rts

scro_9	movem	(a0)+,d1-d7/a2-a3
	move	d1,88(a1)
	move	d2,96(a1)
	move	d3,104(a1)
	move	d4,112(a1)
	move	d5,120(a1)
	move	d6,128(a1)
	move	d7,136(a1)
	move	a2,144(a1)
	move	a3,152(a1)
	movem	(a0)+,d1-d7/a2-a5
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	move	a2,56(a1)
	move	a3,64(a1)
	move	a4,72(a1)
	move	a5,80(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_9
	
	rts

scro_10	movem	(a0)+,d1-d7/a2-a4
	move	d1,80(a1)
	move	d2,88(a1)
	move	d3,96(a1)
	move	d4,104(a1)
	move	d5,112(a1)
	move	d6,120(a1)
	move	d7,128(a1)
	move	a2,136(a1)
	move	a3,144(a1)
	move	a4,152(a1)
	movem	(a0)+,d1-d7/a2-a4
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	move	a2,56(a1)
	move	a3,64(a1)
	move	a4,72(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_10
	
	rts

scro_11	movem	(a0)+,d1-d7/a2-a5
	move	d1,72(a1)
	move	d2,80(a1)
	move	d3,88(a1)
	move	d4,96(a1)
	move	d5,104(a1)
	move	d6,112(a1)
	move	d7,120(a1)
	move	a2,128(a1)
	move	a3,136(a1)
	move	a4,144(a1)
	move	a5,152(a1)
	movem	(a0)+,d1-d7/a2-a3
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	move	a2,56(a1)
	move	a3,64(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_11
	
	rts

scro_12	movem	(a0)+,d1-d7/a2-a6
	move	d1,64(a1)
	move	d2,72(a1)
	move	d3,80(a1)
	move	d4,88(a1)
	move	d5,96(a1)
	move	d6,104(a1)
	move	d7,112(a1)
	move	a2,120(a1)
	move	a3,128(a1)
	move	a4,136(a1)
	move	a5,144(a1)
	move	a6,152(a1)
	movem	(a0)+,d1-d7/a2
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	move	a2,56(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_12
	
	rts

scro_13	move	(a0)+,56(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,64(a1)
	move	d2,72(a1)
	move	d3,80(a1)
	move	d4,88(a1)
	move	d5,96(a1)
	move	d6,104(a1)
	move	d7,112(a1)
	move	a2,120(a1)
	move	a3,128(a1)
	move	a4,136(a1)
	move	a5,144(a1)
	move	a6,152(a1)
	movem	(a0)+,d1-d7
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	move	d7,48(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_13
	
	rts

scro_14	move	(a0)+,48(a1)
	move	(a0)+,56(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,64(a1)
	move	d2,72(a1)
	move	d3,80(a1)
	move	d4,88(a1)
	move	d5,96(a1)
	move	d6,104(a1)
	move	d7,112(a1)
	move	a2,120(a1)
	move	a3,128(a1)
	move	a4,136(a1)
	move	a5,144(a1)
	move	a6,152(a1)
	movem	(a0)+,d1-d6
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	move	d6,40(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_14
	
	rts

scro_15	
	move	(a0)+,40(a1)
	move	(a0)+,48(a1)
	move	(a0)+,56(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,64(a1)
	move	d2,72(a1)
	move	d3,80(a1)
	move	d4,88(a1)
	move	d5,96(a1)
	move	d6,104(a1)
	move	d7,112(a1)
	move	a2,120(a1)
	move	a3,128(a1)
	move	a4,136(a1)
	move	a5,144(a1)
	move	a6,152(a1)
	movem	(a0)+,d1-d5
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	move	d5,32(a1)
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_15
	
	rts
	
scro_16	movem	(a0)+,d1-d4
	move	d1,32(a1)
	move	d2,40(a1)
	move	d3,48(a1)
	move	d4,56(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,64(a1)
	move	d2,72(a1)
	move	d3,80(a1)
	move	d4,88(a1)
	move	d5,96(a1)
	move	d6,104(a1)
	move	d7,112(a1)
	move	a2,120(a1)
	move	a3,128(a1)
	move	a4,136(a1)
	move	a5,144(a1)
	move	a6,152(a1)
	
	movem	(a0)+,d1-d4
	move	d1,(a1)
	move	d2,8(a1)
	move	d3,16(a1)
	move	d4,24(a1)
	
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_16
	
	rts
scro_17	movem	(a0)+,d1-d5
	move	d1,24(a1)
	move	d2,32(a1)
	move	d3,40(a1)
	move	d4,48(a1)
	move	d5,56(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,64(a1)
	move	d2,72(a1)
	move	d3,80(a1)
	move	d4,88(a1)
	move	d5,96(a1)
	move	d6,104(a1)
	move	d7,112(a1)
	move	a2,120(a1)
	move	a3,128(a1)
	move	a4,136(a1)
	move	a5,144(a1)
	move	a6,152(a1)
	
	move	(a0)+,(a1)
	move	(a0)+,8(a1)
	move	(a0)+,16(a1)
	
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_17
	
	rts

scro_18	movem	(a0)+,d1-d6
	move	d1,16(a1)
	move	d2,24(a1)
	move	d3,32(a1)
	move	d4,40(a1)
	move	d5,48(a1)
	move	d6,56(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,64(a1)
	move	d2,72(a1)
	move	d3,80(a1)
	move	d4,88(a1)
	move	d5,96(a1)
	move	d6,104(a1)
	move	d7,112(a1)
	move	a2,120(a1)
	move	a3,128(a1)
	move	a4,136(a1)
	move	a5,144(a1)
	move	a6,152(a1)
	
	move	(a0)+,(a1)
	move	(a0)+,8(a1)
	
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_18
	
	rts

scro_19	movem	(a0)+,d1-d7
	move	d1,8(a1)
	move	d2,16(a1)
	move	d3,24(a1)
	move	d4,32(a1)
	move	d5,40(a1)
	move	d6,48(a1)
	move	d7,56(a1)
	movem	(a0)+,d1-d7/a2-a6
	move	d1,64(a1)
	move	d2,72(a1)
	move	d3,80(a1)
	move	d4,88(a1)
	move	d5,96(a1)
	move	d6,104(a1)
	move	d7,112(a1)
	move	a2,120(a1)
	move	a3,128(a1)
	move	a4,136(a1)
	move	a5,144(a1)
	move	a6,152(a1)
	
	move	(a0)+,(a1)
	
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_19
	
	rts


	section data
* Affichage rout
scroll_pos	dc.l	scro_0
	dc.l	scro_1
	dc.l	scro_2
	dc.l	scro_3
	dc.l	scro_4
	dc.l	scro_5
	dc.l	scro_6
	dc.l	scro_7
	dc.l	scro_8
	dc.l	scro_9
	dc.l	scro_10
	dc.l	scro_11
	dc.l	scro_12
	dc.l	scro_13
	dc.l	scro_14
	dc.l	scro_15
	dc.l	scro_16
	dc.l	scro_17
	dc.l	scro_18
	dc.l	scro_19
	dc.w	$ffff
	
pici	incbin	"bigfonts.pi1"
pic_dat	equ	pici+34

	section bss
last_scro	ds.l	1
scro_a	ds.l	1
scro_b	ds.l	1
scro_buf_a	equ	screen	ds.w	24*30
scro_buf_b	equ	screen+160*30	ds.w	24*30
