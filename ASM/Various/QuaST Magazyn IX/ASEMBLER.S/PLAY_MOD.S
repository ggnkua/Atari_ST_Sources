;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|				Play STe - Prosta odgrywaczka do modulow	  			  |
;|  																	  |
;| autor: Van Eijk, procedura muzyczna: Lancy		    				  |	
;| uwagi: -	Odgrywaczka jest nieskonczona i nigdy nie zostanie skonczona. |
;*------------------------------------------------------------------------*

WYW:		equ		32
EKRAN:		equ		$e6000+246*160
EKRAN1:		equ		$e6000
EKRAN2:		equ		$e6000+103*160
WYSOKOSC	equ		64

*-------------------------------------------------------------------------*

letsgo	MOVE.L 	4(SP),A5
		MOVE.L 	$C(A5),A4
		ADD.L 	$14(A5),A4
		ADD.L 	$1C(A5),A4
		LEA 	$100(A4),A4			; proggy size+basepage
		PEA 	(A4)
		PEA 	(A5)
		CLR 	-(SP)
		MOVE 	#$4A,-(SP)
		TRAP 	#1				; reserve some memory
		LEA 	12(SP),SP
		BSR 	appl_ini			; appli init
		CLR.L 	-(SP)
		MOVE 	#$20,-(SP)	
		TRAP 	#1				; supervisor mode
		ADDQ.L 	#6,SP
		MOVE.L 	D0,oldsp
		MOVE.L 	USP,A0
		MOVE.L 	A0,oldusp
		
		LEA 	my_stack,SP			; our own stack.
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_stuff		; save palette

		MOVE 	#4,-(SP)
		TRAP 	#14			; get rez
		ADDQ.L 	#2,SP
		CMP.W 	#2,D0
		BEQ 	exit			; exit if in hirez
		MOVE.W 	D0,oldres

*		DC.W 	$A00A			; hide mouse

		BSR 	set_screen			; setup the screen
		MOVE 	#1,-(SP)
		PEA 	$c6000
		PEA 	$c6000
		MOVE 	#5,-(SP)
		TRAP 	#14
		LEA 	12(SP),SP

		move.l	#TU,a0
		move.l	#MT_FUNKTABLE,a1
		move.w	#1999,d0
kl1:	move.w	(a1)+,(a0)+
		dbf		d0,kl1

		MOVE 	#$777,D7
fadedownfirst	BSR Wait_Vbl
		BSR 	Wait_Vbl
		MOVE.W 	D7,$FFFF8240.W
		SUB 	#$111,D7
		BGE.S 	fadedownfirst
		MOVE.L 	#$00000777,$FFFF8240.W
		MOVE.L 	#$00000777,$FFFF8244.W
		BSR 	Wait_Vbl
		move.w	#$fff,$fff8246
		move.w	#$fff,$fff8242
		move.w	#$fff,$fff825e

		MOVE 	#1,-(SP)
		PEA 	$e6000
		PEA 	$e6000
		MOVE 	#5,-(SP)
		TRAP 	#14
		LEA 	12(SP),SP
	
select	
		MOVE 	#1,-(SP)
		PEA 	$e6000
		PEA 	$e6000
		MOVE 	#5,-(SP)
		TRAP 	#14
		LEA 	12(SP),SP
		BSR 	Wait_Vbl
		BSR 	clsfast
		move.w	#$000,$fff8240
		move.w	#$fff,$fff8246
		move.w	#$fff,$fff8242
		move.w	#$fff,$fff825e

		DC.W 	$A009
		BSR 	fileselect
		TST 	int_out+2
		BEQ 	exit 			; <cancel> exits.
		DC.W 	$A00A
		BSR 	Wait_Vbl
		BSR 	clsfast			; clear the screen
loadit	BSR Concate_path	
		LEA path_n_name(PC),A4
		LEA mt_data,A5
		MOVE.L #1000000,D7
		BSR Load_file
		TST.B errorflag
		BNE.S select
		LEA mt_data,A0
test_pack	CMP.L #'ICE!',(A0)
		BNE.S nodecrunch
depack_mod	
		LEA mt_data,A0
		BSR ice_decrunch
nodecrunch	

*-------------------------------------------------------------------------*

		move.l	#TU,a1
		move.l	#MT_FUNKTABLE,a0
		move.w	#1999,d0
kl2:	move.w	(a1)+,(a0)+
		dbf		d0,kl2
		
		MOVE 	#0,-(SP)
		PEA 	$e6000
		PEA 	$e6000
		MOVE 	#5,-(SP)
		TRAP 	#14
		LEA 	12(SP),SP

		move.w	#$000,$fff8240
		move.w	#$fff,$fff8246
		move.w	#$fff,$fff8242
		move.w	#$fff,$fff825e
		jsr		WYPISZ

		jsr 	init_ints			; and go!

*-------------------------------------------------------------------------*

DOLOOP:	bra		DOLOOP
WAITK	jSR 	restore_ints		; restore gem..
		BRA 	select			; select another file...

*-------------------------------------------------------------------------*

exit	MOVE 	oldres(PC),-(SP)
		PEA 	-1.W
		PEA 	-1.W
		MOVE 	#5,-(SP)
		TRAP 	#14
		LEA 	12(SP),SP
		MOVEM.L old_stuff(PC),D0-D7	; restore palette
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE.L 	oldsp(PC),-(SP)
		MOVE 	#$20,-(SP)	
		TRAP 	#1				; user mode
		ADDQ.L 	#6,SP
		BSR 	appl_exi			; appli exit.
.redir	PEA 	dummy(PC)
		MOVE.W 	#$4e,-(SP)
		TRAP 	#1	
		ADDQ.L 	#8,SP
		CLR.W 	-(SP)			; Get dir.
		PEA 	dir
		MOVE.W 	#$47,-(SP)
		TRAP 	#1
		ADDQ.L 	#8,SP
		CLR 	-(SP)
		TRAP 	#1

*-------------------------------------------------------------------------*

init_ints	
		move.w	#1,WYK1
		move.w	#1,WYK2
		move.w	#1,WYK3
		move.w	#1,WYK4
		move.w	#1,WYK5
		move.w	#1,WYK6
		move.w	#1,WYK7
		move.w	#1,WYK8
		move.w	#1,WYK9
		move.w	#1,WYK10
		move.w	#1,WYK11
		move.w	#1,WYK12
		move.w	#1,WYK13
		move.w	#1,WYK14
		move.w	#1,WYK15
		move.w	#1,WYK16
		move.w	#1,WYK17
		move.w	#1,WYK18
		move.w	#1,WYK19
		move.w	#1,WYK20
		move.w	#1,WYK21
		move.w	#1,WYK22
		move.w	#1,WYK23
		move.w	#1,WYK24
		move.w	#1,WYK25
		move.w	#1,WYK26
		move.w	#1,WYK27
		move.w	#1,WYK28
		move.w	#1,WYK29
		move.w	#1,WYK30
		move.w	#0,TERAZ
		move.w	#1,WYKA1
		move.w	#1,WYKA2
		move.w	#1,WYKA3
		move.w	#1,WYKA4
		move.w	#0,S0
		move.w	#0,KIEDY
		jsr		WYCZ
		move.l  #SAFEREG,a0
		move.l	$70,(a0)+
		move.l	$118,(a0)+
		move.l	$120,(a0)+
		move.l	$134,(a0)+
		move.b  $fffa07,(a0)+
		move.b  $fffa09,(a0)+
		move.b  $fffa0b,(a0)+
		move.b  $fffa0f,(a0)+
		move.b  $fffa13,(a0)+
		move.b  $fffa15,(a0)+
		move.b  $fffa17,(a0)+
		move.b  $fffa19,(a0)+	
		move.b  $fffa1f,(a0)+	
		move.b  $fffa1b,(a0)+
		move.b  $fffa1d,(a0)+		
		move.b  $fffa21,(a0)+
		jsr		MT_INIT
		move.w	#$7ff,$ff8924		* plynne regulowanie glosnosci...
		move.w	#0,KONIEC
		move.w 	#$2700,SR
		move.b	#0,$484
		move.b	#18,$fffc02
		move.b 	#8,$fffa1b
		move.b 	#4,$fffa21
		clr.b  	$fffffa19		
		move.b 	#$21,$fffffa07	
		move.b 	#$21,$fffffa13	
		bclr   	#3,$fffffa17	
		clr.b	$fffffa09		disable interupt b
		clr.b	$fffffa15		set mask b
		move.l	#STRONICE,$118
		move.l 	#VBL,$70
		move.l 	#TIMER000,$120
		move.l 	#TIMER_A,$134
		move.w 	#$2300,sr		
		RTS

*-------------------------------------------------------------------------*

restore_ints	
		move.w	#$2700,sr
		move.l  #SAFEREG,a0
		move.l	(a0)+,$70
		move.l	(a0)+,$118
		move.l	(a0)+,$120
		move.l	(a0)+,$134
		move.b  (a0)+,$fffa07
		move.b  (a0)+,$fffa09
		move.b  (a0)+,$fffa0b                              
		move.b  (a0)+,$fffa0f
		move.b  (a0)+,$fffa13
		move.b  (a0)+,$fffa15
		move.b  (a0)+,$fffa17
		move.b  (a0)+,$fffa19	
		move.b  (a0)+,$fffa1f	
		move.b  (a0)+,$fffa1b
		move.b  (a0)+,$fffa1d
		move.b  (a0)+,$fffa21
		move.b  (a0)+,$fffa23
		move.w	#$2300,sr		
		jsr		MT_END
		move.b	#255,$484
		move.b	#8,$fffc02
		jsr		CLSFAST
		RTS

*-------------------------------------------------------------------------*

VBL:	clr.b	$fffffa19		
		move.b	#100,$fffffa1f	
		move.b	#4,$fffffa19	
		clr.b	$fffffa1b		
		move.b	#1,$fffffa21	
		move.l	#TIMER00,$120
		move.b	#8,$fffffa1b	
		cmp.w	#1,KONIEC
		beq		WAITK
		cmp.b	#57,$fffc02
		beq		WAITK

		movem.l	a0-a7/d0-d7,-(sp)
		jsr		MT_PAULA
		jsr		MT_MUSIC
		movem.l	(sp)+,a0-a7/d0-d7
		jsr		SPRAWA
		jsr		WYKRES
		jsr		WYBOR

		cmp.w	#1,SIUP
		bne		RTE
		jsr		COTY
RTE:	rte

*-------------------------------------------------------------------------*
	
WYPISZ:	move.l	#EKRAN1+160+(0*18*160)+2,a0
		move.l	#EKRAN1+160+(1*18*160)+2,a1
		move.l	#EKRAN1+160+(2*18*160)+2,a2
		move.l	#EKRAN1+160+(3*18*160)+2,a3
		move.l	#EKRAN1+160+(4*18*160)+2,a4
		move.l	#EKRAN1+160+(5*18*160)+2,a5
		move.w	#16,d0
