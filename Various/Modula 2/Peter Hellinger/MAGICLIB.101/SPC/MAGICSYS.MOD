(*#######################################################################

  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ˇ         ˇ            ˇ    ˇ          ˇ
########################################################################

  MAGICSYS      System-SpezialitÑten
                Dieses Modul soll InkompatibilitÑten zwischen den einzel-
                nen Compilern aufheben.

                Implementation fÅr LPR-Modula-2

#########################################################################
  V1.01 18.06.90  Peter Hellinger       Anpassungen an das neue DEF
  V1.00    (c) by Peter Hellinger
#######################################################################*)

IMPLEMENTATION MODULE MagicSys;


FROM SYSTEM IMPORT BYTE, WORD, ADDRESS, VAL;


VAR     cast:   RECORD
                 CASE : CARDINAL OF
                  0:    addr:   ADDRESS;|
                  1:    lint:   LONGINT;|
                  2:    lcard:  LONGCARD;|
                  3:    ih:     INTEGER;
                        il:     INTEGER;|
                  4:    ch:     CARDINAL;
                        cl:     CARDINAL;|
                  5:    sh:     BITSET;
                        sl:     BITSET;|
                  6:    wh:     WORD;
                        wl:     WORD;|
                  7:    z1:     CHAR;
                        z2:     CHAR;
                        z3:     CHAR;
                        z4:     CHAR;|
                  8:    b1:     BYTE;
                        b2:     BYTE;
                        b3:     BYTE;
                        b4:     BYTE;|
                  9:    dummy:  LONGCARD;
                 END;
                END;
                  


PROCEDURE ByteToChar (byte: BYTE): CHAR;
BEGIN
 cast.dummy:= 0;  cast.b4:= byte;  RETURN cast.z4;
END ByteToChar;

PROCEDURE ByteToInt (byte: BYTE): INTEGER;
BEGIN
 cast.dummy:= 0;  cast.b4:= byte;  RETURN cast.il;
END ByteToInt;

PROCEDURE ByteToCard (byte: BYTE): CARDINAL;
BEGIN
 cast.dummy:= 0;  cast.b4:= byte;  RETURN cast.cl;
END ByteToCard;

PROCEDURE ByteToBitset (byte: BYTE): BITSET;
BEGIN
 cast.dummy:= 0;  cast.b4:= byte;  RETURN cast.sl;
END ByteToBitset;

PROCEDURE ByteToLInt (byte: BYTE): LONGINT;
BEGIN
 cast.dummy:= 0;  cast.b4:= byte;  RETURN cast.lint;
END ByteToLInt;

PROCEDURE ByteToLCard (byte: BYTE): LONGCARD;
BEGIN
 cast.dummy:= 0;  cast.b4:= byte;  RETURN cast.lcard;
END ByteToLCard;

PROCEDURE ByteToAddr (byte: BYTE): ADDRESS;
BEGIN
 cast.dummy:= 0;  cast.b4:= byte;  RETURN cast.addr;
END ByteToAddr;

PROCEDURE ByteToWord (byte: BYTE): WORD;
BEGIN
 cast.dummy:= 0;  cast.b4:= byte;  RETURN cast.wl;
END ByteToWord;



PROCEDURE CharToByte (char: CHAR): BYTE;
BEGIN
 cast.dummy:= 0;  cast.z4:= char;  RETURN cast.b4;
END CharToByte;

PROCEDURE CharToInt (char: CHAR): INTEGER;
BEGIN
 cast.dummy:= 0;  cast.z4:= char;  RETURN cast.il;
END CharToInt;

PROCEDURE CharToCard (char: CHAR): CARDINAL;
BEGIN
 cast.dummy:= 0;  cast.z4:= char;  RETURN cast.cl;
END CharToCard;

PROCEDURE CharToBitset (char: CHAR): BITSET;
BEGIN
 cast.dummy:= 0;  cast.z4:= char;  RETURN cast.sl;
END CharToBitset;

PROCEDURE CharToLInt (char: CHAR): LONGINT;
BEGIN
 cast.dummy:= 0;  cast.z4:= char;  RETURN cast.lint;
END CharToLInt;

PROCEDURE CharToLCard (char: CHAR): LONGCARD;
BEGIN
 cast.dummy:= 0;  cast.z4:= char;  RETURN cast.lcard;
END CharToLCard;

PROCEDURE CharToAddr (char: CHAR): ADDRESS;
BEGIN
 cast.dummy:= 0;  cast.z4:= char;  RETURN cast.addr;
END CharToAddr;

PROCEDURE CharToWord (char: CHAR): WORD;
BEGIN
 cast.dummy:= 0;  cast.z4:= char;  RETURN cast.wl;
END CharToWord;


PROCEDURE IntToByte (int: INTEGER): BYTE;
BEGIN
 cast.dummy:= 0;  cast.il:= int;  RETURN cast.b4;
END IntToByte;

PROCEDURE IntToChar (int: INTEGER): CHAR;
BEGIN
 cast.dummy:= 0;  cast.il:= int;  RETURN cast.z4;
END IntToChar;

PROCEDURE IntToCard (int: INTEGER): CARDINAL;
BEGIN
 cast.dummy:= 0;  cast.il:= int;  RETURN cast.cl;
END IntToCard;

PROCEDURE IntToBitset (int: INTEGER): BITSET;
BEGIN
 cast.dummy:= 0;  cast.il:= int;  RETURN cast.sl;
END IntToBitset;

PROCEDURE IntToLInt (int: INTEGER): LONGINT;
BEGIN
 cast.dummy:= 0;  cast.il:= int;  RETURN cast.lint;
END IntToLInt;

PROCEDURE IntToLCard (int: INTEGER): LONGCARD;
BEGIN
 cast.dummy:= 0;  cast.il:= int;  RETURN cast.lcard;
END IntToLCard;

PROCEDURE IntToAddr (int: INTEGER): ADDRESS;
BEGIN
 cast.dummy:= 0;  cast.il:= int;  RETURN cast.addr;
END IntToAddr;

PROCEDURE IntToWord (int: INTEGER): WORD;
BEGIN
 cast.dummy:= 0;  cast.il:= int;  RETURN cast.wl;
END IntToWord;


PROCEDURE CardToByte (card: CARDINAL): BYTE;
BEGIN
 cast.dummy:= 0;  cast.cl:= card;  RETURN cast.b4;
END CardToByte;

PROCEDURE CardToChar (card: CARDINAL): CHAR;
BEGIN
 cast.dummy:= 0;  cast.cl:= card;  RETURN cast.z4;
END CardToChar;

PROCEDURE CardToInt (card: CARDINAL): INTEGER;
BEGIN
 cast.dummy:= 0;  cast.cl:= card;  RETURN cast.il;
END CardToInt;

PROCEDURE CardToBitset  (card: CARDINAL): BITSET;
BEGIN
 cast.dummy:= 0;  cast.cl:= card;  RETURN cast.sl;
END CardToBitset;

PROCEDURE CardToLInt (card: CARDINAL): LONGINT;
BEGIN
 cast.dummy:= 0;  cast.cl:= card;  RETURN cast.lint;
END CardToLInt;

PROCEDURE CardToLCard (card: CARDINAL): LONGCARD;
BEGIN
 cast.dummy:= 0;  cast.cl:= card;  RETURN cast.lcard;
END CardToLCard;

PROCEDURE CardToAddr (card: CARDINAL): ADDRESS;
BEGIN
 cast.dummy:= 0;  cast.cl:= card;  RETURN cast.addr;
END CardToAddr;

PROCEDURE CardToWord (card: CARDINAL): WORD;
BEGIN
 cast.dummy:= 0;  cast.cl:= card;  RETURN cast.wl;
END CardToWord;


PROCEDURE BitsetToByte (bset: BITSET): BYTE;
BEGIN
 cast.dummy:= 0;  cast.sl:= bset;  RETURN cast.b4;
END BitsetToByte;

PROCEDURE BitsetToChar (bset: BITSET): CHAR;
BEGIN
 cast.dummy:= 0;  cast.sl:= bset;  RETURN cast.z4;
END BitsetToChar;

PROCEDURE BitsetToInt (bset: BITSET): INTEGER;
BEGIN
 cast.dummy:= 0;  cast.sl:= bset;  RETURN cast.il;
END BitsetToInt;

PROCEDURE BitsetToCard (bset: BITSET): CARDINAL;
BEGIN
 cast.dummy:= 0;  cast.sl:= bset;  RETURN cast.cl;
END BitsetToCard;

PROCEDURE BitsetToLInt (bset: BITSET): LONGINT;
BEGIN
 cast.dummy:= 0;  cast.sl:= bset;  RETURN cast.lint;
END BitsetToLInt;

PROCEDURE BitsetToLCard (bset: BITSET): LONGCARD;
BEGIN
 cast.dummy:= 0;  cast.sl:= bset;  RETURN cast.lcard;
END BitsetToLCard;

PROCEDURE BitsetToAddr (bset: BITSET): ADDRESS;
BEGIN
 cast.dummy:= 0;  cast.sl:= bset;  RETURN cast.addr;
END BitsetToAddr;

PROCEDURE BitsetToWord (bset: BITSET): WORD;
BEGIN
 cast.dummy:= 0;  cast.sl:= bset;  RETURN cast.wl;
END BitsetToWord;


PROCEDURE LIntToByte (lint: LONGINT): BYTE;
BEGIN
 cast.lint:= lint;  RETURN cast.b4;
END LIntToByte;

PROCEDURE LIntToChar (lint: LONGINT): CHAR;
BEGIN
 cast.lint:= lint;  RETURN cast.z4;
END LIntToChar;

PROCEDURE LIntToInt (lint: LONGINT): INTEGER;
BEGIN
 cast.lint:= lint;  RETURN cast.il;
END LIntToInt;

PROCEDURE LIntToCard (lint: LONGINT): CARDINAL;
BEGIN
 cast.lint:= lint;  RETURN cast.cl;
END LIntToCard;

PROCEDURE LIntToBitset (lint: LONGINT): BITSET;
BEGIN
 cast.lint:= lint;  RETURN cast.sl;
END LIntToBitset;

PROCEDURE LIntToLCard (lint: LONGINT): LONGCARD;
BEGIN
 cast.lint:= lint;  RETURN cast.lcard;
END LIntToLCard;

PROCEDURE LIntToAddr (lint: LONGINT): ADDRESS;
BEGIN
 cast.lint:= lint;  RETURN cast.addr;
END LIntToAddr;

PROCEDURE LIntToWord (lint: LONGINT): WORD;
BEGIN
 cast.lint:= lint;  RETURN cast.wl;
END LIntToWord;


PROCEDURE LCardToByte (lcard: LONGCARD): BYTE;
BEGIN
 cast.lcard:= lcard;  RETURN cast.b4;
END LCardToByte;

PROCEDURE LCardToChar (lcard: LONGCARD): CHAR;
BEGIN
 cast.lcard:= lcard;  RETURN cast.z4;
END LCardToChar;

PROCEDURE LCardToInt (lcard: LONGCARD): INTEGER;
BEGIN
 cast.lcard:= lcard;  RETURN cast.il;
END LCardToInt;

PROCEDURE LCardToCard (lcard: LONGCARD): CARDINAL;
BEGIN
 cast.lcard:= lcard;  RETURN cast.cl;
END LCardToCard;

PROCEDURE LCardToBitset (lcard: LONGCARD): BITSET;
BEGIN
 cast.lcard:= lcard;  RETURN cast.sl;
END LCardToBitset;

PROCEDURE LCardToLInt (lcard: LONGCARD): LONGINT;
BEGIN
 cast.lcard:= lcard;  RETURN cast.lint;
END LCardToLInt;

PROCEDURE LCardToAddr (lcard: LONGCARD): ADDRESS;
BEGIN
 cast.lcard:= lcard;  RETURN cast.addr;
END LCardToAddr;

PROCEDURE LCardToWord (lcard: LONGCARD): WORD;
BEGIN
 cast.lcard:= lcard;  RETURN cast.wl;
END LCardToWord;


PROCEDURE AddrToByte (addr: ADDRESS): BYTE;
BEGIN
 cast.addr:= addr;  RETURN cast.b4;
END AddrToByte;

PROCEDURE AddrToChar (addr: ADDRESS): CHAR;
BEGIN
 cast.addr:= addr;  RETURN cast.z4;
END AddrToChar;

PROCEDURE AddrToInt (addr: ADDRESS): INTEGER;
BEGIN
 cast.addr:= addr;  RETURN cast.il;
END AddrToInt;

PROCEDURE AddrToCard (addr: ADDRESS): CARDINAL;
BEGIN
 cast.addr:= addr;  RETURN cast.cl;
END AddrToCard;

PROCEDURE AddrToBitset (addr: ADDRESS): BITSET;
BEGIN
 cast.addr:= addr;  RETURN cast.sl;
END AddrToBitset;

PROCEDURE AddrToLInt (addr: ADDRESS): LONGINT;
BEGIN
 cast.addr:= addr;  RETURN cast.lint;
END AddrToLInt;

PROCEDURE AddrToLCard (addr: ADDRESS): LONGCARD;
BEGIN
 cast.addr:= addr;  RETURN cast.lcard;
END AddrToLCard;

PROCEDURE AddrToWord (addr: ADDRESS): WORD;
BEGIN
 cast.addr:= addr;  RETURN cast.wl;
END AddrToWord;


PROCEDURE WordToByte (word: WORD): BYTE;
BEGIN
 cast.dummy:= 0;  cast.wl:= word;  RETURN cast.b4;
END WordToByte;

PROCEDURE WordToChar (word: WORD): CHAR;
BEGIN
 cast.dummy:= 0;  cast.wl:= word;  RETURN cast.z4;
END WordToChar;

PROCEDURE WordToInt (word: WORD): INTEGER;
BEGIN
 cast.dummy:= 0;  cast.wl:= word;  RETURN cast.il;
END WordToInt;

PROCEDURE WordToCard (word: WORD): CARDINAL;
BEGIN
 cast.dummy:= 0;  cast.wl:= word;  RETURN cast.cl;
END WordToCard;

PROCEDURE WordToBitset (word: WORD): BITSET;
BEGIN
 cast.dummy:= 0;  cast.wl:= word;  RETURN cast.sl;
END WordToBitset;

PROCEDURE WordToLInt (word: WORD): LONGINT;
BEGIN
 cast.dummy:= 0;  cast.wl:= word;  RETURN cast.lint;
END WordToLInt;

PROCEDURE WordToLCard (word: WORD): LONGCARD;
BEGIN
 cast.dummy:= 0;  cast.wl:= word;  RETURN cast.lcard;
END WordToLCard;

PROCEDURE WordToAddr (word: WORD): ADDRESS;
BEGIN
 cast.dummy:= 0;  cast.wl:= word;  RETURN cast.addr;
END WordToAddr;


END MagicSys.
