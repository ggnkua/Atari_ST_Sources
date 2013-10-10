(*$c-*)
module berrtest;

FROM SYSTEM IMPORT ASSEMBLER;

begin
  ASSEMBLER
        illegal
        move.l  $4f2,a0
        move.w  $2000(a0),d0
        addq    #1,d0
        move.w  d0,$2000(a0)
        move.l  $ff8600,d0
        move.l  $ffff8600,d0
        move.l  $fffA00,d0
        move.l  $fffffA00,d0
        clr     -(a7)
        trap    #1
  end
end berrtest.
