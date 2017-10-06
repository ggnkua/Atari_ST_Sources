zeilen    equ 1
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
color_2   equ $ff8244
super     equ 32
cnecin    equ 8
logbase   equ 3

          .DC.w $a00a
          movem.l   pipe,d4-d7/a4-a6
          lea.l     farbtab,a0
          movea.l   a0,a1
          lea.l     pos,a2
          move.l    #0,d1
          move.l    #58,d0
          lea.l     farbadr,a3
loop:     move.l    a1,(a3)+

          move.w    #9,d3
          lea.l     pos,a2
looop:    movea.l   a1,a0
          move.w    0(a2,d1.w),d2
          adda.l    d2,a0
          movem.l   d4-d7/a4-a6,(a0)
          adda.l    #2,a2
          dbf       d3,looop

          addi.w    #2,d1
          adda.l    #400,a1
          dbf       d0,loop
          move.l    #0,counter
          move.l    #0,(a3)

start:    move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          movea.l   d0,a0
          move.w    #8000,d0
clear:    move.l    #0,(a0)+
          dbf       d0,clear

          pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
supinit:  movem.l   $ff8240,d0-d7
          movem.l   d0-d7,oldpal
          move.l    vbivec,oldvbi+2
          move.l    mkbvec,oldmkb+2
          move.l    #hbi,hbivec
          move.l    #vbi,vbivec
          move.l    #mkb,mkbvec
          andi.b    #$df,ierb
          ori.b     #1,iera
          ori.b     #1,imra
          move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          move.l    oldvbi+2,vbivec
          move.l    oldmkb+2,mkbvec
          andi.b    #$fe,iera
          ori.b     #$20,ierb
          movem.l   oldpal,d0-d7
          movem.l   d0-d7,$ff8240
          move.l    ssp,-(sp)
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          .DC.w $a009
          clr.w     -(sp)
          trap      #1
mkb:      move.w    #$2500,sr
oldmkb:   jmp       $ffffffff
vbi:      movem.l   d0/a0/a1,savereg
          move.b    #0,tbcr

          move.w    counter,d0
          asl.w     #2,d0
          movea.l   #farbadr,a0
          movea.l   0(a0,d0.w),a1
          cmpa.l    #0,a1
          beq       zero
color:    move.l    a1,adresse
          movea.l   a1,a0
          addi.w    #1,counter
          move.l    #0,d0
          move.w    #0,colind0a
          move.w    0(a0,d0.w),color_0
          move.w    0(a0,d0.w),nextcol0
          move.w    d0,colind0
          move.b    #zeilen,tbdr
          move.b    #8,tbcr
          movem.l   savereg,d0/a0/a1
oldvbi:   jmp       $ffffffff
zero:     move.w    #0,counter
          move.l    #0,d0
          movea.l   0(a0,d0.w),a1
          jmp       color
hbi:      move.w    nextcol0,color_0
          movem.l   d0/a0,savereg
          movea.l   adresse,a0
          move.w    colind0a,d0
          addq.w    #2,d0
          move.w    d0,colind0a
          move.w    0(a0,d0.w),nextcol0
          andi.b    #$fe,isra
          movem.l   savereg,d0/a0
          rte       
          .EVEN 
          .DATA 

adresse:  .DC.l 0
counter:  .DC.w 0
colind0:  .DC.w 0
colind0a: .DC.w 0
nextcol0: .DC.w 0
pipe:     .DC.w $0001,$0002,$0003,$0004,$0005,$0006,$0007
          .DC.w $0007,$0006,$0005,$0004,$0003,$0002,$0001

pos:      .DC.w 2,2,2,2,2,2,2,2,4,6,10,14,20,26,34,44,56,70,86,102,118,134
          .DC.w 150,166,182,196,208,218,226,232,238,242,246,248,250,250
          .DC.w 250,250,250,250,250,250,248,246,242,238,232,226,218,208
          .DC.w 196,182,166,150,134,118,102,86,70,56,44,34,26,20,14,10,6,4

          .BSS 
savereg:  .DS.l 4
ssp:      .DS.l 1
oldpal:   .DS.w 16
farbadr:  .DS.l 60
farbtab:  .DS.w 13000
          .END 


