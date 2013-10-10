MODULE RscConv;

(*  Resource Konverter  V1.3  fr Megamax Modula-2 und KRsc 2  23.10.90
 *
 *  Erstellt 1/90  von Uwe Stein und Wolfgang Walter
 *
 *  Unsere Adresse:     Uwe Stein und Wolfgang Walter
 *                      Postfach 1608
 *                      5653 Leichlingen 1
 *
 *  E-Mail:             Wolfgang Walter @ K2    (im MAUS-Netz)
 *)

FROM MOSGlobals IMPORT Drive;
FROM Directory  IMPORT GetCurrentDir,Rename;
FROM FileNames  IMPORT SplitPath,SplitName;
FROM Files      IMPORT Access,ReplaceMode,Open,Create,Close,EOF,State,File;
FROM PathEnv    IMPORT SelectFile;
FROM InOut      IMPORT WriteCard,WriteString,WriteLn;
FROM Strings    IMPORT String,Relation,Empty,Pos,Delete,Append,Concat,Split,
                       Assign,EatSpaces;

IMPORT Text;
IMPORT FastStrings;

CONST
     maxLines   = 400;         (* beliebig erweiterbar *)
     GrossZeichenWandlung = TRUE;

TYPE
    ShortStr1TYP = ARRAY[0..7] OF CHAR;
    ShortStr2TYP = ARRAY[0..7] OF CHAR;
    TableTYP     = RECORD
                     High  :CARDINAL;
                     T     :ARRAY[1..maxLines] OF ShortStr1TYP;
                     B     :ARRAY[1..maxLines] OF ShortStr2TYP;
                   END;
    
VAR
     Table      :TableTYP;
     
     dBool      :BOOLEAN;
     dInt       :INTEGER;
     
     ModuleName,
     SrcDat,
     SrcName,
     DestName,
     IOldName,
     ImpNeuName,
     ConvName     :String;
     
  
PROCEDURE TextWriteString(f :File; S :ARRAY OF CHAR);
  BEGIN
    Text.WriteString(f,S);
  END TextWriteString;
  
PROCEDURE TextWriteLn(f :File);
  BEGIN
    Text.WriteLn(f);
  END TextWriteLn;
  
PROCEDURE SourceDateiWaehlen(VAR FileName :String);
  VAR Spath,Sname,dStr :String;
      dBool,OK :BOOLEAN;
  BEGIN
    SplitPath(FileName,Spath,dStr);
    Append('*.DEF',Spath,OK);
    Sname:='';
    SelectFile('DEF-Datei w„hlen ...',Spath,Sname,OK);
    IF OK THEN
       SplitPath(Spath,Spath,dStr);
       SplitName(Sname,Sname,dStr);
       Append('.',Sname,dBool);
       Concat(Spath,Sname,FileName,OK);
    ELSE
      FileName:='';
    END;
  END SourceDateiWaehlen;


PROCEDURE LiesSource;
  VAR f           :File;
      InConst     :BOOLEAN;
      SourceLine  :String;
      P           :INTEGER;
      dBool       :BOOLEAN;
  BEGIN
    Table.High:=0;
    InConst:=FALSE;
    
    Open(f,SrcName,readSeqTxt);
    
    WHILE (~EOF(f)) & (~InConst) DO
           Text.ReadString(f,SourceLine);
           InConst:=(InConst OR (Pos('CONST',SourceLine,0)#-1));
           
           P:=Pos('DEFINITION MODULE',SourceLine,0);
           IF P#-1 THEN
              Delete(SourceLine,0,17,dBool);
              Delete(SourceLine,Pos(';',SourceLine,0),1,dBool);
              EatSpaces(SourceLine);
              ModuleName:=SourceLine;
              WriteString('MODULENAME: '); WriteString(ModuleName);
              WriteLn;
           END;
    END;
       
    WHILE (~EOF(f))  DO
          Text.ReadString(f,SourceLine);
       
          WHILE Pos(CHR(09),SourceLine,0)#-1 DO
                Delete(SourceLine, Pos(CHR(09),SourceLine,0) ,1,dBool);
          END;
       
          IF Pos('=',SourceLine,0)#-1 THEN
             INC(Table.High);
             Split(SourceLine,Pos('=',SourceLine,0),
                   Table.T[Table.High],Table.B[Table.High],dBool);
             IF GrossZeichenWandlung THEN
                Table.T[Table.High,0]:=CAP(Table.T[Table.High,0])
             END;
          END;
    END;
    Close(f);
  END LiesSource;
  
  
PROCEDURE SchreibeDest;
  VAR f    :File;
      I    :CARDINAL;
      dStr :String;
      
  PROCEDURE SchreibeExport;
    VAR I,J :CARDINAL;
        S :String;
        ok:BOOLEAN;
    BEGIN
      TextWriteString(f,'EXPORT'); TextWriteLn(f);
      FOR I:=1 TO Table.High-1 DO
          Assign (Table.T[I], S, ok);
          EatSpaces(S);
          TextWriteString(f,S);
          TextWriteString(f,',');
          IF (I MOD 8)=0 THEN
             TextWriteLn(f);
          END;
       END;
       TextWriteString(f,Table.T[Table.High]);
       TextWriteString(f,';');
       TextWriteLn(f);
    END SchreibeExport;
    
  PROCEDURE SchreibeKonstanten;
    VAR dStr :String;
        I    :CARDINAL;
    BEGIN
      TextWriteLn(f);
      TextWriteString(f,'CONST');
      TextWriteLn(f);
      FOR I:=1 TO Table.High DO
          FastStrings.Concat(Table.T[I],Table.B[I],dStr);
          TextWriteString(f,dStr);
          TextWriteLn(f);
      END;
    END SchreibeKonstanten;
      
  BEGIN
    Create(f,DestName,writeSeqTxt,replaceOld);
    TextWriteString(f,'DEFINITION MODULE ');
    TextWriteString(f,ModuleName);
    TextWriteString(f,';');
    
    TextWriteLn(f);
    
    SchreibeExport;
    
    SchreibeKonstanten;
    
    Concat('END ',ModuleName,dStr,dBool);
    Append('.',dStr,dBool);
    TextWriteString(f,dStr);
    TextWriteLn(f);
    Close(f);
  END SchreibeDest;
  
BEGIN (* main *)
  WriteLn;
  WriteString('  Resource Konverter  V1.2  fr Megamax Modula-2 und KRsc 2');
  WriteLn;
  WriteString('  Erstellt 1/90  von Uwe Stein und Wolfgang Walter');
  WriteLn;
  WriteLn;
  
  GetCurrentDir (defaultDrv,SrcDat);
  
  SourceDateiWaehlen(SrcDat);
  
  IF ~Empty(SrcDat) THEN
      
    Concat(SrcDat,'DEF',SrcName,dBool);     (* D-File von KRsc 2 *)
    Concat(SrcDat,'BAK',ConvName,dBool);    (* neuer Name D-File von KRsc 2 *)
    Concat(SrcDat,'D  ',DestName,dBool);    (* D-File fr MM2    *)
    Concat(SrcDat,'MOD',IOldName,dBool);    (* I-File von KRsc 2 *)
    Concat(SrcDat,'I'  ,ImpNeuName,dBool);  (* I-File fr MM2    *)

    LiesSource;
    
    WriteCard(Table.High,4); WriteString('  Symbole'); WriteLn;
    
    SchreibeDest;

    
    Rename(IOldName,ImpNeuName,dInt);    (*  *.IMP ->  *.I   *)
    Rename(SrcName   ,ConvName  ,dInt);  (*  *.DEF ->  *.BAK *)
    
 END;
END RscConv.
