          ;
          ;  NEOchrome cut buffer contents (left justified):
          ;
          ;    pixels/scanline    = $0050 (bytes/scanline: $0028)
          ;  # scanlines (height) = $005C
          ;
          ;  Hardware color pallet  (color 0 to 15):
          ;
          ;      $0000,$FF88,$0710,$0720,$0730,$0740,$0750,$0760
          ;      $0770,$0201,$0027,$0007,$0507,$0707,$0704,$0777
          ;
          ;
cnecin    equ 8
logbase   equ 3
super     equ 32
vsync     equ 37

start:    pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
          move.b    $ff8260,res
          move.b    $ff820a,mode
          movem.l   $ff8240,d0-d7
          movem.l   d0-d7,farbtab

          move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          move.b    #0,$ff8260
          move.b    #2,$ff820a
          movem.l   color,d0-d7
          movem.l   d0-d7,$ff8240

          move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          movea.l   d0,a0
          move.w    #7999,d1
clear:    move.l    #0,(a0)+
          dbf       d1,clear
          movea.l   d0,a0
          movea.l   #rahmen,a1
          move.w    #91,d2
looop:    move.w    #19,d1
loop:     move.w    (a1)+,(a0)+
          dbf       d1,loop
          adda.l    #120,a0
          dbf       d2,looop

          move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          movem.l   farbtab,d0-d7
          movem.l   d0-d7,$ff8240
          move.w    #vsync,-(sp)
          trap      #14
          addq.l    #2,sp
          move.b    res,$ff8260
          move.b    mode,$ff820a
          clr.w     -(sp)
          trap      #1


          .DATA 
color:    .DC.w $0000,$ff88,$0710,$0720,$0730,$0740,$0750,$0760
          .DC.w $0770,$0201,$0027,$0007,$0507,$0707,$0704,$0777
rahmen:   .DC.w $ffff,$0000,$0000,$0000,$ffff,$0000,$0000,$0000
          .DC.w $ffff,$0000,$0000,$0000,$ffff,$0000,$0000,$0000
          .DC.w $ffff,$0000,$0000,$0000,$8000,$7fff,$0000,$0000
          .DC.w $0000,$ffff,$0000,$0000,$0000,$ffff,$0000,$0000
          .DC.w $0000,$ffff,$0000,$0000,$0001,$fffe,$0000,$0000
          .DC.w $bfff,$7fff,$0000,$0000,$ffff,$ffff,$0000,$0000
          .DC.w $ffff,$ffff,$0000,$0000,$ffff,$ffff,$0000,$0000
          .DC.w $fffd,$fffe,$0000,$0000,$a000,$6000,$1fff,$0000
          .DC.w $0000,$0000,$ffff,$0000,$0000,$0000,$ffff,$0000
          .DC.w $0000,$0000,$ffff,$0000,$0005,$0006,$fff8,$0000
          .DC.w $afff,$6000,$1fff,$0000,$ffff,$0000,$ffff,$0000
          .DC.w $ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
          .DC.w $fff5,$0006,$fff8,$0000,$a800,$67ff,$1fff,$0000
          .DC.w $0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff,$0000
          .DC.w $0000,$ffff,$ffff,$0000,$0015,$ffe6,$fff8,$0000
          .DC.w $abff,$67ff,$1fff,$0000,$ffff,$ffff,$ffff,$0000
          .DC.w $ffff,$ffff,$ffff,$0000,$ffff,$ffff,$ffff,$0000
          .DC.w $ffd5,$ffe6,$fff8,$0000,$aa00,$6600,$1e00,$01ff
          .DC.w $0000,$0000,$0000,$ffff,$0000,$0000,$0000,$ffff
          .DC.w $0000,$0000,$0000,$ffff,$0055,$0066,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$66ff,$1e00,$01ff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0055,$ff66,$0078,$ff80,$aa00,$66ff,$1e00,$01ff
          .DC.w $0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
          .DC.w $0000,$ffff,$0000,$ffff,$0055,$ff66,$0078,$ff80
          .DC.w $aa00,$6600,$1e00,$01ff,$0000,$0000,$0000,$ffff
          .DC.w $0000,$0000,$0000,$ffff,$0000,$0000,$0000,$ffff
          .DC.w $0055,$0066,$0078,$ff80,$abff,$67ff,$1fff,$0000
          .DC.w $ffff,$ffff,$ffff,$0000,$ffff,$ffff,$ffff,$0000
          .DC.w $ffff,$ffff,$ffff,$0000,$ffd5,$ffe6,$fff8,$0000
          .DC.w $a800,$67ff,$1fff,$0000,$0000,$ffff,$ffff,$0000
          .DC.w $0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff,$0000
          .DC.w $0015,$ffe6,$fff8,$0000,$afff,$6000,$1fff,$0000
          .DC.w $ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
          .DC.w $ffff,$0000,$ffff,$0000,$fff5,$0006,$fff8,$0000
          .DC.w $a000,$6000,$1fff,$0000,$0000,$0000,$ffff,$0000
          .DC.w $0000,$0000,$ffff,$0000,$0000,$0000,$ffff,$0000
          .DC.w $0005,$0006,$fff8,$0000,$bfff,$7fff,$0000,$0000
          .DC.w $ffff,$ffff,$0000,$0000,$ffff,$ffff,$0000,$0000
          .DC.w $ffff,$ffff,$0000,$0000,$fffd,$fffe,$0000,$0000
          .DC.w $8000,$7fff,$0000,$0000,$0000,$ffff,$0000,$0000
          .DC.w $0000,$ffff,$0000,$0000,$0000,$ffff,$0000,$0000
          .DC.w $0001,$fffe,$0000,$0000,$ffff,$0000,$0000,$0000
          .DC.w $ffff,$0000,$0000,$0000,$ffff,$0000,$0000,$0000
          .DC.w $ffff,$0000,$0000,$0000,$ffff,$0000,$0000,$0000
          .BSS 
ssp:      .DS.l 1
farbtab:  .DS.l 8
oldscr:   .DS.l 1
res:      .DS.b 1
mode:     .DS.b 1

          .END 

