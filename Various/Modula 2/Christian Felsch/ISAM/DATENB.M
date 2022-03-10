MODULE Datenbank;  

(* Eine kleine Address-Verwaltung als Demo-Anwendung der Jau-ISAM *)
 

 FROM IsamGlobals  IMPORT FixFile, ErrorCode, IdxFile, IndexType, IsamKeyStr,
                          MaxKeyLen;
 FROM Files        IMPORT GetFileName;
 FROM FixFiles     IMPORT FixMake, FixOpen, FixClose, FixAdd, FixDel, FixGet,
                          FixErase, FixCounter, FixRename, FixUsed, FixRecSize,
                          FixTotal, FixSize;
 FROM IndexFiles   IMPORT IndexMake, IndexOpen, IndexClose, IndexAdd, IndexDel,
                          IndexFind, IndexSearch, IndexErase, IndexPrev,
                          IndexNext, IndexRefind;
 FROM Strings      IMPORT Insert, Assign, Append,Copy,StrEqual;
 
 FROM InOut        IMPORT WriteString, WriteInt, ReadString, WriteLn, 
                          ReadCard, ReadLInt, WriteCard, Write, Read;
                          
 FROM Block        IMPORT Clear;
 FROM SYSTEM       IMPORT TSIZE, ADR;

 
 CONST  fix      = '.FIX';
        idx      = '.IDX';
       modus     = Dups;
       
 TYPE DatenTyp  = (                           (* Definition des Datensatzes *)
                 Vorname,
                 Nachname,
                 Strasse,
                 Postleitzahl,
                 Wohnort,
                 Telefon,
                 Kommentar  ) ;
                 
        StringTyp= ARRAY[0..15] OF CHAR;    (* kleiner Trick zur Vereinfachung*)
                                            (* der Ein- und Ausgabe           *)
        Daten= ARRAY DatenTyp OF StringTyp;         
                 
 VAR  
      Bezeichner: Daten;
      fixDat    : FixFile;
      idxDat    : IdxFile;
      ok,Closed : BOOLEAN;
      name      : ARRAY [0..137] OF CHAR;
      w         : CARDINAL;


 PROCEDURE Ausgabe(REF dat: Daten);
  VAR
    x:DatenTyp;
  BEGIN
   WriteLn;
   FOR x:= Vorname TO Kommentar DO
    WriteLn;
    WriteString(dat[x]);
   END;
   WriteLn;    
  END Ausgabe;
         
         
 PROCEDURE TestError(msg: ARRAY OF CHAR);
 
  BEGIN
   IF ErrorCode # 0 THEN
    WriteLn;
    WriteString('        Fehler ');
    WriteInt(ErrorCode,3);
    WriteString('   , aufgetreten in');
    WriteString(msg);
    WriteLn;
    WriteLn;
   ELSE
    Closed:=FALSE;
   END(*IF*);
  END TestError;
      
      
 PROCEDURE Make;                             (* Neue DB anlegen. Liefert Fehler *)
  VAR name,str: ARRAY [0..137] OF CHAR;      (* falls schon vorhanden.          *)
  
  BEGIN
   WriteString(' Name: ');
   ReadString(str);
   Insert('E:\',0,str,ok);                   (* <<<<<<< Pfad ggf. anpassen !!! *)
   Assign(str,name,ok);
   Append(fix,name,ok);
   FixMake(fixDat,name,TSIZE(Daten),0);
   Assign(str,name,ok);
   Append(idx,name,ok);
   IndexMake(idxDat,name,MaxKeyLen,modus);
   TestError(' Make ');
  END Make;
  
  
 PROCEDURE Open;                             (* ™ffnen vorhandener DB *)
  VAR name,str: ARRAY [0..137] OF CHAR;
  
  BEGIN
   WriteString(' Name: ');
   ReadString(str);
   Insert('E:\',0,str,ok);                   (*<<<<<<<<<< PFAD !!!! *)
   Assign(str,name,ok);
   Append(fix,name,ok);
   FixOpen(fixDat,name,TSIZE(Daten),0);
   TestError(' FixOpen ');
   Assign(str,name,ok);
   Append(idx,name,ok);
   IndexOpen(idxDat,name,MaxKeyLen,modus);
   TestError(' IndexOpen ');
  END Open;


 PROCEDURE Close;
 
  BEGIN
   IF Closed THEN
    WriteLn;
    WriteString(' Es war keine Datenbank mehr ge”ffnet !!');
    WriteLn;
    WriteLn;
   ELSE
    FixClose(fixDat);
    IndexClose(idxDat);
    TestError(' Close ');
    Closed:=TRUE;
   END(*IF*);
  END Close;


  
 PROCEDURE AddItem;                               (* fgt neue Datens„tze ein *)
  VAR
       x : DatenTyp;
      nr : LONGINT;
      key: IsamKeyStr;
      str: Daten;
     i: CARDINAL;
     
  BEGIN   
   REPEAT    
    Clear(ADR(str),SIZE(str)); 
    Clear(ADR(key),SIZE(key));
    WriteLn;
    FOR x:= Vorname TO Kommentar DO
     WriteString(Bezeichner[x]);
     WriteString(' : ');
     ReadString(str[x]);
     WriteLn;
    END;
    IF str[Vorname,0] # '' THEN 
     FixAdd(fixDat,nr,str);
     IndexAdd(idxDat,nr,str[Vorname]);
    END;
     WriteLn;
     TestError(' ItemAdd ');
   UNTIL str[Vorname,0]='';  
  END AddItem;
  

 PROCEDURE Finden;                             (* Durchsucht DB nach einen Namen *)
  VAR str,dat: Daten;
      key: IsamKeyStr;
      nr,n : LONGINT;
      c    : CHAR;
 
  BEGIN
   n:=-1;
   Clear(ADR(key),SIZE(key));
   WriteLn;
   WriteString(' Vorname: ');
   ReadString(key);
   IF key[0] # '' THEN
    IndexSearch(idxDat,nr,key);
    FixGet(fixDat,nr,str,1);
    dat:=str;
    WHILE (StrEqual(str[Vorname], dat[Vorname])) AND (nr#n) DO
     Ausgabe(dat);
     n:=nr;
     IndexNext(idxDat,nr,key);
     FixGet(fixDat,nr,dat,1);
    END;
    TestError(' Finden ');
   END(*IF*);
   Read(c);
  END Finden;


 PROCEDURE Loeschen;
  VAR str,dat: Daten;
      key: IsamKeyStr;
      nr : LONGINT;
      ch : CHAR;
      
  BEGIN
   Clear(ADR(key),SIZE(key));
   WriteLn;
   WriteString(' Vorname: ');
   ReadString(key);
   IF key[0] # '' THEN
    IndexFind(idxDat,nr,key);
    FixGet(fixDat,nr,str,1);
    dat:=str;
    REPEAT
      Ausgabe(str);
      WriteString(' j=Ja oder space=Weiter  ');
      Read(ch);
      IF ch='j' THEN
        IndexDel(idxDat,nr,key);
        FixDel(fixDat,nr);
      END(*IF*);
      IndexNext(idxDat,nr,key);
      FixGet(fixDat,nr,str,1);
    UNTIL ~StrEqual(str[Vorname], dat[Vorname]);
    TestError(' Loeschen ');
   END(*IF*);
  END Loeschen;

  
 PROCEDURE Blaettern; 
  VAR key  : IsamKeyStr;
      nr   : LONGINT;
      daten: Daten;
      was  : CHAR;
     
  BEGIN
   key:='A';
   IndexSearch(idxDat,nr,key);
   WHILE was # 'q' DO
    FixGet(fixDat,nr,daten,1);
    Ausgabe(daten);
    WriteLn;
    WriteString('Space  Q uit');
    Read(was);
    IF was=' '  THEN 
     IndexNext(idxDat,nr,daten[Vorname]);
    END;
    IF ErrorCode # 0 THEN
     WriteString('--------- ENDE---------');
     was:='q';
    END;
   END;(*while*) 
  END Blaettern;
   
  
 PROCEDURE Status;
 
  BEGIN
   WriteLn;
   WriteString(' Status-Header des Fix-Files: ');
   WriteLn;
   WriteString('   Gr”že in Bytes: '); WriteInt(FixSize(fixDat),5);     WriteLn;
   WriteString('   Anzahl gesamt : '); WriteInt(FixTotal(fixDat),5);    WriteLn;
   WriteString('   Anzahl benutzt: '); WriteInt(FixUsed(fixDat),5);     WriteLn;       
   WriteString('   Z„hlerstand   : '); WriteCard(FixCounter(fixDat),5); WriteLn;
   WriteLn;
  END Status;

PROCEDURE Init;
BEGIN
 Bezeichner[Vorname]:='Vorname';
 Bezeichner[Nachname]:='Nachname';
 Bezeichner[Strasse]:='Straže';
 Bezeichner[Postleitzahl]:='Postleitzahl';
 Bezeichner[Wohnort]:='Wohnort';
 Bezeichner[Telefon]:='Telefon';
 Bezeichner[Kommentar]:='Kommentar';
END Init;

 BEGIN
  Init;
  Closed:=TRUE;
  REPEAT
   WriteLn;
   WriteString( '---------------------------------------');
   WriteLn;
   IF ~Closed THEN
    GetFileName(idxDat.DataF.DosDatei,name);
    WriteString('  ge”ffnenete Datenbank : ');
    WriteString(name);
   ELSE
    WriteString('  keine Datenbank ge”ffnet ');
   END(*IF*);
   WriteLn;
   WriteString( '---------------------------------------');
   WriteLn;
   WriteString('  Datenbank erstellen:  1');
   WriteLn;
   WriteString('  Datenbank ”ffnen   :  2');
   WriteLn;
   WriteString('  Datenbank schliežen:  3');
   WriteLn;
   WriteString('  Datenbank durchbl„.:  4');
   WriteLn;
   WriteString('  Datensatz einfgen :  5');
   WriteLn;
   WriteString('  Datensatz l”schen  :  6');
   WriteLn;
   WriteString('  Datensatz finden   :  7');
   WriteLn;
   WriteString('  Fix-Status anzeigen:  8');
   WriteLn;
   WriteString('  Ende               :  0');
   WriteLn;
   WriteString('                    >> ');
   ReadCard(w);
   WriteLn;
   CASE w OF
    1 : Make;| 
    2 : Open;|
    3 : Close;|
    4 : Blaettern;|
    5 : AddItem;|
    6 : Loeschen;|
    7 : Finden;|
    8 : Status;|
   ELSE
   END(*CASE*);
  UNTIL w=0;
  IF NOT (Closed) THEN
   FixClose(fixDat);
   IndexClose(idxDat);
  END(*IF*);
 END Datenbank.
