
DEFINITION MODULE MathLib0;

(* Erweiterte Definition                      jm 15.4.86, TT 3.10.90

   Die trigonometrischen Funktionen arbeiten im Bogenmass.
   Ueberlauf oder Aufruf mit illegalen Argumenten fuehren zum
   Abbruch des Programms mit entsprechendem Laufzeitfehler.

   Die Funktionen 'lnP1', 'expM1' und 'sincos' sind in Hinblick auf die
   Mathe-Koprozessoren aufgenommen worden. WÑhrend sie ohne Koprozessor
   praktisch keinen Vorteil bieten, wird bei Einsatz einer FPU ein
   Geschwindigkeitsvorteil gegenÅber 'ln(x+1)', 'exp(x-1)' bzw. den
   Einzelaufrufen von 'sin' und 'cos' erlangt.
*)

(*$F+*)

CONST pi = 3.1415926535897932;
CONST e  = 2.7182818284590452;

PROCEDURE ln       (x: LONGREAL): LONGREAL;    (* log_e  (x)   *)
PROCEDURE log      (x: LONGREAL): LONGREAL;    (* log_10 (x)   *)
PROCEDURE ld       (x: LONGREAL): LONGREAL;    (* log_2  (x)   *)
PROCEDURE lnP1     (x: LONGREAL): LONGREAL;    (* log_e  (x+1) *)
PROCEDURE exp      (x: LONGREAL): LONGREAL;    (*  e ^ x     *)
PROCEDURE pwrOfTen (x: LONGREAL): LONGREAL;    (* 10 ^ x     *)
PROCEDURE pwrOfTwo (x: LONGREAL): LONGREAL;    (*  2 ^ x     *)
PROCEDURE expM1    (x: LONGREAL): LONGREAL;    (*  e ^ (x-1) *)

PROCEDURE logar    (b, x: LONGREAL): LONGREAL; (* Logarithmus zur Basis b *)
PROCEDURE power    (b, x: LONGREAL): LONGREAL; (* b ^ x *)

PROCEDURE sin      (x: LONGREAL): LONGREAL;    (* trigonometr. Funktionen, *)
PROCEDURE cos      (x: LONGREAL): LONGREAL;    (* Argumente im Bogenmass   *)
PROCEDURE tan      (x: LONGREAL): LONGREAL;
PROCEDURE arcsin   (x: LONGREAL): LONGREAL;
PROCEDURE arccos   (x: LONGREAL): LONGREAL;
PROCEDURE arctan   (x: LONGREAL): LONGREAL;
PROCEDURE sincos   (x: LONGREAL; VAR sin, cos: LONGREAL); (* beide zugleich *)

PROCEDURE sinh     (x: LONGREAL): LONGREAL;    (* hyberbolische Funktionen *)
PROCEDURE cosh     (x: LONGREAL): LONGREAL;
PROCEDURE tanh     (x: LONGREAL): LONGREAL;
PROCEDURE artanh   (x: LONGREAL): LONGREAL;

PROCEDURE sqrt     (x: LONGREAL): LONGREAL;    (* Wurzel = x ^ (1/2)       *)

PROCEDURE fraction (x: LONGREAL): LONGREAL;    (* Nachkomma-Anteil von x   *)
PROCEDURE int      (x: LONGREAL): LONGREAL;    (* Vorkomma-Anteil von x   *)

PROCEDURE rad      (x: LONGREAL): LONGREAL;    (* x * pi/180 *)
PROCEDURE deg      (x: LONGREAL): LONGREAL;    (* x * 180/pi *)

PROCEDURE real     (x: LONGINT): LONGREAL; (* Umwandlung LONGINT <> LONGREAL  *)
PROCEDURE entier   (x: LONGREAL): LONGINT; (* besser: Verwende INT bzw. FLOAT *)

END MathLib0.
