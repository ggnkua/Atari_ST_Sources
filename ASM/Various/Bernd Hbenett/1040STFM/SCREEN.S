cnecin    equ 8
fopen     equ 61
fread     equ 63
fclose    equ 62
logbase   equ 3
super     equ 32
vsync     equ 37
vbivec    equ $70
ierb      equ $fffa09

          .DC.w $a00a
start:    pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
          movem.l   $ff8240,d0-d7
          movem.l   d0-d7,oldpal
          move.b    $ff8260,res
          move.b    $ff820a,freq
          move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          move.b    #0,$ff8260
          move.b    #2,$ff820a
          move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          move.l    d0,scr
          move.l    #bildsch+256,d0
          andi.l    #$ffffff00,d0
          move.l    d0,screen
          move.l    d0,scr_x

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
read_out: move.l    screen,-(sp)
          move.l    #32000,-(sp)
          move.w    handle,-(sp)
          move.w    #fread,-(sp)
          trap      #1
          lea.l     $c(sp),sp
shut_dat: move.w    handle,-(sp)
          move.w    #fclose,-(sp)
          trap      #1
          addq.l    #4,sp
          movea.l   screen,a0
          move.w    #6,d4
mainloop: movea.l   a0,a1
          movea.l   a1,a2
          adda.l    #32000,a2
          movea.l   a2,a3
          move.w    #7999,d0
fill_up:  move.l    (a1)+,(a2)+
          dbf       d0,fill_up
          andi.w    #%1111111111101111,sr
          move.w    #199,d2
scr_2:    move.w    #3,d1
scr_1:    move.w    #1,d0
scroll:   roxl.w    152(a3)
          roxl.w    144(a3)
          roxl.w    136(a3)
          roxl.w    128(a3)
          roxl.w    120(a3)
          roxl.w    112(a3)
          roxl.w    104(a3)
          roxl.w    96(a3)
          roxl.w    88(a3)
          roxl.w    80(a3)
          roxl.w    72(a3)
          roxl.w    64(a3)
          roxl.w    56(a3)
          roxl.w    48(a3)
          roxl.w    40(a3)
          roxl.w    32(a3)
          roxl.w    24(a3)
          roxl.w    16(a3)
          roxl.w    8(a3)
          roxl.w    0(a3)
          andi.w    #%1111111111101111,sr
          dbf       d0,scroll
          andi.w    #%1111111111101111,sr
          addq.l    #2,a3
          dbf       d1,scr_1
          adda.l    #152,a3
          andi.w    #%1111111111101111,sr
          dbf       d2,scr_2
          adda.l    #32000,a0
          dbf       d4,mainloop
          move.l    vbivec,oldvbi+2
          move.l    #vbi,vbivec
          andi.b    #$df,ierb
wait_key: move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          move.l    oldvbi+2,vbivec
          ori.b     #$20,ierb
          movem.l   oldpal,d0-d7
          movem.l   d0-d7,$ff8240
          move.b    freq,$ff820a
          move.b    res,$ff8260
          move.l    scr,d0
          lsr.l     #8,d0
          move.b    d0,$ff8203
          lsr.l     #8,d0
          move.b    d0,$ff8201
          .DC.w $a009
          move.l    ssp,-(sp)
          move.l    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          clr.w     -(sp)
          trap      #1

vbi:      movem.l   d0/d1/a0-a2,savereg
          move.w    counter,d0
          cmpi.w    #8,d0
          bne       weiter
          move.w    #0,d0
          move.w    d0,counter
          move.l    screen,d1
          move.l    d1,scr_x
weiter:   move.l    scr_x,d1
          lsr.l     #8,d1
          move.b    d1,$ff8203
          lsr.l     #8,d1
          move.b    d1,$ff8201
          addi.l    #32000,scr_x
          addi.w    #1,counter
          movem.l   savereg,d0/d1/a0-a2
oldvbi:   jmp       $ffffffff

          .DATA 
name:     .DC.b "bild.deg"
          .EVEN 

adr_up:   .DC.l 0
down:     .DC.l 39
counter:  .DC.w 0
          .BSS 
vorspann: .DS.b 34
          .EVEN 

ssp:      .DS.l 1
handle:   .DS.w 1
scr:      .DS.l 1
copybuf:  .DS.l 40
res:      .DS.b 1
freq:     .DS.b 1
          .EVEN 
screen:   .DS.l 1
scr_x:    .DS.l 1
bildsch:  .DS.b 256256
          .EVEN 
oldpal:   .DS.w 16
savereg:  .DS.l 10
          .END 

