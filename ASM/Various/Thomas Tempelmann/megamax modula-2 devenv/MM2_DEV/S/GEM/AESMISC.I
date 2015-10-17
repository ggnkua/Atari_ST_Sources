IMPLEMENTATION MODULE AESMisc;
(*$L-, N+, Y+*)

(*  MEGAMAX MODULA 2 GEM-Library :  Verschiedene AES Funktionen         *
 *                                                                      *
 *  Autor: Manuel Chakravarty           Erstellt :  05.11.87            *
 *                                                                      *
 *  Version   2.2     V#0051                                            *)
 
(*  05.11.87    | öbernahme von 'GEMBase' und 'GEMExt'
 *  14.01.88    | Erweiterung um 'ShellGet' und 'ShellPut'
 *  26.07.88    | 'getNoElements' liefert jetzt 'HIGH (..) + 1', statt
 *              | 'HIGH (..)'
 *  20.08.89    | 'SelectFileExteded' def. + impl.
 *  08.09.89 TT | 'ShellFind' korrigiert; kein öberlauf bei ShellRead;
 *                ShellRead/Write konvertieren LÑngenbyte bei TAIL (cmdline);
 *                ShellWrite hat nicht mehr den 3. Parameter f. Wahl, ob
 *                Prg als Sub-Prozeû oder nach Prg-Ende gestartet werden soll.
 *  ???????? TT | REF-Parm.
 *  02.04.90    | Anpassung auf public arrays
 *  17.01.94 TT | FindApplication korrigiert (jetzt Null-Byte hinter Namen).
 *)


FROM    SYSTEM  IMPORT ASSEMBLER, BYTE;

IMPORT  GEMShare;

(*$I GEMOPS.ICL *)


(*  getNoElements -- geg.: 'high'=HIGH(...) und 'userNo' Angabe Åber Anzahl  *
 *                         zu benutzender Elemente.                          *
 *                   ges.: 'D0=userNo', falls '(userNo<high) und (userNo#0)' *
 *                         'D0=high + 1'  , sonst.                           *
 *                                                                           *
 *       !!!!  Nur von Assemblerroutinen zu benÅtzen  !!!!                   *)
                
PROCEDURE getNoElements(high,userNo:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.W  -(A3),D0        ; 'userNo' -> D0
        MOVE.W  -(A3),D1
        ADDQ.W  #1,D1           ; 'high + 1'   -> D1
        TST.W   D0
        BEQ     cont2           ; springe, falls 'userNo=0'
        CMP.W   D0,D1
        BGE     cont            ; springe, falls 'high>=userNo'
cont2
        MOVE.W  D1,D0           ; 'high' -> D0
cont
  END;
END getNoElements;


                (*  Application Manager  *)
                (*  ===================  *)
                
PROCEDURE ReadFromAppl(id:CARDINAL;VAR buffer:ARRAY OF BYTE;noBytes:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    JSR         getNoElements
    MOVE.W      D0,pubArrays.aINTIN+2(A0)
    MOVE.L      -(A3),pubArrays.ADDRIN(A0)
    MOVE.W      -(A3),pubArrays.aINTIN(A0)
    MOVE.W      #APPL_READ,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
  END;
END ReadFromAppl;
        
PROCEDURE WriteToAppl(id:CARDINAL;REF message:ARRAY OF BYTE;noBytes:CARDINAL);
        
BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    JSR         getNoElements
    MOVE.W      D0,pubArrays.aINTIN+2(A0)
    MOVE.L      -(A3),pubArrays.ADDRIN(A0)
    MOVE.W      -(A3),pubArrays.aINTIN(A0)
    MOVE.W      #APPL_WRITE,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
  END;
END WriteToAppl;
        
PROCEDURE FindApplication(REF fname:ARRAY OF CHAR;
                          VAR id:CARDINAL;VAR success:BOOLEAN);

BEGIN
  ASSEMBLER
    CLR.W       -(A7)           ; Bytes hinter Namen lîschen
    SUBQ.L      #8,A7           ; reserviere weitere 8 Byte auf dem A7
    MOVE.L      A7,A2
    MOVE.L      -(A3),-(A7)
    MOVE.L      -(A3),-(A7)
    MOVE.W      -(A3),D0        ; HIGH(fname) -> D0
    CMP.W       #7,D0
    BLE         cont4           ; IF HIGH(fname)>7 THEN D0:=7
    MOVEQ       #7,D0
cont4
    MOVE.L      -(A3),A0
    MOVE.L      A2,A1           ; ADR(stackBuffer) -> A1
    MOVE.W      D0,D1           ; D0(Anzahl der Zeichen) -> D1 (ZÑhler)
loop
    MOVE.B      (A0)+,(A1)+
    DBEQ        D1,loop         ; Zeichen -> stackBuffer, bis #0 oder ZÑhlerende
    BNE         cont2           ; Letztes Zeichen #0, dann Zeichen ignorieren
    SUBQ.L      #1,A1
cont2
    ADDQ.W      #7,D1
    SUB.W       D0,D1           ; (7- Anzahl Åbertragener Zeichen) -> D1
    BMI         cont3
    MOVEQ       #' ',D0         ; FÅllzeichen ist <Space>
loop2
    MOVE.B      D0,(A1)+
    DBF         D1,loop2        ; Auf acht Zeichen auffÅllen
cont3
    MOVE.L      pubs,A0       ; Auruf von 'APPL_FIND' mit ADDRESS(stackBuffer)
    MOVE.L      A2,pubArrays.ADDRIN(A0)
    MOVE.W      #APPL_FIND,(A3)+
    JSR         aes_if
    CLR.W       D1
    MOVE.L      pubs,A0
    MOVE.W      pubArrays.aINTOUT(A0),D0
    SMI         D1
    ADDQ.B      #1,D1
    MOVE.L      (A7)+,A1
    MOVE.W      D0,(A1)         ; id := pubs^.aINTOUT[0]
    MOVE.L      (A7)+,A1
    MOVE.W      D1,(A1)         ; success := (pubs^.aINTOUT[0]>=0)
    ADDA.W      #10,A7          ; 'stackBuffer' freigeben
  END;
END FindApplication;


PROCEDURE PlayEvents (REF buffer:ARRAY OF RecordedEvent; no:CARDINAL;
                      scale:CARDINAL);
                      
BEGIN
  ASSEMBLER
        MOVE.L  pubs,A0
        MOVE.W  -(A3),pubArrays.aINTIN+2(A0)
        JSR     getNoElements
        MOVE.L  pubs,A0
        MOVE.W  D0,pubArrays.aINTIN(A0)
        MOVE.L  -(A3),pubArrays.ADDRIN(A0)
        MOVE.W  #APPL_TPLAY,(A3)+
        JSR     aes_if
  END;
END PlayEvents;

PROCEDURE RecordEvents (VAR buffer:ARRAY OF RecordedEvent; no:CARDINAL;
                        VAR recorded: CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.L  -(A3),-(A7)
        
        JSR     getNoElements
        MOVE.L  pubs,A0
        MOVE.W  D0,pubArrays.aINTIN(A0)
        MOVE.L  -(A3),pubArrays.ADDRIN(A0)
        MOVE.W  #APPL_TRECORD,(A3)+
        JSR     aes_if
        
        MOVE.L  (A7)+,A1
        MOVE.L  pubs,A0
        MOVE.W  pubArrays.aINTOUT(A0),(A1)
  END;
END RecordEvents;

        
                (*  File Selector Manger  *)
                (*  ====================  *)
        
PROCEDURE SelectFile (VAR path, name: ARRAY OF CHAR; VAR ok: BOOLEAN);

  BEGIN
    ASSEMBLER
        JMP     selectFile
    END;
  END SelectFile;

PROCEDURE SelectFileExtended (REF     label     : ARRAY OF CHAR;
                              VAR path, name: ARRAY OF CHAR;
                              VAR ok        : BOOLEAN);

  BEGIN
    ASSEMBLER
        JMP     selectFileExtended
    END;
  END SelectFileExtended;


                (*  Scrap Manager  *)
                (*  =============  *)

PROCEDURE ReadScrapDir(VAR dir:ARRAY OF CHAR);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    TST.W       -(A3)           ; Falls Max. des Scrap Eintrag bekannt wird
                                ; dann abtesten ob HIGH(dir)>= Max.
    MOVE.L      -(A3),pubArrays.ADDRIN(A0)
    MOVE.W      #SCRP_READ,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
  END;
END ReadScrapDir;
         
PROCEDURE WriteScrapDir(REF dir:ARRAY OF CHAR);

BEGIN
  ASSEMBLER
        JSR     stringIntoCFormat
        MOVE.L  pubs,A0
        MOVE.L  D2,pubArrays.ADDRIN(A0)
        MOVE.W  #SCRP_WRITE,(A3)+
        JSR     aes_if
        MOVE.L  (A7),A7
  END;
END WriteScrapDir;


                (*  Shell Manager  *)
                (*  =============  *)

PROCEDURE ShellRead (VAR cmd, tail: ARRAY OF CHAR);

  BEGIN
    ASSEMBLER
        JMP     shellRead
    END;
  END ShellRead;
  
PROCEDURE ShellWrite(start: BOOLEAN;isGraf:ProgramType;
                     REF cmd,tail:ARRAY OF CHAR);
                     
BEGIN
  ASSEMBLER
        MOVE.L  pubs,A0

        ; TAIL muû LÑngenbyte am Anfang bekommen
        SUBA.W  #$100,A7
        MOVE.L  A7,pubArrays.ADDRIN+4(A0)
        MOVE    -(A3),D2
        MOVE.L  -(A3),A2
        LEA     1(A7),A1
        MOVEQ   #0,D1
      L ADDQ    #1,D1
        MOVE.B  (A2)+,(A1)+
        DBEQ    D2,L
        BNE     M
        SUBQ    #1,D1
      M MOVE.B  D1,(A7)

        JSR     stringIntoCFormat
        MOVE.L  pubs,A0
        MOVE.L  D2,pubArrays.ADDRIN(A0)
        MOVE.W  #1,pubArrays.aINTIN+4(A0)       ; unbenutzt - immer EINS!
        MOVE.W  -(A3),pubArrays.aINTIN+2(A0)
        MOVE.W  -(A3),D0
        MOVE.L  our_cb, A1
        CMPI.W  #$140,cb.GLOBAL.ap_version(A1)
        BCC     ok
        MOVEQ   #1,D0
     ok MOVE    D0,pubArrays.aINTIN(A0)
        MOVE.W  #SHEL_WRITE,(A3)+
        JSR     aes_if
        MOVE.L  (A7),A7         ; Strings vom Stack entfernen
        ADDA.W  #$100,A7
        JSR     testINTOUT0
  END;
END ShellWrite;
                     
PROCEDURE ShellGet (VAR buffer:ARRAY OF BYTE; no:CARDINAL);

BEGIN
  ASSEMBLER
        JSR     getNoElements
        MOVE.L  pubs,A0
        MOVE.W  D0,pubArrays.aINTIN(A0)
        MOVE.L  -(A3),pubArrays.ADDRIN(A0)
        MOVE.W  #SHEL_GET,(A3)+
        JSR     aes_if
        JSR     testINTOUT0
  END;
END ShellGet;

PROCEDURE ShellPut (REF buffer:ARRAY OF BYTE; no:CARDINAL);

BEGIN
  ASSEMBLER
        JSR     getNoElements
        MOVE.L  pubs,A0
        MOVE.W  D0,pubArrays.aINTIN(A0)
        MOVE.L  -(A3),pubArrays.ADDRIN(A0)
        MOVE.W  #SHEL_PUT,(A3)+
        JSR     aes_if
        JSR     testINTOUT0
  END;
END ShellPut;

PROCEDURE ShellFind(VAR name:ARRAY OF CHAR);

BEGIN
  ASSEMBLER
        MOVE.W  -2(A3),-(A7)
        MOVE.L  -6(A3),-(A7)
        JSR     stringIntoCFormat
        MOVE.L  D2,-(A7)
        
        MOVE.L  pubs,A0
        MOVE.L  D2,pubArrays.ADDRIN(A0)
        MOVE.W  #SHEL_FIND,(A3)+
        JSR     aes_if
        JSR     testINTOUT0

        MOVE.L  (A7)+,A1        ; ADR (String auf dem Stack) -> A1
        MOVE.L  (A7)+,A2        ; neuer A7
        MOVE.L  (A2)+,A0        ; ADR (name) -> A0
        MOVE.W  (A2)+,D0        ; HIGH (name) -> D0
loop
        MOVE.B  (A1)+,(A0)+
        DBEQ    D0,loop
        MOVE.L  A2,A7
  END;
END ShellFind;

PROCEDURE ShellEnvironment(REF param:ARRAY OF CHAR;VAR value:ARRAY OF CHAR);
        
BEGIN
  ASSEMBLER
        MOVE.L  pubs,A0
        TST.W   -(A3)
        MOVE.L  -(A3),pubArrays.ADDRIN(A0)
        JSR     stringIntoCFormat
        MOVE.L  pubs,A0
        MOVE.L  D2,pubArrays.ADDRIN+4(A0)
        MOVE.W  #SHEL_ENVRN,(A3)+
        JSR     aes_if
        MOVE.L  (A7),A7         ; String vom Stack schmeiûen
        JSR     testINTOUT0
  END;
END ShellEnvironment;


END AESMisc.
