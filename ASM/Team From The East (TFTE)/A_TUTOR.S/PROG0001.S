* Assembler Tutorial 
* The Voice nr 2 by Team From The East 
* funkcje conin/conout
* GemDos posiada dwie takie funkcje
* jak conin, czyli wprowadzenia znaku
* z klawiatury (uzywany najczesciej
* w procedurach czekania na klawisz
* oraz conout, czyli wyswietlania znaku
* o podanym kodzie ascii.
* 

* pisz tekst 					; opisane w prg0002.s

	move.l #tekst,-(sp)
	move.w #9,-(sp)
	trap #1
 	addq.l #6,sp

* wyswietl kod ascii 70

	move.w #70,-(sp)			; przesli na stos kod 
								; ktory bedziemy wyswietlac
								; tu: 70
	move.w #2,-(sp)				; conout, czyli wyswietl
								; kod wczesniej przeslany na stos
								; czyli 70
	trap #1						; wywolaj GEMDOS
	addq.l #2,sp				; porzadek na stosie

* czekamy na klawisz

	move.w #1,-(sp)				; dawaj 1 na stos
								; czeka na wprowadzenie
								; danej z klawiatury
								; czyli nacisniecie klawisza
								; Gemdos 1 dla fachowcow 
								; oznacza cconin
	trap #1						; tu wszystko zostaje
								; wywolane, czyli gemdos (1)
	addq.l #2,sp				; uporzadkuj stos

* sprawdzamy klawisz

* wychodzimy

	clr	-(SP)					; czysc stos
	Trap	#1					; bye bye
	
		SECTION	DATA		; tu umeszczamy dane

tekst:		DC.B	27,'p',10,"Wyswietlamy kod ascii 70 czyli litera F",13,10,27,'q',0


	