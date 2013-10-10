;
; Enveloppes  SOUND3.ASM
; Assembleur
;

gemdos         = 1
xbios          = 14
giaccess       = 28


               .TEXT 

               move.w     #128+7,-(sp)  ;Ouvrir canal A
               move.w     #254,-(sp)
               move.w     #giaccess,-(sp)
               trap       #xbios
               addq.l     #6,sp

               move.w     #128+8,-(sp)  ;Volume canal A
               move.w     #16,-(sp)     ;pilot‚ par l'enveloppe
               move.w     #giaccess,-(sp)
               trap       #xbios
               addq.l     #6,sp

               move.w     #478,d6       ;Son test
               bsr        play

               move.w     #14,d7        ;Triangulaire
               move.w     #15,d6        ;P‚riode
               bsr        courbe
               bsr        wait

               move.w     #400,d6       ;Nouvelle p‚riode
               bsr        courbe
               bsr        wait

               move.w     #3000,d6
               bsr        courbe
               bsr        wait

               move.w     #8,d7         ;Dents de scie descendantes
               bsr        courbe        ;P‚riode toujours 3000
               bsr        wait

               move.w     #1,d7         ;Lin‚aire descendante
               move.w     #40000,d6     ;bien longue!
               bsr        courbe
               bsr        wait

               clr.w      d6            ;Couper son
               bsr        play

               clr.w      -(sp)         ;Fin
               trap       #gemdos


play:          move.w     d6,d5         ;Jouer R‚ 6 par le canal A

               move.w     #128,-(sp)    ;Canal A low
               move.w     d5,-(sp)
               andi.w     #$ff,(sp)     ;Seulement Bits 0 … 7
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


courbe:        move.w     #128+13,-(sp) ;Enveloppe
               move.w     d7,-(sp)
               move.w     #giaccess,-(sp)
               trap       #xbios
               addq.l     #6,sp

               move.w     d6,d5         ;P‚riode de R‚ 6

               move.w     #128+11,-(sp) ;low
               move.w     d5,-(sp)
               andi.w     #$ff,(sp)     ;Seulement bits 0 … 7
               move.w     #giaccess,-(sp)
               trap       #xbios
               addq.l     #6,sp

               move.w     #128+12,-(sp) ;high
               asr.w      #8,d5
               move.w     d5,-(sp)
               move.w     #giaccess,-(sp)
               trap       #xbios
               addq.l     #6,sp

               rts        

wait:          moveq.l    #-1,d0
l1:            moveq.l    #30,d1
l2:            dbra       d1,l2
               dbra       d0,l1
               rts        


               .END 
