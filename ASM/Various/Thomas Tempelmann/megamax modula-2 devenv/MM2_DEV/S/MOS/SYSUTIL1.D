DEFINITION MODULE SysUtil1;

(*
 * Modul mit Peeks, Pokes und Bit-Manipulationen fÅr Megamax Modula-2
 *
 *   25.10.88 Christoph Grunwald: Peek-/Poke-Funktionen
 *   07.12.88 Thomas Tempelmann:  Bit-Funktionen
 *)

FROM SYSTEM IMPORT ADDRESS, BYTE, WORD, LONGWORD;


(*
 *  Poke-Funktionen
 *  ---------------
 *    zum Speichern von Werten in beliebige Speicherstellen.
 *
 *  Peek-Funktionen
 *  ---------------
 *    zum Auslesen von Werten aus beliebigen Speicherstellen.
 *
 *    Die Funktionen, die ein 'B', 'W', oder 'L' enthalten, speichern bzw.
 *  lesen nur ein Byte, Word bzw. Longword, wobei bei den 'W'- und 'L'-
 *  Funktionen die Quell-/Zieladresse nicht ungerade sein darf, da es sonst
 *  zu einem "Adreûfehler" kÑme, die 'BPoke'-Funktionen verwenden nur das
 *  untere Byte des CARDINAL-Arguments. Den Åbrigen Funktionen (mit dem
 *  OPEN ARRAY-Parameter) kann jedes beliebige Datum Åbergeben werden - es
 *  wird dann immer byteweise Åbertragen (so kann es zu keinem "Zugriff auf
 *  ungerade Adresse", also einem "Adreûfehler", kommen).
 *
 *    Die 'Super'-Funktionen erlauben den Zugriff auch auf Speicherbereiche,
 *  die nur im Supervisormodus erreichbar sind (sonst gÑb's "Bus-Fehler"),
 *  z.B. die Hardwareregister (oberhalb $FF8000) oder Systemvariablen
 *  (ab $400).
 *
 *    Die 'Fast'-Funktionen (nur bei 'Poke') waren beim altem Compiler
 *  ohne REF-Parameter nÅtzlich, nun kînnen auch die normalen Funktionen
 *  (ohne 'Fast') ebenso effizient genutzt werden.
 *)

  (* Normale Poke *)

PROCEDURE Poke  ( addr: ADDRESS; REF data: ARRAY OF BYTE );
PROCEDURE BPoke ( addr: ADDRESS; data: WORD );
PROCEDURE WPoke ( addr: ADDRESS; data: WORD );
PROCEDURE LPoke ( addr: ADDRESS; data: LONGWORD );

  (* Supervisor Poke *)

PROCEDURE SuperPoke  ( addr: ADDRESS; REF data: ARRAY OF BYTE );
PROCEDURE SuperBPoke ( addr: ADDRESS; data: WORD );
PROCEDURE SuperWPoke ( addr: ADDRESS; data: WORD );
PROCEDURE SuperLPoke ( addr: ADDRESS; data: LONGWORD );

  (* Normale Peek *)

PROCEDURE Peek  ( addr: ADDRESS; VAR data: ARRAY OF BYTE );
PROCEDURE BPeek ( addr: ADDRESS ): CARDINAL;
PROCEDURE WPeek ( addr: ADDRESS ): CARDINAL;
PROCEDURE LPeek ( addr: ADDRESS ): LONGCARD;

  (* Supervisor Peek *)

PROCEDURE SuperPeek  ( addr: ADDRESS; VAR data: ARRAY OF BYTE );
PROCEDURE SuperBPeek ( addr: ADDRESS ): CARDINAL;
PROCEDURE SuperWPeek ( addr: ADDRESS ): CARDINAL;
PROCEDURE SuperLPeek ( addr: ADDRESS ): LONGCARD;

(*
 * Bit-Funktionen
 * --------------
 *
 *    Die 'Super'-Funktionen erlauben den Zugriff auch auf Speicherbereiche,
 *  die nur im Supervisormodus erreichbar sind (sonst gÑb's "Bus-Fehler"),
 *  z.B. die Hardwareregister (oberhalb $FF8000) oder Systemvariablen
 *  (ab $400).
 *
 *)

TYPE BitRange = [0..7];

PROCEDURE Bit      ( addr: ADDRESS; no: BitRange ): BOOLEAN;
PROCEDURE SuperBit ( addr: ADDRESS; no: BitRange ): BOOLEAN;
  (* Ermittelt Status des Bits 'no' im Byte auf Adr. 'addr' *)

PROCEDURE BitSet      ( addr: ADDRESS; no: BitRange );
PROCEDURE SuperBitSet ( addr: ADDRESS; no: BitRange );
  (* Setzt Bit 'no' im Byte auf Adr. 'addr' *)

PROCEDURE BitClr      ( addr: ADDRESS; no: BitRange );
PROCEDURE SuperBitClr ( addr: ADDRESS; no: BitRange );
  (* Lîscht Bit 'no' im Byte auf Adr. 'addr' *)

PROCEDURE BitChg      ( addr: ADDRESS; no: BitRange );
PROCEDURE SuperBitChg ( addr: ADDRESS; no: BitRange );
  (* Invertiert Bit 'no' im Byte auf Adr. 'addr' *)

PROCEDURE ByteToBitset ( b: BYTE ): BITSET;
  (* Wandelt ein Byte (8 Bits) in ein BITSET (Elemente 8-15 werden gelîscht) *)

PROCEDURE BitsetToByte ( bs: BITSET ): BYTE;
  (* Wandelt ein BITSET in ein Byte (8 Bits) (Elemente 8-15 werden ignoriert) *)

(*
 * Folgende zwei Funktionen existieren nur noch zur KompatibilitÑt mit
 * alten Programmen und brauchen in Zukunft nicht mehr benutzt werden
 * (die Routinen ohne 'Fast' sind durch den REF-Parameter ebenso schnell).
 *)
PROCEDURE FastPoke ( addr: ADDRESS; VAR data: ARRAY OF BYTE );
PROCEDURE FastSuperPoke ( addr: ADDRESS; VAR data: ARRAY OF BYTE );

END SysUtil1.
