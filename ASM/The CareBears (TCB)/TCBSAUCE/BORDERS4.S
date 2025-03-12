
x:
        bra     main


slack:
        move.l  oldcurradd,a1
        moveq   #17,d0
        move.l  currpicadd,a0
oms1:   move.l  (a0)+,d1
        move.l  (a0)+,d2
        move.l  (a0)+,d3
        move.l  (a0)+,d4

        move.l  d1,-(a1)
        move.l  d2,-(a1)
        move.l  d3,-(a1)
        move.l  d1,-(a1)
        move.l  d3,-(a1)
        move.l  d4,-(a1)
        move.l  d1,-(a1)
        move.l  d3,-(a1)
        move.l  d2,-(a1)
        move.l  d4,-(a1)
;       move.l  d1,-(a1)
;       move.l  d2,-(a1)
;       move.l  d1,-(a1)
;       move.l  d2,-(a1)
        lea     -190(a1),a1
        dbra    d0,oms1
        rts
        
        

dist:
        move.l  currpicadd,a1
        lea     19308(a1),a1
        move.l  a1,oldcurradd
        lea     shifteddistblocks,a0
        lea     720(a0),a0
        lea     disttab(pc),a2
        moveq   #17,d0
omd1:   
        add.l   (a2)+,a0
;       movem.l 40(a0),d1-d4
;       movem.l d1-d4,-(a1)
        movem.l 20(a0),d1-d4/a3
        movem.l d1-d4/a3,-(a1)
        movem.l (a0),d1-d4/a3
        movem.l d1-d4/a3,-(a1)
        lea     -190(a1),a1
        dbra    d0,omd1

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
        and.w   #7,distsortpos
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
        mulu    #720,d0
        sub.l   #40,d0
        move.l  d0,(a0)+
        sub.l   d0,(a0)
        sub.l   #40,(a0)
        rts



disttab:        dc.l    4320
                blk.l   30,-40
distpos:        dc.w    0
distsortpos:    dc.w    0
distsorttab:    dc.w    0,0,50,50,0,0,50,50
distsort:       dc.w    0       

disttabx:

;       dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5
;       dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5
;       dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5
;       dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5
;       dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5

        dc.w     6, 7, 8, 9,10,11,10, 9, 8, 7
        dc.w     6, 5, 4, 3, 2, 1, 0, 1, 2, 3
        dc.w     4, 5, 6, 7, 8, 9,10,11,10, 9
        dc.w     8, 7, 6, 5, 4, 3, 2, 1, 0, 1
        dc.w     2, 3, 4, 5, 6, 5, 4, 3, 4, 5

        dc.w     6, 7, 8, 7, 6, 5, 4, 5, 6, 7
        dc.w     8, 7, 6, 5, 4, 5, 6, 7, 8, 7
        dc.w     6, 5, 4, 5, 6, 7, 8, 7, 6, 5
        dc.w     4, 5, 6, 7, 8, 6, 5, 4, 5, 6
        dc.w     7, 8, 7, 6, 5, 4, 5, 6, 7, 8

;       dc.w     6, 6, 7, 8, 8, 9, 9,10,10,10
;       dc.w    11,11,11,11,11,11,10,10,10, 9
;       dc.w     9, 8, 8, 7, 6, 6, 5, 4, 3, 3
;       dc.w     2, 2, 1, 1, 1, 0, 0, 0, 0, 0
;       dc.w     0, 1, 1, 1, 2, 2, 3, 3, 4, 5;

;       dc.w     6, 7, 8, 9, 9,10,10,10,10, 9
;       dc.w     8, 7, 6, 5, 4, 3, 2, 1, 1, 1
;       dc.w     1, 2, 2, 3, 4, 6, 7, 8, 9, 9
;       dc.w    10,10,10,10, 9, 8, 7, 6, 5, 4
;       dc.w     3, 2, 1, 1, 1, 1, 2, 2, 3, 4
       



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









shiftdistblocks:
        lea     shifteddistblocks,a1
        moveq   #11,d7
omsdb1: move.l  d7,-(sp)
;       addq.l  #2,d7
        moveq   #15,d0
        sub.l   d7,d0
        lea     unshifteddistblock(pc),a0
        moveq   #17,d1
