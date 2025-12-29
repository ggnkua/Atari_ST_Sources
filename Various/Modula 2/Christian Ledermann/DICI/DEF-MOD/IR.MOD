IMPLEMENTATION MODULE ir;
FROM Konjugation IMPORT Vokabel,MaxLength;
FROM pSTRING IMPORT SLEN,DELETE,APPEND,ASSIGN, INSERT;

PROCEDURE MakeIr(VAR Verb:Vokabel):BOOLEAN;
VAR i,j : CARDINAL;

BEGIN
   i:=SLEN(Verb.Portugiesisch);
   IF i<2 THEN RETURN FALSE END(*IF*);
   IF (Verb.Portugiesisch[i-1]#'r') OR (Verb.Portugiesisch[i-2]#'i') THEN
      RETURN FALSE
   ELSE
      FOR j:=1 TO 6 DO
        ASSIGN(Verb.Portugiesisch,Verb.Person[j].Stamm);
        DELETE((i-2),2,Verb.Person[j].Stamm);
      END(*FOR*);
      Verb.Endung := 'ir';
   END(*IF*);
   RETURN TRUE
END MakeIr;

PROCEDURE IndPraes(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   IF ~MakeIr(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Pr„sens';
   DasVerb.PersonSingular[1].Endung:='o';
   DasVerb.PersonSingular[2].Endung:='es';
   DasVerb.PersonSingular[3].Endung:='e';
   DasVerb.PersonPlural[1].Endung:='imos';
   DasVerb.PersonPlural[2].Endung:='is';
   DasVerb.PersonPlural[3].Endung:='em';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END IndPraes;

PROCEDURE IndImperf(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   IF ~MakeIr(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Imperfekt';
   DasVerb.PersonSingular[1].Endung:='ia';
   DasVerb.PersonSingular[2].Endung:='ias';
   DasVerb.PersonSingular[3].Endung:='ia';
   DasVerb.PersonPlural[1].Endung:='¡amos';
   DasVerb.PersonPlural[2].Endung:='¡eis';
   DasVerb.PersonPlural[3].Endung:='iam';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END IndImperf;
PROCEDURE PPS(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   IF ~MakeIr(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='(einf) Perfekt';
   DasVerb.PersonSingular[1].Endung:='i';
   DasVerb.PersonSingular[2].Endung:='iste';
   DasVerb.PersonSingular[3].Endung:='iu';
   DasVerb.PersonPlural[1].Endung:='imos';
   DasVerb.PersonPlural[2].Endung:='istes';
   DasVerb.PersonPlural[3].Endung:='iram';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END PPS;
PROCEDURE Futur(VAR DasVerb : Vokabel):BOOLEAN;
VAR i : CARDINAL;
BEGIN
   IF ~MakeIr(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Futur I';
   FOR i:=1 TO 6 DO
     APPEND('ir',DasVerb.Person[i].Stamm);
   END(*FOR*);
   DasVerb.PersonSingular[1].Endung:='ei';
   DasVerb.PersonSingular[2].Endung:=' s';
   DasVerb.PersonSingular[3].Endung:=' ';
   DasVerb.PersonPlural[1].Endung:='emos';
   DasVerb.PersonPlural[2].Endung:='eis';
   DasVerb.PersonPlural[3].Endung:='°o';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END Futur;
PROCEDURE Konditional(VAR DasVerb : Vokabel):BOOLEAN;
VAR i : CARDINAL;
BEGIN
   IF ~MakeIr(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Konditional';
   FOR i:=1 TO 6 DO
     APPEND('ir',DasVerb.Person[i].Stamm);
   END(*FOR*);
   DasVerb.PersonSingular[1].Endung:='ia';
   DasVerb.PersonSingular[2].Endung:='ias';
   DasVerb.PersonSingular[3].Endung:='ia';
   DasVerb.PersonPlural[1].Endung:='¡amos';
   DasVerb.PersonPlural[2].Endung:='¡es';
   DasVerb.PersonPlural[3].Endung:='iam';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END Konditional;

PROCEDURE KonjPraes(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   IF ~MakeIr(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Konj. Pr„sens';
   DasVerb.PersonSingular[1].Endung:='a';
   DasVerb.PersonSingular[2].Endung:='as';
   DasVerb.PersonSingular[3].Endung:='a';
   DasVerb.PersonPlural[1].Endung:='amos';
   DasVerb.PersonPlural[2].Endung:='ais';
   DasVerb.PersonPlural[3].Endung:='am';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END KonjPraes;
PROCEDURE KonjImperf(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   IF ~MakeIr(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Konj. Imperfekt';
   DasVerb.PersonSingular[1].Endung:='isse';
   DasVerb.PersonSingular[2].Endung:='isses';
   DasVerb.PersonSingular[3].Endung:='isse';
   DasVerb.PersonPlural[1].Endung:='¡ssemos';
   DasVerb.PersonPlural[2].Endung:='¡sseis';
   DasVerb.PersonPlural[3].Endung:='issem';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END KonjImperf;
PROCEDURE Partizip(VAR DasVerb : Vokabel):BOOLEAN;
VAR i : CARDINAL;
BEGIN
   IF ~MakeIr(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Partizipien';
   DasVerb.PersonSingular[1].Endung:='indo';
   DasVerb.PersonSingular[2].Endung:='ido';
   FOR i:=3 TO 6 DO
      DasVerb.Person[i].Stamm:='';
      DasVerb.Person[i].Endung:='';
   END(*FOR*);
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END Partizip;
PROCEDURE Imperativ(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   IF ~MakeIr(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Imperativ';
   DasVerb.PersonSingular[1].Endung:='e';
   DasVerb.PersonSingular[2].Endung:='as';
   DasVerb.PersonSingular[3].Endung:='a';
   DasVerb.PersonPlural[1].Endung:='amos';
   DasVerb.PersonPlural[2].Endung:='i';
   DasVerb.PersonPlural[3].Endung:='am';
   INSERT(0,'n°o ',DasVerb.PersonSingular[2].Stamm);
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END Imperativ;
END ir.
