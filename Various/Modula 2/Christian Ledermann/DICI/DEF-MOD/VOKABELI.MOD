IMPLEMENTATION MODULE VokabelImport;
FROM InOut IMPORT Done,ReadLine;
FROM pSTRING IMPORT SLEN, ASSIGN, APPEND,APPENDCHR, EQUALN, 
             COPY,LPOSCHRSET;
FROM BTree IMPORT DataType;             
FROM SYSTEM IMPORT VAL;(* leider *)

PROCEDURE ClearData(VAR Data : DataType);
VAR i,j : INTEGER;
BEGIN 
   FOR i:=0 TO HIGH(Data.Inhalt) DO
       FOR j:=0 TO HIGH(Data.Inhalt[i]) DO
          Data.Inhalt[i,j] := 0C
       END(*FOR*);
   END(*FOR*);
END ClearData;          

PROCEDURE StTrans(GetData : ImportProc);
			
VAR Data : DataType;	
    InLine : ARRAY [0..80] OF CHAR; 
    i : CARDINAL;		
BEGIN
   ClearData(Data);
   InLine := '';
   WHILE Done  DO
       i :=1;			
       ReadLine(InLine); (* erster Eintrag *)
       IF EQUALN(4,InLine,'-----') THEN RETURN END(*IF*); (* Das Ende wird mit ---- gekennzeichnet *)
       REPEAT
	   APPENDCHR(' ',InLine);
       UNTIL   SLEN(InLine) > 6 ;       
       ASSIGN(InLine,Data.Inhalt[0]);
       ReadLine(InLine); (* in der Zweiten Zeile steht nichts interesantes *)
       ReadLine(InLine);
       WHILE ~EQUALN(4,InLine,'-----') AND Done DO
          REPEAT
              APPENDCHR(' ',InLine);
          UNTIL   SLEN(InLine) > 6 ;
          ASSIGN(InLine,Data.Inhalt[i]);
          ReadLine(InLine);
          i:= i+1;
       END(*WHILE*);   
       GetData(Data);
       ClearData(Data);
   END(*WHILE*);
END StTrans;			

PROCEDURE VocMan(GetData : ImportProc);
VAR Data : DataType;
    Rechts, Links, i : INTEGER;		
    fertig : BOOLEAN;
    InLine, Buffer : ARRAY [0..80] OF CHAR;
BEGIN
  ClearData(Data);
  InLine:=''; Buffer := '';
  ReadLine(InLine);
  WHILE Done DO
     Rechts :=0;Links:=0;
     Rechts := LPOSCHRSET(Links,'0123456789',InLine);
     COPY(Links,(Rechts),InLine,Data.Inhalt[0]);
     WHILE  SLEN(Data.Inhalt[0]) < 6 DO
           APPENDCHR(' ',Data.Inhalt[0]);
     END(*WHILE*);
     i := 1;
     LOOP
        fertig := FALSE;
        Links := Rechts; 
        Rechts := LPOSCHRSET(Links,'0123456789',InLine)+1;
        IF Rechts <= 0 (* Keine Weitere Ziffer im String *) THEN
           Rechts := SLEN(InLine)+2; fertig:= TRUE (* Bis zum Ende des Strings kopieren und Schluž *)
        END(*IF*);
        COPY(Links,(Rechts-Links),InLine,Buffer);
        IF ( VAL(CARDINAL,Rechts) < SLEN(InLine)) THEN
           APPENDCHR(';',Buffer);
        END(*IF*);
        REPEAT
           APPENDCHR(' ',Buffer);
        UNTIL   SLEN(Buffer) > 6 ;
        IF (SLEN(Data.Inhalt[i])+SLEN(Buffer) < 40) THEN
           APPEND(Buffer,Data.Inhalt[i]);
        ELSE
           i:= i+1;
           Buffer:='';
           IF i> HIGH(Data.Inhalt) THEN HALT; EXIT; END(*IF*);
           (* unsauber aber bis jetzt reichts *)
        END(*IF*);                       
        ASSIGN(Buffer,Data.Inhalt[i]);
        IF fertig THEN EXIT; END(*IF*);
     END(*LOOP*);
     GetData(Data);
     ClearData(Data);
     ReadLine(InLine);
  END(*WHILE*);
END VocMan;

END VokabelImport. 