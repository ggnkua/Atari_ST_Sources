; Das ist das disassemblierte Bootsektor-Programm von HDDRIVER

	TEXT 
Begin:
      BRA.S   L0006 
      DC.B   $90,'ROOTBZ',$82            
      DC.B   $E6,$00			 ; Bytes/Sektor
L0000:DC.B   $08,$02			 ; Sektoren,Startsektoren
L0002:DC.B   $01,$00                     ; Anzahl FATs
      DC.B   $02,$00
L0004:DC.B   $01,$F8,$BF,$F8             ; Gesamtzahl der Sektoren
L0005:DC.B   $18,$00,$00,$00,$00,$00,$02,$00
      DC.W    0,0,0,0                    ; Seiten pro Medium
      DC.B   ')',$10,$9D,'U%NO '
      DC.B   'NAME  ' 
L0006:DC.B   $48,$78,$FF,$FF		 ; PEA     -1.S
      MOVE.W  #$48,-(A7) 	; Wie groû ist der grîûte freie Speicherblock ?
      TRAP    #1
      ADDQ.L  #6,A7 
      MOVE.L  D0,D5 
      MOVE.L  D0,-(A7)
      MOVE.W  #$48,-(A7) 	; Speicher komplett anfordern 
      TRAP    #1
      ADDQ.L  #6,A7 
      TST.L   D0                ; alles gutgegangen ?
      BEQ.S   L000A 		; nein,dann dorthin
      MOVEA.L D0,A4      	; a4,Startadresse des freien Speicherblocks
      MOVEQ   #0,D1 		; ab hier folgt wildes rumgerechne mit obiger Parameter-Liste
      MOVE.B  L0000(PC),D1	; um den startsektor zu ermitteln,wo sich der Treiber befindet
      LSR.W   #1,D1 
      MOVEQ   #0,D2 
      MOVE.B  L0004(PC),D2
      LSL.W   #8,D2 
      MOVE.B  L0002+3(PC),D2
      MOVE.W  L0002(PC),D3
      ROR.W   #8,D3 
      MULU    D1,D3 
      ADD.L   D6,D3 
      MOVE.W  L0005(PC),D6
      ROR.W   #8,D6 
      MULU    D1,D6 
      ADD.L   D6,D6 
      ADD.L   D3,D6   		; startsektor (d6,siehe Parameter fÅr DMAREAD-Aufruf)
      LSR.L   #4,D2 
      ADD.L   D6,D2 
      MOVEA.L D2,A1             ; letzter Sektor
      MOVEM.L D5/D3/D0-D1,-(A7) ; Register retten...(bleiben auf Stack) 
L0007:MOVEQ   #1,D5             ; count (d5)
      MOVEM.L A5/A1,-(A7) 
      JSR     (A3) 		; readroutine vom Rootprg ausfÅhren (DMAREAD)
      MOVEM.L (A7)+,A5/A1 
      TST.W   D0                ; alles ok ?
      BEQ.S   L000C             ; ja,dann dorthin
L0008:ADD.L   D5,D6             ; startsektor+1
      CMP.L   A1,D6             ; letzter Sektor ?
      BCS.S   L0007             ; wenn nein,wiederhole DMAREAD mit nÑ. Sektornummer
L0009:MOVE.W  #$49,-(A7) 	; Speicher wieder freigeben
      TRAP    #1
      LEA     18(A7),A7         ; Stack komplett zurÅckholen (siehe oben)
L000A:JMP     (A5)              ; zur exit-Routine vom Rootprg springen
L000B:DC.B   'HDDRIVER' 
      DC.B   'SYS',$00
L000C:MOVEA.L A4,A0 		; Startadresse des angeforderten Speicherblocks
      MOVEQ   #$F,D1            ; 16 Dir-Eintrage testen (je 32Byte=512Byte)
L000D:MOVEQ   #$A,D0
L000E:MOVE.B  0(A0,D0.W),D3 
      CMP.B   L000B(PC,D0.W),D3 ; test ab Offset $a "HDDRIVER.SYS" im Dir ?
      BEQ.S   L000F             ; wenn korrektes Byte gefunden,dorthin
      LEA     32(A0),A0         ; zum nÑchsten Dir-Eintrag
      DBF     D1,L000D          ; weiterzÑhlen
      BRA.S   L0008             ; nix gefunden...
