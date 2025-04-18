(*************************************************************************
  Desktoprechner	Copyright (c) 1992 by Application Systems Heidelberg.
  ==============	Alle Rechte vorbehalten.

  Autor:				Dietmar Rabich
  Unit:					HANDLER.PAS
  Entwicklungssystem:	PurePascal

  Der Handler �bernimmt alle Eingabeauswertung (bis auf die Information).

*************************************************************************)

UNIT Handler;


(* Die Schnittstelle zu den anderen Moduln *)
INTERFACE


(* Konstanten *)
CONST	(* G�ltige Tasten *)
		KeyEnter		=	CHR(13);
		KeyClear		=	'(';
		KeyChangeSign	=	'.';
		Key0			=	'0';
		Key1			=	'1';
		Key2			=	'2';
		Key3			=	'3';
		Key4			=	'4';
		Key5			=	'5';
		Key6			=	'6';
		Key7			=	'7';
		Key8			=	'8';
		Key9			=	'9';
		KeyFirstNumber	=	Key0;
		KeyLastNumber	=	Key9;
		KeyMemory		=	'm';
		KeyReMemory		=	'r';
		KeyClearMemory	=	'c';
		KeySwitchMemory	=	's';
		KeyAdd			=	'+';
		KeyMul			=	'*';
		KeySub			=	'-';
		KeyDiv			=	'/';


(* Typen *)
TYPE	(* Fehlertypen *)
		ErrorType	=	(NoError, Overflow, DivisionBy0);

		(* Objekt Rechner *)
		Calculator	=	OBJECT

							(* Variablen f�r Speicher,
								gegenw�rtige Zahl und
								aktuelle Zahl im Speicher *)
							Memory,
							Current,
							Buffer		:	LONGINT;

							(* letzte Taste und letzte Operation *)
							LastKey,
							LastOp		:	CHAR;

							(* g�ltige Tasten *)
							KeyValid,
							KeyOper		:	SET OF CHAR;

							(* (letzter) Fehler *)
							Error		:	ErrorType;

							(* Konstruktor *)
							CONSTRUCTOR Init;

							(* Eingabe *)
							FUNCTION Input(c : CHAR) : BOOLEAN;

							(* Ergebnis *)
							FUNCTION Result : LONGINT;

							(* Abfrage auf Speicher *)
							FUNCTION MemoryEmpty	: BOOLEAN;

							(* Abfrage des Fehlers *)
							FUNCTION IsError : ErrorType;
						END;


(* Implementierung *)
IMPLEMENTATION


(* Funktion, die die Anzahl der Ziffern z�hlt *)
FUNCTION Numbers(x : LONGINT) : INTEGER;

(* Variablen *)
VAR	LNumbers	:	INTEGER;

BEGIN

	(* Ist die Zahl 0? Dann nehmen wir keine Ziffer an! *)
	IF x = 0 THEN
		Numbers	:=	0
	ELSE
	BEGIN

		(* Anzahl der Ziffern erst einmal 0 *)
		LNumbers	:=	0;

		(* Schleife durchf�hren, bis Zahl 0 ist *)
		WHILE x <> 0 DO
		BEGIN

			(* noch eine Ziffer! *)
			INC(LNumbers);

			(* n�chste Ziffer *)
			x	:=	x DIV 10

		END;

		(* Anzahl der Ziffern *)
		Numbers	:=	LNumbers
	END
END;


(* Konstruktor zum Initialisieren *)
CONSTRUCTOR Calculator.Init;
BEGIN

	(* Menge der g�ltigen Tasten *)
	KeyValid	:=	[KeyFirstNumber..KeyLastNumber, KeyEnter, KeyClear,
					 KeyChangeSign, KeyMemory, KeyReMemory, KeyClearMemory,
					 KeySwitchMemory, KeyAdd, KeySub, KeyMul, KeyDiv];

	(* Menge der g�ltigen Operationen *)
	KeyOper		:=	[KeyAdd, KeySub, KeyMul, KeyDiv];

	(* Alle Speicher l�schen *)
	Current		:=	0;
	Memory		:=	0;
	Buffer		:=	0;

	(* letzte Operation vorerst 0 *)
	LastOp		:=	CHR(0)

END;


(* Eingabeauswertung *)
FUNCTION Calculator.Input(c : CHAR) : BOOLEAN;

(* Variablen *)
VAR	Temp	:	LONGINT;
	TempR	:	REAL;

