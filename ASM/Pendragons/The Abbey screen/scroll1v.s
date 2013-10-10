	move.l ecran1,a2
	move.l ecran,a3
	lea 55*160(a2),a0
	lea 54*160(a3),a1
	lea (54*160)-16(a2),a2
	lea (55*160)-16(a3),a3
	
n	set 0
	rept 119
	movem.l n(a0),d0-d3
	movem.l d0-d3,n(a1)
	movem.l (119*160)-n(a2),d0-d3
	movem.l d0-d3,(119*160)-n(a3)
n	set n+160
	endr
	
start_car	movem.l fonte_v+(120*90)+108,d0-d2
start_cav	movem.l fonte_vv+(120*90)+108,d4-d6
	movem.l d0-d2,buf_scr_v
	movem.l d4-d6,buf_scr_w
	moveq #0,d1
	move.l buf_scr_v,d0
	move.w buf_scr_v+4,d1
	swap d1
	moveq #0,d3
	move.l buf_scr_v+6,d2
	move.w buf_scr_v+10,d3
	swap d3
	movem.l d0-d3,160*119(a1)
	moveq #0,d1
	move.l buf_scr_w,d0
	move.w buf_scr_w+4,d1
	swap d1
	moveq #0,d3
	move.l buf_scr_w+6,d2
	move.w buf_scr_w+10,d3
	swap d3
	movem.l d0-d3,(a3)
	
	move.l start_car+4,a0
	lea 120(a0),a0
	move.l a0,start_car+4
	
	move.l start_cav+4,a0
	lea 120(a0),a0
	move.l a0,start_cav+4
	
	subq.b #1,fin_car_v
	beq.s new_car_v
	rts
	
new_car_v	moveq #0,d0
	move.b #30,fin_car_v
	move.l pos_txt_v,a0
	move.b (a0)+,d0
	move.l a0,pos_txt_v
	
	cmp.b #-1,d0
	beq.s deb_car_v
	
	lea tab_car_v,a0
	lea tab_carvv,a1
	lsl.w #2,d0
	move.l (a0,d0.w),start_car+4
	move.l (a1,d0.w),start_cav+4
	rts
	
deb_car_v	move.l #text_v1,pos_txt_v
	bra.s new_car_v
	