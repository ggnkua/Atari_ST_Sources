#ifdef SOZOBON
/****************************************************************/
/*	Fliesskommaroutinen fuer Minix, double Format		*/
/*	Fixed 22.10.92						*/
/*	fehlerfrei? (...)					*/
/* Aenderung: 19.11.90						*/
/*	#ifdef	NEED_FUNC zur Verwendung sowohl fuer libcf.a	*/
/*	als auch fuer shared library ueber trap			*/
/*								*/
/* Anpassung fuer SOZOBON mit 64-bit double			*/
/* 								*/
/****************************************************************/

*	.globl .adf4, .adf8, .sbf4, .sbf8, .mlf4, .mlf8, .dvf4, .dvf8
*	.globl .ngf4, .ngf8

* **************************************************************************
**   Edition History	*
**  #	Date			Comments		    By
** -- --------	---------------------------------------------------- ---
**  1 88/08/25	Adapted to OS9 from elder versions	    hv
**  2 88/08/27	f_mul, f_div adapted			    hv
**  3 89/10/11	adapted for SOZOBON-C-Compiler		    vas
**  4 89/10/24	added double-precision routines 	    vas
**		adapted for ACK MINIX-ST
**  5 92/10/01  Fehler in 64-Bit Multiplikation entfernt    vas

** **********************************
** Globale Konstanten-Definitionen
** fuer das Fliesskommapaket
**

vorz	.equ	0		* Vorzeichenbit des Ergebnisses
subflag .equ	2		* Bitnummer des Subtraktionsflags
maxfexp .equ	255		* Maximal zulaessiger Exponent fuer float
maxdexp .equ	2047		* Maximal zulaessiger Exponent fuer double
biasf	.equ	127		* Bias des Exponenten bei float
biasd	.equ	1023		* Bias des Exponenten bei double
carry	.equ	1		* Carrybit im ccr
extend	.equ	16		* Extendbit im ccr
	
	.text
***********************************************
** Fliesskomma-Subtraktion in Single-Precision
** Parameter: 4(a7).L: Operand 1, 8(a7).L: Operand 2
** Ergebnis:  in 8(a7).L	(SOZOBON: d0.l)
**
	.globl	fpfsub		* _sbf4
fpfsub:
	bchg	#7,8(sp)	* Vorzeichen des zweiten Operanden invertieren

***********************************************
** Fliesskomma-Addition in Single-Precision
** Parameter: 4(a7).L: Operand 1, 8(a7).L: Operand 2
** Ergebnis:  in 8(a7).L	(SOZOBON: d0.l)
**
	.globl	fpfadd		* _adf4
fpfadd:
*	move.l	8(a7),d0	* erster Operand
*	move.l	4(a7),d1	* zweiter Operand
	move.l	4(a7),d0	* erster Operand
	move.l	8(a7),d1	* zweiter Operand
	movem.l d2-d5,-(sp)	* benoetigte Register retten
	rol.l	#1,d0		* Operanden rotieren und in Form
	rol.l	#1,d1		* eeee eeee ffff ... fffs bringen
	move.l	d0,d2
	sub.l	d1,d2		* Differenz beider Zahlen bilden
	bcc	fad4_1
	exg	d0,d1		* ggf. vertauschen, so dass der
fad4_1:
	move.b	d0,d3		* kleinere im Register D1 steht
	and.b	#1<<vorz,d3	* maskiere Vorzeichenbit
	btst	#vorz,d2	* haben beide gleiches Vorzeichen?
	beq	fad4_2		* bei verschiedenen Vorzeichen
	bset	#subflag,d3	* Flag fuer Subtraktion setzen
fad4_2:
	rol.l	#8,d0		* Form: ffff ... fffs eeee eeee
	clr.w	d4		* Exponent der ersten Zahl
	move.b	d0,d4		* wird im Register D4 aufgebaut
	sne	d0		* falls ungleich Null, dann
	ror.l	#1,d0		* implizite Eins, sonst implizite
	clr.b	d0		* Null erzeugen, neu positionieren

	rol.l	#8,d1		* jetzt das gleiche fuer den
	clr.w	d5		* zweiten Operanden, der Exponent
	move.b	d1,d5		* kommt ins Register D5
	sne	d1
	ror.l	#1,d1
	clr.b	d1

* In den Registern D0 und D1 stehen jetzt nur noch die Mantissen
* im Format ffff ... ffff 0000 0000, also linksbuendig, wobei die
* ehemals implizite Null bzw. Eins nun explizit an erster Stelle steht.
* In den Registern D4 und D5 stehen die Exponenten der beiden Zahlen.
* Das Vorzeichen des Ergebnisses sowie die Subtraktionsflag sind im
* Register D3 zwischengespeichert.

	move.w	d4,d2		* Jetzt Differenz der Exponenten
	sub.w	d5,d2		* berechnen
	cmp.w	#24,d2		* groesser als 24?
	bgt	ad4_rnd 	* ja, -> Ergebnis ist groessere Zahl
	lsr.l	d2,d1		* Mantisse um (D2)-Bits verschieben
	btst	#subflag,d3	* Subtraktion oder Addition?
	bne	subtr4		* ggf. zur Subtraktion springen
	add.l	d1,d0		* die beiden Mantissen adderen
	bcc	ad4_rnd 	* kein Ueberlauf --> zum Runden
	roxr.l	#1,d0		* Ueberlauf einschieben
	add.w	#1,d4		* Exponent korrigieren
	bra	ad4_rnd 	* und zum Runden

subtr4:
	sub.l	d1,d0		* die beiden Mantissen subtrahieren
	beq	ad4_zer 	* bei Null ist Gesamtergebnis Null
	bmi	ad4_rnd 	* bei fuehrender Eins zum Runden
ad4_nrm:
	tst.w	d4		* Exponent ist schon Null?
	beq	ad4_rnd 	* dann ist Ergebnis denormalisiert
	sub.w	#1,d4		* Exponent erniedrigen
	lsl.l	#1,d0		* Mantisse normalisieren bis
	bpl	ad4_nrm 	* fuehrende Eins auftaucht

ad4_rnd:
	add.l	#$80,d0 	* jetzt Runden auf Bit hinter
	bcc	ad4_nov 	* Mantisse
	roxr.l	#1,d0		* bei Ueberlauf Mantisse normalisieren
	add.w	#1,d4		* und Exponent korrigieren
ad4_nov:
	clr.b	d0		* Rest-Mantisse loeschen
	tst.l	d0		* ist die Mantisse komplett Null?
	beq	ad4_zer 	* ja, dann ist Ergebnis auch Null
	cmp.w	#maxfexp,d4	* Exponent-ueberlauf?
	blt	ad4_nue
	move.w	#maxfexp,d4	* Unendlich Exponent = maxexpo
	clr.l	d0		* Mantisse = Null
	bra	ad4_den

ad4_nue:
	tst.w	d4		* Exponent Null (Zahl denormalisiert)?
	beq	ad4_den 	* ja, -->
	lsl.l	#1,d0		* fuehrendes Bit wird nicht gespeichert
ad4_den:
	move.b d4,d0		* Exponent einsetzen
	ror.l	#8,d0		* Form: eeee eeee ffff ... fffx
	roxr.b	#1,d3		* Vorzeichen in Carry schieben
	roxr.l	#1,d0		* Form: seee eeee efff ... ffff
	
ad4_zer:

	movem.l (sp)+,d2-d5	* Register restaurieren
*	move.l d0,8(sp)		* nicht fuer SOZOBON
	rts

*************************************************
** Fliesskomma-Multiplikation in Single-Precision
** Parameter: 4(sp).L: Operand 1, 8(sp).L: Operand 2
** Ergebnis:  in 8(sp).L	(SOZOBON: d0.l)
**
	.globl	fpfmul		*.mlf4
fpfmul:
	move.l	4(sp),d0	* A
	move.l	8(sp),d1	* B
	movem.l d2-d5,-(sp)	* benoetigte Register retten
	move.l	d0,d2		* Operand 1 kopieren
	eor.l	d1,d2		* EXOR um Vorzeichen zu bestimmen

	swap	d0		* Registerhaelften Operand 1 vertauschen
	move.l	d0,d3		* Operand 1 ab jetzt im Register D3
	and.w	#$7f,d3 	* Exponent und Vorzeichen loeschen
	and.w	#$7f80,d0	* Exponent maskieren
	beq	mu4_dn1 	* gleich Null: Zahl ist denormalisiert
	bset	#7,d3		* implizite Eins einsetzen
	sub.w	#$0080,d0	* Bias kompensieren

mu4_dn1:
	swap	d1		* jetzt Operand 2 behandeln
	move.w	d1,d4
	and.w	#$7f,d1
	and.w	#$7f80,d4
	beq	mu4_dn2
	bset	#7,d1
	sub.w	#$0080,d4	* Bias kompensieren

mu4_dn2:
	add.w	d0,d4		* Exponenten addieren
	lsr.w	#7,d4		* richtig positionieren
	sub.w	#biasf-3,d4	* Bias-3 subtrahieren
	cmp.w	#-24,d4 	* totaler Unterlauf?
	blt	mu4_zer 	* ja, dann ist Ergebnis Null

	move.w	d3,d0		* oberes Mantissenwort von Operand 1
	mulu	d1,d0		* mal oberem Mantissenwort von Op2
	swap	d0		* entspricht Verschiebung um 16 Bit

