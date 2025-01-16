; The Voice5
; TFTE
*********************************
* Procedura relokacyjna			*
* Relokacja na podstawie tabeli *
* relokacji na poczatku programu*
*********************************
* Greetsy dla YOYO'a i Axla		*
*********************************



	opt p+
relocate:
	lea program(pc),a0
	move.l 2(a0),d0
	add.l 6(a0),d0
	add.l 14(a0),d0
	add.l #$1c,a0
	move.l a0,a1
	move.l a1,a2
	move.l a0,d1	; prg +1c
	add.l d0,a1
	move.l (a1)+,d0
	add.l d0,a2
	add.l d1,(a2)
	clr.l d0
mrelo
	move.b (a1)+,d0
	beq mrelend
	cmp.b #1,d0
	beq jump
	add.l d0,a2
	add.l d1,(a2)
	bra mrelo
jump	
	add.l #254,a2
	bra mrelo
mrelend
	bra program

program
	incbin v_l.prg		; tu jakis program
