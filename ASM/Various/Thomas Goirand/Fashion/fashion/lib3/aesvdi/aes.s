	TEXT

	XDEF	global,int_in,int_out,addr_in,addr_out,aes_params
	XDEF	CALL_AES
CALL_AES
	movem.l	d1-d2/a0-a2,-(sp)

	lea	aes_params,a0
	lea	_AES_REF,a1
	move.w	d0,d1
	lsl.w	#3,d0
	add.w	d1,d0
	add.w	d1,d0
	add.w	d0,a1
	move.l	a1,(a0)
	move.l	a0,d1
	move.w	#200,d0
	trap	#2
	move.w	int_out,d0
	movem.l	(sp)+,d1-d2/a0-a2
	rts

		bss
global		ds.w	15
int_in		ds.w	128
int_out		ds.w	128
addr_in		ds.l	16
addr_out	ds.l	16
*--------------------------------------------------------------------------------------------------------------------------*
	data
aes_params
	dc.l	0	; control (on fait un move de l'adresse lors de l'appel (en foncion du numero de fonction))
	dc.l	global,int_in,int_out,addr_in,addr_out
*--------------------------------------------------------------------------------------------------------------------------*
_AES_REF:
		; opcode,taille intin,intout,addrin,addrout

	dcb.w	10*5,0

	dc.w	10,0,1,0,0
	dc.w	11,2,1,1,0
	dc.w	12,2,1,1,0
	dc.w	13,0,1,1,0
	dc.w	14,2,1,1,0
	dc.w	15,1,1,1,0

	dcb.w	3*5,0

	dc.w	19,0,1,0,0
	dc.w	20,0,1,0,0
	dc.w	21,3,5,0,0
	dc.w	22,5,4,0,0
	dc.w	23,0,1,1,0
	dc.w	24,2,1,0,0
	dc.w	25,16,7,1,0
	dc.w	26,2,1,0,0

	dcb.w	3*5,0

	dc.w	30,1,1,1,0
	dc.w	31,2,1,1,0
	dc.w	32,2,1,1,0
	dc.w	33,2,1,1,0
	dc.w	34,1,1,2,0
	dc.w	35,1,1,1,0

	dcb.w	4*5,0

	dc.w	40,2,1,1,0
	dc.w	41,1,1,1,0
	dc.w	42,6,1,1,0
	dc.w	43,4,1,1,0
	dc.w	44,1,3,1,0
	dc.w	45,2,1,1,0
	dc.w	46,4,2,1,0
	dc.w	47,8,1,1,0

	dcb.w	2*5,0

	dc.w	50,1,1,1,0
	dc.w	51,9,1,0,0
	dc.w	52,1,1,1,0
	dc.w	53,1,0,0,0
	dc.w	54,0,5,1,0
	dc.w	55,3,3,1,0

	dcb.w	14*5,0

	dc.w	70,4,3,0,0
	dc.w	71,8,3,0,0
	dc.w	72,6,1,0,0
	dc.w	73,8,1,0,0
	dc.w	74,8,1,0,0
	dc.w	75,3,1,1,0
	dc.w	76,3,1,1,0
	dc.w	77,0,5,0,0
	dc.w	78,1,1,1,0
	dc.w	79,0,5,0,0
	dc.w	80,0,1,1,0
	dc.w	81,0,1,1,0

	dcb.w	8*5,0

	dc.w	90,0,2,2,0
	dc.w	91,0,2,3,0

	dcb.w	8*5,0

	dc.w	100,5,1,0,0
	dc.w	101,5,1,0,0
	dc.w	102,1,1,0,0
	dc.w	103,1,1,0,0
	dc.w	104,2,5,0,0
	dc.w	105,6,1,0,0
	dc.w	106,2,1,0,0
	dc.w	107,1,1,0,0
	dc.w	108,6,5,0,0
	dc.w	109,0,0,0,0
	dc.w	110,0,1,1,0
	dc.w	111,0,1,0,0
	dc.w	112,2,1,0,1
	dc.w	113,2,1,1,0
	dc.w	114,1,1,1,0

	dcb.w	5*5,0

	dc.w	120,0,1,2,0
	dc.w	121,3,1,2,0
	dc.w	122,1,1,1,0
	dc.w	123,1,1,1,0
	dc.w	124,0,1,1,0
	dc.w	125,0,0,1,1

	dc.w	126,0,0,0,0
	dc.w	127,0,0,0,0
	dc.w	128,0,0,0,0
	dc.w	129,0,0,0,0
	dc.w	130,1,5,0,0
	text