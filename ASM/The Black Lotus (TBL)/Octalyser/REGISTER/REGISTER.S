

start:
	move.l	#info1,-(sp)
	move.w	#9,-(sp)
	trap	#1			; Skriv ut infotexten ...
	addq.w	#6,sp

	pea	buffer
	move.w	#10,-(sp)
	trap	#1			; Mata in namnet
	addq.w	#6,sp

	subq.w	#1,d0
	lea	data,a0
	lea	regname+4,a1
koppanamnet:				; Kopiera namnet till
	move.b	(a0)+,(a1)+		; headern
	dbra	d0,koppanamnet
	move.b	#'',(a1)

	pea	info2
	move.w	#9,-(sp)
	trap	#1			; Skriv ut infotexten ...
	addq.w	#6,sp

	pea	buffer
	move.w	#10,-(sp)
	trap	#1			; Mata in namnet
	addq.w	#6,sp

	subq.w	#1,d0
	lea	data,a0
	lea	adress+4,a1
koppanamnet2:				; Kopiera namnet till
	move.b	(a0)+,(a1)+		; headern
	dbra	d0,koppanamnet2
	move.b	#'',(a1)

	pea	info3
	move.w	#9,-(sp)
	trap	#1			; Skriv ut infotexten ...
	addq.w	#6,sp

	pea	buffer
	move.w	#10,-(sp)
	trap	#1			; Mata in namnet
	addq.w	#6,sp

	subq.w	#1,d0
	lea	data,a0
	lea	state+4,a1
koppanamnet3:				; Kopiera namnet till
	move.b	(a0)+,(a1)+		; headern
	dbra	d0,koppanamnet3
	move.b	#'',(a1)

	move.w	#39*19-1,d0
	moveq	#0,d1
	moveq	#0,d2
	lea	helpscreen9,a0
eora:	move.b	(a0),d2
	add.l	d2,d1
	eor.b	#42,(a0)+		; "Skugga" data
	dbra	d0,eora

	move.b	d1,mm+3
	lsr.l	#8,d1
	move.b	d1,mm+2
	lsr.l	#8,d1
	move.b	d1,mm+1
	lsr.l	#8,d1
	move.b	d1,mm

	move.w	#2,-(sp)
	pea	octa
	move.w	#$3d,-(sp)
	trap	#1
	addq.w	#8,sp
	tst.w	d0
	bmi	hittarinteocta
	move.w	d0,handle

	move.w	#2,-(sp)
	move.w	handle,-(sp)
	clr.l	-(sp)
	move.w	#$42,-(sp)
	trap	#1			; Leta fram slutet av Octan
	lea	10(sp),sp

	pea	helpscreen9
	move.l	#39*19+4,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1			; Skriv ner registreringsdatan
	lea	12(sp),sp

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			; St„ng filen
	addq.w	#4,sp

	pea	info5
	move.w	#9,-(sp)
	trap	#1			; Hittade inte octalyse.prg
	addq.w	#6,sp

	move.w	#1,-(sp)
	trap	#1
	addq.w	#2,sp

	clr.w	-(sp)
	trap	#1			; Avsluta

error:	illegal

hittarinteocta:
	pea	info4
hej:	move.w	#9,-(sp)
	trap	#1			; Hittade inte octalyse.prg
	addq.w	#6,sp

	move.w	#1,-(sp)
	trap	#1
	addq.w	#2,sp

	clr.w	-(sp)
	trap	#1

handle:	dc.w	0

info1:	dc.b	'eE'
	dc.b	'Detta program skriver ner registreringsdata till',10,13
	dc.b	'OCTALYSE.PRG. Registrera inte samma fil flera g†nger',10,13
	dc.b	'eftersom filen d† kommer att bli l„ngre och l„ngre',10,13
	dc.b	'till ingen nytta....',10,13,10,13
	dc.b	'Mata in namnet: ',0
info2:	dc.b	10,13,'Mata in adressen: ',0
info3:	dc.b	10,13,'Mata in postadress + stad: ',0
info4:	dc.b	10,13,10,13,'Hittade inte OCTALYSE.PRG',0
info5:	dc.b	10,13,10,13,'Skrev ner registreringen ...',0

octa:	dc.b	'OCTALYSE.PRG',0

	even

buffer:	dc.b	30,0
data:	ds.b	80

	even

helpscreen9:		; Uppl”sning: 38 x 19
	dc.b	'OCTALYSER STE IS A PRODUCT OF PAIN AND',0
	dc.b	'  SWEAT PLUS SOME  ASSEMBLER CODING.  ',0
	dc.b	'                                      ',0
	dc.b    '    THIS PROGRAM IS REGISTERED TO:    ',0
	dc.b	'                                      ',0
regname:dc.b 	'    X                                ',0 ; Max 30 i regnamn (ESC avslutar)
adress:	dc.b	'    X                                ',0 ; Max 30 i regadress (ESC avslutar)
state:	dc.b	'    X                                ',0 ; Max 30 i regstad (ESC avslutar)
	dc.b	'                                      ',0
	dc.b	'                                      ',0
	dc.b	' PLEASE READ THE MANUAL TO BE ABLE TO ',0
	dc.b	'UNDERSTAND AND USE ALL OF THE MEGATONS',0
	dc.b    'OF FUNCTIONS  THAT CAN BE FOUND IN THE',0
	dc.b	'            OCTALYSER STE!            ',0
	dc.b	'                                      ',0
	dc.b	'(C)1992, 1993, 1994 THE OCTALYSER-TEAM',0
	dc.b    '                                      ',0
	dc.b	'--------------------------------------',0
	dc.b	' PAGE 9 - PAIN AND SWEAT IS ALL U EARN',0
mm:	dc.b	0,0,0,0	; Notera att denna ligger p† oj„mn adress!

	even