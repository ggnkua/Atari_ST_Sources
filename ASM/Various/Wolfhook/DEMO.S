
* Ein einfaches Testprogramm
* Es druckt Text auf den Bildschirm, wartet auf einen Tastendruck
* und kehrt zurÅck zum Desktop
*
* Copyright (c) HiSoft 1987
*

	opt d+				Symbole fÅr's debuggen

* Die GemDos Konstanten
	include gemdos.s

* Den Text drucken

	pea string(pc)
	call_bdos c_conws
	addq.l #6,a7			Stack aufrÑumen

* Auf eine Taste warten
	
	call_bdos c_conin
	addq.l #2,a7

* und aufhîren

	call_bdos p_term

string	dc.b "Ein einfaches GemDos Programm",13,10
	dc.b "DrÅcken Sie eine Taste...",0

	even				GEMDOS mag Dateien mit gerader
*					LÑnge
