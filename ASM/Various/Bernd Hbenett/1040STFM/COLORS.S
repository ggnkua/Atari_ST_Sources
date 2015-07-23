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
supexec   equ 38
start:    lea.l     farbtab,a0
          clr.w     d0
ci_loop:  move.w    d0,d1
          move.w    d0,d2
          move.w    d0,d3
          andi.w    #%0000000000000111,d1
          andi.w    #%0000000000111000,d2
          andi.w    #%111000000,d3
          lsl.w     #1,d2
          lsl.w     #2,d3
          or.w      d2,d1
          or.w      d3,d1
          move.w    d1,(a0)+
          addq.w    #1,d0
          cmpi.w    #512,d0
          bcs.s     ci_loop
          pea       supinit
          move.w    #supexec,-(sp)
          trap      #14
          addq.l    #6,sp
          clr.w     -(sp)
          trap      #1
supinit:  move.l    vbivec,oldvbi+2
          move.l    mkbvec,oldmkb+2
          move.l    #hbi,hbivec
          move.l    #vbi,vbivec
          move.l    #mkb,mkbvec
          andi.b    #$df,ierb
          ori.b     #1,iera
          ori.b     #1,imra
          move.l    #2000000,d0
wait:     subq.l    #1,d0
          bne.s     wait
          move.l    oldvbi+2,vbivec
          move.l    oldmkb+2,mkbvec
          andi.b    #$fe,iera
          ori.b     #$20,ierb
          move.w    #$777,color_0
          move.w    #$0070,color_2
          rts       
mkb:      move.w    #$2500,sr
oldmkb:   jmp       $ffffffff
vbi:      movem.l   d0/a0,savereg
          move.b    #0,tbcr
          lea.l     farbtab,a0
          move.w    colind0,d0
          move.w    d0,colind0a
          move.w    0(a0,d0.w),color_0
          move.w    0(a0,d0.w),nextcol0
          addq.w    #2,d0
          andi.w    #1023,d0
          move.w    d0,colind0
          move.w    colind2,d0
          move.w    d0,colind2a
          move.w    0(a0,d0.w),color_2
          move.w    0(a0,d0.w),nextcol2
          addq.w    #2,d0
          andi.w    #1023,d0
          move.w    d0,colind2
          move.b    #zeilen,tbdr
          move.b    #8,tbcr
          movem.l   savereg,d0/a0
oldvbi:   jmp       $ffffffff
hbi:      move.w    nextcol0,color_0
          move.w    nextcol2,color_2
          movem.l   d0/a0,savereg
          lea.l     farbtab,a0
          move.w    colind0a,d0
          addq.w    #2,d0
          andi.w    #1023,d0
          move.w    d0,colind0a
          move.w    0(a0,d0.w),nextcol0
          move.w    colind2a,d0
          subq.w    #2,d0
          andi.w    #1023,d0
          move.w    d0,colind2a
          move.w    0(a0,d0.w),nextcol2
          andi.b    #$fe,isra
          movem.l   savereg,d0/a0
          rte       
          .DATA 
colind0:  .DC.w 0
colind2:  .DC.w 0
colind0a: .DC.w 0
colind2a: .DC.w 0
nextcol0: .DC.w 0
nextcol2: .DC.w 0
          .BSS 
savereg:  .DS.l 4
farbtab:  .DS.w 512
          .END 


