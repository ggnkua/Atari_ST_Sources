; Das ist das disassemblierte und kommentierte Rootsektor-Programm

L0018 EQU ZUEND+0 
 TEXT 
Begin:
      BRA.S   L0000 
      BRA     L000C 
L0000:CLR.L   $516.S            ; pun_ptr
      BCLR    #2,$4C5.S         ; drvbits (Lfw C lîschen)
      MOVE.L  D5,-(A7)          ; rw-cookie retten
      MOVE.W  #-1,-(A7) 
      MOVE.W  #$B,-(A7) 	; KBSHIFT 
      TRAP    #$D 
      ADDQ.L  #4,A7 
      BTST    #3,D0             ; ALT-Taste gedrÅckt ?
      BNE.S   L0007             ; dann dorthin...
      SUBQ.B  #3,D0             ; Shift-Status lîschen
      BNE.S   L0001 
      TST.B   D5                ; rw-cookie testen
      BEQ.S   L0001             ; bei read dorthin
      EORI.B  #-$40,D5
L0001:MOVEQ   #3,D0 
      MOVEQ   #-8,D1
      LEA     L0017(PC),A0      ; Zeiger auf Bootflag p?_flg
      CMP.L   #$444D4172,D3     ; DMAr ?
      BEQ.S   L0002             ; wenn ja,dorthin (DMAREAD mîglich)
      MOVEQ   #-$80,D2
      BRA.S   L0003 
L0002:MOVE.B  D5,D2             ; rw-cookie
      BEQ.S   L0005             ; bei read dorthin
L0003:BTST    #0,(A0)           ; erste Partition existiert ?
      BEQ.S   L0004             ; wenn nein,dorthin
      AND.B   D1,(A0) 
      CMP.B   (A0),D2 
      BEQ.S   L000A 
L0004:LEA     12(A0),A0         ; zum nÑchsten Bootflag
      DBF     D0,L0003          ; nÑchste Partition abfragen
      BRA.S   L0007 
L0005:BTST    #0,(A0)           ; erste Partiton existiert ?
      BEQ.S   L0006             ; bei nein,dorthin 
      AND.B   D1,(A0) 
      BNE.S   L000A 
L0006:LEA     12(A0),A0         ; zum nÑchsten Bootflag
      DBF     D0,L0005          ; nÑchste Partition abfragen
L0007:MOVE.L  (A7)+,D5          ; rw-cookie holen
L0008:MOVEA.L $4F2.S,A0         ; sysbase-zeiger in a0
      MOVE.L  24(A0),D0         ; os_date holen
      SWAP    D0
      CMP.L   #$19870422,D0     ; datum-test
      BCC.S   L0009             ; Åbertrag (bit31=1) ?
      MOVE.W  #$E0,D7           ; ??????????????????????????????????????????
L0009:CLR.W   $446.S            ; bootdev lîschen (Boot von Lfw A)
      RTS                       ; Ende
L000A:MOVE.L  4(A0),D6          ; Nummer des ersten Sektors der Partition,gerechnet ab Sektor 0
      MOVEQ   #1,D5             ; Sektoranzahl
      LEA     L0018(PC),A4      ; Endadresse des Programms
      BSR.S   L000C             ; Unterprogramm "read sector" aufrufen
      TST.W   D0
      BNE.S   L0007             ; wenn fehler,dorthin
      MOVEA.L A4,A0 
      MOVE.W  #$FF,D1           ; crc ermitteln
      MOVEQ   #0,D0 
L000B:ADD.W   (A0)+,D0
      DBF     D1,L000B
      CMP.W   #$1234,D0         ; crc prÅfen
      BNE.S   L0007             ; wenn falsch,dorthin
      LEA     L000C(PC),A3      ; adresse readroutine
      LEA     L0008(PC),A5      ; adresse exitroutine
      MOVE.L  (A7)+,D5          ; rw-cookie holen
      JMP     (A4)              ; bootprogramm ausfÅhren

