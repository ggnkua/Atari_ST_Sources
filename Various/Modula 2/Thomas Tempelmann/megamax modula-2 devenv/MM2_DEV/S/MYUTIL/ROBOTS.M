MODULE Roboter;

IMPORT RandomGen, TOSIO, InOut;

(*
  Beispielprogramm fr Soft~wave Modula-2
  von Rolf H„nisch, Katzbachstr. 6, 1000 Berlin 61
  
  Anpassung auf Megamax M-2 am 28.5.88 von Thomas Tempelmann
  - GEMDOS.Crawcin -> InOut.Read
  - XBIOS.Random -> RandomGen.RandomCard
  - Tastenbelegung auf Zehnerblock
  - Prozeduren vertauscht wg. 1-Pass
  - 'Setze'-Aufruf in 'SpielStand' erzeugte Range Error -> GotoXY verwendet
  - 'NeuerPlatz': 'Random'-Aufruf erzeugte Range Error -> "+1" entfernt
  - TOSIO importiert
*)

CONST
     ICH = '@';
     ROB = '=';
     BLECH = '#';
     MAMPF = '*';
     LEER = ' ';
     ESC = 33C;

TYPE
        SHORTINT = INTEGER;
        SHORTCARD= CARDINAL;
        
        Cardinal = LONGCARD;
        
     roboter = RECORD
               lebend: BOOLEAN;
               X, Y: SHORTINT;
               END;

CONST
     MAXROBOTER = 300;
VAR
     RoboterListe : ARRAY [1..MAXROBOTER] OF roboter;

     RoboterZahl,
     LebendeRoboter,
     FreieTeleports,
     TeleportsProEbenen,

     Ebene               : SHORTINT;

     MeinX,
     MeinY: SHORTINT;

CONST
     MAXZEILE = 23;
     MAXSPALTE = 79;

VAR
     Besetzt : ARRAY [0..MAXSPALTE],[0..MAXZEILE] OF CHAR;
     Gegessen : BOOLEAN;
     Warten: BOOLEAN;
     FeieTeleports,
     TeleportsProEbene: SHORTINT;

PROCEDURE Random (n: Cardinal): CARDINAL;
  BEGIN
    RETURN RandomGen.RandomCard (0,SHORT(n))
  END Random;

PROCEDURE ZeichneBildSchirm;
VAR
     i, j: SHORTCARD;
BEGIN
     (* Bildschirm loeschen *)
     InOut.Write (ESC);
     InOut.Write ('E');
     (* Karte Loeschen *)
     FOR i := 0 TO MAXSPALTE DO
          FOR j := 0 TO MAXZEILE DO
               Besetzt [i][j] := ' ';
               END;
          END;
END ZeichneBildSchirm;

PROCEDURE NeuerPlatz (VAR x, y: SHORTINT): CHAR;
BEGIN
     x := Random (MAXSPALTE);
     y := Random (MAXZEILE);
     RETURN Besetzt [x][y];
END NeuerPlatz;

PROCEDURE FreierPlatz (z: CHAR; VAR x, y: SHORTINT);
BEGIN
     REPEAT
     UNTIL NeuerPlatz (x, y) = ' ';
     Besetzt [x][y] := z;
END FreierPlatz;

PROCEDURE Setze (z: CHAR; x, y: SHORTCARD);
BEGIN
     Besetzt [x, y] := z;
     InOut.Write (ESC);
     InOut.Write ('Y');
     InOut.Write (CHR (ORD (' ') + y));
     InOut.Write (CHR (ORD (' ') + x));
     InOut.Write (z);
END Setze;

PROCEDURE SetzeRoboter;
VAR
     i, x, y: SHORTINT;
BEGIN
     FOR i := 1 TO RoboterZahl DO
          FreierPlatz (ROB, x, y);
          WITH RoboterListe [i] DO
               X := x;
               Y := y;
               lebend := TRUE;
               END (*WITH*);
          Setze (ROB, x, y);
          END (*FOR*);
END SetzeRoboter;

PROCEDURE NaechsteBewegung;
VAR
     c: CHAR;
     x, y: SHORTINT;
     Bewegt, Weiter: BOOLEAN;