** Das obere Wort von D0 ist nach der Multiplikation auf jeden Fall Null,
** da die oberen Mantissenworte nur im Bereich 0 ... 255 liegen.
** Das groesste moegliche Ergebnis ist also 255 x 255 = 65025 = 0000FE01.
** Nach der Vertauschung erhalten wir also eine Zahl der Form xxxx 0000.
** Die untere Registerhaelfte von D0 koennen wir kurzzeitig als Zwischen-
** speicher verwenden.

	move.w	d3,d0		* oberes Wort von Operand 1 merken
	swap	d3		* jetzt unteres Wort Op1 mal oberes Op2
	move.w	d1,d5
	mulu	d3,d5		* Ergebnis steht im D5
	swap	d1		* jetzt unteres Wort Op1 mal unteres Op2
	mulu	d1,d3		* Ergebnis steht im D3
	swap	d3		* entspricht Verschiebung um 16 Bit
	mulu	d0,d1		* jetzt oberes Wort Op1 mal unteres Op2

	move.w	d3,d0		* zum ersten Zwischenergebnis dazu
	add.l	d5,d0		* jetzt alles aufadderen
	add.l	d1,d0
	beq	mu4_res 	* falls Mantisse Null auch Ergebnis Null
	bmi	mu4_rnd 	* fuehrende Eins? dann zum Runden

** Im Register D0.L befinden sich die oberen 32 Bit des Produktes,
** im oberen Wort von D3 die restlichen 16 Bit.

	tst.w	d4		* Exponent ist negativ?
	bmi	mu4_unt 	* ggf. Unterlauf behandeln

mu4_nor:
	tst.w	d4		* Exponent = Null?
	beq	mu4_rnd 	* falls Null, dann zum Runden
	roxl.l	#1,d3		* Im oberen Wort von D3 sind die
	roxl.l	#1,d0		* niedrigsten Bits des Produktes
	sub.w	#1,d4		* Exponent korrigieren
	tst.l	d0		* Mantisse testen
	bpl	mu4_nor 	* bis fuehrende Eins auftaucht

mu4_rnd:
	add.l	#$80,d0 	* Rundung
	bcc	mu4_nov
	roxr.l	#1,d0		* Ueberlauf einschieben
	add.w	#1,d4		* Exponent korrigieren
mu4_nov:
	cmp.w	#maxfexp,d4	* Exponent-ueberlauf?
	blt	mu4_nue
dv4_err:
	move.w #maxfexp,d4	* Ueberlauf: Exponent = Maxexpo
	clr.l	d0		* Mantisse = Null
	bra	mu4_den

mu4_nue:
	tst.w	d4		* Exponent = Null?
	beq	mu4_den 	* falls Null, dann denormalisiert
	lsl.l	#1,d0		* fuehrende Eins wird nicht abgespeichert

mu4_den:
	move.b	d4,d0		* Exponent einsetzen
	ror.l	#8,d0		* Form: eeee eeee ffff ... fffx
	roxl.l	#1,d2		* Vorzeichen in Carry schieben
	roxr.l	#1,d0		* und ins Ergebnis einsetzen

mu4_res:
	movem.l (sp)+,d2-d5	* Register restaurieren
*	move.l	d0,8(sp)
	rts

mu4_zer:
	clr.l	d0		* Null erzeugen
	bra	mu4_res 	* Ende, Ergebnis steht in D0.L

mu4_unt:
	cmp.w	#-24,d4 	* totaler Unterlauf?
	ble	mu4_zer 	* dann ist Ergebnis auf jeden Fall Null
	neg.w	d4		* sonst Shift-Zaehler erzeugen
	lsr.l	d4,d0		* und Zahl denormalisieren
	clr.w	d4		* Exponent ist Null als Kennzeichen
	bra	mu4_rnd 	* fuer eine denormalisierte Zahl
	
*************************************************
** Fliesskomma-Division in Single-Precision
** Parameter: 4(sp).L: Operand 1, 8(sp).L: Operand 2
** Ergebnis:  in 8(sp).L	(SOZOBON: d0.l)
**
	.globl	fpfdiv		* _dvf4
*	move.l	8(sp),d0	* A
*	move.l	4(sp),d1	* B
fpfdiv:
	move.l	4(sp),d0	* A
	move.l	8(sp),d1	* B
	movem.l d2-d5,-(sp)	* benoetigte Register retten
	move.l	d0,d2		* Operand 1 kopieren
	eor.l	d1,d2		* EXOR um Vorzeichen zu bestimmen

	swap	d0		* Registerhaelften Operand 1 vertauschen
	move.l	d0,d3		* Operand 1 ab jetzt im Register D3
	and.w	#$7f,d3 	* Exponent und Vorzeichen loeschen
	and.w	#$7f80,d0	* Exponent maskieren
	beq	dv4_dn1 	* gleich Null: Zahl ist denormalisiert
	bset	#7,d3		* implizite Eins einsetzen
	sub.w	#$0080,d0	* Bias kompensieren

dv4_dn1:
	swap	d1		* jetzt Operand 2 behandeln
	move.w	d1,d4
	and.w	#$7f,d1
	and.w	#$7f80,d4
	beq	dv4_dn2
	bset	#7,d1
	sub.w	#$0080,d4	* Bias kompensieren

dv4_dn2:
	sub.w	d4,d0		* Exponenten subtrahieren
	move.w	d0,d4		* Exponent nach D4 kopieren
	asr.w	#7,d4		* richtig positionieren
	add.w	#biasf,d4	* Bias addieren
	cmp.w	#-24,d4 	* totaler Unterlauf?
	blt	mu4_zer 	* ja, dann ist Ergebnis Null

	swap	d1		* Form: 0fff ... ffff 0000 0000
	beq	dv4_err 	* falls Divisor Null, dann wird
	lsl.l	#7,d1		* als Ergebnis unendlich ausgegeben
	swap	d3
	beq	mu4_zer 	* falls Dividend Null --> Ergebnis Null
	lsl.l	#7,d3		* fuer Division positionieren

dv4_nlp:
	btst	#30,d1		* ist der Divisor normalisiert?
	bne	dv4_nor 	* ja, -->
	add.w	#1,d4		* nein, Exponent erhoehen
	lsl.l	#1,d1		* Divisor verschieben bis Form 01ff ...
	bra	dv4_nlp

dv4_nor:
	clr.l	d0		* Ergebnis vorbesetzen
	add.w	#25,d4		* Exponent ist sicher groesser als Null
	
dv4_lop:
	move.l	d3,d5		* Dividend zwischenspeichern
	sub.l	d1,d3		* Divisor abziehen
	eor	#extend,ccr	* X-Bit invertieren
	bcc	dv4_one 	* kein Carry: Divisor passt
	move.l	d5,d3		* zurueckkopieren (X-Bit unveraendert*)
dv4_one:
	roxl.l	#1,d0		* Ergebnis aufbauen
	lsl.l	#1,d3		* Dividend verschieben
	sub.w	#1,d4		* Exponent erniedrigen
	beq	dv4_den 	* falls Null, dann denormalisiert
	btst	#24,d0		* fuehrende Eins in Ergebnis-Mantisse?
	beq	dv4_lop 	* nein, weiter rechnen

dv4_den:
	lsl.l	#7,d0		* Mantisse positionieren
	beq	mu4_res 	* Null?
	bra	mu4_rnd 	* zum Runden

***********************************************
** Fliesskomma-Subtraktion in Double-Precision.
** Parameter: 4(sp).LL: Operand 1, 12(sp).LL: Operand 2
** Ergebnis:  in 12(sp).L	(SOZOBON: d0.l/d1.l)
**
	.globl	fpdsub		* _sbf8
fpdsub:
	bchg	#7,12(sp)	* Vorzeichen des zweiten Operanden
				* invertieren und in die Addition fallen 

*************************************************
** Fliesskomma-Addition in Double-Precision
** Parameter: 4(sp).LL: Operand 2, 12(sp).LL: Operand 1
** Ergebnis:  in 12(sp).LL
**
	.globl	fpdadd		* _adf8
fpdadd:
	lea	4(sp),a0
	movem.l d3-d7,-(sp)	* benoetigte Register retten
	movem.l (a0)+,d0-d3
	move.w	#0,d7
	move.w	d7,d4
	move.w	d7,d5
				* fuer ACK
*	exg	d0,d2		* Operanden vertauschen, spaeter Routine
*	exg	d1,d3		* 	vielleicht mal umschreiben ...
	
* Nun den absolut groesseren ermitteln
	lsl.l	#1,d0		* Vorzeichen in Carry, bit 0 = 0
	scs	d4		* d4 = ff wenn Op 1 negativ
	roxr.b	#1,d5		* und merken in bit 7

	lsl.l	#1,d2
	scs	d7		* d7 = ff wenn Op 2 negativ
	roxr.b	#1,d5
	eor.b	d7,d4		* d4 = ff wenn Vorzeichen verschieden

* 				  Form eeee eeee eeef ffff ... fff0
	move.l	d0,d6
	move.l	d1,d7
	sub.l	d3,d7
	subx.l	d2,d6		* Differenz beider Zahlen bilden
	bcc	fad8_1
	exg	d0,d2		* ggf. vertauschen, so dass der
	exg	d1,d3		* kleinere in den Registern D2 D3 steht und
	lsr.b	#1,d5		* Vorzeichen des zweiten Operanden nach Bit 6
fad8_1:
	lsr.b	#6,d5		* Vorzeichen des groesseren nach bit 0
	tst.b	d4
	beq	fad8_2		* bei verschiedenen Vorzeichen
	bset	#subflag,d5	* Flag fuer Subtraktion setzen
