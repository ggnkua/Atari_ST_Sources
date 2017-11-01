PROGRAM Computer_Composition; { 7. Bundeswettbewerb Informatik 1988/1989 }
                              { 1. Runde,Aufgabe 1 ; Autor M.Berger      }
                              {   Hinweise am Ende des Files beachten !  }
  
  CONST Max_Laenge_Motiv        = 20;
        Max_Anzahl_Toene        = 10;
        Max_Anzahl_Schritte     = 20;
  TYPE  Abbildungsregel_DEF     = RECORD
                                    Alt       : CHAR;
                                    Neu       : CHAR;
                                  END;
        Wandlungs_ART    = (Thema,Variation);
      
  VAR   Satzform                         : ARRAY[1..Max_Anzahl_Schritte] OF
                        {  SATZFORM : 112  }
                                                 Wandlungs_ART;
        Anzahl_Schritte                  : INTEGER;
                        {  ANZAHL_SCHRITTE : 39  Min 0.  Max 5  }
        Abbildungsregel                  : ARRAY[1..Max_Anzahl_Toene] 
                        {  ABBILDUNGSREGEL : 2765  }
                                                 OF Abbildungsregel_DEF;
        Anzahl_Toene                     : INTEGER;
                        {  ANZAHL_TOENE : 493  Min 0.  Max 6  }
        Motiv                            : ARRAY[1..Max_Laenge_Motiv] OF
                        {  MOTIV : 359  }
                                                CHAR;
        Motivlaenge                           : INTEGER;
                        {  MOTIVLAENGE : 105  Min 0.  Max 5  }
        Prestofaktor                     : REAL;
                        {  PRESTOFAKTOR : 3  Min 2  Max 2  }
        Anzahl_Saetze                    : INTEGER;
                        {  ANZAHL_SAETZE : 2  Min 3  Max 3  }
        Tondauer                         : REAL;
                        {  TONDAUER : 6  Min 0  Max 1  }
        i                                : INTEGER;
                        {  I : 0.  Min ---  Max ---  }
        
 PROCEDURE Eingabe;  { 1 }
   VAR i : INTEGER;  {  I : 0.  Min ---  Max ---  }
       x : CHAR;  {  X : 16  }
   BEGIN
     CLRSCR;WRITELN('Computer-Composition  (bwINF 7 [88/89];Aufgabe 1)');
     WRITELN;WRITELN;
     
     Anzahl_Toene:=0;
     REPEAT  { 6 }
       Anzahl_Toene:=Anzahl_Toene+1;
       WRITE('  Bitte Ton angeben : ');
       READ(kbd,Abbildungsregel[Anzahl_Toene].Alt);
       WRITE(Abbildungsregel[Anzahl_Toene].Alt);
       IF Abbildungsregel[Anzahl_Toene].Alt<>' ' THEN  { 5 }
       BEGIN
         WRITE(' ; Wird abgebildet auf : ');
         READ(kbd,Abbildungsregel[Anzahl_Toene].Neu);
         WRITE(Abbildungsregel[Anzahl_Toene].NEU);
       END;
       WRITELN;
     UNTIL (Anzahl_Toene=Max_Anzahl_Toene) OR 
           (Abbildungsregel[Anzahl_Toene].Alt=' ');
     Anzahl_Toene:=Anzahl_Toene-1;
     WRITELN;
     
     Motivlaenge:=0;
     REPEAT  { 5 }
       Motivlaenge:=Motivlaenge+1;
       WRITE('  Bitte Ton des Themas angeben : ');
       READ(kbd,Motiv[Motivlaenge]);WRITELN(Motiv[Motivlaenge]);
     UNTIL (Motiv[Motivlaenge]=' ') OR (Motivlaenge>Max_Laenge_Motiv);
     Motivlaenge:=Motivlaenge-1;
     WRITELN;
     
     Anzahl_Schritte:=0;
     REPEAT  { 5 }
       Anzahl_Schritte:=Anzahl_Schritte+1;
       WRITE('  Soll Thema (u)nverÑndert bleiben oder (v)ariiert werden ');
       READ(kbd,x);
       WRITELN(x);
       IF UPCASE(X)='V' THEN  { 2 }
         Satzform[Anzahl_Schritte]:=Variation;
       IF UPCASE(x)='U' THEN  { 2 }
         Satzform[Anzahl_Schritte]:=Thema;
     UNTIL ((UPCASE(x)<>'V') AND (UPCASE(x)<>'U')) OR
           (Anzahl_Schritte>Max_Anzahl_Schritte);
     Anzahl_Schritte:=Anzahl_Schritte-1;
     WRITELN;
     
     WRITE('  Bitte Anzahl SÑtze angeben : ');
     READLN(Anzahl_Saetze);
     
     WRITE('  Bitte Tondauer im ersten Satz angeben : ');
     READLN(Tondauer);
     
     WRITE('  Bitte Prestofaktor angeben : ');
       READLN(Prestofaktor);
   END;
 PROCEDURE Gib_Saetze_aus;  { 1 }
   VAR i,u : INTEGER;  {  I : 10  Min 1  Max 4  }  {  U : 15  Min 1  Max 5  }
       x   : CHAR;  {  X : 3  }
   
   PROCEDURE bilde_Satz (Schachtelung,Variationen : INTEGER);  { 111 }
                                  { Max. Rekursion: 3 }
                        {  SCHACHTELUNG : 219  Min 0.  Max 3  }
                        {  VARIATIONEN : 724  Min 0.  Max 3  }
     
     FUNCTION variiert (Note : Char) : Char ;  { 456 }  {  NOTE : 2280  }
       VAR i : INTEGER;  {  I : 3192  Min 1  Max 6  }
           x : CHAR;  {  X : 2736  }
       BEGIN
         FOR i:=1 TO Anzahl_Toene DO  { 2280 }
           IF Abbildungsregel[i].Alt=Note THEN x:=Abbildungsregel[i].Neu;
                                  { 456 }
         variiert:=x;
       END;
     
     VAR i,u    : INTEGER;  {  I : 555  Min 1  Max 5  }
                        {  U : 280  Min 2  Max 4  }
         x      : CHAR;  {  X : 1128  }
     BEGIN
       IF Schachtelung>0 THEN  { 27 }
         FOR i:=1 TO Anzahl_Schritte DO  { 108 }
           IF Satzform[i]=Thema THEN  { 54 }
             bilde_Satz(Schachtelung-1,Variationen)
                                  ELSE  { 54 }
             bilde_Satz(Schachtelung-1,Variationen+1)
       ELSE  { 84 }
       BEGIN
         FOR i:=1 TO Motivlaenge DO  { 336 }
         BEGIN
             x:=Motiv[i];
             IF Variationen>0 THEN  { 280 }
               FOR u:=1 TO Variationen DO  { 456 }
                 x:=variiert(x);
             WRITE(x);
         END;
         WRITE(' ');
       END;
     END;
   
   BEGIN
     FOR i:=1 TO Anzahl_Saetze DO  { 3 }
     BEGIN
       CLRSCR;WRITE('Computer-Composition :  -');
       FOR u:=1 TO Motivlaenge DO WRITE(Motiv[u]);  { 12 }
       WRITE('- ; Satz ',i,' ; Tondauer : ');
       IF i>1 THEN Tondauer:=Tondauer/Prestofaktor;  { 2 }
       WRITELN(Tondauer:3:2);
       WRITELN;WRITE(' ');
       bilde_Satz(i,0);
       READ(kbd,x);
     END;
   END;
   
 BEGIN
   Eingabe;
   Gib_Saetze_aus;
 END.
{
 Problemstellung :
 Sue Dama ist bekannt fÅr ihre anspruchsvollen Kompositionen. Sie benutzt
 immer nur die fÅnf Tonstufen C,D,F,G und A.
 ZunÑchst gibt sie ein Thema aus n gleichlangen Tînen vor. Jede Tonstufe kann
 dabei mehrfach, einfach oder gar nicht vorkommen. Ein Thema fÅr n=4 ist
 zum Beispiel "AGCA"
 Weiter denkt sie sich eine Abbildungsregel zwischen den Tonstufen aus, deren
 Anwendung auf das Thema automatisch eine Variation ergibt. Die Abbildungs-
 regel " C->F,D->D,F->D,G->C,A->G " ergibt fÅr das Beispielthema die Variation
 "GCFG".
 Jetzt wÑhlt sie noch eine Satzform, die aus einer beliebigen Aneinanderreihung
 von Thema und Variation besteht. FÅr die Satzform "Thema-Variation-Variation-
 Thema" sieht der erste Satz ihrer Komposition im Beispiel nun so aus :
 "AGCA GCFG GCFG AGCA".
 Den zweiten Satz komponiert Sue Dama, indem sie den ganzen ersten Satz als
 Thema nimmt, und die Abbildungsregel und die Abbildungsregel und die Satzform
 darauf wiederholt. FÅr das Beispiel lautet der zweite Satz damit :
 "AGCAAGCFGGCFGAGCAGCFGCFDCCFDCGCFGGCFGCFDCCFDCGCFGAGCAAGCFGGCFGAGCA".
 Weil der zweite Satz viel mehr Tîne hat alsder erste, spielt ihn Sue Dama um
 einen Prestofaktor schneller. Ist der Prestofaktor etwa gleich 2.0, dann
 dauern alle Tîne nur halb so lang wie im vorhergehenden Satz.
 Der dritte, noch schnellere Satz ergibt sich aus dem zweiten, ebenso wie der
 zweite aus dem ersten Satz. Der vierte Satz ergibt sich analog aus dem dritten
 usw.
 Schreibe ein Programm, das im Stil von Sue Dama komponiert, wenn man ihm ein
 Thema, eine Abbildungsregel, eine Satzform, die Anzahl der gewÅnschten SÑtze,
 die Tondauer im ersten Satz und einen Prestofaktor eingibt.
 
 Beispiel :
 
 Thema,Abbildungsregel und Satzform wie oben besprochen.
 Anzahl SÑtze : 3; Prestofaktor 2; TonlÑnge am Anfang 1.
 Ergebnisse wie oben angefÅhrt.
  
 Besonderheiten :
 
 Rekursion, Variablen, IF-THEN-Strukturen ohne Semikolons/ENDs.
 
}
 

