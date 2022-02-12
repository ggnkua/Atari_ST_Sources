#ifdef SOZOBON
*************************************************************************
*									*
*	modf(), ldexp() und frexp() in Assembler fuer SOZOBON		*
*	in double precision.						*
*									*
*	Scheinen zu funktionieren,					*
*	keine endgueltigen Tests durchgefuehrt				*
*									*
*	Volker Seebode 09.01.1992					*
*	Mit #define NOLONGS entsteht Version fuer 32-Bit Ints		*
*************************************************************************

biasd	equ	1023		* Exponent null

*************************************************************************
*									*
* double modf(double x, double *intpart);				*
* x vorzeichenrichtig in Ganzzahl und Rest aufteilen			*
*									*
* fuer SOZOBON mit double precision.					*
* Volker Seebode 07.01.1992						*
*************************************************************************
	.globl	_modf
	.text
_modf:
	movem.l	4(sp),d0-d1/a0		* get arguments
	movem.l	d2-d4,-(sp)		* save regs

	clr.w	d3
	btst	#31,d0			* positiv machen
	sne	d3			* Vorzeichen merken
	swap	d3			* Platz schaffen
	move.l	d0,d2
	swap	d2
	lsr.w	#4,d2			* d2 ist Exponent
	andi.w	#$7ff,d2		* Vorzeichen entfernen
	subi.w	#biasd,d2
	bmi	kleiner1		* kein ganzzahliger Anteil
	cmpi.w	#52,d2			* Ueberlauf des Exponenten?
	bgt	groesser52		* ja, kein Rest

	cmpi.w	#20,d2			* oberes oder unteres Langwort?
	bgt	groesser20		* oberes bleibt

	move.l	#$ffffffff,d4		* Maske berechnen
	move.w	#20,d3
	sub.w	d2,d3
	lsl.l	d3,d4
	move.l	d0,(a0)
	and.l	d4,(a0)
	clr.l	4(a0)

frac:	move.w	#51,d3			* fuer Normalisierung von frac
	sub.w	d2,d3			* max. Anzahl shifts

lp1:	lsl.l	#1,d1			* frac in Position bringen
	roxl.l	#1,d0
	add.w	#1,d3
	dbra	d2,lp1

lp2:	btst	#20,d0			* fuehrende Eins?
	bne	frac1			* ja, fertig
	lsl.l	#1,d1
	roxl.l	#1,d0
	dbra	d3,lp2
	clr.l	d0
	bra	modfret			* frac ist 0

frac1:	addi.w	#biasd-53,d3		* Exponent von frac bestimmen
	move.w	d3,d2
	lsl.w	#4,d2			* Exponent von frac in Position
	swap	d2
	clr.w	d2			* unteres Wort loeschen
	andi.l	#$000fffff,d0		* Exponent und Vorzeichen loeschen
	or.l	d2,d0			* Exponent dazu
frac2:	swap	d3
	tst.b	d3			* negativ?
	beq	modfret
	bset	#31,d0

modfret:
	movem.l	(sp)+,d2-d4
	rts

groesser20:
	move.l	#$ffffffff,d4
	move.w	#52,d3
	sub.w	d2,d3
	lsl.l	d3,d4
	move.l	d0,(a0)
	move.l	d1,4(a0)
	and.l	d4,4(a0)
	bra	frac
	
kleiner1:
	clr.l	(a0)
	clr.l	4(a0)
	bra	modfret

groesser52:
	move.l	d0,(a0)
	move.l	d1,4(a0)
	clr.l	d0
	move.l	d0,d1
	bra	modfret

*************************************************************************
*									*
* double ldexp(double x, int exp);					*
* x * 2 ^ exp berechnen							*
*									*
* fuer SOZOBON mit double precision.					*
* Volker Seebode 07.01.1992						*
* ACHTUNG: denormalisierte Zahlen werden nicht behandelt		*
*************************************************************************
	.globl	_ldexp
_ldexp:	movem.l	d2-d3,-(sp)
	movem.l	12(sp),d0-d1		* value
#ifdef NOLONGS
	move.l	20(sp),d2		* exp
#else
	move.w	20(sp),d2		* exp
