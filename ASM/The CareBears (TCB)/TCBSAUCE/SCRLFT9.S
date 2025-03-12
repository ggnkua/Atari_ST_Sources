org     $8000
load    $80000

x:

        bra     main


intsamp:
        move.w  #$2700,sr
        moveq   #10,d0
setregs:
        move.b  d0,$ffff8800.w
        clr.b   $ffff8802.w
        dbf     d0,setregs
        clr.b   $ffff8800.w
        clr.b   $ffff8802.w
        move.b  #7,$ffff8800.w
        move.b  #$ff,$ffff8802.w
        lea     snd_out(pc),a3
        move.l  #samplin,a5
        lea     sampdat(pc),a0
        move.l  a0,getsampdpos
        move.l  (a0),d0
        add.l   #samplin,d0
        add.l   4(a0),d0
        move.l  d0,enddissamp
        lea     $fff8800,a4
        rts





;oldintsamp:
;       movea.l #samplin,a0
;       movea.l a0,a1
;       movea.l a0,a2
;       adda.l  #samplen,a0
;       adda.l  #samp6len,a1
;       movea.l #snd_out,a5
;oldomis1:
;       suba.l  #1,a0
;       suba.l  #6,a1
;       moveq.l #0,d0
;       move.b  (a0),d0
;       lsl.l   #3,d0
;       move.l  (a5,d0.w),d1
;       move.w  4(a5,d0.w),d2
;       move.l  d1,(a1)
;       move.w  d2,4(a1)
;       cmp.l   a2,a0
;       bgt     oldomis1



;       move.w  #$2700,sr
;       moveq   #10,d0
;oldsetregs:
;       move.b  d0,$fff8800
;       clr.b   $fff8802
;       dbf     d0,oldsetregs
;       clr.b   $fff8800
;       clr.b   $fff8802
;       move.b  #7,$fff8800
;       move.b  #$ff,$fff8802
;       movea.l #$ff8800,a4
;       movea.l #samplin,a5
;       move.l  #sampdat,d0
;       move.l  d0,getsampdpos
;       move.l  #samplin,d0
;       add.l   #112260,d0
;       move.l  d0,enddissamp
;       rts

sampdat:
        dc.l    0,14036,12
        dc.l    0,14036,12
        dc.l    14036,14065,12
        dc.l    14036,14065,12
        dc.l    0,14036,12
        dc.l    0,14036,12
        dc.l    14036,14065,12
        dc.l    14036,14065,12
        dc.l    0,14036,12
        dc.l    0,14036,12
        dc.l    14036,14065,12
        dc.l    14036,14065,12
        dc.l    28101,28289,12
        dc.l    28101,28289,12
        dc.l    28101,28289,-168




chksmp: movem.l a0-a1,-(sp)
        cmpa.l  enddissamp,a5
        bcs     forbivh1
        move.l  a5,a1
        move.l  getsampdpos,a0
        suba.l  enddissamp,a1
        adda.l  8(a0),a0
        move.l  a0,getsampdpos
        adda.l  (a0),a1
        adda.l  #samplin,a1
        move.l  a1,a5
        adda.l  4(a0),a1
        move.l  a1,enddissamp
forbivh1:
        movem.l (sp)+,a0-a1
        rts




oldchksmp:
        movem.l a0-a1,-(sp)
        cmpa.l  enddissamp,a5
        bcs     forbivh1
        move.l  a5,a1
        move.l  getsampdpos,a0
        sub.l   enddissamp,a1
        adda.l  8(a0),a0
        move.l  a0,getsampdpos
        adda.l  (a0),a1
        adda.l  #samplin,a1
        move.l  a1,a5
        adda.l  4(a0),a1
        move.l  a1,enddissamp
oldforbivh1:
        movem.l (sp)+,a0-a1
        rts




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

        



vsyn:   move.l  d0,-(sp)

        st      ready
        move.l  currpicadd,d0
        lsr.l   #8,d0
        move.b  d0,$ff8203
        lsr.l   #8,d0
        move.b  d0,$ff8201
        lea     coltab(pc),a6
        move.l  colpos,d0
        addq.l  #2,d0
        cmp.l   #168,d0
        blt     forbivs1
        moveq   #0,d0
forbivs1:
        move.l  d0,colpos
        adda.l  d0,a6
forbivs2:
        move.l  (sp)+,d0
        rts

vsync:  bsr     vsyn
        rte


slimpa: move.w  (a6),$ff8242
        move.w  (a6),$ff8246
        move.w  (a6),$ff824a
        move.w  (a6)+,$ff824e
        move.l  #slimpa2,$68
        movem.l d0-d1/a3,-(sp)
        moveq   #0,d0
        move.b  (a5)+,d0
        lsl.l   #3,d0
        lea     snd_out(pc),a3
        move.l  (a3,d0.w),d1
        move.w  4(a3,d0.w),d0
        movep.l d1,0(a4)
        movep.w d0,0(a4)
        movem.l (sp)+,d0-d1/a3
        rte




;sample: bclr   #5,$720f(a4)
;       move.l  d0,-(sp)
;       move.l  (a5)+,d0
;       movep.l d0,0(a4)
;       move.w  (a5)+,d0
;       movep.w d0,0(a4)
;       move.l  (sp)+,d0

;       rte


;slump: bclr    #5,$720f(a4)
;       rte
;       movem.l d0-d1/a3,-(sp)
;       moveq   #0,d0
;       lea     snd_out(pc),a3
;       move.b  (a5)+,d0
;       lsl.l   #3,d0
;       move.l  (a3,d0.w),d1
;       move.w  4(a3,d0.w),d0
;       movep.l d1,0(a4)
;       movep.w d0,0(a4)
;       movem.l (sp)+,d0-d1/a3
;       rte




slimpa2:        
        move.w  (a6),$ff8242
        move.w  (a6),$ff8246
        move.w  (a6),$ff824a
        move.w  (a6)+,$ff824e
        move.l  #slimpa,$68
        rte

setints:        
        move.w  #$2700,sr
;       move.l  $70,oldvs
;       move.l  $68,oldhs
        move.b  $fffa07,IEA
        move.b  $fffa09,IEB
;       move.b  $fffa19,TAC
;       move.b  $fffa1b,TBC
;       move.b  $fffa1f,TAD
;       move.b  $fffa21,TBD
;       move.b  $fffa13,IMA
;       move.b  $fffa15,IMB
;       move.l  $120,TBVEC
;       move.l  $134,TAVEC
        move.l  #vsync,$70
        move.w  #$2700,sr
;       move.b  #0,$fffa07
;       move.b  #0,$fffa09
        move.l  #coltab,a6
;       move.l  #hsync,-(sp)
;       move.w  #1,-(sp)
;       move.w  #8,-(sp)
;       move.w  #1,-(sp)
;       move.w  #31,-(sp)
;       trap    #14
;       add.l   #12,sp

;       move.l  #samp,-(sp)
;       move.w  #25,-(sp)
;       move.w  #2,-(sp)
;       move.w  #0,-(sp)
;       move.w  #31,-(sp)
;       trap    #14
;       add.l   #12,sp

        move.l  #slimpa,$68
        move.w  #$2100,sr




        rts

TAD:    dc.w    0
TBD:    dc.w    0
IEA:    dc.w    0
IMA:    dc.w    0
IEB:    dc.w    0
IMB:    dc.w    0
TAC:    dc.w    0
TBC:    dc.w    0
OLDVS:  dc.l    0
oldhs:  dc.l    0
TAVEC:  dc.l    0
TBVEC:  dc.l    0

retints:        
        move.w  #$2700,sr
;       move.b  TAD,$fffa1f
;       move.b  TBD,$fffa21
        move.b  IEA,$fffa07
        move.b  IEB,$fffa09
;       move.b  IMA,$fffa13
;       move.b  IMB,$fffa15
;       move.b  TAC,$fffa19
;       move.b  TBC,$fffa1b
;       move.l  OLDVS,$70
;       move.l  oldhs,$68
;       move.l  TAVEC,$134
;       move.l  TBVEC,$120
        move.w  #$2500,sr
        rts



scpostab:
        dc.l    0,1280,2560,3840

scrlin: move.l  newcharpos,d0
        move.l  d0,d1
        and.b   #3,d0
        move.l  d0,windnr
        and.w   #$fffc,d1
        lsr.l   #1,d1
        lsl.l   #2,d0

        lea     scpostab(pc),a3
        add.l   0(a3,d0.w),d1
        move.l  d1,a1
        move.l  d1,windpos
        


        tst.l   windnr
        bne     forbis4

        move.l  charpos,d0
        addq.l  #1,d0
        move.l  d0,d1
        lsr.l   #4,d1
        move.l  scrollbase,a0
        move.b  (a0,d1.l),d2
        cmp.b   #$55,d2
        bne     forbis3
        moveq   #0,d0
forbis3:        
        move.l  d0,charpos


forbis4:

        move.l  charpos,d0
        move.l  d0,d2
        and.l   #$f,d2
        lsr.l   #4,d0
        move.l  d0,a0

        adda.l  scrollbase,a0

        moveq   #0,d1
        move.b  (a0),d1
        eor.b   #$aa,d1
        lea     sasc(pc),a0

        move.b  (a0,d1.w),d1
        lsl.l   #4,d1

        add.l   d2,d1

        lsl.l   #1,d1
        move.l  d1,a0

        adda.l  #blocks,a1
        adda.l  #font,a0

        moveq   #14,d0
        move.l  windnr,d1
        lsl.l   #2,d1
        move.l  d1,d7

        move.w  (a0),d4
        lsr.w   #1,d4   
oms3:   
        btst    #0,d4
        beq     forbisc1
        move.l  #$ffff,d1
        bra     forbisc2
forbisc1:
        moveq   #0,d1
forbisc2:
        lsl.l   d7,d1
        move.w  d1,2(a1)
        move.w  d1,42(a1)
        swap    d1
        or.w    d1,(a1)
        or.w    d1,40(a1)

        
        lsr.w   #1,d4
        lea     80(a1),a1
        dbra    d0,oms3

        

        move.l  windpos,a0
        adda.l  #blocks,a0
        addq.l  #4,a0

        move.l  currpicadd,a1
        addq.l  #8,a1
        moveq   #14,d1
        lea     1920(a1),a1
omsc2:  moveq   #17,d2

omsc3:  move.w  (a0)+,d0
        move.w  d0,(a1)
        move.w  d0,160(a1)
        move.w  d0,320(a1)
        move.w  d0,480(a1)
        move.w  d0,640(a1)
        move.w  d0,800(a1)
        move.w  d0,960(a1)
        move.w  d0,1120(a1)
        move.w  d0,1280(a1)
        move.w  d0,1440(a1)
        move.w  d0,1600(a1)
        move.w  d0,1760(a1)
        addq.l  #8,a1
        dbra    d2,omsc3
        lea     1776(a1),a1
        lea     44(a0),a0
        dbra    d1,omsc2

        


        
        move.l  newcharpos,d0
        addq.l  #1,d0
        cmp     #80,d0
        blt     forbis2
        moveq   #0,d0
forbis2:        
        move.l  d0,newcharpos


        move.l  currpicadd,a0
        lea     640(a0),a0
        moveq   #0,d1
        moveq   #7,d0
omsc4:  move.w  d1,(a0)
        move.w  d1,8(a0)
        move.w  d1,16(a0)
        move.w  d1,24(a0)
        move.w  d1,32(a0)
        move.w  d1,40(a0)
        move.w  d1,48(a0)
        move.w  d1,56(a0)
        move.w  d1,64(a0)
        move.w  d1,72(a0)
        move.w  d1,80(a0)
        move.w  d1,88(a0)
        move.w  d1,96(a0)
        move.w  d1,104(a0)
        move.w  d1,112(a0)
        move.w  d1,120(a0)
        move.w  d1,128(a0)
        move.w  d1,136(a0)
        move.w  d1,144(a0)
        move.w  d1,152(a0)
        lea     160(a0),a0
        dbra    d0,omsc4        

        rts
        










