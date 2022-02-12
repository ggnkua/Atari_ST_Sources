#ifdef SOZOBON
**************************************************************************
* Hilfsroutinen fuer das IEEE Fliesskommapaket mit echten double-Precision
* Zahlen.
*	Fixed: 22.10.92
*
* Anpassung fuer SOZOBON mit 64-bit double
* Temporaere Register:
*	d0-d1/a0-a1
* 
**************************************************************************

*	.globl	_cfi,  _cfu
*	.globl	_cif4, _cif8
*	.globl	_cuf4, _cuf8
*	.globl	_cff4, _cff8
*	.globl	_cmf4, _cmf8
*	.globl	_ngf4, _ngf8

	.globl	fpitod, fpltod
	.globl	fpitof, fpltof
	.globl	fputod, fpultod
	.globl	fputof, fpultof
	.globl	fpdtoi, fpdtol
	.globl	fpftoi, fpftol
	.globl	fpdtou, fpdtoul
	.globl	fpftou, fpftoul
	.globl	fpdtof, fpftod
	.globl	fpdcmp, fpfcmp
	.globl	fpdneg, fpfneg
	.text

* Konvertiere float oder double in (unsigned) int oder (unsigned) long.
* Volker Seebode 10/89.
* Letzte Aenderung:	14.5.90
*
* Stack:	IN					OUT
*	14(a7)					Ergebnis bei double -> int
*	12(a7)					Ergebnis bei double -> long
*	10(a7)					Ergebnis bei float -> int
*	8(a7)	float bzw double		Ergebnis bei float -> long
*	6(a7)	Byteanzahl Fliesskomma
*	4(a7)	Byteanzahl Integerregebnis

MAXINT	.equ	$7fff
MAXUINT	.equ	$ffff
MAXLONG	.equ	$7fffffff
MAXULONG .equ	$ffffffff

extend	.equ	16
biasf	.equ	127
biasd	.equ	1023

fpdtoi:				* SOZOBON simuliert ACK Aufrufe
 	move.l	(sp),a0		* Ruecksprungadresse in a0 merken
	move.w	#8,2(sp)
	move.w	#2,(sp)
	bra	fpfdil
fpdtol:
	move.l	(sp),a0
	move.w	#8,2(sp)
	move.w	#4,(sp)
	bra	fpfdil
fpftoi:
	move.l	(sp),a0
	move.w	#4,2(sp)
	move.w	#2,(sp)
	bra	fpfdil
fpftol:
	move.l	(sp),a0
	move.w	#4,2(sp)
	move.w	#4,(sp)
fpfdil:
	move.l	d2,a1
	bsr	_cfi
	move.l	a1,d2
	move.l	a0,(sp)	
	rts
_cfi:
	clr.w	d1		* Sicherheit
	cmp.w	#4,6(a7)	* float?
	beq	cfif		* ja
	move.l	8(a7),d0	* oberes Langwort der double-Zahl
	move.w	12(a7),d2	* Bit 32 - 47
	lsl.w	#1,d2		* alles eins nach links, Vorzeichen testen
	roxl.l	#1,d0
	scs	d1		* Vorzeichen merken
	swap	d1		* 
	move.w	d2,d1		* die letzen bits in d1 merken
	rol.l	#8,d0		* Exponent in d2 isolieren
	rol.l	#3,d0
	move.w	d0,d2
	and.w	#$07ff,d2	* 11 Bit
	cmp.w	#2,4(a7)	* solls ein int werden?
	beq	cfidi		* ja
	sub.w	#biasd,d2	* biasd
	bmi	cfid_3		* Exponent < 0, Ergebnis 0
	cmp.w	#31,d2		* groesser 31
	bge	cfid_4		* ja, Overflow
	or	#extend,ccr	* Extendbit setzen
	roxr.l	#1,d0		* implizite 1 explizit machen
	and.w	#$fc00,d0	* Exponent loeschen (geschoben *)
	lsr.w	#6,d1		* 10 Bits nachruecken
	or.w	d1,d0
cfid_1:
	lsr.l	#1,d0
	add.w	#1,d2
	cmp.w	#31,d2		* bis Exponent 31 schieben
	bne	cfid_1
	btst	#16,d1		* positiv?
	beq	cfid_2		* ja
	neg.l	d0
cfid_2:
*	move.l	d0,12(a7)	* fuer ACK
	rts
cfid_3:
	clr.l	d0		* Unterlauf
	bra	cfid_2
cfid_4:
	move.l	#MAXLONG,d0	* Ueberlauf
	btst	#16,d1
	beq	cfid_2
	not.l	d0
	bra	cfid_2

