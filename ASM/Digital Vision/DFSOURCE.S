Comment…:  This source is NO joke! It was done by Headcoder of 
          Digital Vision of The Alliance for the PYM-demo......
€
…We know it's only funny for German readers, but we don't care...

…So now have fun reading... Enjoy...

…Nothing was changed --> this is the original sourcecode!€

;wenn bootload: beginn proc hier OFF
;wenn tos load: beginn proc hier ON

;…wohin? gude€ , moder, l001c: , xylistezz , …putit€ , …space bewtab€: l000e:
;…raser
€
;   d3font: new: …hau€ : prep sound fdh setshape …speise€ pok

          .TEXT 
begin:    move.l    sp,oldstack
;      movea.l 4(SP),A5
;      move.l  12(A5),D0
;      add.l   20(A5),D0
;      add.l   28(A5),D0
;      addi.l  #$0100,D0
;      move.l  D0,-(SP)
;      pea     (A5)
;      clr.w   -(SP)
;      move.w  #$4A,-(SP)
;      trap    #1
;      adda.w  #$0C,SP
;      move.w  #2,-(SP)
;      trap    #14
;     addq.l  #2,SP
          move.l    #0,-(sp)
          move.w    #32,-(sp)
          trap      #1
          addq.l    #6,sp
          movea.l   #stackl,sp
          move.w    #2,-(sp)
          trap      #14
          addq.l    #2,sp
          move.l    d0,…screev€
          move.w    #0,-(sp)
          move.l    #scr1,-(sp)
          move.l    #scr1,-(sp)
          move.w    #5,-(sp)
          trap      #14
          lea.l     $0000000c(sp),sp

          bsr       …evakuier€

;    move.w    #2,-(sp)  ;screen checkin
;   trap      #$e
; adda.l    #2,sp
€;       move.l    d0,l0012
;      move.w    #4,-(sp)
;     trap      #$e
;    adda.l    #2,sp
;   move.w    d0,l0011

          .DC.b $a0,$0a       ;…maus raus
gnark€:…    €
;  jsr piclad1
          move.w    #127,d0
          movea.l   #pb2,a0
rr:       clr.l     (a0)+
          dbra      d0,rr
          move.w    #280,xyliste
          move.w    #158,xyliste+2
          movea.l   #xyliste,a0
          move.w    #31,d0
tr:       move.w    #-64,(a0)+
          move.w    #-64,(a0)+
          move.l    #bewtab,(a0)+
          dbra      d0,tr
          bsr       bufinit
          bsr       prep
          bsr       sound
          bsr       l000e
          move.w    #1,d6
          move.w    #1,d7     ;…richt indikat€


hau:      cmpi.b    #$39,$fffc02
          beq       …quidde€
          cmpi.b    #2,$fffc02
          beq       tabl1
          cmpi.b    #3,$fffc02
          beq       tabl2
          tst.b     …hugl€
          bra       …hau€
          tst.w     d7
          bpl       oben
unten:    movea.l   #scr1+99*160,a0
          movea.l   #scr2+99*160,a1
          bra       vhertz
oben:     movea.l   #scr1+98*160,a0
          movea.l   #scr2+98*160,a1
vhertz:   move.w    #1,vsync
evwait:   tst.w     vsync
          bne       evwait
          move.w    #0,mass
…powslide€: move.w    #1,vsync

vwait:    tst.w     vsync
          bne       vwait
          movea.l   a0,a3     ;bak fuer copy
          movea.l   a1,a4
€          bsr       …rollo€
          movea.l   a3,a0
          movea.l   a4,a1
          tst.w     d7
          bpl       …rightso€
          suba.w    #160,a0
          suba.w    #160,a1
…rightso€:  move.w    #39,d0
copl:     move.l    (a1)+,(a0)+         ;dest-->quell
          dbra      d0,copl
          tst.w     d7
          bpl       r
          adda.w    #160,a0
          adda.w    #160,a1
r:        
          addi.w    #1,mass
          cmp.w     mass,d6
          bhi       powslide
          add.w     d7,d6
          cmpi.w    #10,d6
          bcs       …nieder€
;     adda.w    #160,a0
;       adda.w    #160,a1
          move.w    #-1,d7
…nieder€:   cmpi.w    #0,d6
          bhi       hau
          move.w    #1,d7
          bra       hau
…rollo€:    tst.w     d7
          bmi       …rololi€
…rolore€:             ;a0=zeile d0=anz a1=dest

          move.w    #17,d1
loop2:    move.l    (a0)+,8(a1)
          move.l    (a0)+,12(a1)
          adda.l    #8,a1
          dbra      d1,loop2
          adda.w    #16,a0
          adda.w    #16,a1
          rts       
…rololi€:   
          move.w    #17,d1
loop22:   move.l    -(a0),-8(a1)
          move.l    -(a0),-12(a1)
          subq.w    #8,a1
          dbra      d1,loop22
          suba.w    #16,a0
          suba.w    #16,a1
          rts       

          moveq.l   #0,d2
          moveq.l   #0,d3
          moveq.l   #0,d4
          moveq.l   #0,d5
€          move.w    (a0)+,d2
          move.w    (a0)+,d3
          move.w    (a0)+,d4
          move.w    (a0)+,d5
          ror.l     #1,d2
          ror.l     #1,d3
          ror.l     #1,d4
          ror.l     #1,d5
          or.w      d2,(a1)+
          or.w      d3,(a1)+
          or.w      d4,(a1)+
          or.w      d5,(a1)+
          swap.w    d2
          swap.w    d3
          swap.w    d4
          swap.w    d5
          clr.l     (a1)
          clr.l     4(a1)
          move.w    d2,(a1)+
          move.w    d3,(a1)+
          move.w    d4,(a1)+
          move.w    d5,(a1)+
          subq.l    #8,a1
          dbra      d1,loop2
          rts       

tabl1:    move.l    #…urdis€,whatab
;   move.l    #…schein€,whatcol
          move.b    #98,…eckrast€
          bra       hau
tabl2:    move.l    #distab,whatab
;    move.l    #schein-2,whatcol
          move.b    #100,eckrast
          bra       hau
…quidde€:   bsr       …quitotal€
          movea.l   oldstack,sp

          move.w    #0,-(sp)
          trap      #1
…bauhaus€:  .DCB.b 160,0
mass:     .DC.w 0
hugl:     .DC.b 0
…kilroy€:   .DC.b 0
          .EVEN 
prep:     
          movea.l   #…zuendpol€,a0
          movea.l   #scr1+98*160,a1
          movea.l   #scr2+98*160,a2
          move.w    #2039,d0
…packut€:   
          move.w    (a0),(a1)+
          move.w    (a0)+,(a2)+
          move.w    (a0),(a1)+
          move.w    (a0)+,(a2)+
€          move.w    (a0),(a1)+
          move.w    (a0)+,(a2)+
          move.w    #$0,(a1)+
          move.w    #$0,(a2)+
          dbra      d0,packut
          movea.l   #…zuendlog€,a0
          movea.l   #scr1,a1
          movea.l   #scr2,a2
          move.w    #1159,d0
…utlog€:    
          move.w    (a0),(a1)+
          move.w    (a0)+,(a2)+
          move.w    (a0),(a1)+
          move.w    (a0)+,(a2)+
          move.w    (a0),(a1)+
          move.w    (a0)+,(a2)+
          move.w    #$0,(a1)+
          move.w    #$0,(a2)+
          dbra      d0,utlog
          movea.l   #scr1+56*160,a0
          movea.l   #scr2+56*160,a1
          move.w    #42*40,d0
