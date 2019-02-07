(*#######################################################################

  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ˇ         ˇ            ˇ    ˇ          ˇ
########################################################################

  MAGICSYS      System-SpezialitÑten
                Dieses Modul soll InkompatibilitÑten zwischen den einzel-
                nen Compilern aufheben.

                Implementation fÅr Megamax-Modula-2

#########################################################################
  V1.01 18.06.90  Peter Hellinger    Cast-Record berichtigt   
  V1.00 (c) by    Peter Hellinger
#######################################################################*)

IMPLEMENTATION MODULE MagicSys;

(*----- MM2-Compilerswitches -----------*)
(*                                      *)
(*$R-   Range-Checks                    *)
(*$S-   Stack-Check                     *)
(*                                      *)
(*--------------------------------------*)


FROM SYSTEM IMPORT BYTE, WORD, ADDRESS, CAST;


VAR     cast:   RECORD
                 CASE : CARDINAL OF
                  0:    adr:    ADDRESS;|
                  1:    lc:     LONGCARD;|
                  2:    li:     LONGINT;|
                  3:    wh:     WORD;
                        wl:     WORD;|
                  4:    ch:     CARDINAL;
                        cl:     CARDINAL;|
                  5:    ih:     INTEGER;
                        il:     INTEGER;|
                  6:    bh:     BITSET;
                        bl:     BITSET;|
                  7:    c1:     CHAR;
                        c2:     CHAR;
                        c3:     CHAR;
                        c4:     CHAR;|
                  8:    b1:     BYTE;
                        b2:     BYTE;
                        b3:     BYTE;
                        b4:     BYTE;|
                  9:    dummy:  LONGCARD;
                 END;
                END;


PROCEDURE ByteToChar (byte: BYTE): CHAR;
BEGIN
 RETURN CAST (CHAR, byte);
END ByteToChar;

PROCEDURE ByteToInt (byte: BYTE): INTEGER;
BEGIN
 RETURN CAST (INTEGER, byte);
END ByteToInt;

PROCEDURE ByteToCard (byte: BYTE): CARDINAL;
BEGIN
 RETURN CAST (CARDINAL, byte);
END ByteToCard;

PROCEDURE ByteToBitset ( byte: BYTE): BITSET;
BEGIN
 RETURN CAST (BITSET, byte);
END ByteToBitset;

PROCEDURE ByteToLInt (byte: BYTE): LONGINT;
BEGIN
 RETURN CAST (LONGINT, byte);
END ByteToLInt;

PROCEDURE ByteToLCard (byte: BYTE): LONGCARD;
BEGIN
 RETURN CAST (LONGCARD, byte);
END ByteToLCard;

PROCEDURE ByteToAddr (byte: BYTE): ADDRESS;
BEGIN
 RETURN CAST (ADDRESS, byte);
END ByteToAddr;

PROCEDURE ByteToWord (byte: BYTE): WORD;
BEGIN
 RETURN CAST (WORD, byte);
END ByteToWord;



PROCEDURE CharToByte (char: CHAR): BYTE;
BEGIN
 RETURN CAST (BYTE, char);
END CharToByte;

PROCEDURE CharToInt (char: CHAR): INTEGER;
BEGIN
 RETURN CAST (INTEGER, char);
END CharToInt;

PROCEDURE CharToCard (char: CHAR): CARDINAL;
BEGIN
 RETURN CAST (CARDINAL, char)
END CharToCard;

PROCEDURE CharToBitset ( char: CHAR): BITSET;
BEGIN
 RETURN CAST (BITSET, char);
END CharToBitset;

PROCEDURE CharToLInt (char: CHAR): LONGINT;
BEGIN
 RETURN CAST (LONGINT, char);
END CharToLInt;

PROCEDURE CharToLCard (char: CHAR): LONGCARD;
BEGIN
 RETURN CAST (LONGCARD, char);
END CharToLCard;

PROCEDURE CharToAddr (char: CHAR): ADDRESS;
BEGIN
 RETURN CAST (ADDRESS, char);
END CharToAddr;

PROCEDURE CharToWord (char: CHAR): WORD;
BEGIN
 RETURN CAST (WORD, char);
END CharToWord;



PROCEDURE IntToByte (int: INTEGER): BYTE;
BEGIN
 RETURN CAST (BYTE, int);
END IntToByte;

PROCEDURE IntToChar ( int: INTEGER): CHAR;
BEGIN
 RETURN CAST (CHAR, int);
END IntToChar;

PROCEDURE IntToCard (int: INTEGER): CARDINAL;
BEGIN
 RETURN CAST (CARDINAL, int);
END IntToCard;

PROCEDURE IntToBitset ( int: INTEGER): BITSET;
BEGIN
 RETURN CAST (BITSET, int);
END IntToBitset;

PROCEDURE IntToLInt (int: INTEGER): LONGINT;
BEGIN
 RETURN CAST (LONGINT, int);
END IntToLInt;

PROCEDURE IntToLCard (int: INTEGER): LONGCARD;
BEGIN
 RETURN CAST (LONGCARD, int);
END IntToLCard;

PROCEDURE IntToAddr (int: INTEGER): ADDRESS;
BEGIN
 RETURN CAST (ADDRESS, int);
END IntToAddr;

PROCEDURE IntToWord (int: INTEGER): WORD;
BEGIN
 RETURN CAST (WORD, int);
END IntToWord;



PROCEDURE CardToByte ( card: CARDINAL): BYTE;
BEGIN
 RETURN CAST (BYTE, card);
END CardToByte;

PROCEDURE CardToChar ( card: CARDINAL): CHAR;
BEGIN
 RETURN CAST (CHAR, card);
END CardToChar;

PROCEDURE CardToInt (card: CARDINAL): INTEGER;
BEGIN
 RETURN CAST (INTEGER, card);
END CardToInt;

PROCEDURE CardToBitset  (card: CARDINAL): BITSET;
BEGIN
 RETURN CAST (BITSET, card);
END CardToBitset;

PROCEDURE CardToLInt (card: CARDINAL): LONGINT;
BEGIN
 RETURN CAST (LONGINT, card);
END CardToLInt;

PROCEDURE CardToLCard (card: CARDINAL): LONGCARD;
BEGIN
 RETURN CAST (LONGCARD, card);
END CardToLCard;

PROCEDURE CardToAddr (card: CARDINAL): ADDRESS;
BEGIN
 RETURN CAST (ADDRESS, card);
END CardToAddr;

PROCEDURE CardToWord (card: CARDINAL): WORD;
BEGIN
 RETURN CAST (WORD, card);
END CardToWord;



PROCEDURE BitsetToByte ( bset: BITSET): BYTE;
BEGIN
 RETURN CAST (BYTE, bset);
END BitsetToByte;

PROCEDURE BitsetToChar ( bset: BITSET): CHAR;
BEGIN
 RETURN CAST (CHAR, bset);
END BitsetToChar;

PROCEDURE BitsetToInt (bset: BITSET): INTEGER;
BEGIN
 RETURN CAST (INTEGER, bset);
END BitsetToInt;

PROCEDURE BitsetToCard (bset: BITSET): CARDINAL;
BEGIN
 RETURN CAST (CARDINAL, bset);
END BitsetToCard;

PROCEDURE BitsetToLInt (bset: BITSET): LONGINT;
BEGIN
 RETURN CAST (LONGINT, bset);
END BitsetToLInt;

PROCEDURE BitsetToLCard (bset: BITSET): LONGCARD;
BEGIN
 RETURN CAST (LONGCARD, bset);
END BitsetToLCard;

PROCEDURE BitsetToAddr (bset: BITSET): ADDRESS;
BEGIN
 RETURN CAST (ADDRESS, bset);
END BitsetToAddr;

PROCEDURE BitsetToWord (bset: BITSET): WORD;
BEGIN
 RETURN CAST (WORD, bset);
END BitsetToWord;



PROCEDURE LIntToByte ( lint: LONGINT): BYTE;
BEGIN
 RETURN CAST (BYTE, lint);
END LIntToByte;

PROCEDURE LIntToChar ( lint: LONGINT): CHAR;
BEGIN
 RETURN CAST (CHAR, lint);
END LIntToChar;

PROCEDURE LIntToInt (lint: LONGINT): INTEGER;
BEGIN
 RETURN CAST (INTEGER, lint);
END LIntToInt;

PROCEDURE LIntToCard (lint: LONGINT): CARDINAL;
BEGIN
 RETURN CAST (CARDINAL, lint);
END LIntToCard;

PROCEDURE LIntToBitset ( lint: LONGINT): BITSET;
BEGIN
 RETURN CAST (BITSET, lint);
END LIntToBitset;

PROCEDURE LIntToLCard (lint: LONGINT): LONGCARD;
BEGIN
 RETURN CAST (LONGCARD, lint);
END LIntToLCard;

PROCEDURE LIntToAddr (lint: LONGINT): ADDRESS;
BEGIN
 RETURN CAST (ADDRESS, lint);
END LIntToAddr;

PROCEDURE LIntToWord (lint: LONGINT): WORD;
BEGIN
 RETURN CAST (WORD, lint);
END LIntToWord;



PROCEDURE LCardToByte ( lcard: LONGCARD): BYTE;
BEGIN
 RETURN CAST (BYTE, lcard);
END LCardToByte;

PROCEDURE LCardToChar ( lcard: LONGCARD): CHAR;
BEGIN
 RETURN CAST (CHAR, lcard);
END LCardToChar;

PROCEDURE LCardToInt (lcard: LONGCARD): INTEGER;
BEGIN
 RETURN CAST (INTEGER, lcard);
END LCardToInt;

PROCEDURE LCardToCard (lcard: LONGCARD): CARDINAL;
BEGIN
 RETURN CAST (CARDINAL, lcard);
END LCardToCard;

PROCEDURE LCardToBitset ( lcard: LONGCARD): BITSET;
BEGIN
 RETURN CAST (BITSET, lcard);
END LCardToBitset;

PROCEDURE LCardToLInt (lcard: LONGCARD): LONGINT;
BEGIN
 RETURN CAST (LONGINT, lcard);
END LCardToLInt;

PROCEDURE LCardToAddr (lcard: LONGCARD): ADDRESS;
BEGIN
 RETURN CAST (ADDRESS, lcard);
END LCardToAddr;

PROCEDURE LCardToWord (lcard: LONGCARD): WORD;
BEGIN
 RETURN CAST (WORD, lcard);
END LCardToWord;



PROCEDURE AddrToByte ( addr: ADDRESS): BYTE;
BEGIN
 cast.adr:= addr;  RETURN cast.b4;
END AddrToByte;

PROCEDURE AddrToChar ( addr: ADDRESS): CHAR;
BEGIN
 cast.adr:= addr;  RETURN cast.c4;
END AddrToChar;

PROCEDURE AddrToInt (addr: ADDRESS): INTEGER;
BEGIN
 cast.adr:= addr;  RETURN cast.il;
END AddrToInt;

PROCEDURE AddrToCard (addr: ADDRESS): CARDINAL;
BEGIN
 cast.adr:= addr;  RETURN cast.cl;
END AddrToCard;

PROCEDURE AddrToBitset ( addr: ADDRESS): BITSET;
BEGIN
 cast.adr:= addr;  RETURN cast.bl;
END AddrToBitset;

PROCEDURE AddrToLInt (addr: ADDRESS): LONGINT;
BEGIN
 RETURN CAST (LONGINT, addr);
END AddrToLInt;

PROCEDURE AddrToLCard (addr: ADDRESS): LONGCARD;
BEGIN
 RETURN CAST (LONGCARD, addr);
END AddrToLCard;

PROCEDURE AddrToWord (addr: ADDRESS): WORD;
BEGIN
 cast.adr:= addr;  RETURN cast.wl;
END AddrToWord;



PROCEDURE WordToByte ( word: WORD): BYTE;
BEGIN
 RETURN CAST (BYTE, word);
END WordToByte;

PROCEDURE WordToChar ( word: WORD): CHAR;
BEGIN
 RETURN CAST (CHAR, word);
END WordToChar;

PROCEDURE WordToInt (word: WORD): INTEGER;
BEGIN
 RETURN CAST (INTEGER, word);
END WordToInt;

PROCEDURE WordToCard (word: WORD): CARDINAL;
BEGIN
 RETURN CAST (CARDINAL, word);
END WordToCard;

PROCEDURE WordToBitset ( word: WORD): BITSET;
BEGIN
 RETURN CAST (BITSET, word);
END WordToBitset;

PROCEDURE WordToLInt (word: WORD): LONGINT;
BEGIN
 RETURN CAST (LONGINT, word);
END WordToLInt;

PROCEDURE WordToLCard (word: WORD): LONGCARD;
BEGIN
 RETURN CAST (LONGCARD, word);
END WordToLCard;

PROCEDURE WordToAddr (word: WORD): ADDRESS;
BEGIN
 RETURN CAST (ADDRESS, word);
END WordToAddr;


END MagicSys.
