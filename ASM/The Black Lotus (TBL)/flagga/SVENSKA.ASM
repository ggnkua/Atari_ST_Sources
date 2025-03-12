;
;       En liten kodsnutt som visar en fullsk„rmsflagga, n„rmare best„mt
;       en svensk flagga!
;       Beh”ver en flaggbild och heter FLAGGA.DOO.
;
;       Min adress:
;               Christian Dahl
;               Fotbollsv„gen 11
;               735 37  Surahammar
;               Sweden
;
;       Skriven 910215
;

start:
        clr.l   -(sp)
        move.w  #$20,-(sp)
        trap    #1                      ; Supermode
        addq.l  #6,sp
        move.l  d0,-(sp)

        move.w  #$8240,a0               ; Kom ih†g gamla f„rger
        lea     old_color,a1
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+

        move.w  #4,-(sp)
        trap    #14                     ; Uppl”sning ??
        addq.l  #2,sp
        move.w  d0,-(sp)

        move.w  #2,-(sp)
        trap    #14                     ; Fysikaliskt bildminne ??
        addq.l  #2,sp
        move.l  d0,-(sp)
        move.l  d0,bildminne

        move.w  #2,-(sp)
        trap    #14                     ; Logiskt bildminne ??
        addq.l  #2,sp
        move.l  d0,-(sp)

        clr.w   -(sp)
        move.l  bildminne,-(sp)
        move.l  bildminne,-(sp)
        move.w  #5,-(sp)
        trap    #14                     ; L†guppl”sning
        lea     12(sp),sp

        move.l  #32000,laslangd
        move.l  bildminne,lasbuffer
        move.l  #namn2,filnamn
        bsr     ladda                   ; Ladda bild

        movem.l farg,d0-d7
        movem.l d0-d7,$ff8240
        move.l  $70,-(sp)
        move.l  $70,oldvbl
        clr.b   $fffa1b
        and.b   #$df,$fffa09
        bset    #0,$fffa07              ;  Init rutiner
        bset    #0,$fffa13
        move.l  #dummyhbl,$120
        move.b  #255,$fffa21
        move.b  #8,$fffa1b              ;  N„sta en vbl
        move.l  #resetvbl,$70

        move.l  #$00020002,-(sp)
        trap    #13                     ; V„nta p† en tangent
        addq.l  #4,sp

        move.l  (sp)+,$70               ; Tebax med systemet tack!
        move.w  #8,-(sp)
        move.w  #26,-(sp)
        trap    #14                     ; Bort med timer B
        addq.l  #4,sp
        or.b    #%01110000,$fffa09      ; Timer C & D och tang.bord ig†ng

        move.w  #5,-(sp)
        trap    #14                     ; R„tt uppl”sning
        lea     12(sp),sp

        move.w  #$8240,a1               ; Ladda upp gamla f„rger
        lea     old_color,a0
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+

        move.w  #$20,-(sp)
        trap    #1                      ; Usermode
        addq.l  #6,sp

        clr.w   -(sp)
        trap    #1                      ; Avsluta
fel:    illegal

ladda:  clr.w   -(sp)
        move.l  filnamn,-(sp)
        move.w  #$3d,-(sp)
        trap    #1                      ; ™ppna fil
        addq.l  #8,sp
        tst.l   d0
        bmi     fel
        move.w  d0,handle

        move.l  lasbuffer,-(sp)
        move.l  laslangd,-(sp)
        move.w  handle,-(sp)
        move.w  #$3f,-(sp)
        trap    #1                      ; L„s fil
        lea     12(sp),sp
        cmp.l   laslangd,d0
        bne     fel

        move.w  handle,-(sp)
        move.w  #$3e,-(sp)
        trap    #1                      ; St„ng fil
        addq.l  #4,sp
        rts

dummyhbl:
        bclr    #0,$fffa0f              ; Dummyhbl som „r till f”r att
        rte                             ; v„nta in vbl:en

resetvbl:                               ; VBL
        move.l  #resethbl,$120
        clr.b   $fffa1b                 ; V„nta n†gra rader innan det
        move.b  #80,$fffa21             ; „r dax att visa den gula randen
        move.b  #8,$fffa1b
        bclr    #0,$fffa0f
        rte

resethbl:                               ; HBL
        move.w  #$FF0,$ff8240
        clr.b   $fffa1b                 ; Ok, en gul rand horisontelt
        move.b  #41,$fffa21
        move.b  #8,$fffa1b
        move.l  #resethbl2,$120
        bclr    #0,$fffa0f
        rte

resethbl2:                              ; HBL
        move.w  #$F,$ff8240
        clr.b   $fffa1b                 ; Sluta med det gula och forts„tt
        move.b  #76,$fffa21             ; med bl†tt
        move.b  #8,$fffa1b
        move.l  #resethbl3,$120
        bclr    #0,$fffa0f
        rte

resethbl3:                              ; HBL
        move.w  #$2700,sr               ; Dax att fixa den vertikala randen
        clr.b   $fffa1b                 ; utanf”r ramarna
        move.b  #83,$fffa21
        move.b  #8,$fffa1b
        move.l  #resethbl,$120
        movem.l a1/d0-d2,-(sp)
        moveq   #120,d2
        move.w  #$8209,a1               ; Synca 68000 med videoshiftern
d40016: move.b  (a1),d0
        bpl.s   d40016
d4001a: move.b  (a1),d0
        bmi.s   d4001a
        cmpi.b  #8,d0
        beq.s   d4003e
        cmpi.b  #6,d0
        beq.s   d40050
        cmpi.b  #4,d0
        beq.s   d40060
        cmpi.b  #2,d0
        beq.s   d4006a
        cmpi.b  #0,d0
        beq.s   d40070
        nop
d4003e: move.w  $20000,$300
        move.w  $20000,$300
        bra.s   d40076
d40050: move.w  $20000,d1
        move.w  $20000,d1
        nop
d4005e: bra.s   d40076
d40060: move.w  $20000,$300
        bra.s   d40076
d4006a: move.w  $300,d1
        bra.s   d40076
d40070: bra.s   d40076
        nop
        nop
d40076:
        move.w  #71,d0                  ; Antal rader med bl†gulbl† rand
eeh1:   dbra    d0,eeh1                 ; Fasa in den bl†a
        move.w  #$FF0,$ff8240
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        move.w  #$f,$ff8240
        moveq   #34,d0
        dbra    d2,eeh1


        move.l  oldvbl,$70              ; Beh”ver inte VBLrutinen mer
        movem.l (sp)+,a1/d0-d2
        bclr    #0,$fffa0f
        rte

oldvbl: dc.l    0
handle: dc.w    0
filnamn:dc.l    0
lasbuffer:
        dc.l    0
laslangd:
        dc.l    0
bildminne:
        dc.l    0

namn2:  dc.b    'flagga.doo',0

        CNOP    0,4                     ; J„mn adress (even)

farg:
        dc.w    $0000,$000F,$0FF0,$0750,$0770,$0470,$0070,$0075
        dc.w    $0077,$0057,$0027,$0007,$0507,$0707,$0704,$0777

old_color:
        ds.w    16

        END
