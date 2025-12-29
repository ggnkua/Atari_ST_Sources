MODULE Test1;
FROM Konjugation IMPORT Vokabel,SetVokabel;
FROM  InOut IMPORT WriteString, WriteLn, OpenOutput,  CloseOutput;
FROM pSTRING IMPORT SLEN;
IMPORT ar,er,ir,ear,uar,iar,uir,uzir,oer;
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

PROCEDURE outear;
VAR VerbAr, VerbEr, VerbIr ,Dummy : Vokabel;
BEGIN
   SetVokabel('rasieren','barbear',VerbAr);
   SetVokabel('rasieren','barbear', VerbEr);
   SetVokabel('rasieren','barbear',VerbIr);
   SetVokabel('','',Dummy);
   WriteString('@node -ear "Verben auf -ear');(*WriteString(VerbAr.Endung);*) WriteLn;
   IF ear.IndPraes(VerbAr) AND
   ear.IndImperf(VerbEr) AND
   ear.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ear.Futur(VerbAr) AND
    ear.Partizip( VerbIr) AND 
    ear.Konditional( VerbEr) THEN
         WriteLn;
         OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ear.KonjPraes( VerbAr) AND
    ear.Imperativ( VerbIr) AND 
    ear.KonjImperf( VerbEr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
   WriteString('@endnode');WriteLn;
END outear;
PROCEDURE outuzir;
VAR VerbAr, VerbEr, VerbIr ,Dummy : Vokabel;
BEGIN
   SetVokabel('Åberbringen','traduzir',VerbAr);
   SetVokabel('Åberbringen','traduzir', VerbEr);
   SetVokabel('Åberbringen','traduzir',VerbIr);
   SetVokabel('','',Dummy);
   WriteString('@node -uzir "Verben auf -uzir'); (*WriteString(VerbAr.Endung); *) WriteLn;
   IF uzir.IndPraes(VerbAr) AND
   uzir.IndImperf(VerbEr) AND
   uzir.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF uzir.Futur(VerbAr) AND
    uzir.Partizip( VerbIr) AND 
    uzir.Konditional( VerbEr) THEN
    	 WriteLn;
         OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF uzir.KonjPraes( VerbAr) AND
    uzir.Imperativ( VerbIr) AND 
    uzir.KonjImperf( VerbEr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    (*IF uzir.Partizip( VerbAr) THEN
      WriteLn;
      OutVerb(VerbAr, Dummy, Dummy);
   END(*IF*);*)
   WriteString('@endnode');WriteLn;
END outuzir;
PROCEDURE outiar;
VAR VerbAr, VerbEr, VerbIr ,Dummy : Vokabel;
BEGIN
   SetVokabel('hassen','odiar',VerbAr);
   SetVokabel('hassen','odiar', VerbEr);
   SetVokabel('hassen','odiar',VerbIr);
   SetVokabel('','',Dummy);
   WriteString('@node -iar "Verben auf -iar'); (*WriteString(VerbAr.Endung);*) WriteLn;
   IF iar.IndPraes(VerbAr) AND
   iar.IndImperf(VerbEr) AND
   iar.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF iar.Futur(VerbAr) AND
    iar.Partizip( VerbIr) AND 
    iar.Konditional( VerbEr) THEN
    	 WriteLn;
         OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF iar.KonjPraes( VerbAr) AND
    iar.Imperativ( VerbIr) AND 
    iar.KonjImperf( VerbEr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
(*    IF iar.Partizip( VerbAr) THEN
      WriteLn;
      OutVerb(VerbAr, Dummy, Dummy);
   END(*IF*);*)
   WriteString('@endnode');WriteLn;
END outiar;

PROCEDURE outuar;
VAR VerbAr, VerbEr, VerbIr ,Dummy : Vokabel;
BEGIN
   SetVokabel('ermitteln','averiguar',VerbAr);
   SetVokabel('ermitteln','averiguar', VerbEr);
   SetVokabel('ermitteln','averiguar',VerbIr);
   SetVokabel('','',Dummy);
   WriteString('@node -uar "Verben auf -uar'); (*WriteString(VerbAr.Endung);*) WriteLn;
   IF uar.IndPraes(VerbAr) AND
   uar.IndImperf(VerbEr) AND
   uar.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF uar.Futur(VerbAr) AND
    uar.Partizip( VerbIr) AND 
    uar.Konditional( VerbEr) THEN
    	 WriteLn;
         OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF uar.KonjPraes( VerbAr) AND
    uar.Imperativ( VerbIr) AND 
    uar.KonjImperf( VerbEr) THEN 
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
   WriteString('@endnode');WriteLn;
END outuar;

PROCEDURE outoer;
VAR VerbAr, VerbEr, VerbIr ,Dummy : Vokabel;
BEGIN
   SetVokabel('mahlen','moer',VerbAr);
   SetVokabel('mahlen','moer', VerbEr);
   SetVokabel('mahlen','moer',VerbIr);
   SetVokabel('','',Dummy);
   WriteString('@node -oer "Verben auf -oer'); (*WriteString(VerbAr.Endung);*) WriteLn;
   IF oer.IndPraes(VerbAr) AND
   oer.IndImperf(VerbEr) AND
   oer.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF oer.Futur(VerbAr) AND
    oer.Partizip( VerbIr) AND 
    oer.Konditional( VerbEr) THEN
    	 WriteLn;
         OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF oer.KonjPraes( VerbAr) AND
    oer.Imperativ( VerbIr) AND 
    oer.KonjImperf( VerbEr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
   WriteString('@endnode');WriteLn;
END outoer;
PROCEDURE outuir;
VAR VerbAr, VerbEr, VerbIr ,Dummy : Vokabel;
BEGIN
   SetVokabel('einschlieûen','incluir',VerbAr);
   SetVokabel('einschlieûen','incluir', VerbEr);
   SetVokabel('einschlieûen','incluir',VerbIr);
   SetVokabel('','',Dummy);
   WriteString('@node -uir "Verben auf -uir'); (*WriteString(VerbAr.Endung);*) WriteLn;
   IF uir.IndPraes(VerbAr) AND
   uir.IndImperf(VerbEr) AND
   uir.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF uir.Futur(VerbAr) AND
    uir.Partizip( VerbIr) AND 
    uir.Konditional( VerbEr) THEN
    	 WriteLn;
         OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF uir.KonjPraes( VerbAr) AND
    uir.Imperativ( VerbIr) AND 
    uir.KonjImperf( VerbEr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
   WriteString('@endnode');WriteLn;
END outuir;
PROCEDURE outir;
VAR VerbAr, VerbEr, VerbIr ,Dummy : Vokabel;
BEGIN
   SetVokabel('vereinigen','unir',VerbAr);
   SetVokabel('vereinigen','unir', VerbEr);
   SetVokabel('vereinigen','unir',VerbIr);
   SetVokabel('','',Dummy);
   WriteString('@node -ir "Verben auf -ir'); (*WriteString(VerbAr.Endung);*) WriteLn;
   IF ir.IndPraes(VerbAr) AND
   ir.IndImperf(VerbEr) AND
   ir.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ir.Futur(VerbAr) AND
    ir.Partizip( VerbIr) AND 
    ir.Konditional( VerbEr) THEN
    	 WriteLn;
         OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ir.KonjPraes( VerbAr) AND
    ir.Imperativ( VerbIr) AND 
    ir.KonjImperf( VerbEr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
   WriteString('@endnode');WriteLn;
END outir;
PROCEDURE outer;
VAR VerbAr, VerbEr, VerbIr ,Dummy : Vokabel;
BEGIN
   SetVokabel('essen','comer',VerbAr);
   SetVokabel('essen','comer', VerbEr);
   SetVokabel('essen','comer',VerbIr);
   SetVokabel('','',Dummy);
   WriteString('@node -er "Verben auf -er'); (*WriteString(VerbAr.Endung);*) WriteLn;
   IF er.IndPraes(VerbAr) AND
   er.IndImperf(VerbEr) AND
   er.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF er.Futur(VerbAr) AND
    er.Partizip( VerbIr) AND 
    er.Konditional( VerbEr) THEN
    	 WriteLn;
        OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF er.KonjPraes( VerbAr) AND
    er.Imperativ( VerbIr) AND 
    er.KonjImperf( VerbEr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
   WriteString('@endnode');WriteLn;
END outer;

PROCEDURE outar;
VAR VerbAr, VerbEr, VerbIr ,Dummy : Vokabel;
BEGIN
   SetVokabel('schwimmen','nadar',VerbAr);
   SetVokabel('schwimmen','nadar', VerbEr);
   SetVokabel('schwimmen','nadar',VerbIr);
   SetVokabel('','',Dummy);
   WriteString('@node -ar "Verben auf -ar'); (*WriteString(VerbAr.Endung);*) WriteLn;
   IF ar.IndPraes(VerbAr) AND
   ar.IndImperf(VerbEr) AND
   ar.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ar.Futur(VerbAr) AND
    ar.Partizip( VerbIr) AND 
    ar.Konditional( VerbEr) THEN
    	 WriteLn;
         OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ar.KonjPraes( VerbAr) AND
    ar.Imperativ( VerbIr) AND 
    ar.KonjImperf( VerbEr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
   WriteString('@endnode');WriteLn;
END outar;


BEGIN
   OpenOutput('M:\test1.txt');
   outar;
   outer;
   outir;
   outear;
   outiar;
   outuar;
   outoer;
   outuir;
   outuzir;
   CloseOutput;
END Test1.