* konvertiere double nach int.
cfidi:
	sub.w	#biasd,d2	* biasd double -> int
	bmi	cfidi_4		* Unterlauf
	cmp.w	#15,d2
	bge	cfidi_5		* Ueberlauf passiert
	swap	d0		* nur oberes Wort interessiert
	or	#extend,ccr
	roxr.w	#1,d0		* explizite eins implizit machen
cfidi_1:
	lsr.w	#1,d0		* bis Exponent stimmt
	add.w	#1,d2
	cmp.w	#15,d2
	bne	cfidi_1		* schieben
cfidi_2:			* Zahl positiv?
	btst	#16,d1
	beq	cfidi_3
	neg.w	d0
cfidi_3:
*	move.w	d0,14(a7)	* fuer ACK
	rts
cfidi_4:			* Unterlauf
	clr.w	d0
	bra	cfidi_3
cfidi_5:			* Ueberlauf
	move.w	#MAXINT,d0
	btst	#16,d1
	beq	cfidi_3
	not.w	d0
	bra	cfidi_3
cfif:
	move.l	8(a7),d0	* float -> int oder long
	roxl.l	#1,d0
	scs	d1		* Vorzeichen in d1 merken
	rol.l	#8,d0		* Exponent in d2 isolieren
	move.b	d0,d2
	sub.b	#biasf,d2		* biasf
	bmi	cfif_3		* Unterlauf passiert
	cmp.w	#4,6(a7)	* solls ein int werden?
	bne	cfifi		* ja
	cmp.b	#31,d2
	bge	cfif_4		* Ueberlauf passiert
	or	#extend,ccr
	roxr.l	#1,d0		* implizite Eins
	clr.b	d0		* explizit machen
cfif_1:
	lsr.l	#1,d0
	add.b	#1,d2		* schieben, bis Exponent 31
	cmp.b	#31,d2
	bne	cfif_1
	tst.b	d1		* Zahl positiv?
	bpl	cfif_2		* ja
	neg.l	d0
cfif_2:
*	move.l	d0,8(a7)	* fuer ACK
	rts
cfif_3:
	clr.l	d0
	bra	cfif_2
cfif_4:
	move.l	#MAXLONG,d0	* Ueberlauf
	tst.b	d1
	bpl	cfif_2
	not.l	d0
	bra	cfif_2

cfifi:
	cmp.b	#15,d2		* maximaler Exponent 15
	bge	cfifi_3		* Ueberlauf passiert
	swap 	d0		* es interessiert nur das obere Wort
	or	#extend,ccr	* implizite Eins ...
	roxr.w	#1,d0
cfifi_1:
	lsr.w	#1,d0		* schieben ...
	add.b	#1,d2
	cmp.b	#15,d2
	bne	cfifi_1
	tst.b	d1		* positiv?
	bpl	cfifi_2		* ja
	neg.w	d0
cfifi_2:
*	move.w	d0,10(a7)	* fuer ACK
	rts
cfifi_3:			* Ueberlauf
	move.w	#MAXINT,d0
	tst.b	d1
	beq	cfifi_2
	not.l	d0
	bra	cfifi_2

*************************************************************************

fpdtou:				* SOZOBON simuliert ACK Aufrufe
 	move.l	(sp),a0
	move.w	#8,2(sp)
	move.w	#2,(sp)
	bra	fpfdul
fpdtoul:
	move.l	(sp),a0
	move.w	#8,2(sp)
	move.w	#4,(sp)
	bra	fpfdul
fpftou:
	move.l	(sp),a0
	move.w	#4,2(sp)
	move.w	#2,(sp)
	bra	fpfdul
fpftoul:
	move.l	(sp),a0
	move.w	#4,2(sp)
	move.w	#4,(sp)
fpfdul:
	move.l	d2,a1		* d2 retten
	bsr	_cfu
	move.l	a1,d2		* d2 wiederherstellen
	move.l	a0,(sp)
	rts
_cfu:
	cmp.w	#4,6(a7)	* float?
	beq	cfuf		* ja
	move.l	8(a7),d0	* oberes Langwort der double-Zahl
	move.w	12(a7),d2	* Bit 32 - 47
	lsl.w	#1,d2		* alles eins nach links, Vorzeichen testen
	roxl.l	#1,d0
	bcs	cfuf_3		* Zahl negativ -> Ergebnis null
	move.w	d2,d1
	rol.l	#8,d0		* Exponent in d2 isolieren
	rol.l	#3,d0
	move.w	d0,d2
	and.w	#$07ff,d2	* 11 Bit
	cmp.w	#2,4(a7)	* solls ein int werden?
	beq	cfudi		* ja
	sub.w	#biasd,d2	* biasd
	bmi	cfud_3		* Exponent < 0, Ergebnis 0
	cmp.w	#31,d2		* groesser 32
	bge	cfud_4		* ja, Overflow
	or	#extend,ccr	* Extendbit setzen
	roxr.l	#1,d0		* implizite 1 explizit machen
	roxr.w	#1,d1		* das rausfallende bit behalten*
	and.w	#$f800,d0	* Exponent loeschen
	lsr.w	#5,d1		* 11 Bit nachruecken
	or.w	d1,d0
