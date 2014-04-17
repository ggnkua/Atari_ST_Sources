 Address Objectcode   Line    Sourcetext Assembly listing for RELATIVE.S                                         

000000 :                 1   ; Program Name: RELATIVE.S
000000 :                 2
000000 :203A001A         3   move.l    up_1, d0
000004 :203A001A         4   move.l    up_2, d0
000008 :203CFFFFFFFC     5   move.l    #-4, d0
00000E :                 6
00000E :203CFFFFFFFC     7   move.l    #up_1-up_2,d0
000014 :203AFFE6         8   move.l    up_1-up_2, d0
000018 :                 9   data
000018 :0000001C        10  pointer:   dc.l  up_1
00001C :00000005        11  up_1:      dc.l  5
000020 :00000003        12  up_2:      dc.l  3
000024 :                13   end
