/* WAV Headerfile zur WAV Konvertierung      */
/* Modulname:  WAV.H                         */
/* (c) MAXON Computer 1994                   */
/* Autoren:    H. Schînfeld, B. Spellenberg  */

/* Def. von UBYTE, UWORD, ULONG              */
# include <portab.h>

/* Sounddaten Format-Chunk                   */
typedef struct
{
   int format;       /* Format siehe unten   */
   int channels;     /* Anzahl der KanÑle    */
   long frequency;   /* Frequenz             */
   long average;     /* Bytes pro Sekunde    */
   int align;        /* Blockalignment       */
   int bps;          /* Bits per Sample      */
} FORMATCHUNK;

/* Chunk-Struktur                            */
typedef struct
{
   char name[4];     /* Chunk Name           */
   long len;         /* Chunk LÑnge          */
} CHUNK;

/* UnterstÅtzte(s) WAV Soundformat           */
# define WAVE_FORMAT_PCM   0x0001

/* Makros zum Konvertieren des Intel-Formats */
# define i_int(x)    (*((UBYTE *)&(x)) +      \
                     (((UWORD)*((UBYTE *)     \
                     (&(x))+1))<<8))
# define i_long(x)   (*((UBYTE *)&(x)) +      \
                     (((ULONG)*((UBYTE *)     \
                     (&(x))+1))<<8) +         \
                     (((ULONG)*((UBYTE *)     \
                     (&(x))+2))<<16) +        \
                     (((ULONG)*((UBYTE *)     \
                     (&(x))+3))<<24))

/* Prototypen der lokalen Hilfsfunktionen    */
long SearchChunk(char *, FILE *);
void ConvFmtChunk (FORMATCHUNK *);