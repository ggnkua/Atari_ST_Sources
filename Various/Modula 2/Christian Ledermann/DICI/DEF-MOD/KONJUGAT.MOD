IMPLEMENTATION MODULE Konjugation;
FROM pSTRING IMPORT ASSIGN,SLEN;

PROCEDURE MaxLength(DieVokabel: Vokabel): CARDINAL;			
VAR Length,i : CARDINAL;

  PROCEDURE newmax(String1,String2 : ARRAY  OF CHAR);
  BEGIN 
    IF (SLEN(String1)+SLEN(String2))>Length THEN
       Length:=SLEN(String1)+SLEN(String2);
    END(*IF*);
  END newmax;     
  
BEGIN   
   Length := 0;
   FOR i:=1 TO 6 DO
      newmax(DieVokabel.Person[i].Stamm,DieVokabel.Person[i].Endung);
   END(*FOR*);
   newmax(DieVokabel.Deutsch,'');
   newmax(DieVokabel.Portugiesisch,''); 
   newmax(DieVokabel.Zeit,''); 
   RETURN Length
END MaxLength;

PROCEDURE SetVokabel(Deutsch, Portugiesisch : ARRAY OF CHAR;
		     VAR DieVokabel : Vokabel);		  
VAR i : CARDINAL;
BEGIN
    ASSIGN(Deutsch,DieVokabel.Deutsch);		     
    ASSIGN(Portugiesisch,DieVokabel.Portugiesisch);		     
    DieVokabel.Endung:='';
    DieVokabel.Zeit:='';
    FOR i:=1 TO 6 DO
      DieVokabel.Person[i].Stamm:='';
      DieVokabel.Person[i].Endung:='';
    END(*FOR*);
    i:=SLEN(Deutsch);
    IF i>0 THEN (* falls es etwas zum abschneiden gibt *)
       WHILE DieVokabel.Deutsch[i-1]=' ' DO (* Blanks abschneiden *)			
          DieVokabel.Deutsch[i-1] :=0C;
          DEC(i,1)
      END(*WHILE*);
    END(*IF*);  
    i:=SLEN(Portugiesisch);
    IF i>0 THEN
      WHILE DieVokabel.Portugiesisch[i-1]=' ' DO			
          DieVokabel.Portugiesisch[i-1] :=0C;
          DEC(i,1)
      END(*WHILE*);
    END(*IF*);  
    DieVokabel.MaxLen:= MaxLength(DieVokabel);
END SetVokabel;
 
END Konjugation.