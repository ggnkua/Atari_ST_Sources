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

          .DC.w $a00a
          move.l    #farbtab,counter
          move.l    #farbtab,anfang
          movea.l   anfang,a0
          lea.l     tab_da,a2
          lea.l     tab_db,a3
          lea.l     tab_dc,a4
          lea.l     tab_dd,a5
          move.w    #111,d4
start:    move.w    (a2)+,d0
          move.w    (a3)+,d1
          move.w    (a4)+,d2
          move.w    (a5)+,d3
          bsr       sch1
          dbf       d4,start

          pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
          movem.l   $ff8240,d0-d7
          movem.l   d0-d7,oldpal
          move.w    #$0000,$ff8240
supinit:  move.l    vbivec,oldvbi+2
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
          clr.w     -(sp)
          trap      #1
mkb:      move.w    #$2500,sr
oldmkb:   jmp       $ffffffff
vbi:      movem.l   d0/a0,savereg
          move.b    #0,tbcr
          movea.l   counter,a0
          move.w    nr,d0
          cmpi.w    #111,d0
          bne       weiter
          move.w    #0,nr
          movea.l   anfang,a0
weiter:   move.w    colind0,d0
          move.w    d0,colind0a
          move.w    0(a0,d0.w),color_2
          move.w    0(a0,d0.w),nextcol0
          lea.l     400(a0),a0
          move.l    a0,counter
          addi.w    #1,nr
          move.b    #zeilen,tbdr
          move.b    #8,tbcr
          movem.l   savereg,d0/a0
oldvbi:   jmp       $ffffffff
hbi:      move.w    nextcol0,color_2
          movem.l   d0/a0,savereg
          movea.l   counter,a0
          move.w    colind0a,d0
          addq.w    #2,d0
          andi.w    #1023,d0
          move.w    d0,colind0a
          move.w    0(a0,d0.w),nextcol0
          andi.b    #$fe,isra
          movem.l   savereg,d0/a0
          rte       
sch1:     move.w    #%0000000000000000,(a0)+
          dbf       d0,sch1
          move.w    #%0000000000000000,(a0)+
          move.w    #%0000000100000000,(a0)+
          move.w    #%0000001000000000,(a0)+
          move.w    #%0000001100000000,(a0)+
          move.w    #%0000010000000000,(a0)+
          move.w    #%0000010100000000,(a0)+
          move.w    #%0000011000000000,(a0)+
          move.w    #%0000011100000000,(a0)+
          move.w    #%0000011100000000,(a0)+
          move.w    #%0000011000000000,(a0)+
          move.w    #%0000010100000000,(a0)+
          move.w    #%0000010000000000,(a0)+
          move.w    #%0000001100000000,(a0)+
          move.w    #%0000001000000000,(a0)+
          move.w    #%0000000100000000,(a0)+
          move.w    #%0000000000000000,(a0)+
sch2:     move.w    #%0000000000000000,(a0)+
          dbf       d1,sch2
          move.w    #%0000000000000000,(a0)+
          move.w    #%0000000000010000,(a0)+
          move.w    #%0000000000100000,(a0)+
          move.w    #%0000000000110000,(a0)+
          move.w    #%0000000001000000,(a0)+
          move.w    #%0000000001010000,(a0)+
          move.w    #%0000000001100000,(a0)+
          move.w    #%0000000001110000,(a0)+
          move.w    #%0000000001110000,(a0)+
          move.w    #%0000000001100000,(a0)+
          move.w    #%0000000001010000,(a0)+
          move.w    #%0000000001000000,(a0)+
          move.w    #%0000000000110000,(a0)+
          move.w    #%0000000000100000,(a0)+
          move.w    #%0000000000010000,(a0)+
          move.w    #%0000000000000000,(a0)+