desinf:   clr.l     (a0)+
          clr.l     (a1)+
          dbra      d0,desinf
          rts       

bufinit:  
;    move.l    #damn,$70
;    move.l    #damn,$68
          movea.l   #…zuender€,a3
          movea.l   #buflist+28,a2
          movea.l   (a2),a0
          movea.l   a3,a1
          move.w    #7679,d3  ;d3 = zeilenanzahl v. blk30*16*16
copyblk:  
          move.l    (a1)+,(a0)+
          move.w    #0,(a0)+  ;…nullen hinterschieben€
          dbra      d3,copyblk
          move.l    #6,d7
…rotcop€:   movea.l   (a2),a0
          movea.l   -(a2),a1
          bsr       rotate
          dbra      d7,rotcop
          rts       

rotate:   
          move.l    #0,(a1)
          move.w    #23039,d6 ;d5=UEBERanzahl der blks*1200/4-1
loop3:    
          moveq.l   #0,d0
          move.w    (a0)+,d0
          swap.w    d0
          lsr.l     #2,d0
€          swap.w    d0
          or.w      d0,(a1)+
          swap.w    d0
          tst.w     d6
          beq       return
          move.w    d0,(a1)+
          subq.l    #2,a1
          dbra      d6,loop3
return:   rts       


…quitotal€: 
          move.w    #$2700,sr
          lea.l     l0016,a0
          move.b    (a0)+,$fffa07       ;.L
          move.b    (a0)+,$fffa09       ;.L
          move.b    (a0)+,$fffa13       ;.L
          move.b    (a0)+,$fffa15       ;.L
          move.b    (a0)+,$fffa17       ;.L
          move.b    (a0)+,$fffa19       ;.L
          move.b    (a0)+,$fffa1f       ;.L
          move.l    l0013,$70 ;.L
          move.l    l0014,$00000134     ;.L
          move.l    l0015,$00000120     ;.L
          move.l    #$08080000,$ffff8800
          move.l    #$09090000,$ffff8800
          move.l    #$0a0a0000,$ffff8800
          bset      #1,$482
          move.l    savhbl,$68
          move.w    #1,-(sp)
          move.l    screev,-(sp)
          move.l    screev,-(sp)
          move.w    #5,-(sp)
          trap      #14
          adda.l    #12,sp
          move.b    screev+1,$ff8201
          move.b    screev+2,$ff8203
          movem.l   l0017,d0-d7
          movem.l   d0-d7,$ff8240
          move.w    #$2300,sr
          .DC.b $a0,$09
          rts       

…vorstufe€: clr.b     $fffa1b   ;cntrl:…stohp!€
          move.b    eckrast,$fffa21     ;data
          move.b    #8,$fffa1b          ;cntr:on!
          clr.l     $ff8242
          clr.l     $ff8246
          clr.l     $ff824a
          clr.w     $ff824e
          movem.l   d4,-(sp)
          movem.l   …snirkpal€,d4-d7
          movem.l   d4-d7,$ff8250
          movem.l   (sp)+,d4
€          move.l    #raser,$120
          rte       

…raser€:    clr.b     $fffa1b   ;cntrl:…stohp!!€
          move.b    (a5)+,$fffa21       ;data
          move.b    #8,$fffa1b          ;cntr:on!
fix1:     movem.l   (a6)+,d5-d7         ;…vorgaren€: l001c
          movem.l   d5-d7,$ff8242
          move.w    (a6)+,$ff8240+14
          addq.w    #2,a6
coli1     equ fix1+5
col1      equ fix1+2
;  addi.b    #2,coli1
          rte       
whatab:   .DC.l distab
whatcol:  .DC.l schein
…scrogi€:   .DC.w 0
logopal:  .DC.w $0000,$0003,$0005,$226,$446,$760,$640,$530
…snirkpal€: .DC.w $0220,$0330,$0440,$0570,$0440,$0340,$0330,$0220
          .DC.w $0003,$0004,$0006,$0007,$0006,$0004,$0003,$0002
…buchz€:    .DC.l aaa ;letter vec
          .DC.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   ;…kick slot€
schein:   .DS.b 160
          .DC.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
code:     .DS.b 160
          .EVEN 
distab:   .DC.b 2,4,6,8,10,12,14,16,18,20,199,0,0,0,0,0,0,0,0
          .EVEN 
urdis:    .DC.b 2,4,6,8,10,12,14,16,18,20,199
          .EVEN 
…scrogtab€: .DC.b 0,1,7,2,1,1,6,2,2,1,5,2,3,1,4,2,-1,1
          .DC.b -1,1,3,1,0,1,2,1,1,1
          .DC.b -2,-2         ;-1=eckwert -2=…schlupz€
eckrast:  .DC.b 38
pend:     .DC.b 2
          .EVEN 
l000e:    
;   move.w    #$0000,$ff8240
          move.w    #$2700,sr
          bclr      #3,$fffa17          ;.L
          move.b    #$01,$fffa07        ;.L ;21
          move.b    #0,$fffa09          ;.L
          move.b    #$01,$fffa13        ;.L ;21
          move.b    #0,$fffa15          ;.L
          move.b    #$11,$fffa19        ;.L
          move.b    #$50,$fffa1f        ;.L
          move.l    #l001c,$70          ;.L
;          move.l    l0098,$134          ;.L
          move.l    #…raser€,$120         ;.L
          move.w    #$2300,sr
          rts       



…evakuier€: clr.w     $482
          movem.l   urpal,d0-d7
          movem.l   d0-d7,$ff8240
          moveq.l   #0,d0
          moveq.l   #0,d1
          moveq.l   #0,d2
          moveq.l   #0,d3
          moveq.l   #0,d4
          moveq.l   #0,d5
          moveq.l   #0,d6
          moveq.l   #0,d7
          move.w    #$2700,sr
          lea.l     l0016,a0
          move.b    $fffa07,(a0)+
          move.b    $fffa09,(a0)+
          move.b    $fffa13,(a0)+
          move.b    $fffa15,(a0)+
          move.b    $fffa17,(a0)+
          move.b    $fffa19,(a0)+
          move.b    $fffa1f,(a0)+
          move.l    $70,l0013
          move.l    $00000134,l0014
          move.l    $00000120,l0015
          move.l    $68,savhbl
;   move.b    $ff8201,screev+1
;    move.b    $ff8203,screev+2
          move.w    #$2000,sr
          rts       
urpal:    .DC.w 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
dire:     .DC.w 199
screev:   .DC.l 0   ;sav par
savhbl:   .DC.l 0
l0013:    .DC.l 0
l0014:    .DS.w 2   ;,0
l0015:    .DS.w 2   ;,0
l0016:    .DS.w 4   ;,0
l0017:    .DC.b $66,$66,$07,$00,$00,'p',$00,$00
          .DC.b $00,$07,$07,$07,$00,'w',$05,'U'
          .DC.b $03,'3',$07,'3',$03,'s',$07,'s'
          .DC.b $03,'7',$07,'7',$03,'w',$00,$00



l001c:    
;   move.w    #$666,$ff8240
          movem.l   d0-d4/a0-a4,-(sp)   ;moder
          movea.l   whatab,a5
          cmpi.w    #30000,vbicount     ;~
          beq       …purswi€
