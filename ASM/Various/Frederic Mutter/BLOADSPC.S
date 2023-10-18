**************************
* BLOAD picture
* by Mutter Fr‚d‚ric
* Bonjour … ST-MAG France.
* (c) 90 

* length oder Dateilaenge
* length = 51104 fuer .SPU
* length = 32128 fuer .NEO
* length = xxxxx fuer .SPC (variabel)

length	=	37712		; Dateilaenge fuer "ALIEN.SPC"

	pea	mouse_OFF(PC)
	clr	-(SP)
	move	#25,-(SP)
	Trap	#14
	addq.l	#8,SP
	
	clr	-(SP)
	pea	filename(PC)
	move	#$3D,-(SP)	; OPEN FILE
	Trap	#1
	move	D0,D7		; D7 = handle
	lea	8(SP),SP
	pea	picture(PC)
	pea	length		
	move	D7,-(SP)	
	move	#$3F,-(SP)	; READ FILE
	Trap	#1
	lea	12(SP),SP
	move	D7,-(SP)
	move	#$3E,-(SP)	; CLOSE FILE
	trap	#1
	addq.l	#4,SP

	pea	picture(PC)	; Adresse des Bildes
	pea	show_SPeCtrum(PC)
	move.w	#38,-(SP)
	trap	#14
	lea	10(SP),SP


	pea	mouse_ON(PC)
	clr	-(SP)
	move	#25,-(SP)
	Trap	#14
	addq.l	#8,SP

	clr	-(SP)
	Trap	#1		; bye bye

	INCLUDE "SPC.S"
	
		SECTION	DATA
filename:	DC.B	"alien.SPC",0	; nur 37712 bytes z. B.!
mouse_OFF:	DC.B	18,00
mouse_ON:	DC.B	08,00

		SECTION	BSS
picture:	DS.B	length		; Hoechste Zahl
	

	
	