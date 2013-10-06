PROGRAM sounddemo;

VAR eingabe:CHAR;
    i,form,ffq,rfq:INTEGER;
    snd,fq,ld:ARRAY[0..2] OF INTEGER;

PROCEDURE sound(kanal,hoehe,volumen,modus:INTEGER);
C;

PROCEDURE setcfreq(periode:INTEGER);
C;

PROCEDURE setcurve(form:INTEGER);
C;

PROCEDURE setfreq(kanal,frequenz:INTEGER);
C;

PROCEDURE setloud(kanal,volumen:INTEGER);
C;

PROCEDURE setnoise(periode:INTEGER);
C;

PROCEDURE setvoice(kanal,modus:INTEGER);
C;

PROCEDURE bpoke(adress:LONG_INTEGER; wert:INTEGER);
C;

PROCEDURE IO_Check(modus:BOOLEAN);
EXTERNAL;

FUNCTION Getkey:CHAR;
GEMDOS(7);

{ Cursor positionieren }

PROCEDURE GOTOXY(x,y:INTEGER);
BEGIN
WRITE(CHR(27),'Y',CHR(32+y),CHR(32+x));
END;

{ Bildschirm l”schen }

PROCEDURE CLS;
BEGIN
WRITE(CHR(27),'E');
END;

{ Zeichen l”schen }

PROCEDURE CLEAR(x,y,zeichen:INTEGER);
VAR i:INTEGER;
BEGIN
GOTOXY(x,y);
IF zeichen>0 THEN FOR i:=1 TO zeichen DO WRITE(CHR(32));
END;

PROCEDURE voice(kanal,modus:INTEGER);
BEGIN
CLEAR(44,3+kanal,20);
GOTOXY(44,3+kanal);
CASE modus OF
        0:      WRITELN('Aus');
        1:      WRITELN('Ton');
        2:      WRITELN('Rauschen');
        3:      WRITELN('Ton und Rauschen');
        END;
END;

FUNCTION input(zeile:INTEGER):INTEGER;
VAR i:INTEGER;
BEGIN
CLEAR(44,zeile,10);
GOTOXY(44,zeile);
READLN(i);
input:=i;
END;

FUNCTION frequenz(kanal:INTEGER):INTEGER;
VAR i:INTEGER;
BEGIN
REPEAT
   i:=input(7+kanal);
UNTIL i>30;
frequenz:=i;
END;

FUNCTION laut(kanal:INTEGER):INTEGER;
BEGIN
laut:=input(11+kanal);
END;

FUNCTION huellform:INTEGER;
BEGIN
huellform:=input(15);
END;

FUNCTION huellper:INTEGER;
BEGIN
huellper:=input(16);
END;

FUNCTION rausch:INTEGER;
BEGIN
rausch:=input(18);
END;

PROCEDURE save;
VAR name:STRING;
    datei:TEXT;
    i:INTEGER;
BEGIN
name:='';
GOTOXY(10,21); WRITE('Dateiname : ');
READLN(name);
IF LENGTH(name)>0 THEN
  BEGIN
  REWRITE(datei,name);
  FOR i:=0 TO 2 DO
      WRITELN(datei,'fsound(',i,',',fq[i],',',ld[i],',',snd[i],');');
  IF (snd[0]>1) OR (snd[1]>1) OR (snd[2]>1) THEN
    WRITELN(datei,'setnoise(',rfq,');');
  IF (ld[0]>15) OR (ld[1]>15) OR (ld[2]>15) THEN
    BEGIN
    WRITELN(datei,'setcurve(',form,');');
    WRITELN(datei,'setcfreq(',ffq,');');
    END;
  CLOSE(datei);
  END;
CLEAR(10,21,69);
END;

BEGIN
bpoke($484,0);  { Tastaturklick ausschalten }
IO_Check(FALSE);
fq[0]:=0; fq[1]:=0; fq[2]:=0;
sound(0,0,0,0);
sound(1,0,0,0);
sound(2,0,0,0);
CLS;
GOTOXY(9,0); WRITELN('Sound-Generator F.Mathy, (C) M&T (Grafik&Sound-Buch)');
GOTOXY(9,1); WRITELN('----------------------------------------------------');

GOTOXY(10,3); WRITELN('A   Kanal 0');
GOTOXY(10,4); WRITELN('B   Kanal 1');
GOTOXY(10,5); WRITELN('C   Kanal 2');

GOTOXY(10,7); WRITELN('D   Frequenz Kanal 0 (Hz)');
GOTOXY(10,8); WRITELN('E   Frequenz Kanal 1 (Hz)');
GOTOXY(10,9); WRITELN('F   Frequenz Kanal 2 (Hz)');

GOTOXY(10,11); WRITELN('G   Lautst„rke Kanal 0 (0-16)');
GOTOXY(10,12); WRITELN('H   Lautst„rke Kanal 1 (0-16)');
GOTOXY(10,13); WRITELN('I   Lautst„rke Kanal 2 (0-16)');

GOTOXY(10,15); WRITELN('J   Hllkurvenform (0-15)');
GOTOXY(10,16); WRITELN('K   Hllkurvenperiode');

GOTOXY(10,18); WRITELN('L   Rauschfrequenz (0-31)');

GOTOXY(10,20); WRITELN('S   Speichern');

GOTOXY(10,22); WRITELN('Q   Beenden');

VOICE(0,0);
VOICE(1,0);
VOICE(2,0);

GOTOXY(10,24); WRITE('>');

REPEAT

 GOTOXY(11,24);
 eingabe:=Getkey;

 CASE eingabe OF
        'a','A','b','B','c','C':        BEGIN
                                        i:=ORD(eingabe)-65;
                                        IF i>2 THEN i:=i-32;
                                        snd[i]:=(snd[i]+1) MOD 4;
                                        setvoice(i,snd[i]);
                                        VOICE(i,snd[i]);
                                        END;
        'd','D','e','E','f','F':        BEGIN
                                        i:=ORD(eingabe)-68;
                                        IF i>2 THEN i:=i-32;
                                        WRITE(CHR(i+68));
                                        fq[i]:=frequenz(i);
                                        setfreq(i,fq[i]);
                                        END;
        'g','G','h','H','i','I':        BEGIN
                                        i:=ORD(eingabe)-71;
                                        IF i>2 THEN i:=i-32;
                                        WRITE(CHR(i+71));
                                        ld[i]:=laut(i);
                                        setloud(i,ld[i]);
                                        END;
        'j','J':                        BEGIN
                                        WRITE('J');
                                        form:=huellform;
                                        setcurve(form);
                                        END;
        'k','K':                        BEGIN
                                        WRITE('K');
                                        ffq:=huellper;
                                        setcfreq(ffq);
                                        END;
        'l','L':                        BEGIN
                                        WRITE('L');
                                        rfq:=rausch;
                                        setnoise(rfq);
                                        END;
        's','S':                        BEGIN
                                        WRITE('S');
                                        save;
                                        END;
        END;

 CLEAR(11,24,1);
 UNTIL (eingabe='q') OR (eingabe='Q');
 sound(0,0,0,0);
 sound(1,0,0,0);
 sound(2,0,0,0);
END.
