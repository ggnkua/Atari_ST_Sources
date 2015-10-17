DEFINITION MODULE Granule;

(*
 * Dieses Modul ist eine alternative Speicherverwaltung zu Storage.
 * Der Vorteil ist, daû sie fÅr Blîcke in 16-Byte-Portionen optimiert
 * ist und fast keinen Verwaltungs-Overhead hat.
 *
 * Sie ist u.U. auch schneller als Storage. Allerdings erkennt sie
 * nicht, welche Blîcke zusammengehîren - das Anwendungsprogramm muû
 * selbst genau darauf achten, wieviel es alloziert hatte, wenn es einen
 * Bereich wieder freigeben will. DEALLOCATE (x, 0) ist also hier nicht
 * erlaubt - es muû immer exakt die Grîûe des belegten Bereichs angegeben
 * werden.
 *
 * Granule wurde speziell fÅr den GME entwickelt. Der GME verwaltet jede
 * einzelne Zeile Åber dieses Modul in einem eigens allozierten Block.
 *
 * Ob Granule oder Storage fÅr Ihre Anwendung besser geeignet ist,
 * probieren Sie am Besten in der Praxis aus.
 * Um die Funktionen 'CreateHeap', 'SetDefaultSize' usw. brauchen Sie sich
 * dabei nicht unbedingt zu kÅmmern - sie dienen nur Optimierungszwecken.
 *
 * Hinweis:
 * Die aktuelle Implementation dieses Moduls benutzt bei TT- und Falcon-
 * Rechnern nur das langsamere ST-RAM, also kein TT-RAM.
 * Wen das stîrt, setze sich mit Th. Tempelmann in Verbindung oder siehe
 * die Notizen vom Source des Moduls (die Quelltexte aller Module sind
 * ebenfalls dort zu bekommen). Der Nachteil wÑre dann allerdings, daû ca.
 * 100 KB zusÑtzlich ungenutzt belegt werden mÅûten, falls TT-RAM verfÅgbar
 * ist.
 *)

FROM SYSTEM IMPORT  ADDRESS;


PROCEDURE ALLOCATE (VAR adr: ADDRESS; bytes: LONGCARD);
(* Belegt Speicher ab adr mit bytes Bytes. Wenn Dynamic = TRUE
 * (siehe Prozedur Dynamic) wird bei einem HeapÅberlauf ein weiteres
 * Speichersegment angefordert und in den Heap integriert. Wenn FALSE
 * oder kein Speicher mehr zu VerfÅgung steht, wird adr NIL gesetzt.
 *)

PROCEDURE DEALLOCATE (VAR addr: ADDRESS; bytes: LONGCARD);
(* Gibt den Speicher wieder frei. 'bytes' muû den selben Wert haben,
 * mit dem der Speicher fÅr 'addr' vorher belegt wurde.
 * (werden NEW und DISPOSE verwendet, wird dafÅr automatisch Sorge getragen).
 *)

PROCEDURE Shrink (VAR adr: ADDRESS; amount: LONGCARD; VAR size: LONGCARD);
(* Gibt mit allocate belegten Speicher frei.
 * 'amount' ist die Anzahl, um die der Block verkleinert werden soll,
 * 'size' muû beim Aufruf mit der alten Grîûe besetzt sein und enthÑlt
 * hinterher die neue Grîûe.
 * Der freizugebende Teil wird am Ende des Blocks abgezwackt und fÅr
 * neue ALLOCATEs zur VerfÅgung gestellt.
 *)

PROCEDURE CreateHeap (bytes: LONGCARD): INTEGER;
(* Installiert den Heap mit bytes Byte. Liefert einen Fehlercode mit
 * folgender Bedeutung:
 *
 *  0   = Kein Fehler, Heap wurde installiert
 * -1   = Kein Speicher in ausreichender Grîûe zur VerfÅgung
 * -2   = Heap ist bereits installiert
 *
 * Wird kein Heap installiert, wird beim ersten ALLOCATE-Aufruf
 * automatisch ein Heap v. 64KB erzeugt.
 *)
 
PROCEDURE Dynamic (dyn: BOOLEAN);
(* Schaltet die Dynamic-Option des Heaps.
 * TRUE  = ALLOCATE fordert bei HeapÅberlauf neues Speichersegment an.
 * FALSE = ALLOCATE liefert bei HeapÅberlauf immer NIL
 *)

PROCEDURE SetDefaultSize (size: LONGCARD);
(* Setzt die Standard-Heapgrîûe, um die der Heap erweitert wird,
 * wenn er bei "dynamic=TRUE" um ein neues Segment erweitert werden muû.
 * Der Default ist 64 KB
 *)

PROCEDURE Free (): LONGCARD;
(* Liefert Anzahl der Bytes, die auf dem bereits angelegten Heap noch
 * frei sind.
 *)

PROCEDURE MemAvail (): LONGCARD;
(* liefert die Anzahl aller freien Bytes sowohl im Heap, als auch im
 * noch nicht allozierten Speicher - abzÅglich der GEMDOS-Reserve
 * (Konstante GEMReserve, z.Zt. 64KB)
 *)

END Granule.