cfud_1:
	lsr.l	#1,d0
	add.w	#1,d2
	cmp.w	#31,d2		* bis Exponent 31 schieben
	bne	cfud_1
cfud_2:
*	move.l	d0,12(a7)	* fuer ACK
	rts
cfud_3:
	clr.l	d0		* Unterlauf
	bra	cfud_2
cfud_4:
	move.l	#MAXULONG,d0	* Ueberlauf
	bra	cfud_2
cfudi:
	sub.w	#biasf,d2		* biasf, double -> int
	bmi	cfudi_3		* Unterlauf
	cmp.w	#15,d2
	bge	cfudi_4		* Ueberlauf passiert
	swap	d0		* nur oberes Wort interessiert
	or	#extend,ccr
	roxr.w	#1,d0		* explizite eins implizit machen
cfudi_1:
	lsr.w	#1,d0		* bis Exponent stimmt
	add.w	#1,d2
	cmp.w	#15,d2
	bne	cfudi_1		* schieben
cfudi_2:
*	move.w	d0,14(a7)	* fuer ACK
	rts
cfudi_3:			* Unterlauf
	clr.w	d0
	bra	cfudi_2
cfudi_4:			* Ueberlauf
	move.w	#MAXUINT,d0
	bra	cfudi_2

cfuf:
	move.l	8(a7),d0	* float -> int oder long
	roxl.l	#1,d0
	bcs	cfuf_3
	rol.l	#8,d0		* Exponent in d2 isolieren
	move.b	d0,d2
	sub.b	#biasf,d2		* biasf
	bmi	cfuf_3		* Unterlauf passiert
	cmp.w	#4,6(a7)	* solls ein int werden?
	bne	cfufi		* ja
	cmp.b	#31,d2
	bge	cfuf_4		* Ueberlauf passiert
	or	#extend,ccr
	roxr.l	#1,d0		* implizite Eins
	clr.b	d0		* explizit machen
cfuf_1:
	lsr.l	#1,d0
	add.b	#1,d2		* schieben, bis Exponent 31
	cmp.b	#31,d2
	bne	cfuf_1
cfuf_2:
*	move.l	d0,8(a7)	* fuer ACK
	rts

cfuf_3:
	clr.l	d0		* Unterlauf
	bra	cfuf_2

cfuf_4:
	move.l	#MAXULONG,d0	* Ueberlauf
	tst.b	d1
	bra	cfuf_2

cfufi:
	cmp.b	#15,d2		* maximaler Exponent 15
	bge	cfufi_3		* Ueberlauf passiert
	swap 	d0		* es interessiert nur das obere Wort
	or	#extend,ccr	* implizite Eins ...
	roxr.w	#1,d0
cfufi_1:
	lsr.w	#1,d0		* schieben ...
	add.b	#1,d2
	cmp.b	#15,d2
	bne	cfufi_1
cfufi_2:
*	move.w	d0,10(a7)	* fuer ACK
	rts
cfufi_3:			* Ueberlauf
	move.w	#MAXUINT,d0
	bra	cfufi_2

* cif8,cuf8,cif4,cuf4
*
* Konvertiere long oder int double-precision Fliesskomma
* Volker Seebode 10/89.
* Letzte Aenderung:	30.10.89
*
* Stack:
*	10(a7)	geloescht
*	8(a7)	untere 16 bit long			untere 32 bit double
*	6(a7)	obere 16 bit bzw int
*	4(a7)	#2 bzw #4 fuer Parameterlaenge		obere 32 bit double

*_cif8:				* fuer ACK
*	clr.w	d1
*	cmp.w	#2,4(a7)	* ist ein Integer uebergeben?
*	bne	clf8		* nein, long
*	clr.l	d0
*	move.w	6(a7),d0

fpitod:				* fuer SOZOBON
	move.l	d2,a0		* d2 merken
	clr.l	d0
	move.w	4(sp),d0

	beq	cif8_4		* Ergebnis ist 0
	smi	d1		* Vorzeichen in d1 merken
	bpl	cif8_1		* Zahl positiv machen
	neg.w	d0
cif8_1:
	move.w	#biasd+16,d2	* biasd, Exponent vorbesetzen
cif8_2:
	sub.w	#1,d2		* solange schieben bis fuehrende 1 
	lsl.w	#1,d0		* rausfliegt
	bcc	cif8_2
	swap	d0
	or.w	d2,d0		* Exponent dazumaskieren
	ror.l	#8,d0		* Form eeee eeee eeef ffff ....
	ror.l	#3,d0
	roxr.b	#1,d1		* Vorzeichen dazu
	roxr.l	#1,d0
