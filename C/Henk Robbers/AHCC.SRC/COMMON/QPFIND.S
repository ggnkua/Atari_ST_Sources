*		***************************************
*		**  QUICKFIND,	(c)1990 Han Driesen  **
*		**  methode  Knuth, Morris, Pratt    **
*		***************************************
* This file is part of TTDIGGER.
*
* TTDIGGER is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* TTDIGGER is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with TTDIGGER; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*

*  HR Coldfire: all registers 32 bit clean

*   long qpfind(uchar *pc, uchar *pc0);
*				a0        a1
*	I	d0		lengte van patroon
*	I	a0		begin van tekst c.q. tekst-pointer
*	I	a1		bovengrens van tekst
*	I	a2		begin van patroon
*	I	a3		tabel met pos van tekens t.o.v. eind patroon
*	I	a4		tabel met verschuivingen in patroon
*		a5,d1,d2,d3	hulpvariabelen
*	movem.l $0004(sp),d0/a0-a4	; parameters naar registers

	globl	nxk,td1,qpkl,zkey		; ex qpfind_prepare!

	globl	qpfind,qpfind_nc,aaaalower
module qpfind
*	link	a6,#0
	lea 	-20(sp),sp
	movem.l	d3/a2-a5,(sp)
*	move.l	8(a6),a2
*	move.l	12(a6),a3
*	move.l	16(a6),a4

	movea.l	zkey,a2
	lea 	td1,a3
	lea 	nxk,a4
	move.l	qpkl,d0
	suba.l	d0,a1				; corrigeer voor lengte van patroon
	clr.l	d1					; NB: hogere bytes blijven steeds 0
	move.b	(a2),d2 			; 1e teken van patroon
*
*  Hier begint de snelzoeklus
*
loop1:
	adda.l	d1,a0				; schuif tekst-pointer
loop2:
	cmpa.l	a1,a0				; nog voldoende tekst over ?
	bhi 	exit2				; nee
	move.b	-1(a0,d0.l),d1		; ja, haal teken uit tekst
	move.b	0(a3,d1.l),d1 		; pos van teken t.o.v. eind patroon
	bne 	loop1				; teken niet aan eind van patroon
*
*  Laatste teken uit patroon is nu gelokaliseerd in de tekst
*
	cmp.b	(a0)+,d2			; test eerste teken van patroon
	bne 	loop2				; mis, ga naar snelzoeklus
loop3:
	addq.l	#1,d1				; telling voor passende tekens
	cmp.b	d0,d1				; patroon afgewerkt ?
	bcc 	exit1				; ja, patroon gevonden
	move.b	(a0)+,d3			; nee, haal volgend teken uit tekst
loop4:
	cmp.b	0(a2,d1.l),d3 		; past het patroon tot zover?
	beq 	loop3				; ja, ga door
	move.b	0(a4,d1.l),d1 		; nee, raadpleeg schuiftabel
	bmi 	loop2				; geen shift: ga naar snelzoeklus
	cmpa.l	a1,a0				; voorlopige check op einde tekst
	bls 	loop4				; nauwkeuriger kijken onnodig
	lea		0(a1,d1.l),a5 		; pas bovengrens tijdelijk aan
	cmpa.l	a5,a0				; toch nog voldoende tekst over?
	bls 	loop4				; ja, probeer nieuwe positie in patroon
*
*  Het zoekproces is nu -al of niet succesvol- afgelopen
*
exit1:
	suba.l	d1,a0				; correctie voor start van patroon
exit2:
	move.l	a0,d0
	movem.l	(sp),d3/a2-a5
	lea 	20(sp),sp
*	unlk	a6
	rts

endmod


module qpfind_nc				; case insensitive version
* key must have been translated to lower case (before qpfind_prepare!!)
*	link	a6,#0
	lea 	-24(sp),sp
	movem.l	d3-d4/a2-a5,(sp)
*	move.l	8(a6),a2			; key
*	move.l	12(a6),a3			;
*	move.l	16(a6),a4

	movea.l	zkey,a2
	lea 	td1,a3
	move.l	qpkl,d0
	suba.l	d0,a1				; corrigeer voor lengte van patroon
	clr.l	d1					; NB: hogere bytes blijven steeds 0
	clr.l	d4				;****
	move.b	(a2),d2 			; 1e teken van patroon
	lea 	aaaalower,a5		;****
*
*  Hier begint de snelzoeklus
*
loop1:
	adda.l	d1,a0				; schuif tekst-pointer
loop2:
	cmpa.l	a1,a0				; nog voldoende tekst over ?
	bhi 	exit2				; nee
	move.b	-1(a0,d0.l),d1		; ja, haal teken uit tekst
	move.b	0(a5,d1.l),d1	;****  tolower
	move.b	0(a3,d1.l),d1 		; pos van teken t.o.v. eind patroon
	bne 	loop1				; teken niet aan eind van patroon
*
*  Laatste teken uit patroon is nu gelokaliseerd in de tekst
*
*	cmp.b	(a0)+,d2			; test eerste teken van patroon
	move.b  (a0)+,d4		;****
	cmp.b	0(a5,d4.l),d2	;****  tolower
	bne 	loop2				; mis, ga naar snelzoeklus
loop3:
	addq.l	#1,d1				; telling voor passende tekens
	cmp.b	d0,d1				; patroon afgewerkt ?
	bcc 	exit1				; ja, patroon gevonden
*	move.b	(a0)+,d3			; nee, haal volgend teken uit tekst
	move.b	(a0)+,d4		;****
	move.b	0(a5,d4.l),d3	;****  tolower
loop4:
	cmp.b	0(a2,d1.l),d3 		; past het patroon tot zover?
	beq 	loop3				; ja, ga door
	lea 	nxk,a4			;****
	move.b	0(a4,d1.l),d1 		; nee, raadpleeg schuiftabel
	bmi 	loop2				; geen shift: ga naar snelzoeklus
	cmpa.l	a1,a0				; voorlopige check op einde tekst
	bls 	loop4				; nauwkeuriger kijken onnodig
	lea		0(a1,d1.l),a4 		; pas bovengrens tijdelijk aan
	cmpa.l	a4,a0				; toch nog voldoende tekst over?
	bls 	loop4				; ja, probeer nieuwe positie in patroon
*
*  Het zoekproces is nu -al of niet succesvol- afgelopen
*
exit1:
	suba.l	d1,a0				; correctie voor start van patroon
exit2:
	move.l	a0,d0
	movem.l	(sp),d3-d4/a2-a5
	lea 	24(sp),sp
*	unlk	a6
	rts
endmod
