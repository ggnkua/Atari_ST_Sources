***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Wykres III - 48 stopniowy wykres do muzyki analogowej     *
* autor      :  Van Eijk                                                  *
* inne uwagi :  640x200 !!!                                               *
***************************************************************************

H	EQU		15*160+0+32
H1	EQU		15*160+32+32
H2	EQU		15*160+64+32

SUPER:
		clr.l	-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp

		move.w	#1,-(sp)
		move.l	#$78000,-(sp)
		move.l	#$78000,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.b	#255,$484

		jsr		MUSIC

		move.b	#1,V0
		move.b	#1,V1
		move.b	#1,V2
		move.b	#1,V3
		move.b	#1,V4
		move.b	#1,V5
		move.b	#1,V6
		move.b	#1,V7
		move.b	#1,V8
		move.b	#1,V9
		move.b	#1,V10
		move.b	#1,V11
		move.b	#1,V12
		move.b	#1,V13
		move.b	#1,V14
		move.b	#1,V15
		move.b	#1,VA0
		move.b	#1,VA1
		move.b	#1,VA2
		move.b	#1,VA3
		move.b	#1,VA4
		move.b	#1,VA5
		move.b	#1,VA6
		move.b	#1,VA7
		move.b	#1,VA8
		move.b	#1,VA9
		move.b	#1,VA10
		move.b	#1,VA11
		move.b	#1,VA12
		move.b	#1,VA13
		move.b	#1,VA14
		move.b	#1,VA15
		move.b	#1,VB0
		move.b	#1,VB1
		move.b	#1,VB2
		move.b	#1,VB3
		move.b	#1,VB4
		move.b	#1,VB5
		move.b	#1,VB6
		move.b	#1,VB7
		move.b	#1,VB8
		move.b	#1,VB9
		move.b	#1,VB10
		move.b	#1,VB11
		move.b	#1,VB12
		move.b	#1,VB13
		move.b	#1,VB14
		move.b	#1,VB15
		move.w	#$000,$fff8240
		move.w	#$fff,$fff8242

		move.l	$70,PAM
		move.l	#VBL,$70

*-------------------------------------------------------------------------*

B:		bra		B

END:	move.l	PAM,$70
		jsr		MUSIC+4
		move.b	#255,$484
		move.w	#$fff,$fff8240
		move.w	#$000,$fff8242
		clr.l	-(sp)
		trap	#1

*-------------------------------------------------------------------------*

VBL:	cmp.b	#57,$fffc02
		beq		END
		movem.l	a0-a6/d0-d7,-(sp)
		jsr		WYKRES
		movem.l	(sp)+,a0-a6/d0-d7
		movem.l	a0-a6/d0-d7,-(sp)
		jsr		MUSIC+8
		movem.l	(sp)+,a0-a6/d0-d7
		rte

*-------------------------------------------------------------------------*

WYKRES:	clr.w	d0
		move.b	#8,$fff8800
		move.b	$fff8800,d0
		jsr		ZBADAJ1
		clr.w	d0
		move.b	#9,$fff8800
		move.b	$fff8800,d0
		jsr		ZBADAJ2
		clr.w	d0
		move.b	#10,$fff8800
		move.b	$fff8800,d0
		jsr		ZBADAJ3
		jsr		RYSUJ
		rts

ZBADAJ1:cmp.b	#0,d0
		bne		H0
		move.b	#32,V0
		bra		H15
H0:		cmp.b	#1,d0
		bne		HF1
		move.b	#32,V1
		bra		H15
HF1:	cmp.b	#2,d0
		bne		HF2
		move.b	#32,V2
		bra		H15
HF2:	cmp.b	#3,d0
		bne		H3
		move.b	#32,V3
		bra		H15
H3:		cmp.b	#4,d0
		bne		H4
		move.b	#32,V4
		bra		H15
H4:		cmp.b	#5,d0
		bne		H5
		move.b	#32,V5
		bra		H15
H5:		cmp.b	#6,d0
		bne		H6
		move.b	#32,V6
		bra		H15
H6:		cmp.b	#7,d0
		bne		H7
		move.b	#32,V7
		bra		H15
