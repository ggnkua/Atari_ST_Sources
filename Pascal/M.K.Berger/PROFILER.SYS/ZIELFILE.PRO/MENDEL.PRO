PROGRAM Mendels_Land; { 7. Bundeswettbewerb Informatik 1988/1989 }
                      { 1. Runde, Aufgabe 5 ; Autor M. Berger    }
 CONST   Max_Anzahl_Merkmale = 4;
 
 TYPE    Elternteil_DEF      = (Mutter,Vater,Kind);
         Typname_DEF       = (Muster,Farbe,Fuehlerform);
         Merkmalspeicher     = STRING[20];
         Dominanz_Liste_TEIL = RECORD
                                 Merkmal   : Merkmalspeicher;
                                 Anz_rezes : INTEGER;
                                 rezessive : ARRAY [1..Max_Anzahl_Merkmale]
                                                   OF Merkmalspeicher;
                               END;
                                 
         Dominanz_Liste_TYP  =  
                           ARRAY [Typname_DEF,1..Max_Anzahl_Merkmale]
                                 OF Dominanz_Liste_TEIL; 
           
 VAR     Dominanz_Liste   : Dominanz_Liste_TYP;  {  DOMINANZ_LISTE : 149  }
         Merkmale         : ARRAY [Elternteil_DEF,Typname_DEF,1..2]
                        {  MERKMALE : 208  }
                                    OF Merkmalspeicher;
         Anz_Kinder       : INTEGER;  {  ANZ_KINDER : 2  Min 5  Max 5  }
         Elternteil       : Elternteil_DEF;  {  ELTERNTEIL : 176  }
         Typ              : Typname_DEF;  {  TYP : 321  }
         Zaehler          : INTEGER;  {  ZAEHLER : 6  Min 1  Max 6  }
 
 
 PROCEDURE Initialisierung;  { 1 }
   VAR i : INTEGER;  {  I : 15  Min 1  Max 5  }
   BEGIN
     FOR Typ:=Muster TO Fuehlerform DO  { 3 }
       FOR i:=1 TO Max_Anzahl_Merkmale DO  { 12 }
         Dominanz_Liste[Typ,i].Merkmal:='';
     
     Dominanz_Liste[Muster,1].Merkmal:='uni';
       Dominanz_Liste[Muster,1].Anz_rezes:=3;
       Dominanz_Liste[Muster,1].rezessive[1]:='uni';
       Dominanz_Liste[Muster,1].rezessive[2]:='schwarz gepunktet';
       Dominanz_Liste[Muster,1].rezessive[3]:='schwarz gestreift';
     Dominanz_Liste[Muster,2].Merkmal:='schwarz gepunktet';
       Dominanz_Liste[Muster,2].Anz_rezes:=2;
       Dominanz_Liste[Muster,2].rezessive[1]:='schwarz gepunktet';
       Dominanz_Liste[Muster,2].rezessive[2]:='schwarz gestreift';
     Dominanz_Liste[Muster,3].Merkmal:='schwarz gestreift';
       Dominanz_Liste[Muster,3].Anz_rezes:=1;
       Dominanz_Liste[Muster,3].rezessive[1]:='schwarz gestreift';
     
     Dominanz_Liste[Farbe,1].Merkmal:='rot';
       Dominanz_Liste[Farbe,1].Anz_rezes:=3;
       Dominanz_Liste[Farbe,1].rezessive[1]:='rot';
       Dominanz_Liste[Farbe,1].rezessive[2]:='grÅn';
       Dominanz_Liste[Farbe,1].rezessive[3]:='blau';
     Dominanz_Liste[Farbe,2].Merkmal:='gelb';
       Dominanz_Liste[Farbe,2].Anz_rezes:=3;
       Dominanz_Liste[Farbe,2].rezessive[1]:='gelb';
       Dominanz_Liste[Farbe,2].rezessive[2]:='rot';
       Dominanz_Liste[Farbe,2].rezessive[3]:='blau';
     Dominanz_Liste[Farbe,3].Merkmal:='grÅn';
       Dominanz_Liste[Farbe,3].Anz_rezes:=3;
       Dominanz_Liste[Farbe,3].rezessive[1]:='grÅn';
       Dominanz_Liste[Farbe,3].rezessive[2]:='gelb';
       Dominanz_Liste[Farbe,3].rezessive[3]:='blau';
     Dominanz_Liste[Farbe,4].Merkmal:='blau';
       Dominanz_Liste[Farbe,4].Anz_rezes:=1;
       Dominanz_Liste[Farbe,4].rezessive[1]:='blau';
     
     Dominanz_Liste[Fuehlerform,1].Merkmal:='gerade';
       Dominanz_Liste[Fuehlerform,1].Anz_rezes:=2;
       Dominanz_Liste[Fuehlerform,1].rezessive[1]:='gerade';
       Dominanz_Liste[Fuehlerform,1].rezessive[2]:='gekrÅmmt';
     Dominanz_Liste[Fuehlerform,2].Merkmal:='gekrÅmmt';
       Dominanz_Liste[Fuehlerform,2].Anz_rezes:=1;
       Dominanz_Liste[Fuehlerform,2].rezessive[1]:='gekrÅmmt';
   END;
 
 PROCEDURE Eingabe;  { 1 }
   BEGIN
     CLRSCR;WRITELN('Mendels Land  (bwINF 7 [88/89];Aufgabe 5)');WRITELN;
     FOR Elternteil:=Mutter TO Vater DO  { 2 }
     BEGIN
       WRITE(' Bitte Merkmale ');
       IF Elternteil=Mutter 
       THEN   { 1 }
         WRITE('der Mutter ')
       ELSE   { 1 }
         WRITE('des Vaters ');
       WRITELN('angeben');
       FOR Typ:=Muster TO Fuehlerform DO  { 6 }
       BEGIN
         WRITE('  Bitte ');
         CASE Typ OF  { 6 }
           Muster      : WRITE('Muster ');  { 2 }
           Farbe       : WRITE('FlÅgelfarbe ');  { 2 }
           Fuehlerform : WRITE('FÅhlerform ');  { 2 }
         END;
         WRITE('eingeben : ');
         READLN(Merkmale[Elternteil,Typ,1]);
       END;
     END;
     WRITE('Anzahl der Kinder eingeben : ');READLN(Anz_Kinder);
   END;
   
 PROCEDURE Ermittle_rezessive_Merkmale;  { 1 }
   VAR  i  : INTEGER;  {  I : 28  Min 0.  Max 3  }
   BEGIN
     FOR Elternteil:=Mutter TO Vater DO  { 2 }
     BEGIN
       FOR Typ:=Muster TO Fuehlerform DO  { 6 }
       BEGIN
         Merkmale[Elternteil,Typ,2]:='';
         i:=0;
         REPEAT  { 8 }
           i:=i+1;
           IF Dominanz_Liste[Typ,i].Merkmal=Merkmale[Elternteil,Typ,1]
           THEN  { 6 }
             Merkmale[Elternteil,Typ,2]:=Dominanz_Liste[Typ,i].rezessive
                                  [RANDOM(Dominanz_Liste[Typ,i].Anz_rezes)+1];
         UNTIL Merkmale[Elternteil,Typ,2]<>'';
       END;
     END;
   END;
 
 PROCEDURE Erbmerkmal_ermitteln;  { 5 }
   VAR i : INTEGER;  {  I : 60  Min 1  Max 2  }
   BEGIN
     FOR Elternteil:=Mutter TO Vater DO  { 10 }
     BEGIN
       FOR Typ:=Muster TO Fuehlerform DO  { 30 }
       BEGIN
          i:=ROUND(INT(RANDOM*2))+1;
          IF Elternteil=Mutter THEN  { 15 }
            Merkmale[Kind,Typ,1]:=Merkmale[Elternteil,Typ,i];
          IF Elternteil=Vater THEN  { 15 }
            Merkmale[Kind,Typ,2]:=Merkmale[Elternteil,Typ,i];
       END;
     END;
   END;
 
 PROCEDURE dom_Erbmerkmal_ermitteln;  { 5 }
   VAR i,u             : INTEGER;  {  I : 149  Min 0.  Max 4  }
                        {  U : 53  Min 1  Max 4  }
       swap_hlp        : Merkmalspeicher;  {  SWAP_HLP : 20  }
       beenden         : BOOLEAN;  {  BEENDEN : 40  }
   BEGIN
     FOR Typ:=Muster TO Fuehlerform DO  { 15 }
     BEGIN
       i:=0;
       beenden:=FALSE;
       REPEAT  { 33 }
         i:=i+1;
         IF Merkmale[Kind,Typ,2]=
            Dominanz_Liste[Typ,i].Merkmal 
         THEN  { 15 }
         BEGIN
           FOR u:=1 TO Dominanz_Liste[Typ,i].Anz_rezes DO  { 38 }
           BEGIN
             IF Dominanz_Liste[Typ,i].rezessive[u]
                =Merkmale[Kind,Typ,1]
             THEN   { 10 }
             BEGIN
               swap_hlp:=Merkmale[Kind,Typ,2];
               Merkmale[Kind,Typ,2]:=Merkmale[Kind,Typ,1];
               Merkmale[Kind,Typ,1]:=swap_hlp;
               beenden:=TRUE;
             END;
           END;
         END;
       UNTIL (beenden) OR (i=Max_Anzahl_Merkmale);
     END;
   END;
 
 PROCEDURE Ausgabe;  { 5 }
   VAR x           : CHAR;  {  X : 5  }
   BEGIN
     CLRSCR;
     WRITELN('Mendels Land  (bwINF 7 [88/89];Aufgabe 5)');WRITELN;
     FOR elternteil:=Mutter TO Kind DO  { 15 }
     BEGIN
       WRITE(' Merkmale');
       IF elternteil=Mutter 
       THEN   { 5 }
         WRITELN(' der Mutter :')
       ELSE   { 10 }
         IF elternteil=Vater 
         THEN   { 5 }
           WRITELN(' des Vaters :')
         ELSE   { 5 }
           WRITELN(' des ',Zaehler,'. Kindes :');
       FOR Typ:=Muster to Fuehlerform DO  { 45 }
       BEGIN
         WRITE('   - ');
         CASE Typ OF  { 45 }
           Muster      : WRITE('Muster :');  { 15 }
           Farbe       : WRITE('Farbe  :');  { 15 }
           Fuehlerform : WRITE('FÅhler :');  { 15 }
         END;
         WRITELN(' Dominant ',Merkmale[elternteil,Typ,1],
                 ' ; Rezessiv ',Merkmale[elternteil,Typ,2]);
       END;
     END;
     READ(kbd,x);
   END;
   
   BEGIN
     Initialisierung;
     Eingabe;
     Ermittle_rezessive_Merkmale;
     FOR Zaehler:=1 TO Anz_Kinder DO  { 5 }
     BEGIN
       Erbmerkmal_ermitteln;
       dom_Erbmerkmal_ermitteln;
       Ausgabe;
     END;
   END.
{ Problemstellung :
  In Mendels Land gibt es eine fantastische Vielfalt von Schmetterlingen.
  Man sieht welche mit roten schwarz gepunkteten FlÅgeln und gekrÅmmten
  FÅhlern, andere sind schwargelb gesteift und haben gerade FÅhler usw.
  Bei lÑngerer Beobachtung kînnen wir drei Typen von Merkmalen unterscheiden :
  1. Musterung : uni,schwarz gepunktet,schwarz gestreift
  2. FlÅgelfarbe : rot,gelb,grÅn oder blau
  3. FÅhlerform : gerade oder gekrÅmmt
  Es stellt sich heraus, daû jeder Schmetterling pro Merkmalstyp ein dominan-
  tes Merkmal (das sieht man) und ein rezessives Merkmal (das sieht man nicht
  oder ist gleich dem ersten) in sich trÑgt.
  Es gelten folgende Dominanzregeln :
  uni dominiert schwarz gepunktet oder schwarz gestreift
  schwarz gepunktet dominiert schwarz gestreift
  rot dominiert grÅn und blau
  gelb dominiert rot und blau
  grÅn dominiert gelb und blau
  gerade dominiert gekrÅmmt.
  Ein Schmetterling erbt fÅr jeden Merkmalstyp von beiden Eltern zufÑllig
  je eines von deren zwei Merkmalen. Die in dieser neuen Kombination dominanten
  Merkmale bestimmen dann das Aussehen des spÑteren neuen Schmetterlings.
  Zum Bleistift :
  Mutter : sichtbar    uni-rot-gerade
           unsichtbar  schwarz gesteift-blau-gekrÅmmt
  Vater  : sichtbar    uni-grÅn-gerade
           unsichtbar  schwarz gepunktet-grÅn-gekrÅmmt
  Kind   : zufÑllig von Mutter : schwarz-gestreift-blau-gekrÅmmt
           zufÑllig vom Vater  : uni-grÅn-gekrÅmmt
           sichtbar    uni-grÅn-gekrÅmmt.
  Schreibe ein Programm, das bei Eingabe der dominanten Merkmale zweier Eltern
  und der gewÅnschten Kinderzahl entsprechend viele Kinder "mendelt" und
  beschreibt. Die rezessiven Merkmale der Eltern werden vom Programm zufÑllig,
  aber unter Beachtung der Dominanzregeln hinzugefÅgt.
  
  Beispiel :
  
   Wie oben erlÑutert, 5 Kinder.
   
  Besonderheiten :
  
   VariablenzÑhlung.
}
 
