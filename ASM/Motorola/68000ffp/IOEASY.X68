* EASy68K/Teesside I/O

* Display character in D0

CHAROUT   MOVEM.L   D0-D1,-(SP)
          EXG       D0,D1
          MOVEQ     #6,D0
          TRAP      #15
          MOVEM.L   (SP)+,D0-D1
          RTS

* Read character into D0

CHARIN    MOVEM.L   D1,-(SP)
          MOVEQ     #5,D0
          TRAP      #15
          EXG       D1,D0
          MOVEM.L   (SP)+,D1
          RTS

* HALT - return to EASy68K simulator

HALT      MOVEQ     #9,D0
          TRAP      #15
          NOP

