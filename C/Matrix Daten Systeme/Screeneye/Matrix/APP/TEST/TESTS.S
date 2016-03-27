* Object File "test.o"

			.import	printf
			.export	main

Kloops	= 2000			
          .TEXT   

          .MODULE GLOBAL

main:
T000000:   MOVEM.L   D3-D7,-(A7)
T000004:   LEA.L     D000000,A0
T00000A:   JSR       printf

		   MOVE.L    #Kloops,D7
T000010:   MOVE.L    #1000,D3

T00001A:   MULS      #$098E,D6

		   DBRA		 D3,T00001A
		   DBRA		 D7,T000010



T000028:   LEA.L     D000000+$0000000B,A0
T00002E:   JSR       printf

		   MOVE.L    #Kloops,D7
l2:			MOVE.L    #1000,D3

l21:	   EXT.L     D0
T000040:   MOVE.L    D0,D6
T000042:   LSL.L     #3,D6
T000044:   ADD.L     D0,D6
T000046:   ADD.L     D6,D6
T000048:   ADD.L     D0,D6
T00004A:   LSL.L     #3,D6
T00004C:   ADD.L     D0,D6
T00004E:   LSL.L     #3,D6
T000050:   SUB.L     D0,D6
T000052:   ADD.L     D6,D6

		   DBRA		 D3,l21
		   DBRA		 D7,l2

T00005C:   LEA.L     D000000+$14,A0
T000062:   JSR       printf

T000068:   MOVEM.L   (A7)+,D3-D7
T00006C:   RTS


          .DATA   

          .MODULE LOCAL

D000000:   .DC.W   $1B45, $7374, $6172, $7420, $310A, $0073, $7461, $7274
D000010:   .DC.W   $2032, $0A00, $656E, $640A, $0000


          .END
