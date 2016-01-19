;
; Ooh Crikey Wot A Scorcher Relocator
;
;

BEGIN:            JMP       START

DEMO              INCBIN    'E:\MY_SOCKS.DAT'
D_END             EVEN


START:            CLR.L     -(A7) 
                  MOVE.W    #$20,-(A7) 	;SUPER
                  TRAP      #1
                  ADDQ.L    #6,A7 

                  PEA       TEXT(PC)
                  MOVE.W    #9,-(A7) 	;CCONWS 
                  TRAP      #1
                  ADDQ.L    #6,A7 

                  MOVE      #$2700,SR 
                  LEA       DEMO,A0
                  LEA       $3000.L,A1
                  MOVE.W    #(D_END-DEMO)/8,D0 
RELOCATE:         MOVE.L    (A0)+,(A1)+ 
                  DBF       D0,RELOCATE 

KEY_LOOP:         NOP 
                  NOP 
                  NOP 
                  CMPI.B    #$39,$FFFFFC02.W
                  BNE       KEY_LOOP

                  JMP       $301C	;  Run the Demo

TEXT:             DC.B      27,'E',27,'Y  EGB of Sub Humans In Turkey',13,10
                  DC.B      'presents you... TLB',39,'s Hidden',13,10 
                  DC.B      'screen. The ULM screen!!',13,10
                  DC.B      13,10 
                  DC.B      'This screen is exclusive to the',13,10 
                  DC.B      'Inner Circle bulletin board!!',13,10 
                  DC.B      '(HI master)',13,10 
                  DC.B      13,10 
                  DC.B      '   CMP.B #$39,$FFFFFC02.w',0 
ZUEND: END
