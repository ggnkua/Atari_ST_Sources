start:
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	MOVE.L	#0,$4D2
	MOVE.L	#0,$4D6
	move.w	#0,$FF8900
	MOVE.W	#$486,$FFFF8922
        ;pea     no_cursor
        ;move.w  #9,-(sp)
        ;trap    #1
        ;addq.l  #6,sp

        ;move.w  #2,-(sp)
        ;trap    #14
        ;addq.l  #2,sp
        ;move.b  d0,oldecr2
        ;move.w  #3,-(sp)
        ;trap    #14
        ;addq.l  #2,sp
        ;move.l  d0,oldecr

        move.l  #scrx+256,d0
        and.b   #0,d0
        move.l  d0,ecr_phy
        move.l  d0,a1
        add.l   #44032,d0
        move.l  d0,ecr_log

        move.l  d0,a0

        move.l  #7999,d0
clr:
        clr.l   (a0)+
        clr.l   (a1)+
        dbf     d0,clr

        move.l  #scrx+256,d0
        and.b   #0,d0
        move.l  d0,ecr_phy
        move.l  d0,a1
        add.l   #44032,d0
        move.l  d0,ecr_log

        move.l  d0,a0

        lea     IMAGE,A2
        move.l  #4799,d0
copypic:
        MOVE.W  (A2),(a0)+
        MOVE.W  (A2)+,(a1)+
        dbf     d0,copypic


        ;clr.w   -(sp)
        ;pea     $200000
        ;trap    #1
        ;addq.l  #6,sp

        ;move.l  d0,oldusp
;**********************
; MUSIC
        
       MOVE.W  #130,$FF8920   ;sound-mode
                               ;00 6250hz
                               ;1  15217hz
                               ;2  25033hz
                               ;3  50066hz
                               ; mono +128 

       LEA      MUSIQUE_END,A0 
       MOVE.L  A0,D0
       MOVE.W  D0,$FF8912
       ROR.L   #8,D0
       MOVE.W  D0,$FF8910
       ROR.L   #8,D0
       MOVE.W  D0,$FF890E

       LEA     MUSIQUE,A0
       MOVE.L  A0,D0
       MOVE.W  D0,$FF8908
       ROR.L   #8,D0
       MOVE.W  D0,$FF8904
       ROR.L   #8,D0
       MOVE.W  D0,$FF8902
       
       MOVE.W  #3,$FF8900
       ; control : 0:off
        ;           1:one play
        ;           2: loop                             





        MOVE.L  $120,OLDHBL
        MOVE.B  $FFFA09,OLD09
        MOVE.B  $FFFA07,OLD07
        MOVE.B  $FFFA0F,OLD0F
        MOVE.B  $FFFA13,OLD13
        MOVE.B  $FFFA1B,OLD1B
        MOVE.B  $FFFA21,OLD21

        lea     $ff8240,a0
        lea     palette,a1
        lea     oldpal,a2
        movem.l (a0),d0-d7
        movem.l d0-d7,(a2)
        movem.l (a1),d0-d7
        movem.l d0-d7,(a0)

        ;move.b  $484,tch
        ;move.b  #0,$484

        ;pea     $40012
        ;move.w  #3,-(sp)
        ;trap    #13
        ;addq.l  #6,sp

        lea     ym,a0
        lea     $ff8800,a1
        moveq   #15,d0
bcl0:
        move.b  d0,(a1)
        move.b  (a1),(a0)+
        dbf     d0,bcl0


        bsr     setsprites
        bsr     setstar

        move.w  #$2700,sr
        lea     $70,a0
        move.l  (a0),oldvbl

        move.l  #myirq1,$120


;*************
        move.l  #vbl_scroll2,(a0)
;*************

        and.b   #$df,$fffa09
        and.b   #$fe,$fffa07
        or.b    #1,$fffa07
        or.b    #1,$fffa13
        move.w  #$2300,sr
recommen:
        ;move.w  #7,-(sp)
        ;trap    #1
        ;addq.l  #2,sp
	cmp.b	#$39,$fffc02
	bne	recommen
end:
        move.w  #$2700,sr
        and.b   #$df,$fffa09
        and.b   #$fe,$fffa07
        MOVE.L  OLDHBL,$120     ; RESTAURE LES VECTEURS IT
        move.l  oldvbl,$70
        MOVE.B  OLD09,$FFFA09
        MOVE.B  OLD07,$FFFA07
        MOVE.B  OLD0F,$FFFA0F
        MOVE.B  OLD13,$FFFA13
        MOVE.B  OLD1B,$FFFA1B
        MOVE.B  OLD21,$FFFA21
        move.w  #$2300,sr
;****************
FINMUS: MOVE.W  #0,$FF8900

        lea     $ff8240,a0
        lea     oldpal,a2
        movem.l (a2),d0-d7
        movem.l d0-d7,(a0)


        ;move.l  oldusp,-(sp)
        ;move.w  #32,-(sp)
        ;trap    #1
        ;addq.l  #6,sp

        ;move.w  #-1,-(sp)
        ;move.l  oldecr,-(sp)
        ;move.l  oldecr2,-(sp)
        ;move.w  #5,-(sp)
        ;trap    #14
        ;lea     12(sp),sp

        ;pea     $40008
        ;move.w  #3,-(sp)
        ;trap    #13
        ;addq.l  #6,sp
	move.w	#0,$aaa2
	jmp	$8c
        clr.w   -(sp)
        trap    #1

myirq1:
;        clr.b   $fffa1b
;        move.b  #150,$fffa21
;        move.b  #8,$fffa1b
        move.w  #$000,$ff8240
        move.l  #$7770666,$ff8250
        move.l  #$4440222,$ff8254
        move.l  #$00070007,$ff8258
        move.l  #$04470667,$ff825c
;        move.l  #myirq2,$120
;        bclr    #0,$fffa0f
;        rte