fad8_2:
	rol.l	#8,d0		* Form: ffff ... ffff seee eeee eeee
	rol.l	#3,d0
	move.w	d0,d6		* Exponent der ersten Zahl
	and.w	#$07ff,d6	* wird im Register D6 aufgebaut
	sne	d0		* falls ungleich Null, dann
	ror.l	#1,d0		* implizite Eins, sonst implizite Null
	move.l	d1,d7		* 11 Bit nachschieben
	swap	d7
	lsr.w	#5,d7		* die 11 hoechstwertigen nach 'hinten'
	and.w	#$f800,d0
	or.w	d7,d0
	lsl.l	#8,d1		* das untere Langwort um 11 Bit schieben
	lsl.l	#3,d1

	swap	d6		* wir brauchen ein Wort als Zwischenspeicher
	rol.l	#8,d2		* jetzt das gleiche fuer den
	rol.l	#3,d2
	move.w	d2,d6		* zweiten Operanden, der Exponent
	and.w	#$07ff,d6	* kommt ins Register D7
	sne	d2
	ror.l	#1,d2
	move.l	d3,d7
	swap	d7
	lsr.w	#5,d7		* 11 Bit
	and.w	#$f800,d2
	or.w	d7,d2
	lsl.l	#8,d3
	lsl.l	#3,d3		* das untere Langwort

	move.w	d6,d7		* Exponent des zweiten nach d7.w
	swap	d6		* Exponent des ersten nach d6.w

* In den Registern D0 und D2 stehen jetzt nur noch die oberen 32 Bit
* der Mantissen und in den Registern D1 und D3 die unteren 21 Bit
* im Format ffff ffff ffff ffff ffff f000 ...., also linksbuendig, wobei die
* ehemals implizite Null bzw. Eins nun explizit an erster Stelle steht.
* In den Registern D6 und D7 stehen die Exponenten der beiden Zahlen.
* Das Vorzeichen des Ergebnisses sowie die Subtraktionsflag sind im
* Register D5 zwischengespeichert. D4 ist frei.

	move.w	d6,d4		* Jetzt Differenz der Exponenten
	sub.w	d7,d4		* berechnen
	cmp.w	#53,d4		* groesser als 53?
	bgt	ad8_rnd 	* ja, -> Ergebnis ist groessere Zahl
ad8lp1:
	tst.w	d4
	beq	ad8lpe
	sub.w	#1,d4
	lsr.l	#1,d2		* Mantisse um (D4)-Bits verschieben
	roxr.l	#1,d3
	bra	ad8lp1
ad8lpe:
	btst	#subflag,d5	* Subtraktion oder Addition?
	bne	subtr8		* ggf. zur Subtraktion springen
	add.l	d3,d1		* die beiden Mantissen addieren
*	bcc	ad8_m1		* kein Uebertrag der unteren Bits
*	add.l	#1,d0		* oder eben doch
*ad8_m1:
*	add.l	d2,d0
	addx.l	d2,d0	
	bcc	ad8_rnd 	* kein Ueberlauf --> zum Runden
	roxr.l	#1,d0		* Ueberlauf einschieben
	roxr.l	#1,d1
	add.w	#1,d6		* Exponent korrigieren
	bra	ad8_rnd 	* und zum Runden

subtr8:
	clr.b	d7
	sub.l	d3,d1
	seq	d7		* wenn Ergebnis in unteren Bits 0 merken
	subx.l	d2,d0		* die beiden Mantissen subtrahieren
	beq	ad8_zer 	* bei Null ist Gesamtergebnis Null
ad8_nz:
	bmi	ad8_rnd 	* bei fuehrender Eins zum Runden
ad8_nrm:
	tst.w	d6		* Exponent ist schon Null?
	beq	ad8_rnd 	* dann ist Ergebnis denormalisiert
	sub.w	#1,d6		* Exponent erniedrigen
	lsl.l	#1,d1		* Mantisse normalisieren bis
	roxl.l	#1,d0
	bpl	ad8_nrm 	* fuehrende Eins auftaucht

ad8_rnd:
	add.l	#$400,d1	* jetzt Runden auf Bit hinter
	bcc	ad8_nov 	* Mantisse
	add.l	#1,d0		* Ueberlauf addieren
	bcc	ad8_nov
	roxr.l	#1,d0		* bei Ueberlauf Mantisse normalisieren
	roxr.l	#1,d1
	add.w	#1,d6		* und Exponent korrigieren
ad8_nov:
	and.w	#$f800,d1	* Rest-Mantisse loeschen
	clr.b	d7
	tst.l	d1		* ist die Mantisse komplett Null?
	bne	ad8_nv1
	tst.l	d0
	beq	ad8_z0		* ja, dann ist Ergebnis auch Null
ad8_nv1:
	cmp.w 	#maxdexp,d6	* Exponent-ueberlauf?
	blt	ad8_nue
	move.w	#maxdexp,d6	* Unendlich Exponent = maxexpo
	clr.l	d0		* Mantisse = Null
	clr.l	d1
	bra	ad8_den

ad8_nue:
	tst.w	d6		* Exponent Null (Zahl denormalisiert)?
	beq	ad8_den 	* ja, -->
	lsl.l	#1,d1		* fuehrendes Bit wird nicht gespeichert
	roxl.l	#1,d0
ad8_den:
	move.w #10,d7		* Exponent einschieben, 11 Bit
ad8_lp2:
	lsr.w	#1,d6
	roxr.l	#1,d0
	roxr.l	#1,d1
	dbra	d7,ad8_lp2
	roxr.b	#1,d5		* Vorzeichen in Carry schieben
	roxr.l	#1,d0		* Form: seee eeee eeee ffff ... ffff
	roxr.l	#1,d1
	bra	ad8_out

ad8_zer:
	tst.b	d7
	bne	ad8_z0
	tst.l	d0		* Ergebnis ist nicht null
	bra	ad8_nz

ad8_z0: 
	clr.l	d0		* Ergebnis ist null
	clr.l	d1
ad8_out:

	movem.l (sp)+,d3-d7	* Register restaurieren
*	move.l 	d0,12(sp)	* Ergebnis uebergeben
*	move.l	d1,16(sp)
	rts

*************************************************
** Fliesskomma-Multiplikation in Double-Precision
** Parameter: 4(sp).LL: Operand 1, 12(sp).LL: Operand 2
** Ergebnis:  in 12(sp).LL	(SOZOBON: d0.l/d1.l)
**
	.globl	fpdmul		*.mlf8
fpdmul:
	lea	4(sp),a0
	movem.l d3-d7,-(sp)	* Register retten
	movem.l (a0)+,d0-d3	* Parameter in d0 bis d3
	move.l	d2,d4
	eor.l	d0,d4		* Vorzeichen bestimmen

	swap	d0		* in D0 obere 21 Mantissenbits von Op 1,
	move.w	d0,d5		* in D5 Exponent isolieren
	and.w	#$000f,d0	* Vorzeichen und Exponent loeschen
	and.w	#$7ff0,d5	* Exponent maskieren
	beq	mu8_dn1
	bset	#4,d0		* implizite 1 einsetzen
	sub.w	#$0010,d5	* Bias kompensieren
mu8_dn1:
	swap	d2		* fuer Op 2 dasselbe in D2 bzw. D6
	move.w	d2,d6
	and.w	#$000f,d2
	and.w	#$7ff0,d6
	beq	mu8_dn2
	bset	#4,d2
	sub.w	#$0010,d6	* Bias kompensieren
mu8_dn2:
	add.w	d6,d5		* Exponenten addieren
	lsr.w	#4,d5		* rechtsbuendig positionieren
	sub.w	#biasd-3,d5
	cmp.w	#-52,d5 	* totaler Unterlauf?
	blt	mu8_zer 	* Ergebnis ist also 0
	move.l	d4,a0		* Platz schaffen, Vorzeichen merken 
	move.l	d5,a1		* Exponent retten
* In D0 - D3 stehen nun die Mantissen, in A0 das Vorzeichen und in
* A1.w der Exponent des Ergebnisses. D4 bis D7 sind  frei.
* Nomenklatur: x1-x4 und y1-y4 bezeichnen die Worte der Operanden.
	swap	d0
	swap	d2		* richtig positionieren
	move.w	d1,d6		* fuer spaeter kopieren
	move.w	d3,d7
	move.w	d3,d5		* d5 = x4 * y4
	mulu	d1,d5
	move.w	d5,38(sp)	* Bit 0-15 abspeichern
	clr.w	d5
	swap	d5		* eventuellen Ueberlauf mitnehmen
* bit 16 - 32
	swap	d3
	swap	d1
	move.w	d6,d4
	mulu	d3,d4		* x4 * y3
	add.l	d4,d5		* zu Ueberlauf von x4 * y4 addieren
	move.w	d7,d4
	mulu	d1,d4		* x3 * y4
	add.l	d4,d5		* aufaddieren
	scs	d4		* Ueberlauf beachten
	move.w	d5,36(sp)	* Bit 16-31 merken
	clr.w	d5
	lsr.b	#1,d4
	roxl.w	#1,d5		* Uebertrag dazu
	swap	d5		* shift16
* Bit 32 - 48
*	d0	x1,x2		d2	y1,y2
*	d1	x4,x3		d3.w	y4,y3
*	d6.w	x4		d7.w	y4

	clr.w	d4		* fuer naechste Stelle vorbereiten
	mulu	d0,d7		* x2 * y4
	mulu	d2,d6		* x4 * y2
	add.l	d7,d5		* kein Uebertrag moeglich
	add.l	d6,d5		* 
	bcc	mu8_dn30
	add.w	#1,d4
mu8_dn30:
	move.w	d1,d6
	mulu	d3,d6		* x3 * y3
	add.l	d6,d5
	bcc	mu8_dn3
	add.w	#1,d4
mu8_dn3:
	move.w	d5,34(sp)	* Bit 32-48 merken
	move.w	d4,d5		* Uebertrag dazu
	swap	d5

* Bit 48 bis 80
* Registerbelegung zur Zeit:
*	D0:	x1,x2		D2:	y1,y2
*	D1:	x4,x3		D3:	y4,y3
*	D4,D6,D7 sind frei, D5 enthaelt 16 bit Zwischensumme
	move.w	d0,d6
	mulu	d3,d6		* x2 * y3
	move.w	d2,d7
	mulu	d1,d7		* x3 * y2
	clr.w	d4		* zur Zwischensumme addieren
	add.l	d6,d5
	bcc	mu8_dn4
	add.w	#1,d4
