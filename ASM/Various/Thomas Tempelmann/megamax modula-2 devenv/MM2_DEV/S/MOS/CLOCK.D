DEFINITION MODULE Clock;

(*
 * Zeitbestimmung, Wochentagsbestimmung, sowie Zeitdifferenz/addition.
 *)

IMPORT  MOSGlobals;

TYPE    Time = MOSGlobals.Time;
               (* RECORD second: [0..59]; minute: [0..59]; hour: [0..23] END *)

        Date = MOSGlobals.Date;
               (* RECORD day: [1..31]; month: [1..12]; year: CARDINAL; END *)

        WeekDays = (mon, tue, wed, thu, fri, sat, sun);

(*
 * Die GEMDOS-Zeit wird beim Anlegen und Ver„ndern von Dateien verwendet,
 * die XBIOS-Zeit bleibt bei einem System-Neustart erhalten. Beide Zeiten
 * sind nicht exakt gleich !
 *)

PROCEDURE CurrentDate (): Date;
  (* GEMDOS - Zeit *)

PROCEDURE CurrentTime (): Time;
  (* GEMDOS - Zeit *)

PROCEDURE SetDateAndTime ( d: Date; t: Time );
  (* GEMDOS - und XBIOS - Zeit *)

PROCEDURE GetDateAndTime ( VAR d:Date; VAR t: Time );
  (* XBIOS - Zeit *)


(*
 * Umwandeln der Zeit/Datums-Records in CARDINAL-Werte (GEMDOS-interne
 * Darstellung) und zurck.
 *
 * Die gepackten Werte von 'Time' und 'Date' entsprechen den Darstellungen
 * des GEMDOS und sind so aufgebaut, da Zeitvergleiche einfach mit '>'
 * und '<' m”glich sind.
 *)

PROCEDURE PackDate ( d: Date ): CARDINAL;

PROCEDURE UnpackDate ( d: CARDINAL ): Date;

PROCEDURE PackTime ( t: Time ): CARDINAL;

PROCEDURE UnpackTime ( t: CARDINAL ): Time;


(*
 * Die folgenden Funktionen wurden erstellt von
 *
 *   Markus Kilbinger, Vaalser Str. 152b, 5100 Aachen, Tel.: 0241 875896
 *
 * Sie bercksichtigen auch die Besonderheiten des gregorianischen
 * Kalendersystems. Das Datum ist somit ab der Einfhrung des gregor.
 * Kalenders im Jahre 1582 gltig.
 *)


PROCEDURE DayOfWeek (d: Date): WeekDays;
  (*
   * Bestimmt zu einem gegebenen Datum 'd' den Wochentag.
   *)

PROCEDURE DaysBetween (from, to: Date): LONGINT;
  (*
   * Berechnet die Anzahl der Tage zwischen zwei Daten 'from' und 'to'.
   * Ist 'from' „lteren Datums als 'to', wird ein positiver Wert geliefert.
   *)

PROCEDURE DaysAdded (d: Date; n: LONGINT): Date;
  (*
   * Addiert zu einem Datum 'd' 'n' Tage und liefert das sich ergebende Datum.
   *)

END Clock.