fixnbr: btst    #15,d0
        beq     forbi1
        add.l   #400,d0
forbi1: rts

placepics:
        move.l  #emd,d0
        and.l   #$ffffff00,d0
        add.l   #$0,d0
        move.l  d0,picsadd
        lsr.l   #8,d0
        move.l  d0,picsbas256
        rts

makepic:
        move.l  #slinger,a0
        lea     pic(pc),a1
        moveq   #49,d0
ommp1:  movem.l (a0)+,d1-d7/a2

        movem.l d1-d7/a2,(a1)
        movem.l d1-d7/a2,32(a1)
        movem.l d1-d7/a2,64(a1)
        movem.l d1-d7/a2,96(a1)
        movem.l d1-d7/a2,128(a1)

        movem.l d1-d7/a2,8000(a1)
        movem.l d1-d7/a2,8032(a1)
        movem.l d1-d7/a2,8064(a1)
        movem.l d1-d7/a2,8096(a1)
        movem.l d1-d7/a2,8128(a1)

        movem.l d1-d7/a2,16000(a1)
        movem.l d1-d7/a2,16032(a1)
        movem.l d1-d7/a2,16064(a1)
        movem.l d1-d7/a2,16096(a1)
        movem.l d1-d7/a2,16128(a1)

        movem.l d1-d7/a2,24000(a1)
        movem.l d1-d7/a2,24032(a1)
        movem.l d1-d7/a2,24064(a1)
        movem.l d1-d7/a2,24096(a1)
        movem.l d1-d7/a2,24128(a1)

        adda.l  #160,a1
        dbra    d0,ommp1

        move.l  #vabust,a0
        move.l  #hobust,a1
        lea     pic(pc),a2
        moveq   #39,d0

ommp2:  movem.l (a0)+,d2-d5
        move.l  d2,d6
        move.l  d3,d7
        or.w    d2,d3
        swap    d2
        or.w    d3,d2
        swap    d3
        or.w    d2,d3
        not.w   d3
        moveq   #4,d1
ommp3:  and.w   d3,(a2)
        and.w   d3,2(a2)
        and.w   d3,4(a2)
        and.w   d3,6(a2)
        or.l    d6,(a2)
        or.l    d7,4(a2)
        lea     6400(a2),a2
        dbra    d1,ommp3
        suba.l  #32000,a2

        move.l  d4,d6
        move.l  d5,d7
        or.w    d4,d5
        swap    d4
        or.w    d5,d4
        swap    d5
        or.w    d4,d5
        not.w   d5
        moveq   #4,d1
ommp4:  and.w   d5,8(a2)
        and.w   d5,10(a2)
        and.w   d5,12(a2)
        and.w   d5,14(a2)
        or.l    d6,8(a2)
        or.l    d7,12(a2)
        lea     6400(a2),a2
        dbra    d1,ommp4
        suba.l  #32000,a2

        movem.l (a1)+,d2-d5
        move.l  d2,d6
        move.l  d3,d7
        or.w    d2,d3
        swap    d2
        or.w    d3,d2
        swap    d3
        or.w    d2,d3
        not.w   d3
        moveq   #4,d1
ommp5:  and.w   d3,144(a2)
        and.w   d3,146(a2)
        and.w   d3,148(a2)
        and.w   d3,150(a2)
        or.l    d6,144(a2)
        or.l    d7,148(a2)
        lea     6400(a2),a2
        dbra    d1,ommp5
        suba.l  #32000,a2

        move.l  d4,d6
        move.l  d5,d7
        or.w    d4,d5
        swap    d4
        or.w    d5,d4
        swap    d5
        or.w    d4,d5
        not.w   d5
        moveq   #4,d1
ommp6:  and.w   d5,152(a2)
        and.w   d5,154(a2)
        and.w   d5,156(a2)
        and.w   d5,158(a2)
        or.l    d6,152(a2)
        or.l    d7,156(a2)
        lea     6400(a2),a2
        dbra    d1,ommp6
        suba.l  #31840,a2
        dbra    d0,ommp2

        lea     pic(pc),a0
        lea     18912(a0),a0
        move.l  #tcb,a1
        moveq   #31,d0

ommp7:  movem.l (a1)+,d1-d7/a2
        movem.l d1-d7/a2,(a0)
        adda.l  #160,a0
        dbra    d0,ommp7

        lea     pic(pc),a0
        lea     20864(a0),a0
        move.l  #superscroller,a1
        moveq   #19,d0
ommp8:  movem.l (a1)+,d1-d7/a2
        movem.l d1-d7/a2,(a0)
        movem.l (a1)+,d1-d7/a2
        movem.l d1-d7/a2,32(a0)
        lea     160(a0),a0
        dbra    d0,ommp8

        lea     pic(pc),a0
        lea     48(a0),a0
        move.l  #the_union,a1
        moveq   #49,d0
ommp9:  movem.l (a1)+,d1-d7/a2
        movem.l d1-d7/a2,(a0)
        movem.l (a1)+,d1-d7/a2
        movem.l d1-d7/a2,32(a0)
        adda.l  #160,a0
        dbra    d0,ommp9

        lea     pic(pc),a0
        lea     8832(a0),a0
        move.l  #needs_no,a1
        moveq   #16,d0
ommp10: movem.l (a1)+,d1-d7/a2-a6
        movem.l d1-d7/a2-a6,(a0)
        movem.l (a1)+,d1-d7/a2-a6
        movem.l d1-d7/a2-a6,48(a0)
        adda.l  #160,a0
        dbra    d0,ommp10

        rts

tab125: dc.l    0,125,250,375

movpic: move.l  targpiclin,d0
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

        add.l   picsbas256,d1
        lsl.l   #8,d1
        move.l  d1,currpicadd
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
        lea     pic(pc),a0
        adda.l  sourceadd,a0

        move.l  targpicadd,d0
        add.l   #31040,d0
        move.l  picsadd,a1
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


;loadfil:       move.w  #0,-(sp)
;       move.l  d0,-(sp)
;       move.w  #$3d,-(sp)
;       trap    #1
;       addq.l  #8,sp
;       move.w  d0,handle
;       move.l  d1,-(sp)
;       move.l  d2,-(sp)
;       move.w  handle,-(sp)
;       move.w  #$3f,-(sp)
;       trap    #1
;       add.l   #12,sp
;       move.w  handle,-(sp)
;       move.w  #$3e,-(sp)
;       trap    #1
;       addq.l  #4,sp
;       rts

;loadfils:
;       move.l  #sampname,d0
;       move.l  #samplin,d1
;       move.l  #samplen,d2
;       jsr     loadfil
;       rts






;scrleft:
;       move.l  currpicadd,a1
;       adda.l  #31840,a1
;       move.l  oldbase,a0
;       adda.l  #31840,a0
;       move.l  currpicadd,oldbase
;       move.l  #199,d0
;omsl1: move.w  8(a0),(a1)
;       move.w  16(a0),8(a1)
;       move.w  24(a0),16(a1)
;       move.w  32(a0),24(a1)
;       move.w  40(a0),32(a1)
;       move.w  48(a0),40(a1)
;       move.w  56(a0),48(a1)
;       move.w  64(a0),56(a1)
;       move.w  72(a0),64(a1)
;       move.w  80(a0),72(a1)
;       move.w  88(a0),80(a1)
;       move.w  96(a0),88(a1)
;       move.w  104(a0),96(a1)
;       move.w  112(a0),104(a1)
;       move.w  120(a0),112(a1)
;       move.w  128(a0),120(a1)
;       move.w  136(a0),128(a1)
;       move.w  144(a0),136(a1)
;       move.w  152(a0),144(a1)
;       suba.l  #160,a0
;       suba.l  #160,a1
;       dbra    d0,omsl1
;       rts


makcoltab:
        lea     coltab(pc),a1
        move.l  #colpaltab,a0
        moveq   #0,d1
        move.w  #199,d0
ommct:  
        move.w  (a0,d1.w),d2
        move.w  d2,(a1)+
        move.w  d2,(a1)+
        addq.l  #2,d1
        cmp.l   #84,d1
        blt     forbimct1
        moveq   #0,d1
forbimct1:
        dbra    d0,ommct
        rts


;fillrgt:       move.l  charpos,d0
;       move.l  d0,d1
;       and.l   #15,d0
;       lsr.l   #4,d1
;       lea     textsc(pc),a0
;       moveq   #0,d3
;       move.b  (a0,d1.w),d3
;       lsl.l   #4,d3
;       add.l   d0,d3
;       lsl.l   #1,d3
;       lea     font(pc),a0
;       move.w  (a0,d3.w),d0
;       move.l  #11,d1
;       move.l  currpicadd,a0
;       lea     152(a0),a0
;omfr1: btst    #0,d0
;       beq     forbifr1
;       move.w  #$ffff,d2
;       jmp     forbifr2
;forbifr1:
;       moveq   #0,d2
;forbifr2:
;       move.w  d2,(a0)
;       move.w  d2,160(a0)
;       move.w  d2,320(a0)
;       move.w  d2,480(a0)
;       move.w  d2,640(a0)
;       move.w  d2,800(a0)
;       move.w  d2,960(a0)
;       move.w  d2,1120(a0)
;       move.w  d2,1280(a0)
;       move.w  d2,1440(a0)
;       move.w  d2,1600(a0)
;       move.w  d2,1760(a0)
;       move.w  d2,1920(a0)
;       move.w  d2,2080(a0)
;       move.w  d2,2240(a0)
;       move.w  d2,2400(a0)
;       adda.l  #2560,a0
;       lsr.w   #1,d0
;       dbra    d1,omfr1

;       move.l  charpos,d0
;       add.l   #1,d0
;       cmp.l   textlen,d0
;       blt     forbifr3
;       moveq   #0,d0
;forbifr3:
;       move.l  d0,charpos
;       rts


        

main:   
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





;       clr.l   -(sp)
;       move.w  #32,-(sp)
;       trap    #1
;       addq.l  #6,sp
;       move.l  d0,savstk
;       move.l  #textend,d0
;       sub.l   #textsc,d0
;       lsl.l   #4,d0
;       move.l  d0,textlen
        move.l  a0,d0
        sub.l   a1,d0
        lsl.l   #4,d0
        move.l  d0,charpos
        move.l  a1,scrollbase
        move.l  a2,keyadd



        jsr     placepics
;       jsr     loadfils
        jsr     makepic
        jsr     makcoltab

;       move.w  #4,-(sp)
;       trap    #14
;       addq.l  #2,sp
;       move.w  d0,oldres       

;       move.w  #2,-(sp)
;       trap    #14
;       addq.l  #2,sp
;       move.l  d0,oldphys

        

;       move.w  #0,-(sp)
;       move.l  #-1,-(sp)
;       move.l  #-1,-(sp)
;       move.w  #5,-(sp)
;       trap    #14
;       add.l   #12,sp

;       move.l  #spalette,a0
;       movem.l $ff8240,d0-d7
;       movem.l d0-d7,(a0)

        move.l  #palette1,a0
        lea     $ff8240,a1
        movem.l (a0),d0-d7
        movem.l d0-d7,(a1)
        
        move.l  #0,targpicadd
        move.l  #0,sourceadd
        move.l  #0,sourcelin
        move.l  #0,targpiclin
        move.l  #99,d0
omm2:   
        add.l   #320,targpicadd
        add.l   #320,sourceadd
        addq.l  #1,targpiclin
        addq.l  #1,sourcelin
        cmp.l   #400,targpiclin
        blt     forbimm1
        move.l  #0,targpiclin
        move.l  #0,targpicadd
forbimm1:
        cmp.l   #100,sourcelin
        blt     forbimm2
        move.l  #0,sourceadd
        move.l  #0,sourcelin
forbimm2:
        move.l  d0,-(sp)
        jsr     newlines
        move.l  (sp)+,d0
        dbra    d0,omm2         


        move.l  #1000,d1

        jsr     intsamp
        jsr     setints


om1:    jsr     chksmp
        add.l   #320,targpicadd
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
        jsr     chksmp
        jsr     newlines
        jsr     chksmp
        jsr     movpic
        jsr     chksmp
        jsr     scrlin
        jsr     chksmp


