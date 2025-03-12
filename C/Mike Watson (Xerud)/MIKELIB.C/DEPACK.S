		EXPORT	Depackice,Depackatm5
		MACRO	push.size	reggie
		move.size	reggie,-(a7)
		ENDM	
		
		MACRO	pop.size	reggie
		move.size	(a7)+,reggie
		ENDM

Depackice:
		include	"d:\depacker.s\ice_unpa.s"

Depackatm5:
		include	"d:\depacker.s\a35_2.s"		