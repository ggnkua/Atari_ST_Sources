;Some knowledge of 68000 has been assumed before trying to use this code.
;The main data is loader to $80200 then you need to trace though and follow
;the instructions later in the file.

;Basically, it involves loading the main code into memory then you have to
;write down the call paramaters passed before the track loader is called.
;When loaded to $80000 the call is JSR $81276 for disk1 and JSR $8804C.
;So just search for this call and write the values down in D0 D1 D2 then
;use the code accordingly.

;Good luck.

DEST=$80000
	
	OPT	O+,OW-
	
	
	PEA	0
	MOVE.W	#32,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7



L0000:MOVE      #$2700,SR 
      LEA       $78000,A7 
      LEA       L0002(PC),A0
      LEA       $77000,A1 
      MOVE.W    #$200,D0

L0001:MOVE.B    (A0)+,(A1)+ 
      DBF       D0,L0001
      JMP       $77000

L0002
;      LEA       $FFFF8240,A0 
;      MOVEQ     #15,D0

;L0003:CLR.W     (A0)+ 
;      DBF       D0,L0003

      LEA       $200+DEST,A0 	;LOAD ADDRESS
      MOVEA.L   A0,A6 
      LEA       $78000,A1 
      MOVE.B    #$E,-$7800
      MOVE.B    #5,-$77FE 

      MOVE.W    #$80,-$79FA 
      BSR       L000D 
      MOVE.W    #3,-$79FC 
      BSR       L000C 

      MOVEQ     #7,D6 		;LOAD 7 TRACKS

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

;      MOVE.W    #$637,$FFFF8242

      MOVE.L    #$294+DEST,D0
      MOVE.L    D0,$288+DEST


	MOVE.W	#$4E71,D1	;NOP
	MOVE.L	#$90404E71,D2	;SUB.W D0,D0 -  NOP

ANY_WEAPON
	MOVE.W	D1,$8B78+DEST

INF_LIVES	MOVE.W	D1,$37D6+DEST

CART_CHECK	
	MOVE.W	D1,$1428+DEST
	MOVE.W	D1,$1430+DEST
	MOVE.W	D1,$14B8+DEST
	MOVE.W	D1,$14C0+DEST
	MOVE.W	D1,$190E+DEST
	MOVE.W	D1,$1916+DEST

CHECK_SUM
	MOVE.L	D2,$6AD8+DEST
	MOVE.L	D2,$7922+DEST
	MOVE.L	D2,$8038+DEST

;========== Start of the file generator ============

	LEA	$80288,A7
	MOVE.W	#$2700,SR
BACK	CLR.L	D0
	CLR.L	D1
	CLR.L	D2
	LEA	$90000,A0	

;========================================================
;Put your values in here in D0 D1 D2 that you have written down
;that are stored before the call to the track loader (offset at $1276 and $804C).
;Just do a search for each occurrence of JSR $1276 to get the disk 1 access.
;And search for JSR $804C for the disk 2 access.
;Write down the values for each then put them in DO D1 D2 then call the
;appropriate address (data will be loaded to A0 $90000.
;After you have traced the BSR CALC the file name is under STORE.
;The data start address is $90000
;The file length is calculated by searching for EEEEEEEE from $90000.
:save the file length like this $90000,address of EEEEEEEE




;-- FIll memory from $90000 - $100000 with EEEEEEEE here in Monst

;	JSR	$81276		;DISK 1 LOADER



	BSR	CALC		;Generate file name

;-------- Save the data file here --------------;
;	JSR	$8804C		;DISK 2 LOADER

	BRA	BACK
;-----------------------------------------------;
	MOVE.W	#$777,$FFFF8240
	MOVE.W	#0,$FFFF8246
	
	CLR.W	-(A7)
	TRAP	#1
;----------------------------------------------;	
CALC	MOVEM.L	D0-A6,-(A7)
	LEA	STORE(PC),A1
	MOVE.W	#"  ",(A1)
	MOVE.L	D0,D3		;START TRACK
	MOVE.L	A0,A4		;LOAD ADDRESS
	CLR.L	D4
	CLR.L	D5
	LEA	ASCII(PC),A0
	MOVE.B	D3,D4
	DIVU	#16,D4	
	MOVE.W	D4,D5
	CLR.W	D4
	SWAP	D4
	MOVE.B	(A0,D5.W),(A1)
	MOVE.B	(A0,D4.W),1(A1)
	MOVEM.L	(A7)+,D0-A6
	RTS

STORE	DC.B	"  "
	DC.B	".DAT"
	DC.B	0,0
	EVEN
	
ASCII	DC.B	"0123456789ABCDEF
	
;-----------------------------------------------;

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

	DATA

	BSS
	
