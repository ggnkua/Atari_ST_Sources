
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
supexec   equ 38

          .DC.w $a00a
start:    lea.l     farbtab,a0
          move.w    #31,d0
ci_loop:  move.w    #%0000011101110111,(a0)+
          move.w    #%0000011101110111,(a0)+
          move.w    #%0000011101110111,(a0)+
          move.w    #%0000011101110111,(a0)+
          move.w    #%0000011101110111,(a0)+
          move.w    #%0000011101110111,(a0)+
          move.w    #%0000011101110111,(a0)+
          move.w    #%0000011101110111,(a0)+
          move.w    #%0000011100000000,(a0)+
          move.w    #%0000011100000000,(a0)+
          move.w    #%0000011100000000,(a0)+
          move.w    #%0000011100000000,(a0)+
          move.w    #%0000011100000000,(a0)+
          move.w    #%0000011100000000,(a0)+
          move.w    #%0000011100000000,(a0)+
          move.w    #%0000011100000000,(a0)+
          dbf       d0,ci_loop
          pea       supinit
          move.b    #1,zeilen
          move.w    #2,counter
          move.w    #supexec,-(sp)
          trap      #14
          addq.l    #6,sp
          .DC.w $a009
          clr.w     -(sp)
          trap      #1
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
          move.b    #1,zeilen
          move.w    #2,counter
          move.l    #2000000,d0
wait:     subq.l    #1,d0
          bne.s     wait
          move.b    #2,zeilen
          move.w    #4,counter
          move.l    #2000000,d0
wait1:    subq.l    #1,d0
          bne.s     wait1
          move.b    #4,zeilen
          move.w    #8,counter
          move.l    #2000000,d0
wait2:    subq.l    #1,d0
          bne.s     wait2
          move.b    #8,zeilen
          move.w    #16,counter
          move.l    #2000000,d0
wait3:    subq.l    #1,d0
          bne.s     wait3
          move.l    oldvbi+2,vbivec
          move.l    oldmkb+2,mkbvec
          andi.b    #$fe,iera
          ori.b     #$20,ierb
          movem.l   oldpal,d0-d7
          movem.l   d0-d7,$ff8240
          rts       
mkb:      move.w    #$2500,sr
oldmkb:   jmp       $ffffffff
vbi:      movem.l   d0/a0,savereg
          move.b    #0,tbcr
          lea.l     farbtab,a0
          move.w    colind0,d0
          move.w    d0,colind0a
          move.w    0(a0,d0.w),color_2
          move.w    0(a0,d0.w),nextcol0
          add.w     counter,d0
          andi.w    #1023,d0
          move.w    d0,colind0
          move.b    zeilen,tbdr
          move.b    #8,tbcr
          movem.l   savereg,d0/a0
oldvbi:   jmp       $ffffffff
hbi:      move.w    nextcol0,color_2
          movem.l   d0/a0,savereg
          lea.l     farbtab,a0
          move.w    colind0a,d0
          sub.w     counter,d0
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
          .EVEN 
          .BSS 
oldpal:   .DS.w 16
savereg:  .DS.l 4
farbtab:  .DS.w 512
counter:  .DS.w 1
zeilen:   .DS.b 1
          .EVEN 
          .END 


