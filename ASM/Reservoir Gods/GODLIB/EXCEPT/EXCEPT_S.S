**************************************************************************************
*
* GodLib Exception Handler Library
*
* [c] 2001 Reservoir Gods 
*
**************************************************************************************

	import	Except_Main
	import	gExceptInfo

	export	Except_Handler68000
	export	Except_Handler68030

	export	Except_Crash

	export	gExcept_HandlersTable

**************************************************************************************
;	MACROS
**************************************************************************************

	MACRO	mException	aNum

	move.w	#$2700,sr
	move.w	#aNum,gExceptInfo+sExceptInfo_Type
	bra		Except_Handler68000

	ENDM

**************************************************************************************
;	STRUCTS
**************************************************************************************

	OFFSET

sExceptInfo_Dreg:	ds.l	8
sExceptInfo_Areg:	ds.l	8
sExceptInfo_PC:		ds.l	1
sExceptInfo_SR:		ds.w	1
sExceptInfo_Type:	ds.w	1



**************************************************************************************
	TEXT
**************************************************************************************

Except_Crash:
	illegal
	jmp	$12345678


Except_Handler00:
	mException	0	

Except_Handler01:
	mException	1	

Except_Handler02:
	mException	2

Except_Handler03:
	mException	3	

Except_Handler04:
	mException	4	

Except_Handler05:
	mException	5	

Except_Handler06:
	mException	6	

Except_Handler07:
	mException	7	

Except_Handler08:
	mException	8	

Except_Handler09:
	mException	9	

Except_Handler10:
	mException	10	

Except_Handler11:
	mException	11	

Except_Handler12:
	mException	12	

Except_Handler13:
	mException	13	

Except_Handler14:
	mException	14	

Except_Handler15:
	mException	15	

Except_Handler16:
	mException	16	

Except_Handler17:
	mException	17	

Except_Handler18:
	mException	18	

Except_Handler19:
	mException	19	

Except_Handler20:
	mException	20	

Except_Handler21:
	mException	21	

Except_Handler22:
	mException	22	

Except_Handler23:
	mException	23	

Except_Handler24:
	mException	24	

Except_Handler25:
	mException	25	

Except_Handler26:
	mException	26	

Except_Handler27:
	mException	27	

Except_Handler28:
	mException	28	

Except_Handler29:
	mException	29	

Except_Handler30:
	mException	30	

Except_Handler31:
	mException	31	

Except_Handler32:
	mException	32	

Except_Handler33:
	mException	33	

Except_Handler34:
	mException	34	

Except_Handler35:
	mException	35	

Except_Handler36:
	mException	36	

Except_Handler37:
	mException	37	

Except_Handler38:
	mException	38	

Except_Handler39:
	mException	39	

Except_Handler40:
	mException	40	

Except_Handler41:
	mException	41	

Except_Handler42:
	mException	42	

Except_Handler43:
	mException	43	

Except_Handler44:
	mException	44	

Except_Handler45:
	mException	45	

Except_Handler46:
	mException	46	

Except_Handler47:
	mException	47	

Except_Handler48:
	mException	48	

Except_Handler49:
	mException	49	

Except_Handler50:
	mException	50	

Except_Handler51:
	mException	51	

Except_Handler52:
	mException	52	

Except_Handler53:
	mException	53	

Except_Handler54:
	mException	54	

Except_Handler55:
	mException	55	

Except_Handler56:
	mException	56	

Except_Handler57:
	mException	57	

Except_Handler58:
	mException	58	

Except_Handler59:
	mException	59	

Except_Handler60:
	mException	60	

Except_Handler61:
	mException	61	

Except_Handler62:
	mException	62	

Except_Handler63:
	mException	63	


*------------------------------------------------------------------------------------*
* FUNCTION : Except_Handler68000
* ACTION   : 68000 except handler
* CREATION : 17.11.01 PNK
*------------------------------------------------------------------------------------*

Except_Handler68000:

	move.w	#$2700,sr


	move.w	#$FFFF,$ffff8240

	move.l	d0,gExceptInfo+sExceptInfo_Dreg+(0*4)
	move.l	d1,gExceptInfo+sExceptInfo_Dreg+(1*4)
	move.l	d2,gExceptInfo+sExceptInfo_Dreg+(2*4)
	move.l	d3,gExceptInfo+sExceptInfo_Dreg+(3*4)
	move.l	d4,gExceptInfo+sExceptInfo_Dreg+(4*4)
	move.l	d5,gExceptInfo+sExceptInfo_Dreg+(5*4)
	move.l	d6,gExceptInfo+sExceptInfo_Dreg+(6*4)
	move.l	d7,gExceptInfo+sExceptInfo_Dreg+(7*4)

	move.l	a0,gExceptInfo+sExceptInfo_Areg+(0*4)
	move.l	a1,gExceptInfo+sExceptInfo_Areg+(1*4)
	move.l	a2,gExceptInfo+sExceptInfo_Areg+(2*4)
	move.l	a3,gExceptInfo+sExceptInfo_Areg+(3*4)
	move.l	a4,gExceptInfo+sExceptInfo_Areg+(4*4)
	move.l	a5,gExceptInfo+sExceptInfo_Areg+(5*4)
	move.l	a6,gExceptInfo+sExceptInfo_Areg+(6*4)
	move.l	a7,gExceptInfo+sExceptInfo_Areg+(7*4)

	move.w	0(a7),gExceptInfo+sExceptInfo_SR
	move.l	2(a7),gExceptInfo+sExceptInfo_PC
	
	lea		gExceptStack,a7

	jmp	Except_Main