;      addq.w    #1,vbicount
;     andi.w    #3,vbicount
;     bne       purswi
offer:    movea.l   #scrogtab,a0
          move.w    scrogi,d0
€          addi.w    #2,scrogi
          move.b    1(a0,d0.w),d1       ;d1=anz
          move.b    0(a0,d0.w),d0       ;d0=rast port#
          ext.w     d0
          bpl       switche   ;"norm"rast
…iiih€:               ;  move.w    #30000,vbicount
          cmpi.w    #-2,d0    ;-1=last try -2=new line
          beq       new
;      move.w    #30000,vbicount
          add.b     d1,eckrast          ;erst -1 -->…eckwert€
          bra       …purswi€
;  cmpi.w    #-2,scrogi
;   beq       new
;   addq.b    #2,eckrast
;   bra       switche
new:      
          move.w    #0,scrogi ;reset
;   move.w    #30000,vbicount
…nui€:      tst.b     …flago€
          beq       …tieken€
          subi.l    #16,…buchz€
          movea.l   buchz,a2
          tst.w     14(a2)    ;1st line?
          bpl       …inalph€
          clr.b     flago
          bra       inalph
tieken:   move.b    #1,flago
          moveq.l   #0,d3
          movea.l   firstl,a0
…eg€:       move.b    (a0)+,d3
          bpl       vulg
          movea.l   #d3text,a0
          bra       eg

…vulg€:     subi.b    #32,d3
          move.l    a0,firstl
          movea.l   #trans,a0
          move.b    0(a0,d3.w),d3
          movea.l   #mule,a0
          move.w    0(a0,d3.w),d3
          movea.l   #aaa,a2
          adda.w    d3,a2
          move.l    a2,buchz
          movea.l   #…gloom€,a2 ;…hauptsache >> 0 <<€
inalph:   
          movea.l   #gloom,a0
          movea.l   #code-16,a1

          move.l    (a2)+,(a1)+
          move.l    (a2)+,(a1)+
          move.l    (a2)+,(a1)+
          move.l    (a2)+,(a1)          ;a1=#schein

          movea.l   #code+144,a1
€          movea.l   #schein+144,a2
          move.w    #9,d0     ;70…rast slots€
…shot€:     movem.l   -16(a1),d1-d4
          movem.l   d1-d4,(a1)          ;code tab …shiftshot€
          lsl.w     #1,d0
          movea.l   #gloom,a0
          adda.w    d0,a0
          lsr.w     #1,d0
          move.w    0(a0,d1.w),2(a2)
          move.w    0(a0,d2.w),6(a2)
          move.w    0(a0,d3.w),10(a2)
          move.w    0(a0,d4.w),14(a2)
          swap.w    d1
          swap.w    d2
          swap.w    d3
          swap.w    d4
          move.w    0(a0,d1.w),(a2)
          move.w    0(a0,d2.w),4(a2)
          move.w    0(a0,d3.w),8(a2)
          move.w    0(a0,d4.w),12(a2)



;     move.l    d1,x(a1)
;    move.l    d2,xx(a1)   ;
;    move.l    d3,x(a1)
;    move.l    d4,x(a1)
;          swap.w    d3
;         swap.w    d4
;…hase€:     movem.l   d1-d4,(a1)
;   move.w    -2(a1),12(a1)
          suba.w    #16,a2
          suba.w    #16,a1
          dbra      d0,shot
          moveq.l   #0,d1
          moveq.l   #0,d2
          moveq.l   #0,d3
          moveq.l   #0,d4
          move.b    #38,eckrast
          movem.l   urdis,d0-d2         ;…new zeil€
          movem.l   d0-d2,distab
          bra       offer
gh:       .DC.w 0
switche:  
          add.b     d1,0(a5,d0.w)

purswi:   clr.b     $fffa1b   ;.S
          move.b    #60,$fffa21         ;.S raser
          move.b    #8,$fffa1b          ;.S
          movea.l   #schein,a6
          movem.l   logopal,d0-d3
          movem.l   d0-d3,$ff8240
          move.w    #$0220,$ff8240+16
          move.l    #…vorstufe€,$120
€;          move.w    #vorstufe,$120
;        move.l    #0,$ff8242
;       move.l    #0,$ff8246
;      move.l    #0,$ff824a
;      move.w    #0,$ff82e
; cmpi.b    #82,eckrast
;    bne       switche
; move.w    #30000,vbicount

          cmpi.w    #30000,vbicount
          beq       fdh

;          move.w    #30000,vbicount
;          move.l    #vorstufe,$120
; move.l    #l001b,l0019
;move.l    #scrollpal,zeigera
;          move.w    scrogi,d0
;         addi.w    #2,d0
;        andi.w    #31,d0
;       add.w     d0,coli1
;       move.w    d0,scrogi
;          move.l    #…warmup€,zeiger1

scrswitch:          


          cmpi.l    #scr1+6,screen
          beq       mctwo
          move.l    #scr1+6,screen
          movea.l   pb1zz,a2
          bra       scrset
…mctwo€:    move.l    #scr2+6,screen
          movea.l   pb2zz,a2  ;a2=pbtab
scrset:   



          move.b    screen+1,$ff8201
          move.b    screen+2,$ff8203
;    bra       fdh
;    move.w    sprges,…spranz€
          move.w    #160,d0   ;d0=160 local!
          movea.l   a2,a3     ;a3=pbtab local!
          movea.l   screen,a1 ;screen local
;    adda.w    #4*2,a3   ;SPRANZ*2
          move.w    spranz,d2
…putit€:    
          bsr       …kickit€
          dbra      d2,putit
…flutsch€:  tst.b     …kilroy€
          beq       fg
          clr.b     kilroy
          addi.b    #2,pb1zz
          addi.b    #2,pb2zz
€          subi.w    #1,spranz
fg:       movea.l   xylistezz,a4
          movea.l   indivzz,a3
          movea.l   …silotabzz€,a1
…grein€:    
          movea.l   4(a4),a0  ;…bewtabindi€ in xytab!
          adda.w    (a3),a0
          move.b    (a0)+,d0
          cmpi.b    #-99,d0
          bne       bewon
          move.w    #0,(a3)
          bra       grein
bewon:    move.b    (a0)+,d1
          move.b    (a0)+,d4  ;…rotophas€
          ext.w     d4
          movea.l   #…rotototo€,a0
          move.w    0(a0,d4.w),d4
          addi.w    #3,(a3)
          move.l    a3,d2
          addq.b    #2,d2
          movea.l   d2,a3
          ext.w     d0
          ext.w     d1
          add.w     d1,2(a4)
          add.w     d0,(a4)
          bmi       …schlurf€
          cmpi.w    #-32,2(a4)
          blt       schlurf
          cmpi.w    #200,2(a4)
          bhi       schlurf
          bra       gude
schlurf:  move.b    #1,kilroy ; subq.w    #1,spranz
          move.w    #-64,(a4)
          move.w    #-64,2(a4)
          move.w    #-55,(a1) ;…marker kickit€
          addq.b    #8,xylistezz+3      ;…ring inc€
;   addq.b    #2,pb1zz+3
;   addq.b    #2,pb2zz+3
          addq.b    #2,indivzz+3
          addq.b    #2,silotabzz+3
          bra       space
gude:     
          move.w    (a1),d3   ;…spritpickUEBER€
          bmi       space
          bsr       setshape
