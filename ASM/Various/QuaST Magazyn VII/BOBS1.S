***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Bobsy 2                                                   *
* autor      :  STrych / TFTE                                             *
* inne uwagi :  320x200                                                   *
***************************************************************************

; zaczeto 20.07.94 godz. 12.23
; zakonczono 20.07.94 godz. 13.15
; (wersja specjalna dla wszytkich ktorych wali kod)
; procedura bobsow 8x8 (position-independent)
; coded by STRych specjalnie dla Quast Magazine
; Procedura pozwala na umieszczenie 100 Bobsow (kolek) w 1 VBLu
; Uzyto maskowania.
; Wszystkie rejestry uzyte (zwieksza szybkosc)
; Jezeli uzyjesz tej procedury pozdrow mnie (STRych)
; You can get in touch with me through INTERNET e-mail
; (e-mail) kowacz@mutos.ok.ae.wroc.pl
; Pozdrowienia dla:
;	- Marchewy for teaching me how to code
; zdecydowalem sie opisac procedure, choc niegdy tego nie robie -
; - kod jest oczywisty.

ekran = $44e
klawiatura = $fffffc02

	section text

	pea 0						; supervisor
	move.w #$20,-(sp)
	trap #1
	addq.l #2,sp
			
	clr.w -(sp)					; niska rozdzielczosc
	pea -1
	pea -1
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
main_loop						; main loop
	move.w #37,-(sp)
	trap #14
	addq.l #2,sp
	moveq.l #0,d1				; clear it up
	moveq.l #0,d0

	lea tabela(pc),a0			; tabela punktow
	moveq.l #0,d2
	moveq.l #63,d7				; 63+1 punkty
gimme_point
	move.w (a0,d2.w),d0			; odczyt punktow (x-d0, y-d1)
	move.w 2(a0,d2.w),d1
	bsr bobs_rout				; rysuj bobki (haha)
	addq.l #4,d2
	dbf d7,gimme_point			; zamknij petle
	cmp.b #57,klawiatura		; if space then kiss my ass
	bne main_loop				
	bra exit					; end
exit							; koniec
	move.w #1,-(sp)
	trap #1
	addq.l #2,sp
	move.w #1,-(sp)
	pea -1
	pea -1
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
	clr.l (sp)
	trap #1
	illegal

bobs_rout
	incbin "A:ASEMBLER.S\DANE.DAT\STRYCH.DAT"

	section data

tabela							; punkty na ekranie 
								; pozycje tylko dla 64+16 bobow
	dc.w 128,68,136,68,144,68,152,68,160,68,168,68,176,68,184,68
	dc.w 128,76,136,76,144,76,152,76,160,76,168,76,176,76,184,76
	dc.w 128,84,136,84,144,84,152,84,160,84,168,84,176,84,184,84
	dc.w 128,92,136,92,144,92,152,92,160,92,168,92,176,92,184,92
	dc.w 128,100,136,100,144,100,152,100,160,100,168,100,176,100,184,100
	dc.w 128,108,136,108,144,108,152,108,160,108,168,108,176,108,184,108
	dc.w 128,116,136,116,144,116,152,116,160,116,168,116,176,116,184,116
	dc.w 128,124,136,124,144,124,152,124,160,124,168,124,176,124,184,124
	dc.w 128,132,136,132,144,132,152,132,160,132,168,132,176,132,184,132
	dc.w 128,140,136,140,144,140,152,140,160,140,168,140,176,140,184,140
