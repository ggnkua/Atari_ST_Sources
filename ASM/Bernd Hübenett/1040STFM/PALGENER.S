cnecin    equ 8
cconws    equ 9
logbase   equ 3
super     equ 32
vsync     equ 37

start:    pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
          movem.l   farben,d0-d2
          movem.l   d0-d3,$ff8242
          move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          movea.l   d0,a0
          move.l    #7999,d0
erase:    move.l    #0,(a0)+
          dbf       d0,erase
          move.w    #$0000,d6
loop:     move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          move.w    d6,$ff8240

          movea.l   #string,a0
          bsr       ausgabe

          movea.l   #blau,a0
          bsr       ausgabe
          move.w    $ff8240,d0
          andi.l    #%00000000000000000000000000000111,d0
          bsr       textout

          movea.l   #gruen,a0
          bsr       ausgabe
          move.w    $ff8240,d0
          lsr.w     #4,d0
          andi.l    #%00000000000000000000000000000111,d0
          bsr       textout

          movea.l   #rot,a0
          bsr       ausgabe
          move.w    $ff8240,d0
          lsr.w     #8,d0
          andi.l    #%00000000000000000000000000000111,d0
          bsr       textout

          addi.w    #1,d6
          bra       loop

ausgabe:  move.l    a0,-(sp)
          move.w    #cconws,-(sp)
          trap      #1
          addq.l    #6,sp
          rts       

textout:  move.w    #12,d3
          move.l    d0,d1
h_loop:   move.l    d1,d2
          lsr.l     d3,d2
          andi.w    #$f,d2
          lea.l     ziffern,a0
          move.b    0(a0,d2.w),d2
          move.w    d2,-(sp)
          move.w    #2,-(sp)
          trap      #1
          addq.l    #4,sp
          subq.w    #4,d3
          bpl       h_loop
          rts       

          .DATA 
farben:   .DC.w $777,$777,$777,$777,$777,$777
ziffern:  .DC.b "0123456789ABCDEF"
          .EVEN 
string:   .DC.b 27,"Y",32,42,"Farbregister 0 : ",0
blau:     .DC.b 27,"Y",35,42,"Blau Anteil  : ",0
gruen:    .DC.b 27,"Y",36,42,"GrÅn Anteil  : ",0
rot:      .DC.b 27,"Y",37,42,"Rot  Anteil  : ",0
          .EVEN 
          .BSS 
ssp:      .DS.l 1
          .END 