space:    move.l    a1,d0
          addq.b    #2,d0
          movea.l   d0,a1
          cmpi.w    #248,(a4) ;…schlupz?€
          bgt       outta     ;…noch zu eng€
;  cmpi.w    #166,2(a4)
;   bhi       outta
          move.l    a2,d0
          addq.b    #2,d0
€          movea.l   d0,a2
          move.l    a4,d0
          addq.b    #8,d0
          movea.l   d0,a4
;         addq.w    #2,a2
;          addq.w    #4,a4
;   subq.w    #1,spranz
; bpl       …grein€
; move.w    sprges,d0
; cmp.w     max,d0
; beq       outta
;     move.w    -4(a4),…xyheikl€
;  cmpi.w    #256,-4(a4)
; bhi       outta
oschein:  
          tst.w     (a4)
          bpl       grein     ;def.allready
…hui€:      addq.w    #1,…spranz€
          move.w    #0,(a3)
          move.w    #280,(a4)
          move.w    ind,d0
          add.w     d0,…hoho€

          cmpi.w    #80,hoho
          bcs       …nodang€
          move.w    #-4,ind
…nodang€:   cmpi.w    #68,hoho
          bhi       …pok€
          move.w    #4,ind

…pok€:      move.w    hoho,2(a4)

;        move.l    a4,marker
nextchar: 
          movea.l   first,a0
          cmpa.l    #typend,a0
          bcs       printon
          move.l    #typetable,first
          movea.l   first,a0
printon:  moveq.l   #0,d3
          move.b    (a0),d3
          cmpi.b    #31,d3    ;mind. space
          bhi       …normtyp€   ;dann type
          cmpi.b    #10,d3
          beq       …zuck€      ;…snak bewtab€ aender
          cmpi.b    #11,d3
          beq       cut       ;outfit aender
          movea.l   #…speisek€,a0         ;…qual d.wahl€
          move.l    0(a0,d3.w),…bewchoose€       ;vormerken / d3 ggf.lsl2
          move.w    4(a0,d3.w),max
          addq.l    #1,first
;       movea.l   xylistezz,a0
;     move.w    sprges,d3
;…minpumpe€: move.w    #-64,(a0)+
€;          move.w    #-64,(a0)+
;          dbra      d3,…minpumpe€
;       move.w    #0,sprges
;    move.w    #0,spranz

          bra       nextchar
…zuck€:     addi.l    #2,first
          move.b    1(a0),d3
          move.w    d3,bewswitch
          bra       nextchar
cut:      addi.l    #2,first
          move.b    1(a0),d3
          move.w    d3,stilswitch
          bra       nextchar
normtyp:  subi.b    #32,d3
          movea.l   #trans,a0
          move.b    0(a0,d3.w),d3
          movea.l   #mule,a0
          move.w    0(a0,d3.w),d3
          move.l    bewchoose,4(a4)     ;…bewtab€ …fluestern€
          move.w    d3,(a1)+
          addq.l    #1,first

outta:    
rudow:    addi.w    #2,bewtabvec

fdh:      movem.l   a5/a6,-(sp)
          bsr       sound+8
          movem.l   (sp)+,a5/a6
          tst.w     vsync
          beq       moder
          subi.w    #1,vsync
moder:    movem.l   (sp)+,d0-d4/a0-a4   ;l001c
          rte       


…kickit€:   movea.l   a1,a0
          adda.w    (a3),a0
          move.l    a3,d3
          addq.b    #2,d3
          movea.l   d3,a3
          move.l    #3,d3
erase:    
          clr.w     (a0)
          clr.w     8(a0)
          clr.w     16(a0)
          adda.w    d0,a0
          clr.w     (a0)
          clr.w     8(a0)
          clr.w     16(a0)
          adda.w    d0,a0
          clr.w     (a0)
          clr.w     8(a0)
          clr.w     16(a0)
€          adda.w    d0,a0
          clr.w     (a0)
          clr.w     8(a0)
          clr.w     16(a0)
          adda.w    d0,a0
          clr.w     (a0)
          clr.w     8(a0)
          clr.w     16(a0)
          adda.w    d0,a0
          clr.w     (a0)
          clr.w     8(a0)
          clr.w     16(a0)
          adda.w    d0,a0
          clr.w     (a0)
          clr.w     8(a0)
          clr.w     16(a0)
          adda.w    d0,a0
          clr.w     (a0)
          clr.w     8(a0)
          clr.w     16(a0)
          adda.w    d0,a0
          dbra      d3,erase
          rts       
setshape: 
          movem.l   a1,-(sp)
          move.w    (a4),d0   ;x
          bmi       weg
          move.w    2(a4),d1  ;y
          cmpi.w    #-30,d1
          blt       weg
          cmpi.w    #200,d1
          bhi       weg

;  not.w     d1        ;…over the top€
;   addq.w    #1,d1     ;…make"+"€
;   andi.w    #$fe,d1   ;…bit1 abschmirgln€
;   lsr.w     #1,d1     ;16zeil kompri.
;   move.w    d1,d5
;    mulu.w    #6,d5     ;1zeil=6byt
;    add.w     d5,d3     ;inc UEBRaddwert
;   move.w    #15,d5
;   sub.w     d1,d5     ;d5=loopwertUEBERlocal
;    moveq.l   #0,d1     ;…at the top€
;   bra       onscr

full:               ;  cmpi.w    #166,d1
;  bcs       onscrreset
;  rts
onscrreset:         move.w    #15,d5    ;UEBERlocal loopanz
onscr:    move.w    d0,d2
          mulu.w    #160,d1
          lsr.w     #4,d2
          lsl.w     #3,d2
          add.w     d2,d1
€          movea.l   screen,a1
          adda.w    d1,a1
          move.w    d1,(a2)   ;a2 wurde ueberg.(pufadr)
          andi.w    #15,d0
          lsl.w     #1,d0
          movea.l   #shifttabvec,a0
sprmodi:  movea.l   0(a0,d0.w),a0       ;verschieb.-wert
;sprmod:   adda.l    (a3),a0   ;a3=UEBER.shiftdaten anfang(tabelle)
;d7=ueber anz. v. zeilen
          adda.l    #buffer8,a0         ;+bufbase
          adda.w    d3,a0     ;+typetypUEBER
          adda.l    d4,a0     ;+rotophasUEBER€
          move.w    d5,d3     ;d5=UEBRlocal s.o.
set1:     
          movem.w   (a0)+,d0-d2         ;die maske lesen
          or.w      d0,(a1)   ;MOVEP OPTI
          or.w      d1,8(a1)
          or.w      d2,16(a1)
          adda.w    #160,a1
          or.w      d0,(a1)   ;MOVEP OPTI
          or.w      d1,8(a1)
          or.w      d2,16(a1)
          adda.w    #160,a1
          dbra      d3,set1
weg:      movem.l   (sp)+,a1
          rts       


piclad1:  

          movea.l   #fontfile,a0
          bsr       open
          movea.l   #…zuender€,a0
          move.l    #30720,d0 ;font+sfpic+alliancpic
          bsr       read
          bsr       close
          rts       


fontfile: .DC.b "d:\roundup.dat",0
picvor:   .DC.b "a:\baal.exp",0
pigg:     .DC.b "a:\loading.exp",0
picfil1:  .DC.b "a:\big.exp",0
menufil:  .DC.b "a:\menu2.exp",0
          .EVEN 

…; Comment from Delta Force:…

; Of coz the OS is dead in this demo, so look at the following
; lines....

