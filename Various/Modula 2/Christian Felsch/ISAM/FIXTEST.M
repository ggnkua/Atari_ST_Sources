MODULE FixTest;

 FROM IsamGlobals  IMPORT FixFile, ErrorCode, IdxFile, IndexType, IsamKeyStr;
 FROM Files        IMPORT GetFileName;
 FROM FixFiles     IMPORT FixMake, FixOpen, FixClose, FixAdd, FixDel, FixGet,
                          FixErase, FixCounter, FixRename, FixUsed, FixRecSize,
                          FixTotal, FixSize;
 FROM JauInOut     IMPORT WriteString, WriteInt, ReadString, WriteLn, Clr, Wait,
                          ReadCard, ReadLInt, WriteCard;
 FROM IndexFiles   IMPORT IndexMake, IndexClose, IndexAdd,IndexFind,IndexSearch;
 FROM Strings      IMPORT Copy;
 
 VAR  dat: FixFile;
      idx: IdxFile;
      str: ARRAY [0..19] OF CHAR;
      key: IsamKeyStr;
      na : ARRAY [0..137] OF CHAR;
      nr : LONGINT;
      w  : CARDINAL;
      e  : INTEGER;
      ok : BOOLEAN;
      
 BEGIN
  Clr;
  FixMake(dat,'E:\TEST.FIX',SIZE(str),0);
  IndexMake(idx,'E:\TEST.IDX',16,AutoInc);
  REPEAT
   GetFileName(dat.DosDatei,na);
   IF na[0]='' THEN
    na:='keine';
   END(*IF*);
   WriteLn;
   WriteString('  ge”ffnenete Datei  : ');
   WriteString(na);
   WriteLn;
   WriteLn;
   WriteString('  File ”ffnen        : 1');
   WriteLn;
   WriteString('  File l”schen       : 2');
   WriteLn;
   WriteString('  Datensatz ansehen  : 3');
   WriteLn;
   WriteString('  Datensatz hinzu    : 4');
   WriteLn;
   WriteString('  Datensatz l”schen  : 5');
   WriteLn;
   WriteString('  File-Stati anzeigen: 6');
   WriteLn;
   WriteString('             finden  : 7');
   WriteLn;
   WriteString('  Close              : 8');
   WriteLn;
   WriteString('  Ende               : 0');
   WriteLn;
   WriteString('                    >> ');
   ReadCard(w);
   WriteLn;
   CASE w OF
    1: WriteString(' Dateiname: ');
       ReadString(na);
       FixOpen(dat,na,SIZE(str),0);|
    2: FixErase(dat);|
    3: WriteString(' Nr: ');ReadLInt(nr);
       FixGet(dat,nr,str,1);
       WriteString(str);|
    4: WriteString(' Name: ');
       str:='             ';
       ReadString(str);
       IF str[0] # '' THEN
        FixAdd(dat,nr,str);
        Copy(str,0,16,key,ok);
        IndexAdd(idx,nr,key); 
       END(*IF*); |
    5: WriteString(' Nr: '); ReadLInt(nr);
       FixDel(dat,nr);|
    6: WriteString(' Gr”že in Bytes: ');
       WriteInt(FixSize(dat));
       WriteLn;
       WriteString(' Anzahl gesamt : ');
       WriteInt(FixTotal(dat));
       WriteLn;
       WriteString(' Anzahl benutzt: ');
       WriteInt(FixUsed(dat));
       WriteLn;
       WriteString(' Z„hlerstand   : ');
       WriteCard(FixCounter(dat));
       WriteLn;
       WriteString(' Datensatzl„nge: ');
       WriteInt(FixRecSize(na));
       WriteLn;|
    7: WriteString(' suche nach: ');
       ReadString(key);
       IndexSearch(idx,nr,key);
       WriteInt(nr);|
    8: FixClose(dat);
       IndexClose(idx);|
   ELSE
   END(*CASE*);
   WriteLn;
   WriteInt(ErrorCode);
   WriteLn;
  UNTIL w=0;
  FixClose(dat);
  IndexClose(idx);
  WriteInt(ErrorCode);
  Wait;
 END FixTest.