omw1:   tst.b   ready
        beq     omw1
        clr.b   ready
        move.l  keyadd,a0
        cmp.b   #57,(a0)
        beq     utm1
        jmp     om1
utm1:


        jsr     retints
        
;       move.l  #spalette,a0
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
        move.l  charpos,d0
        lsr.l   #4,d0
        add.l   scrollbase,d0
        move.l  d0,a0
        rts




coltab:         blk.l   200,0
keyadd:         dc.l    0
scrollbase:     dc.l    0

;textsc: 
;       DC.B    '   HI! CAN YOU READ THIS? NO? NEITHER CAN WE.'
;       DC.B    ' THE PROBLEM SEEMS TO BE THAT YOU DONœT REMEMBER'
;       DC.B    ' HOW THE WORDS STARTED WHEN YOU GET TO THE ENDS.'
;       DC.B    ' THATœS PROBABLY WHY WORDS LIKE œPROBABLYœ ARE SO'
;       DC.B    ' DIFFICULT TO READ. œDIFFICULTœ IS ALSO DIFFICULT'
;       DC.B    ' TO READ, COME TO THINK OF IT.'
;       DC.B    ' GETTING BORED? WELL, ME TOO. THEREœS NOTHING MORE'
;       DC.B    ' TO SAY, EXCEPT FOR THAT THE CAREBEARS ARE PROUD'
;       DC.B    ' TO WISH YOU A MERRY, MERRY CHRISTMAS....'
;       DC.B    ' (YES, WEœRE A BIT STRANGE) LETœS WRAP... '
;       even

;textend:       dc.l    0
;textlen:       dc.l    0



sasc:   dc.b    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        dc.b    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        dc.b    0,29, 0, 0, 0, 0, 0,45,42,41, 0, 0,27, 0,28, 0
        dc.b    31,32,33,34,35,36,37,38,39,40,44,43, 0, 0, 0,30
        dc.b    0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15
        dc.b    16,17,18,19,20,21,22,23,24,25,26, 0, 0, 0, 0, 0
        dc.b    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        dc.b    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        dc.b    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        dc.b    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,45, 0, 0, 0
        dc.b    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        dc.b    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        dc.b    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        dc.b    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        dc.b    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        dc.b    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        even

font:   


f :     dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



fa:     dc.w    %1111111100000000
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000

fb:     dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1111111100000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



fc:     dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1111111100000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000011110
        dc.w    %1111000000011110
        dc.w    %1111000000011110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



fd:     dc.w    %1111111100000000
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fe:     dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1111111100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



ff:     dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1111111100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



fg:     dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1111111100000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100011110
        dc.w    %1111111100011110
        dc.w    %1111111100011110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000




fh:     dc.w    %1111111100000000
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000001100000000
        dc.w    %0000001100000000
        dc.w    %0000001100000000
        dc.w    %0000001100000000
        dc.w    %0000001100000000
        dc.w    %0000001100000000
        dc.w    %0000001100000000
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



fi:     dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %1111111100000000
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fj:     dc.w    %1111100000000000
        dc.w    %1111100000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1111111100000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fk:     dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1111111100000000
        dc.w    %0000001110000000
        dc.w    %0000001111000000
        dc.w    %0000001101100000
        dc.w    %0000001100110000
        dc.w    %0000001100011000
        dc.w    %0000001100001100
        dc.w    %0000001100000110
        dc.w    %1111111100000010
        dc.w    %1111111100000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fl:     dc.w    %1111111100000000
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fm:     dc.w    %1111111100000000
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000110
        dc.w    %0000000000011000
        dc.w    %0000000001100000
        dc.w    %0000000110000000
        dc.w    %0000000001100000
        dc.w    %0000000000011000
        dc.w    %0000000000000110
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fn:     dc.w    %1111111100000000
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000001100
        dc.w    %0000000000011000
        dc.w    %0000000000110000
        dc.w    %0000000001100000
        dc.w    %0000000011000000
        dc.w    %0000000110000000
        dc.w    %0000001100000000
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



fo:     dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1111111100000110
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fp:     dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1111111100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001111111110
        dc.w    %0000001111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fq:     dc.w    %0111111111111110
        dc.w    %0111111111111110
        dc.w    %0111111100000110
        dc.w    %0110000000000110
        dc.w    %0110000000000110
        dc.w    %0110000000000110
        dc.w    %0110000000000110
        dc.w    %0110000000000110
        dc.w    %0110100000000110
        dc.w    %0111000000000110
        dc.w    %0111111111111110
        dc.w    %0111111111111110
        dc.w    %1000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



fr:     dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1111111100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001111111110
        dc.w    %0000001111111110
        dc.w    %1111111100000000
        dc.w    %1111111100000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



fs:     dc.w    %1100001111111110
        dc.w    %1100001111111110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1111111100001110
        dc.w    %1111111100001110
        dc.w    %1111111100001110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


ft:     dc.w    %0000000000011110
        dc.w    %0000000000011110
        dc.w    %0000000000000110
        dc.w    %0000000000000110
        dc.w    %1111111100000110
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000110
        dc.w    %0000000000000110
        dc.w    %0000000000000110
        dc.w    %0000000000011110
        dc.w    %0000000000011110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fu:     dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1111111100000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1100000000000000
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fv:     dc.w    %0000000000000110
        dc.w    %0000000000011110
        dc.w    %0000000001111000
        dc.w    %0000000111100000
        dc.w    %0000011110000000
        dc.w    %0001111000000000
        dc.w    %0111100000000000
        dc.w    %1110000000000000
        dc.w    %0111100000000000
        dc.w    %0001111000001110
        dc.w    %0000011111111110
        dc.w    %0000000111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fw:     dc.w    %0000000000001110
        dc.w    %0000000001110000
        dc.w    %0000001110000000
        dc.w    %0001110000000000
        dc.w    %1110000000000000
        dc.w    %0001110000001110
        dc.w    %0000001111111110
        dc.w    %0000001111111110
        dc.w    %0001110000000000
        dc.w    %1110000000001110
        dc.w    %0001111111111110
        dc.w    %0000001111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fx:     dc.w    %1111000000011110
        dc.w    %1111100000111110
        dc.w    %0000110001101110
        dc.w    %0000011011000000
        dc.w    %0000001110000000
        dc.w    %0000001110000000
        dc.w    %0000001110000000
        dc.w    %0000011011000000
        dc.w    %1110110001100000
        dc.w    %1111100000111110
        dc.w    %1111000000011110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fy:     dc.w    %0000000001111110
        dc.w    %0000000011111110
        dc.w    %0000000110000000
        dc.w    %0000001100000000
        dc.w    %1111111000000000
        dc.w    %1111110000000000
        dc.w    %1111111000000000
        dc.w    %0000001100000000
        dc.w    %0000000110001110
        dc.w    %0000000011111110
        dc.w    %0000000001111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



fz:     dc.w    %1110000000011110
        dc.w    %1111000000011110
        dc.w    %1101100000011110
        dc.w    %1100110100000110
        dc.w    %1100011100000110
        dc.w    %1100001100000110
        dc.w    %1100000110000110
        dc.w    %1100000111000110
        dc.w    %1100000101100110
        dc.w    %1111000000110110
        dc.w    %1111000000011110
        dc.w    %1111000000001110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fkomma: dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %1011100000000000
        dc.w    %0111100000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



fpunkt: dc.w    %0000000000000000
        dc.w    %1110000000000000
        dc.w    %1110000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fut:    dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %1110001111111110
        dc.w    %1110001111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


fft:    dc.w    %0000000000001110
        dc.w    %0000000000001110
        dc.w    %0000000000000110
        dc.w    %0000000000000110
        dc.w    %1110000000000110
        dc.w    %1110111100000110
        dc.w    %1110111100000110
        dc.w    %1110001100000110
        dc.w    %0000001100000110
        dc.w    %0000001100000110
        dc.w    %0000001111111110
        dc.w    %0000001111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



f0:     dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


f1:     dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000001000
        dc.w    %1111111100000100
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


f2:     dc.w    %1111111110000000
        dc.w    %1111111110001110
        dc.w    %1100001110001110
        dc.w    %1100000110001110
        dc.w    %1100000110000110
        dc.w    %1100000110000110
        dc.w    %1100000110000110
        dc.w    %1100000110000110
        dc.w    %1100000110000110
        dc.w    %1110000111111110
        dc.w    %1110000111111110
        dc.w    %1110000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


f3:     dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %1111000000011110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1111111100000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


f4:     dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000001110000000
        dc.w    %0000001111000000
        dc.w    %0000001101100000
        dc.w    %0000001100110000
        dc.w    %0000001100011000
        dc.w    %0000001100001100
        dc.w    %1111111100000110
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000001100000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


f5:     dc.w    %1111000000000000
        dc.w    %1111001111111110
        dc.w    %1100001111111110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1111111100000110
        dc.w    %1111111100000110
        dc.w    %1111111100000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000


f6:     dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1111111100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100011110
        dc.w    %1100001100011110
        dc.w    %1111111100000000
        dc.w    %1111111100000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



f7:     dc.w    %1100000000001110
        dc.w    %0110000000001110
        dc.w    %0011000000001110
        dc.w    %0001100000000110
        dc.w    %0000110000000110
        dc.w    %0000011000000110
        dc.w    %0000001100000110
        dc.w    %0000000110000110
        dc.w    %0000000011000110
        dc.w    %0000000001100110
        dc.w    %0000000000111110
        dc.w    %0000000000011110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



f8:     dc.w    %1111111100000000
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001111111110
        dc.w    %1100001111111110
        dc.w    %1111111100000000
        dc.w    %1111111100000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000




f9:     dc.w    %1111000000000000
        dc.w    %1111000000000000
        dc.w    %1100001111111110
        dc.w    %1100001111111110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1100001100000110
        dc.w    %1111111100000110
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000



fvp:    dc.w    %0000000000000000
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000

fhp:    dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %1111111111111110
        dc.w    %1111111111111110
        dc.w    %1100000000000110
        dc.w    %1100000000000110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000

fsk:    dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %1011100111000000
        dc.w    %0111100111000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000

fkolon: dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0011100011100000
        dc.w    %0011100011100000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000

fapo:   dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000101110
        dc.w    %0000000000011110
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000
        dc.w    %0000000000000000




blocks:         blk.l   1280,0
pic:            blk.l   8000,0


spalette:       blk.l   8,0
oldphys:        dc.l    0
oldres:         dc.w    0
scrbase:        dc.l    0
savstk:         dc.l    0
charpos:        dc.l    0
picsadd:        dc.l    0
targpicadd:     dc.l    0
targpiclin:     dc.l    0
sourceadd:      dc.l    0
sourcelin:      dc.l    0
oldbase:        dc.l    0
picsbas256:     dc.l    0
currpicadd:     dc.l    0
newcharpos:     dc.l    0
windnr:         dc.l    0
enddissamp:     dc.l    0
getsampdpos:    dc.l    0
windpos:        dc.l    0
handle:         dc.l    0
ready:          dc.l    0
colpos:         dc.l    0
sampname:       dc.b    'rata2.spl',0
                even

