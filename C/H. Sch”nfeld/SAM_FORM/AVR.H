/* AVR Headerfile zur AVR Konvertierung      */
/* Modulname:  AVR.H                         */
/* (c) MAXON Computer 1994                   */
/* Autoren:    H. Sch”nfeld, B. Spellenberg  */

typedef struct
{
   long  magic;         /* Headerkennung     */
   char  sample_name[8];/* Filename          */
   int   mode;          /* Stereo/Mono       */
   int   resolution;    /* 8/16 Bit Aufl”sung*/
   int   sign;          /* Mit/Ohne Vorz.    */
   int   loop;          /* Looping Sample?   */
   int   note;          /* MIDI Notes?       */
   long  speed;         /* Frequenz          */
   long  len;           /* L„nge in Samples  */
   long  beg_loop;      /* Anfang der Loop   */
   long  end_loop;      /* Ende der Loop     */
   int   res1,res2,res3;
   char  extension[20]; /* Filename-Extension*/
   char  free_area[64]; /* Zusatzinfo.       */
} AVRHEAD;