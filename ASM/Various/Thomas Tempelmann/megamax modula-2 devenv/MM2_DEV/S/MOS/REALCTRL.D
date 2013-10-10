DEFINITION MODULE RealCtrl;

(*
 * Dies Modul dient zur Verwaltung, Unterscheidung und Auswertung
 * der beiden bei Megamax Modula-2 verwendeten Real-Formaten.
 *
 * Beachte:
 *   Das IEEE-Format hat eine grîûere Genauigkeit durch eine grîûere
 *   Mantisse, das Megamax-Format Åberdeckt einen grîûeren Bereich
 *   durch einen grîûeren Exponenten.
 *)

TYPE AnyRealFormat = (MM2Real, IEEEReal, unspecReal);
     RealFormat    = [MM2Real..IEEEReal];

     AnyReal = RECORD
                 value: LONGREAL;
                 format: RealFormat;
               END;

VAR UsedFormat: AnyRealFormat;
  (*
   * Zeigt an, welches Darstellungsformat z.Zt. fÅr Real-Werte
   * verwendet wird. Solange kein Modul resident ist, das Reals
   * benutzt, ist das Format unbestimmt (unspecReal). Ist es
   * einmal bestimmt, weist der Loader Module, die Real-Konstanten
   * im anderen Format enthalten, zurÅck.
   *
   * Keinesfalls darf diese Variable von Anwenderprogrammen, auch nicht
   * kurzzeitig, verÑndert werden!
   *)

PROCEDURE SmallREAL     (format: RealFormat): LONGREAL;
PROCEDURE LargeREAL     (format: RealFormat): LONGREAL;
PROCEDURE SmallLONGREAL (format: RealFormat): LONGREAL;
PROCEDURE LargeLONGREAL (format: RealFormat): LONGREAL;
  (*
   * Liefern (ungefÑhr) grîûte und kleinste positive darstellbare
   * REAL-Werte des angegebenen Formats im selben Format.
   * FÅr das aktuelle Format ist 'UsedFormat' anzugeben.
   *
   * Beispiel:
   *   LargeREAL (IEEEReal) liefert die grîûte REAL-Zahl
   * bei IEEE-Darstellung eben in IEEE-Darstellung.
   *)

CONST InfiniteIEEE = 7FF0000000000000R;
      NullIEEE     = 0R;

PROCEDURE Conv (in: AnyReal; out: RealFormat): LONGREAL;
  (*
   * Der Wert 'in' wird ins Format 'out' gewandelt.
   * FÅr das aktuelle Format ist 'UsedFormat' anzugeben.
   *
   * Beim Wandeln von IEEE nach MM2 gehen u.U. die untersten Bits
   * der Mantisse verloren, sodaû der Wert ungenauer wird.
   * Beim Wandeln von MM2 nach IEEE werden Werte nahe bei Null
   * (Exponent kleiner als -308) zu Null, bei zu groûen Werten
   * wird die IEEE-Zahl "infinity" (positiv bzw. negativ) geliefert,
   * welche durch Vergleich mit der Konstante 'InfiniteIEEE' (s.o.)
   * erkannt werden kann (Vorzeichen beachten!).
   *
   * Beispiel, um einen Wert immer im IEEE-Format zu erhalten:
   *   ieeeZahl:= Conv (AnyReal {realZahl, UsedFormat}, IEEEForm)
   *)

END RealCtrl.
