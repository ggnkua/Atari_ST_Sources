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
logbase   equ 3


start:    move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          move.l    d0,oldscr
          addi.l    #800,d0
          move.l    d0,newscr
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
          move.l    oldscr,d0
          lsr.l     #8,d0
          move.b    d0,$ff8203
          lsr.l     #8,d0
          move.b    d0,$ff8201
          move.b    #zeilen,tbdr
          move.b    #8,tbcr
          movem.l   savereg,d0/a0
oldvbi:   jmp       $ffffffff
hbi:      movem.l   d0/a0,savereg
          move.l    newscr,d0
          lsr.l     #8,d0
          move.b    d0,$ff8203
          lsr.l     #8,d0
          move.b    d0,$ff8201
          move.l    oldscr,d0
          lsr.l     #8,d0
          move.b    d0,$ff8207
          lsr.l     #8,d0
          move.b    d0,$ff8205
          andi.b    #$fe,isra
          movem.l   savereg,d0/a0
          rte       
          .BSS 
savereg:  .DS.l 10
oldscr:   .DS.l 1
newscr:   .DS.l 1

          .END 


