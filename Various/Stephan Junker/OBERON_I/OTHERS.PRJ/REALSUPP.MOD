MODULE RealSupport;

(*****************************************************************************)
(* 15-Okt-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

IMPORT Low:=LowReal;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE min* ((* EIN/ -- *) x : REAL;
                (* EIN/ -- *) y : REAL ): REAL;

(* Es wird das kleinere der beiden Argumente geliefert. *)

BEGIN
 IF x < y THEN
   RETURN(x);
 ELSE
   RETURN(y);
 END;
END min;

(*---------------------------------------------------------------------------*)

PROCEDURE max* ((* EIN/ -- *) x : REAL;
                (* EIN/ -- *) y : REAL ): REAL;

(* Es wird das groessere der beiden Argumente geliefert. *)

BEGIN
 IF x > y THEN
   RETURN(x);
 ELSE
   RETURN(y);
 END;
END max;

(*---------------------------------------------------------------------------*)

PROCEDURE clip* ((* EIN/ -- *) x     : REAL;
                 (* EIN/ -- *) lower : REAL;
                 (* EIN/ -- *) upper : REAL ): REAL;

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

PROCEDURE frexp* ((* EIN/ -- *)     real : REAL;
                  (* -- /AUS *) VAR exp  : INTEGER ): REAL;

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

PROCEDURE ldexp* ((* EIN/ -- *) mant : REAL;
                  (* EIN/ -- *) exp  : INTEGER ): REAL;

(* <mant> und <exp> werden zu einer REAL-Zahl 'real' zusammengesetzt, die
   als Funktionswert geliefert wird; es gilt:

           real = mant * 2^exp.

   Da <mant> nicht notwendigerweise zwischen 0.5 und 1.0 liegen muss,
   sondern eine beliebige REAL-Zahl sein kann, laesst sich die Funktion
   dazu verwenden, REAL-Zahlen mit Zweierpotenzen zu multiplizieren
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

PROCEDURE modf* ((* EIN/ -- *)     real : REAL;
                 (* -- /AUS *) VAR int  : REAL ): REAL;

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

PROCEDURE fmod* ((* EIN/ -- *) real : REAL;
                 (* EIN/ -- *) div  : REAL ): REAL;

(* MODULO-Funktion fuer reelle Zahlen. Das Ergebnis hat das Vorzeichen von
   <real>.

   Bei <div> = 0.0 wird 0.0 zurueckgeliefert.
 *)

BEGIN
 IF div = 0.0 THEN
   RETURN(0.0);
 ELSE
   (* Erklaerung in 'LongSupport' *)
   RETURN(real - div * Low.intpart(real / div));
 END;
END fmod;

(*---------------------------------------------------------------------------*)

PROCEDURE floor* ((* EIN/ -- *) real : REAL ): REAL;

(* Liefert den groessten ganzzahligen (REAL)Wert, der NICHT GROESSER als
   <real> ist. Bei negativen Zahlen wird also auf die naechstkleinere
   ganze Zahl abgerundet, bei positiven Zahlen werden nur die
   Nachkommastellen abgeschnitten.
   Entspricht Rundung gegen Minus Unendlich.

   Beispiele:

     floor(-1.5) = -2.0   ,   floor(1.5) = 1.0
     floor(-1.0) = -1.0   ,   floor(1.0) = 1.0
 *)

BEGIN
 IF Low.fractpart(real) >= 0.0 THEN
   RETURN(Low.intpart(real));
 ELSE
   RETURN(Low.intpart(real) - 1.0);
 END;
END floor;

(*---------------------------------------------------------------------------*)

PROCEDURE ceil* ((* EIN/ -- *) real : REAL ): REAL;

(* Liefert den kleinsten ganzzahligen (REAL)Wert, der NICHT KLEINER als
   <real> ist. Bei negativen Zahlen werden also nur die Nachkommastellen
   abgeschnitten, bei positiven Zahlen wird auf die naechstgroessere ganze
   Zahl aufgerundet.
   Entspricht Rundung gegen Plus Unendlich.

   Beispiele:

     ceil(-1.5) = -1.0    ,   ceil(1.5) = 2.0
     ceil(-1.0) = -1.0    ,   ceil(1.0) = 1.0
 *)

BEGIN
 IF Low.fractpart(real) > 0.0 THEN
   RETURN(Low.intpart(real) + 1.0);
 ELSE
   RETURN(Low.intpart(real));
 END;
END ceil;

END RealSupport.