cif8_3:
	move.l	a0,d2		* d2 wiederherstellen
*	move.l	d0,4(a7)	* Ergebnis*
*	clr.l	8(a7)		* Untere 32 Bit sind 0
	moveq.l	#0,d1		* fuer SOZOBON
	rts
cif8_4:
	clr.l	d0		* Nullergebnis
	bra	cif8_3

*clf8:				* fuer ACK
*	move.l	6(a7),d0
fpltod:				* fuer SOZOBON
	move.l	d2,a0		* d2 retten
	move.l	4(sp),d0
	beq	cif8_4		* Ergebnis ist 0
	smi	d1
	bpl	clf8_1
	neg.l	d0
clf8_1:
	move.l	d0,d2		* pruefen, ob Zahl als Integer darstellbar
	swap	d2
	tst.w	d2
	beq	cif8_1
	move.l	#biasd+32,d2	* biasd
clf8_2:
	sub.w	#1,d2
	lsl.l	#1,d0
	bcc	clf8_2
	swap	d2
	move.w	d0,d2		* eventuell stehengebliebene Stellen
	swap	d2		* im unteren Wort von d2 merken
	and.w	#$f000,d0	* Exponenten- und Vorzeichenbits loeschen
	or.w	d2,d0		* Exponenten dazu
	swap	d2
	lsl.w	#4,d2		* letzte Bits positionieren
	ror.l	#8,d0		* swap -- rol.l #3
	ror.l	#3,d0
	roxr.b	#1,d1		* Vorzeichen einschieben
	roxr.l	#1,d0
*	clr.w	10(a7)		* fuer ACK
*	move.w	d2,8(a7)
*	move.l	d0,4(a7)
	move.w	d2,d1		* fuer SOZOBON
	swap	d1
	clr.w	d1
	move.l	a0,d2		* d2 wiederherstellen
	rts

*_cuf8:				* fuer ACK
*	cmp.w	#2,4(a7)	* int oder long?
*	bne	culf8		* long
*	move.w	6(a7),d0

fputod:				* fuer SOZOBON
	move.l	d2,a0		* d2 retten
	move.w	4(sp),d0
	beq	cif8_4		* Ergebnis ist ebenfalls 0
	clr.b	d1		* unsigned ist nun eben gerade > 0
	bra	cif8_1

*culf8:
*	move.l	6(a7),d0	* fuer ACK
fpultod:
	move.l	d2,a0
	move.l	4(sp),d0	* fuer SOZOBON
	beq	cif8_4		* Ergebnis ist 0
	clr.b	d1
	bra	clf8_1

* Konvertiere int oder long in single-precision Fliesskomma
* Stack:
*		IN					OUT
*	8(a7)	untere 16 bit long
*	6(a7)	obere 16 bit long oder int	float-Ergebnis
*	4(a7)	Laenge int oder long

*_cif4:
*	clr.w	d1
*	cmp.w	#4,4(a7)
*	beq	clf4		* long konvertieren
*	clr.l	d0
*	move.w	6(a7),d0

fpitof:
	move.l	d2,a0
	move.w	4(sp),d0	* fuer SOZOBON

	beq	cif4_5		* Ergebnis ist 0
	smi	d1		* Vorzeichen merken
	bpl	cif4_1		* positiv machen
	neg.w	d0
cif4_1:
	move.w	#biasf+16,d2	* biasf, Exponent vorbesetzen
cif4_2:
	sub.w	#1,d2
	lsl.w	#1,d0
	bcc	cif4_2		* bis fuehrende 1 rausfliegt
	swap	d0
cif4_3:
	move.b	d2,d0		* Exponent dazu
	ror.l	#8,d0
	roxr.b	#1,d1
	roxr.l	#1,d0		* Vorzeichen dazu
cif4_4:
*	move.l	d0,4(a7)	* zwei ints kamen, ein long geht...
	move.l	a0,d2
	rts

cif4_5:
	clr.l	d0		* Ergebnis ist 0
	bra	cif4_4
*clf4:				* fuer ACK
*	move.l	6(a7),d0

fpltof:
	move.l	d2,a0		* d2 retten
	move.l	4(sp),d0	* fuer SOZOBON
	beq	cif4_5		* Ergebnis 0
	smi	d1
	bpl	clf4_1
	neg.l	d0
clf4_1:
	move.w	#biasf+32,d2	* biasf, Exponent vorbesetzten
clf4_2:
	sub.w	#1,d2
	lsl.l	#1,d0
	bcc	clf4_2		* bis fuehrende 1 rausfliegt
	move.b	d2,d0		* Exponent dazu
	ror.l	#8,d0
	roxr.b	#1,d1
	roxr.l	#1,d0		* Vorzeichen dazu
