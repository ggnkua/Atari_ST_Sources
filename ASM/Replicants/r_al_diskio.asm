
	;----------------------------------------------------------------------------------------------------
	; That code is the disk IO routine, containing ciphering code and disk handler.
	; The running code is located at $600 adress (not $16c as in that disassembly listing)
	;----------------------------------------------------------------------------------------------------

diskIOInstall:
$00016C:21C2 0694                     MOVE.L  D2,$694.W 		; D2 contains 32bits key (derived from ascci password somewhere else in bootsector)
$000170:2078 0472                     MOVEA.L $472.W,A0
$000174:21E8 0022 0622                MOVE.L  $22(A0),$622.W 		; Here is the "not very clean" stuff !! Path instruction (path $12345678 addr)
$00017A:21F8 0476 0658                MOVE.L  $476.W,$658.W 		; path JUMP
$000180:21FC 0000 061E 0476           MOVE.L  #$61E,$476.W 		; New Disk IO handler
$000188:4E75                          RTS

newDiskIOHandler:
$00018A:7600                          MOVEQ   #$0,D3
$00018C:267C 1234 5678                MOVEA.L #$12345678,A3 		; addr 12345678 was patched by the move.l $22(a0),$622.w at init period
$000192:362F 000E                     MOVE.W  $E(A7),D3
$000196:EB43                          ASL.W   #5,D3
$000198:D7C3                          ADDA.L  D3,A3
$00019A:0C6B 414C 001C                CMPI.W  #$414C,$1C(A3) 		; CMP with "AL", wich is located in bootsector (to check if it's an encrypted disk). Don't find anything in documetation related to $1c(a3) and $22(a0) at init period
$0001A0:6620                          BNE.S   $1C2
$0001A2:4A6F 000C                     TST.W   $C(A7)
$0001A6:671A                          BEQ.S   $1C2
$0001A8:082F 0000 0005                BTST    #$0,$5(A7)
$0001AE:670A                          BEQ.S   $1BA
$0001B0:362F 000A                     MOVE.W  $A(A7),D3
$0001B4:266F 0006                     MOVEA.L $6(A7),A3
$0001B8:611A                          BSR.S   $1D4
$0001BA:2C57                          MOVEA.L (A7),A6
$0001BC:2EBC 0000 065C                MOVE.L  #$65C,(A7)
$0001C2:4EF9 1234 5678                JMP     $12345678
$0001C8:362F 0006                     MOVE.W  $6(A7),D3
$0001CC:266F 0002                     MOVEA.L $2(A7),A3
$0001D0:6102                          BSR.S   $1D4
$0001D2:4ED6                          JMP     (A6)
$0001D4:2A3A 002A                     MOVE.L  $200(PC),D5
$0001D8:7C7F                          MOVEQ   #$7F,D6
$0001DA:E38D                          LSL.L   #1,D5
$0001DC:0805 0001                     BTST    #$1,D5
$0001E0:6708                          BEQ.S   $1EA
$0001E2:0805 0015                     BTST    #$15,D5
$0001E6:6708                          BEQ.S   $1F0
$0001E8:6008                          BRA.S   $1F2
$0001EA:0805 0015                     BTST    #$15,D5
$0001EE:6702                          BEQ.S   $1F2
$0001F0:5285                          ADDQ.L  #1,D5
$0001F2:DA86                          ADD.L   D6,D5
$0001F4:BB9B                          EOR.L   D5,(A3)+
$0001F6:51CE FFE2                     DBF     D6,$1DA
$0001FA:5343                          SUBQ.W  #1,D3
$0001FC:66D6                          BNE.S   $1D4
$0001FE:4E75                          RTS
