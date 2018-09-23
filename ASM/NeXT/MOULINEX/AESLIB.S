
* AES Library Copyright (C) HiSoft 1988
* this MUST be assembled to either executable or GST linkable, NOT DRI code

* sets section order to TEXT,DATA,BSS

* the actual calling of the AES

	MODULE	LowLevelAES

	XDEF	CALL_AES,control,global,int_in,int_out
	XDEF	addr_in,addr_out,aes_params

	SECTION	TEXT
* call an AES routine
* in:	d0.w=AES function number
* out	d0.w=int_out value
* uses	d0-d2/a0-a2
* (assumes control4 needs to be zero)

CALL_AES	lea	control,a1
	move.w	d0,(a1)+			store the op code
	sub.w	#10,d0
	mulu	#3,d0
	move.l	#gem_ctrl_list,a0
	add.w	d0,a0			points to the entry
	moveq	#0,d0
	move.b	(a0)+,d0
	move.w	d0,(a1)+		do control1
	move.b	(a0)+,d0
	move.w	d0,(a1)+		and control2
	move.b	(a0)+,d0
	move.w	d0,(a1)+		and control3
	clr.w	(a1)			assumes control4=0 (all except RSRC_GADDR)
	move.l	#aes_params,d1
	move.w	#200,d0			function number
	trap	#2
	move.w	int_out,d0		usually a returned value
	rts

* this is a table of pointers to all the AES arrays
aes_params	dc.l	control,global,int_in,int_out,addr_in,addr_out

* this is the list of Control parameters for the AES calls
* contains control(1..3), comment is the function number
* (an asterisk indicates it is not defined)
gem_ctrl_list
	dc.b	0,1,0	10
	dc.b	2,1,1	11
	dc.b	2,1,1	12
	dc.b	0,1,1	13
	dc.b	2,1,1	14
	dc.b	1,1,1	15
	dc.b	0,0,0	16*
	dc.b	0,0,0	17*
	dc.b	0,0,0	18*
	dc.b	0,1,0	19
	dc.b	0,1,0	20
	dc.b	3,5,0	21
	dc.b	5,5,0	22
	dc.b	0,1,1	23
	dc.b	2,1,0	24
	dc.b	16,7,1	25
	dc.b	2,1,0	26
	dc.b	0,0,0	27*
	dc.b	0,0,0	28*
	dc.b	0,0,0	29*
	dc.b	1,1,1	30
	dc.b	2,1,1	31
	dc.b	2,1,1	32
	dc.b	2,1,1	33
	dc.b	1,1,2	34
	dc.b	1,1,1	35
	dc.b	0,0,0	36*
	dc.b	0,0,0	37*
	dc.b	0,0,0	38*
	dc.b	0,0,0	39*
	dc.b	2,1,1	40
	dc.b	1,1,1	41
	dc.b	6,1,1	42
	dc.b	4,1,1	43
	dc.b	1,3,1	44
	dc.b	2,1,1	45
	dc.b	4,2,1	46
	dc.b	8,1,1	47
	dc.b	0,0,0	48*
	dc.b	0,0,0	49*
	dc.b	1,1,1	50
	dc.b	9,1,0	51
	dc.b	1,1,1	52
	dc.b	1,1,0	53
	dc.b	0,5,1	54
	dc.b	0,0,0	55*
	dc.b	0,0,0	56*
	dc.b	0,0,0	57*
	dc.b	0,0,0	58*
	dc.b	0,0,0	59*
	dc.b	0,0,0	60*
	dc.b	0,0,0	61*
	dc.b	0,0,0	62*
	dc.b	0,0,0	63*
	dc.b	0,0,0	64*
	dc.b	0,0,0	65*
	dc.b	0,0,0	66*
	dc.b	0,0,0	67*
	dc.b	0,0,0	68*
	dc.b	0,0,0	69*
	dc.b	4,3,0	70
	dc.b	8,3,0	71
	dc.b	6,1,0	72
	dc.b	8,1,0	73
	dc.b	8,1,0	74
	dc.b	4,1,1	75
	dc.b	3,1,1	76
	dc.b	0,5,0	77
	dc.b	1,1,1	78
	dc.b	0,5,0	79
	dc.b	0,1,1	80
	dc.b	0,1,1	81
	dc.b	0,0,0	82*
	dc.b	0,0,0	83*
	dc.b	0,0,0	84*
	dc.b	0,0,0	85*
	dc.b	0,0,0	86*
	dc.b	0,0,0	87*
	dc.b	0,0,0	88*
	dc.b	0,0,0	89*
	dc.b	0,2,2	90
	dc.b	0,0,0	91*
	dc.b	0,0,0	92*
	dc.b	0,0,0	93*
	dc.b	0,0,0	94*
	dc.b	0,0,0	95*
	dc.b	0,0,0	96*
	dc.b	0,0,0	97*
	dc.b	0,0,0	98*
	dc.b	0,0,0	99*
	dc.b	5,1,0	100
	dc.b	5,1,0	101
	dc.b	1,1,0	102
	dc.b	1,1,0	103
	dc.b	2,5,0	104
	dc.b	6,1,0	105
	dc.b	2,1,0	106
	dc.b	1,1,0	107
	dc.b	6,5,0	108
	dc.b	0,0,0	109*
	dc.b	0,1,1	110
	dc.b	0,1,0	111
	dc.b	2,1,0	112 ** Control(4)=1 **
	dc.b	2,1,1	113
	dc.b	1,1,1	114
	dc.b	0,0,0	115
	dc.b	0,0,0	116
	dc.b	0,0,0	117
	dc.b	0,0,0	118
	dc.b	0,0,0	119
	dc.b	0,1,2	120
	dc.b	3,1,2	121
	dc.b	0,0,0	122*
	dc.b	0,0,0	123*
	dc.b	0,1,1	124
	dc.b	0,1,3	125
	even

* these don't need initialising so can go in the BSS section
control		ds.w	4
global		ds.w	14
int_in		ds.w	16
int_out		ds.w	7
addr_in		ds.l	2
addr_out	ds.l	1


*********** END OF AES *****************

