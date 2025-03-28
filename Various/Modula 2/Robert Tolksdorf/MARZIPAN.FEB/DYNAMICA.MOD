IMPLEMENTATION MODULE DynamicArrays;

(* By Robert Tolksdorf 10/90 *)

FROM SYSTEM IMPORT BYTE, ADDRESS, VAL, TSIZE;
IMPORT Storage;

TYPE ArrayHeader = RECORD
                     ElementNumber : LONGCARD;
                     ArrayMemory   : ADDRESS;
                   END;
     Array       = POINTER TO ArrayHeader;

PROCEDURE AllocateArray(VAR a:Array;
                        ElementNumber:LONGCARD);
VAR p:POINTER TO ADDRESS;
    i:LONGCARD;
BEGIN
  (* Feldkopf allozieren *)
  Storage.ALLOCATE(a,TSIZE(ArrayHeader));
  (* Elementanzahl vermerken *)
  a^.ElementNumber:=ElementNumber;
  (* Speicher fÅr die Elementzeiger allozieren *)
  Storage.ALLOCATE(a^.ArrayMemory,
                   ElementNumber*VAL(LONGCARD,TSIZE(ADDRESS)));
  (* Zeiger auf den ersten Elementzeiger setzen *)
  p:=VAL(ADDRESS,a^.ArrayMemory);
  i:=0;
  (* Alle Elementzeiger auf NIL setzen *)
  REPEAT
    p^:=NIL;
    (* nÑchster Elementzeiger ist eine ADDRESS-Breite weiter *)
    p:=VAL(ADDRESS,VAL(LONGCARD,p)+VAL(LONGCARD,TSIZE(ADDRESS)));
    i:=i+1D;
  UNTIL i=ElementNumber; (* i laeuft von 0 bis ElementNumber-1 *)
END AllocateArray;

PROCEDURE Get(a: Array; Index:LONGCARD;
              VAR Data : ARRAY OF BYTE);
VAR p:POINTER TO ADDRESS;
    c:POINTER TO CARDINAL;
    b:POINTER TO BYTE;
    i:CARDINAL;
BEGIN
  (* Zeiger auf gewÅnschten Elementzeiger einrichten *)
  p:=VAL(ADDRESS,VAL(LONGCARD,a^.ArrayMemory)+
                 Index*VAL(LONGCARD,TSIZE(ADDRESS)));
  (* Wenn es ein Element gibt ... *)
  IF p^#NIL THEN
    (* Die Elementgroesse steht am Anfang ... *)
    c:=p^;
    (* und die Daten dahinter *)
    b:=VAL(ADDRESS,VAL(LONGCARD,p^)+VAL(LONGCARD,TSIZE(CARDINAL)));
    (* Element Byte-weise kopieren *)
    FOR i:=0 TO c^ DO
      Data[i]:=b^;
      (* Zeiger ein Byte weiter setzen *)
      b:=VAL(ADDRESS,VAL(LONGCARD,b)+1D);
    END;
  END;
END Get;

PROCEDURE Put(a: Array; Index:LONGCARD;
              Data : ARRAY OF BYTE);
VAR p:POINTER TO ADDRESS;
    c:POINTER TO CARDINAL;
    b:POINTER TO BYTE;
    i:CARDINAL;
BEGIN
  (* Zeiger auf gewÅnschten Feldzeiger setzen *)
  p:=VAL(ADDRESS,VAL(LONGCARD,a^.ArrayMemory)+
                 Index*VAL(LONGCARD,TSIZE(ADDRESS)));
  (* Wenn es schon ein Element gibt ... *)
  IF p^#NIL THEN
    (* ... Groesse testen und ... *)
    c:=p^;
    (* ... wenn nicht wie gewuenscht, den alten Eintrag loeschen *)
    IF c^#VAL(CARDINAL,HIGH(Data)) THEN
      Storage.DEALLOCATE(p^);
      p^:=NIL;
    END;
  END;
  (* Wenn kein Element vorhanden oder vorher gelîscht ... *)
  IF p^=NIL THEN
    (* ... Speicher einrichten fuer Elementgroesse und Daten *)
    Storage.ALLOCATE(p^,TSIZE(CARDINAL)+HIGH(Data)+1);
    c:=p^;
    (* Groesse vermerken *)
    c^:=HIGH(Data);
  END;
  (* Zeiger auf erstes Datenbyte *)
  b:=VAL(ADDRESS,VAL(LONGCARD,p^)+VAL(LONGCARD,TSIZE(CARDINAL)));
  (* Byte-weise kopieren *)
  FOR i:=0 TO c^ DO
    b^:=Data[i];
    (* Zeiger ein Byte weitersetzen *)
    b:=VAL(ADDRESS,VAL(LONGCARD,b)+1D);
  END;
END Put;

PROCEDURE Delete(a:Array; Index:LONGCARD);
VAR p:POINTER TO ADDRESS;
BEGIN
  (* Zeiger auf gewuenschten Elementzeiger setzen *)
  p:=VAL(ADDRESS,VAL(LONGCARD,a^.ArrayMemory)+
                 Index*VAL(LONGCARD,TSIZE(ADDRESS)));
  (* Falls Element vorhanden *)
  IF p^#NIL THEN
    (* ... loeschen und Elementzeiger auf NIL *)
    Storage.DEALLOCATE(p^);
    p^:=NIL;
  END;
END Delete;

PROCEDURE DeleteArray(VAR a:Array);
VAR p:POINTER TO ADDRESS;
    i:LONGCARD;
BEGIN
  (* Wenn es das Feld ueberhaupt gibt ... *)
  IF p#NIL THEN
    (* p auf den ersten Elementzeiger setzen *)
    p:=VAL(ADDRESS,a^.ArrayMemory);
    i:=0;
    (* alle Elemente loeschen *)
    REPEAT
      IF p^#NIL THEN
        Storage.DEALLOCATE(p^);
      END;
      (* naechster Elementzeiger steht eine Adress-Breite dahinter *)
      p:=VAL(ADDRESS,VAL(LONGCARD,p)+VAL(LONGCARD,TSIZE(ADDRESS)));
      i:=i+1D;
    UNTIL i=a^.ElementNumber; (* von 0 bis ElementNumber-1 *)
    (* Speicher fuer Elementzeiger freigeben *)
    Storage.DEALLOCATE(a^.ArrayMemory);
    (* Feldkopf freigeben *)
    Storage.DEALLOCATE(a);
    (* sicherheitshalber auf NIL setzen *)
    a:=NIL;
  END;
END DeleteArray;

END DynamicArrays.

