Program TetraX;
(* 
	Nach dem PC-Spiel Tetris von Spectrum Holobyte.
	Megamax Modula-2 Version von Heiko Annen Groeneveld. 
	Pure Pascal-Version von 
	Oliver Buchmann, Application Systems Heidelberg,  
	basierend auf der Modula-2 Version von Herrn Groeneveld, der 
	uns freundlicherweise gestattete, dieses Listing mitzuliefern. 
	Ein kleines Beispiel, wie wenig Aufwand es macht, ein 
	Modula-2-Listing auf Pure Pascal umzusetzen. Die Žnderungen
	erkennt man haupts„chlich an den aus Faulheit klein geschriebenen
	'begin's und 'end's und natrlich 'Writeln's. 
*)

{$i-} (* eigene I/O-šberprfung *)

uses tos, crt;

CONST XX    = 30;
      Hoch  = 22;
      Breit = 10;

TYPE TEins   = RECORD
                 X,Y:INTEGER;
               END;
     TVier   = ARRAY[1..3] OF TEins;
     TSteine = ARRAY[1..19] OF TVier;
     CharSet = SET OF CHAR;
     ScoreTable = ARRAY [1..10] OF
        RECORD
          Punkte: integer;
          Zeilen: integer;
          Name  : string[3];
        END;

VAR Steine        : TSteine;
    Art,OldA,nextart : INTEGER;
    Stein,OldSt   : RECORD
                     X,Y: INTEGER;
                    END;
    Stop          : BOOLEAN;
    KeinStein     : BOOLEAN;
    Feld          : ARRAY[-1..Breit+2] of array[-1..Hoch+2] OF BOOLEAN;
    Hoehe         : INTEGER;
    C             : CHAR;
    Lines,FAST    : integer;
    Delay,D,H,K   : integer;
    Score         : integer;
    Level,Stapel  : INTEGER;
    HallofFame    : ScoreTable;
    NewScore      : BOOLEAN;
	Filename	  : Text;
	verzoegerung  : integer;
    
PROCEDURE Initialisieren;
VAR I,J:INTEGER;
BEGIN
  Score:=0;
  FAST := 10;
  Delay := (10-Level) * 50;
  verzoegerung:=20;
  Randomize;
  ClrScr;
  GotoXY(1,1); Write('TetraX');
  GotoXY(1,5); Write('Zeilen:');
  GotoXY(1,7); Write('Punkte:');
  GotoXY(1,8); Write('HiScore');
  Lines:=0;
  GotoXY(9,5); Write(Lines:1);
  GotoXY(9,7); Write(Score:1);
  GotoXY(9,8); Write(HallofFame[1].Punkte:1);
  GotoXY(1,23);Write('1992 by Oliver Buchmann,');
  GotoXY(1,24);Write('        H. A. Groeneveld');
  gotoXY(60,24);
  write('Verz”gerung : ',verzoegerung);
  FOR I:=1 TO Hoch DO
  begin
    GotoXY(XX+1,Hoch+2-I);
    Write('|');
    GotoXY(XX+Breit*2+2,Hoch+2-I);
    Write('|');
  END;
  Hoehe:=0;
  Steine[1][1].X := 1;
  Steine[1][1].Y := 0;
  Steine[1][2].X := 0;
  Steine[1][2].Y := 1;
  Steine[1][3].X := 1;
  Steine[1][3].Y := 1;
  Steine[2][1].X := 0;
  Steine[2][1].Y := 1;
  Steine[2][2].X := 0;
  Steine[2][2].Y := 2;
  Steine[2][3].X := 0;
  Steine[2][3].Y := 3;
  Steine[3][1].X := -1;
  Steine[3][1].Y := 0;
  Steine[3][2].X := 1;
  Steine[3][2].Y := 0;
  Steine[3][3].X := 2;
  Steine[3][3].Y := 0;
  Steine[4][1].X := -1;
  Steine[4][1].Y := 0;
  Steine[4][2].X := 0;
  Steine[4][2].Y := 1;
  Steine[4][3].X := 1;
  Steine[4][3].Y := 1;
  Steine[5][1].X := 1;
  Steine[5][1].Y := 0;
  Steine[5][2].X := 0;
  Steine[5][2].Y := 1;
  Steine[5][3].X := -1;
  Steine[5][3].Y := 1;
  Steine[6][1].X := 1;
  Steine[6][1].Y := 0;
  Steine[6][2].X := 0;
  Steine[6][2].Y := 1;
  Steine[6][3].X := 0;
  Steine[6][3].Y := 2;
  Steine[7][1].X := -1;
  Steine[7][1].Y := 0;
  Steine[7][2].X := 0;
  Steine[7][2].Y := 1;
  Steine[7][3].X := 0;
  Steine[7][3].Y := 2;
  Steine[8][1].X := 0;
  Steine[8][1].Y := 1;
  Steine[8][2].X := -1;
  Steine[8][2].Y := 1;
  Steine[8][3].X := -1;
  Steine[8][3].Y := 2;
  Steine[9][1].X := 0;
  Steine[9][1].Y := 1;
  Steine[9][2].X := 1;
  Steine[9][2].Y := 1;
  Steine[9][3].X := 1;
  Steine[9][3].Y := 2;
  Steine[10][1].X := -1;
  Steine[10][1].Y := 0;
  Steine[10][2].X := 1;
  Steine[10][2].Y := 0;
  Steine[10][3].X := 1;
  Steine[10][3].Y := 1;
  Steine[11][1].X := -1;
  Steine[11][1].Y := 1;
  Steine[11][2].X := -1;
  Steine[11][2].Y := 0;
  Steine[11][3].X := 1;
  Steine[11][3].Y := 0;
  Steine[12][1].X := 0;
  Steine[12][1].Y := 1;
  Steine[12][2].X := 0;
  Steine[12][2].Y := 2;
  Steine[12][3].X := -1;
  Steine[12][3].Y := 2;
  Steine[13][1].X := 0;
  Steine[13][1].Y := 1;
  Steine[13][2].X := 0;
  Steine[13][2].Y := 2;
  Steine[13][3].X := 1;
  Steine[13][3].Y := 2;
  Steine[14][1].X := -1;
  Steine[14][1].Y := -1;
  Steine[14][2].X := -1;
  Steine[14][2].Y := 0;
  Steine[14][3].X := 1;
  Steine[14][3].Y := 0;
  Steine[15][1].X := -1;
  Steine[15][1].Y := 0;
  Steine[15][2].X := 1;
  Steine[15][2].Y := 0;
  Steine[15][3].X := 1;
  Steine[15][3].Y := -1;
  Steine[16][1].X := -1;
  Steine[16][1].Y := 0;
  Steine[16][2].X := 1;
  Steine[16][2].Y := 0;
  Steine[16][3].X := 0;
  Steine[16][3].Y := 1;
  Steine[17][1].X := 0;
  Steine[17][1].Y := 1;
  Steine[17][2].X := 1;
  Steine[17][2].Y := 1;
  Steine[17][3].X := 0;
  Steine[17][3].Y := 2;
  Steine[18][1].X := 0;
  Steine[18][1].Y := 1;
  Steine[18][2].X := -1;
  Steine[18][2].Y := 1;
  Steine[18][3].X := 1;
  Steine[18][3].Y := 1;
  Steine[19][1].X := 0;
  Steine[19][1].Y := 1;
  Steine[19][2].X := -1;
  Steine[19][2].Y := 1;
  Steine[19][3].X := 0;
  Steine[19][3].Y := 2;
  FOR I:=-1 TO Hoch+2 DO
  begin
    FOR J:=-1 TO Breit+2 DO
    begin
      Feld[J][I]:=TRUE;
    END;
  END;
  FOR I:=1 TO Hoch DO
  begin
    FOR J:=1 TO Breit DO
    begin
      Feld[J][I]:=FALSE;
    END;
  END;
  KeinStein:=TRUE;
END;

procedure get_taste;
VAR Taste : longint;
BEGIN
	Taste:=0;
	c:=' ';
	if Bconstat(2)=-1 then 
	begin 
		Taste:=Bconin(2);
		taste:=taste div 65536;
	end; 
    CASE Taste OF 
	77, 108 : 
		begin			
			(*rechts*)
			c:='6';
		end;
    75, 106 : 
		begin
			(*links*)
			c:='4';
		end;
	80, 110 : 
		begin
			(*unten*)
			c:='2';
		end;
    72, 107 : 
		begin
			(*oben*)
			c:='5';
		end;
	57 :
		begin
			(*Space fr Pause*)
			c:='P';
		end;
	16, 1 : 
		begin
			(* Esc oder Q zum Beenden *)
			c:='Q';
		end;
	 74		:
		begin
			if verzoegerung>0 then verzoegerung:=verzoegerung-1;
			gotoXY(60,24);
			write('Verz”gerung : ',verzoegerung,' ');
		end;
	  78	:
		begin
			if verzoegerung<50 then verzoegerung:=verzoegerung+1;
			gotoXY(60,24);
			write('Verz”gerung : ',verzoegerung,' ');
		end;
	END; (* case *)
end;

PROCEDURE schaff_platz;
	var i : integer;
BEGIN
	for i:=1 to 6 do 
	BEGIN
		gotoxy(54,i);write('                   ');
	END;
END;
 
PROCEDURE Abfrage;
VAR I,Entfernung: INTEGER;
    
 PROCEDURE RadierStein;
 BEGIN
   GotoXY(2*OldSt.X+XX,Hoch+2-OldSt.Y);
   Write(' '); Write(' ');
   GotoXY(2*(OldSt.X+Steine[OldA][1].X)+XX,Hoch+2-OldSt.Y-Steine[OldA][1].Y);
   Write(' '); Write(' ');
   GotoXY(2*(OldSt.X+Steine[OldA][2].X)+XX,Hoch+2-OldSt.Y-Steine[OldA][2].Y);
   Write(' '); Write(' ');
   GotoXY(2*(OldSt.X+Steine[OldA][3].X)+XX,Hoch+2-OldSt.Y-Steine[OldA][3].Y);
   Write(' '); Write(' ');
 END;

PROCEDURE zeigenext;
 BEGIN
 	schaff_platz;
   gotoxy(57,1);
   write('N„chster Stein:');
   GotoXY(2*Stein.X+XX+20,5);
   Write('['); Write(']');
   GotoXY(2*(Stein.X+Steine[nextart][1].X)+XX+20,5-Steine[nextart][1].Y);
   Write('['); Write(']');
   GotoXY(2*(Stein.X+Steine[nextart][2].X)+XX+20,5-Steine[nextart][2].Y);
   Write('['); Write(']');
   GotoXY(2*(Stein.X+Steine[nextart][3].X)+XX+20,5-Steine[nextart][3].Y);
   Write('['); Write(']');
 END;
 
 PROCEDURE MaleStein;
 BEGIN
   GotoXY(2*Stein.X+XX,Hoch+2-Stein.Y);
   Write('['); Write(']');
   GotoXY(2*(Stein.X+Steine[Art][1].X)+XX,Hoch+2-Stein.Y-Steine[Art][1].Y);
   Write('['); Write(']');
   GotoXY(2*(Stein.X+Steine[Art][2].X)+XX,Hoch+2-Stein.Y-Steine[Art][2].Y);
   Write('['); Write(']');
   GotoXY(2*(Stein.X+Steine[Art][3].X)+XX,Hoch+2-Stein.Y-Steine[Art][3].Y);
   Write('['); Write(']');
   OldSt:=Stein;
   OldA:=Art;
 END;
 PROCEDURE Turn(A:INTEGER);
 BEGIN
   IF NOT ( Feld[Stein.X,Stein.Y]
            OR Feld[Stein.X+Steine[A][1].X,Stein.Y+Steine[A][1].Y]
            OR Feld[Stein.X+Steine[A][2].X,Stein.Y+Steine[A][2].Y]
            OR Feld[Stein.X+Steine[A][3].X,Stein.Y+Steine[A][3].Y] )
   THEN
   begin
     Art := A;
     RadierStein;
     MaleStein;
   END;
 END;
 PROCEDURE Drehe;
 BEGIN
   CASE Art OF
    2: IF NOT ( Feld[Stein.X,Stein.Y+1]
                 OR Feld[Stein.X+Steine[3][1].X,Stein.Y+1+Steine[3][1].Y]
                 OR Feld[Stein.X+Steine[3][2].X,Stein.Y+1+Steine[3][2].Y]
                 OR Feld[Stein.X+Steine[3][3].X,Stein.Y+1+Steine[3][3].Y] )
        THEN
        begin
          Art := 3;
          Stein.Y := Stein.Y+1;
          RadierStein;
          MaleStein;
        END;
    3: Turn(2);
    4: Turn(8);
    5: Turn(9);
    6: Turn(10);
    7: Turn(15);
    8: Turn(4);
    9: Turn(5);
    10:Turn(12);
    11:Turn(7);
    12:Turn(14);
    13:Turn(11);
    14:Turn(6);
    15:Turn(13);
    16:Turn(19);
    17:Turn(16);
    18:Turn(17);
    19:Turn(18)
   ELSE
   END;
 END;
 PROCEDURE ErzeugStein;
 BEGIN
 	art:=nextart;
   Stein.X:=5;
   Stein.Y:=Hoch;
   WHILE ( Feld[Stein.X,Stein.Y]
           OR Feld[Stein.X+Steine[Art][1].X,Stein.Y+Steine[Art][1].Y]
           OR Feld[Stein.X+Steine[Art][2].X,Stein.Y+Steine[Art][2].Y]
           OR Feld[Stein.X+Steine[Art][3].X,Stein.Y+Steine[Art][3].Y] )
           AND (Stein.Y > Hoch-3) DO
   begin
     Stein.Y := Stein.Y-1;
   END;
   IF ( Feld[Stein.X,Stein.Y]
           OR Feld[Stein.X+Steine[Art][1].X,Stein.Y+Steine[Art][1].Y]
           OR Feld[Stein.X+Steine[Art][2].X,Stein.Y+Steine[Art][2].Y]
           OR Feld[Stein.X+Steine[Art][3].X,Stein.Y+Steine[Art][3].Y] )
           THEN
   begin
     Stop:=TRUE;
   END;
 END;

 PROCEDURE Uebernahme;
 VAR I:INTEGER;
 BEGIN
   Feld[Stein.X,Stein.Y]:=TRUE;
   IF Hoehe < Stein.Y THEN Hoehe:=Stein.Y;
   FOR I:=1 TO 3 DO
   begin
     Feld[Stein.X+Steine[Art][I].X,Stein.Y+Steine[Art][I].Y]:=TRUE;
     IF Hoehe < Stein.Y+Steine[Art][I].Y THEN
     begin
       Hoehe := Stein.Y+Steine[Art][I].Y;
     END;
   END;
 END;
 PROCEDURE Runter(From,Amount:INTEGER);
 VAR I,J:INTEGER;
 BEGIN
   FOR I:=From+Amount TO Hoehe DO
   begin
     FOR J:=1 TO Breit DO
     begin
       Feld[J][I-Amount] := Feld[J][I];
     END;
   END;
   FOR I:=Hoehe-Amount+1 TO Hoehe DO
   begin
     FOR J:=1 TO Breit DO
     begin
       Feld[J][I]:=FALSE;
     END;
   END;
   FOR I:=From TO Hoehe DO
   begin
     FOR J:=1 TO Breit DO
     begin
       IF Feld[J][I] THEN
       begin
         GotoXY(2*J+XX,Hoch+2-I);
         Write('['); Write(']');
       end
       ELSE
       begin
         GotoXY(2*J+XX,Hoch+2-I);
         Write(' '); Write(' ');
       END;
     END;
   END;
   Lines:=Lines+integer(Amount);
   IF Lines > FAST THEN
   begin
     IF Delay > 400 THEN Delay := Delay - Delay DIV 5;
     FAST:=FAST+10;
   END;
   GotoXY(9,5); Write(Lines:1);
   Write(CHR(7));
 END;
 
 PROCEDURE Packen;
 VAR I,J,Destroy:INTEGER;
     Leer:BOOLEAN;
 BEGIN
   I:=1;
   WHILE I <= Hoehe DO
   begin
     Leer:=TRUE;
     Destroy:=0;
     WHILE Leer DO
     begin
       FOR J:=1 TO Breit DO
       begin
         IF Feld[J][I] THEN
         begin
           Leer:=FALSE;
         END;
       END;
       IF Leer THEN
       begin
         Destroy:=Destroy+1;
         IF I<Hoehe THEN
         begin
           I:=I+1;
         end
         ELSE
         begin
           Leer:=FALSE;
           Lines:=Lines + integer(Destroy);
           Hoehe:=Hoehe - Destroy;
           IF Lines > FAST THEN
           begin
             IF Delay > 400 THEN Delay := Delay - Delay DIV 5;
             FAST:=FAST+10;
           END;
           GotoXY(9,5); Write(Lines:1);
           Write(CHR(7));
           Destroy:=0;
         END;
       END;
     END;
     I:=I-Destroy;
     IF Destroy > 0 THEN
     begin
       Runter(I,Destroy);
       Hoehe:=Hoehe-Destroy;
     END;
     I:=I+1;
   END;
 END;

 PROCEDURE VolleZeilen;
 VAR I,J : INTEGER;
     Voll,Pack: BOOLEAN;
 BEGIN
   Pack:=FALSE;
   FOR I:=1 TO Hoehe DO
   begin
     Voll:=TRUE;
     FOR J:=1 TO Breit DO
     begin
       IF NOT Feld[J][I] THEN Voll:=FALSE;
     END;
     IF Voll THEN
     begin
       Pack:=TRUE;
       FOR J:=1 TO Breit DO
       begin
         Feld[J][I] := FALSE;
         GotoXY(2*J+XX,Hoch+2-I);
         Write(' '); Write(' ');
       END;
     END;
   END;
   IF Pack THEN Packen;
 END;
 
BEGIN
  IF KeinStein THEN
  begin
    ErzeugStein;
    MaleStein;
    KeinStein := FALSE;
    nextart := INTEGER(system.Random(19)+1);
	 zeigenext;
  END;
  D:=0;
  WHILE D < Delay DO
  begin
	 get_taste;
    crt.delay(verzoegerung); (* Diese Warteschleife musste rein *)
    D:=D + Delay DIV 10;
    CASE C OF
     '4': IF NOT ( Feld[Stein.X-1,Stein.Y]
                   OR Feld[Stein.X+Steine[Art][1].X-1,Stein.Y+Steine[Art][1].Y]
                   OR Feld[Stein.X+Steine[Art][2].X-1,Stein.Y+Steine[Art][2].Y]
                   OR Feld[Stein.X+Steine[Art][3].X-1,Stein.Y+Steine[Art][3].Y] )
          THEN
          begin
            Stein.X := Stein.X-1;
            RadierStein;
            MaleStein;
          END; 
     '5': Drehe; 
     '6': IF NOT ( Feld[Stein.X+1,Stein.Y]
                   OR Feld[Stein.X+Steine[Art][1].X+1,Stein.Y+Steine[Art][1].Y]
                   OR Feld[Stein.X+Steine[Art][2].X+1,Stein.Y+Steine[Art][2].Y]
                   OR Feld[Stein.X+Steine[Art][3].X+1,Stein.Y+Steine[Art][3].Y] )
          THEN
          begin
            Stein.X := Stein.X+1;
            RadierStein;
            MaleStein;
          END;
     '2': begin
  	   	  	 I:=Stein.Y;
	          WHILE Feld[Stein.X][I] = FALSE DO I:=I-1;
	          Entfernung:=Stein.Y-I;
	          I:=Stein.Y+Steine[Art][1].Y;
	          WHILE Feld[Stein.X+Steine[Art][1].X][I] = FALSE DO I:=I-1;
	          IF Stein.Y+Steine[Art][1].Y-I < Entfernung THEN
	          begin
	            Entfernung:=Stein.Y+Steine[Art][1].Y-I;
	          END;
	          I:=Stein.Y+Steine[Art][2].Y;
	          WHILE Feld[Stein.X+Steine[Art][2].X][I] = FALSE DO I:=I-1;
	          IF Stein.Y+Steine[Art][2].Y-I < Entfernung THEN
	          begin
	            Entfernung:=Stein.Y+Steine[Art][2].Y-I;
	          END;
	          I:=Stein.Y+Steine[Art][3].Y;
	          WHILE Feld[Stein.X+Steine[Art][3].X][I] = FALSE DO I:=I-1;
	          IF Stein.Y+Steine[Art][3].Y-I < Entfernung THEN
	          begin
	            Entfernung:=Stein.Y+Steine[Art][3].Y-I;
	          END;
	          Stein.Y:=Stein.Y-Entfernung+1;
	          RadierStein;
	          MaleStein;
	          D:=Delay; 
          end;
     'P': WHILE NOT KeyPressed DO;
     'Q': Stop:=TRUE
    ELSE
      (* Rest ignorieren *)
    END; (* of CASE *)
  END; (* of WHILE *)
  IF NOT ( Feld[Stein.X,Stein.Y-1]
           OR Feld[Stein.X+Steine[Art][1].X,Stein.Y+Steine[Art][1].Y-1]
           OR Feld[Stein.X+Steine[Art][2].X,Stein.Y+Steine[Art][2].Y-1]
           OR Feld[Stein.X+Steine[Art][3].X,Stein.Y+Steine[Art][3].Y-1] )
  THEN
  begin
    Stein.Y := Stein.Y-1;
    RadierStein;
    MaleStein;
  end
  ELSE
  begin
    Score:=Score + Hoch - integer(Stein.Y);
    GotoXY(9,7); Write(Score:1);
    Uebernahme;
    KeinStein:=TRUE;
  END;
  VolleZeilen;
END;

PROCEDURE Aufruecken(I:INTEGER);
VAR K:INTEGER;
BEGIN
  FOR K:=9 downto I DO
  begin
    HallofFame[K+1]:=HallofFame[K];
  END;
END;

PROCEDURE Nameneingabe(I:INTEGER);
	var j : integer;
BEGIN
   for j:=1 to 6 do 
   begin
   	gotoxy(54,i);write('                    ');
   end;
  GotoXY(60,1); Write('Sie haben eine');
  GotoXY(59,2); Write('der zehn h”chsten');
  GotoXY(58,3); Write('Punktzahlen erreicht!');
  GotoXY(60,5); Write('Geben Sie Ihre');
  GotoXY(60,6); Write('Initialien ein:');
  GotoXY(60,7); Write('---');
  GotoXY(60,7);
  K:=1;
  REPEAT
    GotoXY(59+K,7);
    c:=Readkey;
    IF ord(c)>31 THEN
    begin
	  Write(c);
      HallofFame[I].Name[K]:=c;
      K:=K+1;
      IF K>3 THEN
      begin
        GotoXY(64,7); Write('<CR> ');
        c:=Readkey;
	    Write(c);
        IF c <> CHR(13) THEN
        begin
          GotoXY(64,7); Write('      ');
          K:=3;
        END;
      END;
    end
    ELSE
    begin
      IF (c = CHR(8)) AND (K > 1) THEN
	  begin
        K:=K-1
      end
      ELSE
      begin
        Write(CHR(7));
      END;
    END;
  UNTIL K>3;
END;

PROCEDURE HighscoreTable;
VAR K:INTEGER;
BEGIN
   for k:=1 to 6 do 
   begin
      	gotoxy(54,k);write('                          ');
   end;
  GotoXY(60,7); Write('Top Scores & Lines');
  GotoXY(60,8); Write('               ');
  FOR K:=1 TO 10 DO
  begin
    GotoXY(60,8+K);
    Write(HallofFame[K].Name:3);
    Write('  ');
    Write(HallofFame[K].Punkte:5);
    Write('   ');
    Write(HallofFame[K].Zeilen:1);
  END;
END;
PROCEDURE LevelEin;
BEGIN
  GotoXY(1,18); Write('Level (0-9)? ');
  REPEAT
	c:=Readkey;
	Write(c);
	level:=ord(c)-48;
  UNTIL (level>=0) and (level<=9);
  IF Level <> 0 THEN
  begin
    GotoXY(1,19); Write('H”he (0-9) ? ');
    REPEAT
  	  c:=Readkey;
	  Write(c);
      stapel:=ord(c)-48;
    UNTIL (stapel>=0) and (stapel<=9);
  END;
END;

BEGIN
    FOR H:=1 TO 10 DO
    begin
      HallofFame[H].Punkte:=100;
      HallofFame[H].Zeilen:=0;
      HallofFame[H].Name[1]:='-';
      HallofFame[H].Name[2]:='-';
      HallofFame[H].Name[3]:='-';
    END;
  NewScore:=FALSE;
  ClrScr;
  Assign(Filename,'HiScores.Tet');
  Reset(Filename);
  if IOResult=0 then
  begin
	ClrScr;
	Write('Lese Hiscoredaten ein...');
	ClrScr;
	for h:=1 to 10 do
	begin	
		readln(Filename,HallofFame[h].punkte);
		readln(Filename,HallofFame[h].zeilen);
		readln(Filename,HallofFame[h].name);
	end;
	close(Filename);
  end;
  LevelEin;
  IF Level <> 0 THEN
  begin
  REPEAT
    Initialisieren;
    FOR H:=1 TO ORD(Stapel) DO
    begin
      FOR K:=1 TO Breit DO
      begin
        IF (system.Random(4)=0) OR (system.Random(4)=1) THEN
        begin
          Feld[K,H]:=TRUE;
          GotoXY(2*K+XX,Hoch+2-H);
          Write('['); Write(']');
        END;
      END;
    END;
    Stop:=FALSE;
   nextart := INTEGER(system.Random(19)+1);
	REPEAT
      Abfrage;
    UNTIL Stop;
    IF Score > HallofFame[1].Punkte THEN
    begin
		schaff_platz;
      Aufruecken(1);
      HallofFame[1].Punkte:=Score;
      HallofFame[1].Zeilen:=Lines;
      GotoXY(9,8); Write(HallofFame[1].Punkte:1);
      GotoXY(4,11); Write('Gratulation,');
      GotoXY(1,13); Write('Sie haben den HiScore !');
      Nameneingabe(1);
      NewScore:=TRUE;
    end
    ELSE
    begin
      H:=2;
      REPEAT
        IF Score >= HallofFame[H].Punkte THEN
        begin
			 schaff_platz;
          Aufruecken(H);
          HallofFame[H].Punkte:=Score;
          HallofFame[H].Zeilen:=Lines;
          Nameneingabe(H);
          NewScore:=TRUE;
          H:=10;
        END;
        H:=H+1;
      UNTIL H > 10;
    END;
    HighscoreTable;
    GotoXY(1,17); Write('Game over !');
    LevelEin;
  UNTIL Level = 0;
  ClrScr;
  IF NewScore THEN
  begin
	Assign(Filename,'HiScores.Tet');
	ReWrite(Filename);
    IF IOResult <> 0 THEN
    begin
	  ClrScr;
      Writeln('Fehler beim ™ffnen (2)! <Taste> ');
      c:=Readkey;
    END;
	for h:=1 to 10 do
	begin
		writeln(Filename,HallofFame[h].punkte);
		writeln(Filename,HallofFame[h].zeilen);
		writeln(Filename,HallofFame[h].name);
	end;
    IF IOResult <> 0 THEN
    begin
      ClrScr;
      Writeln('Fehler beim Schreiben (2)! <Taste> ');
      c:=Readkey;
    END;
    Close(Filename);
    IF IOResult <> 0 THEN
	  begin
	  ClrScr;
      Writeln('Fehler beim Schliežen (3)! <Taste> ');
      c:=Readkey;
    END;
  END; (* of IF NewScore *)
  end;
end.