logo1:  clr.b   $fffffa1b
        movem.l d0-d7/a0-a2,-(sp)
        move.w  #$fa21,a1
        move.b  #200,(a1)
        move.b  #8,$fffffa1b.w
        move.l  decalox,d4
        move.w  #$f00,d5
        move.w  #$000,d6
        LEA     COLORS,A2
        move.b  (a1),d0
wait:
        cmp.b   (a1),d0
        beq     wait


        move.w  scandelay,d3


        move.w  #$2700,sr
        moveq   #30,d2
        move.w  #$8209,a0
waitloop:
        move.b  (a0),d0
        beq.s     waitloop

        sub.w   d0,d2
        lsl.l   d2,d0
        moveq   #19,d0
waitloop2:
        nop
        dbf d0,waitloop2
scandelx:
        rept    125
        nop
        endr
        dbra    d3,scandelx

        lsl.w   d4,d4   
        move.w  #$8240,a0

        moveq   #16,d0
loop:

        rept    16
        nop
        endr
        dc.w $3087
ligne1: 
        REPT    49
        dc.w $3086
        ENDR
        MOVE.W  (A2)+,D5
        rept    7
        nop
        endr
        dbf     d0,loop
        nop
        nop
;***********************
        moveq   #16,d0
loop2:
        rept    12
        nop
        endr
        dc.w $3086
ligne2: 
        REPT    49
        dc.w $3086
        ENDR
        MOVE.W  (A2)+,D5
        rept    11
        nop
        endr
        dbf     d0,loop2
        nop
        nop
 ;*************************
        moveq   #16,d0
loop3:
        rept    8
        nop
        endr
        dc.w $3086;
ligne3: 
        REPT    49
        dc.w $3086
        ENDR
        MOVE.W  (A2)+,D5        
        rept    15
        nop
        endr
        dbf     d0,loop3
        nop
        nop
;***********************
        moveq   #16,d0
loop4:
        rept    4
        nop
        endr
        dc.w $3086;
ligne4: 
        REPT 49
        dc.w $3086
        ENDR
        MOVE.W  (A2)+,D5
        rept    19
        nop
        endr    
        dbf     d0,loop4
        nop
        nop
**********************
       moveq   #16,d0
loop5:
        dc.w $3086;;;;
ligne5: 
        REPT 49
        dc.w $3086
        ENDR
        MOVE.W  (A2)+,D5
        rept    23
        nop
        endr
        dbf     d0,loop5
        dc.w    $3086
        moveq   #8,d0
loop6:
        dc.w $3086;;;;
ligne6: 
        REPT 49
        dc.w $3086
        ENDR
        MOVE.W  (A2)+,D5
        rept    23
        nop
        endr
        dbf     d0,loop6
        dc.w    $3086
        


        move.w  #$2300,sr
return: movem.l (sp)+,d0-d7/a0-a2
        bclr    #0,$fffffa0f.w
        rte
scroll:
        movem.l a0-a6/d0-d7,-(sp)
        cmp.l   #6,datacount
        bne     suix
        move.l  #0,datacount
        lea     datas,a0
        lea     text,a1
        add.l   textcount,a1
        add.l   #1,textcount
        clr.l   d0
        move.b  (a1),d0
        cmp.b   #-1,d0
        bne     okchar
        move.l  #0,textcount
        move.l  #32,d0
okchar:
        sub.b   #33,d0
        mulu    #6,d0
        lea     fonts,a1
        add.l   d0,a1
        move.l  #5,d1
get:    move.l  #5,d0
getloop:btst    d0,(a1)
        beq     met0
met1:   move.b  #$85,(a0)+
        bra     suiyt
met0:   move.b  #$86,(a0)+
suiyt:  
        dbra    d0,getloop
        add.l   #1,a1
        dbra    d1,get
suix:
        lea     datas,a0
        add.l   datacount,a0
        add.l   #1,datacount
        move.b  (a0),dta1
        move.b  6(a0),dta2
        move.b  12(a0),dta3
        move.b  18(a0),dta4
        move.b  24(a0),dta5
suit:   
        lea     ligne1,a0
        move.b  dta1,97(a0)
        move.w  (a0),a1
        movem.w (a0),d0-d7
        movem.w d0-d7,-2(a0)
        movem.w 16(a0),d0-d7
        movem.w d0-d7,14(a0)
        movem.w 32(a0),d0-d7
        movem.w d0-d7,30(a0)
        movem.w 48(a0),d0-d7
        movem.w d0-d7,46(a0)
        movem.w 64(a0),d0-d7
        movem.w d0-d7,62(a0)
        movem.w 80(a0),d0-d7
        movem.w d0-d7,78(a0)
        move.w  96(a0),94(a0)
        lea     ligne2,a0
        move.b  dta2,97(a0)
        movem.w (a0),d0-d7
        movem.w d0-d7,-2(a0)
        movem.w 16(a0),d0-d7
        movem.w d0-d7,14(a0)
        movem.w 32(a0),d0-d7
        movem.w d0-d7,30(a0)
        movem.w 48(a0),d0-d7
        movem.w d0-d7,46(a0)
        movem.w 64(a0),d0-d7
        movem.w d0-d7,62(a0)
        movem.w 80(a0),d0-d7
        movem.w d0-d7,78(a0)
        move.w  96(a0),94(a0)   
        lea     ligne3,a0
        move.b  dta3,97(a0)
        movem.w (a0),d0-d7
        movem.w d0-d7,-2(a0)
        movem.w 16(a0),d0-d7
        movem.w d0-d7,14(a0)
        movem.w 32(a0),d0-d7
        movem.w d0-d7,30(a0)
        movem.w 48(a0),d0-d7
        movem.w d0-d7,46(a0)
        movem.w 64(a0),d0-d7
        movem.w d0-d7,62(a0)
        movem.w 80(a0),d0-d7
        movem.w d0-d7,78(a0)
        move.w  96(a0),94(a0)
        lea     ligne4,a0
        move.b  dta4,97(a0)
        movem.w (a0),d0-d7
        movem.w d0-d7,-2(a0)
        movem.w 16(a0),d0-d7
        movem.w d0-d7,14(a0)
        movem.w 32(a0),d0-d7
        movem.w d0-d7,30(a0)
        movem.w 48(a0),d0-d7
        movem.w d0-d7,46(a0)
        movem.w 64(a0),d0-d7
        movem.w d0-d7,62(a0)
        movem.w 80(a0),d0-d7
        movem.w d0-d7,78(a0)
        move.w  96(a0),94(a0)
        lea     ligne5,a0
        move.b  dta5,97(a0)
        movem.w (a0),d0-d7
        movem.w d0-d7,-2(a0)
        movem.w 16(a0),d0-d7
        movem.w d0-d7,14(a0)
        movem.w 32(a0),d0-d7
        movem.w d0-d7,30(a0)
        movem.w 48(a0),d0-d7
        movem.w d0-d7,46(a0)
        movem.w 64(a0),d0-d7
        movem.w d0-d7,62(a0)
        movem.w 80(a0),d0-d7
        movem.w d0-d7,78(a0)
        move.w  96(a0),94(a0)
        movem.l (sp)+,a0-a6/d0-d7
        rts



