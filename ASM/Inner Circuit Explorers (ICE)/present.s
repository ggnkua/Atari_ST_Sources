**********************************************************************
* Presentation design-program... v0.1
* By Tobias Nilsson, -94
**********************************************************************
* Elof shit presentation... tid nu: 2.45...

                pea       0
                move.w    #$20,-(sp)
                trap      #1
                addq.l    #6,sp

                move.b    #2,$0484.w
                bsr       makegoc

                move.l    $70.w,oldvbl
                move.l    #vbl,$70.w
                move      #$2300,sr

                bra       goon

* intro...
                movem.l   intpic,d0-d7
                movem.l   d0-d7,$ffff8240.w


                move.w    #7,-(sp)
                trap      #1
                addq.l    #2,sp

                bra       goon


* end intro...
**********************************************************************
goon:
                move.b    #1,$ffff8260.w

                move.w    #$0777,$ffff8240.w
                move.w    #$0777,$ffff8242.w
                move.w    #$00,$ffff8242+2.w
                move.w    #$00,$ffff8242+4.w


;                movea.l   screen1,a0
;                bsr       clrscrn

vblwait:
                sf        vblcnt
wv:             tst.b     vblcnt
                beq.s     wv


                lea       txt1,a0
                bsr       ffprint
                move.w    #30,d7
                bsr       pause
                bsr       fadeclrtxt

                lea       txt2,a0
                bsr       ffprint
                move.w    #100,d7
                bsr       pause
                bsr       fadeclrtxt

                move.w    #$00,d0
                move.w    #$0777,d1
                moveq     #16-1,d7
xfadelp:
                bsr       fade_RGB
                sf        vblcnt
xvblp2:         cmpi.b    #3,vblcnt
                bne.s     xvblp2
                move.w    d1,$ffff8240.w
                dbra      d7,xfadelp
* showpic
                move.b    #0,$ffff8260.w          ; lowrez
                lea       $ffff8240.w,a0
                clr.l     d0
              rept 8
                move.l    d0,(a0)+
              endr

;                move.l    #intpic+34,screen1

                movem.l   intpic,d0-d7
                movem.l   d0-d7,$ffff8240.w

                lea       intpic+34,a0
                movea.l   screen1,a1

                move.w    #100-1,d6
ylp1:           sf        vblcnt
novbl1:         tst.b     vblcnt
                beq.s     novbl1
                moveq     #20-1,d7
xlp1:           move.l    (a0)+,(a1)+
                move.l    (a0)+,(a1)+
                dbra      d7,xlp1
                lea       160(a0),a0
                lea       160(a1),a1
                dbra      d6,ylp1

                lea       -160*1(a0),a0
                lea       -160*1(a1),a1
                move.w    #100-1,d6
ylp11:          sf        vblcnt
novbl11:        tst.b     vblcnt
                beq.s     novbl11
                moveq     #20-1,d7
xlp11:          move.l    (a0)+,(a1)+
                move.l    (a0)+,(a1)+
                dbra      d7,xlp11
                lea       -160*3(a0),a0
                lea       -160*3(a1),a1
                dbra      d6,ylp11

                move.w    #170,d7
                bsr       pause

                lea       intpic+34,a0
                movea.l   screen1,a1

                move.w    #100-1,d6
ylp111:         sf        vblcnt
novbl111:       tst.b     vblcnt
                beq.s     novbl111
                moveq     #20-1,d7
xlp111:         move.l    #0,(a1)+
                move.l    #0,(a1)+
                dbra      d7,xlp111
                lea       160(a0),a0
                lea       160(a1),a1
                dbra      d6,ylp111

                lea       -160*1(a0),a0
                lea       -160*1(a1),a1
                move.w    #100-1,d6
ylp1111:        sf        vblcnt
novbl1111:      tst.b     vblcnt
                beq.s     novbl1111
                moveq     #20-1,d7
xlp1111:        move.l    #0,(a1)+
                move.l    #0,(a1)+
                dbra      d7,xlp1111
                lea       -160*3(a0),a0
                lea       -160*3(a1),a1
                dbra      d6,ylp1111


                move.w    #$0777,d0
                move.w    #$00,d1
                moveq     #16-1,d7
xxfadelp:
                bsr       fade_RGB
                sf        vblcnt
