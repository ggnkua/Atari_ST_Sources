cnecin    equ 8
fopen     equ 61
fread     equ 63
fclose    equ 62
logbase   equ 3
super     equ 32
vsync     equ 37
vbivec    equ $70
ierb      equ $fffa09
h_mouse   equ $a00a
s_mouse   equ $a009

          .DC.w h_mouse
          move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          move.l    d0,oldscr
          move.l    #screen+256,d0
          andi.l    #$ffffff00,d0
          move.l    d0,scr_anf
          move.l    d0,pointer
          addi.l    #448000,d0
          move.l    d0,scr_end
          pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
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
          movem.l   $ff8240,d0-d3/a0-a3
          movem.l   d0-d3/a0-a3,farbtab
          movem.l   vorspann+2,d0-d7
          movem.l   d0-d7,$ffff8240
readout:  move.l    #bild,-(sp)
          move.l    #32000,-(sp)
          move.w    handle,-(sp)
          move.w    #fread,-(sp)
          trap      #1
          lea.l     $c(sp),sp
shut_dat: move.w    handle,-(sp)
          move.w    #fclose,-(sp)
          trap      #1
          addq.l    #4,sp

          movea.l   #bild,a0
          adda.l    #31840,a0
          move.w    #39,d0
erase:    move.l    #0,(a0)+
          dbf       d0,erase

start:    movea.l   #bild,a0
          movea.l   #low,a1
          movea.l   scr_anf,a2
          move.w    #7,d1
looop:    move.w    #7999,d0
          movea.l   a2,a5
          movea.l   a0,a3
loop:     move.l    (a3)+,(a5)+
          dbf       d0,loop
          movea.l   a0,a3
          movea.l   a1,a4
          move.w    #7999,d0
scroll:   move.l    (a3)+,(a4)+
          dbf       d0,scroll
          adda.l    #64000,a2
          dbf       d1,looop

supinit:  move.l    vbivec,oldvbi+2
          move.l    #vbi,vbivec
          andi.b    #$df,ierb
          move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          move.l    oldvbi+2,vbivec
          ori.b     #$20,ierb
          move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          move.l    oldscr,d0
          lsr.l     #8,d0
          move.b    d0,$ff8203
          lsr.l     #8,d0
          move.b    d0,$ff8201
          movem.l   farbtab,d0-d3/a0-a3
          movem.l   d0-d3/a0-a3,$ff8240
          .DC.w s_mouse
          clr.w     -(sp)
          trap      #1

vbi:      movem.l   d0-d3,savereg
          move.l    pointer,d0
          move.l    scr_end,d1
          lsr.l     #8,d0
          move.b    d0,$ff8203
          lsr.l     #8,d0
          move.b    d0,$ff8201
          move.l    pointer,d0
          cmp.l     d0,d1
          beq       hit
          addi.l    #64000,pointer
go_on:    movem.l   savereg,d0-d3
oldvbi:   jmp       $ffffffff
hit:      addi.l    #1280,scr_anf
          move.l    scr_anf,pointer
          addi.l    #1280,scr_end
          bra.s     go_on

          .DATA 
name:     .DC.b "bild.deg",0
          .EVEN 
          .BSS 
savereg:  .DS.l 16
ssp:      .DS.l 1
farbtab:  .DS.l 8
oldscr:   .DS.l 1
scr_anf:  .DS.l 1
scr_end:  .DS.l 1
pointer:  .DS.l 1
handle:   .DS.w 1
vorspann: .DS.b 34
low:      .DS.b 160
bild:     .DS.b 32000
high:     .DS.b 160
screen:   .DS.b 512256
          .END 