setsprites:
        moveq   #0,d0
        lea     spdestin,a1
sp001:
        lea     spsource,a0
        moveq   #15,d2
sp002:
        moveq   #0,d3
        moveq   #0,d4
        move.w  (a0)+,d3
        move.w  (a0)+,d4
        swap    d3
        swap    d4
        lsr.l   d0,d3
        lsr.l   d0,d4
        move.l  d3,d5
        or.l    d4,d5
        not.l   d5
        swap    d5
        move.w  d5,(a1)+
        move.w  d5,(a1)+
        swap    d5
        move.w  d5,(a1)+
        move.w  d5,(a1)+
        swap    d3
        swap    d4
        move.w  d3,(a1)+
        move.w  d4,(a1)+
        swap    d3
        swap    d4
        move.w  d3,(a1)+
        move.w  d4,(a1)+
        dbf     d2,sp002
        addq.l  #1,d0
        cmp.l   #16,d0
        bne     sp001
        jsr     plotsprites
        rts

clearsprites:
        moveq   #nbsprites-1,d0
        move.l  spbuffer,a0
sp0:
        move.l  (a0)+,a2
        ;move.l a2,a1
        add.l   ecr_phy,a2
        ;add.l  #picneo+34,a1
        moveq   #7,d1
sp1:
        rept    2
        clr.l   (a2)+
        clr.l   (a2)+
        clr.l   (a2)+
        clr.l   (a2)+
        ;lea    $90(a1),a1
        lea     $90(a2),a2
        endr
        dbf     d1,sp1
        dbf     d0,sp0
        rts

plotsprites:
        lea     $0,a6
        lea     spdata,a0
        move.l  spbuffer,a1
        move.l  #nbsprites-1,d0
sp2:
        move.l  ecr_phy,a2
        move.l  (a0)+,a3        ; motif du sprite
        move.l  (a0),d1         ; coord. x (decalage)
        and.w   #$f,d1          ; nombre de d‚calages dans d1
        lsl.l   #8,d1           ; x 512 (longueur d'1 sprite)
        add.l   d1,a3           ; Adresse du motif

        move.l  (a0)+,d2        ; x pour pos x dans bitmap
        and.w   #$fff0,d2       ; prend juste la partie haute
        lsr.w   #1,d2           ; nombre de words.
        add.w   d2,a2           ; rajout‚ … l'adresse ‚cran
        move.w  d2,a6

        move.l  (a0)+,d2        ; y pour pos y dans bitmap
        mulu    #160,d2
        add.w   d2,a2           ; ajouter … l'adresse ecran
        add.w   d2,a6

        move.l  a6,(a1)+        ; sauver adresse dans buffer

        moveq   #7,d1           ; 8x2 lignes.
sp3:
        rept    2
        movem.l (a3)+,d2-d5
        and.l   d2,(a2)
        or.l    d4,(a2)+
        not.l   d2
        or.l    d2,(a2)+
        and.l   d3,(a2)
        or.l    d5,(a2)+
        not.l   d3
        or.l    d3,(a2)+
        lea     $90(a2),a2
        endr
        dbf     d1,sp3
        dbf     d0,sp2
        rts

sinussprites:
sp01:
        moveq   #0,d4
        moveq   #0,d5
        move.w  inc,d4
        move.w  den,d5
        lea     spdata+4,a0     ; Adresse des coord. x
        lea     sinustable,a1
        moveq   #nbsprites-1,d0
        moveq   #0,d6
        moveq   #0,d1
sp02:
        move.w  d1,d2
        add.w   phi,d2
        and.w   #255,d2
        move.l  lengh,d3
        add.w   d2,d2
        muls    (a1,d2.w),d3
        add.w   d3,d3
        swap    d3
        add.w   #xcenter,d3
        move.l  d3,(a0)+
        move.w  d6,d2
        add.w   psi,d2
        and.w   #255,d2
        move.l  high,d3
        add.w   d2,d2
        muls    (a1,d2.w),d3
        add.w   d3,d3
        swap    d3
        add.w   #ycenter,d3
        move.l  d3,(a0)+
        addq.l  #4,a0
        add.w   d4,d1
        add.w   d5,d6
        dbf     d0,sp02

        move.w  phiad,d7
        add.w   d7,phi
        cmp.w   #0,phi
        bmi     neg1
        cmp.w   #255,phi
        ble     ok‚1
        move.w  #-255,phi
        bra     ok‚1
neg1:
        cmp.w   #-255,phi
        bge     ok‚1
        move.w  #255,phi
ok‚1:
        move.w  psiad,d7
        add.w   d7,psi
        cmp.w   #0,psi
        bmi     neg2
        cmp.w   #255,psi
        ble     ok‚2
        move.w  #-255,psi
        bra     ok‚2
neg2:
        cmp.w   #-255,psi
        bge     ok‚2
        move.w  #255,psi
ok‚2:
        move.l  high,d0
        add.w   addhigh,d0
        cmp.w   #100,d0
        bge     sp08
        cmp.w   #1,d0
        bge     sp09