mu8_dn4:
	add.l	d7,d5
	bcc	mu8_dn5
	add.w	#1,d4
mu8_dn5:
	swap	d0		* x1 * y4 und
	swap	d1		* x4 * y1 vorbereiten
	swap	d2
	swap	d3
	move.w	d1,d6
	mulu	d2,d6		* x4 * y1
	move.w	d3,d7
	mulu	d0,d7		* x1 * y4
	add.l	d6,d5		* mit Uebertrag
	bcc	mu8_dn5a
	add.w	#1,d4
mu8_dn5a:
	add.l	d7,d5		* mit Uebertrag
	bcc	mu8_dn6
	add.w	#1,d4
mu8_dn6:
	move.w	d5,32(sp)
	move.w	d4,d5
	swap	d5
* Bit 64 bis 96
* x4 und y4 werden ueberhaupt nicht mehr benoetigt und x3,y3
* nur noch dieses eine Mal.
* Registerbelegung:
*	D0:	x2,x1		D2:	y2,y1
*	D1:	x3,x4		D3:	y3,y4
*	D4,D5 enthalten Zwischensumme.

	clr.w	d4		* fuer Addition vorbereitet
	swap	d1
	swap	d3
	mulu	d0,d3		* x1 * y3
	mulu	d2,d1		* x3 * y1
	add.l	d1,d5
	bcc	mu8_dn6a
	add.w	#1,d4
mu8_dn6a:
	add.l	d3,d5
	bcc	mu8_dn6b
	add.w	#1,d4
mu8_dn6b:
	swap	d0
	swap	d2
	move.w	d2,d6		* y2
	mulu	d0,d6		* x2 * y2
	add.l	d6,d5
	bcc	mu8_dn7
	add.w	#1,d4
mu8_dn7:
	swap	d5
	swap	d4
	move.w	d5,d4		* das high word kopieren,  Ueberlauf okay*

* bit 80 bis 112
* Registerbelegung:
*	D0:	x1,x2		D2:	y1,y2
*	D5,D7 Zwischenergebnis
	move.w	d0,d1		* x2
	swap	d0
	move.w	d2,d3		* y2
	swap	d2
	mulu	d0,d3		* x1 * y2
	mulu	d2,d1		* x2 * y1
	mulu	d0,d2		* x1 * y1
	add.l	d3,d4
	add.l	d1,d4
	move.w	d4,d5
	swap	d5
	swap	d4
	add.w	d2,d4

* nun steht also in D4, D5, 32-39(sp) tatsaechlich das Ergebnis der Mantissen-
* multiplikation.
mu8_dn9:
	move.l	32(sp),d6
	move.l	36(sp),d7
	move.w	a1,d3		* Exponent
	tst.w	d4
	beq	mu8_q0		* vielleicht 0?
	btst	#9,d4		* fuehrende 1?
	bne	mu8_rnd 	* dann zum Runden
mu8_noz:
	tst.w	d3		* Exponent negativ?
	bmi	mu8_unt 	* dann Unterlauf testen
mu8_nor:
	tst.w	d3
	beq	mu8_rnd 	* wenn Exponent 0 zum Runden
	lsl.l	#1,d7		* Mantisse eine Stelle nach links
	roxl.l	#1,d6
	roxl.l	#1,d5
	roxl.w	#1,d4
	sub.w	#1,d3		* Exponent erniedrigen
	btst	#9,d4		* fuehrende 1?
	beq	mu8_nor 	* nein, nochmal
mu8_rnd:
	add.l	#$00100000,d6	* stimmt das? Ja, es stimmt*
	bcc	mu8_nov
	add.l	#1,d5
	bcc	mu8_nov
	add.l	#1,d4
	btst	#10,d4
	beq	mu8_nov
	lsr.w	#1,d4		* Mantisse verschieben
	roxr.l	#1,d5
	roxr.l	#1,d6
	add.w	#1,d3		* Exponent erhoehen
mu8_nov:
	cmp.w	#maxdexp,d3	* Exponentueberlauf?
	blt	mu8_nue 	* nein
dv8_err:
	move.w	#maxdexp,d3
	clr.l	d6
	clr.l	d5
	clr.l	d4
	bra	mu8_den

mu8_nue:
	tst.w	d3
	beq	mu8_den 	* wenn Exponent 0 denormalisiert
	bclr	#9,d4		* fuehrende Eins loeschen

* nun muss die 52 bit grosse Mantisse in die richtige Position gebracht werden
* 9 bit von d4, 32 von d5 und 11 von d6.
mu8_den:
	clr.l	d7
	swap	d6		* bit 15-5 enthalten Ergebnis
	move.w	d6,d7
	lsr.w	#4,d7		* nun bit 11-1
	move.l	d5,d6
	rol.l	#8,d6
	rol.l	#4,d6
	and.w	#$f000,d6
	or.l	d6,d7		* d7 enthaelt nun 31 bit linksbuendig
	move.l	d5,d6
	move.w	d4,d6
	ror.l	#8,d6		* 10 + 11 bit in d6, fuer Exponent positioniert
	ror.l	#1,d6
	and.w	#$f800,d6
	or.w	d3,d6		* Exponent einsetzen
	ror.l	#8,d6		* swap d6 * ror.l #5
	ror.l	#3,d6
	move.l	a0,d2		* Vorzeichen holen
	lsl.l	#1,d2
	roxr.l	#1,d6		* Vorzeichen dazu
	roxr.l	#1,d7
mu8_out:
*	move.l	d7,36(sp)	* Ergebnis 
*	move.l	d6,32(sp)
	move.l	d7,d1		* fuer SOZOBON
	move.l	d6,d0
	movem.l (sp)+,d3-d7
	rts

mu8_q0:
	tst.l	d5
	bne	mu8_noz 	* nicht 0
	tst.l	d6
	bne	mu8_noz 	* nicht 0
mu8_zer:
	clr.l	d7		* die ganze Rechnerei fuer Nullen
	clr.l	d6
	bra	mu8_out

mu8_unt:
	cmp.w	#-53,d3
	ble	mu8_zer 	* Unterlauf, Ergebnis 0
	neg.w	d3		* sonst Zahl denormalisieren
	sub.w	#1,d3
mu8_dlp:			* solange nach rechts, bis
	lsr.w	#1,d4		* Exponent 0
	roxr.l	#1,d5
	roxr.l	#1,d6
	roxr.l	#1,d7
	dbra	d3,mu8_dlp
	clr.w	d3
	bra	mu8_rnd
	
*************************************************
** Fliesskomma-Division in Double-Precision
** Parameter: 4(sp).LL: Operand 1, 12(sp).LL: Operand 2
** Ergebnis:  in 12(sp).LL	(SOZOBON: d0.l/d1.l)
**
	.globl fpddiv		* _dvf8
fpddiv:
	lea	4(sp),a0
	movem.l d3-d7,-(sp)
	movem.l (a0)+,d0-d3
*				* fuer ACK
*	exg	d0,d2		* Operanden vertauschen, spaeter mal
*	exg	d1,d3		* Routine umschreiben ...
	move.l	d0,d4
	eor.l	d2,d4		* Vorzeichen bestimmen
	swap	d0		* in D0 obere 21 Mantissenbits von Op 1,
	move.w	d0,d5		* in D5 Exponent isolieren
	and.w	#$000f,d0	* Vorzeichen und Exponent loeschen
	and.w	#$7ff0,d5	* Exponent maskieren
	beq	dv8_dn1
	bset	#4,d0		* implizite 1 einsetzen
	sub.w	#$0010,d5	* Bias kompensieren
dv8_dn1:
	swap	d2		* fuer Op 2 dasselbe in D2 bzw. D6
	move.w	d2,d6
	and.w	#$000f,d2
	and.w	#$7ff0,d6
	beq	dv8_dn2
	bset	#4,d2
	sub.w	#$0010,d6
dv8_dn2:
	sub.w	d6,d5		* Exponenten subtrahieren
	asr.w	#4,d5		* rechtsbuendig positionieren
	add.w	#biasd+1,d5	* Bias addieren (????????????????????)
	cmp.w	#-53,d5 	* totaler Unterlauf?
	blt	mu8_zer 	* Ergebnis ist 0
	swap	d0
	swap	d2		* Form 0000 0000 000f ffff ffff .... ffff
	tst.l	d2		* Divisor null?
	bne	dv8_dn3
	tst.l	d3
	beq	dv8_err 	* ja, Fehler*
* in d5 nun Exponent des Ergebnisses
dv8_dn3:
	tst.l	d0
	bne	dv8_nlp
	tst.l	d1
	beq	mu8_zer
dv8_nlp:
	btst	#20,d2		* Divisor normalisiert ?
	bne	dv8_nor 	* ja
	add.w	#1,d5		* Exponent erhoehen
	lsl.l	#1,d3
	roxl.l	#1,d2
	bra	dv8_nlp
dv8_nor:
	clr.l	d6
	clr.l	d7		* Ergebnis vorbesetzen
	add.w	#53,d5		* Exponent ist sicher groesser Null
dv8_lop:
	move.l	d0,a0
	move.l	d1,a1		* Dividend zwischenspeichern
	sub.l	d3,d1		* Divisor abziehen
	subx.l	d2,d0
	eor	#extend,ccr
	bcc	dv8_one
	move.l	a0,d0		* Dividend zurueckholen
	move.l	a1,d1
dv8_one:
	roxl.l	#1,d7		* Ergebnis aufbauen
	roxl.l	#1,d6
	lsl.l	#1,d1
	roxl.l	#1,d0
	sub.w	#1,d5		* Exponent erniedrigen
	beq	dv8_den 	* falls Null denormalisiert
	btst	#21,d6		* fuehrende 1 im Ergebnis?
	beq	dv8_lop
