MODULE Test2;
FROM Konjugation IMPORT Vokabel,SetVokabel;
FROM  InOut IMPORT WriteString, WriteLn, OpenOutput,  CloseOutput;
FROM pSTRING IMPORT SLEN;
IMPORT ear,uar,iar,uir,uzir,oer;

PROCEDURE WriteBlock(Str1,Str2 : ARRAY	OF CHAR; Laenge : CARDINAL);
VAR j : CARDINAL;
BEGIN
   WriteString('  ');
   IF (SLEN(Str1)+SLEN(Str2))>0 THEN
      WriteString(Str1);
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
   WriteBlock(Verb3.Zeit,'',Verb3.MaxLen);   WriteLn;   WriteLn;
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
   WriteString('@node ');WriteString(VerbAr.Endung); WriteLn;
   IF ear.IndPraes(VerbAr) AND
   ear.IndImperf(VerbEr) AND
   ear.PPS(VerbIr) THEN
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF ear.Futur(VerbAr) AND
    ear.Konditional( VerbEr) THEN
         OutVerb(VerbAr, VerbEr, Dummy);
   END(*IF*);
    IF ear.KonjPraes( VerbAr) AND
    ear.KonjImperf( VerbEr) THEN
      OutVerb(VerbAr, VerbEr, Dummy);
   END(*IF*);
    IF ear.Partizip( VerbAr) THEN 
      OutVerb(VerbAr, Dummy, Dummy);
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
   WriteString('@node '); WriteString(VerbAr.Endung); WriteLn;
   IF uzir.IndPraes(VerbAr) AND
   uzir.IndImperf(VerbEr) AND
   uzir.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF uzir.Futur(VerbAr) AND
    uzir.Konditional( VerbEr) THEN
    	 WriteLn;
         OutVerb(VerbAr, VerbEr, Dummy);
   END(*IF*);
    IF uzir.KonjPraes( VerbAr) AND
    uzir.KonjImperf( VerbEr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, Dummy);
   END(*IF*);
    IF uzir.Partizip( VerbAr) THEN 
      WriteLn;
      OutVerb(VerbAr, Dummy, Dummy);
   END(*IF*);
   WriteString('@endnode');WriteLn;
END outuzir;
PROCEDURE outiar;
VAR VerbAr, VerbEr, VerbIr ,Dummy : Vokabel;
BEGIN
   SetVokabel('hassen','odiar',VerbAr);
   SetVokabel('hassen','odiar', VerbEr);
   SetVokabel('hassen','odiar',VerbIr);
   SetVokabel('','',Dummy);
   WriteString('@node '); WriteString(VerbAr.Endung); WriteLn;
   IF iar.IndPraes(VerbAr) AND
   iar.IndImperf(VerbEr) AND
   iar.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF iar.Futur(VerbAr) AND
    iar.Konditional( VerbEr) THEN
    	 WriteLn;
         OutVerb(VerbAr, VerbEr, Dummy);
   END(*IF*);
    IF iar.KonjPraes( VerbAr) AND
    iar.KonjImperf( VerbEr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, Dummy);
   END(*IF*);
    IF iar.Partizip( VerbAr) THEN 
      WriteLn;
      OutVerb(VerbAr, Dummy, Dummy);
   END(*IF*);
   WriteString('@endnode');WriteLn;
END outiar;
   
PROCEDURE outuar;
VAR VerbAr, VerbEr, VerbIr ,Dummy : Vokabel;
BEGIN
   SetVokabel('ermitteln','averiguar',VerbAr);
   SetVokabel('ermitteln','averiguar', VerbEr);
   SetVokabel('ermitteln','averiguar',VerbIr);
   SetVokabel('','',Dummy);
   WriteString('@node '); WriteString(VerbAr.Endung); WriteLn;
   IF uar.IndPraes(VerbAr) AND
   uar.IndImperf(VerbEr) AND
   uar.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF uar.Futur(VerbAr) AND
    uar.Konditional( VerbEr) THEN
    	 WriteLn;
         OutVerb(VerbAr, VerbEr, Dummy);
   END(*IF*);
    IF uar.KonjPraes( VerbAr) AND
    uar.KonjImperf( VerbEr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, Dummy);
   END(*IF*);
    IF uar.Partizip( VerbAr) THEN 
      
      WriteLn;
      OutVerb(VerbAr, Dummy, Dummy);
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
   WriteString('@node '); WriteString(VerbAr.Endung); WriteLn;
   IF oer.IndPraes(VerbAr) AND
   oer.IndImperf(VerbEr) AND
   oer.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF oer.Futur(VerbAr) AND
    oer.Konditional( VerbEr) THEN
    	 
    	 WriteLn;
         OutVerb(VerbAr, VerbEr, Dummy);
   END(*IF*);
    IF oer.KonjPraes( VerbAr) AND
    oer.KonjImperf( VerbEr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, Dummy);
   END(*IF*);
    IF oer.Partizip( VerbAr) THEN 
      
      WriteLn;
      OutVerb(VerbAr, Dummy, Dummy);
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
   WriteString('@node '); WriteString(VerbAr.Endung); WriteLn;
   IF uir.IndPraes(VerbAr) AND
   uir.IndImperf(VerbEr) AND
   uir.PPS(VerbIr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, VerbIr);
   END(*IF*);
    IF uir.Futur(VerbAr) AND
    uir.Konditional( VerbEr) THEN
    	 WriteLn;
         OutVerb(VerbAr, VerbEr, Dummy);
   END(*IF*);
    IF uir.KonjPraes( VerbAr) AND
    uir.KonjImperf( VerbEr) THEN
      WriteLn;
      OutVerb(VerbAr, VerbEr, Dummy);
   END(*IF*);
    IF uir.Partizip( VerbAr) THEN      
      
      WriteLn;
      OutVerb(VerbAr, Dummy, Dummy);
   END(*IF*);
   WriteString('@endnode');WriteLn;
END outuir;


BEGIN
   OpenOutput('M:\test2.txt'); 
   outear;
   outiar;
   outuar;
   outoer;
   outuir;
   outuzir;
   CloseOutput;
END Test2.
