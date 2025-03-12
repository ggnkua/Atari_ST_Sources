* Assembler Tutorial 
* The Voice nr 2 by Team From The East 
* Program do wylaczania/wlaczania myszki 
* 
**** wylaczenie myszki ****

	pea	mouse_OFF(PC)		; 
	clr	-(SP)				; czysc stos
	move	#25,-(SP)		; odloz wartosc 25 na stos
							; 25 oznacza ikbdws 
							; Dla niewtajemniczonych tu oznacza
							; wylaczenie myszki (patrz section data)
	trap	#14				; wywolaj xbios
	addq.l	#8,SP			; uporzadkuj stos 

* Zobacz, ze mysz sie nie rusza

	move.l #tekst,-(sp)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

* czekaj na klawisz (te kilka instrukcji wyjasnia prg0001.s

	move.w #1,-(sp)				; dawaj 1 na stos
								; czeka na wprowadzenie
								; danej z klawiatury
								; czyli nacisniecie klawisza
								; Gemdos 1 dla fachowcow 
								; oznacza cconin
	trap #1						; tu wszystko zostaje
								; wywolane, czyli gemdos (1)
	addq.l #2,sp				; uporzadkuj stos

* Teraz wlaczamy mysz z powrotem

	pea	mouse_ON(PC)			; Jak poprzednio tylko, ze teraz 
								; wlamczamy mysz
	clr	-(SP)					; czysc stos
	move	#25,-(SP)			; ibkdws na stos
	Trap	#14					; wywolaj xbios
	addq.l	#8,SP				; uporzadkuj stos

* wychodzimy

	clr	-(SP)					; czysc stos
	Trap	#1					; bye bye
	
		SECTION	DATA		; tu umeszczamy dane

tekst:		DC.B	27,'p',10,"Zobacz czary mysz sie nie rusza",10,27,'q',0
mouse_OFF:	DC.B	18,00   ; zatrzymaj przesylanie danych z mychy
mouse_ON:	DC.B	08,00	; wlacz przesyl danych z mychy 
	