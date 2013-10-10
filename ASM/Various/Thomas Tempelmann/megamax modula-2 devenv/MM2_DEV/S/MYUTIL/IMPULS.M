MODULE Impuls;

(*
  Beispielprogramm fr Soft~wave Modula-2
  von Rolf H„nisch, Katzbachstr. 6, 1000 Berlin 61
  
  Anpassung auf Megamax M-2 am 28.5.88 & 18.2.90 von Thomas Tempelmann
  - Prozeduren vertauscht wg. 1-Pass
  - In 'BewegeKugeln' Const Expr. durch CONSTs ersetzt.
  - Reg-Vars eingesetzt
*)

FROM SYSTEM IMPORT ADDRESS, ADR, BITNUM;
IMPORT BIOS, XBIOS, LineA;
FROM GrafBase IMPORT Pnt;

CONST
     MAXKugeln = 8;

     DELTA = 0;
     MAXX = 640-16-DELTA;
     MAXY = 400-16-DELTA;
     MINX = DELTA;
     MINY = DELTA;
     FAKTOR = 50;
     MINX_FAKTOR = MINX * FAKTOR;
     MINY_FAKTOR = MINY * FAKTOR;
     MAXX_FAKTOR = MAXX * FAKTOR;
     MAXY_FAKTOR = MAXY * FAKTOR;
     MAXV = 8;
     MAXV_FAKTOR = MAXV * FAKTOR;
     WZEIT = 00;
     g = 0;

TYPE
        SHORTINT = INTEGER;
        Integer = LONGINT;
        BitSet = SET OF BITNUM [0..15];
        
     Kugel = RECORD
          xx, yy,
          px, py,
          vx, vy : Integer;
          Sprite : ADDRESS;
          buffer : ARRAY [0..99] OF CHAR;
          END;

     Kugeln = [1..MAXKugeln];
     KList = ARRAY Kugeln OF INTEGER;

VAR

     Abstand : ARRAY Kugeln OF ARRAY Kugeln OF Integer;

     KugelListe : ARRAY Kugeln OF Kugel;

     Ordnung, XOrdnung : KList;

     sprite: RECORD
               x: SHORTINT;
               y: SHORTINT;
               form: SHORTINT;
               back: SHORTINT;
               forg: SHORTINT;
               image: ARRAY [0..31] OF BitSet;
             END;

PROCEDURE InitSprite;
BEGIN
     sprite.x := 0;
     sprite.y := 0;
     sprite.form := -1;
     sprite.back := 0;
     sprite.forg := 1;
     
     sprite.image [0]:= BitSet {6..10};
     sprite.image [2]:= BitSet {4..12};
     sprite.image [4]:= BitSet {3..13};
     sprite.image [6]:= BitSet {2..14};
     sprite.image [8]:= BitSet {2..14};
     sprite.image [10]:= BitSet {1..15};
     sprite.image [12]:= BitSet {1..15};
     sprite.image [14]:= BitSet {1..15};
     sprite.image [16]:= BitSet {1..15};
     sprite.image [18]:= BitSet {1..15};
     sprite.image [20]:= BitSet {2..14};
     sprite.image [22]:= BitSet {2..14};
     sprite.image [24]:= BitSet {3..13};
     sprite.image [26]:= BitSet {4..12};
     sprite.image [28]:= BitSet {6..10};
     sprite.image [30]:= BitSet {};

     sprite.image [1]:= BitSet {6..10};
     sprite.image [3]:= BitSet {4..7, 9..12};
     sprite.image [5]:= BitSet {3..6, 11..13};
     sprite.image [7]:= BitSet {2..7, 12..14};
     sprite.image [9]:= BitSet {2..9, 13..14};
     sprite.image [11]:= BitSet {1..10, 13..15};
     sprite.image [13]:= BitSet {1..11, 14..15};
     sprite.image [15]:= BitSet {1..11, 13..15};
     sprite.image [17]:= BitSet {1..15};
     sprite.image [19]:= BitSet {1..15};
     sprite.image [21]:= BitSet {2..14};
     sprite.image [23]:= BitSet {2..14};
     sprite.image [25]:= BitSet {3..13};
     sprite.image [27]:= BitSet {4..12};
     sprite.image [29]:= BitSet {6..10};
     sprite.image [31]:= BitSet {};
     
