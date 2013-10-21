;
; Algorithmes de division pour le DSP 56001
;

; ces routines proviennent du DSP User's Manual.


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Division complete:
; Op‚randes sign‚es
; Qutient sur 24 bits sign‚s
; Reste sur 48 bits sign‚s

; Entr‚e:
;  A contient le dividende sur 48 bits sign‚s
;  X0 contient le diviseur sur 24 bits sign‚s
; Sortie
;  B contient le reste sur 48 bits sign‚s
;  X1 contient le quotient
;
; Routine valable pour |A|<|X0|

div24	abs a		a,b	; dividende positif, sauve a1 dans b1
	eor x0,b	b,y0	; signe du quotient dans b,  sauve le signe du reste, 
	and #$fe,ccr		; efface la carry
	rep #24			; repete 24 fois
	div x0,a		; quotient dans a0, reste dans a1
	tfr a,b			; copie a dans b
	jpl savequo		; si le quotient est positif
	neg b			; sinon prends l'oppos‚ de b
savequo	tfr x0,b	b0,x1	; recupere le diviseur, sauve le quotient dans x1
	abs b			; valeur absolue du diviseur
	add a,b			; restauration du reste
	jclr #23,y0,done	; si le reste est negatif
	move #0,b0		; sinon b0 n'est pas significatif
	neg b			; et on prend l'oppos‚ du reste
done				; Ouf, c'est fini !


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Idem, mais ici les op‚randes doivent etre POSITIVES !

; Entree:
;  A contient le dividende sur 48 bits (positif)
;  x0 contient le diviseur sur 24 bits (positif)
; Sortie:
;  a0 contient le quotient sur 24 bits (positif)
;  a1 contient le reste sur 24 bits (positif)

div24p	and #$fe,ccr
	rep 24		; 24 bits
	div x0,a	; division
	add x0,a	; restauration du reste
done			; c'est beaucoup plus simple !

