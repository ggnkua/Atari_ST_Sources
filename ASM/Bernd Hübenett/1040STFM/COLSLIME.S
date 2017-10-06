cnecin    equ 8
fopen     equ 61
fread     equ 63
fclose    equ 62
logbase   equ 3
super     equ 32
vsync     equ 37

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
read_out: move.l    #screen,-(sp)
          move.l    #32000,-(sp)
          move.w    handle,-(sp)
          move.w    #fread,-(sp)
          trap      #1
          lea.l     $c(sp),sp
shut_dat: move.w    handle,-(sp)
          move.w    #fclose,-(sp)
          trap      #1
          addq.l    #4,sp
          movea.l   scr,a0
          movea.l   #screen,a1
          move.w    #199,d5
          move.w    d5,d3
main:     move.w    d3,d4
          movea.l   a1,a6
          movea.l   a0,a5
          move.w    #39,d0
          movea.l   #copybuf,a2
copy:     move.l    (a6)+,(a2)+
          dbf       d0,copy
copy_2:   movea.l   #copybuf,a2
          move.w    #39,d0
copy_1:   move.l    (a2)+,(a5)+
          dbf       d0,copy_1
          dbf       d4,copy_2
          subi.w    #1,d3
          adda.l    #160,a1
          adda.l    #160,a0
          dbf       d5,main
wait_key: move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          movem.l   oldpal,d0-d7
          movem.l   d0-d7,$ff8240
          move.b    freq,$ff820a
          move.b    res,$ff8260
          .DC.w $a009
          move.l    ssp,-(sp)
          move.l    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          clr.w     -(sp)
          trap      #1
          .DATA 
name:     .DC.b "bild.deg"
          .EVEN 
          .BSS 
vorspann: .DS.b 34
          .EVEN 
ssp:      .DS.l 1
handle:   .DS.w 1
scr:      .DS.l 1
screen:   .DS.l 8000
copybuf:  .DS.l 40
oldpal:   .DS.w 16
res:      .DS.b 1
freq:     .DS.b 1
          .END 

