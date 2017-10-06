UNIT M_Buffer;

INTERFACE

TYPE    BUFFER = POINTER;

FUNCTION NewBuffer (VAR buffer: BUFFER): BOOLEAN;
(* Generiert einen neuen Buffer *)

PROCEDURE DisposeBuffer (VAR buffer: BUFFER);
(* L”scht einen Buffer, wenn der Buffer nicht leer ist, wird der Inhalt
 * vorher gel”scht.
 *)

FUNCTION BufferEmpty (buffer: BUFFER): BOOLEAN;
(* TRUE, wenn der Buffer leer ist *)

FUNCTION BufferEntries (buffer: BUFFER): LONGINT;
(* Anzahl der Eintr„ge in den Puffer *)

FUNCTION Put (buffer: BUFFER; infoptr: POINTER; size: INTEGER): BOOLEAN;
(* Legt ein Element im buffer ab, FALSE wenn dabei ein Fehler auftritt *)

FUNCTION Get (buffer: BUFFER; infoptr: POINTER): BOOLEAN;
(* Holt ein Element aus dem Puffer. Es wird nur kopiert, wenn die
 * Datenstruktur gleich oder gr”žer als die gespeicherte Struktur ist.
 * FALSE wenn dabei ein Fehler auftritt (info zu klein, buffer leer).
 * Das Element wird dabei aus dem Buffer entfernt.
 *)

IMPLEMENTATION

(*----------------------------------------------------------------------*
 * Int. Vers | Datum    | Name | Žnderung                               *
 *-----------+----------+------+----------------------------------------*
 *  1.00     | 09.05.92 |  Hp  | Modula-2 to Pascal                     *
 *-----------+----------+------+----------------------------------------*)

{$I COMPOPT.INC}

CONST   cMax =          $07FFF;

TYPE    INFO =          ^Information;
        Information =   ARRAY [0..cMax] OF BYTE;

TYPE    ENTRY =         ^EntryDescr;
        EntryDescr =    RECORD
                         addr: INFO;
                         size: WORD;
                         next: ENTRY;
                        END;

TYPE    BUFFERPtr =     ^BufferDescr;
        BufferDescr =   RECORD
                         start: ENTRY;
                         ende:  ENTRY;
                         entry: LONGINT;
                        END;


FUNCTION NewBuffer (VAR buffer: BUFFER): BOOLEAN;
VAR b: BUFFERPtr;
BEGIN
 GetMem (buffer, SIZEOF(BufferDescr));
 IF buffer = NIL THEN BEGIN  NewBuffer:= FALSE; EXIT; END;
 b:= buffer;  b^.start:= NIL;  b^.ende:= NIL;  b^.entry:= 0;
 NewBuffer:= TRUE;
END (*NewBuffer*);

PROCEDURE DisposeBuffer (VAR buffer: BUFFER);
VAR p: ENTRY;
    b: BUFFERPtr;
BEGIN
 IF buffer <> NIL THEN BEGIN
  b:= buffer;
  WITH b^ DO BEGIN
   WHILE start <> NIL DO BEGIN
    p:= start^.next;
    FreeMem (start^.addr, start^.size);
    FreeMem (start, SIZEOF(EntryDescr));
    start:= p;
   END;
  END;
  FreeMem (buffer, SIZEOF(BufferDescr));
 END;
END (*DisposeBuffer*);

FUNCTION BufferEmpty (buffer: BUFFER): BOOLEAN;
VAR b: BUFFERPtr;
BEGIN
 IF buffer = NIL THEN BEGIN BufferEmpty:= FALSE;  EXIT;  END;
 b:= buffer; BufferEmpty:= b^.start = NIL;
END (*BufferEmpty*);

FUNCTION BufferEntries (buffer: BUFFER): LONGINT;
VAR b: BUFFERPtr;
BEGIN
 IF buffer = NIL THEN BEGIN
  BufferEntries:= 0; 
 END ELSE BEGIN
  b:= buffer;
  BufferEntries:= b^.entry;
 END;
END (*BufferEntries*);

FUNCTION Put (buffer: BUFFER; infoptr: POINTER; size: INTEGER): BOOLEAN;
VAR b: BUFFERPtr;
    p: ENTRY;
    x: INFO;
BEGIN
 put:= FALSE;
 IF buffer <> NIL THEN BEGIN
  b:= buffer;
  GetMem (p, SIZEOF(EntryDescr));
  IF p = NIL THEN BEGIN  EXIT;  END;
  p^.size:= size;
  p^.next:= NIL;
  GetMem (p^.addr, p^.size);
  IF p^.addr = NIL THEN BEGIN
   FreeMem (p, SIZEOF(EntryDescr));
   EXIT;
  END;
  x:= infoptr;
  Move (x^, p^.addr^, p^.size);
  WITH b^ DO BEGIN
   IF ende <> NIL THEN BEGIN
    ende^.next:= p;
    ende:= p;
   END ELSE IF start <> NIL THEN BEGIN
    start^.next:= p;  start:= p;
   END ELSE BEGIN
    start:= p;  ende:= p;
   END;
   INC (entry);
  END;
  Put:= TRUE;
 END;
END (*Put*);

FUNCTION Get (buffer: BUFFER; infoptr: POINTER): BOOLEAN;
VAR b: BUFFERPtr;
VAR p: ENTRY;
    x: INFO;
BEGIN
 Get:= FALSE;
 IF buffer = NIL THEN BEGIN  EXIT;  END;
 b:= buffer;
 WITH b^ DO BEGIN
  IF start = NIL THEN BEGIN  EXIT;  END;
  p:= start;
 (* IF HIGH (info) < p^.size THEN  RETURN FALSE;  END;*)
  x:= infoptr;
  Move (p^.addr^, x^, p^.size);
  start:= p^.next;
  FreeMem (p^.addr, p^.size);
  FreeMem (p, SIZEOF (EntryDescr));
  IF start = NIL THEN BEGIN  ende:= NIL;  END;
  DEC (entry);
  Get:= TRUE;
 END;
END (*Get*);

END (*mpBuffer*).