omsdb2:
        moveq   #3,d2
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

        lea     $70000,a1
        lea     shifteddistblocks,a0
        move.l  #1079,d0
omsdb7:
        move.w  (a0),d1
        or.w    2(a0),d1
        or.w    4(a0),d1
        or.w    6(a0),d1
        not.w   d1
        move.w  (a1)+,d2
        and.w   d1,d2
        or.w    d2,(a0)+
        move.w  (a1)+,d2
        and.w   d1,d2
        or.w    d2,(a0)+
        move.w  (a1)+,d2
        and.w   d1,d2
        or.w    d2,(a0)+
        move.w  (a1)+,d2
        and.w   d1,d2
        or.w    d2,(a0)+
        dbra    d0,omsdb7
        
        rts



unshifteddistblock:
;
; NEOchrome cut buffer contents (left justified):
;
;    pixels/scanline    = $0040 (bytes/scanline: $0020)
;  # scanlines (height) = $0012
;
;  Hardware color pallet  (color 0 to 15):
;
;      $0000,$0777,$0555,$0444,$0333,$0222,$0111,$0000
;      $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0777
;
;
        dc.w    $6966,$999E,$0601,$0000,$C065,$F0E6,$0898,$0000
        dc.w    $C8CD,$3B13,$0400,$0000,$2CD0,$33D4,$C02C,$0000
        dc.w    $371B,$4FFB,$8004,$0000,$08AD,$F36E,$1A10,$0000
        dc.w    $B786,$7449,$08D0,$0000,$E36E,$FF7C,$0082,$0000
        dc.w    $8CCC,$1595,$E3E3,$0000,$D2B3,$8169,$FA07,$0000
        dc.w    $6616,$BDC2,$C3D9,$0000,$666A,$CAC9,$F1F7,$0000
        dc.w    $CCCC,$3B7B,$C787,$0000,$D533,$6256,$9C8F,$0000
        dc.w    $66DE,$5305,$8FDB,$0000,$6664,$BDBF,$C3C3,$0000
        dc.w    $B333,$1656,$CF8F,$0000,$3ECC,$47A6,$981F,$0000
        dc.w    $9911,$F6C3,$0FDF,$0000,$9998,$2B2B,$C7C7,$0000
        dc.w    $4CCC,$66A6,$9F1F,$0000,$CB33,$B3ED,$1C1E,$0000
        dc.w    $6606,$ACC3,$1FDF,$0000,$6664,$5353,$8F8F,$0000
        dc.w    $9243,$E0D4,$7F3F,$0000,$B126,$2898,$DE7F,$0000
        dc.w    $461B,$3853,$FFCC,$0000,$97A4,$EF6F,$001F,$0000
        dc.w    $26B4,$4113,$FE7F,$0000,$98C1,$11BE,$EE7F,$0000
        dc.w    $8311,$7C15,$FFCE,$0000,$9998,$4D4F,$3E3F,$0000
        dc.w    $0138,$00E0,$007C,$0000,$02C0,$0678,$01F8,$0000
        dc.w    $0019,$001A,$0004,$0000,$9992,$B2BC,$7C7E,$0000
        dc.w    $0048,$01E0,$007C,$0000,$0138,$06C0,$01F8,$0000
        dc.w    $0006,$001D,$0000,$0000,$6663,$3530,$F8FF,$0000
        dc.w    $00B8,$0150,$006C,$0000,$06D4,$0187,$01F8,$0000
        dc.w    $4681,$BF5F,$0000,$0000,$999A,$6F6D,$F0F3,$0000
        dc.w    $01B4,$0028,$004C,$0000,$06CE,$016F,$0190,$0000
        dc.w    $6919,$9E44,$00C3,$0000,$DD98,$E3D7,$0023,$0000
        dc.w    $0144,$00F8,$000C,$0000,$0133,$0656,$018F,$0000
        dc.w    $6606,$53DD,$8FC3,$0000,$6664,$BDBF,$C3C3,$0000
        dc.w    $0034,$01D8,$000C,$0000,$05CC,$07A6,$001F,$0000
        dc.w    $9901,$F6DB,$0FC7,$0000,$9998,$2B2B,$C7C7,$0000
        dc.w    $01B0,$01EC,$001C,$0000,$02CC,$06D9,$053E,$0000
        dc.w    $99D9,$4D1E,$3EC7,$0000,$999F,$F6F0,$0F0F,$0000
        dc.w    $01C0,$01DC,$003C,$0000,$0373,$01DA,$023C,$0000
        dc.w    $661E,$DB1C,$3CC7,$0000,$666A,$ACA1,$1F1F,$0000
        dc.w    $0090,$010C,$01FC,$0000,$01A8,$0090,$017F,$0000
        dc.w    $C05D,$3F90,$FFCF,$0000,$1DC4,$E03A,$FFFE,$0000
        dc.w    $0198,$0004,$01FC,$0000,$0058,$0020,$007F,$0000
        dc.w    $3008,$0FD0,$FFDF,$0000,$8870,$700C,$FFFC,$0000


