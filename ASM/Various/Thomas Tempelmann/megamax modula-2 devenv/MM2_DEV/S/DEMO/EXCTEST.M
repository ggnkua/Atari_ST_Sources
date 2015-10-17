MODULE ExcTest;

(* Demo-Programm fÅr Modul 'EasyExceptions' *)

IMPORT InOut, EasyExceptions;

MODULE localMod;

(*
 * Dies lokale Modul exportiert eine Funktion 'DoIt', die zwei Zahlen
 * multiplizieren kann.
 * Zwei Fehler kînnen auftreten:
 *  - Das Ergebnis wird grîûer als 65335 - ein öberlauf tritt auf,
 *    der durch 'EasyExceptions.Overflow()' signalisiert wird.
 *  - Der Anwender gibt ungÅltige Werte ein - Die Funktion 'DoIt'
 *    lîst diesen Fehler selbst aus (mittels 'Raise') - der Aufrufer
 *    kann dies mit 'InputFault()' ermitteln (s.u.).
 * Die Kennung fÅr den Laufzeitfehler sollte nach auûen nur Åber eine
 * Funktion zugÑnglich gemacht werden, um zu verhindern, daû sie von
 * auûen verÑndert werden kînnte.
 *)

  IMPORT InOut, EasyExceptions;
  
  EXPORT DoIt,          (* Die Funktion *)
         InputFault;    (* Die Kennung fÅr Eingabefehler *)

  VAR myError: EasyExceptions.Exception;
  
  PROCEDURE InputFault (): EasyExceptions.Exception;
    BEGIN
      RETURN myError
    END InputFault;

  PROCEDURE DoIt;
    VAR c1, c2: CARDINAL;
    BEGIN
      InOut.WriteLn;
      InOut.WriteString ('Multiplikation zweier CARDINAL-Zahlen');
      InOut.WriteLn;
      InOut.WriteString (' Erste Zahl? ');
      InOut.ReadCard (c1);
      IF NOT InOut.Done THEN
        (* Fehler signalisieren und zum Aufrufer von 'Call' zurÅckkehren *)
        EasyExceptions.Raise (InputFault ())
      END;
      InOut.WriteString (' Zweite Zahl? ');
      InOut.ReadCard (c2);
      IF NOT InOut.Done THEN
        EasyExceptions.Raise (InputFault ())
      END;
      InOut.WriteLn;
      InOut.WriteString ('Ergebnis: ');
      InOut.WriteCard (c1 * c2, 0); (* Hier kann ein öberlauf auftreten *)
      InOut.WriteLn
    END DoIt;

  BEGIN
    (* Die Kennung muû zuerst einmal erzeugt werden *)
    EasyExceptions.New (myError)
  END localMod;

VAR result: EasyExceptions.Exception;

PROCEDURE Report (text: ARRAY OF CHAR);
  VAR ch: CHAR;
  BEGIN
    InOut.WriteLn;
    InOut.WriteString (text);
    InOut.WriteString ('   Taste...');
    InOut.Read (ch);
    InOut.WriteLn;
  END Report;

PROCEDURE Abort (): BOOLEAN;
  VAR ch: CHAR;
  BEGIN
    InOut.WriteLn;
    InOut.WriteString ('Nochmal (J/N)? ');
    InOut.Read (ch);
    InOut.WriteLn;
    RETURN CAP (ch) = 'N'
  END Abort;

BEGIN
  REPEAT
    EasyExceptions.Call (DoIt, result);
    IF result = EasyExceptions.NormalReturn () THEN
      Report ('Kein Fehler.')
    ELSIF result = EasyExceptions.Overflow () THEN
      Report ('öberlauf!')
    ELSIF result = InputFault () THEN
      Report ('Eingabefehler!')
    ELSE
      (* Unerkannte / unerwartetet Fehler weiterreichen *)
      (* -- Kann ausprobiert werden, indem einer *)
      (*    der oberen FÑlle eingeklammert wird. *)
      EasyExceptions.Raise (result)
    END;
  UNTIL Abort ()
END ExcTest.
