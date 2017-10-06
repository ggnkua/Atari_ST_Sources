
;**************************************************************************
;*
;*      EXTENSION COMPILATEUR
;*
;*      (c) FL Soft 1989
;*
;**************************************************************************

;**************************************************************************

; STOS BASIC INTERFACE
even
        bra load                ; JUMP TO FIRST CALL AFTER LOAD

        dc.b $80   
tokens: dc.b 13
	dc.b "***************************************",13,10
	dc.b "*                                     *",13,10
	dc.b "*          COMPILED PROGRAM           *",13,10
	dc.b "*                                     *",13,10
	dc.b "*      Don't change line 65535!       *",13,10
	dc.b "*                                     *",13,10
	dc.b "***************************************",13,10
	dc.b $80
        dc.b "compad",$81
	dc.b "comptest off",$82
	dc.b "comptest on",$84
	dc.b "comptest always",$86
	dc.b "comptest",$88
	dc.b 0

; Table of jumps related to the tokens
even
jumps:  dc.w 9                  ;Number of jumps
        dc.l run,compad
	dc.l rien,0
	dc.l rien,0
	dc.l rien,0
	dc.l rien

; Welcome message, in two languages, 40 char max.
welcome:dc.b 10,"COMPILER installed",0
        dc.b 10,"COMPILATEUR pr‚sent",0
        dc.b 0

even
table:	dc.l 0
return: dc.l 0

;**************************************************************************
;       INITIALISATION ROUTINES
;**************************************************************************

load:   lea finprg,a0           ;A0---> end of the extension
        lea cold,a1             ;A1---> adress of COLD START routine
        rts

cold:   move.l a0,table         ;INPUT: basic table adress
        lea welcome,a0          ;OUTPUT:        A0= welcome message
        lea warm,a1             ;               A1= warm start
        lea tokens,a2           ;               A2= token table
        lea jumps,a3            ;               A3= jump table
        rts   
rien:
warm:   rts

;************************************************************************
;       INTERFACE ROUTINES
;**************************************************************************

;-----> Appel du programme en langage machine
run:    move.l (sp)+,return             ;Return address
	movem.l a4-a6,-(sp)		;Pousse les registres importants
; Trouve le debut du programme
run1:	add.w (a5),a5			;Cherche la derniere ligne
	tst.w (a5)
	bne.s run1
	addq.l #2,a5			;Saute le 0
	move.l Table,a0			;Adresse de la table
	jsr (a5)			;Appelle le prg
; Fin du programme
finrun:	movem.l (sp)+,a4-a6
end:    move.l return,a0
        jmp (a0)

;-----> FONCTION: ramene l'adresse de la table des vecteurs
CompAd:	clr.b d2
	move.l table,d3
	rts
           
;************************************************************************
;       END OF THE PROGRAM
;************************************************************************

        dc.l 0
finprg: equ *


