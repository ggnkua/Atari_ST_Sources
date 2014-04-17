 Address Objectcode   Line    Sourcetext Assembly listing for COMBO.PRG                                          

000000 :                 1   ; Program Name: COMBO.S
000000 :                 2
000000 :203A001C         3   move.l    up_1(pc), d0
000004 :203A001C         4   move.l    up_2(pc), d0
000008 :203CFFFFFFFC     5   move.l    #-4, d0
00000E :                 6
00000E :203CFFFFFFFC     7   move.l    #up_1-up_2,d0  ; (pc) can't be used with the labels here.
000014 :2039FFFFFFFC     8   move.l    up_1-up_2, d0  ; (pc) can't be used with the labels here.
00001A :                 9   data
00001A :0000001E        10  pointer:   dc.l  up_1
00001E :00000005        11  up_1:      dc.l  5
000022 :00000003        12  up_2:      dc.l  3
000026 :                13   end