sp08:
        neg.w   addhigh
sp09:
        move.l  d0,high
        move.l  lengh,d0
        add.w   addlengh,d0
        cmp.w   #300,d0
        bge     sp010
        cmp.w   #1,d0
        bge     sp011
sp010:
        neg.w   addlengh
sp011:
        move.l  d0,lengh
        rts
vbl_scroll2:

        clr.b   $fffa1b
        move.b  #15,$fffa21
        move.b  #8,$fffa1b
        move.l  #myirq1,$120
        bclr    #0,$fffa0f
        movem.l d0-d7/a0-a6,-(sp)

;******************
        move.w  plos,d0
        add.w   d0,scandelay
        bne     nextone
        move.w  #1,plos;1 POUR DESCENDRE
nextone:
        cmp.w   #50,scandelay
        bne     nexttwo
        move.w  #-1,plos;-1 POUR MONTER
nexttwo:
        cmp.l   #0,decalox
        bne     nextfour
        bsr     scroll
        move.l  #2,decalox
        bra     nextfive
nextfour:
        move.l  #0,decalox
nextfive:
;******************
        lea     $ff8240,a0
        lea     palette,a1
        movem.l (a1),d0-d7
        movem.l d0-d7,(a0)

        ;move.l itmuz,a0
        ;jsr    (a0)
        bsr     swap
        move.l  #spbuffer1,spbuffer
        tst.w   screenflag
        beq     sptest
        move.l  #spbuffer2,spbuffer
sptest:
        jsr     clearsprites
        jsr     clearstar
        jsr     movestar
        jsr     plotstar
        jsr     sinussprites

        jsr     plotsprites
        movem.l (sp)+,d0-d7/a0-a6
        rte

swap:
        eor.w   #1,screenflag
        move.b  ecr_log+2,$ff8203
        move.b  ecr_log+1,$ff8201
        move.l  ecr_log,d0
        move.l  ecr_phy,ecr_log
        move.l  d0,ecr_phy
        lea     starbuffer,a0
        move.l  (a0),d0
        move.l  4(a0),a0
        move.l  d0,4(a0)

        rts

clearstar:
        move.l  starbuffer,a0
        moveq.l #nbstar-1,d0
star1:
        move.l  (a0)+,a1
        clr.l   (a1)+
        clr.l   (a1)
        dbf     d0,star1
        rts
movestar:
        lea     stardata+6,a0
        moveq.l #nbstar-1,d0
starx:
        move.w  (a0)+,d1
        add.w   d1,-8(a0)
        cmp.w   #320,-8(a0)
        bcs     star3
        clr.w   -8(a0)
star3:
        addq.l  #6,a0 ; add.w
        dbf     d0,starx
        rts

plotstar:
        moveq.l #nbstar-1,d0
        lea     stardata,a0
        move.l  ecr_log,a1
        adda.l  #160*60,a1
        move.l  starbuffer,a2
star2:
        move.l  a1,a3

        move.w  (a0)+,d1
        move.l  (a0)+,d3
        move.w  (a0)+,d4
        move.w  d1,d2
        and.l   #$fff0,d1
        and.l   #$000f,d2
        lsr.w   #1,d1
        add.w   d1,a3
        move.l  a3,(a2)+
        lsr.l   d2,d3
        move.w  (a3),d4
        or.w    2(a3),d4
        or.w    4(a3),d4
        or.w    6(a3),d4
        not.w   d4
        and.w   d4,d3
        or.w    d3,(a3)+
        or.w    d3,4(a3)
        swap    d3
        and.w   d4,d3
        or.w    d3,(a3)+
        or.w    d3,2(a3)
        add.w   #starmodulo,a1
        dbf     d0,star2
        rts
setstar:
        lea     stardata,a3
        lea     speedtable,a4
        moveq.l #nbstar-1,d3
star4:
        jsr     rand
        lsr.l   #8,d0 ; /256
        lsr.l   #8,d0 ; /256...
        move.w  d0,(a3)+
        jsr     rand
        lsr.l   #8,d0
        lsr.l   #8,d0
        lsr.l   #6,d0
        lsl.l   #3,d0
        move.l  (a4,d0),(a3)+
        move.w  6(a4,d0),(a3)+
        dbf     d3,star4
        jsr     plotstar
        rts
rand:
        move.w  #17,-(sp)
        trap    #14
        addq.l  #2,sp
        rts

        section data

count:  dc.w    0
count2: dc.w    0
count3: dc.w    0
count4: dc.w    0
decalox: dc.l 0

scandelay: dc.w 0

plos:   dc.w    0
cm:     dc.b    $08
        even
dm:     dc.b    $12
        even
