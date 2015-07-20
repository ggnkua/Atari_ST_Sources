;This code was ripped from the loader of BAAL. It relocates the DMA
;loader code to $77000, reads 7 tracks of data to $200 then JMPs to it.
;An exit has been added to avoid the jump for cracking purposes.
;Once the data/main program has been loaded we can then check the code
;for other DMA loaders, protection etc.
;The original game was on 2 non-standard disks which had different
;formats for tracks 0-41 and 41-79 and the only thing that could read or
;copy them was a cartridge called the Happy Copier from Third Coast
;Technologies.

;You will find that there a number of methods to deter would-be hackers in
;the main file.

;First of all there are cartridge checks (3 in all), so if you've got the Ultimate
;Ripper in the slot you'll be OK - but if you've got the later version
;SuperMon then it will be detected as the later version left the normal
;cartridge signature.

	
;Secondly, if you modify the cartridge checks then there is another
;check to see if the code has been tampered with (3 in all) and the
;game hangs up or crashes - so you have to remove these checks as well.

;Examine checks.s for details.


	OPT	O+,OW-		;Optimize code!
	
	
	PEA	0		;Supervisor mode
	MOVE.W	#32,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7

L0000:MOVE      #$2700,SR 	;Relocate DMA loader
      LEA       $78000,A7 
      LEA       L0002(PC),A0
      LEA       $77000,A1 
      MOVE.W    #512,D0
L0001:MOVE.B    (A0)+,(A1)+ 
      DBF       D0,L0001
      JMP       $77000

L0002:LEA       $80200,A0 	;LOAD ADDRESS (normally $200) $80200 is
      MOVEA.L   A0,A6 		;above 1 meg
      LEA       $78000,A1 
      MOVE.B    #$E,-$7800
      MOVE.B    #5,-$77FE 

      MOVE.W    #$80,-$79FA 
      BSR       L000D 
      MOVE.W    #3,-$79FC 
      BSR       L000C 

      	MOVEQ     #7,D6 	;TRACKS TO LOAD
	
L0004:MOVE.W    #$80,-$79FA 
      BSR       L000D 
      MOVE.W    #$53,-$79FC 
      BSR       L000C 
A     MOVE.L    A1,D0 

L0005:MOVE.B    D0,-$79F3 
      LSR.W     #8,D0 
      MOVE.B    D0,-$79F5 
      SWAP      D0
      MOVE.B    D0,-$79F7 
      MOVE.W    #$90,-$79FA 
      MOVE.W    #$190,-$79FA
      MOVE.W    #$90,-$79FA 
      BSR       L000D 
      MOVE.W    #$E,-$79FC
      BSR       L000D 
      MOVE.W    #$80,-$79FA 
      BSR       L000D 
      MOVE.W    #$E0,-$79FC 
      BSR       L000C 
      MOVEA.L   A1,A2 
      MOVEQ     #1,D1 		;(0)
      MOVE.B    #-$5F,D1

L0006:CMP.B     (A2)+,D1
      BNE     L0006 

L0007:CMP.B     (A2)+,D1
      BEQ     L0007 
      MOVE.B    -1(A2),D1 

L0008:MOVE.B    (A2)+,D2
      MOVE.W    #$1FC,D3

L0009:MOVE.B    (A2)+,D0
      CMP.B     #-$C,D0 
      BNE     L000B 
      ADD.B     (A2)+,D0
      EOR.B     D2,D0 
      MOVE.B    D0,(A0)+
      SUBQ.W    #2,D3 
      BPL     L0009 

L000A:ADDQ.L    #4,A2 
      DBF       D1,L0008
      DBF       D6,L0004

;     JMP 	(A6)	;Start game

EXIT	CLR.W	-(A7)	;The JMP to the code would normally be here
	TRAP	#1	;but just exit to test it.


L000B:EOR.B     D2,D0 
      MOVE.B    D0,(A0)+
      DBF       D3,L0009
      BRA       L000A 

L000C:NOP 
      NOP 
      NOP 
      NOP 
      NOP 
      NOP 
      NOP 
      BTST      #5,-$5FF
      BNE     L000C 
      RTS 

L000D:MOVEQ     #$24,D7 

L000E:DBF       D7,L000E
      RTS 
	
	EVEN
	
	BSS

BUFFER	DS.B	40000	;Just a bit of extra space!