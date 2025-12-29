MODULE TestBBaum;
FROM BTree IMPORT CreateBase,StartBase,First, Last,Next, Previous,
 		  SearchFirst,SearchNext,PagePtr,CloseBase,FileOf,
		  PrintTree, InsertData, DeleteData, KeyType,DataType;
FROM InOut IMPORT ReadString, WriteString, ReadCard, Read, WriteInt, WriteLn;

FROM SYSTEM IMPORT LONG,SHORT;

VAR Index, DataBase : FileOf;

PROCEDURE domain;
VAR ch1,
    ch2,
    ch3 : CHAR;
    key : CARDINAL;
    data : DataType;
    tree : PagePtr;
    i,
    anz : INTEGER;
    lkey,lkey1 : KeyType;

BEGIN
   lkey := 0D;
   REPEAT
   tree := 0D;
   WriteLn;
   WriteString('Testumgebung fÅr BayerbÑume ');
   WriteLn;
   WriteString('1 EinfÅgen ');WriteLn;
   WriteString('2 Loeschen');WriteLn;
   WriteString('3 suchen ');WriteLn;
   
   WriteString('4 Baumausgabe');WriteLn;
   WriteString('5 Neue Datei (loeschen aller Daten) ');WriteLn;
(*   WriteString('6 Random-Daten einfÅgen ');WriteLn;*)
   WriteString('7 Erster Schluessel ');WriteLn;
   WriteString('8 Letzter Schluessel ');WriteLn;
   WriteString('9 NÑchster Schluessel ');WriteLn;
   WriteString('a voriger Schluessel ');WriteLn;
   WriteLn;
   WriteString('0 Beenden ');WriteLn;
   WriteLn;
   WriteString(' Ihre Wahl ->'); Read(ch1);
   WriteLn;
   WriteLn;
   CASE ch1 OF
     '1' :
             WriteLn;
             WriteLn;
             WriteString('einfÅgen');
             WriteLn;
             WriteString('SchlÅssel (INTEGER)? ');
             ReadCard(key); WriteLn;
             WriteString('Daten (String)? ');
             ReadString(data.Inhalt); WriteLn;
             InsertData(Index, DataBase,LONG(key),data);
             lkey := LONG(key);
             WriteString(' daten eigefÅgt !');WriteLn;
             Read(ch3);
     | '2' :
              WriteLn;
              WriteLn;
              WriteString('Lîschen ');
              WriteLn;
              WriteString('Welcher Schluessel?');
              ReadCard(key); WriteLn;
              lkey := LONG(key);
  
              IF NOT DeleteData(Index, DataBase,LONG(key)) THEN
                 WriteString('Dieser Schluessel existiert nicht!')
              ELSE
                 WriteString('Eintrag geloescht');
              END(*IF*);
              Read(ch3);
      |'3' :
                WriteLn;
                WriteLn;
                WriteString('Suche');
                WriteLn;
                WriteString('Schuessel (INTEGER) ?');
                ReadCard(key);
                lkey := LONG(key);

                WriteLn;
                IF SearchFirst(Index, DataBase,LONG(key),data) THEN
                  WriteString('('); WriteString(data.Inhalt);
                   WHILE SearchNext(Index, DataBase,data)  DO
                       WriteString('\');WriteString(data.Inhalt);
                   END(*WHILE*);
                   WriteString(')'); WriteLn;
                   WriteString('Ausgabe beendet ');WriteLn;
                ELSE
                  WriteString('Eintrag nicht gefunden !');
                END(*IF*);
                WriteLn;
                Read(ch3);
      |'4' :
                WriteLn;
                WriteLn;
                WriteString('Ausgabe des gesammten Baumes: ');
                WriteLn;
		PrintTree(Index, DataBase,tree,1);
		WriteLn;
                WriteString('Ausgabe fertig ');
                Read(ch3);WriteLn;

      |'5' :
	      CreateBase(Index, DataBase);
	      StartBase(Index, DataBase);
      |'6' :
        (*     WriteLn;WriteLn;
             WriteLn('ZufallsZahlen einfÅgen');
             WriteLn;
             Write('Anzahl?');Readln(anz);
             FOR i:= 1 TO anz DO
                key:= random;
				WriteLn('key',key);
                data := random;
                WriteLn('data',data);
                InsertData(key,data);
             END(*FOR*);
             WriteLn('EinfÅgen abgeschlossen');
             Readln(ch3);*)
             WriteLn;
       |'7' :
                WriteLn;
                WriteLn;
                WriteString(' Erster Schluessel ');
                WriteLn;
		First(Index,DataBase,lkey,data);
		WriteInt(SHORT(lkey),5);
		 WriteString('('); WriteString(data.Inhalt);
                   WHILE SearchNext(Index, DataBase,data)  DO
                       WriteString('\');WriteString(data.Inhalt);
                   END(*WHILE*);
                   WriteString(')'); WriteLn;
		WriteLn;
                WriteString('Ausgabe fertig ');
                Read(ch3);WriteLn;
        |'8' :
                WriteLn;
                WriteLn;
                WriteString(' Letzter Schluessel ');
                WriteLn;
		Last(Index,DataBase,lkey,data);
 		WriteInt(SHORT(lkey),5);
		 WriteString('('); WriteString(data.Inhalt);
                   WHILE SearchNext(Index, DataBase,data)  DO
                       WriteString('\');WriteString(data.Inhalt);
                   END(*WHILE*);
                   WriteString(')'); WriteLn;
		WriteLn;
		WriteLn;
                WriteString('Ausgabe fertig ');
                Read(ch3);WriteLn;  
       |'9' :
                WriteLn;
                WriteLn;
                WriteString(' NÑchster Schluessel ');
     		WriteInt(SHORT(lkey),5);
                WriteLn; lkey1 := lkey;
		IF Next(Index,DataBase,lkey1,lkey,data) THEN
		WriteInt(SHORT(lkey),5);
		 WriteString('('); WriteString(data.Inhalt);
                   WHILE SearchNext(Index, DataBase,data)  DO
                       WriteString('\');WriteString(data.Inhalt);
                   END(*WHILE*);
                   WriteString(')'); WriteLn;
                 ELSE
                   WriteString('Kein Nachfolger'); 
                 END(*IF*);  
		WriteLn;
		WriteLn;
                WriteString('Ausgabe fertig ');
                Read(ch3);WriteLn; 
       |'a' :
                WriteLn;
                WriteLn;
                WriteString(' Voriger Schluessel ');
     		WriteInt(SHORT(lkey),5);
                WriteLn; lkey1 := lkey;
		IF Previous(Index,DataBase,lkey1,lkey,data) THEN
		WriteInt(SHORT(lkey),5);
		 WriteString('('); WriteString(data.Inhalt);
                   WHILE SearchNext(Index, DataBase,data)  DO
                       WriteString('\');WriteString(data.Inhalt);
                   END(*WHILE*);
                   WriteString(')'); WriteLn;
                 ELSE
                   WriteString('Kein Nachfolger'); 
                 END(*IF*);  
		WriteLn;
		WriteLn;
                WriteString('Ausgabe fertig ');
                Read(ch3);WriteLn;                                 
   ELSE
      ;
   END(*CASE*);
   UNTIL ch1='0';
END  domain;



BEGIN
   DataBase.Name :='TEST.DBF';
   Index.Name :='TEST.NDX';
  (* CreateBase;*)
   StartBase(Index, DataBase);
   domain;
   CloseBase(Index, DataBase);
END TestBBaum.
