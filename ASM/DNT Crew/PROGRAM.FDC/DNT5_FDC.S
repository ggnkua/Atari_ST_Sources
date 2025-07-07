;Lecture du boot sector
;a l'adresse _bufbpb
;par Dr Clone/Radiation
;ceci est juste une routine et non pas un programme autonome
;il faut l'appeler en superviseur
;elle fini par un RTS


read_boot

        move    sr,-(a7)                ;sauve le sr
        movem.l d0-a6,-(a7)             ;sauve les registres
        move    #$2700,sr               ;stoppe les inters
        movea.w #$8604,a0               ;a0=$ffff8604
        lea     2(a0),a1                ;a1=$ffff8606
        move.l  #$0e0e2525,$1fc(a0)     ;face 1
        moveq   #1,d7
        moveq   #1,d0
        bsr     send_command            ;restore (on se place piste 00)
        move.l  $4c6.w,a2               ;adresse de chargement
        move.l  a2,d6
        bsr     set_dma
        move.w  #$90,(a1)
        move.w  #$190,(a1)
        move.w  #$90,(a1)               ;dma en lecture
        move    d7,(a0)                 ;512 octets (1)
        divu    d7,d7
        move.w  #$84,(a1)               ;select sector reg
        move    d7,(a0)                 ;secteur 1
        divu    d7,d7
        move.w  #$80,d0
        bsr     send_command            ;read a sector
motor   move.w  (a0),d0
        btst    #7,d0
        bne.s   motor                   ;attend motor off
        movem.l (a7)+,d0-a6
        move    (a7)+,sr
        rts
send_command
        move.w  #$80,(a1)               ;select commande reg
        divu    d7,d7
        move.w  d0,(a0)                 ;envoie la commande d‚sir‚e
wait_fdc
        btst    #5,$73fd(a0)
        bne.s   wait_fdc
        rts
set_dma move.b  d6,9(a0)
        lsr.l   #8,d6
        move.b  d6,7(a0)
        lsr.l   #8,d6
        move.b  d6,5(a0)
        rts
        
        end
                
