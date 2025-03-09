/* MagicSLM - File Input Modul                 */
/* by Bernd Spellenberg & Harald Schînfeld     */
/* (c) Maxon 1995                              */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define BUFFSIZE  10240L   /* Grîûe des File   */
                           /* Buffers          */
                           
/* Hilfsfunkt. zur Abfrage ob Button gedrÅckt  */
extern int CheckButton(void);

extern FILE *InputFH;      /* Input Filehandle */

/* File Buffer                                 */
static unsigned char buffer[BUFFSIZE];
/* Zeiger auf nÑchstes zu lesende Zeichen      */
static long Counter = BUFFSIZE,
/* Zeiger auf das letzte Zeichen des Files     */
            EndPtr=BUFFSIZE+1;
            
int    FileEndFlag = 0;    /* Fileende erreicht*/


/* NÑchstes Zeichen aus File lesen             */

int GetNextByte (void)
{
   long Read;           /* gelesene Bytes      */
   int Button;          /* gedrÅckter Button   */
   
   if (Counter == BUFFSIZE) {
      Counter = 0;
      
      Button=CheckButton();   /* Wenn Button   */
      if (Button)             /* gwÑhlt,       */
         return Button;       /* abbrechen     */
         
      Read = fread(buffer, 1, BUFFSIZE, InputFH);
      if (Read < BUFFSIZE) {
         EndPtr = Read;
      }
   }
   
   if (Counter >= EndPtr-1) { /* Fileende      */
      FileEndFlag = 1;
   }
   
   return (int)buffer[Counter++];
}


/* Filepointer zurÅcksetzen                    */

void InitFile(void)
{
   Counter = BUFFSIZE;
   EndPtr=BUFFSIZE+1;
}