***************************************************************************
* Q u a s t  V I - programowanie w assemblerze							  *
***************************************************************************
* program  		 - Yamaha I - czyli uruchomienie analogowej muzyczki   	  *
* autor    		 - Van Eijk ( na podstawie procedury ZIPPYa )    	      *
* typ Atari		 - ST/E												      *
***************************************************************************

START:
		clr	-(sp)			* Supervisor
		move.w #32,-(sp)
		trap #1
		addq.l #2,sp

		move.l $484,pamie2
		bclr #0,$484		* wylaczenie dzwieku klawiatury
		move.l $70,pamiec	* zapamietanie wartosci starego VBLa
		moveq #1,d0			* wybor muzyczki nr.1
		bsr MUZYKA
		move.l #gramy,$70	* nasza procedura pod VBLa

CZEKAJ:	cmp.b #57,$ffffc02	* oczekiwanie na klawisz
		bne CZEKAJ			* jesli nie wcisniety to skacze do CZEKAJ
		moveq #0,d0			* wybor muzyki nr.0 co oznacza inaczej cisze
		jsr MUZYKA		
		move.b pamie2,$484		

		move.l pamiec,$70	* zwolnienie naszego przerwania
		clr	-(sp)
		trap #1				* wyjscie z programu

GRAMY:						* procedura VBLa
		movem.l d0-d7/a0-a6,-(sp)	* zapamietanie rejestrow i adresow
		jsr (MUZYKA+8)
		movem.l (sp)+,d0-d7/a0-a6	* zwrot rejestrow i adresow
		rte							* powrot z procedury

MUZYKA:	incbin "a:\asembler.s\dane.dat\big_alec.mus"

PAMIEC:	dc.l 1				* tu zapamietane jest stare VBL
PAMIE2: dc.l 1				* tu zapamietane jest brzmienie klawiatury