H7:		cmp.b	#8,d0
		bne		H8
		move.b	#32,V8
		bra		H15
H8:		cmp.b	#9,d0
		bne		H9
		move.b	#32,V9
		bra		H15
H9:		cmp.b	#10,d0
		bne		H10
		move.b	#32,V10
		bra		H15
H10:	cmp.b	#11,d0
		bne		H11
		move.b	#32,V11
		bra		H15
H11:	cmp.b	#12,d0
		bne		H12
		move.b	#32,V12
		bra		H15
H12:	cmp.b	#13,d0
		bne		H13
		move.b	#32,V13
		bra		H15
H13:	cmp.b	#14,d0
		bne		H14
		move.b	#32,V14
		bra		H15
H14:	cmp.b	#15,d0
		bne		H15
		move.b	#32,V15
		bra		H15
H15:	rts

ZBADAJ2:cmp.b	#0,d0
		bne		HA0
		move.b	#32,VA0
		bra		HA15
HA0:	cmp.b	#1,d0
		bne		HA1
		move.b	#32,VA1
		bra		HA15
HA1:	cmp.b	#2,d0
		bne		HA2
		move.b	#32,VA2
		bra		HA15
HA2:	cmp.b	#3,d0
		bne		HA3
		move.b	#32,VA3
		bra		HA15
HA3:	cmp.b	#4,d0
		bne		HA4
		move.b	#32,VA4
		bra		HA15
HA4:	cmp.b	#5,d0
		bne		HA5
		move.b	#32,VA5
		bra		HA15
HA5:	cmp.b	#6,d0
		bne		HA6
		move.b	#32,VA6
		bra		HA15
HA6:	cmp.b	#7,d0
		bne		HA7
		move.b	#32,VA7
		bra		HA15
HA7:	cmp.b	#8,d0
		bne		HA8
		move.b	#32,VA8
		bra		HA15
HA8:	cmp.b	#9,d0
		bne		HA9
		move.b	#32,VA9
		bra		HA15
HA9:	cmp.b	#10,d0
		bne		HA10
		move.b	#32,VA10
		bra		HA15
HA10:	cmp.b	#11,d0
		bne		HA11
		move.b	#32,VA11
		bra		HA15
HA11:	cmp.b	#12,d0
		bne		HA12
		move.b	#32,VA12
		bra		HA15
HA12:	cmp.b	#13,d0
		bne		HA13
		move.b	#32,VA13
		bra		HA15
HA13:	cmp.b	#14,d0
		bne		HA14
		move.b	#32,VA14
		bra		HA15
HA14:	cmp.b	#15,d0
		bne		HA15
		move.b	#32,VA15
HA15:	rts

ZBADAJ3:cmp.b	#0,d0
		bne		HB0
		move.b	#32,VB0
		bra		HB15
HB0:	cmp.b	#1,d0
		bne		HB1
		move.b	#32,VB1
		bra		HB15
HB1:	cmp.b	#2,d0
		bne		HB2
		move.b	#32,VB2
		bra		HB15
HB2:	cmp.b	#3,d0
		bne		HB3
		move.b	#32,VB3
		bra		HB15
HB3:	cmp.b	#4,d0
		bne		HB4
		move.b	#32,VB4
		bra		HB15
HB4:	cmp.b	#5,d0
		bne		HB5
		move.b	#32,VB5
		bra		HB15
HB5:	cmp.b	#6,d0
		bne		HB6
		move.b	#32,VB6
		bra		HB15
HB6:	cmp.b	#7,d0
		bne		HB7
		move.b	#32,VB7
		bra		HB15
HB7:	cmp.b	#8,d0
		bne		HB8
		move.b	#32,VB8
		bra		HB15
HB8:	cmp.b	#9,d0
		bne		HB9
		move.b	#32,VB9
		bra		HB15
HB9:	cmp.b	#10,d0
		bne		HB10
		move.b	#32,VB10
		bra		HB15
HB10:	cmp.b	#11,d0
		bne		HB11
		move.b	#32,VB11
		bra		HB15
HB11:	cmp.b	#12,d0
		bne		HB12
		move.b	#32,VB12
		bra		HB15
