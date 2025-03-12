org     $8000
load    $80000
x:
        bra     main



intsamp:
        move.w  #$2700,sr
        moveq   #10,d0
setregs:
        move.b  d0,$fff8800
        clr.b   $fff8802
        dbf     d0,setregs
        clr.b   $fff8800
        clr.b   $fff8802
        move.b  #7,$fff8800
        move.b  #$ff,$fff8802
        lea     snd_out(pc),a5
        lea     samplin,a6
        lea     sampdat(pc),a0
        move.l  a0,getsampdpos
        move.l  (a0),d0
        add.l   #samplin,d0
        add.l   4(a0),d0
        move.l  d0,enddissamp
        lea     $ff8800,a4
        rts




samp:   movem.l d0-d1,-(sp)
        moveq   #0,d0
        move.b  (a6)+,d0
        lsl.l   #3,d0
        move.l  (a5,d0.w),d1
        move.w  4(a5,d0.w),d0
        movep.l d1,0(a4)
        movep.w d0,0(a4)
        movem.l (sp)+,d0-d1
        rte


snd_out:

        dc.w    $80e,$90d,$a0c,0,$80f,$903,$a00,0
        dc.w    $80f,$903,$a00,0,$80f,$903,$a00,0
        dc.w    $80f,$903,$a00,0,$80f,$903,$a00,0
        dc.w    $80f,$903,$a00,0,$80e,$90d,$a0b,0
        dc.w    $80e,$90d,$a0b,0,$80e,$90d,$a0b,0
        dc.w    $80e,$90d,$a0b,0,$80e,$90d,$a0b,0
        dc.w    $80e,$90d,$a0b,0,$80e,$90d,$a0b,0
        dc.w    $80e,$90d,$a0a,0,$80e,$90d,$a0a,0

        dc.w    $80e,$90d,$a0a,0,$80e,$90d,$a0a,0
        dc.w    $80e,$90c,$a0c,0,$80e,$90d,$a00,0
        dc.w    $80d,$90d,$a0d,0,$80d,$90d,$a0d,0
        dc.w    $80d,$90d,$a0d,0,$80d,$90d,$a0d,0
        dc.w    $80d,$90d,$a0d,0,$80d,$90d,$a0d,0
        dc.w    $80e,$90c,$a0b,0,$80e,$90c,$a0b,0
        dc.w    $80e,$90c,$a0b,0,$80e,$90c,$a0b,0
        dc.w    $80e,$90c,$a0b,0,$80e,$90c,$a0b,0

        dc.w    $80e,$90c,$a0b,0,$80e,$90c,$a0b,0
        dc.w    $80e,$90c,$a0a,0,$80e,$90c,$a0a,0
        dc.w    $80e,$90c,$a0a,0,$80e,$90c,$a0a,0
        dc.w    $80d,$90d,$a0c,0,$80d,$90d,$a0c,0
        dc.w    $80e,$90c,$a09,0,$80e,$90c,$a09,0
        dc.w    $80e,$90c,$a05,0,$80e,$90c,$a00,0
        dc.w    $80e,$90c,$a00,0,$80e,$90b,$a0b,0
        dc.w    $80e,$90b,$a0b,0,$80e,$90b,$a0b,0

        dc.w    $80e,$90b,$a0b,0,$80e,$90b,$a0a,0
        dc.w    $80e,$90b,$a0a,0,$80e,$90b,$a0a,0
        dc.w    $80d,$90d,$a0b,0,$80d,$90d,$a0b,0
        dc.w    $80d,$90d,$a0b,0,$80e,$90b,$a09,0
        dc.w    $80e,$90b,$a09,0,$80e,$90b,$a09,0
        dc.w    $80d,$90c,$a0c,0,$80d,$90d,$a0a,0
        dc.w    $80e,$90b,$a07,0,$80e,$90b,$a00,0
        dc.w    $80e,$90b,$a00,0,$80d,$90d,$a09,0

        dc.w    $80d,$90d,$a09,0,$80e,$90a,$a09,0
        dc.w    $80d,$90d,$a08,0,$80d,$90d,$a07,0
        dc.w    $80d,$90d,$a04,0,$80d,$90d,$a00,0
        dc.w    $80e,$90a,$a04,0,$80e,$909,$a09,0
        dc.w    $80e,$909,$a09,0,$80d,$90c,$a0b,0
        dc.w    $80e,$909,$a08,0,$80e,$909,$a08,0
        dc.w    $80e,$909,$a07,0,$80e,$908,$a08,0
        dc.w    $80e,$909,$a01,0,$80c,$90c,$a0c,0

        dc.w    $80d,$90c,$a0a,0,$80e,$908,$a06,0
        dc.w    $80e,$907,$a07,0,$80e,$908,$a00,0
        dc.w    $80e,$907,$a05,0,$80e,$906,$a06,0
        dc.w    $80d,$90c,$a09,0,$80e,$905,$a05,0
        dc.w    $80e,$904,$a04,0,$80d,$90c,$a08,0
        dc.w    $80d,$90b,$a0b,0,$80e,$900,$a00,0
        dc.w    $80d,$90c,$a06,0,$80d,$90c,$a05,0
        dc.w    $80d,$90c,$a02,0,$80c,$90c,$a0b,0

        dc.w    $80c,$90c,$a0b,0,$80d,$90b,$a0a,0
        dc.w    $80d,$90b,$a0a,0,$80d,$90b,$a0a,0
        dc.w    $80d,$90b,$a0a,0,$80c,$90c,$a0a,0
        dc.w    $80c,$90c,$a0a,0,$80c,$90c,$a0a,0
        dc.w    $80d,$90b,$a09,0,$80d,$90b,$a09,0
        dc.w    $80d,$90a,$a0a,0,$80d,$90a,$a0a,0
        dc.w    $80d,$90a,$a0a,0,$80c,$90c,$a09,0
        dc.w    $80c,$90c,$a09,0,$80c,$90c,$a09,0

        dc.w    $80d,$90b,$a06,0,$80c,$90b,$a0b,0
        dc.w    $80c,$90c,$a08,0,$80d,$90b,$a00,0
        dc.w    $80d,$90b,$a00,0,$80c,$90c,$a07,0
        dc.w    $80c,$90c,$a06,0,$80c,$90c,$a05,0
        dc.w    $80c,$90c,$a03,0,$80c,$90c,$a01,0
        dc.w    $80c,$90b,$a0a,0,$80d,$90a,$a05,0
        dc.w    $80d,$90a,$a04,0,$80d,$90a,$a02,0
        dc.w    $80d,$909,$a08,0,$80d,$909,$a08,0




        dc.w    $80c,$90b,$a09,0,$80c,$90b,$a09,0
        dc.w    $80d,$908,$a08,0,$80b,$90b,$a0b,0
        dc.w    $80d,$909,$a05,0,$80c,$90b,$a08,0
        dc.w    $80d,$909,$a02,0,$80d,$908,$a06,0
        dc.w    $80c,$90b,$a07,0,$80d,$907,$a07,0
        dc.w    $80c,$90b,$a06,0,$80c,$90a,$a09,0
        dc.w    $80b,$90b,$a0a,0,$80c,$90b,$a02,0
        dc.w    $80c,$90b,$a00,0,$80c,$90a,$a08,0

        dc.w    $80d,$906,$a04,0,$80d,$905,$a05,0
        dc.w    $80d,$905,$a04,0,$80c,$909,$a09,0
        dc.w    $80d,$904,$a03,0,$80b,$90b,$a09,0
        dc.w    $80c,$90a,$a05,0,$80b,$90a,$a0a,0
        dc.w    $80c,$909,$a08,0,$80b,$90b,$a08,0
        dc.w    $80c,$90a,$a00,0,$80c,$90a,$a00,0
        dc.w    $80c,$909,$a07,0,$80b,$90b,$a07,0
        dc.w    $80c,$909,$a06,0,$80b,$90b,$a06,0

        dc.w    $80b,$90a,$a09,0,$80b,$90b,$a05,0
        dc.w    $80a,$90a,$a0a,0,$80b,$90b,$a02,0
        dc.w    $80b,$90a,$a08,0,$80c,$907,$a07,0
        dc.w    $80c,$908,$a04,0,$80c,$907,$a06,0
        dc.w    $80b,$909,$a09,0,$80c,$906,$a06,0
        dc.w    $80a,$90a,$a09,0,$80c,$907,$a03,0
        dc.w    $80b,$90a,$a05,0,$80b,$909,$a08,0
        dc.w    $80b,$90a,$a03,0,$80a,$90a,$a08,0

        dc.w    $80b,$90a,$a00,0,$80b,$909,$a07,0
        dc.w    $80b,$908,$a08,0,$80a,$90a,$a07,0
        dc.w    $80a,$909,$a09,0,$80c,$901,$a01,0
        dc.w    $80a,$90a,$a06,0,$80b,$908,$a07,0
        dc.w    $80a,$90a,$a05,0,$80a,$909,$a08,0
        dc.w    $80a,$90a,$a02,0,$80a,$90a,$a01,0
        dc.w    $80a,$90a,$a00,0,$809,$909,$a09,0
        dc.w    $80a,$908,$a08,0,$80b,$908,$a01,0

        dc.w    $80a,$909,$a06,0,$80b,$907,$a04,0
        dc.w    $80a,$909,$a05,0,$809,$909,$a08,0
        dc.w    $80a,$909,$a03,0,$80a,$908,$a06,0
        dc.w    $80a,$909,$a00,0,$809,$909,$a07,0
        dc.w    $809,$908,$a08,0,$80a,$908,$a04,0
        dc.w    $809,$909,$a06,0,$80a,$908,$a01,0
        dc.w    $809,$909,$a05,0,$809,$908,$a07,0
        dc.w    $808,$908,$a08,0,$809,$909,$a02,0

        dc.w    $809,$908,$a06,0,$809,$909,$a00,0
        dc.w    $809,$907,$a07,0,$808,$908,$a07,0
        dc.w    $809,$907,$a06,0,$809,$908,$a02,0
        dc.w    $808,$908,$a06,0,$809,$906,$a06,0
        dc.w    $808,$907,$a07,0,$808,$908,$a04,0
        dc.w    $808,$907,$a06,0,$808,$908,$a02,0
        dc.w    $807,$907,$a07,0,$808,$906,$a06,0
        dc.w    $808,$907,$a04,0,$807,$907,$a06,0

        dc.w    $808,$906,$a05,0,$808,$906,$a04,0
        dc.w    $807,$906,$a06,0,$807,$907,$a04,0
        dc.w    $808,$905,$a04,0,$806,$906,$a06,0
        dc.w    $807,$906,$a04,0,$807,$905,$a05,0
        dc.w    $806,$906,$a05,0,$806,$906,$a04,0
        dc.w    $806,$905,$a05,0,$806,$906,$a02,0
        dc.w    $806,$905,$a04,0,$805,$905,$a05,0
        dc.w    $806,$905,$a02,0,$805,$905,$a04,0

        dc.w    $805,$904,$a04,0,$805,$905,$a02,0
        dc.w    $804,$904,$a04,0,$804,$904,$a03,0
        dc.w    $804,$904,$a02,0,$804,$903,$a03,0
        dc.w    $803,$903,$a03,0,$803,$903,$a02,0
        dc.w    $803,$902,$a02,0,$802,$902,$a02,0
        dc.w    $802,$902,$a01,0,$801,$901,$a01,0
        dc.w    $802,$901,$a00,0,$801,$901,$a00,0
        dc.w    $801,$900,$a00,0,$800,$900,$a00,0

        




hs1:    move.w  #$111,$ff8240
        bclr    #0,$fffa0f
        move.b  #1,$fffa21
        move.l  #hs2,$120
        move.l  pal21,$ff8240
        move.l  pal22,$ff8244
        move.l  pal23,$ff8248
        move.l  pal24,$ff824c
        move.l  pal25,$ff8250
        move.l  pal26,$ff8254
        move.l  pal27,$ff8258
        move.l  pal28,$ff825c


        rte

hs2:    move.w  #$222,$ff8240
        bclr    #0,$fffa0f
        move.b  #45,$fffa21
        move.l  #hs3,$120
        rte

hs3:    move.w  #$333,$ff8240
        bclr    #0,$fffa0f
        move.b  #1,$fffa21
        move.l  #hs4,$120
        rte

hs4:    move.w  #$222,$ff8240
        bclr    #0,$fffa0f
        move.b  #1,$ffa21
        move.l  #hs5,$120
        rte

hs5:    move.w  #$111,$ff8240
        bclr    #0,$fffa0f
        move.b  #151,$fffa21
        move.l  #hs6,$120
        rte

hs6:    move.w  #$000,$ff8240
        bclr    #0,$fffa0f
        move.b  #1,$fffa21
        move.l  #hs1,$120
        rte




vsync:  movem.l d0-d7/a0-a1,-(sp)


        st      read
        lea     palette1(pc),a0
        movem.l (a0),d0-d7
        movem.l d0-d7,$ff8240
        tst.b   beatflag
        bne     forbivs1
        movem.l a2-a6,-(sp)
        jsr     $48780
        movem.l (sp)+,a2-a6
forbivs1:
        move.b  #1,$fffa21
        move.l  #hs1,$120
        movem.l (sp)+,d0-d7/a0-a1
        rte


chksmp: movem.l a0-a1,-(sp)
        cmpa.l  enddissamp,a6
        bcs     forbivh1
        move.l  a6,a1
        move.l  getsampdpos(pc),a0
        sub.l   enddissamp(pc),a1
        adda.l  8(a0),a0
        move.l  a0,getsampdpos
        adda.l  (a0),a1
        adda.l  #samplin,a1
        move.l  a1,a6
        adda.l  4(a0),a1
        move.l  a1,enddissamp
forbivh1:       
        movem.l (sp)+,a0-a1
        rts



setints:
;       move.w  #37,-(sp)
;       trap    #14
;       addq.l  #2,sp
        move.w  #$2700,sr
        move.l  #vsync,$70
;       move.b  #0,$fffa07
;       move.b  #0,$fffa09
        move.w  #$2300,sr
        clr.b   read
omsi3:  tst.b   read
        beq     omsi3
        move.w  #$2700,sr
        move.l  #hs1,$120
        bset    #0,$fffa07
        bset    #0,$fffa13
        bclr    #0,$fffa0f
        move.b  #8,$fffa1b
        move.b  #150,$fffa21

;       move.l  #hs1,-(sp)
;       move.w  #150,-(sp)
;       move.w  #8,-(sp)
;       move.w  #1,-(sp)
;       move.w  #31,-(sp)
;       trap    #14
;       add.l   #12,sp



        move.w  #$2300,sr
        move.b  $ff8209,d0
omsi1:  cmp.b   $ff8209,d0
        beq     omsi1
        move.l  #50,d0
omsi2:  dbra    d0,omsi2
        move.b  #1,$fffa21
        move.l  #samp,$68
        tst.b   beatflag
        beq     forbisi1
        move.w  #$2100,sr
forbisi1:
        rts


saveints:
        move.w  #$2700,sr
        move.b  $fffa07,mfpiea
        move.b  $fffa09,mfpieb
;       move.b  $fffa13,mfpima
;       move.b  $fffa15,mfpimb
;       move.b  $fffa19,mfptac
;       move.b  $fffa1b,mfptbc
;       move.b  $fffa1f,mfptad
;       move.b  $fffa21,mfptbd

;       move.l  $120,timbvec
;       move.l  $68,hsynvec
;       move.l  $70,oldvsync
        rts

retints:
        move.w  #$2700,sr
        move.b  mfpiea,$fffa07
        move.b  mfpieb,$fffa09
;       move.b  mfpima,$fffa13
;       move.b  mfpimb,$fffa15
;       move.b  mfptac,$fffa19
;       move.b  mfptbc,$fffa1b
;       move.b  mfptad,$fffa1f
;       move.b  mfptbd,$fffa21


;       move.l  timbvec,$120
;       move.l  hsynvec,$68
;       move.l  oldvsync,$70
        move.w  #$2500,sr
        rts








slacksprite:
        move.b  oddvsync,d0
        btst    #0,d0
        beq     forbiss1
        lea     slackaddrtab2,a0
        bra     forbiss2
forbiss1:
        lea     slackaddrtab,a0
forbiss2:
        adda.l  #1820,a0
        moveq   #7,d4
        tst.l   (a0)
        beq     forbiss3
omslsp1:
        move.l  (a0)+,a1