L000C:BTST    #4,D4             ; IDE ?
      BNE.S   L000D             ; wenn IDE,dann dorthin (direct register-acccess)

      MOVE.W  D4,-(A7)          ; devno
      PEA     (A4)              ; buffer
      MOVE.W  D5,-(A7)          ; count
      MOVE.L  D6,-(A7)          ; startsector
      MOVE.W  #$2A,-(A7)        ; DMAREAD()
      TRAP    #$E 
      LEA     14(A7),A7 
      RTS 
L000D:LEA     L0016(PC),A6      ; Zeiger auf IDE-Parameter
      TST.W   (A6)
      BNE.S   L000E             ; dorthin (Wert=8)
      MOVE.B  D4,D0             ; device
      AND.B   #1,D0             ; Bit fÅr IDE0/IDE1 
      LSL.B   #4,D0             
      OR.B    #-$60,D0
      MOVE.B  D0,$FFF00019.L    ; Laufwerknummer direkt setzen 
      MOVEA.L A4,A0             ; Programm-Endadresse (Readout-Buffer)
      MOVEQ   #0,D1             ; Anzahl der Readouts (je 512 Byte)
      MOVE.B  #-$14,D2          ; Command "Identify device"
      BSR.S   L000F             ; IDE-Command ausfÅhren
      BNE     L0013             ; bei Fehler,dorthin
      MOVE.W  6(A4),(A6)        ; heads
      MOVE.W  12(A4),2(A6)      ; sectors
L000E:MOVE.L  D6,D1             ; startsector
      MOVE.W  2(A6),D0
      MOVE.W  (A6),D2 
      MULU    D0,D2             ; startsector/(sectors*heads)
      DIVU    D2,D1             ; 
      MOVE.B  D1,$FFF00011.L    ; set cylinder low
      LSR.L   #8,D1 
      MOVE.B  D1,$FFF00015.L    ; set cylinder high
      LSR.L   #8,D1             
      DIVU    D0,D1             ; head=rest/sectors
      MOVE.B  D4,D0 
      AND.B   #1,D0 
      LSL.B   #4,D0 
      OR.B    D0,D1             ; drivebit+head
      OR.B    #-$60,D1          ; compatibility ??????????
      MOVE.B  D1,$FFF00019.L    ; set drive/head
      SWAP    D1
      ADDQ.W  #1,D1 
      MOVE.B  D1,$FFF0000D.L    ; set sector-number
      MOVEA.L A4,A0 
      MOVE.B  D5,$FFF00009.L    ; count
      MOVE.W  D5,D1 
      SUBQ.W  #1,D1 
      MOVEQ   #$20,D2           ; Command "Read-sectors"
L000F:MOVE.B  #2,$FFF00039.L    ; Digital Output-Register setzen  ????????
      MOVE.B  D2,$FFF0001D.L    ; Command
      TST.B   $FFF00039.L       ; Alternate-Status auslesen
L0010:LEA     $FFF0001D.L,A1    
      MOVE.L  #$7D0,D0          
      ADD.L   $4BA.S,D0         ; timer hz_200
      TST.B   (A1)
L0011:TST.B   (A1)              ; busy ?
      BMI.S   L0012             ; dann dorthin
      BTST    #3,(A1)           ; data_transfer ?
      BNE.S   L0014             ; dann dorthin
L0012:CMP.L   $4BA.S,D0 
      BHI.S   L0011             ; wiederholen
L0013:MOVEQ   #-1,D0            ; error,ende
      RTS 
L0014:BTST    #0,(A1)           ; errorflag gesetzt ?
      BNE.S   L0013             ; dann tschÅss
      MOVEQ   #$7F,D0 
      LEA     $FFF00000.L,A1
L0015:MOVE.W  (A1),(A0)+        ; Readout 512 Byte
      MOVE.W  (A1),(A0)+
      DBF     D0,L0015
      DBF     D1,L0010
      MOVEQ   #0,D0             ; Alles fehlerfrei
      RTS 
L0016:DS.W    8,0 
      DC.B   $06,'*',$00,$00,$00,$00,$00,$03
      DC.B   $00,$00
L0017:DC.B   $81,'BGM',$00,$00,$00,$02
      DC.B   $00,$02,$FF,$E0,$00,$00,$00,$00
      DS.W    17,0
      DC.B   $00,$01,$00,$00,$00,$01,$00,$00
ZUEND: END