*	move.l	d0,6(a7)	* fuer ACK
	move.l	a0,d2		* d2 wiederherstellen
	rts

*_cuf4:				* fuer ACK
*	clr.w	d1		* Vorzeichen positiv
*	cmp.w	#4,4(a7)	* long?
*	beq	culf4		* ja
*	move.w	6(a7),d0
fputof:				* fuer SOZOBON
	move.l	d2,a0		* d2 retten
	clr.w	d1
	move.w	4(sp),d0
	beq	cif4_5		* Ergebnis ist 0
	bra	cif4_1

*culf4:				* fuer ACK
*	move.l	6(a7),d0
fpultof:
	move.l	d2,a0		* d2 retten
	clr.w	d1
	move.l	4(sp),d0	* fuer SOZOBON
	beq	cif4_5
	bra	clf4_1

* single-precision und double-precision ineinander umwandeln,
* vergleichen oder negieren.
* cff4, cff8, cmf4, cmf8, ngf4, ngf8.

* cff4. Bei Ueberlauf wird MAXFLOAT zurueckgegeben.
* Denormalisierung wird noch nicht abgefangen.
* Stack:
*		IN				OUT
*	4(a7)	double			8(a7)	float

MAXFLOAT .equ	$7f800000

*_cff4:				* fuer ACK
fpdtof:				* fuer SOZOBON
	move.l	d2,a0		* d2 retten
	move.l	4(a7),d0
	beq	cff4out
	move.w	8(a7),d1
	move.l	d0,d2		* Exponent in d2 pruefen
	clr.w	d2
	swap	d2
	lsr.w	#4,d2		* Form 0000 seee eeee eeee
	bclr	#11,d2		* Vorzeichen loeschen
	sub.w	#896,d2		* biasd-biasf
	bmi	cff4und		* Unterlauf
	cmp.w	#255,d2
	bge	cff4ove		* Exponent zu gross -> Ueberlauf
	ror.l	#8,d2
	lsl.w	#1,d1
	roxl.l	#1,d0
	roxr.l	#1,d2
	lsl.w	#1,d1
	roxl.l	#1,d0
	lsl.w	#1,d1
	roxl.l	#1,d0
	and.l	#$007fffff,d0
	or.l	d2,d0
cff4out:
	move.l	a0,d2		* d2 wiederherstellen
*	move.l	d0,8(a7)	* fuer ACK
	rts
cff4und:
	clr.l	d0
	bra	cff4out
cff4ove:
	and.l	#$80000000,d0
	or.l	#$7f800000,d0	* Ueberlauf
	bra	cff4out

* cff8. Keine Probleme.
* Stack:
*		IN				OUT
*	4(a7)	float			4(a7)	double
*

*_cff8:				* fuer ACK
fpftod:				* fuer SOZOBON
	move.l	d2,a0		* d2 retten
	move.l	4(a7),d0
	beq	cff8nul
	clr.b	d1
	move.l	d0,d2
	smi	d1
	ext.w	d1
	ext.l	d1
	swap	d2
	and.w	#$7f80,d2
	lsr.w	#7,d2
	add.w	#896,d2		* biasd-biasf
	lsl.w	#5,d2
	roxl.l	#1,d0		* Vorzeichenbit
	roxr.w	#1,d2		* uebernehmen
	lsr.l	#2,d0
	roxr.l	#1,d1
	lsr.l	#1,d0
	roxr.l	#1,d1
	lsr.l	#1,d0
	roxr.l	#1,d1
	and.l	#$000fffff,d0
	swap	d2
	clr.w	d2
	or.l	d2,d0
cff8out:
	move.l	a0,d2			* d2 wiederherstellen
*	move.l	d1,8(a7)		* fuer ACK
*	move.l	d0,4(a7)		*
	rts
cff8nul:
	clr.l	d0
	clr.l	d1
	bra	cff8out
	
* cmf4
* Fliesskommazahlen vergleichen.
* 	1.Operand	2.Operand	Ergebnis
*		    ==			    0L
*		    >			  > 0
*		    <			  < 0
* Stack:
*		IN				OUT
*	8(a7)	float2		
*	4(a7)	float1				D0.w
*						wird mit tst.w geprueft

*_cmf4:				*
*	move.l	8(a7),d0	* fuer ACK
*	move.l	4(a7),d1	*
fpfcmp:
	move.l	4(sp),d0	* fuer SOZOBON
	move.l	8(sp),d1	*
cmf4_x:
	bclr	#31,d1
	bne	cmf4_3		* zweiter Operand < 0
	bclr	#31,d0
	bne	cmf4_4		* erster Operand < 0
