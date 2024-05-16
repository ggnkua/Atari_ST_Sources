**********************************************************************
* CheckMem by Tobbe Nilsson... 1st version done ages ago on K-Seka!
* Xclusive redesigned for STE-SoftDisk...
* v0.9
**********************************************************************

                pea       $00
                move.w    #$20,-(sp)
                trap      #1
                addq.l    #6,sp

                move.b    $ffff8260.w,olddata+33

                move.w    #0,-(sp)                ; low
                move.l    #-1,-(sp)
                move.l    #-1,-(sp)
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp

                move.w    #2,-(sp)                ; get scrn (not log.)
                trap      #14
                addq.l    #2,sp
                move.l    d0,scrn


                movem.l   $ffff8240.w,d0-d7
                movem.l   d0-d7,olddata
                move.b    $0484.w,olddata+32

                move.b    #2,$0484.w
                move.w    #$04,$ffff8240.w
                move.w    #$0777,$ffff825e.w

                lea       txt(pc),a0
                bsr       txtout

* init
                move.l    $70.w,oldvbl
                move.l    #vbl,$70.w

key:
                tst.b     err_flg
                beq.s     noerr
                sf        err_flg
                lea       txt(pc),a0
                bsr       txtout
noerr:
                move.w    #7,-(sp)
                trap      #1
                addq.l    #2,sp

                move.w    #$04,$ffff8240.w

                swap      d0
                move.b    d0,scankey
                move.b    #-1,keytimer
;                move.l    #0,$04ba.w              ; timer C - 200Hz

                cmp.b     #16,d0                  ; Q
                beq       back
                cmp.b     #$1f,d0                 ; S
                beq.s     sav2
                cmp.b     #$20,d0
                beq       dmaplay
                bra.s     key

sav2:
                tst.b     escflg
                bne       setted

                move.l    scrn(pc),d0
                move.l    scrn+4(pc),d1
                move.l    d1,scrn
                move.l    d0,scrn+4

                st        discflg
                move.l    scrn+4(pc),d6
                move.l    #32000,d7
                bsr       create
                sf        discflg

                move.l    scrn(pc),d0
                move.l    scrn+4(pc),d1
                move.l    d1,scrn
                move.l    d0,scrn+4
                bra       key
setted:
                st        discflg
                move.l    scrn+4(pc),d6
                move.l    #32000,d7
                bsr       create
                sf        discflg
                bra       key

keytimer:     dc.b 0
              even
**********************************************************************
**********************************************************************
vbl:            movem.l   d0-a6,-(sp)

                move.l    scrn(pc),d0
                move.b    d0,$ffff8209.w
                lsr.w     #8,d0
                move.b    d0,$ffff8207.w
                swap      d0
                move.b    d0,$ffff8205.w


                tst.b     discflg
                bne       out

                tst.b     repflg
                beq.s     norep
                cmpi.b    #1,keytimer
                blt.s     tstkeys
                clr.b     scankey
                bra.s     tstkeys

;                cmpi.l    #$09,$04ba              ; ???????

norep:
                tst.b     keytimer
                bmi.s     tstkeys
                clr.b     scankey

* for 50Hz...
tstkeys:
                move.b    scankey(pc),d6

                addq.b    #1,keytimer
                tst.b     escflg                  ; branch menu supervisor...
                bne       k13

                cmpi.b    #$48,d6                 ; UP
                bne.s     k2
                move.l    ymove(pc),d0
                sub.l     d0,scrn
                bra       out

k2:             cmpi.b    #$50,d6                 ; DOWN
                bne.s     k3
                move.l    ymove(pc),d0
                add.l     d0,scrn
                bra       out

k3:             cmpi.b    #$4b,d6                 ; LEFT
                bne.s     k4
                move.l    xmove(pc),d0
                sub.l     d0,scrn
                bra       out

k4:             cmpi.b    #$4d,d6                 ; RIGHT
                bne.s     tstrep
                move.l    xmove(pc),d0
                add.l     d0,scrn
                bra       out

tstrep:
                tst.b     repflg
                beq.s     k5
                tst.b     keytimer
                beq       out


k5:             cmp.b     #$6d,d6
                beq.s     y1
                cmp.b     #$02,d6
                bne.s     k6
y1:             move.l    #160,ymove
                bra       out
k6:             cmp.b     #$6e,d6
                beq.s     y2
                cmp.b     #$03,d6
                bne.s     k7
y2:             move.l    #640,ymove
                bra       out
k7:             cmp.b     #$6f,d6
                beq.s     y3
                cmp.b     #$04,d6
                bne.s     k8
y3:             move.l    #1440*2,ymove
                bra       out

**********************************************************************
k8:             cmpi.b    #$30,d6                 ; B
                bne.s     k9
                cmpi.w    #8,xmove+2
                beq.s     decx
                addq.w    #6,xmove+2
                bra.s     out
decx:           subq.w    #6,xmove+2
                bra.s     out

k9:

k10:            cmpi.b    #$19,d6                 ; P
                bne.s     k11
                movea.l   scrn(pc),a0
                lea       $ffff8240.w,a1
              rept 8
                move.l    (a0)+,(a1)+
              endr
                bra.s     out

k11:            cmpi.b    #$3b,d6                 ; F1
                bne.s     k12
                not.b     repflg
                clr.b     scankey
                bra.s     out

