IMPLEMENTATION MODULE LargeArrays;

(* By Robert Tolksdorf 10/90 *)

FROM SYSTEM IMPORT BYTE, ADDRESS, TSIZE, VAL;
IMPORT Storage;

TYPE ArrayHeader = RECORD
                     ElementSize : CARDINAL;
(* Falls bei Storage.DEALLOCATE eine Groessenangabe noetig ist,
   dann muesste hier noch ein Eintrag fuer die Elementanzahl
   hinzu, der in AllocateArray gesetzt werden muesste *)
                     ArrayMemory : ADDRESS;
                   END;
     Array       = POINTER TO ArrayHeader;

PROCEDURE AllocateArray(VAR a:Array;
                        ElementSize : CARDINAL;
                        ElementNumber : LONGCARD);
BEGIN
  (* Feldkopf allokieren *)
  Storage.ALLOCATE(a,TSIZE(ArrayHeader));
  (* Elementgr”že vermerken *)
  a^.ElementSize:=ElementSize;
  (* Hier eventuelle auch Elementanzahl vermerken *)
  (* Feldspeicher allokieren *)
  Storage.ALLOCATE(a^.ArrayMemory,
                   VAL(LONGCARD,ElementSize)*ElementNumber);
END AllocateArray;

PROCEDURE Get(a:Array; Index:LONGCARD; VAR Data:ARRAY OF BYTE);
VAR Byte   : POINTER TO BYTE;
    i      : CARDINAL;
BEGIN
  (* Elementoffset aus Index und Elementgroesse errechnen
     und zur Basisadresse addieren *)
  Byte:=VAL(ADDRESS,Index*VAL(LONGCARD,a^.ElementSize)+
                    VAL(LONGCARD,a^.ArrayMemory));
  (* Byteweise alle Daten kopieren *)
  FOR i:=0 TO a^.ElementSize-1 DO
    Data[i]:=Byte^;
    (* Adresse ein Byte weitersetzen *)
    Byte:=VAL(ADDRESS,VAL(LONGCARD,Byte)+1D);
  END;
END Get;

PROCEDURE Put(a:Array; Index:LONGCARD; Data:ARRAY OF BYTE);
VAR Byte   : POINTER TO BYTE;
    i      : CARDINAL;
BEGIN
  (* Elementoffset aus Index und Elementgroesse errechnen
     und zur Basisadresse addieren *)
  Byte:=VAL(ADDRESS,Index*VAL(LONGCARD,a^.ElementSize)+
                    VAL(LONGCARD,a^.ArrayMemory));
  (* Byteweise alle Daten kopieren *)
  FOR i:=0 TO a^.ElementSize-1 DO
    Byte^:=Data[i];
    (* Adresse ein Byte weitersetzen *)
    Byte:=VAL(ADDRESS,VAL(LONGCARD,Byte)+1D);
  END;
END Put;

PROCEDURE DeleteArray(VAR a:Array);
BEGIN
  (* Wenn Feld ueberhaupt vorhanden ... *)
  IF a#NIL THEN
    (* ... und Speicher allokiert ... *)
    IF a^.ArrayMemory#NIL THEN
      (* ... Feldspeicher deallokieren *)
      Storage.DEALLOCATE(a^.ArrayMemory)
    END;
    (* Feldkopf freigeben *)
    Storage.DEALLOCATE(a);
    (* sicherheitshalber auf NIL *)
    a:=NIL;
  END;
END DeleteArray;

END LargeArrays.