END InitSprite;

PROCEDURE Zufall (min, max: Integer): Integer;
BEGIN
     RETURN LONGINT(XBIOS.Random ()) MOD (max-min) + min;
END Zufall;

PROCEDURE InitKugeln;
VAR
     i: SHORTINT;
BEGIN
     FOR i := 1 TO MAXKugeln DO
          WITH KugelListe [i] DO
               Sprite := ADR (sprite);
               px := Zufall (MINX_FAKTOR, MAXX_FAKTOR);
               py := Zufall (MINY_FAKTOR, MAXY_FAKTOR);
               xx := px DIV FAKTOR;
               yy := py DIV FAKTOR;
               vx := Zufall (-MAXV_FAKTOR, MAXV_FAKTOR);
               vy := Zufall (-MAXV_FAKTOR, MAXV_FAKTOR);
          END (*WITH*);
     END (*FOR*);
END InitKugeln;

PROCEDURE Ordne (VAR Ordnung: KList);
VAR
     (*$Reg*)i, (*$Reg*)j, (*$Reg*)k, (*$Reg*)t: SHORTINT;
BEGIN
     Ordnung [1] := 1;
     FOR i := 2 TO MAXKugeln DO
          k := i;
          FOR j := 1 TO i - 1 DO
               IF KugelListe [Ordnung [j]].yy > KugelListe [k].yy
               THEN t := Ordnung [j];
                    Ordnung [j] := k;
                    k := t;
                    END;
               END;
          Ordnung [i] := k;
          END;
END Ordne;

VAR
     pink: ARRAY [0..5] OF CHAR;
     ip: ARRAY [0..19] OF CHAR;

PROCEDURE Pink;
BEGIN (* Pink *)
     XBIOS.DoSound (ADR (pink));
END Pink;

PROCEDURE EndPink;
BEGIN (* EmdPink *)
     ip [0] := 07C;
     ip [1] := 77C;
     ip [2] := 377C;
     ip [3] := 00C;
     XBIOS.DoSound (ADR (ip));
END EndPink;

PROCEDURE MaleKugeln;
VAR
     i: SHORTINT;
     b: LineA.PtrSpriteBuffer;
     
BEGIN
     FOR i := 1 TO MAXKugeln DO
          WITH KugelListe [Ordnung [i]] DO
               IF (xx < 640) AND (yy < 400) THEN
                   b.onePlane:= ADR (buffer);
                   LineA.DrawSprite (Pnt(SHORT(xx), SHORT(yy)), Sprite, b);
               END;
          END (*WITH*);
     END (*FOR*);
END MaleKugeln;

PROCEDURE LoescheKugeln;
VAR
     i: SHORTINT;
     b: LineA.PtrSpriteBuffer;
     
BEGIN
     FOR i := MAXKugeln TO 1 BY - 1 DO
          WITH KugelListe [Ordnung [i]] DO
               b.onePlane:= ADR (buffer);
               LineA.UndrawSprite (b);
               END (*WITH*);
          END (*FOR*);
END LoescheKugeln;

PROCEDURE BewegeKugeln;

VAR  (*$Reg*)i, (*$Reg*)j : SHORTINT;
     a, b,
     (*$Reg*)x2, (*$Reg*)y2, d,
     VX0, VX1,
     VY0, VY1,
     vjx3, vjx4,
     vjy3, vjy4,
     vix3, vix4,
     viy3, viy4: Integer;
     Kollision : BOOLEAN;
     Fehler: BOOLEAN;

