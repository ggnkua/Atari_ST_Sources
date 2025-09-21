PROGRAM Cube;      { Author: William P. Smith  }
                   {         Mitchellville, Md }

                   { This is a real time graphics demo of a cube tumbling in }
                   { 3-space.   The 8088 processor is just too slow to do    }
                   { effectively demonstrate real time graphics, but this    }
                   { program can be used as a bench mark for graphics        }
                   { performance of future generation PCs.                   }

{
 05/20/86
 Converted form Turbo Pascal For I.B.M. PCs to O.S.S. Personal Pascal
 By Jerry LaPeer of LaPeer Systems Inc.
 Uses 2 screens of memory and swaps them for smooth animation

 Well the 8088 on the PCs may be slow but the ST is at the least
 fast enough
}

CONST
  Pi    = 3.1415927;

{$I GEMCONST.PAS}

TYPE

  Screendef =   ^Screendata;
  Screendata =  PACKED ARRAY[1..32766] OF CHAR;

{$I gemtype.pas}    { Note That CASE Doesn'T Matter }

VAR
  A,B,Ax,Bx,Ay,By,Az,Bz,Th,Thx,Thy,Thz: REAL;
  T:     ARRAY[1..3,1..3] OF REAL;
  Scale: REAL;
  Incrs: REAL;
  Xp,Yp: ARRAY[1..3] OF INTEGER;
  X,Y:   ARRAY[1..7] OF INTEGER;
  J:     INTEGER;
  Offsetx,Offsety,Hoffsetx,Hoffsety: INTEGER;
  Incrx,Incry: INTEGER;
  Color_Off,Color_On:   INTEGER;
  Reply:        Str255;

  Curlogbase:   Screendef;
  Curphybase:   Screendef;

  Visible_Screen:Screendef;
  Build_Screen: Screendef;

  Screen1:      Screendef;
  Screen2:      Screendef;

{$I gemsubs}          { AND That ".Pas" Is Default }

FUNCTION Getphybase : Screendef;
Xbios(2);

FUNCTION Getlogbase : Screendef;
Xbios(3);

PROCEDURE Setscreen(Logloc,Phyloc : Screendef;
                    Rez : INTEGER);
Xbios(5);

PROCEDURE Draw(X1,Y1,X2,Y2,Lc : INTEGER);

BEGIN

  Line_Color(Lc);

  Line(X1,Y1,X2,Y2);

END;

PROCEDURE Drawcube(Thx,Thy,Thz: REAL);

VAR
  I,J:          INTEGER;
  Tempscreen:   Screendef;

BEGIN

  Az:=COS(Thz) / Scale;
  Ax:=COS(Thx) / Scale;
  Ay:=COS(Thy) / Scale;

  Bz:=SIN(Thz) / Scale;
  Bx:=SIN(Thx) / Scale;
  By:=SIN(Thy) / Scale;

  T[1,1]:=Az*Ay-Bx*By*Bz;  T[1,2]:=-Bz*Ax;  T[1,3]:=Az*By+Ay*Bz*Bx;
  T[2,1]:=Bz*Ay+Az*Bx*By;  T[2,2]:=Az*Ax;   T[2,3]:=Bz*By-Az*Ay*Bx;
  T[3,1]:=-Ax*By;          T[3,2]:=Bx;      T[3,3]:=Ax*Ay;

  FOR J:=1 TO 3 DO BEGIN
    Xp[J]:=ROUND(60*(T[2,J]-T[1,J]*B));
    Yp[J]:=ROUND(30*(T[3,J]-T[1,J]*A));
  END;

  X[1]:=Offsetx+Xp[1];               Y[1]:=Offsety-Yp[1];
  X[2]:=X[1]+Xp[2];                  Y[2]:=Y[1]-Yp[2];
  X[3]:=Offsetx+Xp[2];               Y[3]:=Offsety-Yp[2];
  X[4]:=X[3]+Xp[3];                  Y[4]:=Y[3]-Yp[3];
  X[5]:=Offsetx+Xp[3];               Y[5]:=Offsety-Yp[3];
  X[6]:=X[1]+Xp[3];                  Y[6]:=Y[1]-Yp[3];
  X[7]:=X[2]+Xp[3];                  Y[7]:=Y[2]-Yp[3];

  Draw(Offsetx,Offsety,X[1],Y[1],Color_On);
  Draw(X[1],Y[1],X[2],Y[2],Color_On);
  Draw(X[2],Y[2],X[3],Y[3],Color_On);
  Draw(X[3],Y[3],X[4],Y[4],Color_On);
  Draw(X[4],Y[4],X[5],Y[5],Color_On);
  Draw(X[5],Y[5],X[6],Y[6],Color_On);
  Draw(X[6],Y[6],X[7],Y[7],Color_On);
  Draw(X[7],Y[7],X[4],Y[4],Color_On);
  Draw(X[3],Y[3],Offsetx,Offsety,Color_On);
  Draw(Offsetx,Offsety,X[5],Y[5],Color_On);
  Draw(X[6],Y[6],X[1],Y[1],Color_On);
  Draw(X[7],Y[7],X[2],Y[2],Color_On);

  Tempscreen := Visible_Screen;
  Visible_Screen := Build_Screen;
  Build_Screen := Tempscreen;

  Setscreen(Build_Screen,Visible_Screen,-1);

  Clear_Screen;

END;

PROCEDURE Beep;

BEGIN

  WRITE(CHR($07));

  Color_On := Color_On + 1;

  IF NOT (Color_On IN [1..3])
    THEN Color_On := 1;

END;

PROCEDURE Do_Main;

VAR
  Delay_Count:          INTEGER;
  I:                    INTEGER;
  Creply:               CHAR;

BEGIN

  Th:=Pi/4;

  A:=COS(Th); B:=SIN(Th);

  Offsetx:=300; Offsety:=100; Scale := 1.0;

  Incrx:=5; Incry:=3; Incrs := 0.02;

  Thx:=0.0; Thy:=0.0; Thz:=0.0;

  Color_Off := 0;
  Color_On := 1;

  Drawcube(Thx,Thy,Thz);

  REPEAT

    Thz:=Thz+0.1; Thx:=Thx-0.1; Thy:=Thy+0.1;

    Drawcube(Thx,Thy,Thz);

    IF (Offsetx >= 500) OR (Offsetx <= 40)
      THEN BEGIN
        Incrx:=-Incrx;
        Beep;
      END;

    IF (Offsety <= 50) OR (Offsety >= 150)
      THEN BEGIN
        Incry:=-Incry;
        Beep;
      END;

    Scale := Scale + Incrs;

    IF Scale >= 3.0
      THEN Incrs := -Incrs
      ELSE IF Scale <= 0.5
             THEN Incrs := -Incrs;

    Offsetx:=Offsetx+Incrx; Offsety:=Offsety+Incry;

  UNTIL Keypress;

  READ(Creply);

END;

FUNCTION Alloc_Screen : Screendef;

CONST
  Scraddrresolution = 256;

VAR
  Scrjunk:      RECORD
    CASE Byte OF
      0 : (Sali:       Long_Integer);
      1 : (Sa:         Screendef);
  END;

BEGIN

  WITH Scrjunk DO BEGIN
    NEW(Sa);
    IF Sali MOD Scraddrresolution <> 0
      THEN Sali := Sali + (Scraddrresolution - (Sali MOD Scraddrresolution));
  END;

  Alloc_Screen := Scrjunk.Sa;

END;

BEGIN

  IF Init_Gem >= 0
    THEN BEGIN
      Curlogbase := Getlogbase;
      Curphybase := Getphybase;
      Screen1 := Alloc_Screen;
      Screen2 := Alloc_Screen;
      Setscreen(Screen1,Curphybase,-1);
      Clear_Screen;
      Setscreen(Screen2,Curphybase,-1);
      Clear_Screen;
      Visible_Screen := Screen2;
      Build_Screen := Screen1;
      Setscreen(Build_Screen,Visible_Screen,-1);
      Set_Clip(0,0,640,200);
      Do_Main;
      Setscreen(Curlogbase,Curphybase,-1);
      Exit_Gem;
    END;

END.
                                                                               