textcount:      dc.l 0
text:  dc.b "                     SUSPENS                 AND HERE IT IS"
	DC.B ".....THE GREET DEMO    THE ONLY SCREEN WHICH CONTAINS A "
	DC.B "SCROLLTEXT      THIS SCREEN IS AN OLD DEMO NEVER USED BEFORE   "
	DC.B "CODED BY DR NO      GRAFX AND SOUND BY MARIO   AND TEXT BY AXEL F.    "
	DC.B "SO    PUMP UP THE VOLUME  AND LISTEN TO THE 25 KHZ DIGISOUND "
	DC.B "THE  STF  CAN'T BEAT DIS     TRY TO IMAGINE A SOUNDTRACKER WITH "
	DC.B "ALL INSTRUMENTS DIGITIZED AT 25 KHZ ...  BECAUSE THE AMIGA USES "
	DC.B "10 KHZ INSTRUMENTS       I GIVE THE KEYBOARD      "
	DC.B " HI LADIES AND GENTLEMEN  HERE IS MARIO ON THE KEYBOARD. "
	DC.B "I WANT TO WRITE SOME GREETINGS AND PERSONNAL MESSAGES IN THIS "
	DC.B "SCREEN.  FIRST I SEND SOME VALUABLE GREETS TO ALL MEMBERS "
	DC.B "OF  MCS  (OH YES)  LET'S START GREETINGS TO AXEL F. (I HAVEN'T "
	DC.B "EVERYTHING SPECIAL TO SAY BUT I WANT TO TELL YOU 'THANK YOU' "
	DC.B "FOR THE SUPPORT YOU GAVE ME WHEN DOCTOR NO HAS RESTARTED THE SCHOOL "
	DC.B "I ENJOY YOUR CODING... YOU'RE REALLY A VERY GOOD PAL ...   I LOVE YOU ...)  "
	DC.B "UPS I'M VERY ENJOYED    LET'S CONTINUE WITH GADGET (I HOPE YOU DON'T HAVE TO MUCH TO "
	DC.B "CORRECT ME IN THIS TEXT)   DOCTOR NO  (THE HARD MAN OF THE CREW AND WHO HAVE TO "
	DC.B "SUPPORT ME TOO MUCH I PROMISED YOU ... I TRY TO HAVE NO COMPLEX IDEA THE NEXT TIME. "
	DC.B "BUT ALL RAVING ARE COMPLEX)   I MUST SEND SOME THANKS TO MEMBERS FROM OTHERS "
	DC.B "CREWS    TO DAEWOO FROM FALLEN ANGEL ... FOR HIS FUN ... AND GOOD EXPLANATIONS "
	DC.B "ABOUT SOME ALGORYTHM IN THE PAST      TO KRAZY REX FROM ST CONNEXION FOR ALL (?) "
	DC.B "(DO YOU HAVE MADE YOUR CHOICE ?  FINE ART SCHOOL OR ELSE ?)  TO VANTAGE (ST CNX) "
	DC.B "(MANY THANK FOR YOUR HOT STUFF)    SOME GREETINGS TO THE REPLICANTS  ESPECIALLY FURY "
	DC.B "(YOU AND ME ... WE HAVE THE SAME IDEAS ... BUT YOU CAN REALISE THEM FASTER THAN ME "
	DC.B "I DON'T WANT TO SEE YOUR SCHOOL RESULTS BECAUSE I THINK YOU MUST CODE ALL DAYS "
	DC.B "... NOT US ... THAT'S THE WAY WHY YOU'RE ALLWAYS THE FIRST BUT NOW ... BE CARE ...) "
	DC.B "I WANT TO SEND GOLDEN REGARDS TO MY OLD CORRESPONDANT (WHO DOESN'T RESPOND ANYWAY) "
	DC.B "TO THE EXEPTIONS (ESPECIALLY -ES- WHO WAS MY PEN-PAL) OTHER REGARD TO THE CAREBEARS "
	DC.B "(WHAT DO YOU THINK ABOUT THIS ?) AND TO THE LOST (BUT NOT LAST) BOYS.  I WANT TO TELL "
	DC.B "A LITTLE HELLO TO MY OLD CORRESPONDANT FROM OCC A GERMAN CREW  FIRST KADUL  MY FIRST "
	DC.B "GOOD CORRESPONDANT IN GERMANY (ARE YOU DEAD? IF YOU STILL ALIVE YOU CAN WRITE ME "
	DC.B "TO MY OLD ADRESS. I HOPE YOU ALREADY HAVE IT) AND TO JEOFI (JEOFY?) OF OCC "
	DC.B "YOU WERE GOOD PAL TOO.ARE YOU STILL ON AMIGA ?)  OTHER GREETINGS TO DON CHAOS (WHO ONLY "
	DC.B "SWAP DP) AND ALL THE REST I FORGOT (HOPE THEY AREN'T MUCH)         "
	DC.B "A BIG BIG BIG BIG HELLO TO ZESTOON,JUJU AND JUJUE,SOAZ,SPEEDER,  HMM ... ALL THE HORRIBLE CREW "
	DC.B ".... , CERISE , SOME GIRL FRIENDS, ANNE,SQUIDLY,GISLAINE,ALEXANDRA,DANIELLE (MY LUX-BOURGEOISE), "
	DC.B "ESTELLE,SANDRINE,CAROLINE,SYLVIE,SYLVIA,KARINE, ETC.      OK I'M GOING TO STOP THOSE OBLIGATIONS "
	DC.B "(HMMM.... HEY GADGET WE SAY THOSE OR THIS ?)  OTHER GREET TO GRYZOR (MANY THANKS FOR THE MODULES) "
	DC.B "ST FUN (AND HIS  RC-MODEL OF EQUILOPTERE) THE BESTS BUT NOT FORGOTTEN ZLORK, ELDAR  ALIAS ... ALIAS ... "
	DC.B "NO I DON'T SAY IT     TO CHRISTOPHE AND HIS GIRLFRIEND  (HEY TIANA WHEN YOU COME TO MY LITTLE HOME "
	DC.B "TO MAKE THE KITCHEN ONE DAY OR TWO ? )  TO ALL OTHER NUMEROUS GUYS I'VE FORGOTTEN   OH YES  TO ALF "
	DC.B "(WHO ARE YOU? I ONLY SEE YOUR GFX .... QUITE GOOD)     SO LET'S STOP CRAPTALK WITH SOME FUCKING "
	DC.B "SEND TO ALL THE LAMERS .. VIRUS MAKER .. CODE STOLLER .. NAME RIPPER .. PROGRAMM SELLER   AND ALL "
	DC.B "PEOPLE LIKE THIS  I SENT YOU A BIG  'GO TO SEEYOUR MOTHER,IF SHE DOESN'T MADE COOKIES, KISS HER ASS, "
	DC.B "AND GO TO EVIL   YYYEEEAAAHHH   NOW I MUST STOP   SSSTTTOOOPPP  OK     "
	DC.B "AXEL ON THE KEYBOARD   WHAT A LENGHT ???  PPFFOOUU         DID YOU SEE,  THIS DEMO,   IT IS A BALL DEMO ...  "
	DC.B " SO NOW THE AXEL'S GREETINGS  :   "
	DC.B "TCB (KEEP ON CODING GUYS), THALION (HOPE YOUR END IS NOT NOW), "
	DC.B "TLB (GGOOOODD DEMO), OVERLANDERS (SEE YOU SOON), "
	DC.B "THE GERMAN ALLIANCE (DON'T KNOW WHAT TO SAY), SAS, EMPIRE, "
	DC.B "THE REPLICANT (HELLO MAXI), EQUINOX, CLONE, MENTA (HELLO RENKER), BLACK PANTHERS(CONIN AND BERANGERE), "
	DC.B "OOPSSS  SORRY     BLACK CATS, PENDRAGONS, THE SERGEANT AND THE BUSHWACKERS, "
	DC.B "FUZION, HEMOROIDS AND ALL  GEN 4  DEMO CODERS, ATAVIK, ZLORK (SORRY I DON'T USE YOUR TUNE), ELDAR,THE VOYAGERS "
	DC.B "(WITH US), NEWSOVOR, MY FUTURE WIFE  LAUREN (SCHMUCK),ULM "
	DC.B "AND  PPFFOUOU  YOU ARE TOO NUMEROUS    SO   I WRAP      "

        DC.B    -1


        even