BEGIN
     FOR i := 1 TO MAXKugeln DO
          WITH KugelListe [i] DO

               px:= px + vx;
               IF px < MINX_FAKTOR THEN vx := -vx; px:= px + vx; END;
               IF px > MAXX_FAKTOR THEN vx := -vx; px:= px + vx; END;
               xx := px DIV FAKTOR;

               py:= py + vy;
               IF py < MINY_FAKTOR THEN vy := -vy; py:= py + vy; END;
               IF py > MAXY_FAKTOR THEN vy := -vy; py:= py + vy; END;
               yy := py DIV FAKTOR;

               END (*WITH*);
          END (*FOR*);

     Kollision := FALSE;
     Fehler := FALSE;
     FOR i := 1 TO MAXKugeln - 1 DO
          FOR j := i + 1 TO MAXKugeln DO
               x2 := KugelListe [j].py - KugelListe [i].py;
               y2 := - (KugelListe [j].px - KugelListe [i].px);
               d := x2 * x2 + y2 * y2;
               IF (d < 15 * 15 * FAKTOR * FAKTOR)
               AND (d < Abstand [i][j])
               THEN (* Kollision *)
                    Kollision := TRUE;
                    (* v3 = Eigengeschwindigkeit *)
                    (* v4 = Impulsgeschwindigkeit *)
                    WITH KugelListe [j] DO
                         a := vy * x2 - vx * y2;
                         vjy4 := x2 * a DIV d;
                         vjx4 := y2 * (-a) DIV d;
                         (**)
                         b := vy * y2 + vx * x2;
                         vjy3 := y2 * b DIV d;
                         vjx3 := x2 * b DIV d;
                         (*
                         vjy3 := vy - vjy4;
                         vjx3 := vx - vjx4;
                         *)
                    END (*WITH*);
                    WITH KugelListe [i] DO
                         a := vy * x2 - vx * y2;
                         viy4 := x2 * a DIV d;
                         vix4 := y2 * (-a) DIV d;
                         (**)
                         b := vy * y2 + vx * x2;
                         viy3 := y2 * b DIV d;
                         vix3 := x2 * b DIV d;
                         (*
                         viy3 := vy - viy4;
                         vix3 := vx - vix4;
                         *)
                    END (*WITH*);
                    KugelListe [j].vx := vjx3 + vix4;
                    KugelListe [j].vy := vjy3 + viy4;
                    KugelListe [i].vx := vix3 + vjx4;
                    KugelListe [i].vy := viy3 + vjy4;
               END;
               Abstand [i][j] := d;
          END (*FOR*);
     END (*FOR*);
     IF Kollision THEN Pink END;
END BewegeKugeln;

PROCEDURE InitPink;
BEGIN
     (* Register 0/1 = 41 (Frequenz) *)
     ip [0] := 00C;
     ip [1] := 51C;
     ip [2] := 01C;
     ip [3] := 00C;
     (* Register 8 = Steuerung durch Hllkurve *)
     ip [4] := 10C;
     ip [5] := 20C;
     (* Register 13 = Art der Huelkurve *)
     ip [6] := 15C;
     ip [7] := 00C;
     (* Register 11/12 = 3276 (Laenge der Hllkurve) *)
     ip [8] := 13C;
     ip [9] := 314C;
     ip [10] := 14C;
     ip [11] := 14C;
     (* Register 7 = A Kanal einschalten *)
     ip [12] := 07C;
     ip [13] := 76C;
     (* Ende *)
     ip [14] := 377C;
     ip [15] := 0C;
     XBIOS.DoSound (ADR (ip));
     pink [0] := 15C;
     pink [1] := 11C;
     pink [2] := 377C;
     pink [3] := 14C;
     pink [4] := 377C;
     pink [5] := 00C;
END InitPink;

PROCEDURE Impuls;
VAR
     lc: LONGCARD;
     Zaehler: SHORTINT;

     PROCEDURE Warten;
     VAR
          i : SHORTINT;
     BEGIN
          XBIOS.VSync;
          FOR i := 0 TO WZEIT DO END;
     END Warten;

BEGIN
     InitSprite;
     InitKugeln;
     Ordne (Ordnung);
     MaleKugeln;
     REPEAT
          Warten;
          BewegeKugeln;
          Ordne (XOrdnung);
          LoescheKugeln;
          Ordnung := XOrdnung;
          MaleKugeln;
     UNTIL BIOS.BConStat (BIOS.CON);
     lc:= BIOS.BConIn (BIOS.CON);
     LoescheKugeln;
END Impuls;


BEGIN
     (*LineA.HideMouse;*)
     InitPink;
     Impuls;
     EndPink;
     (*LineA.ShowMouse(TRUE);*)
END Impuls.
 
(* $FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$0000106F$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$FFEA4CE4$00001E23T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$0000030E$00001B4B$00001D74$FFEA33DA$FFEA33DA$00001B99$00001B15$00001BFA$00001C87$00001E23$00001E9A$00001607$00001514$00000137$000000A9$FFEA33DA¬€€*)