HB12:	cmp.b	#13,d0
		bne		HB13
		move.b	#32,VB13
		bra		HB15
HB13:	cmp.b	#14,d0
		bne		HB14
		move.b	#32,VB14
		bra		HB15
HB14:	cmp.b	#15,d0
		bne		HB15
		move.b	#32,VB15
HB15:	rts

RYSUJ:	sub.b	#1,V0
		sub.b	#1,V1
		sub.b	#1,V2
		sub.b	#1,V3
		sub.b	#1,V4
		sub.b	#1,V5
		sub.b	#1,V6
		sub.b	#1,V7
		sub.b	#1,V8
		sub.b	#1,V9
		sub.b	#1,V10
		sub.b	#1,V11
		sub.b	#1,V12
		sub.b	#1,V13
		sub.b	#1,V14
		sub.b	#1,V15
		sub.b	#1,VA0
		sub.b	#1,VA1
		sub.b	#1,VA2
		sub.b	#1,VA3
		sub.b	#1,VA4
		sub.b	#1,VA5
		sub.b	#1,VA6
		sub.b	#1,VA7
		sub.b	#1,VA8
		sub.b	#1,VA9
		sub.b	#1,VA10
		sub.b	#1,VA11
		sub.b	#1,VA12
		sub.b	#1,VA13
		sub.b	#1,VA14
		sub.b	#1,VA15
		sub.b	#1,VB0
		sub.b	#1,VB1
		sub.b	#1,VB2
		sub.b	#1,VB3
		sub.b	#1,VB4
		sub.b	#1,VB5
		sub.b	#1,VB6
		sub.b	#1,VB7
		sub.b	#1,VB8
		sub.b	#1,VB9
		sub.b	#1,VB10
		sub.b	#1,VB11
		sub.b	#1,VB12
		sub.b	#1,VB13
		sub.b	#1,VB14
		sub.b	#1,VB15
Q0:		cmp.b	#0,V0
		bne		Q1
		move.b	#1,V0	
Q1:		cmp.b	#0,V1
		bne		Q2
		move.b	#1,V1	
Q2:		cmp.b	#0,V2
		bne		Q3
		move.b	#1,V2	
Q3:		cmp.b	#0,V3
		bne		Q4
		move.b	#1,V3	
Q4:		cmp.b	#0,V4
		bne		Q5
		move.b	#1,V4	
Q5:		cmp.b	#0,V5
		bne		Q6
		move.b	#1,V5	
Q6:		cmp.b	#0,V6
		bne		Q7
		move.b	#1,V6	
Q7:		cmp.b	#0,V7
		bne		Q8
		move.b	#1,V7	
Q8:		cmp.b	#0,V8
		bne		Q9
		move.b	#1,V8	
Q9:		cmp.b	#0,V9
		bne		Q10
		move.b	#1,V9	
Q10:	cmp.b	#0,V10
		bne		Q11
		move.b	#1,V10
Q11:	cmp.b	#0,V11
		bne		Q12
		move.b	#1,V11
Q12:	cmp.b	#0,V12
		bne		Q13
		move.b	#1,V12
Q13:	cmp.b	#0,V13
		bne		Q14
		move.b	#1,V13
Q14:	cmp.b	#0,V14
		bne		Q15
		move.b	#1,V14
Q15:	cmp.b	#0,V15
		bne		Q16
		move.b	#1,V15
Q16:	clr.w	d0
		cmp.b	#0,VA0
		bne		QA1
		move.b	#1,VA0	
QA1:	cmp.b	#0,VA1
		bne		QA2
		move.b	#1,VA1	
QA2:	cmp.b	#0,VA2
		bne		QA3
		move.b	#1,VA2	
QA3:	cmp.b	#0,VA3
		bne		QA4
		move.b	#1,VA3	
QA4:	cmp.b	#0,VA4
		bne		QA5
		move.b	#1,VA4	
QA5:	cmp.b	#0,VA5
		bne		QA6
		move.b	#1,VA5	
QA6:	cmp.b	#0,VA6
		bne		QA7
		move.b	#1,VA6	