dv8_den:
	tst.l	d7
	bne	dv8_no0
	tst.l	d6
	beq	mu8_out
dv8_no0:
	add.l	#1,d7		* runden
	bcc	dv8_dn4
	add.l	#1,d6
dv8_dn4:
	btst	#22,d6
	beq	dv8_nov 	* kein Ueberlauf passiert
	lsr.l	#1,d6
	roxl.l	#1,d7
	add.w	#1,d5		* Exponent erhoehen
dv8_nov:
	cmp.w	#maxdexp,d5
	bge	dv8_err
	tst.w	d5
	beq	dv8_dn5 	* Exponent gleich Null -> denormalisiert
	bclr	#21,d6		* fuehrende 1 wird nicht abgespeichert
dv8_dn5:
	lsl.w	#5,d5		* Exponent positionieren
	swap	d5
	clr.w	d5
	or.l	d5,d6		* und einsetzen
	lsl.l	#1,d4
	roxr.l	#1,d6
	roxr.l	#1,d7
	bra	mu8_out 	* fertig

#endif /* SOZOBON */

#ifdef __GNUC__

|################################################################
|#	Fliesskommaroutinen fuer M680x0, double & float Format  #
|#	Fixed 22.10.92						#
|#	fehlerfrei? (...)					#
|#	Version fuer GNU-C bzw. UNIX Assembler Syntax           #
|#	Temporaere Register:                                    #
|#	d0-d1/a0-a1                                             #
|#	Volker Seebode, Version 7                               #
|# 								#
|################################################################

|###########################################################################
|#   Edition History	#
|#  #	Date			Comments		By
|# -- --------	---------------------------------------------------- ---
|#  1 88/08/25	Adapted to OS9 from elder versions	hv
|#  2 88/08/27	f_mul, f_div adapted			hv
|#  3 89/10/11	adapted for SOZOBON-C-Compiler		vs
|#  4 89/10/24	added double-precision routines 	vs
|#		adapted for ACK MINIX-ST
|#  6 92/03/14  UNIX Assembler Syntax                   vs
|#  7 92/10/01  Fehler in 64-Bit Multiplikation entfernt vs


|# ##################################
|# Globale Konstanten-Definitionen
|# fuer das Fliesskommapaket
|#

vorz	=	0		| Vorzeichenbit des Ergebnisses
subflag =	2		| Bitnummer des Subtraktionsflags
maxfexp =	255		| Maximal zulaessiger Exponent fuer float
maxdexp =	2047		| Maximal zulaessiger Exponent fuer double
biasf	=	127		| Bias des Exponenten bei float
biasd	=	1023		| Bias des Exponenten bei double
carry	=	1		| Carrybit im ccr
extend	=	16		| Extendbit im ccr
	

|##############################################
|# Fliesskomma-Subtraktion in Single-Precision
|# Parameter: 4(a7).L: Operand 1, 8(a7).L: Operand 2
|# Ergebnis:  in 8(a7).L	(SOZOBON: d0.l)
|#
	.text
	.globl	___subsf3
	.even
___subsf3:
	bchg	#7,sp@(8)	| Vorzeichen des zweiten Operanden invertieren

|##############################################
|# Fliesskomma-Addition in Single-Precision
|# Parameter: 4(a7).L: Operand 1, 8(a7).L: Operand 2
|# Ergebnis:  in 8(a7).L	(SOZOBON: d0.l)
|#
	.globl	___addsf3
___addsf3:
	movel	sp@(4),d0	| erster Operand
	movel	sp@(8),d1	| zweiter Operand
	moveml	d2-d5,sp@-	| benoetigte Register retten
	roll	#1,d0		| Operanden rotieren und in Form
	roll	#1,d1		| eeee eeee ffff ... fffs bringen
	movel	d0,d2
	subl	d1,d2		| Differenz beider Zahlen bilden
	bcc	fad4_1
	exg	d0,d1		| ggf. vertauschen, so dass der
fad4_1:
	moveb	d0,d3		| kleinere im Register D1 steht
	andb	#1<<vorz,d3	| maskiere Vorzeichenbit
	btst	#vorz,d2	| haben beide gleiches Vorzeichen?
	beq	fad4_2		| bei verschiedenen Vorzeichen
	bset	#subflag,d3	| Flag fuer Subtraktion setzen
fad4_2:
	roll	#8,d0		| Form: ffff ... fffs eeee eeee
	clrw	d4		| Exponent der ersten Zahl
	moveb	d0,d4		| wird im Register D4 aufgebaut
	sne	d0		| falls ungleich Null, dann
	rorl	#1,d0		| implizite Eins, sonst implizite
	clrb	d0		| Null erzeugen, neu positionieren

	roll	#8,d1		| jetzt das gleiche fuer den
	clrw	d5		| zweiten Operanden, der Exponent
	moveb	d1,d5		| kommt ins Register D5
	sne	d1
	rorl	#1,d1
	clrb	d1

| In den Registern D0 und D1 stehen jetzt nur noch die Mantissen
| im Format ffff ... ffff 0000 0000, also linksbuendig, wobei die
| ehemals implizite Null bzw. Eins nun explizit an erster Stelle steht.
| In den Registern D4 und D5 stehen die Exponenten der beiden Zahlen.
| Das Vorzeichen des Ergebnisses sowie die Subtraktionsflag sind im
| Register D3 zwischengespeichert.

	movew	d4,d2		| Jetzt Differenz der Exponenten
	subw	d5,d2		| berechnen
	cmpw	#24,d2		| groesser als 24?
	bgt	ad4_rnd 	| ja, -> Ergebnis ist groessere Zahl
	lsrl	d2,d1		| Mantisse um (D2)-Bits verschieben
	btst	#subflag,d3	| Subtraktion oder Addition?
	bne	subtr4		| ggf. zur Subtraktion springen
	addl	d1,d0		| die beiden Mantissen adderen
	bcc	ad4_rnd 	| kein Ueberlauf --> zum Runden
	roxrl	#1,d0		| Ueberlauf einschieben
	addw	#1,d4		| Exponent korrigieren
	bra	ad4_rnd 	| und zum Runden

subtr4:
	subl	d1,d0		| die beiden Mantissen subtrahieren
	beq	ad4_zer 	| bei Null ist Gesamtergebnis Null
	bmi	ad4_rnd 	| bei fuehrender Eins zum Runden
ad4_nrm:
	tstw	d4		| Exponent ist schon Null?
	beq	ad4_rnd 	| dann ist Ergebnis denormalisiert
	subw	#1,d4		| Exponent erniedrigen
	lsll	#1,d0		| Mantisse normalisieren bis
	bpl	ad4_nrm 	| fuehrende Eins auftaucht

ad4_rnd:
	addl	#0x80,d0 	| jetzt Runden auf Bit hinter
	bcc	ad4_nov 	| Mantisse
	roxrl	#1,d0		| bei Ueberlauf Mantisse normalisieren
	addw	#1,d4		| und Exponent korrigieren
ad4_nov:
	clrb	d0		| Rest-Mantisse loeschen
	tstl	d0		| ist die Mantisse komplett Null?
	beq	ad4_zer 	| ja, dann ist Ergebnis auch Null
	cmpw	#maxfexp,d4	| Exponent-ueberlauf?
	blt	ad4_nue
	movew	#maxfexp,d4	| Unendlich Exponent = maxexpo
	clrl	d0		| Mantisse = Null
	bra	ad4_den

ad4_nue:
	tstw	d4		| Exponent Null (Zahl denormalisiert)?
	beq	ad4_den 	| ja, -->
	lsll	#1,d0		| fuehrendes Bit wird nicht gespeichert
ad4_den:
	moveb 	d4,d0		| Exponent einsetzen
	rorl	#8,d0		| Form: eeee eeee ffff ... fffx
	roxrb	#1,d3		| Vorzeichen in Carry schieben
	roxrl	#1,d0		| Form: seee eeee efff ... ffff
	
ad4_zer:
	moveml	sp@+,d2-d5	| Register restaurieren
	rts

|################################################
|# Fliesskomma-Multiplikation in Single-Precision
|# Parameter: 4(a7).L: Operand 1, 8(a7).L: Operand 2
|# Ergebnis:  in 8(a7).L	(SOZOBON: d0.l)
|#
	.globl	___mulsf3
___mulsf3:
	movel	sp@(4),d0	| A
	movel	sp@(8),d1	| B
	moveml	d2-d5,sp@-	| benoetigte Register retten
	movel	d0,d2		| Operand 1 kopieren
	eorl	d1,d2		| EXOR um Vorzeichen zu bestimmen

	swap	d0		| Registerhaelften Operand 1 vertauschen
	movel	d0,d3		| Operand 1 ab jetzt im Register D3
	andw	#0x7f,d3 	| Exponent und Vorzeichen loeschen
	andw	#0x7f80,d0	| Exponent maskieren
	beq	mu4_dn1 	| gleich Null: Zahl ist denormalisiert
	bset	#7,d3		| implizite Eins einsetzen
	subw	#0x0080,d0	| Bias kompensieren

mu4_dn1:
	swap	d1		| jetzt Operand 2 behandeln
	movew	d1,d4
	andw	#0x7f,d1
	andw	#0x7f80,d4
	beq	mu4_dn2
	bset	#7,d1
	subw	#0x0080,d4	| Bias kompensieren

mu4_dn2:
	addw	d0,d4		| Exponenten addieren
	lsrw	#7,d4		| richtig positionieren
	subw	#biasf-3,d4	| Bias-3 subtrahieren
	cmpw	#-24,d4 	| totaler Unterlauf?
	blt	mu4_zer 	| ja, dann ist Ergebnis Null

	movew	d3,d0		| oberes Mantissenwort von Operand 1
	mulu	d1,d0		| mal oberem Mantissenwort von Op2
	swap	d0		| entspricht Verschiebung um 16 Bit

