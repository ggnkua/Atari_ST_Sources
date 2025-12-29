IMPLEMENTATION MODULE Upper2LC;

FROM SYSTEM IMPORT LONG, VAL, SHIFT, SHORT;


PROCEDURE MakeLongCard(InString : ARRAY OF CHAR): LONGCARD; 
VAR i : INTEGER;
    l : LONGCARD; 
    l1 : LONGCARD; 
BEGIN
    l:= 0D;
    FOR i:=0 TO 5 DO
        IF (InString[i] >= 'A') AND (InString[i] <= 'Z') AND (i <= HIGH(InString)) THEN
              l1 := LONG(ORD(InString[i])-64);(* A=1, B=2,...*)
              l := l+l1;
        ELSE (* Alle Zeichen die keine Grožbuchstaben sind werden zu 0 *)
             l1:=0D; 
        END(*IF*);
        IF i<5 THEN
           l:= SHIFT(l,+5);
        END(*IF*);   
    END(*FOR*);
    RETURN l
END MakeLongCard;

PROCEDURE MakeString( LongCard : LONGCARD; VAR OutString : ARRAY OF CHAR);
VAR i : INTEGER;
    l : LONGCARD; 
BEGIN
   IF HIGH(OutString) > 5 THEN
     FOR i:=5 TO 0 BY -1  DO
         l := (LongCard) MOD 32D;
         IF l#0D THEN
            OutString[i] := CHR(SHORT(l)+64);
         ELSE
            OutString[i] :=' ';
         END(*IF*);      
         LongCard := SHIFT(LongCard,-5);
     END(*FOR*);    
     OutString[6]:=0C
   ELSE
     OutString[0]:=0C 
   END(*IF*);  
END MakeString;

BEGIN
END Upper2LC.