#endif
	move.l	d0,d3			* Exponenent in d3 isolieren
	swap	d3
	lsr.w	#4,d3
	andi.l	#$000007ff,d3

	tst.w	d2			* neuer Exponenent negativ?
	bmi	ldexpneg		* ja

	add.w	d2,d3			* Exponenten addieren
	cmpi.w	#$7ff,d3		* Ueberlauf?
	bgt	ldueber			* ja

ldok:	lsl.w	#4,d3			* Exponenent in Position
	swap	d3
	andi.l	#$800fffff,d0		* alten Exponenten entfernen
	or.l	d3,d0			* neuen einbauen

ldret:	movem.l	(sp)+,d2-d3
	rts
ldueber:
	move.l	#$7fffffff,d0
	move.l	#$ffffffff,d1
	bra	ldret
ldunter:
	clr.l	d0
	clr.l	d1
	bra	ldret
ldexpneg:
	neg	d2			* neuen Exponenten positiv machen
	sub.w	d2,d3
	bmi	ldunter			* Unterlauf
	bra	ldok

*************************************************************************
*									*
* double frexp(double x, int *exp);					*
* x = frexp * 2 ^ (exp);						*
*									*
* fuer SOZOBON mit double precision.					*
* Volker Seebode 07.01.1992						*
* ACHTUNG: denormalisierte Zahlen werden nicht behandelt		*
*************************************************************************
	.globl	_frexp
_frexp:	move.l	d2,-(sp)
	movem.l	8(sp),d0-d1/a0		* get Arguments

	move.l	d0,d2			* Exponent in d2 isolieren
#ifdef NOLONGS
	clr.w	d2			* Mantisse entfernen
#endif
	swap	d2
	lsr.w	#4,d2
	andi.w	#$07ff,d2
#ifdef NOLONGS
	subi.l	#biasd-1,d2
	move.l	d2,(a0)
#else
	subi.w	#biasd-1,d2
	move.w	d2,(a0)			* Exponent in exp eintragen
#endif
	andi.l	#$800fffff,d0		* Exponenten entfernen
	or.l	#$3fe00000,d0		* Exponenent 0 eintragen

	move.l	(sp)+,d2
	rts

* Ende von modf.s

#else /* SOZOBON, jetzt kommt GNU-C */

|************************************************************************
|									*
|	modf(), ldexp() und frexp() in Assembler fuer GNUC		*
|	in double precision.						*
|									*
|	Scheinen zu funktionieren,					*
|	keine endgueltigen Tests durchgefuehrt				*
|									*
|	Volker Seebode 09.01.1992					*
|	Mit #define NOLONGS entsteht Version fuer 32-Bit Ints		*
|************************************************************************

biasd	=	1023		| Exponent null

|************************************************************************
|									*
| double modf(double x, double *intpart);				*
| x vorzeichenrichtig in Ganzzahl und Rest aufteilen			*
|									*
| fuer SOZOBON mit double precision.					*
| Volker Seebode 07.01.1992						*
|************************************************************************
	.globl	_modf
	.text
_modf:
	moveml	sp@(4),d0-d1/a0		| get arguments
	moveml	d2-d4,sp@-		| save regs

	clrw	d3
	btst	#31,d0			| positiv machen
	sne	d3			| Vorzeichen merken
	swap	d3			| Platz schaffen
	movel	d0,d2
	swap	d2
	lsrw	#4,d2			| d2 ist Exponent
	andiw	#0x7ff,d2		| Vorzeichen entfernen
	subiw	#biasd,d2
	bmi	kleiner1		| kein ganzzahliger Anteil
	cmpiw	#52,d2			| Ueberlauf des Exponenten?
	bgt	groesser52		| ja, kein Rest

	cmpiw	#20,d2			| oberes oder unteres Langwort?
	bgt	groesser20		| oberes bleibt

	movel	#0xffffffff,d4		| Maske berechnen
	movew	#20,d3
	subw	d2,d3
	lsll	d3,d4
	movel	d0,a0@
	andl	d4,a0@
	clrl	a0@(4)

frac:	movew	#51,d3			| fuer Normalisierung von frac
	subw	d2,d3			| max. Anzahl shifts

