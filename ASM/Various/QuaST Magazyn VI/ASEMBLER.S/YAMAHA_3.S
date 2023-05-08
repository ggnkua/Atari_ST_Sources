***************************************************************************
* Q u a s t  V I - programowanie w assemblerze							  *
***************************************************************************
* program  		 - Yamaha III- czyli muzyczki analogowa z kanalem digi	  *
* autor    		 - Vat   											      *
* typ Atari		 - ST/E												      *
***************************************************************************
* Muzyczki mozesz zmieniac klawiszami od F1 do F10

START:
	clr.l	-(sp)				* Supervisor
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
							
	bclr	#0,$484.w			* klawiatura -cisza
	lea	STORE(pc),a0			* zapamietanie woktorow przerwan 
	move.l	$70.w,(a0)+		
	move.l	$114.w,(a0)+				
	move.b	$fffffa09.w,(a0)+	* zapamietania wartosci zegara 
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa1d.w,(a0)+
						
	moveq	#1,d0				* inicjacja muzyki
	bsr	MUSIC
	bsr MUSIC+8
	bclr	#3,$fffffa17.w	    * automatyczne MFP
	move.l	#INT,$70.w		    * procedura INT do VBLa

PP: cmp.b #57,$fffc02			* oczekiwanie na klawisz
	bne PP
	move.w	#$2700,sr	
	lea	STORE(pc),a0			* zwrocenie starych wartsoci przerwan
	move.l	(a0)+,$70.w			*  i starych wartsoci zegara 
	move.l	(a0)+,$114.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa1d.w
	lea	$ffff8800.w,a0
	move.l	#$0707ffff,(a0)		* wyciszenie dywieku
	move.l	#$08080000,(a0)
	move.l	#$0909ffff,(a0)
	move.l	#$0a0a0000,(a0)
	move.b	#$c0,$fffffa23.w    * powtarzanie klawiatury
	bset	#0,$484.w			* klawiatura z dzwiekiem
	move.w	(sp)+,sr			
	clr.w	-(sp)
	trap	#1					* wyjscie z programu
							
INT:	
		movem.l	d0-d7/a0-a6,-(a7)	* zapamietanie 
		bsr	(MUSIC+4)	
KKK1:	cmp.b #59,$fffc02
		bne KKK2
		moveq	#1,d0
		bsr	MUSIC
		bsr MUSIC+8
KKK2:	cmp.b #60,$fffc02
		bne KKK3
		moveq	#2,d0
		bsr	MUSIC
		bsr MUSIC+8
KKK3:	cmp.b #61,$fffc02
		bne KKK4
		moveq #3,d0
		bsr	MUSIC
		bsr MUSIC+8
KKK4:	cmp.b #62,$fffc02
		bne KKK5
		moveq	#4,d0
		bsr	MUSIC
		bsr MUSIC+8
KKK5:	cmp.b #63,$fffc02
		bne KKK6
		moveq	#5,d0
		bsr	MUSIC
		bsr MUSIC+8
KKK6:	cmp.b #64,$fffc02
		bne KKK7
		moveq	#13,d0
		bsr	MUSIC
		bsr MUSIC+8
KKK7:	cmp.b #65,$fffc02
		bne KKK8
		moveq	#7,d0
		bsr	MUSIC
		bsr MUSIC+8
KKK8:	cmp.b #66,$fffc02
		bne KKK9
		moveq	#11,d0
		bsr	MUSIC
		bsr MUSIC+8
KKK9:	cmp.b #67,$fffc02
		bne KKK0
 		moveq	#9,d0
		bsr	MUSIC
		bsr MUSIC+8
KKK0:	cmp.b #68,$fffc02
		bne KK10
 		moveq	#10,d0
		bsr	MUSIC
		bsr MUSIC+8
KK10:
		movem.l	(a7)+,d0-d7/a0-a6
		rte

STORE:	ds.l	4				* tu zapamietane sa stare wartosci zegara
MUSIC:	incbin	"a:asembler.s\dane.dat\wingsd.mus"		*   plik z muzyka
