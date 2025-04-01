#include "stdio.h"


#define FILEN    175000                  /* Anzahl CHARs in ary[].  */

/*-----Global declarations------------------------------------------*/

char ary[FILEN];                     /* Puffer fÅr source file.     */


/*-----Funktionsdeklarationen---------------------------------------*/

void main(int argc, char *argv[]);
unsigned int crc_16(unsigned char *start_ptr, long len);
unsigned int crc_update(unsigned int crc, unsigned char c);


/*-----Funktionsdefinitionen----------------------------------------*/


unsigned int crc_16(unsigned char *start_ptr, long len)
/*********************************************************************
**                                                                  **
** Berechnet ein 16 bit CRC Wort fuer den Speicherblock, welcher an **
** der Stelle "start" beginnt und "len" Bytes lang ist. crc_16()    **
** verwendet die Funktion crc_update(), welche ein von CCITT emp-   **
** fohlenes Generatorpolynom vom Grad 16 benutzt.                   **
**                                                                  **
*********************************************************************/
{


unsigned int crc;       /* crc beherbergt das Restpolynom r(x) und  */
                        /* mu· 16bit breit sein, damit das Resultat */
                        /* vollstaendig aufgenommen werden kann.    */

/*------Starte CRC-Berechnung---------------------------------------*/

crc = 0;

while(len-- != 0)      /* Fuehre CRC-Berechnung solange durch, bis */
{                       /* alle Bytes abgearbeitet sind.            */

   crc = crc_update(crc, *start_ptr++);    /* Bearbeite ein Byte.       */
}

return(crc_update(crc_update(crc,'\0'),'\0'));/* Haenge 16 Nullen an*/
                                              /* fuer korrektes Re- */
                                              /* sultat (Entspricht */
                                              /* der Multiplikation */
                                              /* (x^16)*p(x).       */
}



unsigned int crc_update(unsigned int crc, unsigned char c)
/*********************************************************************
**                                                                  **
** Kernroutine fÅr CRC-Berechnung. Hier werden 8 aufeinanderfolgende**
** Schritte einer Polynomdivision im Galois-Koerper GF(2) mit Hilfe **
** des Generatorpolynoms g(x) = x^16 + x^12 + x^5 + 1 vorgenommen.  **
** Die einzelnen Rechenschritte bestehen aus EXOR-Operationen.      **
**                                                                  **
*********************************************************************/
{

unsigned long x;               /* Puffervariable zur Aufnahme der   */
                               /* Zwischenergebnisse.               */
int i;                         /* Schleifenzaehler.                 */

x = ((unsigned long)crc << 8) + (unsigned long)c;

/*-----FÅhre 8 EXOR-Schritte durch----------------------------------*/

for (i=0; i<8; i++)
{
   x = x << 1;

/*-----Falls erstes Bit des Dividenden 1 ist, fuehre EXOR-----------*/
/*-----Operation mit g(x) durch, ansonsten EXOR-Operation-----------*/
/*-----mit Nullen, d.h. keine Veraenderung.-------------------------*/

   if ((x & 0x01000000) != 0)
   {
      x = x ^ 0x01102100;      /* g(x) ist x^16+x^12+x^5+1 und ist  */
   }                           /* 8 bits nach links verschoben.     */
}

/*-----Blende Ergebnis aus und gib es als 16bit-Variable zurÅck-----*/

return((unsigned int)((x & 0x00ffff00) >> 8));
}


void main(int argc, char *argv[])
/*********************************************************************
**                                                                  **
** Mini-Testtreiber fÅr CRC-Berechnungsroutine. Dient lediglich     **
** zur Demonstration des Gebrauchs von crc_16().                    **
**                                                                  **
*********************************************************************/

{
 FILE *fin_ptr;                    /* File pointer auf input file.  */
 char ch_buffer;                   /* Zwischenpuffer.               */
 char eof_flag;                    /* = 1 bei EOF, ansonsten = 0.   */
 long i;                           /* ZÑhlervariable fÅr FilelÑnge. */
 unsigned int result;              /* CRC-Ergebnis.                 */


/*-------PrÅfe korrekte Input Syntax------------------------------------*/

 if (argc != 2)                        /* Zahl der Argumente in main(). */
 {
    printf("\nAnwendung : crc <input-file>\n");
    printf("Press return to go back to desktop\n");
    getchar();
    exit(1);
 }


/*------ ôffne Input File ----------------------------------------------*/

 fin_ptr = fopen(argv[1],"r");           /* ôffne Input File zum Lesen. */

 if (fin_ptr == NULL)
 {
    printf("\nCannot open input file. fopen() failed in main().\n");
    printf("Press return to go back to desktop\n");
    getchar();
    exit(1);
 }

/*----- Lese Source File------------------------------------------------*/

 for (i=0; i<FILEN; i++)
 {
    ary[i] = ' ';              /* Initialisiere array ary[] mit Blanks.  */
 }

 ary[FILEN-1] = '\0';         /* Kennzeichne Ende des arrays mit '\0'.   */

 ch_buffer  = (char)getc(fin_ptr); /* Lese ersten Character.             */
 i          = 0;                   /* Initialisiere ZÑhler fÅr FilelÑnge.*/
 eof_flag   = 0;                   /* Setze eof_flag auf "no EOF" zurÅck.*/

 while ((ary[i] != '\0') && ( feof(fin_ptr) == 0 ))
 {
    ary[i] = ch_buffer;
    i++;
    ch_buffer      = (char)getc(fin_ptr);    /* Lese nÑchsten Character. */

    if ( feof(fin_ptr) != 0)
    {
       eof_flag = 1;                  /* Setze eof_flag auf "EOF found". */
    }
 }

 if (eof_flag == 0)
 {
    printf("\nInput file is too large for input buffer ary[]\n");
    (void)fclose(fin_ptr);
    exit(1);
 }
 (void)fclose(fin_ptr);                         /* Schlie·e Input File.  */

 result = crc_16(ary,i);

 printf("%x\n",result);
 printf("Press return to go back to desktop\n");
 
 getchar();

}
