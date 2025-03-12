***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Wykres 1 - 16 poziomowy wykres do muzyki analogowej       *
* autor      :  Van Eijk                                                  *
* inne uwagi :  320x200 !!!                                               *
***************************************************************************

H	EQU		24000

SUPER:
		clr.l	-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp

		move.w	#0,-(sp)
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
		jsr		ZBADAJ
		clr.w	d0
		move.b	#9,$fff8800
		move.b	$fff8800,d0
		jsr		ZBADAJ
		clr.w	d0
		move.b	#10,$fff8800
		move.b	$fff8800,d0
		jsr		ZBADAJ
		jsr		RYSUJ
		rts

ZBADAJ:	cmp.b	#0,d0
		bne		H0
		move.b	#32,V0
		bra		H15
H0:		cmp.b	#1,d0
		bne		H1
		move.b	#32,V1
		bra		H15
H1:		cmp.b	#2,d0
		bne		H2
		move.b	#32,V2
		bra		H15
H2:		cmp.b	#3,d0
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
		move.l	#$78000+8016+H,a0
		move.b	V0,d0
AV00:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV00
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8024+H,a0
		move.b	V1,d0
AV01:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV01		
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8032+H,a0
		move.b	V2,d0
AV02:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV02
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8040+H,a0
		move.b	V3,d0
AV03:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV03		
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8048+H,a0
		move.b	V4,d0
AV04:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV04		
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8056+H,a0
		move.b	V5,d0
AV05:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV05		
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8064+H,a0
		move.b	V6,d0
AV06:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV06		
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8072+H,a0
		move.b	V7,d0
AV07:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV07		
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8080+H,a0
		move.b	V8,d0
AV08:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV08		
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8088+H,a0
		move.b	V9,d0
AV09:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV09		
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8096+H,a0
		move.b	V10,d0
AV10:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV10		
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8104+H,a0
		move.b	V11,d0
AV11:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV11		
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8112+H,a0
		move.b	V12,d0
AV12:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV12		
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8120+H,a0
		move.b	V13,d0
AV13:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV13		
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8128+H,a0
		move.b	V14,d0
AV14:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV14		
		move.w  #%0000000000000000,(a0)
		clr.w	d0
		move.l	#$78000+8136+H,a0
		move.b	V15,d0
AV15:	move.w	#%1111111111111100,(a0)
		sub.w	#320,a0
		dbf		d0,AV15		
		move.w  #%0000000000000000,(a0)
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
PAM:	dc.l	1
MUSIC:	incbin	"A:ASEMBLER.S\DANE.DAT\JESS001.MUS"
		even
