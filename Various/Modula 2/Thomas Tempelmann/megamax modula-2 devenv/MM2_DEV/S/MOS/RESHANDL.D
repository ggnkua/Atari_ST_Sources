DEFINITION MODULE ResHandler;

(*------------------------------------------------------------------------------
 * Version 1.3
 *------------------------------------------------------------------------------
 * Written 1989, 1990 by Michael Seyfried
 * Copyright 1989, 1990 by Michael Seyfried, Thomas Tempelmann
 *------------------------------------------------------------------------------
 *                            Modulbeschreibung
 *
 * Bei der Verwaltung von Systemressourcen (z.B: Speicher, Fenster, Daten
 * etc.) in Anwenderprozessen sollte man bei Beendigung dafÅr sorgen, daû
 * diese wieder freigegeben werden. Insbesondere sollten auch bei Abbruch
 * des Programms die geîffneten Ressourcen korrekt geschlossen werden.
 *
 * Mit Hilfe dieses Moduls kann dies automatisch durchgefÅhrt werden. Dazu
 * werden alle geîffneten Ressourcen in Listen verwaltet. Eine Ressource-Liste
 * kann mit 'CreateResource' angelegt werden. Nach dem ôffnen einer Ressource
 * sollte man diese mit 'InsertHandle' in die richtige Liste eintragen und nur
 * mit 'RemoveHandle' wieder lîschen. Mit 'HandleInList' kann man erfragen,
 * ob eine Ressource noch in einer Liste enthalten, d.h. geîffnet ist.
 * Endet ein Prozeû, dann werden alle so verketteten Ressourcen, die von
 * ihm mit 'InsertHandle' eingetragen wurden, automatisch gelîscht.
 *
 * Ein Modul, das diese Funktionen benutzt, sollte in der Regel als System-
 * Modul mit der Option $Y+ (s. Handbuch) Åbersetzt werden.
 *
 * Eine Demo-Anwendung hierzu findet sich im Modul "SysLibDemo" (s. DEMO-
 * Ordner).
 *------------------------------------------------------------------------------
 *)

FROM SYSTEM IMPORT ADDRESS;


TYPE Resource;                                      (* Ressourceliste *)

     CloseProc = PROCEDURE ((* handle *) ADDRESS,
                            (* user   *) BOOLEAN);  (* Freigabe-Prozedur *)


PROCEDURE CreateResource (VAR rsc: Resource; VAR error: BOOLEAN);
  (*
   * Effekt:  Es wird eine Liste angelegt, in der geîffnete Ressourcen
   *          verkettet werden kînnen.
   * Ausgabe: 'error' ist genau dann TRUE, wenn der Speicher nicht reicht.
   *          Es werden nur wenige Bytes dafÅr benîtigt (ca. 10-50)
   *)

PROCEDURE InsertHandle (    rsc: Resource;
                            handle: ADDRESS;
                            close: CloseProc;
                        VAR error: BOOLEAN);
  (*
   * Eingabe: Ressource-Liste, Ressourcekennung und Freigabe-Prozedur
   * Effekt:  Die Resorcekennung wird in der angegebenen Ressource-Liste
   *          eingetragen. Wird nun der Prozeû, von dem aus 'InsertHandle'
   *          aufgerufen wurde, beendet, so wird fÅr jede Ressource die
   *          zustÑndige Freigabe-Prozedur aufgerufen, und zwar in der
   *          umgekehrten Reihenfolge, in der sie hier angemeldet wurde.
   *          Der Parameter 'user' ist in diesem Fall 'FALSE', da die Freigabe-
   *          prozedur vom System automatisch aufgerufen wurde.
   * Beachte: Eine mit 'InsertHandle' eingetragene Ressource sollte nur mit
   *          'RemoveHandle' freigegeben werden, weil sonst die Freigabe -
   *          Prozedur mit einer ungÅltigen Kennung aufgerufen wird.
   *          Die Kennungen mÅssen paarweise verschieden sein (z.B: Adressen)!!
   * Ausgabe: error ist genau dann TRUE, wenn der Speicher nicht reicht.
   *          Es werden nur wenige Bytes dafÅr benîtigt (ca. 10-50)
   *)

PROCEDURE InsertSysHandle (    rsc: Resource;
                               handle: ADDRESS;
                               close: CloseProc;
                           VAR error: BOOLEAN);
  (*
   * Wie 'InsertHandle', nur wird die Freigabe-Prozedur nicht automatisch
   * aufgerufen. Dies muû explizit mit 'RemoveHandle' erledigt werden.
   * Zweck dieser Prozedur ist eine einheitliche Verwaltung von Ressourcen
   * und System-Ressourcen wÑhrend der Laufzeit. So kann z.B. einheitlich
   * mit 'HandleInList' festgestellt werden, ob eine Ressource noch in der
   * zugehîrigen Liste, d.h., noch geîffnet ist.
   *)

PROCEDURE RemoveHandle (rsc: Resource; handle: ADDRESS);
  (*
   * Eingabe: Ressource-Liste, Kennung einer Ressource
   * Effekt:  Falls die Ressource mit 'InsertHandle' eingetragen wurde, wird
   *          die zugehîrige Freigabe-Prozedur (mit 'user = TRUE') aufgerufen
   *          und die Kennung aus der Liste 'rsc' gestrichen.
   *)

PROCEDURE HandleInList (rsc: Resource; handle: ADDRESS): BOOLEAN;
  (*
   * Eingabe: Ressource-Liste, Kennung einer Ressource
   * Wert:    genau dann TRUE, wenn die Ressource in 'rsc' eingetragen und
   *          noch nicht wieder mit 'RemoveHandle' gelîscht wurde.
   *)


(*
 * Mit den folgenden beiden Prozeduren kînnen alle eingetragenen Kennungen in
 * einer Ressource-Liste erfragt werden. Dazu wird erst 'FirstHandle' und dann
 * immerwieder 'NextHandle' aufgerufen, bis NIL zurÅckgegeben wird.
 * Es ist erlaubt, zwischen 'FirstHandle' und 'NextHandle', andere
 * Prozeduren aus diesem Modul aufzurufen (z.B: 'RemoveHandle').
 *)

PROCEDURE FirstHandle (rsc: Resource): ADDRESS;
  (*
   * Eingabe: Ressource-Liste
   * Wert:    Kennung der ersten verketteten Ressource oder NIL, falls die
   *          Liste leer ist.
   *)

PROCEDURE NextHandle (rsc: Resource): ADDRESS;
  (*
   * Eingabe: Ressource-Liste
   * Wert:    Kennung der nÑchsten verketteten Ressource oder NIL, falls dies
   *          nicht existiert.
   *)

END ResHandler.