open:     
          move.w    #0,-(sp)
          move.l    a0,-(sp)
          move.w    #$3d,-(sp)
          trap      #1
          addq.l    #8,sp
          move.w    d0,handle
          tst.w     d0
          bmi       error
          rts       
read:     move.l    a0,-(sp)  ;Worein ?
          move.l    d0,-(sp)  ;Wieviel ?
          move.w    handle,-(sp)
          move.w    #$3f,-(sp)
          trap      #1
          adda.w    #12,sp
          tst.w     d0
;    bmi       error
          rts       

close:    
          move.w    handle,-(sp)
          move.w    #$3e,-(sp)
          trap      #1
          addq.l    #4,sp
          rts       
handle:   .DC.w 0
error:    trap      #10
€




flag:     .DC.b 160 ;…kustpaus. am anf.€
          .EVEN 
vsync:    .DC.w 0
bewswitch:          .DC.w -1
stilswitch:         .DC.w -1

shifttabvec:        .DC.l 0,46080,92160,138240,184320,230400,276480,322560
shifttabsnak:       .DC.l 0,768,1536,2304,3072,3840,4608,5376
shifttabsnak2:      .DC.l 0,384,768,1152,1536,1920,2304,2688
;…xyheikl€:  .DC.w 0,34          ;1st sprit orient.
;xyliste:  .DC.w 280,68
          .DCB.w 32,-1        ;16pot.spr
;  .DC.w 288,0,288,0,288,0,288,0,288,0,288,0,288,0,288,0,288,0,288,0
; .DC.w 288,0,288,0,288,0,288,0,288,0,288,0,288,0,288,0,288,0,288,0,288,0,288,0 
  ;spr cont.
screen:   .DC.l 0
vbicount: .DC.w 0
spranz:   .DC.w 0
sprges:   .DC.w 0
max:      .DC.w 9
marker:   .DC.l xyliste
hoho:     .DC.w 0
ind:      .DC.w 4
xylistezz:          .DC.l xyliste
€pb1zz:    .DC.l pb1
pb2zz:    .DC.l pb2
silotabzz:          .DC.l silotab
indivzz:  .DC.l indiv
bewchoose:          .DC.l bewtab
first:    .DC.l typetable
;…10dummybytes€
…rotototo€: .DC.w 0,2,4,6,8,0,2880,5760,8640,11520,14400,17280,20160,23040,25920,2
8800,31680,34560,37440,40320,43200

mule:     
          .DC.w 0,96,192,288,384,480,576,672,768,864,960,1056,1152,1248,1344,144
0,1536,1632,1728,1824,1920,2016,2112,2208,2304,2400,2496
          .DC.w 2592,2688,2784,2880,2976,3072,3168,3264,3360,3456,3552,3648,3744
,-1,3840,3936,4032,4128,4224,4320,4416,4512,4608,4704,4800,4896,4992
          .DC.w 5184,5376,5568,5760,5952,6144,6336,6528,6720,6912,7104,7296,7488
          .DC.w -1  ;-=space

trans:    .DC.b 80,76,99,99,78,99,99,99,56,58,99,99,54,99,52,99       ;start bei
 32(space)
          .DC.b 70,52,54,56,58,60,62,64,66,68,99,99,99,99,99,78,99
          .DC.b 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,
46,48,50
          .EVEN 

bewi:     .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10

          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10
          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10
          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10
          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10
          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10

          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10
          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10
          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10
          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10
          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10

          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10
          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10
€          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10
          .DC.b -4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,-4,0,10,
-4,0,10


bewtab:   

;          .DC.b 0,2,10,0,2,10,0,2,10,0,2,10,0,4,10,0,4,10,0,8,10,0,8,10

;          .DC.b 0,8,10,0,8,10,0,8,10,0,8,10,0,8,10,0,8,10,0,8,10,0,8,10,0,8,10,
0,8,10,0,8,10
;         .DC.b 0,8,10,0,8,10,0,8,10,0,8,10,0,4,10,0,4,10,0,4,10,0,2,10,0,2,10


bewi6:    .DC.b -4,1,12,-4,1,12,-4,1,12,-4,1,12,-4,1,12,-4,1,12,-4,1,12,-4,1,12
          .DC.b -4,1,12,-4,1,12,-4,1,12,-4,1,12,-4,1,12,-4,1,12,-4,1,12,-4,1,12
          .DC.b -4,2,14,-4,2,14,-4,2,14,-4,2,14,-4,2,14,-4,2,14,-4,2,14,-4,2,14
          .DC.b -4,2,14,-4,2,14,-4,2,14,-4,2,14,-4,2,14,-4,2,14,-4,2,14,-4,2,14
          .DC.b -4,2,14,-4,2,14,-4,2,14,-4,3,16,-4,3,16,-4,3,16,-4,3,16,-4,3,16
          .DC.b -4,3,16,-4,3,16,-4,3,16,-4,3,16,-4,3,16,-4,3,16,-4,3,16,-4,3,16



;…hinher€

bewi5:    .DC.b -4,0,10
          .DC.b -4,0,12,-4,0,12
          .DC.b -4,0,14,-4,0,14
          .DC.b -4,0,16,-4,0,16,-4,0,16
          .DC.b -4,0,18,-4,0,18,-4,0,18,-4,0,18
          .DC.b -4,0,20,-4,0,20,-4,0,20,-4,0,20,-4,0,20
          .DC.b -4,0,22,-4,0,22,-4,0,22,-4,0,22,-4,0,22
          .DC.b -4,0,20,-4,0,20,-4,0,20,-4,0,20
          .DC.b -4,0,18,-4,0,18,-4,0,18,-4,0,18
          .DC.b -4,0,16,-4,0,16,-4,0,16
          .DC.b -4,0,14,-4,0,14
          .DC.b -4,0,12,-4,0,12
          .DC.b -4,0,10
          .DC.b -4,0,40,-4,0,40
          .DC.b -4,0,38,-4,0,38,-4,0,38
          .DC.b -4,0,36,-4,0,36,-4,0,36,-4,0,36
          .DC.b -4,0,34,-4,0,34,-4,0,34,-4,0,34,-4,0,34
          .DC.b -4,0,36,-4,0,36,-4,0,36,-4,0,36
          .DC.b -4,0,38,-4,0,38,-4,0,38
          .DC.b -4,0,40,-4,0,40
          .DC.b -4,0,10
          .DC.b -4,0,12,-4,0,12
          .DC.b -4,0,14,-4,0,14
          .DC.b -4,0,16,-4,0,16,-4,0,16
          .DC.b -4,0,18,-4,0,18,-4,0,18
          .DC.b -4,0,20,-4,0,20,-4,0,20,-4,0,20
          .DC.b -4,0,22,-4,0,22,-4,0,22,-4,0,22,-4,0,22
          .DC.b -4,0,20,-4,0,20,-4,0,20,-4,0,20
€          .DC.b -4,0,18,-4,0,18,-4,0,18
          .DC.b -4,0,16,-4,0,16,-4,0,16
          .DC.b -4,0,14,-4,0,14
          .DC.b -4,0,16,-4,0,16,-4,0,16
          .DC.b -4,0,18,-4,0,18,-4,0,18,-4,0,18
          .DC.b -4,0,20,-4,0,20,-4,0,20,-4,0,20,-4,0,20
          .DC.b -4,0,22,-4,0,22,-4,0,22,-4,0,22,-4,0,22
          .DC.b -4,0,20,-4,0,20,-4,0,20,-4,0,20
          .DC.b -4,0,18,-4,0,18,-4,0,18,-4,0,18
          .DC.b -4,0,16,-4,0,16,-4,0,16
          .DC.b -4,0,14,-4,0,14
          .DC.b -4,0,12,-4,0,12
          .DC.b -4,0,10


