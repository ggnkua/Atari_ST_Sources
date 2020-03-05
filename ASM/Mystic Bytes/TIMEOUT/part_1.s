	    move.l sp,sav_sp

	    moveq 	#2,d0
	    trap	#4		

            ;----------------            
            lea		pic,a0
            lea		$2f0000,a1
            bsr		DEPACK
            ;----------------            
no            
            
            
hoho        lea 	pic_pal,a0
            lea 	$fffff9800.w,a1
            move.w 	#256-1,d7
rew_it      move.l 	(a0)+,(a1)+
            dbf 	d7,rew_it            
   	    bra 	done

real_fade   move.w 	tim_op(pc),d3
            lea 	pic_pal,a0
            lea 	temp_pal,a1
            move.w 	#256-1,d7               
            move.l 	#%111111,d4
next_color  move.l 	(a0)+,d0
            move.l 	d0,d1
            move.l 	d0,d2
            lsr.w 	#2,d0	
            	
            swap.w 	d1
            lsr.w 	#2,d1
            
            ;move.w d1,d2
            swap.w 	d2
            lsr.w 	#8,d2
            lsr.w 	#2,d2
            
            and.l 	d4,d3
            and.l 	d4,d0   ;blue
            and.l 	d4,d1   ;green
            and.l 	d4,d2   ;red
            mulu  	d3,d0
            mulu  	d3,d1
            mulu  	d3,d2 
            divu  	#64,d0
            divu  	#64,d1
            divu  	#64,d2
            and.l 	d4,d0   ;blue
            and.l 	d4,d1   ;green
            and.l 	d4,d2   ;red                                        
            moveq 	#0,d5
            lsl.l 	#2,d0
            move.l 	d0,d5
            
            swap.w 	d1
            lsl.l 	#2,d1
            or.l 	d1,d5
            
            swap.w 	d2
            lsl.l 	#8,d2
            lsl.l 	#2,d2
            or.l 	d2,d5
                                                           
            move.l 	d5,(a1)+
            dbf 	d7,next_color
            ;--------------                                 
            ;addq.w 	#1,tim_op
            
            ;subq.w 	#1,wsjo
            ;bne  	no
            ;-------------
done        move.l 	sav_sp,sp
	    rts
DEPACK:
	;MOVE.W	$FFFF8240.W,-(SP)
	movem.l d0-a6,-(sp)
	ADDQ.L	#4,A0			;GET PAST ICE! HEADER
	bsr.s	ice04
	lea	-8(a0,d0.l),a5
	bsr.s	ice04
	move.l	d0,(sp)
	movea.l a1,a4
	movea.l a1,a6
	adda.l	d0,a6
	movea.l a6,a3
	move.b	-(a5),d7
	bsr	ice06
	;MOVE.W	(SP)+,$FFFF8240.W
ice03:	movem.l (sp)+,d0-a6
	rts
ice04:	moveq	#3,d1
ice05:	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbra	d1,ice05
	rts
ice06:	bsr.s	ice0a
	bcc.s	ice09
	moveq	#0,d1
	bsr.s	ice0a
	bcc.s	ice08
	lea	ice17(pc),a1
	moveq	#4,d3
ice07:	move.l	-(a1),d0
	bsr.s	ice0c
	swap	d0
	cmp.w	d0,d1
	dbne	d3,ice07
	add.l	20(a1),d1
ice08:	move.b	-(a5),-(a6)
	dbra	d1,ice08
ice09:	cmpa.l	a4,a6
	bgt.s	ice0f
	rts
ice0a:	add.b	d7,d7
	bne.s	ice0b
	move.b	-(a5),d7
	addx.b	d7,d7
ice0b:	rts
ice0c:	moveq	#0,d1
ice0d:	add.b	d7,d7
	bne.s	ice0e
	move.b	-(a5),d7
	;MOVE.W	D7,$FFFF8240.W
	addx.b	d7,d7
ice0e:	addx.w	d1,d1
	dbra	d0,ice0d
	rts
ice0f:	lea	ice18(pc),a1
	moveq	#3,d2
ice10:	bsr.s	ice0a
	dbcc	d2,ice10
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	ice11
	bsr.s	ice0c
ice11:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	ice13
	lea	ice19(pc),a1
	moveq	#1,d2
ice12:	bsr.s	ice0a
	dbcc	d2,ice12
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	ice0c
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	ice15
	sub.w	d4,d1
	bra.s	ice15
ice13:	moveq	#0,d1
	moveq	#5,d0
	moveq	#-1,d2
	bsr.s	ice0a
	bcc.s	ice14
	moveq	#8,d0
	moveq	#$3f,d2
ice14:	bsr.s	ice0c
	add.w	d2,d1
ice15:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
ice16:	move.b	-(a1),-(a6)
	dbra	d4,ice16
	bra	ice06
	DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
	DC.B $00,$07,$00,$02,$00,$03,$00,$01
	DC.B $00,$03,$00,$01
ice17:	DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
	DC.B $00,$00,$00,$07,$00,$00,$00,$04
	DC.B $00,$00,$00,$01
ice18:	DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
	DC.B $01,$00
ice19:	DC.B $0b,$04,$07,$00,$01,$1f,$ff,$ff
	DC.B $00,$1f	    
	    
;---------------------------------------------------------------------------           
            section data
teeem      dc.w 	0
wsjo       dc.w 	63
tim_op     dc.w 	1 
sav_sp	   dc.l 0
temp_pal   ds.l 	256
;---------------------------------------------------------------------------
pic       incbin  	mb_hi.dat
pic_pal   incbin  	mb_hi.pal
;---------------------------------------------------------------------------
