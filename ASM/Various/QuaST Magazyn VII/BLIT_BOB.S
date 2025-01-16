***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Bobsy systemowe                                           *
* autor      :  STrych / TFTE                                             *
* inne uwagi :  320x200                                                   *
***************************************************************************

; procedura systemowa bobsow 16x16 
; coded by STRych specjalnie dla Quast Magazine
; Procedura pozwala na umieszczenie 11 Bobsow (kolek) w 1 VBLu
; Uzyto maskowania.
; Jezeli uzyjesz tej procedury pozdrow mnie (STRych)
; You can get in touch with me through INTERNET e-mail
; (e-mail) kowacz@mutos.ok.ae.wroc.pl
; Pozdrowienia dla:
;	- Marchewy for teaching me how to code
; zdecydowalem sie opisac procedure, choc niegdy tego nie robie -
; - kod jest oczywisty.

	
	move.w 	#$20,-(sp)			; suuuuuupppppeeeeeer
	trap 	#1
	addq.l 	#2,sp

	clr.w 	-(sp)				; rozdzielczosc
	pea 	-1
	pea 	-1
	move.w 	#5,-(sp)
	trap	#14
	add.l 	#12,sp
	move.l 	#tab_mov,poin		; tabela
	
disp_ball:
	move.w 	#$555,$ff8240
	move.w	#37,-(SP)			; wait for Vsync
	trap 	#14
	addq.l 	#2,SP
loki
	move.l 	poin,a0				; czytaj z tabeli
	move.w 	(a0),d0				; x
	move.w 	2(a0),d1			; y
	add.l 	#4,poin				; +1
	bsr		blit				; Blit the Ball
	cmp.w 	#0,d0				; czy koniec
	bne 	loki
	move.l 	#tab_mov,poin		; jeszcze raz
	clr.l 	d0
	clr.l 	d1
	move.w 	#$777,$ff8240
	cmp.b 	#57,$fffc02			; SPACJA - end
	bne 	disp_ball
	clr.w 	(sp)				; exit
	trap 	#1
	

; dla formalnosci uklad rejestrow po angielsku
*************************************************************************
* BLIT - Perform a blit from screen to screen. Uses, but preserves		*
* the following registers...											*
* A0 - Address of screen FROM.	(z)										*
* A1 - Address of screen TO.	(do)									*
* D0 - Left FROM			    (x1 'z')								*
* D1 - Top FROM					(y1 'z')								*
* D2 - Left TO					(x2 'do')								*
* D3 - Top TO					(y2 'do') 								*
* D4 - WIDTH					(szerokosc)								*
* D5 - HEIGHT					(wysokosc)  							*
* D6 - unused															*
* D7 - Logical Operation 												*
*************************************************************************

blit:

	move.l	d0,-(sp)			;d0 na stos
	lea		bitblt(pc),a6		;Adres 'blit table'
	move.l	#sprite+34,18(a6)	;z
	move.l	$44e,32(a6)			;do
	move	d0,28(a6)			;pozyje
	move	d1,30(a6)			;gorna
low_rez:
	move	#4,4(a6)			
	dc.w	$a007				;let's go fuck !
blit_exit:
	move.l	(sp)+,D0	
	rts							;koniec

bitblt:	
	dc.w	16					;szerokosc boba
	dc.w	16					;wyskosc
	dc.w	0					;No. Planes
	dc.w	0					;fg_col
	dc.w	0					;bg_col
	dc.b	07,07,07,07			;log. ops
	dc.w	0					;x (gorne)
	dc.w	0					;y
	dc.l	0					;Source screen top address
	dc.w	8					;(8=low 4=med)
	dc.w	160					;160 for med/low
	dc.w	2
	dc.w	0	
	dc.w	0	
	dc.l	0	
	dc.w	8					;slow w linii
	dc.w	160					;linii na planie
	dc.w	2
	dc.l	0	
	dc.w	0
	dc.w	0
	dc.w	0
	ds.b	30
	even
poin
	dc.l 0
tab_mov
	dc.w 2,10					; punkt
	dc.w 16,10					; punkt
	dc.w 32,10					; punkt
	dc.w 48,10					; punkt
	dc.w 64,10					; punkt
	dc.w 80,10					; punkt
	dc.w 96,10					; punkt
	dc.w 112,10					; punkt
	dc.w 138,10					; punkt
	dc.w 154,10					; punkt
	dc.w 0,0
sprite:
	incbin 'A:ASEMBLER.S\DANE.DAT\SPRITES.PI1'		;boby
