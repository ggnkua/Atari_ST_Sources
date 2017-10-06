super     equ 32
logbase   equ 3
vsync     equ 37
cnecin    equ 8
vbivec    equ $70
ierb      equ $ffa09

          .DC.w $a00a
          pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
          move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          move.l    d0,scr
          movem.l   $ff8240,d0-d7
          movem.l   d0-d7,oldpal
          move.b    $ff8260,res
          move.b    $ff820a,freq
          move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          move.b    #0,$ff8260
          move.b    #2,$ff820a
          movem.l   farbtab,d0-d7
          movem.l   d0-d7,$ff8240
          move.l    #bildsch+256,d0
          andi.l    #$ffffff00,d0
          move.l    d0,screen
          move.l    d0,scr_x
          move.w    #15,d4
main:     movea.l   d0,a0
          move.w    #13,d2
loooop:   movea.l   #daten,a1
          move.w    #15,d1
looop:    move.w    #19,d3
loop:     move.l    0(a1),(a0)+
          move.l    4(a1),(a0)+
          dbf       d3,loop
          adda.l    #8,a1
          dbf       d1,looop
          dbf       d2,loooop
          addi.l    #32000,d0
          movea.l   #daten,a1
          move.l    #15,d2
shift:    move.w    (a1),d1
          swap.w    d1
          move.w    (a1),d1
          lsl.l     #1,d1
          swap.w    d1
          move.w    d1,(a1)
          move.w    2(a1),d1
          swap.w    d1
          move.w    2(a1),d1
          lsl.l     #1,d1
          swap.w    d1
          move.w    d1,2(a1)
          move.w    4(a1),d1
          swap.w    d1
          move.w    4(a1),d1
          lsl.l     #1,d1
          swap.w    d1
          move.w    d1,4(a1)
          move.w    6(a1),d1
          swap.w    d1
          move.w    6(a1),d1
          lsl.l     #1,d1
          swap.w    d1
          move.w    d1,6(a1)
          addq.l    #8,a1
          dbf       d2,shift
          dbf       d4,main
          move.l    vbivec,oldvbi+2
          move.l    #vbi,vbivec
          andi.b    #$df,ierb
          move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          move.w    #1,marke
          move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          move.w    #2,marke
          move.w    #cnecin,-(sp)
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

vbi:      movem.l   d0/d1,savereg
          move.w    counter,d0
          move.w    vor_1,d1
          cmp.w     d1,d0
          bne       weiter
          move.w    #0,counter
          move.l    screen,d0
          move.l    d0,scr_x
          cmpi.w    #2,marke
          bne       go
          move.w    #4,vor_1
          move.l    #128000,vor_2
go:       cmpi.w    #1,marke
          bne       weiter
          move.w    #8,vor_1
          move.l    #64000,vor_2
weiter:   move.l    scr_x,d0
          lsr.l     #8,d0
          move.b    d0,$ff8203
          lsr.l     #8,d0
          move.b    d0,$ff8201
          addi.w    #1,counter
          move.l    vor_2,d1
          add.l     d1,scr_x
          movem.l   savereg,d0/d1
oldvbi:   jmp       $ffffffff

          .DATA 
counter:  .DC.w 0
vor_1:    .DC.w 16
vor_2:    .DC.l 32000
marke:    .DC.w 0
farbtab:  .DC.w $0000,$0701,$0601,$0501,$0401,$0301,$0070,$0060
          .DC.w $0050,$0040,$0030,$0020,$0707,$0704,$0126,$0777

daten:    .DC.w $ffff,$0000,$ffff,$0000,$8001,$0000,$ffff,$0000
          .DC.w $bffd,$3ffc,$c003,$0000,$a005,$3ffc,$c003,$0000
          .DC.w $aff5,$300c,$c003,$0000,$a815,$37ec,$c003,$0000
          .DC.w $abd5,$37ec,$c003,$0000,$aa55,$366c,$c183,$0000
          .DC.w $aa55,$366c,$c183,$0000,$abd5,$37ec,$c003,$0000
          .DC.w $a815,$37ec,$c003,$0000,$aff5,$300c,$c003,$0000
          .DC.w $a005,$3ffc,$c003,$0000,$bffd,$3ffc,$c003,$0000
          .DC.w $8001,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
          .BSS 
savereg:  .DS.l 8
screen:   .DS.l 1
scr_x:    .DS.l 1
ssp:      .DS.l 1
scr:      .DS.l 1
oldpal:   .DS.w 16
res:      .DS.b 1
freq:     .DS.b 1
          .EVEN 
bildsch:  .DS.b 512256
          .END 