WYP00:	move.w	#%1111111111111111,00(a0)
		move.w	#%1111111111111111,08(a0)
		move.w	#%1111111111111111,16(a0)
		move.w	#%1111111111111111,24(a0)
		move.w	#%1111111111111111,32(a0)
		move.w	#%1111111111111111,40(a0)
		move.w	#%1111111111111111,48(a0)
		move.w	#%1111111111111111,058(a0)
		move.w	#%1111111111111111,066(a0)
		move.w	#%1111111111111111,074(a0)
		move.w	#%1111111111111111,082(a0)
		move.w	#%1111111111111111,090(a0)
		move.w	#%1111111111111111,098(a0)
		move.w	#%1111111111111111,106(a0)
		move.w	#%1111111111111111,114(a0)
		move.w	#%1111111111111111,122(a0)
		move.w	#%1111111111111111,130(a0)
		move.w	#%1111111111111111,138(a0)
		move.w	#%1111111111111111,148(a0)
		move.w	#%1111111111111111,156(a0)
		move.w	#%1111111111111111,148+160(a0)
		move.w	#%1111111111111111,156+160(a0)
		add.w	#160,a0
		move.w	#%1111111111111111,00(a1)
		move.w	#%1111111111111111,08(a1)
		move.w	#%1111111111111111,16(a1)
		move.w	#%1111111111111111,24(a1)
		move.w	#%1111111111111111,32(a1)
		move.w	#%1111111111111111,40(a1)
		move.w	#%1111111111111111,48(a1)
		move.w	#%1111111111111111,058(a1)
		move.w	#%1111111111111111,066(a1)
		move.w	#%1111111111111111,074(a1)
		move.w	#%1111111111111111,082(a1)
		move.w	#%1111111111111111,090(a1)
		move.w	#%1111111111111111,098(a1)
		move.w	#%1111111111111111,106(a1)
		move.w	#%1111111111111111,114(a1)
		move.w	#%1111111111111111,122(a1)
		move.w	#%1111111111111111,130(a1)
		move.w	#%1111111111111111,138(a1)
		move.w	#%1111111111111111,148(a1)
		move.w	#%1111111111111111,156(a1)
		move.w	#%1111111111111111,148+160(a1)
		move.w	#%1111111111111111,156+160(a1)
		add.w	#160,a1
		move.w	#%1111111111111111,00(a2)
		move.w	#%1111111111111111,08(a2)
		move.w	#%1111111111111111,16(a2)
		move.w	#%1111111111111111,24(a2)
		move.w	#%1111111111111111,32(a2)
		move.w	#%1111111111111111,40(a2)
		move.w	#%1111111111111111,48(a2)
		move.w	#%1111111111111111,058(a2)
		move.w	#%1111111111111111,066(a2)
		move.w	#%1111111111111111,074(a2)
		move.w	#%1111111111111111,082(a2)
		move.w	#%1111111111111111,090(a2)
		move.w	#%1111111111111111,098(a2)
		move.w	#%1111111111111111,106(a2)
		move.w	#%1111111111111111,114(a2)
		move.w	#%1111111111111111,122(a2)
		move.w	#%1111111111111111,130(a2)
		move.w	#%1111111111111111,138(a2)
		move.w	#%1111111111111111,148(a2)
		move.w	#%1111111111111111,156(a2)
		move.w	#%1111111111111111,148+160(a2)
		move.w	#%1111111111111111,156+160(a2)
		add.w	#160,a2
		move.w	#%1111111111111111,00(a3)
		move.w	#%1111111111111111,08(a3)
		move.w	#%1111111111111111,16(a3)
		move.w	#%1111111111111111,24(a3)
		move.w	#%1111111111111111,32(a3)
		move.w	#%1111111111111111,40(a3)
		move.w	#%1111111111111111,48(a3)
		move.w	#%1111111111111111,058(a3)
		move.w	#%1111111111111111,066(a3)
		move.w	#%1111111111111111,074(a3)
		move.w	#%1111111111111111,082(a3)
		move.w	#%1111111111111111,090(a3)
		move.w	#%1111111111111111,098(a3)
		move.w	#%1111111111111111,106(a3)
		move.w	#%1111111111111111,114(a3)
		move.w	#%1111111111111111,122(a3)
		move.w	#%1111111111111111,130(a3)
		move.w	#%1111111111111111,138(a3)
		move.w	#%1111111111111111,148(a3)
		move.w	#%1111111111111111,156(a3)
		move.w	#%1111111111111111,148+160(a3)
		move.w	#%1111111111111111,156+160(a3)
		add.w	#160,a3
		move.w	#%1111111111111111,00(a4)
		move.w	#%1111111111111111,08(a4)
		move.w	#%1111111111111111,16(a4)
		move.w	#%1111111111111111,24(a4)
		move.w	#%1111111111111111,32(a4)
		move.w	#%1111111111111111,40(a4)
		move.w	#%1111111111111111,48(a4)
		move.w	#%1111111111111111,058(a4)
		move.w	#%1111111111111111,066(a4)
		move.w	#%1111111111111111,074(a4)
		move.w	#%1111111111111111,082(a4)
		move.w	#%1111111111111111,090(a4)
		move.w	#%1111111111111111,098(a4)
		move.w	#%1111111111111111,106(a4)
		move.w	#%1111111111111111,114(a4)
		move.w	#%1111111111111111,122(a4)
		move.w	#%1111111111111111,130(a4)
		move.w	#%1111111111111111,138(a4)
		move.w	#%1111111111111111,148(a4)
		move.w	#%1111111111111111,156(a4)
		move.w	#%1111111111111111,148+160(a4)
		move.w	#%1111111111111111,156+160(a4)
		add.w	#160,a4
		move.w	#%1111111111111111,00(a5)
		move.w	#%1111111111111111,08(a5)
		move.w	#%1111111111111111,16(a5)
		move.w	#%1111111111111111,24(a5)
		move.w	#%1111111111111111,32(a5)
		move.w	#%1111111111111111,40(a5)
		move.w	#%1111111111111111,48(a5)
		move.w	#%1111111111111111,058(a5)
		move.w	#%1111111111111111,066(a5)
		move.w	#%1111111111111111,074(a5)
		move.w	#%1111111111111111,082(a5)
		move.w	#%1111111111111111,090(a5)
		move.w	#%1111111111111111,098(a5)
		move.w	#%1111111111111111,106(a5)
		move.w	#%1111111111111111,114(a5)
		move.w	#%1111111111111111,122(a5)
		move.w	#%1111111111111111,130(a5)
		move.w	#%1111111111111111,138(a5)
		move.w	#%1111111111111111,148(a5)
		move.w	#%1111111111111111,156(a5)
		move.w	#%1111111111111111,148+160(a5)
		move.w	#%1111111111111111,156+160(a5)
		add.w	#160,a5
		dbf		d0,WYP00
		jsr		BIERZ1

		move.w	#00,SS1
		move.w	#40,SS2		* wysokosc LR
		move.w	#20,SS3		* wysokosc L
		move.w	#20,SS4		* wysokosc R
		move.w	#06,SS5		* bass
		move.w	#06,SS6		* treble

		move.w	#1,SIUP
		move.w	#0,S0
		jsr		COTY
		move.w	#1,SIUP
		move.w	#1,S0
		jsr		COTY
		move.w	#1,SIUP
		move.w	#2,S0
		jsr		COTY
		move.w	#1,SIUP
		move.w	#3,S0
		jsr		COTY
		move.w	#1,SIUP
		move.w	#4,S0
		jsr		COTY
		move.w	#1,SIUP
		move.w	#5,S0
		jsr		COTY
		rts

*-------------------------------------------------------------------------*

COTY:	movem.l	a0-a6/d0-d7,-(sp)
		cmp.w	#0,S0
		bne		COT01
		move.l	#TABXX+15*2,a2
		move.l	#MT_DATA,a0
		move.l	#SSS1,a4
		clr.w	d0
		move.w	SS1,d0
		mulu.w	#2,d0
		add.w	d0,a4
		add.w	(a4),a0
		move.w	#19,d0
		cmp.w	#0,SS1
		beq.s	OK1			
		move.w	#21,d0
OK1:	jsr		BIERI
COT01:	cmp.w	#1,S0			* kanal LR
		bne		COT02
		clr.w	d0
		move.w	#1216,d0
		add.w	SS2,d0
		move.w	d0,$fff8922
		move.l	#EKRAN1+20*160+57,a1
		move.l	#LICZ,a0
		clr.w	d0
		move.w	SS2,d0
		mulu.w	#32,d0
		add.w	d0,a0
		jsr		POKAR1
COT02:	cmp.w	#2,S0			* kanal L
		bne		COT03
		clr.w	d0
		move.w	#1344,d0
		add.w	SS3,d0
		move.w	d0,$fff8922
		move.l	#EKRAN1+38*160+57,a1
		move.l	#LICZ,a0
		clr.w	d0
		move.w	SS3,d0
		mulu.w	#32,d0
		add.w	d0,a0
		jsr		POKAR1
COT03:	cmp.w	#3,S0			* kanal R
		bne		COT04
		clr.w	d0
		move.w	#1280,d0
		add.w	SS4,d0
		move.w	d0,$fff8922
		move.l	#EKRAN1+56*160+57,a1
		move.l	#LICZ,a0
		clr.w	d0
		move.w	SS4,d0
		mulu.w	#32,d0
		add.w	d0,a0
		jsr		POKAR1
COT04:	cmp.w	#4,S0			* bass 
		bne		COT05
		clr.w	d0
		move.w	#1088,d0
		add.w	SS5,d0
		move.w	d0,$fff8922
		move.l	#EKRAN1+74*160+57,a1
		move.l	#LICZ,a0
		clr.w	d0
		move.w	SS5,d0
		mulu.w	#32,d0
		add.w	d0,a0
		jsr		POKAR1
COT05:	cmp.w	#5,S0			* treble
		bne		COT06
		clr.w	d0
		move.w	#1152,d0
		add.w	SS6,d0
		move.w	d0,$fff8922
		move.l	#EKRAN1+92*160+57,a1
		move.l	#LICZ,a0
		clr.w	d0
		move.w	SS6,d0
		mulu.w	#32,d0
		add.w	d0,a0
		jsr		POKAR1
COT06:
		movem.l	(sp)+,a0-a6/d0-d7
		clr.w	SIUP
		rts

*-------------------------------------------------------------------------*

POKAR1:	move.b	00(a0),0000(a1)
		move.b	02(a0),0160(a1)
		move.b	04(a0),0320(a1)
		move.b	06(a0),0480(a1)
		move.b	08(a0),0640(a1)
		move.b	10(a0),0800(a1)
		move.b	12(a0),0960(a1)
		move.b	14(a0),1120(a1)
		move.b	16(a0),1280(a1)
		move.b	18(a0),1440(a1)
		move.b	20(a0),1600(a1)
		move.b	22(a0),1760(a1)
		move.b	24(a0),1920(a1)
		move.b	26(a0),2080(a1)
		move.b	28(a0),2240(a1)
		move.b	30(a0),2400(a1)
		move.b	01(a0),0007(a1)
		move.b	03(a0),0167(a1)
		move.b	05(a0),0327(a1)
		move.b	07(a0),0487(a1)
		move.b	09(a0),0647(a1)
		move.b	11(a0),0807(a1)
		move.b	13(a0),0967(a1)
		move.b	15(a0),1127(a1)
		move.b	17(a0),1287(a1)
		move.b	19(a0),1447(a1)
		move.b	21(a0),1607(a1)
		move.b	23(a0),1767(a1)
		move.b	25(a0),1927(a1)
		move.b	27(a0),2087(a1)
		move.b	29(a0),2247(a1)
		move.b	31(a0),2407(a1)
		rts

*-------------------------------------------------------------------------*

BIERI:	move.l	#EKRAN1+1*160,a1
		add.w	(a2)+,a1
		move.l	#FONT,a3
		clr.w	d1
		move.b	(a0)+,d1
		mulu.w	#16,d1
		add.w	d1,a3
		move.b	00(a3),0000(a1)
		move.b	01(a3),0160(a1)
		move.b	02(a3),0320(a1)
		move.b	03(a3),0480(a1)
		move.b	04(a3),0640(a1)
		move.b	05(a3),0800(a1)
		move.b	06(a3),0960(a1)
		move.b	07(a3),1120(a1)
		move.b	08(a3),1280(a1)
		move.b	09(a3),1440(a1)
		move.b	10(a3),1600(a1)
		move.b	11(a3),1760(a1)
		move.b	12(a3),1920(a1)
		move.b	13(a3),2080(a1)
		move.b	14(a3),2240(a1)
		move.b	15(a3),2400(a1)	
		dbf		d0,BIERI
		cmp.w	#0,SS1		
		bne		BIERE
		move.l	#EKRAN1+1*160+136,a1
		move.w	#0,0000(a1)
		move.w	#0,0160(a1)
		move.w	#0,0320(a1)
		move.w	#0,0480(a1)
		move.w	#0,0640(a1)
		move.w	#0,0800(a1)
		move.w	#0,0960(a1)
		move.w	#0,1120(a1)
		move.w	#0,1280(a1)
		move.w	#0,1440(a1)
		move.w	#0,1600(a1)
		move.w	#0,1760(a1)
		move.w	#0,1920(a1)
		move.w	#0,2080(a1)
		move.w	#0,2240(a1)
		move.w	#0,2400(a1)
BIERE:	rts

*-------------------------------------------------------------------------*

SS1:	dc.w	1
SS2:	dc.w	1
SS3:	dc.w	1
SS4:	dc.w	1
SS5:	dc.w	1
SS6:	dc.w	1
		even
SIUP:	dc.w	1
		even
SSS1:	dc.w	000,020,050,080,110,140,170,200,230,260,290
		dc.w	320,350,380,410,440,470,500,530,560,590
		dc.w	620,650,680,710,740,770,800,830,860,890
		even

BIERZ1:	move.l	#T1,a0
		clr.w	d3
		move.w	#5,d4
BIERZ3:	move.l	#TABXX,a2
		move.w	#14,d0
BIERZ2:	move.l	#EKRAN1+1*160,a1
		add.w	d3,a1
		add.w	(a2)+,a1
		move.l	#FONT,a3
		clr.w	d1
		move.b	(a0)+,d1
		mulu.w	#16,d1
		add.w	d1,a3
		move.b	00(a3),0000(a1)
		move.b	01(a3),0160(a1)
		move.b	02(a3),0320(a1)
		move.b	03(a3),0480(a1)
		move.b	04(a3),0640(a1)
		move.b	05(a3),0800(a1)
		move.b	06(a3),0960(a1)
		move.b	07(a3),1120(a1)
		move.b	08(a3),1280(a1)
		move.b	09(a3),1440(a1)
		move.b	10(a3),1600(a1)
		move.b	11(a3),1760(a1)
		move.b	12(a3),1920(a1)
		move.b	13(a3),2080(a1)
		move.b	14(a3),2240(a1)
		move.b	15(a3),2400(a1)	
		dbf		d0,BIERZ2
		add.w	#18*160,d3
		dbf		d4,BIERZ3
		rts

*-------------------------------------------------------------------------*

T1:			dc.b	"Nazwa modu‘u > "
			dc.b	"G‘o◊no◊“ LR  > "
			dc.b	"G‘o◊no◊“ L   > "
			dc.b	"G‘o◊no◊“ R   > "
			dc.b	"poziom bas÷w > "
			dc.b	"poziom trebli> "

TABX:		dc.w	0,1,4,5,8,9,12,13,16,17,20,21,24,25,28,29,32,33,36,37,40,41,44,45,48,49,52,53,56,57,60,61,64,65,68,69,72,73,76,77,80,81
			dc.w	84,85,88,89,92,93,96,97,100,101,104,105,108,109,112,113,116,117,120,121,124,125,128,129,132,133,136,137,140,141,144,145,148,149,152,153,156,157
			even			
TABXX:		dc.w	0,1,8,9,16,17,24,25,32,33,40,41,48,49,56,57,64,65,72,73,80,81,88,89,96,97,104,105,112,113,120,121,128,129,136,137,144,145,152,153

*    a    - — ¡
*    c    - “ ¬
*    e    - ” √
*    l    - ‘ ƒ
*    n    - ’ ≈
*    s    - ◊ «
*    o    - ÷ ∆
*    zaba - Ÿ …
*    z    - ÿ »

*-------------------------------------------------------------------------*

WYCZ:	move.w	#1,S1
		move.w	#1,S2
		move.w	#1,S3
		move.w	#1,S4
		move.w	#1,S5
		move.w	#1,S6
		rts

*-------------------------------------------------------------------------*

WYBOR:	jsr		WYCZ
		cmp.w	#0,S0
		bne		WYB0
		move.w	#2,S1
WYB0:	cmp.w	#1,S0
		bne		WYB1
		move.w	#2,S2
WYB1:	cmp.w	#2,S0
		bne		WYB2
		move.w	#2,S3
WYB2:	cmp.w	#3,S0
		bne		WYB3
		move.w	#2,S4
WYB3:	cmp.w	#4,S0
		bne		WYB4
		move.w	#2,S5
WYB4:	cmp.w	#5,S0
		bne		WYB5
		move.w	#2,S6
WYB5:	rts

*-------------------------------------------------------------------------*

S0:		dc.w	1
S1:		dc.w	1
S2:		dc.w	1
S3:		dc.w	1
S4:		dc.w	1
S5:		dc.w	1
S6:		dc.w	1

*-------------------------------------------------------------------------*

WYKRES:	movem.l	d0/a0,-(sp)
		sub.w	#1,WYK1
		cmp.w	#0,WYK1
		bne		NIE1
		move.w	#1,WYK1
NIE1:	move.l	#EKRAN+17,a0
		move.w	WYK1,d0
MN1:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN1
		move.b	#%00000000,(a0)
		sub.w	#1,WYK2
		cmp.w	#0,WYK2
		bne		NIE2
		move.w	#1,WYK2
