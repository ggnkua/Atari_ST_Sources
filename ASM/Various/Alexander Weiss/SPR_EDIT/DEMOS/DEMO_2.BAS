10    dim sp%(243):closew 1:closew 0:closew 2:clearw 3
20    for x=0 to 179:read sp%(x):next
30    sps=0:sps=varptr(sp%(0)):rem  Sprite einschalten
40    spo=0:spo=varptr(sp%(2)):rem  Sprite ausschalten
50    spi=0:spi=varptr(sp%(4)):rem  Sprite invertieren
60    spu=0:spu=varptr(sp%(6)):rem  Sprite hoch
70    spd=0:spd=varptr(sp%(8)):rem  Sprite runter
80    spl=0:spl=varptr(sp%(10)):rem Sprite links
90    spr=0:spr=varptr(sp%(12)):rem Sprite rechts
100   sp%(106)=20:rem    X-Koordinate Werte zwischen 0...75
110   sp%(108)=100:rem   Y-Koordinate Werte zwischen 0...367
120   call sps:for a=0 to 2000:next:call spo
130   for a=0 to 60:call spd:next:for b=0 to 2000:next
140   for a=0 to 60:call spu:next:for b=0 to 2000:next
150   for a=0 to 10:call spr:next:for b=0 to 2000:next
160   for a=0 to 10:call spl:next:for b=0 to 2000:next
170   for a=0 to 41:call spi:for b=0 to 200:next b,a
500   for a=0 to 3000:next:call spo
40000 rem  Maschinenprogramm
40010 data &H6000,&H001A,&H6000,&H0048,&H6000,&H005E,&H6000,&H0072
40020 data &H6000,&H007C,&H6000,&H008A,&H6000,&H0098,&H6100,&H00A6
40030 data &HD4FC,&H0168,&H7003,&H14D9,&H51C8,&HFFFC,&HD2FC,&H004C
40040 data &H51C9,&HFFF2,&H6100,&H008E,&HD4FC,&H00E8,&H7003,&H12DA
40050 data &H51C8,&HFFFC,&HD2FC,&H004C,&H51C9,&HFFF2,&H4E75,&H6100
40060 data &H0074,&HD4FC,&H0164,&H7003,&H12DA,&H51C8,&HFFFC,&HD2FC
40070 data &H004C,&H51C9,&HFFF2,&H4E75,&H6100,&H005A,&H7003,&H0A19
40080 data &H00FF,&H51C8,&HFFFA,&HD2FC,&H004C,&H51C9,&HFFF0,&H4E75
40090 data &H5188,&H61CA,&H5988,&H0468,&H0001,&H00D8,&H608E,&H90FC
40100 data &H000C,&H61BA,&H5988,&H0668,&H0001,&H00D8,&H6000,&HFF7E
40110 data &H90FC,&H0010,&H61A8,&H5988,&H0468,&H0001,&H00D4,&H6000
40120 data &HFF6C,&H90FC,&H0014,&H6196,&H5988,&H0668,&H0001,&H00D4
40130 data &H6000,&HFF5A,&H2F08,&H3F3C,&H0002,&H4E4E,&H548F,&H205F
40140 data &H2240,&HD2FC,&H0000,&H303C,&H0000,&HC0FC,&H0050,&HD2C0
40150 data &H2448,&H323C,&H001F,&H4E75
50000 rem spritedaten
50010 data &HFFFF,&HFFFE,&H8000,&H0003,&H8000,&H0003,&H8000,&H0003
50020 data &H8300,&H0003,&H8360,&H0003,&H87F0,&H0003,&H8FF0,&H0003
50030 data &H9F60,&H0003,&H9F80,&H0003,&H83E0,&H0383,&H83F0,&H0E43
50040 data &H87F8,&H1C23,&H8FFC,&H3803,&H8BFE,&H7003,&H82FE,&HE003
50050 data &H80FF,&HC003,&H803F,&H8003,&H81EF,&H0003,&H801C,&H0003
50060 data &H8078,&H0003,&H8000,&H0003,&H8000,&H0003,&HBB80,&H0003
50070 data &HBF80,&H0003,&HBF9E,&H667B,&HB583,&H66C3,&HB19F,&H6673
50080 data &HB1B3,&H661B,&HB19F,&H3EF3,&H8000,&H0003,&HFFFF,&HFFFF
