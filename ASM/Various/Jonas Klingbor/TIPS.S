*** H„r kommer lite tips f”r att g”ra snabba rutiner! ***

Ist„llet f”r att g”ra loopar som flyttar saker p† sk„rmen,
ska du skriva ut alla move:s p† en l†ng lista!
Man skall †tminstone ha sis†d„r 20-30 moves innan man g”r en loop!


ex 1. (s† skall man inte g”ra!)

	move.l	#2000,d7

LOOP	move.w	(a0),(a1)
	addq.l	#8,a0
	addq.l	#8,a1
	dbf	d7,LOOP


ex 2. (s† skall man g”ra!)

	move.w	#30,d7

LOOP	move.w	(a0),(a1)
	move.w	8(a0),8(a1)
	move.w	16(a0),16(a1)
	move.w	24(a0),24(a1)
	osv

	lea	160(a0),a0
	lea	160(a1),a1

	dbf	d7,LOOP

*****

F”rs”k att anv„nda LEA p† alla st„llen det g†r!
Det „r mycket, mycket snabbare „n MOVE!
LEA kan visserligen bara anv„ndas till adress-registrena (a0-a6)
men d† kan man anv„nda det till att subtrahera, addera och flytta
till ett adress-register!

ex

	lea	KALLE,a0	flytta adress till A0
	lea	$ff8240,a0	samma sak!

	lea	10(a0),a0	addera 10 till a0
	lea	-15(a0),a0	subtrahera 15 fr†n a0

Dock „r det snabbare att anv„nda addq och subq men d† f†r inte
talet ”verstiga 8!

	addq.l	#8,a0	snabbare „n LEA
	addq.l	#9,a0	s† h„r f†r man inte g”ra, m†ste anv„nda LEA!
	

**** 

Att anv„nda Multiplikation tar 70 processorcykler och 
division tar 140 (!) processor cykler!
Men vill man mul el div med 2,4,8,16 osv kan man anv„nda SHIFT! (LSL, LSR)

ex
	lsl.l	#1,d0	mul. d0 med 2
	lsl.l	#2,d0	mul. d0 med 4

	lsr.l	#1,d0	div. d0 med 2
	lsr.l	#2,d0	div. d0 med 4

SHIFT tar endast 8 (!!!!) cykler, s† h„r tj„nar man in massor
med processortid!	


Om du beh”ver lite mer tips, eller om det „r n†got du undrar ”ver, s†
skriv g„rna ett brev! Jag ska f”rs”ka svara s† gott jag kan!