;…obenfallab€
bewi4:    .DC.b -2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,
-2,0,40,-2,0,40
          .DC.b -2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,
-2,0,40,-2,0,40
          .DC.b -2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,
-2,0,40,-2,0,40
          .DC.b -2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40,
-2,0,40,-2,0,40
          .DC.b -2,0,40,-2,0,40,-2,0,40,-2,0,40,-2,0,40
          .DC.b -4,-2,38,-4,-2,38,-4,-2,38,-4,-2,38,-4,-2,38,-4,-2,38,-4,-2,38,-
4,-2,38,-4,-2,38,-4,-2,38
          .DC.b -4,4,14,-4,4,14,-4,4,14,-4,4,14,-4,4,14,-4,4,14,-4,4,14,-4,4,14
          .DC.b -2,-4,36,-2,-4,36,-2,-4,36,-2,-4,36,-2,-4,36,-2,-4,36,-2,-4,36,-
2,-4,36
          .DC.b 0,-4,34,0,-4,34,0,-4,34,0,-4,34,0,-4,34,0,-4,34,0,-4,34,0,-4,34,
0,-4,34
          .DC.b 0,-4,34,0,-4,34,0,-4,34,0,-4,34,0,-4,34,0,-4,34,0,-4,34,0,-4,34,
0,-4,34
          .DC.b 0,-4,34,0,-4,34,0,-4,34,0,-4,34,0,-4,34,0,-4,34,0,-4,34,0,-4,34,
0,-4,34



;…untenfallab€
bewi3:    .DC.b -2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,
-2,0,10,-2,0,10
          .DC.b -2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,
-2,0,10,-2,0,10
          .DC.b -2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,
-2,0,10,-2,0,10
          .DC.b -2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,
-2,0,10,-2,0,10
          .DC.b -2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10,-2,0,10

          .DC.b -4,2,12,-4,2,12,-4,2,12,-4,2,12,-4,2,12,-4,2,12,-4,2,12,-4,2,12,
-4,2,12,-4,2,12
          .DC.b -4,4,14,-4,4,14,-4,4,14,-4,4,14,-4,4,14,-4,4,14,-4,4,14,-4,4,14
          .DC.b -2,4,16,-2,4,16,-2,4,16,-2,4,16,-2,4,16,-2,4,16,-2,4,16,-2,4,16
€          .DC.b 0,4,18,0,4,18,0,4,18,0,4,18,0,4,18,0,4,18,0,4,18,0,4,18,0,4,18
          .DC.b 0,4,18,0,4,18,0,4,18,0,4,18,0,4,18,0,4,18,0,4,18,0,4,18,0,4,18
          .DC.b 0,4,18,0,4,18,0,4,18,0,4,18,0,4,18,0,4,18,0,4,18,0,4,18,0,4,18




;fast rotate

bewi2:    .DC.b -4,0,10,-4,0,40,-4,0,38,-4,0,36,-4,0,34,-4,0,32,-4,0,30,-4,0,28,
-4,0,26
          .DC.b -4,0,24,-4,0,22,-4,0,20,-4,0,18,-4,0,16,-4,0,14,-4,0,12
          .DC.b -4,0,10,-4,0,40,-4,0,38,-4,0,36,-4,0,34,-4,0,32,-4,0,30,-4,0,28,
-4,0,26
          .DC.b -4,0,24,-4,0,22,-4,0,20,-4,0,18,-4,0,16,-4,0,14,-4,0,12
          .DC.b -4,0,10,-4,0,40,-4,0,38,-4,0,36,-4,0,34,-4,0,32,-4,0,30,-4,0,28,
-4,0,26
          .DC.b -4,0,24,-4,0,22,-4,0,20,-4,0,18,-4,0,16,-4,0,14,-4,0,12
          .DC.b -4,0,10,-4,0,40,-4,0,38,-4,0,36,-4,0,34,-4,0,32,-4,0,30,-4,0,28,
-4,0,26
          .DC.b -4,0,24,-4,0,22,-4,0,20,-4,0,18,-4,0,16,-4,0,14,-4,0,12
          .DC.b -4,0,10,-4,0,40,-4,0,38,-4,0,36,-4,0,34,-4,0,32,-4,0,30,-4,0,28,
-4,0,26


; jump
bewi1:    .DC.b -4,-8,12,-4,-8,12,-4,-8,12,-4,-6,12,-4,-6,14
          .DC.b -4,-6,14,-4,-4,14,-4,-4,14,-4,-4,14,-4,-2,16
          .DC.b -4,-1,18,-4,0,18,-4,0,18,-4,0,18,-4,0,18
          .DC.b -4,0,18,-4,0,18,-4,0,18,-4,1,18,-4,2,20,-4,2,20,-4,2,20,-4,2,20
          .DC.b -4,4,22,-4,4,22,-4,4,22,-4,6,22,-4,6,24,-4,6,24,-4,8,24,-4,8,24,
-4,8,24

          .DC.b -4,-8,28,-4,-8,28,-4,-8,28,-4,-6,28,-4,-6,30
          .DC.b -4,-6,30,-4,-4,30,-4,-4,30,-4,-4,30,-4,-2,32,-4,-2,32,-4,-2,32
          .DC.b -4,-1,34,-4,0,34,-4,0,34,-4,0,34,-4,0,34
          .DC.b -4,0,34,-4,0,34,-4,0,34,-4,1,34,-4,2,36,-4,2,36,-4,2,36,-4,2,36
          .DC.b -4,4,38,-4,4,38,-4,4,38,-4,6,38,-4,6,40,-4,6,40,-4,8,40,-4,8,40,
-4,8,40

          .DC.b -4,-8,20,-4,-8,20,-4,-8,20,-4,-6,20,-4,-6,22
          .DC.b -4,-6,22,-4,-4,22,-4,-4,22,-4,-4,22,-4,-2,24,-4,-2,24,-4,-2,24
          .DC.b -4,-1,26,-4,0,26,-4,0,26,-4,0,26,-4,0,26
          .DC.b -4,0,26,-4,0,26,-4,0,26,-4,1,26,-4,2,28,-4,2,28,-4,2,28,-4,2,28
          .DC.b -4,4,30,-4,4,30,-4,4,30,-4,6,30,-4,6,32,-4,6,32,-4,8,32,-4,8,32,
-4,8,32

          .DC.b -4,-8,20,-4,-8,20,-4,-8,20,-4,-6,20,-4,-6,22
          .DC.b -4,-6,22,-4,-4,22,-4,-4,22,-4,-4,22,-4,-2,24,-4,-2,24,-4,-2,24
          .DC.b -4,-1,26,-4,0,26,-4,0,26,-4,0,26,-4,0,26
          .DC.b -4,0,26,-4,0,26,-4,0,26,-4,1,26,-4,2,28,-4,2,28,-4,2,28,-4,2,28
          .DC.b -4,4,30,-4,4,30,-4,4,30,-4,6,30,-4,6,32,-4,6,32,-4,8,32,-4,8,32,
-4,8,32
          .DC.b -99,-99
