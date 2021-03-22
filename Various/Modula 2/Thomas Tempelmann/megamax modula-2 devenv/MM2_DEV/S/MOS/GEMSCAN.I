IMPLEMENTATION MODULE GEMScan;
(*$Y+,R-,S-*)

FROM SYSTEM IMPORT LONGWORD, WORD, ADDRESS, BYTE, ADR;

FROM SysTypes IMPORT ScanDesc;

FROM SysCtrl IMPORT ScanBack;

FROM AESForms IMPORT FormAlert;

FROM StrConv IMPORT CardToStr, StrToLCard, IntToStr, LHexToStr;

FROM ModCtrl IMPORT GetModName, GetSourceName;

FROM Strings IMPORT String, Pos, Delete, Assign, Insert, Concat, Copy, Length,
        Empty, Append, Upper;

VAR strVal: BOOLEAN;

PROCEDURE InitChain ( pos: ScanDesc );
  BEGIN
    ChainDepth:= 0;
    REPEAT
      WITH CallingChain [ChainDepth] DO
        GetModName (pos.pc, modName, relAddr, procName);
        IF modName [0] = 0C THEN
          relAddr:= pos.pc
        END;
        GetSourceName (modName, sourceName, codeOpts)
      END;
      INC (ChainDepth)
    UNTIL (ChainDepth > MaxDepth) OR ~ScanBack (pos);
    DEC (ChainDepth)
  END InitChain;


PROCEDURE apnd (REF s:ARRAY OF CHAR; VAR to: ARRAY OF CHAR);
  BEGIN
    Append (s,to,strVal)
  END apnd;

PROCEDURE InputScan ( REF msg: ARRAY OF CHAR; VAR index: CARDINAL );
  
  VAR scan: ScanDesc;
      msg2, msg1:ARRAY [0..166] OF CHAR; (* reicht f. 5 Zeilen *)
      pos2, pos: INTEGER;
      lines, button, exBut, fwBut, baBut: CARDINAL;

  BEGIN
    IF index>=0 THEN
      IF index>CARDINAL(ChainDepth) THEN index:= ChainDepth END;
      LOOP
        IF msg[0]#0C THEN
          Assign (msg, msg2, strVal);
          (* maximal 2 Zeilen … 29 Zeichen: *)
          pos:= Pos ('|', msg2, 0);
          IF pos < 0 THEN
            lines:= 1;
            msg2 [29]:= 0C
          ELSE
            IF pos > 29 THEN
              Delete (msg2, 29, pos-29, strVal);
              pos:= 29
            END;
            lines:= 2;
            msg2 [pos+30]:= 0C;
            pos2:= Pos ('|', msg2, pos+1);
            IF pos2 >= 0 THEN
              msg2 [pos2] := 0C
            END
          END;
          Append ('|', msg2, strVal);
        ELSE
          lines:= 0;
          msg2:= ''
        END;
        IF CallingChain [index].modName[0] = 0C THEN
          apnd ("Unbekannter Programmbereich,|Adresse: ",msg2)
        ELSE
          INC (lines);
          apnd ("Modul '",msg2);
          Copy (CallingChain [index].modName,0,22,msg1,strVal);
          apnd (msg1,msg2);
          IF CallingChain [index].procName[0] # 0C THEN
            apnd ("'|Proc '",msg2);
            Copy (CallingChain [index].procName,0,24,msg1,strVal);
            apnd (msg1,msg2);
            apnd ("'",msg2)
          ELSE
            apnd ("'| ",msg2);
          END;
          apnd ("|Offset: ",msg2)
        END;
        apnd (LHexToStr(CallingChain [index].relAddr,0),msg2);
        IF lines < 3 THEN
          Concat ('|Tiefe: ',CardToStr (index,0),msg1,strVal);
          apnd (msg1,msg2)
        END;
        exBut:= 1; fwBut:= 0; baBut:= 0;
        msg1:= '[0][][EXIT]';
        IF index>0 THEN
          Insert ('Frwd|',6,msg1,strVal);
          INC (fwBut);
          INC (exBut)
        END;
        IF INTEGER(index)<ChainDepth THEN
          Insert ('Back|',6,msg1,strVal);
          INC (baBut);
          IF fwBut#0 THEN INC (fwBut) END;
          INC (exBut)
        END;
        Insert (msg2,4,msg1,strVal);
        FormAlert (exBut, msg1,button);
        IF button=exBut THEN (* Exit *)
          EXIT
        ELSIF button=fwBut THEN
          DEC (index)
        ELSE
          INC (index)
        END
      END  (* LOOP *)
    END
  END InputScan;

BEGIN
  ChainDepth:= -1
END GEMScan.
