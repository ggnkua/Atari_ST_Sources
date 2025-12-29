IMPLEMENTATION MODULE  UnregelmaessigeVerben;
FROM GEMX IMPORT BasePagePtr;
FROM Konjugation IMPORT Vokabel,SetVokabel,MaxLength;
FROM  InOut IMPORT WriteString, WriteLn, OpenOutput, ReadLine, CloseOutput,
                   OpenInput, CloseInput,Done,Write;
FROM pSTRING IMPORT SLEN,ASSIGN,CONCAT,APPEND,COPY,EQUAL,EQUALN,
                    RPOS,LPOSCHR,LPOSCHRSET,RPOSCHRSET,DELETE,RPOSCHR;
IMPORT ar,er,ir,ear,uar,iar,uir,uzir,oer;

TYPE KonjugiereZeit = PROCEDURE (VAR  Vokabel):BOOLEAN;
     ZeitArray = ARRAY [1..9] OF ARRAY [0..127] OF CHAR;

VAR Verb : Vokabel;
    InLine : ARRAY [0..255] OF CHAR;
    MeinZeitArray : ZeitArray;


PROCEDURE WriteBlock(Str1,Str2 : ARRAY  OF CHAR; Laenge : CARDINAL);
VAR j : CARDINAL;
BEGIN
   WriteString('  ');
   WriteString(Str1);
    IF SLEN(Str2)>0 THEN
      WriteString('@{B}');
      WriteString(Str2);
      WriteString('@{0}');
   END(*IF*);
   j:=SLEN(Str1)+SLEN(Str2);
   REPEAT
          WriteString(' ');
          INC(j)
   UNTIL j>=Laenge + 2;
   WriteString('');
END WriteBlock;

PROCEDURE OutVerb(Verb1,Verb2,Verb3 : Vokabel);
VAR i,j : CARDINAL;
BEGIN
   Verb1.MaxLen:=MaxLength(Verb1);
   Verb2.MaxLen:=MaxLength(Verb2);
   Verb3.MaxLen:=MaxLength(Verb3);
   WriteBlock(Verb1.Zeit,'',Verb1.MaxLen);
   WriteBlock(Verb2.Zeit,'',Verb2.MaxLen);
   WriteBlock(Verb3.Zeit,'',Verb3.MaxLen);   WriteLn;
   WriteLn;
   WriteBlock('',Verb1.Portugiesisch,Verb1.MaxLen);
   WriteBlock('',Verb2.Portugiesisch,Verb2.MaxLen);
   WriteBlock('',Verb3.Portugiesisch,Verb3.MaxLen);
   WriteLn;

   WriteString('@{I}');
   WriteBlock(Verb1.Deutsch,'',Verb1.MaxLen);
   WriteBlock(Verb2.Deutsch,'',Verb2.MaxLen);
   WriteBlock(Verb3.Deutsch,'',Verb3.MaxLen);
   WriteString('@{0}');
   WriteLn;
   WriteLn;
   FOR i:=1 TO  3 DO
     WriteBlock(Verb1.PersonSingular[i].Stamm,Verb1.PersonSingular[i].Endung,Verb1.MaxLen);
     WriteBlock(Verb2.PersonSingular[i].Stamm,Verb2.PersonSingular[i].Endung,Verb2.MaxLen);
     WriteBlock(Verb3.PersonSingular[i].Stamm,Verb3.PersonSingular[i].Endung,Verb3.MaxLen);
     WriteLn;
   END(*FOR*);
   FOR i:=1 TO  3 DO
     WriteBlock(Verb1.PersonPlural[i].Stamm,Verb1.PersonPlural[i].Endung,Verb1.MaxLen);
     WriteBlock(Verb2.PersonPlural[i].Stamm,Verb2.PersonPlural[i].Endung,Verb2.MaxLen);
     WriteBlock(Verb3.PersonPlural[i].Stamm,Verb3.PersonPlural[i].Endung,Verb3.MaxLen);
     WriteLn;
   END(*FOR*);