BEGIN
     Bewegt := FALSE;
     REPEAT
          REPEAT
               Weiter := TRUE;
               IF Warten THEN c := '.'
               ELSE InOut.Read (c);
               END;
               CASE c OF
                    | '7': x := -1; y := -1;
                    | '9': x :=  1; y := -1;
                    | '1': x := -1; y :=  1;
                    | '3': x :=  1; y :=  1;
                    | '4': x := -1; y :=  0;
                    | '2': x :=  0; y :=  1;
                    | '8': x :=  0; y := -1;
                    | '6': x :=  1; y :=  0;
                    | '5': x :=  0; y :=  0;
                    | 'q', ESC: HALT;
                    | '.': x := 0; y := 0; Warten := TRUE;
                    | '0':
                         Weiter := FALSE;
                         Setze (LEER, MeinX, MeinY);
                         IF FreieTeleports > 0
                         THEN DEC (FreieTeleports);
                              REPEAT
                              UNTIL NeuerPlatz (MeinX, MeinY) = LEER;
                              Setze (ICH, MeinX, MeinY);
                         ELSE IF NeuerPlatz (MeinX, MeinY) = LEER
                              THEN Setze (ICH, MeinX, MeinY);
                              ELSE Setze (MAMPF, MeinX, MeinY);
                                   Gegessen := TRUE;
                                   Weiter := TRUE;
                                   END;
                              END;
                    END (*CASE*);
               UNTIL Weiter;
          IF ((MeinX + x) < 0) OR
               ((MeinX + x) > MAXSPALTE) OR
               ((MeinY + y) < 0) OR
               ((MeinY + y) > MAXZEILE)
          THEN InOut.Write (7C);
          ELSE Setze (LEER, MeinX, MeinY);
               Bewegt := TRUE;
               END;
     UNTIL Bewegt;
     MeinX := MeinX + x;
     MeinY := MeinY + y;
     CASE Besetzt [MeinX, MeinY] OF
          | ROB: Setze (MAMPF, MeinX, MeinY);
               Gegessen := TRUE;
          | BLECH:
               IF ((MeinX + x) >= 0) AND
                    ((MeinX + x) <= MAXSPALTE) AND
                    ((MeinY + y) >= 0) AND
                    ((MeinY + y) <= MAXZEILE) AND
                    (Besetzt [MeinX + x, MeinY + y] = LEER)
               THEN Setze (BLECH, MeinX + x, MeinY + y);
                    Setze (ICH, MeinX, MeinY);
               ELSE MeinX := MeinX - x;
                    MeinY := MeinY - y;
                    Setze (ICH, MeinX, MeinY);
                    END;
          | LEER:
               Setze (ICH, MeinX, MeinY);
               END (*CASE*);
END NaechsteBewegung;

PROCEDURE RoboterBewegung;
VAR
     i, j: SHORTINT;
BEGIN
     FOR i := 1 TO RoboterZahl DO
          WITH RoboterListe [i] DO
               IF lebend
               THEN Setze (' ', X, Y);
                    IF X > MeinX THEN DEC (X) ELSIF X < MeinX THEN INC (X) END;
                    IF Y > MeinY THEN DEC (Y) ELSIF Y < MeinY THEN INC (Y) END;
                    END;
               END;
          END;
     FOR i := 1 TO RoboterZahl DO
          WITH RoboterListe [i] DO
               IF lebend
               THEN CASE Besetzt [X, Y] OF
                    | LEER: Setze (ROB, X, Y);
                    | ROB : Setze (BLECH, X, Y);
                         lebend := FALSE;
                         DEC (LebendeRoboter);
                         FOR j := 1 TO RoboterZahl DO
                              IF (X = RoboterListe [j].X)
                              AND (Y = RoboterListe [j].Y)
                              AND RoboterListe [j].lebend
                              THEN RoboterListe [j].lebend := FALSE;
                                   DEC (LebendeRoboter);
                                   END;
                              END;
                    | BLECH:
                         lebend := FALSE;
                         DEC (LebendeRoboter);
                    | ICH : Setze (MAMPF, X, Y);
                         Gegessen := TRUE;
                         END (*CASE*);
                    END (*IF*);
               END (*WITH*);
          END (*FOR*);
END RoboterBewegung;

PROCEDURE SpielStand;
BEGIN
     InOut.GotoXY (0, 24);
     InOut.Write ('(');
     InOut.WriteCard (FreieTeleports, 0);
     InOut.WriteString (')  ');
     InOut.WriteCard (Ebene, 0);
     InOut.WriteString ('. Ebene; ');
     InOut.WriteInt (LebendeRoboter, 0);
     InOut.WriteString (' Roboter        ');
END SpielStand;

PROCEDURE RoboterSpiel;
VAR
     x: CHAR;
BEGIN
     FreieTeleports := 0;
     TeleportsProEbene := 1;
     Ebene := 0;
     RoboterZahl := 0;
     Gegessen := FALSE;
     REPEAT
          Warten := FALSE;
          FreieTeleports := FreieTeleports + TeleportsProEbene;
          INC (RoboterZahl, 10);
          LebendeRoboter := RoboterZahl;
          INC (TeleportsProEbene);
          INC (Ebene);
          ZeichneBildSchirm;
          SetzeRoboter;
          FreierPlatz (ICH, MeinX, MeinY);
          Setze (ICH, MeinX, MeinY);
          LOOP
               SpielStand;
               IF LebendeRoboter = 0 THEN EXIT END;
               NaechsteBewegung;
               RoboterBewegung;
               IF Gegessen THEN EXIT END;
               END;
          UNTIL Gegessen;
     InOut.Read (x);
END RoboterSpiel;

BEGIN
     RoboterSpiel;
END Roboter.
 