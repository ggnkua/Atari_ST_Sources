{ Diese Programm stellt den Systemtakt des      }
{ MEGA-STE auf einen gewÅnschten Wert und       }
{ erlaubt es den Cache einzuschalten.           }
{   Ersteller        : Martin Ruppenstein       }
{   Programiersystem : MAXON Pascal 1.5         }
{   Datum            : 03.04.92                 }
{   (c) 1992 MAXON Computer                     }

{$R-,S-,V-,D-}
Program Umschaltung_16MHz_C;

(******** Benîtigte Tools         *************)

uses Dos,Bios;


(********    Globale Variabelen   *************)

var
  Sp_stelle  : ^longint;  { RÅckgabewert Cookie }
  ok_g       : boolean;   { CapsLock betÑtigt?  }
  inhalt     : longint;   { Inhalt von Kbshift  }
                          { [bios 11] lesen     }

(******* Hilfsrotinen             *************)

{ C_String in Pascal String wandeln  }
procedure CtoPas_Str(C: pointer;
                     P: string);ASSEMBLER;
ASM
  MOVE.L  C,A0    { Adresse vom C-String Åberg. }
  MOVE.L  P,A1    { Pascal-Str. Åbergeben       }
  CLR.L   D0      { ZÑhler auf Null             }
 @L1:             { Label 1                     }
  TST.B   (A0)    { Test ob Null char           }
  BEQ     @L2     { und tschÅû                  }
  ADDQ.B  #1,D0   { ZÑhler um 1 erhîhen         }
  MOVE.B  D0,(A1) { ZÑhler an Pas[0] Åbergeben  }
  MOVE.B  (A0)+,0(A1,D0)  { C-Char an Pascal- }
                          { string Åbergeben  }
  BRA     @L1   { Neues Zeichen holen         }
 @L2:             { Unterprogramm ende          }
END;

{ Funktion dieht zum Auffinden eines bestimmten }
{ Cookie's im Cookie Jar                        }
function Find_cookie(name : string) : pointer;
  var
    cook_name  : ^char;   { Adresse Cookie      }
    cook_str   : string;  { Cookie Name         }
    sp         : pointer; { Stackpointer sichern}

    { Absolute Adresse des Cookie Jar's}
    cookie_jar : longint ABSOLUTE $5A0;

    zaehler    : shortint;{ HilfszÑhler         }
begin
  sp := super(NIl);    { Supervisormode ein!    }

    { Variabelen auf null setzen                }
  Find_cookie := NIL;
  zaehler     := 0;

    {Cookie Jar untersuchen }
  While (( cookie_jar<>0 ) and
        not ((cook_str = name) or
        (cook_name^=char(0)))) do begin
    cook_name := ptr(cookie_jar+
                 sizeof(longint)*zaehler);
    CtoPas_Str(cook_name,cook_str);

     { Cookie gefunden?     }
    if cook_str = name then
      Find_cookie := Cook_name;
    inc(zaehler,2);
  end;
  sp:=super(sp);      { Supervisormodus aus }
end;

{ -- Systemtakt stellen und Cache einschalten ! }
procedure Takt_stellen(W : shortint);
  var
    sp         : pointer; { Stackpointer sichern}

    {Absolute Adresse fÅr Hardwareregister zum  }
    {Umschalen von Systemtakt und Cache         }
    ste_ctl    : Byte ABSOLUTE $FF8E21;

begin

    { -- Komentar Zeilen  }
  writeln(#27'E');writeln;
  writeln('Umschalt Rotine des Mega STE');
  writeln('(C) Martin Ruppenstein 1992');

  sp:=super(NIL);     { Supervisormodus ein }

    { Bit 0 und 1 auf Low setzen }
  ste_ctl := (ste_ctl or 3) xor 3;
  case W of
    1 : begin
         write(#27'p Mega STE mit 8 Mhz Modus');
         writeln(#27'q');
        end;
    2 : begin
         ste_ctl:=ste_ctl or 2;
         write(#27'p Mega STE mit 16 Mhz Modus');
         writeln(' ohne Cache!'#27'q');
        end;
    3 : begin
         ste_ctl:=ste_ctl or 3;
         write(#27'p Mega STE mit 16 Mhz Modus');
         writeln(' mit Cache!'#27'q');
        end;
  end;
  sp:=super(sp);      {Supervisormodus aus }
end;

{ Auswahl Menu um den Takt selber einzustellen  }
function Menu : shortint;
  var wahl  : shortint;
begin
  clrscr;
  gotoxy(5,7);
  write('Mit dem nun folgendem Menu kann ');
  write('die Einstellung selbst ');
  write('gewÑhlt werden!');
  gotoxy(7,10);
  write(#27'p1'#27'q -> 8 Mhz Mode ohne Cache');
  gotoxy(7,12);
  write(#27'p2'#27'q -> 16 Mhz Mode ohne Cache');
  gotoxy(7,14);
  write(#27'p3'#27'q -> 16 Mhz Mode mit Cache');
  gotoxy(13,16);
  writeln('Treffen Sie Ihre Wahl (1/2/3) ?');
  repeat
    wahl:=integer(readkey)-integer('0');
  until wahl in [1,2,3];
  Menu := wahl;
end;

{ Anzeige fÅr falsches System !!!!!!!!}
procedure Kein_STE;
begin
  clrscr;
  writeln;
  writeln;
  writeln(#27'pTut mir Sorry!'#27'q');
  write('Handelt sich nicht um einen MEGA STE!');
  writeln;
  write('Dieses Programm ist aber nur fÅr ');
  writeln('MEGA STE geeignet !!');
  delay(1000);
end;

{ Status Umschalttasten abfragen und zurÅckge. }
function Tastenabf(VAR UE :longint) : Boolean;
  var In_h : longint;
begin
  In_h      := Kbshift(-1);
  Tastenabf := (In_h and UE) = UE;
  UE        := In_h;
end;


(***********************************************)
(******* H A U P T P R O G R A M M   ***********)
(***********************************************)

begin

    { Feststellen ob CapsLock in Betrieb und }
    { zurÅcksetzen falls sie betÑtigt        }
  inhalt := 16;
  ok_g   := Tastenabf(inhalt);
  if ok_g then
    inhalt:= Kbshift(inhalt xor 16);

    { Suchen nach Maschinen Type            }
  sp_stelle := find_cookie('_MCH');

    { Keinen Eintrag gefunden kein MEGA-STE }
  if (sp_stelle=NIL) then begin
    Kein_STE;
    exit;     { und TschÅû }
  end
  else { wenn Cookie vorhanden, Inhalt Lesen }
    sp_stelle := ptr(longint(sp_stelle)
                 +sizeof(longint));

    { Ist der Cookie Inhalt gleich  }
    { $00010010 dann ist Rechner ein}
    { Mega STE                      }
  if (sp_stelle^ = 65552)  then
    if ok_g then { Selber Configurieren?      }
    begin
      Takt_stellen(Menu); { Systemtakt selber }
      delay(500);         { stellen !         }
    end
    else
      Takt_stellen(3)    { Systemtakt auf     }
                         { 16 Mhz plus Cache  }
  else
    Kein_STE;   { Es war wieder kein Mega STE }

end.
