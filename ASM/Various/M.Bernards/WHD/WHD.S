; Installiert WHD Bootsektor auf Diskette

flock     equ $43e
hz200     equ $4ba
_dskbufp  equ $4c6
wdl       equ $ffff8604
wdc       equ $ffff8606
dmahig    equ $ffff8609
dmamid    equ $ffff860b
dmalow    equ $ffff860d
gpip      equ $fffffa01

          pea       msg1(pc)
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp
          move.w    #7,-(sp)
          trap      #1
          addq.l    #2,sp
          clr.w     -(sp)
          clr.w     -(sp)
          move.w    #1,-(sp)
          pea       buffer(pc)
          move.w    #2,-(sp)
          move.w    #4,-(sp)
          trap      #13
          lea.l     14(sp),sp
          lea.l     buffer(pc),a0
          move.w    #$6038,(a0)
          lea.l     $3a(a0),a0
          lea.l     bootcode(pc),a1
          move.w    #end_code-bootcode,d0
          lsr.w     #1,d0
.loop:    move.w    (a1)+,(a0)+
          dbf       d0,.loop
          move.w    #1,-(sp)
          move.w    #-1,-(sp)
          move.l    #-1,-(sp)
          pea       buffer(pc)
          move.w    #18,-(sp)
          trap      #14
          lea.l     14(sp),sp
          clr.w     -(sp)
          clr.w     -(sp)
          move.w    #1,-(sp)
          pea       buffer(pc)
          move.w    #3,-(sp)
          move.w    #4,-(sp)
          trap      #13
          lea.l     14(sp),sp
          clr.w     -(sp)
          trap      #1

bootcode: pea       msg2(pc)
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    hz200,d0
          addi.l    #6000,d0  ; 30 Sek.
          lea.l     timer(pc),a0
          move.l    d0,(a0)
nexttest: lea.l     timer(pc),a0
          move.l    (a0),d0
          sub.l     hz200,d0
          bmi.s     isdone
          moveq.l   #100,d0   ; 1. Warteschleife
          add.l     hz200,d0
loopi:    cmp.l     hz200,d0
          bcc.s     loopi
          bsr.s     testdev
          bne.s     nexttest
          moveq.l   #100,d0   ; 2. Warteschleife
          add.l     hz200,d0
.loop:    cmp.l     hz200,d0
          bcc.s     .loop
isdone:   rts       

timer:    .DC.l 0

testdev:  clr.w     d5
nextretr: lea.l     wdc,a6
          lea.l     wdl,a5
          st        flock
          move.l    _dskbufp,-(sp)
          addi.l    #$200,(sp)
          move.b    3(sp),dmalow
          move.b    2(sp),dmamid
          move.b    1(sp),dmahig
          addq.w    #4,sp
          move.w    #$98,(a6)
          move.w    #$198,(a6)
          move.w    #$98,(a6)
          move.w    #1,(a5)
          move.w    #$88,(a6)
          move.l    #$8a,d0
          bsr.s     send_dma
          bne.s     errout
          moveq.l   #3,d6
          lea.l     dmacmd(pc),a0
.loop:    move.l    (a0)+,d0
          bsr.s     send_dma
          bne.s     errout
          dbf       d6,.loop
          move.l    #10,(a5)
          move.w    #$190,d1
          bsr.s     lwait
          bne.s     errout
          move.w    #$8a,(a6)
          move.w    (a5),d0
          andi.w    #$ff,d0
          beq.s     ok
          dbf       d5,nextretr
errout:   moveq.l   #-1,d0
ok:       move.w    #$80,(a6)
          tst.b     d0
          sf        flock
          rts       

dmacmd:   .DC.l $8a,$8a,$8a,$8a

send_dma: move.l    d0,(a5)
          moveq.l   #10,d1
lwait:    add.l     hz200,d1
.loop:    btst.b    #5,gpip
          beq.s     send_end
          cmp.l     hz200,d1
          bne.s     .loop
          moveq.l   #-1,d1
send_end: rts       

msg2:     .DC.b 'ST wartet auf die Harddisk',13,10
          .DC.b 'Ω 2/89 by Michael Bernards',13,10
          .DC.b '    fÅr das ST-MAGAZIN',13,10,0
end_code: 
msg1:     .DC.b 'Harddisk-WÑchter Ω`89 by M.Bernards',13,10
          .DC.b 'Verîffentlicht im ST-MAGAZIN 5/1989',13,10,10
          .DC.b 'Laufwerk A: und drÅcken sie eine Taste',13,10,0

          .BSS 
          .EVEN 
buffer:   .DS.w 256
          .END 