currpicadd:
        dc.l    0
oldcurradd:
        dc.l    0

;************
vsyn:
 movem.l d0-d7/a0-a3/a5-a6,-(sp)
; move #$2700,sr
        move.l a4,d7
        add.l #33,d7    ;24
; 62 when ready!, normally
        move.w  #$2100,sr

;       bsr     chksmp
        bsr     slack
        bsr     distit
        tst.b   distquest
        beq     forbivs4
        bsr     dist
forbivs4:

        addq.l  #4,pictabpos
        and.l   #63,pictabpos
        lea     pictab(pc),a0
        add.l   pictabpos,a0
        move.l  (a0),d0
        move.l  d0,currpicadd
        lsr.l   #8,d0
        move.b  d0,$ff8203
        lsr     #8,d0
        move.b  d0,$ff8201

        cmp.l   #endoffirstpart,a4
        bls     forbiallt
 lea $ff8209,a0
 lea $ff8260,a1
 lea $fffa21,a2
 lea $ff8241,a3

 moveq #0,d0
 moveq #0,d1
 moveq #16,d2
 moveq #2,d3
 moveq #0,d4

;tbsyncloop:
; cmp.b #199,(a2)
; bne tbsyncloop



waitis: cmp.l   d7,a4
        blt.s   waitis
        move.w  #$2700,sr
        moveq   #8,d0
omw1:   dbf     d0,omw1
        move.w  #$00,$ffff8240.w        ;70
        clr.b   $ffff820a.w
        moveq   #3,d0
omw2:   nop
        dbf     d0,omw2
        move.w  #2,$ffff820a.w  
        move.w  #$000,$ffff8240.w       ;700
;       move.w  #$2100,sr
;       add.l   #2,d7
;waitis2:
;       cmp.l   d7,a4
;       blt.s   waitis2
;       move.w  #$2700,sr
;       bra     forbiallt

waitloop27:
 move.b (a0),d0
 beq.s waitloop27

; move.w #$2700,sr      ;???????????? 16
 sub d0,d2
 lsl.w d2,d1

;       moveq   #18,d0
;ommmm: nop
;       dbf     d0,ommmm
;       nop

anfang2:

; nop

 lea $ffff8800.w,a6

; nop
; nop
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

 moveq #14,d0
delayloop21:
 nop
 dbra d0,delayloop21

 lea $ff820a,a0
 move #227,d0
zeilenloop22:


 nop

;monochromeumschaltung fuer linken rand

 move.b d3,(a1)
 move.b d4,(a1)

 moveq #12,d1
delayloop22:
 nop
 dbra d1,delayloop22

 nop
        lea     imptab(pc),a5   ;12
        moveq   #0,d5           ;4
        move.b  (a4)+,d5        ;8
        lsl.w   #3,d5           ;12
        move.l  (a5,d5.w),d6    ;18 /20
        move.w  4(a5,d5.w),d5   ;14 /16
        lea     $ffff8800.w,a5  ;12 /8
        movep.l d6,0(a5)        ;24
        movep.w d5,0(a5)        ;16
;                               120
; or 4 cycles wrong!
;************************
 nop

;***********************


; nop
 nop
 nop

;50/60 Hz fuer rechten rand
 move.b d4,(a0)
 move.b d3,(a0)

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

 move.b d3,(a1)
 nop
 move.b d4,(a1)

 
 nop
 nop
 nop
 nop
 nop

 nop
 nop
 nop
 nop

 dbra d0,zeilenloop22
        move.w  #$000,$ffff8240.w       ;777
        clr.b   $ffff820a.w
        moveq   #3,d0
