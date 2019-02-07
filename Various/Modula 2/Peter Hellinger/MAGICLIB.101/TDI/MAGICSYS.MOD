(*#######################################################################

  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ˇ         ˇ            ˇ    ˇ          ˇ
########################################################################

  MAGICSYS      System-SpezialitÑten
                Dieses Modul soll InkompatibilitÑten zwischen den einzel-
                nen Compilern aufheben.

                Implementation fÅr TDI-Modula-2/ST

#########################################################################
        V1.0    (c) by Peter Hellinger
#######################################################################*)

IMPLEMENTATION MODULE MagicSys;

(*----- TDI-Compilerswitches -----------*)
(*                                      *)
(*$V-   Overflow-Checks                 *)
(*$R-   Range-Checks                    *)
(*$S-   Stack-Check                     *)
(*$N-   NIL-Checks                      *)
(*$T-   fÅr TDI-Compiler vor 3.01       *)
(*$Q+   Branch-Befehle statt Jumps      *)
(*                                      *)
(*--------------------------------------*)


FROM SYSTEM IMPORT BYTE, WORD, LONGWORD, ADDRESS;


PROCEDURE ByteToChar (byte: BYTE): CHAR;
BEGIN
 RETURN CHAR (byte);
END ByteToChar;

PROCEDURE ByteToInt (byte: BYTE): INTEGER;
BEGIN
 RETURN INTEGER (byte);
END ByteToInt;

PROCEDURE ByteToCard (byte: BYTE): CARDINAL;
BEGIN
 RETURN CARDINAL (byte);
END ByteToCard;

PROCEDURE ByteToBitset (byte: BYTE): BITSET;
BEGIN
 RETURN BITSET (byte);
END ByteToBitset;

PROCEDURE ByteToLInt (byte: BYTE): LONGINT;
BEGIN
 RETURN LONGINT (byte);
END ByteToLInt;

PROCEDURE ByteToLCard (byte: BYTE): LONGCARD;
BEGIN
 RETURN LONGCARD (byte);
END ByteToLCard;

PROCEDURE ByteToAddr (byte: BYTE): ADDRESS;
BEGIN
 RETURN ADDRESS (byte);
END ByteToAddr;

PROCEDURE ByteToWord (byte: BYTE): WORD;
BEGIN
 RETURN WORD (byte);
END ByteToWord;



PROCEDURE CharToByte (char: CHAR): BYTE;
BEGIN
 RETURN BYTE (char);
END CharToByte;

PROCEDURE CharToInt (char: CHAR): INTEGER;
BEGIN
 RETURN INTEGER (char);
END CharToInt;

PROCEDURE CharToCard (char: CHAR): CARDINAL;
BEGIN
 RETURN CARDINAL (char)
END CharToCard;

PROCEDURE CharToBitset (char: CHAR): BITSET;
BEGIN
 RETURN BITSET (char);
END CharToBitset;

PROCEDURE CharToLInt (char: CHAR): LONGINT;
BEGIN
 RETURN LONGINT (char);
END CharToLInt;

PROCEDURE CharToLCard (char: CHAR): LONGCARD;
BEGIN
 RETURN LONGCARD (char);
END CharToLCard;

PROCEDURE CharToAddr (char: CHAR): ADDRESS;
BEGIN
 RETURN ADDRESS (char);
END CharToAddr;

PROCEDURE CharToWord (char: CHAR): WORD;
BEGIN
 RETURN WORD (char);
END CharToWord;



PROCEDURE IntToByte (int: INTEGER): BYTE;
BEGIN
 RETURN BYTE (int);
END IntToByte;

PROCEDURE IntToChar (int: INTEGER): CHAR;
BEGIN
 RETURN CHAR (int);
END IntToChar;

PROCEDURE IntToCard (int: INTEGER): CARDINAL;
BEGIN
 RETURN CARDINAL (int);
END IntToCard;

PROCEDURE IntToBitset (int: INTEGER): BITSET;
BEGIN
 RETURN BITSET (int);
END IntToBitset;

PROCEDURE IntToLInt (int: INTEGER): LONGINT;
BEGIN
 RETURN LONGINT (int);
END IntToLInt;

PROCEDURE IntToLCard (int: INTEGER): LONGCARD;
BEGIN
 RETURN LONGCARD (int);
END IntToLCard;

PROCEDURE IntToAddr (int: INTEGER): ADDRESS;
BEGIN
 RETURN ADDRESS (int);
END IntToAddr;

PROCEDURE IntToWord (int: INTEGER): WORD;
BEGIN
 RETURN WORD (int);
END IntToWord;



PROCEDURE CardToByte (card: CARDINAL): BYTE;
BEGIN
 RETURN BYTE (card);
END CardToByte;

PROCEDURE CardToChar (card: CARDINAL): CHAR;
BEGIN
 RETURN CHR (card);
END CardToChar;

PROCEDURE CardToInt (card: CARDINAL): INTEGER;
BEGIN
 RETURN INTEGER (card);
END CardToInt;

PROCEDURE CardToBitset  (card: CARDINAL): BITSET;
BEGIN
 RETURN BITSET (card);
END CardToBitset;

PROCEDURE CardToLInt (card: CARDINAL): LONGINT;
BEGIN
 RETURN LONGINT (card);
END CardToLInt;

PROCEDURE CardToLCard (card: CARDINAL): LONGCARD;
BEGIN
 RETURN LONGCARD (card);
END CardToLCard;

PROCEDURE CardToAddr (card: CARDINAL): ADDRESS;
BEGIN
 RETURN ADDRESS (card);
END CardToAddr;

PROCEDURE CardToWord (card: CARDINAL): WORD;
BEGIN
 RETURN WORD (card);
END CardToWord;



PROCEDURE BitsetToByte (bset: BITSET): BYTE;
BEGIN
 RETURN BYTE (bset);
END BitsetToByte;

PROCEDURE BitsetToChar (bset: BITSET): CHAR;
BEGIN
 RETURN CHAR (bset);
END BitsetToChar;

PROCEDURE BitsetToInt (bset: BITSET): INTEGER;
BEGIN
 RETURN INTEGER (bset);
END BitsetToInt;

PROCEDURE BitsetToCard (bset: BITSET): CARDINAL;
BEGIN
 RETURN CARDINAL (bset);
END BitsetToCard;

PROCEDURE BitsetToLInt (bset: BITSET): LONGINT;
BEGIN
 RETURN LONGINT (bset);
END BitsetToLInt;

PROCEDURE BitsetToLCard (bset: BITSET): LONGCARD;
BEGIN
 RETURN LONGCARD (bset);
END BitsetToLCard;

PROCEDURE BitsetToAddr (bset: BITSET): ADDRESS;
BEGIN
 RETURN ADDRESS (bset);
END BitsetToAddr;

PROCEDURE BitsetToWord (bset: BITSET): WORD;
BEGIN
 RETURN WORD (bset);
END BitsetToWord;



PROCEDURE LIntToByte (lint: LONGINT): BYTE;
BEGIN
 RETURN BYTE (lint);
END LIntToByte;

PROCEDURE LIntToChar (lint: LONGINT): CHAR;
BEGIN
 RETURN CHAR (lint);
END LIntToChar;

PROCEDURE LIntToInt (lint: LONGINT): INTEGER;
BEGIN
 RETURN INTEGER (lint);
END LIntToInt;

PROCEDURE LIntToCard (lint: LONGINT): CARDINAL;
BEGIN
 RETURN CARDINAL (lint);
END LIntToCard;

PROCEDURE LIntToBitset (lint: LONGINT): BITSET;
BEGIN
 RETURN BITSET (lint);
END LIntToBitset;

PROCEDURE LIntToLCard (lint: LONGINT): LONGCARD;
BEGIN
 RETURN LONGCARD (lint);
END LIntToLCard;

PROCEDURE LIntToAddr (lint: LONGINT): ADDRESS;
BEGIN
 RETURN ADDRESS (lint);
END LIntToAddr;

PROCEDURE LIntToWord (lint: LONGINT): WORD;
BEGIN
 RETURN WORD (lint);
END LIntToWord;



PROCEDURE LCardToByte (lcard: LONGCARD): BYTE;
BEGIN
 RETURN BYTE (lcard);
END LCardToByte;

PROCEDURE LCardToChar (lcard: LONGCARD): CHAR;
BEGIN
 RETURN CHAR (lcard);
END LCardToChar;

PROCEDURE LCardToInt (lcard: LONGCARD): INTEGER;
BEGIN
 RETURN INTEGER (lcard);
END LCardToInt;

PROCEDURE LCardToCard (lcard: LONGCARD): CARDINAL;
BEGIN
 RETURN CARDINAL (lcard);
END LCardToCard;

PROCEDURE LCardToBitset (lcard: LONGCARD): BITSET;
BEGIN
 RETURN BITSET (lcard);
END LCardToBitset;

PROCEDURE LCardToLInt (lcard: LONGCARD): LONGINT;
BEGIN
 RETURN LONGINT (lcard);
END LCardToLInt;

PROCEDURE LCardToAddr (lcard: LONGCARD): ADDRESS;
BEGIN
 RETURN ADDRESS (lcard);
END LCardToAddr;

PROCEDURE LCardToWord (lcard: LONGCARD): WORD;
BEGIN
 RETURN WORD (lcard);
END LCardToWord;



PROCEDURE AddrToByte (addr: ADDRESS): BYTE;
BEGIN
 RETURN BYTE (addr);
END AddrToByte;

PROCEDURE AddrToChar (addr: ADDRESS): CHAR;
BEGIN
 RETURN CHAR (addr);
END AddrToChar;

PROCEDURE AddrToInt (addr: ADDRESS): INTEGER;
BEGIN
 RETURN INTEGER (addr);
END AddrToInt;

PROCEDURE AddrToCard (addr: ADDRESS): CARDINAL;
BEGIN
 RETURN CARDINAL (addr);
END AddrToCard;

PROCEDURE AddrToBitset (addr: ADDRESS): BITSET;
BEGIN
 RETURN BITSET (addr);
END AddrToBitset;

PROCEDURE AddrToLInt (addr: ADDRESS): LONGINT;
BEGIN
 RETURN LONGINT (addr);
END AddrToLInt;

PROCEDURE AddrToLCard (addr: ADDRESS): LONGCARD;
BEGIN
 RETURN LONGCARD (addr);
END AddrToLCard;

PROCEDURE AddrToWord (addr: ADDRESS): WORD;
BEGIN
 RETURN WORD (addr);
END AddrToWord;



PROCEDURE WordToByte (word: WORD): BYTE;
BEGIN
 RETURN BYTE (word);
END WordToByte;

PROCEDURE WordToChar (word: WORD): CHAR;
BEGIN
 RETURN CHAR (word);
END WordToChar;

PROCEDURE WordToInt (word: WORD): INTEGER;
BEGIN
 RETURN INTEGER (word);
END WordToInt;

PROCEDURE WordToCard (word: WORD): CARDINAL;
BEGIN
 RETURN CARDINAL (word);
END WordToCard;

PROCEDURE WordToBitset (word: WORD): BITSET;
BEGIN
 RETURN BITSET (word);
END WordToBitset;

PROCEDURE WordToLInt (word: WORD): LONGINT;
BEGIN
 RETURN LONGINT (word);
END WordToLInt;

PROCEDURE WordToLCard (word: WORD): LONGCARD;
BEGIN
 RETURN LONGCARD (word);
END WordToLCard;

PROCEDURE WordToAddr (word: WORD): ADDRESS;
BEGIN
 RETURN ADDRESS (word);
END WordToAddr;

END MagicSys.
