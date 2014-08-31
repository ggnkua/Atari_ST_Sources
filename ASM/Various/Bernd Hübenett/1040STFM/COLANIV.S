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
color_12  equ $ff8258
color_13  equ $ff825a
color_14  equ $ff825c
color_15  equ $ff825e
logbase   equ 3
vbivec    equ $70
ierb      equ $fffa09
super     equ 32
vsync     equ 37
cnecin    equ 8

          .DC.w $a00a
screen:   move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          movea.l   d0,a6
          move.w    #1999,d0
schleife: move.l    #%00110011001100110011110000111100,(a6)+
          move.l    #%00111111110000001100000000000000,(a6)+
          dbf       d0,schleife
          move.w    #1999,d0
schle:    move.l    #%11001100110011000011110000111100,(a6)+
          move.l    #%00000011111111000000000000000011,(a6)+
          dbf       d0,schle
          pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
          move.b    $ff8260,res
          move.b    $ff820a,freq
          movem.l   $ff8240,d0-d7
          movem.l   d0-d7,oldpal
          move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          move.b    #0,$ff8260
          move.b    #2,$ff820a
superx:   move.w    #%0000000000000000,color_0
          move.w    #%0000011101110111,color_1
          move.w    #%0000000000000000,color_2
          move.w    #%0000000000000000,color_3
          move.w    #%0000000000000000,color_4
          move.w    #%0000000000000000,color_5
          move.w    #%0000000000000000,color_6
          move.w    #%0000000000000000,color_7
          move.w    #%0000000000000000,color_8
          move.l    vbivec,oldvbi+2
          move.l    #vbi,vbivec
          andi.b    #$df,ierb
          move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,-(sp)
          move.l    oldvbi+2,vbivec
          ori.b     #$20,ierb
          move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          move.b    freq,$ff820a
          move.b    res,$ff8260
          movem.l   oldpal,d0-d7
          movem.l   d0-d7,$ff8240
          move.l    ssp,-(sp)
          move.l    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          clr.w     -(sp)
          trap      #1

vbi:      movem.l   d0-d2/a0-a2,savereg
          move.w    nr,d0
          cmpi.w    #8,d0
          bne       weiter
          move.w    #0,nr
          move.w    #0,d0
weiter:   asl.w     #2,d0
          movea.l   #irqtab,a0
          movea.l   0(a0,d0.w),a1
          jmp       (a1)
go_on:    addi.w    #1,nr
          movem.l   savereg,d0-d2/a0-a2
oldvbi:   jmp       $ffffffff

aaa:      move.w    #%0000000000000000,color_1
          move.w    #%0000011101110111,color_2
          jmp       go_on
bbb:      move.w    #%0000000000000000,color_2
          move.w    #%0000011101110111,color_3
          jmp       go_on
ccc:      move.w    #%0000000000000000,color_3
          move.w    #%0000011101110111,color_4
          jmp       go_on
ddd:      move.w    #%0000000000000000,color_4
          move.w    #%0000011101110111,color_5
          jmp       go_on
eee:      move.w    #%0000000000000000,color_5
          move.w    #%0000011101110111,color_6
          jmp       go_on
fff:      move.w    #%0000000000000000,color_6
          move.w    #%0000011101110111,color_7
          jmp       go_on
ggg:      move.w    #%0000000000000000,color_7
          move.w    #%0000011101110111,color_8
          jmp       go_on
hhh:      move.w    #%0000000000000000,color_8
          move.w    #%0000011101110111,color_1
          jmp       go_on

          .DATA 
irqtab:   .DC.l aaa,bbb,ccc,ddd,eee,fff,ggg,hhh
nr:       .DC.w 0
          .BSS 
savereg:  .DS.l 8
ssp:      .DS.l 1
oldpal:   .DS.w 16
res:      .DS.b 1
freq:     .DS.b 1
          .END 

