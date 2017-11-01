DEFINITION MODULE MagicSys;

FROM SYSTEM IMPORT BYTE, WORD, ADDRESS;

(* Solange die Bitsets noch verdreht sind, muž dieses Flag auf FALSE stehen *)
CONST   Bitset = FALSE;
(*$?     Bitset:  Bit0 =   0; *)
(*$?     Bitset:  Bit1 =   1; *)
(*$?     Bitset:  Bit2 =   2; *)
(*$?     Bitset:  Bit3 =   3; *)
(*$?     Bitset:  Bit4 =   4; *)
(*$?     Bitset:  Bit5 =   5; *)
(*$?     Bitset:  Bit6 =   6; *)
(*$?     Bitset:  Bit7 =   7; *)
(*$?     Bitset:  Bit8 =   8; *)
(*$?     Bitset:  Bit9 =   9; *)
(*$?     Bitset:  Bit10 = 10; *)
(*$?     Bitset:  Bit11 = 11; *)
(*$?     Bitset:  Bit12 = 12; *)
(*$?     Bitset:  Bit13 = 13; *)
(*$?     Bitset:  Bit14 = 14; *)
(*$?     Bitset:  Bit15 = 15; *)
(*$? NOT Bitset:  Bit0 =   8; *)
(*$? NOT Bitset:  Bit1 =   9; *)
(*$? NOT Bitset:  Bit2 =  10; *)
(*$? NOT Bitset:  Bit3 =  11; *)
(*$? NOT Bitset:  Bit4 =  12; *)
(*$? NOT Bitset:  Bit5 =  13; *)
(*$? NOT Bitset:  Bit6 =  14; *)
(*$? NOT Bitset:  Bit7 =  15; *)
(*$? NOT Bitset:  Bit8 =   0; *)
(*$? NOT Bitset:  Bit9 =   1; *)
(*$? NOT Bitset:  Bit10 =  2; *)
(*$? NOT Bitset:  Bit11 =  3; *)
(*$? NOT Bitset:  Bit12 =  4; *)
(*$? NOT Bitset:  Bit13 =  5; *)
(*$? NOT Bitset:  Bit14 =  6; *)
(*$? NOT Bitset:  Bit15 =  7; *)


(* Typ-Casting *)

PROCEDURE ByteToChar    (byte: BYTE): CHAR;
PROCEDURE ByteToInt     (byte: BYTE): INTEGER;
PROCEDURE ByteToCard    (byte: BYTE): CARDINAL;
PROCEDURE ByteToBitset  (byte: BYTE): BITSET;
PROCEDURE ByteToLInt    (byte: BYTE): LONGINT;
PROCEDURE ByteToLCard   (byte: BYTE): LONGCARD;
PROCEDURE ByteToAddr    (byte: BYTE): ADDRESS;
PROCEDURE ByteToWord    (byte: BYTE): WORD;

PROCEDURE CharToByte    (char: CHAR): BYTE;
PROCEDURE CharToInt     (char: CHAR): INTEGER;
PROCEDURE CharToCard    (char: CHAR): CARDINAL;
PROCEDURE CharToBitset  (char: CHAR): BITSET;
PROCEDURE CharToLInt    (char: CHAR): LONGINT;
PROCEDURE CharToLCard   (char: CHAR): LONGCARD;
PROCEDURE CharToAddr    (char: CHAR): ADDRESS;
PROCEDURE CharToWord    (char: CHAR): WORD;

PROCEDURE IntToByte     (int: INTEGER): BYTE;
PROCEDURE IntToChar     (int: INTEGER): CHAR;
PROCEDURE IntToCard     (int: INTEGER): CARDINAL;
PROCEDURE IntToBitset   (int: INTEGER): BITSET;
PROCEDURE IntToLInt     (int: INTEGER): LONGINT;
PROCEDURE IntToLCard    (int: INTEGER): LONGCARD;
PROCEDURE IntToAddr     (int: INTEGER): ADDRESS;
PROCEDURE IntToWord     (int: INTEGER): WORD;

PROCEDURE CardToByte    (card: CARDINAL): BYTE;
PROCEDURE CardToChar    (card: CARDINAL): CHAR;
PROCEDURE CardToInt     (card: CARDINAL): INTEGER;
PROCEDURE CardToBitset  (card: CARDINAL): BITSET;
PROCEDURE CardToLInt    (card: CARDINAL): LONGINT;
PROCEDURE CardToLCard   (card: CARDINAL): LONGCARD;
PROCEDURE CardToAddr    (card: CARDINAL): ADDRESS;
PROCEDURE CardToWord    (card: CARDINAL): WORD;

PROCEDURE BitsetToByte  (bset: BITSET): BYTE;
PROCEDURE BitsetToChar  (bset: BITSET): CHAR;
PROCEDURE BitsetToInt   (bset: BITSET): INTEGER;
PROCEDURE BitsetToCard  (bset: BITSET): CARDINAL;
PROCEDURE BitsetToLInt  (bset: BITSET): LONGINT;
PROCEDURE BitsetToLCard (bset: BITSET): LONGCARD;
PROCEDURE BitsetToAddr  (bset: BITSET): ADDRESS;
PROCEDURE BitsetToWord  (bset: BITSET): WORD;

PROCEDURE LIntToByte    (lint: LONGINT): BYTE;
PROCEDURE LIntToChar    (lint: LONGINT): CHAR;
PROCEDURE LIntToInt     (lint: LONGINT): INTEGER;
PROCEDURE LIntToCard    (lint: LONGINT): CARDINAL;
PROCEDURE LIntToBitset  (lint: LONGINT): BITSET;
PROCEDURE LIntToLCard   (lint: LONGINT): LONGCARD;
PROCEDURE LIntToAddr    (lint: LONGINT): ADDRESS;
PROCEDURE LIntToWord    (lint: LONGINT): WORD;

PROCEDURE LCardToByte   (lcard: LONGCARD): BYTE;
PROCEDURE LCardToChar   (lcard: LONGCARD): CHAR;
PROCEDURE LCardToInt    (lcard: LONGCARD): INTEGER;
PROCEDURE LCardToCard   (lcard: LONGCARD): CARDINAL;
PROCEDURE LCardToBitset ( lcard: LONGCARD): BITSET;
PROCEDURE LCardToLInt   (lcard: LONGCARD): LONGINT;
PROCEDURE LCardToAddr   (lcard: LONGCARD): ADDRESS;
PROCEDURE LCardToWord   (lcard: LONGCARD): WORD;

PROCEDURE AddrToByte    (addr: ADDRESS): BYTE;
PROCEDURE AddrToChar    (addr: ADDRESS): CHAR;
PROCEDURE AddrToInt     (addr: ADDRESS): INTEGER;
PROCEDURE AddrToCard    (addr: ADDRESS): CARDINAL;
PROCEDURE AddrToBitset  (addr: ADDRESS): BITSET;
PROCEDURE AddrToLInt    (addr: ADDRESS): LONGINT;
PROCEDURE AddrToLCard   (addr: ADDRESS): LONGCARD;
PROCEDURE AddrToWord    (addr: ADDRESS): WORD;

PROCEDURE WordToByte    (word: WORD): BYTE;
PROCEDURE WordToChar    (word: WORD): CHAR;
PROCEDURE WordToInt     (word: WORD): INTEGER;
PROCEDURE WordToCard    (word: WORD): CARDINAL;
PROCEDURE WordToBitset  (word: WORD): BITSET;
PROCEDURE WordToLInt    (word: WORD): LONGINT;
PROCEDURE WordToLCard   (word: WORD): LONGCARD;
PROCEDURE WordToAddr    (word: WORD): ADDRESS;


END MagicSys.

