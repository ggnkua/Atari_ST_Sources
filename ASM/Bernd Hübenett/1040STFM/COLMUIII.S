zeilen    equ 2
hbivec    equ $120
vbivec    equ $70
mkbvec    equ $118
iera      equ $fffa07
ierb      equ $fffa09
isra      equ $fffa0f
imra      equ $fffa13
tbcr      equ $fffa1b
tbdr      equ $fffa21
color_0   equ $ff8240
color_1   equ $ff8242
color_2   equ $ff8244
color_3   equ $ff8246
color_4   equ $ff8248
color_5   equ $ff824a
color_6   equ $ff824c
color_7   equ $ff824e
color_8   equ $ff8250
color_9   equ $ff8252
color_10  equ $ff8254
color_11  equ $ff8256
super     equ 32
logbase   equ 3
vsync     equ 37
cnecin    equ 8

          .DC.w $a00a
          move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          movea.l   d0,a0
          move.l    #0,d0
          move.w    #39,d1
fill:     move.l    #0,(a0)+
          dbf       d1,fill
          lea.l     muster,a1
          move.w    #197,d2
fuellen:  move.w    #0,d1
          move.w    #9,d0
make:     move.w    0(a1,d1.w),(a0)+
          move.w    2(a1,d1.w),(a0)+
          move.w    4(a1,d1.w),(a0)+
          move.w    6(a1,d1.w),(a0)+
          move.w    0(a1,d1.w),(a0)+
          move.w    2(a1,d1.w),(a0)+
          move.w    4(a1,d1.w),(a0)+
          move.w    6(a1,d1.w),(a0)+
          addq.w    #8,d1
          dbf       d0,make
          dbf       d2,fuellen
          move.w    #39,d1
fill1:    move.l    #0,(a0)+
          dbf       d1,fill1
start:    lea.l     farbtab,a0
          move.w    #99,d0
looop:    move.w    #%0000000000000000,(a0)+
          move.w    #%0000001000000001,(a0)+
          move.w    #%0000001000000010,(a0)+
          move.w    #%0000001100000011,(a0)+
          move.w    #%0000001100010011,(a0)+
          move.w    #%0000001100100011,(a0)+
          move.w    #%0000001100110011,(a0)+
          move.w    #%0000011100010111,(a0)+
          move.w    #%0000011100100111,(a0)+
          move.w    #%0000011100110111,(a0)+
          move.w    #%0000011101000111,(a0)+
          move.w    #%0000011101010111,(a0)+
          move.w    #%0000011101100111,(a0)+
          move.w    #%0000011101110111,(a0)+

          move.w    #%0000011101110111,(a0)+
          move.w    #%0000011101100111,(a0)+
          move.w    #%0000011101010111,(a0)+
          move.w    #%0000011101000111,(a0)+
          move.w    #%0000011100110111,(a0)+
          move.w    #%0000011100100111,(a0)+
          move.w    #%0000011100010111,(a0)+
          move.w    #%0000001100110011,(a0)+
          move.w    #%0000001100100011,(a0)+
          move.w    #%0000001100010011,(a0)+
          move.w    #%0000001100000011,(a0)+
          move.w    #%0000001000000010,(a0)+
          move.w    #%0000001000000001,(a0)+
          move.w    #%0000000000000000,(a0)+
          move.w    #%0000000000000000,(a0)+
          move.w    #%0000000000000000,(a0)+
          move.w    #%0000000000000000,(a0)+
          move.w    #%0000000000000000,(a0)+
          dbf       d0,looop

          pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
          movem.l   $ff8240,d0-d7
          movem.l   d0-d7,oldpal
          move.b    $ff8260,res
          move.b    $ff820a,freq
          move.b    ierb,saveierb
          andi.b    #%10111111,ierb
