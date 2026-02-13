; We included this music only to show
; you how to play Quartet-sounds !
; (If you don't know it anyway !)

          movea.l   4(sp),a0
          lea       neu(pc),sp
          move.l    $0c(a0),d0
          add.l     $14(a0),d0
          add.l     $1c(a0),d0
          addi.l    #$0100,d0
          move.l    d0,-(sp)
          move.l    a0,-(sp)
          pea       $4a0000
          trap      #1
          lea       $0c(sp),sp

          DC.W $a00a

          lea       text1(pc),a0
          bsr       print

          pea       name2(pc)
          pea       name2(pc)
          pea       name2(pc)
          pea       $4b0003
          trap      #1
          lea       16(sp),sp
          addi.l    #$0100,d0
          move.l    d0,programm

          clr.w     -(sp)
          pea       name1(pc)
          move.w    #$3d,-(sp)
          trap      #1
          addq.l    #8,sp
          move.w    d0,-(sp)

          pea       melodie(pc)
          move.l    #1000000,-(sp)
          move.w    d0,-(sp)
          move.w    #$3f,-(sp)
          trap      #1
          lea       $0c(sp),sp

          move.w    #$3e,-(sp)
          trap      #1
          addq.l    #4,sp

          clr.w     -(sp)
          pea       name12(pc)
          move.w    #$3d,-(sp)
          trap      #1
          addq.l    #8,sp
          move.w    d0,-(sp)

          pea       melodie2(pc)
          move.l    #1000000,-(sp)
          move.w    d0,-(sp)
          move.w    #$3f,-(sp)
          trap      #1
          lea       $0c(sp),sp

          move.w    #$3e,-(sp)
          trap      #1
          addq.l    #4,sp

          clr.w     -(sp)
          pea       name3(pc)
          move.w    #$3d,-(sp)
          trap      #1
          addq.l    #8,sp
          move.w    d0,-(sp)

          pea       voiceset(pc)
          move.l    #1000000,-(sp)
          move.w    d0,-(sp)
          move.w    #$3f,-(sp)
          trap      #1
          lea       $0c(sp),sp

          move.w    #$3e,-(sp)
          trap      #1
          addq.l    #4,sp

          lea       text2(pc),a0
          bsr.s     print

          movea.l   programm(pc),a0
          move.l    #melodie,12(a0)
          move.l    #voiceset,16(a0)

neustart1:
          movea.l   programm(pc),a0
          jsr       (a0)

          move.w    #7,-(sp)
          trap      #1
          addq.l    #2,sp
          movea.l   programm(pc),a0
          cmp.b     #'1',d0
          bne.s     zwei
          move.l    #melodie,12(a0)
          bra.s     neustart1
zwei:     cmp.b     #'2',d0
          bne.s     leer
          move.l    #melodie2,12(a0)
          bra.s     neustart1
leer:     cmp.b     #" ",d0
          bne.s     neustart1

          lea       text3(pc),a0
          bsr.s     print

          DC.W $a009
          clr.w     -(sp)
          trap      #1

print:
          move.l    a0,-(sp)
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp
          rts

          DATA
name1:    DC.B "TITLE.4V",0
name12:   DC.B "HERO.4V",0
name2:    DC.B "SING.DAT",0
name3:    DC.B "DANDARE3.SET",0
text1:    DC.B "EXENEX -- DEMOZONE 68000",13,10
          DC.B "proudly presents ......",13,10,0
text2:    DC.B "DAN DARES III - Musexx.",13,10
          DC.B "Ripped by:  RAMSES XIII",13,10
          DC.B "DEUTSCHLAND am 20.07.90",13,10
          DC.B "Try keys space,1 and 2.",13,10,0
text3:    DC.B "See you in next demo !!",13,10,0
          BSS
programm: DS.L 1
          DS.L 1000
neu:
melodie:  DS.B 10000
melodie2: DS.B 10000
voiceset: DS.W 200000/2
          END