| Das obere Wort von D0 ist nach der Multiplikation auf jeden Fall Null,
| da die oberen Mantissenworte nur im Bereich 0 ... 255 liegen.
| Das groesste moegliche Ergebnis ist also 255 x 255 = 65025 = 0000FE01.
| Nach der Vertauschung erhalten wir also eine Zahl der Form xxxx 0000.
| Die untere Registerhaelfte von D0 koennen wir kurzzeitig als Zwischen-
| speicher verwenden.

	movew	d3,d0		| oberes Wort von Operand 1 merken
	swap	d3		| jetzt unteres Wort Op1 mal oberes Op2
	movew	d1,d5
	mulu	d3,d5		| Ergebnis steht im D5
	swap	d1		| jetzt unteres Wort Op1 mal unteres Op2
	mulu	d1,d3		| Ergebnis steht im D3
	swap	d3		| entspricht Verschiebung um 16 Bit
	mulu	d0,d1		| jetzt oberes Wort Op1 mal unteres Op2

	movew	d3,d0		| zum ersten Zwischenergebnis dazu
	addl	d5,d0		| jetzt alles aufadderen
	addl	d1,d0
	beq	mu4_res 	| falls Mantisse Null auch Ergebnis Null
	bmi	mu4_rnd 	| fuehrende Eins? dann zum Runden

| Im Register D0.L befinden sich die oberen 32 Bit des Produktes,
| im oberen Wort von D3 die restlichen 16 Bit.

	tstw	d4		| Exponent ist negativ?
	bmi	mu4_unt 	| ggf. Unterlauf behandeln

mu4_nor:
	tstw	d4		| Exponent = Null?
	beq	mu4_rnd 	| falls Null, dann zum Runden
	roxll	#1,d3		| Im oberen Wort von D3 sind die
	roxll	#1,d0		| niedrigsten Bits des Produktes
	subw	#1,d4		| Exponent korrigieren
	tstl	d0		| Mantisse testen
	bpl	mu4_nor 	| bis fuehrende Eins auftaucht

mu4_rnd:
	addl	#0x80,d0 	| Rundung
	bcc	mu4_nov
	roxrl	#1,d0		| Ueberlauf einschieben
	addw	#1,d4		| Exponent korrigieren
mu4_nov:
	cmpw	#maxfexp,d4	| Exponent-ueberlauf?
	blt	mu4_nue
dv4_err:
	movew	#maxfexp,d4	| Ueberlauf: Exponent = Maxexpo
	clrl	d0		| Mantisse = Null
	bra	mu4_den

mu4_nue:
	tstw	d4		| Exponent = Null?
	beq	mu4_den 	| falls Null, dann denormalisiert
	lsll	#1,d0		| fuehrende Eins wird nicht abgespeichert

mu4_den:
	moveb	d4,d0		| Exponent einsetzen
	rorl	#8,d0		| Form: eeee eeee ffff ... fffx
	roxll	#1,d2		| Vorzeichen in Carry schieben
	roxrl	#1,d0		| und ins Ergebnis einsetzen

mu4_res:
	moveml	sp@+,d2-d5	| Register restaurieren
	rts

mu4_zer:
	clrl	d0		| Null erzeugen
	bra	mu4_res 	| Ende, Ergebnis steht in D0.L

mu4_unt:
	cmpw	#-24,d4 	| totaler Unterlauf?
	ble	mu4_zer 	| dann ist Ergebnis auf jeden Fall Null
	negw	d4		| sonst Shift-Zaehler erzeugen
	lsrl	d4,d0		| und Zahl denormalisieren
	clrw	d4		| Exponent ist Null als Kennzeichen
	bra	mu4_rnd 	| fuer eine denormalisierte Zahl
	
|################################################
|# Fliesskomma-Division in Single-Precision
|# Parameter: 4(a7).L: Operand 1, 8(a7).L: Operand 2
|# Ergebnis:  in 8(a7).L	(SOZOBON: d0.l)
|#
	.globl	___divsf3
___divsf3:
	movel	sp@(4),d0	| A
	movel	sp@(8),d1	| B
	moveml	d2-d5,sp@-	| benoetigte Register retten
	movel	d0,d2		| Operand 1 kopieren
	eorl	d1,d2		| EXOR um Vorzeichen zu bestimmen

	swap	d0		| Registerhaelften Operand 1 vertauschen
	movel	d0,d3		| Operand 1 ab jetzt im Register D3
	andw	#0x7f,d3 	| Exponent und Vorzeichen loeschen
	andw	#0x7f80,d0	| Exponent maskieren
	beq	dv4_dn1 	| gleich Null: Zahl ist denormalisiert
	bset	#7,d3		| implizite Eins einsetzen
	subw	#0x0080,d0	| Bias kompensieren

dv4_dn1:
	swap	d1		| jetzt Operand 2 behandeln
	movew	d1,d4
	andw	#0x7f,d1
	andw	#0x7f80,d4
	beq	dv4_dn2
	bset	#7,d1
	subw	#0x0080,d4	| Bias kompensieren

dv4_dn2:
	subw	d4,d0		| Exponenten subtrahieren
	movew	d0,d4		| Exponent nach D4 kopieren
	asrw	#7,d4		| richtig positionieren
	addw	#biasf,d4	| Bias addieren
	cmpw	#-24,d4 	| totaler Unterlauf?
	blt	mu4_zer 	| ja, dann ist Ergebnis Null

	swap	d1		| Form: 0fff ... ffff 0000 0000
	beq	dv4_err 	| falls Divisor Null, dann wird
	lsll	#7,d1		| als Ergebnis unendlich ausgegeben
	swap	d3
	beq	mu4_zer 	| falls Dividend Null --> Ergebnis Null
	lsll	#7,d3		| fuer Division positionieren

dv4_nlp:
	btst	#30,d1		| ist der Divisor normalisiert?
	bne	dv4_nor 	| ja, -->
	addw	#1,d4		| nein, Exponent erhoehen
	lsll	#1,d1		| Divisor verschieben bis Form 01ff ...
	bra	dv4_nlp

dv4_nor:
	clrl	d0		| Ergebnis vorbesetzen
	addw	#25,d4		| Exponent ist sicher groesser als Null
	