NIE2:	move.l	#EKRAN+24,a0
		move.w	WYK2,d0
MN2:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN2
		move.b	#%00000000,(a0)
		sub.w	#1,WYK3
		cmp.w	#0,WYK3
		bne		NIE3
		move.w	#1,WYK3
NIE3:	move.l	#EKRAN+25,a0
		move.w	WYK3,d0
MN3:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN3
		move.b	#%00000000,(a0)
		sub.w	#1,WYK4
		cmp.w	#0,WYK4
		bne		NIE4
		move.w	#1,WYK4
NIE4:	move.l	#EKRAN+32,a0
		move.w	WYK4,d0
MN4:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN4
		move.b	#%00000000,(a0)
		sub.w	#1,WYK5
		cmp.w	#0,WYK5
		bne		NIE5
		move.w	#1,WYK5
NIE5:	move.l	#EKRAN+33,a0
		move.w	WYK5,d0
MN5:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN5
		move.b	#%00000000,(a0)
		sub.w	#1,WYK6
		cmp.w	#0,WYK6
		bne		NIE6
		move.w	#1,WYK6
NIE6:	move.l	#EKRAN+40,a0
		move.w	WYK6,d0
MN6:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN6
		move.b	#%00000000,(a0)
		sub.w	#1,WYK7
		cmp.w	#0,WYK7
		bne		NIE7
		move.w	#1,WYK7
NIE7:	move.l	#EKRAN+41,a0
		move.w	WYK7,d0
MN7:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN7
		move.b	#%00000000,(a0)
		sub.w	#1,WYK8
		cmp.w	#0,WYK8
		bne		NIE8
		move.w	#1,WYK8
NIE8:	move.l	#EKRAN+48,a0
		move.w	WYK8,d0
MN8:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN8
		move.b	#%00000000,(a0)
		sub.w	#1,WYK9
		cmp.w	#0,WYK9
		bne		NIE9
		move.w	#1,WYK9
NIE9:	move.l	#EKRAN+49,a0
		move.w	WYK9,d0
MN9:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN9
		move.b	#%00000000,(a0)
		sub.w	#1,WYK10
		cmp.w	#0,WYK10
		bne		NIE10
		move.w	#1,WYK10
NIE10:	move.l	#EKRAN+56,a0
		move.w	WYK10,d0
MN10:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN10
		move.b	#%00000000,(a0)
		sub.w	#1,WYK11
		cmp.w	#0,WYK11
		bne		NIE11
		move.w	#1,WYK11
NIE11:	move.l	#EKRAN+57,a0
		move.w	WYK11,d0
MN11:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN11
		move.b	#%00000000,(a0)
		sub.w	#1,WYK12
		cmp.w	#0,WYK12
		bne		NIE12
		move.w	#1,WYK12
NIE12:	move.l	#EKRAN+64,a0
		move.w	WYK12,d0
MN12:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN12
		move.b	#%00000000,(a0)
		sub.w	#1,WYK13
		cmp.w	#0,WYK13
		bne		NIE13
		move.w	#1,WYK13
NIE13:	move.l	#EKRAN+65,a0
		move.w	WYK13,d0
MN13:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN13
		move.b	#%00000000,(a0)
		sub.w	#1,WYK14
		cmp.w	#0,WYK14
		bne		NIE14
		move.w	#1,WYK14
NIE14:	move.l	#EKRAN+72,a0
		move.w	WYK14,d0
MN14:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN14
		move.b	#%00000000,(a0)
		sub.w	#1,WYK15
		cmp.w	#0,WYK15
		bne		NIE15
		move.w	#1,WYK15
NIE15:	move.l	#EKRAN+73,a0
		move.w	WYK15,d0
MN15:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN15
		move.b	#%00000000,(a0)
		sub.w	#1,WYK16
		cmp.w	#0,WYK16
		bne		NIE16
		move.w	#1,WYK16
NIE16:	move.l	#EKRAN+80,a0
		move.w	WYK16,d0
MN16:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN16
		move.b	#%00000000,(a0)
		sub.w	#1,WYK17
		cmp.w	#0,WYK17
		bne		NIE17
		move.w	#1,WYK17
NIE17:	move.l	#EKRAN+81,a0
		move.w	WYK17,d0
MN17:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN17
		move.b	#%00000000,(a0)
		sub.w	#1,WYK18
		cmp.w	#0,WYK18
		bne		NIE18
		move.w	#1,WYK18
NIE18:	move.l	#EKRAN+88,a0
		move.w	WYK18,d0
MN18:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN18
		move.b	#%00000000,(a0)
		sub.w	#1,WYK19
		cmp.w	#0,WYK19
		bne		NIE19
		move.w	#1,WYK19
NIE19:	move.l	#EKRAN+89,a0
		move.w	WYK19,d0
MN19:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN19
		move.b	#%00000000,(a0)
		sub.w	#1,WYK20
		cmp.w	#0,WYK20
		bne		NIE20
		move.w	#1,WYK20
NIE20:	move.l	#EKRAN+96,a0
		move.w	WYK20,d0
MN20:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN20
		move.b	#%00000000,(a0)
		sub.w	#1,WYK21
		cmp.w	#0,WYK21
		bne		NIE21
		move.w	#1,WYK21
NIE21:	move.l	#EKRAN+97,a0
		move.w	WYK21,d0
MN21:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN21
		move.b	#%00000000,(a0)
		sub.w	#1,WYK22
		cmp.w	#0,WYK22
		bne		NIE22
		move.w	#1,WYK22
NIE22:	move.l	#EKRAN+104,a0
		move.w	WYK22,d0
MN22:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN22
		move.b	#%00000000,(a0)
		sub.w	#1,WYK23
		cmp.w	#0,WYK23
		bne		NIE23
		move.w	#1,WYK23
NIE23:	move.l	#EKRAN+105,a0
		move.w	WYK23,d0
MN23:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN23
		move.b	#%00000000,(a0)
		sub.w	#1,WYK24
		cmp.w	#0,WYK24
		bne		NIE24
		move.w	#1,WYK24
NIE24:	move.l	#EKRAN+112,a0
		move.w	WYK24,d0
MN24:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN24
		move.b	#%00000000,(a0)
		sub.w	#1,WYK25
		cmp.w	#0,WYK25
		bne		NIE25
		move.w	#1,WYK25
NIE25:	move.l	#EKRAN+113,a0
		move.w	WYK25,d0
MN25:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN25
		move.b	#%00000000,(a0)
		sub.w	#1,WYK26
		cmp.w	#0,WYK26
		bne		NIE26
		move.w	#1,WYK26
NIE26:	move.l	#EKRAN+120,a0
		move.w	WYK26,d0
MN26:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN26
		move.b	#%00000000,(a0)
		sub.w	#1,WYK27
		cmp.w	#0,WYK27
		bne		NIE27
		move.w	#1,WYK27
NIE27:	move.l	#EKRAN+121,a0
		move.w	WYK27,d0
MN27:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN27
		move.b	#%00000000,(a0)
		sub.w	#1,WYK28
		cmp.w	#0,WYK28
		bne		NIE28
		move.w	#1,WYK28
NIE28:	move.l	#EKRAN+128,a0
		move.w	WYK28,d0
MN28:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN28
		move.b	#%00000000,(a0)
		sub.w	#1,WYK29
		cmp.w	#0,WYK29
		bne		NIE29
		move.w	#1,WYK29
NIE29:	move.l	#EKRAN+129,a0
		move.w	WYK29,d0
MN29:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN29
		move.b	#%00000000,(a0)
		sub.w	#1,WYK30
		cmp.w	#0,WYK30
		bne		NIE30
		move.w	#1,WYK30
NIE30:	move.l	#EKRAN+136,a0
		move.w	WYK30,d0
MN30:	move.b	#%01111111,(a0)
		sub.w	#320,a0
		dbf		d0,MN30
		move.b	#%00000000,(a0)
*
		sub.w	#1,WYKA1
		cmp.w	#0,WYKA1
		bne		NIEA1
		move.w	#1,WYKA1
NIEA1:	move.l	#EKRAN2+144,a0
		clr.w	d0
		move.w	WYKA1,d0
MNA1:	move.b	#%11111110,(a0)
		move.b	#%11111110,160(a0)
		sub.w	#480,a0
		dbf		d0,MNA1
		move.b	#%00000000,(a0)
		move.b	#%00000000,160(a0)
		sub.w	#1,WYKA2
		cmp.w	#0,WYKA2
		bne		NIEA2
		move.w	#1,WYKA2
NIEA2:	move.l	#EKRAN2+145,a0
		clr.w	d0
		move.w	WYKA2,d0
MNA2:	move.b	#%11111110,(a0)
		move.b	#%11111110,160(a0)
		sub.w	#480,a0
		dbf		d0,MNA2
		move.b	#%00000000,(a0)
		move.b	#%00000000,160(a0)
		sub.w	#1,WYKA3
		cmp.w	#0,WYKA3
		bne		NIEA3
		move.w	#1,WYKA3
NIEA3:	move.l	#EKRAN2+152,a0
		clr.w	d0
		move.w	WYKA3,d0
MNA3:	move.b	#%11111110,(a0)
		move.b	#%11111110,160(a0)
		sub.w	#480,a0
		dbf		d0,MNA3
		move.b	#%00000000,(a0)
		move.b	#%00000000,160(a0)
		sub.w	#1,WYKA4
		cmp.w	#0,WYKA4
		bne		NIEA4
		move.w	#1,WYKA4
NIEA4:	move.l	#EKRAN2+153,a0
		clr.w	d0
		move.w	WYKA4,d0
MNA4:	move.b	#%11111110,(a0)
		move.b	#%11111110,160(a0)
		sub.w	#480,a0
		dbf		d0,MNA4
		move.b	#%00000000,(a0)
		move.b	#%00000000,160(a0)
		movem.l	(sp)+,d0/a0
		rts

*-------------------------------------------------------------------------*

STRONICE:	rte

SPRAWA	move.b	$fffc02,KEY		* obsluga wyboru
		add.w	#1,KIEDY
		cmp.w	#8,KIEDY
		bne		JJ00
		clr.w	KIEDY
		cmp.b	#57,KEY
		bne.s	JJJJ
		move.w	#1,KONIEC
JJJJ:	cmp.b	#72,KEY
		bne.s	JJ01
		cmp.w	#0,S0
		beq.s	JJ01
		sub.w	#1,S0
JJ01:	cmp.b	#80,KEY
		bne.s	JJ02
		cmp.w	#5,S0
		beq.s	JJ02
		add.w	#1,S0

JJ02:	cmp.w	#0,S0			* nr. sampla/nazwa modulu
		bne.s	JJ03		
		cmp.b	#77,KEY
		bne.s	KK01
		cmp.w	#30,SS1
		beq.w	KK01
		addq	#1,SS1
		move.w	#1,SIUP
KK01:	cmp.b	#75,KEY
		bne.s	JJ03
		cmp.w	#0,SS1
		beq.s	JJ03
		subq	#1,SS1
		move.w	#1,SIUP

JJ03:	cmp.w	#1,S0			*	glosnosc LR
		bne.s	JJ04	
		cmp.b	#77,KEY
		bne.s	KK02
		cmp.w	#40,SS2
		beq.w	KK02
		addq	#1,SS2
		move.w	#1,SIUP
KK02:	cmp.b	#75,KEY
		bne.s	JJ04
		cmp.w	#0,SS2
		beq.s	JJ04
		subq	#1,SS2
		move.w	#1,SIUP

JJ04:	cmp.w	#2,S0			* glosnosc L
		bne.s	JJ05
		cmp.b	#77,KEY
		bne.s	KK03
		cmp.w	#20,SS3
		beq.w	KK03
		addq	#1,SS3
		move.w	#1,SIUP
KK03:	cmp.b	#75,KEY
		bne.s	JJ05
		cmp.w	#0,SS3
		beq.s	JJ05
		subq	#1,SS3
		move.w	#1,SIUP

JJ05:	cmp.w	#3,S0			* glosnosc R
		bne.s	JJ06
		cmp.b	#77,KEY
		bne.s	KK04
		cmp.w	#20,SS4
		beq.w	KK04
		addq	#1,SS4
		move.w	#1,SIUP
KK04:	cmp.b	#75,KEY
		bne.s	JJ06
		cmp.w	#0,SS4
		beq.s	JJ06
		subq	#1,SS4
		move.w	#1,SIUP

JJ06:	cmp.w	#4,S0			* BASSy
		bne.s	JJ07
		cmp.b	#77,KEY
		bne.s	KK05
		cmp.w	#12,SS5
		beq.w	KK05
		addq	#1,SS5
		move.w	#1,SIUP
KK05:	cmp.b	#75,KEY
		bne.s	JJ07
		cmp.w	#0,SS5
		beq.s	JJ07
		subq	#1,SS5
		move.w	#1,SIUP

JJ07:	cmp.w	#5,S0			* TREBLE
		bne.s	JJ08
		cmp.b	#77,KEY
		bne.s	KK06
		cmp.w	#12,SS6
		beq.w	KK06
		addq	#1,SS6
		move.w	#1,SIUP
KK06:	cmp.b	#75,KEY
		bne.s	JJ08
		cmp.w	#0,SS6
		beq.s	JJ07
		subq	#1,SS6
		move.w	#1,SIUP
JJ08:

JJ00:		rts

*-------------------------------------------------------------------------*

KIEDY:	dc.w	1
		even
KEY:	dc.b	1
		even

*-------------------------------------------------------------------------*


TIMER000:rte

TIMER00:move.l	#TIMER01,$120
		move.w	S1,$fff8240
		move.w	#$100,$fff8244	
		move.w	#$fff,$fff8246
		move.w	#$101,$fff8248
		move.w	#$011,$fff8250
		move.w	#$200,$fff8252
		rte
TIMER01:move.l	#TIMER02,$120
		move.w	#$111,$fff8246
		move.w	#$011,$fff824a
		rte
TIMER02:move.l	#TIMER03,$120
		move.w	#$999,$fff8246
		move.w	#$099,$fff824a
		rte
TIMER03:move.l	#TIMER04,$120
		move.w	#$222,$fff8246
		move.w	#$022,$fff824a
		rte
TIMER04:move.l	#TIMER05,$120
		move.w	#$aaa,$fff8246
		move.w	#$0aa,$fff824a
		rte
TIMER05:move.l	#TIMER06,$120
		move.w	#$333,$fff8246
		move.w	#$033,$fff824a
		rte
