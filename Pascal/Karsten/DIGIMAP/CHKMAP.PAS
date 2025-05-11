PROGRAM CheckMap;

CONST CallLength  = 9;
      DefFileName = 'DIGIMAP';
      DefDatExt   = '.DAT';
      DefErrExt   = '.ERR';

TYPE errTyp  = (E_NOCOMMA, E_NOCALL , E_LOCLEN , E_TYPVAL ,
                E_TYPERR , E_FREQVAL, E_RADVAL , E_NOLBRA ,
                E_NORBRA , E_NOLCALL, E_COMLEN , E_NOLINK ,
                E_LINKTYP, E_NOENTRY, E_DOUBLE, E_NOSORT);

     recPtr  = ^recTyp;
     linkPtr = ^linkTyp;
     str255  = string[255];

     linkTyp = RECORD
                 recP: recPtr;
                 lTyp: Char;
                 next: linkPtr
               END;
	 Longint = Long_Integer;
	 Word    = Integer;

     recTyp  = RECORD
                 lNum   : Integer;
                 call   : String[CallLength];
                 loc    : String[6];
                 freq   : Longint;
                 typ    : Byte;
                 rad    : Word;
                 links  : linkPtr;
                 comment: String[70];
                 next   : recPtr
               END;

VAR LineNum    : Integer;
    recNum     : Integer;
    errcnt     : Integer;
    hierHeap   : ^Integer;
    LastCall   : String[CallLength];
    DatFileName: String[12];
    ErrFileName: String[12];
    Line       : str255;
    dat        : Text;
    err        : Text;
    rem        : Boolean;
    datOpen    : Boolean;
    recRoot    : recPtr;
	nulrec     : recTyp;
	nullink    : linkTyp;
	ParamCount : integer;
	ParamStr   : str255;

procedure gotoxy(x,y: integer);				{ Cursor positionieren }
begin
  write(chr(27),'Y',chr(y+32),chr(x+32));
end;

procedure clreol;                           { bis zum Zeilenende lîschen }
begin
  write(chr(27),'K');
end;

procedure inc(var l: integer);
begin
	l := l + 1;
end;

procedure dec(var l: integer);
begin
	l := l - 1;
end;

function UpCase(c: char):char;
begin
	if (ord(c) > 96) and (ord(c) < 126) then
		UpCase := chr(ord(c)-32) else UpCase := c;
end;
 
PROCEDURE StopIt;				{Bei Chaos: geordnet raus hier}
BEGIN
  IF datOpen THEN Close(dat);
  IF hierHeap<>NIL THEN Release(hierHeap);
  Halt;
END;