vabust:

        dc.w    $0000,$1d4c,$0303,$ffff,$0000,$90e0,$e000,$f9f0
        dc.w    $0000,$8526,$0341,$ffff,$0000,$2800,$f000,$f8e0
        dc.w    $0000,$4623,$0140,$ffff,$0000,$d000,$2000,$f800
        dc.w    $0000,$d370,$0000,$ffff,$0000,$6000,$0000,$f800
        dc.w    $0000,$6850,$8020,$ffff,$0000,$0000,$0000,$f000
        dc.w    $0000,$582c,$a010,$ffff,$0000,$6100,$0000,$f700
        dc.w    $0000,$345c,$c003,$ffff,$0000,$c280,$0100,$ef80
        dc.w    $0000,$9cb0,$6070,$ffff,$0000,$0500,$0000,$8f80
        dc.w    $0000,$78b6,$c078,$ffff,$0000,$0400,$0000,$0f80
        dc.w    $0000,$40ca,$f831,$ffff,$0000,$0204,$0000,$071c
        dc.w    $0000,$9475,$7803,$ffff,$0000,$000a,$8004,$803e
        dc.w    $0000,$ca06,$3001,$ffff,$0000,$8014,$0000,$c03e
        dc.w    $0000,$790b,$0000,$ffff,$0000,$4410,$8200,$ce3e
        dc.w    $0000,$074c,$0000,$ffff,$0000,$8a08,$0700,$df1c
        dc.w    $0000,$8fa7,$0000,$ffff,$0000,$0d00,$0200,$bf80
        dc.w    $0000,$18e0,$0700,$ffff,$0000,$1680,$0100,$3f80
        dc.w    $0000,$3253,$0f80,$ffff,$0000,$1900,$0000,$3f80
        dc.w    $0000,$3744,$0f83,$ffff,$0000,$8e00,$0000,$df00
        dc.w    $0000,$320b,$0f87,$ffff,$0000,$4080,$8040,$efc0
        dc.w    $0000,$980b,$0707,$ffff,$0000,$6140,$80e0,$f3e0
        dc.w    $0000,$8f0c,$0003,$ffff,$0000,$b1a0,$4040,$f7f0
        dc.w    $0000,$c087,$0000,$ffff,$0000,$52d0,$e020,$fff0
        dc.w    $0000,$4161,$8000,$ffff,$0000,$7320,$e000,$fff0
        dc.w    $0000,$99d1,$0000,$ffff,$0000,$b1c0,$4000,$fbe0
        dc.w    $0000,$25f4,$1800,$ffff,$0000,$e002,$0000,$f9ce
        dc.w    $0000,$5a5a,$3ca0,$ffff,$0000,$0605,$0002,$fe1f
        dc.w    $0000,$5b96,$3c68,$ffff,$0000,$0c8a,$0300,$ff9f
        dc.w    $0000,$65cd,$1a30,$ffff,$0000,$0b48,$0780,$ffdf
        dc.w    $0000,$3aa7,$0718,$ffff,$0000,$0a04,$07c0,$ffce
        dc.w    $0000,$0bbe,$0700,$ffff,$0000,$0ca0,$03c0,$ffe0
        dc.w    $0000,$8dad,$021e,$ffff,$0000,$0640,$0180,$ffe0
        dc.w    $0000,$a728,$001f,$ffff,$0000,$23c0,$0000,$ffe0
        dc.w    $0000,$d032,$000f,$ffff,$0000,$f000,$0000,$ffc0
        dc.w    $0000,$b019,$4006,$ffff,$0000,$5c00,$2000,$ffc0
        dc.w    $0000,$688f,$8000,$ffff,$0000,$3600,$0800,$bf80
        dc.w    $0000,$39c0,$c000,$ffff,$0000,$0c40,$0020,$0ee0
        dc.w    $0000,$7373,$0480,$ffff,$0000,$80a0,$0070,$81f0
        dc.w    $0000,$2dc6,$1e01,$ffff,$0000,$20d0,$c020,$e3f8
        dc.w    $0000,$2d8c,$1e03,$ffff,$0000,$9168,$e010,$f3f8
        dc.w    $0000,$32cd,$0d03,$ffff,$0000,$d190,$e000,$f3f8

hobust:

        dc.w    $0000,$0709,$0007,$0f9f,$0000,$32b8,$c0c0,$ffff
        dc.w    $0000,$0014,$000f,$071f,$0000,$64a1,$82c0,$ffff
        dc.w    $0000,$000b,$0004,$001f,$0000,$c462,$0280,$ffff
        dc.w    $0000,$0006,$0000,$001f,$0000,$0ecb,$0000,$ffff
        dc.w    $0000,$0000,$0000,$000f,$0000,$0a16,$0401,$ffff
        dc.w    $0000,$0086,$0000,$00ef,$0000,$341a,$0805,$ffff
        dc.w    $0000,$0143,$0080,$01f7,$0000,$3a2c,$c003,$ffff
        dc.w    $0000,$00a0,$0000,$01f1,$0000,$0d39,$0e06,$ffff
        dc.w    $0000,$0020,$0000,$01f0,$0000,$6d1e,$1e03,$ffff
        dc.w    $0000,$2040,$0000,$38e0,$0000,$5302,$8c1f,$ffff
        dc.w    $0000,$5000,$2001,$7c01,$0000,$ae29,$c01e,$ffff
        dc.w    $0000,$2801,$0000,$7c03,$0000,$6053,$800c,$ffff
        dc.w    $0000,$0822,$0041,$7c73,$0000,$d09e,$0000,$ffff
        dc.w    $0000,$1051,$00e0,$38fb,$0000,$32e0,$0000,$ffff
        dc.w    $0000,$00b0,$0040,$01fd,$0000,$e5f1,$0000,$ffff
        dc.w    $0000,$0168,$0080,$01fc,$0000,$0718,$00e0,$ffff
        dc.w    $0000,$0098,$0000,$01fc,$0000,$ca4c,$01f0,$ffff
        dc.w    $0000,$0071,$0000,$00fb,$0000,$22ec,$c1f0,$ffff
        dc.w    $0000,$0102,$0201,$03f7,$0000,$d04c,$e1f0,$ffff
        dc.w    $0000,$0286,$0701,$07cf,$0000,$d019,$e0e0,$ffff
        dc.w    $0000,$058d,$0202,$0fef,$0000,$30f1,$c000,$ffff
        dc.w    $0000,$0b4a,$0407,$0fff,$0000,$e103,$0000,$ffff
        dc.w    $0000,$04ce,$0007,$0fff,$0000,$8682,$0001,$ffff
        dc.w    $0000,$038d,$0002,$07df,$0000,$8b99,$0000,$ffff
        dc.w    $0000,$4007,$0000,$739f,$0000,$2fa4,$0018,$ffff
        dc.w    $0000,$a060,$4000,$f87f,$0000,$5a5a,$053c,$ffff
        dc.w    $0000,$5130,$00c0,$f9ff,$0000,$69da,$163c,$ffff
        dc.w    $0000,$12d0,$01e0,$fbff,$0000,$b3a6,$0c58,$ffff
        dc.w    $0000,$2050,$03e0,$73ff,$0000,$e55c,$18e0,$ffff
        dc.w    $0000,$0530,$03c0,$07ff,$0000,$7dd0,$00e0,$ffff
        dc.w    $0000,$0260,$0180,$07ff,$0000,$b5b1,$7840,$ffff
        dc.w    $0000,$03c4,$0000,$07ff,$0000,$14e5,$f800,$ffff
        dc.w    $0000,$000f,$0000,$03ff,$0000,$4c0b,$f000,$ffff
        dc.w    $0000,$003a,$0004,$03ff,$0000,$980d,$6002,$ffff
        dc.w    $0000,$006c,$0010,$01fd,$0000,$f116,$0001,$ffff
        dc.w    $0000,$0230,$0400,$0770,$0000,$039c,$0003,$ffff
        dc.w    $0000,$0501,$0e00,$0f81,$0000,$cece,$0120,$ffff
        dc.w    $0000,$0b04,$0403,$1fc7,$0000,$63b4,$8078,$ffff
        dc.w    $0000,$1689,$0807,$1fcf,$0000,$31b4,$c078,$ffff
        dc.w    $0000,$098b,$0007,$1fcf,$0000,$b34c,$c0b0,$ffff

