;	CAPTU
;	charge et lance
;	captu.bin


debut:
	lea	tx1,A0
	jsr	print_line
	jsr	read_line
	tst	D0
	beq	quit
	lea	$20000-16,A0
	jsr	copy_line

	lea	tx2,A0
	jsr	print_line
	jsr	read_line
	tst	D0
	beq	pterm
	lea	$20000-32,A0
	jsr	copy_line

	move.l	#tx3,D0
	move.l	#$20000,D1
	move.l	#80000,D2
	jsr	read

	lea	txf,A0
	jsr	print_line
stop:	nop

	jmp	$20000
copy_line:
	lea	buffer+2,A1
b_cop:
	move.b	(A1)+,(A0)+
	bne	b_cop
	rts
quit:
	nop
pterm:
	clr	-(A7)
	trap	#1
read:
; D0 adresse nom de fichier
; D1 adresse memoire
; D2 nombre de bytes
	movem.l	D1-D3/A0,-(A7)
	move	#2,-(A7)
	move.l	D0,-(A7)
	move	#$3D,-(A7)
	trap	#1
	addq	#8,A7
	move	D0,D5
	bmi	error
	move.l	D1,-(A7)
	move.l	D2,-(A7)
	move	D5,-(A7)
	move	#$3F,-(A7)
	trap	#1
	add.l	#12,A7
	move.l	D0,D3
	move	D5,-(A7)
	move	#$3E,-(A7)
	trap	#1
	addq	#4,A7
	move.l	D3,D0
	bra	quit_read
error:	moveq	#0,D0
quit_read:
	movem.l	(A7)+,D1-D3/A0
	rts
write:
; D0 adresse nom de fichier
; D1 adresse memoire
; D2 nombre de bytes
	movem.l	D1-D2/A0,-(A7)
	move	#0,-(A7)
	move.l	D0,-(A7)
	move	#$3C,-(A7)
	trap	#1
	addq	#8,A7
	move	D0,D5
	move.l	D1,-(A7)
	move.l	D2,-(A7)
	move	D5,-(A7)
	move	#$40,-(A7)
	trap	#1
	add.l	#12,	A7
	move	D5,-(A7)
	move	#$3E,-(A7)
	trap	#1
	addq	#4,A7
	movem.l	(A7)+,D1-D2/A0
	rts
print_line:
	move.l	A0,-(A7)
	move	#9,-(A7)
	trap	#1
	addq	#6,A7
	rts
conout:
	move	D0,-(A7)
	move	#$2,-(A7)
	trap	#1
	addq	#4,A7
	rts
read_line:
	pea	buffer
	move	#$0A,-(A7)
	trap	#1
	addq	#6,A7
	lea	buffer+2,A0
	clr.b	0(A0,D0.w)
	move	D0,-(A7)
	move	#$0A,D0
	bsr.s	conout
	move	(A7)+,D0
	rts
buffer:	dc.b	20,0
	blk.b	20
longueur:
	dc.l	0
tx1:	dc.b	"CAPTU",13,10
	dc.b	"Ecran PI1 ?"
	dc.b	13,10,0
	even
tx2:	dc.b	"Objet ?"
	dc.b	9,13,10,0
	even
tx3:	dc.b	"CAPTU.BIN",0
	even
txf:	dc.b	27,"f",0
	even
fin:
