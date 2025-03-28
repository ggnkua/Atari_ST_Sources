(************************************************
*                                               *
* Interrupt-Programmierung in MAXON-Pascal      *
* UNIT I_TIMER zum Handling einer Uhr           *
* von Thomas Krieger                            *
* (C) 1992 MAXON Computer                       *
*                                               *
************************************************)

(*$S-,R-,D-,F+*)

unit i_timer;

interface

(*

   ”ffentliche Prozeduren und deren 
   Schnittstellen

*)


uses dos, bios, graph;


(*

   Prozedur : init_timer
   Parameter: x, y - Koordinaten fr OutTextXY
   Zweck    : Einrichten des Timers im Interrupt
              und Start
   Ver„ndert: Flag is_init

*)


   procedure init_timer(x, y: Integer);


(*

   Prozedur : exit_timer
   Parameter: keine
   Zweck    : Entfernen des Timers und Interrupt
              abschalten
   Ver„ndert: Flag is_init

*)


   procedure exit_timer;


(*

   Prozedur : restore_timer
   Parameter: keine
   Zweck    : Aktuellen Stand des Timers
              ausgeben, wenn initialisiert
   Ver„ndert: nichts

*)


   procedure restore_timer;

(*

   Prozedur : enable_timer
   Parameter: keine
   Zweck    : Bildschirmausgabe des Timers
              erfolgt
   Ver„ndert: Flag disabled

*)


   procedure enable_timer;


(*

   Prozedur : disable_timer
   Parameter: keine
   Zweck    : Bildschirmausgabe des Timers
              erfolgt nicht mehr
   Ver„ndert: Flag disabled

*)


   procedure disable_timer;




implementation

(*

   Implementierung der Prozeduren;
   Nach aužen verdeckte Konstanten und
   Variaben

*)


const MFPISRA          = $FFFA0F;
         (* Interrupt-Service-Register   *)

      TIMER_A          = 0;
         (* Nummer Timer A               *)

      MFP_TIMERA       = 13;
         (* Interrupt Timer A im MFP     *)


var zaehler,                 (* Milisekunden   *)
    stunde,                  (* Initialwerte
                                des Timers     *)
    minute,
    sekunde,
    i,                       (* Laufvariable   *)
    tx,                      (* Position fr
                                String-Ausgabe *)
    ty     : Integer;

    stundestr,               (* String fr
                                Stunde         *)
    minutestr,               (* Minute         *)
    sekundestr  : String[2]; (* Sekunde        *)

    zeit   : String;         (* Zeit, format-
                                tiert fr  die
                                Ausgabe        *)

    adresse: Pointer;        (* Zeiger auf
                                Timer-Prozedur *)

    disabled,                (* Timer nicht
                                angezeigen     *)
    is_init: Boolean;        (* Flag, ob Timer
                                initialisiert  *)


(*

   Interrupt-Routine mit Zeitausgabe am
   Bildschirm benutzt diverse interne
   globale Variablen.
   Die String-Ausgabe erfolgt ber die
   Graph-Unit-Funktion OutTextXY

*)


   procedure do_time;
   begin
      asm
         movem.l  D0-D7/A0-A5,-(A7); (* Register
                                        retten *)
         bclr     #5, MFPISRA
      end;

      if
         (zaehler = 999) (* Eine Sekunde ist
                            vorbei             *)
      then
      begin
         Jdisint(MFP_TIMERA);   (* Timer_A-
                                   Interrupt
                                   sperren     *)

         sekunde:= sekunde + 1; (* Sekunden um
                                   eins erh”hen*)

         if                     (* Minute
                                   erh”hen ?   *)
            sekunde > 59
         then
         begin
            sekunde := 0;
            minute  := minute + 1;
         end;

         if                     (* Stunde
                                   erh”hen ?   *)
            minute > 59
         then
         begin
            minute := 0;
            stunde := stunde + 1;
         end;

         if                     (* Stunde auf
                                   Null zu-
                                   rcksetzen? *)
            stunde > 23
         then
            stunde := 0;

         str(stunde ,stundestr); (* Umwandeln  *)
         str(minute ,minutestr); (* in Strings *)
         str(sekunde,sekundestr);(* zur Ausgabe*)

         if
            length(stundestr) < 2    (* Fhrende
                                        Nullen
                                        einfgen,
                                        wenn
                                        n”tig  *)
         then
            stundestr := '0' + stundestr;

         if
            length(minutestr) < 2
         then
            minutestr := '0' + minutestr;

         if
            length(sekundestr) < 2
         then
            sekundestr := '0' + sekundestr;

         zeit := stundestr + ':' + minutestr +
         ':' + sekundestr + #00;
             (* Zeit-String zusammensetzen *)

         for i := 1 to length(zeit) do
                     (* Ziffern in Digital-
                        Ziffern umwandeln *)
         begin
            case zeit[i] of
            '0': zeit[i] := chr(16);
            '1': zeit[i] := chr(17);
            '2': zeit[i] := chr(18);
            '3': zeit[i] := chr(19);
            '4': zeit[i] := chr(20);
            '5': zeit[i] := chr(21);
            '6': zeit[i] := chr(22);
            '7': zeit[i] := chr(23);
            '8': zeit[i] := chr(24);
            '9': zeit[i] := chr(25);
            end;
         end;

         if
            not disabled  (* Ausgabe m”glich *)
         then
         begin
            SetTextStyle(DefaultFont,HorizDir,8);
            OutTextXY(tx, ty, zeit);
         end;

         zaehler := 1;         (* Z„hler
                                  zurcksetzen *)

         Jenabint(MFP_TIMERA); (* Timer_A-Inter-
                                  rupt wieder
                                  zulassen     *)
      end
      else                     (* Sonst, Mili-
                                  sekunden-Z„hler
                                  um eins
                                  erh”hen      *)
      begin
         zaehler := zaehler + 1;
      end;

      asm
         movem.l  (A7)+,D0-D7/A0-A5  (* Register
                                     zurckholen
                                     und Ende *)
         unlk     A6
         rte
      end;
   end;


(*

   Initialisieren des Timers;
   holen der aktuellen Uhrzeit, Z„hler setzen
   Initialisierungsflag setzen, Adresse der
   Interrupt-Routine ermitteln;
   Koordinaten fr Ausgabe in interne Variablen
   bernehmen

*)


   procedure init_timer(x, y: Integer);
   var dummy: Integer;
   begin
      if
         not is_init    (* Timer noch nicht
                           initialisiert *)
      then
      begin
         if             (* Koordinaten
                           korrekt ? *)
            ((x >= 0) and (x <= GetMaxX) and
            ((y >= 0) and (y <= GetMaxY)))
         then
         begin
            tx       := x;         (* Koordinaten
                                   bernehmen *)
            ty       := y;
            zaehler  := 999;       (* Z„hler
                                   initialisieren
                                   und sofort
                                   Zeit ausge-
                                   ben *)

            adresse  := @do_time;  (* Adresse der
                                      Interrupt-
                                      Routine
                                      ermitteln*)

            is_init  := true;      (* Timer ist
                                      jetzt
                                   initialisiert
                                   *)

            GetTime(stunde,minute,sekunde,dummy);
                        (* aktuelle Zeit holen *)

            XbTimer(NIL,0,0,TIMER_A);
                        (* evtl. vorhandene
                           Timer_A-Interrupt-
                           Routine l”schen *)

            XbTimer(adresse,49,4,TIMER_A);
                        (* Timer_A starten mit
                           Vorteiler 1:50 und
                           Initialwert 49 *)
         end
         else     (* Koordinaten falsch => nicht
                     initialisieren + Meldung *)
         begin
            write('Interrupt-Timer nicht ');
            writeln('initialisiert !');
            delay(3000);
                  (* 3 Sekunden Pause *)
         end;
      end;
   end;


(*

   Timer_A Interrupt-Routine l”schen;
   Timer-Routine beenden

*)


   procedure exit_timer;
   begin
      if
         is_init        (* Timer schon
                           initialisiert ? *)
      then
      begin
         XbTimer(NIL,0,0,TIMER_A);
               (* Interrupt-Routine l”schen *)

         Jdisint(MFP_TIMERA);
               (* Timer_A-Interrupt sperren *)

         is_init := false;
               (* Timer ist nicht mehr da *)
      end;
   end;


(*

   Zeit am Bildschirm ausgeben, auch wenn noch
   keine Sekunde vorbei ist. Dient dazu, wenn der
   Bildschirm in TOS-Programmen gel”scht wird,
   den Timer ohne Verz”gerung wieder auf den
   Bildschirm zu bringen.

*)


   procedure restore_timer;
   begin
      if
         is_init and not disabled
            (* Timer initialisiert und
               eingeschaltet ? *)
      then
      begin
         SetTextStyle(DefaultFont, HorizDir, 8);
         OutTextXY(tx, ty, zeit);
      end;
   end;


(*

   Zeitausgabe wieder einschalten und sofort
   Zeit ausgeben

*)


   procedure enable_timer;
   begin
      if
         is_init
            (* Uhr initialisiert ? *)
      then
      begin
         disabled := false;
            (* Ausgabe einschalten *)

         restore_timer;
            (* Zeit am Bildschirm ausgeben *)
      end;
   end;


(*

   Zeitausgabe ausschalten

*)


   procedure disable_timer;
   begin
      if
         is_init
            (* Uhr initialisiert ? *)
      then
         disabled := true;
            (* Ausgabe abschalten *)
   end;


begin
   is_init := false;     (* Initialisierungen *)
   disabled:= false;
end.