slinger:

        dc.w    $0000,$fc13,$03fc,$0000,$0000,$ed9c,$f3e0,$0000
        dc.w    $0000,$3387,$0ff8,$0000,$0000,$04b6,$03d8,$0000
        dc.w    $0000,$07c9,$003e,$0000,$0000,$8d38,$f3c0,$0000
        dc.w    $0000,$263c,$1fc0,$0000,$0000,$0db4,$03d8,$0000
        dc.w    $0000,$036d,$009e,$0000,$0000,$3d2e,$c3d0,$0000
        dc.w    $0000,$2ce8,$1f10,$0000,$0000,$1924,$07d8,$0000
        dc.w    $0000,$01ad,$005e,$0000,$0000,$fdb3,$1bcc,$0000
        dc.w    $0000,$e998,$1e60,$0000,$0000,$1364,$0f98,$0000
        dc.w    $0000,$00e5,$001e,$0000,$0000,$c49f,$3be0,$0000
        dc.w    $0000,$e9b0,$1ec0,$0000,$0000,$3674,$0fb8,$0000
        dc.w    $0000,$07cd,$003e,$0000,$0000,$7ec8,$81f7,$0000
        dc.w    $0000,$2da0,$de40,$0000,$0000,$e4f6,$1f38,$0000
        dc.w    $0000,$9c19,$03fe,$0000,$0000,$23f3,$c00f,$0000
        dc.w    $0000,$e4ff,$df00,$0000,$0000,$8d93,$7e7c,$0000
        dc.w    $0000,$f1f3,$0ffc,$0000,$0000,$be1e,$c1e3,$0000
        dc.w    $0000,$3640,$cfbf,$0000,$0000,$39c8,$fe3f,$0000
        dc.w    $0000,$0786,$fff9,$0000,$0000,$98c6,$e7f9,$0000
        dc.w    $0000,$f31f,$0fff,$0000,$0000,$e36e,$fc1f,$0000
        dc.w    $0000,$cc3e,$ffc1,$0000,$0000,$f3f3,$cffc,$0000
        dc.w    $0000,$99f1,$67fe,$0000,$0000,$fe23,$001f,$0000
        dc.w    $0000,$79ff,$fe00,$0000,$0000,$e619,$5ffe,$0000
        dc.w    $0000,$9c07,$73f8,$0000,$0000,$0638,$f807,$0000
        dc.w    $0000,$03e0,$fc1f,$0000,$0000,$eccd,$1f3e,$0000
        dc.w    $0000,$b7fe,$7801,$0000,$0000,$720f,$fc00,$0000
        dc.w    $0000,$fe0e,$01ff,$0000,$0000,$49e4,$be1f,$0000
        dc.w    $0000,$a700,$78ff,$0000,$0000,$da03,$fc00,$0000
        dc.w    $0000,$00f3,$ffff,$0000,$0000,$5336,$bccf,$0000
        dc.w    $0000,$fc7f,$43ff,$0000,$0000,$8a0e,$fc01,$0000
        dc.w    $0000,$ffc1,$ffff,$0000,$0000,$d7f2,$39ef,$0000
        dc.w    $0000,$e1c0,$1fff,$0000,$0000,$2a18,$dc07,$0000
        dc.w    $0000,$801d,$ffe3,$0000,$0000,$941b,$7be6,$0000
        dc.w    $0000,$8f1f,$7fe0,$0000,$0000,$ebff,$1c03,$0000
        dc.w    $0000,$3ffc,$c003,$0000,$0000,$b7eb,$7814,$0000
        dc.w    $0000,$3870,$ff80,$0000,$0000,$df06,$20f9,$0000
        dc.w    $0000,$e0f8,$0007,$0000,$0000,$a43a,$7805,$0000
        dc.w    $0000,$63df,$fc00,$0000,$0000,$f072,$0ffd,$0000
        dc.w    $0000,$8783,$007f,$0000,$0000,$ac0a,$7005,$0000
        dc.w    $0000,$ce70,$f00f,$0000,$0000,$079b,$fffc,$0000
        dc.w    $0000,$1c3e,$03ff,$0000,$0000,$a80a,$7005,$0000
        dc.w    $0000,$98c7,$e03f,$0000,$0000,$fe09,$fffe,$0000
        dc.w    $0000,$31ef,$0ff0,$0000,$0000,$fc0a,$0005,$0000
        dc.w    $0000,$919c,$e07f,$0000,$0000,$00ed,$ff1e,$0000
        dc.w    $0000,$6718,$1fe7,$0000,$0000,$0c0a,$f005,$0000
        dc.w    $0000,$d931,$e0fe,$0000,$0000,$ffe5,$001e,$0000
        dc.w    $0000,$c873,$3f8f,$0000,$0000,$e40a,$f805,$0000
        dc.w    $0000,$4f67,$f0f8,$0000,$0000,$d7c5,$e03e,$0000
        dc.w    $0000,$93e6,$7c1f,$0000,$0000,$341b,$f804,$0000
        dc.w    $0000,$664f,$f9f3,$0000,$0000,$bc19,$c3fe,$0000
        dc.w    $0000,$b62c,$781f,$0000,$0000,$9793,$780e,$0000
        dc.w    $0000,$32de,$fde7,$0000,$0000,$e1f3,$1ffc,$0000
        dc.w    $0000,$2429,$f81e,$0000,$0000,$d0f7,$3f0e,$0000
        dc.w    $0000,$9e91,$79ee,$0000,$0000,$8f07,$7ff8,$0000
        dc.w    $0000,$6ce9,$f01e,$0000,$0000,$da44,$3fbf,$0000
        dc.w    $0000,$c4bf,$3bc0,$0000,$0000,$387d,$ff80,$0000
        dc.w    $0000,$4fac,$f05f,$0000,$0000,$cf5d,$3fbe,$0000
        dc.w    $0000,$fda6,$03c1,$0000,$0000,$43d9,$fc20,$0000
        dc.w    $0000,$6326,$fcdf,$0000,$0000,$2373,$dfbc,$0000
        dc.w    $0000,$cd24,$33c3,$0000,$0000,$9f4d,$e0f0,$0000
        dc.w    $0000,$39f3,$fecf,$0000,$0000,$824e,$ffb1,$0000
        dc.w    $0000,$196d,$f783,$0000,$0000,$b167,$c0f8,$0000
        dc.w    $0000,$8d78,$7e87,$0000,$0000,$e6d8,$ff27,$0000
        dc.w    $0000,$eb49,$f787,$0000,$0000,$3f31,$c0fe,$0000
        dc.w    $0000,$19ce,$fe31,$0000,$0000,$3cf3,$ff0f,$0000
        dc.w    $0000,$0a4b,$f787,$0000,$0000,$639c,$9c7f,$0000
        dc.w    $0000,$f39f,$fc7c,$0000,$0000,$81a4,$7e1f,$0000
        dc.w    $0000,$6aca,$9707,$0000,$0000,$79c7,$8e3f,$0000
        dc.w    $0000,$0730,$f8ff,$0000,$0000,$ff69,$001e,$0000
        dc.w    $0000,$ca6b,$3787,$0000,$0000,$1d70,$e60f,$0000
        dc.w    $0000,$ff66,$00f9,$0000,$0000,$6c4b,$f03c,$0000
        dc.w    $0000,$5b39,$37c7,$0000,$0000,$cdff,$f600,$0000
        dc.w    $0000,$a64f,$79f0,$0000,$0000,$2452,$f83c,$0000
        dc.w    $0000,$598c,$37f3,$0000,$0000,$6c30,$f7c0,$0000
        dc.w    $0000,$969d,$79e6,$0000,$0000,$b452,$783c,$0000
        dc.w    $0000,$4ce0,$33ff,$0000,$0000,$ce90,$f7e0,$0000
        dc.w    $0000,$d6b2,$39cf,$0000,$0000,$944a,$783c,$0000
        dc.w    $0000,$663f,$19ff,$0000,$0000,$9bd0,$e7e0,$0000
        dc.w    $0000,$54b2,$3bcf,$0000,$0000,$d46b,$381c,$0000
        dc.w    $0000,$3380,$0c7f,$0000,$0000,$38d0,$c7e0,$0000
        dc.w    $0000,$fda4,$0bdf,$0000,$0000,$d629,$381e,$0000
        dc.w    $0000,$f9ff,$0700,$0000,$0000,$e097,$1fe0,$0000
        dc.w    $0000,$1d39,$e3de,$0000,$0000,$d224,$3c1f,$0000
        dc.w    $0000,$6246,$9f81,$0000,$0000,$39bc,$ffc3,$0000
        dc.w    $0000,$cd63,$f39c,$0000,$0000,$5a33,$3c0f,$0000
        dc.w    $0000,$0cfb,$ff00,$0000,$0000,$8f39,$7fc7,$0000
        dc.w    $0000,$654e,$fbb0,$0000,$0000,$4a18,$3c07,$0000
        dc.w    $0000,$f18c,$fe70,$0000,$0000,$e072,$1f8f,$0000
        dc.w    $0000,$3578,$fb80,$0000,$0000,$4a0e,$3c01,$0000
        dc.w    $0000,$07e4,$f8f8,$0000,$0000,$3fe4,$001f,$0000
        dc.w    $0000,$9520,$7bc0,$0000,$0000,$5a0f,$3c00,$0000
        dc.w    $0000,$fdb4,$03f8,$0000,$0000,$306d,$0f9e,$0000
        dc.w    $0000,$a5a0,$7bc0,$0000,$0000,$5a78,$3c07,$0000
        dc.w    $0000,$ff1f,$ffe0,$0000,$0000,$e72d,$1fde,$0000
        dc.w    $0000,$27e0,$f800,$0000,$0000,$d3c3,$3c3f,$0000
        dc.w    $0000,$8070,$ff8f,$0000,$0000,$0da9,$ffde,$0000
        dc.w    $0000,$7038,$ffc0,$0000,$0000,$971e,$78ff,$0000
        dc.w    $0000,$3fc7,$c03f,$0000,$0000,$f8bb,$ffdc,$0000
        dc.w    $0000,$3f8f,$fff0,$0000,$0000,$b670,$79ff,$0000
        dc.w    $0000,$ee1c,$01ff,$0000,$0000,$02bb,$fddc,$0000
        dc.w    $0000,$81e6,$7ff9,$0000,$0000,$24c7,$fbf8,$0000
        dc.w    $0000,$98f1,$07fe,$0000,$0000,$feb3,$01dc,$0000


tcb:

        dc.w    $0000,$8783,$007f,$0000,$0000,$ac0a,$7005,$0000
        dc.w    $0000,$ce70,$f00f,$0000,$0000,$209b,$9f3c,$7fc0
        dc.w    $0000,$1c3e,$03ff,$0000,$0000,$a80a,$7005,$0000
        dc.w    $0000,$98c5,$e03c,$0003,$0000,$0009,$ffde,$ffe0
        dc.w    $0000,$31ef,$0ff0,$0000,$0000,$fc0a,$0005,$0000
        dc.w    $0000,$9198,$e077,$000f,$0000,$3fad,$ffce,$fff0
        dc.w    $0000,$6718,$1fe7,$0000,$0000,$0c0a,$f005,$0000
        dc.w    $0000,$d931,$e0ef,$001f,$0000,$ffd5,$ffe6,$fff8
        dc.w    $0000,$c873,$3f8f,$0000,$0000,$e40a,$f805,$0000
        dc.w    $0000,$4f47,$f0df,$003f,$0000,$fffd,$ffe6,$fff8
        dc.w    $0000,$93e6,$7c1f,$0000,$0000,$3410,$f80f,$003f
        dc.w    $0000,$010f,$fe3f,$ffff,$0000,$ffe9,$fff2,$fffc
        dc.w    $0000,$b62c,$781f,$0000,$0000,$9500,$78ff,$03ff
        dc.w    $0000,$004f,$ffbf,$ffff,$0000,$ffff,$f0f0,$fffc
        dc.w    $0000,$2429,$f81e,$0000,$0000,$c81f,$27ff,$1fff
        dc.w    $0000,$ff4f,$ffbf,$ffff,$0000,$feff,$e7f0,$f9fc
        dc.w    $0000,$6ce9,$f01e,$0000,$0000,$a1ff,$1fff,$7fff
        dc.w    $0000,$ffff,$ff9f,$ffff,$0000,$f8fd,$eff0,$f1fc
        dc.w    $0000,$4fac,$f05e,$0001,$0000,$8fff,$7fff,$ffff
        dc.w    $0000,$ffe7,$ff9f,$ffff,$0000,$f0fd,$eff0,$f3fc
        dc.w    $0000,$6322,$fcd9,$0007,$0000,$3fff,$ffff,$ffff
        dc.w    $0000,$ff61,$ff9f,$ffff,$0000,$e1e9,$fff0,$fffc
        dc.w    $0000,$39f8,$fec7,$000f,$0000,$ffff,$ffff,$ffff
        dc.w    $0000,$fdd8,$fe3f,$ffff,$0000,$ffff,$ffe0,$fff8
        dc.w    $0000,$8d63,$7e9f,$001f,$0000,$feef,$fff0,$ffff
        dc.w    $0000,$ffbd,$007e,$ffff,$0000,$7fd1,$ffe6,$fff8
        dc.w    $0000,$19cf,$fe3f,$003f,$0000,$f7df,$f8e0,$ffff
        dc.w    $0000,$feff,$01fe,$ffff,$0000,$ffbc,$7fcf,$fff0
        dc.w    $0000,$f3df,$fc3f,$007f,$0000,$def7,$e1cf,$ffff
        dc.w    $0000,$fffd,$fffe,$ffff,$0000,$fee7,$7f1f,$ffe0
        dc.w    $0000,$071f,$f87f,$00ff,$0000,$74af,$83df,$fbff
        dc.w    $0000,$ffff,$fffc,$ffff,$0000,$7fc0,$fc0f,$fff0
        dc.w    $0000,$ffbd,$007e,$00ff,$0000,$a9ff,$339f,$c7ff
        dc.w    $0000,$bdf7,$c3f8,$ffff,$0000,$fd47,$fee0,$fff8
        dc.w    $0000,$a6bb,$797c,$00ff,$0000,$25fe,$7b9f,$87ff
        dc.w    $0000,$ffff,$0001,$ffff,$0000,$ffe0,$fff0,$fffc
        dc.w    $0000,$96df,$79a0,$007e,$0000,$b1fd,$7f9e,$07ff
        dc.w    $0000,$cffb,$3007,$83ff,$0000,$fff4,$fff8,$fffe
        dc.w    $0000,$d6ba,$39c3,$003c,$0000,$91ff,$779c,$0fff
        dc.w    $0000,$64ff,$1bff,$03ff,$0000,$fffe,$fff8,$fffe
        dc.w    $0000,$54b2,$3bcf,$0000,$0000,$dbfb,$379c,$0ffe
        dc.w    $0000,$30ff,$0fff,$03ff,$0000,$fffa,$e7fc,$fffe
        dc.w    $0000,$fda4,$0bdf,$0000,$0000,$c3ff,$2f98,$1ffe
        dc.w    $0000,$f8fc,$07ff,$03ff,$0000,$67fa,$dbfc,$e7ff
        dc.w    $0000,$1d39,$e3de,$0000,$0000,$d7fe,$2f99,$1ffe
        dc.w    $0000,$60f8,$9fff,$03ff,$0000,$39ff,$fffc,$c3ff
        dc.w    $0000,$cd63,$f39c,$0000,$0000,$47ff,$3f99,$1ffe
        dc.w    $0000,$0df3,$fbff,$07ff,$0000,$69ff,$9ffc,$e7ff
        dc.w    $0000,$654e,$fbb0,$0000,$0000,$47fb,$1f9c,$3fff
        dc.w    $0000,$f1c7,$ffff,$07ff,$0000,$c3ff,$3ffc,$ffff
        dc.w    $0000,$3578,$fb80,$0000,$0000,$6fff,$1f9c,$3fff
        dc.w    $0000,$c10f,$3ffe,$c7ff,$0000,$bffa,$7ffc,$ffff
        dc.w    $0000,$9520,$7bc0,$0000,$0000,$4ffe,$3f9f,$3fff
        dc.w    $0000,$003d,$fffe,$ffff,$0000,$ffff,$7ff8,$fffe
        dc.w    $0000,$a5a0,$7bc0,$0000,$0000,$4f7f,$3f9f,$3fff
        dc.w    $0000,$c0fb,$fffc,$ffff,$0000,$7ff5,$fff8,$fffe
        dc.w    $0000,$27e0,$f800,$0000,$0000,$efdf,$1f3f,$3fff
        dc.w    $0000,$ffee,$fff1,$ffff,$0000,$ffd9,$ffe2,$fffc
        dc.w    $0000,$7038,$ffc0,$0000,$0000,$8efb,$5707,$3fff
        dc.w    $0000,$feff,$ff00,$ffff,$0000,$def3,$3f04,$fff8
        dc.w    $0000,$3f8f,$fff0,$0000,$0000,$afdf,$6040,$1fbf
        dc.w    $0000,$ffec,$000e,$fff1,$0000,$ffdb,$001c,$ffe0
        dc.w    $0000,$81e6,$7ff9,$0000,$0000,$22c3,$f8f8,$0707
        dc.w    $0000,$fef1,$00fe,$ff00,$0000,$deb3,$00dc,$3f00


