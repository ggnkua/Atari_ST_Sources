***************************************************************************
* Q u a s t  V I - programowanie w assemblerze							  *
***************************************************************************
* program  		 - Yamaha II - czyli uruchomienie analogowej muzyczki 	  *
* autor    		 - Van Eijk											      *
* typ Atari		 - ST/E												      *
***************************************************************************
* Pod klawiszem UNDO wylaczenie muzyczki
* Pod Klawiszem HELP wlaczenie muzyczki
* Pod klawiszem '*' calkowite wygaszenie przerwania

	clr	-(sp)				* Supervisor
	move.w #32,-(sp)
	trap #1
	addq.l #2,sp
						
	bclr #0,$484			* klawiatura - cisza
	clr	$4d2.w				* wyczyszczenie wektora spod VBLa
	move.l $4d2.w,PAMIEC	* zapamietanie starego wektora

	moveq #1,d0				* inicjacja muzyczki
	jsr MUSIC	

	move.l #GRAMY,a0		* inicjacja nowego wektora pod VBLa
	move.l a0,$4d2.w

	clr	-(sp)
	trap #1					* teoretyczne wyjscie z programu

GRAMY:						* procedura pod przerwania
	jsr (MUSIC+8)	
	cmp.b #97,$ffffc02		* jesli wcisnieto UNDO to cisza
	bne DALEJ_1
	moveq #0,d0
	jsr MUSIC
DALEJ_1:					* jesli wcisnieto HELP to ponowne granie
	cmp.b #98,$ffffc02
	bne DALEJ_2
	moveq #1,d0
	jsr MUSIC
DALEJ_2:
	cmp.b #102,$ffffc02		* jesli wcisnieto '*' cisza bezpowrotnie
	bne DALEJ_3
	moveq #0,d0
	jsr MUSIC
	move.l PAMIEC,$4d2.w
DALEJ_3:
	rts

MUSIC:	incbin "a:\asembler.s\dane.dat\vcs.mus"		* muzyka w pliku
PAMIEC:	dc.l 1