sch3:     move.w    #%0000000000000000,(a0)+
          dbf       d2,sch3
          move.w    #%0000000000000000,(a0)+
          move.w    #%0000000000000001,(a0)+
          move.w    #%0000000000000010,(a0)+
          move.w    #%0000000000000011,(a0)+
          move.w    #%0000000000000100,(a0)+
          move.w    #%0000000000000101,(a0)+
          move.w    #%0000000000000110,(a0)+
          move.w    #%0000000000000111,(a0)+
          move.w    #%0000000000000111,(a0)+
          move.w    #%0000000000000110,(a0)+
          move.w    #%0000000000000101,(a0)+
          move.w    #%0000000000000100,(a0)+
          move.w    #%0000000000000011,(a0)+
          move.w    #%0000000000000010,(a0)+
          move.w    #%0000000000000001,(a0)+
          move.w    #%0000000000000000,(a0)+
sch4:     move.w    #%0000000000000000,(a0)+
          dbf       d3,sch4
          rts       

          .EVEN 
          .DATA 
colind0:  .DC.w 0
colind2:  .DC.w 0
colind0a: .DC.w 0
colind2a: .DC.w 0
nextcol0: .DC.w 0
nextcol2: .DC.w 0
nr:       .DC.w 0
tab_da:   .DC.w 9,10,11,12,13,14,15,16,17,18,19,20,21,22
          .DC.w 23,24,25,26,27,28,29,30,31,32,33,34,35,36
          .DC.w 37,38,39,40,41,42,43,44,45,46,47,48,49,50
          .DC.w 51,52,53,54,55,56,57,58,59,60,61,62,63,64,65
          .DC.w 65,64,63,62,61,60,59,58,57,56,55,54,53,52,51
          .DC.w 50,49,48,47,46,45,44,43,42,41,40,39,38,37
          .DC.w 36,35,34,33,32,31,30,29,28,27,26,25,24,23
          .DC.w 22,21,20,19,18,17,16,15,14,13,12,11,10,9

tab_db:   .DC.w 65,64,63,62,61,60,59,58,57,56,55,54,53,52,51
          .DC.w 50,49,48,47,46,45,44,43,42,41,40,39,38,37
          .DC.w 36,35,34,33,32,31,30,29,28,27,26,25,24,23
          .DC.w 22,21,20,19,18,17,16,15,14,13,12,11,10,9
          .DC.w 9,10,11,12,13,14,15,16,17,18,19,20,21,22
          .DC.w 23,24,25,26,27,28,29,30,31,32,33,34,35,36
          .DC.w 37,38,39,40,41,42,43,44,45,46,47,48,49,50
          .DC.w 51,52,53,54,55,56,57,58,59,60,61,62,63,64,65

tab_dc:   .DC.w 65,64,63,62,61,60,59,58,57,56,55,54,53,52,51
          .DC.w 50,49,48,47,46,45,44,43,42,41,40,39,38,37
          .DC.w 36,35,34,33,32,31,30,29,28,27,26,25,24,23
          .DC.w 22,21,20,19,18,17,16,15,14,13,12,11,10,9
          .DC.w 9,10,11,12,13,14,15,16,17,18,19,20,21,22
          .DC.w 23,24,25,26,27,28,29,30,31,32,33,34,35,36
          .DC.w 37,38,39,40,41,42,43,44,45,46,47,48,49,50
          .DC.w 51,52,53,54,55,56,57,58,59,60,61,62,63,64,65

tab_dd:   .DC.w 9,10,11,12,13,14,15,16,17,18,19,20,21,22
          .DC.w 23,24,25,26,27,28,29,30,31,32,33,34,35,36
          .DC.w 37,38,39,40,41,42,43,44,45,46,47,48,49,50
          .DC.w 51,52,53,54,55,56,57,58,59,60,61,62,63,64,65
          .DC.w 65,64,63,62,61,60,59,58,57,56,55,54,53,52,51
          .DC.w 50,49,48,47,46,45,44,43,42,41,40,39,38,37
          .DC.w 36,35,34,33,32,31,30,29,28,27,26,25,24,23
          .DC.w 22,21,20,19,18,17,16,15,14,13,12,11,10,9

          .BSS 
savereg:  .DS.l 4
farbtab:  .DS.w 80000
anfang:   .DS.l 1
counter:  .DS.l 1
ssp:      .DS.l 1
oldpal:   .DS.w 16
          .END 


