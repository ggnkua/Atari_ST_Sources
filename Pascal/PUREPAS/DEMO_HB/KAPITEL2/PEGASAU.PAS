PROGRAM pegasau;

(* Gegeben sind drei TÅren. Hinter zwei TÅren befinden sich zwei
	Ziegen, hinter einer TÅr ein Auto. Man wÑhlt eine TÅr. Danach wird 
	eine TÅr geîffnet (die man natÅrlich nicht gewÑhlt hat), hinter 
	der eine Ziege ist. Danach wir behauptet, daû die Wahrscheinlichkeit,
	daû man das Auto findet, sich verdoppelt, wenn man sich umentscheidet, 
	also die andere geschlossene TÅr wÑhlt.
	Das Programm erechnet die Wahrscheinlichkeit dafÅr.
	Bleibt man bei seiner Wahl, ist die Wahrscheinlichkeit natÅrlich 1/3 *)

	CONST	nummer=3;
			anzahl=100000;
			
	VAR k, j, wahl1, wahl2, offen : INTEGER;
		tuer : ARRAY[1..3] OF INTEGER;
		verh : REAL;
		counter, richtig : longint;

BEGIN
	clrscr;
	WRITELN('Moment bitte, ich rechne...');
	WRITELN;
	offen:=0;
	wahl2:=0;
	richtig:=0;
	FOR counter:=1 TO anzahl DO
	BEGIN
		FOR j:=1 TO 3 DO tuer[j]:=0; 	(* Inhalt der TÅren wird gelîscht *)
		j:=RANDOM(nummer)+1; 			(* Zufallszahl fÅr TÅr *)
		tuer[j]:=1;     					(* hinter der das Auto versteckt ist *)
		wahl1:=RANDOM(nummer)+1; 		(* Erste Wahl *)
		FOR k:=1 TO 3 DO
		BEGIN
			IF (k<>j) AND (k<>wahl1) THEN 
				offen:=k; 					(* Jetzt wird ein TÅr geîffnet, *)
		END;									(* die nicht gewÑhlt wurde und hinter *)
												(* der das Auto nicht ist. *)

		FOR k:=1 TO 3 DO
		BEGIN
			IF (k<>wahl1) AND (k<>offen) THEN
				wahl2:=k; 	(* Jetzt wird umentschieden auf die andere TÅr *)
		END;					(* die noch zu ist. *)

		IF wahl2=j THEN 	(* Auto gefunden *)
			richtig:=richtig+1;
	END;
	verh:=richtig /anzahl;
	WRITE('Wahrscheinlichkeit fÅr Treffer nach Umentscheiden ist :');
	WRITELN(verh:2:8);
	WRITELN('DrÅcke Taste...');
	REPEAT UNTIL KEYPRESSED;
END.