BEGIN

	(* Erst einmal annehmen, da� kein Fehler auftritt *)
	Error	:=	NoError;

	(* Eingabe wird als wahr angenommen *)
	Input	:=	TRUE;

	(* Falls keine g�ltige Taste, nichts machen und Fehler melden *)
	IF NOT(c IN KeyValid) THEN
	BEGIN
		Input	:=	FALSE;
		EXIT
	END;

	(* Auswertung der Taste *)
	CASE c OF

		(* Zifferntaste? *)
		KeyFirstNumber..KeyLastNumber	:

			(* Kein Platz mehr? *)
			IF Current > 1E7 THEN
				Error	:=	Overflow
			ELSE
				Current	:=	Current * 10 + ORD(c) - ORD(KeyFirstNumber);

		(* Vorzeichenwechsel? *)
		KeyChangeSign	:
			Current	:=	Current * -1;

		(* L�schen? *)
		KeyClear		:
			IF LastKey = KeyClear THEN
				Current	:=	0
			ELSE
				Current	:=	Current DIV 10;

		(* aktuellen Wert speichern? *)
		KeyMemory		:
			Memory	:=	Current;

		(* Wert aus dem Speicher holen? *)
		KeyReMemory		:
			Current	:=	Memory;

		(* Speicher l�schen? *)
		KeyClearMemory	:
			Memory	:=	0;

		(* aktuellen Wert mit Speicher tauschen? *)
		KeySwitchMemory	:
			BEGIN
				Temp	:=	Memory;
				Memory	:=	Current;
				Current	:=	Temp
			END;

		(* Operation oder '='? *)
		KeyEnter,
		KeyAdd, KeySub, KeyDiv, KeyMul:
			BEGIN

				(* Ausf�hrung von letzter Operation abh�ngig! *)
				CASE LastOp OF

					(* Addieren? *)
					KeyAdd	:

						(* Kein Platz mehr? *)
						IF (Buffer + Current >= 1E8) OR
							(Buffer + Current <= -1E8) THEN
							Error	:=	OverFlow
						ELSE

							(* Addition *)
							Buffer	:=	Buffer + Current;

					(* Subtrahieren? *)
					KeySub	:

						(* Kein Platz mehr? *)
						IF (Buffer + Current >= 1E8) OR
							(Buffer + Current <= -1E8) THEN
							Error	:=	OverFlow
						ELSE

							(* Subtraktion *)
							Buffer	:=	Buffer - Current;

					(* Multiplizieren? *)
					KeyMul	:

						(* L��t die Ziffernanzahl Multiplikation zu? *)
						IF Numbers(Buffer) + Numbers(Current) <= 8 THEN

							(* Multiplikation *)
							Buffer	:=	Buffer * Current

						ELSE
							Error	:=	OverFlow;

					(* Dividieren? *)
					KeyDiv	:

						(* Soll durch 0 geteilt werden? *)
						IF Current = 0 THEN
							Error	:=	DivisionBy0
						ELSE

							(* Division *)
							Buffer	:=	Buffer DIV Current;

					(* sonst Speicher �bertragen! *)
					ELSE
						Buffer	:=	Current
				END;

				(* Gleichheitszeichen gedr�ckt? *)
				(* Sonst Puffer l�schen! *)
				IF c = KeyEnter THEN
					Current	:=	Buffer
				ELSE
					Current	:=	0;

				(* letzte Operation merken *)
				LastOp	:=	c
			END
	END;

	(* letzte Taste merken *)
	LastKey	:=	c

END;


(* Ergebnis zur�ckgeben *)
FUNCTION Calculator.Result : LONGINT;
BEGIN

	(* letzte Taste Operation? *)
	(* Dann Puffer zur�ckgeben, sonst aktuelle Zahl. *)
	IF LastKey IN KeyOper THEN
		Result	:=	Buffer
	ELSE
		Result	:=	Current
END;


(* Fehler�berpr�fung *)
FUNCTION Calculator.IsError : ErrorType;
BEGIN
	IsError	:=	Error
END;


(* �berpr�fung, ob Speicher leer ist *)
FUNCTION Calculator.MemoryEmpty : BOOLEAN;
BEGIN
	IF Memory = 0 THEN
		MemoryEmpty	:=	TRUE
	ELSE
		MemoryEmpty	:=	FALSE
END;

END.