datas:  
        dc.b $86,$86,$86,$86,$86,$86
        dc.b $86,$86,$86,$86,$86,$86
        dc.b $86,$86,$86,$86,$86,$86
        dc.b $86,$86,$86,$86,$86,$86
        dc.b $86,$86,$86,$86,$86,$86
        ds.b 50
        even
fonts:
E1:	DC.B	%00000100
	DC.B	%00000100
	DC.B	%00000100
	DC.B	%00000000
	DC.B	%00000100
	EVEN
E2:	DC.B	%00001010
	DC.B	%00001010
	DC.B	%00000000
	DC.B	%00000000
	DC.B	%00000000
	EVEN
E3:	DC.B	%00001010
	DC.B	%00011111
	DC.B	%00001010
	DC.B	%00011111
	DC.B	%00001010
	EVEN
E4:	DC.B	%00001010
	DC.B	%00011111
	DC.B	%00011111
	DC.B	%00001110	
	DC.B	%00000100
	EVEN
E5:	DC.B	%00000000
	DC.B	%00000000
	DC.B	%00000000
	DC.B	%00000000
	DC.B	%00000000
	EVEN
E6:	DC.B	%00000000
	DC.B	%00000000
	DC.B	%00000000
	DC.B	%00000000
	DC.B	%00000000
	EVEN
E7:	DC.B	%00000100
	DC.B	%00000100
	DC.B	%00001000
	DC.B	%00000000
	DC.B	%00000000
	EVEN
E8:	DC.B	%00000100
	DC.B	%00001000
	DC.B	%00001000
	DC.B	%00001000
	DC.B	%00000100
	EVEN
E9:	DC.B	%00001000
	DC.B	%00000100
	DC.B	%00000100
	DC.B	%00000100
	DC.B	%00001000
	EVEN
E10:	DC.B	%00010101
	DC.B	%00001110
	DC.B	%00011111
	DC.B	%00001110
	DC.B	%00010101
	EVEN
E11:	DC.B	%00000100
	DC.B	%00000100
	DC.B	%00011111
	DC.B	%00000100
	DC.B	%00000100
	EVEN
E12:	DC.B	%00000000
	DC.B	%00000000
	DC.B	%00000100
	DC.B	%00000100
	DC.B	%00001000
	EVEN
E13:	DC.B	%00000000
	DC.B	%00000000
	DC.B	%00011111
	DC.B	%00000000
	DC.B	%00000000
	EVEN
E14:	DC.B	%00000000
	DC.B	%00000000
	DC.B	%00000000
	DC.B	%00000000
	DC.B	%00001100
	EVEN
E15: 	DC.B	%00000001
	DC.B	%00000010
	DC.B	%00000100
	DC.B	%00001000
	DC.B	%00010000
	EVEN
E16:	DC.B	%00001110
	DC.B	%00010011
	DC.B	%00010101
	DC.B	%00011001
	DC.B	%00001110
	EVEN
E17:	DC.B	%00000100
	DC.B	%00001100
	DC.B	%00000100
	DC.B	%00000100
	DC.B	%00001110
	EVEN
E18:	DC.B	%00001110
	DC.B	%00010001	
	DC.B	%00000010
	DC.B	%00001100
	DC.B	%00011111
	EVEN
E19:	DC.B	%00011111
	DC.B	%00000010
	DC.B	%00000110
	DC.B	%00010001
	DC.B	%00001110
	EVEN
E20:	DC.B	%00000010
	DC.B	%00000110
	DC.B	%00001010
	DC.B	%00011111
	DC.B	%00000010
	EVEN
E21:	DC.B	%00011111
	DC.B	%00010000
	DC.B	%00011110
	DC.B	%00000001
	DC.B	%00011110
	EVEN
E22:	DC.B	%00001111
	DC.B	%00010000
	DC.B	%00011110
	DC.B	%00010001
	DC.B	%00001110
	EVEN
E23:	DC.B	%00011111
	DC.B	%00000010
	DC.B	%00000010
	DC.B	%00000100
	DC.B	%00000100
	EVEN
E24:	DC.B	%00001110
	DC.B	%00010001
	DC.B	%00001110
	DC.B	%00010001
	DC.B	%00001110
	EVEN
E25:	DC.B	%00001110
	DC.B	%00010001
	DC.B	%00001111
	DC.B	%00000001
	DC.B	%00011110
	EVEN
E26:	DC.B	%00000000
	DC.B	%00000100
	DC.B	%00000000
	DC.B	%00000100
	DC.B	%00000000
	EVEN
E27:	DC.B	%00000000
	DC.B	%00000100
	DC.B	%00000000
	DC.B	%00000100
	DC.B	%00001000
	EVEN
E28:	DC.B	%00000010
	DC.B	%00000100
	DC.B	%00001000
	DC.B	%00000100
	DC.B	%00000010
	EVEN
E29:	DC.B	%00000000
	DC.B	%00011111
	DC.B	%00000000
	DC.B	%00011111
	DC.B	%00000000
	EVEN
