{  
  AUTOR   :  Stefan Maetschke
             (c) 1991 MAXON Computer
  ZWECK   :  Programm zum Vergleich der Sekantensuche mit der BinÑrsuche
}  


PROGRAM sekantensuche(INPUT,OUTPUT);

VAR feld  :ARRAY [1..30000] OF INTEGER;   { Feld in dem gesucht wird }

    binz,suchz :LONG_INTEGER;  { ZÑhlvariablen fÅr BinÑrsuche
                                 und Sekantensuche }
    
    i,max :INTEGER;  
    
    taste :CHAR;



FUNCTION random(x:INTEGER):INTEGER;    { Zufallszahlengenerator }
  FUNCTION zufall :INTEGER;            { Zahlen im Bereich von 1-x }
  xbios(17);
BEGIN
  random:=abs(zufall MOD x)+1
END;


PROCEDURE initialisierung(anzahl :INTEGER); 
{ Initialisiert das Feld mit Zufallswerten }
VAR i :INTEGER;
BEGIN
  FOR i:=1 TO anzahl DO
    feld[i]:=random(anzahl)
END;


PROCEDURE quicksort(lb,ub:INTEGER);
{ Quicksort sollte ein bekannter Begriff sein! }
VAR i,j,
    x,w :INTEGER;
BEGIN
  i:=lb;
  j:=ub;
  x:=feld[(lb+ub) DIV 2];
  REPEAT
    WHILE feld[i]<x DO i:=succ(i);
    WHILE feld[j]>x DO j:=pred(j);
    IF i<=j
      THEN BEGIN
             w:=feld[i];
             feld[i]:=feld[j];
             feld[j]:=w;
             i:=succ(i);
             j:=pred(j)
           END
  UNTIL i>j;
  IF lb<j THEN quicksort(lb,j);
  IF ub>i THEN quicksort(i,ub)
END;


PROCEDURE sekantensuche(u,o,ai,ni,dy,w :LONG_INTEGER);
{ Die Sekantensuche }
BEGIN
  IF dy=0 THEN dy:=1;      { waagrechte Sekante abfabgen }
  ni:=(w-feld[ai])*(ni-ai) DIV dy+ai; { Neuen Index berechnen }
  IF (ni>o) OR (ni<u)      { Index im zulÑssigen Intervall }
    THEN ni:=(o+u) DIV 2;  { Wenn nicht, dann also halbieren }
  suchz:=succ(suchz);      { ZÑhlen der Suchschritte }
  IF (o>u) AND (feld[ni]<>w) { Wert gefunden }
    THEN IF w>feld[ni]     { Nein, also rekursiver Aufruf }
           THEN sekantensuche(ni+1,o,ni,ai,feld[ai]-feld[ni],w)
           ELSE sekantensuche(u,ni-1,ni,ai,feld[ai]-feld[ni],w)
END;


PROCEDURE binaersuche(xmin,xmax,wert :INTEGER);
{ BinÑrsuche wie sie leibt und lebt }
VAR m :INTEGER;  { Mittlerer Index }
BEGIN
  REPEAT
    m:=(xmin+xmax) DIV 2;  { Halbieren }
    IF feld[m]<wert        { Intervall zum Weitersuchen auswÑhlen }
      THEN xmin:=m+1
      ELSE xmax:=m-1;
    binz:=succ(binz);      { gesamt Suchschritte zÑhlen }
  UNTIL (xmin>xmax) OR (feld[m]=wert);
END;


BEGIN   { Hauptprogramm }
  writeln(' Testprogramm zur Sekantensuche');
  writeln('   erstellt mit CCD-Pascal+ 2.00');
  writeln;
  REPEAT
    writeln;
    REPEAT
      write('Feldgrîûe (1-30000):');
      readln(max)
    UNTIL (max>0) AND(max<30001);  
    binz:=0;
    suchz:=0;
    writeln('Intitialisiere Feld');
    initialisierung(max);
    writeln('Beginne Sortierung');
    quicksort(1,max);
    writeln('Beginne Suche');
    FOR i:=1 TO max DO  { Alle Feldwerte suchen }
      BEGIN
        binaersuche(1,max,feld[i]);
        sekantensuche(1,max,1,max,feld[max]-feld[1],feld[i]);
      END;
    writeln('AUSWERTUNG:');
    writeln('Anzahl der Suchschritte um jedes Feldelement zu finden:');
    writeln;
    writeln('Suchschrittgesamtsumme  :');
    writeln('  BinÑrsuche: ',binz:10,'         Sekantensuche: ',suchz:10);
    writeln('Mittlere Suchschrittzahl:');
    writeln('  BinÑrsuche: ',binz/max:10:2, 
            '         Sekantensuche: ',suchz/max:10:2);
    writeln('Im Schnitt gesparte Suchschritte : ',(binz-suchz)/max:5:2);
    writeln;
    writeln('Abbruch mit (a), Weiter mit beliebiger Taste');
    read(taste)
  UNTIL taste='a' 
END.