TIMER06:move.l	#TIMER07,$120
		move.w	#$bbb,$fff8246
		move.w	#$0bb,$fff824a
		rte
TIMER07:move.l	#TIMER08,$120
		move.w	#$444,$fff8246
		move.w	#$044,$fff824a
		rte
TIMER08:move.l	#TIMER09,$120
		move.w	#$ccc,$fff8246
		move.w	#$0cc,$fff824a
		rte
TIMER09:move.l	#TIMER10,$120
		move.w	#$555,$fff8246
		move.w	#$055,$fff824a
		rte 
TIMER10:move.l	#TIMER11,$120
		move.w	#$ddd,$fff8246
		move.w	#$0dd,$fff824a
		rte
TIMER11:move.l	#TIMER12,$120
		move.w	#$666,$fff8246
		move.w	#$066,$fff824a
		rte
TIMER12:move.l	#TIMER13,$120
		move.w	#$eee,$fff8246
		move.w	#$0ee,$fff824a
		rte
TIMER13:move.l	#TIMER14,$120
		move.w	#$777,$fff8246
		move.w	#$077,$fff824a
		rte
TIMER14:move.l	#TIMER15,$120
		move.w	#$fff,$fff8246
		move.w	#$0ff,$fff824a
		rte
TIMER15:move.l	#TIMER16,$120
		rte
TIMER16:move.l	#TIMER17,$120
		rte
TIMER17:move.l	#TIMER18,$120
		move.w	#0,$fff8240
		move.w	#$900,$fff8244
		move.w	#$909,$fff8248
		move.w	#$099,$fff8250
		rte
TIMER18:move.l	#TIMER19,$120
		move.w	S2,$fff8240
		move.w	#$111,$fff8246
		move.w	#$011,$fff824a
		rte
TIMER19:move.l	#TIMER20,$120
		move.w	#$999,$fff8246
		move.w	#$099,$fff824a
		rte
TIMER20:move.l	#TIMER21,$120
		move.w	#$222,$fff8246
		move.w	#$022,$fff824a
		rte
TIMER21:move.l	#TIMER22,$120
		move.w	#$aaa,$fff8246
		move.w	#$0aa,$fff824a
		rte
TIMER22:move.l	#TIMER23,$120
		move.w	#$333,$fff8246
		move.w	#$033,$fff824a
		rte
TIMER23:move.l	#TIMER24,$120
		move.w	#$bbb,$fff8246
		move.w	#$0bb,$fff824a
		rte
TIMER24:move.l	#TIMER25,$120
		move.w	#$444,$fff8246
		move.w	#$044,$fff824a
		rte
TIMER25:move.l	#TIMER26,$120
		move.w	#$ccc,$fff8246
		move.w	#$0cc,$fff824a
		rte
TIMER26:move.l	#TIMER27,$120
		move.w	#$555,$fff8246
		move.w	#$055,$fff824a
		move.w	#$0a0,$fff8252
		rte
TIMER27:move.l	#TIMER28,$120
		move.w	#$ddd,$fff8246
		move.w	#$0dd,$fff824a
		rte
TIMER28:move.l	#TIMER29,$120
		move.w	#$666,$fff8246
		move.w	#$066,$fff824a
		move.w	#$030,$fff8252
		rte
TIMER29:move.l	#TIMER30,$120
		move.w	#$eee,$fff8246
		move.w	#$0ee,$fff824a
		rte
TIMER30:move.l	#TIMER31,$120
		move.w	#$777,$fff8246
		move.w	#$077,$fff824a
		move.w	#$0b0,$fff8252
		rte
TIMER31:move.l	#TIMER32,$120
		move.w	#$fff,$fff8246
		move.w	#$0ff,$fff824a
		rte
TIMER32:move.l	#TIMER33,$120
		move.w	#$040,$fff8252
		rte
TIMER33:move.l	#TIMER34,$120
		rte
TIMER34:move.l	#TIMER35,$120
		move.w	#$0c0,$fff8252
		rte
TIMER35:move.l	#TIMER36,$120
		move.w	#0,$fff8240
		move.w	#$200,$fff8244
		move.w	#$202,$fff8248
		move.w	#$022,$fff8250
		rte
TIMER36:move.l	#TIMER37,$120
		move.w	S3,$fff8240
		move.w	#$111,$fff8246
		move.w	#$011,$fff824a
		move.w	#$050,$fff8252
		rte
TIMER37:move.l	#TIMER38,$120
		move.w	#$999,$fff8246
		move.w	#$099,$fff824a
		rte
TIMER38:move.l	#TIMER39,$120
		move.w	#$222,$fff8246
		move.w	#$022,$fff824a
		move.w	#$0d0,$fff8252
		rte
TIMER39:move.l	#TIMER40,$120
		move.w	#$aaa,$fff8246
		move.w	#$0aa,$fff824a
		rte
TIMER40:move.l	#TIMER41,$120
		move.w	#$333,$fff8246
		move.w	#$033,$fff824a
		move.w	#$060,$fff8252
		rte
TIMER41:move.l	#TIMER42,$120
		move.w	#$bbb,$fff8246
		move.w	#$0bb,$fff824a
		rte
TIMER42:move.l	#TIMER43,$120
		move.w	#$444,$fff8246
		move.w	#$044,$fff824a
		move.w	#$0e0,$fff8252
		rte
TIMER43:move.l	#TIMER44,$120
		move.w	#$ccc,$fff8246
		move.w	#$0cc,$fff824a
		rte
TIMER44:move.l	#TIMER45,$120
		move.w	#$555,$fff8246
		move.w	#$055,$fff824a
		move.w	#$070,$fff8252
		rte
TIMER45:move.l	#TIMER46,$120
		move.w	#$ddd,$fff8246
		move.w	#$0dd,$fff824a
		rte
TIMER46:move.l	#TIMER47,$120
		move.w	#$666,$fff8246
		move.w	#$066,$fff824a
		move.w	#$0f0,$fff8252
		rte
TIMER47:move.l	#TIMER48,$120
		move.w	#$eee,$fff8246
		move.w	#$0ee,$fff824a
		rte
TIMER48:move.l	#TIMER49,$120
		move.w	#$777,$fff8246
		move.w	#$077,$fff824a
		move.w	#$8f0,$fff8252
		rte
TIMER49:move.l	#TIMER50,$120
		move.w	#$fff,$fff8246
		move.w	#$0ff,$fff824a
		rte
TIMER50:move.l	#TIMER51,$120
		move.w	#$1f0,$fff8252
		rte
TIMER51:move.l	#TIMER52,$120
		move.w	#$000,$fff8246
		move.w	#$111,$fff824a
		rte
TIMER52:move.l	#TIMER53,$120
		move.w	#$9f0,$fff8252
		rte
TIMER53:move.l	#TIMER54,$120
		move.w	#0,$fff8240
		move.w	#$a00,$fff8244
		move.w	#$a0a,$fff8248
		move.w	#$0aa,$fff8250
		rte
TIMER54:move.l	#TIMER55,$120
		move.w	S4,$fff8240
		move.w	#$2f0,$fff8252
		rte
TIMER55:move.l	#TIMER56,$120
		move.w	#$111,$fff8246
		move.w	#$011,$fff824a
		rte
TIMER56:move.l	#TIMER57,$120
		move.w	#$999,$fff8246
		move.w	#$099,$fff824a
		move.w	#$af0,$fff8252
		rte
TIMER57:move.l	#TIMER58,$120
		move.w	#$222,$fff8246
		move.w	#$022,$fff824a
		rte
TIMER58:move.l	#TIMER59,$120
		move.w	#$aaa,$fff8246
		move.w	#$0aa,$fff824a
		move.w	#$3f0,$fff8252
		rte
TIMER59:move.l	#TIMER60,$120
		move.w	#$333,$fff8246
		move.w	#$033,$fff824a
		rte
TIMER60:move.l	#TIMER61,$120
		move.w	#$bbb,$fff8246
		move.w	#$0bb,$fff824a
		move.w	#$bf0,$fff8252
		rte
TIMER61:move.l	#TIMER62,$120
		move.w	#$444,$fff8246
		move.w	#$044,$fff824a
		rte
TIMER62:move.l	#TIMER63,$120
		move.w	#$ccc,$fff8246
		move.w	#$0cc,$fff824a
		move.w	#$4f0,$fff8252
		rte
TIMER63:move.l	#TIMER64,$120
		move.w	#$555,$fff8246
		move.w	#$055,$fff824a
		rte
TIMER64:move.l	#TIMER65,$120
		move.w	#$ddd,$fff8246
		move.w	#$0dd,$fff824a
		move.w	#$cf0,$fff8252
		rte
TIMER65:move.l	#TIMER66,$120
		move.w	#$666,$fff8246
		move.w	#$066,$fff824a
		rte
TIMER66:move.l	#TIMER67,$120
		move.w	#$eee,$fff8246
		move.w	#$0ee,$fff824a
		move.w	#$5f0,$fff8252
		rte
TIMER67:move.l	#TIMER68,$120
		move.w	#$777,$fff8246
		move.w	#$077,$fff824a
		rte
TIMER68:move.l	#TIMER69,$120
		move.w	#$fff,$fff8246
		move.w	#$0ff,$fff824a
		move.w	#$df0,$fff8252
		rte
TIMER69:move.l	#TIMER70,$120
		rte
TIMER70:move.l	#TIMER71,$120
		move.w	#$6f0,$fff8252
		rte
TIMER71:move.l	#TIMER72,$120
		move.w	#0,$fff8240
		move.w	#$300,$fff8244
		move.w	#$303,$fff8248
		move.w	#$033,$fff8250
		rte
TIMER72:move.l	#TIMER73,$120
		move.w	S5,$fff8240
		move.w	#$ef0,$fff8252
		rte
TIMER73:move.l	#TIMER74,$120
		move.w	#$111,$fff8246
		move.w	#$011,$fff824a
		rte
TIMER74:move.l	#TIMER75,$120
		move.w	#$999,$fff8246
		move.w	#$099,$fff824a
		move.w	#$7f0,$fff8252
		rte
TIMER75:move.l	#TIMER76,$120
		move.w	#$222,$fff8246
		move.w	#$022,$fff824a
		rte
TIMER76:move.l	#TIMER77,$120
		move.w	#$aaa,$fff8246
		move.w	#$0aa,$fff824a
		move.w	#$ff0,$fff8252
		rte
TIMER77:move.l	#TIMER78,$120
		move.w	#$333,$fff8246
		move.w	#$033,$fff824a
		rte
TIMER78:move.l	#TIMER79,$120
		move.w	#$bbb,$fff8246
		move.w	#$0bb,$fff824a
		move.w	#$ff8,$fff8252
		rte
TIMER79:move.l	#TIMER80,$120
		move.w	#$444,$fff8246
		move.w	#$044,$fff824a
		rte
TIMER80:move.l	#TIMER81,$120
		move.w	#$ccc,$fff8246
		move.w	#$0cc,$fff824a
		move.w	#$ff1,$fff8252
		rte
TIMER81:move.l	#TIMER82,$120
		move.w	#$555,$fff8246
		move.w	#$055,$fff824a
		rte
TIMER82:move.l	#TIMER83,$120
		move.w	#$ddd,$fff8246
		move.w	#$0dd,$fff824a
		move.w	#$ff9,$fff8252
		rte
TIMER83:move.l	#TIMER84,$120
		move.w	#$666,$fff8246
		move.w	#$066,$fff824a
		rte
TIMER84:move.l	#TIMER85,$120
		move.w	#$eee,$fff8246
		move.w	#$0ee,$fff824a
		move.w	#$ff2,$fff8252
		rte
TIMER85:move.l	#TIMER86,$120
		move.w	#$777,$fff8246
		move.w	#$077,$fff824a
		rte
TIMER86:move.l	#TIMER87,$120
		move.w	#$fff,$fff8246
		move.w	#$0ff,$fff824a
		move.w	#$ffa,$fff8252
		rte
TIMER87:move.l	#TIMER88,$120
		rte
TIMER88:move.l	#TIMER89,$120
		move.w	#$ff3,$fff8252
		rte
TIMER89:move.l	#TIMER90,$120
		move.w	#0,$fff8240
		move.w	#$b00,$fff8244
		move.w	#$b0b,$fff8248
		move.w	#$0bb,$fff8250
		rte
TIMER90:move.l	#TIMER91,$120
		move.w	S6,$fff8240
		move.w	#$ffb,$fff8252
		rte
TIMER91:move.l	#TIMER92,$120
		move.w	#$111,$fff8246
		move.w	#$011,$fff824a
		rte
TIMER92:move.l	#TIMER93,$120
		move.w	#$999,$fff8246
		move.w	#$099,$fff824a
		move.w	#$ff4,$fff8252
		rte
TIMER93:move.l	#TIMER94,$120
		move.w	#$222,$fff8246
		move.w	#$022,$fff824a
		rte
TIMER94:move.l	#TIMER95,$120
		move.w	#$aaa,$fff8246
		move.w	#$0aa,$fff824a
		move.w	#$ffc,$fff8252
		rte
TIMER95:move.l	#TIMER96,$120
		move.w	#$333,$fff8246
		move.w	#$033,$fff824a
		rte
TIMER96:move.l	#TIMER97,$120
		move.w	#$bbb,$fff8246
		move.w	#$0bb,$fff824a
		move.w	#$ff5,$fff8252
		rte
TIMER97:move.l	#TIMER98,$120
		move.w	#$444,$fff8246
		move.w	#$044,$fff824a
		rte
TIMER98:move.l	#TIMER99,$120
		move.w	#$ccc,$fff8246
		move.w	#$0cc,$fff824a
		move.w	#$ffd,$fff8252
		rte
TIMER99:move.l	#TIMER100,$120
		move.w	#$555,$fff8246
		move.w	#$055,$fff824a
		rte
TIMER100:move.l	#TIMER101,$120
		move.w	#$ddd,$fff8246
		move.w	#$0dd,$fff824a
		move.w	#$ff6,$fff8252
		rte
TIMER101:move.l	#TIMER102,$120
		move.w	#$666,$fff8246
		move.w	#$066,$fff824a
		rte
TIMER102:move.l	#TIMER103,$120
		move.w	#$eee,$fff8246
		move.w	#$0ee,$fff824a
		move.w	#$ffe,$fff8252
		rte
TIMER103:move.l	#TIMER104,$120
		move.w	#$777,$fff8246
		move.w	#$077,$fff824a
		rte
