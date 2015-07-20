cnecin    equ 8
fopen     equ 61
fread     equ 63
fclose    equ 62
logbase   equ 3
super     equ 32
vsync     equ 37

          pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
          movem.l   $ff8240,d0-d7
          movem.l   d0-d7,oldpal
          move.b    $ff8260,res
          move.b    $ff820a,freq
          move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          move.l    d0,oldscr
          move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          move.b    #0,$ff8260
          move.b    #2,$ff820a
          move.l    #bild+256,d0
          andi.l    #$ffffff00,d0
          move.l    d0,newscr1
          addi.l    #32000,d0
          move.l    d0,newscr2
          move.l    newscr1,d0
          lsr.l     #8,d0
          move.b    d0,$ff8203
          lsr.l     #8,d0
          move.b    d0,$ff8201
          movem.l   pal1,d0-d7
          movem.l   d0-d7,$ffff8240
          movem.l   graphic,d6/d7
          movea.l   newscr1,a0
          moveq.l   #99,d1
alles:    moveq.l   #19,d0
zeile1:   move.l    d6,(a0)+
          move.l    d7,(a0)+
          dbf       d0,zeile1
          moveq.l   #9,d0
zeile2:   move.l    d6,(a0)+
          move.l    d7,(a0)+
          addq.l    #8,a0
          dbf       d0,zeile2
          dbf       d1,alles
          move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          move.l    newscr2,d0
          lsr.l     #8,d0
          move.b    d0,$ff8203
          lsr.l     #8,d0
          move.b    d0,$ff8201

          move.w    #$fff,$43e

oeffnen:  move.w    #2,-(sp)
          pea       name
          move.w    #fopen,-(sp)
          trap      #1
          addq.l    #8,sp
          move.w    d0,handle
schrott:  move.l    #vorspann,-(sp)
          move.l    #34,-(sp)
          move.w    handle,-(sp)
          move.w    #fread,-(sp)
          trap      #1
          lea.l     $c(sp),sp
          movem.l   vorspann+2,d0-d7
          movem.l   d0-d7,$ffff8240
readout:  move.l    newscr2,-(sp)
          move.l    #32000,-(sp)
          move.w    handle,-(sp)
          move.w    #fread,-(sp)
          trap      #1
          lea.l     $c(sp),sp
shut_dat: move.w    handle,-(sp)
          move.w    #fclose,-(sp)
          trap      #1
          addq.l    #4,sp
wait_key: move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          move.l    oldscr,d0
          lsr.l     #8,d0
          move.b    d0,$ff8203
          lsr.l     #8,d0
          move.b    d0,$ff8201
          move.b    freq,$ff820a
          move.b    res,$ff8260
          movem.l   oldpal,d0-d7
          movem.l   d0-d7,$ff8240
          move.l    ssp,-(sp)
          move.l    #$20,-(sp)
          trap      #1
          addq.l    #6,sp
          clr.w     -(sp)
          trap      #1
          .DATA 
graphic:  .DC.w $55aa,$33cc,$0ff0,$0000
pal1:     .DC.w $0000,$111,$222,$333,$444,$555,$666,$777
          .DC.w $772,$772,$772,$772,$772,$772,$772,$772
name:     .DC.b "bild.deg",0
          .EVEN 
          .BSS 
ssp:      .DS.l 1
oldscr:   .DS.l 1
newscr1:  .DS.l 1
newscr2:  .DS.l 1
handle:   .DS.w 1
vorspann: .DS.b 34
bild:     .DS.b 64256
oldpal:   .DS.w 16
res:      .DS.b 1
freq:     .DS.b 1
          .END 

