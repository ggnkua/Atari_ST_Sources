

BRA_VCEQ	Equ	%00
BRA_VCGT	Equ	%01
BRA_VCLT	Equ	%10
BRA_GPU		Equ	%11



Setup_Initial_Branch
	Lea	Master_Stop_Object(pc),a1
	Move.l	a1,d0
	And.l	#-8,d0
	Move.l	d0,a1
	Pea	(a1)
	Move.l	#0,(a1)+
	Move.l	#4,(a1)+
; a1 now points to first branch object
	Lea	Dont_Know_What_This_Does_Pointer(pc),a3
	Move.l	a1,(a3)
	Move.l	a1,a0				; Setup pointer to branch
	Move.l	(sp),a1				; Setup destination (if branch taken!)
	Move.w	#BRA_VCLT,d0			; Condition
;	Move.w	#N_VDE,d1			; Line number ( halflines !)
	Ifd	Booter
	Move.w	Height_Of_Screen(pc),d1
	Else
	Move.w	Height_Of_Screen+Data,d1
	Endc
	Add.w	d1,d1
	Add.w	#N_VDB,d1
	Bsr	Make_Branch_Object
	Move.l	(sp)+,a1			; Setup destination (if branch taken!)
	Move.w	#BRA_VCGT,d0			; Condition
	Move.w	#N_VDB,d1			; Line number ( halflines !)
	Bsr	Make_Branch_Object
	Rts


Make_Branch_Object
	Moveq	#0,d6
	Moveq	#3,d7				; 64 bits ( branch object, type 3)
	Lsl.w	#3,d1
	Or.w	d1,d7				; Set y-pos
	Moveq	#14,d5
	Lsl.w	d5,d0				; Condition
	Or.w	d0,d7				; Set conidition
	Move.l	a1,d5
	Lsr.l	#3,d5				; Branch is in phrases
	Move.l	d5,d4
	And.l	#%11111111,d5
	Ror.l	#8,d5
	Or.l	d5,d7
	Lsr.l	#8,d4
	Move.l	d4,d6
	Move.l	d6,(a0)+
	Move.l	d7,(a0)+
	Rts

Dont_Know_What_This_Does_Pointer
	Ds.l	1

	Ds.b	8
Master_Stop_Object
	Ds.b	32