omw28:  nop
        dbf     d0,omw28
        move.w  #2,$ffff820a.w  
        move.w  #$000,$ffff8240.w       ;700

forbiallt:
 move.w #$000,$ffff8240.w
 cmp.b  #185,$fffc02
 bne    forbivs3
 move.l #vsyndummy,$70
forbivs3:
 bsr    chksmp
 movem.l (sp)+,d0-d7/a0-a3/a5-a6
; bclr #0,$fffa0f
 rte

vsyndummy:
        rte

hsyn:
;       add.w   #$123,$ffff8240.w
;       lea     imptab(pc),a5   ;12
        moveq   #0,d5           ;4
        move.b  (a4)+,d5        ;8
        lsl.w   #3,d5           ;12
        move.l  (a5,d5.w),d6    ;18 /20
        move.w  4(a5,d5.w),d5   ;14 /16
;       lea     $ffff8800.w,a5  ;12 /8
        movep.l d6,0(a6)        ;24
        movep.w d5,0(a6)        ;16
        rte



chksmp:
        cmp.l   #endoffirstpart,a4
        bls     forbics2
        cmp.l   #endoffirstpart,a4
        blt     forbics2
        st      bordersquest
forbics2:
        cmp.l   #endofsecondpart,a4
        bls     forbics3
        st      distquest
forbics3:
        cmp.l   #endsamp,a4
        bls     forbics1
        sub.l   #samplen,a4
        clr.b   bordersquest
        clr.b   distquest
        move.w  #0,bordersquest
        move.b #2,$ff820a
forbics1:
        rts

bordersquest:
        dc.b    0
distquest:
        dc.b    0
picpos: equ     $70000
pictab: dc.l    picpos+$000,picpos+$700,picpos+$300,picpos+$900
        dc.l    picpos+$500,picpos+$200,picpos+$a00,picpos+$100
        dc.l    picpos+$600,picpos+$f00,picpos+$000,picpos+$d00
        dc.l    picpos+$800,picpos+$e00,picpos+$b00,picpos+$400
pictabpos:
        dc.l    0




randomizescreen:
 lea $70000,a0
 moveq #0,d1
 move #15000,d0
clsloop2:
 move.l d1,(a0)+
 dbra d0,clsloop2

 lea $70000,a0
 move.l a0,currpicadd
 move.l a0,oldcurradd
 add.l #2000,oldcurradd
 move.l #$75831639,d1
 move #30000,d0 ;260104
clsloop:
 eor.l d1,(a0)
 addq   #2,a0
 add.l #$74928123,d1
 eor.l #$52345679,d1
 rol.l #3,d1
; eor.l d0,d1
 dbra d0,clsloop
 rts


initvsync:

 move.b #0,$fffa1d

 move #0,$ff8240

 move #2,-(sp)
 trap #14
 addq.l #2,sp
 move.l d0,orgram

 move.l #$70000,d0
 lsr.l #8,d0
 move.b d0,$ff8203
 lsr #8,d0
 move.b d0,$ff8201

 move.l #$70000+5280,vidram


 move #37,-(sp)
 trap #14
 addq.l #2,sp

 move.b #2,$ff820a
 move.b #0,$ff8260

 movem.l palette,d0-d7
 movem.l d0-d7,$ff8240

 move #37,-(sp)
 trap #14
 addq.l #2,sp

;timer_b installieren
; move.l #timer_b,$120
; move.b #0,$fffa1b
; move.b #31,$fffa21
; move.b #8,$fffa1b
; move.b #200,$fffa21
; bset #0,$fffa07
; bset #0,$fffa13
 move.b $fffa07,mfpiea
 move.b $fffa09,mfpieb
 move.b #0,$fffa07
 move.b #0,$fffa09
 move.l $70,oldvsyn
 move.l #vsyn,$70
 move.l $68,oldhsync
 move.l #hsyn,$68
 move.w #$2100,sr
 rts

oldhsync:       dc.l    0

restorevsync:
 move.w #$2700,sr
 move.b #0,$fffa1b