lp1:	lsll	#1,d1			| frac in Position bringen
	roxll	#1,d0
	addw	#1,d3
	dbra	d2,lp1

lp2:	btst	#20,d0			| fuehrende Eins?
	bne	frac1			| ja, fertig
	lsll	#1,d1
	roxll	#1,d0
	dbra	d3,lp2
	clrl	d0
	bra	modfret			| frac ist 0

frac1:	addiw	#biasd-53,d3		| Exponent von frac bestimmen
	movew	d3,d2
	lslw	#4,d2			| Exponent von frac in Position
	swap	d2
	clrw	d2			| unteres Wort loeschen
	andil	#0x000fffff,d0		| Exponent und Vorzeichen loeschen
	orl	d2,d0			| Exponent dazu
frac2:	swap	d3
	tstb	d3			| negativ?
	beq	modfret
	bset	#31,d0

modfret:
	moveml	sp@+,d2-d4
	rts

groesser20:
	movel	#0xffffffff,d4
	movew	#52,d3
	subw	d2,d3
	lsll	d3,d4
	movel	d0,a0@
	movel	d1,a0@(4)
	andl	d4,a0@(4)
	bra	frac
	
kleiner1:
	clrl	a0@
	clrl	a0@(4)
	bra	modfret

groesser52:
	movel	d0,a0@
	movel	d1,a0@(4)
	clrl	d0
	movel	d0,d1
	bra	modfret

|************************************************************************
|									*
| double ldexp(double x, int exp);					*
| x * 2 ^ exp berechnen							*
|									*
| fuer SOZOBON mit double precision.					*
| Volker Seebode 07.01.1992						*
| ACHTUNG: denormalisierte Zahlen werden nicht behandelt		*
|************************************************************************
	.globl	_ldexp
_ldexp:	moveml	d2-d3,sp@-
	moveml	sp@(12),d0-d1		| value
#ifdef NOLONGS
	movel	sp@(20),d2		| exp
#else
	movew	sp@(20),d2		| exp
#endif
	movel	d0,d3			| Exponenent in d3 isolieren
	swap	d3
	lsrw	#4,d3
	andil	#0x000007ff,d3

	tstw	d2			| neuer Exponenent negativ?
	bmi	ldexpneg		| ja

	addw	d2,d3			| Exponenten addieren
	cmpw	#0x7ff,d3		| Ueberlauf?
	bgt	ldueber			| ja

ldok:	lslw	#4,d3			| Exponenent in Position
	swap	d3
	andl	#0x800fffff,d0		| alten Exponenten entfernen
	orl	d3,d0			| neuen einbauen

ldret:	moveml	sp@+,d2-d3
	rts
ldueber:
	movel	#0x7fffffff,d0
	movel	#0xffffffff,d1
	bra	ldret
ldunter:
	clrl	d0
	clrl	d1
	bra	ldret
ldexpneg:
	negw	d2			| neuen Exponenten positiv machen
	subw	d2,d3
	bmi	ldunter			| Unterlauf
	bra	ldok

|************************************************************************
|									*
| double frexp(double x, int *exp);					*
| x = frexp * 2 ^ (exp);						*
|									*
| fuer SOZOBON mit double precision.					*
| Volker Seebode 07.01.1992						*
| ACHTUNG: denormalisierte Zahlen werden nicht behandelt		*
|************************************************************************
	.globl	_frexp
_frexp:	movel	d2,sp@-
	moveml	sp@(8),d0-d1/a0		| get Arguments

	movel	d0,d2			| Exponent in d2 isolieren
#ifdef NOLONGS
	clrw	d2			| Mantisse entfernen
#endif
	swap	d2
	lsrw	#4,d2
	andw	#0x07ff,d2
#ifdef NOLONGS
	subl	#biasd-1,d2
	movel	d2,a0@
#else
	subw	#biasd-1,d2
	movew	d2,a0@			| Exponent in exp eintragen
#endif
	andl	#0x800fffff,d0		| Exponenten entfernen
	orl	#0x3fe00000,d0		| Exponenent 0 eintragen

	movel	sp@+,d2
	rts
| Ende von modf.s
#endif
