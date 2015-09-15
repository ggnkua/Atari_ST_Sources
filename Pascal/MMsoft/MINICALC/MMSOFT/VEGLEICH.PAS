PROGRAM AV_System;

{ Dieses Programm dient zum Vergleich von Angeboten. Falls sie an der
  Kaufm„nnischen Schule sind, so k”nnen sie dieses Programm durch
  ASCII-šbertragung auch auf einen DOSen-Rechner unter Turbo-Pascal
  einsetzen. Sie sollten aber keine Tabulatoren einbauen (Tab-Taste!),
  da unter DOS dort ein anderes ASCII-Kommando ist! }

USES   crt,printer;   { Programm braucht CRT (nur bei DOS) und PRINTER }

{ Die Zeile USES bei Turbo-Pascal 3.0 l”schen!!! }

TYPE   strg = STRING[255];      { Wegen Turbo-Pascal 3.0 }

VAR   head         : ARRAY[1..5] OF STRG;      { Angebotskopf }
      maske         : ARRAY[0..14] OF STRG;      { Fr Maskenverarbeitung }
      back         : ARRAY[1..3] OF STRG;      { Ergebnissanhang }
      lieferer      : ARRAY[1..4] OF STRG;      { Fr die Lieferernamen }
      artikel      : STRG;                     { Artikelname }
      listpr,                                 { Listenpreis / Stck }
      rabattpr,                              { Rabatt in DM }
      zieleinpr,                              { Zieleinkaufspreis }
      skontopr,                              { Skonto in DM }
      barpr,                                 { Bareinkaufspreis }
      bezugsk,
      endpr,                                 { Einstandspreis }
      rabatt,                                 { Rabatt in % }
      skonto      : ARRAY[1..4] OF REAL;      { Skonto in % }
      cheaplyl      : STRG;                     { Der gnstigste Lieferant }
      cheaplya      : REAL;                     { ...mit einen Preis von... }
      cheaplyastr : STRG;                     { als String }
      max         : INTEGER;                  { Anzahl der Vergleiche }
      key         : CHAR;                     { Taste }

PROCEDURE maskenaufbau;      { Erstellt die Maske zur Darstellung }
VAR   m,
      i,
      j   : INTEGER;         { lokale Variable }
BEGIN
   head[1]  := '                       A N G E B O T S V E R G L E I C H';
   head[2]  := '                       =================================';
   head[3]  := ' ';
   head[4]  := ' Artikel: ';
   head[5]  := ' ';
   maske[0] := ' .--------------------.';
   maske[1] := ' |Lieferant:          |';   { einzelne Arrays fllen }
   maske[2] := ' |--------------------|';
   maske[3] := ' |                    |';
   maske[4] := ' |Listenpreis/Stck   |';
   maske[5] := ' |- Rabatt            |';
   maske[6] := ' |--------------------|';
   maske[7] := ' |Zieleinkaufspreis   |';
   maske[8] := ' |- Skonto            |';
   maske[9] := ' |--------------------|';
   maske[10]:= ' |Bareinkaufspreis    |';
   maske[11]:= ' |+ Bezugskosten      |';
   maske[12]:= ' |--------------------|';
   maske[13]:= ' |Einstandspreis      |';
   maske[14]:= ' ======================';
   FOR i := 1 TO max DO      { Masken nach Anzahl d. Lieferanten erweitern }
   BEGIN
      maske[0] := maske[0] + '-------------.';
      maske[1] := maske[1] + '             |';
      maske[2] := maske[2] + '-------------|';
      maske[3] := maske[3] + ' % |  in DM  |';
      m := 0;               { Z„hlwert auf 0 setzen }
      FOR j := 4 TO 6 DO   { Schleifen k”nnen unn”tige Arbeit ersparen.. }
      BEGIN
         m := m + 3;
         maske[m+1] := maske[m+1] + '   |         |';
         maske[m+2] := maske[m+2] + '   |         |';
         maske[m+3] := maske[m+3] + '---|---------|';
      END;
      maske[13] := maske[13] + '   |         |';
      maske[14] := maske[14] + '==============';
   END;
   back[1] := ' ';
   back[2] := '                      gnstigster Lieferant: ';
   back[3] := '                      gnstigstes Angebot  : ';
   
   FOR i := 1 TO 5 DO      { Header auf Bildschirm ausgeben }
      Writeln(head[i]);
   FOR i := 0 TO 14 DO      { Maske auf Bildschirm ausgeben }
      Writeln(maske[i]);
   FOR i := 1 TO 3 DO      { Ergebniss auf Bildschirm ausgeben }
      Writeln(back[i]);
END;

FUNCTION zeile( wert : REAL; wich : BOOLEAN ) : STRG;
VAR   zl : STRG;
BEGIN
   IF wich = TRUE THEN
      Str(wert:9:2,zl)
   ELSE
      Str(wert:3:0,zl);
   zeile := zl;
END;

PROCEDURE werteeingabe;
VAR   m,
      i   : INTEGER;      { lokale Variablen }