omslsp2:
        movem.l (a0)+,d0-d3
        movem.l d0-d3,(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,160(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,320(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,480(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,640(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,800(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,960(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,1120(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,1280(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,1440(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,1600(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,1760(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,1920(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,2080(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,2240(a1)
        movem.l (a0)+,d0-d3
        movem.l d0-d3,2400(a1)
        lea     -520(a0),a0
        dbra    d4,omslsp1
forbiss3:
        rts



        
utmedsprite:
        move.b  oddvsync,d0
        btst    #0,d0
        beq     forbiums1
        lea     slackaddrtab2,a2
        bra     forbiums2
forbiums1:
        lea     slackaddrtab,a2
forbiums2:
        lea     shiftedsprites,a0
        lea     xytab(pc),a1

        moveq   #7,d4
omums2: move.l  a0,-(sp)
        move.w  (a1),d1
        move.w  d1,d2
        and.l   #15,d1
        mulu    #384,d1
        adda.l  d1,a0
        lsr.w   #1,d2
        and.l   #$fff8,d2
        moveq   #0,d3
        move.w  2(a1),d3
        lsl.l   #2,d3
        lea     tab160,a3
        add.l   (a3,d3.w),d2
        move.l  currpicadd(pc),a3
        adda.l  d2,a3
        move.l  a3,(a2)+

        move.l  d4,-(sp)
        moveq   #15,d0
omums1: 
        move.l  (a3),(a2)+
        move.l  4(a3),(a2)+
        move.l  8(a3),(a2)+
        move.l  12(a3),(a2)+
        
        movem.l (a0)+,d1-d4/d6-d7
        and.l   d1,(a3)
        and.l   d1,4(a3)
        and.l   d4,8(a3)
        and.l   d4,12(a3)
        or.l    d2,(a3)
        or.l    d3,4(a3)
        or.l    d6,8(a3)
        or.l    d7,12(a3)

        lea     160(a3),a3
        dbra    d0,omums1
        move.l  (sp)+,d4
        move.l  (sp)+,a0
        lea     6144(a0),a0
        addq.l  #4,a1
        dbra    d4,omums2
        rts



move3sprites:
        movem.l d0-d1,-(sp)
        move.l  #xtab,a1
        move.l  #ytab,a2
omm3s1: cmp.l   #0,d0
        bmi     forbim3s1
        bra     forbim3s2
forbim3s1:
        add.l   #128,d0
        bra     forbim3s3
forbim3s2:
        cmp.l   #128,d0
        blt     forbim3s3
        sub.l   #128,d0
forbim3s3:
        cmp.l   #0,d1
        bmi     forbim3s4
        bra     forbim3s5
forbim3s4:
        add.l   #100,d1
        bra     forbim3s6
forbim3s5:
        cmp.l   #100,d1
        blt     forbim3s6
        sub.l   #100,d1
forbim3s6:
        move.l  d0,d2
        move.l  d1,d3
        lsl.l   #1,d2
        lsl.l   #1,d3
        move.w  (a1,d2.w),d4
        move.w  d4,(a0)+
        move.w  (a2,d3.w),d4
        move.w  d4,(a0)+
        add.l   d6,d0
        add.l   d6,d1
        dbra    d7,omm3s1
        movem.l (sp)+,d0-d1
        rts

movesprites:
        move.l  xnr,d0
        move.l  ynr,d1
        move.l  #4,d6
        move.l  #4,d7
        move.l  #xytab,a0
        bsr     move3sprites

        move.l  xnr,d0
        move.l  ynr,d1
        add.l   #24,d0
        add.l   #24,d1
        move.l  #4,d6
        move.l  #2,d7
        bsr     move3sprites

        move.l  xnr,d0
        move.l  ynr,d1
        addq.l  #1,d0
        addq.l  #1,d1
        cmp.l   #128,d0
        blt     forbims1
        moveq   #0,d0
forbims1:
        cmp.l #100,d1
        blt     forbims2
        moveq   #0,d1
forbims2:
        move.l  d0,xnr
        move.l  d1,ynr
        rts



movesprites2:
        move.w  xya,d0
        add.w   d0,xyp
        and.w   #511,xyp
        move.w  xza,d0
        add.w   d0,xzp
        and.w   #511,xzp
        move.w  yza,d0
        add.w   d0,yzp
        and.w   #511,yzp
        lea     xytab,a0
        moveq   #4,d0
        lea     sincostab,a1
        move.w  xyp,d1
        move.w  xzp,d2
        move.w  yzp,d3
        lsl.w   #1,d1
        lsl.w   #1,d2
        lsl.w   #1,d3
omms21: move.w  (a1,d1.w),d4
        move.w  (a1,d2.w),d5
        muls    d4,d5
        asr.l   #7,d5
        asr.w   #4,d5
        add.w   #152,d5
        move.w  d5,(a0)+
        move.w  (a1,d1.w),d4
        move.w  (a1,d3.w),d5
        muls    d4,d5
        asr.l   #8,d5
        asr.w   #4,d5
        add.w   #67,d5
        move.w  d5,(a0)+
        add.w   xyo,d1
        add.w   xyo,d1
        add.w   xzo,d2
        add.w   xzo,d2
        add.w   yzo,d3
        add.w   yzo,d3
        and.w   #1023,d1
        and.w   #1023,d2
        and.w   #1023,d3
        dbra    d0,omms21
        add.w   xyo,d1
        add.w   xyo,d1
        add.w   xzo,d2
        add.w   xzo,d2
        add.w   yzo,d3
        add.w   yzo,d3
        and.w   #1023,d1
        and.w   #1023,d2
        and.w   #1023,d3
        moveq   #2,d0        
omms22: move.w  (a1,d1.w),d4
        move.w  (a1,d2.w),d5
        muls    d4,d5
        asr.l   #7,d5
        asr.w   #4,d5
        add.w   #152,d5
        move.w  d5,(a0)+
        move.w  (a1,d1.w),d4
        move.w  (a1,d3.w),d5
        muls    d4,d5
        asr.l   #8,d5
        asr.w   #4,d5
        add.w   #67,d5
        move.w  d5,(a0)+
        add.w   xyo,d1
        add.w   xyo,d1
        add.w   xzo,d2
        add.w   xzo,d2
        add.w   yzo,d3
        add.w   yzo,d3
        and.w   #1023,d1
        and.w   #1023,d2
        and.w   #1023,d3
        dbra    d0,omms22

        rts
        
xyp:    dc.w    0
xzp:    dc.w    0
yzp:    dc.w    0
xyo:    dc.w    19
xzo:    dc.w    14
yzo:    dc.w    24
xya:    dc.w    3
xza:    dc.w    5
yza:    dc.w    2




shiftsprites:
        lea     sprite(pc),a0
        lea     shiftedsprites,a1
        moveq   #7,d0
omssp1: moveq   #15,d1
omssp2: move.l  a0,a2
        moveq   #16,d4
        sub.l   d1,d4
        move.w  #-1,d2
        lsr.w   d4,d2
        move.w  d2,d5
        swap    d5
        move.w  d2,d5
        move.l  d1,d6
        movem.l d0-d1/a0,-(sp)
        move.l  a2,a3
        adda.l  #128,a3
        moveq   #15,d2
omssp3: movem.l (a2),d0-d1
        move.w  (a3)+,d3

        move.w  d3,d7
        swap    d7
        move.w  d3,d7
        move.l  d7,d3
        lsr.l   d4,d7
        and.l   d5,d7
        lsl.l   d6,d3
        eor.l   #-1,d5
        and.l   d5,d3
        eor.l   #-1,d5
        eor.l   #-1,d7
        eor.l   #-1,d3
        move.l  d7,(a1)
        move.l  d3,12(a1)

        move.l  d0,d7
        lsr.l   d4,d7
        and.l   d5,d7
        lsl.l   d6,d0
        eor.l   #-1,d5
        and.l   d5,d0
        eor.l   #-1,d5
        move.l  d7,4(a1)
        move.l  d0,16(a1)


        move.l  d1,d7
        lsr.l   d4,d7
        and.l   d5,d7
        lsl.l   d6,d1
        eor.l   #-1,d5
        and.l   d5,d1
        eor.l   #-1,d5
        move.l  d7,8(a1)
        move.l  d1,20(a1)
        adda.l  #8,a2
        adda.l  #24,a1

        dbra    d2,omssp3
        movem.l (sp)+,d0-d1/a0
        dbra    d1,omssp2
        adda.l  #160,a0
        dbra    d0,omssp1
        rts

        



scpostab:       dc.l    0,16000,32000,48000

tab400: dc.l    0,400,800,1200

scrlin: move.l  newcharpos(pc),d0
        move.l  d0,d1
        and.b   #3,d0
        move.l  d0,windnr
        and.w   #$fffc,d1
        lsl.l   #1,d1
        lsl.l   #2,d0

        lea     scpostab(pc),a3
        add.l   0(a3,d0.w),d1
        move.l  d1,a1
        move.l  d1,windpos
        


        tst.l   windnr
        bne     forbis4
        move.l  charposl(pc),d1
        addq.l  #1,d1
        cmp     #3,d1
        blt     forbit1
        moveq   #0,d1

        move.l  scrollpos(pc),a0
        addq    #1,a0
        cmp.b   #$55,(a0)
        bne     forbis3
        move.l  scrollbase,a0
forbis3:
        move.l  a0,scrollpos
forbit1:
        move.l  d1,charposl
forbis4:

        move.l  scrollpos(pc),a0

        moveq   #0,d1
        move.b  (a0),d1
        eor.b   #$aa,d1
        lea     stasc(pc),a0
        move.b  (a0,d1.w),d1

        move.l  d1,d7
        add.w   d7,d1
        add.w   d7,d1

        add.l   charposl(pc),d1

        mulu    #400,d1

        move.l  d1,a0

        lea     tab400(pc),a3
        move.l  windnr(pc),d0
        lsl.l   #2,d0
        move.l  0(a3,d0.w),a2

        adda.l  #backs,a2
        adda.l  #blocks,a1
        adda.l  #font,a0
        moveq   #50,d0
        move.l  windnr(pc),d1
        lsl     #2,d1
        move    d1,d7
        bsr     chksmp
        
oms3:   
        moveq   #0,d1
        move.w  (a0),d1
        lsl.l   d7,d1
        move.w  d1,8(a1)
        move.w  d1,168(a1)
        swap    d1
        or.w    160(a1),d1
        move.w  d1,d2
        eor.w   #$ffff,d2
        move.w  (a2)+,d3
        and.w   d2,d3
        or.w    d3,d1
        move.w  d1,(a1)
        move.w  d1,160(a1)
        
        moveq   #0,d1
        move.w  2(a0),d1
        lsl.l   d7,d1
        move.w  d1,10(a1)
        move.w  d1,170(a1)
        swap    d1
        or.w    162(a1),d1
        move.w  (a2)+,d3
        and.w   d2,d3
        or.w    d3,d1
        move.w  d1,2(a1)
        move.w  d1,162(a1)
        
        moveq   #0,d1
        move.w  4(a0),d1
        lsl.l   d7,d1
        move.w  d1,12(a1)
        move.w  d1,172(a1)
        swap    d1
        or.w    164(a1),d1
        move.w  (a2)+,d3
        and.w   d2,d3
        or.w    d3,d1
        move.w  d1,4(a1)
        move.w  d1,164(a1)

        moveq   #0,d1
        move.w  6(a0),d1
        lsl.l   d7,d1
        move.w  d1,14(a1)
        move.w  d1,174(a1)
        swap    d1
        or.w    166(a1),d1
        move.w  (a2)+,d3
        and.w   d2,d3
        or.w    d3,d1
        move.w  d1,6(a1)
        move.w  d1,166(a1)
        
        addq.l  #8,a0
        lea     320(a1),a1
        dbra    d0,oms3

        bsr     chksmp
        

        move.l  windpos(pc),a0
        adda.l  #blocks,a0
        move.l  currpicadd(pc),a1
        lea     24000(a1),a1
        move.l  a1,a2
        lea     7840(a2),a2
        
oms4:   movem.l 16(a0),d0-d7/a3
        movem.l d0-d7/a3,8(a1)
        movem.l 52(a0),d0-d7/a3
        movem.l d0-d7/a3,44(a1)
        movem.l 88(a0),d0-d7/a3
        movem.l d0-d7/a3,80(a1)
        movem.l 124(a0),d0-d7/a3
        movem.l d0-d7/a3,116(a1)

        movem.l 336(a0),d0-d7/a3
        movem.l d0-d7/a3,168(a1)
        movem.l 372(a0),d0-d7/a3
        movem.l d0-d7/a3,204(a1)
        movem.l 408(a0),d0-d7/a3
        movem.l d0-d7/a3,240(a1)
        movem.l 444(a0),d0-d7/a3
        movem.l d0-d7/a3,276(a1)
        
        lea     640(a0),a0
        lea     320(a1),a1
        cmpa.l  a2,a1
        blt     oms4

        bsr     chksmp

        move.l  currpicadd(pc),a1
        lea     23840(a1),a1
        lea     tom(pc),a0
        movem.l (a0),d0-d7
        movem.l d0-d7,(a1)
        movem.l d0-d7,32(a1)
        movem.l d0-d7,64(a1)
        movem.l d0-d7,96(a1)
        movem.l d0-d7,128(a1)

        lea     lrback(pc),a3
        move.l  currpicadd(pc),a1
        lea     24000(a1),a1

        lea     -640(a2),a2

oms9:   movem.l (a3)+,d0-d1
        movem.l d0-d1,(a1)
        movem.l (a3)+,d0-d1
        movem.l d0-d1,152(a1)


        movem.l (a3)+,d0-d1
        movem.l d0-d1,160(a1)
        movem.l (a3)+,d0-d1
        movem.l d0-d1,312(a1)


        movem.l (a3)+,d0-d1
        movem.l d0-d1,320(a1)
        movem.l (a3)+,d0-d1
        movem.l d0-d1,472(a1)


        movem.l (a3)+,d0-d1
        movem.l d0-d1,480(a1)
        movem.l (a3)+,d0-d1
        movem.l d0-d1,632(a1)


        lea     640(a1),a1
        cmpa.l  a2,a1
        blt     oms9


        movem.l (a3)+,d0-d1
        movem.l d0-d1,(a1)
        movem.l (a3)+,d0-d1
        movem.l d0-d1,152(a1)


        movem.l (a3)+,d0-d1
        movem.l d0-d1,160(a1)
        movem.l (a3)+,d0-d1
        movem.l d0-d1,312(a1)


        
        move.l  newcharpos(pc),d0
        addq    #1,d0
        cmp     #80,d0
        blt     forbis2
        moveq   #0,d0
forbis2:        move.l  d0,newcharpos

        rts
        




fixnbr: btst    #15,d0
        beq     forbi1
        add.l   #400,d0
forbi1: rts

placepics:
        tst.b   beatflag
        beq     forbipp1
        move.l  #emd,d0
        bra     forbipp2
forbipp1:
        move.l  #emd2,d0
forbipp2:
        and.l   #$ffffff00,d0
        move.l  d0,pic1add
        move.l  d0,picsadd
        add.l   #32000,d0
        move.l  d0,pic2add
        add.l   #32000,d0
        move.l  d0,pic3add
        add.l   #32000,d0
        move.l  d0,pic4add
        move.l  pic1add(pc),d0
        lsr.l   #8,d0
        move.l  d0,picsbas256
        move.l  picsadd,a0
        moveq   #3,d1
        moveq   #0,d3
ompp1:  move.l  #7999,d2
ompp2:  move.l  d3,(a0)+
        dbra    d2,ompp2
        dbra    d1,ompp1
        rts

tab125:         dc.l    0,125,250,375

movpic: move.l  targpiclin(pc),d0
        move.l  d0,d1
        and.l   #3,d0

        lsr.l   #2,d1

        move.l  d1,d7
        lsl.l   #2,d7
        add.l   d7,d1

        lsl.l   #2,d0
        lea     tab125(pc),a3
        add.l   (a3,d0.w),d1

        cmp.l   #500,d1
        blt     forbimp1
        sub.l   #500,d1
forbimp1:

        add.l   picsbas256(pc),d1
        lsl.l   #8,d1
        move.l  d1,currpicadd
        lsr.l   #8,d1
        move.b  d1,$fff8203
        lsr.l   #8,d1
        move.b  d1,$ff8201
        
        rts

        
movlin: movem.l d0-d7/a0,-(sp)
        
        movem.l (a0)+,d0-d7
        movem.l d0-d7,(a2)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,32(a2)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,64(a2)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,96(a2)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,128(a2)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,160(a2)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,192(a2)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,224(a2)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,256(a2)
        movem.l (a0)+,d0-d7
        movem.l d0-d7,288(a2)

        movem.l (sp)+,d0-d7/a0

        rts

newlines:       
        move.l  sourceadd(pc),d0
        lea     pic(pc),a0
        adda.l  d0,a0

        move.l  targpicadd(pc),d0
        add.l   #23360,d0
        move.l  picsadd(pc),a1
        move.l  #3,d1
        
om2:    move.l  a1,a2
        adda.l  d0,a2
        bsr     movlin
        add.l   #32000,d0
forbinl2:       
        cmp.l   #160000,d0
        blt     forbinl1
        sub.l   #160000,d0
        bra     om2
forbinl1:
        sub.l   #320,d0
        btst    #15,d0
        beq     forbi4
        add.l   #128000,d0
forbi4: dbra    d1,om2
        rts     



loadfil:
        move.w  #0,-(sp)
        move.l  d0,-(sp)
        move.w  #$3d,-(sp)
        trap    #1
        addq.l  #8,sp
        move.w  d0,handle
        move.l  d1,-(sp)
        move.l  d2,-(sp)
        move.w  handle,-(sp)
        move.w  #$3f,-(sp)
        trap    #1
        add.l   #12,sp
        move.l  d0,-(sp)
        move.w  handle,-(sp)
        move.w  #$3e,-(sp)
        trap    #1
        addq.l  #4,sp
        move.l  (sp)+,d0
        rts

loadsamplin:
;       Hi Gunter.
;       so, you're tapping around in my program...
;       You should insert something that loads the beat-dis
;       sampling here (and of course delete this rout)
        move.l  #sampname,d0
        move.l  #samplin,d1
        move.l  #samplength,d2
        bsr     loadfil

forbilf1:
        rts


makcoltab:
        move.l  #coltab,a1
        move.l  #199,d0
om16:   move.l  #0,(a1)+
        move.l  #hs1,(a1)+
        dbra    d0,om16
        move.l  #coltab,a1
        adda.l  #1160,a1
        move.l  #$6660000,(a1)+
        move.l  #hs2,(a1)+
        adda.l  #8,a1
        move.l  #49,d0
om17:   move.l  #$4440001,(a1)+
        adda.l  #4,a1
        dbra    d0,om17
        move.l  #$2220000,(a1)+
        adda.l  #4,a1
        move.l  #$2220000,(a1)+
        adda.l  #4,a1
        move.l  #0,(a1)+
        rts

makbacks:
        lea     back(pc),a0
        lea     backs,a1
        moveq   #0,d0
        moveq   #3,d6
        
        
om5:    move.l  a1,a3
        move.l  a0,a2
        move.l  #16,d1
om6:    move.l  (a2)+,(a3)+
        move.l  (a2)+,(a3)+
        dbra    d1,om6
        move.l  #15,d7
om9:    move.l  #3,d5
om7:    moveq   #0,d1
        move.w  (a2)+,d1
        lsl.l   d0,d1
        move.l  d1,d2
        swap    d2
        or.w    d2,d1
        move.w  d1,(a3)+
        dbra    d5,om7
        dbra    d7,om9
        move.l  #16,d1
om8:    move.l  (a2)+,(a3)+
        move.l  (a2)+,(a3)+
        dbra    d1,om8
        add.l   #2,d0
        add.l   #400,a1
        dbra    d6,om5

        moveq   #3,d0
        move.l  #blocks,a1
        move.l  #backs,a0
om12:   move.l  #49,d1
om10:   move.l  #39,d2
om11:   move.l  (a0),(a1)+
        move.l  4(a0),(a1)+
        dbra    d2,om11
        adda.l  #8,a0
        dbra    d1,om10
        dbra    d0,om12
        
        rts

maksincostab:
        lea     sincostab(pc),a0
        lea     sct3(pc),a1
        moveq   #127,d0
ommst1: move.w  (a0)+,-(a1)
        dbra    d0,ommst1
        lea     sincostab(pc),a0
        lea     sct5(pc),a1
        move.l  #255,d0
ommst2: move.w  (a0)+,d1
        neg.w   d1
        move.w  d1,-(a1)
        dbra    d0,ommst2
        rts

;d0 = x word
;d1 = Y word
;a0 = address
;d2 = width
;d3 = height
oronback:
        lea     tab160,a1
        lsl.l   #2,d1
        move.l  (a1,d1.w),a1
        adda.l  #pic,a1
        lsl.l   #3,d0
        add.l   d0,a1
        subq.l  #1,d2
        subq.l  #1,d3
omob1:  move.l  a1,a2
        move.l  d2,d4
omob2:  moveq   #0,d5
        or.w    (a0),d5
        or.w    2(a0),d5
        or.w    4(a0),d5
        or.w    6(a0),d5
        not     d5
        and.w   d5,(a2)
        and.w   d5,2(a2)
        and.w   d5,4(a2)
        and.w   d5,6(a2)
        move.l  (a0)+,d5
        or.l    d5,(a2)+
        move.l  (a0)+,d5
        or.l    d5,(a2)+
        dbra    d4,omob2
        lea     160(a1),a1
        dbra    d3,omob1
        rts
        
        

makepic:
        move.l  #3,d1
ommp1:  move.l  d1,-(sp)
        lea     background1,a0
        move.l  #0,d0
        mulu    #50,d1
        move.l  #10,d2
        move.l  #50,d3
        bsr     oronback
        lea     background1,a0
        move.l  #10,d0
        move.l  (sp)+,d1
        move.l  d1,-(sp)
        mulu    #50,d1
        move.l  #10,d2
        move.l  #50,d3
        bsr     oronback
        move.l  (sp)+,d1
        dbra    d1,ommp1
        move.l  #2,d0
        move.l  #80,d1
        move.l  #16,d2
        move.l  #43,d3
        bsr     oronback
        move.l  #1,d0
        move.l  #0,d1
        move.l  #4,d2
        move.l  #28,d3
        lea     Background3,a0
        bsr     oronback
        move.l  #15,d0
        move.l  #0,d1
        move.l  #4,d2
        move.l  #28,d3
        lea     Background3,a0
        bsr     oronback
        move.l  #8,d0
        move.l  #150,d1
        move.l  #4,d2
        move.l  #28,d3
        lea     BackGround3,a0
        bsr     oronback
        rts     


initvars:
;       clr.l   -(sp)
;       move.w  #32,-(sp)
;       trap    #1
;       addq.l  #6,sp
;       move.l  d0,savstk

;       move.w  #2,-(sp)
;       trap    #14
;       addq.l  #2,sp
;       move.l  d0,oldphys

;       move.w  #4,-(sp)
;       trap    #14
;       addq.l  #2,sp
;       move.w  d0,oldres


;       move.w  #0,-(sp)
;       move.l  #-1,-(sp)
;       move.l  #-1,-(sp)
;       move.w  #5,-(sp)
;       trap    #14
;       add.l   #12,sp

;       lea     oldpal(pc),a0
;       movem.l $ff8240,d0-d7
;       movem.l d0-d7,(a0)


        move.l  #samplength,samplen


        tst.b   beatflag
        beq     forbiiv2
        bsr     loadsamplin
forbiiv2:
        bsr     makbacks
        bsr     maksincostab
        tst.b   beatflag
        bne     forbiiv1
        bsr     shiftsprites
        bsr     startmusic
forbiiv1:


;       move.w  #3,-(sp)
;       trap    #14
;       addq.l  #2,sp
;       move.l  d0,iglogscr


        moveq   #0,d1
        move.w  #199,d0
        lea     tab160,a0
omiv1:  move.l  d1,(a0)+
        add.l   #160,d1
        dbra    d0,omiv1



        bsr     placepics
        bsr     makepic
        bsr     makcoltab

        bsr     saveints
        bsr     intsamp
        bsr     setints

        move.l  #0,targpiclin
        move.l  #0,targpicadd

        rts
        
        
endp:   tst.b   read
        beq     endp
        bsr     retints

;       lea     oldpal(pc),a0
;       movem.l (a0),d0-d7
;       movem.l d0-d7,$ff8240

;       move.w  oldres,-(sp)
;       move.l  oldphys,-(sp)
;       move.l  oldphys,-(sp)
;       move.w  #5,-(sp)
;       trap    #14
;       adda.l  #12,sp

;       move.l  savstk,-(sp)
;       move.w  #32,-(sp)
;       trap    #1
;       addq.l  #6,sp
        rts


beat:   
omb1:   add.l   #320,targpicadd
        add.l   #320,sourceadd
        addq.l  #1,targpiclin
        cmp.l   #400,targpiclin
        blt     forbib2
        move.l  #0,targpicadd
        move.l  #0,targpiclin
forbib2:
        addq.l  #1,sourcelin
        cmp.l   #100,sourcelin
        blt     forbib3
        move.l  #0,sourceadd
        move.l  #0,sourcelin
forbib3:
        bsr     chksmp
        bsr     movpic
        bsr     chksmp
        bsr     newlines
        bsr     chksmp
        bsr     scrlin

        bsr     chksmp
omb15:  tst.b   read
        beq     omb15
        clr.b   read
        bsr     chksmp

        move.l  keyadd(pc),a0
        cmp.b   #57,(a0)
        beq     utb1

        bra     omb1

utb1:   rts

keyadd: dc.l    0

; insert music somewhere in this rout...
nobeat:
        bsr     movesprites2
        bsr     utmedsprite

om1:    add.l   #320,targpicadd
        add.l   #320,sourceadd
        addq.l  #1,targpiclin
        cmp.l   #400,targpiclin
        blt     forbi2
        move.l  #0,targpicadd
        move.l  #0,targpiclin
forbi2: addq.l  #1,sourcelin
        cmp.l   #100,sourcelin
        blt     forbi3
        move.l  #0,sourceadd
        move.l  #0,sourcelin
forbi3:
;       move.w  #$000,$ff8240
        bsr     movpic
        bsr     newlines
        bsr     scrlin

        bsr     slacksprite
        bsr     movesprites2
        bsr     utmedsprite
;       move.w  #$100,$ff8240
om15:   tst.b   read
        beq     om15
        clr.b   read

        move.l  keyadd(pc),a0
        cmp.b   #57,(a0)
        beq     utnb1

        addq.b  #1,oddvsync
        bra     om1

utnb1:  rts

cleareverything:
        lea     endequs,a1
        lea     endvars,a0
        moveq   #0,d0
omce1:  move.l  d0,(a0)+
        cmpa.l  a1,a0
        blt     omce1
        rts

startmusic:
        lea     musix,a0
        lea     $48000,a1
        move.l  #2499,d0
omsm:   move.l  (a0)+,(a1)+
        dbra    d0,omsm
        jsr     $48784
        rts

main:
;       move.l  sp,oldstack
;       move.l  #ustck,sp
;       move.l  oldstack,a0
;       move.l  4(a0),4(sp)
;       move.l  (a0),(sp)
        tst.l   d7
        beq     forbim27
        st      beatflag
        bra     forbim28
forbim27:
        clr.b   beatflag
forbim28:
        move.l  a2,keyadd
        move.l  a0,scrollpos
        move.l  a1,scrollbase

        bsr     cleareverything
        bsr     initvars

        tst.b   beatflag
        bne     omm1
        bsr     nobeat
        bra     utm1
omm1:   bsr     beat
        bra     utm1






        
utm1:   bsr     endp
;       move.l  oldstack,a0
;       move.l  (sp),(a0)
;       move.l  4(sp),4(a0)
;       move.l  oldstack,sp
        move.l  scrollpos,a0
        rts
;       illegal




beatflag:       dc.w    0
read:           dc.w    0
drewlasttime:   dc.w    0
oddvsync:       dc.w    0
textlen:        dc.l    0
iglogscr:       dc.l    0
picsadd:        dc.l    0
pic1add:        dc.l    0
pic2add:        dc.l    0
pic3add:        dc.l    0
pic4add:        dc.l    0
getsampdpos:
                dc.l    0
enddissamp:     dc.l    0
targpicadd:     dc.l    0
targpiclin:     dc.l    0
picsbas256:     dc.l    0
targetlin:      dc.l    0
sourcelin:      dc.l    0
sourceadd:      dc.l    0
targetadd:      dc.l    0
currpicadd:     dc.l    0
windnr:         dc.l    0
windpos:        dc.l    0
charposh:       dc.l    0
charposl:       dc.l    0
scrlinofs:      dc.l    0
handle:         dc.l    0
samplen:        dc.l    0
newcharpos:     dc.l    0

savstk:         dc.l    0
oldstack:       dc.l    0
mfpiea:         dc.b    0
mfpieb:         dc.b    0
mfpima:         dc.b    0
mfpimb:         dc.b    0
mfptac:         dc.b    0
mfptbc:         dc.b    0
mfptad:         dc.b    0
mfptbd:         dc.b    0
timbvec:        dc.l    0
hsynvec:        dc.l    0
oldvsync:       dc.l    0
oldphys:        dc.l    0
oldres:         dc.l    0
oldpal:         blk.l   8,0


tom:            blk.l   16,0

;fontname:      dc.b    "atafntc",0
sampname:       dc.b    'beatdis.spl',0

stasc:
        dc.b    42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
        dc.b    42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
        dc.b    42,43,44,42,42,42,45,46,47,48,42,42,51,52,53,54
        dc.b    26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41
        dc.b    42, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14
        dc.b    15,16,17,18,19,20,21,22,23,24,25,42,42,42,42,42
        dc.b    42, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14
        dc.b    15,16,17,18,19,20,21,22,23,24,25,42,42,42,42,42
        dc.b    42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
        dc.b    42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
        dc.b    42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
        dc.b    42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
        dc.b    42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
        dc.b    42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
        dc.b    42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
        dc.b    42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42


palette1:       dc.w    $500,$776,$774,$772,$760,$750,$740,$730
                dc.w    $720,$710,$600,$040,$167,$057,$047,$037 
;               dc.w    000,$110,$220,$330,$440,$011,$022,$033,$044,$055
;               dc.w    $101,$202,$303,$404,$505,$777
palette2:       dc.w    $333,1,$20,2,$40,3,$60,4,$300,5,$400,6,$600,7
                dc.w    $227,$304

pal21:  dc.l    $1110001
pal22:  dc.l    $0200002
pal23:  dc.l    $0400003
pal24:  dc.l    $0600004
pal25:  dc.l    $3000005
pal26:  dc.l    $4000006
pal27:  dc.l    $6000007
pal28:  dc.l    $3040227


sampdat:
        dc.l    0,3860,12
        dc.l    0,3860,12
        dc.l    0,3860,12
        dc.l    0,3860,12
        dc.l    0,3860,12
        dc.l    0,3860,12
        dc.l    0,3860,12
        dc.l    0,321128,12
        dc.l    259053,62075,12
        dc.l    259053,30778,12
        dc.l    321130,62124,12
        dc.l    352230,30967,12
        dc.l    352230,30967,12
        dc.l    352230,30967,12
        dc.l    383256,61896,12
        dc.l    383256,61896,12
        dc.l    383256,61896,12
        dc.l    383256,61896,12
        dc.l    135139,124093,12
        dc.l    456008,62088,12
        dc.l    456008,62088,12
        dc.l    456008,62088,12
        dc.l    456008,62088,12
        dc.l    518098,30971,12
        dc.l    518098,30971,12
        dc.l    518098,30971,12
        dc.l    518098,30971,-228






xtab:   dc.w    152,159,167,174,181,189,196,203,210,217,223
        dc.w    230,236,242,248,253,259,264,269,273,278,282
        dc.w    285,289,292,294,296,298,300,301,302,303,303
        dc.w    303,302,301,300,298,296,294,292,289,285,282
        dc.w    278,273,269,264,259,253,248,242,236,230,223
        dc.w    217,210,203,196,189,181,174,167,159,152,145
        dc.w    137,130,123,115,108,101,94,87,81,74,68,62,56
        dc.w    51,45,40,35,31,26,22,19,15,12,10,8,6,4,3,2,1
        dc.w    1,1,2,3,4,6,8,10,12,15,19,22,26,31,35,40,45,51
        dc.w    56,62,68,74,81,87,94,101,108,115,123,130,137,145

ytab:   dc.w    67,71,75,79,83,87,91,95,99,102,106,109,112,115
        dc.w    118,120,123,125,127,128,130,131,132,132,133,133
        dc.w    133,132,132,131,130,128,127,125,123,120,118,115
        dc.w    112,109,106,102,99,95,91,87,83,79,75,71,67,63,59
        dc.w    55,51,47,43,39,35,32,28,25,22,19,16,14,11,9,7,6
        dc.w    4,3,2,2,1,1,1,2,2,3,4,6,7,9,11,14,16,19,22,25
        dc.w    28,32,35,39,43,47,51,55,59,63


xnr:    dc.l    0
ynr:    dc.l    0


sprite: 


        dc.w    $781E,$781E,$0000,$781E,$FC3F,$FC3F,$0000,$FC3F
        dc.w    $CE33,$CE33,$300C,$FE3F,$FF3F,$C733,$380C,$FF3F
        dc.w    $C3B3,$FFBF,$3C0C,$FFBF,$C1F3,$FFFF,$3E0C,$FFFF
        dc.w    $FFFF,$FFFF,$3F0C,$FFFF,$C873,$FFFF,$0000,$FFFF
        dc.w    $FFFF,$CC33,$0000,$FFFF,$CE13,$CE13,$0000,$FFFF
        dc.w    $FFFF,$FFFF,$30FC,$CF03,$CD83,$FDFF,$307C,$CD83
        dc.w    $FCFF,$CCC3,$303C,$CCC3,$CC63,$CC63,$301C,$CC63
        dc.w    $FC3F,$FC3F,$0000,$CC33,$781E,$781E,$0000,$781E

        dc.w    $781E,$FC3F,$FE3F,$FF3F,$FFBF,$FFFF,$FFFF,$FFFF
        dc.w    $FFFF,$FFFF,$FFFF,$FDFF,$FCFF,$FC7F,$FC3F,$781E

        dc.w    $0FF0,$0FF0,$0000,$0FF0,$3FFC,$3FFC,$0000,$3FFC
        dc.w    $700E,$700E,$0FF0,$7FFE,$7FFE,$63C6,$1C38,$7FFE
        dc.w    $C7E3,$FFFF,$381C,$FFFF,$CE73,$FE7F,$300C,$FE7F
        dc.w    $FC3F,$FC3F,$300C,$FC3F,$CC33,$FC3F,$0000,$FC3F
        dc.w    $CC37,$FC3B,$0000,$FC3F,$CC33,$CC33,$0000,$FC3F
        dc.w    $FE7F,$FE7F,$300C,$CE73,$C7E3,$FFFF,$381C,$C7E3
        dc.w    $7FFE,$43C2,$3C3C,$43C2,$6006,$6006,$1FF8,$6006
        dc.w    $3FFC,$3FFC,$0000,$381C,$0FF0,$0FF0,$0000,$0FF0

        dc.w    $0FF0,$3FFC,$7FFE,$7FFE,$FFFF,$FE7F,$FC3F,$FC3F
        dc.w    $FC3F,$FC3F,$FE7F,$FFFF,$7FFE,$7FFE,$3FFC,$0FF0

        dc.w    $1FF8,$1FF8,$0000,$1FF8,$3FFC,$3FFC,$0000,$3FFC
        dc.w    $300C,$300C,$0FF0,$3FFC,$3FFC,$300C,$0FF0,$3FFC
        dc.w    $3E7C,$3FFC,$0180,$3FFC,$1E78,$1FF8,$0180,$1FF8
        dc.w    $07E0,$07E0,$0180,$07E0,$0660,$07E0,$0000,$07E0
        dc.w    $07E0,$0660,$0000,$07E0,$0660,$0660,$0000,$07E0
        dc.w    $1FF8,$1FF8,$0180,$1E78,$3E7C,$3FFC,$0180,$3E7C
        dc.w    $3FFC,$381C,$07E0,$381C,$300C,$300C,$0FF0,$300C
        dc.w    $3FFC,$3FFC,$0000,$300C,$1FF8,$1FF8,$0000,$1FF8

        dc.w    $1FF8,$3FFC,$3FFC,$3FFC,$3FFC,$1FF8,$07E0,$07E0
        dc.w    $07E0,$07E0,$1FF8,$3FFC,$3FFC,$3FFC,$3FFC,$1FF8

        dc.w    $781E,$781E,$0000,$781E,$FC3F,$FC3F,$0000,$FC3F
        dc.w    $CE33,$CE33,$300C,$FE3F,$FF3F,$C733,$380C,$FF3F
        dc.w    $C3B3,$FFBF,$3C0C,$FFBF,$C1F3,$FFFF,$3E0C,$FFFF
        dc.w    $FFFF,$FFFF,$3F0C,$FFFF,$C873,$FFFF,$0000,$FFFF
        dc.w    $FFFF,$CC33,$0000,$FFFF,$CE13,$CE13,$0000,$FFFF
        dc.w    $FFFF,$FFFF,$30FC,$CF03,$CD83,$FDFF,$307C,$CD83
        dc.w    $FCFF,$CCC3,$303C,$CCC3,$CC63,$CC63,$301C,$CC63
        dc.w    $FC3F,$FC3F,$0000,$CC33,$781E,$781E,$0000,$781E

        dc.w    $781E,$FC3F,$FE3F,$FF3F,$FFBF,$FFFF,$FFFF,$FFFF
        dc.w    $FFFF,$FFFF,$FFFF,$FDFF,$FCFF,$FC7F,$FC3F,$781E

        dc.w    $781E,$781E,$0000,$781E,$FC3F,$FC3F,$0000,$FC3F
        dc.w    $CC33,$CC33,$300C,$FC3F,$FC3F,$CC33,$300C,$FC3F
        dc.w    $CC33,$FC3F,$300C,$FC3F,$CC33,$FC3F,$300C,$FC3F
        dc.w    $FC3F,$FC3F,$300C,$FC3F,$CC33,$FC3F,$0000,$FC3F
        dc.w    $FC3F,$CC33,$0000,$FC3F,$CC33,$CC33,$0000,$FC3F
        dc.w    $FE7F,$FE7F,$300C,$CE73,$C7E3,$FFFF,$381C,$C7E3
        dc.w    $7FFE,$43C2,$3C3C,$43C2,$6006,$6006,$1FF8,$6006
        dc.w    $3FFC,$3FFC,$0000,$381C,$0FF0,$0FF0,$0000,$0FF0

        dc.w    $781E,$FC3F,$FC3F,$FC3F,$FC3F,$FC3F,$FC3F,$FC3F
        dc.w    $FC3F,$FC3F,$FE7F,$FFFF,$7FFE,$7FFE,$3FFC,$0FF0


        dc.w    $7FFE,$7FFE,$0000,$7FFE,$FFFF,$FFFF,$0000,$FFFF
        dc.w    $E003,$E003,$1FFC,$FFFF,$FFFF,$C003,$3FFC,$FFFF
        dc.w    $C7FF,$FFFF,$3800,$FFFF,$CC0E,$FC0E,$3000,$FC0E
        dc.w    $FFF0,$FFF0,$3000,$FFF0,$C030,$FFF0,$0000,$FFF0
        dc.w    $FFF0,$C030,$0000,$FFF0,$CFF0,$CFF0,$0000,$FFF0
        dc.w    $FC0E,$FC0E,$3000,$CC0E,$C7FF,$FFFF,$3800,$C7FF
        dc.w    $FFFF,$C003,$3FFC,$C003,$C003,$C003,$3FFC,$C003
        dc.w    $FFFF,$FFFF,$0000,$E003,$7FFE,$7FFE,$0000,$7FFE

        dc.w    $7FFE,$FFFF,$FFFF,$FFFF,$FFFF,$FC0E,$FFF0,$FFF0
        dc.w    $FFF0,$FFF0,$FC0E,$FFFF,$FFFF,$FFFF,$FFFF,$7FFE




        dc.w    $781E,$781E,$0000,$781E,$FC3F,$FC3F,$0000,$FC3F
        dc.w    $CC33,$CC33,$300C,$FC3F,$FC3F,$CC33,$300C,$FC3F
        dc.w    $CC33,$FC3F,$300C,$FC3F,$CFF3,$FFFF,$300C,$FFFF
        dc.w    $FFFF,$FFFF,$300C,$FFFF,$C003,$FFFF,$0000,$FFFF
        dc.w    $FFFF,$C003,$0000,$FFFF,$C003,$C003,$0000,$FFFF
        dc.w    $FFFF,$FFFF,$300C,$CFF3,$CFF3,$FFFF,$300C,$CFF3
        dc.w    $FC3F,$CC33,$300C,$CC33,$CC33,$CC33,$300C,$CC33
        dc.w    $FC3F,$FC3F,$0000,$CC33,$781E,$781E,$0000,$781E

        dc.w    $781E,$FC3F,$FC3F,$FC3F,$FC3F,$FFFF,$FFFF,$FFFF
        dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FC3F,$FC3F,$FC3F,$781E

        dc.w    $7FFE,$7FFE,$0000,$7FFE,$FFFF,$FFFF,$0000,$FFFF
        dc.w    $C003,$C003,$3FFC,$FFFF,$FFFF,$C003,$3FFC,$FFFF
        dc.w    $FE7F,$FFFF,$0180,$FFFF,$7E7E,$7FFE,$0180,$7FFE
        dc.w    $07E0,$07E0,$0180,$07E0,$0660,$07E0,$0000,$07E0
        dc.w    $07E0,$0660,$0000,$07E0,$0660,$0660,$0000,$07E0
        dc.w    $07E0,$07E0,$0180,$0660,$0660,$07E0,$0180,$0660
        dc.w    $07E0,$0660,$0180,$0660,$0660,$0660,$0180,$0660
        dc.w    $07E0,$07E0,$0000,$0660,$03C0,$03C0,$0000,$03C0

        dc.w    $7FFE,$FFFF,$FFFF,$FFFF,$FFFF,$7FFE,$07E0,$07E0
        dc.w    $07E0,$07E0,$07E0,$07E0,$07E0,$07E0,$07E0,$03C0






xytab:  blk.w   18,0
        dc.w    0,0,3,16,6,32,9,48,12,64,15,80



SINCOSTAB:
        dc.w    0,6,13,19,26,32,38,45,51,57,64,70,76,83,89,95
        dc.w    101,108,114,120,126,133,139,145
        dc.w    151,157,163,169,175,181,187,193
        dc.w    199,205,211,217,222,228,234,239
        dc.w    245,251,256,262,267,273,278,284
        dc.w    289,294,299,305,310,315,320,325
        dc.w    330,335,340,344,349,354,359,363
        dc.w    368,372,377,381,385,390,394,398
        dc.w    402,406,410,414,418,421,425,429
        dc.w    432,436,439,443,446,449,452,456
        dc.w    459,462,464,467,470,473,475,478
        dc.w    480,483,485,487,490,492,494,496
        dc.w    498,499,501,503,504,506,507,509
        dc.w    510,511,512,513,514,515,516,517
        dc.w    517,518,519,519,519,519,519,519 ;520,520,520

;       dc.w    0,2,3,5,6,8,10,11,13,14,16,17,19,21,22,24
;       dc.w    25,27,28,30,32,33,35,36,38,39,41,42,44,45,47,48
;       dc.w    50,51,53,54,56,57,58,60,61,63,64,65,67,68,70,71
;       dc.w    72,74,75,76,77,79,80,81,82,84,85,86,87,88,90,91
;       dc.w    92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107
;       dc.w    108,109,110,111,111,112,113,114,115,115,116,117,118,118,119,119
;       dc.w    120,121,121,122,122,123,123,124,124,125,125,126,126,126,127,127
;       dc.w    127,128,128,128,129,129,129,129,129,130,130,130,130,130,130,130
SCT2:   BLK.W   128,0
SCT3:   BLK.W   128,0
SCT4:   BLK.W   128,0
SCT5:   dc.w    0



back:   dc.w    0,0,0,0,0,$7e0,$7e0,0,0,$810,$fe0,0
        dc.w    0,$1108,$1ff0,0,0,$1248,$1fb0,0,0,$1248,$1fb0,0
        dc.w    0,$1088,$1f70,0,0,$ffff,$ffff,0,0,$ffff,$ffff,0
        dc.w    0,$8001,$fffe,0,0,$9011,$fffe,0,0,$a425,$fbfa,0
        dc.w    0,$a425,$fbfa,0,0,$8809,$f7f6,0,0,$8001,$fffe,0
        dc.w    0,$8241,$ffbe,0,0,$fe7f,$8780,0
n1:     dc.w    0,$c7c7,$3838,$ffff,0,$8b8b,$7070,$ffff
        dc.w    0,$2929,$d0d0,$ffff,0,$3d3d,$c0c0,$ffff
        dc.w    0,$5151,$a0a0,$ffff,0,$abab,$0,$ffff
        dc.w    0,$c7c7,$0,$ffff,0,$ffff,$0,$ffff
n2:     dc.w    0,$c7c7,$3838,$ffff,0,$8b8b,$7070,$ffff
        dc.w    0,$2929,$d0d0,$ffff,0,$3d3d,$c0c0,$ffff
        dc.w    0,$5151,$a0a0,$ffff,0,$abab,$0,$ffff
        dc.w    0,$c7c7,$0,$ffff,0,$ffff,$0,$ffff
        dc.w    0,$fe7f,$ff9f,0,0,$8241,$ffbe,0,0,$8001,$fffe,0
        dc.w    0,$9011,$fffe,0,0,$a425,$fbfa,0,0,$a425,$fbfa,0
        dc.w    0,$8809,$f7f6,0,0,$8001,$fffe,0,0,$ffff,$8000,0
        dc.w    0,$ffff,$8000,0,0,$1108,$1ff0,0,0,$1248,$1fb0,0
        dc.w    0,$1248,$1fb0,0,0,$1088,$1f70,0,0,$810,$fe0,0
        dc.w    0,$7e0,0,0,0,0,0,0      

lrback:
        dc.w    $0,$0,$0,$0,$0,$0,$0,$0
        dc.w    $0,$f,$f,$0,$0,$f000,$f000,$0
        dc.w    $0,$1f,$1f,$0,$0,$f800,$f000,$0
        dc.w    $0,$38,$3f,$0,$0,$1c00,$e000,$0
        dc.w    $0,$30,$3f,$0,$0,$c00,$f000,$0
        dc.w    $0,$30,$3f,$0,$0,$c00,$f000,$0
        dc.w    $0,$30,$3f,$0,$0,$c00,$f000,$0
        dc.w    $0,$ff0,$fff,$0,$0,$ff0,$f3f0,$0
        dc.w    $0,$3ff0,$3fff,$0,$0,$ffc,$f3fc,$0
        dc.w    $0,$6030,$7fff,$0,$0,$c06,$f3f8,$0
        dc.w    $0,$43f0,$7fff,$0,$0,$fc2,$f3fc,$0
        dc.w    $0,$c430,$ffff,$0,$0,$c23,$f3dc,$0
        dc.w    $0,$c5b8,$ffff,$0,$0,$1da3,$fbdc,$0
        dc.w    $0,$c5e4,$ff7b,$60,$0,$25a3,$fb5c,$0
        dc.w    $0,$c4b4,$fffb,$90,$0,$2f23,$ffdc,$f00
        dc.w    $0,$c3e4,$fd3b,$100,$0,$27c3,$f8bc,$80
        dc.w    $0,$c0b8,$fff7,$80,$0,$1c83,$e3fc,$80
        dc.w    $0,$c170,$ffff,$140,$0,$c63,$f3fc,$60
        dc.w    $0,$c1b0,$ffff,$180,$0,$dd3,$f3fc,$1d0
        dc.w    $0,$c270,$ffff,$240,$0,$d23,$f3fc,$120
        dc.w    $0,$c3b0,$ffff,$380,$0,$c83,$f3fc,$80
        dc.w    $0,$c3f0,$ffff,$200,$0,$fc3,$f3fc,$40
        dc.w    $0,$c530,$ffff,$100,$0,$c23,$f3fc,$0
        dc.w    $0,$dc78,$ffff,$0,$0,$1e3b,$fffc,$0
        dc.w    $0,$d084,$fffb,$0,$0,$210b,$fef4,$0
        dc.w    $0,$d0d4,$ff2b,$0,$0,$2b0b,$f4f4,$0
        dc.w    $0,$de78,$e787,$600,$0,$1e3b,$e1c4,$0
        dc.w    $0,$fc30,$ffff,$3800,$0,$c73,$f3fc,$70
        dc.w    $0,$cff0,$fc3f,$4c00,$0,$fcb,$f03c,$8
        dc.w    $0,$f030,$ffff,$7000,$0,$c07,$f3fc,$4
        dc.w    $0,$e030,$ffff,$e000,$0,$c37,$f3fc,$34
        dc.w    $0,$d030,$ffff,$9000,$0,$c2b,$f3fc,$28
        dc.w    $0,$f0f0,$ffff,$f000,$0,$f1b,$fffc,$18
        dc.w    $0,$c300,$ffff,$4200,$0,$f3,$ff7c,$70
        dc.w    $0,$fff0,$ff1f,$3c00,$0,$fc3,$f0fc,$0
        dc.w    $0,$c430,$ffff,$0,$0,$c23,$f3dc,$0
        dc.w    $0,$c5b0,$ffff,$0,$0,$da3,$f3dc,$0
        dc.w    $0,$c5b0,$ff7f,$0,$0,$da3,$f35c,$0
        dc.w    $0,$c430,$ffff,$0,$0,$c23,$f3dc,$0
        dc.w    $0,$43f0,$7c3f,$0,$0,$fc2,$f03c,$0
        dc.w    $0,$6030,$1fff,$0,$0,$c06,$f3f8,$0
        dc.w    $0,$3ff0,$3f,$0,$0,$ffc,$f000,$0
        dc.w    $0,$ff0,$3f,$0,$0,$ff0,$f000,$0
        dc.w    $0,$30,$3f,$0,$0,$c00,$f000,$0
        dc.w    $0,$30,$3f,$0,$0,$c00,$f000,$0
        dc.w    $0,$30,$3f,$0,$0,$c00,$f000,$0
        dc.w    $0,$38,$37,$0,$0,$1c00,$e000,$0
        dc.w    $0,$1f,$0,$0,$0,$f800,$0,$0
        dc.w    $0,$f,$0,$0,$0,$f000,$0,$0
        dc.w    $0,$0,$0,$0,$0,$0,$0,$0


samplength:     equ     549070
;textlength:    equ     856
        
scrollbase:     dc.l    0
scrollpos:      dc.l    0
;textscroll:    blk.l   400,0
;stck:          blk.l   100,0
;ustck:         dc.l    0
;               dc.l    0
bpic:           blk.l   32,0
pic:            blk.l   8000,0
font:           blk.l   16500,0
endfont:        dc.w    0


Background1:
; A0 pixs 32 scanlines
        dc.w    $7867,$7818,$87FF,$0000,$324B,$31F3,$CFC3,$003C
        dc.w    $26E7,$C6FF,$F900,$0000,$E3FA,$FC06,$0001,$0000
        dc.w    $1320,$0F18,$FF00,$00F8,$01B6,$0238,$003F,$03C0
        dc.w    $064B,$0038,$FFF8,$0007,$09DE,$F1E6,$3E01,$C000
        dc.w    $3F50,$00CC,$FFC0,$003C,$1FB2,$603C,$003F,$7FC0
        dc.w    $CF34,$CF08,$30FF,$0000,$734B,$70F3,$8FC3,$003C
        dc.w    $303E,$C03E,$FFC1,$0000,$DCFA,$DF06,$2001,$0000
        dc.w    $19B0,$078C,$FF80,$007C,$01A4,$3E38,$003F,$3FC0
        dc.w    $005B,$0038,$FFF8,$0007,$AC5A,$5066,$1F81,$E000
        dc.w    $9D58,$82C4,$7FC0,$003C,$3826,$4038,$003F,$7FC0
        dc.w    $239C,$0380,$FC7F,$0000,$C969,$F8D1,$07C1,$003E
        dc.w    $9F80,$E000,$FFFF,$0000,$C7F2,$C70E,$3801,$0000
        dc.w    $CC90,$038C,$FF80,$007C,$1929,$6631,$003E,$7FC0
        dc.w    $FC48,$FC38,$03F8,$0007,$D76E,$3872,$1F81,$E000
        dc.w    $DC68,$C3E6,$3FE0,$001E,$33C5,$43F9,$03FE,$7C00
        dc.w    $EFE7,$0FE7,$F018,$0000,$A94C,$D8D0,$07C0,$003F
        dc.w    $C0FD,$FF01,$FFFE,$0000,$9106,$81FE,$7E01,$0000
        dc.w    $C6D0,$01CC,$FFC0,$003C,$1B6B,$6473,$007C,$7F80
        dc.w    $062E,$FE1E,$01FE,$0001,$412F,$2E33,$0FC0,$F000
        dc.w    $DBEC,$C7E2,$3FE0,$001E,$161C,$67E0,$07FF,$7800
        dc.w    $983C,$1FFF,$E000,$0000,$4976,$B8E8,$07E0,$001F
        dc.w    $7808,$7FF0,$7FFF,$8000,$3D8C,$01FC,$FE03,$0000
        dc.w    $A6D0,$41CC,$FFC0,$003C,$1352,$6463,$007C,$7F80
        dc.w    $73A3,$8F9F,$007F,$0000,$49A5,$3E3B,$0FC0,$F000
        dc.w    $93B4,$8FB2,$7FB0,$004E,$1A7F,$6380,$03FF,$7C00
        dc.w    $3381,$3C7E,$C000,$0000,$D353,$30CC,$0FC0,$003F
        dc.w    $87CF,$07F0,$07FF,$F800,$E4F1,$18F0,$FF0F,$0000
        dc.w    $BC90,$4388,$FF80,$0078,$0353,$6463,$007C,$7F80
        dc.w    $18A9,$E797,$007F,$0000,$6B15,$141B,$07E0,$F800
        dc.w    $BB2C,$8722,$7F20,$00DE,$0B06,$33F8,$03FF,$3C00
        dc.w    $F4E7,$FB18,$0000,$0000,$1258,$F1C7,$0FC0,$003F
        dc.w    $F873,$007C,$007F,$FF80,$8607,$7800,$FFFF,$0000
        dc.w    $81B0,$7F88,$FF80,$0078,$0D59,$EA61,$087E,$F780
        dc.w    $CEB5,$F183,$007F,$0000,$2272,$1C7D,$0780,$F800
        dc.w    $9938,$8726,$7F20,$00DE,$09CC,$31F0,$01FF,$3E00
        dc.w    $333C,$3FC3,$C000,$0000,$76D0,$F1CD,$0FC0,$003D
        dc.w    $0F1C,$F01F,$001F,$FFE0,$33F8,$FC07,$FFFF,$0000
        dc.w    $39A0,$FF98,$FF80,$0078,$094C,$EA70,$087F,$F780
        dc.w    $2249,$3DC7,$C03F,$0000,$2EFA,$10FD,$0700,$F800
        dc.w    $CD58,$C304,$3F00,$00FC,$0C77,$1078,$007F,$1F80
        dc.w    $9CD9,$1CE7,$E300,$0000,$C490,$C388,$3F80,$0078
        dc.w    $01C7,$1E07,$0007,$1FF8,$F8C0,$FF3F,$FFFF,$0000
        dc.w    $6F20,$EF11,$EF00,$10F1,$6D64,$8E78,$0C7F,$F380
        dc.w    $0DB3,$0F8F,$F07F,$0000,$669A,$109D,$0760,$F800
        dc.w    $6530,$E30C,$1F00,$00FC,$0318,$3C1F,$001F,$3FE0
        dc.w    $ECBB,$0CC7,$F300,$0000,$19B0,$0788,$FF80,$0078
        dc.w    $0070,$3F80,$0000,$3FFF,$8E63,$8F9F,$8FFF,$7000
        dc.w    $CCE0,$CC13,$CC00,$33F3,$CB32,$0C3C,$0C3F,$F3C0
        dc.w    $6016,$000E,$FFFE,$0001,$4E37,$3838,$0FC0,$F000
        dc.w    $3520,$F318,$0F00,$00F8,$0C7C,$307F,$007F,$3F80
        dc.w    $A16D,$4193,$FE00,$0000,$3220,$0E19,$FE00,$01F9
        dc.w    $0E0E,$F1F0,$0000,$FFFF,$3366,$039E,$03FE,$FC01
        dc.w    $4081,$3F66,$0000,$FFE7,$3094,$3D18,$3C1F,$C3E0
        dc.w    $DA4B,$2007,$FFFF,$0000,$5AB7,$2C39,$0FC0,$F000
        dc.w    $B520,$F318,$0F00,$00F8,$06C9,$18FE,$00FF,$1F00
        dc.w    $3AC5,$C33B,$FC00,$0000,$92C0,$8E33,$7E00,$01F3
        dc.w    $FFE3,$001C,$0000,$FFFF,$FDA7,$01DE,$01FE,$FE01
        dc.w    $3E82,$C15C,$0000,$FFDF,$66CF,$7B08,$7E0F,$81F0
        dc.w    $21EB,$FE07,$FFFF,$0000,$4BA7,$2C38,$0FC0,$F000
        dc.w    $F590,$F388,$0F80,$0078,$0253,$0C6C,$007F,$0F80
        dc.w    $5294,$E37B,$FC00,$0000,$DB61,$C71E,$3F00,$00FF
        dc.w    $C038,$0007,$0000,$FFFF,$068E,$F8FD,$00FC,$FF03
        dc.w    $E10C,$00F0,$0000,$FFFF,$C468,$FA8F,$FE0F,$01F0
        dc.w    $7C12,$FFEE,$FFFE,$0001,$4CA7,$2F38,$0FC0,$F000
        dc.w    $25D0,$E3C8,$1FC0,$0038,$0376,$0479,$007F,$0780
        dc.w    $B532,$C6FD,$F800,$0000,$4913,$C70C,$3F00,$00FF
        dc.w    $1F0C,$1F02,$1F00,$E0FE,$03CD,$0CFA,$00F8,$0F07
        dc.w    $C819,$09E1,$0801,$F7FE,$1E37,$E147,$FF07,$00F8
        dc.w    $C7EE,$C7FE,$C7FE,$3801,$C4B2,$273D,$07C0,$F800
        dc.w    $EDD0,$E3C8,$1FC0,$0038,$0199,$061F,$001F,$07E0
        dc.w    $A45B,$C7DC,$F820,$0000,$6DD2,$E3CC,$1FC0,$003F
        dc.w    $71E4,$7FE3,$7FE0,$801F,$017D,$067A,$0078,$0787
        dc.w    $1C1B,$1CE3,$1C03,$E3FC,$7308,$80B0,$FF80,$007F
        dc.w    $1838,$0038,$0038,$FFC7,$9699,$671F,$07E0,$F800
        dc.w    $8990,$8788,$7F80,$0078,$00C7,$0307,$0007,$03F8
        dc.w    $AF89,$CF8E,$F070,$0000,$AC66,$63E8,$1FE0,$001F
        dc.w    $C074,$FFF3,$FFF0,$000F,$0123,$8224,$0020,$83DF
        dc.w    $7632,$7EC3,$7E03,$81FC,$4A67,$8828,$F7E0,$001F
        dc.w    $FF13,$0010,$0010,$FFEF,$92DF,$631F,$03E0,$FC00
        dc.w    $4930,$2608,$E000,$1FF8,$0070,$0180,$0000,$01FF
        dc.w    $B324,$C307,$FCF8,$0000,$AD24,$62E8,$1FE0,$001F
        dc.w    $9F97,$E070,$FFF0,$000F,$018A,$E204,$0000,$E3FF
        dc.w    $49E6,$7607,$7E07,$81F8,$D6AA,$1099,$EF78,$0007
        dc.w    $0187,$FE00,$0000,$FFFF,$1A49,$E388,$03F7,$FC00
        dc.w    $2F00,$90F8,$8000,$7FF8,$001E,$00E0,$0000,$00FF
        dc.w    $9A76,$E207,$FDF8,$0000,$AFA5,$6079,$1FE1,$001E
        dc.w    $B0D1,$C030,$FFF0,$000F,$C19A,$3204,$0000,$F3FF
        dc.w    $D68E,$E30F,$FE0F,$01F0,$B492,$308F,$CF7F,$0000
        dc.w    $0D7C,$FC83,$FC00,$03FF,$0A59,$B394,$03EC,$BC03
        dc.w    $3FE0,$C01F,$0000,$FFFF,$0006,$E038,$0000,$E03F
        dc.w    $CBD2,$F323,$FCFC,$0000,$4F8D,$C051,$3FC1,$003E
        dc.w    $265C,$C63C,$F9FC,$0003,$60F2,$1B0C,$0000,$FBFF
        dc.w    $D0B3,$E13F,$FC3F,$03C0,$ADDD,$21C2,$DE3F,$0000
        dc.w    $E740,$1F3E,$FF00,$00FE,$0A55,$1382,$03F0,$1C0F
        dc.w    $E01F,$0000,$0000,$FFFF,$0002,$F81C,$0000,$F81F
        dc.w    $69DB,$7123,$7EFC,$8000,$58E9,$C711,$3FC1,$003E
        dc.w    $6B47,$8F3F,$F0FF,$0000,$3002,$09FC,$0000,$F9FF
        dc.w    $6BA5,$743B,$7C3F,$83C0,$A3E7,$23E0,$DC1F,$0000
        dc.w    $30D8,$0FC4,$FFC0,$003C,$0D67,$1188,$01E0,$1E1F
        dc.w    $0FC1,$0FC0,$0FC0,$F03F,$B002,$4FFC,$0000,$FFFF
        dc.w    $2C69,$3011,$3FFE,$C000,$935B,$8FA3,$7FC3,$003C
        dc.w    $4971,$8F0F,$F0FF,$0000,$9006,$8C08,$8000,$7C0F
        dc.w    $CD2C,$F633,$FC3F,$03C0,$B634,$37F0,$C80F,$0000
        dc.w    $5E4C,$41C2,$BFC0,$003E,$054C,$1990,$01C0,$1E3F
        dc.w    $7878,$7FF8,$7FF8,$8007,$9FFC,$6003,$0000,$FFFF
        dc.w    $27CC,$F830,$3FFF,$C000,$365A,$0FA3,$FFC3,$003C
        dc.w    $550C,$9B03,$E0FF,$0000,$9804,$8618,$8000,$7E1F
        dc.w    $9168,$E273,$F87F,$0780,$94B1,$1771,$E80E,$0000
        dc.w    $C364,$C0E2,$3FE0,$001E,$0539,$09C1,$01C1,$0E3E
        dc.w    $C38E,$FC7E,$FFFE,$0001,$4302,$2001,$0000,$FFFF
        dc.w    $9187,$7E78,$1FFF,$E000,$EEDA,$1F23,$FFC3,$003C
        dc.w    $D5E6,$1BE1,$E01F,$0000,$CC04,$C218,$C000,$3E1F
        dc.w    $AE68,$C073,$F87F,$0780,$9D46,$1EC7,$E038,$0000
        dc.w    $7934,$F8F2,$07F0,$000E,$059B,$09E3,$01C3,$0E3C
        dc.w    $1FF3,$E00F,$FFFF,$0000,$7C7D,$1C7C,$1C7C,$E383
        dc.w    $CC30,$3FFF,$0FFF,$F000,$1DBA,$FE43,$FFC3,$003C
        dc.w    $D612,$19F1,$E00F,$0000,$6406,$E218,$E000,$1E1F
        dc.w    $9269,$EC70,$F87F,$0780,$9D49,$1ECE,$E030,$0000
        dc.w    $6DA4,$EC62,$13E0,$001E,$0692,$08A3,$0083,$0F7C
        dc.w    $701D,$8003,$FFFF,$0000,$27C2,$0FFE,$0FFE,$F001
        dc.w    $67FF,$17FF,$07FF,$F800,$740A,$F7D3,$F7C3,$083C
        dc.w    $D7C9,$1838,$E007,$0000,$3402,$F30C,$F000,$0F0F
        dc.w    $C234,$FC38,$F83F,$07C0,$0DB6,$0E79,$F000,$0000
        dc.w    $4DAC,$C062,$3FE0,$001E,$0256,$0C27,$0007,$0FF8
        dc.w    $C7C5,$07C3,$F83F,$0000,$B09E,$8FE2,$8FFE,$7001
        dc.w    $2201,$1A01,$0201,$FDFE,$C1EB,$C1F3,$C1E3,$3E1C
        dc.w    $5B9B,$9C78,$E007,$0000,$9402,$7304,$F000,$0F07
        dc.w    $7717,$7818,$781F,$87E0,$24AC,$0773,$F800,$0000
        dc.w    $9F28,$80E6,$7FE0,$001E,$0334,$0447,$0007,$07F8
        dc.w    $9872,$1FF1,$E00F,$0000,$AB65,$9083,$8FFF,$7000
        dc.w    $90E4,$8800,$8000,$7FFF,$1C09,$0011,$0001,$FFFE
        dc.w    $4A33,$8DF0,$F00F,$0000,$3403,$F304,$F000,$0F07
        dc.w    $11D3,$1A1C,$181F,$E7E0,$F6D9,$0727,$F800,$0000
        dc.w    $326C,$0DE2,$FFE0,$001E,$01B4,$0647,$0007,$07F8
        dc.w    $A79A,$3879,$C007,$0000,$A0C9,$9007,$8FFF,$7000
        dc.w    $D7BF,$C840,$C000,$3FFF,$E3E5,$1C19,$0001,$FFFE
        dc.w    $6D86,$8F81,$F07F,$0000,$2401,$E306,$E000,$1F07
        dc.w    $DAD8,$1D1F,$1C1F,$E3E0,$1A73,$E38F,$FC00,$0000
        dc.w    $9C64,$83E2,$7FE0,$001E,$00B4,$0347,$0007,$03F8
        dc.w    $B1EA,$3E19,$C007,$0000,$AE04,$9603,$89FF,$7000
        dc.w    $504E,$CFB1,$C000,$3FFF,$3DF5,$A409,$3C01,$C3FE
        dc.w    $A73C,$C703,$F8FF,$0000,$EC00,$E203,$E000,$1E03
        dc.w    $D2CF,$1F0F,$1E0F,$E1F0,$8A78,$F387,$FC00,$0000
        dc.w    $C724,$C0E3,$3FE0,$001F,$0016,$01E7,$0007,$01F8
        dc.w    $9EDA,$1F39,$E007,$0000,$A086,$9F81,$887F,$7000
        dc.w    $5095,$CF11,$C011,$3FEE,$0344,$8138,$FF00,$00FF
        dc.w    $B063,$C01F,$FFFF,$0000,$8800,$8601,$8000,$7E01
        dc.w    $55C7,$9806,$1E07,$E1F8,$3ECE,$C731,$F800,$0000
        dc.w    $31AE,$F061,$0FE0,$001F,$0012,$1FE3,$0003,$1FFC
        dc.w    $C2D2,$0331,$FC0F,$0000,$AE73,$99F0,$880F,$7000
        dc.w    $58DC,$C51F,$C01F,$3DE0,$F384,$03A8,$FC60,$001F
        dc.w    $CF8E,$F07E,$FFFE,$0001,$3800,$0400,$0000,$FC00
        dc.w    $526D,$9C8E,$1E0F,$E1F0,$E491,$077E,$F800,$0000
        dc.w    $9CA6,$7C61,$03E0,$001F,$07D3,$7823,$0003,$7FFC
        dc.w    $7A84,$8363,$FC1F,$0000,$A319,$9CF8,$8807,$7000
        dc.w    $5847,$C587,$C007,$3DF8,$1826,$E018,$FFF0,$000F
        dc.w    $7039,$7FF8,$7FF8,$8007,$8000,$7C00,$0000,$FC00
        dc.w    $5928,$9FCE,$1F0F,$E0F0,$65BC,$067F,$F800,$0000
        dc.w    $C6B4,$3E73,$01F0,$000F,$3C1B,$4023,$0003,$7FFC
        dc.w    $0A2D,$F3E3,$FC1F,$0000,$29C9,$1638,$0807,$F000
        dc.w    $D871,$C481,$C001,$3CFE,$C7C3,$F834,$FFF0,$000F
        dc.w    $1FC2,$1FC1,$1FC0,$E03F,$3800,$C780,$0000,$FF80
        dc.w    $6F2A,$8ECC,$0E0F,$F1F0,$8D26,$8EE7,$7018,$0000
        dc.w    $7294,$8E73,$01F0,$000F,$2189,$C1B1,$0181,$FE7E
        dc.w    $E969,$F1E7,$FE1F,$0000,$741A,$07F9,$0807,$F000
        dc.w    $901E,$8CE0,$8000,$7CFF,$7038,$7FFB,$7FF8,$8007
        dc.w    $C000,$01FF,$0000,$FFFF,$EE00,$01F0,$0000,$FFF0
        dc.w    $224A,$438C,$020F,$7DF0,$5B63,$5CE3,$A01C,$0000
        dc.w    $8CB4,$FC73,$03F0,$000F,$EFCC,$0FD0,$0FC0,$F03F
        dc.w    $24CB,$38C7,$3F3F,$C000,$47F2,$27F1,$080F,$F000
        dc.w    $B003,$887C,$8000,$787F,$0FE2,$0FE1,$0FE0,$F01F
        dc.w    $78F9,$8706,$0000,$FFFF,$D3E0,$101C,$1000,$EFFC
        dc.w    $1E4B,$618C,$000F,$7FF0,$7448,$7BC0,$803F,$0000
        dc.w    $F1A5,$F062,$0FE0,$001F,$9C27,$1FE8,$1FE0,$E01F
        dc.w    $B61A,$3806,$3FFE,$C001,$5004,$3003,$1FFF,$E000
        dc.w    $B001,$8806,$8000,$7807,$E00C,$0003,$0000,$FFFF
        dc.w    $0387,$BC00,$0000,$BFFF,$7C38,$7C06,$7C00,$83FE
        dc.w    $0CC9,$330E,$000F,$3FF0,$B1DE,$3FC0,$C03F,$0000
        dc.w    $0769,$00E6,$FFE0,$001F,$1190,$1E77,$1FF0,$E00F
        dc.w    $9376,$1C0E,$1FFE,$E001,$FC0D,$1003,$1FFF,$E000
        dc.w    $2000,$1803,$0000,$F803,$3FF8,$C006,$0000,$FFFE
        dc.w    $0630,$1830,$0030,$1FCF,$8F8C,$0F82,$0F80,$F07E
        dc.w    $02EC,$1D0F,$000F,$1FF0,$8E13,$0E0C,$F1FF,$0000
        dc.w    $FCCB,$03C4,$FFC0,$003F,$73CC,$7C3F,$7FFC,$8003
        dc.w    $D8E5,$1F1C,$1FFC,$E003,$9E7D,$4183,$1FFF,$E000
        dc.w    $4000,$37E0,$0000,$F7E0,$0000,$7FF0,$0000,$7FF0
        dc.w    $0C78,$3078,$0078,$3F87,$1864,$1FE3,$1FE0,$E01F
        dc.w    $0066,$0387,$0007,$03F8,$C060,$001F,$FFFF,$0000
        dc.w    $F9E9,$07E6,$FFE0,$001F,$3A60,$3C1D,$3FFC,$C003
        dc.w    $4E4D,$8FBC,$0FFC,$F003,$7203,$AFFF,$3FFF,$C000
        dc.w    $43C0,$3C30,$0000,$FFF0,$0000,$3000,$0000,$3000
        dc.w    $19FF,$21FF,$01FF,$3E00,$FB34,$FCF3,$FFF0,$000F
        dc.w    $0066,$0087,$0007,$00F8,$31CE,$C03F,$FFFF,$0000
        dc.w    $1B85,$E7E2,$FFE0,$001F,$8A3A,$0C06,$0FFE,$F001
        dc.w    $6309,$83F8,$03F8,$FC07,$06E6,$BFFE,$3FFE,$C001
        dc.w    $9C60,$601E,$0000,$FFFE,$0000,$FC00,$0000,$FC00
        dc.w    $1780,$67FF,$07FF,$7800,$398E,$FE61,$FFE0,$001F
        dc.w    $0023,$C0C3,$0003,$C0FC,$DF13,$E0F3,$FFF3,$000C
        dc.w    $BA54,$C7B3,$FFF0,$000F,$9B08,$1C06,$1FFE,$E001
        dc.w    $31BB,$C1F8,$01F8,$FE07,$4FF8,$FFF8,$7FF8,$8007
        dc.w    $B03C,$4003,$0000,$FFFF,$1800,$E700,$0000,$FF00
        dc.w    $363F,$C7C0,$07FF,$F800,$8781,$7860,$FFE0,$001F
        dc.w    $C031,$3041,$0001,$F07E,$C074,$FFF0,$FFF0,$000F
        dc.w    $9CD6,$E331,$FFF0,$000F,$B0CC,$3F03,$3FFF,$C000
        dc.w    $1CE2,$60E1,$00E0,$FF1F,$79C7,$F9C0,$79C0,$863F
        dc.w    $073E,$8701,$0700,$F8FF,$7E00,$81C1,$0000,$FFC1
        dc.w    $64E0,$8700,$07FF,$F800,$EF3C,$10FC,$FFFC,$0003
        dc.w    $601C,$1860,$0000,$F87F,$7FC6,$7FC0,$7FC0,$803F
        dc.w    $C796,$F871,$FFF0,$000F,$A7C4,$3803,$3FFF,$C000
        dc.w    $060E,$B801,$8000,$7FFF,$019C,$8183,$0180,$FE7F
        dc.w    $BF83,$3F80,$3F80,$C07F,$8F80,$0063,$0000,$FFE3
        dc.w    $6D8E,$8E0E,$0FF1,$F000,$7F87,$007F,$FFFF,$0000
        dc.w    $3003,$0E3C,$0000,$FE3F,$9E1A,$1E04,$1E00,$E1FF
        dc.w    $7036,$7FF1,$7FF0,$800F,$2601,$3800,$3FFF,$C000
        dc.w    $63F8,$EC07,$E000,$1FFF,$FC30,$000F,$0000,$FFFF
        dc.w    $20F0,$3FF0,$3FF0,$C00F,$00C1,$0022,$0000,$FFE3
        dc.w    $C9BF,$0E3F,$0FC0,$F000,$21C1,$003F,$FFFF,$0000
        dc.w    $9800,$8707,$8000,$7F07,$61F1,$800E,$0000,$FFFF
        dc.w    $9FE6,$1FE1,$1FE0,$E01F,$E4F9,$F8F8,$FF07,$0000
        dc.w    $1000,$F7FF,$F000,$0FFF,$67E0,$981F,$0000,$FFFF
        dc.w    $4F1B,$70FB,$7FFB,$8004,$F841,$F826,$F800,$07E7
        dc.w    $1B29,$1C3F,$1FC0,$E000,$8CF9,$8C07,$73FF,$0000
        dc.w    $CC00,$C380,$C000,$3F80,$3F84,$C07B,$0000,$FFFF
        dc.w    $C30D,$0302,$0300,$FCFF,$C58D,$F9FC,$FE03,$0000
        dc.w    $9B00,$78F0,$F800,$07F0,$0001,$7FFE,$0000,$7FFF
        dc.w    $D8CE,$E03F,$FFFF,$0000,$0E43,$FE3C,$FE00,$01FF
        dc.w    $726C,$7C7F,$7F80,$8000,$FE0C,$FE03,$01FF,$0000
        dc.w    $6700,$E080,$E000,$1F80,$0C3C,$73C1,$0000,$7FFF
        dc.w    $7862,$801C,$0000,$FFFF,$0934,$F1CC,$FE03,$0000
        dc.w    $CA60,$3810,$F800,$07F0,$0007,$0798,$0000,$079F
        dc.w    $E06C,$FE1F,$FFFF,$0000,$E722,$1F1C,$FF00,$00FF
        dc.w    $66DE,$78E5,$7F00,$8000,$3807,$F800,$07FF,$0000
        dc.w    $1100,$F0C0,$F000,$0FC0,$0022,$1EC2,$0002,$1EFD
        dc.w    $8FC7,$7038,$0000,$FFFF,$0A76,$F38E,$FC01,$0000
        dc.w    $4920,$3918,$F900,$06F8,$000E,$0070,$0000,$007F
        dc.w    $316E,$FE18,$FFFF,$0000,$31A6,$0F98,$FF80,$007F
        dc.w    $CEBF,$F0C0,$FF00,$0000,$CFF0,$3FF0,$000F,$0000
        dc.w    $1D80,$FC60,$FC00,$03E0,$004C,$008F,$000F,$00F0
        dc.w    $A02A,$9FC9,$8008,$7FF7,$EA7A,$9386,$FC01,$0000
        dc.w    $49B0,$3F88,$FF80,$0078,$0008,$0FF0,$0000,$0FFF
        dc.w    $FF2A,$001C,$FFFF,$0000,$9DAC,$8390,$7F80,$007F
        dc.w    $989E,$E0E1,$FF00,$0000,$3D9C,$C3FC,$0003,$0000
        dc.w    $C4C0,$3C30,$FC00,$03F0,$0058,$019F,$001F,$01E0
        dc.w    $09CA,$FE39,$FFF8,$0007,$7A72,$038E,$7C01,$8000
        dc.w    $6090,$1F88,$FF80,$0078,$01F3,$3E03,$0003,$3FFC
        dc.w    $8023,$001C,$FFFF,$0000,$65C9,$63D1,$9FC1,$003E
        dc.w    $B3C1,$C3FF,$FC00,$0000,$8F26,$F0DE,$0001,$0000
        dc.w    $7640,$0E30,$FE00,$01F0,$0097,$0318,$001F,$03E0
        dc.w    $CF2A,$3019,$FFF8,$0007,$9B76,$638E,$7C01,$8000
        dc.w    $7650,$09CC,$FFC0,$003C,$0FE6,$7007,$0007,$7FF8


Background2:
; 100 pixs 2b scanlines
        dc.w    $0000,$0000,$0000,$0000,$0003,$0003,$0003,$0003
        dc.w    $FC00,$FC00,$FC00,$FC00,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $000F,$000F,$000F,$000F,$8000,$8000,$8000,$8000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$001F,$001F,$001F,$001F
        dc.w    $FF00,$FF00,$FF00,$FF00,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0010,$001F,$001F,$001F,$C000,$C000,$C000,$C000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0060,$007F,$007F,$007F
        dc.w    $0180,$FF80,$FF80,$FF80,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0037,$0038,$003F,$003F,$4003,$C003,$C003,$C003
        dc.w    $E000,$E000,$E000,$E000,$0000,$0000,$0000,$0000
        dc.w    $000F,$000F,$000F,$000F,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$00C7,$00F8,$00FF,$00FF
        dc.w    $F8C0,$07C0,$FFC0,$FFC0,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$7E00,$7E00,$7E00,$7E00
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0025,$0038,$003F,$003F,$600E,$E00F,$E00F,$E00F
        dc.w    $3000,$F000,$F000,$F000,$0000,$0000,$0000,$0000
        dc.w    $003F,$003F,$003F,$003F,$E000,$E000,$E000,$E000
        dc.w    $0000,$0000,$0000,$0000,$01BC,$01C0,$01FF,$01FF
        dc.w    $0E40,$01C0,$FFC0,$FFC0,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0001,$0001,$0001,$0001,$C300,$FF00,$FF00,$FF00
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0045,$0078,$007F,$007F,$2008,$E00F,$E00F,$E00F
        dc.w    $1800,$F800,$F800,$F800,$0000,$0000,$0000,$0000
        dc.w    $0060,$007F,$007F,$007F,$3000,$F000,$F000,$F000
        dc.w    $0000,$0000,$0000,$0000,$0330,$03C0,$03FF,$03FF
        dc.w    $0320,$00E0,$FFE0,$FFE0,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0001,$0001,$0001,$0001,$3900,$C700,$FF00,$FF00
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $004D,$0070,$007F,$007F,$201B,$E01C,$E01F,$E01F
        dc.w    $C800,$3800,$F800,$F800,$0000,$0000,$0000,$0000
        dc.w    $0060,$007F,$007F,$007F,$1800,$F800,$F800,$F800
        dc.w    $0000,$0000,$0000,$0000,$0267,$0380,$03FF,$03FF
        dc.w    $F9F0,$0030,$FFF0,$FFF0,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0001,$0001,$0001,$0001,$2900,$C700,$FF00,$FF00
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0049,$0070,$007F,$007F,$2016,$E018,$E01F,$E01F
        dc.w    $4800,$3800,$F800,$F800,$0000,$0000,$0000,$0000
        dc.w    $0043,$007C,$007F,$007F,$8C00,$7C00,$FC00,$FC00
        dc.w    $0000,$0000,$0000,$0000,$06C8,$0707,$07FF,$07FF
        dc.w    $0258,$FC38,$FFF8,$FFF8,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0003,$0003,$0003,$0003,$4900,$8700,$FF00,$FF00
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0049,$0070,$007F,$007F,$2014,$E018,$E01F,$E01F
        dc.w    $4800,$3800,$F800,$F800,$0000,$0000,$0000,$0000
        dc.w    $00C7,$00F8,$00FF,$00FF,$E600,$1E00,$FE00,$FE00
        dc.w    $0000,$0000,$0000,$0000,$0490,$070F,$07FF,$07FF
        dc.w    $0168,$FE18,$FFF8,$FFF8,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0002,$0003,$0003,$0003,$5900,$8700,$FF00,$FF00
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $004B,$0070,$007F,$007F,$6016,$E018,$E01F,$E01F
        dc.w    $C800,$3800,$F800,$F800,$0000,$0000,$0000,$0000
        dc.w    $00C6,$00F8,$00FF,$00FF,$E200,$1E00,$FE00,$FE00
        dc.w    $0000,$0000,$0000,$0000,$0480,$071E,$07FE,$07FE
        dc.w    $012C,$0E1C,$0FFC,$0FFC,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0006,$0007,$0007,$0007,$5900,$8700,$FF00,$FF00
        dc.w    $0001,$0001,$0001,$0001,$FE00,$FE00,$FE00,$FE00
        dc.w    $00CA,$00F1,$00FF,$00FF,$6013,$E01C,$E01F,$E01F
        dc.w    $9800,$7800,$F800,$F800,$0000,$0000,$0000,$0000
        dc.w    $00CC,$00F0,$00FF,$00FF,$6200,$1E00,$FE00,$FE00
        dc.w    $0000,$0000,$0000,$0000,$05A0,$061C,$07FC,$07FC
        dc.w    $012C,$061C,$07FC,$07FC,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $001E,$001F,$001F,$001F,$D300,$0F00,$FF00,$FF00
        dc.w    $0003,$0003,$0003,$0003,$0300,$FF00,$FF00,$FF00
        dc.w    $0092,$00E1,$00FF,$00FF,$6018,$E01F,$E01F,$E01F
        dc.w    $7000,$F000,$F000,$F000,$0000,$0000,$0000,$0000
        dc.w    $00CC,$00F0,$00FF,$00FF,$3300,$0F00,$FF00,$FF00
        dc.w    $0000,$0000,$0000,$0000,$0520,$0618,$07F8,$07F8
        dc.w    $012C,$021C,$03FC,$03FC,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $00EA,$00FF,$00FF,$00FF,$92C0,$0EC0,$FEC0,$FEC0
        dc.w    $0006,$0007,$0007,$0007,$7D00,$8300,$FF00,$FF00
        dc.w    $0092,$00E1,$00FF,$00FF,$400F,$C00F,$C00F,$C00F
        dc.w    $E000,$E000,$E000,$E000,$FC00,$FC00,$FC00,$FC00
        dc.w    $008C,$00F0,$00FF,$00FF,$3300,$0F00,$FF00,$FF00
        dc.w    $0000,$0000,$0000,$0000,$0D20,$0E10,$0FF0,$0FF0
        dc.w    $012C,$021C,$03FC,$03FC,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0180,$01FF,$01FF,$01FF,$93E0,$0FE0,$FFE0,$FFE0
        dc.w    $0004,$0007,$0007,$0007,$CD80,$0380,$FF80,$FF80
        dc.w    $0092,$00E1,$00FF,$00FF,$4007,$C007,$C007,$C007
        dc.w    $8003,$8003,$8003,$8003,$0780,$FF80,$FF80,$FF80
        dc.w    $018C,$01F0,$01FF,$01FF,$3100,$0F00,$FF00,$FF00
        dc.w    $0000,$0000,$0000,$0000,$0D20,$0E10,$0FF0,$0FF0
        dc.w    $012C,$021C,$03FC,$03FC,$00FF,$00FF,$00FF,$00FF
        dc.w    $8000,$8000,$8000,$8000,$0000,$0000,$0000,$0000
        dc.w    $013F,$01C0,$01FF,$01FF,$BFB0,$0070,$FFF0,$FFF0
        dc.w    $0004,$0007,$0007,$0007,$C680,$0180,$FF80,$FF80
        dc.w    $0092,$00E1,$00FF,$00FF,$4000,$C000,$C000,$C000
        dc.w    $0006,$0007,$0007,$0007,$0060,$FFE0,$FFE0,$FFE0
        dc.w    $019C,$01E0,$01FF,$01FF,$3100,$0F00,$FF00,$FF00
        dc.w    $0000,$0000,$0000,$0000,$1D20,$1E10,$1FF0,$1FF0
        dc.w    $012C,$021C,$03FC,$03FC,$07C7,$07FF,$07FF,$07FF
        dc.w    $E000,$E000,$E000,$E000,$0001,$0001,$0001,$0001
        dc.w    $E121,$E1C0,$E1FF,$E1FF,$B090,$0070,$FFF0,$FFF0
        dc.w    $0006,$0007,$0007,$0007,$6680,$8180,$FF80,$FF80
        dc.w    $0096,$00E1,$00FF,$00FF,$401F,$C01F,$C01F,$C01F
        dc.w    $0004,$0007,$0007,$0007,$7F30,$80F0,$FFF0,$FFF0
        dc.w    $019C,$01E0,$01FF,$01FF,$3100,$0F00,$FF00,$FF00
        dc.w    $0000,$0000,$0000,$0000,$1F20,$1810,$1FF0,$1FF0
        dc.w    $0168,$0618,$07F8,$07F8,$1C00,$1FFF,$1FFF,$1FFF
        dc.w    $F000,$F000,$F000,$F000,$7FFB,$7FFB,$7FFB,$7FFB
        dc.w    $21B0,$E1C0,$E1FF,$E1FF,$0190,$0070,$FFF0,$FFF0
        dc.w    $0002,$0003,$0003,$0003,$6483,$8383,$FF83,$FF83
        dc.w    $FD94,$FDE3,$FDFF,$FDFF,$C031,$C03F,$C03F,$C03F
        dc.w    $800C,$800F,$800F,$800F,$80C8,$0038,$FFF8,$FFF8
        dc.w    $0198,$01E0,$01FF,$01FF,$2300,$1F00,$FF00,$FF00
        dc.w    $0000,$0000,$0000,$0000,$2C20,$3018,$3FF8,$3FF8
        dc.w    $00C8,$1E38,$1FF8,$1FF8,$38FF,$3F00,$3FFF,$3FFF
        dc.w    $3001,$F001,$F001,$F001,$E00E,$FFFF,$FFFF,$FFFF
        dc.w    $30DC,$F0E0,$F0FF,$F0FF,$1F30,$00F0,$FFF0,$FFF0
        dc.w    $0003,$0003,$0003,$0003,$2D8E,$C38F,$FF8F,$FF8F
        dc.w    $0734,$FFC3,$FFFF,$FFFF,$C060,$C07F,$C07F,$C07F
        dc.w    $C009,$C00E,$C00F,$C00F,$3E64,$001C,$FFFC,$FFFC
        dc.w    $0118,$01E0,$01FF,$01FF,$6200,$1E00,$FE00,$FE00
        dc.w    $0000,$0000,$0000,$0000,$69D0,$700F,$7FFF,$7FFF
        dc.w    $0698,$F878,$FFF8,$FFF8,$7301,$7C00,$7FFF,$7FFF
        dc.w    $9807,$7807,$F807,$F807,$0F86,$F07F,$FFFF,$FFFF
        dc.w    $D06F,$3070,$F07F,$F07F,$7030,$0FF0,$FFF0,$FFF0
        dc.w    $0001,$0001,$0001,$0001,$A918,$C71F,$FF1F,$FF1F
        dc.w    $0024,$FFC3,$FFFF,$FFFF,$C04E,$C071,$C07F,$C07F
        dc.w    $4009,$C00E,$C00F,$C00F,$63B2,$1C0E,$FFFE,$FFFE
        dc.w    $0118,$01E0,$01FF,$01FF,$6200,$1E00,$FE00,$FE00
        dc.w    $0000,$0000,$0000,$0000,$4F4F,$7080,$7FFF,$7FFF
        dc.w    $F1B0,$0070,$FFF0,$FFF0,$E8FE,$F000,$FFFF,$FFFF
        dc.w    $D80C,$380F,$F80F,$F80F,$70F1,$800E,$FFFF,$FFFF
        dc.w    $D033,$303C,$F03F,$F03F,$40E0,$3FE0,$FFE0,$FFE0
        dc.w    $0000,$0000,$0000,$0000,$9B30,$C73F,$FF3F,$FF3F
        dc.w    $7F24,$80C3,$FFFF,$FFFF,$C05B,$C060,$C07F,$C07F
        dc.w    $4009,$C00E,$C00F,$C00F,$6CC2,$1F0E,$FFFE,$FFFE
        dc.w    $0118,$01E0,$01FF,$01FF,$C600,$3E00,$FE00,$FE00
        dc.w    $0000,$0000,$0000,$0000,$9DE0,$E200,$FFFF,$FFFF
        dc.w    $0760,$00E0,$FFE0,$FFE0,$9903,$E0FC,$FFFF,$FFFF
        dc.w    $5808,$380F,$F80F,$F80F,$C01F,$0000,$FFFF,$FFFF
        dc.w    $B00B,$700C,$F00F,$F00F,$5F80,$3F80,$FF80,$FF80
        dc.w    $0000,$0000,$0000,$0000,$5667,$8E78,$FE7F,$FE7F
        dc.w    $81CC,$0003,$FFFF,$FFFF,$C0D3,$C0E0,$C0FF,$C0FF
        dc.w    $4009,$C00E,$C00F,$C00F,$5232,$33CE,$F3FE,$F3FE
        dc.w    $0318,$03E0,$03FF,$03FF,$C400,$3C00,$FC00,$FC00
        dc.w    $0000,$0000,$0000,$0000,$9370,$E080,$FFFF,$FFFF
        dc.w    $39C1,$07C1,$FFC1,$FFC1,$9601,$E18E,$FF8F,$FF8F
        dc.w    $6811,$181E,$F81F,$F81F,$9FEF,$0000,$FFFF,$FFFF
        dc.w    $A00A,$600C,$E00F,$E00F,$B000,$7000,$F000,$F000
        dc.w    $0001,$0001,$0001,$0001,$2CCC,$9CF0,$FCFF,$FCFF
        dc.w    $3F68,$0007,$FFFF,$FFFF,$8093,$80E0,$80FF,$80FF
        dc.w    $4009,$C00E,$C00F,$C00F,$6986,$19FE,$F9FE,$F9FE
        dc.w    $0318,$03E0,$03FF,$03FF,$CC00,$3C00,$FC00,$FC00
        dc.w    $0000,$0000,$0000,$0000,$A34F,$C0B0,$FFFF,$FFFF
        dc.w    $CF01,$3F01,$FF01,$FF01,$3400,$C307,$FF07,$FF07
        dc.w    $AC13,$1C1C,$FC1F,$FC1F,$3076,$0F81,$FFFF,$FFFF
        dc.w    $201A,$E01C,$E01F,$E01F,$A000,$6000,$E000,$E000
        dc.w    $0002,$0003,$0003,$0003,$989B,$78E0,$F8FF,$F8FF
        dc.w    $A189,$5E07,$FFFF,$FFFF,$8096,$80E1,$80FF,$80FF
        dc.w    $4004,$C007,$C007,$C007,$B67C,$0E7C,$FE7C,$FE7C
        dc.w    $0330,$03C0,$03FF,$03FF,$8C00,$7C00,$FC00,$FC00
        dc.w    $0001,$0001,$0001,$0001,$A648,$C1B7,$FFFF,$FFFF
        dc.w    $3801,$F801,$F801,$F801,$2400,$C303,$FF03,$FF03
        dc.w    $AC36,$1C38,$FC3F,$FC3F,$6013,$1FE0,$FFFF,$FFFF
        dc.w    $6016,$E018,$E01F,$E01F,$A000,$6000,$E000,$E000
        dc.w    $0004,$0007,$0007,$0007,$6192,$E1E1,$E1FF,$E1FF
        dc.w    $00C9,$FF07,$FFFF,$FFFF,$80B4,$80C3,$80FF,$80FF
        dc.w    $4004,$C007,$C007,$C007,$1980,$8780,$FF80,$FF80
        dc.w    $0231,$03C0,$03FF,$03FF,$9800,$7800,$F800,$F800
        dc.w    $0001,$0001,$0001,$0001,$AEF8,$C107,$FFFF,$FFFF
        dc.w    $3C03,$FC03,$FC03,$FC03,$6C00,$8301,$FF01,$FF01
        dc.w    $AC24,$1C38,$FC3F,$FC3F,$C01D,$3FE0,$FFFF,$FFFF
        dc.w    $4014,$C018,$C01F,$C01F,$A000,$6000,$E000,$E000
        dc.w    $0009,$000F,$000F,$000F,$8136,$81C1,$81FF,$81FF
        dc.w    $0049,$CF87,$CFFF,$CFFF,$80A4,$80C3,$80FF,$80FF
        dc.w    $C003,$C003,$C003,$C003,$6CC0,$83C0,$FFC0,$FFC0
        dc.w    $0631,$07C0,$07FF,$07FF,$B800,$7800,$F800,$F800
        dc.w    $0001,$0001,$0001,$0001,$ADBF,$C240,$FFFF,$FFFF
        dc.w    $8606,$7E07,$FE07,$FE07,$4C00,$8381,$FF81,$FF81
        dc.w    $AC2D,$1C30,$FC3F,$FC3F,$800D,$71F0,$F1FF,$F1FF
        dc.w    $6015,$E018,$E01F,$E01F,$A000,$6000,$E000,$E000
        dc.w    $000E,$000E,$000E,$000E,$012C,$01C3,$01FF,$01FF
        dc.w    $0009,$03C7,$03FF,$03FF,$80A4,$80C3,$80FF,$80FF
        dc.w    $8000,$8000,$8000,$8000,$B760,$C0E0,$FFE0,$FFE0
        dc.w    $0673,$0780,$07FF,$07FF,$3000,$F000,$F000,$F000
        dc.w    $0001,$0001,$0001,$0001,$4D80,$8200,$FFFF,$FFFF
        dc.w    $E306,$1F07,$FF07,$FF07,$C200,$01F1,$FFF1,$FFF1
        dc.w    $AC69,$1C70,$FC7F,$FC7F,$800D,$6030,$E03F,$E03F
        dc.w    $2035,$E038,$E03F,$E03F,$2000,$E000,$E000,$E000
        dc.w    $0000,$0000,$0000,$0000,$0168,$0186,$01FE,$01FE
        dc.w    $0028,$01C7,$01FF,$01FF,$81A9,$81C7,$81FF,$81FF
        dc.w    $8000,$8000,$8000,$8000,$F120,$E0E0,$FFE0,$FFE0
        dc.w    $0666,$0781,$07FF,$07FF,$6000,$E000,$E000,$E000
        dc.w    $0003,$0003,$0003,$0003,$7A7F,$8400,$FFFF,$FFFF
        dc.w    $3186,$0F87,$FF87,$FF87,$9C80,$007F,$FFFF,$FFFF
        dc.w    $A869,$1870,$F87F,$F87F,$800D,$6010,$E01F,$E01F
        dc.w    $2025,$E038,$E03F,$E03F,$6000,$E000,$E000,$E000
        dc.w    $0000,$0000,$0000,$0000,$0348,$0386,$03FE,$03FE
        dc.w    $0028,$01C7,$01FF,$01FF,$81A9,$81C7,$81FF,$81FF
        dc.w    $0000,$0000,$0000,$0000,$2590,$3870,$3FF0,$3FF0
        dc.w    $04E4,$0703,$07FF,$07FF,$C000,$C000,$C000,$C000
        dc.w    $0002,$0003,$0003,$0003,$5B81,$807E,$FFFF,$FFFF
        dc.w    $9186,$0F87,$FF87,$FF87,$A77F,$1800,$FFFF,$FFFF
        dc.w    $2849,$1870,$F87F,$F87F,$0005,$C018,$C01F,$C01F
        dc.w    $A025,$6038,$E03F,$E03F,$6000,$E000,$E000,$E000
        dc.w    $0000,$0000,$0000,$0000,$0248,$0384,$03FC,$03FC
        dc.w    $0024,$00C3,$00FF,$00FF,$81E9,$8187,$81FF,$81FF
        dc.w    $0000,$0000,$0000,$0000,$12D0,$1C30,$1FF0,$1FF0
        dc.w    $04FD,$0703,$07FF,$07FF,$8000,$8000,$8000,$8000
        dc.w    $0006,$0007,$0007,$0007,$45FC,$83FF,$FFFF,$FFFF
        dc.w    $D886,$0787,$FF87,$FF87,$A180,$1E00,$FFFF,$FFFF
        dc.w    $5849,$3870,$F87F,$F87F,$0004,$C018,$C01F,$C01F
        dc.w    $A025,$6038,$E03F,$E03F,$2000,$E000,$E000,$E000
        dc.w    $0000,$0000,$0000,$0000,$0258,$0384,$03FC,$03FC
        dc.w    $0024,$00C3,$00FF,$00FF,$81CB,$8187,$81FF,$81FF
        dc.w    $0000,$0000,$0000,$0000,$1A50,$1C30,$1FF0,$1FF0
        dc.w    $067B,$0787,$07FF,$07FF,$0000,$0000,$0000,$0000
        dc.w    $0004,$0007,$0007,$0007,$4B06,$8707,$FF07,$FF07
        dc.w    $4886,$8787,$FF87,$FF87,$AEE1,$1F00,$FFFF,$FFFF
        dc.w    $B049,$7070,$F07F,$F07F,$8004,$4018,$C01F,$C01F
        dc.w    $A025,$6038,$E03F,$E03F,$A3C0,$63C0,$E3C0,$E3C0
        dc.w    $0000,$0000,$0000,$0000,$0250,$038C,$03FC,$03FC
        dc.w    $0024,$00C3,$00FF,$00FF,$815A,$8186,$81FE,$81FE
        dc.w    $007C,$007C,$007C,$007C,$1A50,$1C30,$1FF0,$1FF0
        dc.w    $0302,$03FE,$03FE,$03FE,$0000,$0000,$0000,$0000
        dc.w    $000C,$000F,$000F,$000F,$D603,$0E03,$FE03,$FE03
        dc.w    $6884,$8787,$FF87,$FF87,$ABBE,$1BC1,$FBFF,$FBFF
        dc.w    $6049,$E070,$E07F,$E07F,$8004,$6018,$E01F,$E01F
        dc.w    $A025,$6038,$E03F,$E03F,$A660,$67E0,$E7E0,$E7E0
        dc.w    $0000,$0000,$0000,$0000,$0250,$038C,$03FC,$03FC
        dc.w    $0024,$00C3,$00FF,$00FF,$835A,$8386,$83FE,$83FE
        dc.w    $F0C6,$F0FE,$F0FE,$F0FE,$1250,$1C30,$1FF0,$1FF0
        dc.w    $01F8,$01F8,$01F8,$01F8,$0000,$0000,$0000,$0000
        dc.w    $0019,$001E,$001F,$001F,$B403,$0C03,$FC03,$FC03
        dc.w    $2C84,$C387,$FF87,$FF87,$A8C1,$18FF,$F8FF,$F8FF
        dc.w    $F86C,$F870,$F87F,$F87F,$800C,$6030,$E03F,$E03F
        dc.w    $A024,$6038,$E03F,$E03F,$BC30,$7FF0,$FFF0,$FFF0
        dc.w    $0000,$0000,$0000,$0000,$0258,$0384,$03FC,$03FC
        dc.w    $0024,$01C3,$01FF,$01FF,$C353,$C38F,$C3FF,$C3FF
        dc.w    $9982,$F9FE,$F9FE,$F9FE,$32D0,$3C30,$3FF0,$3FF0
        dc.w    $0600,$0600,$0600,$0600,$0000,$0000,$0000,$0000
        dc.w    $0037,$0038,$003F,$003F,$2403,$1C03,$FC03,$FC03
        dc.w    $2D84,$C387,$FF87,$FF87,$AC7F,$1C7F,$FC7F,$FC7F
        dc.w    $442C,$7C30,$7C3F,$7C3F,$C00C,$3070,$F07F,$F07F
        dc.w    $A024,$6038,$E03F,$E03F,$99D0,$7E30,$FFF0,$FFF0
        dc.w    $0000,$0000,$0000,$0000,$0268,$0386,$03FE,$03FE
        dc.w    $0024,$01C3,$01FF,$01FF,$42D0,$C30F,$C3FF,$C3FF
        dc.w    $E539,$1DC7,$FDFF,$FDFF,$E490,$F870,$FFF0,$FFF0
        dc.w    $0980,$0F80,$0F80,$0F80,$0000,$0000,$0000,$0000
        dc.w    $002E,$0030,$003F,$003F,$6C03,$1C03,$FC03,$FC03
        dc.w    $6D84,$8387,$FF87,$FF87,$9400,$0C00,$FC00,$FC00
        dc.w    $DE36,$E638,$FE3F,$FE3F,$401C,$3FE0,$FFFF,$FFFF
        dc.w    $A034,$6038,$E03F,$E03F,$C350,$3C30,$FFF0,$FFF0
        dc.w    $0000,$0000,$0000,$0000,$022C,$03C3,$03FF,$03FF
        dc.w    $0044,$8783,$87FF,$87FF,$62C9,$E306,$E3FF,$E3FF
        dc.w    $B52C,$0DC3,$FDFF,$FDFF,$09A0,$F060,$FFE0,$FFE0
        dc.w    $1340,$1CC0,$1FC0,$1FC0,$0000,$0000,$0000,$0000
        dc.w    $006C,$0070,$007F,$007F,$4E07,$3E07,$FE07,$FE07
        dc.w    $4D06,$8307,$FF07,$FF07,$5701,$8F01,$FF01,$FF01
        dc.w    $FA13,$861C,$FE1F,$FE1F,$60F1,$1F00,$FFFF,$FFFF
        dc.w    $3016,$F018,$F01F,$F01F,$6650,$1830,$FFF0,$FFF0
        dc.w    $0000,$0000,$0000,$0000,$0326,$03C1,$03FF,$03FF
        dc.w    $00D4,$FF03,$FFFF,$FFFF,$23CF,$E300,$E3FF,$E3FF
        dc.w    $15B7,$0DC0,$FDFF,$FDFF,$FB20,$00E0,$FFE0,$FFE0
        dc.w    $35E0,$3860,$3FE0,$3FE0,$0000,$0000,$0000,$0000
        dc.w    $00CC,$00F0,$00FF,$00FF,$C78E,$3F8F,$FF8F,$FF8F
        dc.w    $DD02,$0303,$FF03,$FF03,$4983,$8783,$FF83,$FF83
        dc.w    $4A11,$861E,$FE1F,$FE1F,$BF81,$0000,$FFFF,$FFFF
        dc.w    $1013,$F01C,$F01F,$F01F,$3CD0,$0030,$FFF0,$FFF0
        dc.w    $0000,$0000,$0000,$0000,$0133,$01C0,$01FF,$01FF
        dc.w    $9F36,$6001,$FFFF,$FFFF,$2370,$E380,$E3FF,$E3FF
        dc.w    $3490,$0CE0,$FCFF,$FCFF,$0EC0,$01C0,$FFC0,$FFC0
        dc.w    $28A0,$3060,$3FE0,$3FE0,$0000,$0000,$0000,$0000
        dc.w    $008C,$00F0,$00FF,$00FF,$61F9,$1FFE,$FFFF,$FFFF
        dc.w    $B303,$0F03,$FF03,$FF03,$64FE,$83FF,$FFFF,$FFFF
        dc.w    $BA08,$060F,$FE0F,$FE0F,$8E18,$0000,$FFFF,$FFFF
        dc.w    $9009,$700E,$F00F,$F00F,$83B0,$0070,$FFF0,$FFF0
        dc.w    $0000,$0000,$0000,$0000,$0198,$01E0,$01FF,$01FF
        dc.w    $70F6,$0001,$FFFF,$FFFF,$2130,$E1C0,$E1FF,$E1FF
        dc.w    $64DE,$1CE0,$FCFF,$FCFF,$3980,$0780,$FF80,$FF80
        dc.w    $29A0,$3060,$3FE0,$3FE0,$0000,$0000,$0000,$0000
        dc.w    $008E,$00F0,$00FF,$00FF,$3C03,$03FC,$FFFF,$FFFF
        dc.w    $6601,$1E01,$FE01,$FE01,$3382,$C07C,$FFFF,$FFFF
        dc.w    $E40C,$1C0F,$FC0F,$FC0F,$E0FC,$0000,$FFFF,$FFFF
        dc.w    $500C,$300F,$F00F,$F00F,$FE60,$01E0,$FFE0,$FFE0
        dc.w    $0000,$0000,$0000,$0000,$00CE,$00F0,$00FF,$00FF
        dc.w    $071B,$00E0,$FFFF,$FFFF,$219F,$E1E0,$E1FF,$E1FF
        dc.w    $C867,$3878,$F87F,$F87F,$E600,$1E00,$FE00,$FE00
        dc.w    $2760,$38E0,$3FE0,$3FE0,$0000,$0000,$0000,$0000
        dc.w    $00C3,$00FC,$00FF,$00FF,$87FE,$0000,$FFFF,$FFFF
        dc.w    $6C01,$1C01,$FC01,$FC01,$987C,$E000,$FFFF,$FFFF
        dc.w    $0C04,$FC07,$FC07,$FC07,$3FE6,$C018,$FFFF,$FFFF
        dc.w    $5006,$3007,$F007,$F007,$01C0,$FFC0,$FFC0,$FFC0
        dc.w    $0000,$0000,$0000,$0000,$0063,$007C,$007F,$007F
        dc.w    $FCC9,$03F0,$FFFF,$FFFF,$20C0,$E0FF,$E0FF,$E0FF
        dc.w    $183C,$F83F,$F83F,$F83F,$1800,$F800,$F800,$F800
        dc.w    $3040,$3FC0,$3FC0,$3FC0,$0000,$0000,$0000,$0000
        dc.w    $0070,$007F,$007F,$007F,$E031,$0000,$FFFF,$FFFF
        dc.w    $D800,$3800,$F800,$F800,$C703,$F800,$FFFF,$FFFF
        dc.w    $B803,$7803,$F803,$F803,$0033,$FFFC,$FFFF,$FFFF
        dc.w    $D003,$3003,$F003,$F003,$0700,$FF00,$FF00,$FF00
        dc.w    $0000,$0000,$0000,$0000,$003C,$003F,$003F,$003F
        dc.w    $01CF,$FFF0,$FFFF,$FFFF,$607F,$E07F,$E07F,$E07F
        dc.w    $F007,$F007,$F007,$F007,$E000,$E000,$E000,$E000
        dc.w    $1F80,$1F80,$1F80,$1F80,$0000,$0000,$0000,$0000
        dc.w    $001F,$001F,$001F,$001F,$BF07,$C000,$FFFF,$FFFF
        dc.w    $6000,$E000,$E000,$E000,$707E,$7F81,$7FFF,$7FFF
        dc.w    $6001,$E001,$E001,$E001,$C078,$FFFF,$FFFF,$FFFF
        dc.w    $3000,$F000,$F000,$F000,$FC00,$FC00,$FC00,$FC00
        dc.w    $0000,$0000,$0000,$0000,$0007,$0007,$0007,$0007
        dc.w    $FF60,$FF7F,$FF7F,$FF7F,$C000,$C000,$C000,$C000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$FDFF,$FE03,$FFFF,$FFFF
        dc.w    $8000,$8000,$8000,$8000,$1E07,$1FFF,$1FFF,$1FFF
        dc.w    $C000,$C000,$C000,$C000,$7FCC,$7FCF,$7FCF,$7FCF
        dc.w    $6000,$E000,$E000,$E000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $003F,$003F,$003F,$003F,$8000,$8000,$8000,$8000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$07F8,$07F8,$07F8,$07F8
        dc.w    $0000,$0000,$0000,$0000,$03FC,$03FC,$03FC,$03FC
        dc.w    $0000,$0000,$0000,$0000,$0007,$0007,$0007,$0007
        dc.w    $C000,$C000,$C000,$C000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

Background3:
; 3d pixs 1c scanlines
        dc.w    $003F,$003F,$003F,$003F,$FC00,$FC00,$FC00,$FC00
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $07C0,$07FF,$07FF,$07FF,$3E03,$C603,$FE03,$FE03
        dc.w    $FE00,$FE00,$FE00,$FE00,$E300,$FF00,$FF00,$FF00
        dc.w    $183F,$1FC0,$1FFF,$1FFF,$FF0F,$030F,$FF0F,$FF0F
        dc.w    $8301,$FF01,$FF01,$FF01,$8CC0,$F3C0,$FFC0,$FFC0
        dc.w    $43C0,$7C00,$7FFF,$7FFF,$071C,$031F,$FF1F,$FF1F
        dc.w    $3B01,$C701,$FF01,$FF01,$40A0,$8060,$FFE0,$FFE0
        dc.w    $9C17,$E000,$FFFF,$FFFF,$F333,$0F3C,$FF3F,$FF3F
        dc.w    $E102,$0703,$FF03,$FF03,$91B0,$2E30,$FFF0,$FFF0
        dc.w    $A1F4,$C003,$FFFF,$FFFF,$067E,$FE70,$FE7F,$FE7F
        dc.w    $0103,$0F02,$FF03,$FF03,$DF90,$3F30,$FFF0,$FFF0
        dc.w    $9815,$C7E3,$FFFF,$FFFF,$F849,$F870,$F87F,$F87F
        dc.w    $F701,$0F02,$FF03,$FF03,$7148,$3198,$F1F8,$F1F8
        dc.w    $A3D5,$DFE3,$FFFF,$FFFF,$00B6,$00C1,$00FF,$00FF
        dc.w    $0705,$FF06,$FF07,$FF07,$6088,$20D8,$E0F8,$E0F8
        dc.w    $8ED5,$FEE3,$FEFF,$FEFF,$0129,$01C7,$01FF,$01FF
        dc.w    $FE05,$FE06,$FE07,$FE07,$6088,$20D8,$E0F8,$E0F8
        dc.w    $7815,$7863,$787F,$787F,$024F,$0387,$03FF,$03FF
        dc.w    $F005,$F006,$F007,$F007,$2098,$60C8,$E0F8,$E0F8
        dc.w    $0056,$0062,$007E,$007E,$024C,$039C,$03FC,$03FC
        dc.w    $0006,$0004,$0007,$0007,$A158,$6188,$E1F8,$E1F8
        dc.w    $0046,$0062,$007E,$007E,$06F8,$0718,$07F8,$07F8
        dc.w    $000A,$000C,$000F,$000F,$B328,$7398,$F3F8,$F3F8
        dc.w    $00EA,$00C6,$00FE,$00FE,$0698,$0738,$07F8,$07F8
        dc.w    $000A,$000C,$000F,$000F,$BDD0,$7E30,$FFF0,$FFF0
        dc.w    $00AA,$00C6,$00FE,$00FE,$04D0,$0730,$07F0,$07F0
        dc.w    $000A,$000C,$000F,$000F,$8E60,$71E0,$FFE0,$FFE0
        dc.w    $00AA,$00C6,$00FE,$00FE,$0D50,$0E30,$0FF0,$0FF0
        dc.w    $0014,$0018,$001F,$001F,$0380,$0180,$FF80,$FF80
        dc.w    $00CA,$0086,$00FE,$00FE,$0D50,$0E30,$0FF0,$0FF0
        dc.w    $0015,$0018,$001F,$001F,$C080,$3980,$FF80,$FF80
        dc.w    $014A,$0186,$01FE,$01FE,$0D50,$0E30,$0FF0,$0FF0
        dc.w    $0015,$0018,$001F,$001F,$7140,$FCC0,$FFC0,$FFC0
        dc.w    $0156,$018E,$01FE,$01FE,$0D50,$0E30,$0FF0,$0FF0
        dc.w    $003A,$0031,$003F,$003F,$D8E0,$DE60,$DFE0,$DFE0
        dc.w    $0226,$039E,$03FE,$03FE,$0D18,$0E38,$0FF8,$0FF8
        dc.w    $3E2B,$3E31,$3E3F,$3E3F,$86A0,$8760,$87E0,$87E0
        dc.w    $02A4,$031C,$03FC,$03FC,$0DBC,$0E1C,$0FFC,$0FFC
        dc.w    $772A,$7F31,$7F3F,$7F3F,$8250,$8330,$83F0,$83F0
        dc.w    $06AC,$071C,$07FC,$07FC,$0D87,$0E3F,$0FFF,$0FFF
        dc.w    $C928,$F733,$FF3F,$FF3F,$0250,$0330,$03F0,$03F0
        dc.w    $0D2C,$0E1C,$0FFC,$0FFC,$0C91,$0F0F,$0FFF,$0FFF
        dc.w    $1541,$E373,$FF7F,$FF7F,$0290,$0330,$03F0,$03F0
        dc.w    $0868,$0E18,$0FF8,$0FF8,$0E44,$0F83,$0FFF,$0FFF
        dc.w    $6544,$8373,$FF7F,$FF7F,$8210,$83B0,$83F0,$83F0
        dc.w    $0A58,$0C38,$0FF8,$0FF8,$0671,$0780,$07FF,$07FF
        dc.w    $C964,$0773,$FF7F,$FF7F,$C4F0,$C730,$C7F0,$C7F0
        dc.w    $0BD0,$0C30,$0FF0,$0FF0,$031C,$03E0,$03FF,$03FF
        dc.w    $2238,$1E33,$FE3F,$FE3F,$3E20,$F060,$FFE0,$FFE0
        dc.w    $0830,$0FF0,$0FF0,$0FF0,$00C7,$00F8,$00FF,$00FF
        dc.w    $CE1E,$3E18,$FE1F,$FE1F,$01C0,$00C0,$FFC0,$FFC0
        dc.w    $07E0,$07E0,$07E0,$07E0,$0038,$003F,$003F,$003F
        dc.w    $1C0E,$FC0F,$FC0F,$FC0F,$7380,$8F80,$FF80,$FF80
        dc.w    $0000,$0000,$0000,$0000,$0007,$0007,$0007,$0007
        dc.w    $F001,$F001,$F001,$F001,$FE00,$FE00,$FE00,$FE00


Musix:          blk.l   2500,0
endvars:        dc.w    0
tab160:         equ     endvars
backs:          equ     tab160+800
coltab:         equ     backs+1600
blocks:         equ     coltab+1600
shiftedsprites: equ     blocks+64400
        
samplin:        equ     $50000

slackaddrtab:   equ     shiftedsprites+49152
slackaddrtab2:  equ     slackaddrtab+2080
endequs:        equ     slackaddrtab2+2080

endsamp:        equ     $d1000
emd:            equ     endsamp
emd2:           equ     $51000
endcomp:        equ     $100000














