;	Ritar en cirkel med float sinus rutiner

	move.w	#0,-(sp)	; Fixa lÜgupplîÑsning
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#2,-(sp)	; HÑmta physic
	trap	#14
	addq.l	#2,sp
	move.l	d0,physic

	move.l	#90,d1		; BerÑkna radien till float
	move	#$e,d0
	trap	#6
	move.l	d0,radie_fl
	move.l	d1,radie_fl+4

	move.l	#0,vinkel	; Bîrja pÜ noll vinkel

loopa	move.l	vinkel,d1	; Konva ett tal till float (vinkel att kalka)
	move	#$e,d0
	trap	#6

	move.l	rad_tal,d3	; Gîr om grader till radianer
	move.l	rad_tal+4,d4
	move.l	d1,d2
	move.l	d0,d1
	move.w	#3,d0
	trap	#6
	move.l	d0,vinkel_grad
	move.l	d1,vinkel_grad+4

	bsr	visa_fl			; Visa vinkeln som radianer

	move.l	vinkel_grad+4,d2	; Calka sinus
	move.l	vinkel_grad,d1
	move.w	#4,d0
	trap	#6

	move.l	d1,d2		; Multiplicera me radien
	move.l	d0,d1
	move.l	radie_fl,d3
	move.l	radie_fl+4,d4
	move.w	#2,d0
	trap	#6

	move.l	d1,d2		; Gîr om till integer
	move.l	d0,d1
	move.w	#$D,d0
	trap	#6

	add.l	#100,d0
	move.w	d0,y		; Y vÑrde

	move.l	vinkel_grad,d1		; Calka cosinus
	move.l	vinkel_grad+4,d2
	move.w	#5,d0
	trap	#6

	move.l	d1,d2		; Multiplicera me radien
	move.l	d0,d1
	move.l	radie_fl,d3
	move.l	radie_fl+4,d4
	move.w	#2,d0
	trap	#6

	move.l	d1,d2		; Gîr om till integer
	move.l	d0,d1
	move.w	#$D,d0
	trap	#6

	add.l	#160,d0
	move.w	d0,x		; X vÑrde

	move.w	x,d0		; SÑtt ut en prick pÜ X,Y
	move.w	y,d1
	move.w	#3,d2
	move.l	physic,a0
	bsr	prick

	add.l	#1,vinkel
	cmp.l	#361,vinkel	; Kîr alla 360 grader
	blt	loopa
	
	move.w	#7,-(sp)	; VÑnta pÜ knapp
	trap	#1
	addq.l	#2,sp

	clr.w	-(sp)		; HejdÜ
	trap	#1

visa_fl	move.l	d1,d2		; Rutin fîr att visa float tal i d0-d1
	move.l	d0,d1
	move.w	#$c,d0
	move.w	#30,d3
	move.l	#buf,a0
	trap	#6

	move.l	#buf1,-(sp)	; Visa strÑng
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	rts

prick	mulu	#$a0,d1		; SÑtter ut en prick d0,d1 med fÑrg d2
	move.w	d0,d3		; Adress i a0
	lsr.w	#1,d3 
	and.w	#-8,d3
	add.w	d3,d1 
	adda.w	d1,a0 
	and.w	#$f,d0
	neg.w	d0
	add.w	#$f,d0
	moveq	#3,d3 
nÑsta_bitplan
	move.w	(a0),d1 
	lsr.w	#1,d2 
	bcs.s	nolla 
	bclr	d0,d1 
	bra.s	Ñndra_bitplan
nolla	bset	d0,d1 
Ñndra_bitplan
	move.w	d1,(a0)+
	dbf	d3,nÑsta_bitplan
	
	rts

; Visa ett tal i d0 som hex (.l)

showhex	move.l	#hextext+9,a0
	move.w	#7,d2		; 8 tecken
nexthex	move.l	d0,d1		; kom ihÜg d0
	and.l	#%1111,d0	; Bara de 4 lÑgsta bitarna

	add.b	#48,d0		; ôka till siffrorna

	cmp.b	#58,d0		; ér det en siffra?
	blt	decimal_hex	; Ja

	add.b	#39,d0		; LÑgg till lite till sÜ det blir abcdef

decimal_hex
	move.b	d0,-(a0)	; LÑgg in tecknet

	move.l	d1,d0		; èterstÑll d0
	ror.l	#4,d0		; Rulla bitarna 4 steg hîger
	dbra	d2,nexthex	; LÑgg in alla 8 tecken

	move.l	#hextext,-(sp)	; Visa strÑngen
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	rts

hextext dc.b	'$        ',10,13,0

x	dc.w	0
y	dc.w	0
vinkel	dc.l	0
physic	dc.l	0
vinkel_grad 	ds.l	2
rad_tal		dc.l	$e52ee046,$12345678
radie_fl 	ds.l	2

buf1	dc.b	27,'b',3,27,'H'
buf	ds.b	100