BEGIN
   Gotoxy(11,4);
   Readln(artikel);
   head[4] := head[4] + artikel;

   m := 24;
   FOR i := 1 TO max DO
   BEGIN
      Gotoxy(m,7);               { Cursor auf richtige Stelle setzen }
      Readln(lieferer[i]);
      Delete(maske[1], m, Length(lieferer[i]));
      Insert(lieferer[i], maske[1], m);

      Gotoxy(m+4,10);
      Readln(listpr[i]);                        { Listenpreis einlesen }
      Delete(maske[4], m+4, 9);
      Insert(zeile(listpr[i],TRUE), maske[4], m+4);

      Gotoxy(m,11);
      Readln(rabatt[i]);                        { Rabatt einlesen }
      Delete(maske[5], m, 3);
      Insert(zeile(rabatt[i],FALSE), maske[5], m);
      rabattpr[i] := (listpr[i] * rabatt [i])/100; { Rabatt ausrechnen }
      zieleinpr[i] := listpr[i] - rabattpr[i];   { Zieleinkaufspreis ausr.}
      Delete(maske[5], m+4, 9);            { errechnete Werte einsetzen }
      Insert(zeile(rabattpr[i],TRUE), maske[5], m+4);
      Delete(maske[7], m+4, 9);
      Insert(zeile(zieleinpr[i],TRUE), maske[7], m+4);

      Gotoxy(m,14);
      Readln(skonto[i]);                        { Skonto einlesen }
      Delete(maske[8], m, 3);
      Insert(zeile(skonto[i],FALSE), maske[8], m);
      skontopr[i] := (zieleinpr[i] * skonto [i])/100; { Skonto ausrechnen }
      barpr[i] := zieleinpr[i] - skontopr[i];   { Bareinkaufspreis ausr. }
      Delete(maske[8], m+4, 9);            { errechnete Werte einsetzen }
      Insert(zeile(skontopr[i],TRUE), maske[8], m+4);
      Delete(maske[10], m+4, 9);
      Insert(zeile(barpr[i],TRUE), maske[10], m+4);

      Gotoxy(m+4,17);
      Readln(bezugsk[i]);                        { Bezugskosten einlesen }
      Delete(maske[11], m+4, 9);
      Insert(zeile(bezugsk[i],TRUE), maske[11], m+4);

      endpr[i] := barpr[i] + bezugsk[i];   { Einstandspreis=Barpreis+Bezugsk. } 
      Delete(maske[13], m+4, 9);
      Insert(zeile(endpr[i],TRUE), maske[13], m+4);
      m := m + 14;            { Cursor um eine Spalte verschieben }
   END;
END;

PROCEDURE cheapest;
VAR   i : INTEGER;   { lokale Variable }
BEGIN
   cheaplya := 999999;
   FOR i := 1 TO max DO
   BEGIN
      IF cheaplya >= endpr[i] THEN { Ist dieser Preis gnstiger? }
      BEGIN
         cheaplya := endpr[i];   { Dann als gnstigstes einsetzen! }
         cheaplyl := lieferer[i];
      END;
   END;
END;

PROCEDURE hauptprogramm;
VAR   i : INTEGER;   { lokale Variable }
BEGIN
   ClrScr;      { Bildschirm l”schen }
   Writeln('*** AV-System 2.0 TOS-Version (c) 1992/93 by MMsoft ***');
   Writeln;
   REPEAT
      Write('Wieviel Preise wollen sie vergleichen? (max.4): ');
      Readln(max);
   UNTIL (max > 0) AND (max < 5);   { Weiter, wenn Bedingung erfllt }
   ClrScr;
   maskenaufbau;         { Prozeduraufruf }
   werteeingabe;
   cheapest;
   back[2] := back[2] + cheaplyl;
   Str(cheaplya:1:2,cheaplyastr);
   back[3] := back[3] + cheaplyastr + ' DM';
   ClrScr;
   FOR i := 1 TO 5 DO      { Header auf Bildschirm ausgeben }
      Writeln(head[i]);
   FOR i := 0 TO 14 DO      { Maske auf Bildschirm ausgeben }
      Writeln(maske[i]);
   FOR i := 1 TO 3 DO      { Ergebniss auf Bildschirm ausgeben }
      Writeln(back[i]);
   Write('Liste drucken? (j/n): ');
   Readln(key);
   IF key = 'j' THEN
   BEGIN
      FOR i := 1 TO 5 DO      { Header auf Drucker ausgeben }
         Writeln(Lst,head[i]);
      FOR i := 0 TO 14 DO      { Maske auf Drucker ausgeben }
         Writeln(Lst,maske[i]);
      FOR i := 1 TO 3 DO      { Ergebniss auf Bildschirm ausgeben }
         Writeln(Lst,back[i]);
   END;
END;

BEGIN      { Hier f„ngt es an ! }
   REPEAT
      hauptprogramm;      { Hauptprogramm aufrufen }
      Write('Noch ein Vergleich? (j/n): ');
      Readln(key);
   UNTIL key <> 'j' { Wenn was anderes wie ja, dann Programm beenden! }
END.