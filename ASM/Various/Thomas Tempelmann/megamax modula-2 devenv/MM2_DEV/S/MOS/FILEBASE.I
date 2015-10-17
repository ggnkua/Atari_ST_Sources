IMPLEMENTATION MODULE FileBase;
(*$Y+,M-,R-*)

(* V#0027 *)

(* !!! die flush-funktionen fÅr v24, midi, printer, usw. mÅssen warten,
 * bis der ausgabepuffer geleert ist !
 *
 * 14.03.88: MOVE.L InOutErr,... --> MOVE.L #InOutErr,...
 * 05.06.88: Die Treibervariablen f. InOut befinden sich nun im Modul
 *           'InOutBase'.
 * 28.01.89: chin meldet nie Fehler -> Text.Read (MIDI) geht jetzt?
 * 07.09.89: MIDI-Handle von 3 auf 4 korrigiert
 * 23.03.90: strout lÑdt Regs korrekt zurÅck (fÅhrte bei nicht-vollen Strings
 *           zu Bus-Errors)
 * 12.05.90: strout und dout prÅfen timeout bei Printer (handle = 0) und
 *           liefern dann -1 als Error-Code
 *)

FROM SYSTEM IMPORT ASSEMBLER, LONGWORD, ADDRESS, CAST;

FROM SysTypes IMPORT ScanDesc;


PROCEDURE dummyClose (f:File0; new:BOOLEAN);
  END dummyClose;

PROCEDURE dummyHdlErr ( VAR f:File0; err:INTEGER; info: ScanDesc );
  BEGIN
    (* Fehler ignorieren *)
  END dummyHdlErr;

PROCEDURE open0 (VAR hdl:LONGWORD; name: ARRAY OF CHAR): INTEGER;
  BEGIN
    RETURN 0
  END open0;

PROCEDURE close0 (hdl:LONGWORD): INTEGER;
  BEGIN
    RETURN 0
  END close0;


PROCEDURE din ( hdl: LONGWORD; ad:ADDRESS; VAR l:LONGCARD ): INTEGER;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVEM.L D4/D5/A4,-(A7)
        MOVE.L  -(A3),A0
        MOVE.L  (A0),D4
        MOVE.L  -(A3),A4
        MOVE.L  -(A3),D5
        BRA     st
       lo:
        MOVE    D5,-(A7)
        MOVE    #2,-(A7)
        TRAP    #13
        ADDQ.L  #4,A7
        MOVE.B  D0,(A4)+
       st:
        DBRA    D4,lo
        MOVEM.L (A7)+,D4/D5/A4
        CLR     (A3)+
    END
  END din;
  (*$L=*)

PROCEDURE chin ( hdl: LONGWORD ): INTEGER;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D5
        MOVE    D5,-(A7)
        MOVE    #2,-(A7)
        TRAP    #13
        ADDQ.L  #4,A7
        ANDI.W  #$00FF,D0       ; tja, da meldet das BIOS sowieso nie Fehler
        MOVE.W  D0,(A3)+        ; und bei MIDI ist das upper Byte immer $FF !
    END
  END chin;
  (*$L=*)

PROCEDURE dout ( hdl: LONGWORD; ad:ADDRESS; VAR l:LONGCARD ): INTEGER;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVEM.L D4/D5/A4/A6,-(A7)
        MOVE.L  -(A3),A6
        MOVE.L  (A6),D4
        CLR.L   (A6)
        MOVE.L  -(A3),A4
        MOVE.L  -(A3),D5        ; hdl
        MOVEQ   #1,D0
        BRA     st
       lo:
        MOVE.B  (A4)+,D0
        MOVE    D0,-(A7)
        MOVE    D5,-(A7)
        MOVE    #3,-(A7)
        TRAP    #13
        ADDQ.L  #6,A7
        TST.L   D0
        OR.L    D5,D0           ; nur bei Printer den Return-Wert prÅfen
        BEQ     error
        ADDQ.L  #1,(A6)
       st:
        DBRA    D4,lo
       ok:
        MOVEM.L (A7)+,D4/D5/A4/A6
        CLR     (A3)+
        RTS
       error:
        ; Printer-Timeout
        MOVEM.L (A7)+,D4/D5/A4/A6
        MOVE    #-1,(A3)+
    END
  END dout;
  (*$L=*)

PROCEDURE strout ( hdl: LONGWORD; REF str: ARRAY OF CHAR ): INTEGER;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVEM.L D4/D5/A4,-(A7)
        MOVE.W  -(A3),D4
        MOVE.L  -(A3),A4
        MOVE.L  -(A3),D5
        MOVEQ   #0,D0
       lo:
        MOVE.B  (A4)+,D0
        BEQ     ok
        MOVE    D0,-(A7)
        MOVE    D5,-(A7)
        MOVE    #3,-(A7)
        TRAP    #13
        ADDQ.L  #6,A7
        
        TST.L   D0
        OR.L    D5,D0           ; nur bei Printer den Return-Wert prÅfen
       st:
        DBEQ    D4,lo
        BNE     ok
        ; Printer-Timeout
        MOVEM.L (A7)+,D4/D5/A4
        MOVE    #-1,(A3)+
        RTS
       ok:
        MOVEM.L (A7)+,D4/D5/A4
        CLR     (A3)+
    END
  END strout;
  (*$L=*)

PROCEDURE flush0 (a:LONGWORD): INTEGER;
  (*$L-*)
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A3
        CLR     (A3)+
    END
  END flush0;
  (*$L=*)

BEGIN
  CloseFile:= dummyClose;
  HandleError:= dummyHdlErr;
  (* Wird automatisch gelîscht:
    FOR c:= con TO ext3 DO
      UnitDriver [c].valid:= FALSE
    END
  *)
  WITH UnitDriver [con] DO
    valid:= TRUE;
    name:= 'CON:';
    input:= TRUE;
    output:= TRUE;
    initHdl:= CAST (LONGWORD, 2L);
    flush:= flush0;
    open:= open0;
    close:= close0;
    rdData:= din;
    wrData:= dout;
    (*extRS:= FALSE;*)
    wrStr:= strout;
    rdChr:= chin
  END;
  WITH UnitDriver [prn] DO
    valid:= TRUE;
    name:= 'PRN:';
    output:= TRUE;
    initHdl:= CAST (LONGWORD, 0L);
    flush:= flush0;
    open:= open0;
    close:= close0;
    wrData:= dout;
    wrStr:= strout;
  END;
  WITH UnitDriver [aux] DO
    valid:= TRUE;
    name:= 'AUX:';
    input:= TRUE;
    output:= TRUE;
    initHdl:= CAST (LONGWORD, 1L);
    flush:= flush0;
    open:= open0;
    close:= close0;
    rdData:= din;
    wrData:= dout;
    (*extRS:= FALSE;*)
    wrStr:= strout;
    rdChr:= chin
  END;
  WITH UnitDriver [kbd] DO
    valid:= TRUE;
    name:= 'KBD:';
    input:= TRUE;
    initHdl:= CAST (LONGWORD, 2L);
    open:= open0;
    close:= close0;
    rdData:= din;
    (*extRS:= FALSE;*)
    rdChr:= chin
  END;
  WITH UnitDriver [midi] DO
    valid:= TRUE;
    name:= 'MIDI:';
    input:= TRUE;
    output:= TRUE;
    initHdl:= CAST (LONGWORD, 4L);
    flush:= flush0;
    open:= open0;
    close:= close0;
    rdData:= din;
    wrData:= dout;
    (*extRS:= FALSE;*)
    wrStr:= strout;
    rdChr:= chin
  END;
END FileBase.

