DISPOBJ  Object file browser                Borland Intl. Scotts Valley
Copyright (C) 1990                          All Rights reserved
Version 1.00

* Object File "test.o"


          .TEXT   

          .MODULE GLOBAL

p:
T000000:   MOVEM.L   D3-D5,-(A7)
T000004:   MOVE.W    D3,D5
T000006:   MULS      #$098E,D5
T00000A:   EXT.L     D5
T00000C:   ADD.L     D4,D5
T00000E:   JSR       f
T000014:   MOVE.W    D3,D0
T000016:   EXT.L     D0
T000018:   MOVE.L    D0,D5
T00001A:   LSL.L     #3,D5
T00001C:   ADD.L     D0,D5
T00001E:   ADD.L     D5,D5
T000020:   ADD.L     D0,D5
T000022:   LSL.L     #3,D5
T000024:   ADD.L     D0,D5
T000026:   LSL.L     #3,D5
T000028:   SUB.L     D0,D5
T00002A:   ADD.L     D5,D5
T00002C:   ADD.L     D4,D5
T00002E:   JSR       f
T000034:   MOVE.W    D3,D0
T000036:   EXT.L     D0
T000038:   MOVE.L    D0,D5
T00003A:   LSL.L     #3,D5
T00003C:   ADD.L     D0,D5
T00003E:   ADD.L     D5,D5
T000040:   ADD.L     D0,D5
T000042:   LSL.L     #3,D5
T000044:   ADD.L     D0,D5
T000046:   LSL.L     #3,D5
T000048:   SUB.L     D0,D5
T00004A:   ADD.L     D5,D5
T00004C:   ADD.L     D4,D5
T00004E:   JSR       f
T000054:   MOVEM.L   (A7)+,D3-D5
T000058:   RTS


          .END
