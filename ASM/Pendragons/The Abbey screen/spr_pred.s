	lea sprite1,a0
	lea spr_1,a1
	
	moveq #34,d0
	
trans_spr	movem.l (a0),d1-d4
	movem.l d1-d4,(a1)
	
	lea 16(a0),a0
	lea 24(a1),a1
	
	dbf d0,trans_spr
	
	lea spr_1,a0
	lea spr_1+840,a1

	moveq #14,d0

predec_2	moveq #34,d1

predec_3	movem.l (a0),d2-d7
	movem.l d2-d7,(a1)
	
	roxr (a1)
	roxr 8(a1)
	roxr 16(a1)
	
	roxr 2(a1)
	roxr 10(a1)
	roxr 18(a1)
	
	roxr 4(a1)
	roxr 12(a1)
	roxr 20(a1)
	
	roxr 6(a1)
	roxr 14(a1)
	roxr 22(a1)
	
	lea 24(a0),a0
	lea 24(a1),a1
	
	dbf d1,predec_3
	
	dbf d0,predec_2

	lea sprite2,a0
	lea spr_2,a1
	
	moveq #14,d0
	
tran_spr	movem.l (a0),d1-d7/a2
	movem.l d1-d7/a2,(a1)
	
	lea 32(a0),a0
	lea 40(a1),a1
	
	dbf d0,tran_spr
	
	lea spr_2,a0
	lea spr_2+600,a1
	
	moveq #14,d0

predec_4	moveq #14,d1

predec_5	movem.l (a0),d2-d7/a2-a5
	movem.l d2-d7/a2-a5,(a1)
	
	roxr (a1)
	roxr 8(a1)
	roxr 16(a1)
	roxr 24(a1)
	roxr 32(a1)
	
	roxr 2(a1)
	roxr 10(a1)
	roxr 18(a1)
	roxr 26(a1)
	roxr 34(a1)
	
	roxr 4(a1)
	roxr 12(a1)
	roxr 20(a1)
	roxr 28(a1)
	roxr 36(a1)
	
	roxr 6(a1)
	roxr 14(a1)
	roxr 22(a1)
	roxr 30(a1)
	roxr 38(a1)
	
	lea 40(a0),a0
	lea 40(a1),a1
	
	dbf d1,predec_5
	
	dbf d0,predec_4

	rts
	