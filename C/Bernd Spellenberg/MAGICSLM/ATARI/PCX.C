/* MagicSLM - PCX Modul                        */
/* by Bernd Spellenberg & Harald Sch”nfeld     */
/* (c) Maxon 1995                              */

#include <stdio.h>
#include <string.h>

extern char OutPath[255];       /* Ausgabepfad */
extern long CurrPageNo;        /* Seitennummer */

/* Schreiben des Seitenbuffers als PCX File    */

void PcxWrite (unsigned char *Src, long SrcWidth,
               long SrcHeight)
{
   FILE *PCX_FH;         /* Ausgabe Filehandle */
   int PCX_Count,       /* Z„hler fr LastChar */
       PCX_LastChar; /* Letztes gelesenes Byte */
   long PCX_i,PCX_j;        /* x-y Koordinaten */
   unsigned char PCX_Buffer[128], /* Wandelbuff*/
       *PCX_Ptr;  /* Zeiger auf akt. Inputpos. */
   
   char PcxFileName[255], /* Ausgabepfad mit NR*/
       *NamePtr,        /* Zeiger auf Filename */
       FileName[10];        /* Reiner Filename */
  
   /* Ausgabepfad kopieren und reinen Filename */
                                     /* suchen */
   strcpy(PcxFileName,OutPath);
   if(!(NamePtr=strrchr(PcxFileName,'\\')))
      NamePtr=PcxFileName+1;
   NamePtr++;
   
              /* Filename auf 5 Zeichen krzen */
   NamePtr[5]=0;
   if(NamePtr=strrchr(NamePtr,'.'))
      NamePtr[0]=0;  
   
         /* Seitennummer und Extension anfgen */
   sprintf (FileName, "%03ld.pcx", CurrPageNo+1);
   strcat(PcxFileName,FileName);

                                /* File ”ffnen */
   if (!(PCX_FH=fopen (PcxFileName, "wb"))) {
      return;
   }

            /* PCX Header setzen und schreiben */
   memset (PCX_Buffer, 0, 128);
   PCX_Buffer[0] = 0xa;
   PCX_Buffer[2] = 1;
   PCX_Buffer[3] = 1;
   PCX_Buffer[8] = (SrcWidth*8-1)&255;
   PCX_Buffer[9] = (SrcWidth*8-1)>>8;
   PCX_Buffer[10] = (SrcHeight-1)&255;
   PCX_Buffer[11] = (SrcHeight-1)>>8;
   PCX_Buffer[12] = PCX_Buffer[14] = 300&255;
   PCX_Buffer[13] = PCX_Buffer[15] = 300>>8;
   PCX_Buffer[65] = 1;
   PCX_Buffer[66] = SrcWidth&255;
   PCX_Buffer[67] = SrcWidth>>8;
   PCX_Buffer[68] = 1;

   fwrite (PCX_Buffer, 1, 128, PCX_FH);

       /* Zeilenweise durch Seitenbuffer gehen */

   for (PCX_i = 0; PCX_i < SrcHeight; PCX_i++) {
                     
                     /* Zeilenanfang ermitteln */
      PCX_Ptr = Src+PCX_i*SrcWidth;
      PCX_LastChar = -1;  /* Merker und Z„hler */
      PCX_Count = 0;           /* zurcksetzen */

               /* Fr jedes Byte der Zeile ... */
      for (PCX_j = 0; PCX_j < SrcWidth; PCX_j++,
                                     PCX_Ptr++) {
         /* Falls aktuelles Byte gleich letztem*/
         if (*PCX_Ptr == PCX_LastChar) {
            PCX_Count++;     /* Z„hler erh”hen */

            if (PCX_Count == 63) {      /* 63? */
          /* Z„hler und Byte in File schreiben */
               fputc (PCX_Count+64+128, PCX_FH);
               fputc (~PCX_LastChar, PCX_FH);

               PCX_Count = 0;  /* Zurcksetzen */
               PCX_LastChar = -1;
            }
            
         } else {                     /* sonst */
        /* falls nicht das erste gelesene Byte */
            if (PCX_LastChar != -1) {
            
  /* Falls Byte verpackt werden muss oder mehr */
                 /* als einmal aufgetreten ist */
               if (((PCX_LastChar^255)>=(128+64))
                            || (PCX_Count > 1)) {
          /* Z„hler und Byte in File schreiben */
                  fputc (PCX_Count+64+128, PCX_FH);
                  fputc (~PCX_LastChar, PCX_FH);
               } else {
                   /* sonst nur Byte schreiben */
                  fputc (~PCX_LastChar, PCX_FH);
               }
            }
                      /* Aktuelles Byte merken */
            PCX_LastChar = *PCX_Ptr;
            PCX_Count = 1;
         }
      }

                     /* Letztes Byte schreiben */
      if (PCX_LastChar != -1) {
         if (((PCX_LastChar^255) >= (128+64)) 
                           || (PCX_Count > 1)) {
            fputc (PCX_Count+64+128, PCX_FH);
            fputc (~PCX_LastChar, PCX_FH);
         } else {
            fputc (~PCX_LastChar, PCX_FH);
         }
      }
   }

   fclose (PCX_FH);  /* Ausgabefile schliessen */
}