;
;
; Frontend for depacking a hacked file to an address
;
;

Begin:            PEA       0.L 
                  MOVE.W    #$20,-(A7) 	;SUPER
                  TRAP      #1
                  ADDQ.L    #6,A7 

                  LEA       L0003(PC),A0	;
                  LEA       $80000,A1 
                  MOVE.L    #(end_pack-L0003),D2 
R_LOOP:           MOVE.B    (A0)+,(A1)+ 
                  DBF       D2,R_LOOP 
                  PEA       TEXT
                  MOVE.W    #9,-(A7) 	;CCONWS 
                  TRAP      #1
                  ADDQ.L    #6,A7 
                  JMP       $80000
TEXT:             DC.B      27,69 
                  DC.B      ' KING H. brings you : ',10,13
                  DC.B      10,13 
                  DC.B      ' ETERNAL SOUND DEMO II ',10,13 
                  DC.B      10,13 
                  DC.B      '     -FILE VERSION- ',10,13
                  DC.B      10,13 
                  DC.B      ' Press SPACE when screen turns ',10,13 
                  DC.B      '     deep green colour !!! ',10,13 
                  DC.B      10,13 
                  DC.B      ' Now depacking :',27,'p The Intro Screen ',27,'q',10,13
                  DC.B      10,13 
                  DC.B      '  Hacked,filed & re-packed by ',10,13
                  DC.B      ' TGA or KING H. or The COOLEST ',0,0 
L0003:            LEA       PACKDATA(PC),A0 
                  LEA       $30000,A1 
                  JSR       D_PAK 
                  MOVE.W    #$30,$FFFF8240.W
K_LOOP:           CMPI.B    #$39,$FFFFFC02.W
                  BNE.B     K_LOOP
                  JMP       $30000

PACKDATA		dc.l	1
end_pack	even
	ds.l	10
D_PAK	include	'e:\packers\atomic\atomic.3_5\depack*.s'
