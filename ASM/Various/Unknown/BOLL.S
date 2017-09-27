	; BOLL DEMO
x:
	jmp	main(pc)


init_ints:
	move.w	sr,save_sr
	move.w	#$2700,sr
	move.l	$70.w,save_vbi
	move.b	$fffffa07.w,mfp1
	move.b	$fffffa09.w,mfp2
	move.b	#0,$fffffa07.w
	move.b	#0,$fffffa09.w
	move.l	#vbi,$70.w
	move.w	#$2300,sr
	rts

end_tab:
	lea	sin_tab(pc),a3
	jmp	go_stud(pc)

end_tab2:
	lea	sin_tab2(pc),a3
	jmp	go_stud2(pc)
	
blatt_boll:
	lea	$77878,a4
	lea	sprit_tab(pc),a2
	moveq	#19,d1

blatt_loop:
	move.l	a4,a1
	move.l	(a2),a3
		
go_stud:
	move.l	(a3)+,d0
	cmp.l	#-1,d0
	beq.s	end_tab
	add.l	d0,a1
	move.l	a3,(a2)+
		
	move.l	(a2),a3
		
go_stud2:	
	move.l	(a3)+,d0
	cmp.l	#-1,d0	
	beq.s	end_tab2
	add.l	d0,a1
	move.l	a3,(a2)+
	
	moveq	#0,d0
	moveq	#12,d2
	
clear_loop:
	move.l	d0,(a1)
	lea	160(a1),a1
	dbra	d2,clear_loop
	lea	boll(pc),a0
	move.l	(a0)+,(a1)
	move.l	(a0)+,160(a1)
	move.l	(a0)+,320(a1)
	move.l	(a0)+,480(a1)
	move.l	(a0)+,640(a1)
	move.l	(a0)+,800(a1)
	move.l	(a0)+,960(a1)
	move.l	(a0)+,1120(a1)
	move.l	(a0)+,1280(a1)
	move.l	(a0)+,1440(a1)
	move.l	(a0)+,1600(a1)
	move.l	(a0)+,1760(a1)
	move.l	(a0)+,1920(a1)
	move.l	(a0)+,2080(a1)
	move.l	(a0)+,2240(a1)
	move.l	(a0)+,2400(a1)
	lea	2560(a1),a1
	moveq 	#12,d2
	
clear_loop2:
	move.l	d0,(a1)
	lea	160(a1),a1
	dbra	d2,clear_loop2
	lea	-8(a4),a4
	dbra	d1,blatt_loop
	rts	

main:
	move.w	#0,-(sp)
	move.l	#$78000,-(sp)
	move.l	#$78000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l     #12,sp
	
	pea	0
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,save_pal
	movem.l	pal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	jsr	init_ints(pc)

	move.w	#0,wfnc

demo_loop:
	cmp.w	#1,wfnc
	bne.s	demo_loop
	move.w	#0,wfnc

	jsr	blatt_boll(pc)
	cmp.b	#185,$fffffc02.w
	bne.s	demo_loop
	movem.l	save_pal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	#$2700,sr
	move.l	save_vbi(pc),$70.w
	move.b	mfp1(pc),$fffffa07.w
	move.b	mfp2(pc),$fffffa09.w
	move.w	save_sr,sr
	move.l	save_stk(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.w	-(sp)
	trap	#1

vbi:
	move.w	#1,wfnc
	rte	

pal:
	dc.w	$0,$20,$40,$60
	ds.w	12

save_pal:
	ds.w	16
	
save_vbi:
	dc.l	0

save_sr:
	dc.w	0
	
mfp1:
	dc.b	0

mfp2:
	dc.b	0

wfnc:
	dc.w	0
	
save_stk:
	dc.l	0

sprit_tab:
	dc.l	sin_tab
	dc.l	sin_tab2
	dc.l	sin_tab+8
	dc.l	sin_tab2+4
	dc.l	sin_tab+16
	dc.l	sin_tab2+8
	dc.l	sin_tab+24
	dc.l	sin_tab2+12
	dc.l	sin_tab+32
	dc.l	sin_tab2+16
	dc.l	sin_tab+40
	dc.l	sin_tab2+20
	dc.l	sin_tab+48
	dc.l	sin_tab2+24
	dc.l	sin_tab+56
	dc.l	sin_tab2+28
	dc.l	sin_tab+64
	dc.l	sin_tab2+32
	dc.l	sin_tab+72
	dc.l	sin_tab2+36
	dc.l	sin_tab+80
	dc.l	sin_tab2+40
	dc.l	sin_tab+88
	dc.l	sin_tab2+44
	dc.l	sin_tab+96
	dc.l	sin_tab2+48
	dc.l	sin_tab+104
	dc.l	sin_tab2+52
	dc.l	sin_tab+112
	dc.l	sin_tab2+56
	dc.l	sin_tab+120
	dc.l	sin_tab2+60
	dc.l	sin_tab+128
	dc.l	sin_tab2+64
	dc.l	sin_tab+136
	dc.l	sin_tab2+68
	dc.l	sin_tab+144
	dc.l	sin_tab2+72
	dc.l	sin_tab+152
	dc.l	sin_tab2+76

boll:
	dc.w	$07E0,$0000,$1818,$07E0
	dc.w	$2384,$1FF8,$4782,$3FFC
	dc.w	$4C02,$3FFC,$8801,$7FFE
	dc.w	$8801,$7FFE,$8001,$7FFE
	dc.w	$8001,$7FFE,$8003,$7FFC
	dc.w	$8003,$7FFC,$4006,$3FF8
	dc.w	$400E,$3FF0,$201C,$1FE0
	dc.w	$18F8,$0700,$07E0,$0000

sin_tab:
	dc.l	0,0,0,0,0,0,0,0,0
	dc.l	0,160,160,320,320,480,640,800,960,1120
	dc.l	1280,1440,1600,1760,2080,2240,2400,2720,3040,3200
	dc.l	3520,3840,4160,4480,4800,5120,5440,5760,6240,6560
	dc.l	7040,7360,7840,8320,8640,9120,9600,10080,10560,11040
	dc.l	11680,12160,12640,13280,12640,12160,11680,11040,10560,10080
	dc.l	9600,9120,8640,8320,7840,7360,7040,6560,6240,5760
	dc.l	5440,5120,4800,4480,4160,3840,3520,3200,3040,2720
	dc.l 	2400,2240,2080,1760,1600,1440,1280,1120,960,800
	dc.l	640,480,320,320,160,160,-1

sin_tab2:
	dc.l	0,0,0,0,160,480,800,1120,1600,2080,2720
	dc.l	3360,4000,4640,5440,6240,7040,7840,8640,9440,10240
	dc.l 	10880,11680,12320,12960,13600,14080,14560,15040,15360,15680
	dc.l	15840,15840,15840,15840,15680,15520,15200,14880,14400,13920
	dc.l	13440,12800,12160,11360,10720,9920,9120,8320,7520,6720
	dc.l	5920,5280,4480,3840,3040,2560,1920,1440,960,640
	dc.l	320,160,-1



	
	