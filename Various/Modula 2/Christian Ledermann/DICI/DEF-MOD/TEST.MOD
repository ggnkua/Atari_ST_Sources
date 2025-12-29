MODULE Test;
FROM Konjugation IMPORT Vokabel,SetVokabel;
FROM  InOut IMPORT WriteString, WriteLn, OpenOutput,CloseOutput;
FROM pSTRING IMPORT SLEN;
IMPORT ar,er,ir;
VAR VerbAr, VerbEr, VerbIr ,Dummy : Vokabel;

PROCEDURE WriteBlock(Str1,Str2 : ARRAY	OF CHAR; Laenge : CARDINAL);
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
   WriteString('@alabel "'); WriteString(Verb1.Zeit);
   WriteLn;
   WriteString('@index "'); WriteString(Verb1.Zeit);
   WriteLn;
   WriteBlock('',Verb1.Zeit,Verb1.MaxLen);
   WriteLn;
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
   FOR i:=1 TO	3 DO
     WriteBlock(Verb1.PersonSingular[i].Stamm,Verb1.PersonSingular[i].Endung,Verb1.MaxLen);
     WriteBlock(Verb2.PersonSingular[i].Stamm,Verb2.PersonSingular[i].Endung,Verb2.MaxLen);
     WriteBlock(Verb3.PersonSingular[i].Stamm,Verb3.PersonSingular[i].Endung,Verb3.MaxLen);
     WriteLn;
   END(*FOR*);
   FOR i:=1 TO	3 DO
     WriteBlock(Verb1.PersonPlural[i].Stamm,Verb1.PersonPlural[i].Endung,Verb1.MaxLen);
     WriteBlock(Verb2.PersonPlural[i].Stamm,Verb2.PersonPlural[i].Endung,Verb2.MaxLen);
     WriteBlock(Verb3.PersonPlural[i].Stamm,Verb3.PersonPlural[i].Endung,Verb3.MaxLen);
     WriteLn;
   END(*FOR*);
END OutVerb;
BEGIN
   OpenOutput('M:\test.txt');
   SetVokabel('loben','louvar',VerbAr);
   SetVokabel('verkaufen','vender', VerbEr);
   SetVokabel('weggehen','partir',VerbIr);
   SetVokabel('','',Dummy);
   IF ar.IndPraes(VerbAr) AND
   er.IndPraes(VerbEr) AND
   ir.IndPraes(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ar.IndImperf(VerbAr) AND
    er.IndImperf(VerbEr) AND
    ir.IndImperf(VerbIr) THEN
	 WriteLn;
	 OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ar.PPS(VerbAr) AND
    er.PPS(VerbEr) AND
    ir.PPS(VerbIr) THEN
	 WriteLn;
	 OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ar.Futur(VerbAr) AND
    er.Futur(VerbEr) AND
    ir.Futur(VerbIr) THEN
	 WriteLn;
	 OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ar.Konditional( VerbAr) AND
    er.Konditional( VerbEr) AND
    ir.Konditional( VerbIr) THEN
	WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ar.KonjPraes( VerbAr) AND
    er.KonjPraes( VerbEr) AND
    ir.KonjPraes( VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ar.KonjImperf( VerbAr) AND
    er.KonjImperf( VerbEr) AND
    ir.KonjImperf( VerbIr) THEN
	 WriteLn;
	 OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ar.Partizip( VerbAr) AND
    er.Partizip( VerbEr) AND
    ir.Partizip( VerbIr) THEN

      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);

   END(*IF*);
   IF ar.Imperativ( VerbAr) AND
    er.Imperativ( VerbEr) AND
    ir.Imperativ( VerbIr) THEN

      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);

   END(*IF*);
   CloseOutput;
END Test.
