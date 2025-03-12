/* VLUN Minimal-Rahmenprogramm               */
/* Modulname:  VLUN.C                        */
/* (c) MAXON Computer 1994                   */
/* Autoren:    H. Schînfeld, B. Spellenberg  */

# include "vlun.h"

/* Struktur mit Zeigern auf sÑmtliche zur
   Wandlung eines Formats nîtigen Routinen   */
typedef struct 
{
   HEAD_FUNC      *TstHead;
   READ_FUNC      *ToStd;
   WRITE_FUNC     *FromStd;
   WRT_HEAD_FUNC  *WrtHead;
   FINISH_FUNC    *Finish;
   char           *FmtName;
} FMT_FUNCTION;

/* Liste mit den Wandelfunktionen fÅr alle
   unterstÅtzen Formate                      */
FMT_FUNCTION CnvFuncs[] =
{
   { AvrTstHead, AllToStd, AvrFromStd,
     AvrWrtHead, AvrFinish, "AVR-Format" },
   { SndTstHead, AllToStd, SndFromStd,
     SndWrtHead, SndFinish, "SND-Format" },
   { DvsTstHead, DvsToStd, DvsFromStd,
     DvsWrtHead, 0L, "DVSM-Format" },
   { WavTstHead, WavToStd, WavFromStd,
     WavWrtHead, WavFinish, "WAVE-Format" },
   { RawSetHead, AllToStd, RawFromStd,
     0L, 0L, "Raw-Format" },
   { 0L, 0L, 0L, 0L, 0L, 0L}
};

   
SAMPLE_SPEC InSmp;   /* Input-File Format    */
OUT_FORMAT  OutSmp;  /* Export-File Format   */

/* Minimal Beispiel Rahmenprogramm ohne
   Benutzerinterface zur Demonstration der
   Anwendung der Wandel-Routinen             */
int main(void)
{
/* Komplette Pfade fÅr Input und Export File
   mit Extension                             */
   char  InFileName[128],
         OutFileName[128];
/* Std. C Filehandles fÅr Input/Export Files */
   FILE  *InFileH,
         *OutFileH;
/* Resultat des Header-Tests fÅr Format Fmt  */
   int   TstRes,
/* IndexzÑhler fÅr Liste der Wandelfunktionen*/
         Fmt;
/* Grîûe des Wandelbuffers in Byte           */
   long  StdBufLen,
/* Grîûe der gelesenen Daten im Std. Format  */
         Read;
/* Zeiger auf Wandelbuffer                   */
   char  *StdBuf;
   
/* Festlegen des Input/Export Filenamens und
   des Exportformats.
   In eigenen Progs. z.B. Eingabe per Dialog
   oder Kommandozeile.                       */

   strcpy(InFileName,"in.avr");
   strcpy(OutFileName,"out.wav");
   OutSmp.Typ=WAVHEADER;
   OutSmp.Format=STEREO|SIGNED|BIT16;

/* Input-File îffnen                         */ 
   InFileH=fopen(InFileName,"rb");
   if(!InFileH)
   {
      puts("Kann Inputfile nicht îffnen");
      exit(1);
   }

/* Export-File îffnen                        */
   OutFileH=fopen(OutFileName,"wb");
   if(!OutFileH)
   {
      puts("Kann Outputfile nicht îffnen");
      fclose(InFileH);
      exit(1);
   }

/* FÅr alle Formate in der Wandelliste den
   Header-Test aufrufen bis Format erkannt
   wird                                      */
   for(Fmt=0;CnvFuncs[Fmt].TstHead;Fmt++)
   {
/* Vorm Header Test zum Fileanfang gehen     */
      fseek(InFileH,0L,0);
/* Testfunktion des aktuellen Format aufrufen*/
      TstRes=(*CnvFuncs[Fmt].TstHead)
               (InFileH,&InSmp);

/* Abbruch da Format erkannt, aber in dieser
   Form nicht unterstÅtzt                    */                   
      if(NOT_SUPPORTED==TstRes)
      {
         printf ("Unbekanntes %s\n",
                  *CnvFuncs[Fmt].FmtName);
         continue;
      }

/* Weiter zum nÑchsten Format-Test           */
      if(UNKNOWN==TstRes)
         continue;

/* Ansonsten Format erkannt...               */

/* LÑnge eines Blocks im Standardformat
   berechnen                                 */
      StdBufLen=InSmp.BufLen*InSmp.SizeFac;

/* DafÅr nîtigen Buffer allozieren           */
      if(!(StdBuf=malloc(StdBufLen)))
      {
         fclose(OutFileH);
         fclose(InFileH);
         puts("Nicht genÅgend Speicher");
         exit(2);
      }

/* Export-File-Format Header schreiben falls
   vorhanden                                 */
      if(CnvFuncs[OutSmp.Typ].WrtHead)
         (*CnvFuncs[OutSmp.Typ].WrtHead)
            (OutFileH,&InSmp,&OutSmp);

/* Solange nîtig Input-File blockweise laden
   und ins Standard-Format wandeln. Dann Block
   ins Export-Format wandeln und schreiben   */
      while(Read=(*CnvFuncs[Fmt].ToStd)
                  (InFileH,&InSmp,
                  StdBuf,StdBufLen))
      {
         (*CnvFuncs[OutSmp.Typ].FromStd)
            (OutFileH,&OutSmp,Read,StdBuf);
      }

/* Zusatzinformationen in Export-File schreiben
   wenn im Format vorgesehen                 */
      if(CnvFuncs[OutSmp.Typ].Finish)
         (*CnvFuncs[OutSmp.Typ].Finish)
            (OutFileH,&OutSmp);

/* Wandeln beendet                           */
      break;
   }

   free(StdBuf);
   fclose(InFileH);
   fclose(OutFileH);
   return(0);
}