€          .EVEN 

bewtabvec:          .DC.w 0
…speisek€:  .DC.l bewi1
          .DC.w 10
          .DC.l bewi2
          .DC.w 10
          .DC.l bewi3
          .DC.w 11
          .DC.l bewi4
          .DC.w 11
          .DC.l bewi6
          .DC.w 0
; .DC.b -9,-99
;syntax: 1=bewtab 11=style qqq

d3font:   .DC.w -1  ;…benutzung in new€:
…alphabas€: 
          .DC.w 0,0,32,32,32,0,0,-2
          .DC.w 0,32,0,0,0,32,0,0
          .DC.w 0,32,32,32,32,0,0,0
          .DC.w 0,32,0,0,0,32,0,0
          .DC.w 0,32,0,0,0,32,0,0
          .DC.w 0,32,0,0,0,32,0,0
aaa:      
          .DC.w 0,32,64,64,64,0,0,-2
          .DC.w 0,32,0,0,0,64,0,0
          .DC.w 0,32,64,64,64,0,0,0
          .DC.w 0,32,0,0,0,64,0,0
          .DC.w 0,32,0,0,0,64,0,0
          .DC.w 0,32,64,64,64,0,0,0
bbb:      

          .DC.w 0,32,32,32,32,32,32,-2
          .DC.w 32,0,0,0,0,0,0,0
          .DC.w 32,0,0,0,0,0,0,0
          .DC.w 32,0,0,0,0,0,0,0
          .DC.w 32,0,0,0,0,0,0,0
          .DC.w 0,32,32,32,32,32,32,0


ccc:      

          .DC.w 192,192,192,192,192,192,0,-2
          .DC.w 192,0,0,0,0,0,192,0
          .DC.w 192,0,0,0,0,0,192,0
          .DC.w 192,0,0,0,0,0,192,0
          .DC.w 192,0,0,0,0,0,192,0
          .DC.w 192,192,192,192,192,192,0,0
ddd:      

          .DC.w 64,64,64,64,64,64,64,-2
          .DC.w 64,0,0,0,0,0,0,0
          .DC.w 64,64,64,64,0,0,0,0
€          .DC.w 64,0,0,0,0,0,0,0
          .DC.w 64,0,0,0,0,0,0,0
          .DC.w 64,64,64,64,64,64,64,0
eee:      

          .DC.w 96,96,96,96,96,96,96,-2
          .DC.w 96,0,0,0,0,0,0,0
          .DC.w 96,96,96,96,0,0,0,0
          .DC.w 96,0,0,0,0,0,0,0
          .DC.w 96,0,0,0,0,0,0,0
          .DC.w 96,0,0,0,0,0,0,0
fff:      

          .DC.w 160,160,160,160,160,160,0,-2
          .DC.w 160,0,0,0,0,0,160,0
          .DC.w 160,0,0,0,0,0,0,0
          .DC.w 160,0,0,0,160,160,0,0
          .DC.w 160,0,0,0,0,0,160,0
          .DC.w 0,160,160,160,160,160,0,0

ggg:      
          .DC.w 128,0,0,0,0,0,128,-2
          .DC.w 128,0,0,0,0,0,128,0
          .DC.w 128,128,128,128,128,128,128,0
          .DC.w 128,0,0,0,0,0,128,0
          .DC.w 128,0,0,0,0,0,128,0
          .DC.w 128,0,0,0,0,0,128,0

hhh:      

          .DC.w 0,0,32,32,32,0,0,-2
          .DC.w 0,0,0,32,0,0,0,0
          .DC.w 0,0,0,32,0,0,0,0
          .DC.w 0,0,0,32,0,0,0,0
          .DC.w 0,0,0,32,0,0,0,0
          .DC.w 0,0,32,32,32,0,0,0
iii:      

          .DC.w 0,0,0,0,0,64,0,-2
          .DC.w 0,0,0,0,0,64,0,0
          .DC.w 0,0,0,0,0,64,0,0
          .DC.w 0,0,64,0,0,64,0,0
          .DC.w 0,0,64,0,0,64,0,0
          .DC.w 0,0,0,64,64,64,0,0
jjj:      

          .DC.w 96,0,0,0,0,0,96,-2
          .DC.w 96,0,0,0,0,96,0,0
          .DC.w 96,0,0,96,96,0,0,0
          .DC.w 96,96,96,0,0,0,0,0
          .DC.w 96,0,0,96,96,0,0,0
          .DC.w 96,0,0,0,0,96,0,0
kkk:      

€          .DC.w 128,0,0,0,0,0,0,-2
          .DC.w 128,0,0,0,0,0,0,0
          .DC.w 128,0,0,0,0,0,0,0
          .DC.w 128,0,0,0,0,0,0,0
          .DC.w 128,0,0,0,0,0,0,0
          .DC.w 128,128,128,128,128,128,128,0
lll:      

          .DC.w 160,0,0,0,0,0,160,-2
          .DC.w 160,160,0,0,0,160,160,0
          .DC.w 160,0,160,0,160,0,160,0
          .DC.w 160,0,0,160,0,0,160,0
          .DC.w 160,0,0,0,0,0,160,0
          .DC.w 160,0,0,0,0,0,160,0
mmm:      

          .DC.w 192,0,0,0,0,0,192,-2
          .DC.w 192,192,0,0,0,0,192,0
          .DC.w 192,0,192,0,0,0,192,0
          .DC.w 192,0,0,192,0,0,192,0
          .DC.w 192,0,0,0,192,0,192,0
          .DC.w 192,0,0,0,0,192,192,0
nnn:      

          .DC.w 0,32,32,32,32,32,0,-2
          .DC.w 32,0,0,0,0,0,32,0
          .DC.w 32,0,0,0,0,0,32,0
          .DC.w 32,0,0,0,0,0,32,0
          .DC.w 32,0,0,0,0,0,32,0
          .DC.w 0,32,32,32,32,32,0,0

ooo:      

          .DC.w 64,64,64,64,64,64,0,-2
          .DC.w 64,0,0,0,0,0,64,0
          .DC.w 64,0,0,0,0,0,64,0
          .DC.w 64,64,64,64,64,64,0,0
          .DC.w 64,0,0,0,0,0,0,0
          .DC.w 64,0,0,0,0,0,0,0

ppp:      
          .DC.w 0,32,32,32,32,32,0,-2
          .DC.w 32,0,0,0,0,0,32,0
          .DC.w 32,0,0,0,0,0,32,0
          .DC.w 32,0,0,0,32,0,32,0
          .DC.w 32,0,0,0,0,32,32,0
          .DC.w 0,32,32,32,32,32,32,0

qqq:      
          .DC.w 64,64,64,64,64,64,0,-2
          .DC.w 64,0,0,0,0,0,64,0
          .DC.w 64,64,64,64,64,64,0,0
          .DC.w 64,0,0,0,64,0,0,0
          .DC.w 64,0,0,0,0,64,0,0
€          .DC.w 64,0,0,0,0,0,64,0
rrr:      
          .DC.w 0,96,96,96,96,96,96,-2
          .DC.w 96,0,0,0,0,0,0,0
          .DC.w 96,0,0,0,0,0,0,0
          .DC.w 0,96,96,96,96,96,0,0
          .DC.w 0,0,0,0,0,0,96,0
          .DC.w 96,96,96,96,96,96,0,0

