MODULE AddWords; (*$E MOS*)

(* fÅgt Wîrter in ein Wîrterbuch ein und kann einfache Trennungen erkennen und
 * rÅckgÑngig machen.
 * ---------------------------------------------------------------------------
 * VERSIONSNUMMER:  V#0033#
 * ---------------------------------------------------------------------------
 * 21.10.90 | 0000 | W.K | Modul angelegt.
 *)

IMPORT MoreIO;
IMPORT Text;

FROM MOSGlobals IMPORT  FileStr;
FROM StrConv    IMPORT  CardToStr;
FROM Strings    IMPORT  Lower, String;
FROM Characters IMPORT  Spaces, Alphas;
FROM XInOut     IMPORT  WritePg, WriteLSL, WriteSSL, WriteSL, WriteSCSL;
FROM GEMEnv     IMPORT  InitGem, RC, DeviceHandle;
FROM Files      IMPORT  File, Create, Access, ReplaceMode, Close;
FROM MyUtil     IMPORT  voidO, YesNoAlert, CPtr, FileToAdr, XSelectFile;
FROM Dics       IMPORT  SaveDic, InsertDic, Dic, LoadDic;

CONST verbose  = TRUE;
      
      nl          = 15C + 12C;
      
      txt_0       = 'FÅgt alle in der Textdatei enthaltenen Wîrter in'+nl+
                    'ein Wîrterbuch ein.'+nl;
                 
      txt_1       = 'Zu lesende Textdatei:';
      loadSrcStr  = 'Lade Textdatei: ';
      
      txt_2       = 'Wîrterbuch:';
      loadDicStr  = 'Lade Wîrterbuch: ';
      
      saveStr     = 'GeÑndertes Wîrterbuch|     sichern?';
      yesStr      = 'Ja';
      noStr       = 'Nein';
      saveDicStr  = 'Speichere Wîrterbuch: ';
      
      startWorkStr = 'Wîrter werden EingefÅgt.'+ nl + 'Bei Fragen zur'+
                     'Bedienung vom More einfach <Help> drÅcken.';
      
      src_name    = '\*.TXT';
      dic_name    = '\SPELLING.DIC';
      
      NL       = CHR (13);
      
TYPE zustand = (void, word, cr, lf, white, rest);
    
VAR f          : File;
    cnt, size  : LONGCARD;
    pos,i,ln,p : LONGCARD;
    ix         : CARDINAL;
    cPtr       : CPtr;
    z          : zustand;
    handle     : DeviceHandle;
    str        : String;
    dic        : Dic;
    srcName, tgtName, dicName: FileStr;

(* ------------------------------------------------------------------------- *)

PROCEDURE Push;
  BEGIN
    str[ix] := 0C; ix := 0; z := void;
    Lower (str);
    InsertDic (dic, str, voidO);
    WriteSL (str);
  END Push;
  
PROCEDURE Add (c: CHAR);
  BEGIN
    str[ix] := c; INC (ix);
  END Add;
  
BEGIN
  InitGem (RC, handle, voidO);cPtr := NIL; WritePg;
  srcName := src_name;  dicName := dic_name;
  XSelectFile (txt_1, srcName); XSelectFile (txt_2, dicName);
  
  WriteSSL (loadSrcStr,srcName);   FileToAdr (srcName, cPtr, size);
  WriteSSL (loadDicStr, dicName);  LoadDic (dicName, dic, 200L*1024L, 0L);
  
  WriteLSL (startWorkStr);
  
  ix := 0; str := ''; z := void;
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
  IF YesNoAlert (saveDicStr, yesStr, noStr) THEN
    WriteSSL (saveStr, dicName);
    SaveDic (dicName, dic);
  END;
END AddWords.
(* $FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$00000975$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6C$FFF58A6CÅ$0000024ET.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000ABB$0000097E$00000968$0000065B$00000675$FFEE803A$00000435$FFEE803A$000003B3$000003A7$0000097D$0000024E$FFEE803A$00001020$0000065B$00000675∞ÄÅ*)