PROCEDURE Fehler(code: errTyp; s1,s2: String);	{Fehlernummer in Klartext}
BEGIN
  Inc(errcnt);
  Write(err,LineNum:4,': ');
  CASE code OF
    E_NOCOMMA: Write(err,''','' missing');
    E_NOCALL : Write(err,'Invalid callsign ',s1);
    E_LOCLEN : Write(err,'wrong Locator length');
    E_TYPVAL : Write(err,'Type value error');
    E_TYPERR : Write(err,'Wrong TYPE value ',s1);
    E_FREQVAL: Write(err,'Wrong freq value ',s1);
    E_LINKTYP: Write(err,s1,': wrong linktyp to ',s2);
    E_NOENTRY: Write(err,s1,': no entry');
    E_DOUBLE : Write(err,s1,': double entry');
    E_NOLINK : Write(err,s1,': no link to ',s2);
    E_RADVAL : Write(err,'Wrong RAD entry');
    E_NOLBRA : Write(err,'Missing left brace');
    E_NORBRA : Write(err,'Missing right brace');
    E_NOLCALL: Write(err,'Invalid link callsign',s1);
    E_COMLEN : Write(err,'Too much comment');
	E_NOSORT : Write(err,'Not in alphabetical order');
    ELSE       Write(err,'Unknown error');
  END;
  WriteLn(err);
END;

PROCEDURE trim(VAR s: String);			{ Leerzeichen entfernen }
VAR l: Integer;
BEGIN
  WHILE(s>'') AND (s[1]=' ') DO
    Delete(s,1,1);
  l := Length(s);
  WHILE(l>0) AND (s[l]=' ') DO 
  BEGIN
    Delete(s,l,1);
    dec(l);
  END;
END;

PROCEDURE toUpper(VAR s: String);     { in Groûbuchstaben umwandeln }
VAR i: Integer;
BEGIN
  FOR i:=1 TO Length(s) DO
    s[i]:=UpCase(s[i]);
END;

PROCEDURE Help;							{ wat wohl? }
BEGIN
  writeln('TNX to LX9EG, DC7OS, DH4DAI etc.');
  writeln('See CHKMAP.DOC for more information!');
  writeln;
  writeln('Usage: CHKMAP [/?][filename.ext]',chr(10));

  writeln('Example: CHKMAP               checks DIGIMAP.DAT in the current directory');
  writeln('         CHKMAP filename.ext  checks <filename.ext>');
  writeln('         CHKMAP /?            this help screen',chr(10));
  halt;
END;

PROCEDURE getFileName;                   { Filenamen zusammenbasteln }
VAR fnm: String;
    ext: String;
    p  : Integer;
BEGIN
  IF ParamCount=0 THEN                   { Wenn keine Parameter, dann Default } 
  BEGIN
    fnm:=DefFileName;
    ext:=DefDatExt;
  END
  ELSE 
  BEGIN                                  { sonst: mal sehen, was kommt! }
    Line:=ParamStr;
    IF Line='/?' THEN Help;              { Hilfe gefÑllig? }
    p:=Pos('.',Line);
    IF p=0 THEN 
    BEGIN
      fnm:=Copy(Line,1,8);
      ext:='';
    END
    ELSE 
    BEGIN
      ext:=Copy(Line,p,4);
      IF p>9 THEN p:=9;
      fnm:=Copy(Line,1,Pred(p));
    END;
    toUpper(fnm);
    toUpper(Ext);
  END;
  DatFileName:=concat(fnm,ext);
  ErrFileName:=concat(fnm,DefErrExt);
END;

PROCEDURE CheckLinks;						{ Links checken, ob in Ordnung         }
VAR rec  : recPtr;                          { wen die Funktionsweise interessiert, }
    link : linkPtr;                         { der soll's sich mal aufmalen.        }
    link1: linkPtr;
    exit1: boolean;
    dummy: integer;
BEGIN
  rec:=recRoot^.next;
  WHILE rec<>NIL DO							{ sÑmtliche Links } 
  BEGIN
    LineNum := rec^.lNum;
    gotoxy(0,9); clreol; write(rec^.lNum,':',rec^.call);
    if rec^.lNum = 0 then Fehler(E_NOENTRY,rec^.call,'')
    else
    begin
      link := rec^.links;
      while link <> NIL do
      begin
        gotoxy(21,9); clreol; write(link^.recP^.call);
        if link^.recP^.lNum <> 0 then
        begin
           link1 := link^.recP^.links;
           exit1 := (link1 = NIL);
		   while (link1 <> NIL) and (not exit1) do
           begin
             gotoxy(32,9); clreol; write(link1^.recP^.call);
		     if (link1^.recP <> rec) then link1 := link1^.next
		                             else exit1 := TRUE;
		   end;
  		   if (link1 <> NIL) then
  		   begin
             if (link1^.recP <> rec) then
               Fehler(E_NOLINK,rec^.call,link^.recP^.call)
	   	     else
		       if link1^.lTyp <> link^.lTyp then
		         Fehler(E_LINKTYP,rec^.call,link^.recP^.call);
		   end
		   else Fehler(E_NOLINK,rec^.call,link^.recP^.call);
		end
        else Fehler(E_NOLINK,rec^.call,link^.recP^.call);
        link := link^.next;
      end;
    end;
    rec := rec^.next;
  end;
end;

FUNCTION invalidCall(s: String ): Boolean;	{ Rufzeichen checken }
VAR i,l   : Integer;
    isCall: Boolean;
BEGIN
  isCall:=True;
  i:=1;
  l:=Length(s);
  WHILE(i<=l) AND isCall DO 
  BEGIN                                     { nur provisorisch; ausbaufÑhig! }
    isCall:=s[i] IN ['0'..'9','A'..'Z','-'];
    Inc(i);
  END;
  invalidCall:=NOT isCall
END;

FUNCTION findCall(call: String ): recPtr;		{ Call suchen }
VAR rPre, rAct: recPtr;
    found     : boolean;
BEGIN
{  call:=Copy(call,1,CallLength);}
  rPre:=recRoot;
  rAct:=rPre^.next;
  found := false;
  WHILE ((rAct<>NIL) and (not found)) DO
    if (rAct^.call <=  call) then
	BEGIN
      rPre:=rAct;
      rAct:=rPre^.next
    END
	else found := true; 
  IF call=rPre^.call THEN findCall:=rPre
  ELSE 
  BEGIN
    New(rAct);
    rAct^:=nulrec;
    rAct^.call:=call;
    rAct^.next:=rPre^.next;
    rPre^.next:=rAct;
    findCall:=rAct;
  END;
END;

PROCEDURE Decode(Line: str255);				{ Daten aufdrîseln }
label 1;
VAR Line1      : str255;
    Line2      : str255;
    rec        : recPtr;
    link       : linkPtr;
    link1      : linkPtr;
    p          : Integer;
    valCode    : Integer;
    value      : Real;
   SpecialLinks: SET OF Char;

 PROCEDURE MoveLine;						{ Zeile aufteilen }
 BEGIN
   Line1:=Copy(Line,1,Pred(p));
   trim(Line1);
   Delete(Line,1,p);
 END;

 function min(x,y: integer):integer;
 begin
   if x<y then min := x else min := y;
 end;

 procedure Val(s: string; var wert: real; err: integer); { String in real }
 var i: integer;
 begin
   err := 0;
   for i := 1 to length(s) do if not (s[i] in ['0'..'9','.']) then err := 1;
   if err = 0 then readv(s,wert);
 end;
 
BEGIN
  SpecialLinks := ['$','@','#','?','!','&','%'];
  p:=Pos(',',Line);                               { Rufzeichen ÅberprÅfen }
  IF p>10 THEN
  BEGIN
    Fehler(E_NOCOMMA,'','');
    goto 1;
  END;
  MoveLine;
  toUpper(Line1);
  IF invalidCall(Line1)= true THEN 
  BEGIN
    Fehler(E_NOCALL,Line1,'');
    goto 1;
  END;
  rec:=findCall(Line1);
  IF rec^.call=LastCall THEN Fehler(E_DOUBLE,Line1,'');
  if rec^.call<LastCall THEN Fehler(E_NOSORT,'','');
  LastCall:=rec^.call;
  rec^.lNum:=LineNum;
  p:=Pos(',',Line);                                  { Locator prÅfen }
  IF p>7 THEN 
  BEGIN
    Fehler(E_NOCOMMA,'','');
    goto 1;
  END;
  MoveLine;
  p:=Length(Line1);
  IF ((p<>6) and (p <>0)) THEN 
  BEGIN
    Fehler(E_LOCLEN,'','');
    goto 1;
  END;
  rec^.loc:=Line1;
  p:=Pos(',',Line);                                { Typ prÅfen }
  IF p <> 2 THEN 
  BEGIN
    Fehler(E_NOCOMMA,'','');
    goto 1;
  END;
  MoveLine;
  Val(Line1,value,valCode);
  IF valCode<>0 THEN 
  BEGIN
    Fehler(E_TYPVAL,'','');
    goto 1;
  END;
  IF(value<1) OR (value>5) THEN 
  BEGIN
    Fehler(E_TYPERR,Line1,'');
    goto 1;
  END;
  rec^.typ:=trunc(value);
  p:=Pos(',',Line);                           { Frequenz prÅfen }
  IF p>9 THEN 
  BEGIN
    Fehler(E_NOCOMMA,'','');
    goto 1;
  END;
  MoveLine;
  IF Line1='' THEN rec^.freq:=0
  ELSE 
  BEGIN
    Val(Line1,value,valCode);
    IF valCode<>0 THEN 
    BEGIN
      Fehler(E_FREQVAL,'','');
      goto 1;
    END;
    value := value * 1000;
    rec^.freq:=long_trunc(value)
  END;
  p:=Pos(',',Line);                                  { Hmm?! }
  IF p>3THEN 
  BEGIN
    Fehler(E_NOCOMMA,'','');
    goto 1;
  END;
  MoveLine; 
  IF Line1='' THEN 
  rec^.rad:=0
  ELSE 
  BEGIN
    Val(Line1,value,valCode);
    IF valCode<>0 THEN 
    BEGIN
      Fehler(E_RADVAL,'','');
      goto 1;
    END;
    rec^.rad:=Trunc(value)
  END;
  trim(Line);								{ Linkliste aufbauen }
  IF Line[1]<>'(' THEN 
  BEGIN
    Fehler(E_NOLBRA,'','');
    goto 1
  END;
  Delete(Line,1,1);
  p:=Pos(')',Line);
  IF p=0 THEN 
  BEGIN
    Fehler(E_NORBRA,'','');
    goto 1
  END;
  MoveLine;
  Line1:=concat(Line1,',');
  p:=Pos(',',Line1);
  WHILE p>1 DO 
  BEGIN
    New(link);
    link^:=nullink;
    IF rec^.links=NIL
      THEN rec^.links:=link
      ELSE link1^.next:=link;
    link1:=link;
    Line2:=Copy(Line1,1,Pred(p));
    trim(Line2);
    toUpper(Line2);
    Delete(Line1,1,p);
    p:=Length(Line2);
    link^.lTyp:=Line2[p];
    IF link^.lTyp IN SpecialLinks THEN Delete(Line2,p,1)
                                  ELSE link^.lTyp:=' ';
    IF invalidCall(Line2) = TRUE THEN 
    BEGIN
      Fehler(E_NOLCALL,Line2,'');
      goto 1;
    END;
    link^.recP:=findCall(Line2);
    p:=Pos(',',Line1);
  END;
  p:=Pos(',',Line);								{ Kommentar vorhanden ?}
  IF p=0 THEN 
  BEGIN
    Fehler(E_NOCOMMA,'','');
    goto 1;
  END;
  Delete(Line,1,p);
  trim(Line);
  IF Length(Line)>70 THEN 
  BEGIN
    Fehler(E_COMLEN,'','');
    goto 1;
  END;
  rec^.comment:=Line;
1:
 END;

BEGIN
  writeln(chr(27),'f',chr(27),'EChkMap V1.0c ST');
  ParamCount := cmd_args;                                    { Init }
  if ParamCount >= 1 then cmd_getarg(ParamCount,ParamStr);
  nulrec.lNum   := 0;
  nulrec.call   := '';
  nulrec.loc    := '';
  nulrec.freq   := 0;
  nulrec.typ    := 0;
  nulrec.rad    := 0;
  nulrec.links  := NIL;
  nulrec.comment:= '';
  nulrec.next   := NIL;
  nullink.recP  := NIL;
  nullink.lTyp  := ' ';
  nullink.next  := NIL;


  datOpen:=False;
  hierHeap:=NIL;

  getFileName;

  io_check(false);
  Reset(dat,DatFileName);
  IF io_result <> 0 THEN 
  BEGIN
  	io_check(true);
    WriteLn('File ',DatFileName,' not found');
    StopIt;
  END
  else io_check(true);
  datOpen:=True;

  errcnt:=0;                                   { Nun geht's los! }
  Rewrite(err,ErrFileName);
  WriteLn(err,'General errors');
  WriteLn(err);

  Mark(hierHeap);
  New(recRoot);
  recRoot^:=nulrec;
  recRoot^.call:='      ';

  LineNum:=0;
  recNum:=0;
  WriteLn('Processing ',DatFileName);
  WHILE NOT Eof(dat) DO 
  BEGIN
    rem:=False;
    Inc(LineNum);
    ReadLn(dat,Line);                    { Daten zeilenweise einlesen }
    gotoxy(1,4);write(LineNum);
    trim(Line);
    IF Line[1]='#' THEN                  { Kommentare interessieren nicht }
      rem:=True
    else
	begin                                { ansonsten: bearbeiten }
	  Inc(recNum);
      Decode(Line);
    end;
  END;
  Close(dat);
  gotoxy(1,4);                           { kleine Statistik ausgeben }
  Write(recNum,' records in ',LineNum,' lines   => ');
  writeln(round((recNum/LineNum)*100),'%');
  IF errcnt>0
    THEN WriteLn(errcnt,' errors found   ',round((errcnt/recNum)*100),'%')
    ELSE 
    BEGIN                                { falls keine Fehler, }
      gotoxy(0,8); write('Check Link list'); { Links Checken   }
      WriteLn(err,'Linklist errors');
      WriteLn(err);
      CheckLinks;
      IF errcnt>0 THEN                   { Fehler gefunden ?   } 
      begin
        gotoxy(0,9);
        clreol;
        gotoxy(1,9);
        WriteLn(errcnt,' linklist errors found')
      end;
    END;

  Close(err);
  write(chr(27),'e');
  IF errcnt>0                            { Hinweis auf Fehler  }
    THEN WriteLn(#10,'(See ',ErrFileName,' for Details)')
    ELSE 
    begin
      WriteLn(#10,'No errors found');
      erase(err);
    end;
  Release(hierHeap);
  write(#10,#10,'Press >RETURN< to continue '); readln;
END.

