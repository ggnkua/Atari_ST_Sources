;--------------------------------------
;      Bootsektor-Passwortabfrage
;      Version 1.0
;      (c)1989 by Martin M�ller
;                 Klopstockweg 23
;                 4440 Rheine
;--------------------------------------
       move.w #$00,$482  ; no Command.Prg
       pea txt           ; Message ausgeben
       move.w #9,-(sp)   ; Print Line
       trap #1           ; do it !
       addq.l #6,sp
       pea buff          ; Puffer
       move.w #$0A,-(sp) ; Cconrs
       trap #1
       addq.l #6,sp
       move.l inp,D1     ; INPUT nach D1
       cmp.l #'1606',D1  ;
       bne.s loop
       move.w #2,-(sp)   ; 'con:'
       move.w #2,-(sp)   ; Bconin
       trap #13
       addq.l #4,sp
       clr.l D0          ; all right!
       rts               ; back!
loop:  bra.s loop
txt:   dc.b "Bitte Ihr Passwort eingeben:",$00,$00
buff:  dc.b 4
       dc.b 0
inp:   dc.b "0000","0000"
       end

 