* 256b 68K Inside promo, Emphii / eXtream, 06.03.2024 - 14.03.2024

* Puhtaasti GEM/TOS yhteensopiva, joten pitaisi toimia kaikilla Atareilla,
* kaikilla resoluutioilla, toisilla nopeammin kuin toisilla.

* Britelite / Dekadence tilaama 256b intro mainostamaan 256b compoa
* 68K Inside partyilla 24. - 26.5.2024 Aulangolla

* PRESS SPACE TO EXIT *


RELEASE	= 1

		IFNE	RELEASE
		opt	d-
		ENDC

		opt	o+,ow-
		opt	p=68000


		section TEXT

*******
extream		
		IFNE	RELEASE
		dc.w	$a000			; (2) seiftaa hiiren pois
		dc.w	$a00a			; (2) jos ajetaan GEMssä
		ENDC

		lea	textSpace(pc),a0	; (4)
		move.w	#$2020,d0		; (4) tayta spacella
		moveq	#256/2-1,d7		; (2)
.preploop	move.w	d0,(a0)+		; (2)
		dbra	d7,.preploop		; (4)

		lea	-216(a0),a0		; (4) jatetaan 40 ekaa merkkia tyhjaksi
		lea	teksti(pc),a1		; (4)
		moveq	#84-1,d7		; (2) lisaa teksti
.prep2loop	move.b	(a1)+,(a0)+		; (2)
		dbra	d7,.prep2loop		; (4)

		move.l	a1,a6			; (2) sinikappyran alku


main		move.w	#37,-(sp)		; (4) vsync
		trap	#14			; (2)
		
		pea	tbuf(pc)		; (4) tulosta tekstirivi
		move.w	#9,-(sp)		; (4)
		trap	#1			; (2)
		addq.l	#8,sp			; (2) vsyncin 2 ja tulostuksen 6

		and.w	#16-1,d5		; (4) palauta siniptr alkuun
		and.w	#128-1,d6		; (4) palauta tekstiptr alkuun
		
		moveq	#37-1,d7		; (2) luo uusi tekstirivi (skrollaus)
		lea	tbuf+10(pc),a1		; (4) kohde
		lea	textSpace(pc),a3	; (4) lahde
		add.w	d6,a3			; (2)
.tloop		move.b	(a3)+,(a1)+		; (2)
		dbra	d7,.tloop		; (4)

		add.b	(a6,d5.w),d6		; (4) lisaa sini tekstiptraan

		addq.w	#1,d5			; (2) paivita siniptr
		addq.w	#1,d6			; (2) paivita tekstiptr

******* Space painettu?
		move.w	#$ff,-(sp)		; (4)
		move.w	#6,-(sp)		; (4)
		trap	#1			; (2)
		addq.l	#4,sp			; (2)
		
		cmp.b	#32,d0			; (4) Spazce?
		bne.s	main			; (2) ei
******* Space painettu?
		

Logout
		IFNE	RELEASE
		dc.w	$a009			; (2) palauttaa hiiren
		ENDC
		
		clr.w	-(sp)			; (2)
		trap	#1			; (2)


		section DATA

		EVEN
teksti		dc.b	'HOX! We have a 256b compo in 68K Inside   '
		dc.b	'        More info https://68k-inside.party' ; (84)

sini		dc.b	-1,0,0,1		; (16)
		dc.b	2,1,1,0
		dc.b	-1,-1,-2,-3
		dc.b	-3,-2,-2,-1

tbuf		dc.b	27,'f',27,'H',27,'M',27,'Y',(32+24),32	; VT52 sekvenssi
						; (10) curs off+home+del line+curs yx

		section	BSS

		EVEN
tbuf2		ds.l	40/4
textSpace	ds.l	256/4
