;*****************************************************************************;
;   CST source file -- copyright 1986 Tom Bajoras
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 XREF _main

 bra  skip    ; skip copyright notice
 dc.b  "Copyright 1986 Tom Bajoras"
skip:
 move.l  4(a7),a5   ; basepage address
 move.l  $c(a5),d0     ; tsize
 add.l   $14(a5),d0    ; dsize
 add.l   $1c(a5),d0    ; bsize
 add.l   #$100,d0   ; sizeof(basepage)
 move.l  d0,-(a7)
 move.l  a5,-(a7)
 clr.w   -(a7)
 move.w  #$4a,-(a7)
 trap #1      ; shrink(0,basepage,top)
 add.l   #12,a7
 jsr  _main      ; branch and link to program

 clr.w   -(a7)
 trap #1      ; terminate, return to GEM desktop

 dc.b  "This message can be changed to anything."