cmf4_1:
	sub.l	d1,d0		* beide sind > 0, Differenz bilden
cmf4_2:
	bmi	cmf4_4		* Ergebnis negativ -> -1 zurueckgeben
	beq	cmf4_6		* Ergebnis null -> 0 zurueckgeben
	moveq	#1,d0
cmf4_6:
	rts
cmf4_3:
	bclr	#31,d0
	bne	cmf4_5		* b: beide kleiner 0
	moveq	#1,d0
	rts
cmf4_4:
	moveq	#-1,d0		* erster Operand < 0, zweiter > 0
	rts
cmf4_5:
	exg	d0,d1
	bra	cmf4_1

*_cmf8:				* fuer ACK
*	move.l	12(a7),d0
*	move.l	4(a7),d1
fpdcmp:				* fuer SOZOBON
	move.l	4(a7),d0
	move.l	12(a7),d1
	bsr	cmf4_x		* zuerst die hoeherwertigen Langworte pruefen
	beq	cmf8_2		* nur, wenn die gleich sind weiterzumachen
cmf8_1:
	rts
cmf8_2:
	move.l	8(sp),d0	* low Langwort zweiter Operand
	sub.l	16(sp),d0	* low Langwort erster Operand
	beq	cmf8_1		* sind wirklich absolut gleich
	bmi	cmf8_3		* Ergebnis < 0?
	moveq	#1,d0
	bra	cmf8_4
cmf8_3:
	move.w	#-1,d0
cmf8_4:	
	btst	#7,4(sp)	* vielleicht beide negativ?
	beq	cmf8_1		* b: nein
	neg.w	d0		* dann Ergebnis negieren
	rts

* ngf4, ngf8.
* Fliesskommazahlen negieren. Vorzeichenbit toggeln, wenn ungleich 0

fpdneg:
	move.l	4(sp),d0	* oberes Langwort
	move.l	8(sp),d1	* unteres Langwort
	bne	doneg		* wenn ungleich 0 auf jeden Fall negieren
	tst.l	d0		* wenn ungleich 0 negieren
	bne	doneg
	rts
fpfneg:
	move.l	4(sp),d0
	beq	notneg
doneg:
	bchg	#31,d0
notneg:
	rts

#endif /* SOZOBON */

#ifdef __GNUC__

|#########################################################################
| Hilfsroutinen fuer das IEEE Fliesskommapaket mit echten double-Precision
| Zahlen.
|	Fixed: 22.10.92
|
|       Version fuer GNU-C bzw. UNIX Syntax, nur benoetigte Funktionen
|	Temporaere Register:
|	d0-d1/a0-a1
| 
|#########################################################################

| Konvertiere double nach long.
| Volker Seebode 10/89.
|

MAXINT	=	0x7fff
MAXUINT	=	0xffff
MAXLONG	=	0x7fffffff
MAXULONG =	0xffffffff

extend	=	16
biasf	=	127
biasd	=	1023

	.text
	.even
	.globl	___fixdfdi
	.globl	___fixdfsi
___fixdfdi:
___fixdfsi:
	movel	d2,sp@-
	clrw	d1		| Sicherheit
	movel	sp@(8),d0	| oberes Langwort der double-Zahl
	movew	sp@(12),d2	| Bit 32 - 47 (Rest wird nicht gebraucht)
	lslw	#1,d2		| alles eins nach links, Vorzeichen testen
	roxll	#1,d0
	scs	d1		| Vorzeichen merken
	swap	d1		| 
	movew	d2,d1		| die letzen bits in d1 merken
	roll	#8,d0		| Exponent in d2 isolieren
	roll	#3,d0
	movew	d0,d2
	andw	#0x07ff,d2	| 11 Bit
	subw	#biasd,d2	| biasd
	bmi	cfid_3		| Exponent < 0, Ergebnis 0
	cmpw	#31,d2		| groesser 31
	bge	cfid_4		| ja, Overflow
	orb	#extend,ccr	| Extendbit setzen
	roxrl	#1,d0		| implizite 1 explizit machen
	andw	#0xfc00,d0	| Exponent loeschen (geschoben #)
	lsrw	#6,d1		| 10 Bits nachruecken
	orw	d1,d0
cfid_1:
	lsrl	#1,d0
	addw	#1,d2
	cmpw	#31,d2		| bis Exponent 31 schieben
	bne	cfid_1
	btst	#16,d1		| positiv?
	beq	cfid_2		| ja
	negl	d0
cfid_2:
	movel	sp@+,d2
	rts
cfid_3:
	clrl	d0		| Unterlauf
	bra	cfid_2
cfid_4:
	movel	#MAXLONG,d0	| Ueberlauf
	btst	#16,d1
	beq	cfid_2
	notl	d0
	bra	cfid_2