superscroller:


        dc.w    $0000,$8dd8,$7be7,$07f0,$0000,$e6d8,$ff27,$0000
        dc.w    $0000,$eb49,$f787,$0000,$0000,$3f31,$c0fe,$0000
        dc.w    $0000,$8d78,$7e87,$0000,$0000,$e6d8,$ff27,$0000
        dc.w    $0000,$eb49,$f787,$0000,$0000,$3f31,$c0fe,$0000
        dc.w    $0000,$1ff6,$f7f9,$0ff8,$0000,$3cf3,$ff0f,$0000
        dc.w    $0000,$0a4b,$f787,$0000,$0000,$639c,$9c7f,$0000
        dc.w    $0000,$19ce,$fe31,$0000,$0000,$3cb3,$ff4f,$00e0
        dc.w    $0000,$0a4b,$f787,$0000,$0000,$639c,$9c7f,$0000
        dc.w    $0000,$f67f,$ff3c,$0ff8,$0000,$81a4,$7e1f,$0000
        dc.w    $0000,$6aca,$9707,$0000,$0000,$79c7,$8e3f,$0000
        dc.w    $0000,$f39f,$fc7c,$0000,$0000,$8144,$7eff,$00e0
        dc.w    $0000,$5aca,$a707,$7000,$0000,$79c7,$8e3f,$0000
        dc.w    $0000,$0e28,$feff,$0f18,$0000,$ff69,$001e,$0000
        dc.w    $0000,$ca6b,$3787,$0000,$0000,$1d70,$e60f,$0000
        dc.w    $0000,$0730,$f8ff,$0000,$0000,$ffe9,$00fe,$00e0
        dc.w    $0000,$aa6b,$7787,$7000,$0000,$1d70,$e60f,$0000
        dc.w    $0000,$ff66,$0e79,$0f80,$0000,$6c4b,$f03c,$0000
        dc.w    $0000,$5739,$3bc7,$7c00,$0000,$cdff,$f600,$0000
        dc.w    $0000,$ff66,$00f9,$0000,$0000,$6dcb,$f0fc,$01e0
        dc.w    $0000,$fb39,$67c7,$f000,$0000,$cdff,$f600,$0000
        dc.w    $0000,$a74f,$7f90,$0fe0,$0000,$2452,$f83c,$0000
        dc.w    $0000,$bf8c,$7df3,$fe00,$0000,$6730,$ffc0,$0f80
        dc.w    $0000,$a64f,$79f0,$0000,$0000,$24f2,$f9dc,$01e0
        dc.w    $0000,$59d8,$f7bf,$e07c,$0000,$6c30,$f7c0,$0000
        dc.w    $0000,$93df,$7fe5,$07f3,$0000,$acf2,$f1fc,$99f8
        dc.w    $0000,$c4c8,$7fb7,$ee78,$0000,$cf90,$ffe0,$1fc0
        dc.w    $0000,$969d,$79e6,$0000,$0000,$b593,$79fc,$01c1
        dc.w    $0000,$ecfc,$d37f,$e0fe,$0000,$b490,$cfe0,$fe00
        dc.w    $0000,$d767,$38fb,$01f7,$0000,$35fa,$dbfc,$bbfc
        dc.w    $0000,$663d,$dfff,$c67e,$0000,$9a9b,$fde7,$1bcf
        dc.w    $0000,$5335,$bccb,$8fc7,$0000,$b5ca,$d9bd,$e1c1
        dc.w    $0000,$e67f,$d9ff,$c0e6,$0000,$ffd0,$ffe0,$ff00
        dc.w    $0000,$54f3,$3b7f,$38f7,$0000,$ff6f,$1b9c,$bbfc
        dc.w    $0000,$f5fe,$ce7f,$ce7f,$0000,$3957,$deaf,$19df
        dc.w    $0000,$8fdb,$ffe7,$dfef,$0000,$f7eb,$e99d,$f381
        dc.w    $0000,$b3ce,$ccf7,$c1ce,$0000,$f4d0,$fbe0,$ff00
        dc.w    $0000,$fdee,$3bf7,$3c7f,$0000,$ffbd,$1b0e,$3b9c
        dc.w    $0000,$ffeb,$fd77,$feff,$0000,$fa8f,$1dfc,$1e1e
        dc.w    $0000,$6fed,$dff6,$dfef,$0000,$a5ab,$7b9d,$7383
        dc.w    $0000,$f8fd,$87fe,$c1fe,$0000,$7097,$efe0,$f000
        dc.w    $0000,$3b7f,$fce6,$3fff,$0000,$fb3c,$1f0f,$3b1c
        dc.w    $0000,$d676,$fbe1,$fcf0,$0000,$2eb8,$ff5f,$1f9c
        dc.w    $0000,$1ef7,$ef5c,$1fee,$0000,$f325,$3f9f,$3383
        dc.w    $0000,$e3fa,$9ffd,$81fc,$0000,$e9bc,$7fc3,$f000
        dc.w    $0000,$ffc7,$dfee,$3ffe,$0000,$532b,$3f1f,$3b3c
        dc.w    $0000,$7efb,$efe0,$f2e0,$0000,$5f3d,$efdb,$f79c
        dc.w    $0000,$cf6f,$fd9c,$0e0c,$0000,$7bb3,$3f0f,$3383
        dc.w    $0000,$8cfb,$ffc0,$81e0,$0000,$ff39,$7fc7,$7000
        dc.w    $0000,$77ee,$efde,$1fee,$0000,$7bf0,$37ff,$3bf8
        dc.w    $0000,$bdec,$fef0,$7ee0,$0000,$fbfa,$f79d,$fb9e
        dc.w    $0000,$7d4e,$efbc,$dc0e,$0000,$7b99,$3f07,$7383
        dc.w    $0000,$f1da,$bee6,$c1f6,$0000,$f072,$7f8f,$7000
        dc.w    $0000,$357b,$f387,$0fcf,$0000,$efde,$fbe1,$f7f0
        dc.w    $0000,$2b44,$dcf8,$3ee0,$0000,$bf6f,$7f9f,$ff9f
        dc.w    $0000,$ad75,$ff8e,$dc0f,$0000,$bb6f,$7f99,$f3fb
        dc.w    $0000,$af7c,$dcfe,$fdfe,$0000,$2fe4,$701f,$7000
        dc.w    $0000,$9522,$7bc1,$0003,$0000,$db8f,$ef00,$f780
        dc.w    $0000,$fdb4,$0358,$00e0,$0000,$2ee7,$1f1f,$3f8f
        dc.w    $0000,$192f,$ffc7,$9c0f,$0000,$69fe,$fff9,$f3f9
        dc.w    $0000,$f9b8,$ff7c,$fcfc,$0000,$506d,$2f9e,$7000
        dc.w    $0000,$a5a0,$7bc0,$0000,$0000,$5f78,$3f07,$0700
        dc.w    $0000,$ff1f,$ffe0,$0000,$0000,$e72d,$1fde,$0000
        dc.w    $0000,$b5a5,$7bc3,$1807,$0000,$daf9,$fdf6,$e1f9
        dc.w    $0000,$6f1f,$f7e0,$f800,$0000,$e72d,$1fde,$0000
        dc.w    $0000,$27e0,$f800,$0000,$0000,$d7c3,$3f3f,$0700
        dc.w    $0000,$8070,$ff8f,$0000,$0000,$0da9,$ffde,$0000
        dc.w    $0000,$27e0,$f800,$0000,$0000,$d3c3,$3c3f,$0000
        dc.w    $0000,$8070,$ff8f,$0000,$0000,$0da9,$ffde,$0000
        dc.w    $0000,$7038,$ffc0,$0000,$0000,$931e,$7fff,$0700
        dc.w    $0000,$3fc7,$c03f,$0000,$0000,$f8bb,$ffdc,$0000
        dc.w    $0000,$7038,$ffc0,$0000,$0000,$971e,$78ff,$0000
        dc.w    $0000,$3fc7,$c03f,$0000,$0000,$f8bb,$ffdc,$0000
        dc.w    $0000,$3f8f,$fff0,$0000,$0000,$b670,$7bff,$0700
        dc.w    $0000,$ee1c,$01ff,$0000,$0000,$02bb,$fddc,$0000
        dc.w    $0000,$3f8f,$fff0,$0000,$0000,$b670,$79ff,$0000
        dc.w    $0000,$ee1c,$01ff,$0000,$0000,$02bb,$fddc,$0000
        dc.w    $0000,$81e6,$7ff9,$0000,$0000,$25c7,$faf8,$0300
        dc.w    $0000,$98f1,$07fe,$0000,$0000,$feb3,$01dc,$0000
        dc.w    $0000,$81e6,$7ff9,$0000,$0000,$24c7,$fbf8,$0000
        dc.w    $0000,$98f1,$07fe,$0000,$0000,$feb3,$01dc,$0000


