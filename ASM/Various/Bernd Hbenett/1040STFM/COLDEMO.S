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
color_0   equ $ff8242
color_2   equ $ff8240
super     equ 32
logbase   equ 3
cnecin    equ 8

          .DC.w $a00a
          move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          movea.l   d0,a0
          move.w    #7999,d0
gggg:     move.l    #%00000000000000000000000000000000,(a0)+
          dbf       d0,gggg
start:    lea.l     farbtab,a0
          move.w    #169,d0
looop:    move.w    #%0000000000000000,(a0)+
          dbf       d0,looop
          move.w    #$0777,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0001,(a0)+
          move.w    #$0002,(a0)+
          move.w    #$0003,(a0)+
          move.w    #$0004,(a0)+
          move.w    #$0005,(a0)+
          move.w    #$0006,(a0)+
          move.w    #$0006,(a0)+
          move.w    #$0007,(a0)+
          move.w    #$0007,(a0)+
          move.w    #$0007,(a0)+
          move.w    #$0007,(a0)+
          move.w    #$0006,(a0)+
          move.w    #$0006,(a0)+
          move.w    #$0005,(a0)+
          move.w    #$0004,(a0)+
          move.w    #$0003,(a0)+
          move.w    #$0002,(a0)+
          move.w    #$0001,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0777,(a0)+

          move.w    #313,d0
loop:     move.w    #%0000000000000000,(a0)+
          dbf       d0,loop

          lea.l     tabelle,a0
          move.w    #469,d0
looop2:   move.w    #%0000000000000000,(a0)+
          dbf       d0,looop2

          move.w    #$0777,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0001,(a0)+
          move.w    #$0002,(a0)+
          move.w    #$0003,(a0)+
          move.w    #$0004,(a0)+
          move.w    #$0005,(a0)+
          move.w    #$0006,(a0)+
          move.w    #$0006,(a0)+
          move.w    #$0007,(a0)+
          move.w    #$0007,(a0)+
          move.w    #$0007,(a0)+
          move.w    #$0007,(a0)+
          move.w    #$0006,(a0)+
          move.w    #$0006,(a0)+
          move.w    #$0005,(a0)+
          move.w    #$0004,(a0)+
          move.w    #$0003,(a0)+
          move.w    #$0002,(a0)+
          move.w    #$0001,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0000,(a0)+
          move.w    #$0777,(a0)+

          move.w    #13,d0
loop2:    move.w    #%0000000000000000,(a0)+
          dbf       d0,loop2

          pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
          movem.l   $ff8240,d0-d7
          movem.l   d0-d7,oldpal
supinit:  move.l    vbivec,oldvbi+2
          move.l    vbivec,oldvbi_2+2
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
vbi:      movem.l   d0/a0,savereg
          move.b    #0,tbcr
          lea.l     farbtab,a0
          move.w    colind0,d0
          move.w    d0,colind0a
          move.w    0(a0,d0.w),color_2
          move.w    0(a0,d0.w),nextcol0
          addq.w    #2,d0
          cmpi.w    #310,d0
          bne       ok_ok
          move.w    #0,d0
          move.l    #hbi_2,hbivec
          move.l    #vbi_2,vbivec
          move.w    #0,colind0a
          move.w    #0,nextcol0
ok_ok:    move.w    d0,colind0
          move.b    #zeilen,tbdr
          move.b    #8,tbcr
          movem.l   savereg,d0/a0
oldvbi:   jmp       $ffffffff

vbi_2:    movem.l   d0/a0,savereg
          move.b    #0,tbcr
          lea.l     tabelle,a0
          move.w    colind0,d0
          move.w    d0,colind0a
          move.w    0(a0,d0.w),color_2
          move.w    0(a0,d0.w),nextcol0
          addq.w    #2,d0
          cmpi.w    #310,d0
          bne       ready
          move.w    #0,d0
          move.l    #hbi,hbivec
          move.l    #vbi,vbivec
          move.w    #0,colind0a
          move.w    #0,nextcol0
ready:    move.w    d0,colind0
          move.b    #zeilen,tbdr
          move.b    #8,tbcr
          movem.l   savereg,d0/a0
oldvbi_2: jmp       $ffffffff


hbi:      move.w    nextcol0,color_2
          movem.l   d0/a0,savereg
          lea.l     farbtab,a0
          move.w    colind0a,d0
          addq.w    #2,d0
          andi.w    #1023,d0
          move.w    d0,colind0a
          move.w    0(a0,d0.w),nextcol0
          andi.b    #$fe,isra
          movem.l   savereg,d0/a0
          rte       

hbi_2:    move.w    nextcol0,color_2
          movem.l   d0/a0,savereg
          lea.l     tabelle,a0
          move.w    colind0a,d0
          subq.w    #2,d0
          andi.w    #1023,d0
          move.w    d0,colind0a
          move.w    0(a0,d0.w),nextcol0
          andi.b    #$fe,isra
          movem.l   savereg,d0/a0
          rte       
          .EVEN 
          .DATA 
colind0:  .DC.w 0
colind2:  .DC.w 0
colind0a: .DC.w 0
colind2a: .DC.w 0
nextcol0: .DC.w 0
nextcol2: .DC.w 0

          .BSS 
savereg:  .DS.l 4
farbtab:  .DS.w 520
tabelle:  .DS.w 520
ssp:      .DS.l 1
oldpal:   .DS.w 16
          .END 


