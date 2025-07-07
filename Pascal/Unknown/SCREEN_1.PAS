{$S10,$p-}                             {Zeigerkontrolle unbedingt ausschalten }
program screen_1;
                                     {Einlesen und Umdrehen eines s/w Bildes  }
type bildname = string[12];          {fuer DEGAS und andere Formate           }

var                   a,b,i,j,wert   : integer;
                      name1,name2  : bildname;
                      logadr,physadr,bild1,bild2,puffer : long_integer;
                      datei : text;
                      ch      : char;

procedure cls;
  begin
    write (chr(27),'E')
  end;

procedure cursor_aus;
  begin
    write (chr(27),'f')
  end;


procedure poke  (x:long_integer; y:integer)     ;external;
function  peek  (x:long_integer) :integer       ;external;
procedure lpoke (x:long_integer; y:long_integer);external;
function  lpeek (x:long_integer) :long_integer  ;external;
function  logbase :long_integer; xbios(3);
function  physbase :long_integer;xbios(2);
procedure lesebild (wohin:integer; size, buff: long_integer);
    gemdos ($3f);                                        {Einlesen des Bildes }
procedure setscreen (logadr,physadr:long_integer; rez:integer);xbios(5);
function getrez :integer;xbios(4);
function malloc (laenge:long_integer):long_integer; gemdos ($48);

begin


    logadr:= logbase;
    physadr:=physbase;
    cls; cursor_aus;
    puffer :=malloc (38);
    bild1 := $ca400;
    bild2 := malloc (32000);
    writeln (bild1:10,bild2:10);
    writeln (getrez);
    repeat until keypress;
    name1  := 'house.mon';
    name2  := 'aafall.mon';
     reset    (datei,name1);
     lesebild (6,32000,bild1);                    {Einlesen des Bildes }
     close(datei);

      reset (datei,name2);
      lesebild (6,32000, bild2);
      close (datei);
    for a:=0 to 5 do begin
         setscreen (logadr,BILD1,getrez);
         readln (ch);
         setscreen (logadr,BILD2,getrez);
         readln(ch);
    end;


    setscreen (logadr,physadr,getrez);

end.