the_union:


        dc.w    $0000,$3387,$0ff8,$0000,$0000,$04b6,$03d8,$0000
        dc.w    $0000,$fc13,$03fc,$0000,$0000,$ed9d,$f3e3,$0003
        dc.w    $0000,$3387,$8ff8,$8000,$0000,$04b6,$03d8,$0000
        dc.w    $0000,$fc13,$03fc,$0000,$0000,$ed9c,$f3e0,$0000
        dc.w    $0000,$263c,$1fc0,$0000,$0000,$0db4,$03d8,$0000
        dc.w    $0000,$07c9,$003e,$0000,$0000,$8d3a,$f3c7,$0007
        dc.w    $0000,$a63c,$dfc0,$c000,$0000,$0db4,$03d8,$0000
        dc.w    $0000,$07c9,$003e,$0000,$0000,$8d38,$f3c0,$0000
        dc.w    $0000,$2ce8,$1f10,$0000,$0000,$1924,$07d8,$0000
        dc.w    $0000,$036d,$009e,$0000,$0000,$3d26,$c3df,$000f
        dc.w    $0000,$8ce8,$ff10,$e000,$0000,$1924,$07d8,$0000
        dc.w    $0000,$036d,$009e,$0000,$0000,$3d2e,$c3d0,$0000
        dc.w    $0000,$e998,$1e60,$0000,$0000,$1364,$0f98,$0000
        dc.w    $0000,$01ad,$005e,$0000,$0000,$fda9,$1bde,$001f
        dc.w    $0000,$6998,$fe60,$f000,$0000,$1364,$0f98,$0000
        dc.w    $0000,$01ad,$005e,$0000,$0000,$fdb3,$1bcc,$0000
        dc.w    $0000,$e9b0,$1ec0,$0000,$0000,$3674,$0fb8,$0000
        dc.w    $0000,$00e5,$001e,$0000,$0000,$c49b,$3bfc,$003f
        dc.w    $0000,$b1b0,$7ec0,$f800,$0000,$3674,$0fb8,$0000
        dc.w    $0000,$00e5,$001e,$0000,$0000,$c49f,$3be0,$0000
        dc.w    $0000,$2da0,$de40,$0000,$0000,$e4f6,$1f38,$0000
        dc.w    $0000,$07cd,$003e,$0000,$0000,$7eb6,$81f8,$007f
        dc.w    $0000,$91a0,$3e40,$fc00,$0000,$e4f6,$1f38,$0000
        dc.w    $0000,$07cd,$003e,$0000,$0000,$7ec8,$81f7,$0000
        dc.w    $0000,$e4ff,$df00,$0000,$0000,$8d93,$7e7c,$0000
        dc.w    $0000,$9c19,$03fe,$0000,$0000,$234a,$c0f4,$00ff
        dc.w    $0000,$8cff,$5f00,$fe00,$0000,$8d93,$7e7c,$0000
        dc.w    $0000,$9c19,$03fe,$0000,$0000,$23f3,$c00f,$0000
        dc.w    $0000,$3640,$cfbf,$0000,$0000,$39c8,$fe3f,$0000
        dc.w    $0000,$f1f3,$0ffc,$0000,$0000,$bed9,$c1e4,$01ff
        dc.w    $0000,$3640,$4fbf,$ff00,$0000,$39c8,$fe3f,$0000
        dc.w    $0000,$f1f3,$0ffc,$0000,$0000,$be1e,$c1e3,$0000
        dc.w    $0000,$f31f,$0fff,$0000,$0000,$e36e,$fc1f,$0000
        dc.w    $0000,$0786,$fff9,$0000,$0000,$99aa,$e7d4,$03ff
        dc.w    $0000,$ab1f,$57ff,$ff80,$0000,$e36e,$fc1f,$0000
        dc.w    $0000,$0786,$fff9,$0000,$0000,$98c6,$e7f9,$0000
        dc.w    $0000,$99f1,$67fe,$0000,$0000,$fe23,$001f,$0000
        dc.w    $0000,$cc3e,$ffc1,$0000,$0000,$f35a,$cfa4,$07ff
        dc.w    $0000,$a5b1,$5bfe,$ffc0,$0000,$fe23,$001f,$0000
        dc.w    $0000,$cc3e,$ffc1,$0000,$0000,$f3f3,$cffc,$0000
        dc.w    $0000,$9c07,$73f8,$0000,$0000,$0638,$f807,$0000
        dc.w    $0000,$79ff,$fe00,$0000,$0000,$e6bb,$5f44,$0fff
        dc.w    $0000,$a2c7,$55f8,$ffe0,$0000,$0638,$f807,$0000
        dc.w    $0000,$79ff,$fe00,$0000,$0000,$e619,$5ffe,$0000
        dc.w    $0000,$b7fe,$7801,$0000,$0000,$720f,$fc00,$0000
        dc.w    $0000,$03e0,$fc1f,$0000,$0000,$ed7b,$1e84,$1fff
        dc.w    $0000,$296e,$52f1,$fff0,$0000,$720f,$fc00,$0000
        dc.w    $0000,$03e0,$fc1f,$0000,$0000,$eccd,$1f3e,$0000
        dc.w    $0000,$a700,$78ff,$0000,$0000,$da03,$fc00,$0000
        dc.w    $0000,$fe0e,$01ff,$0000,$0000,$5a60,$bd84,$3fff
        dc.w    $0000,$8430,$517f,$fff8,$0000,$da03,$fc00,$0000
        dc.w    $0000,$fe0e,$01ff,$0000,$0000,$49e4,$be1f,$0000
        dc.w    $0000,$fc7f,$43ff,$0000,$0000,$8a0e,$fc01,$0000
        dc.w    $0000,$00f3,$ffff,$0000,$0000,$3558,$fa87,$7fff
        dc.w    $0000,$205b,$de3f,$fffc,$0000,$8a0e,$fc01,$0000
        dc.w    $0000,$00f3,$ffff,$0000,$0000,$5336,$bccf,$0000
        dc.w    $0000,$e1c0,$1fff,$0000,$0000,$2a18,$dc07,$0000
        dc.w    $0000,$ffc1,$ffff,$0000,$0000,$6a3b,$f484,$ffff
        dc.w    $0000,$862c,$501f,$fffe,$0000,$2a18,$dc07,$0000
        dc.w    $0000,$ffc1,$ffff,$0000,$0000,$d7f2,$39ef,$0000
        dc.w    $0000,$8f1f,$7fe0,$0000,$0000,$ebff,$1c03,$0000
        dc.w    $0000,$801c,$ffe3,$0001,$0000,$d458,$e884,$ffff
        dc.w    $0000,$0436,$500f,$ffff,$0000,$ebff,$1c03,$0000
        dc.w    $0000,$801d,$ffe3,$0000,$0000,$941b,$7be6,$0000
        dc.w    $0000,$3870,$ff80,$0000,$0000,$df06,$20f9,$0000
        dc.w    $0000,$3ffd,$c003,$0003,$0000,$ba30,$c084,$ffff
        dc.w    $0000,$20eb,$5007,$ffff,$0000,$5f06,$a0f9,$8000
        dc.w    $0000,$3ffc,$c003,$0000,$0000,$b7eb,$7814,$0000
        dc.w    $0000,$63df,$fc00,$0000,$0000,$f072,$0ffd,$0000
        dc.w    $0000,$e0fb,$0007,$0007,$0000,$6179,$8084,$ffff
        dc.w    $0000,$800d,$5ff3,$ffff,$0000,$b072,$cffd,$c000
        dc.w    $0000,$e0f8,$0007,$0000,$0000,$a43a,$7805,$0000
        dc.w    $0000,$ce70,$f00f,$0000,$0000,$1e1b,$fffc,$1f80
        dc.w    $0000,$8f06,$0fff,$0f8f,$0000,$e0e7,$0000,$ffff
        dc.w    $0000,$f70e,$0001,$ffff,$0000,$c60b,$fffc,$e1f0
        dc.w    $0000,$8673,$01ff,$01f0,$0000,$ac0a,$7005,$0000
        dc.w    $0000,$98c7,$e03f,$0000,$0000,$fe09,$fffe,$1f80
        dc.w    $0000,$1f2d,$0ffe,$0f9f,$0000,$a1df,$0000,$ffff
        dc.w    $0000,$5617,$0000,$ffff,$0000,$6e71,$fffe,$f1f8
        dc.w    $0000,$1c7e,$03ff,$01f8,$0000,$a80a,$7005,$0000
        dc.w    $0000,$919c,$e07f,$0000,$0000,$1e6d,$ff9e,$1f80
        dc.w    $0000,$3b5b,$0ffc,$0fbf,$0000,$d2d3,$0000,$ffff
        dc.w    $0000,$1c0f,$0000,$ffff,$0000,$b06d,$7ffe,$f9fc
        dc.w    $0000,$307f,$0ff8,$01f8,$0000,$fc0a,$0005,$0000
        dc.w    $0000,$d931,$e0fe,$0000,$0000,$fc65,$1f9e,$1f80
        dc.w    $0000,$6637,$1ff8,$0fff,$0000,$e51f,$0000,$ffff
        dc.w    $0000,$6d3f,$0000,$ffff,$0000,$5a5b,$3dfe,$fdfe
        dc.w    $0000,$6678,$1fff,$01f8,$0000,$0c0a,$f005,$0000
        dc.w    $0000,$4f67,$f0f8,$0000,$0000,$da45,$ffbe,$1f80
        dc.w    $0000,$cd6f,$3fff,$0fff,$0000,$99ff,$01c3,$ffff
        dc.w    $0000,$97fd,$87ff,$ffff,$0000,$ec3f,$ffff,$ffff
        dc.w    $0000,$c873,$3fff,$01f8,$0000,$e40a,$f805,$0000
        dc.w    $0000,$664f,$f9f3,$0000,$0000,$bc19,$dffe,$1f80
        dc.w    $0000,$9b5f,$7fef,$0fff,$0000,$d1df,$81e3,$ffff
        dc.w    $0000,$7f7b,$87ff,$ffff,$0000,$d66f,$ffff,$ffff
        dc.w    $0000,$926e,$fdff,$81f8,$0000,$341b,$f804,$0000
        dc.w    $0000,$32de,$fde7,$0000,$0000,$fa73,$1ffc,$1f80
        dc.w    $0000,$b63f,$7fcf,$0fff,$0000,$f1b6,$c1e3,$ffff
        dc.w    $0000,$aeff,$87ff,$ffff,$0000,$fa5f,$ffff,$ffff
        dc.w    $0000,$f65c,$f9ff,$c1f8,$0000,$9793,$780e,$0000
        dc.w    $0000,$9e91,$79ee,$0000,$0000,$9607,$7ff8,$1f80
        dc.w    $0000,$2d7d,$ff8f,$0fff,$0000,$c17d,$e1e3,$ffff
        dc.w    $0000,$875f,$8700,$ffff,$0000,$bc3f,$7bff,$ffff
        dc.w    $0000,$a479,$f9fe,$e1f8,$0000,$d0f7,$3f0e,$0000
        dc.w    $0000,$c4bf,$3bc0,$0000,$0000,$3e7d,$ff80,$1f80
        dc.w    $0000,$6b5b,$ff8f,$0fff,$0000,$b1df,$f1e3,$ffff
        dc.w    $0000,$677f,$8700,$ffff,$0000,$3a7b,$79ff,$ffff
        dc.w    $0000,$7c79,$f1fe,$f1f8,$0000,$da44,$3fbf,$0000
        dc.w    $0000,$fda6,$03c1,$0000,$0000,$5e59,$ffa0,$1f80
        dc.w    $0000,$5f5e,$ff8f,$1fff,$0000,$79be,$f9e3,$ffff
        dc.w    $0000,$861e,$8700,$ffff,$0000,$b859,$79fb,$fffb
        dc.w    $0000,$f86c,$ffff,$fff8,$0000,$cf5d,$3fbe,$0000
        dc.w    $0000,$cd24,$33c3,$0000,$0000,$1e00,$ffff,$ffff
        dc.w    $0000,$0f0e,$ffff,$ffff,$0000,$fd63,$ffff,$ffff
        dc.w    $0000,$8500,$ffff,$ffff,$0000,$3838,$ffff,$ffff
        dc.w    $0000,$fc58,$ffff,$ffff,$0000,$2373,$dfbc,$8000
        dc.w    $0000,$196c,$f783,$0001,$0000,$1e00,$ffff,$ffff
        dc.w    $0000,$0f0e,$ffff,$ffff,$0000,$7ee3,$ffff,$ffff
        dc.w    $0000,$8700,$ffff,$ffff,$0000,$3878,$ffff,$ffff
        dc.w    $0000,$7e38,$ffff,$ffff,$0000,$024e,$ffb1,$c000
        dc.w    $0000,$eb48,$f787,$0003,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$06d8,$ff27,$e000
        dc.w    $0000,$0a4c,$f787,$0007,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0cf3,$ff0f,$f000
        dc.w    $0000,$6acf,$970f,$000f,$0000,$ffff,$ffff,$ffff
        dc.w    $0000,$ffff,$ffff,$ffff,$0000,$ffff,$ffff,$ffff
        dc.w    $0000,$ffff,$ffff,$ffff,$0000,$ffff,$ffff,$ffff
        dc.w    $0000,$ffff,$ffff,$ffff,$0000,$f9a4,$fe1f,$f800
        dc.w    $0000,$ca6b,$3787,$0000,$0000,$1fb3,$ffcf,$1fc7
        dc.w    $0000,$fd7e,$8f8f,$ffff,$0000,$4ff7,$07e3,$ffff
        dc.w    $0000,$bbfb,$87ff,$ffff,$0000,$fe7d,$f9fb,$ffff
        dc.w    $0000,$87f8,$ffff,$cff8,$0000,$ff69,$001e,$0000
        dc.w    $0000,$5b39,$37c7,$0000,$0000,$df7f,$ffff,$1fff
        dc.w    $0000,$eb57,$ff86,$ffff,$0000,$47fb,$03e3,$ffff
        dc.w    $0000,$9df7,$83ff,$ffff,$0000,$fe70,$f9f9,$ffff
        dc.w    $0000,$dbee,$e7f9,$e7f8,$0000,$6c4b,$f03c,$0000
        dc.w    $0000,$598c,$37f3,$0000,$0000,$6eff,$ffff,$1fff
        dc.w    $0000,$f73f,$ff80,$ffff,$0000,$bff8,$0000,$ffff
        dc.w    $0000,$efc0,$0000,$ffff,$0000,$3c69,$01f8,$ffff
        dc.w    $0000,$65df,$fbf8,$f3f8,$0000,$2452,$f83c,$0000
        dc.w    $0000,$4ce0,$33ff,$0000,$0000,$cdff,$ffff,$0fff
        dc.w    $0000,$af7f,$ff80,$ffff,$0000,$f9f7,$0000,$ffff
        dc.w    $0000,$79e7,$0000,$ffff,$0000,$f958,$00f8,$ffff
        dc.w    $0000,$b6bd,$79fe,$f9f8,$0000,$b452,$783c,$0000
        dc.w    $0000,$663f,$19ff,$0000,$0000,$9fbf,$e7ff,$07ff
        dc.w    $0000,$7f7f,$ff80,$ffff,$0000,$63e7,$0000,$ffff
        dc.w    $0000,$7306,$0000,$ffff,$0000,$b8f0,$0078,$ffff
        dc.w    $0000,$1a7a,$3dff,$fcf8,$0000,$944a,$783c,$0000
        dc.w    $0000,$3380,$0c7f,$0000,$0000,$39fe,$c7ff,$03ff
        dc.w    $0000,$febc,$ff00,$ffff,$0000,$4baa,$0000,$ffff
        dc.w    $0000,$e61e,$0000,$ffff,$0000,$d1ec,$0038,$ffff
        dc.w    $0000,$2cba,$1fff,$fe78,$0000,$d46b,$381c,$0000
        dc.w    $0000,$f9ff,$0700,$0000,$0000,$e0dd,$1fe0,$01ff
        dc.w    $0000,$3e5a,$0000,$ffff,$0000,$8727,$0000,$ffff
        dc.w    $0000,$140b,$0000,$ffff,$0000,$c0da,$0000,$ffff
        dc.w    $0000,$96a4,$0fdf,$ff00,$0000,$d629,$381e,$0000
        dc.w    $0000,$6246,$9f81,$0000,$0000,$39b8,$ffc0,$03ff
        dc.w    $0000,$5d7f,$0000,$ffff,$0000,$17e7,$0000,$ffff
        dc.w    $0000,$005b,$0000,$ffff,$0000,$12c0,$0000,$ffff
        dc.w    $0000,$3b39,$07de,$ff80,$0000,$d224,$3c1f,$0000
        dc.w    $0000,$0cfb,$ff00,$0000,$0000,$8b60,$7f80,$07ff
        dc.w    $0000,$b3bf,$0000,$ffff,$0000,$1eee,$0000,$ffff
        dc.w    $0000,$03cc,$0000,$ffff,$0000,$c141,$0000,$ffff
        dc.w    $0000,$fda3,$03dc,$ffc0,$0000,$5a33,$3c0f,$0000
        dc.w    $0000,$f18c,$fe70,$0000,$0000,$e644,$1f00,$0fff
        dc.w    $0000,$525c,$0000,$ffff,$0000,$17cf,$0000,$ffff
        dc.w    $0000,$0718,$0000,$ffff,$0000,$c9e0,$0000,$ffff
        dc.w    $0000,$f6ce,$01f0,$ffe0,$0000,$4a18,$3c07,$0000
        dc.w    $0000,$07e4,$f8f8,$0000,$0000,$2980,$1e00,$1fff
        dc.w    $0000,$60e8,$0000,$ffff,$0000,$3f78,$0000,$ffff
        dc.w    $0000,$0f31,$0000,$ffff,$0000,$272b,$0000,$ffff
        dc.w    $0000,$d368,$00f0,$fff0,$0000,$4a0e,$3c01,$0000
        dc.w    $0000,$fdb4,$03f8,$0000,$0000,$1b02,$3c00,$3fff
        dc.w    $0000,$c070,$0000,$ffff,$0000,$5ec8,$0000,$ffff
        dc.w    $0000,$1e76,$0000,$ffff,$0000,$1797,$0000,$ffff
        dc.w    $0000,$8cb0,$0078,$fff8,$0000,$5a0f,$3c00,$0000
        dc.w    $0000,$ff1f,$ffe0,$0000,$0000,$a795,$7800,$7fff
        dc.w    $0000,$80c2,$0000,$ffff,$0000,$fb80,$0000,$ffff
        dc.w    $0000,$6fdc,$0000,$ffff,$0000,$7f4f,$0000,$ffff
        dc.w    $0000,$08d8,$003c,$fffc,$0000,$5a78,$3c07,$0000
        dc.w    $0000,$8070,$ff8f,$0000,$0000,$6d3f,$f000,$ffff
        dc.w    $0000,$815f,$0000,$ffff,$0000,$7c00,$0000,$ffff
        dc.w    $0000,$ee71,$0000,$ffff,$0000,$ffbc,$0000,$ffff
        dc.w    $0000,$1cac,$001e,$fffe,$0000,$d3c3,$3c3f,$0000
        dc.w    $0000,$3fc7,$c03f,$0000,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$000c,$fffe,$fffe,$0000,$971e,$78ff,$0000
        dc.w    $0000,$ee1c,$01ff,$0000,$0000,$157f,$ffff,$ffff
        dc.w    $0000,$ffff,$ffff,$ffff,$0000,$ffff,$ffff,$ffff
        dc.w    $0000,$ffff,$ffff,$ffff,$0000,$ffff,$ffff,$ffff
        dc.w    $0000,$fff9,$fffe,$fffe,$0000,$b670,$79ff,$0000
        dc.w    $0000,$98f1,$07fe,$0000,$0000,$8000,$7fff,$7fff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0002,$fffd,$fffc,$0000,$24c7,$fbf8,$0000


