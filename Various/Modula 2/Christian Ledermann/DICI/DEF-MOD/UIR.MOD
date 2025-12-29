IMPLEMENTATION MODULE uir;
FROM Konjugation IMPORT Vokabel,MaxLength;
FROM pSTRING IMPORT SLEN,DELETE,APPEND,ASSIGN;
IMPORT ir;
PROCEDURE MakeUir(VAR Verb:Vokabel):BOOLEAN;
VAR i,j : CARDINAL;

BEGIN
   i:=SLEN(Verb.Portugiesisch);
   IF i<3 THEN RETURN FALSE END(*IF*);
   IF (Verb.Portugiesisch[i-1]#'r') OR
      (Verb.Portugiesisch[i-2]#'i') OR
      (Verb.Portugiesisch[i-3]#'u')THEN
      RETURN FALSE
   ELSE
      FOR j:=1 TO 6 DO
        ASSIGN(Verb.Portugiesisch,Verb.Person[j].Stamm);
        DELETE((i-3),3,Verb.Person[j].Stamm);
      END(*FOR*);
      Verb.Endung := 'uir';
   END(*IF*);
   RETURN TRUE
END MakeUir;

PROCEDURE IndPraes(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   IF ~MakeUir(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Pr„sens';
   DasVerb.PersonSingular[1].Endung:='uo';
   DasVerb.PersonSingular[2].Endung:='uis';
   DasVerb.PersonSingular[3].Endung:='ui';
   DasVerb.PersonPlural[1].Endung:='u¡mos';
   DasVerb.PersonPlural[2].Endung:='u¡s';
   DasVerb.PersonPlural[3].Endung:='uem';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END IndPraes;
PROCEDURE IndImperf(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
  RETURN ir.IndImperf(DasVerb);
END IndImperf;
PROCEDURE PPS(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   IF ~MakeUir(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='(einf) Perfekt';
   DasVerb.PersonSingular[1].Endung:='u¡';
   DasVerb.PersonSingular[2].Endung:='u¡ste';
   DasVerb.PersonSingular[3].Endung:='u¡u';
   DasVerb.PersonPlural[1].Endung:='u¡mos';
   DasVerb.PersonPlural[2].Endung:='u¡stes';
   DasVerb.PersonPlural[3].Endung:='u¡ram';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END PPS;
PROCEDURE Futur(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   RETURN ir.Futur(DasVerb);
END Futur;
PROCEDURE Konditional(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
  RETURN ir.Konditional(DasVerb);
END Konditional;
PROCEDURE KonjPraes(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   RETURN ir.KonjPraes(DasVerb);
END KonjPraes;
PROCEDURE KonjImperf(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   RETURN ir.KonjImperf(DasVerb);
END KonjImperf;
PROCEDURE Partizip(VAR DasVerb : Vokabel):BOOLEAN;
VAR i : CARDINAL;
BEGIN
   IF ~MakeUir(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Partizipien';
   DasVerb.PersonSingular[1].Endung:='u¡ndo';
   DasVerb.PersonSingular[2].Endung:='u¡do';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   FOR i:=3 TO 6 DO
      DasVerb.Person[i].Stamm:='';
      DasVerb.Person[i].Endung:='';
   END(*FOR*);
   RETURN TRUE
END Partizip;
PROCEDURE Imperativ(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
    RETURN ir.Imperativ(DasVerb);
END Imperativ;
END uir.