; bclr #0,$fffa07
; bclr #0,$fffa13
 move.b mfpiea,$fffa07
 move.b mfpieb,$fffa09
 move.b #$51,$fffa1d

 move.l oldhsync,$68
 move.l oldvsyn,$70
 move #$777,$ff8240
 move #0,$ff8240+6

 move.b #1,$ff8260
 move.b #2,$ff820a

 move.l orgram,d0
 lsr.l #8,d0
 move.b d0,$ff8203
 lsr #8,d0
 move.b d0,$ff8201
 move.w #$2300,sr 
rts

mfpiea: dc.b    0
mfpieb: dc.b    0

intsamp:
        moveq   #10,d0
setregs:
        move.b  d0,$fff8800
        clr.b   $fff8802
        dbf     d0,setregs
        clr.b   $fff8800
        clr.b   $fff8802
        move.b  #7,$fff8800
        move.b  #$ff,$fff8802
        lea     samplin,a4
        lea     imptab(pc),a5   ;12
        lea     $ffff8800.w,a6  ;12 /8
        rts


main:
        lea     $60000,a7
        bsr     randomizescreen
        bsr     shiftdistblocks
        bsr     intsamp
        bsr     initvsync
wait:   bsr     chksmp
        cmp.b   #185,$fffc02
        bne     wait
        bsr     restorevsync
        move.w  #$2300,sr
        illegal



 even


palette:
 dc.w   $000,$666,$555,$444,$333,$222,$111,$000
 dc.w   $444,$333,$666,$111,$000,$555,$777,$222
; dc.w $0000,$0076,$0210,$0650,$0320,$0760,$0540,$0430
; dc.w $0527,$0111,$0222,$0333,$0444,$0555,$0666,$0777

kasten:
  dc.w $0001,$0000,$FFFF,$FFFF,$7FFD,$7FFC,$8003,$FFFF
  dc.w $4005,$7FFC,$8003,$FFFF,$5FF5,$7FFC,$8003,$FFFF
  dc.w $5015,$701C,$8FE3,$FFFF,$57D5,$701C,$8FE3,$FFFF
  dc.w $5455,$739C,$8FE3,$FFFF,$5555,$739C,$8FE3,$FFFF
  dc.w $5455,$739C,$8FE3,$FFFF,$57D5,$701C,$8FE3,$FFFF
  dc.w $5015,$701C,$8FE3,$FFFF,$5FF5,$7FFC,$8003,$FFFF
  dc.w $4005,$7FFC,$8003,$FFFF,$7FFD,$7FFC,$8003,$FFFF
  dc.w $0001,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF


 EVEN

bitcount: dc.w 0
textpos: dc.l 0

orgram: dc.l 0
vidram: dc.l 0
oldvsyn: dc.l 0

;bpuffer:


imptab:          ;this is the output from "IMPACT" it's not our own
 dc.w $80E,$90D,$A0C,$0,$80F,$903,$A00,$0,$80F,$903,$A00,$0,$80F,$903,$A00,0
 dc.w $80F,$903,$A00,$0,$80F,$903,$A00,$0,$80F,$903,$A00,$0,$80E,$90D,$A0B,0
 dc.w $80E,$90D,$A0B,$0,$80E,$90D,$A0B,$0,$80E,$90D,$A0B,$0,$80E,$90D,$A0B,0
 dc.w $80E,$90D,$A0B,$0,$80E,$90D,$A0B,$0,$80E,$90D,$A0A,$0,$80E,$90D,$A0A,0
 dc.w $80E,$90D,$A0A,$0,$80E,$90D,$A0A,$0,$80E,$90C,$A0C,$0,$80E,$90D,$A00,0
 dc.w $80D,$90D,$A0D,$0,$80D,$90D,$A0D,$0,$80D,$90D,$A0D,$0,$80D,$90D,$A0D,0
 dc.w $80D,$90D,$A0D,$0,$80D,$90D,$A0D,$0,$80E,$90C,$A0B,$0,$80E,$90C,$A0B,0
 dc.w $80E,$90C,$A0B,$0,$80E,$90C,$A0B,$0,$80E,$90C,$A0B,$0,$80E,$90C,$A0B,0
 dc.w $80E,$90C,$A0B,$0,$80E,$90C,$A0B,$0,$80E,$90C,$A0A,$0,$80E,$90C,$A0A,0
 dc.w $80E,$90C,$A0A,$0,$80E,$90C,$A0A,$0,$80D,$90D,$A0C,$0,$80D,$90D,$A0C,0
 dc.w $80E,$90C,$A09,$0,$80E,$90C,$A09,$0,$80E,$90C,$A05,$0,$80E,$90C,$A00,0
 dc.w $80E,$90C,$A00,$0,$80E,$90B,$A0B,$0,$80E,$90B,$A0B,$0,$80E,$90B,$A0B,0
 dc.w $80E,$90B,$A0B,$0,$80E,$90B,$A0A,$0,$80E,$90B,$A0A,$0,$80E,$90B,$A0A,0
 dc.w $80D,$90D,$A0B,$0,$80D,$90D,$A0B,$0,$80D,$90D,$A0B,$0,$80E,$90B,$A09,0
 dc.w $80E,$90B,$A09,$0,$80E,$90B,$A09,$0,$80D,$90C,$A0C,$0,$80D,$90D,$A0A,0
 dc.w $80E,$90B,$A07,$0,$80E,$90B,$A00,$0,$80E,$90B,$A00,$0,$80D,$90D,$A09,0
 dc.w $80D,$90D,$A09,$0,$80E,$90A,$A09,$0,$80D,$90D,$A08,$0,$80D,$90D,$A07,0
 dc.w $80D,$90D,$A04,$0,$80D,$90D,$A00,$0,$80E,$90A,$A04,$0,$80E,$909,$A09,0
 dc.w $80E,$909,$A09,$0,$80D,$90C,$A0B,$0,$80E,$909,$A08,$0,$80E,$909,$A08,0
 dc.w $80E,$909,$A07,$0,$80E,$908,$A08,$0,$80E,$909,$A01,$0,$80C,$90C,$A0C,0
 dc.w $80D,$90C,$A0A,$0,$80E,$908,$A06,$0,$80E,$907,$A07,$0,$80E,$908,$A00,0
 dc.w $80E,$907,$A05,$0,$80E,$906,$A06,$0,$80D,$90C,$A09,$0,$80E,$905,$A05,0
 dc.w $80E,$904,$A04,$0,$80D,$90C,$A08,$0,$80D,$90B,$A0B,$0,$80E,$900,$A00,0
 dc.w $80D,$90C,$A06,$0,$80D,$90C,$A05,$0,$80D,$90C,$A02,$0,$80C,$90C,$A0B,0
 dc.w $80C,$90C,$A0B,$0,$80D,$90B,$A0A,$0,$80D,$90B,$A0A,$0,$80D,$90B,$A0A,0
 dc.w $80D,$90B,$A0A,$0,$80C,$90C,$A0A,$0,$80C,$90C,$A0A,$0,$80C,$90C,$A0A,0
 dc.w $80D,$90B,$A09,$0,$80D,$90B,$A09,$0,$80D,$90A,$A0A,$0,$80D,$90A,$A0A,0
 dc.w $80D,$90A,$A0A,$0,$80C,$90C,$A09,$0,$80C,$90C,$A09,$0,$80C,$90C,$A09,0
 dc.w $80D,$90B,$A06,$0,$80C,$90B,$A0B,$0,$80C,$90C,$A08,$0,$80D,$90B,$A00,0
 dc.w $80D,$90B,$A00,$0,$80C,$90C,$A07,$0,$80C,$90C,$A06,$0,$80C,$90C,$A05,0
 dc.w $80C,$90C,$A03,$0,$80C,$90C,$A01,$0,$80C,$90B,$A0A,$0,$80D,$90A,$A05,0
 dc.w $80D,$90A,$A04,$0,$80D,$90A,$A02,$0,$80D,$909,$A08,$0,$80D,$909,$A08,0
 dc.w $80C,$90B,$A09,$0,$80C,$90B,$A09,$0,$80D,$908,$A08,$0,$80B,$90B,$A0B,0
 dc.w $80D,$909,$A05,$0,$80C,$90B,$A08,$0,$80D,$909,$A02,$0,$80D,$908,$A06,0
 dc.w $80C,$90B,$A07,$0,$80D,$907,$A07,$0,$80C,$90B,$A06,$0,$80C,$90A,$A09,0
 dc.w $80B,$90B,$A0A,$0,$80C,$90B,$A02,$0,$80C,$90B,$A00,$0,$80C,$90A,$A08,0
 dc.w $80D,$906,$A04,$0,$80D,$905,$A05,$0,$80D,$905,$A04,$0,$80C,$909,$A09,0
 dc.w $80D,$904,$A03,$0,$80B,$90B,$A09,$0,$80C,$90A,$A05,$0,$80B,$90A,$A0A,0
 dc.w $80C,$909,$A08,$0,$80B,$90B,$A08,$0,$80C,$90A,$A00,$0,$80C,$90A,$A00,0
 dc.w $80C,$909,$A07,$0,$80B,$90B,$A07,$0,$80C,$909,$A06,$0,$80B,$90B,$A06,0
 dc.w $80B,$90A,$A09,$0,$80B,$90B,$A05,$0,$80A,$90A,$A0A,$0,$80B,$90B,$A02,0
 dc.w $80B,$90A,$A08,$0,$80C,$907,$A07,$0,$80C,$908,$A04,$0,$80C,$907,$A06,0
 dc.w $80B,$909,$A09,$0,$80C,$906,$A06,$0,$80A,$90A,$A09,$0,$80C,$907,$A03,0
 dc.w $80B,$90A,$A05,$0,$80B,$909,$A08,$0,$80B,$90A,$A03,$0,$80A,$90A,$A08,0
 dc.w $80B,$90A,$A00,$0,$80B,$909,$A07,$0,$80B,$908,$A08,$0,$80A,$90A,$A07,0
 dc.w $80A,$909,$A09,$0,$80C,$901,$A01,$0,$80A,$90A,$A06,$0,$80B,$908,$A07,0
 dc.w $80A,$90A,$A05,$0,$80A,$909,$A08,$0,$80A,$90A,$A02,$0,$80A,$90A,$A01,0
 dc.w $80A,$90A,$A00,$0,$809,$909,$A09,$0,$80A,$908,$A08,$0,$80B,$908,$A01,0
 dc.w $80A,$909,$A06,$0,$80B,$907,$A04,$0,$80A,$909,$A05,$0,$809,$909,$A08,0
 dc.w $80A,$909,$A03,$0,$80A,$908,$A06,$0,$80A,$909,$A00,$0,$809,$909,$A07,0
 dc.w $809,$908,$A08,$0,$80A,$908,$A04,$0,$809,$909,$A06,$0,$80A,$908,$A01,0
 dc.w $809,$909,$A05,$0,$809,$908,$A07,$0,$808,$908,$A08,$0,$809,$909,$A02,0
 dc.w $809,$908,$A06,$0,$809,$909,$A00,$0,$809,$907,$A07,$0,$808,$908,$A07,0
 dc.w $809,$907,$A06,$0,$809,$908,$A02,$0,$808,$908,$A06,$0,$809,$906,$A06,0
 dc.w $808,$907,$A07,$0,$808,$908,$A04,$0,$808,$907,$A06,$0,$808,$908,$A02,0
 dc.w $807,$907,$A07,$0,$808,$906,$A06,$0,$808,$907,$A04,$0,$807,$907,$A06,0
 dc.w $808,$906,$A05,$0,$808,$906,$A04,$0,$807,$906,$A06,$0,$807,$907,$A04,0
 dc.w $808,$905,$A04,$0,$806,$906,$A06,$0,$807,$906,$A04,$0,$807,$905,$A05,0
 dc.w $806,$906,$A05,$0,$806,$906,$A04,$0,$806,$905,$A05,$0,$806,$906,$A02,0
 dc.w $806,$905,$A04,$0,$805,$905,$A05,$0,$806,$905,$A02,$0,$805,$905,$A04,0
 dc.w $805,$904,$A04,$0,$805,$905,$A02,$0,$804,$904,$A04,$0,$804,$904,$A03,0
 dc.w $804,$904,$A02,$0,$804,$903,$A03,$0,$803,$903,$A03,$0,$803,$903,$A02,0
 dc.w $803,$902,$A02,$0,$802,$902,$A02,$0,$802,$902,$A01,$0,$801,$901,$A01,0
 dc.w $802,$901,$A00,$0,$801,$901,$A00,$0,$801,$900,$A00,$0,$800,$900,$A00,0

shifteddistblocks:
        blk.l   5600,0

samplen:        equ     179251
samplin:
endsamp:        equ     samplin+samplen
endoffirstpart: equ     samplin+59855
endofsecondpart: equ    samplin+119501