*------------------------------------------------------------------------------------*
* FUNCTION : Except_Handler68030
* ACTION   : 68000 except handler
* CREATION : 17.11.01 PNK
*------------------------------------------------------------------------------------*

Except_Handler68030:

	move.w	#$2700,sr

	move.l	d0,gExceptInfo+sExceptInfo_Dreg+(0*4)
	move.l	d1,gExceptInfo+sExceptInfo_Dreg+(1*4)
	move.l	d2,gExceptInfo+sExceptInfo_Dreg+(2*4)
	move.l	d3,gExceptInfo+sExceptInfo_Dreg+(3*4)
	move.l	d4,gExceptInfo+sExceptInfo_Dreg+(4*4)
	move.l	d5,gExceptInfo+sExceptInfo_Dreg+(5*4)
	move.l	d6,gExceptInfo+sExceptInfo_Dreg+(6*4)
	move.l	d7,gExceptInfo+sExceptInfo_Dreg+(7*4)

	move.l	a0,gExceptInfo+sExceptInfo_Areg+(0*4)
	move.l	a1,gExceptInfo+sExceptInfo_Areg+(1*4)
	move.l	a2,gExceptInfo+sExceptInfo_Areg+(2*4)
	move.l	a3,gExceptInfo+sExceptInfo_Areg+(3*4)
	move.l	a4,gExceptInfo+sExceptInfo_Areg+(4*4)
	move.l	a5,gExceptInfo+sExceptInfo_Areg+(5*4)
	move.l	a6,gExceptInfo+sExceptInfo_Areg+(6*4)
	move.l	a7,gExceptInfo+sExceptInfo_Areg+(7*4)


	move.w	0(a7),gExceptInfo+sExceptInfo_SR
	move.l	2(a7),gExceptInfo+sExceptInfo_PC
	move.w	6(a7),d0
	lsr.w	#2,d0
	andi.w	#63,d0
	move.w	d0,gExceptInfo+sExceptInfo_Type

	
	lea		gExceptStack,a7

	jmp	Except_Main

**************************************************************************************
	DATA
**************************************************************************************

gExcept_HandlersTable:
	dc.l	Except_Handler00
	dc.l	Except_Handler01
	dc.l	Except_Handler02
	dc.l	Except_Handler03
	dc.l	Except_Handler04
	dc.l	Except_Handler05
	dc.l	Except_Handler06
	dc.l	Except_Handler07
	dc.l	Except_Handler08
	dc.l	Except_Handler09
	dc.l	Except_Handler10
	dc.l	Except_Handler11
	dc.l	Except_Handler12
	dc.l	Except_Handler13
	dc.l	Except_Handler14
	dc.l	Except_Handler15
	dc.l	Except_Handler16
	dc.l	Except_Handler17
	dc.l	Except_Handler18
	dc.l	Except_Handler19
	dc.l	Except_Handler20
	dc.l	Except_Handler21
	dc.l	Except_Handler22
	dc.l	Except_Handler23
	dc.l	Except_Handler24
	dc.l	Except_Handler25
	dc.l	Except_Handler26
	dc.l	Except_Handler27
	dc.l	Except_Handler28
	dc.l	Except_Handler29
	dc.l	Except_Handler30
	dc.l	Except_Handler31
	dc.l	Except_Handler32
	dc.l	Except_Handler33
	dc.l	Except_Handler34
	dc.l	Except_Handler35
	dc.l	Except_Handler36
	dc.l	Except_Handler37
	dc.l	Except_Handler38
	dc.l	Except_Handler39
	dc.l	Except_Handler40
	dc.l	Except_Handler41
	dc.l	Except_Handler42
	dc.l	Except_Handler43
	dc.l	Except_Handler44
	dc.l	Except_Handler45
	dc.l	Except_Handler46
	dc.l	Except_Handler47
	dc.l	Except_Handler48
	dc.l	Except_Handler49
	dc.l	Except_Handler50
	dc.l	Except_Handler51
	dc.l	Except_Handler52
	dc.l	Except_Handler53
	dc.l	Except_Handler54
	dc.l	Except_Handler55
	dc.l	Except_Handler56
	dc.l	Except_Handler57
	dc.l	Except_Handler58
	dc.l	Except_Handler59
	dc.l	Except_Handler60
	dc.l	Except_Handler61
	dc.l	Except_Handler62
	dc.l	Except_Handler63


**************************************************************************************
	BSS
**************************************************************************************

	ALIGN	4

gExceptStackSpace:	ds.b	1024
gExceptStack:		ds.b	16