QA7:	cmp.b	#0,VA7
		bne		QA8
		move.b	#1,VA7	
QA8:	cmp.b	#0,VA8
		bne		QA9
		move.b	#1,VA8	
QA9:	cmp.b	#0,VA9
		bne		QA10
		move.b	#1,VA9	
QA10:	cmp.b	#0,VA10
		bne		QA11
		move.b	#1,VA10
QA11:	cmp.b	#0,VA11
		bne		QA12
		move.b	#1,VA11
QA12:	cmp.b	#0,VA12
		bne		QA13
		move.b	#1,VA12
QA13:	cmp.b	#0,VA13
		bne		QA14
		move.b	#1,VA13
QA14:	cmp.b	#0,VA14
		bne		QA15
		move.b	#1,VA14
QA15:	cmp.b	#0,VA15
		bne		QA16
		move.b	#1,VA15
QA16:	clr.w	d0
		cmp.b	#0,VB0
		bne		QB1
		move.b	#1,VB0	
QB1:	cmp.b	#0,VB1
		bne		QB2
		move.b	#1,VB1	
QB2:	cmp.b	#0,VB2
		bne		QB3
		move.b	#1,VB2	
QB3:	cmp.b	#0,VB3
		bne		QB4
		move.b	#1,VB3	
QB4:	cmp.b	#0,VB4
		bne		QB5
		move.b	#1,VB4	
QB5:	cmp.b	#0,VB5
		bne		QB6
		move.b	#1,VB5	
QB6:	cmp.b	#0,VB6
		bne		QB7
		move.b	#1,VB6	
QB7:	cmp.b	#0,VB7
		bne		QB8
		move.b	#1,VB7	
QB8:	cmp.b	#0,VB8
		bne		QB9
		move.b	#1,VB8	
QB9:	cmp.b	#0,VB9
		bne		QB10
		move.b	#1,VB9	
QB10:	cmp.b	#0,VB10
		bne		QB11
		move.b	#1,VB10
QB11:	cmp.b	#0,VB11
		bne		QB12
		move.b	#1,VB11
QB12:	cmp.b	#0,VB12
		bne		QB13
		move.b	#1,VB12
QB13:	cmp.b	#0,VB13
		bne		QB14
		move.b	#1,VB13
QB14:	cmp.b	#0,VB14
		bne		QB15
		move.b	#1,VB14
QB15:	cmp.b	#0,VB15
		bne		QB16
		move.b	#1,VB15
QB16:	clr.w	d0

		move.l	#$78000+8000+H,a0
		move.b	V0,d0
AV00:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV00
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8001+H,a0
		move.b	V1,d0
AV01:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV01		
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8004+H,a0
		move.b	V2,d0
AV02:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV02
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8005+H,a0
		move.b	V3,d0
AV03:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV03	
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8008+H,a0
		move.b	V4,d0
AV04:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV04		
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8009+H,a0
		move.b	V5,d0
AV05:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV05		
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8012+H,a0
		move.b	V6,d0
AV06:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV06		
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8013+H,a0
		move.b	V7,d0
AV07:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV07		
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8016+H,a0
		move.b	V8,d0
AV08:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV08		
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8017+H,a0
		move.b	V9,d0
AV09:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV09		
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8020+H,a0
		move.b	V10,d0
AV10:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV10		
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8021+H,a0
		move.b	VA11,d0
AV11:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV11		
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8024+H,a0
		move.b	V12,d0
AV12:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV12		
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8025+H,a0
		move.b	V13,d0
AV13:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV13		
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8028+H,a0
		move.b	V14,d0
AV14:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV14		
		move.b  #%00000000,(a0)
		clr.w	d0
		move.l	#$78000+8029+H,a0
		move.b	V15,d0
AV15:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AV15		
		move.b  #%00000000,(a0)



		clr.w	d0
		move.l	#$78000+8000+H1,a0
		move.b	VA0,d0
AVA00:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA00
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8001+H1,a0
		move.b	VA1,d0
AVA01:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA01		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8004+H1,a0
		move.b	VA2,d0
AVA02:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA02
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8005+H1,a0
		move.b	VA3,d0