L000F:DBF     D0,L000E          ; nÑchstes Byte (wird rÅckwÑrts getestet)
      MOVE.L  28(A0),D5         ; Treibername stimmt vollstÑndig Åberein,hurra !
      ROR.W   #8,D5             ; LL ML MH HH -> HH MH ML LL (Intel-MÅll)
      SWAP    D5
      ROR.W   #8,D5 
      DC.W    $DABC,0,$1800     ; ADD.L   #$1800,D5         ; HÑÑÑ ?
      CMP.L   12(A7),D5         ; wahrscheinlich Wert von D0 (Startadresse des Speicherblocks) 
      BHI.S   L0009             ; da war ja wohl nix...
      MOVEA.L A4,A2             ; Pufferadresse
      ADDA.L  12(A7),A4 	
      LEA     -32768(A4),A4 
      MOVE.W  26(A0),D2 
      ROR.W   #8,D2 
      MOVEQ   #-1,D3
L0010:MOVEQ   #0,D5 
      MOVE.B  L0000+1(PC),D5      ; reservierte Startsektoren
      MULU    6(A7),D5          ; count (d5)
      MOVE.W  D2,D6 
      SUBQ.W  #2,D6 
      MULU    D5,D6 
      ADD.L   A1,D6             ; startsektor (d6)
      EXG     A2,A4             ; buffer (a4)
      MOVEM.L A5/A1-A2/D2,-(A7) 
      JSR     (A3)		; readroutine des Rootprg aufrufen (DMAREAD)
      MOVEM.L (A7)+,A5/A1-A2/D2 
      TST.W   D0
      BNE.S   L0009 
      EXG     A2,A4 
      MULU    #$200,D5
      ADDA.L  D5,A2 
      MOVE.W  D2,D6 
      EXT.L   D6
      LSR.L   #8,D6 
      ADD.L   8(A7),D6
      CMP.L   D3,D6 
      BEQ.S   L0011 
      MOVEQ   #1,D5 
      MOVE.L  D6,D3 
      MOVEM.L A5/A1-A2/D2,-(A7) 
      JSR     (A3)    		; readroutine des Rootprg aufrufen (DMAREAD)
      MOVEM.L (A7)+,A5/A1-A2/D2 
      TST.W   D0
      BNE     L0009 
L0011:DC.B    $C4,$7C,0,$FF     ; ANDI  #$FF,D2 
      ADD.W   D2,D2 
      MOVE.W  0(A4,D2.W),D2 
      ROR.W   #8,D2 
      BPL.S   L0010 
      MOVEA.L (A7),A2 
      MOVEA.L A2,A0 
      CMPI.W  #$601A,(A0)+
      BNE     L0009 
      LEA     28(A2),A1 
      ADDA.L  (A0)+,A1
      ADDA.L  (A0)+,A1
      ADDA.L  4(A0),A1
      TST.L   (A1)
      BEQ.S   L0015 
      LEA     28(A2),A0 
      MOVE.L  A0,D1 
      MOVEQ   #0,D0 
      ADDA.L  (A1)+,A0
L0012:ADD.L   D1,(A0) 
L0013:MOVE.B  (A1)+,D0
      BEQ.S   L0015 
      CMP.B   #1,D0 
      BNE.S   L0014 
      LEA     254(A0),A0
      BRA.S   L0013 
L0014:ADDA.W  D0,A0 
      BRA.S   L0012 
L0015:MOVE.L  12(A7),D0 
      LEA     16(A7),A7 
      JMP     32(A2)		; sprung in HDDRIVER.SYS ?
      DC.W   0,0,0,0    
      DC.W   0,0,0,0    
      DC.W   0,0,0,0    
      DC.W   0,0,0,0    
      DC.W   0,0,0,0    
      DC.W   0,0,0,0    
      DC.W   0,0,0,0    
      DC.W   0,0,0,0    
      DC.W   0,0,0,0    
      DC.W   0,0,0,0    
      DC.W   0,0,0,0    
      DC.W   0,0,0,0    
      DC.W   0
      DC.B   $C1,$9C
ZUEND: END
