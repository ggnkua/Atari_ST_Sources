IMPLEMENTATION MODULE uzir;
FROM Konjugation IMPORT Vokabel,MaxLength;
FROM pSTRING IMPORT SLEN,DELETE,APPEND,ASSIGN;
IMPORT ir;
PROCEDURE MakeUzir(VAR Verb:Vokabel):BOOLEAN;
VAR i,j : CARDINAL;

BEGIN
   i:=SLEN(Verb.Portugiesisch);
   IF i<4 THEN RETURN FALSE END(*IF*);
   IF (Verb.Portugiesisch[i-1]#'r') OR
      (Verb.Portugiesisch[i-2]#'i') OR
      (Verb.Portugiesisch[i-3]#'z') OR
      (Verb.Portugiesisch[i-4]#'u')THEN
      RETURN FALSE
   ELSE
      FOR j:=1 TO 6 DO
        ASSIGN(Verb.Portugiesisch,Verb.Person[j].Stamm);
        DELETE((i-4),4,Verb.Person[j].Stamm);
      END(*FOR*);
      Verb.Endung := 'uzir';
   END(*IF*);
   RETURN TRUE
END MakeUzir;

PROCEDURE IndPraes(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   IF ~MakeUzir(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Pr„sens';
   DasVerb.PersonSingular[1].Endung:='uzo';
   DasVerb.PersonSingular[2].Endung:='uzes';
   DasVerb.PersonSingular[3].Endung:='uz';
   DasVerb.PersonPlural[1].Endung:='uzimos';
   DasVerb.PersonPlural[2].Endung:='uzis';
   DasVerb.PersonPlural[3].Endung:='uzem';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END IndPraes;
PROCEDURE IndImperf(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
  RETURN ir.IndImperf(DasVerb);
END IndImperf;
PROCEDURE PPS(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   RETURN ir.PPS(DasVerb);
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
BEGIN
   RETURN ir.Partizip(DasVerb);
END Partizip;
PROCEDURE Imperativ(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
    RETURN ir.Imperativ(DasVerb);
END Imperativ;
END uzir.