supinit:  move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          move.b    #2,$ff820a
          move.b    #0,$ff8260
          move.l    vbivec,oldvbi+2
          move.l    mkbvec,oldmkb+2
          move.l    #hbi_1,hbivec
          move.l    #vbi,vbivec
          move.l    #mkb,mkbvec
          andi.b    #$df,ierb
          ori.b     #1,iera
          ori.b     #1,imra
          move.l    #6000000,d6
wait:     nop       
          nop       
          subi.l    #1,d6
          cmpi.l    #0,d6
          bne.s     wait
          move.l    oldvbi+2,vbivec
          move.l    oldmkb+2,mkbvec
          andi.b    #$fe,iera
          ori.b     #$20,ierb
          movem.l   oldpal,d0-d7
          movem.l   d0-d7,$ff8240
          move.b    freq,$ff820a
          move.b    res,$ff8260
          move.b    saveierb,ierb
          move.l    ssp,-(sp)
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          .DC.w $a009
          clr.w     -(sp)
          trap      #1
mkb:      move.w    #$2500,sr
oldmkb:   jmp       $ffffffff
vbi:      movem.l   d0/a0,savereg
          move.b    #0,tbcr
          lea.l     farbtab,a0
          move.w    colind0,d0
          move.w    d0,colind0a
          move.w    0(a0,d0.w),nextcol0
          move.w    0(a0,d0.w),nextcol0
          addq.w    #2,d0
          andi.w    #1023,d0
          move.w    d0,colind0
          move.b    #zeilen,tbdr
          move.b    #8,tbcr
          movem.l   savereg,d0/a0
oldvbi:   jmp       $ffffffff
hbi_1:    movem.l   pal1,d0-d5
          movem.l   d0-d5,$ffff8240
          lea.l     pal1,a1
          lea.l     farbtab,a0
          move.w    colind0a,d0
          addi.w    #2,colind0a
          move.w    0(a0,d0.w),(a1)+
          move.w    6(a0,d0.w),(a1)+
          move.w    12(a0,d0.w),(a1)+
          move.w    18(a0,d0.w),(a1)+
          move.w    24(a0,d0.w),(a1)+
          move.w    30(a0,d0.w),(a1)+
          move.w    36(a0,d0.w),(a1)+
          move.w    42(a0,d0.w),(a1)+
          move.w    48(a0,d0.w),(a1)+
          move.w    54(a0,d0.w),(a1)+
          move.w    60(a0,d0.w),(a1)
          andi.b    #$fe,isra
          rte       

          .EVEN 
          .DATA 
colind0:  .DC.w 0
colind2:  .DC.w 0
colind0a: .DC.w 0
colind2a: .DC.w 0
nextcol0: .DC.w 0
nextcol2: .DC.w 0
muster:   .DC.w %1111111111111111,%0000000000000000,%0000000000000000,%0000000000000000
          .DC.w %0000000000000000,%1111111111111111,%0000000000000000,%0000000000000000
          .DC.w %1111111111111111,%1111111111111111,%0000000000000000,%0000000000000000
          .DC.w %0000000000000000,%0000000000000000,%1111111111111111,%0000000000000000
          .DC.w %1111111111111111,%0000000000000000,%1111111111111111,%0000000000000000
          .DC.w %0000000000000000,%1111111111111111,%1111111111111111,%0000000000000000
          .DC.w %1111111111111111,%1111111111111111,%1111111111111111,%0000000000000000
          .DC.w %0000000000000000,%0000000000000000,%0000000000000000,%1111111111111111
          .DC.w %1111111111111111,%0000000000000000,%0000000000000000,%1111111111111111
          .DC.w %0000000000000000,%1111111111111111,%0000000000000000,%1111111111111111
pal1:     .DC.w $0000,$111,$0000,$111,$0000,$111,$0000,$111,$0000,$111
          .BSS 
savereg:  .DS.l 20
ssp:      .DS.l 1
oldpal:   .DS.w 16
res:      .DS.b 1
freq:     .DS.b 1
saveierb: .DS.b 1
          .EVEN 
farbtab:  .DS.w 5000
          .END 

