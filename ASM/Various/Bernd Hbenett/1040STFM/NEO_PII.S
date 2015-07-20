super     equ 32
logbase   equ 3
vsync     equ 37
cnecin    equ 8

          .DC.w $a00a
          pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
          movem.l   $ff8240,d0-d7
          movem.l   d0-d7,oldpal
          move.b    $ff8260,res
          move.b    $ff820a,freq
          move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          move.l    d0,scr
          move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          move.b    #0,$ff8260
          move.b    #2,$ff820a
          movem.l   farbtab,d0-d7
          movem.l   d0-d7,$ffff8240
          movea.l   scr,a0
          move.w    #13,d2
loooop:   movea.l   #daten,a1
          move.w    #15,d1
looop:    move.w    #19,d0
loop:     move.l    0(a1),(a0)+
          move.l    4(a1),(a0)+
          dbf       d0,loop
          adda.l    #8,a1
          dbf       d1,looop
          dbf       d2,loooop
wait:     move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          movem.l   oldpal,d0-d7
          movem.l   d0-d7,$ff8240
          move.b    freq,$ff820a
          move.b    res,$ff8260
          move.l    ssp,-(sp)
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          clr.w     -(sp)
          trap      #1

          .DATA 
farbtab:  .DC.w $0000,$0700,$0730,$0750,$0770,$0470,$0070,$0075
          .DC.w $0077,$0057,$0027,$0007,$0507,$0707,$0704,$0777
daten:    .DC.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
          .DC.w $3ffc,$0000,$0000,$0000,$2004,$1ff8,$0000,$0000
          .DC.w $2ff4,$1ff8,$0000,$0000,$2814,$1818,$07e0,$0000
          .DC.w $2bd4,$1818,$07e0,$0000,$2a54,$1998,$07e0,$0000
          .DC.w $2a54,$1998,$07e0,$0000,$2bd4,$1818,$07e0,$0000
          .DC.w $2814,$1818,$07e0,$0000,$2ff4,$1ff8,$0000,$0000
          .DC.w $2004,$1ff8,$0000,$0000,$3ffc,$0000,$0000,$0000
          .DC.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
          .BSS 
ssp:      .DS.l 1
scr:      .DS.l 1
oldpal:   .DS.w 16
res:      .DS.b 1
freq:     .DS.b 1
          .END 


