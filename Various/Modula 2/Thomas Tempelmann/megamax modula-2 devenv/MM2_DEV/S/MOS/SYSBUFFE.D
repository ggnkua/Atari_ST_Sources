DEFINITION MODULE SysBuffers;

(*
 * Dies Modul stellt lediglich Variablen zur VerfÅgung, die sich als
 * Stack-Bereich fÅr die Verwendung bei einigen MOS-Funktionen eignen.
 *
 * Alle in Frage kommenden MOS-Funktionen haben dazu einen Parameter,
 * meist 'wsp' genannt, vom Typ 'MOSGlobals.MemArea'. Eine Variable
 * dieses Typs ist zu deklarieren und dann wie folgt zu initialisieren
 * (naja, ein Aggregat wÅrde es auch tun).
 *
 *   Bsp. fÅr Anwendung von CatchErrors:
 *
 *   BEGIN
 *     HdlError.CatchErrors (errorHandlingProcedure,
 *                           MOSGlobals.MEM (SysBuffers.HdlErrorStack));
 *
 * öbrigens: Bei CatchProcessTerm, CatchRemoval und SetEnvelope kann
 *    'wsp.bottom' NIL sein, es braucht also kein extra Stack reserviert
 *    werden, weil zum Zeitpunkt der Aufrufe der dort angemeldeten
 *    Prozeduren bereits der normale Programm-Stack verwendet werden kann.
 *)

FROM SYSTEM IMPORT BYTE;

VAR HdlErrorStack: ARRAY [1..2000] OF BYTE;
    (*
     * Dieser Stack kann, sofern er ausreichend groû ist,
     * fÅr alle bei 'HdlError.CatchErrors' angemeldeten
     * verwendet werden.
     *)

VAR ExceptsStack: ARRAY [1..2000] OF BYTE;
    (*
     * Dieser Stack ist fÅr die Prozeduren im Modul 'Excepts'
     * vorgesehen.
     *)

END SysBuffers.