xxvblp2:        cmpi.b    #3,vblcnt
                bne.s     xxvblp2
                move.w    d1,$ffff8240.w
                dbra      d7,xxfadelp


                move.w    #$0777,$ffff8242.w
                move.w    #$00,$ffff8242+2.w
                move.w    #$00,$ffff8242+4.w

                move.b    #1,$ffff8260.w          ; midrez
* done...

                lea       txt3,a0                 ; <
                bsr       ffprint
                move.w    #180,d7
                bsr       pause
                bsr       fadeclrtxt
                lea       txt4,a0                 ; <
                bsr       ffprint
                move.w    #180,d7
                bsr       pause
                bsr       fadeclrtxt
                lea       txt5,a0                 ; <
                bsr       ffprint
                move.w    #180,d7
                bsr       pause
                bsr       fadeclrtxt
                lea       txt6,a0                 ; <
                bsr       ffprint
                move.w    #180,d7
                bsr       pause
                bsr       fadeclrtxt

                lea       txt7,a0                 ; <
                bsr       ffprint
                move.w    #180,d7
                bsr       pause
                bsr       fadeclrtxt
                lea       txt8,a0                 ; <
                bsr       ffprint
                move.w    #180,d7
                bsr       pause
                bsr       fadeclrtxt
                lea       txt9,a0                 ; <
                bsr       ffprint
                move.w    #180,d7
                bsr       pause
                bsr       fadeclrtxt

                lea       txtend,a0               ; <
                bsr       ffprint
                move.w    #150,d7
                bsr       pause
                bsr       fadeclrtxt


                move.w    #7,-(sp)
                trap      #1
                addq.l    #2,sp

                bra       back

**********************************************************************
* d0= decnt
pause:
                sf        vblcnt
vblp:           tst.b     vblcnt
                beq.s     vblp
                dbra      d7,pause
                rts

fadeclrtxt:     move.w    #$0777,d0
                move.w    #$00,d1
                moveq     #16-1,d7
fadelp:
                bsr       fade_RGB
                sf        vblcnt
vblp2:          cmpi.b    #4,vblcnt
                bne.s     vblp2

                move.w    d1,$ffff8244.w
                dbra      d7,fadelp

                movea.l   screen1,a0
                addq.l    #2,a0
                bsr       clrscrn

                move.w    #0,$ffff8244.w
                rts


**********************************************************************
back:
                move.l    oldvbl(pc),$70
                move.w    #1,-(sp)                ; midrez
                pea       -1
                pea       -1
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp
                clr.w     -(sp)
                trap      #1

oldvbl:       dc.l 0




**********************************************************************
vbl:
                move.b    screen1+1,$ffff8205
                move.b    screen1+2,$ffff8207
                move.b    screen1+3,$ffff8209

                addq.b    #1,vblcnt

                rte

vblcnt:       dc.b 0
              even
**********************************************************************
* a0 = screen
* v1.0
clrscrn:
                lea       $ffff8a00.w,a1
                move.l    #-1,$28(a1)             ; msk1-2
                move.w    #-1,$2c(a1)             ; msk3
                move.b    #0,$3d(a1)              ; use halftone

                move.l    #$040000,$2e(a1)        ; des x,y inc
                lea       $2e+4(a1),a1

                move.l    a0,(a1)+                ; des addr
                move.w    #40*200,(a1)+           ; x cnt
                move.w    #1,(a1)+                ; y cnt
                move.l    #%1000000001100000000000000,(a1)+ ; op & busy
                rts

**********************************************************************
* RGB Faderoute v0.1
* d0= color  d1= src/des  (d2= times)

fade_RGB:
                move.w    d0,d3
                bsr       order
                move.w    d3,d0
                move.w    d1,d3
                bsr       order
                move.w    d3,d1

                bsr       fade_B
                bsr       fade_G
                bsr       fade_R

                move.w    d0,d3
                bsr       disorder
                move.w    d3,d0
                move.w    d1,d3
                bsr       disorder
                move.w    d3,d1
                rts

* find inc/dec
fade_B:
                move.w    d0,d3
                move.w    d1,d4
                and.w     #$0f,d3
                and.w     #$0f,d4
                sub.w     d4,d3                   ; neg?
                bmi.s     neg_B
                beq.s     done_B
                addq.w    #$01,d1
                bra.s     done_B