|########################################################################

	.globl	___fixunsdfsi
	.globl	___fixunsdfdi
___fixunsdfsi:
___fixunsdfdi:
	movel	d2,sp@-
	movel	sp@(8),d0	| oberes Langwort der double-Zahl
	movew	sp@(12),d2	| Bit 32 - 47
	lslw	#1,d2		| alles eins nach links, Vorzeichen testen
	roxll	#1,d0
	bcs	cfud_3		| Zahl negativ -> Ergebnis null
	movew	d2,d1
	roll	#8,d0		| Exponent in d2 isolieren
	roll	#3,d0
	movew	d0,d2
	andw	#0x07ff,d2	| 11 Bit
	subw	#biasd,d2	| biasd
	bmi	cfud_3		| Exponent < 0, Ergebnis 0
	cmpw	#31,d2		| groesser 32
	bge	cfud_4		| ja, Overflow
	orb	#extend,ccr	| Extendbit setzen
	roxrl	#1,d0		| implizite 1 explizit machen
	roxrw	#1,d1		| das rausfallende bit behalten#
	andw	#0xf800,d0	| Exponent loeschen
	lsrw	#5,d1		| 11 Bit nachruecken
	orw	d1,d0
cfud_1:
	lsrl	#1,d0
	addw	#1,d2
	cmpw	#31,d2		| bis Exponent 31 schieben
	bne	cfud_1
cfud_2:
	rts
cfud_3:
	clrl	d0		| Unterlauf
	bra	cfud_2
cfud_4:
	movel	#MAXULONG,d0	| Ueberlauf
	bra	cfud_2

|
| Konvertiere long nach double-precision Fliesskomma
| Volker Seebode 10/89.
|
cif8_1:
	movew	#biasd+16,d2	| biasd, Exponent vorbesetzen
cif8_2:
	subw	#1,d2		| solange schieben bis fuehrende 1 
	lslw	#1,d0		| rausfliegt
	bcc	cif8_2
	swap	d0
	orw	d2,d0		| Exponent dazumaskieren
	rorl	#8,d0		| Form eeee eeee eeef ffff ....
	rorl	#3,d0
	roxrb	#1,d1		| Vorzeichen dazu
	roxrl	#1,d0
cif8_3:
	moveql	#0,d1
	movel	sp@+,d2
	rts
cif8_4:
	clrl	d0		| Nullergebnis
	bra	cif8_3

	.globl	___floatsidf
|	.globl	___floatdidf
___floatsidf:
|___floatdidf:
	movel	d2,sp@-
	movel	sp@(8),d0
	beq	cif8_4		| Ergebnis ist 0
	smi	d1
	bpl	clf8_1
	negl	d0
clf8_1:
	movel	d0,d2		| pruefen, ob Zahl als Integer darstellbar
	swap	d2
	tstw	d2
	beq	cif8_1
	movel	#biasd+32,d2	| biasd
clf8_2:
	subw	#1,d2
	lsll	#1,d0
	bcc	clf8_2
	swap	d2
	movew	d0,d2		| eventuell stehengebliebene Stellen
	swap	d2		| im unteren Wort von d2 merken
	andw	#0xf000,d0	| Exponenten- und Vorzeichenbits loeschen
	orw	d2,d0		| Exponenten dazu
	swap	d2
	lslw	#4,d2		| letzte Bits positionieren
	rorl	#8,d0		| swap -- roll #3
	rorl	#3,d0
	roxrb	#1,d1		| Vorzeichen einschieben
	roxrl	#1,d0
	movew	d2,d1		| fuer SOZOBON
	swap	d1
	clrw	d1
	moveml	sp@+,d2
	rts

|###############################################################
| single-precision und double-precision ineinander umwandeln,
| vergleichen oder negieren.

| Bei Ueberlauf wird MAXFLOAT zurueckgegeben.
| Denormalisierung wird noch nicht abgefangen.
|  Stack:
|		IN				OUT
|	4(a7)	double			d0.l	float

MAXFLOAT =	0x7f800000

	.globl	___truncdfsf2
___truncdfsf2:
	movel	d2,sp@-
	movel	sp@(8),d0
	beq	cff4out
	movew	sp@(12),d1
	movel	d0,d2		| Exponent in d2 pruefen
	clrw	d2
	swap	d2
	lsrw	#4,d2		| Form 0000 seee eeee eeee
	bclr	#11,d2		| Vorzeichen loeschen
	subw	#biasd-biasf,d2	| biasd-biasf
	bmi	cff4und		| Unterlauf
	cmpw	#255,d2
	bge	cff4ove		| Exponent zu gross -> Ueberlauf
	rorl	#8,d2
	lslw	#1,d1
	roxll	#1,d0
	roxrl	#1,d2
	lslw	#1,d1
	roxll	#1,d0
	lslw	#1,d1
	roxll	#1,d0
	andl	#0x007fffff,d0
	orl	d2,d0