AVA03:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA03		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8008+H1,a0
		move.b	VA4,d0
AVA04:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA04		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8009+H1,a0
		move.b	VA5,d0
AVA05:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA05		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8012+H1,a0
		move.b	VA6,d0
AVA06:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA06		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8013+H1,a0
		move.b	VA7,d0
AVA07:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA07		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8016+H1,a0
		move.b	VA8,d0
AVA08:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA08		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8017+H1,a0
		move.b	VA9,d0
AVA09:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA09		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8020+H1,a0
		move.b	VA10,d0
AVA10:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA10		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8021+H1,a0
		move.b	VA11,d0
AVA11:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA11		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8024+H1,a0
		move.b	VA12,d0
AVA12:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA12		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8025+H1,a0
		move.b	VA13,d0
AVA13:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA13		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8028+H1,a0
		move.b	VA14,d0
AVA14:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA14		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8029+H1,a0
		move.b	VA15,d0
AVA15:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVA15		
		move.b  #0,(a0)

		clr.w	d0
		move.l	#$78000+8000+H2,a0
		move.b	VB0,d0
AVB00:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB00
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8001+H2,a0
		move.b	VB1,d0
AVB01:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB01		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8004+H2,a0
		move.b	VB2,d0
AVB02:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB02
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8005+H2,a0
		move.b	VB3,d0
AVB03:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB03		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8008+H2,a0
		move.b	VB4,d0
AVB04:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB04		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8009+H2,a0
		move.b	VB5,d0
AVB05:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB05		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8012+H2,a0
		move.b	VB6,d0
AVB06:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB06		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8013+H2,a0
		move.b	VB7,d0
AVB07:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB07		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8016+H2,a0
		move.b	VB8,d0
AVB08:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB08		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8017+H2,a0
		move.b	VB9,d0
AVB09:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB09		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8020+H2,a0
		move.b	VB10,d0
AVB10:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB10		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8021+H2,a0
		move.b	VB11,d0
AVB11:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB11		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8024+H2,a0
		move.b	VB12,d0
AVB12:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB12		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8025+H2,a0
		move.b	VB13,d0
AVB13:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB13		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8028+H2,a0
		move.b	VB14,d0
AVB14:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB14		
		move.b  #0,(a0)
		clr.w	d0
		move.l	#$78000+8029+H2,a0
		move.b	VB15,d0
AVB15:	move.b	#%11111110,(a0)
		sub.w	#320,a0
		dbf		d0,AVB15		
		move.b  #0,(a0)
		clr.w	d0
		rts

*-------------------------------------------------------------------------*

V0:		dc.b	1
V1:		dc.b	1
V2:		dc.b	1
V3:		dc.b	1
V4:		dc.b	1
V5:		dc.b	1
V6:		dc.b	1
V7:		dc.b	1
V8:		dc.b	1
V9:		dc.b	1
V10:	dc.b	1
V11:	dc.b	1
V12:	dc.b	1
V13:	dc.b	1
V14:	dc.b	1
V15:	dc.b	1
VA0:	dc.b	1
VA1:	dc.b	1
VA2:	dc.b	1
VA3:	dc.b	1
VA4:	dc.b	1
VA5:	dc.b	1
VA6:	dc.b	1
VA7:	dc.b	1
VA8:	dc.b	1
VA9:	dc.b	1
VA10:	dc.b	1
VA11:	dc.b	1
VA12:	dc.b	1
VA13:	dc.b	1
VA14:	dc.b	1
VA15:	dc.b	1
VB0:	dc.b	1
VB1:	dc.b	1
VB2:	dc.b	1
VB3:	dc.b	1
VB4:	dc.b	1
VB5:	dc.b	1
VB6:	dc.b	1
VB7:	dc.b	1
VB8:	dc.b	1
VB9:	dc.b	1
VB10:	dc.b	1
VB11:	dc.b	1
VB12:	dc.b	1
VB13:	dc.b	1
VB14:	dc.b	1
VB15:	dc.b	1
PAM:	dc.l	1
MUSIC:	incbin	"A:ASEMBLER.S\DANE.DAT\JESS001.MUS"
		even
