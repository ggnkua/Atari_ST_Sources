(* Unit, welches eine Textausgabedatei als Objekt implementiert *)

UNIT Demo5FUnit;

{$I-} (* Kein Laufzeitfehler bei Zugriffsfehler *)

INTERFACE

(* Deklaration des Objektes TTextoutfile *)

TYPE	PTextoutfile=^TTextoutfile;
		TTextoutfile=OBJECT
			CONSTRUCTOR Init(Pathname:STRING);
			DESTRUCTOR Done;
			PROCEDURE WriteLine(Text:STRING);
			FUNCTION Error:WORD;
		PRIVATE
			OutFile:TEXT; (* Damit kein direkter Zugriff m”glich *)
			END;

IMPLEMENTATION

(* Implementation der Methoden von TTextoutfile *)

CONSTRUCTOR TTextoutfile.Init(Pathname:STRING);
BEGIN
ASSIGN(OutFile,Pathname);
IF IOResult=0 THEN
	REWRITE(OutFile);
END;

DESTRUCTOR TTextoutfile.Done;
BEGIN
CLOSE(OutFile)
END;

PROCEDURE TTextoutfile.WriteLine(Text:STRING);
BEGIN
WRITELN(OutFile,Text);
END;

FUNCTION TTextoutfile.Error:WORD;
BEGIN
Error:=IOResult
END;

END.
