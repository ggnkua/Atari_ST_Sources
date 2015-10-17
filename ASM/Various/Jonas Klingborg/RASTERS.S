**** Rasters on ST/STE! ****

* H„r ska jag f”rs”ka f”rklara
* ganska utf”rligt hur man g”r
* ett raster!
* F”r att g”ra ett raster
* m†ste man ha tv† interupt!
* Vertical-blanc (VBI) och 
* Horizontal-blank (HBI)!

* HBI byter f„rg p† varje rad
* och n„r HBI har gjort klart
* sitt jobb s† st„nger den av sig
* sj„lv!
* VBI „r det interupt som s„tter p†
* HBI varje 50:ndels sekund!

* Tyv„rr blir det en vandrande pinne
* som g†r ”ver rastret! Jag har aldrig
* lyckats komma underfund med vad det „r
* som orsakara den! (tyv„rr!) 


** Alla adresser och udda funktioner
** finns med i H†rdfakta!

** Let's start!

 
** G”m mus!

	dc.w	$a00a (Line-A)

** Byt till ”vervakarl„ge

	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,oldSP	Spara adress till gammal stack!	


** Rensa sk„rm

	move.l	$44e,a0
	move.l	#8000,d7
CLSloop	clr.l	(a0)+
	dbf	d7,CLSloop

** Initiera HBI-interupt!

	bset	#0,$fffa07	Avbrott m”jligt
	bclr	#0,$fffa13	Nolla avbrotts masken s† att HBI inte kan utf”ras.
*				Detta register anv„nder vi f”r att st„nga 
*				av/s„tta p† interupt!	
	move.l	#HBI,$120	L„gg rutinadress i avbrotts-vektorn!
	move.b	#2,$fffa21	Timer B:s dataregister. Nu kommer
*				avbrottet att utf”ras varannan HBI!
*				Vill du ha t„tare rasters, s† ska du „ndra h„r!
	move.b	#%1000,$fffa1b	Timer B:s kontroll-register!


** Initiera VBI-interupt

	move.l	$70,oldVBI	Spara gammalt VBI-inter. (OS-VBI)
	move.l	#VBI,$70	L„gg in v†rt eget interupt!


****** Main-program *******
* (V„ntar bara p† att man trycker tangent!)

	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7	

****** Slut!

	bclr	#0,$fffa07	HBI-avst„ngt!
	move.l	oldVBI,$70	L„gg tillbaka OS-VBI

	move.w	#$777,$ff8240	terst„ll f„rg!


** Byt till usermode!

	move.l	oldSP,-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7

** Visa mus!

	dc.w	$a009		(Line A)

** Avsluta

	clr.w	-(a7)
	trap	#1


****** Avbrotts-rutiner:

** N„r man tagit bort OS-VBI,
** s† kan man inte anv„nda
** VSYNC 37 XBIOS! D„rf”r har jag gjort
** en egen! Skriv bara JSR VSYNC!


VBI	move.w	#1,vsync	Anv„nds till min
*				VSYNC-rutin
	
	move.w	#20,rastcnt	20 f„rger i rastret! Kan du „ndra s† du f†r flera!
*				men d† m†ste du l„gga till fler f„rger till rastcol!

	move.l	#rastcol,rastpos  Flytta-rasterpekaren 
*			          till b”rjan!
	bset	#0,$fffa13	S„tt p† HBI-rutin!

	rte			Hejd†!


HBI	movem.l	a0,-(a7)	Spara register som anv„nds p† stacken!

	move.l	rastpos,a0	H„r s„tter jag
	move.w	(a0),$ff8240	f„rg och r„knar upp
	addq.l	#2,rastpos	och ner mina r„knare
	subq.w	#1,rastcnt	m.m

	bne	slut		Om r„knaren inte „r noll s† hoppa

	* R„knaren var noll = st„ng av HBI!

	bclr	#0,$fffa13

slut	movem.l	(a7)+,a0	terst„ll sparat register!
	bclr	#0,$fffa0f	Nolla p†g†ende biten. Denna s„tts n„r avbrottet
*				tillkallas men m†ste nollas av mig f”r att visa
* 				att avbrottet „r slut! (s† att ett nytt kan intr„ffa!)

	rte			hejd†!


** VSYNC rutin. V„ntar p† verticalblank!

VSYNC	cmpi.w	#1,vsync
	bne	VSYNC
	clr.w	vsync
	rts


**** Datas

oldVBI	dc.l	0
oldSP	dc.l	0
vsync	dc.w	0

rastcnt	dc.w	0
rastpos	dc.l	rastcol

rastcol	dc.w	$000,$110,$220,$330,$440,$550,$660,$770,$660,$550,$440,$330,$220,$110,$000,$000,$000,$000,$000,$000,$000,$000