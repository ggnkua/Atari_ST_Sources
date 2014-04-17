 Address Objectcode  Line    Sourcetext Assembly listing for RELOCATE.S                                         

000000 :                1   ; Program Name: RELOCATE.S
000000 :                2
000000 :203900000022    3   move.l    up_1, d0
000006 :203900000026    4   move.l    up_2, d0
00000C :203CFFFFFFFC    5   move.l    #-4, d0
000012 :203CFFFFFFFC    6   move.l    #up_1-up_2,d0
000018 :2039FFFFFFFC    7   move.l    up_1-up_2, d0
00001E :                8   data
00001E :00000022        9  pointer:   dc.l  up_1
000022 :00000005       10  up_1:      dc.l  5
000026 :00000003       11  up_2:      dc.l  3
00002A :               12   end
