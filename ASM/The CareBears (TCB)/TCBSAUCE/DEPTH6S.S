org     $8000
load    $80000


x:      bra     main


hsync1:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync2,$120.w
        rte

hsync2:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync3,$120.w
        rte

hsync3:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync4,$120.w
        rte

hsync4:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync5,$120.w
        rte

hsync5:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync6,$120.w
        rte

hsync6:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync7,$120.w
        rte

hsync7:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync8,$120.w
        rte

hsync8:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync9,$120.w
        rte

hsync9:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync10,$120.w
        rte

hsync10:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync11,$120.w
        rte

hsync11:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync12,$120.w
        rte

hsync12:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync13,$120.w
        rte

hsync13:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync14,$120.w
        rte

hsync14:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync15,$120.w
        rte

hsync15:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync16,$120.w
        rte

hsync16:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync17,$120.w
        move.l  a0,-(sp)
        move.l  a1,-(sp)
        lea     $ffff8240,a1
        lea     palette2(pc),a0
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (sp)+,a1
        move.l  (sp)+,a0
        rte

palette2:
        dc.w    $0000,$0760,$0750,$0640,$0530,$0420,$0310,$0003   

hsync17:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync18,$120.w
        rte

hsync18:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync19,$120.w
        rte

hsync19:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync20,$120.w
        rte

hsync20:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync21,$120.w
        rte

hsync21:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync22,$120.w
        rte

hsync22:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync23,$120.w
        rte

hsync23:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync24,$120.w
        rte

hsync24:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        move.l  #hsync25,$120.w
        move.l  a0,-(sp)
        move.l  a1,-(sp)
        lea     $ffff8240,a1
        lea     palette3(pc),a0
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (sp)+,a1
        move.l  (sp)+,a0
        rte

palette3:
        dc.w    $0000,$0310,$0421,$0532,$0643,$0754,$0407,$0707

hsync25:
        move.l  (a5),(a6)
        move.l  (a5),4(a6)
        move.l  (a5),8(a6)
        move.l  (a5)+,12(a6)
        bclr    #0,$77bf(a6)
        rte



dummyhs:
        bclr    #0,$77bf(a6)
        rte     

hsyncstart:
        move.l  #hsyncstart2,$120
        move.b  #5,$fffa21
        bclr    #0,$77bf(a6)
        rte

hsyncstart2:
        move.l  #hsync3,$120
        bclr    #0,$77bf(a6)
        rte

setints:
        move.w  #$2700,sr
;        move.l  $70,oldvsync
        move.l  #vsync,$70
        move.b  $fffa07,mfpiea
        move.b  $fffa09,mfpieb
;        move.b  $fffa1b,mfptbc
;        move.b  $fffa21,mfptbd
;        move.l  $120,oldtimb

        lea     coltab(pc),a5
        lea     $ff8250,a6

        move.w  #$2300,sr
        clr.b   vflag
omsi1:  tst.b   vflag
        beq     omsi1
        move.l  #dummyhs,$120
        bset    #0,$fffa07
        bset    #0,$fffa13
        bclr    #0,$fffa09
        move.b  #1,$fffa21
        move.b  #8,$fffa1b
        clr.b   vflag
omsi2:  tst.b   vflag
        beq     omsi2
        move.w  #$2700,sr

        move.l  #hsyncstart,$120
        bset    #0,$fffa07
        bset    #0,$fffa13
        bclr    #0,$fffa09
;        move.b  #1,$fffa07
;        move.b  #1,$fffa13
;        move.b  #0,$fffa09
        move.b  #4,$fffa21
        move.b  #8,$fffa1b
        lea     coltab(pc),a5
        lea     $ff8250,a6
        move.w  #$2300,sr
        rts

retints:
        move.w  #$2700,sr
;        move.l  oldvsync,$70
        move.b  mfpiea,$fffa07
        move.b  mfpieb,$fffa09
;        move.b  mfptbc,$fffa1b
;        move.b  mfptbd,$fffa21
;        move.l  oldtimb,$120
        move.w  #$2500,sr
        rts





hsyn:   bsr     hsyn
        bclr    #0,$fffa0f
        rte


vsync:  st      vflag
        movem.l d0-d7/a0-a6,-(sp)
        jsr     $6e860
        movem.l (sp)+,d0-d7/a0-a6
        lea     coltab(pc),a5
        move.b  #8,$fffa1b
        move.l  #hsync1,$120
        move.b  #5,$fffa21
        move.l  a0,-(sp)
        move.l  a1,-(sp)
        lea     $ff8240,a1
        lea     palette1(pc),a0
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (sp)+,a1
        move.l  (sp)+,a0
        rte

palette1:
        dc.w    $000,$210,$321,$432,$543,$654,$012,$023




oldvsync:
        dc.l    1
mfpiea: dc.w    1
mfpieb: dc.w    1
mfptbc: dc.w    1
mfptbd: dc.w    1
oldtimb:
        dc.l    1




tsplus: move.l  d7,-(sp)
        add.l   d4,d1
        move.l  #160,d7
        sub.l   d4,d7
        asr.w   #3,d7
        subq.w  #1,d7
        tst.w   d7
        bmi     forbitsp1


        move.l  d3,d4
        lsl.l   #3,d2
        add.l   d2,d4
        lsl.w   #3,d4
        add.l   d4,d0
        lsl.l   #2,d0
        move.l  (a1,d0.w),a0
        lsl.w   #1,d3
        add.w   #17,d3
        move.l  currpicadd,a1
        add.l   d1,a1
        move.l  d3,d0
        cmp.w   #1,d7
        beq     forbitsp2
omtsp1: movem.w (a0)+,d1-d3
        or.w    d1,6(a1)
        lea     160(a1),a1
        dbra    d0,omtsp1
        bra     forbitsp3
forbitsp2:
omtsp2: movem.w (a0)+,d1-d3
        or.w    d1,6(a1)
        or.w    d2,14(a1)
        lea     160(a1),a1
        dbra    d0,omtsp2
forbitsp3:
forbitsp1:
        move.l  (sp)+,d7
        movem.l (sp)+,d4/a0-a1
        move.w  #$000,$ff8240
        rts




tsminus:
        move.l  d7,-(sp)
        add.w   #24,d4
        asr.w   #3,d4
        subq.w  #1,d4
        move.w  d4,d7
        tst.w   d7
        bmi     forbitsm1


        move.l  d3,d4
        lsl.l   #3,d2
        add.l   d2,d4
        lsl.w   #3,d4
        add.l   d4,d0
        lsl.l   #2,d0
        move.l  (a1,d0.w),a0
        lsl.w   #1,d3
        add.w   #17,d3
        move.l  currpicadd,a1
        add.l   d1,a1
        move.l  d3,d0
        cmp.w   #1,d7
        beq     forbitsm2
omtsm1: movem.w (a0)+,d1-d3
        or.w    d3,6(a1)
        lea     160(a1),a1
        dbra    d0,omtsm1
        bra     forbitsm3
forbitsm2:
omtsm2: movem.w (a0)+,d1-d3
        or.w    d2,6(a1)
        or.w    d3,14(a1)
        lea     160(a1),a1
        dbra    d0,omtsm2
forbitsm3:
forbitsm1:
        move.l  (sp)+,d7
        movem.l (sp)+,d4/a0-a1
        rts


; x in d0
; y in d1
; charnr in d2
; charsize in d3
testsprite:
        movem.l d4/a0-a1,-(sp)
        lea     fontadds(pc),a1
        sub.w   #24,d0
        sub.w   d3,d1
        move.l  d0,d4
        and.w   #15,d0
        lsr.w   #1,d0
        lea     tab160,a0
        lsl.w   #2,d1
        move.l  (a0,d1.w),d1
        asr.w   #1,d4
        and.w   #$fff8,d4
        tst.w   d4
        bmi     tsminus
        cmp.w   #136,d4
        bgt     tsplus
        add.l   d4,d1

        move.l  d3,d4
        lsl.l   #3,d2
        add.l   d2,d4
        lsl.w   #3,d4
        add.l   d4,d0
        lsl.l   #2,d0

; new routs
        move.l  d0,-(sp)
        move.l  d5,-(sp)
        move.l  a2,-(sp)

        lsl.w   #2,d3
        lea     routsizetab(pc),a0
        move.l  (a0,d3.w),a2

