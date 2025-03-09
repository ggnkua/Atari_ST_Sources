; (1) Abfrage, ob MEGA-Uhr vorhanden
FC0448:
        bpl.s   $FC0462 - $FC0448+FC0448


; (2) _bootdev richtig auslesen
FC04B8:
        move.w  $000446.l,d0


; (3) Stackpointer korrigieren in autoexec
FC0C7C:
        add.w   #12,a7
        tst.w   d0
        bne.s   $FC0CEC - $FC0C7C+FC0C7C
        move.w  #7,-(a7)
        move.l  $0984,-(a7)


; (4) Fastload
FC1516:
        moveq   #$10,d6


; (5) Intel-Format --> Motorola-Format
FC1E5E:
        move.l  4(a7),a0
        move    (a0),d0
        swap    d0
        rts
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        

; (6) Rsconf (xbios 15)
FC3A3E:
        cmp.w   #3,d0
        bhi.s   $FC3a58 - $FC3A3E+FC3A3E
        bne.s   $FC3A54 - $FC3A3E+FC3A3E
        bra.s   $FC3A50 - $FC3A3E+FC3A3E
        nop
        nop
        nop
        nop


; (7) AES: Dateinamen im Pfad finden (LINE-F: $F5DC)
FE411E:
        move.l  4(a7),a1
        move.l  a1,a2
        tst.b   (a1)+
        bne.s   $FE4124 - $FE411E+FE411E
        move.b  -(a1),d0
        cmp.l   a2,a1
        bcs.s   $FE413A - $FE411E+FE411E
        cmp.b   #$5C,d0
        beq.s   $FE413A - $FE411E+FE411E
        cmp.b   #$3A,d0
        bne.s   $FE4128 - $FE411E+FE411E
        addq.l  #1,a1
        move.l  a1,d0
        rts
        nop
        nop
        nop
        nop
        nop
