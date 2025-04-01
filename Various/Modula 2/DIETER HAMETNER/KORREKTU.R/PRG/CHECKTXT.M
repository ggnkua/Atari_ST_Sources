MODULE CheckTxt;

(* Konvertierungsprogramm fÅr Text --> Worte.
 * ---------------------------------------------------------------------------
 * VERSIONSNUMMER:  V#0056#
 * ---------------------------------------------------------------------------
 * 17.10.90 | 0000 | W.K | Kosmetik.
 *)

IMPORT MoreIO; (*$E MOS*)

IMPORT Text;
FROM GEMEnv     IMPORT  InitGem, RC, DeviceHandle;
FROM StrConv    IMPORT  CardToStr;
FROM MOSGlobals IMPORT  FileStr;
FROM Characters IMPORT  Spaces, Alphas;
FROM Strings    IMPORT  Lower, String;
FROM XInOut     IMPORT  WriteLSL, WritePg, WriteSSL, WriteSL, WriteSCSL;
FROM Files      IMPORT  File, Create, Access, ReplaceMode, Close;
FROM MyUtil     IMPORT  wait, working, nl, voidO, CPtr, FileToAdr, XSelectFile;
FROM Dics       IMPORT  Dic, LoadDic, SetSpellMode, FindDic;

CONST verbose  = TRUE;
      
      startStr    = 'öberprÅft eine Textdatei mit Hilfe eines Wîrterbuches.'+nl+
                    'Nichtgefundene Wîrter werden protokolliert.'+nl;
                 
      srcMsg      = 'Zu lesende Textdatei:';
      srcStr      = 'Lade Textdatei'+working;
      
      dicMsg      = 'Wîrterbuch:';
      dicStr      = 'Lade Wîrterbuch'+working;
      
      tgtMsg      = 'Datei fÅr nichtgefundene Wîrter:';
      tgtStr      = 'lege Datei fÅr nichtgefundene Wîrter an'+working;
      
      src_name = '\*.TXT';
      tgt_name = '\*.WRD';
      dic_name = '\SPELLING.DIC';
      
      NL       = CHR (13);
      
TYPE zustand = (void, word, cr, lf, white, rest);
    
VAR f   : File;
    cnt : LONGCARD;
    srcName, tgtName, dicName: FileStr;
    cPtr:CPtr;
    size: LONGCARD;
    pos,i,ln,p : LONGCARD;
    z: zustand;
    handle: DeviceHandle;
    ix : CARDINAL;
    str:String;
    dic: Dic;

(* ------------------------------------------------------------------------- *)

PROCEDURE Push;
  BEGIN
    str[ix] := 0C; ix := 0; z := void;
    Lower (str);
    IF ~FindDic (dic, str) THEN
      IF verbose THEN
        WriteSCSL (str, ln, 6, '');
        Text.WriteString (f, str);
        Text.WriteString (f, CardToStr (ln, 6));
        Text.WriteLn (f);
      ELSE
        WriteSL (str);
        Text.WriteString (f, str);
        Text.WriteLn (f);
      END;
    END;
  END Push;
  
PROCEDURE Add (c: CHAR);
  BEGIN
    str[ix] := c; INC (ix);
  END Add;
  
BEGIN
  InitGem (RC, handle, voidO); WritePg;
  
  srcName := src_name;
  tgtName := src_name;
  dicName := dic_name;
  
  ix := 0; str := '';
  
  WriteSL (startStr);wait;
  
  XSelectFile (srcMsg, srcName);
  XSelectFile (tgtMsg, tgtName);
  XSelectFile (dicMsg, dicName);
  
  WriteSSL (srcStr, srcName);
  cPtr := NIL;
  FileToAdr (srcName, cPtr, size);
  
  WriteSSL (tgtStr, tgtName);
  Create (f, tgtName, writeSeqTxt, replaceOld);
  
  WriteSSL (dicStr, dicName);
  LoadDic (dicName, dic, 200L*1024L, 0L);
  
  SetSpellMode (dic, 10);
  z := void;
  FOR i := 1 TO size DO
    CASE z OF
    | void: IF cPtr^  = NL THEN
              INC (ln); p := 0;
            ELSIF cPtr^ IN Alphas THEN
              Add (cPtr^);
              z := word;
            END;
            
    | word: IF cPtr^ IN Alphas THEN
              Add (cPtr^);
            ELSIF (cPtr^ = '~') OR (cPtr^ = '-') THEN
              z := cr;
            ELSIF cPtr^  = NL THEN
              Push; INC (ln); p := 0;
            ELSE
              Push;
            END;
            
    | cr:   IF cPtr^ = NL THEN
              INC (ln); p := 0; z := lf;
            ELSIF cPtr^ IN Alphas THEN
              Push; Add (cPtr^); z := word;
            ELSE
              Push;
            END;
            
    | lf:   IF cPtr^ = CHR (10) THEN
              z := white;
            ELSIF cPtr^ IN Alphas THEN
              Add (cPtr^);
              z := word;
            ELSIF cPtr^  = NL THEN
              Push; INC (ln); p := 0;
            ELSE
              Push;
            END;
     
    |white: IF cPtr^ IN Alphas THEN
              Add (cPtr^);
              z := word;
            ELSIF cPtr^  = NL THEN
              Push; INC (ln); p := 0;
            ELSIF ~(cPtr^ IN Spaces) THEN
              Push;
            END;
    END;
    INC (p); INC (cPtr);
  END;
  Close (f);
  WriteLSL (working +' Fertig!');
END CheckTxt.
(* $FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$00000A08$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6CÅ$000004C3T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000004C3$FFEE803A$0000040B$FFEE803A$FFEE803A$0000040B$00000384$00000376$FFEE803A$FFEE803A$00000380$00000399$FFEE803A$000003B1$000003F2$00000B37ÑÄÅ*)
