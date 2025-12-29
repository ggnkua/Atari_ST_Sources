IMPLEMENTATION MODULE ear;
FROM Konjugation IMPORT Vokabel,MaxLength;
FROM pSTRING IMPORT SLEN,DELETE,APPEND,ASSIGN;
IMPORT ar;
PROCEDURE MakeEar(VAR Verb:Vokabel):BOOLEAN;
VAR i,j : CARDINAL;

BEGIN
   i:=SLEN(Verb.Portugiesisch);
   IF i<3 THEN RETURN FALSE END(*IF*);
   IF (Verb.Portugiesisch[i-1]#'r') OR
      (Verb.Portugiesisch[i-2]#'a') OR
      (Verb.Portugiesisch[i-3]#'e')THEN
      RETURN FALSE
   ELSE
      FOR j:=1 TO 6 DO
        ASSIGN(Verb.Portugiesisch,Verb.Person[j].Stamm);
        DELETE((i-3),3,Verb.Person[j].Stamm);
      END(*FOR*);
      Verb.Endung := 'ear';
   END(*IF*);
   RETURN TRUE
END MakeEar;

PROCEDURE IndPraes(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   IF ~MakeEar(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Pr„sens';
   DasVerb.PersonSingular[1].Endung:='eio';
   DasVerb.PersonSingular[2].Endung:='eias';
   DasVerb.PersonSingular[3].Endung:='eia';
   DasVerb.PersonPlural[1].Endung:='eamos';
   DasVerb.PersonPlural[2].Endung:='eais';
   DasVerb.PersonPlural[3].Endung:='eiam';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END IndPraes;
PROCEDURE IndImperf(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
  RETURN ar.IndImperf(DasVerb);
END IndImperf;
PROCEDURE PPS(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   RETURN ar.PPS(DasVerb);
END PPS;
PROCEDURE Futur(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   RETURN ar.Futur(DasVerb);
END Futur;
PROCEDURE Konditional(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
  RETURN ar.Konditional(DasVerb);
END Konditional;
PROCEDURE KonjPraes(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   IF ~MakeEar(DasVerb) THEN RETURN FALSE END(*IF*);
   DasVerb.Zeit:='Konj. Pr„sens';
   DasVerb.PersonSingular[1].Endung:='eie';
   DasVerb.PersonSingular[2].Endung:='eies';
   DasVerb.PersonSingular[3].Endung:='eie';
   DasVerb.PersonPlural[1].Endung:='eemos';
   DasVerb.PersonPlural[2].Endung:='eeis';
   DasVerb.PersonPlural[3].Endung:='eiem';
   DasVerb.MaxLen:=MaxLength(DasVerb);
   RETURN TRUE
END KonjPraes;
PROCEDURE KonjImperf(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   RETURN ar.KonjImperf(DasVerb);
END KonjImperf;
PROCEDURE Partizip(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
   RETURN ar.Partizip(DasVerb);
END Partizip;
PROCEDURE Imperativ(VAR DasVerb : Vokabel):BOOLEAN;
BEGIN
    RETURN ar.Imperativ(DasVerb);
END Imperativ;    
END ear.