k12:            cmpi.b    #$3c,d6                 ; F2
                bne.s     k13
                addq.w    #$01,$ffff8240.w
                bra.s     out

k13:
                cmpi.b    #$01,d6                 ; ESC
                bne.s     out
                not.b     escflg
                move.l    scrn(pc),d0
                move.l    scrn+4(pc),d1
                move.l    d1,scrn
                move.l    d0,scrn+4
                sf        repflg
                sf        scankey

**********************************************************************
out:

;                tst.b     repflg
;                beq.s     vblend
;                clr.b     scankey
;                move.b    #-3,keytimer

vblend:
                movem.l   (sp)+,d0-a6
                rte
**********************************************************************
**********************************************************************

back:
                move.l    oldvbl(pc),$70.w
                movem.l   olddata(pc),d0-d7
                movem.l   d0-d7,$ffff8240.w
                move.b    olddata+32(pc),$0484

                move.b    olddata+33(pc),d0
                and.w     #$0f,d0
                move.w    d0,-(sp)
                move.l    #-1,-(sp)
                move.l    #-1,-(sp)
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp

                clr.w     -(sp)
                trap      #1

oldvbl:       dc.l 0
olddata:      ds.w 16
              ds.b 1+1
              even
**********************************************************************
scrn:         dc.l $0f8000,0

ymove:        dc.l 160
xmove:        dc.l 8

scankey:      dc.b 0
escflg:       dc.b -1
repflg:       dc.b 0
discflg:      dc.b 0
err_flg:      dc.b 0
              even

**********************************************************************
* subroutes...

txtout:         move.l    a0,-(sp)
                move.w    #9,-(sp)
                trap      #1
                addq.l    #6,sp
                rts


* start, length => d6-d7
create:         bsr.s     input
                move.w    #$00,-(sp)
                pea       filename(pc)
                move.w    #$3c,-(sp)
                trap      #1
                addq.l    #8,sp
                move.w    d0,handle               ; save
                tst.l     d0
                bmi.s     error

write:          move.l    d6,d0                   ; start
                move.l    d0,-(sp)
                move.l    d7,-(sp)
                move.w    handle(pc),-(sp)
                move.w    #$40,-(sp)
                trap      #1
                lea       12(sp),sp
                tst.l     d0
                bmi.s     error

close:          move.w    handle(pc),-(sp)
                move.w    #$3e,-(sp)
                trap      #1
                addq.l    #4,sp
                tst.l     d0
                bmi.s     error
                rts

error:          move.w    #$0f00,$ffff8240.w
                st        err_flg
                rts

input:          lea       inputtxt(pc),a0
                bsr.s     txtout
                pea       inbuffer(pc)
                move.w    #$0a,-(sp)
                trap      #1
                addq.l    #6,sp
                rts

inbuffer:     dc.b 8+4
              dc.b 0
filename:     ds.b 8+4
              dc.b 0

              even
handle:       dc.w 0

;imgsav:       ds.b 128
;NEOPAL:       ds.b 124
;              dc.b $4e,$45,$4f,$21


txt:
              dc.b 27,69,27,112
              dc.b 27,89,32,42
              dc.b " - CheckMem v0.9á - "
              dc.b 27,89,34,32,27,113
              dc.b "         Old Code by T. Nilsson "
              dc.b 27,89,37,32
              dc.b "<ESC>    Toggle dest/menu"
              dc.b 27,89,39,32
              rept 40
              dc.b "~"
              endr
              dc.b 27,89,40,32
              dc.b "<Arrows> To scroll in "
              dc.b "memory"
              dc.b 27,89,41,32
              dc.b "<F1>     Toggle step/smooth"
              dc.b " scroll"
              dc.b 27,89,42,32
              dc.b "<1-3>    Speed, hardwarescroll"
              dc.b 27,89,43,32
              dc.b "<B>      Scroll 2/8 bytes in x-"
              dc.b "axis"
              dc.b 27,89,45,32
              dc.b "<P>      Take palette"
              dc.b 27,89,46,32
              dc.b "<D>      DMAplay, 32k"
              dc.b 27,89,48,32
              rept 40
              dc.b "~"
              endr
              dc.b 27,89,49,32
              dc.b "<S>      Save dest, 32000 bytes"
              dc.b 27,89,50,32
              dc.b "<Q>      Quit now»"


              dc.b 0

inputtxt:
              dc.b 27,89,56,32
              dc.b "Please enter filename: ",0
              even


dmaplay:
                move.b    #0,$ffff8901.w
                move.w    #%0,$ffff8920.w         ;kHz, mono

                move.b    scrn+1(pc),$ffff8903.w
                move.b    scrn+2(pc),$ffff8905.w
                move.b    scrn+3(pc),$ffff8907.w
                addi.l    #32000,scrn
                move.b    scrn+1(pc),$ffff890f.w
                move.b    scrn+2(pc),$ffff8911.w
                move.b    scrn+3(pc),$ffff8913.w
                subi.l    #32000,scrn
                addq.b    #1,$ffff8901.w
                bra       key


find_mod:
                lea       $00.w,a0
go:             cmpi.l    #"M.K.",(a0)
                beq.s     foundmod
                addq.w    #1,a0
                not.w     $ffff8240.w
                cmpa.l    endmem(pc),a0
                bne.s     go
                rts

foundmod:       move.w    #$f0,$ffff8240.w
                rts
**********************************************************************
endmem:       dc.l $0f8000
              end