TIMER104:move.l	#TIMER105,$120
		move.w	#$fff,$fff8246
		move.w	#$0ff,$fff824a
		move.w	#$ff7,$fff8252
		rte
TIMER105:move.l	#TIMER106,$120
		rte
TIMER106:move.l	#TIMER107,$120
		move.w	#$fff,$fff8252
		rte
TIMER107:move.l	#TIMER108,$120
		move.w	#0,$fff8240
		move.w	#0,$fff8244
		move.w	#0,$fff8246
		move.w	#0,$fff8248
		move.w	#0,$fff824a
		move.w	#0,$fff8250
		move.w	#0,$fff8252
		rte
TIMER108:move.l	#TIMER109,$120
		rte
TIMER109:move.l	#TIMER110,$120
		rte
TIMER110:move.l	#TIMER111,$120
		rte
TIMER111:move.l	#TIMER112,$120
		rte
TIMER112:move.l	#TIMER113,$120
		rte
TIMER113:move.l	#TIMER114,$120
		rte
TIMER114:move.l	#TIMER115,$120
		rte
TIMER115:move.l	#TIMER_B,$120
		bclr.b 	#0,$fffa0f
		move.b 	#0,$fffa1b
		move.b 	#228-116,$fffa21
		move.b 	#8,$fffa1b
		rte
TIMER_B:move.w	d6,-(sp)		
		rept	24		
		nop			nop 
		endr			
		clr.w	d6		
		move.b	$ffff8209,d6
		neg.b	d6
		add.b	#192,d6
		lsl.b	d6,d6	
		move.w	#18,d6		
PAUSE:	dbra	d6,PAUSE		
  		move.b	#0,$ffff820a	
		rept	12		
		nop			nop 
		endr			
		move.b	#2,$ffff820a	
		move.w	(sp)+,d6		
		rte

TIMER_A	move.w	#$2100,sr		* procedura przerwania TIMERa A
		stop	#$2100		
		clr.b	$fffffa19	
		rept	78		
		nop			nop 
		endr			
		clr.b	$ffff820a
		nop			nop
		nop			nop 
		move.b	#2,$ffff820a	
		rte			

*-------------------------------------------------------------------------*

KONIEC:		dc.w	1
			even
SAFEREG: 	ds.l 	10
			even
WYKA1:		dc.w	1
WYKA2:		dc.w	1
WYKA3:		dc.w	1
WYKA4:		dc.w	1
TERAZ:		dc.w	1
WYK1:		dc.w	1
WYK2:		dc.w	1
WYK3:		dc.w	1
WYK4:		dc.w	1
WYK5:		dc.w	1
WYK6:		dc.w	1
WYK7:		dc.w	1
WYK8:		dc.w	1
WYK9:		dc.w	1
WYK10:		dc.w	1
WYK11:		dc.w	1
WYK12:		dc.w	1
WYK13:		dc.w	1
WYK14:		dc.w	1
WYK15:		dc.w	1
WYK16:		dc.w	1
WYK17:		dc.w	1
WYK18:		dc.w	1
WYK19:		dc.w	1
WYK20:		dc.w	1
WYK21:		dc.w	1
WYK22:		dc.w	1
WYK23:		dc.w	1
WYK24:		dc.w	1
WYK25:		dc.w	1
WYK26:		dc.w	1
WYK27:		dc.w	1
WYK28:		dc.w	1
WYK29:		dc.w	1
WYK30:		dc.w	1
WYK31:		dc.w	1

;-----------------------------------------------------------------------;

Wait_Vbl:	MOVE #37,-(SP)
			TRAP 	#14
			ADDQ.L 	#2,SP
			RTS

*-------------------------------------------------------------------------*

old_stuff:	DS.L 20
oldres		DS.W 1
oldsp		DS.L 1
oldusp		DS.L 1

set_screen	MOVE.W 	#2,-(SP)
			TRAP 	#14			; get phybase
			ADDQ.L 	#2,SP
			MOVE.L 	D0,log_base		; store it.
			MOVE.L 	D0,A0			; fall thru and clear screen
		
clsfast		move.l	#EKRAN1,a0
			MOVE 	#300*160-1,D1
cls			clr.l	(A0)+
			DBF 	D1,cls
			RTS	

log_base	DC.L 0				; screen ptr

Load_file	SF 		errorflag			; assume no error!
			MOVE 	#2,-(SP)
			MOVE.L 	A4,-(SP)
			MOVE 	#$3D,-(SP)
			TRAP 	#1				; open da file
			ADDQ.L 	#8,SP
			TST.L 	D0
			BMI.S 	.error
			MOVE 	D0,D4
.read		MOVE.L 	A5,-(SP)
			MOVE.L 	D7,-(SP)
			MOVE 	D4,-(SP)
			MOVE 	#$3F,-(SP)
			TRAP 	#1				; read da file
			LEA 	12(SP),SP
			TST.L 	D0
			BMI.S 	.error
.close		MOVE 	D4,-(SP)
			MOVE 	#$3E,-(SP)
			TRAP 	#1				; close da file!
			ADDQ.L 	#4,SP
			RTS
.error		ST 		errorflag			; shit a load error!
			RTS
errorflag	DC.W 	0

fileselect	LEA 	control(PC),A0
			MOVE.W 	#90,(A0)+
			MOVE.W 	#0,(A0)+
			MOVE.W 	#2,(A0)+
			MOVE.W 	#2,(A0)+
			MOVE.L 	#path,addr_in
			MOVE.L 	#filename,addr_in+4
			BSR 	AES	
			RTS

dummy:		DC.B 	'*.*',0
path		DC.B 	"\*.MOD",0
			DS.B 	100
			EVEN
loading		DC.B 	"Loading : "
filename	DS.B 	64
path_n_name	DS.W 	64

; VDI subroutine call.

VDI			LEA 	VDIparblock(PC),A0
			MOVE.L 	#contrl,(A0)
			MOVE.L 	A0,D1
			MOVEQ 	#115,D0
			TRAP 	#2
			RTS

; AES subroutine call.

AES			LEA 	AESparblock(PC),A0
			MOVE.L 	#control,(A0)
			MOVE.L 	A0,D1
			MOVE.L 	#200,D0
			TRAP 	#2
			RTS

; 1st BDOS call is APPL_INI

appl_ini	LEA 	control(PC),A0
			MOVE 	#10,(A0)+
			MOVE 	#0,(A0)+
			MOVE 	#1,(A0)+
			MOVE 	#0,(A0)+
			BRA 	AES	

; Last BDOS call is APPL_EXI

appl_exi	LEA 	control(PC),A0
			MOVE 	#19,(A0)+
			MOVE 	#0,(A0)+
			MOVE 	#1,(A0)+
			MOVE 	#0,(A0)+
			BRA 	AES	

; VDI & AES Reserved arrays

VDIparblock	DC.L contrl
		DC.L intin
		DC.L ptsin
		DC.L intout
		DC.L ptsout
		
contrl		DS.W 12
intin		DS.W 30
ptsin		DS.W 30
intout		DS.W 45
ptsout		DS.W 12

AESparblock	DC.L control
		DC.L global
		DC.L int_in
		DC.L int_out
		DC.L addr_in
		DC.L addr_out 
control		DS.W 5
global		DS.W 16
int_in		DS.W 16
int_out		DS.W 7
addr_in		DS.L 2
addr_out	DS.L 1

; The Gem Fileselector returns a path and filename as seperate strings
; - this rout concatenates the two strings together into one (for loading).

Concate_path	LEA path(PC),A1
		MOVE.L A1,A0
.find_end	TST.B (A0)+		; search for end of path
		BNE.S .find_end
.foundit	CMP.B #'\',-(A0)	; now look back for slash
		BEQ.S .foundslash	
		CMP.L A1,A0		; (or if we reach start of path)
		BNE.S .foundit
.foundslash	SUB.L A1,A0		; number of bytes
		MOVE.W A0,D0
		LEA path_n_name(PC),A0
		TST.W D0
		BEQ.S .nonetodo		; if zero then not in subdir
.copypath	MOVE.B (A1)+,(A0)+	; copy path
		DBF D0,.copypath	
.nonetodo	LEA filename(PC),A1
.copy_filename	MOVE.B (A1),(A0)+	; concatenate file name
		TST.B (A1)+
		BNE.S .copy_filename
		RTS

; Ice 2.31 Decrunch Rout. A0 -> packed data.

ice_decrunch:	link a3,#-120
		movem.l	d0-a6,-(sp)
		lea 120(a0),a4		; a4 = Anfang entpackte Daten
		move.l a4,a6		; a6 = Ende entpackte Daten
		bsr.s .getinfo
		cmpi.l #'ICE!',d0	; Kennung gefunden?
		bne .not_packed
		bsr.s .getinfo		; gepackte LÑnge holen
		lea.l -8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
		bsr.s .getinfo		; ungepackte LÑnge holen (original)
		move.l d0,(sp)		; OriginallÑnge: spÑter nach d0
		adda.l d0,a6		; a6 = Ende entpackte Daten
		move.l a6,a1

		moveq #119,d0		; 120 Bytes hinter entpackten Daten
.save:		move.b -(a1),-(a3)	; in sicheren Bereich sichern
		dbf d0,.save
		move.l a6,a3		; merken fÅr Picture decrunch
		move.b -(a5),d7		; erstes Informationsbyte
		bsr.s .normal_bytes
		move.l a3,a5		; fÅr 120 Bytes restore

.no_picture	movem.l	(sp),d0-a3	; hole nîtige Register

.move		move.b (a4)+,(a0)+
		subq.l #1,d0
		bne.s .move
		moveq #119,d0		; um Åberschriebenen Bereich
.rest		move.b -(a3),-(a5)	; wieder herzustellen
		dbf d0,.rest
.not_packed:	movem.l	(sp)+,d0-a6
		unlk a3
		rts

.getinfo: 	moveq #3,d1		; ein Langwort vom Anfang
.getbytes: 	lsl.l #8,d0		; der Daten lesen
		move.b (a0)+,d0
		dbf d1,.getbytes
		rts

.normal_bytes:	bsr.s .get_1_bit
		bcc.s .test_if_end	; Bit %0: keine Daten
		moveq.l	#0,d1		; falls zu copy_direkt
		bsr.s .get_1_bit
		bcc.s .copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
		lea.l .direkt_tab+20(pc),a1
		moveq.l	#4,d3
.nextgb:	move.l -(a1),d0		; d0.w Bytes lesen
		bsr.s .get_d0_bits
		swap.w d0
		cmp.w d0,d1		; alle gelesenen Bits gesetzt?
		dbne d3,.nextgb		; ja: dann weiter Bits lesen
.no_more: 	add.l 20(a1),d1 	; Anzahl der zu Åbertragenen Bytes
.copy_direkt:	move.b -(a5),-(a6)	; Daten direkt kopieren
		dbf d1,.copy_direkt	; noch ein Byte
.test_if_end:	cmpa.l	a4,a6		; Fertig?
		bgt.s .strings		; Weiter wenn Ende nicht erreicht
		rts	

.get_1_bit:	add.b d7,d7		; hole ein bit
		bne.s .bitfound 	; quellfeld leer
*		move.w	#$000,$fff8240			*************************
		move.b -(a5),d7		; hole Informationsbyte
		addx.b d7,d7
.bitfound:	rts	

.get_d0_bits:	moveq.l	#0,d1		; ergebnisfeld vorbereiten
.hole_bit_loop:	add.b d7,d7		; hole ein bit
		bne.s .on_d0		; in d7 steht noch Information
		move.b -(a5),d7		; hole Informationsbyte
		addx.b d7,d7
.on_d0:		addx.w d1,d1		; und Åbernimm es
		dbf d0,.hole_bit_loop  	; bis alle Bits geholt wurden
		rts	

.strings: 	lea.l .length_tab(pc),a1 ; a1 = Zeiger auf Tabelle
		moveq.l	#3,d2		 ; d2 = Zeiger in Tabelle
.get_length_bit:bsr.s .get_1_bit
		dbcc d2,.get_length_bit	; nÑchstes Bit holen
.no_length_bit:	moveq.l	#0,d4		; d4 = öberschuû-LÑnge
		moveq.l	#0,d1
		move.b 1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
		ext.w d0		; als Wort behandeln
		bmi.s .no_Åber		; kein öberschuû nîtig
.get_Åber:	bsr.s .get_d0_bits
.no_Åber:	move.b 6(a1,d2.w),d4	; Standard-LÑnge zu öberschuû add.
		add.w d1,d4		; d4 = String-LÑnge-2
		beq.s .get_offset_2	; LÑnge = 2: Spezielle Offset-Routine

		lea.l .more_offset(pc),a1 ; a1 = Zeiger auf Tabelle
		moveq.l	#1,d2
.getoffs: 	bsr.s .get_1_bit
		dbcc d2,.getoffs
		moveq.l	#0,d1		; Offset-öberschuû
		move.b 1(a1,d2.w),d0	; request d0 Bits
		ext.w d0		; als Wort
		bsr.s .get_d0_bits
		add.w d2,d2		; ab jetzt: Pointer auf Worte
		add.w 6(a1,d2.w),d1	; Standard-Offset zu öberschuû add.
		bpl.s .depack_bytes	; keine gleiche Bytes: String kop.
		sub.w d4,d1		; gleiche Bytes
		bra.s .depack_bytes


.get_offset_2:	moveq.l	#0,d1		; öberschuû-Offset auf 0 setzen
		moveq.l	#5,d0		; standard: 6 Bits holen
		moveq.l	#-1,d2		; Standard-Offset auf -1
		bsr.s .get_1_bit
		bcc.s .less_40		; Bit = %0
		moveq.l	#8,d0		; quenty fourty: 9 Bits holen
		moveq.l	#$3f,d2		; Standard-Offset: $3f
.less_40: 	bsr.s .get_d0_bits
		add.w d2,d1		; Standard-Offset + öber-Offset

.depack_bytes:				; d1 = Offset, d4 = Anzahl Bytes
		move.w	#$fff,$fff8240			*************************
   		move.w	#$000,$fff8240			*************************
		lea.l 2(a6,d4.w),a1	; Hier stehen die Originaldaten
		adda.w	d1,a1		; Dazu der Offset
		move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
.dep_b:		move.b	-(a1),-(a6)	; mehr Bytes kopieren
		dbf d4,.dep_b 		; und noch ein Mal
		bra .normal_bytes	; Jetzt kommen wieder normale Bytes


