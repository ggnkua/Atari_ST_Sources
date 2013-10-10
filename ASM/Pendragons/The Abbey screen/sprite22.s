	* a0 : adresse ecran
	* a1 : adresse du sprite
	* a2 : adresse du buffer
	
	move.l ecran,a0
	lea t_spr2,a1
	move.l pos_buf3,a2
	
recom_sp	move.l pos_spr2,a3
	move.w (a3)+,d0
	move.l a3,pos_spr2
	
	cmp.w #-1,d0
	bne.s cont_sp
	
	move.l #tab_pos1,pos_spr2
	bra.s recom_sp

cont_sp	move.w d0,d1
	and.w #$fff0,d0
	and.w #$000f,d1
	lsr.w #1,d0  
	lsl.w #2,d1
	
	move.l (a1,d1.w),a1
	lea (a0,d0.w),a0
	
rec_sp2	move.l pos_x2,a3
	move.w (a3)+,d0
	move.l a3,pos_x2
	
	cmp.w #-1,d0
	bne.s cont_sp2
	
	move.l #x_pos1,pos_x2
	bra.s rec_sp2
	
cont_sp2	lea (a0,d0.w),a0
	
	move.l save_pos3,a3
	move.l a0,(a3)
	
	rept 15
	
	move.l (a1)+,d0
	move.l (a1)+,d1
	move.l (a0),d2
	move.l 4(a0),d3
	move.l d2,(a2)+
	move.l d3,(a2)+

	move.l d0,d5
	or.l d1,d5
	move.l d1,d4
	swap d4
	or.l d4,d5
	not.l d5
	
	and.l d5,d2
	and.l d5,d3
	or.l d0,d2
	or.l d1,d3
	move.l d2,(a0)+
	move.l d3,(a0)+

	move.l (a1)+,d0
	move.l (a1)+,d1
	move.l (a0),d2
	move.l 4(a0),d3
	move.l d2,(a2)+
	move.l d3,(a2)+

	move.l d0,d5
	or.l d1,d5
	move.l d1,d4
	swap d4
	or.l d4,d5
	not.l d5
	
	and.l d5,d2
	and.l d5,d3
	or.l d0,d2
	or.l d1,d3
	move.l d2,(a0)+
	move.l d3,(a0)+

	move.l (a1)+,d0
	move.l (a1)+,d1
	move.l (a0),d2
	move.l 4(a0),d3
	move.l d2,(a2)+
	move.l d3,(a2)+

	move.l d0,d5
	or.l d1,d5
	move.l d1,d4
	swap d4
	or.l d4,d5
	not.l d5
	
	and.l d5,d2
	and.l d5,d3
	or.l d0,d2
	or.l d1,d3
	move.l d2,(a0)+
	move.l d3,(a0)+

	move.l (a1)+,d0
	move.l (a1)+,d1
	move.l (a0),d2
	move.l 4(a0),d3
	move.l d2,(a2)+
	move.l d3,(a2)+

	move.l d0,d5
	or.l d1,d5
	move.l d1,d4
	swap d4
	or.l d4,d5
	not.l d5
	
	and.l d5,d2
	and.l d5,d3
	or.l d0,d2
	or.l d1,d3
	move.l d2,(a0)+
	move.l d3,(a0)+

	move.l (a1)+,d0
	move.l (a1)+,d1
	move.l (a0),d2
	move.l 4(a0),d3
	move.l d2,(a2)+
	move.l d3,(a2)+

	move.l d0,d5
	or.l d1,d5
	move.l d1,d4
	swap d4
	or.l d4,d5
	not.l d5
	
	and.l d5,d2
	and.l d5,d3
	or.l d0,d2
	or.l d1,d3
	move.l d2,(a0)+
	move.l d3,(a0)+
	
	lea 160-40(a0),a0
	endr
	
	rts
	