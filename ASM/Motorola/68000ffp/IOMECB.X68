* MECB I/O
*   Taken from the Tiny BASIC Interpreter by Gordon Brandly
*   The CHARIN routine is made complicated because I wanted
*     it to emulate the EASy68K emulator more closely.

* DISPLAY CHARACTER IN D0

CHAROUT   BTST      #1,$010040            ;READY?
          BEQ       CHAROUT               ;->NO
          MOVE.B    D0,$010042            ;SEND CHARACTER
          RTS

* READ CHARACTER INTO D0

CHARIN    BTST      #0,$010040            ;READY?
          BEQ       CHARIN                ;->NO
          MOVE.B    $010042,D0            ;GET CHARACTER
          AND.B     #$7F,D0               ;CLEAR HIGH BIT
          BSR       CHAROUT               ;ECHO TO OUTPUT
          CMP.B     #13,D0                ;CARRIAGE RETURN?
          BNE.S     CHARIN2               ;->NO
          MOVE.B    #10,D0                ;YES, SEND LINE FEED
          BSR       CHAROUT
          MOVE.B    #13,D0                ;RESTORE CARRIAGE RETURN
CHARIN2   RTS

* HALT - RETURN TO TUTOR

HALT      MOVE.W    #228,D7
          TRAP      #14
          NOP

