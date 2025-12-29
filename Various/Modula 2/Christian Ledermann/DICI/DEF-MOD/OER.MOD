IMPLEMENTATION MODULE oer;
FROM Konjugation IMPORT Vokabel,MaxLength;
FROM pSTRING IMPORT SLEN,DELETE,APPEND,ASSIGN;
IMPORT er;
PROCEDURE MakeOer(VAR Verb:Vokabel):BOOLEAN;
VAR i,j : CARDINAL;

BEGIN
   i:=SLEN(Verb.Portugiesisch);
   IF i<3 THEN RETURN FALSE END(*IF*);
   IF (Verb.Portugiesisch[i-1]#'r') OR
      (Verb.Portugiesisch[i-2]#'e') OR
      (Verb.Portugiesisch[i-3]#'o')THEN
      RETURN FALSE
   ELSE
      FOR j:=1 TO 6 DO
        ASSIGN(Verb.Portugiesisch,Verb.Person[j].Stamm);
        DELETE((i-3),3,Verb.Person[j].Stamm);
      END(*FOR*);
      Verb.Endung := 'oer';
   END(*IF*);
   RETURN TRUE
END MakeOer;

PROCEDURE IndPraes(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   IF ~MakeOer(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Pr„sens';
   DasVerb.PersonSingular[1].Endung:='oo';
   DasVerb.PersonSingular[2].Endung:='¢is';
   DasVerb.PersonSingular[3].Endung:='¢i';
   DasVerb.PersonPlural[1].Endung:='oemos';
   DasVerb.PersonPlural[2].Endung:='oeis';
   DasVerb.PersonPlural[3].Endung:='oem';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END IndPraes;
PROCEDURE IndImperf(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
  RETURN er.IndImperf(DasVerb);
END IndImperf;
PROCEDURE PPS(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   IF ~MakeOer(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='(einf) Perfekt';
   DasVerb.PersonSingular[1].Endung:='o¡';
   DasVerb.PersonSingular[2].Endung:='oeste';
   DasVerb.PersonSingular[3].Endung:='oeu';
   DasVerb.PersonPlural[1].Endung:='oemos';
   DasVerb.PersonPlural[2].Endung:='oestes';
   DasVerb.PersonPlural[3].Endung:='oeram';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END PPS;
PROCEDURE Futur(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   RETURN er.Futur(DasVerb);
END Futur;
PROCEDURE Konditional(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
  RETURN er.Konditional(DasVerb);
END Konditional;
PROCEDURE KonjPraes(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
    RETURN er.KonjImperf(DasVerb);
END KonjPraes;
PROCEDURE KonjImperf(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   RETURN er.KonjImperf(DasVerb);
END KonjImperf;
PROCEDURE Partizip(VAR DasVerb : Vokabel):BOOLEAN;
VAR i : CARDINAL;
BEGIN
   IF ~MakeOer(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Partizipien';
   DasVerb.PersonSingular[1].Endung:='o¡ndo';
   DasVerb.PersonSingular[2].Endung:='o¡do';
   FOR i:=3 TO 6 DO
      DasVerb.Person[i].Stamm:='';
      DasVerb.Person[i].Endung:='';
   END(*FOR*);
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END Partizip;
PROCEDURE Imperativ(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
    RETURN er.Imperativ(DasVerb);
END Imperativ;
END oer.