needs_no:


        dc.w    $0000,$0000,$3fff,$3fff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0076,$ffb8,$ff80
        dc.w    $0000,$8bff,$7fff,$7fff,$0000,$df7f,$ffff,$ffff
        dc.w    $0000,$ffff,$ffff,$ffff,$0000,$ffeb,$ffff,$ffff
        dc.w    $0000,$7bff,$ffff,$ffff,$0000,$ffff,$ffff,$ffff
        dc.w    $0000,$feef,$ffff,$ffff,$0000,$7fff,$ffff,$ffff
        dc.w    $0000,$ffff,$ffff,$ffff,$0000,$ffff,$ffff,$ffff
        dc.w    $0000,$ffef,$ffff,$ffff,$0000,$ef13,$fffc,$ffc0
        dc.w    $0000,$a000,$7fff,$7fff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0188,$ffff,$ffc0
        dc.w    $0000,$2fff,$f000,$7fff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$feae,$01df,$ffc0
        dc.w    $0000,$8fff,$f000,$7fff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$fea3,$01df,$ffc0
        dc.w    $0000,$2fff,$f000,$7fff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$feb8,$01c7,$ffc0
        dc.w    $0000,$2fff,$f000,$7fff,$0000,$cc40,$0080,$ffff
        dc.w    $0000,$4040,$8081,$ffff,$0000,$e07f,$0080,$ffff
        dc.w    $0000,$3383,$0204,$ffff,$0000,$fe04,$0008,$ffff
        dc.w    $0000,$4604,$8808,$ffff,$0000,$060c,$0810,$ffff
        dc.w    $0000,$4604,$8808,$ffff,$0000,$461c,$8810,$ffff
        dc.w    $0000,$0e07,$1008,$ffff,$0000,$0e8f,$11c0,$ffc0
        dc.w    $0000,$afff,$7000,$7fff,$0000,$c447,$0088,$ffff
        dc.w    $0000,$c7c4,$0808,$ffff,$0000,$47ff,$8800,$ffff
        dc.w    $0000,$1111,$0222,$ffff,$0000,$fc7c,$0080,$ffff
        dc.w    $0000,$4c7f,$8880,$ffff,$0000,$1cc4,$2088,$ffff
        dc.w    $0000,$0c7c,$0880,$ffff,$0000,$473c,$8820,$ffff
        dc.w    $0000,$447f,$8880,$ffff,$0000,$0e03,$11c0,$ffc0
        dc.w    $0000,$2fff,$f000,$7fff,$0000,$c040,$0081,$ffff
        dc.w    $0000,$c0c4,$0008,$ffff,$0000,$e0ff,$8100,$ffff
        dc.w    $0000,$0311,$0222,$ffff,$0000,$fc7c,$0080,$ffff
        dc.w    $0000,$4e0f,$8810,$ffff,$0000,$1ccc,$2088,$ffff
        dc.w    $0000,$04fc,$0880,$ffff,$0000,$071c,$0820,$ffff
        dc.w    $0000,$0e0f,$1010,$ffff,$0000,$0e8e,$11c1,$ffc0
        dc.w    $0000,$ac44,$f088,$7fff,$0000,$44c7,$8888,$ffff
        dc.w    $0000,$c7c4,$0808,$ffff,$0000,$7c7f,$8080,$ffff
        dc.w    $0000,$1111,$2222,$ffff,$0000,$fc7c,$0080,$ffff
        dc.w    $0000,$47c7,$8808,$ffff,$0000,$3c44,$2088,$ffff
        dc.w    $0000,$4c7c,$8880,$ffff,$0000,$471c,$8820,$ffff
        dc.w    $0000,$7fc7,$8008,$ffff,$0000,$fe98,$01c7,$ffc0
        dc.w    $0000,$8c44,$f088,$7fff,$0000,$4640,$8880,$ffff
        dc.w    $0000,$40c0,$8081,$ffff,$0000,$c0ff,$0100,$ffff
        dc.w    $0000,$1983,$2204,$ffff,$0000,$fe06,$0008,$ffff
        dc.w    $0000,$040f,$0810,$ffff,$0000,$3e0c,$2010,$ffff
        dc.w    $0000,$4604,$8808,$ffff,$0000,$c60c,$8810,$ffff
        dc.w    $0000,$fc0f,$8010,$ffff,$0000,$0ebf,$11c3,$ffc0
        dc.w    $0000,$2fff,$f000,$7fff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$fe86,$01f9,$ffc0
        dc.w    $0000,$afff,$7000,$7fff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$fe32,$01fd,$ffc0
        dc.w    $0000,$8fff,$7000,$7fff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
        dc.w    $0000,$ffff,$0000,$ffff,$0000,$fe9b,$01fc,$ffc0
        dc.w    $0000,$2000,$7fff,$7fff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0089,$fffe,$ffc0
        dc.w    $0000,$0bff,$7fff,$7fff,$0000,$d7ff,$ffff,$ffff
        dc.w    $0000,$ffff,$ffff,$ffff,$0000,$ffff,$ffff,$ffff
        dc.w    $0000,$fff7,$ffff,$ffff,$0000,$af7f,$ffff,$ffff
        dc.w    $0000,$ffff,$ffff,$ffff,$0000,$fdbd,$ffff,$ffff
        dc.w    $0000,$fbff,$ffff,$ffff,$0000,$ffff,$ffff,$ffff
        dc.w    $0000,$fffe,$ffff,$ffff,$0000,$de2d,$ffde,$ffc0
        dc.w    $0000,$4000,$3fff,$3fff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
        dc.w    $0000,$0000,$ffff,$ffff,$0000,$0065,$ff9e,$ff80






colpaltab:
        dc.w    $700,$710,$720,$730,$740,$750,$760
        dc.w    $770,$670,$570,$470,$370,$270,$170
        dc.w    $070,$071,$072,$073,$074,$075,$076
        dc.w    $077,$067,$057,$047,$037,$027,$017
        dc.w    $007,$107,$207,$307,$407,$507,$607
        dc.w    $707,$706,$705,$704,$703,$702,$701


palette1:
        dc.w    $0000,$0777,$0300,$0777,$0500,$0777,$0710,$0777
        dc.w    $0223,$0223,$0334,$0334,$0445,$0445,$0567,$0567


;stck:  blk.l   100
;ustck: dc.l    0
samplen:        equ     56391
samplin:
        blk.b   samplen
        even
endsamp:
        dc.w    0
epd:    dc.l    0
ewd:    equ     epd+$100
emd:    equ     $51000