END OutVerb;

PROCEDURE Futur(VAR DasVerb : Vokabel; Stamm : ARRAY OF CHAR);
VAR i : CARDINAL;
BEGIN
   DasVerb.Zeit:='Futur I';
   FOR i:=1 TO 6 DO
     ASSIGN(Stamm,DasVerb.Person[i].Stamm)
   END(*FOR*);
   DasVerb.PersonSingular[1].Endung:='ei';
   DasVerb.PersonSingular[2].Endung:=' s';
   DasVerb.PersonSingular[3].Endung:=' ';
   DasVerb.PersonPlural[1].Endung:='emos';
   DasVerb.PersonPlural[2].Endung:='eis';
   DasVerb.PersonPlural[3].Endung:='°o';
   DasVerb.MaxLen:=MaxLength(DasVerb);

END Futur;

PROCEDURE Konditional(VAR DasVerb : Vokabel; Stamm : ARRAY OF CHAR);
VAR  i : CARDINAL;
BEGIN
   DasVerb.Zeit:='Konditional';
   FOR i:=1 TO 6 DO
     ASSIGN(Stamm,DasVerb.Person[i].Stamm)
   END(*FOR*);
   DasVerb.PersonSingular[1].Endung:='ia';
   DasVerb.PersonSingular[2].Endung:='ias';
   DasVerb.PersonSingular[3].Endung:='ia';
   DasVerb.PersonPlural[1].Endung:='¡amos';
   DasVerb.PersonPlural[2].Endung:='¡es';
   DasVerb.PersonPlural[3].Endung:='iam';
   DasVerb.MaxLen:=MaxLength(DasVerb);

END Konditional;

PROCEDURE ReplaceUnderScore(VAR String : ARRAY OF CHAR);
(* Weil in der URV-Datei keine Blanks erlaubt sind, bzw. weil 	*)
(* diese beim Einlesen entfernt werden kann 			*)
(* man diese bei der Eingabe durch '_' ersetzten. Hier werden 	*)
(* die '_' wieder duch Blanks ersetzt.				*)
VAR i : CARDINAL;
BEGIN
   IF SLEN(String)>1 THEN
     FOR i:=0 TO SLEN(String) DO
        IF String[i]='_' THEN
           String[i]:=' ';
        END(*IF*);
     END(*FOR*);
   END(*IF*);  
END ReplaceUnderScore;

PROCEDURE ZeitenAufspalten(Line : ARRAY OF CHAR; VAR Zeiten : ZeitArray);
VAR anfang,ende,i : INTEGER;

 PROCEDURE RemoveBlanks(VAR String : ARRAY OF CHAR);
 VAR j,k : CARDINAL;
 BEGIN
     k :=SLEN(String);
     FOR j:=0 TO k DO
        IF String[j]=' ' THEN
           DELETE(j,1,String);
        END(*IF*);
     END(*FOR*);
 END RemoveBlanks;

 PROCEDURE SetArray(cell : INTEGER);
 BEGIN
    anfang :=LPOSCHR(0,CHR(cell+48),Line)+1;
    Zeiten[cell]:='';
    IF anfang >0 THEN
      ende := LPOSCHRSET(anfang,'0123456789',Line);
      IF ende=-1 THEN
         ende := SLEN(Line);
      END(*IF*);
      COPY(anfang,ende-anfang,Line,Zeiten[cell]);
      RemoveBlanks(Zeiten[cell]);
    END(*IF*);
 END SetArray;

