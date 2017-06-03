	INCLUDE	"B:\START.S"
	INCLUDE	"B:\SUPER_ON.S
	
	BSR	SET_MUS
	
	MOVE.W	#7,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	
	BSR	UNSET_MUS
	INCLUDE	"B:\SUPER_OF.S"
	
	MOVE.W	#0,-(SP)
	TRAP	#1
*--------------------------------------------------------------------------*	
set_mus:
 clr.w music+$80a
 moveq #1,d0
 jsr music
 move.l #music+4,$4d2
 rts
*--------------------------------------------------------------------------*	
dpl1:
 move.l (a0)+,(a1)+
 dbra d0,dpl1
 jsr $63268
 move.l #$a,$4d2
 rts
*--------------------------------------------------------------------------*	
unset_mus:
 clr.l $4d2
 rts
*--------------------------------------------------------------------------*	
music	 incbin "A:\SYNC.B"
*--------------------------------------------------------------------------*	
	SECTION DATA

	SECTION BSS
ANC_PILE	DS.L	1
	DS.L	100
PILE	DS.L	1