; end new routs

        move.l  (a1,d0.w),a0
        move.l  currpicadd,a1
        add.l   d1,a1

        movem.w (a0)+,d0-d5
        or.w    d0,6(a1)
        or.w    d1,14(a1)
        or.w    d2,22(a1)
        or.w    d3,166(a1)
        or.w    d4,174(a1)
        or.w    d5,182(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,326(a1)
        or.w    d1,334(a1)
        or.w    d2,342(a1)
        or.w    d3,486(a1)
        or.w    d4,494(a1)
        or.w    d5,502(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,646(a1)
        or.w    d1,654(a1)
        or.w    d2,662(a1)
        or.w    d3,806(a1)
        or.w    d4,814(a1)
        or.w    d5,822(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,966(a1)
        or.w    d1,974(a1)
        or.w    d2,982(a1)
        or.w    d3,1126(a1)
        or.w    d4,1134(a1)
        or.w    d5,1142(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,1286(a1)
        or.w    d1,1294(a1)
        or.w    d2,1302(a1)
        or.w    d3,1446(a1)
        or.w    d4,1454(a1)
        or.w    d5,1462(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,1606(a1)
        or.w    d1,1614(a1)
        or.w    d2,1622(a1)
        or.w    d3,1766(a1)
        or.w    d4,1774(a1)
        or.w    d5,1782(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,1926(a1)
        or.w    d1,1934(a1)
        or.w    d2,1942(a1)
        or.w    d3,2086(a1)
        or.w    d4,2094(a1)
        or.w    d5,2102(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,2246(a1)
        or.w    d1,2254(a1)
        or.w    d2,2262(a1)
        or.w    d3,2406(a1)
        or.w    d4,2414(a1)
        or.w    d5,2422(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,2566(a1)
        or.w    d1,2574(a1)
        or.w    d2,2582(a1)
        or.w    d3,2726(a1)
        or.w    d4,2734(a1)
        or.w    d5,2742(a1)

        jsr     (a2)

        move.l  (sp)+,a2
        move.l  (sp)+,d5
        move.l  (sp)+,d0

        movem.l (sp)+,d4/a0-a1
        rts

routsizetab:
        dc.l    size0rout,size1rout,size2rout,size3rout
        dc.l    size4rout,size5rout,size6rout,size7rout


size0rout:
        rts

size1rout:
        movem.w (a0)+,d0-d5
        or.w    d0,2886(a1)
        or.w    d1,2894(a1)
        or.w    d2,2902(a1)
        or.w    d3,3046(a1)
        or.w    d4,3054(a1)
        or.w    d5,3062(a1)
        rts

size2rout:
        movem.w (a0)+,d0-d5
        or.w    d0,2886(a1)
        or.w    d1,2894(a1)
        or.w    d2,2902(a1)
        or.w    d3,3046(a1)
        or.w    d4,3054(a1)
        or.w    d5,3062(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3206(a1)
        or.w    d1,3214(a1)
        or.w    d2,3222(a1)
        or.w    d3,3366(a1)
        or.w    d4,3374(a1)
        or.w    d5,3382(a1)
        rts

size3rout:
        movem.w (a0)+,d0-d5
        or.w    d0,2886(a1)
        or.w    d1,2894(a1)
        or.w    d2,2902(a1)
        or.w    d3,3046(a1)
        or.w    d4,3054(a1)
        or.w    d5,3062(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3206(a1)
        or.w    d1,3214(a1)
        or.w    d2,3222(a1)
        or.w    d3,3366(a1)
        or.w    d4,3374(a1)
        or.w    d5,3382(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3526(a1)
        or.w    d1,3534(a1)
        or.w    d2,3542(a1)
        or.w    d3,3686(a1)
        or.w    d4,3694(a1)
        or.w    d5,3702(a1)
        rts

size4rout:
        movem.w (a0)+,d0-d5
        or.w    d0,2886(a1)
        or.w    d1,2894(a1)
        or.w    d2,2902(a1)
        or.w    d3,3046(a1)
        or.w    d4,3054(a1)
        or.w    d5,3062(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3206(a1)
        or.w    d1,3214(a1)
        or.w    d2,3222(a1)
        or.w    d3,3366(a1)
        or.w    d4,3374(a1)
        or.w    d5,3382(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3526(a1)
        or.w    d1,3534(a1)
        or.w    d2,3542(a1)
        or.w    d3,3686(a1)
        or.w    d4,3694(a1)
        or.w    d5,3702(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3846(a1)
        or.w    d1,3854(a1)
        or.w    d2,3862(a1)
        or.w    d3,4006(a1)
        or.w    d4,4014(a1)
        or.w    d5,4022(a1)
        rts

size5rout:
        movem.w (a0)+,d0-d5
        or.w    d0,2886(a1)
        or.w    d1,2894(a1)
        or.w    d2,2902(a1)
        or.w    d3,3046(a1)
        or.w    d4,3054(a1)
        or.w    d5,3062(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3206(a1)
        or.w    d1,3214(a1)
        or.w    d2,3222(a1)
        or.w    d3,3366(a1)
        or.w    d4,3374(a1)
        or.w    d5,3382(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3526(a1)
        or.w    d1,3534(a1)
        or.w    d2,3542(a1)
        or.w    d3,3686(a1)
        or.w    d4,3694(a1)
        or.w    d5,3702(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3846(a1)
        or.w    d1,3854(a1)
        or.w    d2,3862(a1)
        or.w    d3,4006(a1)
        or.w    d4,4014(a1)
        or.w    d5,4022(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,4166(a1)
        or.w    d1,4174(a1)
        or.w    d2,4182(a1)
        or.w    d3,4326(a1)
        or.w    d4,4334(a1)
        or.w    d5,4342(a1)
        rts

size6rout:
        movem.w (a0)+,d0-d5
        or.w    d0,2886(a1)
        or.w    d1,2894(a1)
        or.w    d2,2902(a1)
        or.w    d3,3046(a1)
        or.w    d4,3054(a1)
        or.w    d5,3062(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3206(a1)
        or.w    d1,3214(a1)
        or.w    d2,3222(a1)
        or.w    d3,3366(a1)
        or.w    d4,3374(a1)
        or.w    d5,3382(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3526(a1)
        or.w    d1,3534(a1)
        or.w    d2,3542(a1)
        or.w    d3,3686(a1)
        or.w    d4,3694(a1)
        or.w    d5,3702(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3846(a1)
        or.w    d1,3854(a1)
        or.w    d2,3862(a1)
        or.w    d3,4006(a1)
        or.w    d4,4014(a1)
        or.w    d5,4022(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,4166(a1)
        or.w    d1,4174(a1)
        or.w    d2,4182(a1)
        or.w    d3,4326(a1)
        or.w    d4,4334(a1)
        or.w    d5,4342(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,4486(a1)
        or.w    d1,4494(a1)
        or.w    d2,4502(a1)
        or.w    d3,4646(a1)
        or.w    d4,4654(a1)
        or.w    d5,4662(a1)
        rts

size7rout:
        movem.w (a0)+,d0-d5
        or.w    d0,2886(a1)
        or.w    d1,2894(a1)
        or.w    d2,2902(a1)
        or.w    d3,3046(a1)
        or.w    d4,3054(a1)
        or.w    d5,3062(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3206(a1)
        or.w    d1,3214(a1)
        or.w    d2,3222(a1)
        or.w    d3,3366(a1)
        or.w    d4,3374(a1)
        or.w    d5,3382(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3526(a1)
        or.w    d1,3534(a1)
        or.w    d2,3542(a1)
        or.w    d3,3686(a1)
        or.w    d4,3694(a1)
        or.w    d5,3702(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,3846(a1)
        or.w    d1,3854(a1)
        or.w    d2,3862(a1)
        or.w    d3,4006(a1)
        or.w    d4,4014(a1)
        or.w    d5,4022(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,4166(a1)
        or.w    d1,4174(a1)
        or.w    d2,4182(a1)
        or.w    d3,4326(a1)
        or.w    d4,4334(a1)
        or.w    d5,4342(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,4486(a1)
        or.w    d1,4494(a1)
        or.w    d2,4502(a1)
        or.w    d3,4646(a1)
        or.w    d4,4654(a1)
        or.w    d5,4662(a1)
        movem.w (a0)+,d0-d5
        or.w    d0,4806(a1)
        or.w    d1,4814(a1)
        or.w    d2,4822(a1)
        or.w    d3,4966(a1)
        or.w    d4,4974(a1)
        or.w    d5,4982(a1)

        rts








scrollback:
        lea     backposs(pc),a0
        moveq   #15,d0
        move.l  currpicadd,a2
        move.l  a2,a4
        lea     19200(a2),a2
        lea     12800(a4),a4
;       lea     shiftedblocks,a1
        lea     shiftedblocksadds,a1
        move.l  a1,spar1
ommb1:  move.l  (a0)+,d1
        lsr.l   #1,d1
        move.l  d1,d2
        and.w   #15,d1
        lea     tab160,a1
        lsl.w   #3,d1
        move.l  (a1,d1.w),d1
;        move.l  spar1(pc),a1
;        add.l   #5120,spar1
        move.l  spar1(pc),a1
        addq.l  #4,spar1
        move.l  (a1),a1         
;        lea     shiftedblocks(pc),a1
        lsr.l   #1,d2
        and.l   #24,d2
        add.l   d2,a1
        add.l   d1,a1
        movem.l (a1),d1-d7/a3
        movem.l d1-d7/a3,(a2)
        movem.l d1-d7/a3,32(a2)
        movem.l d1-d7/a3,64(a2)
        movem.l d1-d7/a3,96(a2)
        movem.l d1-d7/a3,128(a2)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l 64(a1),d1-d7/a3
        movem.l d1-d7/a3,160(a2)
        movem.l d1-d7/a3,192(a2)
        movem.l d1-d7/a3,224(a2)
        movem.l d1-d7/a3,256(a2)
        movem.l d1-d7/a3,288(a2)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l 128(a1),d1-d7/a3
        movem.l d1-d7/a3,320(a2)
        movem.l d1-d7/a3,352(a2)
        movem.l d1-d7/a3,384(a2)
        movem.l d1-d7/a3,416(a2)
        movem.l d1-d7/a3,448(a2)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l 192(a1),d1-d7/a3
        movem.l d1-d7/a3,480(a2)
        movem.l d1-d7/a3,512(a2)
        movem.l d1-d7/a3,544(a2)
        movem.l d1-d7/a3,576(a2)
        movem.l d1-d7/a3,608(a2)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l 256(a1),d1-d7/a3
        movem.l d1-d7/a3,640(a2)
        movem.l d1-d7/a3,672(a2)
        movem.l d1-d7/a3,704(a2)
        movem.l d1-d7/a3,736(a2)
        movem.l d1-d7/a3,768(a2)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        movem.l d1-d7/a3,-(a4)
        lea     800(a2),a2
        dbra    d0,ommb1
        move.l  currpicadd,a0
        lea     12800(a0),a0
        moveq   #0,d0
        moveq   #15,d1
ommb2:  move.w  d0,6(a0)
        move.w  d0,14(a0)
        move.w  d0,22(a0)
        move.w  d0,30(a0)
        move.w  d0,38(a0)
        move.w  d0,46(a0)
        move.w  d0,54(a0)
;        move.w  d0,62(a0)
;        move.w  d0,70(a0)
;        move.w  d0,78(a0)
;        move.w  d0,86(a0)
;        move.w  d0,94(a0)
;        move.w  d0,102(a0)
        move.w  d0,110(a0)
        move.w  d0,118(a0)
        move.w  d0,126(a0)
        move.w  d0,134(a0)
        move.w  d0,142(a0)
        move.w  d0,150(a0)
        move.w  d0,158(a0)
        lea     160(a0),a0
        dbra    d1,ommb2
        
        




;ommb2:  movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        movem.l d0-d6/a1-a3,-(a0)
;        dbra    d7,ommb2

        rts


shiftedblocksadds:
        dc.l    0,5120,5120,10240,10240,15360,15360,20480
        dc.l    20480,25600,25600,30720,30720,35840,35840,40960


updatevars:
        lea     backposs(pc),a0
        moveq   #5,d0
        moveq   #15,d1
omudv1: add.l   d0,(a0)+
        addq.l  #1,d0
        dbra    d1,omudv1
        rts

backposs:       blk.l   16,0
endbpos:        dc.l    1




scroll: lea     scrollmat(pc),a0
        move.l  #170,d7
        move.l  #-80,d6
        lea     newbackoforthtab,a3
        move.l  zinc,d0
        add.l   d0,bofposz
        and.l   #2047,bofposz
        move.l  yinc,d0
        add.l   d0,bofposy
        and.l   #2047,bofposy
        move.l  bofposz(pc),d5
        lsl.w   #2,d5
        move.l  bofposy(pc),d1
        lsl.w   #2,d1
        move.l  zadd,d2
        move.l  yadd,d4
oms1:   add.w   d2,d5
        add.w   d4,d1
        tst.w   (a0)+
        beq     forbis1
        movem.w d1-d2/d4-d5,-(sp)
        and.w   #8191,d5
        and.w   #8191,d1
        move.w  -2(a0),d2
        subq.l  #1,d2
        move.l  (a3,d5.w),d3
        move.l  (a3,d1.w),d1
        sub.l   #127,d1
        move.l  d3,d5
        add.l   #256,d5
        move.l  d6,d0
        muls    d5,d0
        muls    d5,d1
        asr.l   #8,d1
        asr.l   #2,d1
        add.l   #92,d1
        asr.l   #7,d0
        lsr.l   #5,d3
        and.l   #7,d3
        add.l   #160,d0
        bsr     testsprite
        movem.w (sp)+,d1-d2/d4-d5
forbis1:
        addq.l  #1,d6
        dbra    d7,oms1
        rts

swapscreens:
        not.w   oddvsync
        tst.w   oddvsync
        bmi     forbiss1
        move.l  screen1add(pc),d0
        bra     forbiss2
forbiss1:
        move.l  screen2add(pc),d0
forbiss2:
        move.l  d0,currpicadd
        lsr.l   #8,d0
        move.b  d0,$ff8203
        lsr.l   #8,d0
        move.b  d0,$ff8201
        rts



scrollitleft:
        lea     scrollmat(pc),a0
        move.l  a0,a1
        addq.l  #2,a0
        movem.l (a0)+,d0-d7
        movem.l d0-d7,(a1)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,32(a1)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,64(a1)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,96(a1)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,128(a1)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,160(a1)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,192(a1)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,224(a1)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,256(a1)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,288(a1)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,320(a1)
        movem.l (a0)+,d0-d1
        movem.l d0-d1,352(a1)

        addq.w  #1,waittilnextchar
        cmp.w   #11,waittilnextchar
        blt     forbisil1
        clr.w   waittilnextchar

        move.w  textofs,d0
        lea     scrtext(pc),a0
        moveq   #0,d1
        move.b  (a0,d0.w),d1
        lea     stasc(pc),a0
        move.b  (a0,d1.w),d1
        addq.w  #1,d1
        move.w  d1,360(a1)
        addq.w  #1,d0
        cmp.w   textlen(pc),d0
        bcs     forbisil3
        moveq   #0,d0
forbisil3:
        move.w  d0,textofs

        bra     forbisil2
forbisil1:
        clr.w   360(a1)
forbisil2:
        rts


waittilnextchar:
                dc.w    0
textofs:        dc.w    0
textlen:        dc.w    0
bofposz:        dc.l    0
bofposy:        dc.l    0
zinc:           dc.l    0
yinc:           dc.l    0
zadd:           dc.l    0
yadd:           dc.l    0
scrollmat:      blk.w   200,0


chooseform:
        move.w  textofs,d0
        lea     scrtext(pc),a0
        moveq   #0,d1
        move.b  (a0,d0.w),d1
        cmp.w   #48,d1
        blt     forbicf1
        cmp.w   #57,d1
        bgt     forbicf1
        sub.w   #48,d1
        addq.w  #3,textofs
        moveq   #0,d2
        move.b  1(a0,d0.w),d2
        sub.w   #48,d2
        lsl.w   #1,d2
        lea     tab10(pc),a1
        move.w  (a1,d2.w),d2
        moveq   #0,d3
        move.b  2(a0,d0.w),d3
        sub.w   #48,d3
        add.w   d3,d2
; Number of func in d1
; Number in D2
        lsl.w   #2,d1
        lea     jsrto(pc),a1
        move.l  (a1,d1.w),a1
        jsr     (a1)
forbicf1:
        move.l  zposshould,d0
        sub.l   bofposz,d0
        add.l   #20,d0
        cmp.l   #40,d0
        bhi     forbicf2
        clr.l   zinc
forbicf2:
        move.l  yposshould,d0
        sub.l   bofposy,d0
        add.l   #20,d0
        cmp.l   #40,d0
        bhi     forbicf3
        clr.l   yinc
forbicf3:
        move.l  zadd,d0
        move.l  zaddshould,d1
        cmp.l   d1,d0
        beq     forbicf4
        cmp.l   d1,d0
        blt     forbicf5
        subq.l  #4,d0
        bra     forbicf4
forbicf5:
        addq.l  #4,d0
forbicf4:
        move.l  d0,zadd

        move.l  yadd,d0
        move.l  yaddshould,d1
        cmp.l   d1,d0
        beq     forbicf6
        cmp.l   d1,d0
        blt     forbicf7
        subq.l  #4,d0
        bra     forbicf6
forbicf7:
        addq.l  #4,d0
forbicf6:
        move.l  d0,yadd
        rts
        
        
tab10:          dc.w    0,10,20,30,40,50,60,70,80,90
zposshould:     dc.l    0
zaddshould:     dc.l    0
yposshould:     dc.l    0
yaddshould:     dc.l    0

jsrto:          dc.l    zposrout,yposrout,zincrout,yincrout
                dc.l    zaddrout,yaddrout
                dc.l    dummyrout,dummyrout,dummyrout,dummyrout,dummyrout    

zposrout:    
        lea     tab512(pc),a1
        lsl.w   #2,d2
        move.l  (a1,d2.w),d2
        move.l  d2,zposshould
        rts

yposrout:    
        lea     tab512(pc),a1
        lsl.w   #2,d2
        move.l  (a1,d2.w),d2
        move.l  d2,yposshould
        rts

tab512: dc.l    0,512,1024,1536,50000

zincrout:
        sub.l   #32,d2
        move.l  d2,zinc
        move.l  #50000,zposshould
        rts

yincrout:
        sub.l   #32,d2
        move.l  d2,yinc
        move.l  #50000,yposshould
        rts

zaddrout:
        sub.l   #32,d2
        lsl.l   #2,d2
        move.l  d2,zaddshould
        rts

yaddrout:
        sub.l   #32,d2
        lsl.l   #2,d2
        move.l  d2,yaddshould
        rts

dummyrout:
        rts





tempintvars:    
        lea     scrollmat(pc),a0
        moveq   #14,d0
omtiv1: move.w  #1,(a0)+
        move.w  #0,(a0)+
        move.w  #0,(a0)+
        move.w  #0,(a0)+
        move.w  #0,(a0)+
        dbra    d0,omtiv1
        move.w  #1,(a0)+
        rts


makenewbackoforthtab:
        lea     backoforthtab(pc),a0
        lea     newbackoforthtab,a1
        move.l  #127,d0
ommnboft1:
        move.l  (a0)+,d1
        move.l  (a0),d2
        lsl.l   #4,d1
        lsl.l   #4,d2
        move.l  d2,d3
        sub.l   d1,d3
        lsr.l   #4,d3
        moveq   #15,d4
ommnboft2:
        move.l  d1,d5
        lsr.l   #4,d5
        move.l  d5,(a1)+
        add.l   d3,d1
        dbra    d4,ommnboft2
        dbra    d0,ommnboft1
        lea     tab160(pc),a0
        moveq   #0,d0
        move.l  #199,d1
omiv1:  move.l  d0,(a0)+
        add.l   #160,d0
        dbra    d1,omiv1
        rts


dist:
        move.l  currpicadd,a1
        lea     19200(a1),a1
        lea     shifteddistblocks,a0
        lea     4000(a0),a0
        lea     disttab(pc),a2
omd1:   
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        add.l   (a2)+,a0
        movem.l 120(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 80(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l 40(a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        movem.l (a0),d0-d7/a3-a4
        movem.l d0-d7/a3-a4,-(a1)
        rts        



distit:
        lea     disttab(pc),a0
        lea     80(a0),a0
        moveq   #4,d0
omdi1:  move.l  16(a0),20(a0)
        move.l  12(a0),16(a0)
        move.l  8(a0),12(a0)
        move.l  4(a0),8(a0)
        move.l  (a0),4(a0)
        lea     -20(a0),a0
        dbra    d0,omdi1
        lea     disttab(pc),a0
        move.w  distpos(pc),d0
        addq.w  #1,d0
        cmp.w   #50,d0
        blt     forbidi2
        moveq   #0,d0
        addq.w  #1,distsortpos
        and.w   #15,distsortpos
        move.w  distsortpos,d1
        lsl.w   #1,d1
        lea     distsorttab(pc),a1
        move.w  (a1,d1.w),d1
        move.w  d1,distsort
forbidi2:
        move.w  d0,distpos
        add.w   distsort(pc),d0
        lea     disttabx(pc),a1
        lsl.w   #1,d0
        move.w  (a1,d0.w),d0
        mulu    #4000,d0
        sub.l   #160,d0
        move.l  d0,(a0)+
        sub.l   d0,(a0)
        sub.l   #160,(a0)
        rts



disttab:        dc.l    27840
                blk.l   30,-160
distpos:        dc.w    0
distsortpos:    dc.w    0
distsorttab:    dc.w    0,0,0,0,50,50,50,50,50,50,50,50,100,100,100,100
distsort:       dc.w    0       

disttabx:

        dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5
        dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5
        dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5
        dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5
        dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5

        dc.w     6, 6, 7, 8, 8, 9, 9,10,10,10
        dc.w    11,11,11,11,11,11,10,10,10, 9
        dc.w     9, 8, 8, 7, 6, 6, 5, 4, 3, 3
        dc.w     2, 2, 1, 1, 1, 0, 0, 0, 0, 0
        dc.w     0, 1, 1, 1, 2, 2, 3, 3, 4, 5

        dc.w     6, 7, 8, 9, 9,10,10,10,10, 9
        dc.w     8, 7, 6, 5, 4, 3, 2, 1, 1, 1
        dc.w     1, 2, 2, 3, 4, 6, 7, 8, 9, 9
        dc.w    10,10,10,10, 9, 8, 7, 6, 5, 4
        dc.w     3, 2, 1, 1, 1, 1, 2, 2, 3, 4
       



;        dc.w     7, 8, 9,10,11,12,13,13,14,14
;        dc.w    15,15,15,15,15,15,14,14,13,13
;        dc.w    12,11,10, 9, 8, 8, 7, 6, 5, 4
;        dc.w     3, 2, 2, 1, 1, 0, 0, 0, 0, 0
;        dc.w     0, 1, 1, 2, 2, 3, 4, 5, 6, 7

;        dc.w     7, 8, 9,10,11,12,12,12,12,11
;        dc.w    10, 9, 8, 6, 5, 4, 3, 2, 2, 2
;        dc.w     2, 3, 4, 5, 6, 7, 8, 9,10,11
;        dc.w    12,12,12,12,11,10, 9, 8, 6, 5
;        dc.w     4, 3, 2, 2, 2, 2, 3, 4, 5, 6

;       dc.w     4, 4, 4, 5, 5, 6, 6, 6, 6, 7
;       dc.w     7, 7, 7, 7, 7, 7, 7, 6, 6, 6
;       dc.w     6, 5, 5, 4, 4, 4, 3, 3, 2, 2
;       dc.w     1, 1, 1, 1, 0, 0, 0, 0, 0, 0
;       dc.w     0, 0, 1, 1, 1, 1, 2, 2, 3, 3


;       dc.w     7, 8,10,11,12,13,13,13,12,12
;       dc.w    11, 9, 8, 6, 5, 3, 2, 2, 1, 1
;       dc.w     1, 2, 3, 4, 6, 7, 8,10,11,12
;       dc.w    13,13,13,12,12,11, 9, 8, 6, 5
;       dc.w     3, 2, 2, 1, 1, 1, 2, 3, 4, 6

;       dc.w     7, 9,11,13,14,15,15,15,14,13
;       dc.w    12,10, 8, 7, 5, 3, 2, 1, 0, 0
;       dc.w     0, 1, 2, 4, 6, 7, 9,11,13,14
;       dc.w    15,15,15,14,13,12,10, 8, 7, 5
;       dc.w     3, 2, 1, 0, 0, 0, 1, 2, 4, 6






rotatethe:
        moveq   #0,d0
        move.w  rotpos(pc),d0
        addq.w  #2,d0
        and.w   #63,d0
        move.w  d0,rotpos
        lsl.w   #1,d0
        lea     rottab(pc),a1
        move.w  (a1,d0.w),d0
        lsl.w   #6,d0
        lea     rotcrunchtab(pc),a0
        add.l   d0,a0
        move.l  currpicadd(pc),a1
        lea     12800(a1),a1

        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,56(a1)
        move.l  (a2)+,96(a1)
        move.l  (a2)+,100(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,216(a1)
        move.l  (a2)+,256(a1)
        move.l  (a2)+,260(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,376(a1)
        move.l  (a2)+,416(a1)
        move.l  (a2)+,420(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,536(a1)
        move.l  (a2)+,576(a1)
        move.l  (a2)+,580(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,696(a1)
        move.l  (a2)+,736(a1)
        move.l  (a2)+,740(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,856(a1)
        move.l  (a2)+,896(a1)
        move.l  (a2)+,900(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,1016(a1)
        move.l  (a2)+,1056(a1)
        move.l  (a2)+,1060(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,1176(a1)
        move.l  (a2)+,1216(a1)
        move.l  (a2)+,1220(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,1336(a1)
        move.l  (a2)+,1376(a1)
        move.l  (a2)+,1380(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,1496(a1)
        move.l  (a2)+,1536(a1)
        move.l  (a2)+,1540(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,1656(a1)
        move.l  (a2)+,1696(a1)
        move.l  (a2)+,1700(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,1816(a1)
        move.l  (a2)+,1856(a1)
        move.l  (a2)+,1860(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,1976(a1)
        move.l  (a2)+,2016(a1)
        move.l  (a2)+,2020(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,2136(a1)
        move.l  (a2)+,2176(a1)
        move.l  (a2)+,2180(a1)
        move.l  (a0)+,a2
        movem.l (a2)+,d0-d7/a3-a4
        movem.l d0-d7/a3-a4,2296(a1)
        move.l  (a2)+,2336(a1)
        move.l  (a2)+,2340(a1)
        rts




rotpos: dc.w    0

rottab: dc.w    7,6,6,5,4,4,3,3,2,2,1,1,1,0,0,0
        dc.w    0,0,0,0,1,1,1,2,2,3,3,4,4,5,6,6 
        dc.w    7,8,8,9,10,10,11,11,12,12,13,13,13,14,14,14
        dc.w    14,14,14,14,13,13,13,12,12,11,11,10,10,9,8,8


rotcrunchtab:
        dc.l    48,96,144,192,240,288,336,384,432,480,528,576,624,672,720,0
        dc.l    0,48,96,144,192,288,336,384,432,480,576,624,672,720,0,0
        dc.l    0,0,48,96,192,240,336,384,432,528,576,672,720,0,0,0
        dc.l    0,0,0,48,144,192,288,384,480,576,624,720,0,0,0,0
        dc.l    0,0,0,0,48,144,288,384,480,624,720,0,0,0,0,0
        dc.l    0,0,0,0,0,48,192,384,576,720,0,0,0,0,0,0
        dc.l    0,0,0,0,0,0,48,384,720,0,0,0,0,0,0,0
        dc.l    0,0,0,0,0,0,0,384,0,0,0,0,0,0,0,0
        dc.l    0,0,0,0,0,0,720,384,48,0,0,0,0,0,0,0
        dc.l    0,0,0,0,0,720,576,384,192,48,0,0,0,0,0,0
        dc.l    0,0,0,0,720,624,480,384,288,144,48,0,0,0,0,0
        dc.l    0,0,0,720,672,576,480,384,288,192,144,48,0,0,0,0
        dc.l    0,0,720,672,576,528,432,384,336,240,192,96,48,0,0,0
        dc.l    0,720,672,624,576,480,432,384,336,288,192,144,96,48,0,0
        dc.l    720,672,624,576,528,480,432,384,336,288,240,192,144,96,48,0



shiftblocks:
        lea     block(pc),a0
        lea     shiftedblocks,a1
        moveq   #8,d7 ;15
omsb4:  move.l  d7,-(sp)
        moveq   #15,d7
        moveq   #0,d0
omsb1:  move.l  a0,a2
        moveq   #4,d1
omsb2:  moveq   #3,d2
        movem.w (a2),d3-d6
        and.l   #$ffff,d3
        and.l   #$ffff,d4
        and.l   #$ffff,d5
        and.l   #$ffff,d6
        lsl.l   d0,d3
        lsl.l   d0,d4
        lsl.l   d0,d5
        lsl.l   d0,d6
        swap    d3
        swap    d4
        swap    d5
        swap    d6
        lea     32(a2),a2
        lea     32(a1),a1
omsb3:  lea     -8(a1),a1
        movem.w d3-d6,(a1)
        movem.w d3-d6,32(a1)
        lea     -8(a2),a2
        movem.w (a2),d3-d6
        and.l   #$ffff,d3
        and.l   #$ffff,d4
        and.l   #$ffff,d5
        and.l   #$ffff,d6
        lsl.l   d0,d3
        lsl.l   d0,d4
        lsl.l   d0,d5
        lsl.l   d0,d6

        or.w    d3,(a1)
        or.w    d4,2(a1)
        or.w    d5,4(a1)
        or.w    d6,6(a1)
        or.w    d3,32(a1)
        or.w    d4,34(a1)
        or.w    d5,36(a1)
        or.w    d6,38(a1)
        swap    d3
        swap    d4
        swap    d5
        swap    d6
        dbra    d2,omsb3
        lea     64(a1),a1
        lea     32(a2),a2
        dbra    d1,omsb2
        addq.l  #1,d0
        dbra    d7,omsb1
        move.l  (sp)+,d7
        add.l   #160,a0
        dbra    d7,omsb4
        rts

shiftfont:
        lea     shiftedfont,a1
        lea     fontadds(pc),a2
        lea     font,a0
        move.l  a0,spar3
        moveq   #28,d0
omsf1:  moveq   #7,d1
        lea     sizeingy(pc),a3
        move.l  a3,spar4
        lea     sizeingx(pc),a4
        move.l  a4,spar2
omsf2:
        move.l  spar4,a3
        moveq   #31,d2
        sub.l   d1,d2
        sub.l   d1,d2
        movem.l d0-d1,-(sp)
        lea     mellanblock(pc),a5
        move.l  d2,spar1
omsf3:  move.l  spar2,a4
        moveq   #0,d0
        move.w  (a3)+,d0
        lsl.w   #2,d0
        move.l  spar3,a0
        add.l   d0,a0
        move.l  (a0),d0
        moveq   #31,d1
        moveq   #0,d5
omsf5:  move.l  d0,d3
        moveq   #0,d4
        move.w  (a4)+,d4
        lsr.l   d4,d3
        ror.l   #1,d3
        and.l   #$80000000,d3
        lsr.l   #1,d5
        or.l    d3,d5
        dbra    d1,omsf5
        move.l  d5,(a5)+
        dbra    d2,omsf3
        movem.l (sp)+,d0-d1
        movem.l d0-d1,-(sp)
        moveq   #7,d0
        moveq   #0,d2
omsf4:  move.l  spar1,d1
        lea     mellanblock(pc),a5
        move.l  a1,(a2)+
        lsl.l   #1,d0
        addq.l  #2,d0
omsf6:
        move.l  (a5)+,d3
        move.l  d3,d4
        lsr.l   d2,d3
        lsl.l   d0,d4
        move.l  d3,(a1)+
        move.w  d4,(a1)+
        dbra    d1,omsf6
        subq.l  #2,d0
        lsr.l   #1,d0
        addq.l  #2,d2
        dbra    d0,omsf4
        movem.l (sp)+,d0-d1
        add.l   #64,spar2
        add.l   #64,spar4
        dbra    d1,omsf2
        add.l   #128,spar3
        dbra    d0,omsf1
        move.l  #-1,(a1)+
        rts

mellanblock:    blk.l   96,0



shiftdistblocks:
        lea     shifteddistblocks,a1
        moveq   #11,d7
omsdb1: move.l  d7,-(sp)
        addq.l  #2,d7
        moveq   #15,d0
        sub.l   d7,d0
        lea     unshifteddistblock(pc),a0
        moveq   #24,d1
omsdb2:
        moveq   #18,d2
        moveq   #0,d3
        moveq   #0,d4
omsdb3:
        moveq   #0,d5
        move.w  (a0)+,d5
        ror.l   d0,d5
        or.w    d3,d5
        move.w  d5,(a1)+
        swap    d5
        move.w  d5,d3
        swap    d3

        moveq   #0,d5
        move.w  (a0)+,d5
        ror.l   d0,d5
        or.w    d3,d5
        move.w  d5,(a1)+
        swap    d5
        move.w  d5,d3
        swap    d3

        moveq   #0,d5
        move.w  (a0)+,D5
        swap    d5
        lsr.l   d0,d5
        move.w  d5,d6
        swap    d5
        or.w    d4,d5
        move.w  d6,d4
        swap    d4
        move.w  d5,(a1)+

        moveq   #0,d5
        move.w  (a0)+,d5
        swap    d5
        lsr.l   d0,d5
        move.w  d5,d6
        swap    d5
        or.w    d4,d5
        move.w  d6,d4
        swap    d4
        move.w  d5,(a1)+

        dbra    d2,omsdb3
        move.w  d3,(a1)+
        swap    d3
        move.w  d3,(a1)+
        move.w  d4,(a1)+
        swap    d4
        move.w  d4,(a1)+
        dbra    d1,omsdb2
        move.l  (sp)+,d7
        dbra    d7,omsdb1
        rts


preparescreens:
        move.l  screen1add(pc),a0
        lea     32000(a0),a0
        move.l  screen2add(pc),a1
        lea     32000(a1),a1
        moveq   #0,d0
        move.l  d0,d1
        move.l  d0,d2
        move.l  d0,d3
        move.l  d0,d4
        move.l  d0,d5
        move.l  d0,d6
        move.l  d0,a2
        move.l  #999,d7
omps1:  movem.l d0-d6/a2,-(a0)
        movem.l d0-d6/a2,-(a1)
        dbra    d7,omps1
        lea     the(pc),a0
        move.l  screen1add(pc),a1
        move.l  screen2add(pc),a2
        lea     12800(a1),a1
        lea     12800(a2),a2
        moveq   #14,d7
omps2:  movem.l (a0)+,d0-d5
        movem.l d0-d5,56(a1)
        movem.l d0-d5,56(a2)
        movem.l (a0)+,d0-d5
        movem.l d0-d5,80(a1)
        movem.l d0-d5,80(a2)
        lea     160(a1),a1
        lea     160(a2),a2
        dbra    d7,omps2
        rts


initvars:
;        clr.l   -(sp)
;        move.w  #32,-(sp)
;        trap    #1
;        addq.l  #6,sp
;        move.l  d0,savstck
;        move.w  #2,-(sp)
;        trap    #14
;        addq.l  #2,sp
;        move.l  d0,physbase
        move.l  #screenadds,d0
        move.l  d0,currpicadd
        move.l  d0,screen1add
        add.l   #32000,d0
        move.l  d0,screen2add
;        move.w  #4,-(sp)
;        trap    #14
;        addq.l  #2,sp
;        move.w  d0,oldres
;        move.w  #0,-(sp)
;        move.l  physbase,-(sp)
;        move.l  physbase,-(sp)
;        move.w  #5,-(sp)
;        trap    #14
;        add.l   #12,sp
        lea     palette(pc),a0
;        lea     oldpalette(pc),a1
        move.l  #$ff8240,a2
;        movem.l (a2),d0-d7
;        movem.l d0-d7,(a1)
        movem.l (a0),d0-d7
        movem.l d0-d7,(a2)


        lea     rotcrunchtab(pc),a0
        lea     the(pc),a1
        move.l  a1,d0
        move.l  #239,d1
omiv2:  add.l   d0,(a0)+
        dbra    d1,omiv2

        lea     shiftedblocksadds(pc),a0
        lea     shiftedblocks,a1
        move.l  a1,d0
        moveq   #15,d1
omiv3:  add.l   d0,(a0)+
        dbra    d1,omiv3     

        move.l  #endtext,d0
        sub.l   #scrtext,d0
        move.w  d0,textlen
        rts


endp:   
;        lea     oldpalette(pc),a1
;        move.l  #$ff8240,a2
;        movem.l (a1),d0-d7
;        movem.l d0-d7,(a2)
;        move.w  oldres,-(sp)
;        move.l  physbase,-(sp)
;        move.l  physbase,-(sp)
;        move.w  #5,-(sp)
;        trap    #14
;        add.l   #12,sp
;        move.l  savstck,-(sp)
;        move.w  #32,-(sp)
;        trap    #1
;        addq.l  #6,sp
        rts


startmusix:
        lea     musix,a0
        lea     $6def0,a1
        move.l  #2499,d0
omsm1:  move.l  (a0)+,(a1)+
        dbra    d0,omsm1
        jsr     $6e864
        rts

main2:
;       move.l  a7,a5
;       move.l  #ustck,a7
;       move.l  4(a5),a5
;       move.l  $c(a5),d0
;       add.l   $14(a5),d0
;       add.l   $1c(a5),d0
;       add.l   #$100,d0
;       move.l  d0,-(sp)
;       move.l  a5,-(sp)
;       move.w  #0,-(sp)
;       move.w  #$4a,-(sp)
;       trap    #1
;       add.l   #12,sp


main:   
;        move.l  a7,a5
;        move.l  a7,oldustck
;        move.l  #ustck,a4
;        suba.l  #20,a4
;        move.l  (a5)+,(a4)+
;        move.l  (a5)+,(a4)+
;        move.l  (a5)+,(a4)+
;        move.l  (a5)+,(a4)+
;        move.l  (a5)+,(a4)+
;        suba.l  #20,a4
;        move.l  a4,a7
        move.l  a2,keyadd
        move.l  a0,-(sp)
        move.l  a1,-(sp)

        bsr     startmusix
        bsr     initvars
        bsr     shiftblocks
        bsr     shiftfont
        bsr     shiftdistblocks
        bsr     makenewbackoforthtab
        bsr     preparescreens
        bsr     setints
omm1:   tst.b   vflag
        beq     omm1
        clr.b   vflag
;        move.w  #$000,$ff8240
        bsr     swapscreens
        bsr     scrollback
        bsr     dist
        bsr     rotatethe
        bsr     updatevars
        bsr     distit
        bsr     scroll
        bsr     scrollitleft
        bsr     chooseform
;        move.w  #$111,$ff8240
        move.l  keyadd,a0
        cmp.b   #57,(a0)
        bne     omm1
        bsr     retints
        bsr     endp
;        move.l  #ustck,a6
;        move.l  oldustck,a5
;        suba.l  #20,a6
;        move.l  (a6)+,(a5)+
;        move.l  (a6)+,(a5)+
;        move.l  (a6)+,(a5)+
;        move.l  (a6)+,(a5)+
;        move.l  (a6)+,(a5)+
;        move.l  oldustck,a7
        move.l  (sp)+,a1
        move.l  (sp)+,a0
        rts

sintab:         dc.l    0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7
                dc.l    7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0


oldustck:       dc.l    0
;stck:           blk.l   100,0
;ustck:          dc.l    0
oldres:         dc.w    0
physbase:       dc.l    0
currpicadd:     dc.l    0
screen1add:     dc.l    0
screen2add:     dc.l    0
oddvsync:       dc.w    0
vflag:          dc.b    0,0
savstck:        dc.l    0
spar1:          dc.l    0
spar2:          dc.l    0
spar3:          dc.l    0
spar4:          dc.l    0
spar5:          dc.l    0
tom:            blk.l   20,0
keyadd:         dc.l    0



palette:        dc.w    $0000,$0310,$0421,$0532,$0643,$0754,$0407,$0707
                dc.w    $0007,$0117,$0227,$0337,$0447,$0557,$0667,$0777
oldpalette:     blk.l   8,0


scrtext:        
                dc.b    ' 250350003100432532        '
                dc.b    '                   '
                dc.b    ' WOW, THIS DEMO SURE DOES LOOK'
                DC.B    ' GREAT..  BUT PERHAPS THE SCROLLINE'
                DC.B    ' LOOKS A BIT   TOO ORDINARY.'
                DC.B    ' WELL, OKEY, LET US SWING IT'
                DC.B    ' UP AND DOWN. 363 THIS IS THE'
                DC.B    ' LITTLE BIT OF EVERYTHING DEMO'
                DC.B    ' BY THE CAREBEARS. THERE ARE'
                DC.B    ' STAR RAY TYPE OF BACKGROUND'
                DC.B    ' SCROLLERS, A DISTORTED TCB LOGO'
                DC.B    ', SOME GREAT MAD MAX MUSIC AND'
                DC.B    ' A SWINGING SCROLLINE OR.....'
                DC.B    ' PERHAPS EVEN MORE..............538........... '
                DC.B    ' THIS IS BEGINNING TO LOOK LIKE'
                DC.B    ' THE XXX INTERNATIONAL BALL DEMO'
                DC.B    ' SCREEN.                    '
                DC.B    ' 250001    BUT THEIR SCROLLINE WAS NOT'
                DC.B    ' THIS BIG. WE HOPE YOU DO NOT THINK'
                DC.B    ' THAT WE HAVE TWO DIFFERENTLY SIZED'
                DC.B    ' FONTS. WE HAVE MANY MORE... 273 '
                DC.B    ' YEAH...  DO NOT LEAVE YET, THERE'
                DC.B    ' IS STILL MORE TO COME, JUST WAIT AND'
                DC.B    ' SEE. '
                DC.B    ' IF YOU THINK THIS IS HARD TO READ,'
                DC.B    ' WAIT TILL YOU HAVE SEEN WHAT YOU'
                DC.B    ' ARE GOING TO SEE IN ABOUT THREE SECONDS.'
                DC.B    '     419 THAT WAS NOT THREE SECONDS,'
                DC.B    ' BUT NOW YOU HAVE SEEN OUR THREE DIMENSIONAL'
                DC.B    ' BENDING..'
                DC.B    ' YOU MIGHT WONDER WHY WE HAVE NO'
                DC.B    ' PUNCTUATION EXCEPT FOR THESE TWO ., .'
                DC.B    ' WE DO NOT EVEN HAVE THE LITTLE BLACK'
                DC.B    ' DOT BETWEEN HAVEN AND T, HAVEN T, SEE...'
                DC.B    ' WELL, NOW THAT WE ARE OUT OF IDEAS WHAT TO'
                DC.B    ' WRITE, WE CAN AS WELL EXPLAIN WHY.'
                DC.B    ' THE PROBLEM IS THAT ALL THE PART DEMOS'
                DC.B    ' MUST WORK ON HALF A MEG AND EVERY'
                DC.B    ' CHARACTER TAKES ABOUT TEN KILOBYTES.'
                DC.B    ' WE ARE GOING TO GREET SOME FOLKS NOW,'
                DC.B    ' SO LET US CHANGE WAVEFORM...         '
                DC.B    '          003100432532                '
                DC.B    ' 200300448548  MEGAGREETINGS GO TO'
                DC.B    ' ALL THE OTHER MEMBERS OF THE UNION.'
                DC.B    ' WE DO NOT FEEL LIKE GREETING TO MUCH'
                DC.B    ' COZ WE DO NOT HAVE THOSE LITTLE BENT'
                DC.B    ' LINES, SO WE CAN NOT MAKE COMMENTS.'
                DC.B    ' BUT JUST ONCE YOU WILL HAVE TO PRETEND'
                DC.B    ' YOU SAW ONE OF THOSE, IT SHOULD HAVE COME'
                DC.B    ' INSTEAD OF THE SPACE BETWEEN THE WORDS'
                DC.B    ' COOL AND YOUR.'
                DC.B    ' HERE WE GO... HELLO, AN COOL  YOUR NEW'
                DC.B    ' INTRO IS REALLY SOMETHING .'
                DC.B    '                267351437541 '
                DC.B    ' YOU WILL HAVE TO READ'
                DC.B    ' IN THE MAIN SCROLLTEXT FOR MORE GREETINGS.'
                DC.B    '...  BYE..............'
                DC.B    '                   '
                  



;               dc.b    ' 250 350 003 100 432 532   '
;               dc.b    '   ','   '
;               dc.b    ' HI, SUCKERS. I HOPE YOU DO NOT THINK'
;               dc.b    ' THAT THIS SCROLLINE IS BORING...'
;               DC.B    ' PERHAPS WE SHOULD SWING IT...'
;               dc.b    '    ','   ',' 363 '
;               DC.B    ' WHAT, YOU CANNOT MEAN THAT YOU STILL'
;               DC.B    ' THINK IT IS BORING. WELL, LET US BEND'
;               DC.B    ' IT.....  '
;               DC.B    '   ','   ',' 538 '
;               DC.B    ' I THINK THIS IS MUCH BETTER...'
;               DC.B    ' BUT LET US MAKE IT A BIT BIGGER...'
;               DC.B    '   ','   ','   ','   ',' 250 001 '
;               DC.B    '   MUCH BETTER..... BUT SWINGING'
;               DC.B    ' BACK AND FORTH WOULD NOT HURT...'
;               DC.B    ' 273 AND PERHAPS SOME THREE DIMENSIONAL'
;               DC.B    ' BENDING. 419 NOW, THIS FEELS GOOD...'
;               DC.B    ' THE CAREBEARS ARE SORT OF PROUD TO'
;               DC.B    ' PRESENT THE FLICKERY SCROLLER, '
;               DC.B    ' BY NICLAS......'
;               DC.B    ' I THINK I AM GOING TO MAKE THE'       
;               DC.B    ' SCROLLINE GO A BIT SMOOTHER.    ','    '
;               DC.B    ' 003100432532   ','   ','    ',' 264364'
;               DC.B    '448548 READY... NOW, I SUPPOSE YOU CAN'
;               DC.B    ' READ IT, SO LET US GREET SOME PEOPLE'     
;               DC.B    '. GREETINGS GO TO  ALL '
;               DC.B    '280380 THE MEMBERS OF'
;               DC.B    ' THE UNION, AN COOL, HCC, PYROTECHNICS'
;               DC.B    ' AND GROWTWIG......     I THINK I AM'
;               DC.B    ' GOING TO WRAP NOW, SO BYEEEEEE........'
;               DC.B    '   ','    ','    ','    '

                even

endtext:        dc.l    0

stasc:
                dc.b    26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26
                dc.b    26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26
                dc.b    26,28,26,26,26,26,26,26,26,26,26,26,28,26,27,26
                dc.b    26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26
                dc.b    26, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14
                dc.b    15,16,17,18,19,20,21,22,23,24,25,26,26,26,26,26
                dc.b    26, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14
                dc.b    15,16,17,18,19,20,21,22,23,24,25,26,26,26,26,26
                dc.b    26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26
                dc.b    26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26
                dc.b    26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26
                dc.b    26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26
                dc.b    26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26
                dc.b    26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26
                dc.b    26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26
                dc.b    26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26




backoforthtab:
                dc.l    127,133,139,146,152,158,164,170,176,181,187
                dc.l    192,198,203,208,212,217,221,225,229,233,236
                dc.l    239,242,244,247,249,250,252,253,253,254,254
                dc.l    254,253,253,252,250,249,247,244,242,239,236
                dc.l    233,229,225,221,217,212,208,203,198,192,187
                dc.l    181,176,170,164,158,152,146,139,133,127,121
                dc.l    115,108,102,96,90,84,78,73,67,62,56,51,46,42
                dc.l    37,33,29,25,21,18,15,12,10,7,5,4,2,1,1,0,0,0
                dc.l    1,1,2,4,5,7,10,12,15,18,21,25,29,33,37,42
                dc.l    46,51,56,62,67,73,78,84,90,96,102,108,115
                dc.l    121
                dc.l    127

sizeingx:       
sizex0:         dc.w    32,32,32,32,32,32,32, 0, 2, 4, 5, 7, 9,11,12,14
                dc.w    16,18,20,21,23,25,27,28,30,32,32,32,32,32,32,32
sizex1:         dc.w    32,32,32,32,32,32, 0, 2, 3, 5, 6, 8,10,11,13,14
                dc.w    16,18,19,21,22,24,26,27,29,30,32,32,32,32,32,32
sizex2:         dc.w    32,32,32,32,32, 0, 1, 3, 4, 6, 7, 9,10,12,13,15
                dc.w    16,17,19,20,22,23,25,26,28,29,31,32,32,32,32,32
sizex3:         dc.w    32,32,32,32, 0, 1, 3, 4, 5, 7, 8, 9,11,12,13,15
                dc.w    16,17,19,20,21,23,24,25,27,28,29,31,32,32,32,32
sizex4:         dc.w    32,32,32, 0, 1, 2, 4, 5, 6, 7, 9,10,11,12,14,15
                dc.w    16,17,18,20,21,22,23,25,26,27,28,30,31,32,32,32
sizex5:         dc.w    32,32, 0, 1, 2, 3, 5, 6, 7, 8, 9,10,11,13,14,15
                dc.w    16,17,18,19,21,22,23,24,25,26,27,29,30,31,32,32
sizex6:         dc.w    32, 0, 1, 2, 3, 4, 5, 6, 7, 9,10,11,12,13,14,15
                dc.w    16,17,18,19,20,21,22,23,25,26,27,28,29,30,31,32
sizex7:         dc.w    0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15
                dc.w    16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31

sizeingy:
sizey0:         dc.w    0, 2, 4, 5, 7, 9,11,12,14,16,18,20,21,23,25,27
                dc.w    28,30,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
sizey1:         dc.w    0, 2, 3, 5, 6, 8,10,11,13,14,16,18,19,21,22,24
                dc.w    26,27,29,30,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
sizey2:         dc.w    0, 1, 3, 4, 6, 7, 9,10,12,13,15,16,17,19,20,22
                dc.w    23,25,26,28,29,31,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
sizey3:         dc.w    0, 1, 3, 4, 5, 7, 8, 9,11,12,13,15,16,17,19,20
                dc.w    21,23,24,25,27,28,29,31,-1,-1,-1,-1,-1,-1,-1,-1
sizey4:         dc.w    0, 1, 2, 4, 5, 6, 7, 9,10,11,12,14,15,16,17,18
                dc.w    20,21,22,23,25,26,27,28,30,31,-1,-1,-1,-1,-1,-1
sizey5:         dc.w    0, 1, 2, 3, 5, 6, 7, 8, 9,10,11,13,14,15,16,17
                dc.w    18,19,21,22,23,24,25,26,27,29,30,31,-1,-1,-1,-1
sizey6:         dc.w    0, 1, 2, 3, 4, 5, 6, 7, 9,10,11,12,13,14,15,16
                dc.w    17,18,19,20,21,22,23,25,26,27,28,29,30,31,-1,-1
sizey7:         dc.w    0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15
                dc.w    16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31


coltab:
                dc.w    $770,$770,$760,$760,$750,$750,$740,$740
                dc.w    $730,$730,$720,$720,$710,$710,$700,$700
                dc.w    $701,$701,$702,$702,$703,$703,$704,$704
                dc.w    $705,$705,$706,$706,$707,$707,$607,$607
                dc.w    $507,$507,$407,$407,$307,$307,$207,$207
                dc.w    $107,$107,$007,$007,$017,$017,$027,$027
                dc.w    $037,$037,$047,$047,$047,$057,$057,$057
                dc.w    $067,$067,$077,$077,$076,$076,$075,$075
                dc.w    $074,$074,$073,$073,$072,$072,$071,$071
                dc.w    $070,$070,$170,$170,$270,$270,$370,$370



the:
;
;  NEOchrome cut buffer contents (left justified)
;
;  pixels/scanline    = $0060 (bytes/scanline: $0030)
;  # scanlines (height) = $000F
;
;  Hardware color pallet  (color 0 to 15):
;
;      $0000,$0760,$0750,$0640,$0530,$0420,$0310,$0003
;      $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0777

        blk.l   12,0
        dc.w    $003A,$0006,$0041,$0000,$4F98,$739F,$8060,$0000
        dc.w    $0E50,$47A8,$C818,$0000,$0AD0,$0DC8,$0038,$0000
        dc.w    $1FB0,$6FCC,$4003,$0000,$FA00,$C500,$0300,$0000
        dc.w    $001F,$0023,$0040,$0000,$D3B0,$EFBE,$0041,$0000
        dc.w    $4F68,$8390,$CC38,$0000,$0EA0,$0D98,$0078,$0000
        dc.w    $77D9,$8FE5,$C002,$0000,$B000,$CF00,$0300,$0000
        dc.w    $005F,$001F,$007F,$0000,$FFFF,$FFFE,$FFFF,$0000
        dc.w    $83E0,$03C0,$CFF8,$0000,$03C0,$0FF9,$03F9,$0000
        dc.w    $5FFF,$BFFF,$1FFF,$0000,$FF00,$FC00,$FF00,$0000
        dc.w    $005F,$001F,$007F,$0000,$FFFE,$FFFF,$FFFF,$0000
        dc.w    $CBD8,$0BE0,$C7F8,$0000,$0FC9,$03F1,$03F8,$0000
        dc.w    $BFFF,$FFFF,$3FFF,$0000,$FC00,$FC00,$FF00,$0000
        dc.w    $003F,$003F,$005F,$0000,$FFFE,$FFFF,$FFFF,$0000
        dc.w    $4FCD,$8FF6,$C3F8,$0000,$A7D8,$63E0,$1BF9,$0000
        dc.w    $FFFF,$FFFF,$3FFF,$0000,$FF00,$FC00,$FF00,$0000
        dc.w    $004C,$0070,$003F,$0000,$DEBB,$3E43,$DFFC,$0000
        dc.w    $8FFB,$4FDC,$C3E0,$0000,$FBE8,$3BC0,$07F9,$0000
        dc.w    $7DC9,$7E3A,$BC04,$0000,$C800,$3B00,$0700,$0000
        dc.w    $0000,$0000,$0000,$0000,$3F00,$5E00,$1FC0,$0000
        dc.w    $07FF,$0BFF,$03FF,$0000,$FFD1,$FFD1,$FFE8,$0000
        dc.w    $3FFF,$3FFF,$FFFF,$0000,$FF00,$FC00,$FF00,$0000
        dc.w    $0000,$0000,$0000,$0000,$5F00,$3E00,$1FC0,$0000
        dc.w    $07FF,$0BFF,$03FF,$0000,$FFD0,$FFD1,$FFE8,$0000
        dc.w    $BFFF,$BFFF,$7FFF,$0000,$FF00,$FC00,$FF00,$0000
        dc.w    $0000,$0000,$0000,$0000,$3F80,$5E00,$1FC0,$0000
        dc.w    $0FFF,$03FF,$03FF,$0000,$FFE9,$FFC0,$FFF8,$0000
        dc.w    $BFFF,$7FFF,$3FFF,$0000,$FD00,$FE00,$FF00,$0000
        dc.w    $0000,$0000,$0000,$0000,$7EC0,$1F00,$1FC0,$0000
        dc.w    $07C3,$0BFC,$03FF,$0000,$8FD9,$03E0,$FFF8,$0000
        dc.w    $BD33,$7DCF,$3E00,$0000,$3B00,$F800,$0700,$0000
        dc.w    $0000,$0000,$0000,$0000,$1E40,$7F80,$1FC0,$0000
        dc.w    $03E0,$0FDF,$03FF,$0000,$FFC8,$07F1,$FBF8,$0000
        dc.w    $3FFF,$FFFF,$3FFF,$0000,$FF00,$FC00,$FF00,$0000
        dc.w    $0000,$0000,$0000,$0000,$7E40,$7F80,$1FC0,$0000
        dc.w    $0FD8,$0FC0,$03F8,$0000,$0FC1,$03F8,$03F9,$0000
        dc.w    $FFFF,$FFFF,$3FFF,$0000,$FC00,$FF00,$FF00,$0000
        dc.w    $0000,$0000,$0000,$0000,$7E00,$7FC0,$1FC0,$0000
        dc.w    $07C8,$0BC0,$03F8,$0000,$0BC0,$07F8,$03F8,$0000
        dc.w    $8FFF,$3FFF,$C7FF,$0000,$FC00,$FF00,$FF00,$0000
        dc.w    $0000,$0000,$0000,$0000,$5C00,$63C0,$3FC0,$0000
        dc.w    $08C0,$0720,$03F8,$0000,$07C0,$0C38,$03F8,$0000
        dc.w    $5134,$B2C3,$CFFF,$0000,$CC00,$0300,$FF00,$0000
        dc.w    $0000,$0000,$0000,$0000,$2300,$40C0,$7FC0,$0000
        dc.w    $0220,$0418,$0FF8,$0000,$0840,$0788,$0FF8,$0000
        dc.w    $0B44,$1483,$1FFF,$0000,$E200,$0100,$FF00,$0000




block:
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $5028,$000C,$5830,$0000,$0294,$00C6,$0318,$0000
        dc.w    $002A,$0003,$002C,$0000,$0014,$8004,$0018,$0000
        dc.w    $A893,$2C1C,$D0E0,$0000,$8929,$01CE,$0E10,$0000
        dc.w    $8452,$0013,$066C,$0000,$70AA,$802C,$00D0,$0000
        dc.w    $9733,$183C,$E1C0,$0000,$D339,$03CE,$1C00,$0000
        dc.w    $EAAE,$0337,$0CC0,$0000,$3947,$C078,$0180,$0000
        dc.w    $A371,$BC7E,$C080,$0000,$FF3F,$FFFF,$FC3F,$0000
        dc.w    $FFF8,$FFFF,$FFD8,$0000,$7FC1,$FFFF,$7F81,$0000

        dc.w    $FEDF,$F93F,$FDBF,$0000,$FF7F,$9CFC,$DEFE,$0000
        dc.w    $7EF7,$F9CF,$FDEF,$0000,$DFDF,$3F3F,$BFBF,$0000
        dc.w    $FDBF,$C3FC,$F3FE,$0000,$7FFB,$87E7,$97F7,$0000
        dc.w    $EFBE,$9E79,$DF7D,$0000,$FF7B,$F0E4,$FCF6,$0000
        dc.w    $E37B,$FCE4,$FEF4,$0000,$7FD7,$FF2C,$FFAE,$0000
        dc.w    $7FF7,$FFCF,$FFEF,$0000,$EFBE,$9E7F,$DF7F,$0000
        dc.w    $DEFF,$31FC,$B9FE,$0000,$7EEF,$E1FF,$F5FF,$0000
        dc.w    $FBFF,$E7F9,$F7FD,$0000,$FFEF,$FF98,$FFDE,$0000
        dc.w    $BFBE,$FE7F,$FF7F,$0000,$EDF7,$9BCC,$DBEE,$0000
        dc.w    $77FF,$FE9F,$FFFF,$0000,$DB9C,$27FF,$B7FF,$0000

;        dc.w    $F7F7,$CFCF,$EFEF,$0000,$FFB7,$FE4F,$FF6F,$0000
;        dc.w    $FFDF,$E73F,$F7BF,$0000,$DFBD,$3E73,$BF7B,$0000
;        dc.w    $BFDE,$7C39,$7F3D,$0000,$FF6F,$30FF,$BCFF,$0000
;        dc.w    $DFFE,$21F9,$A5FD,$0000,$FBEF,$E79E,$F7DF,$0000
;        dc.w    $FBEF,$E79F,$F7DF,$0000,$B8DE,$FF39,$FFBD,$0000
;        dc.w    $DFF5,$3FCB,$3FEB,$0000,$DFFD,$3FF3,$BFFB,$0000
;        dc.w    $FFFB,$7FE6,$7FF7,$0000,$F7BF,$0C7F,$AE7F,$0000
;        dc.w    $DFBB,$387F,$BD7F,$0000,$FEFF,$F9FE,$FDFF,$0000
;        dc.w    $F6E7,$C9FF,$EDFF,$0000,$2FEF,$FF9F,$FFDF,$0000
;        dc.w    $BB7D,$E6F3,$F6FB,$0000,$DDFF,$3FA7,$BFFF,$0000

        dc.w    $FDAF,$F96F,$FE77,$0000,$C63F,$DCFE,$EF7F,$0000
        dc.w    $72CF,$25DF,$B9FF,$0000,$FFC6,$FF9C,$FFEF,$0000
        dc.w    $CB65,$138B,$6C33,$0000,$D55E,$89B4,$EE3F,$0000
        dc.w    $F994,$BFA9,$BFCE,$0000,$BFCC,$7FF9,$7FFE,$0000
        dc.w    $A72D,$7FCB,$7FF3,$0000,$EE35,$FFE7,$FFFB,$0000
        dc.w    $FC6C,$F9FF,$FEFF,$0000,$7DFC,$F8FF,$FEFF,$0000
        dc.w    $F2F2,$E5AC,$F9CF,$0000,$39AA,$E70D,$7BF1,$0000
        dc.w    $ABBF,$127E,$DC7F,$0000,$5B79,$72F2,$BCFC,$0000
        dc.w    $F9AE,$FF37,$FFC7,$0000,$BAE1,$5DFE,$61FF,$0000
        dc.w    $545E,$6F8C,$8FEF,$0000,$AC78,$DFFF,$1FFF,$0000

;        dc.w    $EE59,$C4BB,$F73F,$0000,$FFF8,$FFF3,$FFFD,$0000
;        dc.w    $DFB5,$9F2D,$FFCE,$0000,$F8C7,$FB9F,$FDEF,$0000
;        dc.w    $DF32,$97F5,$F7F9,$0000,$97F9,$2FFF,$CFFF,$0000
;        dc.w    $996C,$2271,$CD86,$0000,$BAAB,$7136,$7DC7,$0000
;        dc.w    $BF8D,$FF3F,$7FDF,$0000,$8FBF,$FF1F,$FFDF,$0000
;        dc.w    $94E5,$EFF9,$EFFE,$0000,$BDC6,$7FFC,$7FFF,$0000
;        dc.w    $5577,$A24F,$3B8F,$0000,$EB6F,$CE5E,$F79F,$0000
;        dc.w    $3E5E,$5CB5,$9F39,$0000,$4735,$9CE1,$EF7E,$0000
;        dc.w    $2A8B,$CDF1,$F1FD,$0000,$D58F,$9BFF,$E3FF,$0000
;        dc.w    $1F35,$FFE6,$FFF8,$0000,$D75C,$EBBF,$EC3F,$0000

        dc.w    $FAF7,$F373,$FC7B,$0000,$DBFB,$D7FA,$E7FC,$0000
        dc.w    $FFF6,$FFF5,$FFF9,$0000,$FBFC,$F2FF,$FCFF,$0000
        dc.w    $E8B3,$CF2C,$F0C0,$0000,$26B4,$B8E7,$C378,$0000
        dc.w    $DBD9,$3B9E,$3DE0,$0000,$B4B7,$6767,$787B,$0000
        dc.w    $FACE,$FCF1,$F301,$0000,$7A58,$F3BF,$FC38,$0000
        dc.w    $3578,$E6FF,$F8F0,$0000,$7C69,$FFCE,$F8F0,$0000
        dc.w    $9FC0,$FFFF,$3F8F,$0000,$B83E,$BFFC,$D87F,$0000
        dc.w    $F8F8,$FFFF,$7FFF,$0000,$F8F0,$AFFF,$CFF3,$0000
        dc.w    $B7FF,$CFFE,$0FFF,$0000,$5C7A,$6FF3,$9FFC,$0000
        dc.w    $7FDF,$9F3E,$1FBF,$0000,$CD92,$73FC,$83FF,$0000

;        dc.w    $FFDB,$FFD7,$FFE7,$0000,$EFF3,$CBFF,$F3FF,$0000
;        dc.w    $EBDF,$CDCF,$F1EF,$0000,$6FEF,$5FEB,$9FF3,$0000
;        dc.w    $6F66,$EE79,$F781,$0000,$D2DF,$9D9F,$E1EF,$0000
;        dc.w    $A2CC,$3CB2,$C303,$0000,$9AD3,$E39C,$0DE0,$0000
;        dc.w    $D5E1,$9BFF,$E3C3,$0000,$F1A7,$FF3B,$E3C3,$0000
;        dc.w    $EB39,$F3C7,$CC07,$0000,$E960,$CEFF,$F0E3,$0000
;        dc.w    $E3E3,$FFFE,$FFFF,$0000,$E3C2,$BFFF,$3FCC,$0000
;        dc.w    $7F02,$FFFE,$FE3F,$0000,$E0FB,$FFF3,$61FD,$0000
;        dc.w    $FF7F,$7CF9,$7EFE,$0000,$364A,$CFF3,$0FFC,$0000
;        dc.w    $DFFD,$3FF9,$3FFE,$0000,$71E9,$BFCE,$7FF0,$0000

        dc.w    $F7FF,$E7FF,$FBFF,$0000,$FD7F,$F9FF,$FE7F,$0000
        dc.w    $FFBE,$FF3F,$FFDF,$0000,$7F5F,$FE7F,$FF9F,$0000
        dc.w    $CA7F,$8DFE,$F1FF,$0000,$7A4F,$73BE,$FC3F,$0000
        dc.w    $7F57,$7E6F,$FF8F,$0000,$FE89,$FCF7,$FF07,$0000
        dc.w    $9B3D,$1CF9,$E0FE,$0000,$544E,$A7B8,$383F,$0000
        dc.w    $96B7,$E4CE,$3F0F,$0000,$7D8C,$79F3,$BE03,$0000
        dc.w    $D87A,$DFF3,$E3FC,$0000,$C409,$3FF1,$387E,$0000
        dc.w    $2A8E,$CDFC,$11FF,$0000,$B441,$CF9F,$0FEF,$0000
        dc.w    $E1FE,$FFFF,$FFFF,$0000,$0E36,$FFE7,$FFF8,$0000
        dc.w    $6B7D,$8CF9,$10FE,$0000,$17AB,$EF37,$0FC7,$0000

;        dc.w    $F7FF,$E7FF,$FBFF,$0000,$FD7F,$F9FF,$FE7F,$0000
;        dc.w    $FFBE,$FF3F,$FFDF,$0000,$7F5F,$FE7F,$FF9F,$0000
;        dc.w    $CA7F,$8DFE,$F1FF,$0000,$7A4F,$73BE,$FC3F,$0000
;        dc.w    $7F57,$7E6F,$FF8F,$0000,$FE89,$FCF7,$FF07,$0000
;        dc.w    $9B3D,$1CF9,$E0FE,$0000,$544E,$A7B8,$383F,$0000
;        dc.w    $96B7,$E4CE,$3F0F,$0000,$7D8C,$79F3,$BE03,$0000
;        dc.w    $D87A,$DFF3,$E3FC,$0000,$C409,$3FF1,$387E,$0000
;        dc.w    $2A8E,$CDFC,$11FF,$0000,$B441,$CF9F,$0FEF,$0000
;        dc.w    $E1FE,$FFFF,$FFFF,$0000,$0E36,$FFE7,$FFF8,$0000
;        dc.w    $6B7D,$8CF9,$10FE,$0000,$17AB,$EF37,$0FC7,$0000

        dc.w    $FAFF,$E37F,$FC7F,$0000,$FFEB,$FFCF,$FFF3,$0000
        dc.w    $FFBF,$FF3F,$FFFF,$0000,$FAFF,$F3FF,$FCFF,$0000
        dc.w    $E44E,$87BC,$F83F,$0000,$BF9A,$FF1D,$3FE1,$0000
        dc.w    $7F63,$FE7F,$FF8F,$0000,$ECE3,$CF1F,$F01F,$0000
        dc.w    $9C65,$1F99,$E01E,$0000,$B733,$CE3C,$0FC0,$0000
        dc.w    $374C,$E673,$FB83,$0000,$D878,$9F87,$E007,$0000
        dc.w    $DCE9,$DF11,$E01E,$0000,$9CCC,$E3F3,$03C3,$0000
        dc.w    $6A46,$CC79,$F381,$0000,$3FE3,$F01F,$F01F,$0000
        dc.w    $F809,$FFF1,$FFFE,$0000,$0F21,$F0FF,$00FF,$0000
        dc.w    $FCEF,$F8F0,$FF00,$0000,$1E07,$FFFF,$FFFF,$0000

;        dc.w    $FFFA,$FFF3,$FFFC,$0000,$FFEF,$FFCF,$FFFF,$0000
;        dc.w    $FEBF,$FCFF,$FF3F,$0000,$FEBF,$F8DF,$FF1F,$0000
;        dc.w    $AFE6,$3FC7,$CFF8,$0000,$9FD8,$7F9F,$7FE3,$0000
;        dc.w    $FB38,$F3C7,$FC07,$0000,$F913,$E1EF,$FE0F,$0000
;        dc.w    $6DCC,$738F,$83F0,$0000,$CDD3,$399C,$3EE0,$0000
;        dc.w    $361E,$E7E1,$F801,$0000,$2719,$C7E6,$F807,$0000
;        dc.w    $6733,$78FC,$80F0,$0000,$1A91,$F31E,$FCE0,$0000
;        dc.w    $8FF8,$7C07,$7C07,$0000,$F73A,$F7C4,$F807,$0000
;        dc.w    $43C8,$7C3F,$803F,$0000,$7F3B,$FE3C,$FFC0,$0000
;        dc.w    $C781,$3FFF,$3FFF,$0000,$FE02,$FFFC,$FFFF,$0000

        dc.w    $B5FF,$67FF,$79FF,$0000,$FD1F,$F9FF,$FE7F,$0000
        dc.w    $FDFF,$F9FE,$FEFF,$0000,$5FFD,$6FF9,$8FFE,$0000
        dc.w    $48C3,$8F3F,$303F,$0000,$F263,$E39F,$FC1F,$0000
        dc.w    $FADE,$C33C,$FC3F,$0000,$C8F2,$F7E3,$07FC,$0000
        dc.w    $B0F1,$3F0F,$C00F,$0000,$E67B,$8784,$F807,$0000
        dc.w    $CC66,$0F9C,$F01F,$0000,$CE36,$F1E7,$01F8,$0000
        dc.w    $7078,$FF87,$8007,$0000,$863C,$07C0,$F81F,$0000
        dc.w    $1C74,$1F88,$E00F,$0000,$CF26,$F0C7,$00F8,$0000
        dc.w    $7861,$FF9F,$F81F,$0000,$E620,$E7C0,$F83F,$0000
        dc.w    $7C70,$7F8E,$800F,$0000,$C444,$FB87,$03FB,$0000

;        dc.w    $A3FF,$3FFF,$CFFF,$0000,$BFEB,$3FCD,$DFF1,$0000
;        dc.w    $FFB6,$FF2C,$FFCF,$0000,$BFFF,$FFFF,$3FFF,$0000
;        dc.w    $4C7F,$73F8,$83FF,$0000,$5BD9,$679E,$87E0,$0000
;        dc.w    $1E49,$FC71,$FF86,$0000,$187E,$E7FC,$07FF,$0000
;        dc.w    $CF79,$F081,$00FE,$0000,$8CD9,$F39E,$03E0,$0000
;        dc.w    $C6D6,$3CE7,$3F18,$0000,$1E3C,$E1F0,$01FF,$0000
;        dc.w    $C783,$F803,$03FC,$0000,$8E99,$F11E,$01E0,$0000
;        dc.w    $E4CE,$18FF,$1F10,$0000,$0F10,$F0E0,$00FF,$0000
;        dc.w    $C40F,$F80F,$07F0,$0000,$8E18,$F1DF,$01E0,$0000
;        dc.w    $888F,$70FF,$7F7F,$0000,$0C3C,$F3FC,$03FF,$0000

        dc.w    $FF2F,$FC33,$FFC3,$0000,$FFF9,$FFE1,$FFFE,$0000
        dc.w    $7FFF,$BFFF,$3FFF,$0000,$EBFF,$8DFF,$F1FF,$0000
        dc.w    $7EC7,$F0F8,$FF00,$0000,$DFF2,$3E03,$3FFC,$0000
        dc.w    $3FFF,$C1FC,$01FF,$0000,$D3A3,$1C3F,$E1CF,$0000
        dc.w    $71C3,$81FC,$FE00,$0000,$F70E,$0E0F,$0FF0,$0000
        dc.w    $1FE4,$E018,$001F,$0000,$674C,$7873,$8783,$0000
        dc.w    $4780,$87FF,$F800,$0000,$F9FC,$06FF,$0700,$0000
        dc.w    $0F00,$F0FF,$00FF,$0000,$7CC6,$80F9,$FF01,$0000
        dc.w    $FF80,$FFFF,$F000,$0000,$4100,$BFFF,$3FF0,$0000
        dc.w    $003F,$FFF0,$07FF,$0000,$8787,$07F8,$F800,$0000

;        dc.w    $FFAF,$FE37,$FFC7,$0000,$FFFC,$FFF0,$FFFF,$0000
;        dc.w    $BFFF,$CFFF,$0FFF,$0000,$E5FF,$86FF,$F8FF,$0000
;        dc.w    $FF4E,$F070,$FF87,$0000,$8DFB,$FFC3,$3FFC,$0000
;        dc.w    $1F7F,$E0F8,$00FF,$0000,$C8FF,$0F07,$F007,$0000
;        dc.w    $919D,$61E1,$7E1E,$0000,$31C7,$CE07,$0FF8,$0000
;        dc.w    $0FDC,$F038,$003F,$0000,$387F,$3F80,$C000,$0000
;        dc.w    $01F3,$FE03,$FFFC,$0000,$191E,$E61F,$07E0,$0000
;        dc.w    $03E7,$FC1B,$001C,$0000,$F03C,$FFC3,$0003,$0000
;        dc.w    $FE1E,$C01F,$FFE0,$0000,$1FFE,$E3FF,$03C0,$0000
;        dc.w    $0104,$FEFF,$00FF,$0000,$0000,$FFFF,$C01F,$0000

        dc.w    $FFFF,$FFFF,$FFFF,$0000,$FE38,$F03F,$FFC0,$0000
        dc.w    $30FF,$CFFF,$0FFF,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $F83F,$07FF,$07FF,$0000,$E078,$007F,$FF80,$0000
        dc.w    $3FF0,$C00F,$000F,$0000,$07C9,$FF0E,$FFF0,$0000
        dc.w    $7FFF,$8000,$03FF,$0000,$07E0,$07FF,$F800,$0000
        dc.w    $0FFE,$F001,$0001,$0000,$3F30,$C03F,$FFC0,$0000
        dc.w    $1FF0,$E000,$0FFF,$0000,$3F80,$3FFF,$C000,$0000
        dc.w    $03FF,$FC00,$0000,$0000,$C070,$007F,$7F80,$0000
        dc.w    $F007,$0007,$FFF8,$0000,$F000,$FFFF,$0000,$0000
        dc.w    $7FFF,$8000,$0000,$0000,$CB80,$33FF,$3C00,$0000







font:
        dc.w    $0000,$3e00,$0000,$7e00,$0000,$7e00,$0000,$fe00
        dc.w    $0001,$ff00,$0001,$ff00,$0003,$ff00,$0007,$ff00
        dc.w    $0007,$ff00,$000f,$7f80,$001e,$7f80,$001e,$3f80
        dc.w    $003c,$3f80,$0078,$3f80,$0078,$3fc0,$00f0,$3fc0
        dc.w    $01e0,$1fc0,$01e0,$1fc0,$03c0,$1fc0,$07ff,$ffe0
        dc.w    $07ff,$ffe0,$0fff,$ffe0,$1fff,$ffe0,$1e00,$0fe0
        dc.w    $3c00,$0ff0,$7800,$0ff0,$7800,$07f0,$f000,$07f0
        dc.w    $ff80,$07ff,$ff80,$07ff,$ff80,$07ff,$ff80,$07ff

        dc.w    $ffe1,$fff0,$ffe1,$fffc,$ffe1,$fffe,$ffe1,$fffe
        dc.w    $1fe0,$03ff,$1fe0,$01ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$01fe,$1fe0,$03fe,$1fe1,$fffc,$1fe1,$fff0
        dc.w    $1fe1,$fff0,$1fe1,$fffc,$1fe0,$03fe,$1fe0,$01fe
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$01ff,$1fe0,$03ff
        dc.w    $ffe1,$fffe,$ffe1,$fffe,$ffe1,$fffc,$ffe1,$fff0

        dc.w    $007c,$3fff,$03fc,$3fff,$0ffc,$3fff,$1ffc,$3fff
        dc.w    $3ffc,$003f,$3ffc,$001f,$7ffc,$000f,$7ffc,$000f
        dc.w    $7ffc,$000f,$fffc,$0000,$fffc,$0000,$fffc,$0000
        dc.w    $fffc,$0000,$fffc,$0000,$fffc,$0000,$fffc,$0000
        dc.w    $fffc,$0000,$fffc,$0000,$fffc,$0000,$fffc,$0000
        dc.w    $fffc,$0000,$fffc,$0000,$fffc,$0000,$7ffc,$000f
        dc.w    $7ffc,$000f,$7ffc,$000f,$3ffc,$001f,$3ffc,$003f
        dc.w    $1ffc,$3fff,$0ffc,$3fff,$03fc,$3fff,$007c,$3fff

        dc.w    $ffe1,$fff0,$ffe1,$fffc,$ffe1,$fffe,$ffe1,$fffe
        dc.w    $1fe0,$03ff,$1fe0,$01ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$01ff,$1fe0,$03ff
        dc.w    $ffe1,$fffe,$ffe1,$fffe,$ffe1,$fffc,$ffe1,$fff0

        dc.w    $ffe1,$ffff,$ffe1,$ffff,$ffe1,$ffff,$ffe1,$ffff
        dc.w    $1fe0,$003f,$1fe0,$001f,$1fe0,$000f,$1fe0,$000f
        dc.w    $1fe0,$000f,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000
        dc.w    $1fe0,$0000,$1fe0,$0000,$1fe1,$f800,$1fe1,$f800
        dc.w    $1fe1,$f800,$1fe1,$f800,$1fe0,$0000,$1fe0,$0000
        dc.w    $1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$000f
        dc.w    $1fe0,$000f,$1fe0,$000f,$1fe0,$001f,$1fe0,$003f
        dc.w    $ffe1,$ffff,$ffe1,$ffff,$ffe1,$ffff,$ffe1,$ffff

        dc.w    $ffe1,$ffff,$ffe1,$ffff,$ffe1,$ffff,$ffe1,$ffff
        dc.w    $1fe0,$003f,$1fe0,$001f,$1fe0,$000f,$1fe0,$000f
        dc.w    $1fe0,$000f,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000
        dc.w    $1fe0,$0000,$1fe0,$0000,$1fe1,$f800,$1fe1,$f800
        dc.w    $1fe1,$f800,$1fe1,$f800,$1fe0,$0000,$1fe0,$0000
        dc.w    $1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000
        dc.w    $1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000
        dc.w    $fffc,$0000,$fffc,$0000,$fffc,$0000,$fffc,$0000

        dc.w    $007c,$3fff,$03fc,$3fff,$0ffc,$3fff,$1ffc,$3fff
        dc.w    $3ffc,$003f,$3ffc,$001f,$7ffc,$000f,$7ffc,$000f
        dc.w    $7ffc,$000f,$fffc,$0000,$fffc,$0000,$fffc,$0000
        dc.w    $fffc,$0000,$fffc,$0000,$fffc,$0fff,$fffc,$0fff
        dc.w    $fffc,$0fff,$fffc,$0fff,$fffc,$00ff,$fffc,$00ff
        dc.w    $fffc,$00ff,$fffc,$00ff,$fffc,$00ff,$7ffc,$00ff
        dc.w    $7ffc,$00ff,$7ffc,$00ff,$3ffc,$01ff,$3ffc,$03ff
        dc.w    $1ffc,$3ffe,$0ffc,$3ffe,$03fc,$3ffc,$007c,$3ff0

        dc.w    $ffe0,$00ff,$ffe0,$00ff,$ffe0,$00ff,$ffe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe1,$ffff,$1fe1,$ffff
        dc.w    $1fe1,$ffff,$1fe1,$ffff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $ffe0,$00ff,$ffe0,$00ff,$ffe0,$00ff,$ffe0,$00ff

        dc.w    $007f,$fe00,$007f,$fe00,$007f,$fe00,$007f,$fe00
        dc.w    $000f,$f000,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $000f,$f000,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $000f,$f000,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $000f,$f000,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $000f,$f000,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $000f,$f000,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $007f,$fe00,$007f,$fe00,$007f,$fe00,$007f,$fe00

        dc.w    $0000,$fffc,$0000,$fffc,$0000,$fffc,$0000,$fffc
        dc.w    $0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0
        dc.w    $0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0
        dc.w    $0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0
        dc.w    $0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0
        dc.w    $0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$1e00,$1fe0
        dc.w    $1e00,$1fe0,$1e00,$1fe0,$1f00,$1fe0,$1f80,$1fe0
        dc.w    $1ffe,$1fc0,$1ffe,$1fc0,$1ffe,$1f80,$1ffe,$1e00

        dc.w    $ffe0,$07ff,$ffe0,$07ff,$ffe0,$07ff,$ffe0,$07ff
        dc.w    $1fe0,$01f8,$1fe0,$03f0,$1fe0,$07e0,$1fe0,$0fc0
        dc.w    $1fe0,$1f80,$1fe0,$3f00,$1fe0,$7e00,$1fe0,$fc00
        dc.w    $1fe1,$f800,$1fe1,$fc00,$1fe1,$fe00,$1fe1,$ff00
        dc.w    $1fe1,$ff80,$1fe1,$ffc0,$1fe1,$ffe0,$1fe1,$fff0
        dc.w    $1fe0,$3ff8,$1fe0,$1ffc,$1fe0,$0ffe,$1fe0,$07fe
        dc.w    $1fe0,$03ff,$1fe0,$01ff,$1fe0,$01ff,$1fe0,$00ff
        dc.w    $ffe0,$00ff,$ffe0,$00ff,$ffe0,$00ff,$ffe0,$00ff

        dc.w    $fffc,$0000,$fffc,$0000,$fffc,$0000,$fffc,$0000
        dc.w    $1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000
        dc.w    $1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000
        dc.w    $1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000
        dc.w    $1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000
        dc.w    $1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$000f
        dc.w    $1fe0,$000f,$1fe0,$000f,$1fe0,$001f,$1fe0,$003f
        dc.w    $ffe1,$ffff,$ffe1,$ffff,$ffe1,$ffff,$ffe1,$ffff

        dc.w    $f800,$00ff,$fc00,$01ff,$fe00,$03ff,$ff00,$07ff
        dc.w    $7f80,$0fff,$3fc0,$1fff,$1fe0,$3fff,$0ff0,$7fff
        dc.w    $87f8,$ffff,$c3fd,$ffff,$e1ff,$feff,$f0ff,$fcff
        dc.w    $f07f,$f8ff,$f03f,$f0ff,$f01f,$e0ff,$f00f,$c0ff
        dc.w    $f007,$80ff,$f000,$00ff,$f000,$00ff,$f000,$00ff
        dc.w    $f000,$00ff,$f000,$00ff,$f000,$00ff,$f000,$00ff
        dc.w    $f000,$00ff,$f000,$00ff,$f000,$00ff,$f000,$00ff
        dc.w    $fe00,$07ff,$fe00,$07ff,$fe00,$07ff,$fe00,$07ff

        dc.w    $ff00,$007f,$ff80,$007f,$7fc0,$007f,$3fe0,$007f
        dc.w    $1ff0,$000f,$0ff8,$000f,$87fc,$000f,$c3fe,$000f
        dc.w    $e1ff,$000f,$f0ff,$800f,$f07f,$c00f,$f03f,$e00f
        dc.w    $f01f,$f00f,$f00f,$f80f,$f007,$fc0f,$f003,$fe0f
        dc.w    $f001,$ff0f,$f000,$ff87,$f000,$7fc3,$f000,$3fe1
        dc.w    $f000,$1ff0,$f000,$0ff8,$f000,$07fc,$f000,$03fe
        dc.w    $f000,$01ff,$f000,$00ff,$f000,$007f,$f000,$003f
        dc.w    $fe00,$001f,$fe00,$000f,$fe00,$0007,$fe00,$0003

        dc.w    $0ffc,$3ff0,$3ffc,$3ffc,$7ffc,$3ffe,$7ffc,$3ffe
        dc.w    $ffc0,$03ff,$ff80,$01ff,$ff00,$00ff,$ff00,$00ff
        dc.w    $ff00,$00ff,$ff00,$00ff,$ff00,$00ff,$ff00,$00ff
        dc.w    $ff00,$00ff,$ff00,$00ff,$ff00,$00ff,$ff00,$00ff
        dc.w    $ff00,$00ff,$ff00,$00ff,$ff00,$00ff,$ff00,$00ff
        dc.w    $ff00,$00ff,$ff00,$00ff,$ff00,$00ff,$ff00,$00ff
        dc.w    $ff00,$00ff,$ff00,$00ff,$ff80,$01ff,$ffc0,$03ff
        dc.w    $7ffc,$3ffe,$7ffc,$3ffe,$3ffc,$3ffc,$0ffc,$3ff0

        dc.w    $ffe1,$fff0,$ffe1,$fffc,$ffe1,$fffe,$ffe1,$fffe
        dc.w    $1fe0,$03ff,$1fe0,$01ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$01ff,$1fe0,$03ff,$1fe1,$fffe,$1fe1,$fffe
        dc.w    $1fe1,$fffc,$1fe1,$fff0,$1fe0,$0000,$1fe0,$0000
        dc.w    $1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000
        dc.w    $1fe0,$0000,$1fe0,$0000,$1fe0,$0000,$1fe0,$0000
        dc.w    $fffc,$0000,$fffc,$0000,$fffc,$0000,$fffc,$0000

        dc.w    $0ffc,$3ff0,$3ffc,$3ffc,$7ffc,$3ffe,$7ffc,$3ffe
        dc.w    $ffc0,$03ff,$ff80,$01ff,$ff00,$00ff,$ff00,$00ff
        dc.w    $ff00,$00ff,$ff00,$00ff,$ff00,$00ff,$ff00,$00ff
        dc.w    $ff00,$00ff,$ff00,$00ff,$ff00,$00ff,$ff00,$00ff
        dc.w    $ff00,$00ff,$ff00,$00ff,$ff03,$80ff,$ff03,$c0ff
        dc.w    $ff03,$e0ff,$ff03,$f0ff,$ff01,$f8ff,$ff00,$fc7f
        dc.w    $ff00,$7e3e,$ff00,$3f1c,$ff80,$1f80,$ffc0,$0fc0
        dc.w    $7fff,$c7ff,$7fff,$e3ff,$3fff,$f1ff,$0fff,$f8ff



        dc.w    $ffe1,$fff0,$ffe1,$fffc,$ffe1,$fffe,$ffe1,$fffe
        dc.w    $1fe0,$03ff,$1fe0,$01ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$01ff,$1fe0,$03fe,$1fe1,$fffc,$1fe1,$fff0
        dc.w    $1fe1,$fff0,$1fe1,$fffc,$1fe0,$03fe,$1fe0,$01fe
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff,$1fe0,$00ff
        dc.w    $ffe0,$07ff,$ffe0,$07ff,$ffe0,$07ff,$ffe0,$07ff

        dc.w    $0ffc,$3fff,$3ffc,$3fff,$7ffc,$3fff,$7ffc,$3fff
        dc.w    $ffc0,$003f,$ff80,$001f,$ff00,$000f,$ff00,$000f
        dc.w    $ff80,$000f,$ffe0,$0000,$fffc,$0000,$ffff,$8000
        dc.w    $ffff,$f000,$ffff,$fe00,$7fff,$ffc0,$3fff,$fff0
        dc.w    $0fff,$fffc,$03ff,$fffe,$007f,$ffff,$000f,$ffff
        dc.w    $0001,$ffff,$0000,$3fff,$0000,$07ff,$f000,$01ff
        dc.w    $f000,$00ff,$f000,$00ff,$f800,$01ff,$fc00,$03ff
        dc.w    $fffc,$3ffe,$fffc,$3ffe,$fffc,$3ffc,$fffc,$3ff0

        dc.w    $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
        dc.w    $fc0f,$f03f,$f80f,$f01f,$f00f,$f00f,$f00f,$f00f
        dc.w    $f00f,$f00f,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $000f,$f000,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $000f,$f000,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $000f,$f000,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $000f,$f000,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $007f,$fe00,$007f,$fe00,$007f,$fe00,$007f,$fe00

        dc.w    $fffc,$007f,$fffc,$007f,$fffc,$007f,$fffc,$007f
        dc.w    $1fe0,$000f,$1fe0,$000f,$1fe0,$000f,$1fe0,$000f
        dc.w    $1fe0,$000f,$1fe0,$000f,$1fe0,$000f,$1fe0,$000f
        dc.w    $1fe0,$000f,$1fe0,$000f,$1fe0,$000f,$1fe0,$000f
        dc.w    $1fe0,$000f,$1fe0,$000f,$1fe0,$000f,$1fe0,$000f
        dc.w    $1fe0,$000f,$1fe0,$000f,$1fe0,$000f,$1fe0,$000f
        dc.w    $1fe0,$000f,$1fe0,$000f,$1ff0,$001f,$1ff8,$003f
        dc.w    $0fff,$fffe,$0fff,$fffe,$07ff,$fffc,$01ff,$fff0

        dc.w    $ffe0,$007f,$ffe0,$007f,$ffe0,$007f,$ffe0,$007f
        dc.w    $1fe0,$000f,$1ff0,$000f,$0ff0,$000f,$0ff8,$001f
        dc.w    $07f8,$001e,$07fc,$001e,$03fc,$003c,$03fe,$003c
        dc.w    $01fe,$003c,$01ff,$0078,$00ff,$0078,$00ff,$8078
        dc.w    $007f,$80f0,$007f,$c0f0,$003f,$c0f0,$003f,$e1e0
        dc.w    $001f,$e1e0,$001f,$f1e0,$000f,$f3c0,$000f,$fbc0
        dc.w    $0007,$fbc0,$0007,$ff80,$0003,$ff80,$0003,$ff80
        dc.w    $0001,$ff00,$0001,$ff00,$0000,$ff00,$0000,$ff00

        dc.w    $ffe0,$007f,$ffe0,$007f,$ffe0,$007f,$ffe0,$007f
        dc.w    $ff00,$000f,$ff00,$000f,$ff00,$000f,$ff00,$000f
        dc.w    $ff00,$000f,$ff00,$000f,$ff00,$000f,$ff00,$000f
        dc.w    $ff00,$000f,$ff00,$000f,$ff00,$000f,$ff01,$e00f
        dc.w    $ff03,$f00f,$ff07,$f80f,$ff0f,$fc0f,$ff1f,$fe0f
        dc.w    $ff3f,$ff0f,$ff7f,$ff87,$ffff,$bfc3,$ffff,$1fe1
        dc.w    $fffe,$0ff0,$fffc,$07f8,$fff8,$03fc,$fff0,$01fe
        dc.w    $ffe0,$00ff,$ffc0,$007f,$ff80,$003f,$ff00,$001f

        dc.w    $fff0,$01ff,$fff0,$01ff,$fff0,$01ff,$fff0,$01fe
        dc.w    $ff80,$007c,$7fc0,$00f8,$3fe0,$01f0,$1ff0,$03e0
        dc.w    $0ff8,$07c0,$07fc,$0f80,$03fe,$1f00,$01ff,$3e00
        dc.w    $00ff,$fc00,$007f,$f800,$003f,$f000,$001f,$f000
        dc.w    $000f,$f800,$000f,$fc00,$001f,$fe00,$003f,$ff00
        dc.w    $007c,$ff80,$00f8,$7fc0,$01f0,$3fe0,$03e0,$1ff0
        dc.w    $07c0,$0ff8,$0f80,$07fc,$1f00,$03fe,$3e00,$01ff
        dc.w    $7f80,$0fff,$ff80,$0fff,$ff80,$0fff,$ff80,$0fff

        dc.w    $fff0,$01ff,$fff0,$01ff,$fff0,$01ff,$fff0,$01fe
        dc.w    $ff80,$007c,$7fc0,$00f8,$3fe0,$01f0,$1ff0,$03e0
        dc.w    $0ff8,$07c0,$07fc,$0f80,$03fe,$1f00,$01ff,$3e00
        dc.w    $00ff,$fc00,$007f,$f800,$003f,$f000,$001f,$f000
        dc.w    $000f,$f000,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $000f,$f000,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $000f,$f000,$000f,$f000,$000f,$f000,$000f,$f000
        dc.w    $007f,$fe00,$007f,$fe00,$007f,$fe00,$007f,$fe00

        dc.w    $ffff,$fe1f,$ffff,$fc3f,$ffff,$f87f,$ffff,$f0ff
        dc.w    $fc00,$01ff,$f800,$03fe,$f000,$07fc,$f000,$0ff8
        dc.w    $f000,$1ff0,$0000,$3fe0,$0000,$7fc0,$0000,$ff80
        dc.w    $0001,$ff00,$0003,$fe00,$0007,$fc00,$000f,$f800
        dc.w    $001f,$f000,$003f,$e000,$007f,$c000,$00ff,$8000
        dc.w    $01ff,$0000,$03fe,$0000,$07fc,$0000,$0ff8,$000f
        dc.w    $1ff0,$000f,$3fe0,$000f,$7fc0,$001f,$ff80,$003f
        dc.w    $ff0f,$ffff,$fe1f,$ffff,$fc3f,$ffff,$f87f,$ffff

        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000


        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $03c0,$0000,$07e0,$0000,$0ff0,$0000,$0ff0,$0000
        dc.w    $0ff0,$0000,$0ff0,$0000,$07e0,$0000,$03c0,$0000

;       dc.w    $0ff0,$0000,$0ff0,$0000,$0ff0,$0000,$0ff0,$0000
;       dc.w    $0ff0,$0000,$0ff0,$0000,$0ff0,$0000,$0ff0,$0000
;       dc.w    $0ff0,$0000,$0ff0,$0000,$0ff0,$0000,$0ff0,$0000
;       dc.w    $0ff0,$0000,$0ff0,$0000,$0ff0,$0000,$0ff0,$0000
;       dc.w    $0ff0,$0000,$0ff0,$0000,$0ff0,$0000,$0ff0,$0000
;       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;       dc.w    $0ff0,$0000,$0ff0,$0000,$0ff0,$0000,$0ff0,$0000
;       dc.w    $0ff0,$0000,$0ff0,$0000,$0ff0,$0000,$0ff0,$0000

        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$03C0,$0000
        dc.w    $07E0,$0000,$0FF0,$0000,$0FF0,$0000,$0FF0,$0000
        dc.w    $0FF0,$0000,$07F0,$0000,$03F0,$0000,$00F0,$0000
        dc.w    $01E0,$0000,$01E0,$0000,$03C0,$0000,$0F80,$0000


; 29 chars, so far

unshifteddistblock:
;
;  NEOchrome cut buffer contents (left justified):
;
;    pixels/scanline    = $0130 (bytes/scanline: $0098)
;  # scanlines (height) = $0019
;
;  Hardware color pallet  (color 0 to 15):
;
;      $0000,$0760,$0750,$0640,$0530,$0420,$0310,$0003
;      $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0777
;
;

        dc.w    $0719,$0B1E,$0CE0,$0000,$C69E,$3EE0,$0102,$0000
        dc.w    $0000,$0000,$0000,$0000,$0034,$05F2,$060E,$0000
        dc.w    $0721,$08E1,$001E,$0000,$39CC,$C7CD,$0033,$0000
        dc.w    $001F,$002F,$0030,$0000,$BD99,$C39E,$0060,$0000
        dc.w    $C872,$308E,$0801,$0000,$139C,$1C7C,$E003,$0000
        dc.w    $C001,$D802,$3803,$0000,$FBD9,$FC39,$0006,$0000
        dc.w    $9C80,$E300,$0080,$0000,$0000,$0001,$0001,$0000
        dc.w    $0D01,$7C82,$8380,$0000,$C84E,$3871,$0780,$0000
        dc.w    $7300,$F340,$0CC0,$0000,$186F,$2870,$3780,$0000
        dc.w    $6672,$E78C,$1802,$0000,$1793,$2B9C,$3060,$0000
        dc.w    $CCBC,$3CC2,$0306,$0000,$0000,$0000,$0000,$0000
        dc.w    $0DA2,$0661,$081F,$0000,$03B3,$0473,$080C,$0000
        dc.w    $3739,$CF3F,$00C0,$0000,$805F,$40AF,$C0C0,$0000
        dc.w    $DC9B,$E39C,$0060,$0000,$903B,$6847,$1880,$0000
        dc.w    $3373,$3CF3,$C00C,$0000,$9805,$F40A,$0C0C,$0000
        dc.w    $FDC9,$FE39,$0006,$0000,$B900,$C680,$0180,$0000
        dc.w    $0003,$0001,$0002,$0000,$6880,$9841,$07C2,$0000
        dc.w    $ECCD,$1CF3,$0300,$0000,$CE60,$CFD0,$3030,$0000
        dc.w    $6C77,$3C78,$4380,$0000,$26E4,$E71A,$1806,$0000
        dc.w    $2DB9,$53BE,$6040,$0000,$9978,$7986,$060E,$0000
        dc.w    $0000,$0000,$0000,$0000,$13AF,$0C6E,$1011,$0000
        dc.w    $01DF,$023F,$0C00,$0000,$4773,$BF7F,$0080,$0000
        dc.w    $40B7,$014F,$C180,$0000,$E6B7,$F9B8,$0040,$0000
        dc.w    $201D,$D823,$38C0,$0000,$F477,$FBF7,$0008,$0000
        dc.w    $340B,$F014,$0C18,$0000,$7E6B,$FF9B,$0004,$0000
        dc.w    $7200,$8D80,$0380,$0000,$0004,$0003,$0004,$0000
        dc.w    $EBC0,$1B80,$0443,$0000,$77D1,$8FEF,$0000,$0000
        dc.w    $DCD0,$DFC0,$2030,$0000,$7439,$CC3E,$83C0,$0000
        dc.w    $ADC8,$6E36,$100E,$0000,$4DFF,$33FF,$41FF,$0000
        dc.w    $FFF2,$FFFC,$FFFE,$0000,$0000,$0000,$0000,$0000
        dc.w    $21FF,$1EFC,$20F3,$0000,$09FF,$01FF,$0FFF,$0000
        dc.w    $FFFE,$FFFE,$FFFD,$0000,$C137,$20CF,$E107,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$C09F,$F81F,$F8FF,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$EC13,$E20C,$DE10,$0000
        dc.w    $7FFF,$FFFF,$7FFF,$0000,$FC00,$FF80,$FF80,$0000
        dc.w    $0008,$0007,$0008,$0000,$7FC2,$BF00,$3CC3,$0000
        dc.w    $7FFF,$7FFF,$FFFF,$0000,$FFB0,$FF88,$FF78,$0000
        dc.w    $B7FF,$4FFF,$87FF,$0000,$FFF0,$FFFE,$FFFE,$0000
        dc.w    $27FF,$DFFF,$87FF,$0000,$FFF6,$FFF8,$FFFE,$0000
        dc.w    $0000,$0000,$0000,$0000,$7BFE,$3FF9,$43FF,$0000
        dc.w    $0DFF,$81FF,$8FFF,$0000,$FFFF,$FFFE,$FFFF,$0000
        dc.w    $E09F,$037F,$E21F,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $D8DF,$E01F,$F8FF,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $FE09,$E037,$FE21,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $FD80,$FE00,$FF80,$0000,$001E,$000F,$0010,$0000
        dc.w    $FF83,$FE60,$FFE3,$0000,$7FFF,$7FFF,$FFFF,$0000
        dc.w    $FFF8,$FF80,$FFF8,$0000,$CFFF,$FFFF,$0FFF,$0000
        dc.w    $FFF6,$FFF8,$FFFE,$0000,$BFFF,$4FFF,$8FFF,$0000
        dc.w    $FFFE,$FFF0,$FFFE,$0000,$0000,$0000,$0000,$0000
        dc.w    $FFFC,$7FFF,$87FF,$0000,$0FFF,$81FF,$8FFF,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$82FF,$613F,$E23F,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$E0FF,$C01F,$F8FF,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$F82F,$F613,$FE23,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$FE00,$FC00,$FF80,$0000
        dc.w    $003F,$001F,$0021,$0000,$FF03,$FFE0,$FFE3,$0000
        dc.w    $FFFF,$7FFF,$FFFF,$0000,$FFE0,$FFD8,$FFF8,$0000
        dc.w    $FFFF,$FFFF,$1FFF,$0000,$FFF8,$FFF0,$FFFE,$0000
        dc.w    $CFFF,$FFFF,$0FFF,$0000,$FFF2,$FFFC,$FFFE,$0000
        dc.w    $0001,$0000,$0001,$0000,$7FFC,$FFFF,$0FFF,$0000
        dc.w    $89FF,$01FF,$8FFF,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $033F,$E3FF,$E03F,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $C09F,$C01F,$F8FF,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $F033,$FE3F,$FE03,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $FC00,$FC00,$FF80,$0000,$005F,$003F,$0043,$0000
        dc.w    $FF22,$FFC0,$FFE3,$0000,$7FFF,$7FFF,$FFFF,$0000
        dc.w    $FFC0,$FFF8,$FFF8,$0000,$7FFF,$7FFF,$9FFF,$0000
        dc.w    $FFF0,$FFF0,$FFFE,$0000,$7FFF,$7FFF,$9FFF,$0000
        dc.w    $FFF0,$FFFE,$FFFE,$0000,$0002,$0001,$0002,$0000
        dc.w    $1FFD,$FFFE,$1FFF,$0000,$81FF,$01FF,$8FFF,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$01FF,$E1FF,$E27F,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$F81F,$C01F,$F8FF,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$F01F,$FE1F,$FE27,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$FF80,$FC00,$FF80,$0000
        dc.w    $0087,$007F,$0087,$0000,$FF60,$FF80,$FFE3,$0000
        dc.w    $7FFF,$7FFF,$FFFF,$0000,$FFC0,$FFF8,$FFF8,$0000
        dc.w    $9FFF,$1FFF,$FFFF,$0000,$FFFE,$FFF0,$FFFE,$0000
        dc.w    $7F83,$7FFC,$9FFF,$0000,$CF00,$300E,$FFFE,$0000
        dc.w    $0007,$0000,$0004,$0000,$FFFF,$3FFC,$3FFF,$0000
        dc.w    $8E00,$01FF,$8FFF,$0000,$003F,$FFDF,$FFFF,$0000
        dc.w    $01FE,$E1FF,$E27F,$0000,$0000,$FFFF,$FFFF,$0000
        dc.w    $00E0,$F81F,$F8FF,$0000,$0003,$FFFD,$FFFF,$0000
        dc.w    $F01F,$FE1F,$FE27,$0000,$E000,$FFFF,$FFFF,$0000
        dc.w    $0000,$FF80,$FF80,$0000,$01FF,$000F,$010F,$0000
        dc.w    $FFE3,$FF00,$FFE3,$0000,$8000,$7FFF,$FFFF,$0000
        dc.w    $0FC0,$F7F8,$FFF8,$0000,$DF40,$1F3F,$FFFF,$0000
        dc.w    $3C0E,$C3F0,$FFFE,$0000,$3F0C,$3FF0,$DFFF,$0000
        dc.w    $61C0,$1E06,$FFFE,$0000,$000F,$0000,$0008,$0000
        dc.w    $FE7E,$7FFC,$7FFF,$0000,$8E78,$087F,$8780,$0000
        dc.w    $D6BF,$377F,$081F,$0000,$00FC,$E0FD,$E37E,$0000
        dc.w    $F2BC,$0EC3,$0100,$0000,$80E7,$B887,$7878,$0000
        dc.w    $8D6B,$F377,$0081,$0000,$F00F,$FE0F,$FE37,$0000
        dc.w    $CF2B,$D0EC,$E010,$0000,$C800,$3B80,$0780,$0000
        dc.w    $03FF,$001F,$021F,$0000,$9FA3,$FF02,$FFE1,$0000
        dc.w    $9E35,$1FCD,$E002,$0000,$AFC0,$DFF8,$07F8,$0000
        dc.w    $9FCC,$1FF3,$FF00,$0000,$E0EE,$E0F8,$1F06,$0000
        dc.w    $3F03,$3FFC,$DFFF,$0000,$80E0,$7F02,$FFFE,$0000
        dc.w    $001F,$0000,$0010,$0000,$FFFC,$FCFC,$FF7F,$0000
        dc.w    $0DFF,$0DFF,$83FF,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $00FF,$E0FF,$E37F,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $C8DF,$F0DF,$F83F,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $F00F,$FE0F,$FE37,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $FC80,$FF00,$FF80,$0000,$07FF,$003F,$043F,$0000
        dc.w    $FF03,$3F03,$DFE0,$0000,$7FFF,$7FFF,$FFFF,$0000
        dc.w    $FFC0,$FFF8,$FFF8,$0000,$3FFF,$3FFF,$DFFF,$0000
        dc.w    $FFD8,$FFE4,$FFC0,$0000,$9F00,$9FE0,$7FE0,$0000
        dc.w    $0000,$0000,$0000,$0000,$002F,$0011,$0021,$0000
        dc.w    $FAFD,$FCFD,$FF7E,$0000,$07FF,$0FFF,$81FF,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$027F,$E27F,$E1FF,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$D8FF,$E0FF,$F81F,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$E027,$FE27,$FE1F,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$FD80,$FE00,$FF80,$0000
        dc.w    $0BFE,$047F,$087F,$0000,$BF41,$3F43,$DFA0,$0000
        dc.w    $FFFF,$FFFF,$7FFF,$0000,$FFC0,$FFF8,$FFF8,$0000
        dc.w    $FFFF,$FFFF,$1FFF,$0000,$FFF6,$FFEE,$FFE0,$0000
        dc.w    $5F00,$DFE0,$3FE0,$0000,$0000,$0000,$0000,$0000
        dc.w    $004F,$0033,$0043,$0000,$F07D,$FFFD,$FE7E,$0000
        dc.w    $03FF,$0FFF,$81FF,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $817F,$637F,$E0FF,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $F8BF,$C0FF,$F81F,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $CC17,$F037,$FC0F,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $FF80,$FC00,$FF80,$0000,$13FC,$0CFF,$10FF,$0000
        dc.w    $1F40,$FF43,$9FA0,$0000,$FFFF,$FFFF,$7FFF,$0000
        dc.w    $FFE0,$FFD8,$FFF8,$0000,$9FFF,$FFFF,$1FFF,$0000
        dc.w    $FFFC,$FFFC,$FFF2,$0000,$3F60,$FF90,$1FF0,$0000
        dc.w    $0000,$0000,$0000,$0000,$00CF,$0077,$0087,$0000
        dc.w    $E57C,$FBFC,$FC7F,$0000,$05FF,$0BFF,$81FF,$0000
        dc.w    $FFFF,$FFFE,$FFFF,$0000,$E0FF,$03FF,$E07F,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$D81F,$E0FF,$F81F,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$E60F,$E03F,$FE07,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$FD80,$FE00,$FF80,$0000
        dc.w    $33F9,$1DFE,$21FF,$0000,$5F01,$FF02,$1FE0,$0000
        dc.w    $7FFF,$FFFF,$7FFF,$0000,$FFF8,$FF80,$FFF8,$0000
        dc.w    $AFFF,$6FFF,$9FFF,$0000,$FFF2,$FFF0,$FFFE,$0000
        dc.w    $DFC8,$3F0F,$1FF0,$0000,$61C8,$9FF4,$0002,$0000
        dc.w    $01CF,$00FF,$010F,$0000,$C3FE,$F7FC,$F87F,$0000
        dc.w    $8DFF,$03FF,$81FF,$0000,$FFFE,$FFFC,$FFFF,$0000
        dc.w    $C37F,$C0FF,$007F,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $C85F,$F0BF,$F81F,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $FC37,$F20F,$FE07,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $FC80,$FF00,$FF80,$0000,$73F0,$3FFD,$43FE,$0000
        dc.w    $FFA3,$FF00,$1FE0,$0000,$7FFF,$FFFF,$7FFF,$0000
        dc.w    $FFB0,$FF30,$FFC0,$0000,$5FFF,$47FF,$3FFF,$0000
        dc.w    $FFFE,$FFF0,$FFFE,$0000,$FF98,$1F1F,$1FE0,$0000
        dc.w    $F390,$0FEA,$0006,$0000,$02FF,$01FF,$021F,$0000
        dc.w    $FFFF,$FFFC,$FFFF,$0000,$8DF1,$03FE,$81FF,$0000
        dc.w    $C3FF,$03FF,$FC7E,$0000,$E3FC,$E07F,$007F,$0000
        dc.w    $0000,$FFFF,$FFFF,$0000,$00FF,$F81F,$F81F,$0000
        dc.w    $1C01,$E3FF,$FFFF,$0000,$F03F,$FE07,$FE07,$0000
        dc.w    $C000,$FFFF,$FFFF,$0000,$0000,$FF80,$FF80,$0000
        dc.w    $BFFF,$7FFF,$87FF,$0000,$FFE3,$FF00,$FFE0,$0000
        dc.w    $7C70,$FF80,$7FFF,$0000,$FFF8,$FFF8,$1F80,$0000
        dc.w    $DCC0,$B03F,$0FFF,$0000,$1DF0,$E1FE,$FFFE,$0000
        dc.w    $DFBC,$3FBF,$1FC0,$0000,$7220,$8FD6,$000E,$0000
        dc.w    $04FF,$03FF,$043F,$0000,$FFFD,$FFFE,$FFFF,$0000
        dc.w    $85F0,$0BFF,$81FF,$0000,$71BF,$81FF,$FE3F,$0000
        dc.w    $237E,$20FE,$C07F,$0000,$9CE3,$E3FF,$0000,$0000
        dc.w    $98FF,$A01F,$781F,$0000,$CF39,$F0FF,$0001,$0000
        dc.w    $F037,$FE0F,$FE07,$0000,$E9CE,$EE3F,$F000,$0000
        dc.w    $3981,$FA00,$0781,$0000,$3FFF,$FFFF,$0FFF,$0000
        dc.w    $FF61,$FF82,$FFE0,$0000,$7C1C,$FFE0,$7FFF,$0000
        dc.w    $6FC8,$7FC8,$8FF0,$0000,$F199,$CF9E,$0060,$0000
        dc.w    $B1F0,$71FE,$0FFE,$0000,$1FFF,$FFFF,$1FFF,$0000
        dc.w    $FFF0,$FFFE,$FFFE,$0000,$08FF,$07FF,$087F,$0000
        dc.w    $FFFC,$FFFF,$FFFF,$0000,$81F8,$0FF7,$81FF,$0000
        dc.w    $191F,$E1FF,$FE1F,$0000,$807F,$03FF,$E07F,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$F85F,$C0BF,$F81F,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$F007,$FE3F,$FE07,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$FF82,$FC01,$FF82,$0000
        dc.w    $3FFF,$FFFF,$1FFF,$0000,$FF20,$FFC3,$FFE0,$0000
        dc.w    $7E06,$FDF8,$7FFF,$0000,$47E0,$7FC0,$87F8,$0000
        dc.w    $FFFF,$FFFF,$1FFF,$0000,$FFF8,$FFF6,$FFFE,$0000
        dc.w    $BFFF,$FFFF,$0FFF,$0000,$FFF2,$FFFC,$FFFE,$0000
        dc.w    $1CFF,$0FFC,$10FF,$0000,$00FC,$007F,$FFFF,$0000
        dc.w    $8BFC,$0FF2,$81FE,$0000,$00BF,$00DF,$001F,$0000
        dc.w    $C2FF,$03FF,$E03F,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $F01F,$C8FF,$F81F,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $F02F,$FE3F,$FE03,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $FF07,$FC83,$FF84,$0000,$3FC0,$FF00,$3FFF,$0000
        dc.w    $3F22,$1FC3,$FFE0,$0000,$FF00,$FC80,$7F80,$0000
        dc.w    $2FF0,$37C0,$07F8,$0000,$3FFF,$FFFF,$1FFF,$0000
        dc.w    $FFFC,$FFF2,$FFFE,$0000,$EFFF,$6FFF,$9FFF,$0000
        dc.w    $FFF6,$FFF8,$FFFE,$0000,$27F9,$1FFE,$21FF,$0000
        dc.w    $C3FC,$00FF,$FF7F,$0000,$0DF6,$8FF0,$81FE,$0000
        dc.w    $00FF,$001F,$001F,$0000,$63BF,$81BF,$E27F,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$E01F,$D8FF,$F81F,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$F83B,$F61B,$FE27,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$FE09,$FD87,$FF88,$0000
        dc.w    $FE70,$FF80,$7FFF,$0000,$FF03,$3FE3,$DFE0,$0000
        dc.w    $7D80,$FC00,$7F80,$0000,$3FD8,$07E0,$07F8,$0000
        dc.w    $9FFF,$7FFF,$1FFF,$0000,$FFFE,$FFF0,$FFFE,$0000
        dc.w    $4FFF,$CFFF,$B7FF,$0000,$FFFC,$FFF0,$FFFE,$0000
        dc.w    $23F0,$3FFF,$03FF,$0000,$6F7C,$81FF,$FE7F,$0000
        dc.w    $0BF2,$8DF0,$81FE,$0000,$00DF,$003F,$001F,$0000
        dc.w    $213F,$C33F,$E2DF,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $C0BF,$F8FF,$F81F,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $FE13,$E033,$FE2D,$0000,$FFFF,$FFFF,$FFFF,$0000
        dc.w    $FC08,$FF8F,$FF80,$0000,$FC1B,$FFE0,$FFFF,$0000
        dc.w    $DF02,$7FE3,$9FE0,$0000,$FC80,$7C00,$7F80,$0000
        dc.w    $37C8,$0FF0,$07F8,$0000,$FFFF,$1FFF,$1FFF,$0000
        dc.w    $FFE6,$FFE0,$FFFE,$0000,$53FF,$1FFF,$61FF,$0000
        dc.w    $FFF0,$FFF0,$FFFE,$0000,$1FE0,$1FFE,$27FE,$0000
        dc.w    $02FC,$037F,$007F,$0000,$05F2,$8BF0,$81FE,$0000
        dc.w    $00BF,$007F,$001F,$0000,$014F,$E07F,$E187,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$C0FF,$F8FF,$F81F,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$E414,$C207,$FE18,$0000
        dc.w    $FFFF,$FFFF,$7FFF,$0000,$FC07,$FF87,$FF89,$0000
        dc.w    $F800,$FF80,$FF80,$0000,$BF01,$DFE2,$1FE0,$0000
        dc.w    $7C80,$FC00,$7F80,$0000,$2FC0,$1FF8,$07F8,$0000
        dc.w    $DFFF,$3FFF,$1FFF,$0000,$FFD0,$FFD2,$FFEE,$0000
        dc.w    $248F,$5C70,$63FF,$0000,$0008,$FFF0,$FFFE,$0000
        dc.w    $2300,$0C3C,$3FFC,$0000,$01F8,$0303,$00FF,$0000
        dc.w    $0860,$8598,$83FE,$0000,$007E,$00C0,$003F,$0000
        dc.w    $0090,$E173,$E18F,$0000,$8D18,$70E0,$FFFF,$0000
        dc.w    $C0DE,$38E1,$F83F,$0000,$1FE0,$E01F,$FFFF,$0000
        dc.w    $3409,$C017,$FC18,$0000,$08D1,$370E,$FFFF,$0000
        dc.w    $8C08,$0383,$FF8F,$0000,$C000,$0F00,$FF00,$0000
        dc.w    $7E02,$C0E1,$3FE0,$0000,$1800,$6600,$FF80,$0000
        dc.w    $1F80,$3038,$0FF8,$0000,$A9B9,$5041,$3FFE,$0000
        dc.w    $E63C,$E038,$1FC4,$0000,$1930,$28C0,$37FF,$0000
        dc.w    $E004,$1FF8,$FFFE,$0000,$0180,$1E18,$3FF8,$0000
        dc.w    $031C,$02E1,$01FF,$0000,$00F0,$8B0C,$87FE,$0000
        dc.w    $00C7,$00B8,$007F,$0000,$0065,$60A2,$E0DF,$0000
        dc.w    $999C,$6060,$FFFF,$0000,$60B3,$18C0,$F87F,$0000
        dc.w    $0F3C,$F003,$FFFF,$0000,$1806,$E40A,$FC0D,$0000
        dc.w    $5999,$2606,$FFFF,$0000,$C600,$0187,$FF8F,$0000
        dc.w    $6000,$8600,$FE00,$0000,$C700,$B862,$7FE1,$0000
        dc.w    $3C00,$C300,$FF80,$0000,$31C0,$2E18,$1FF8,$0000
        dc.w    $530C,$A0F0,$7FFF,$0000,$9F90,$8014,$7FEC,$0000
        dc.w    $02E0,$0500,$07FF,$0000,$3802,$07FC,$FFFE,$0000
        dc.w    $00C0,$3F00,$3FF0,$0000,$020C,$01F0,$03FF,$0000
        dc.w    $0118,$8606,$8FFE,$0000,$0083,$007C,$00FF,$0000
        dc.w    $000B,$2014,$E01F,$0000,$B19E,$4060,$FFFF,$0000
        dc.w    $3061,$0880,$F8FF,$0000,$8607,$7800,$FFFF,$0000
        dc.w    $8000,$7001,$F001,$0000,$BB19,$4406,$FFFF,$0000
        dc.w    $E300,$008F,$FF8F,$0000,$3000,$C000,$FC00,$0000
        dc.w    $8300,$7C21,$FFE3,$0000,$4600,$8180,$FF80,$0000
        dc.w    $20C0,$1F08,$3FF8,$0000,$A604,$41F8,$FFFF,$0000
        dc.w    $30D0,$0F08,$FFF8,$0000

musix:          blk.l   2500
endvars:        dc.l    0


tab160:                 equ     block
newbackoforthtab:       equ     block+800
endbackoforttab:        equ     block+8992
fontadds:               equ     block+8992
shiftedblocks:          equ     fontadds+15360
shifteddistblocks:      equ     fontadds+61440
shiftedfont:            equ     fontadds+109440
screenadds:             equ     $70600
;fontadds:               blk.l   3840,0
;tab160:                 blk.l   200,0
;shiftedblocks:          blk.l   20480,0
;newbackoforthtab:       blk.l   2048,0
;shifteddistblocks:      blk.l   16000,0
;shiftedfont:            blk.l   10000,0





