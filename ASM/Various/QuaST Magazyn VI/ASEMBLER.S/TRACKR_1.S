***************************************************************************
* Q u a s t  V I - programowanie w assemblerze							  *
***************************************************************************
* program  		 - TRACKER - czyli moduly w wersji na ST			  	  *
* autor    		 - autor nieznany                       	    	      *
* typ Atari		 - ST/E												      *
***************************************************************************
* Jakosc odtwarzania okolo 7.5 Mhz

START:
	pea	0
	move.w	#$20,-(sp)		* supervisor
	trap	#1
	addq.l	#6,sp
	or.w	#$700,sr

	move.l	$70.w,OLD_70	* zapamietanie starego VBLa
	move.l	#NEW_70,$70.w	* inicjacja nowego VBLa
	clr.b	$fffa13			* czyszczenie bitow zegara
	clr.b	$fffa15

	lea	DEBMOD,a1			* uruchomienie glownej procedury odgrywajacej
	lea	FINMOD,a2
	moveq	#0,d0
	bsr	PLAYER
	move.l	a0,SDTVAR
	move.w	#$2300,sr

AT:	cmp.b #57,$ffffc02		* oczekiwanie na spacje
	bne.s AT

	move.w	#$2700,sr		* zwrocenie przerwania jak i zostawienie
	move.b	#$1e,$fffa13	* w spokoju zegara
	move.b	#$64,$fffa15
	move.l	OLD_70,$70.w
	move.w	#$2300,sr
	clr.w	-(sp)
	trap	#1

NEW_70						* procedura VBLa
	move.l	SDTVAR(pc),a0
	move.l	(a0),a6
	moveq	#1,d0
	bsr	PLAYER				* skok do procedury odgrywajacej
	rte

SDTVAR:	ds.l	1			
OLD_70:	ds.l	1									* tu stary VBL
PLAYER:	incbin	"a:\asembler.s\dane.dat\tracker7.bin"	* glowna procedura
DEBMOD:	incbin	"a:\asembler.s\dane.dat\boot.mod"		* modul w pliku
FINMOD: