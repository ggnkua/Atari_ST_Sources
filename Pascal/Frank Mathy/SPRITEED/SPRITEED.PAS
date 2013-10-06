{ Sprite-Editor von Frank Mathy. FÅr den Gebrauch mit den speziellen
  Sprite-Routinen fÅr 16-farbige Sprites im 320x200-Pixel-Modus.
  Die Sprites bestehen jeweils 16 Paketen aus je fÅnf Worten wie folgt:

  Zeile 0:      Bitebene 0
                Bitebene 1
                Bitebene 2
                Bitebene 3
                Maske

  Zeile 1:      Bitebene 0
                ...

  Insgesamt kînnen 128 Sprites editiert werden, jedes "verschlingt" einen
  Speicherplatz von 160 Bytes. Die Daten werden nach obigem Muster ohne
  jede Zusatzinformation abgelegt und kînnen direkt in den Speicher
  geladen werden. }

PROGRAM sprite_editor;

CONST
        {$I gemconst.pas}
        PI              =       3.141592654;
        Info            =       3;

        OneSprite       =       0;      { Auflîsungen }
        FourSprites     =       1;


TYPE
        {$I gemtype.pas}
        Clipping = ARRAY [0..3] OF INTEGER;
        Pointer = ^char;
        Int_In_Parms = ARRAY[0..15] OF INTEGER;
        Int_Out_Parms = ARRAY[0..45] OF INTEGER;
        Addr_In_Parms = ARRAY[0..1] OF Pointer;
        Addr_Out_Parms = ARRAY[0..0] OF Pointer;

VAR
        spx,spy,spw,sph:INTEGER;
        wx,wy,ww,wh:INTEGER;
        px,py,pw,ph:INTEGER;
        menu:Menu_Ptr;
        menu_datei,menu_edit,menu_goodies:INTEGER;
        wname,winfo:Window_Title;
        pname:Window_Title;
        spwindow,palette:INTEGER;
        window:INTEGER;
        bits:ARRAY[0..15] OF INTEGER;
        sprite:ARRAY[0..10239] OF INTEGER;
        grid:ARRAY[0..31,0..31] OF INTEGER;
        clip:Clipping;
        aktspr,aktcol:INTEGER;
        undobuffer:ARRAY[0..319] OF INTEGER;
        mx,my:INTEGER;
        wahl,event:INTEGER;
        msg:Message_Buffer;
        load_data,save_data,dummy,read_sprite,write_sprite:INTEGER;
        read_rgb,write_rgb:INTEGER;
        fuell,dline:INTEGER;
        loeschen,kopieren,mischen,rotieren,frotieren,scrollen,zoomen:INTEGER;
        hspiegeln,vspiegeln,undo,setsres,animate,ascspr,laspr,lafill:INTEGER;
        mausin:BOOLEAN;
        logbase:LONG_INTEGER;
        sres:INTEGER;

        {$I gemsubs.pas}

{ Rechteck zeichnen (eigene Routine) }
PROCEDURE fbox(x1,y1,x2,y2,color:INTEGER; screen:LONG_INTEGER;
               VAR clip:Clipping);
C;

{ Horizontale Linie zeichnen (eigene Routine) }
PROCEDURE fhline(x1,y1,x2,color:INTEGER; screen:LONG_INTEGER;
                 VAR clip:Clipping);
C;

{ Sprite setzen ohne Retten des Bildschirminhaltes (eigene Routine) }
PROCEDURE setsprite(x,y:INTEGER; VAR data:INTEGER;screen:LONG_INTEGER;
                    VAR clip:Clipping; hoehe:INTEGER);
C;

{ AES-Routine aufrufen }
PROCEDURE AES_Call(op:INTEGER; VAR int_in:Int_In_Parms;
                  VAR int_out:Int_Out_Parms; VAR addr_in:Addr_In_Parms;
                  VAR addr_out:Addr_Out_Parms);
EXTERNAL;

{ Zustand der Mauskn[pfe holen }
FUNCTION Mouse_Button:INTEGER;
VAR int_in:Int_In_Parms;
    int_out:Int_Out_Parms;
    addr_in:Addr_In_Parms;
    addr_out:Addr_Out_Parms;
BEGIN
AES_Call(79,int_in,int_out,addr_in,addr_out);
Mouse_Button:=int_out[3];
END;

{ Laufwerksnummer holen }
FUNCTION Get_Drive:INTEGER;
GEMDOS($19);

{ Startadresse der logischen Bildschirmseite holen }
FUNCTION GetLog:LONG_INTEGER;
XBIOS(3);

{ Auflîsung bestimmen }
FUNCTION GetRez:INTEGER;
XBIOS(4);

{ Farbtopf setzen }
FUNCTION Setcolor(topf,farbe:INTEGER):INTEGER;
XBIOS(7);

{ Auf BildrÅcklauf warten }
PROCEDURE Vsync;
XBIOS(37);

{ Teste, ob Diskettenfehler }
PROCEDURE IO_Check (a:BOOLEAN);
External;

{ Fehlernummer holen }
FUNCTION IO_Result:INTEGER;
External;

{ Tabelle fÅr Bits setzen }
PROCEDURE Bit_Init;
BEGIN
        bits[0] :=$0001;
        bits[1] :=$0002;
        bits[2] :=$0004;
        bits[3] :=$0008;
        bits[4] :=$0010;
        bits[5] :=$0020;
        bits[6] :=$0040;
        bits[7] :=$0080;
        bits[8] :=$0100;
        bits[9] :=$0200;
        bits[10]:=$0400;
        bits[11]:=$0800;
        bits[12]:=$1000;
        bits[13]:=$2000;
        bits[14]:=$4000;
        bits[15]:=$8000;
END;

{ Zahl in String umwandeln }
PROCEDURE STR(zahl:INTEGER; VAR kette:STRING);
VAR ok:BOOLEAN;
    help:STRING;
BEGIN
ok:=FALSE;
help:='';
IF (zahl DIV 100) MOD 10>0 THEN
        BEGIN
        kette:=CONCAT(help,CHR($30 + (zahl DIV 100) MOD 10));
        ok:=TRUE;
        help:=kette;
        END;
IF ((zahl DIV 10) MOD 10>0) OR ok THEN
        BEGIN
        kette:=CONCAT(help,CHR($30 + (zahl DIV 10) MOD 10));
        ok:=TRUE;
        help:=kette;
        END;
kette:=CONCAT(help,CHR($30 + zahl MOD 10));
END;

{ String in Zahl umwandeln }
FUNCTION Val(kette:STRING):INTEGER;
VAR zeichen:CHAR;
    i,help:INTEGER;
BEGIN
help:=0;
IF Length(kette)>0 THEN
   FOR i:=1 TO Length(kette) DO
        help:=help*10+Ord(kette[i])-Ord('0');
Val:=help;
END;

{ Zahleneingabe per Dialogbox }
FUNCTION Get_Number(titel,nachfrage:STRING; VAR eingabe:INTEGER;
                    minimum:INTEGER):BOOLEAN;
VAR dialog:Dialog_Ptr;
    dltitle,dlfrage,dleingabe,dlok,dlabbruch:Tree_Index;
    input:Str255;
    start:STRING;
BEGIN
dialog:=New_Dialog(7,0,0,30,13);

dltitle:=Add_DItem(dialog,G_TEXT,None,2,2,26,1,0,256*Red);
Set_DText(dialog,dltitle,titel,System_Font,TE_Center);

dlfrage:=Add_DItem(dialog,G_TEXT,None,2,4,26,1,0,256*Black);
Set_DText(dialog,dlfrage,nachfrage,System_Font,TE_Center);

IF minimum>0 THEN STR(minimum,start)
             ELSE BEGIN
                  start:='';
                  minimum:=1;
                  END;

dleingabe:=Add_DItem(dialog,G_FText,Editable,2,6,26,1,0,256*Black+128);
Set_DEdit(dialog,dleingabe,'Sprite ___','999',start,System_Font,TE_Center);

dlok:=Add_DItem(dialog,G_Boxtext,Selectable|Exit_Btn|Default,
                 6,9,8,2,-4,Green*4096+Black*256);
Set_DText(dialog,dlok,'OK',System_Font,TE_Center);

dlabbruch:=Add_DItem(dialog,G_Boxtext,Selectable|Exit_Btn,
                 17,9,8,2,-2,Red*4096+Black*256);
Set_DText(Dialog,dlabbruch,'Abbruch',System_Font,TE_Center);

Center_Dialog(dialog);

wahl:=Do_Dialog(dialog,dleingabe);
Get_DEdit(dialog,dleingabe,input);
eingabe:=Val(input);

WHILE (wahl<>dlabbruch) AND ((eingabe<minimum) OR (eingabe>128)) DO
        BEGIN
        Obj_SetState(dialog,dlok,NORMAL,TRUE);
        wahl:=Redo_Dialog(dialog,dleingabe);
        Get_DEdit(dialog,dleingabe,input);
        eingabe:=Val(input);
        END;

IF wahl<>dlabbruch THEN Get_Number:=TRUE
                   ELSE Get_Number:=FALSE;

End_Dialog(dialog);
Delete_Dialog(dialog);
END;


{ Umwandeln von BinÑrdaten in das Eingabefeld
  Sprite steht fÅr die Spritenummer (1 bis 128) }
PROCEDURE Sprite_To_Grid(sprnr:INTEGER);
VAR     zeile,spalte,plane,wert,groesse:INTEGER;
BEGIN
        CASE sres OF    OneSprite:      groesse:=15;
                        FourSprites:    groesse:=31;
                        END;
        sprnr:=(sprnr-1)*80;
        FOR zeile:=0 TO groesse DO
            FOR spalte:=0 TO 15 DO
                BEGIN
                wert:=0;
                FOR plane:=0 TO 3 DO
                    IF (sprite[sprnr+zeile*5+plane]&bits[15-spalte]) <> 0
                       THEN wert:=wert+bits[plane];
                grid[spalte,zeile]:=wert;
                IF ((sprite[sprnr+zeile*5+4] & bits[15-spalte]) <> 0)
                   AND (grid[spalte,zeile]=0) THEN grid[spalte,zeile]:=16;
                END;

        IF sres=FourSprites THEN
        FOR zeile:=0 TO groesse DO
            FOR spalte:=0 TO 15 DO
                BEGIN
                wert:=0;
                FOR plane:=0 TO 3 DO
                    IF (sprite[sprnr+zeile*5+plane+160]&bits[15-spalte]) <> 0
                       THEN wert:=wert+bits[plane];
                grid[spalte+16,zeile]:=wert;
                IF ((sprite[sprnr+zeile*5+164] & bits[15-spalte]) <> 0)
                  AND (grid[spalte+16,zeile]=0) THEN grid[spalte+16,zeile]:=16;
                END;

END;

{ Umwandeln einer Zeile des Eingabe-Feldes in BinÑrdaten
  Zeile steht fÅr die Zeilennummer (0 bis 15)
  Sprite steht fÅr die Spritenummer (0 bis 127) }
PROCEDURE Line_To_Sprite(zeile,sprnr:INTEGER);
VAR     spalte,plane,wert:INTEGER;
BEGIN
        sprnr:=(sprnr-1)*80;
        FOR plane:=0 TO 3 DO
            BEGIN
            wert:=0;
            FOR spalte:=0 TO 15 DO
                IF (grid[spalte,zeile] & bits[plane]) > 0
                        THEN wert:=wert|bits[15-spalte];
            sprite[sprnr+zeile*5+plane]:=wert;
            IF sres=FourSprites THEN
                BEGIN
                wert:=0;
                FOR spalte:=0 TO 15 DO
                IF (grid[spalte+16,zeile] & bits[plane]) > 0
                        THEN wert:=wert|bits[15-spalte];
                sprite[sprnr+zeile*5+plane+160]:=wert;
                END;
            END;
        wert:=0;
        FOR spalte:=0 TO 15 DO
            IF grid[spalte,zeile] > 0
                   THEN wert:=wert|bits[15-spalte];
        sprite[sprnr+zeile*5+4]:=wert;
        wert:=0;
        IF sres=FourSprites THEN
        FOR spalte:=0 TO 15 DO
            IF grid[spalte+16,zeile] > 0
                   THEN wert:=wert|bits[15-spalte];
        sprite[sprnr+zeile*5+164]:=wert;
END;

{ Dargestelltes Spriteraster in BinÑrdaten umwandeln }
PROCEDURE Grid_To_Sprite(sprnr:INTEGER);
VAR i,groesse:INTEGER;
BEGIN
        CASE sres OF    OneSprite:      groesse:=15;
                        FourSprites:    groesse:=31;
                        END;
        FOR i:=0 TO groesse DO Line_To_Sprite(i,sprnr);
END;

{ Eingabefenster als Clippingfeld }
PROCEDURE Window_Clip;
BEGIN
clip[0]:=wx;
clip[1]:=wy;
clip[2]:=wx+ww-1;
clip[3]:=wy+wh-1;
Set_Clip(wx,wy,ww,wh);
END;

{ Zeichnen eines Pixels im Netz }
PROCEDURE Draw_Block(x,y,farbe:INTEGER);
BEGIN
  Paint_Outline(false);
  IF farbe<16 THEN BEGIN

  CASE sres OF
    OneSprite:   fbox(x*10+wx,y*10+wy,x*10+wx+8,y*10+wy+8,farbe,logbase,clip);
    FourSprites: fbox(x*5+wx,y*5+wy,x*5+wx+3,y*5+wy+3,farbe,logbase,clip);
    END;
  END

  ELSE BEGIN
                Paint_Color(1);
                Paint_Style(3);
                CASE sres OF
                     OneSprite:   Paint_Rect(x*10+wx,y*10+wy,9,9);
                     FourSprites: Paint_Rect(x*5+wx,y*5+wy,4,4);
                END;
  END;
END;

{ Spriteraster zeichnen }
PROCEDURE Draw_Grid;
VAR     zeile,spalte,groesse:INTEGER;
BEGIN
        CASE sres OF    OneSprite:      groesse:=15;
                        FourSprites:    groesse:=31;
                        END;
        for zeile:=0 TO groesse DO
            for spalte:=0 TO groesse DO
                Draw_Block(spalte,zeile,grid[spalte,zeile]);
END;

{ Sprite im kleinen Fenster darstellen }
PROCEDURE Spline_Redraw(zeile:INTEGER);
VAR x,y,w,h:INTEGER;
BEGIN
    Hide_Mouse;
    Begin_Update;
    First_Rect(spwindow,x,y,w,h);
     WHILE (w<>0) OR (h<>0) DO
        BEGIN
        IF Rect_Intersect(spx,spy,spw,sph,x,y,w,h) THEN
         BEGIN
         clip[0]:=x;
         clip[1]:=y;
         clip[2]:=x+w-1;
         clip[3]:=y+h-1;
         IF sres=OneSprite
         THEN
          BEGIN
          fhline(spx,spy+8+zeile,spx+31,0,logbase,clip);
          Setsprite(spx+8,spy+8+zeile,sprite[(aktspr-1)*80+zeile*5],
                    logbase,clip,0);
          END
         ELSE
          BEGIN
          fhline(spx,spy+zeile,spx+31,0,logbase,clip);
          Setsprite(spx,spy+zeile,sprite[(aktspr-1)*80+zeile*5],
                    logbase,clip,0);
          Setsprite(spx+16,spy+zeile,sprite[(aktspr+1)*80+zeile*5],
                    logbase,clip,0);
          END;
         END;
        Next_Rect(spwindow,x,y,w,h);
        END;
End_Update;
Show_Mouse;
END;

{ Block im Spriteraster setzen }
PROCEDURE Set_Block(spalte,zeile,farbe:INTEGER);
BEGIN
        grid[spalte,zeile]:=farbe;
        Line_To_Sprite(zeile,aktspr);
        Hide_Mouse;
        Draw_Block(spalte,zeile,farbe);
        Show_Mouse;
END;

{ Farbpalette darstellen }
PROCEDURE Palette_Init;
VAR i:INTEGER;
BEGIN
Paint_Outline(false);
Paint_Style(1);
FOR i:=0 TO 15 DO
        BEGIN
        fbox(px+i*8,py,px+i*8+7,py+9,i,logbase,clip);
        END;
Paint_Color(1);
Paint_Style(3);
Paint_Rect(px+128,py,8,10);
Line_Style(Solid);
Line_Color(Black);
Line(px,py+10,px+pw-1,py+10);
IF aktcol<16 THEN
        BEGIN
        fbox(px,py+11,px+pw-1,py+ph-1,aktcol,logbase,clip);
        END
ELSE
        BEGIN
        Paint_Color(1);
        Paint_Style(3);
        Paint_Rect(px,py+11,pw,ph-11);
        END;
END;

{ Leeres Spriteraster zeichnen }
PROCEDURE Window_Init;
VAR     i,lx,ly,groesse:INTEGER;
BEGIN
CASE sres OF    OneSprite:      groesse:=15;
                FourSprites:    groesse:=31;
                END;
Line_Style(Solid);
Line_Color(L_White);
lx:=wx-1;
ly:=wy-1;
FOR i:=1 TO groesse DO
        BEGIN
        lx:=lx+5*(2-sres);
        ly:=ly+5*(2-sres);
        Line(lx,wy,lx,wy+wh-1);
        Line(wx,ly,wx+ww-1,ly);
        END;
i:=0;
Line_Color(Black);
CASE sres OF    OneSprite:      groesse:=2;
                FourSprites:    groesse:=4;
                END;
lx:=wx-1;
ly:=wy-1;
FOR i:=1 TO groesse DO
        BEGIN
        lx:=lx+40*(2-sres);
        ly:=ly+40*(2-sres);
        Line(lx,wy,lx,wy+wh-1);
        Line(wx,ly,wx+ww-1,ly);
        END;
END;

{ Farbe auswÑhlen }
PROCEDURE Select_Color(farbe:INTEGER);
BEGIN
Set_Clip(px,py,pw,ph);
clip[0]:=px;
clip[1]:=py;
clip[2]:=px+pw-1;
clip[3]:=py+ph-1;
aktcol:=farbe;
Hide_Mouse;
IF aktcol<16 THEN
        fbox(px,py+11,px+pw-1,py+ph-1,aktcol,logbase,clip)
ELSE
        BEGIN
        Paint_Color(1);
        Paint_Style(3);
        Paint_Rect(px,py+11,pw,ph-11);
        END;
Show_Mouse;
END;

{ Test, ob Punkt innerhalb eines Rechtecks }
FUNCTION InRect(xp,yp,x1,y1,breite,hoehe:INTEGER):BOOLEAN;
BEGIN
        IF((xp>=x1) AND (xp<x1+breite) AND (yp>=y1) AND (yp<y1+hoehe))
                THEN InRect:=TRUE
                ELSE InRect:=FALSE;
END;

{ Sprite im kleinen Spritefenster zeichnen }
PROCEDURE Sprite_Redraw;
VAR x,y,w,h:INTEGER;
BEGIN
    Begin_Update;
    Hide_Mouse;
    First_Rect(spwindow,x,y,w,h);
     WHILE (w<>0) OR (h<>0) DO
        BEGIN
        IF Rect_Intersect(spx,spy,spw,sph,x,y,w,h) THEN
            BEGIN
            clip[0]:=x;
            clip[1]:=y;
            clip[2]:=x+w-1;
            clip[3]:=y+h-1;
            fbox(clip[0],clip[1],clip[2],clip[3],0,logbase,clip);
            IF sres=OneSprite
            THEN
             Setsprite(spx+8,spy+8,sprite[(aktspr-1)*80],logbase,clip,15)
            ELSE
             BEGIN
             Setsprite(spx,spy,sprite[(aktspr-1)*80],logbase,clip,31);
             Setsprite(spx+16,spy,sprite[(aktspr+1)*80],logbase,clip,31);
             END;
            END;
        Next_Rect(spwindow,x,y,w,h);
        END;
Show_Mouse;
End_Update;
END;

{ Spriteraster aktualisieren }
PROCEDURE Grid_Redraw(gitter:BOOLEAN);
VAR x,y,w,h:INTEGER;
BEGIN
    Begin_Update;
    Hide_Mouse;
    First_Rect(window,x,y,w,h);
     WHILE (w<>0) OR (h<>0) DO
        BEGIN
        IF Rect_Intersect(wx,wy,ww,wh,x,y,w,h) THEN
            BEGIN
            Set_Clip(x,y,w,h);
            clip[0]:=x;
            clip[1]:=y;
            clip[2]:=x+w-1;
            clip[3]:=y+h-1;
            IF gitter THEN Window_Init;
            Draw_Grid;
            END;
        Next_Rect(window,x,y,w,h);
        END;
Show_Mouse;
End_Update;
Sprite_Redraw;
END;

{ Palette aktualisieren }
PROCEDURE Palette_Redraw;
VAR x,y,w,h:INTEGER;
BEGIN
    Begin_Update;
    Hide_Mouse;
    First_Rect(palette,x,y,w,h);
     WHILE (w<>0) OR (h<>0) DO
        BEGIN
        IF Rect_Intersect(px,py,pw,ph,x,y,w,h) THEN
            BEGIN
            Set_Clip(x,y,w,h);
            clip[0]:=x;
            clip[1]:=y;
            clip[2]:=x+w-1;
            clip[3]:=y+h-1;
            Palette_Init;
            END;
        Next_Rect(palette,x,y,w,h);
        END;
Show_Mouse;
End_Update;
END;

{ Spriterasterinhalt in UNDO-Puffer schreiben }
PROCEDURE Save_Undo;
VAR i,groesse:INTEGER;
BEGIN
CASE sres OF    OneSprite:      groesse:=79;
                FourSprites:    groesse:=319;
                END;
FOR i:=0 TO groesse DO undobuffer[i]:=sprite[(aktspr-1)*80+i];
END;

{ UNDO ausfÅhren }
PROCEDURE Do_Undo;
VAR i,groesse:INTEGER;
    puffer:INTEGER;
BEGIN
CASE sres OF    OneSprite:      groesse:=79;
                FourSprites:    groesse:=319;
                END;
FOR i:=0 TO groesse DO
        BEGIN
        puffer:=sprite[(aktspr-1)*80+i];
        sprite[(aktspr-1)*80+i]:=undobuffer[i];
        undobuffer[i]:=puffer;
        END;
Sprite_To_Grid(aktspr);
Grid_Redraw(False);
END;

{ Sprite auswÑhlen }
PROCEDURE Sprite_Select(nummer:INTEGER);
VAR text:STRING;
    help:REAL;
BEGIN
        Sprite_To_Grid(nummer);
        STR(nummer,text);
        winfo:=CONCAT(' Sprite ',text,' ');
        Set_WInfo(window,winfo);
        help:=nummer;
        help:=(999*help)/128;
        nummer:=ROUND(help)+1;
        Wind_Set(window,WF_VSLIDE,nummer,0,0,0);
        Grid_Redraw(False);
END;

{ Kennbuchstaben des aktuellen Laufwerks holen }
FUNCTION Floppy:CHAR;
VAR i:INTEGER;
BEGIN
i:=Get_Drive MOD 5;
IF (i<0) THEN i:=0;
Floppy:=CHR(65+i);
END;

{ Fehlermeldung fÅr Diskettenfehler ausgeben }
PROCEDURE Diskerror;
BEGIN
wahl:=Do_Alert('[3][ | Diskfehler...! | ][ ABBRUCH ]',1);
END;

{ BinÑre Spritedaten einlesen }
PROCEDURE Read_Data;
VAR datei:FILE OF INTEGER;
    count,sprite1,sprite2,i:INTEGER;
    name,pfad:Path_Name;
BEGIN
IF Get_Number('Lade Spritedaten...','Erstes Sprite (1-128) ?',sprite1,0) THEN
    IF Get_Number('Lade Spritedaten...','Letztes Sprite ?',sprite2,sprite1)THEN
        BEGIN
        pfad:=Concat(Floppy,':\*.IMG');
        name:='';
        IF Get_In_File(pfad,name) THEN
            BEGIN
            IO_Check(FALSE);
            RESET(datei,name);
            IF IO_Result=0 THEN
                BEGIN
                Set_Mouse(M_BEE);
                count:=sprite1;
                WHILE (count<=sprite2) AND (NOT EOF(datei)) DO
                    BEGIN
                    FOR i:=0 TO 79 DO
                        BEGIN
                        sprite[(count-1)*80+i]:=datei^;
                        GET(datei);
                        IF EOF(datei) THEN i:=79;
                        END;
                    count:=count+1;
                    END; {While}
                CLOSE(datei);
                Sprite_To_Grid(aktspr);
                Set_Mouse(M_ARROW);
                END {If IORESULT}
            ELSE Diskerror;
        END; {IF Get_In_File }
    END; { IF Get_Number }
END;

{ Spritedaten binÑr schreiben }
PROCEDURE Write_Data;
VAR datei:FILE OF INTEGER;
    sprite1,sprite2,count,i:INTEGER;
    name:Path_Name;

BEGIN
IF Get_Number('Save Spritedaten...','Erstes Sprite (1-128) ?',sprite1,0) THEN
   IF Get_Number('Save Spritedaten...','Letztes Sprite ?',sprite2,sprite1) THEN
        BEGIN
        name:=Concat(Floppy,':\sprite.IMG');
        IF Get_Out_File('Daten saven unter...',name)THEN
            BEGIN
            REWRITE(datei,name);
            IF IO_Result=0 THEN
                BEGIN
                Set_Mouse(M_BEE);
                FOR count:=sprite1 TO sprite2 DO
                    FOR i:=0 TO 79 DO
                        BEGIN
                        datei^:=sprite[(count-1)*80+i];
                        PUT(datei);
                        END;
                CLOSE(datei);
                Set_Mouse(M_ARROW);
                END
            ELSE Diskerror;
            END;
        END;
END; {Load Data}

{ BinÑre Daten in das aktuelle Sprite laden }
PROCEDURE Load_Sprite;
VAR pfad,name:Path_Name;
    i:INTEGER;
    datei:FILE OF INTEGER;
BEGIN
IF sres=OneSprite THEN pfad:=Concat(Floppy,':\*.SPL')
                  ELSE pfad:=Concat(Floppy,':\*.SPH');
name:='';
IF Get_In_File(pfad,name) THEN
        BEGIN
        IO_Check(FALSE);
        RESET(datei,name);
        IF IO_Result=0 THEN
                BEGIN
                Set_Mouse(M_BEE);
                FOR i:=0 TO (79+sres*240) DO
                        BEGIN
                        sprite[(aktspr-1)*80+i]:=datei^;
                        GET(datei);
                        IF EOF(datei) THEN i:=79+sres*240;
                        END;
                CLOSE(datei);
                Sprite_To_Grid(aktspr);
                Set_Mouse(M_ARROW);
                END
            ELSE Diskerror;
        END;
END;

{ Spritedaten des aktuellen Sprites binÑr speichern }
PROCEDURE Save_Sprite;
VAR name:Path_Name;
    i:INTEGER;
    datei:FILE OF INTEGER;
BEGIN
IF sres=OneSprite THEN name:=Concat(Floppy,':\sprite.SPL')
                  ELSE name:=Concat(Floppy,':\sprite.SPH');
IF Get_Out_File('Sprite saven unter...',name)THEN
        BEGIN
        REWRITE(datei,name);
        IF IO_Result=0 THEN
                BEGIN
                Set_Mouse(M_BEE);
                FOR i:=0 TO (79+sres*240) DO
                        BEGIN
                        datei^:=sprite[(aktspr-1)*80+i];
                        PUT(datei);
                        END;
                CLOSE(datei);
                Set_Mouse(M_ARROW);
                END
            ELSE Diskerror;
        END;
END;

{ Farbtîpfe laden }
PROCEDURE Load_RGB;
VAR pfad,name:Path_Name;
    i,j,k:INTEGER;
    datei:FILE OF INTEGER;
BEGIN
pfad:=Concat(Floppy,':\*.RGB');
name:='';
IF Get_In_File(pfad,name) THEN
        BEGIN
        IO_Check(FALSE);
        RESET(datei,name);
        IF IO_Result=0 THEN
                BEGIN
                Set_Mouse(M_BEE);
                FOR i:=0 TO 15 DO
                        BEGIN
                        j:=datei^;
                        k:=Setcolor(i,j);
                        GET(datei);
                        IF EOF(datei) THEN i:=15;
                        END;
                CLOSE(datei);
                Set_Mouse(M_ARROW);
                END
            ELSE Diskerror;
        END;
END;

{ Farbtîpfe speichern }
PROCEDURE Save_RGB;
VAR name:Path_Name;
    i,j:INTEGER;
    datei:FILE OF INTEGER;
BEGIN
name:=Concat(Floppy,':\PALETTE.RGB');
IF Get_Out_File('Palette saven unter...',name)THEN
        BEGIN
        REWRITE(datei,name);
        IF IO_Result=0 THEN
                BEGIN
                Set_Mouse(M_BEE);
                FOR i:=0 TO 15 DO
                        BEGIN
                        j:=Setcolor(i,-1);
                        datei^:=j;
                        PUT(datei);
                        END;
                CLOSE(datei);
                Set_Mouse(M_ARROW);
                END
            ELSE Diskerror;
        END;
END;

{ Lîschen des Sprites }
PROCEDURE Clear_Grid;
VAR spalte,zeile,groesse:INTEGER;
BEGIN
wahl:=Do_Alert('[2][ | Wirklich | Sprite | lîschen...? | ][ Ja | Nein ]',2);
IF wahl=1 THEN
        BEGIN
        Save_Undo;
        CASE sres OF    OneSprite:      groesse:=15;
                        FourSprites:    groesse:=31;
                        END;
        For zeile:=0 TO groesse DO
                FOR spalte:=0 TO groesse DO
                        grid[spalte,zeile]:=0;
        Grid_To_Sprite(aktspr);
        Grid_Redraw(False);
        END;
END;

{ Sprite kopieren }
PROCEDURE Copy_Sprite;
VAR ziel,i,groesse:INTEGER;
BEGIN
CASE sres OF    OneSprite:      groesse:=79;
                FourSprites:    groesse:=319;
                END;
IF Get_Number('Sprite kopieren','Zielsprite (1-128) ?',ziel,0)
   THEN BEGIN
        Save_Undo;
        FOR i:=0 TO groesse DO
        sprite[(ziel-1)*80+i]:=sprite[(aktspr-1)*80+i];
        END;
END;

{ Sprites mischen }
PROCEDURE Mix_Sprites;
VAR cpgrid:ARRAY[0..31,0..31] OF INTEGER;
    x,y,groesse,muster:INTEGER;
BEGIN
CASE sres OF    OneSprite:      groesse:=15;
                FourSprites:    groesse:=31;
                END;
IF Get_Number('Mische Sprites','Mit Sprite (1-128) ?',muster,0)
  THEN IF muster<=128-sres*3 THEN
        BEGIN
        Save_Undo;
        FOR x:=0 TO groesse DO FOR y:=0 TO groesse DO cpgrid[x,y]:=grid[x,y];
        Sprite_to_Grid(muster);
        FOR x:=0 TO groesse DO FOR y:=0 TO groesse DO
          IF cpgrid[x,y]&$f<>0 THEN grid[x,y]:=cpgrid[x,y];
        Grid_to_Sprite(aktspr);
        END;
END;

{ Raster um 90 Grad rotieren }
PROCEDURE Rotate_Grid;
VAR spalte,zeile,groesse:INTEGER;
    cpgrid:ARRAY [0..31,0..31] OF INTEGER;
BEGIN
CASE sres OF    OneSprite:      groesse:=15;
                FourSprites:    groesse:=31;
                END;
Save_Undo;
FOR zeile:=0 TO groesse DO
        FOR spalte:=0 TO groesse DO
                cpgrid[spalte,zeile]:=grid[zeile,groesse-spalte];
FOR zeile:=0 TO groesse DO
        FOR spalte:=0 TO groesse DO
                grid[spalte,zeile]:=cpgrid[spalte,zeile];
Grid_To_Sprite(aktspr);
Grid_Redraw(False);
END;

{ Rotieren in Gradschritten }
PROCEDURE Frotate_Grid;
VAR cpgrid:ARRAY[0..31,0..31] OF INTEGER;
    dialog:Dialog_Ptr;
    dltitel,dlfrage,dlinput,dlok,dlabbruch,knopf:INTEGER;
    input:Str255;
    grad:INTEGER;
    winkel,mitte:REAL;
    x,y,xn,yn:REAL;
    spalte,zeile,nspalte,nzeile,groesse:INTEGER;

BEGIN
dialog:=New_Dialog(5,0,0,28,10);

dltitel:=Add_DItem(dialog,G_TEXT,None,2,1,24,1,0,Red*256);
Set_DText(dialog,dltitel,'Rotiere Sprite',System_Font,TE_Center);

dlfrage:=Add_DItem(dialog,G_TEXT,None,2,3,24,1,0,Black*256);
Set_DText(dialog,dlfrage,'Wieviel Grad (1-359) ?',System_Font,TE_Center);

dlinput:=Add_DItem(dialog,G_FText,None,2,5,24,1,0,Black*256+128);
Set_DEdit(dialog,dlinput,'___ Grad','999','',System_Font,TE_Center);

dlok:=Add_DItem(dialog,G_Boxtext,Selectable|Exit_Btn|Default,
                5,7,8,2,-4,Green*4096+Black*256);
Set_DText(dialog,dlok,'OK',System_Font,TE_Center);

dlabbruch:=Add_DItem(dialog,G_Boxtext,Selectable|Exit_Btn,
                     15,7,8,2,-2,Red*4096+Black*256);
Set_DText(dialog,dlabbruch,'Abbruch',System_Font,TE_Center);

Center_Dialog(dialog);
knopf:=Do_Dialog(dialog,dlinput);
Get_DEdit(dialog,dlinput,input);
grad:=Val(input);

WHILE (knopf<>dlabbruch) AND ((grad<1) OR (grad>359)) DO
        BEGIN
        Obj_SetState(dialog,dlok,NORMAL,TRUE);
        knopf:=Redo_Dialog(dialog,dlinput);
        Get_DEdit(dialog,dlinput,input);
        grad:=Val(input);
        END;

IF knopf<>dlabbruch THEN
        BEGIN
        Save_Undo;
        CASE sres OF    OneSprite:      groesse:=15;
                        FourSprites:    groesse:=31;
                        END;
        Set_Mouse(M_BEE);
        winkel:=360-grad;
        winkel:=winkel*PI/180;
        mitte:=groesse;
        mitte:=mitte/2;
        FOR spalte:=0 TO groesse DO
            FOR zeile:=0 TO groesse DO
                cpgrid[spalte,zeile]:=0;
        FOR spalte:=0 TO groesse DO
            FOR zeile:=0 TO groesse DO
                BEGIN
                x:=spalte;
                y:=zeile;
                xn:=(Cos(winkel)*(x-mitte)) - (Sin(winkel)*(y-mitte));
                yn:=(Sin(winkel)*(x-mitte)) + (Cos(winkel)*(y-mitte));
                nspalte:=Round(xn+mitte);
                nzeile :=Round(yn+mitte);
                IF (nspalte>=0) AND (nspalte<=groesse) AND
                   (nzeile >=0) AND (nzeile <=groesse) THEN
                   cpgrid[spalte,zeile]:=grid[nspalte,nzeile];
                END;
        FOR spalte:=0 TO groesse DO
            FOR zeile:=0 TO groesse DO
                grid[spalte,zeile]:=cpgrid[spalte,zeile];
        Grid_To_Sprite(aktspr);
        Set_Mouse(M_ARROW);
        END;

End_Dialog(dialog);
Delete_Dialog(dialog);

END;

{ Hochscrollen }
PROCEDURE Up_Scroll;
VAR puffer:ARRAY[0..31] OF INTEGER;
    spalte,zeile,groesse:INTEGER;

BEGIN
CASE sres OF    OneSprite:      groesse:=15;
                FourSprites:    groesse:=31;
                END;
FOR spalte:=0 TO groesse DO puffer[spalte]:=grid[spalte,0];
FOR zeile:=0 TO groesse-1 DO
    FOR spalte:=0 TO groesse DO grid[spalte,zeile]:=grid[spalte,zeile+1];
FOR spalte:=0 TO groesse DO grid[spalte,groesse]:=puffer[spalte];
Grid_To_Sprite(aktspr);
Grid_Redraw(False);
END;

{ Runterscrollen }
PROCEDURE Down_Scroll;
VAR puffer:ARRAY[0..31] OF INTEGER;
    spalte,zeile,groesse:INTEGER;

BEGIN
CASE sres OF    OneSprite:      groesse:=15;
                FourSprites:    groesse:=31;
                END;
FOR spalte:=0 TO groesse DO puffer[spalte]:=grid[spalte,groesse];
FOR zeile:=groesse DOWNTO 1 DO
    FOR spalte:=0 TO groesse DO grid[spalte,zeile]:=grid[spalte,zeile-1];
FOR spalte:=0 TO groesse DO grid[spalte,0]:=puffer[spalte];
Grid_To_Sprite(aktspr);
Grid_Redraw(False);
END;

{ Linksscrollen }
PROCEDURE Left_Scroll;
VAR puffer:ARRAY[0..31] OF INTEGER;
    spalte,zeile,groesse:INTEGER;

BEGIN
CASE sres OF    OneSprite:      groesse:=15;
                FourSprites:    groesse:=31;
                END;
FOR zeile:=0 TO groesse DO puffer[zeile]:=grid[0,zeile];
FOR spalte:=0 TO groesse-1 DO
    FOR zeile:=0 TO groesse DO grid[spalte,zeile]:=grid[spalte+1,zeile];
FOR zeile:=0 TO groesse DO grid[groesse,zeile]:=puffer[zeile];
Grid_To_Sprite(aktspr);
Grid_Redraw(False);
END;

{ Rechtsscrollen }
PROCEDURE Right_Scroll;
VAR puffer:ARRAY[0..31] OF INTEGER;
    spalte,zeile,groesse:INTEGER;

BEGIN
CASE sres OF    OneSprite:      groesse:=15;
                FourSprites:    groesse:=31;
                END;
FOR zeile:=0 TO groesse DO puffer[zeile]:=grid[groesse,zeile];
FOR spalte:=groesse DOWNTO 1 DO
    FOR zeile:=0 TO groesse DO grid[spalte,zeile]:=grid[spalte-1,zeile];
FOR zeile:=0 TO groesse DO grid[0,zeile]:=puffer[zeile];
Grid_To_Sprite(aktspr);
Grid_Redraw(False);
END;


{ Hauptroutine fÅr das scrollen }
PROCEDURE Scroll;
VAR dialog:Dialog_Ptr;
    titel,up,down,left,right,bye:INTEGER;
    help:STRING;

BEGIN

dialog:=New_Dialog(7,29,8,10,11);

titel:=Add_DItem(dialog,G_TEXT,None,1,1,8,1,0,Red*256);
Set_DText(dialog,titel,'Scrollen',System_Font,TE_Center);

up:=Add_DItem(dialog,G_BOXTEXT,Selectable|Exit_Btn,
              4,3,2,2,1,Blue*4096+Black*256);
help:=Chr(1);
Set_DText(dialog,up,help,System_Font,TE_Center);

down:=Add_DItem(dialog,G_BOXTEXT,Selectable|Exit_Btn,
                4,5,2,2,1,Blue*4096+Black*256);
help:=Chr(2);
Set_DText(dialog,down,help,System_Font,TE_Center);

left:=Add_DItem(dialog,G_BOXTEXT,Selectable|Exit_Btn,
                2,4,2,2,1,Blue*4096+Black*256);
help:=Chr(4);
Set_DText(dialog,left,help,System_Font,TE_Center);

right:=Add_DItem(dialog,G_BOXTEXT,Selectable|Exit_Btn,
                 6,4,2,2,1,Blue*4096+Black*256);
help:=Chr(3);
Set_DText(dialog,right,help,System_Font,TE_Center);

bye:=Add_DItem(dialog,G_BOXTEXT,Selectable|Exit_Btn|Default,
               2,8,6,2,3,Green*4096+Black*256);
Set_DText(dialog,bye,'Ende',System_Font,TE_Center);

wahl:=Do_Dialog(dialog,0);

IF wahl<>bye THEN Save_Undo;

WHILE wahl<>bye DO
      BEGIN
      IF wahl=up    THEN Up_Scroll;
      IF wahl=down  THEN Down_Scroll;
      IF wahl=left  THEN Left_Scroll;
      IF wahl=right THEN Right_Scroll;
      Obj_SetState(dialog,wahl,NORMAL,TRUE);
      wahl:=Redo_Dialog(dialog,0);
      END;

End_Dialog(dialog);
Delete_Dialog(dialog);
END;

{ Horizontal Spiegeln }
PROCEDURE Hmirror;
VAR spalte,zeile,hilfe,groesse:INTEGER;

BEGIN
Save_Undo;
CASE sres OF    OneSprite:      groesse:=15;
                FourSprites:    groesse:=31;
                END;
FOR zeile:=0 TO (groesse DIV 2) DO
    FOR spalte:=0 TO groesse DO
        BEGIN
        hilfe:=grid[spalte,zeile];
        grid[spalte,zeile]:=grid[spalte,groesse-zeile];
        grid[spalte,groesse-zeile]:=hilfe;
        END;
Grid_To_Sprite(aktspr);
Grid_Redraw(False);
END;

{ Vertikal spiegeln }
PROCEDURE Vmirror;
VAR spalte,zeile,hilfe,groesse:INTEGER;

BEGIN
Save_Undo;
CASE sres OF    OneSprite:      groesse:=15;
                FourSprites:    groesse:=31;
                END;
FOR spalte:=0 TO (groesse DIV 2) DO
    FOR zeile:=0 TO groesse DO
        BEGIN
        hilfe:=grid[spalte,zeile];
        grid[spalte,zeile]:=grid[groesse-spalte,zeile];
        grid[groesse-spalte,zeile]:=hilfe;
        END;
Grid_To_Sprite(aktspr);
Grid_Redraw(False);
END;

{ Sprite Zoomen }
PROCEDURE Zoom;
VAR dialog:Dialog_Ptr;
    dltitel,dlh,dlv,dlfaktor,dlok,dlabbruch:INTEGER;
    spalte,zeile,x,y,groesse:INTEGER;
    input:Str255;
    xn,yn,xfaktor,yfaktor,mitte:REAL;
    cpgrid:ARRAY[0..31,0..31] OF INTEGER;

BEGIN
dialog:=New_Dialog(5,0,0,22,12);

dltitel:=Add_DItem(dialog,G_TEXT,None,1,1,20,1,0,Red*256);
Set_DText(dialog,dltitel,'Zoomen',System_Font,TE_Center);

dlh:=Add_DItem(dialog,G_BOXTEXT,Selectable|Exit_Btn,
               6,3,4,2,2,Blue*4096+Black*256);
input:=Concat(Chr(3),Chr(4));
Set_DText(dialog,dlh,input,System_Font,TE_Center);

dlv:=Add_DItem(dialog,G_BOXTEXT,Selectable|Exit_Btn,
               12,3,4,2,2,Blue*4096+Black*256);
input:=Concat(Chr(1),Chr(2));
Set_DText(dialog,dlv,input,System_Font,TE_Center);

dlfaktor:=Add_DItem(dialog,G_FTEXT,Editable,1,6,20,1,0,Black*256+128);
Set_DEdit(dialog,dlfaktor,'Faktor 0._','9','5',System_Font,TE_Center);

dlok:=Add_DItem(dialog,G_BOXTEXT,Selectable|Default|Exit_Btn,
                2,9,8,2,-3,Green*4096+Black*256);
Set_DText(dialog,dlok,'OK',System_Font,TE_Center);

dlabbruch:=Add_DItem(dialog,G_BOXTEXT,Selectable|Exit_Btn,
                     12,9,8,2,-1,Red*4096+Black*256);
Set_DText(dialog,dlabbruch,'Abbruch',System_Font,TE_Center);

Center_Dialog(dialog);

wahl:=Do_Dialog(dialog,dlfaktor);
Get_DEdit(dialog,dlfaktor,input);

WHILE ((wahl=dlh) OR (wahl=dlv)) OR
      ((((Obj_State(dialog,dlh) & Selected = 0) AND
       (Obj_State(dialog,dlv) & Selected = 0)) OR (Val(input)=0))
       AND (wahl=dlok)) DO
       BEGIN
       IF (wahl=dlabbruch) OR (wahl=dlok) THEN
               Obj_SetState(dialog,wahl,Normal,TRUE);
       wahl:=Redo_Dialog(dialog,dlfaktor);
       Get_DEdit(dialog,dlfaktor,input);
       END;

IF wahl=dlok THEN
    BEGIN
    Save_Undo;
    CASE sres OF    OneSprite:      groesse:=15;
                    FourSprites:    groesse:=31;
                    END;
    mitte:=groesse;
    mitte:=mitte/2;
    IF Obj_State(dialog,dlh) & Selected <> 0
       THEN xfaktor:=Val(input)
       ELSE xfaktor:=10;
    IF Obj_State(dialog,dlv) & Selected <> 0
       THEN yfaktor:=Val(input)
       ELSE yfaktor:=10;
    FOR zeile:=0 TO groesse DO
       FOR spalte:=0 TO groesse DO
          cpgrid[spalte,zeile]:=0;
    FOR zeile:=0 TO groesse DO
       FOR spalte:=0 TO groesse DO
          IF grid[spalte,zeile] <> 0 THEN
          BEGIN
          xn:=spalte;
          yn:=zeile;
          xn:=((spalte-mitte)*xfaktor/10)+mitte;
          yn:=((zeile-mitte)*yfaktor/10)+mitte;
          x:=Round(xn);
          y:=Round(yn);
          cpgrid[x,y]:=grid[spalte,zeile];
          END;
    FOR zeile:=0 TO groesse DO
       FOR spalte:=0 TO groesse DO
          grid[spalte,zeile]:=cpgrid[spalte,zeile];
    Grid_To_Sprite(aktspr);
    Grid_Redraw(False);
    END;

End_Dialog(dialog);
Delete_Dialog(dialog);

END;

{ Mauskoordinaten in Spriterasterkoordinaten umwandeln }
PROCEDURE CConvert(VAR mx,my:INTEGER);
BEGIN
        CASE sres OF
        OneSprite:   BEGIN
                     mx:=(mx-wx) DIV 10;
                     my:=(my-wy) DIV 10;
                     END;
        FourSprites: BEGIN
                     mx:=(mx-wx) DIV 5;
                     my:=(my-wy) DIV 5;
                     END;
        END;
END;


{ Zeile fÅllen }
FUNCTION Line_Fill(y1,color:INTEGER; VAR lr,rr:INTEGER):BOOLEAN;
VAR x1,groesse:INTEGER;
    help:BOOLEAN;
BEGIN
CASE sres OF    OneSprite:      groesse:=15;
                FourSprites:    groesse:=31;
                END;
help:=False;
IF grid[lr,y1]<>color
THEN
    BEGIN
    x1:=lr;
    REPEAT
        IF grid[x1,y1]=color THEN help:=True;
        x1:=x1+1;
    UNTIL help OR (x1>rr);
    Line_Fill:=help;
    lr:=x1-1;
    END
ELSE
    BEGIN
    Line_Fill:=True;
    help:=True;
    x1:=lr;
    IF x1>0 THEN
        REPEAT
            x1:=x1-1;
        UNTIL (grid[x1,y1]<>color) OR (x1=0);
    IF grid[x1,y1]<>color THEN lr:=x1+1
                          ELSE lr:=x1;
    END;
IF help THEN
    BEGIN
    x1:=lr;
        REPEAT
        Set_Block(x1,y1,aktcol);
        x1:=x1+1;
    UNTIL (x1>groesse) OR (grid[x1&groesse,y1]<>color);
    rr:=x1-1;
    END;
END;

{ FÅlloperation }
PROCEDURE Fill_Grid;
VAR lr,lmem,rr,rmem,ax,ay,sx,sy,dy,col,groesse:INTEGER;
    help:BOOLEAN;

BEGIN

CASE sres OF    OneSprite:      groesse:=15;
                FourSprites:    groesse:=31;
                END;

Save_Undo;
Erase_Menu(menu);
Set_Mouse(M_Thin_Cross);
Window_Clip;

REPEAT
dy:=Get_Event(E_BUTTON,
    1,1,1,0,False,0,0,0,0,False,0,0,0,0,msg,dy,dy,dy,sx,sy,dy);
UNTIL InRect(sx,sy,wx,wy,ww,wh);

CConvert(sx,sy);

col:=grid[sx,sy];

lr:=sx;
rr:=groesse;
ay:=sy;
Hide_Mouse;
help:=Line_Fill(ay,col,lr,rr);
lmem:=lr;
rmem:=rr;

help:=False;

IF ay<groesse THEN
REPEAT
    ay:=ay+1;
    help:=Line_Fill(ay,col,lr,rr);
UNTIL (NOT help) OR (ay=groesse);

ay:=sy;

IF ay>0 THEN
REPEAT
    ay:=ay-1;
    help:=Line_Fill(ay,col,lmem,rmem);
UNTIL (NOT help) OR (ay=0);

Grid_To_Sprite(aktspr);
Grid_Redraw(False);
Sprite_Redraw;
Show_Mouse;
Set_Mouse(M_Arrow);
Draw_Menu(menu);
END;


{ Linie ziehen }
PROCEDURE Draw_Line;
VAR sx,sy,ex,ey,x,y,groesse:INTEGER;
    dx,dy,helpx,helpy,f:REAL;
BEGIN

Save_Undo;
Erase_Menu(menu);
Set_Mouse(M_Outln_Cross);

REPEAT
dy:=Get_Event(E_BUTTON,
    1,1,1,0,False,0,0,0,0,False,0,0,0,0,msg,x,x,x,sx,sy,x);
UNTIL InRect(sx,sy,wx,wy,ww,wh);
CConvert(sx,sy);

Set_Mouse(M_Thin_Cross);
REPEAT
dy:=Get_Event(E_BUTTON,
    1,1,1,0,False,0,0,0,0,False,0,0,0,0,msg,x,x,x,ex,ey,x);
UNTIL InRect(ex,ey,wx,wy,ww,wh);
CConvert(ex,ey);

dx:=ex-sx;
dy:=ey-sy;
helpx:=sx;
helpy:=sy;
IF dx<0 THEN BEGIN
              sx:=ex;
              ex:=TRUNC(helpx);
              END;
IF dy<0 THEN BEGIN
              sy:=ey;
              ey:=TRUNC(helpy);
              END;
IF (ABS(dx)>0) OR (ABS(dy)>0) THEN
   IF ABS(dx)>=ABS(dy) THEN
        FOR x:=sx TO ex DO
            BEGIN
            f:=x;
            y:=ROUND((f-helpx)*dy/dx+helpy);
            grid[x,y]:=aktcol;
            END
   ELSE FOR y:=sy TO ey DO
            BEGIN
            f:=y;
            x:=ROUND((f-helpy)*dx/dy+helpx);
            grid[x,y]:=aktcol;
            END;
Grid_To_Sprite(aktspr);
Grid_Redraw(False);
Set_Mouse(M_Arrow);
Draw_Menu(menu);
END;

{ Animationsroutine }
PROCEDURE Animation;
VAR dialog:Dialog_Ptr;
    titel,zyklus,serie,rueckw,speed,asprite,esprite,ok,abbruch,pause:INTEGER;
    anfang,ende,gs,addwert,shownr,richtung:INTEGER;
    eingabe:Str255;
BEGIN
dialog:=New_Dialog(10,0,0,20,14);

titel:=Add_DItem(dialog,G_TEXT,NONE,1,1,18,1,0,Red*256);
Set_Dtext(dialog,titel,'Animation',System_Font,TE_CENTER);

serie:=Add_DItem(dialog,G_BUTTON,SELECTABLE|RADIO_BTN,1,3,8,1,1,0);
Set_Dtext(dialog,serie,'Vorw.',System_Font,TE_CENTER);
Obj_SetState(dialog,serie,SELECTED,False);

rueckw:=Add_DItem(dialog,G_BUTTON,SELECTABLE|RADIO_BTN,11,3,8,1,1,0);
Set_Dtext(dialog,rueckw,'RÅckw.',System_Font,TE_CENTER);

zyklus:=Add_DItem(dialog,G_BUTTON,SELECTABLE|RADIO_BTN,6,5,8,1,1,0);
Set_Dtext(dialog,zyklus,'Zyklus',System_Font,TE_CENTER);

speed:=Add_DItem(dialog,G_FTEXT,EDITABLE,1,7,18,1,0,Black*256+128);
Set_Dedit(dialog,speed,'Speed : _','9','9',System_Font,TE_CENTER);

asprite:=Add_DItem(dialog,G_FTEXT,EDITABLE,1,9,8,1,0,Black*256+128);
Set_Dedit(dialog,asprite,'Von ___','999','',System_Font,TE_CENTER);

esprite:=Add_DItem(dialog,G_FTEXT,EDITABLE,11,9,8,1,0,Black*256+128);
Set_Dedit(dialog,esprite,'bis ___','999','',System_Font,TE_CENTER);

ok:=Add_DItem(dialog,G_BOXTEXT,SELECTABLE|DEFAULT|EXIT_BTN,1,11,8,2,3,
              Green*4096+Black*256);
Set_Dtext(dialog,ok,'OK',System_Font,TE_CENTER);

abbruch:=Add_DItem(dialog,G_BOXTEXT,SELECTABLE|EXIT_BTN,11,11,8,2,1,
                   Red*4096+Black*256);
Set_Dtext(dialog,abbruch,'Abbruch',System_Font,TE_CENTER);

Center_Dialog(dialog);
wahl:=Do_Dialog(dialog,asprite);
Get_DEdit(dialog,speed,eingabe);
gs:=Val(eingabe);
Get_DEdit(dialog,asprite,eingabe);
anfang:=Val(eingabe);
Get_DEdit(dialog,esprite,eingabe);
ende:=Val(eingabe);
IF (Obj_State(dialog,serie)&Selected <> 0) THEN richtung:=1 ELSE
   IF (Obj_State(dialog,rueckw)&Selected <> 0) THEN richtung:=2 ELSE
      IF (Obj_State(dialog,zyklus)&Selected <> 0) THEN richtung:=3;
IF ((anfang >= ende) OR (anfang<1) OR (ende+sres*3>128)) AND (wahl=ok) THEN
        REPEAT
        Obj_SetState(dialog,ok,NORMAL,True);
        wahl:=Redo_Dialog(dialog,asprite);
        Get_DEdit(dialog,speed,eingabe);
        gs:=Val(eingabe);
        Get_DEdit(dialog,asprite,eingabe);
        anfang:=Val(eingabe);
        Get_DEdit(dialog,esprite,eingabe);
        ende:=Val(eingabe);
        IF (Obj_State(dialog,serie)&Selected <> 0) THEN richtung:=1 ELSE
           IF (Obj_State(dialog,rueckw)&Selected <> 0) THEN richtung:=2 ELSE
              IF (Obj_State(dialog,zyklus)&Selected <> 0) THEN richtung:=3;
        UNTIL (wahl<>ok) OR ((anfang<ende) AND (anfang>0)
              AND (ende+sres*3<=128));
End_Dialog(dialog);
Delete_Dialog(dialog);

IF wahl=ok THEN
   BEGIN
   Grid_Redraw(True);
   Bring_to_Front(spwindow);
   IF sres = FourSprites THEN addwert:=4
                         ELSE addwert:=1;
   IF richtung<>2 THEN shownr:=anfang
                  ELSE BEGIN
                       shownr:=ende;
                       addwert:=-addwert;
                       END;
   clip[0]:=spx; clip[1]:=spy; clip[2]:=spx+spw-1; clip[3]:=spy+sph-1;
   Hide_Mouse;
   REPEAT
     FOR pause:=1 TO (10-gs) DO Vsync;
     FOR pause:=1 TO 800 DO;
     fbox(clip[0],clip[1],clip[2],clip[3],0,logbase,clip);
     IF sres=OneSprite
     THEN
       Setsprite(spx+8,spy+8,sprite[(shownr-1)*80],logbase,clip,15)
     ELSE
       BEGIN
       Setsprite(spx,spy,sprite[(shownr-1)*80],logbase,clip,31);
       Setsprite(spx+16,spy,sprite[(shownr+1)*80],logbase,clip,31);
       END;
     shownr:=shownr+addwert;
     IF shownr>ende THEN
        IF richtung=3 THEN BEGIN
                           addwert:=-addwert;
                           shownr:=shownr+addwert;
                           END
                      ELSE shownr:=anfang;
     IF shownr<anfang THEN
        IF richtung=3 THEN BEGIN
                           addwert:=-addwert;
                           shownr:=shownr+addwert;
                           END
                      ELSE shownr:=ende;
   UNTIL Mouse_Button=1;
   Bring_to_Front(window);
   Sprite_Redraw;
   Show_Mouse;
   END;
END;

{ Daten als C- oder Pascal-Quellcode ablegen }
PROCEDURE Lsprite(art:BOOLEAN; planes:INTEGER);
VAR name:Path_Name;
    datei:text;
    i,j,k,gr:INTEGER;
BEGIN
gr:=15+sres*48;
IF art THEN
 IF planes=1 THEN
wahl:=Do_Alert('[2][ |Line-A-Sprite saven|Welches Format...?][ C | Pascal ]',0)
  ELSE
  wahl:=Do_Alert('[2][ |Sprite saven|Welches Format...?][ C | Pascal ]',0)
 ELSE
 wahl:=Do_Alert('[2][ |FÅllmuster saven|Welches Format...?][ C | Pascal ]',0);
IF wahl=1 THEN
    BEGIN
    IF art THEN name:=Concat(Floppy,':\sprite.c')
           ELSE name:=Concat(Floppy,':\muster.c');
    IF Get_Out_File('Name der C-Datei ?',name)THEN
        BEGIN
        REWRITE(datei,name);
        IF art THEN WRITE(datei,'int sprite[] = { ')
               ELSE WRITE(datei,'int muster[] = { ');
        IF IO_Result=0 THEN
            BEGIN
            Set_Mouse(M_BEE);
            IF art THEN
              FOR i:=0 TO gr DO
                 BEGIN
                 FOR j:=0 TO planes DO
                    BEGIN
                    WRITE(datei,'0x',sprite[(aktspr-1)*80+i*5+j]:4:h);
                    IF (j<planes) OR (i<gr) THEN WRITE(datei,',');
                    END;
                    IF i=gr THEN WRITELN(datei,' };')
                           ELSE BEGIN
                                WRITELN(datei);
                                WRITE(datei,'                 ');
                                END;
                 END
            ELSE
              FOR j:=0 TO 3 DO
                BEGIN
                FOR i:=0 TO 15 DO
                    BEGIN
                    WRITE(datei,'0x',sprite[(aktspr-1)*80+i*5+j]:4:h);
                    IF (j<3) OR (i<15) THEN WRITE(datei,',');
                    IF ((i MOD 4)=3) AND ((i<15) OR (j<3)) THEN
                                   BEGIN
                                   WRITELN(datei);
                                   WRITE(datei,'                 ');
                                   END;
                    END;
                IF j=3 THEN WRITELN(datei,' };')
                       ELSE BEGIN
                            WRITELN(datei);
                            WRITE(datei,'                 ');
                            END;
                END;
            CLOSE(datei);
            Set_Mouse(M_ARROW);
            END
            ELSE Diskerror;
        END;
    END
   ELSE
    BEGIN
    IF art THEN name:=Concat(Floppy,':\sprite.pas')
           ELSE name:=Concat(Floppy,':\muster.pas');
    IF Get_Out_File('Name der Pascal-Datei ?',name)THEN
        BEGIN
        REWRITE(datei,name);
        IF IO_Result=0 THEN
         BEGIN
         Set_Mouse(M_BEE);
         IF art THEN
         BEGIN
          IF planes=1 THEN k:=5 ELSE k:=0;
          FOR i:=0 TO gr DO
           FOR j:=0 TO planes DO
           BEGIN
         WRITELN(datei,'sprite[',k,']:=$',sprite[(aktspr-1)*80+i*5+j]:4:h,';');
           k:=k+1;
           END;
         END
         ELSE
         BEGIN
          k:=0;
          FOR j:=0 TO 3 DO
           BEGIN
           FOR i:=0 TO 15 DO
           BEGIN
         WRITELN(datei,'muster[',k,']:=$',sprite[(aktspr-1)*80+i*5+j]:4:h,';');
           k:=k+1;
           END;
           WRITELN(datei);
           END;
         END;
         CLOSE(datei);
         Set_Mouse(M_ARROW);
         END
         ELSE Diskerror;
        END;
    END;
END;

{ Information Åber das Programm ausgeben }
PROCEDURE Information;
VAR infotext:Str255;
BEGIN
infotext:='[1][ | M&T-Sprite-Editor | Ω Frank Mathy 1987 |';
infotext:=Concat(infotext,' Grafik&Sound-Buch | ST-Pascal+ (CCD)]');
infotext:=Concat(infotext,'[ OK ]');
wahl:=Do_Alert(infotext,1);
END;

{ MenÅ initialisieren }
PROCEDURE Menu_Init;
BEGIN
menu:=New_Menu(50,'  M&T Sprite-Editor ');

menu_datei:=Add_Mtitle(menu,' Datei ');

menu_edit:=Add_Mtitle(menu,' Edit ');

menu_goodies:=Add_Mtitle(menu,' Goodies ');

load_data:=Add_MItem(menu,menu_datei,'  Lade Daten  ');
save_data:=Add_MItem(menu,menu_datei,'  Save Daten  ');
dummy:=Add_MItem(menu,menu_datei,'--------------');
Menu_Disable(menu,dummy);
read_sprite:=Add_MItem(menu,menu_datei,'  Lade Sprite ');
write_sprite:=Add_MItem(menu,menu_datei,'  Save Sprite ');
dummy:=Add_MItem(menu,menu_datei,'--------------');
Menu_Disable(menu,dummy);
read_rgb:=Add_MItem(menu,menu_datei,'  Lade Farben ');
write_rgb:=Add_MItem(menu,menu_datei,'  Save Farben ');

dline:=Add_MItem(menu,menu_edit,'  Linie ziehen  ');
fuell:=Add_MItem(menu,menu_edit,'  FÅlle FlÑche  ');

dummy:=Add_MItem(menu,menu_edit,'----------------');
Menu_Disable(menu,dummy);

loeschen:=Add_MItem(menu,menu_edit,'  Lîschen       ');
kopieren:=Add_MItem(menu,menu_edit,'  Kopieren      ');
mischen:=Add_MItem(menu,menu_edit,'  Mischen       ');

dummy:=Add_MItem(menu,menu_edit,'----------------');
Menu_Disable(menu,dummy);

rotieren:=Add_MItem(menu,menu_edit,'  Rotieren 90¯  ');
frotieren:=Add_MItem(menu,menu_edit,'  Rotieren  n¯  ');

dummy:=Add_MItem(menu,menu_edit,'----------------');
Menu_Disable(menu,dummy);

scrollen:=Add_MItem(menu,menu_edit,'  Scrollen      ');
zoomen:=Add_MItem(menu,menu_edit,'  Zoomen        ');

dummy:=Add_MItem(menu,menu_edit,'----------------');
Menu_Disable(menu,dummy);

hspiegeln:=Add_MItem(menu,menu_edit,'  Spiegeln hor. ');
vspiegeln:=Add_MItem(menu,menu_edit,'  Spiegeln ver. ');

dummy:=Add_MItem(menu,menu_edit,'----------------');
Menu_Disable(menu,dummy);

undo:=Add_MItem(menu,menu_edit,'  Undo          ');

setsres:=Add_MItem(menu,menu_goodies,'  4-Sprite-Modus ');

dummy:=Add_MItem(menu,menu_goodies,'-----------------');
Menu_Disable(menu,dummy);

animate:=Add_MItem(menu,menu_goodies,'  Animation      ');

dummy:=Add_MItem(menu,menu_goodies,  '- Saven als.... -');
Menu_Disable(menu,dummy);

ascspr :=Add_MItem(menu,menu_goodies,'  Quellcode      ');
laspr  :=Add_MItem(menu,menu_goodies,'  Line-A-Sprite  ');
lafill :=Add_MItem(menu,menu_goodies,'  FÅllmuster     ');

Draw_Menu(menu);
END;

{ Auswertung der MenÅwahl }
PROCEDURE Do_Menu;
BEGIN
mausin:=FALSE;
Set_Mouse(M_ARROW);

IF msg[3]=Info THEN Information;

IF msg[3]=menu_datei THEN
        BEGIN
        IF msg[4]=load_data    THEN Read_Data;
        IF msg[4]=save_data    THEN Write_Data;
        IF msg[4]=read_sprite  THEN Load_Sprite;
        IF msg[4]=write_sprite THEN Save_Sprite;
        IF msg[4]=read_rgb     THEN Load_RGB;
        IF msg[4]=write_rgb    THEN Save_RGB;
        END;

IF msg[3]=menu_edit THEN
        BEGIN
        IF (msg[4]=dline) AND (window=Front_Window) THEN Draw_Line;
        IF (msg[4]=fuell) AND (window=Front_Window) THEN Fill_Grid;
        IF msg[4]=loeschen  THEN Clear_Grid;
        IF msg[4]=kopieren  THEN Copy_Sprite;
        IF msg[4]=mischen   THEN Mix_Sprites;
        IF msg[4]=rotieren  THEN Rotate_Grid;
        IF msg[4]=frotieren THEN Frotate_Grid;
        IF msg[4]=scrollen  THEN Scroll;
        IF msg[4]=zoomen    THEN Zoom;
        IF msg[4]=hspiegeln THEN Hmirror;
        IF msg[4]=vspiegeln THEN Vmirror;
        IF msg[4]=undo      THEN Do_Undo;
        END;

IF msg[3]=menu_goodies THEN
        BEGIN
        if msg[4]=setsres   THEN
            BEGIN
            CASE sres OF
                OneSprite:      BEGIN
                                Menu_Check(menu,setsres,TRUE);
                                sres:=FourSprites;
                                Sprite_To_Grid(aktspr);
                                Menu_Disable(menu,laspr);
                                Menu_Disable(menu,lafill);
                                END;
                FourSprites:    BEGIN
                                Menu_Check(menu,setsres,FALSE);
                                sres:=OneSprite;
                                Menu_Enable(menu,laspr);
                                Menu_Enable(menu,lafill);
                                END;
                END;
            Grid_Redraw(True);
            END;
        if msg[4]=animate THEN Animation;
        if msg[4]=ascspr  THEN Lsprite(TRUE,4);
        if msg[4]=laspr   THEN Lsprite(TRUE,1);
        if msg[4]=lafill  THEN Lsprite(FALSE,0);
        END;

Menu_Normal(menu,msg[3]);
END;

{ Hauptroutine, Åbernimmt Event-Verwaltung }
PROCEDURE Main;
VAR help:REAL;
BEGIN
mausin:=FALSE;
REPEAT
event:=Get_Event(E_BUTTON|E_MRECT_1|E_MESSAGE,
                 1,1,1,0,
                 mausin,wx,wy,ww,wh,
                 FALSE,0,0,0,0,
                 msg,
                 dummy,dummy,dummy,mx,my,dummy);

IF (event & E_MRECT_1)>0 THEN
        BEGIN
        IF mausin=FALSE THEN
                BEGIN
                mausin:=TRUE;
                Set_Mouse(M_POINT_HAND);
                END
        ELSE
                BEGIN
                mausin:=FALSE;
                Set_Mouse(M_ARROW);
                END;
        END;

IF ((event & E_BUTTON)>0) THEN
                BEGIN
                IF (window=Front_Window) AND mausin THEN
                    BEGIN
                    CConvert(mx,my);
                    Window_Clip;
                    IF (Mouse_Button & 2 = 0)  THEN Set_Block(mx,my,aktcol)
                                               ELSE Set_Block(mx,my,0);
                    Spline_Redraw(my);
                    END;
                IF (palette=Front_Window) AND InRect(mx,my,px,py,pw,10) THEN
                    Select_Color((mx-px) DIV 8);
                END;

IF (event & E_MESSAGE)>0 THEN
BEGIN
        CASE msg[0] OF
        WM_REDRAW: BEGIN
                   IF msg[3]=window THEN Grid_Redraw(True);
                   IF msg[3]=palette THEN Palette_Redraw;
                   IF msg[3]=spwindow THEN Sprite_Redraw;
                   END;

        WM_TOPPED: BEGIN
                   IF msg[3]=window THEN Bring_To_Front(window);
                   IF msg[3]=palette THEN Bring_To_Front(palette);
                   END;
        WM_ARROWED: IF msg[3]=window THEN
                        BEGIN
                        CASE msg[4] OF
                             0:   aktspr := aktspr - 4;
                             1:   aktspr := aktspr + 4;
                             2:   aktspr := aktspr - 1;
                             3:   aktspr := aktspr + 1;
                             END;
                        IF aktspr>128 THEN aktspr := 128;
                        IF (sres=FourSprites) AND (aktspr>125) THEN
                                                        aktspr:=125;
                        IF aktspr<1   THEN aktspr := 1;
                        Sprite_Select(aktspr);
                        END;
        WM_VSLID:  IF msg[3]=window THEN
                        BEGIN
                        help:=msg[4]-1;
                        help:=help*0.128;
                        aktspr:=Trunc(help)+1;
                        IF (sres=FourSprites) AND (aktspr>125) THEN
                                                        aktspr:=125;
                        Sprite_Select(aktspr);
                        END;
        MN_SELECTED:    Do_Menu;
        END;
END;

UNTIL FALSE;
END;

{ Hauptprogramm }
BEGIN
IF Init_Gem >=0 THEN
IF GetRez=0 THEN
BEGIN
Bit_Init;
Init_Mouse;
logbase:=GetLog;
Set_Mouse(M_ARROW);
Draw_Mode(Replace_Mode);

Menu_Init;

sres:=OneSprite;
aktcol:=Blue;
pname:=' Palette ';
spwindow:=New_Window(None,pname,180,45,34,34);
Open_Window(spwindow,180,45,34,34);
Work_Rect(spwindow,spx,spy,spw,sph);
palette:=New_Window(G_NAME,pname,180,11,138,29);
Open_Window(palette,180,11,138,29);
Work_Rect(palette,px,py,pw,ph);
wname:=' M&T-Sprite-Editor ';
winfo:=' Sprite 1 ';
window:=New_Window(G_NAME|G_INFO|G_UPARROW|G_DNARROW|G_VSLIDE,
                   wname,0,11,172,181);
Set_WInfo(window,winfo);
Open_Window(window,0,11,172,181);
Wind_Set(window,WF_VSLSIZE,8,0,0,0);
Work_Rect(window,wx,wy,ww,wh);

aktspr:=1;
Sprite_To_Grid(aktspr);

Main;
END

ELSE BEGIN
     wahl:=Do_Alert
 ('[3][ Der M&T-Sprite-Editor | lÑuft nur im | 320x200 Modus... ][ OK ]',1);
     Exit_Gem;
     END;

END.