E30:	DC.B	%00000100
	DC.B	%00000010
	DC.B	%00000001
	DC.B	%00000010
	DC.B	%00000100
	EVEN
E31:	DC.B	%00001110
	DC.B	%00010001
	DC.B	%00000010
	DC.B	%00000100
	DC.B	%00000100
	EVEN


aa:     dc.b    %00011111
        dc.b    %00011111
        dc.b    %00011111
        dc.b    %00011111
        dc.b    %00011111
        even
a:      dc.b    %00001110
        dc.b    %00010001
        dc.b    %00011111
        dc.b    %00010001
        dc.b    %00010001
        even
b:      dc.b    %00011110
        dc.b    %00001001
        dc.b    %00001110
        dc.b    %00001001
        dc.b    %00011110
        even
c:
        dc.b    %00001111
        dc.b    %00010000
        dc.b    %00010000
        dc.b    %00010000
        dc.b    %00001111
        EVEN
D:      DC.B    %00011110
        DC.B    %00001001
        dc.b    %00001001
        dc.b    %00001001
        dc.b    %00011110
        EVEN
e:      dc.b    %00011111
        dc.b    %00010000
        dc.b    %00011100
        dc.b    %00010000
        dc.b    %00011111
        EVEN
f:      dc.b    %00011111
        dc.b    %00010000
        dc.b    %00011100
        dc.b    %00010000
        dc.b    %00010000
        EVEN
g:      dc.b    %00001111
        dc.b    %00010000
        dc.b    %00010011
        dc.b    %00010001
        dc.b    %00001110
        EVEN
h:      dc.b    %00010001
        dc.b    %00010001
        dc.b    %00011111
        dc.b    %00010001
        dc.b    %00010001
        EVEN
i:      dc.b    %00001110
        dc.b    %00000100
        dc.b    %00000100
        dc.b    %00000100
        dc.b    %00001110
        EVEN
j:      dc.b    %00001110
        dc.b    %00000100
        dc.b    %00000100
        dc.b    %00010100
        dc.b    %00001000
        EVEN
k:      dc.b    %00010001
        dc.b    %00010010
        dc.b    %00011100
        dc.b    %00010010
        dc.b    %00010001
        EVEN
l:
        dc.b    %00010000
        dc.b    %00010000
        dc.b    %00010000
        dc.b    %00010000
        dc.b    %00011111
        EVEN
m:
        dc.b    %00010001
        dc.b    %00011011
        dc.b    %00010101
        dc.b    %00010001
        dc.b    %00010001
        EVEN
N:      DC.B    %10001
        DC.B    %11001
        DC.B    %10101
        DC.B    %10011
        DC.B    %10001
        EVEN
O:      DC.B    %01110
        DC.B    %10001
        DC.B    %10001
        DC.B    %10001
        DC.B    %01110
P:      EVEN
        DC.B    %11110
        DC.B    %10001
        DC.B    %11110
        DC.B    %10000
        DC.B    %10000
        EVEN
Q:      DC.B    %01110
        DC.B    %10001
        DC.B    %10001
        DC.B    %10010
        DC.B    %01101
R:      EVEN
        DC.B    %11110
        DC.B    %10001
        DC.B    %11110
        DC.B    %10100
        DC.B    %10011
S:      EVEN
        DC.B    %01111
        DC.B    %10000
        DC.B    %01110
        DC.B    %00001
        DC.B    %11110
T:      EVEN
        DC.B    %11111
        DC.B    %00100
        DC.B    %00100  
        DC.B    %00100
        DC.B    %00100
U:      EVEN
        DC.B    %10001
        DC.B    %10001
        DC.B    %10001
        DC.B    %10001
        DC.B    %01110
V:      EVEN
        DC.B    %10001
        DC.B    %10001
        DC.B    %01010
        DC.B    %01010
        DC.B    %00100
W:      EVEN
        DC.B    %10001
        DC.B    %10001
        DC.B    %10101
        DC.B    %10101
        DC.B    %01010
X:      EVEN
        DC.B    %10001
        DC.B    %01010
        DC.B    %00100
        DC.B    %01010
        DC.B    %10001
Y:      EVEN
        DC.B    %10001
        DC.B    %10001
        DC.B    %01110
        DC.B    %00100
        DC.B    %00100
Z:      EVEN
        DC.B    %11111
        DC.B    %00010
        DC.B    %00100
        DC.B    %01000
        DC.B    %11111
datacount:      dc.l 0
dta1:   dc.l 0
dta2:dc.l 0
dta3:   dc.l 0
dta4:   dc.l 0
dta5:dc.l 0     
buff:   ds.l    3
palptr:
        ds.l    1

COLORS:
        DC.W    $f80,$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0,$f60,$fe0,$f70,$ff0
        DC.W    $7f0,$ef0,$6f0,$df0,$5f0,$cf0,$4f0,$bf0,$3f0,$af0,$2f0,$9f0,$1f0,$8f0,$0f0
        DC.W    $0f8,$0f1,$0f9,$0f2,$0fa,$0f3,$0fb,$0f4,$0fc,$0f5,$0fd,$0f6,$0fe,$0f7,$0ff
        DC.W    $07f,$0ef,$06f,$0df,$05f,$0cf,$04f,$0bf,$03f,$0af,$02f,$09f,$01f,$08f,$00f
        DC.W    $80f,$10f,$90f,$20f,$a0f,$30f,$b0f,$40f,$c0f,$50f,$d0f,$60f,$e0f,$70f,$f0f
        DC.W    $f07,$f0e,$f06,$f0d,$f05,$f0c,$f04,$f0b,$f03,$f0a,$f02,$f09,$f01,$f08,$f00
        DC.W    $003,$004,$005,$006,$007,$006,$005,$004,$003
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003  
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003  
        DC.W    $001,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444
        DC.W    $333,$222,$111,$004,$005,$006,$007,$006,$005,$004,$003  
        DC.W    $100,$200,$300,$400,$500,$600,$700,$600,$500,$400,$300
        DC.W    $010,$020,$030,$040,$050,$060,$070,$060,$050,$040,$030  
        DC.W    $020,$010,$000,$004,$005,$006,$007,$006,$005,$004,$003
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003  
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003  
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003  
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003  

        DC.W    $001,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444
        DC.W    $333,$222,$111,$004,$005,$006,$007,$006,$005,$004,$003  
        DC.W    $100,$200,$300,$400,$500,$600,$700,$600,$500,$400,$300
        DC.W    $010,$020,$030,$040,$050,$060,$070,$060,$050,$040,$030  
        DC.W    $020,$010,$000,$004,$005,$006,$007,$006,$005,$004,$003
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003  
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003  
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003  
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003
        DC.W    $001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003  


