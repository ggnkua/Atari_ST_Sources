MODULE LongSupport;

(*****************************************************************************)
(* 15-Okt-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

IMPORT Low:=LowLong;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE min* ((* EIN/ -- *) x : LONGREAL;
                (* EIN/ -- *) y : LONGREAL ): LONGREAL;

(* Es wird das kleinere der beiden Argumente geliefert. *)

BEGIN
 IF x < y THEN
   RETURN(x);
 ELSE
   RETURN(y);
 END;
END min;

(*---------------------------------------------------------------------------*)

PROCEDURE max* ((* EIN/ -- *) x : LONGREAL;
                (* EIN/ -- *) y : LONGREAL ): LONGREAL;

(* Es wird das groessere der beiden Argumente geliefert. *)

BEGIN
 IF x > y THEN
   RETURN(x);
 ELSE
   RETURN(y);
 END;
END max;

(*---------------------------------------------------------------------------*)

PROCEDURE clip* ((* EIN/ -- *) x     : LONGREAL;
                 (* EIN/ -- *) lower : LONGREAL;
                 (* EIN/ -- *) upper : LONGREAL ): LONGREAL;

(* Falls <x> kleiner als <lower> ist, wird <lower> zurueckgeliefert; falls
   <x> groesser als <upper> ist, wird <upper> zurueckgeliefert, sonst <x>.
   Ist <lower> groesser als <upper>, wird <lower> ignoriert, und der
   kleinere Wert von <x> und <upper> zurueckgeliefert.
 *)

BEGIN
 IF (lower <= upper) & (x <= lower) THEN
   RETURN(lower);
 ELSIF x >= upper THEN
   RETURN(upper);
 ELSE
   RETURN(x);
 END;
END clip;

(*---------------------------------------------------------------------------*)

PROCEDURE frexp* ((* EIN/ -- *)     real : LONGREAL;
                  (* -- /AUS *) VAR exp  : INTEGER ): LONGREAL;

(* Spaltet <real> in die Mantisse 'mant', die als Funktionswert geliefert
   wird, und den Exponenten <exp> auf; es gilt:

           real = mant * 2^exp  , mit  0.5 <= |mant| < 1.0.

   Ist <real> = 0.0, wird <exp> = 0 und 'mant' = 0.0 geliefert.
 *)

BEGIN
 exp := Low.exponent(real) + 1;
 RETURN(Low.scale(Low.fraction(real), -1));
END frexp;

(*---------------------------------------------------------------------------*)

PROCEDURE ldexp* ((* EIN/ -- *) mant : LONGREAL;
                  (* EIN/ -- *) exp  : INTEGER ): LONGREAL;

(* <mant> und <exp> werden zu einer LONGREAL-Zahl 'real' zusammengesetzt, die
   als Funktionswert geliefert wird; es gilt:

           real = mant * 2^exp.

   Da <mant> nicht notwendigerweise zwischen 0.5 und 1.0 liegen muss,
   sondern eine beliebige LONGREAL-Zahl sein kann, laesst sich die Funktion
   dazu verwenden, LONGREAL-Zahlen mit Zweierpotenzen zu multiplizieren
   (exp > 0) oder auch zu dividieren (exp < 0).

   Es gilt:       x := frexp(real, exp);
                  real = ldexp(x, exp).

   Ist <mant> = 0.0, wird Null zurueckgegeben.

   Je nach Implementierung der Gleitkommaarithmetik ist diese Prozedur
   erheblich schneller als die Multiplikation/Division mit Zweierpotenzen.
 *)

BEGIN
 RETURN(Low.scale(mant, exp));
END ldexp;

(*---------------------------------------------------------------------------*)

PROCEDURE modf* ((* EIN/ -- *)     real : LONGREAL;
                 (* -- /AUS *) VAR int  : LONGREAL ): LONGREAL;

(* Spaltet <real> in den ganzzahligen Anteil <int> und den gebrochenen
   Anteil 'fract' auf, der als Funktionswert geliefert wird. Beide haben
   das Vorzeichen von <real>, so dass gilt:

                   real = int + fract.
 *)

BEGIN
 int := Low.intpart(real);
 RETURN(Low.fractpart(real));
END modf;

(*---------------------------------------------------------------------------*)

PROCEDURE fmod* ((* EIN/ -- *) real : LONGREAL;
                 (* EIN/ -- *) div  : LONGREAL ): LONGREAL;

(* MODULO-Funktion fuer reelle Zahlen. Das Ergebnis hat das Vorzeichen von
   <real>.

   Bei <div> = 0.0 wird 0.0 zurueckgeliefert.
 *)

BEGIN
 IF div = 0.0D0 THEN
   RETURN(0.0D0);
 ELSE
   RETURN(real - div * Low.intpart(real / div));
(*
   Folgendes waere auch moeglich, liefert aber eine geringere
   Genauigkeit:

     RETURN(div * fractpart(real / div));

   Erklaerung (hoffentlich richtig...):

   Wegen der endlichen Stellenzahl ist das Ergebnis der Division
   real / div in den meisten Faellen nicht mathematisch exakt.
   Das Ergebnis laesst sich in die Vorkommastellen und die Nachkommastellen
   unterteilen. Haelt sich die absolute Groesse des Werts in Grenzen, koennen
   alle Vorkommastellen repraesentiert werden, d.h das Ergebnis
   von intpart(real / div) ist mathematisch exakt, solange der Exponent
   eine bestimmte Groesse nicht ueberschreitet; das Ergebnis von
   fractpart(real / div) jedoch, also die Nachkommastellen, ist i.allg.
   nicht exakt, wenn nicht das Ergebnis mit der gegebenen Stellenzahl
   repraesentiert werden kann. Hinzu kommt noch, dass die Genauigkeit
   einer Zahl durch fractpart() abnimmt, da ja nur die Bits der Nachkomma-
   stellen benutzt werden koennen, um einen kompletten Realwert darzustellen,
   waehrend der unbekannte Rest mit Nullen aufgefuellt wird.
   Bei intpart werden zwar fuer das Ergebnis auch nur die Vorkommabits
   verwendet, aber da die Nachkommastellen sowieso gleich Null sind,
   entsteht ein Ergebnis mit voller Genauigkeit. Da folgendes gilt:

     fractpart(x) = x - intpart(x),

   erkennt man auch die durch die Subtraktion moegliche Stellenausloeschung
   bei fractpart, wenn x ungefaehr ganzzahlig ist (nur wenige Nachkommabits).

   D.h. also bei: div * intpart(real / div) geht keine Genauigkeit
   verloren, waehrend: div * fractpart(real / div) durch
   fractpart und die damit verbundene Stellenausloeschung und die
   nicht exakten Nachkommastellen an Genauigkeit verliert.

   Bei:

     real - div * intpart(real / div);

   kann es durch die Subtraktion natuerlich auch zu einer Stellenausloeschung
   kommen, wenn der Rest sehr klein ist, also div ein mehr oder weniger
   ganzzahliges Vielfache von real ist, aber in diesem Fall ist auch die
   andere Variante nicht besser, denn durch die Division von real und div
   entsteht dann ein Wert, der wiederum fast ganzzahlig ist, wodurch
   bei fractpart ja wieder eine Stellenausloeschung entsteht:

   Beispiele:

   o fmod(3.5, 1.5):

     1. Variante:

       3.5 / 1.5 = 2.3333...x  ist nicht exakt repraesentierbar
       damit ist auch
       fractpart(3.5 / 1.5) = 0.3333...x nicht exakt repraesentierbar
       und
       1.5 * 0.3333...x = 0.500...y  nicht genau

     2. Variante:

       intpart(3.5 / 1.5) = 2.0  ist exakt darstellbar
       damit ist auch
       1.5 * 2.0 = 3.0  exakt darstellbar
       und ebenfalls
       3.5 - 3.0 = 0.5

   o fmod(3.001, 1.5):

     1. Variante:

       3.001 / 1,5 = 2.0006666...x  nicht exakt darstellbar
       zusaetzlich Stellenausloeschung bei
       fractpart(3.001 / 1.5) = 0.0006666...x
       Ergebnis
       1.5 * 0.0006666...x = 0.001000...y  nicht genau

     2. Variante:

       Exaktes Ergebnis bei
       intpart(3.001 / 1.5) = 2.0
       und
       1.5 * 2.0 = 3.0
       aber Stellenausloeschung bei
       3.001 - 3.0 = 0.001
*)
 END;
END fmod;

(*---------------------------------------------------------------------------*)

PROCEDURE floor* ((* EIN/ -- *) real : LONGREAL ): LONGREAL;

(* Liefert den groessten ganzzahligen (LONGREAL)Wert, der NICHT GROESSER als
   <real> ist. Bei negativen Zahlen wird also auf die naechstkleinere
   ganze Zahl abgerundet, bei positiven Zahlen werden nur die
   Nachkommastellen abgeschnitten.
   Entspricht Rundung gegen Minus Unendlich.

   Beispiele:

     floor(-1.5) = -2.0   ,   floor(1.5) = 1.0
     floor(-1.0) = -1.0   ,   floor(1.0) = 1.0
 *)

BEGIN
 IF Low.fractpart(real) >= 0.0D0 THEN
   RETURN(Low.intpart(real));
 ELSE
   RETURN(Low.intpart(real) - 1.0D0);
 END;
END floor;

(*---------------------------------------------------------------------------*)

PROCEDURE ceil* ((* EIN/ -- *) real : LONGREAL ): LONGREAL;

(* Liefert den kleinsten ganzzahligen (LONGREAL)Wert, der NICHT KLEINER als
   <real> ist. Bei negativen Zahlen werden also nur die Nachkommastellen
   abgeschnitten, bei positiven Zahlen wird auf die naechstgroessere ganze
   Zahl aufgerundet.
   Entspricht Rundung gegen Plus Unendlich.

   Beispiele:

     ceil(-1.5) = -1.0    ,   ceil(1.5) = 2.0
     ceil(-1.0) = -1.0    ,   ceil(1.0) = 1.0
 *)

BEGIN
 IF Low.fractpart(real) > 0.0D0 THEN
   RETURN(Low.intpart(real) + 1.0D0);
 ELSE
   RETURN(Low.intpart(real));
 END;
END ceil;

END LongSupport.
