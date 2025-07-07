;************************************************************************
;* Header-Library, Programmrumpf					*
;* ½1989 by ä-soft, written by Markus Fritze	       18.06.1988 01:30 *
;************************************************************************
	  movea.l   4(sp),a6		;Basepageadresse holen
	  movea.w   #$100+$400,a5	;Gr”že der Basepage + Stackgr”že (1k)
	  adda.l    12(a6),a5		;+ Gr”že des TEXT-Segments
	  adda.l    20(a6),a5		;+ Gr”že des DATA-Segments
	  adda.l    28(a6),a5		;+ Gr”že des BSS-Segments
	  move.l    a5,d1		;= Gesamtl„nge des Programms
	  and.w     #$FFFE,d1		;L„nge nun gerade
	  add.l     a6,d1		;+ Programmstart (Basepageadresse)
	  move.l    d1,sp		;Stack endet dort
	  move.l    a5,-(sp)		;Programml„nge
	  move.l    a6,-(sp)		;Adresse der Basepage
	  move.l    #$4A0000,-(sp)	;Funktionsnummer + Dummyword (0)
	  trap	    #1			;Mshrink(0,Basepageadr,Prgl„nge)
	  lea	    12(sp),sp		;Nur noch den Stack korrigieren
;Das war schon alles. In A6 befindet sich noch die Basepageadresse und in a5
;liegt die totale Programml„nge (TRAP #1 zerst”rt D0-D2 und A0-A2!)

;Hier kann nun das eigene Programm liegen

	  clr.w     -(sp)
	  trap	    #1			;Pterm ausfhren => Programmende

