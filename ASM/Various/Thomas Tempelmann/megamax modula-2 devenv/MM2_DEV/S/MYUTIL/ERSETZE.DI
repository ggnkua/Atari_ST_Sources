PROCEDURE Ersetze (oldName, wildcard: ARRAY OF CHAR; VAR new: ARRAY OF CHAR);
(*
 * Bildet aus wildcard und oldName einen neuen Dateinamen (new).
 * oldName sollte keine Joker enthalten!  
 * new sollte mindestens ARRAY [0..11] OF CHAR sein.
 * Beispiele:
 *
 *      oldName       |  wildcard    |  new
 *     ---------------+--------------+----------------
 *      ALFONS.TXT    |  E*.MOD      |  ELFONS.MOD
 *      ALFONS.TXT    |  HANS.DOC    |  HANS.DOC
 *      ALFONS.TXT    |  HANS*.DOC   |  HANSNS.DOC
 *      EDITOR.MOD    |  *.I         |  EDITOR.I  
 *      EDITSHEL.MOD  |  ??Y?.I??    |  EDYT.IOD
 *      EDITSHEL.MOD  |  ??Y*.I      |  EDYTSHEL.IOD
 *
 * Es werden also Dateinamen ggf. gekÅrzt oder verlÑngert!
 *)

CONST cMaxLen =  11;
      cPrefLen =  8;

 PROCEDURE MachMaske(wild: ARRAY OF CHAR; VAR maske: ARRAY OF CHAR);
 (*
  * Expandiert einen Dateinamen auf 12 Zeichen, ? und * werden als ?
  * eingetragen. Nichtvorhandene Zeichen werden Blanks!
  * maske sollte mindestens ein ARRAY [0..11] OF CHAR sein!
  *)
  VAR c:   CARDINAL;  (* IndexzÑhler in der neuen Maske *)
      d:   CARDINAL;  (* IndexzÑhler in der Wildcard *)
      i:   CARDINAL;  (* Allgemeiner ZÑhler *)

 BEGIN (* MachMaske *)
  c:= 0;  d:= 0;
  maske:= "????????????"; (* Vorgefertigte Maske *)
  LOOP 
   IF (wild[d] = CHR(0)) OR (d = HIGH(wild)) THEN
    (* Wildcard zu Ende, Rest der Maske mit Blanks auffÅllen *)
    FOR i:= c TO cMaxLen DO maske[i]:= " "; END;
    RETURN;
   ELSIF (wild[d] = "*") THEN
    (* Auf einen * muû ein Punkt in der Wildcard folgen! *E*.MOD ist illegal! *)
    INC(d, 2); (* Punkt auslassen *)
    EXIT; (* Fertig mit Prefix-Teil *)
   ELSIF (wild[d] = ".") THEN
    (* Punkt gefunden, Prefix bis zur Maximalen LÑnge mit Blanks auffÅllen *)
    FOR i:= c TO cPrefLen DO  maske[i]:= " ";  END; 
    INC(d);
    EXIT; (* Fertig mit Prefix-Teil *)
   ELSE (* Zeichen aus wild nach maske Åbertragen *)
    maske[c]:= wild[d];  INC(c);  INC(d);
   END;
  END;
  c:= cPrefLen + 1; (* Index von maske auf "nach dem Punkt" einstellen *)
  LOOP
   IF (wild[d] = CHR(0)) OR (d = HIGH(wild)) THEN
    (* Wildcard zu Ende, Rest der Maske mit Blanks auffÅllen *)
    FOR i:= c TO cMaxLen DO maske[i]:= " "; END;
    RETURN;
   END;
   IF (c > cMaxLen) OR (wild[d]="*") THEN 
    EXIT (* wild fertig, bzw. maske voll *)
   END;
   (* Zeichen aus wild nach maske Åbertragen *)
   maske[c]:= wild[d]; INC(c); INC(d); 
  END;
 END MachMaske;


VAR c, d: CARDINAL;
    wild, maske: einDateiName; (* ARRAY [0..11] OF CHAR *)

BEGIN (* Ersetze *)
 MachMaske(wildcard, wild); (* Masken erstellen *)
 MachMaske(oldName, maske);
 
 (* Alle legalen Zeichen aus wild nach maske Åbertragen (auch Blanks!) *)
 FOR c:= 0 TO cMaxLen DO
  IF wild[c] <> "?" THEN maske[c]:= wild[c] END;
 END;

 (* new zur Sicherheit lîschen *)
 FOR c:= 0 TO cMaxLen DO new[c]:= CHR(0);  END;

 c:= 0;  d:= 0;
 LOOP
  IF (d > cMaxLen) THEN EXIT END; (* Neuer Name fertig *)
  IF d = cPrefLen THEN (* Punktposition, Punkt in new einsetzen *)
   new[c]:= ".";  INC(c);  INC(d); 
  END;
  IF (maske[d] <> "?") AND (maske[d] <> " ") THEN  
   (* Blanks und ? aussparen, haben nix im neuen Namen zu suchen! *)
   new[c]:= maske[d];  INC(c); INC(d);
  ELSE
   INC(d);
  END;
 END;

END Ersetze;

