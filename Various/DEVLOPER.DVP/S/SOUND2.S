;
; Cr‚er un son en variant la p‚riode
; Assembleur           	SOUND2.S
;

gemdos         = 1
xbios          = 14
giaccess       = 28


               SECTION TEXT 

               move.w     #128+7,-(sp)  ;Activer canal A
               move.w     #254,-(sp)
               move.w     #giaccess,-(sp)
               trap       #xbios
               addq.l     #6,sp

               move.w     #128+8,-(sp)  ;Volume canal A
               move.w     #15,-(sp)     ;augmenter volume
               move.w     #giaccess,-(sp)
               trap       #xbios
               addq.l     #6,sp

               moveq.l    #4,d7         ;5 passes

loop:          move.w     #4000,d6      ;Valeur initiale de la p‚riode
l1:            bsr        play          ;Jouer le son
               subq.w     #1,d6         ;Descendre de un
               cmpi.w     #500,d6       ;Valeur finale?
               bne.s      l1

l2:            bsr        play          ;Jouer
               addq.w     #1,d6
               cmpi.w     #4000,d6      ;Encore tout en haut?
               bne.s      l2

               dbra       d7,loop       ;Cinq fois SVP

               clr.w      d6            ;Couper le son
               bsr        play

               clr.w      -(sp)         ;Fin
               trap       #gemdos


play:          move.w     d6,d5         ;Jouer le R‚6 sur le canal A

               move.w     #128,-(sp)    ;Canal A low
               move.w     d5,-(sp)
               andi.w     #$ff,(sp)     ;Bits 0 … 7 seulement
               move.w     #giaccess,-(sp)
               trap       #xbios
               addq.l     #6,sp

               move.w     #128+1,-(sp)  ;Canal A high
               asr.w      #8,d5
               move.w     d5,-(sp)
               move.w     #giaccess,-(sp)
               trap       #xbios
               addq.l     #6,sp

               rts        

               END 