neg_B:          subq.w    #$01,d1
done_B:         rts
fade_G:         move.w    d0,d3
                move.w    d1,d4
                and.w     #$f0,d3
                and.w     #$f0,d4
                sub.w     d4,d3                   ; neg?
                bmi.s     neg_G
                beq.s     done_G
                add.w     #$10,d1
                bra.s     done_G
neg_G:          sub.w     #$10,d1
done_G:         rts
fade_R:         move.w    d0,d3
                move.w    d1,d4
                and.w     #$0f00,d3
                and.w     #$0f00,d4
                sub.w     d4,d3                   ; neg?
                bmi.s     neg_R
                beq.s     done_R
                add.w     #$0100,d1
                bra.s     done_R
neg_R:          sub.w     #$0100,d1
done_R:         rts

order:          add.w     d3,d3                   ; whole *2
                btst      #4,d3
                beq.s     bsf1
                addq.w    #1,d3
                bclr      #4,d3
bsf1:           btst      #4+4,d3                 ; optim. more...
                beq.s     bsf2
                add.w     #$10,d3                 ; bset??
                bclr      #4+4,d3
bsf2:           btst      #4+4+4,d3
                beq.s     bsf3
                add.w     #$0100,d3
                bclr      #4+4+4,d3
bsf3:           rts                               ; order.in bright. from 0-f

disorder:       ror.w     #1,d3
                btst      #4+3,d3
                beq.s     dbsf1
                add.w     #$0800,d3
                bclr      #4+3,d3
dbsf1:          btst      #3,d3                   ; optim. more...
                beq.s     dbsf2
                add.w     #$80,d3
                bclr      #3,d3
dbsf2:          btst      #15,d3
                beq.s     dbsf3
                addq.w    #$08,d3
                bclr      #15,d3
dbsf3:          rts


**********************************************************************
* Bpl- fade convert route...

bpldo:
                lea       bplfade,a0
                sf        vblcnt
wvbl:           tst.b     vblcnt
                beq.s     wvbl

                move.w    (a0)+,$ffff8242.w
                sf        vblcnt
                cmpi.w    #-1,(a0)
                bne.s     wvbl

* convert
                lea       screen,a0
                move.w    xyout,d0
                lsr.w     #2,d0
                and.w     #$ffff-3,d0
                adda.w    d0,a0
                move.w    xyout+2,d0
                mulu      #160,d0
                adda.w    d0,a0

                clr.w     d1
                move.w    ylen,d7
bplconv:
              rept 4
                move.w    (a0),d0
                or.w      d0,2(a0)
                move.w    d1,(a0)
                addq.l    #4,a0
              endr
                move.w    (a0),d0
                or.w      d0,2(a0)
                move.w    d1,(a0)

                lea       160-(4*4)(a0),a0
                dbra      d7,bplconv

                move.w    #$0777,$ffff8242.w
                rts

bplfade:                                          ; dc.w $0777,$0666,$0555,$0444,$0333,$0222,$0111,$00,-1
;              dc.w $0777,$0677,$0577,$0477,$0377,$0277,$0177,$77,-1
              dc.w $0777,$0555,$0333,$0111,-1

**********************************************************************
* Bitmapped Flexible-Font Printroute v0.5
* Nonoptimiz...

ffprint:
string_lp:      move.b    (a0)+,d0
                cmp.b     #-1,d0
                beq       ffdone

                cmp.b     #2,d0
                bgt.s     printnow                ; ASCII-value
                bne.s     chkother
                move.b    (a0)+,intxyflgs
                move.b    (a0)+,intxyflgs+1
                move.w    ylen,ylen+2
                tst.b     intxyflgs+1
                beq.s     string_lp
                lsr.w     ylen+2
                bra.s     string_lp

chkother:       tst.b     d0
                bne.s     chkret
                clr.w     d0
                move.b    (a0)+,d0                ; x
                lsl.w     #4,d0                   ; 16
                move.w    d0,xyout
                clr.w     d0
                move.b    (a0)+,d0                ; y
                mulu      ylen+2,d0
                move.w    d0,xyout+2
                bra.s     string_lp
