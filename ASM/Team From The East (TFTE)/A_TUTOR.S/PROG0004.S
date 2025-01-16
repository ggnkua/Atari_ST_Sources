* The Voice II by Team From The East
* Assembler Tutorial
* Program do zmiany rozdzielczosci
* wywolanie XBIOSa 5

	move.w #3,-(sp)			; odporowadzam 3 na stos dla XBIOSa
	trap #14				; XBIOS(3)
	addq.l #2,sp			; porzadek na stosie
	move.l d0,ekran			; w tym miejscu
							; zmienna ekran=XBIOS(3)
	move.w #0,-(sp)			; tu podaje rozdzielczosc (0-niska)
	move.l ekran,-(sp)		; adres ekranu na stos
	move.l ekran,-(sp)		; jeszcze raz to samo
	move.w #5,-(sp)			; 5 na stos
	trap #14				; wywolujemy XBIOS(5,L:ekran,L:ekran,0)
							; powoduje to zmiane rozdzielczosci
							; na niska (0 to niska)
	addq.l #8,sp			; jeszcze stos
	move.l #txt,-(sp)		; procedura wyswietlenia tekstu 
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	move.w #1,-(sp)			; czekaj na klawisz
	trap #1
	addq.l #2,sp
	clr.w (sp)	
	trap #1					; bye !!!

ekran:						; rezerwujemy dane dla ekranu
	ds.l	1				; ds.l 1 oznacza zarezerwuj 1 miejsce 
							; w pamieci (.l dlugie slowo czyli 4 osmio-
							; bitowe komorki
	even
txt:						; tekst
	dc.b	10,"Niska rozdzielczosc",10,0
	even

