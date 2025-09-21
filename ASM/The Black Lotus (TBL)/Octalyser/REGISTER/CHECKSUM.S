

start:
	move.l	#info1,-(sp)
	move.w	#9,-(sp)
	trap	#1			; Skriv ut infotexten ...
	addq.w	#6,sp

	pea	buffer
	move.w	#10,-(sp)
	trap	#1			; Mata in namnet
	addq.w	#6,sp

	clr.w	CHECKSUM
	moveq.l	#0,d7
	move.b	buffer+1,CHECKSUM+1
	move.b	buffer+2,d7
	add.w	d7,CHECKSUM
	move.b	buffer+3,d7
	add.w	d7,CHECKSUM


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

	moveq.l	#0,d7
	move.b	buffer+2,d7
	add.w	d7,CHECKSUM
	move.b	buffer+3,d7
	add.w	d7,CHECKSUM

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

	moveq.l	#0,d7
	move.b	buffer+2,d7
	add.w	d7,CHECKSUM
	move.b	buffer+3,d7
	add.w	d7,CHECKSUM

	subq.w	#1,d0
	lea	data,a0
	lea	state+4,a1
koppanamnet3:				; Kopiera namnet till
	move.b	(a0)+,(a1)+		; headern
	dbra	d0,koppanamnet3
	move.b	#'',(a1)


word_to_string		; Word i d0 („ven ”vre wordet ska vara rensat)
			; antal teckenrutor i d1, destination i a0
	
	moveq	#0,d0
	move.w	CHECKSUM,d0
	move.w	#4,d1
	lea	value,a0

	lea	(a0,d1.w),a0
	clr.b	(a0)		; nollavslutad

	subq	#1,d1
.loop
	divu.w	#10,d0
	swap	d0
	add.w	#$30,d0
	move.b	d0,-(a0)
	clr.w	d0
	swap	d0
	dbf	d1,.loop



	pea	info6
	move.w	#9,-(sp)
	trap	#1			; Skriv ut infotexten ...
	addq.w	#6,sp

	move.w	#1,-(sp)
	trap	#1
	addq.w	#2,sp

	clr.w	-(sp)
	trap	#1

handle:	dc.w	0

CHECKSUM dc.w	0

info1:	dc.b	'eE'
	dc.b	'This program may not be spread outside THE OCTALYSER TEAM!',10,13,10
	dc.b	'Enter the name: ',0
info2:	dc.b	10,13,'Enter the adress: ',0
info3:	dc.b	10,13,'Enter ZIP-Code & City: ',0
info6:	dc.b	10,10,13,'Checksum number is: '
value:	dc.b	0,0,0,0,0,0,0,0,0,0


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