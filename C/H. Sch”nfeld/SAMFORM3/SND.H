/* SND Headerfile zur SND Konvertierung      */
/* Modulname:  SND.H                         */
/* (c) MAXON Computer 1994                   */
/* Autoren:    H. Schînfeld, B. Spellenberg  */

typedef struct
{
   long magic;        /* Headerkennung       */
   long datalocation; /* Sampledaten Beginn  */
   long datasize;     /* DatenlÑnge in Bytes */
   long dataformat;   /* Datenformat s.u.    */
   long samplingrate; /* Frequenz            */
   long channelcount; /* Kanalanzahl         */
   char info[4];      /* optionale Info      */
} SNDHEAD;

/* Mîgliche Datenformate fÅr VLUN            */
# define SND_FORMAT_MULAW_8   1
# define SND_FORMAT_LINEAR_8  2
# define SND_FORMAT_LINEAR_16 3