BEGIN
    anfang := 0; (* Die Portugiesische Vokabel muž!!!! an erster Stelle stehen! *)
    ende := LPOSCHRSET(0,'0123456789',Line);
    IF ende >= 0 THEN
      COPY(anfang,ende-anfang,Line,Verb.Portugiesisch);
      RemoveBlanks(Verb.Portugiesisch);
      ReplaceUnderScore(Verb.Portugiesisch);
      anfang := ende+1;
    ELSE
       anfang:=0;
    END(*IF*);
    ende := LPOSCHRSET(anfang,'0123456789',Line);
    IF ende=-1  THEN
       ende := SLEN(Line);
    END(*IF*);
    COPY(anfang,ende-anfang,Line,Verb.Deutsch);
    RemoveBlanks(Verb.Deutsch);
    ReplaceUnderScore(Verb.Deutsch);
    FOR i:=1 TO 9 DO
        SetArray(i);
    END(*FOR*);
END ZeitenAufspalten;

PROCEDURE Tilde(DieZeit : ARRAY OF CHAR; VAR Stamm,Endung,ohneTilde : ARRAY OF CHAR):BOOLEAN;
VAR pos,startPos,endPos : INTEGER;
BEGIN
    pos :=LPOSCHR(0,'~',DieZeit);
    IF pos >= 0 THEN
       (* m”gliche Begrenzer nach links und rechts sind Leerzeichen, Komma
          (Ziffern) und Punkt *)
       endPos:=LPOSCHRSET(pos,(*'0123456789*) ',. ',DieZeit)-1;
       IF endPos<0 THEN endPos := SLEN(DieZeit); END(*IF*);
       startPos:=RPOSCHRSET(pos,(*'0123456789*) ',. ',DieZeit)+1;
       IF startPos<0 THEN startPos := 0; END(*IF*);
       IF (pos-startPos)>=0 THEN
          COPY(startPos,pos-startPos,DieZeit,Stamm);
       END(*IF*);
       IF (endPos-pos)>=0 THEN
          COPY(pos+1,endPos-pos,DieZeit,Endung);
       END(*IF*);
       IF  (endPos-startPos) >= 0 THEN
          COPY(startPos,endPos-startPos,DieZeit,ohneTilde);
       END(*IF*);
       IF (pos-startPos)>=0 THEN
          DELETE(pos-startPos,1,ohneTilde);
       END(*IF*);
       RETURN TRUE
    END(*IF*);
    RETURN FALSE
END Tilde;

PROCEDURE FuelleVerbAusString(DieZeit : ARRAY OF CHAR; VAR DasVerb : Vokabel);
VAR i               : CARDINAL;
    startPos,endPos,tildePos : INTEGER;
    


BEGIN
  IF SLEN(DieZeit)>0 THEN
   endPos:=0;
   startPos:=0;
   tildePos:=LPOSCHR(startPos,'~',DieZeit);
   ReplaceUnderScore(DieZeit);
   FOR i:=1 TO 6 DO
     endPos:=LPOSCHRSET(startPos,',',DieZeit);(* bis zum n„chsten Komma suchen! *)
     IF ((endPos >= tildePos) AND (tildePos >= 0)) (* ohne tilde ist alles unregelm„žig ! *)
        OR ((endPos<0) AND (tildePos>=0)) THEN
        RETURN
     END(*IF*);
     IF endPos < 0 THEN (* Kein weiteres Komma gefunden *)
       IF i=6 THEN
          endPos := SLEN(DieZeit);
         (* hinter dem letzen Eintrag steht kein Komma mehr *)
       ELSE
          IF RPOS(startPos,'..',DieZeit) > 0 THEN
          (* Ich bin rechts von den Pnktchen =>  *)
          (* Rest der Konjugation ist regelm„ssig *)
             (*HALT;*)
             RETURN
             (* nicht weiter fllen *)
          ELSE
             endPos := SLEN(DieZeit);
             (*HALT;*)
          END(*IF*);
       END(*IF*);
     END(*IF*);
    (* startPos:=RPOSCHRSET(endPos,', .',DieZeit)+1; *)
     IF endPos >= startPos THEN
       DasVerb.Person[i].Stamm :='';
       COPY(startPos,endPos-startPos(*Komma nicht mitkopieren*),DieZeit,DasVerb.Person[i].Endung);
       startPos:=endPos+1;
     END(*IF*);
   END(*FOR*);
  ELSE (* fr diese Zeit gibt es keine Angaben ber die Konjugation *)
    SetVokabel('','',DasVerb); (* => l”schen ! *)
  END(*IF*);
END FuelleVerbAusString;



PROCEDURE Main;
VAR HilfsVerbStamm,HilfsVerbEndung, HilfsVerbOhneTilde : ARRAY [0..24] OF CHAR;
    VerbI,VerbII,VerbIII,Dummy : Vokabel;
BEGIN
  IF InLine[0] # '#' THEN
   SetVokabel('','',Dummy);
   ZeitenAufspalten(InLine,MeinZeitArray);
   WriteString('@node ');
   VerbI:=Dummy;VerbII:=Dummy;VerbIII:=Dummy;
   WriteString(Verb.Portugiesisch);WriteLn;
   IF Tilde(MeinZeitArray[1],HilfsVerbStamm,HilfsVerbEndung, HilfsVerbOhneTilde) THEN
      SetVokabel(Verb.Deutsch,HilfsVerbOhneTilde,VerbI);
      IF EQUAL(HilfsVerbEndung,'ar') THEN
         IF ar.IndPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'er') THEN
         IF er.IndPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ir') THEN
         IF ir.IndPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ear') THEN
         IF ear.IndPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uar') THEN
         IF uar.IndPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'iar') THEN
         IF iar.IndPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uir') THEN
         IF uir.IndPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uzir') THEN
         IF uzir.IndPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'oer') THEN
         IF oer.IndPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSE
         WriteString('unbekannte Konjugation !!!');WriteLn;
      END(*IF*);
      VerbI.Portugiesisch:=Verb.Portugiesisch;
   ELSE
      SetVokabel(Verb.Deutsch,Verb.Portugiesisch,VerbI);
      VerbI.Zeit:='Pr„sens';
   END(*IF*);
   FuelleVerbAusString(MeinZeitArray[1],VerbI);

   IF Tilde(MeinZeitArray[2],HilfsVerbStamm,HilfsVerbEndung, HilfsVerbOhneTilde) THEN
      SetVokabel(Verb.Deutsch,HilfsVerbOhneTilde,VerbII);
      IF EQUAL(HilfsVerbEndung,'ar') THEN
         IF ar.IndImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'er') THEN
         IF er.IndImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ir') THEN
         IF ir.IndImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ear') THEN
         IF ear.IndImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uar') THEN
         IF uar.IndImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'iar') THEN
         IF iar.IndImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uir') THEN
         IF uir.IndImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uzir') THEN
         IF uzir.IndImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'oer') THEN
         IF oer.IndImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSE
         WriteString('unbekannte Konjugation !!!');WriteLn;
      END(*IF*);
      VerbII.Portugiesisch:=Verb.Portugiesisch;
   ELSE
      SetVokabel(Verb.Deutsch,Verb.Portugiesisch,VerbII);
      VerbII.Zeit:='Imperfekt';
   END(*IF*);
   FuelleVerbAusString(MeinZeitArray[2],VerbII);

   IF Tilde(MeinZeitArray[3],HilfsVerbStamm,HilfsVerbEndung, HilfsVerbOhneTilde) THEN
      SetVokabel(Verb.Deutsch,HilfsVerbOhneTilde,VerbIII);
      IF EQUAL(HilfsVerbEndung,'ar') THEN
         IF ar.PPS(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'er') THEN
         IF er.PPS(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ir') THEN
         IF ir.PPS(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ear') THEN
         IF ear.PPS(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uar') THEN
         IF uar.PPS(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'iar') THEN
         IF iar.PPS(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uir') THEN
         IF uir.PPS(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uzir') THEN
         IF uzir.PPS(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'oer') THEN
         IF oer.PPS(VerbIII) THEN
          ;
         END(*IF*);
      ELSE
         WriteString('unbekannte Konjugation !!!');WriteLn;
      END(*IF*);
      VerbIII.Portugiesisch:=Verb.Portugiesisch;
   ELSE
      SetVokabel(Verb.Deutsch,Verb.Portugiesisch,VerbIII);
      VerbIII.Zeit:='(einf) Perfekt';
   END(*IF*);
   FuelleVerbAusString(MeinZeitArray[3],VerbIII);
   WriteLn;
   OutVerb(VerbI, VerbII, VerbIII);
   VerbI:=Dummy;VerbII:=Dummy;VerbIII:=Dummy;

   IF Tilde(MeinZeitArray[4],HilfsVerbStamm,HilfsVerbEndung, HilfsVerbOhneTilde) THEN
      SetVokabel(Verb.Deutsch,HilfsVerbOhneTilde,VerbI);
      Futur(VerbI,HilfsVerbOhneTilde);
      VerbI.Portugiesisch:=Verb.Portugiesisch;
   END(*if*);
   IF Tilde(MeinZeitArray[5],HilfsVerbStamm,HilfsVerbEndung, HilfsVerbOhneTilde) THEN
      SetVokabel(Verb.Deutsch,HilfsVerbOhneTilde,VerbII);
      Konditional(VerbII,HilfsVerbOhneTilde);
      VerbII.Portugiesisch:=Verb.Portugiesisch;
   END(*if*);

   IF Tilde(MeinZeitArray[8],HilfsVerbStamm,HilfsVerbEndung, HilfsVerbOhneTilde) THEN
      SetVokabel(Verb.Deutsch,HilfsVerbOhneTilde,VerbIII);
      IF EQUAL(HilfsVerbEndung,'ar') THEN
         IF ar.Partizip(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'er') THEN
         IF er.Partizip(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ir') THEN
         IF ir.Partizip(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ear') THEN
         IF ear.Partizip(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uar') THEN
         IF uar.Partizip(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'iar') THEN
         IF iar.Partizip(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uir') THEN
         IF uir.Partizip(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uzir') THEN
         IF uzir.Partizip(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'oer') THEN
         IF oer.Partizip(VerbIII) THEN
          ;
         END(*IF*);
      ELSE
         WriteString('unbekannte Konjugation !!!');WriteLn;
      END(*IF*);
      VerbIII.Portugiesisch:=Verb.Portugiesisch;
   ELSE
      SetVokabel(Verb.Deutsch,Verb.Portugiesisch,VerbIII);
      VerbIII.Zeit:='Partizipien';
   END(*IF*);
   (* I, II ,III *)
      FuelleVerbAusString(MeinZeitArray[8],VerbIII);
      WriteLn;
      OutVerb(VerbI, VerbII, VerbIII);
      VerbI:=Dummy;VerbII:=Dummy;VerbIII:=Dummy;

   IF Tilde(MeinZeitArray[6],HilfsVerbStamm,HilfsVerbEndung, HilfsVerbOhneTilde) THEN
      SetVokabel(Verb.Deutsch,HilfsVerbOhneTilde,VerbI);
      IF EQUAL(HilfsVerbEndung,'ar') THEN
         IF ar.KonjPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'er') THEN
         IF er.KonjPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ir') THEN
         IF ir.KonjPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ear') THEN
         IF ear.KonjPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uar') THEN
         IF uar.KonjPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'iar') THEN
         IF iar.KonjPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uir') THEN
         IF uir.KonjPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uzir') THEN
         IF uzir.KonjPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'oer') THEN
         IF oer.KonjPraes(VerbI) THEN
          ;
         END(*IF*);
      ELSE
         WriteString('unbekannte Konjugation !!!');WriteLn;
      END(*IF*);
      VerbI.Portugiesisch:=Verb.Portugiesisch;
   ELSE
      SetVokabel(Verb.Deutsch,Verb.Portugiesisch,VerbI);
      VerbI.Zeit:='Konj. Pr„sens';
   END(*IF*);
      FuelleVerbAusString(MeinZeitArray[6],VerbI);

IF Tilde(MeinZeitArray[7],HilfsVerbStamm,HilfsVerbEndung, HilfsVerbOhneTilde) THEN
      SetVokabel(Verb.Deutsch,HilfsVerbOhneTilde,VerbII);
      IF EQUAL(HilfsVerbEndung,'ar') THEN
         IF ar.KonjImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'er') THEN
         IF er.KonjImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ir') THEN
         IF ir.KonjImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ear') THEN
         IF ear.KonjImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uar') THEN
         IF uar.KonjImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'iar') THEN
         IF iar.KonjImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uir') THEN
         IF uir.KonjImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uzir') THEN
         IF uzir.KonjImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'oer') THEN
         IF oer.KonjImperf(VerbII) THEN
          ;
         END(*IF*);
      ELSE
         WriteString('unbekannte Konjugation !!!');WriteLn;
      END(*IF*);
      VerbII.Portugiesisch:=Verb.Portugiesisch;
   ELSE
      SetVokabel(Verb.Deutsch,Verb.Portugiesisch,VerbII);
      VerbII.Zeit:='Konj. Imperfekt';
   END(*IF*);
   FuelleVerbAusString(MeinZeitArray[7],VerbII);
   IF Tilde(MeinZeitArray[9],HilfsVerbStamm,HilfsVerbEndung, HilfsVerbOhneTilde) THEN
      SetVokabel(Verb.Deutsch,HilfsVerbOhneTilde,VerbIII);
      IF EQUAL(HilfsVerbEndung,'ar') THEN
         IF ar.Imperativ(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'er') THEN
         IF er.Imperativ(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ir') THEN
         IF ir.Imperativ(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'ear') THEN
         IF ear.Imperativ(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uar') THEN
         IF uar.Imperativ(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'iar') THEN
         IF iar.Imperativ(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uir') THEN
         IF uir.Imperativ(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'uzir') THEN
         IF uzir.Imperativ(VerbIII) THEN
          ;
         END(*IF*);
      ELSIF EQUAL(HilfsVerbEndung,'oer') THEN
         IF oer.Imperativ(VerbIII) THEN
          ;
         END(*IF*);
      ELSE
         WriteString('unbekannte Konjugation !!!');WriteLn;
      END(*IF*);
      VerbIII.Portugiesisch:=Verb.Portugiesisch;
   ELSE
      SetVokabel(Verb.Deutsch,Verb.Portugiesisch,VerbIII);
      VerbIII.Zeit:='Imperativ';
   END(*IF*);
      FuelleVerbAusString(MeinZeitArray[9],VerbIII);
   (* OutVer 123 *)
      WriteLn;
      OutVerb(VerbI, VerbII, VerbIII);
   WriteString('@endnode');WriteLn;
  END(*IF*); 
END Main;

PROCEDURE ConvertURV2STT(file : ARRAY OF CHAR);
VAR pointPos : INTEGER;
BEGIN
   OpenInput(file);
   IF Done THEN
      WriteString(file);WriteLn;
      pointPos:=RPOS(SLEN(file),'.',file);
      IF pointPos>0 THEN
        DELETE(pointPos,4,file);
        APPEND('.STT',file);
        WriteString(file);
        OpenOutput(file);
      END(*IF*);
   END(*IF*);
   WHILE Done DO
      ReadLine(InLine);
      IF Done THEN
         Main;
      END(*IF*);
   END(*WHILE*);
   CloseOutput;
   CloseInput;
END ConvertURV2STT;

BEGIN
    (*InLine:='M:\DICI\PORTUGUE.URV';*)
    ASSIGN(BasePagePtr^.CmdLine,InLine);
    DELETE(0,1,InLine);
    ConvertURV2STT(InLine);
END UnregelmaessigeVerben.
