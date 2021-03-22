MODULE ShowImports;

(*
 * Zeigt die importierten Module eines residenten Moduls an.
 *
 * Beim Start des Programms kann ein Modulname eingegeben werden,
 * daraufhin werden alle Importe angezeigt.
 * Ende des Programms durch eine Leereingabe.
 *)

FROM ModCtrl IMPORT GetProcAddr, QueryImports;

FROM SYSTEM IMPORT ADDRESS;

IMPORT InOut;

VAR shown: BOOLEAN;

PROCEDURE showIt ( REF modName:  ARRAY OF CHAR;
                       modAddr:  ADDRESS;
                       modLen:   LONGCARD;
                       varAddr:  ADDRESS;
                       varLen:   LONGCARD;
                   REF fileName: ARRAY OF CHAR;
                       module:   BOOLEAN;
                       loaded:   BOOLEAN;
                       resident: BOOLEAN );
  BEGIN
    InOut.Write (' ');
    InOut.WriteString (modName);
    shown:= TRUE
  END showIt;

VAR s: ARRAY [0..50] OF CHAR;
    loc: ADDRESS;

BEGIN
  LOOP
    InOut.WriteString ('Modul? ');
    InOut.ReadString (s);
    IF s[0]=0C THEN EXIT END;
    InOut.WriteLn;
    (* Haben wir das Modul Åberhaupt im Speicher? *)
    GetProcAddr (s, loc);
    IF loc # NIL THEN
      InOut.WriteString ('Importe: ');
      shown:= FALSE;
      QueryImports (s, showIt);
      IF NOT shown THEN
        InOut.WriteString ('keine!');
      END
    ELSE
      InOut.WriteString ('Dies Modul ist nicht resident (ggf. vorher laden!)');
    END;
    InOut.WriteLn;
    InOut.WriteLn;
  END
END ShowImports.