IMAGE:  INCBIN masters.BLK
        even
starbuffer:
        dc.l    starbuffer2
        dc.l    starbuffer1
starbuffer1:
        rept    50
        dc.l    $20000
        endr
speedtable:
        dc.l    $00008000,4,$00008000,3,$80000000,2,$80008000,1
ecr_phy:
        dc.l    0
ecr_log:
        dc.l    0
worktxt:
        dc.b    -2,0,0
        dc.b    "+000"
        dc.b    -1
adresses:
        dc.l    33136,34416,35696
        dc.l    33184,34464,35744
tagada:
        dc.w    0
no_cursor:
        dc.b    27,"f",0
vitesse:
        dc.b    4
v:
        dc.b    4
offset:
        dc.b    47
        even
palette:
        dc.w    $000,$770,$550,$660
        dc.w    $220,$330,$440,$110
        dc.w    $443,$544,$554,$655
        dc.w    $665,$766,$776,$777
spbuffer:
        dc.l    spbuffer2
spbuffer1:
        rept    16
        dc.l    $20000
        endr
spbuffer2:
        ds.l    16
spdata:
        rept    2*16
        dc.l    spdestin,0,0
        endr
intyp:
        dc.w    0
btest:
        dc.w    0
screenbase:
        dc.l    $78000
screenflag:
        dc.w    1
sinustable:
        dc.w    0,804,1607,2410,3211,4011,4808,5602,6392,7179
        dc.w    7961,8739,9512,10278,11039,11793,12539,13278,14010,14732
        dc.w    15446,16151,16846,17530,18204,18868,19519,20159,20787,21403
        dc.w    22005,22594,23170,23732,24279,24812,25330,25832,26319,26790
        dc.w    27245,27684,28106,28511,28898,29269,29621,29956,30273,30572
        dc.w    30852,31114,31357,31581,31785,31971,32138,32285,32413,32521
        dc.w    32610,32679,32728,32758
        dc.w    32767,32758,32728,32679,32610,32521,32413,32285,32138,31971
        dc.w    31785,31581,31357,31114,30852,30572,30273,29956,29621,29269
        dc.w    28898,28511,28106,27684,27245,26790,26319,25832,25330,24812
        dc.w    24279,23732,23170,22594,22005,21403,20787,20159,19519,18868
        dc.w    18204,17530,16846,16151,15446,14732,14010,13278,12539,11793
        dc.w    11039,10278,9512,8739,7961,7179,6392,5602,4808,4011
        dc.w    3211,2410,1607,804
        dc.w    0,-804,-1607,-2410,-3211,-4011,-4808,-5602,-6392,-7179
        dc.w    -7961,-8739,-9512,-10278,-11039,-11793,-12539,-13278,-14010,-14732
        dc.w    -15446,-16151,-16846,-17530,-18204,-18868,-19519,-20159,-20787,-21403
        dc.w    -22005,-22594,-23170,-23732,-24279,-24812,-25330,-25832,-26319,-26790
        dc.w    -27245,-27684,-28106,-28511,-28898,-29269,-29621,-29956,-30273,-30572
        dc.w    -30852,-31114,-31357,-31581,-31785,-31971,-32138,-32285,-32413,-32521
        dc.w    -32610,-32679,-32728,-32758
        dc.w    -32767,-32758,-32728,-32679,-32610,-32521,-32413,-32285,-32138,-31971
        dc.w    -31785,-31581,-31357,-31114,-30852,-30572,-30273,-29956,-29621,-29269
        dc.w    -28898,-28511,-28106,-27684,-27245,-26790,-26319,-25832,-25330,-24812
        dc.w    -24279,-23732,-23170,-22594,-22005,-21403,-20787,-20159,-19519,-18868
        dc.w    -18204,-17530,-16846,-16151,-15446,-14732,-14010,-13278,-12539,-11793
        dc.w    -11039,-10278,-9512,-8739,-7961,-7179,-6392,-5602,-4808,-4011
        dc.w    -3211,-2410,-1607,-804
nbstar=49
starmodulo=480
nbsprites=12
xcenter=152
ycenter=133
time=600


        
addhigh:
        dc.w    1
addlengh:
        dc.w    2
phi:
        dc.w    0
phiad:
        dc.w    -2      ; zinc
psi:
        dc.w    0
psiad:
        dc.w    6       ; qinc
num:
        dc.w    3
den:
        dc.w    -20     ; Yinc
inc:
        dc.w    -10     ; Xinc
high:
        dc.l    45
lengh:
        dc.l    80
spsource:
        INCBIN  SSPRITES.DAT
        even
MUSIQUE:
       INCBIN  grace.spl
MUSIQUE_END:
        dc.l 0
        ;section bss
starbuffer2:
        ds.l    50
stardata:
        ds.l    100
tch:
        ds.w    1
ym:
        ds.b    16
spdestin:
        ds.b    4096
oldpal:
        ds.w    16
oldecr:
        ds.l    1
oldecr2:
        ds.l    1
oldusp:
        ds.l    1
oldvbl:
        ds.l    1
scrx:
        ds.b    256
        ds.b    90000
OLD09:
        ds.b    1
OLD07:
        ds.b    1
OLD0F:
        ds.b    1
OLD13:
        ds.b    1
OLD1B:
        ds.b    1
OLD21:
        ds.b    1
        even
OLDHBL:
        ds.l    1