chkret:         cmp.b     #1,d0
                bne.s     printnow
                clr.w     xyout
                move.w    ylen+2,d0
                addq.w    #2,d0
                add.w     d0,xyout+2
                bra.s     string_lp
printnow:
                cmp.b     #32,d0
                bne.s     gonot
                moveq     #18,d6                  ; spacewidth
                tst.b     intxyflgs
                beq.s     gospace
                lsr.w     #1,d6
                bra.s     gospace

gonot:          move.l    a0,-(sp)
                bsr       ff_output               ; returns len. in d6
                movea.l   (sp)+,a0

                movem.l   d6/a0,-(sp)
                bsr       bpldo
                movem.l   (sp)+,d6/a0

gospace:
                addq.w    #3,d6
                add.w     d6,xyout                ; inc xpos
                bra       string_lp
ffdone:         rts

**********************************************************************
spchars:        lea       spdat,a0                ; for swedish crap...
                moveq     #6-1,d7
splp:           cmp.b     (a0)+,d0
                beq.s     charfnd
                addq.w    #1,a0
                dbra      d7,splp
                rts
charfnd:        move.b    (a0),d0
                rts
spdat:        dc.b "","[","Ž","\","™","]","†","{","„","|","”","}"
              even

nooutput:       moveq     #18,d6                  ; spacewidth
                tst.b     intxyflgs
                beq.s     noint
                lsr.w     #1,d6
noint:          rts
ff_output:      and.w     #$ff,d0                 ; ASCII in d0
                bsr.s     spchars

                sub.b     #32+1,d0                ; space+1
                bmi.s     nooutput
                add.w     d0,d0
                add.w     d0,d0

                lea       fontpic+34,a0
                lea       goctab(pc),a1
                adda.w    d0,a1
                clr.l     d0
                move.w    (a1)+,d0
                adda.l    d0,a0                   ; don't sign-do
                move.w    (a1)+,d0                ; 4+10 bits

                move.w    d0,d1
                and.w     #$03ff,d1
                add.w     xyout(pc),d1
                cmp.w     #639,d1
                ble.s     noreturn
                clr.w     xyout
                move.w    ylen+2(pc),d1
                addq.w    #2,d1
                add.w     d1,xyout+2
noreturn:
                move.w    d0,d1
                rol.w     #4,d0
                and.w     #$0f,d0                 ;  4bits
                and.w     #$03ff,d1               ; 10bits

                movea.l   screen1,a1              ; dest
                move.w    xyout,d3
                move.w    d3,d4
                lsr.w     #2,d3
                and.w     #$fffc,d3
                adda.w    d3,a1
                move.w    xyout+2,d3
                move.w    #199+1,d5
                sub.w     ylen+2,d5

                cmp.w     d5,d3
                bge       nooutput
                mulu      #160,d3
                adda.w    d3,a1

                not.w     d4                      ; <
                and.w     #$0f,d4
                move.w    d4,oldd4
                movea.l   a0,a2
                movea.l   a1,a3

**********************************************************************

                move.w    #160,ysrcadd
                move.w    ylen+2,d7
                tst.b     intxyflgs+1
                beq.s     noninty
                lsl.w     ysrcadd
noninty:        tst.b     intxyflgs
                bne.s     intx

* start output
                move.w    d1,d6
ylp:            move.w    (a0),d2
                rol.w     d0,d2
                move.w    d0,d5
                clr.w     d3
xlp:            roxl.w    #1,d2
                roxl.w    #1,d3                   ; dest
                subq.w    #1,d4
                bmi.s     savedest
sdback:
                cmp.w     #$0f,d5
                blo.s     noword
                moveq     #-1,d5
                addq.l    #8,a0
                move.w    (a0),d2
noword:         addq.w    #1,d5                   ; xrot
                subq.w    #1,d6                   ; xlen-1
                bpl.s     xlp
                addq.w    #1,d4                   ; <
                lsl.w     d4,d3
                or.w      d3,(a1)                 ; lastword
nolast:
                move.w    d1,d6
                adda.w    ysrcadd,a2
                lea       160(a3),a3
                movea.l   a2,a0
                movea.l   a3,a1
                move.w    oldd4,d4                ; <
                dbra      d7,ylp
                rts

savedest:       or.w      d3,(a1)
                addq.l    #4,a1                   ; midrez
                moveq     #16-1,d4
                bra.s     sdback