.direkt_tab:	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
		dc.l 270-1,15-1,8-1,5-1,2-1	; Anz. Bytes

.length_tab:	dc.b 9,1,0,-1,-1	; Bits lesen
		dc.b 8,4,2,1,0		; Standard-LÑnge - 2 (!!!)
.more_offset:	dc.b 11,4,7,0		; Bits lesen
		dc.w $11f,-1,$1f	; Standard Offset

print:		movem.l	d0-d4/a0/a2-a3,-(sp)
		moveq	#0,d2
printline:
		move.b	(a0)+,d0
		bne.s	notend
		move.l	a0,lastptr
		movem.l	(sp)+,d0-d4/a0/a2-a3
		rts
notend:		cmpi.b	#1,d0
		bne.s	notinv
		moveq	#1,d2
		move.b	(a0)+,d0
notinv:		cmpi.b	#2,d0
		bne.s	notnorm
		moveq	#0,d2
		move.b	(a0)+,d0
notnorm:	cmpi.b	#$a,d0
		bne.s	notcr
		addq.b	#8,typos
		bra.s	printline
notcr:		cmpi.b	#$d,d0
		bne.s	notlf
		move.b	#0,txpos
		bra.s	printline
notlf:		tst.b	d2
		bne.s	inverse
		moveq   #0,D3
	        moveq   #0,D4
        	move.b  txpos(PC),D3
	        move.b  typos(PC),D4
		mulu #160,d4
	        movea.l log_base(pc),A2		; Screen
        	adda.l d4,A2
	        lea     xtab(PC),a3
        	move.b  0(a3,D3.w),D3
	        adda.w  D3,A2
        	lea     font(PC),a3
	        moveq   #0,D3
	        move.b  D0,D3
        	sub.b   #32,D3
	        lsl.w   #3,D3
        	adda.w  D3,a3
        	move.b  (a3)+,(A2)
	        move.b  (a3)+,160(A2)
        	move.b  (a3)+,320(A2)
	        move.b  (a3)+,480(A2)
        	move.b  (a3)+,640(A2)
	        move.b  (a3)+,800(A2)
        	move.b  (a3)+,960(A2)
	        move.b  (a3),1120(A2)
		addq.b	#1,txpos
		bra	printline

inverse:	moveq   #0,D3
	        moveq   #0,D4
        	move.b  txpos(PC),D3
	        move.b  typos(PC),D4
		mulu #160,d4
	        movea.l log_base(pc),A2		; Screeen
	        adda.l d4,A2
        	lea     xtab(PC),a3
	        move.b  0(a3,D3.w),D3
        	adda.w  D3,A2
        	lea     font(PC),a3
	        moveq   #0,D3
        	move.b  D0,D3
	        sub.b   #32,D3
        	lsl.w   #3,D3
	        adda.w  D3,a3
        	move.b  (a3)+,(A2)
		not.b	(a2)
        	move.b  (a3)+,160(A2)
		not.b	160(a2)
	        move.b  (a3)+,320(A2)
		not.b	320(a2)
        	move.b  (a3)+,480(A2)
		not.b	480(a2)
        	move.b  (a3)+,640(A2)
		not.b	640(a2)
	        move.b  (a3)+,800(A2)
		not.b	800(a2)
	        move.b  (a3)+,960(A2)
		not.b	960(a2)
	        move.b  (a3),1120(A2)
		not.b	1120(a2)
		addq.b	#1,txpos
		bra	printline

xoff		set	0
xtab:   	rept	40
		dc.b	xoff,xoff+1
xoff		set	xoff+4
		endr

txpos:		ds.b 1
typos:		ds.b 1

lastptr:	ds.l 1

selecttext
 dc.b "                        ProTracker V1.1b Replay (ST/STE)"
 rept 23
 dc.b $a,$d
 endr
 dc.b "                             ",1,"Please Select a Module",2," "
 dc.b 0

decrunching
 dc.b "Decrunching",0

thetext	
 dc.b $a,$d
 dc.b 0
	even

;-----------------------------------------------------------------------;

my_stack	DS.L 4
			even
LICZ:		incbin	"\asembler.s\dane.dat\LICZNIK.DAT"
			even
FONT:		incbin	"\asembler.s\dane.dat\FONT.DAT"
			even

;-----------------------------------------------------------------------;

n_note	equ	0  ; w
n_cmd	equ	2  ; w
n_cmdlo	equ	3  ; b
n_start	equ	4  ; l
n_length	equ	8  ; w
n_loopstart	equ	10 ; l
n_replen	equ	14 ; w
n_period	equ	16 ; w
n_finetune	equ	18 ; b
n_volume	equ	19 ; b
n_dmabit	equ	20 ; w
n_toneportdirec	equ	22 ; b
n_toneportspeed	equ	23 ; b
n_wantedperiod	equ	24 ; w
n_vibratocmd	equ	26 ; b
n_vibratopos	equ	27 ; b
n_tremolocmd	equ	28 ; b
n_tremolopos	equ	29 ; b
n_wavecontrol	equ	30 ; b
n_glissfunk	equ	31 ; b
n_sampleoffset	equ	32 ; b
n_pattpos	equ	33 ; b
n_loopcount	equ	34 ; b
n_funkoffset	equ	35 ; b
n_wavestart	equ	36 ; l
n_reallength	equ	40 ; w

	section	text

mt_init	lea	mt_data,a0
	move.l	a0,mt_songdataptr
	move.l	a0,a1
	lea	952(a1),a1
	moveq	#127,d0
	moveq	#0,d1
mtloop	move.l	d1,d2
	subq.w	#1,d0
mtloop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mtloop
	dbra	d0,mtloop2
	addq.b	#1,d2
			
	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#1084,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#30,d0
	moveq	#0,d2
	lea	42(a0),a0
mtloop3	clr.l	(a2)
	move.l	a2,d1
	add.l	d2,d1
	move.l	d1,(a1)+
	moveq	#0,d1
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.w	#640,d2
	tst.w	4(a0)
	bne.s	.mt_no_test
	cmp.w	#1,6(a0)
	ble.s	.mt_no_test
	subq.w	#1,6(a0)
	move.w	#1,4(a0)
.mt_no_test	add.l	#30,a0
	dbra	d0,mtloop3
	add.w	d2,a2
	lea	mt_module_end,a1
	move.l	a2,(a1)
	move.b	#6,mt_speed
	move.b	#6,mt_counter
	clr.b	mt_songpos
	clr.w	mt_patternpos

	lea	-31*640(a2),a1

	moveq	#30,d7
mt_init_loops	sub.w	#30,a0
	lea	-640(a2),a2
	lea	(a2),a3
	move.w	(a0),d0
	beq.s	.mt_just_loop
	subq.w	#1,d0
.mt_copy_spl	move.w	-(a1),-(a2)
	dbra	d0,.mt_copy_spl

.mt_just_loop	moveq	#0,d0
	move.w	4(a0),d0
	sne	d1
	andi.w	#$4,d1
	move.l	mt_loop_point(pc,d1.w),a4
	jsr	(a4)
	dbra	d7,mt_init_loops

	bsr	mt_init_Paula
	rts
mt_end	bsr	mt_stop_Paula
	rts
mt_loop_point	dc.l	.mt_no_loop
	dc.l	.mt_yes_loop
.mt_no_loop	move.w	#640/4-1,d0
.mt_clear_loop	clr.l	(a3)+
	dbra	d0,.mt_clear_loop
	rts
.mt_yes_loop	add.l	d0,d0
	lea	(a2,d0.l),a4
	lea	(a4),a5
	moveq	#0,d1
	move.w	4(a0),d1
	add.w	6(a0),d1
	move.w	d1,(a0)
	add.l	d1,d1
	lea	(a2,d1.l),a3
	move.w	6(a0),d1
	move.w	#320-1,d2
.mt_loop_loop	move.w	(a4)+,(a3)+
	subq.w	#1,d1
	bne.s	.mt_no_restart
	lea	(a5),a4
	move.w	6(a0),d1
.mt_no_restart	dbra	d2,.mt_loop_loop
	rts

mt_music	movem.l	d0-d4/a0-a6,-(sp)
	addq.b	#1,mt_counter
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blo.s	mt_nonewnote
	clr.b	mt_counter
	tst.b	mt_pattdeltime2
	beq.s	mt_getnewnote
	bsr.s	mt_nonewallchannels
	bra	mt_dskip

mt_nonewnote
	bsr.s	mt_nonewallchannels
	bra	mt_nonewposyet

mt_nonewallchannels
	lea	mt_channel_0,a5
	lea	mt_chan1temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_1,a5
	lea	mt_chan2temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_2,a5
	lea	mt_chan3temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_3,a5
	lea	mt_chan4temp(pc),a6
	bra	mt_checkefx

mt_getnewnote
	move.l	mt_songdataptr(pc),a0
	lea	12(a0),a3
	lea	952(a0),a2	;pattpo
	lea	1084(a0),a0	;patterndata
	moveq	#0,d0
	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_patternpos(pc),d1
	clr.w	mt_dmacontemp

	lea	mt_channel_0,a5
	lea	mt_chan1temp(pc),a6
	move.w	#1,TERAZ			***********
	bsr.s	mt_playvoice
	lea	mt_channel_1,a5
	lea	mt_chan2temp(pc),a6
	move.w	#2,TERAZ			***********
	bsr.s	mt_playvoice
	lea	mt_channel_2,a5
	lea	mt_chan3temp(pc),a6
	move.w	#3,TERAZ			***********
	bsr.s	mt_playvoice
	lea	mt_channel_3,a5
	lea	mt_chan4temp(pc),a6
	move.w	#4,TERAZ			***********
	bsr.s	mt_playvoice
	bra	mt_setdma
mt_playvoice	tst.l	(a6)
	bne.s	mt_plvskip
	bsr	mt_pernop