sss:      
          .DC.w 128,128,128,128,128,128,128,-2
          .DC.w 0,0,0,128,0,0,0,0
          .DC.w 0,0,0,128,0,0,0,0
          .DC.w 0,0,0,128,0,0,0,0
          .DC.w 0,0,0,128,0,0,0,0
          .DC.w 0,0,0,128,0,0,0,0
ttt:      

          .DC.w 160,0,0,0,0,0,160,-2
          .DC.w 160,0,0,0,0,0,160,0
          .DC.w 160,0,0,0,0,0,160,0
          .DC.w 160,0,0,0,0,0,160,0
          .DC.w 160,0,0,0,0,0,160,0
          .DC.w 0,160,160,160,160,160,0,0

uuu:      
          .DC.w 192,0,0,0,0,0,192,-2
          .DC.w 192,0,0,0,0,0,192,0
          .DC.w 0,192,0,0,0,192,0,0
          .DC.w 0,0,192,0,192,0,0,0
          .DC.w 0,0,192,0,192,0,0,0
          .DC.w 0,0,0,192,0,0,0,0

vvv:      
          .DC.w 160,0,0,0,0,0,160,-2
          .DC.w 160,0,0,0,0,0,160,0
          .DC.w 160,0,0,160,0,0,160,0
          .DC.w 160,0,160,0,160,0,160,0
          .DC.w 160,160,0,0,0,160,160,0
          .DC.w 160,0,0,0,0,0,160,0
www:      
          .DC.w 128,0,0,0,0,0,128,-2
          .DC.w 0,128,0,0,0,128,0,0
          .DC.w 0,0,128,0,128,0,0,0
          .DC.w 0,0,0,128,0,0,0,0
          .DC.w 0,128,128,0,128,128,0,0
          .DC.w 128,0,0,0,0,0,128,0
xxx:      
          .DC.w 96,0,0,0,0,0,96,-2
          .DC.w 0,96,96,0,96,96,0,0
          .DC.w 0,0,96,96,96,0,0,0
          .DC.w 0,0,0,96,0,0,0,0
          .DC.w 0,0,0,96,0,0,0,0
          .DC.w 0,0,0,96,0,0,0,0
€yyy:      
          .DC.w 64,64,64,64,64,64,64,-2
          .DC.w 0,0,0,0,0,64,64,0
          .DC.w 0,0,0,64,64,0,0,0
          .DC.w 0,0,64,64,0,0,0,0
          .DC.w 0,64,64,0,0,0,0,0
          .DC.w 64,64,64,64,64,64,64,0
zzz:      
          .DC.w 0,0,0,0,0,0,0,-2
          .DC.w 0,0,0,0,0,0,0,0
          .DC.w 0,0,0,0,0,0,0,0
          .DC.w 0,0,0,0,0,0,0,0
          .DC.w 0,0,0,0,0,0,0,0
          .DC.w 0,0,0,0,0,0,0,0

spac:     
gloom:    .DC.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          .DC.w $1000,$1111,$1222,$1333,$1444,$1555,$1666,$1777,$1776,$1775,0,0,
0,0,0,0
          .DC.w $2000,$2010,$2020,$2021,$2031,$2032,$2042,$2043,$2053,$2063,$206
4,$2074,0,0,0,0
          .DC.w $0001,$0002,$0003,$0004,$0005,$0006,$0007,$117,$227,$337,$447,$5
57,$667,$777,0,0
          .DC.w $100,$200,$300,$400,$500,$600,$700,$711,$722,$733,$744,$755,$766
,0,0,0
          .DC.w $110,$220,$330,$440,$550,$660,$770,$771,$772,$773,$774,$775,$776
,0,0,0
          .DC.w $0011,$0022,$0033,$0044,$0055,$0066,$0077,$177,$277,$377,$477,$5
77,$677,0,0,0



firstl:   .DC.l d3text
d3text:   .DC.b "IS1DIS1COOL1OR1WOT11€",-1

typetable:          
          .DC.b 6,"..............................PUNISH YOUR MACHINE.........",2
4,"THIS RATTLESNAKE ROUNDUP (UHUUHUUU HOW ORIGINAL) IS THE ENTRY FROM    ",12
          .DC.b "  DIGITAL VISION  ",24,"  OF THE ALLIANCE... CURRENTLY
 ON THE KEYBORD... THE HEADCODER OF D.V. BUT NOW MORE EXACTLY THE "
          .DC.b "HEAT CODER OF D.V. COZ A CUMMULATION OF HORRIFYING
 TECHNICAL RUBBISH HINDERED ME TO PROGRESS MOR STRAIGHTFORWARD. "
          .DC.b "MY SPRINKY OLD ST PERIODICALLY CRASHES DOWN EVERY THREE
 MINUTES WHICH ISN T VERY CONVENIENT DURING CODING UNDER PRESSURE (THIS
 SCREEN "
          .DC.b "MUST BE READY AT THE MEETING). GOT IT. MADE IT. OK, I
 KNOW AND YOU, THE VIEWER SURELY TOO THAT THE QUALITY OF THE RESULT IS
 FAR FAR AWAY FROM "
          .DC.b "GOLDEN CODE. TO MY DEFENSE I COULD TELL YOU THE HIDEHOUS
 TECHNICAL AND TIMING DESASTER, BUT MY MACABRE ENGLISH PREVENT ME FROM
 MORE DETAIL. "
          .DC.b 18,"HOWEVER, THE SCREEN MUST GO ON ",24,"AND THATS
 EXACTLY WHATS GOING ON.... ",0,"LET ME (THE SCROLLY ROLLY LETTERLINE)
 JUMP A LITTLE AROUND....",24
€          .DC.b "GOT IT. THE ATHMOSPHERE HERE AT THE GYMN, WHERE THE ICC
 II TAKES PLACE IS INFLUENCED FROM A HIGH GRADE OF RELAXNESS AROUND. "
          .DC.b "THE ARCHITECTUAL TOUCH IS VERY MUCH CATHEDRAL LIKE AND,
 CORRESPONDELY, THE ST S ARE HERE THE ALTAIRS. LETS KEEP ON PRAYING....
WRAP..........."
typend:   .DC.b "..............."
flago:    .DC.b 1
          .EVEN 
buflist:  .DC.l buffer1,buffer2,buffer3,buffer4,buffer5,buffer6,buffer7,buffer8
oldstack: .DC.l 0
          .EVEN 
;BEREICH AF DISK …AUSLAGERN€/IN BUFFER1 LADEN!!
          .DS.b 1024
stackl:   .DS.l 1

sound:    .IBYTES 'TUNE2.SND'
zuend:    .IBYTES 'ROUNDUP.DAT'
zuendpol: .IBYTES 'POLE.DAT'
zuendlog: .IBYTES 'LOGO.DAT'
zuender   equ zuend
          .BSS 
xyliste   equ 1016576-329216-256-768    ;ringspeicher spr.org.
pb1       equ xyliste-256
pb2       equ pb1-256
indiv     equ pb2-256
silotab   equ indiv-256
buffer1   equ silotab-46080   ;scr2-46080
buffer2   equ buffer1-46080
buffer3   equ buffer2-46080
buffer4   equ buffer3-46080
buffer5   equ buffer4-46080
buffer6   equ buffer5-46080
buffer7   equ buffer6-46080
buffer8   equ buffer7-46080
scr1      equ buffer8-32000-32*160      ; 1016576-329216-32000 ;-329216
fuer 320 k ramdisk!!
€scr2      equ scr1-32