**********************************************************************
intx:
                lsr.w     #1,d1
                and.w     #$fe,d0
* start output
                move.w    d1,d6
ylp2:           move.w    (a0),d2
                rol.w     d0,d2
                move.w    d0,d5
                clr.w     d3
xlp2:
;                rol.w     #1,d2
                roxl.w    #2,d2
                roxl.w    #1,d3                   ; dest
                subq.w    #1,d4
                bmi.s     savedest2
sdback2:
                cmp.w     #$0f-1,d5
                blo.s     noword2
                moveq     #-1,d5
                addq.l    #8,a0
                move.w    (a0),d2

noword2:        addq.w    #1+1,d5                 ; xrot
                subq.w    #1,d6                   ; xlen-1
                bpl.s     xlp2
                addq.w    #1,d4                   ; <
                lsl.w     d4,d3
                or.w      d3,(a1)                 ; lastword
nolast2:
                move.w    d1,d6
                adda.w    ysrcadd,a2              ; 160(*2)
                lea       160(a3),a3
                movea.l   a2,a0
                movea.l   a3,a1
                move.w    oldd4,d4                ; <
                dbra      d7,ylp2
                rts

savedest2:      or.w      d3,(a1)
                addq.l    #4,a1                   ; midrez
                moveq     #16-1,d4
                bra.s     sdback2


intxyflgs:    dc.b 0,0
ysrcadd:      dc.w 0
;inter         equ 2
oldd4:        dc.w 0
ylen:         dc.w 36-1,36-1
xyout:        dc.w 0,0

* command-order.b: 0,x,y, : 1= next line : no center <<
* 2,intx,inty
* -1 stringend


txt1:         dc.b 0,0,2,2,0,0
              dc.b "   En presentation av..."
              dc.b -1

txt2:         dc.b 0,0,1,2,0,0
              dc.b "     ELOF LINDŽLVS ",1
              dc.b "       GYMNASIUM  ",1
              dc.b 2,0,1,1
              dc.b "       I Kungsbacka  "
              dc.b -1

* show pic...

txt3:         dc.b 0,0,0,2,1,0
              dc.b "     -  ELOF  LINDŽLVS  GYMNASIUM  -"
              dc.b 2,1,1
              dc.b 1,1,1,"Lind„lvsskolan stod klar 1981.  I  byggnaden ",1
              dc.b "†terfinns undervisningslokaler f”r de "
              dc.b "ca 950 eleverna,  s†v„l  som  Kungsbacka "
              dc.b "Teater,    Lind„lvsrestaurangen och "
              dc.b "cafeteria... "
              dc.b 1
              dc.b "Rektor:                     Lennart Jonsson ",1
              dc.b "Telefon expedition:        0300-344 20 ",1
              dc.b "Postadress:  Varlag†rd 1, 434 32 Kungsbacka ",1
              dc.b -1


txt4:         dc.b 0,0,0,2,0,1,1,1,1
;              dc.b " F”ljande  program  och ",1," grenar  "
;              dc.b "finns  p†  Elof ",1," Lind„lvs "
;              dc.b "Gymnasium:"
              dc.b "F”ljande program/grenar ",1
              dc.b "finns p† Elof Lind„lvs: ",1
              dc.b -1

txt5:         dc.b 0,0,0,2,0,1,"ELprogrammet:",1
              dc.b 1,"  Automation,  ECAU"
              dc.b 1,"  Elektronik,   ECEK"
              dc.b 1,"  Datakomm.,  lokal gren"
              dc.b 1,1,2,1,1
              dc.b "Elprogrammet „r ett yrkesf”rberedande prog-",1
              dc.b "ram  inom  det  eltekniska  omr†det,  bl.a. "
              dc.b "undervisar man inom  omr†dena  elektronik, "
              dc.b "styrteknik och mikrodatorn..."
              dc.b -1

txt6:
              dc.b 0,0,0,2,0,1,"FORDONSprget:",1
              dc.b 1,1,"  Fordonsteknik,  FPRP"
              dc.b 1,1,2,1,1
              dc.b "Fordonsprogrammet  ger en grundutbildning  "
              dc.b "f”r arbete med  reparationer,  service  och  "
              dc.b "underh†ll av fordon.   F”rst†else  f”r  mek-"
              dc.b "aniska,   pneumatiska,   hydrauliska  och   "
              dc.b "elektroniska  system  l„rs ut. "
              dc.b -1

