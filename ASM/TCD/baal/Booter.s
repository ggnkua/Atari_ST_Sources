;This code is for training the standard (non-filed) version of BAAL.
;YOU MUST HAVE A COPY OF THE ORIGINAL FIRST!.

;This code replaces the bootsector with code to load the main data,
;remove the cartridge check, checksum checks and also adds a trainer
;for infinite lives and the use of any weapon.
;Do not use on the original game!




	BSR LOAD
	BSR IMMDSK
	MOVE.W #$4C,-(A7)
	TRAP #1

; LOAD BOOT SECTOR
LOAD	MOVE.W #1,-(A7)
	MOVE.W #0,-(A7)
	MOVE.W #0,-(A7)
	MOVE.W #1,-(A7)
	MOVE.W #0,-(A7)
	CLR.L -(A7)
	MOVE.L #DSKBUF,-(A7)
	MOVE.W #8,-(A7)
	TRAP #14
	ADD.L #20,A7
	RTS
; SAVE BOOT SECTOR
SAVE	MOVE.W #1,-(A7)
	MOVE.W #0,-(A7)
	MOVE.W #0,-(A7)
	MOVE.W #1,-(A7)
	MOVE.W #0,-(A7)
	CLR.L -(A7)
	MOVE.L #DSKBUF,-(A7)
	MOVE.W #9,-(A7)
	TRAP #14
	ADD.L #20,A7
	RTS
IMMDSK	LEA ROUT(PC),A0
	LEA EROUT(PC),A1
	LEA DSKBUF(PC),A2
	MOVE.W #$601C,(A2)
	ADD.W #$1E,A2
IM1	MOVE.B (A0)+,(A2)+
	CMP.L A0,A1
	BNE IM1
	MOVE.W #1,-(A7)
	MOVE.W #-1,-(A7)
	MOVE.L #-1,-(A7)
	MOVE.L #DSKBUF,-(A7)
	MOVE.W #18,-(A7)
	TRAP #14
	ADD.L #14,A7
	BSR SAVE
	RTS

;============ Start of bootcode =================;


ROUT	

dest=$200	;game loads here

	OPT	O+,OW-

	PEA	TEX(PC)
	MOVE.W	#9,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	
	
	MOVE.L	#$200+dest,A0
	MOVE.L	$42E,A1
CLEAR	CLR.L	(A0)+
	CMP.L	A1,A0
	BNE	CLEAR
	


L0000:MOVE      #$2700,SR 
      LEA       $78000,A7 
      LEA       L0002(PC),A0
      LEA       $77000,A1 
      MOVE.W    #$200,D0

L0001:MOVE.B    (A0)+,(A1)+ 
      DBF       D0,L0001
      JMP       $77000

L0002:	

      LEA       $FFFF8240,A0 
      MOVEQ     #15,D0
L0003:CLR.W     (A0)+ 
      DBF       D0,L0003

      MOVE.L    #dest,A0 	;LOAD ADDRESS

      MOVEA.L   A0,A6 
      LEA       $78000,A1 
      MOVE.B    #$E,-$7800
      MOVE.B    #5,-$77FE 

      MOVE.W    #$80,-$79FA 
      BSR       L000D 
      MOVE.W    #3,-$79FC 
      BSR       L000C 
      MOVEQ     #7,D6 

L0004:MOVE.W    #$80,-$79FA 
      BSR       L000D 
      MOVE.W    #$53,-$79FC 
      BSR       L000C 
      MOVE.L    A1,D0 

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
      MOVEQ     #0,D1 
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
      MOVE.W    #$637,$FFFF8242
      MOVE.L    #$294+dest,D0
      MOVE.L    D0,$288+dest

;=================== Crack it here ===========================;

	MOVE.W	#$4E71,D1	;NOP
	MOVE.L	#$90404E71,D2	;SUB.W D0,D0 -  NOP

	OPT O-
	
CART_CHECK	
	MOVE.W	D1,$1428+dest
	MOVE.W	D1,$1430+dest
	MOVE.W	D1,$14B8+dest
	MOVE.W	D1,$14C0+dest
	MOVE.W	D1,$190E+dest
	MOVE.W	D1,$1916+dest

ANY_WEAPON
	MOVE.W	D1,$8B78+dest

INF_LIVES	
	MOVE.W	D1,$37D6+dest
	
CHECK_SUM
	MOVE.L	D2,$6AD8+dest
	MOVE.L	D2,$7922+dest
	MOVE.L	D2,$8038+dest

  	JMP       (A6)	;RUN MAIN PROGRAM

;=========== End of crack code========================;



    
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


TEX	DC.B	27,"E"
	DC.B	"BAAL",13,10,10
	DC.B	"TRAINED BY DR.D",13,10,10,10,10
	DC.B	"INFINITE LIVES / ANY WEAPON",0

	DS.B	60


	RTS


EROUT
	EVEN
DSKBUF	DS.B 512
