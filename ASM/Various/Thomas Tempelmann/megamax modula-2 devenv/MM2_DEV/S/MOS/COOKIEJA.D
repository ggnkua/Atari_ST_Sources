DEFINITION MODULE CookieJar;

(*
 * Cookies sind, Ñhnlich XBRA (s. entspr. Modul), im System global
 * zugÑngliche Variablen. Sie bestehen jeweils aus einem Namen (4 Byte,
 * mîglichst ein lesbarer Text) und einem 32Bit-Wert. Sie werden vom
 * Betriebssystem (im Atari STE und TT) oder von residenten Programmen
 * eingetragen.
 *
 * Sie dienen dazu, eine statische Schnittstelle zu anderen Programmen
 * herzustellen. Wenn beispielsweise ein residentes Programm (im AUTO-Ordner)
 * einen Cookie anlegt, dessen Wert ein Zeiger auf einen eigenen Datenbereich
 * ist, kînnen andere Programme spÑter diesen Cookie finden und auf die Daten
 * des residenten Programms zugreifen.
 *
 * Atari hat weiterhin einige Cookies vordefiniert (s.u.), die den Rechner
 * und seine Hardware beschreiben. Sie sind allerdings erst seit TOS 1.6,
 * also z.Zt. nur beim Atari STE und TT vorhanden. LÑût sich also ein
 * Atari-definierter Cookie nicht finden, kann davon ausgegangen werden,
 * daû ein Atari ST vorliegt. Allerdings ist es auch mîglich, daû residente
 * Programme auf dem ST die Atari-Cookies nachtragen.
 *
 * VORSICHT: Wenn Sie selbst eigene Cookies eintragen wollen, mÅssen Sie
 * einiges mehr an Wissen darÅber haben (z.B. Atari STE TOS Release Notes
 * vom 12.1.90). Vor allem sollten Sie Cookies nur in residenten Programmen
 * erzeugen, jedoch NIE in Accessories. FÅr Accessories gibt es im Åbrigen
 * eine bessere Methode: Die AES-Funktionen 'FindApplication', 'WriteToAppl'
 * und 'ReadFromAppl' (Modul AESMisc)!
 *)


FROM SYSTEM IMPORT LONGWORD;

PROCEDURE GetCookie (cookie: LONGWORD; VAR value: LONGWORD): BOOLEAN;
  (*
   * Liefert TRUE, wenn der Åbergebene Cookie gefunden wird. Liefert
   * dann in 'value' den dazugehîrigen Lognword-Wert, bei FALSE ist
   * 'value' immer Null. Die von Atari vordefinierten Cookies finden
   * sich weiter unten.
   *
   * Wird beispielsweise nur das 1. Word des Wertes als SHORTCARD benîtigt,
   * kann eine Variable vom Typ "SysTypes.AnyLongType" Åbergeben und
   * der SHORTCARD dann Åber das Record-Feld "c1" erreicht werden.
   *)

PROCEDURE ModifyCookie (cookie: LONGWORD; newvalue: LONGWORD): BOOLEAN;
  (*
   * Sucht, wie 'GetCookie', den Cookie und liefert FALSE, wenn er nicht
   * vorhanden ist. Wird er gefunden, wird 'newvalue' als neuer Cookie-Wert
   * eingesetzt und die Funktion liefert TRUE.
   *
   * Hiermit werden also keine neuen Cookies eingetragen sondern nur
   * vorhandene modifiziert!
   *)

TYPE CookieProc = PROCEDURE (     (* cookie: *) LONGWORD,
                              VAR (* value : *) LONGWORD ): BOOLEAN;

(*$H+*)
PROCEDURE QueryCookies (with: CookieProc);
  (*
   * Geht die Liste aller Cookies durch und ruft 'with' fÅr jeden vorhandenen
   * Cookie auf. Der Wert wird dabei als VAR-Parameter Åbergeben und kann
   * somit verÑndert werden.
   * Die 'with'-Funktion muû einen BOOLEAN-Wert zurÅckgeben. Ist er FALSE,
   * wird die Query-Funktion abgebrochen, bei TRUE werden weitere Cookies
   * durchgegangen.
   *
   * Wegen des $H+ (s.o.) ist es mîglich, auch lokale Prozeduren an 'with'
   * zu Åbergeben (ist aber nicht portabel!).
   *
   * Das Modul 'ShowCookies' im UTILITY-Ordner zeigt die Anwendung dieser
   * Prozedur.
   *)

CONST

   (*
    * Von Atari vordefinierte Cookies, die den Rechner beschreiben.
    *)
  CPU            = "_CPU"; (* Hauptprozessor: 0, 10, 20, 30 usw. *)
  FPU            = "_FPU"; (* Mathe-Koprozessor: 0,1,2 im 1. Word *)
  Machine        = "_MCH"; (* Rechner; 1. Word: 0=ST, 1=STE, 2=TT *)
  VideoShifter   = "_VDO"; (* Video-Hardware; 1. Word: 0=ST, 1=STE, 2=TT *)
  SoundHardware  = "_SND"; (* Bits im Longword: 0: GI/Yamaha(ST), 1: DMA(TT) *)
  ConfigSwitches = "_SWI"; (* BIOS-interne Konfigurationswerte *)
  FastReadBuffer = "_FRB"; (* Adresse des 64KB-Puffers f. Disk-Treiber im TT *)

END CookieJar.
