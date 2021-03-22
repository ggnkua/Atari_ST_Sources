IMPLEMENTATION MODULE InOutBase;
(*$Y+,L-,M-,N+*)

FROM SYSTEM IMPORT ASSEMBLER;
FROM SystemError IMPORT AbortWithMsg;

PROCEDURE InOutErr;
  BEGIN
    ASSEMBLER
        LEA     msg(PC),A0
        MOVE.L  A0,(A3)+
        JMP     AbortWithMsg
    msg ACZ     'InOut driver is missing'
    END
  END InOutErr;

PROCEDURE InOutRtn;
  END InOutRtn;

BEGIN
  ASSEMBLER
        MOVE.L  #InOutErr,Read
        MOVE.L  #InOutErr,Write
        MOVE.L  #InOutErr,OpenWdw
        MOVE.L  #InOutErr,KeyPressed
        MOVE.L  #InOutErr,CondRead
        MOVE.L  #InOutErr,WriteLn
        MOVE.L  #InOutErr,WritePg
        MOVE.L  #InOutErr,WriteString
        MOVE.L  #InOutErr,ReadString
        MOVE.L  #InOutErr,GotoXY
        MOVE.L  #InOutErr,GetInput
        MOVE.L  #InOutErr,GetOutput
        MOVE.L  #InOutErr,OpenError
        MOVE.L  #InOutErr,IOError
        MOVE.L  #InOutErr,FlushKbd
        
        MOVE.L  #InOutRtn,CloseWdw      ; hier keinen Fehler melden.
        MOVE.L  #InOutRtn,fCloseInput   ; hier keinen Fehler melden.
        MOVE.L  #InOutRtn,fCloseOutput  ; hier keinen Fehler melden.
        
        ; die restlichen f..-Funktionen brauchen nicht
        ; init. zu werden, da sie nicht angesprungen wer-
        ; den k”nnen, solange nicht InOutFile 'consIn/Out'
        ; auf FALSE setzt, und dann sind auch die f..-Vars
        ; initialisiert.
  END
END InOutBase.
