(* Koorigiertes Demo fÅr virtuelle Methoden *)

PROGRAM Demo5E;

(* Deklaration der Objekte TVektor, TVektor2D und TVektor3D *)

TYPE	TVektor=OBJECT	(* "Abstraktes" Objekt *)
			CONSTRUCTOR Init;
			FUNCTION Betrag:REAL; VIRTUAL;
			END;

		TVektor2D=OBJECT(TVektor)
			vx,vy:REAL;
			CONSTRUCTOR Init(x,y:REAL);
			FUNCTION Betrag:REAL; VIRTUAL;
			END;
			
		TVektor3D=OBJECT(TVektor)
			vx,vy,vz:REAL;
			CONSTRUCTOR Init(x,y,z:REAL);
			FUNCTION Betrag:REAL; VIRTUAL;
			END;

(* Implementation der Methoden von TVektor *)

CONSTRUCTOR TVektor.Init;
BEGIN
END;

FUNCTION TVektor.Betrag:REAL;
BEGIN
END;

(* Implementation der Methoden von TVektor2D *)

CONSTRUCTOR TVektor2D.Init(x,y:REAL);
BEGIN
vx:=x;
vy:=y
END;

FUNCTION TVektor2D.Betrag:REAL;
BEGIN
Betrag:=SQRT(vx*vx+vy*vy)
END;

(* Implementation der Methoden von TVektor3D *)

CONSTRUCTOR TVektor3D.Init(x,y,z:REAL);
BEGIN
vx:=x;
vy:=y;
vz:=z
END;

FUNCTION TVektor3D.Betrag:REAL;
BEGIN
Betrag:=SQRT(vx*vx+vy*vy+vz*vz)
END;

(* Weitere selbststÑndige Prozeduren und Funktionen *)

FUNCTION Betragskehrwert(VAR Vektor:TVektor):REAL;
BEGIN
Betragskehrwert:=1/Vektor.Betrag
END;

(* Hauptprogramm *)

VAR Zeiger:TVektor3D;

BEGIN
Zeiger.Init(1,4,6);
WRITELN('Betrag   = ',Zeiger.Betrag:7:3);
WRITELN('1/Betrag = ',Betragskehrwert(Zeiger):7:3);
END.