dv4_lop:
	movel	d3,d5		| Dividend zwischenspeichern
	subl	d1,d3		| Divisor abziehen
	eorb	#extend,ccr	| X-Bit invertieren
	bcc	dv4_one 	| kein Carry: Divisor passt
	movel	d5,d3		| zurueckkopieren (X-Bit unveraendert#)
dv4_one:
	roxll	#1,d0		| Ergebnis aufbauen
	lsll	#1,d3		| Dividend verschieben
	subw	#1,d4		| Exponent erniedrigen
	beq	dv4_den 	| falls Null, dann denormalisiert
	btst	#24,d0		| fuehrende Eins in Ergebnis-Mantisse?
	beq	dv4_lop 	| nein, weiter rechnen

dv4_den:
	lsll	#7,d0		| Mantisse positionieren
	beq	mu4_res 	| Null?
	bra	mu4_rnd 	| zum Runden

|##############################################
|# Fliesskomma-Subtraktion in Double-Precision.
|# Parameter: 4(a7).LL: Operand 1, 12(a7).LL: Operand 2
|# Ergebnis:  in 12(a7).L	(SOZOBON: d0.l/d1.l)
|#
	.globl	___subdf3
___subdf3:
	bchg	#7,sp@(12)	| Vorzeichen des zweiten Operanden
				| invertieren und in die Addition fallen 

|################################################
|# Fliesskomma-Addition in Double-Precision
|# Parameter: 4(a7).LL: Operand 2, 12(a7).LL: Operand 1
|# Ergebnis:  in 12(a7).LL
|#
	.globl	___adddf3
___adddf3:
	lea	sp@(4),a0
	moveml	d2-d7,sp@-	| benoetigte Register retten
	moveml	a0@+,d0-d3
	movew	#0,d7
	movew	d7,d4
	movew	d7,d5
	
| Nun den absolut groesseren ermitteln
	lsll	#1,d0		| Vorzeichen in Carry, bit 0 = 0
	scs	d4		| d4 = ff wenn Op 1 negativ
	roxrb	#1,d5		| und merken in bit 7

	lsll	#1,d2
	scs	d7		| d7 = ff wenn Op 2 negativ
	roxrb	#1,d5
	eorb	d7,d4		| d4 = ff wenn Vorzeichen verschieden

| 				|  Form eeee eeee eeef ffff ... fff0
	movel	d0,d6
	movel	d1,d7
	subl	d3,d7
	subxl	d2,d6		| Differenz beider Zahlen bilden
	bcc	fad8_1
	exg	d0,d2		| ggf. vertauschen, so dass der
	exg	d1,d3		| kleinere in den Registern D2 D3 steht und
	lsrb	#1,d5		| Vorzeichen des zweiten Operanden nach Bit 6
fad8_1:
	lsrb	#6,d5		| Vorzeichen des groesseren nach bit 0
	tstb	d4
	beq	fad8_2		| bei verschiedenen Vorzeichen
	bset	#subflag,d5	| Flag fuer Subtraktion setzen
fad8_2:
	roll	#8,d0		| Form: ffff ... ffff seee eeee eeee
	roll	#3,d0
	movew	d0,d6		| Exponent der ersten Zahl
	andw	#0x07ff,d6	| wird im Register D6 aufgebaut
	sne	d0		| falls ungleich Null, dann
	rorl	#1,d0		| implizite Eins, sonst implizite Null
	movel	d1,d7		| 11 Bit nachschieben
	swap	d7
	lsrw	#5,d7		| die 11 hoechstwertigen nach 'hinten'
	andw	#0xf800,d0
	orw	d7,d0
	lsll	#8,d1		| das untere Langwort um 11 Bit schieben
	lsll	#3,d1

	swap	d6		| wir brauchen ein Wort als Zwischenspeicher
	roll	#8,d2		| jetzt das gleiche fuer den
	roll	#3,d2
	movew	d2,d6		| zweiten Operanden, der Exponent
	andw	#0x07ff,d6	| kommt ins Register D7
	sne	d2
	rorl	#1,d2
	movel	d3,d7
	swap	d7
	lsrw	#5,d7		| 11 Bit
	andw	#0xf800,d2
	orw	d7,d2
	lsll	#8,d3
	lsll	#3,d3		| das untere Langwort

	movew	d6,d7		| Exponent des zweiten nach d7.w
	swap	d6		| Exponent des ersten nach d6.w

| In den Registern D0 und D2 stehen jetzt nur noch die oberen 32 Bit
| der Mantissen und in den Registern D1 und D3 die unteren 21 Bit
| im Format ffff ffff ffff ffff ffff f000 ...., also linksbuendig, wobei die
| ehemals implizite Null bzw. Eins nun explizit an erster Stelle steht.
| In den Registern D6 und D7 stehen die Exponenten der beiden Zahlen.
| Das Vorzeichen des Ergebnisses sowie die Subtraktionsflag sind im
| Register D5 zwischengespeichert. D4 ist frei.

	movew	d6,d4		| Jetzt Differenz der Exponenten
	subw	d7,d4		| berechnen
	cmpw	#53,d4		| groesser als 53?
	bgt	ad8_rnd 	| ja, -> Ergebnis ist groessere Zahl
ad8lp1:
	tstw	d4
	beq	ad8lpe
	subw	#1,d4
	lsrl	#1,d2		| Mantisse um (D4)-Bits verschieben
	roxrl	#1,d3
	bra	ad8lp1
ad8lpe:
	btst	#subflag,d5	| Subtraktion oder Addition?
	bne	subtr8		| ggf. zur Subtraktion springen
	addl	d3,d1		| die beiden Mantissen addieren
|	bcc	ad8_m1		| kein Uebertrag der unteren Bits
|	addl	#1,d0		| oder eben doch
|ad8_m1:
|	addl	d2,d0
	addxl	d2,d0	
	bcc	ad8_rnd 	| kein Ueberlauf --> zum Runden
	roxrl	#1,d0		| Ueberlauf einschieben
	roxrl	#1,d1
	addw	#1,d6		| Exponent korrigieren
	bra	ad8_rnd 	| und zum Runden

subtr8:
	clrb	d7
	subl	d3,d1
	seq	d7		| wenn Ergebnis in unteren Bits 0 merken
	subxl	d2,d0		| die beiden Mantissen subtrahieren
	beq	ad8_zer 	| bei Null ist Gesamtergebnis Null
ad8_nz:
	bmi	ad8_rnd 	| bei fuehrender Eins zum Runden
ad8_nrm:
	tstw	d6		| Exponent ist schon Null?
	beq	ad8_rnd 	| dann ist Ergebnis denormalisiert
	subw	#1,d6		| Exponent erniedrigen
	lsll	#1,d1		| Mantisse normalisieren bis
	roxll	#1,d0
	bpl	ad8_nrm 	| fuehrende Eins auftaucht

ad8_rnd:
	addl	#0x400,d1	| jetzt Runden auf Bit hinter
	bcc	ad8_nov 	| Mantisse
	addl	#1,d0		| Ueberlauf addieren
	bcc	ad8_nov
	roxrl	#1,d0		| bei Ueberlauf Mantisse normalisieren
	roxrl	#1,d1
	addw	#1,d6		| und Exponent korrigieren
ad8_nov:
	andw	#0xf800,d1	| Rest-Mantisse loeschen
	clrb	d7
	tstl	d1		| ist die Mantisse komplett Null?
	bne	ad8_nv1
	tstl	d0
	beq	ad8_z0		| ja, dann ist Ergebnis auch Null
ad8_nv1:
	cmpw 	#maxdexp,d6	| Exponent-ueberlauf?
	blt	ad8_nue
	movew	#maxdexp,d6	| Unendlich Exponent = maxexpo
	clrl	d0		| Mantisse = Null
	clrl	d1
	bra	ad8_den

ad8_nue:
	tstw	d6		| Exponent Null (Zahl denormalisiert)?
	beq	ad8_den 	| ja, -->
	lsll	#1,d1		| fuehrendes Bit wird nicht gespeichert
	roxll	#1,d0
ad8_den:
	movew	#10,d7		| Exponent einschieben, 11 Bit
ad8_lp2:
	lsrw	#1,d6
	roxrl	#1,d0
	roxrl	#1,d1
	dbra	d7,ad8_lp2
	roxrb	#1,d5		| Vorzeichen in Carry schieben
	roxrl	#1,d0		| Form: seee eeee eeee ffff ... ffff
	roxrl	#1,d1
	bra	ad8_out

ad8_zer:
	tstb	d7
	bne	ad8_z0
	tstl	d0		| Ergebnis ist nicht null
	bra	ad8_nz

ad8_z0: 
	clrl	d0		| Ergebnis ist null
	clrl	d1
ad8_out:
	moveml	sp@+,d2-d7	| Register restaurieren
	rts

|################################################
|# Fliesskomma-Multiplikation in Double-Precision
|# Parameter: 4(a7).LL: Operand 1, 12(a7).LL: Operand 2
|# Ergebnis:  in 12(a7).LL	(SOZOBON: d0.l/d1.l)
|#
	.globl	___muldf3
___muldf3:
	lea	sp@(4),a0
	moveml	d2-d7,sp@-	| Register retten
	moveml	a0@+,d0-d3	| Parameter in d0 bis d3
	movel	d2,d4
	eorl	d0,d4		| Vorzeichen bestimmen

	swap	d0		| in D0 obere 21 Mantissenbits von Op 1,
	movew	d0,d5		| in D5 Exponent isolieren
	andw	#0x000f,d0	| Vorzeichen und Exponent loeschen
	andw	#0x7ff0,d5	| Exponent maskieren
	beq	mu8_dn1
	bset	#4,d0		| implizite 1 einsetzen
	subw	#0x0010,d5	| Bias kompensieren
mu8_dn1:
	swap	d2		| fuer Op 2 dasselbe in D2 bzw. D6
	movew	d2,d6
	andw	#0x000f,d2
	andw	#0x7ff0,d6
	beq	mu8_dn2
	bset	#4,d2
	subw	#0x0010,d6	| Bias kompensieren
mu8_dn2:
	addw	d6,d5		| Exponenten addieren
	lsrw	#4,d5		| rechtsbuendig positionieren
	subw	#biasd-3,d5
	cmpw	#-52,d5 	| totaler Unterlauf?
	blt	mu8_zer 	| Ergebnis ist also 0
	movel	d4,a0		| Platz schaffen, Vorzeichen merken 
	movel	d5,a1		| Exponent retten
| In D0 - D3 stehen nun die Mantissen, in A0 das Vorzeichen und in
| A1.w der Exponent des Ergebnisses. D4 bis D7 sind  frei.
| Nomenklatur: x1-x4 und y1-y4 bezeichnen die Worte der Operanden.
	swap	d0
	swap	d2		| richtig positionieren
	movew	d1,d6		| fuer spaeter kopieren
	movew	d3,d7
	movew	d3,d5		| d5 = x4 * y4
	mulu	d1,d5
	movew	d5,sp@(38)	| Bit 0-15 abspeichern
	clrw	d5
	swap	d5		| eventuellen Ueberlauf mitnehmen
| bit 16 - 32
	swap	d3
	swap	d1
	movew	d6,d4
	mulu	d3,d4		| x4 * y3
	addl	d4,d5		| zu Ueberlauf von x4 # y4 addieren
	movew	d7,d4
	mulu	d1,d4		| x3 * y4
	addl	d4,d5		| aufaddieren
	scs	d4		| Ueberlauf beachten
	movew	d5,sp@(36)	| Bit 16-31 merken
	clrw	d5
	lsrb	#1,d4
	roxlw	#1,d5		| Uebertrag dazu
	swap	d5		| shift16
| Bit 32 - 48
|	d0	x1,x2		d2	y1,y2
|	d1	x4,x3		d3.w	y4,y3
|	d6.w	x4		d7.w	y4

	clrw	d4		| fuer naechste Stelle vorbereiten
	mulu	d0,d7		| x2 * y4
	mulu	d2,d6		| x4 * y2
	addl	d7,d5		| kein Uebertrag moeglich
	addl	d6,d5
	bcc	mu8_dn30
	addw	#1,d4
mu8_dn30:
	movew	d1,d6
	mulu	d3,d6		| x3 * y3
	addl	d6,d5
	bcc	mu8_dn3
	addw	#1,d4
mu8_dn3:
	movew	d5,sp@(34)	| Bit 32-48 merken
	movew	d4,d5		| Uebertrag dazu
	swap	d5

| Bit 48 bis 80
| Registerbelegung zur Zeit:
|	D0:	x1,x2		D2:	y1,y2
|	D1:	x4,x3		D3:	y4,y3
|	D4,D6,D7 sind frei, D5 enthaelt 16 bit Zwischensumme
	movew	d0,d6
	mulu	d3,d6		| x2 * y3
	movew	d2,d7
	mulu	d1,d7		| x3 * y2
	clrw	d4		| zur Zwischensumme addieren
	addl	d6,d5
	bcc	mu8_dn4
	addw	#1,d4
mu8_dn4:
	addl	d7,d5
	bcc	mu8_dn5
	addw	#1,d4
mu8_dn5:
	swap	d0		| x1 * y4 und
	swap	d1		| x4 * y1 vorbereiten
	swap	d2
	swap	d3
	movew	d1,d6
	mulu	d2,d6		| x4 * y1
	movew	d3,d7
	mulu	d0,d7		| x1 * y4
	addl	d6,d5		| mit Uebertrag
	bcc	mu8_dn5a
	addw	#1,d4
mu8_dn5a:
	addl	d7,d5		| mit Uebertrag
	bcc	mu8_dn6
	addw	#1,d4
mu8_dn6:
	movew	d5,sp@(32)
	movew	d4,d5
	swap	d5		| Bit 64 bis 96
| x4 und y4 werden ueberhaupt nicht mehr benoetigt und x3,y3
| nur noch dieses eine Mal.
| Registerbelegung:
|	D0:	x2,x1		D2:	y2,y1
|	D1:	x3,x4		D3:	y3,y4
|	D4,D5 enthalten Zwischensumme, ab jetzt auch D7.

	clrw	d4		| fuer Addition vorbereitet
	swap	d1
	swap	d3
	mulu	d0,d3		| x1 * y3
	mulu	d2,d1		| x3 * y1
	addl	d1,d5
	bcc	mu8_dn6a
	addw	#1,d4
mu8_dn6a:
	addl	d3,d5
	bcc	mu8_dn6b
	addw	#1,d4
mu8_dn6b:
	swap	d0
	swap	d2
	movew	d2,d6		| y2
	mulu	d0,d6		| x2 # y2
	addl	d6,d5
	bcc	mu8_dn7
	addw	#1,d4
mu8_dn7:
	swap	d5
	swap	d4
	movew	d5,d4		| das high word kopieren,  Ueberlauf okay#

| bit 80 bis 112
| Registerbelegung:
|	D0:	x1,x2		D2:	y1,y2
|	D5,D7 Zwischenergebnis
	movew	d0,d1		| x2
	swap	d0
	movew	d2,d3		| y2
	swap	d2
	mulu	d0,d3		| x1 * y2
	mulu	d2,d1		| x2 * y1
	mulu	d0,d2		| x1 * y1
	addl	d3,d4
	addl	d1,d4
	movew	d4,d5
	swap	d5
	swap	d4
	addw	d2,d4

| nun steht also in D4, D5, 32-39(a7) tatsaechlich das Ergebnis der Mantissen-
| multiplikation.
mu8_dn9:
	movel	sp@(32),d6
	movel	sp@(36),d7
	movew	a1,d3		| Exponent
	tstw	d4
	beq	mu8_q0		| vielleicht 0?
	btst	#9,d4		| fuehrende 1?
	bne	mu8_rnd 	| dann zum Runden
mu8_noz:
	tstw	d3		| Exponent negativ?
	bmi	mu8_unt 	| dann Unterlauf testen
mu8_nor:
	tstw	d3
	beq	mu8_rnd 	| wenn Exponent 0 zum Runden
	lsll	#1,d7		| Mantisse eine Stelle nach links
	roxll	#1,d6
	roxll	#1,d5
	roxlw	#1,d4
	subw	#1,d3		| Exponent erniedrigen
	btst	#9,d4		| fuehrende 1?
	beq	mu8_nor 	| nein, nochmal
mu8_rnd:
	addl	#0x00100000,d6	| stimmt das? Ja, es stimmt#
	bcc	mu8_nov
	addl	#1,d5
	bcc	mu8_nov
	addl	#1,d4
	btst	#10,d4
	beq	mu8_nov
	lsrw	#1,d4		| Mantisse verschieben
	roxrl	#1,d5
	roxrl	#1,d6
	addw	#1,d3		| Exponent erhoehen
mu8_nov:
	cmpw	#maxdexp,d3	| Exponentueberlauf?
	blt	mu8_nue 	| nein
dv8_err:
	movew	#maxdexp,d3
	clrl	d6
	clrl	d5
	clrl	d4
	bra	mu8_den

mu8_nue:
	tstw	d3
	beq	mu8_den 	| wenn Exponent 0 denormalisiert
	bclr	#9,d4		| fuehrende Eins loeschen

| nun muss die 52 bit grosse Mantisse in die richtige Position gebracht werden
| 9 bit von d4, 32 von d5 und 11 von d6

mu8_den:
	clrl	d7
	swap	d6		| bit 15-5 enthalten Ergebnis
	movew	d6,d7
	lsrw	#4,d7		| nun bit 11-1
	movel	d5,d6
	roll	#8,d6
	roll	#4,d6
	andw	#0xf000,d6
	orl	d6,d7		| d7 enthaelt nun 31 bit linksbuendig
	movel	d5,d6
	movew	d4,d6
	rorl	#8,d6		| 10 + 11 bit in d6, fuer Exponent positioniert
	rorl	#1,d6
	andw	#0xf800,d6
	orw	d3,d6		| Exponent einsetzen
	rorl	#8,d6		| swap d6 # rorl #5
	rorl	#3,d6
	movel	a0,d2		| Vorzeichen holen
	lsll	#1,d2
	roxrl	#1,d6		| Vorzeichen dazu
	roxrl	#1,d7
mu8_out:
	movel	d7,d1		| Ergebnis
	movel	d6,d0
	moveml 	sp@+,d2-d7
	rts

mu8_q0:
	tstl	d5
	bne	mu8_noz 	| nicht 0
	tstl	d6
	bne	mu8_noz 	| nicht 0
mu8_zer:
	clrl	d7		| die ganze Rechnerei fuer Nullen
	clrl	d6
	bra	mu8_out

mu8_unt:
	cmpw	#-53,d3
	ble	mu8_zer 	| Unterlauf, Ergebnis 0
	negw	d3		| sonst Zahl denormalisieren
	subw	#1,d3
mu8_dlp:			| solange nach rechts, bis
	lsrw	#1,d4		| Exponent 0
	roxrl	#1,d5
	roxrl	#1,d6
	roxrl	#1,d7
	dbra	d3,mu8_dlp
	clrw	d3
	bra	mu8_rnd

|################################################
|# Fliesskomma-Division in Double-Precision
|# Parameter: 4(a7).LL: Operand 1, 12(a7).LL: Operand 2
|# Ergebnis:  in 12(a7).LL	(SOZOBON: d0.l/d1.l)
|#
	.globl ___divdf3
___divdf3:
	lea	sp@(4),a0
	moveml	d2-d7,sp@-
	moveml	a0@+,d0-d3
	movel	d0,d4
	eorl	d2,d4		| Vorzeichen bestimmen
	swap	d0		| in D0 obere 21 Mantissenbits von Op 1,
	movew	d0,d5		| in D5 Exponent isolieren
	andw	#0x000f,d0	| Vorzeichen und Exponent loeschen
	andw	#0x7ff0,d5	| Exponent maskieren
	beq	dv8_dn1
	bset	#4,d0		| implizite 1 einsetzen
	subw	#0x0010,d5	| Bias kompensieren
dv8_dn1:
	swap	d2		| fuer Op 2 dasselbe in D2 bzw. D6
	movew	d2,d6
	andw	#0x000f,d2
	andw	#0x7ff0,d6
	beq	dv8_dn2
	bset	#4,d2
	subw	#0x0010,d6
dv8_dn2:
	subw	d6,d5		| Exponenten subtrahieren
	asrw	#4,d5		| rechtsbuendig positionieren
	addw	#biasd+1,d5	| Bias addieren (????????????????????)
	cmpw	#-53,d5 	| totaler Unterlauf?
	blt	mu8_zer 	| Ergebnis ist 0
	swap	d0
	swap	d2		| Form 0000 0000 000f ffff ffff .... ffff
	tstl	d2		| Divisor null?
	bne	dv8_dn3
	tstl	d3
	beq	dv8_err 	| ja, Fehler#
| in d5 nun Exponent des Ergebnisses
dv8_dn3:
	tstl	d0
	bne	dv8_nlp
	tstl	d1
	beq	mu8_zer
dv8_nlp:
	btst	#20,d2		| Divisor normalisiert ?
	bne	dv8_nor 	| ja
	addw	#1,d5		| Exponent erhoehen
	lsll	#1,d3
	roxll	#1,d2
	bra	dv8_nlp
dv8_nor:
	clrl	d6
	clrl	d7		| Ergebnis vorbesetzen
	addw	#53,d5		| Exponent ist sicher groesser Null
dv8_lop:
	movel	d0,a0
	movel	d1,a1		| Dividend zwischenspeichern
	subl	d3,d1		| Divisor abziehen
	subxl	d2,d0
	eorb	#extend,ccr
	bcc	dv8_one
	movel	a0,d0		| Dividend zurueckholen
	movel	a1,d1
dv8_one:
	roxll	#1,d7		| Ergebnis aufbauen
	roxll	#1,d6
	lsll	#1,d1
	roxll	#1,d0
	subw	#1,d5		| Exponent erniedrigen
	beq	dv8_den 	| falls Null denormalisiert
	btst	#21,d6		| fuehrende 1 im Ergebnis?
	beq	dv8_lop
dv8_den:
	tstl	d7
	bne	dv8_no0
	tstl	d6
	beq	mu8_out
dv8_no0:
	addl	#1,d7		| runden
	bcc	dv8_dn4
	addl	#1,d6
dv8_dn4:
	btst	#22,d6
	beq	dv8_nov 	| kein Ueberlauf passiert
	lsrl	#1,d6
	roxll	#1,d7
	addw	#1,d5		| Exponent erhoehen
dv8_nov:
	cmpw	#maxdexp,d5
	bge	dv8_err
	tstw	d5
	beq	dv8_dn5 	| Exponent gleich Null -> denormalisiert
	bclr	#21,d6		| fuehrende 1 wird nicht abgespeichert
dv8_dn5:
	lslw	#5,d5		| Exponent positionieren
	swap	d5
	clrw	d5
	orl	d5,d6		| und einsetzen
	lsll	#1,d4
	roxrl	#1,d6
	roxrl	#1,d7
	bra	mu8_out 	| fertig

#endif /* __GNUC__ */