mt_plvskip	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	n_cmd(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move	d2,d4
T01	cmp.w	#1,d2
	bne		T02
	move.w	#WYW,WYK1
T02	cmp.w	#2,d2
	bne		T03
	move.w	#WYW,WYK2
T03	cmp.w	#3,d2
	bne		T04
	move.w	#WYW,WYK3
T04	cmp.w	#4,d2
	bne		T05
	move.w	#WYW,WYK4
T05	cmp.w	#5,d2
	bne		T06
	move.w	#WYW,WYK5
T06	cmp.w	#6,d2
	bne		T07
	move.w	#WYW,WYK6
T07	cmp.w	#7,d2
	bne		T08
	move.w	#WYW,WYK7
T08	cmp.w	#8,d2
	bne		T09
	move.w	#WYW,WYK8
T09	cmp.w	#9,d2
	bne		T10
	move.w	#WYW,WYK9
T10	cmp.w	#10,d2
	bne		T11
	move.w	#WYW,WYK10
T11	cmp.w	#11,d2
	bne		T12
	move.w	#WYW,WYK11
T12	cmp.w	#12,d2
	bne		T13
	move.w	#WYW,WYK12
T13	cmp.w	#13,d2
	bne		T14
	move.w	#WYW,WYK13
T14	cmp.w	#14,d2
	bne		T15
	move.w	#WYW,WYK14
T15	cmp.w	#15,d2
	bne		T16
	move.w	#WYW,WYK15
T16	cmp.w	#16,d2
	bne		T17
	move.w	#WYW,WYK16
T17	cmp.w	#17,d2
	bne		T18
	move.w	#WYW,WYK17
T18	cmp.w	#18,d2
	bne		T19
	move.w	#WYW,WYK18
T19	cmp.w	#19,d2
	bne		T20
	move.w	#WYW,WYK19
T20	cmp.w	#20,d2
	bne		T21
	move.w	#WYW,WYK20
T21	cmp.w	#21,d2
	bne		T22
	move.w	#WYW,WYK21
T22	cmp.w	#22,d2
	bne		T23
	move.w	#WYW,WYK22
T23	cmp.w	#23,d2
	bne		T24
	move.w	#WYW,WYK23
T24	cmp.w	#24,d2
	bne		T25
	move.w	#WYW,WYK24
T25	cmp.w	#25,d2
	bne		T26
	move.w	#WYW,WYK25
T26	cmp.w	#26,d2
	bne		T27
	move.w	#WYW,WYK26
T27	cmp.w	#27,d2
	bne		T28
	move.w	#WYW,WYK27
T28	cmp.w	#28,d2
	bne		T29
	move.w	#WYW,WYK28
T29	cmp.w	#29,d2
	bne		T30
	move.w	#WYW,WYK29
T30	cmp.w	#30,d2
	bne		T31
	move.w	#WYW,WYK30
T31	subq.l	#1,d2
	asl.l	#2,d2
	mulu	#30,d4
	move.l	(a1,d2.l),n_start(a6)
	move.w	(a3,d4.l),n_length(a6)
	move.w	(a3,d4.l),n_reallength(a6)
	move.b	2(a3,d4.l),n_finetune(a6)
	move.b	3(a3,d4.l),n_volume(a6)
	move.w	4(a3,d4.l),d3 ; get repeat
	tst.w	d3
	beq.s	mt_noloop
	move.l	n_start(a6),d2		; get start
	asl.w	#1,d3
	add.l	d3,d2		; add repeat
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	4(a3,d4.l),d0	; get repeat
	add.w	6(a3,d4.l),d0	; add replen
	move.w	d0,n_length(a6)
	move.w	6(a3,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,12(a5)	; set volume
	bra.s	mt_setregs

mt_noloop	move.l	n_start(a6),d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	6(a3,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,12(a5)	; set volume

mt_setregs	move.w	(a6),d0
	and.w	#$0fff,d0
	beq	mt_checkmoreefx	; if no note
	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0e50,d0
	beq.s	mt_dosetfinetune
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#3,d0	; toneportamento
	beq.s	mt_chktoneporta
	cmp.b	#5,d0
	beq.s	mt_chktoneporta
	cmp.b	#9,d0	; sample offset
	bne.s	mt_setperiod
	bsr	mt_checkmoreefx
	bra.s	mt_setperiod

mt_dosetfinetune
	bsr	mt_setfinetune
	bra.s	mt_setperiod

mt_chktoneporta
	bsr	mt_settoneporta
	bra	mt_checkmoreefx

mt_setperiod
	cmp.w	#1,TERAZ
	bne		TONIE1
	move.w	#34,WYKA1
TONIE1:
	cmp.w	#2,TERAZ
	bne		TONIE2
	move.w	#34,WYKA2
TONIE2:
	cmp.w	#3,TERAZ
	bne		TONIE3
	move.w	#34,WYKA3
TONIE3:
	cmp.w	#4,TERAZ
	bne		TONIE4
	move.w	#34,WYKA4
TONIE4:
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	(a6),d1
	and.w	#$0fff,d1
	lea	mt_periodtable(pc),a1
	moveq	#0,d0
	moveq	#36,d7
mt_ftuloop	cmp.w	(a1,d0.w),d1
	bhs.s	mt_ftufound
	addq.l	#2,d0
	dbra	d7,mt_ftuloop
mt_ftufound
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	add.l	d1,a1
	move.w	(a1,d0.w),n_period(a6)
	movem.l	(sp)+,d0-d1/a0-a1

	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0ed0,d0 ; notedelay
	beq	mt_checkmoreefx

	btst	#2,n_wavecontrol(a6)
	bne.s	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.s	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc
	move.l	n_start(a6),(a5)	; set start
	moveq	#0,d0
	move.w	n_length(a6),d0		; set length
	add.l	d0,d0
	add.l	(a5),d0
	move.l	d0,8(a5)
	move.l	n_loopstart(a6),d0
	cmp.l	(a5),d0
	bne.s	.mt_set_loop
	moveq	#0,d0
.mt_set_loop	move.l	d0,4(a5)
	move.w	n_period(a6),d0
	move.w	d0,14(a5)		; set period
	move.w	n_dmabit(a6),d0
	or.w	d0,mt_dmacontemp
	bra	mt_checkmoreefx
 
mt_setdma
mt_dskip	add.w	#16,mt_patternpos
	move.b	mt_pattdeltime,d0
	beq.s	mt_dskc
	move.b	d0,mt_pattdeltime2
	clr.b	mt_pattdeltime
mt_dskc	tst.b	mt_pattdeltime2
	beq.s	mt_dska
	subq.b	#1,mt_pattdeltime2
	beq.s	mt_dska
	sub.w	#16,mt_patternpos
mt_dska	tst.b	mt_pbreakflag
	beq.s	mt_nnpysk
	sf	mt_pbreakflag
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	clr.b	mt_pbreakpos
	lsl.w	#4,d0
	move.w	d0,mt_patternpos
mt_nnpysk	cmp.w	#1024,mt_patternpos
	blo.s	mt_nonewposyet
mt_nextposition	
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	lsl.w	#4,d0
	move.w	d0,mt_patternpos
	clr.b	mt_pbreakpos
	clr.b	mt_posjumpflag
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos(pc),d1
	move.l	mt_songdataptr(pc),a0
	cmp.b	950(a0),d1
	blo.s	mt_nonewposyet
	clr.b	mt_songpos
mt_nonewposyet	
	tst.b	mt_posjumpflag
	bne.s	mt_nextposition
	movem.l	(sp)+,d0-d4/a0-a6
	rts

mt_checkefx
	bsr	mt_updatefunk
	move.w	n_cmd(a6),d0
	and.w	#$0fff,d0
	beq.s	mt_pernop
	move.b	n_cmd(a6),d0
	and.b	#$0f,d0
	beq.s	mt_arpeggio
	cmp.b	#1,d0
	beq	mt_portaup
	cmp.b	#2,d0
	beq	mt_portadown
	cmp.b	#3,d0
	beq	mt_toneportamento
	cmp.b	#4,d0
	beq	mt_vibrato
	cmp.b	#5,d0
	beq	mt_toneplusvolslide
	cmp.b	#6,d0
	beq	mt_vibratoplusvolslide
	cmp.b	#$e,d0
	beq	mt_e_commands
setback	move.w	n_period(a6),14(a5)
	cmp.b	#7,d0
	beq	mt_tremolo
	cmp.b	#$a,d0
	beq	mt_volumeslide
mt_return2
	rts

mt_pernop
	move.w	n_period(a6),14(a5)
	rts

mt_arpeggio
	moveq	#0,d0
	move.b	mt_counter(pc),d0
	divs	#3,d0
	swap	d0
	cmp.w	#0,d0
	beq.s	mt_arpeggio2
	cmp.w	#2,d0
	beq.s	mt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arpeggio3

mt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#15,d0
	bra.s	mt_arpeggio3

mt_arpeggio2
	move.w	n_period(a6),d2
	bra.s	mt_arpeggio4

mt_arpeggio3
	asl.w	#1,d0
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	lea	mt_periodtable(pc),a0
	add.l	d1,a0
	moveq	#0,d1
	move.w	n_period(a6),d1
	moveq	#36,d7
mt_arploop
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bhs.s	mt_arpeggio4
	addq.l	#2,a0
	dbra	d7,mt_arploop
	rts

mt_arpeggio4	move.w	d2,14(a5)
	rts

mt_fineportaup
	tst.b	mt_counter
	bne.s	mt_return2
	move.b	#$0f,mt_lowmask
mt_portaup
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	sub.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#113,d0
	bpl.s	mt_portauskip
	and.w	#$f000,n_period(a6)
	or.w	#113,n_period(a6)
mt_portauskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,14(a5)
	rts	
 
mt_fineportadown
	tst.b	mt_counter
	bne	mt_return2
	move.b	#$0f,mt_lowmask
mt_portadown
	clr.w	d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	add.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#856,d0
	bmi.s	mt_portadskip
	and.w	#$f000,n_period(a6)
	or.w	#856,n_period(a6)
mt_portadskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,14(a5)
	rts

mt_settoneporta
	move.l	a0,-(sp)
	move.w	(a6),d2
	and.w	#$0fff,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#37*2,d0
	lea	mt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_stploop
	cmp.w	(a0,d0.w),d2
	bhs.s	mt_stpfound
	addq.w	#2,d0
	cmp.w	#37*2,d0
	blo.s	mt_stploop
	moveq	#35*2,d0
mt_stpfound
	move.b	n_finetune(a6),d2
	and.b	#8,d2
	beq.s	mt_stpgoss
	tst.w	d0
	beq.s	mt_stpgoss
	subq.w	#2,d0
mt_stpgoss
	move.w	(a0,d0.w),d2
	move.l	(sp)+,a0
	move.w	d2,n_wantedperiod(a6)
	move.w	n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp.w	d0,d2
	beq.s	mt_cleartoneporta
	bge	mt_return2
	move.b	#1,n_toneportdirec(a6)
	rts

mt_cleartoneporta
	clr.w	n_wantedperiod(a6)
	rts

mt_toneportamento
	move.b	n_cmdlo(a6),d0
	beq.s	mt_toneportnochange
	move.b	d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
mt_toneportnochange
	tst.w	n_wantedperiod(a6)
	beq	mt_return2
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	mt_toneportaup
mt_toneportadown
	add.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	bgt.s	mt_toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)
	bra.s	mt_toneportasetper

mt_toneportaup
	sub.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	blt.s	mt_toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)

mt_toneportasetper
	move.w	n_period(a6),d2
	move.b	n_glissfunk(a6),d0
	and.b	#$0f,d0
	beq.s	mt_glissskip
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#36*2,d0
	lea	mt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_glissloop
	cmp.w	(a0,d0.w),d2
	bhs.s	mt_glissfound
	addq.w	#2,d0
	cmp.w	#36*2,d0
	blo.s	mt_glissloop
	moveq	#35*2,d0
mt_glissfound
	move.w	(a0,d0.w),d2
mt_glissskip
	move.w	d2,14(a5) ; set period
	rts

mt_vibrato
	move.b	n_cmdlo(a6),d0
	beq.s	mt_vibrato2
	move.b	n_vibratocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_vibskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_vibskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_vibskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_vibskip2
	move.b	d2,n_vibratocmd(a6)
mt_vibrato2
	move.b	n_vibratopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	and.b	#$03,d2
	beq.s	mt_vib_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_vib_rampdown
	move.b	#255,d2
	bra.s	mt_vib_set
mt_vib_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	mt_vib_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	mt_vib_set
mt_vib_rampdown2
	move.b	d0,d2
	bra.s	mt_vib_set
mt_vib_sine
	move.b	0(a4,d0.w),d2
mt_vib_set
	move.b	n_vibratocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.s	mt_vibratoneg
	add.w	d2,d0
	bra.s	mt_vibrato3
mt_vibratoneg
	sub.w	d2,d0
mt_vibrato3
	move.w	d0,14(a5)
	move.b	n_vibratocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_vibratopos(a6)
	rts

mt_toneplusvolslide
	bsr	mt_toneportnochange
	bra	mt_volumeslide

mt_vibratoplusvolslide
	bsr.s	mt_vibrato2
	bra	mt_volumeslide

mt_tremolo
	move.b	n_cmdlo(a6),d0
	beq.s	mt_tremolo2
	move.b	n_tremolocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_treskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_treskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_treskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_treskip2
	move.b	d2,n_tremolocmd(a6)
mt_tremolo2
	move.b	n_tremolopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	lsr.b	#4,d2
	and.b	#$03,d2
	beq.s	mt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_tre_rampdown
	move.b	#255,d2
	bra.s	mt_tre_set
mt_tre_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	mt_tre_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	mt_tre_set
mt_tre_rampdown2
	move.b	d0,d2
	bra.s	mt_tre_set
mt_tre_sine
	move.b	0(a4,d0.w),d2
mt_tre_set
	move.b	n_tremolocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.s	mt_tremoloneg
	add.w	d2,d0
	bra.s	mt_tremolo3
mt_tremoloneg
	sub.w	d2,d0
mt_tremolo3
	bpl.s	mt_tremoloskip
	clr.w	d0
mt_tremoloskip
	cmp.w	#$40,d0
	bls.s	mt_tremolook
	move.w	#$40,d0
mt_tremolook
	move.w	d0,12(a5)
	move.b	n_tremolocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_tremolopos(a6)
	rts

mt_sampleoffset
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	beq.s	mt_sononew
	move.b	d0,n_sampleoffset(a6)
mt_sononew
	move.b	n_sampleoffset(a6),d0
	lsl.w	#7,d0
	cmp.w	n_length(a6),d0
	bge.s	mt_sofskip
	sub.w	d0,n_length(a6)
	lsl.w	#1,d0
	add.l	d0,n_start(a6)
	add.l	n_loopstart(a6),d0
	cmp.l	n_start(a6),d0
	ble.s	.mt_set_loop
	move.l	n_loopstart(a6),d0
.mt_set_loop	move.l	d0,n_loopstart(a6)
	rts
mt_sofskip	move.w	#$0001,n_length(a6)
	rts

mt_volumeslide
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_volslidedown
mt_volslideup
	add.b	d0,n_volume(a6)
	cmp.b	#$40,n_volume(a6)
	bmi.s	mt_vsuskip
	move.b	#$40,n_volume(a6)
mt_vsuskip
	move.b	n_volume(a6),d0
	move.w	d0,12(a5)
	rts

mt_volslidedown
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
mt_volslidedown2
	sub.b	d0,n_volume(a6)
	bpl.s	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip
	move.b	n_volume(a6),d0
	move.w	d0,12(a5)
	rts

mt_positionjump
	move.b	n_cmdlo(a6),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos
mt_pj2	clr.b	mt_pbreakpos
	st 	mt_posjumpflag
	rts

mt_volumechange
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	cmp.b	#$40,d0
	bls.s	mt_volumeok
	moveq	#$40,d0
mt_volumeok
	move.b	d0,n_volume(a6)
	move.w	d0,12(a5)
	rts

mt_patternbreak
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	mulu	#10,d0
	and.b	#$0f,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.s	mt_pj2
	move.b	d0,mt_pbreakpos
	st	mt_posjumpflag
	rts

mt_setspeed
	move.b	3(a6),d0
	beq	mt_return2
	clr.b	mt_counter
	move.b	d0,mt_speed
	rts

mt_checkmoreefx
	bsr	mt_updatefunk
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$9,d0
	beq	mt_sampleoffset
	cmp.b	#$b,d0
	beq	mt_positionjump
	cmp.b	#$d,d0
	beq.s	mt_patternbreak
	cmp.b	#$e,d0
	beq.s	mt_e_commands
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	cmp.b	#$c,d0
	beq	mt_volumechange
	bra	mt_pernop

mt_e_commands
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	lsr.b	#4,d0
	beq.s	mt_filteronoff
	cmp.b	#1,d0
	beq	mt_fineportaup
	cmp.b	#2,d0
	beq	mt_fineportadown
	cmp.b	#3,d0
	beq.s	mt_setglisscontrol
	cmp.b	#4,d0
	beq.s	mt_setvibratocontrol
	cmp.b	#5,d0
	beq.s	mt_setfinetune
	cmp.b	#6,d0
	beq.s	mt_jumploop
	cmp.b	#7,d0
	beq	mt_settremolocontrol
	cmp.b	#9,d0
	beq	mt_retrignote
	cmp.b	#$a,d0
	beq	mt_volumefineup
	cmp.b	#$b,d0
	beq	mt_volumefinedown
	cmp.b	#$c,d0
	beq	mt_notecut
	cmp.b	#$d,d0
	beq	mt_notedelay
	cmp.b	#$e,d0
	beq	mt_patterndelay
	cmp.b	#$f,d0
	beq	mt_funkit
	rts

mt_filteronoff	rts	

mt_setglisscontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts

mt_setvibratocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_setfinetune
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	move.b	d0,n_finetune(a6)
	rts

mt_jumploop
	tst.b	mt_counter
	bne	mt_return2
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_setloop
	tst.b	n_loopcount(a6)
	beq.s	mt_jumpcnt
	subq.b	#1,n_loopcount(a6)
	beq	mt_return2
mt_jmploop	move.b	n_pattpos(a6),mt_pbreakpos
	st	mt_pbreakflag
	rts

mt_jumpcnt
	move.b	d0,n_loopcount(a6)
	bra.s	mt_jmploop

mt_setloop
	move.w	mt_patternpos(pc),d0
	lsr.w	#4,d0
	move.b	d0,n_pattpos(a6)
	rts

mt_settremolocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_retrignote	move.l	d1,-(sp)
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
	bne.s	mt_rtnskp
	move.w	(a6),d1
	and.w	#$0fff,d1
	bne.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
mt_rtnskp	divu	d0,d1
	swap	d1
	tst.w	d1
	bne.s	mt_rtnend
mt_doretrig	move.l	n_start(a6),(a5)	; set sampledata pointer
	moveq	#0,d0
	move.w	n_length(a6),d0		; set length
	add.l	d0,d0
	add.l	(a5),d0
	move.l	d0,8(a5)

	move.l	n_loopstart(a6),d0
	cmp.l	(a5),d0
	bne.s	.mt_set_loop
	moveq	#0,d0
.mt_set_loop	move.l	d0,4(a5)

mt_rtnend	move.l	(sp)+,d1
	rts

mt_volumefineup
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	bra	mt_volslideup

mt_volumefinedown
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	bra	mt_volslidedown2

mt_notecut
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter(pc),d0
	bne	mt_return2
	clr.b	n_volume(a6)
	move.w	#0,12(a5)
	rts

mt_notedelay
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter,d0
	bne	mt_return2
	move.w	(a6),d0
	beq	mt_return2
	move.l	d1,-(sp)
	bra	mt_doretrig

mt_patterndelay
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	tst.b	mt_pattdeltime2
	bne	mt_return2
	addq.b	#1,d0
	move.b	d0,mt_pattdeltime
	rts

mt_funkit
	tst.b	mt_counter
	bne	mt_return2
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	beq	mt_return2
mt_updatefunk
	movem.l	a0/d1,-(sp)
	moveq	#0,d0
	move.b	n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.s	mt_funkend
	lea	mt_funktable(pc),a0
	move.b	(a0,d0.w),d0
	add.b	d0,n_funkoffset(a6)
	btst	#7,n_funkoffset(a6)
	beq.s	mt_funkend
	clr.b	n_funkoffset(a6)

	move.l	n_loopstart(a6),d0
	moveq	#0,d1
	move.w	n_replen(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	move.l	n_wavestart(a6),a0
	addq.l	#1,a0
	cmp.l	d0,a0
	blo.s	mt_funkok
	move.l	n_loopstart(a6),a0
mt_funkok
	move.l	a0,n_wavestart(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
mt_funkend
	movem.l	(sp)+,a0/d1
	rts

mt_init_Paula	bsr.s	mt_make_freq
	bsr	mt_make_tables
	bsr	mt_setup_voltab
	bsr	mt_make_zero
mt_init_Trap0	lea	mt_save_Trap0,a0
	move.l	$80.w,(a0)
	lea	mt_return,a0
	move.l	a0,$80.w
	rts

mt_make_freq	move.l	mt_freq_code_0,a0
	move.l	mt_freq_code_1,a1
	move.l	mt_freq_table0,a2
	move.l	mt_freq_table1,a3
	moveq	#$f,d0
.mt_make_loop	move.l	a0,(a2)+
	move.l	a1,(a3)+
	move.l	d0,d1
	swap	d1
	divu.w	#200,d1
	move.w	#199,d7
	move.l	d1,d2
	swap	d2
	cmp.w	#100,d2
	blt.s	.mt_zero
	addq.w	#1,d1
.mt_zero	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
.mt_maker	moveq	#0,d5

	add.w	d1,d2
	addx.w	d5,d3
	move.w	d3,d5
	move.w	d2,d6
	add.w	d6,d6
	negx.w	d5
	neg.w	d5
	cmp.w	d4,d5
	beq.s	.mt_put_op
	move.w	d5,d4
	move.w	d3,d5
	move.w	d2,d6
	add.w	d1,d6
	negx.w	d5
	neg.w	d5
	add.w	d6,d6
	negx.w	d5
	neg.w	d5
	cmp.w	d4,d5
	beq.s	.mt_just_one_inc

	move.l	mt_one_inc10,(a0)+
	move.w	mt_one_inc10+4,(a0)+
	move.l	mt_one_inc01,(a1)+
	move.l	mt_one_inc01+4,(a1)+
	bra.s	.mt_go_on_loop
.mt_just_one_inc
	move.l	mt_one_inc00,(a0)+
	move.l	mt_one_inc00+4,(a0)+
	move.l	mt_one_inc01,(a1)+
	move.l	mt_one_inc01+4,(a1)+
	bra.s	.mt_go_on_loop
.mt_put_op	move.w	mt_copy0,(a0)+
	move.w	mt_copy1,(a1)+
.mt_go_on_loop	dbra	d7,.mt_maker
	move.w	#$4ed5,(a0)+
	move.w	#$4ed5,(a1)+
	addq.l	#1,d0
	cmp.l	#126,d0
	bne	.mt_make_loop

	rts
mt_one_inc00	move.b	(a3)+,d0
	move.l	d0,a4
	move.b	(a4),d0
	move.b	d0,(sp)+

mt_one_inc01	move.b	(a3)+,d0
	move.l	d0,a4
	move.b	(a4),d0
	add.b	d0,(sp)+

mt_one_inc10	move.b	(a3)+,d0
	move.l	d0,a4
	move.b	(a4),(sp)+

mt_copy0	move.b	d0,(sp)+
mt_copy1	add.b	d0,(sp)+

mt_make_tables	move.l	mt_period_tab,a0

	move.w	#$72-1,d0
	moveq	#110,d1
.mt_copy_loop	move.l	d1,(a0)+
	dbra	d0,.mt_copy_loop

	move.w	#$72,d0
.mt_maker	move.l	mt_amiga_freq,d1
	divu.w	d0,d1
	move.w	d0,d3
	moveq	#0,d2
	asr.w	#1,d3
	addx.w	d2,d3
	move.l	d1,d2
	swap	d2
	cmp.w	d3,d2
	blt.s	.mt_no_add
	addq.w	#1,d1
.mt_no_add	andi.l	#$ffff,d1
	divu.w	#250,d1
	move.w	d1,d2
	clr.w	d1
	divu.w	#250,d1
	swap	d1
	moveq	#0,d3
	cmp.w	#125,d1
	blt.s	.mt_no_add1
	add.l	#$10000,d1
	addx.w	d3,d2
.mt_no_add1	move.w	d2,d1
	sub.w	#$f,d1
	bpl.s	.mt_no_dang
	moveq	#0,d1
.mt_no_dang	move.l	d1,(a0)+
	addq.w	#1,d0
	cmp.w	#$400,d0
	bne.s	.mt_maker
	rts
mt_setup_voltab
	lea	mt_volume_tab,a0
	move.l	(a0),d0
	andi.w	#$ff00,d0
	add.l	#$100,d0
	move.l	d0,(a0)
	move.l	d0,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
.mt_clop	move.w	d1,d2
	ext.w	d2
	muls.w	d0,d2
	asr.w	#7,d2
	move.b	d2,(a0)+
	addq.w	#1,d1
	cmp.w	#$100,d1
	bne.s	.mt_clop
	moveq	#0,d1
	addq.w	#1,d0
	cmp.w	#$41,d0
	bne.s	.mt_clop	
	rts

mt_make_zero	move.l	mt_zero_code,a0
	move.w	.mt_zero_op,d0
	move.w	#500-1,d1
.mt_make_lop	move.w	d0,(a0)+
	dbra	d1,.mt_make_lop
	move.w	#$4ed2,(a0)
	rts
.mt_zero_op	move.l	d0,(a0)+

mt_stop_Paula
mt_rest_Trap0	move.l	mt_save_Trap0,$80.w
	rts
;Paula(Ste) table
;dc.l	sample_start		+0
;dc.l	sample_loop_start	+4
;dc.l	sample_end		+8
;dc.w	volume		+12
;dc.w	period		+14
;dc.w	old_period		+16
;dc.w	float_add		+18
;
;Offset Paula table
	rsreset
mt_sample_start	rs.l	1
mt_sample_loop	rs.l	1
mt_sample_end	rs.l	1
mt_volume	rs.w	1
mt_period	rs.w	1
mt_oldperiod	rs.w	1
mt_add_iw	rs.w	1
mt_old_sample	rs.w	1

mt_channel	macro
	move.l	mt_sample_start(a0),d0
	beq	.mt_continue
.mt_no_reset	move.w	mt_period(a0),d0
	and.w	#$3ff,d0
	cmp.w	mt_oldperiod(a0),d0
	beq.s	.mt_noreset_add
	clr.w	mt_add_iw(a0)
	move.w	d0,mt_oldperiod(a0)
.mt_noreset_add	add.w	d0,d0
	add.w	d0,d0
	move.l	mt_period_tab,a4
	move.l	(a4,d0.w),d2
	move.w	d2,d4
	swap	d2
	move.w	mt_add_iw(a0),d3


	move.w	mt_volume(a0),d0
	andi.w	#$7f,d0
	asl.w	#8,d0
	move.l	mt_volume_tab,a4
	lea	(a4,d0.w),a4
	move.l	a4,d0
	move.l	mt_sample_start(a0),a3
	move.b	mt_old_sample(a0),d0

	moveq	#0,d5

	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	.mt_return_0,a5
	move.l	(a1,d5.w),a2
	jmp	(a2)

.mt_return_0	moveq	#0,d5
	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	.mt_return_1,a5
	move.l	(a1,d5.w),a2
	jmp	(a2)

.mt_return_1	moveq	#0,d5
	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	.mt_return_2,a5
	move.l	(a1,d5.w),a2
	jmp	(a2)

.mt_return_2	moveq	#0,d5
	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	.mt_return_3,a5
	move.l	(a1,d5.w),a2
	jmp	(a2)

.mt_return_3	moveq	#0,d5
	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	.mt_return_4,a5
	move.l	(a1,d5.w),a2
	jmp	(a2)

.mt_return_4	move.w	d3,mt_add_iw(a0)
	move.b	d0,mt_old_sample(a0)
	move.l	a3,mt_sample_start(a0)
	move.l	mt_sample_end(a0),d1
	cmp.l	d1,a3
	blt.s	.mt_continue
	move.l	mt_sample_loop(a0),d0
	beq.s	.mt_no_loop
	move.l	d0,mt_sample_start(a0)
	sub.l	d1,d0
	neg.l	d0
	neg.l	d1
	add.l	a3,d1
	cmp.l	d0,d1
	ble.s	.mt_no_div
	divu.w	d0,d1
	clr.w	d1
	swap	d1
.mt_no_div	add.l	d1,mt_sample_start(a0)
	bra.s	.mt_continue
.mt_no_loop	lea	mt_dummy_spl_tab,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
.mt_continue
	endm

mt_Paula	move.w	#$ffff8900,a0
	clr.w	(a0)
	move.l	mt_physic_buf,d0
	movep.l	d0,$1(a0)
	add.l	mt_buf_length,d0
	movep.l	d0,$d(a0)
	move.w	mt_frequency,$20(a0)
	move.w	#1,(a0)
	lea	mt_save_SSP,a0
	move.l	sp,(a0)
	pea	mt_emulate
	move.w	mt_SR,-(sp)
	rte
mt_return	move.l	mt_save_SSP,sp
	lea	mt_physic_buf,a0
	lea	mt_logic_buf,a1
	move.l	(a0),d0
	move.l	(a1),(a0)
	move.l	d0,(a1)
	rts

mt_emulate	lea	mt_save_USP,a0
	move.l	sp,(a0)

	move.l	mt_channel_0,d0
	seq	d1
	move.l	mt_channel_1,d0
	seq	d0
	or.b	d0,d1
	beq.s	mt_no_clear_buf

	moveq	#0,d0
	move.l	mt_logic_buf,a0
	move.l	mt_zero_code,a1
	lea	mt_no_clear_buf,a2
	jmp	(a1)

mt_no_clear_buf	move.l	mt_logic_buf,sp
	lea	mt_channel_0,a0
	move.l	mt_freq_table0,a1
mt_left0	mt_channel

	move.l	mt_logic_buf,sp
	lea	1(sp),sp
	lea	mt_channel_1,a0
	move.l	mt_freq_table0,a1
mt_right0	mt_channel

	move.l	mt_logic_buf,sp
	lea	mt_channel_3,a0
	move.l	mt_freq_table1,a1
mt_left1	mt_channel

	move.l	mt_logic_buf,sp
	lea	1(sp),sp
	lea	mt_channel_2,a0
	move.l	mt_freq_table1,a1
mt_right1	mt_channel

	move.l	mt_save_USP,sp
	trap	#0

	section	data
mt_funktable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_vibratotable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_periodtable
; tuning 0, normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

	dc.w	$416E,$6F74,$6865,$7220
	dc.w	$6772,$6561,$7420,$636F
	dc.w	$6465,$2062,$793A,$204C
	dc.w	$616E,$6365,$2000

mt_chan1temp	dc.l	0,0,0,0,$3ff0000,$00010000,0,0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,$3ff0000,$00020000,0,0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,$3ff0000,$00040000,0,0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,$3ff0000,$00080000,0,0,0,0,0

mt_samplestarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_songdataptr	dc.l	0
mt_module_end	dc.l	0

mt_speed	dc.b	6
mt_counter	dc.b	0
mt_songpos	dc.b	0
mt_pbreakpos	dc.b	0
mt_posjumpflag	dc.b	0
mt_pbreakflag	dc.b	0
mt_lowmask	dc.b	0
mt_pattdeltime	dc.b	0
mt_pattdeltime2	dc.b	0,0

mt_patternpos	dc.w	0
mt_dmacontemp	dc.w	0

mt_amiga_freq	dc.l	3545000
mt_save_Trap0	dc.l	0
mt_physic_buf	dc.l	mt_physic_base
mt_logic_buf	dc.l	mt_logic_base
mt_buf_length	dc.l	2000
mt_save_USP	dc.l	0
mt_save_SSP	dc.l	0
mt_volume_tab	dc.l	mt_volume_data
mt_zero_code	dc.l	mt_zero_data
mt_freq_code_0	dc.l	mt_freq_0
mt_freq_code_1	dc.l	mt_freq_1
mt_freq_table0	dc.l	mt_freq_points0
mt_freq_table1	dc.l	mt_freq_points1
mt_period_tab	dc.l	mt_period_count
mt_frequency	dc.w	$0003
mt_SR	dc.w	$0300

mt_channel_0	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0
mt_channel_1	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0
mt_channel_2	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0
mt_channel_3	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0

mt_dummy_spl_tab
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0
TU:	ds.w	2000
	section	bss
mt_freq_points0	ds.l	111
mt_freq_points1	ds.l	111
mt_period_count	ds.l	1024
mt_physic_base	ds.w	1000+2
mt_logic_base	ds.w	1000+2
mt_volume_data	ds.w	128+$41*128
mt_zero_data	ds.w	501
mt_freq_0	ds.w	44971
mt_freq_1	ds.w	45621
dir:
mt_data:


