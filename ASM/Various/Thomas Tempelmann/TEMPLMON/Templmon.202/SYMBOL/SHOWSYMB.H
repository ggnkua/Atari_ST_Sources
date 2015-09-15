#ifndef __SYMBOL__
#define __SYMBOL__

#include <tos.h>
#include <portab.h>

#define SYMBOL_COOKIE   0x53594D42L     /* Cookie-Jar-Name "SYMB" */

#define DATA_MASK   0x80                /* Maske fÅr Bit 7 */
#define TEXT_MASK   0x40                /* Maske fÅr Bit 6 */
#define BSS_MASK    0x20                /* Maske fÅr Bit 5 */
#define SIZE_MASK   0x1F                /* Maske fÅr Bit 4-0 */
#define	SYSTEM_MASK	(DATA_MASK + TEXT_MASK + BSS_MASK)

/*********************************************/
/* Diese Struktur existiert fÅr jedes Symbol */
/*********************************************/
typedef struct SYMBOL
{
    LONG    Value;      /* Wert des Symbols */
    BYTE    Type;       /* Type-Byte / Grîûen-Byte */
    BYTE    Name [];    /* Symbolname (0-terminiert) */
} Symbol;

/*******************************************************/
/* Diese Struktur wird fÅr jede Symboltabelle angelegt */
/*******************************************************/
typedef struct SYMBOLHEADER
{
    char    ProgramName [15];   /* Programmname (0-terminiert) */

    char    reserved;

    WORD    SymbolCount;        /* Anzahl der Symbole (TEXT, DATA, BSS) */
    WORD    FirstData;          /* Index des ersten DATA-Symbols */
    WORD    FirstBss;           /* Index des ersten BSS-Symbols */

    WORD    *SymbolValues;      /* Zeiger auf die Werte-Offset-Tabelle */
    WORD    *SymbolNames;       /* Zeiger auf die Namen-Offset-Tabelle */
    Symbol  *SymbolData;        /* Zeiger auf die Symboldaten */

    LONG    FirstAddress;       /* TEXT-Segment-Start */
    LONG    LastAddress;        /* BSS-Segment-Start + BSS-Segment-Grîûe */
    BASPAG  *Basepage;          /* Zeiger auf die Basepage des Programms */

    struct SYMBOLHEADER *Next;  /* Zeiger auf die nÑchste Struktur */
} SymbolHeader;

/***************************************************************/
/* Auf diese Struktur zeigt der Cookie-Wert des Cookies "SYMB" */
/***************************************************************/
typedef struct SYMBOLCOOKIE
{
    BYTE    Version;                /* Aktuelle Versionsnummer des Treibers */
    BYTE    Revision;               /* Aktuelle Revisionsnr. des Treibers */
    WORD    reserved;
    SymbolHeader    *First;         /* Zeiger auf die erste Symbol-Struktur */
    long    (*GetSymbolName) ();    /* Zeiger auf die 1. Routine */
    long    (*GetSymbolValue) ();   /* Zeiger auf die 2. Routine */
    long    (*AddSymbolTable) ();   /* Zeiger auf die 3. Routine */
    long    (*RemoveSymbolTable) (); /* Zeiger auf die 4. Routine */
} SymbolCookie;

/*******************************************************/
/* Dies sind die Prototypen der Routinen von SUBROUT.S */
/*******************************************************/
LONG GetSymbolName  (SymbolCookie *Start, LONG Address, Symbol **Data,
                    SymbolHeader **Header);

LONG GetSymbolValue (SymbolCookie *Start, char *SymbolName, char *ProgramName,
                    Symbol **Data, SymbolHeader **Header);

LONG AddSymbolTable (SymbolCookie *Start, char *ProgramPath, BASPAG *Basepage);

LONG RemoveSymbolTable (SymbolCookie *Start, char *ProgramName);

#endif