txt7:
              dc.b 0,0,0,2,0,1,"HOTELL och REST.prget:",1
              dc.b 1,"  Hotell,        HRHO"
              dc.b 1,"  Restaurang, HRRE"
              dc.b 1,"  Storhush†ll, HRSH "
              dc.b 1,1,2,1,1
              dc.b "Hotell och restaurangprogrammet ger grund-",1
              dc.b "utbildning f”r arbete i k”k eller p† hotell.",1
              dc.b "Bl.a.  reception,  konferens,  kallsk„nk  och "
              dc.b "servering..."
              dc.b -1

txt8:
              dc.b 0,0,0,2,0,1,"INDUSTRIprogrammet:",1,1
              dc.b 1,"  Industri,    IPIN "
              dc.b 1,1,2,1,1
              dc.b "Industriprogrammet  ger en  grundutbildning",1
              dc.b "f”r en  m„ngd  olika yrken inom  industrin. ",1
              dc.b "Inriktningar  i  grenen  „r  sk„rande  bear-  betning, "
              dc.b "  pl†t och svets,   underh†ll  och ",1,"verktygsteknik. "
              dc.b -1


txt9:
              dc.b 0,0,0,2,0,1,"NATUR och SAMHŽLLS-VETENSKAPSprgen:",1
              dc.b 1,"Naturvet. gren,     NVNA"
              dc.b 1,"Ekonomisk gren,   SPEK"
              dc.b 1,"Samh„llsvet. gren, SPSA"
              dc.b 1,1,2,1,1
              dc.b "Naturvetenskapsprogrammet och  Samh„lls-  "
              dc.b "vetenskapsprogrammet  „r  b†da  studie-",1
              dc.b "f”rberedande utbildningar..."
              dc.b -1


txtend:       dc.b 0,0,1,2,1,1,1
              dc.b "Med  f”rhoppning  om  v„ckt  "
              dc.b "intresse  f”r ",1,"ELOF LINDŽLVS "
              dc.b "GYMNASIUM, tackar vi f”r ",1
              dc.b "din tid och v„lkomnar dig "
              dc.b "att bes”ka oss !"
              dc.b 1,1,1,1,"Copyright ElTele ravers -94"
              dc.b -1

;              dc.b "STATE OF THE BINARY",-1
              dc.b -1
              even

**********************************************************************
* Gfx-Offset Calc, GOC-system v0.2 (2pics)
* By TSN
makegoc:        movea.l   imgdata(pc),a0          ; what to detect
                lea       goctab(pc),a1
                move.w    #$8000,d1
                clr.w     d2
                clr.w     d3

                move.w    #20*200*2-1,d7          ; 2pics
ror_lp:         move.w    (a0),d0
                and.w     d1,d0
                bne.s     detected
dback:          addq.w    #1,d3                   ; coord
                ror.w     #1,d1
                bcc.s     ror_lp
                addq.l    #8,a0
                addq.w    #8,d2                   ; offs, max 65535
                cmp.w     #319,d3
                ble.s     noclr
                clr.w     d3
noclr:          cmp.w     #20*200,d7
                bne.s     nopicadd
                lea       34(a0),a0
                add.w     #34,d2
nopicadd:
                dbra      d7,ror_lp
                rts

detected:       not.b     offs_flg
                beq.s     savelen
                move.w    d2,(a1)+
                move.w    d3,d4
                bra.s     dback
savelen:        move.w    d3,d5
                sub.w     d4,d5
                and.w     #$0f,d4                 ; rotbits
                ror.w     #4,d4
                or.w      d4,d5
                move.w    d5,(a1)+
                bra.s     dback

offs_flg:     dc.b 0
              even
goctab:       ds.w 2*100                      ; offs, xlen
imgdata:      dc.l fontpic+34+4


**********************************************************************
screen1:      dc.l screen
screen:       ds.b 32000

fontpic:      ibytes 'FF1.PI1'                ; flexible-font
              ibytes 'FF2.PI1'
intpic:       ibytes 'LIND*.PI1'
              end