cff4out:
	moveml	sp@+,d2
	rts
cff4und:
	clrl	d0
	bra	cff4out
cff4ove:
	andl	#0x80000000,d0
	orl	#0x7f800000,d0	| Ueberlauf
	bra	cff4out

| ___extendsfdf2. Keine Probleme.
| Stack:
|		IN				OUT
|	4(a7)	float			4(a7)	double
|
	.globl	___extendsfdf2
___extendsfdf2:
	movel	d2,sp@-
	movel	sp@(8),d0
	beq	cff8nul
	clrb	d1
	movel	d0,d2
	smi	d1
	extw	d1
	extl	d1
	swap	d2
	andw	#0x7f80,d2
	lsrw	#7,d2
	addw	#biasd-biasf,d2	| biasd-biasf
	lslw	#5,d2
	roxll	#1,d0		| Vorzeichenbit
	roxrw	#1,d2		| uebernehmen
	lsrl	#2,d0
	roxrl	#1,d1
	lsrl	#1,d0
	roxrl	#1,d1
	lsrl	#1,d0
	roxrl	#1,d1
	andl	#0x000fffff,d0
	swap	d2
	clrw	d2
	orl	d2,d0
cff8out:
	movel	sp@+,d2
	rts
cff8nul:
	clrl	d0
	clrl	d1
	bra	cff8out
	
|
| Fliesskommazahlen vergleichen.
| 	1.Operand	2.Operand	Ergebnis
|		    ==			    0L
|		    >			  > 0
|		    <			  < 0
| Stack:
|		IN				OUT
|	8(a7)	float2		
|	4(a7)	float1				D0.w
|						wird mit tst.w geprueft
	.globl	___cmpsf2
___cmpsf2:
	movel	sp@(4),d0	| fuer SOZOBON
	movel	sp@(8),d1	|
cmf4_x:
	bclr	#31,d1
	bne	cmf4_3		| zweiter Operand < 0
	bclr	#31,d0
	bne	cmf4_4		| erster Operand < 0
cmf4_1:
	subl	d1,d0		| beide sind > 0, Differenz bilden
cmf4_2:
	bmi	cmf4_4		| Ergebnis negativ -> -1 zurueckgeben
	beq	cmf4_6		| Ergebnis null -> 0 zurueckgeben
	moveq	#1,d0
cmf4_6:
	rts
cmf4_3:
	bclr	#31,d0
	bne	cmf4_5		| b: beide kleiner 0
	moveq	#1,d0
	rts
cmf4_4:
	moveq	#-1,d0		| erster Operand < 0, zweiter > 0
	rts
cmf4_5:
	exg	d0,d1
	bra	cmf4_1

	.globl	___cmpdf2
___cmpdf2:
	movel	sp@(4),d0
	movel	sp@(12),d1
	bsr	cmf4_x		| zuerst die hoeherwertigen Langworte pruefen
	beq	cmf8_2		| nur, wenn die gleich sind weiterzumachen
cmf8_1:
	rts
cmf8_2:
	movel	sp@(8),d0	| low Langwort zweiter Operand
	subl	sp@(16),d0	| low Langwort erster Operand
	beq	cmf8_1		| sind wirklich absolut gleich
	bmi	cmf8_3		| Ergebnis < 0?
	moveq	#1,d0
	bra	cmf8_4
cmf8_3:
	moveq	#-1,d0
cmf8_4:	
	btst	#7,sp@(4)	| vielleicht beide negativ?
	beq	cmf8_1		| b: nein
	negl	d0		| dann Ergebnis negieren
	rts

| ngf4, ngf8.
| Fliesskommazahlen negieren. Vorzeichenbit toggeln, wenn ungleich 0

	.globl	___negdf2
___negdf2:
	movel	sp@(4),d0	| oberes Langwort
	movel	sp@(8),d1	| unteres Langwort
	bne	doneg		| wenn ungleich 0 auf jeden Fall negieren
	tstl	d0		| wenn ungleich 0 negieren
	bne	doneg
	rts

	.globl	___negsf2
___negsf2:
	movel	sp@(4),d0
	beq	notneg
doneg:
	bchg	#31,d0
notneg:
	rts

|
| GCC benutzt diese Funktion !!!
|
	.globl	_isinf
_isinf:	clrl	d0		| vorbesetzen
	movew	sp@(4),d1	| Exponent holen
	andiw	#0x7ff0,d1	| und ausmaskieren
	cmpiw	#0x7ff0,d1	| wenn unendlich
	seq	d0		| mit 1 eins zurueck
	rts
	
| end of file

#endif /* __GNUC__ */
