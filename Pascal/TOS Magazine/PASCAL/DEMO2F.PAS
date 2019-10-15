(* Demoprogramm fÅr Mengen unter Pure Pascal *)

PROGRAM Mengendemo;

TYPE 	TAutos = (Fiat,BMW,Porsche,VW);
		TAutomenge = SET OF TAutos;

VAR autos,autos2,autos3:TAutomenge;

PROCEDURE DruckMenge(name:STRING; menge:TAutomenge);
BEGIN
WRITELN('Menge: ',name);
WRITELN;
IF Fiat IN menge THEN WRITELN('Fiat');
IF BMW IN menge THEN WRITELN('BMW');
IF Porsche IN menge THEN WRITELN('Porsche');
IF VW IN menge THEN WRITELN('VW');
WRITELN;
END;


BEGIN
autos2:=[ Fiat , BMW ];
DruckMenge('Autos2',autos2);
autos3:=[BMW,Porsche,VW];
DruckMenge('Autos3',autos3);
autos:=autos2+autos3; (* Vereinigungsmenge *)
DruckMenge('Autos2 + Autos3',autos);
autos:=autos2-autos3; (* Ergibt: [Fiat] *)
DruckMenge('Autos2 - Autos3',autos);
autos:=autos2*autos3; (* Ergibt: [BMW] *)
DruckMenge('Autos2 * Autos3',autos);
END.