/* Routinen zur Konvertierung von Rohdaten   */
/* Modulname:  RAW.C                         */
/* (c) MAXON Computer 1994                   */
/* Autoren:    H. Sch”nfeld, B. Spellenberg  */

# include "vlun.h"

/* Bestimmung des Inputformates fr Header-  */
/* lose Rohdaten --- Minimalbeispiel         */
/* Jedes unbekannte File wird als Rohdaten-  */
/* file akzeptiert.                          */
int RawSetHead(FILE *InFH, SAMPLE_SPEC *Smp)
{
/* Soundformatbeschreibung initialisieren    */
   memset(Smp,0,sizeof(SAMPLE_SPEC));

   Smp->Typ=RAWDATA;

/* Hier k”nnte man die n”tigen Parameter     */
/* interaktiv vom Benutzer erfragen          */
   Smp->Freq=8195;
   Smp->Format=SIGNED;
   Smp->SizeFac=1;
   
/* Gr”ženverh„ltnisse entsprechend dem Format*/
/* bestimmen                                 */
   if(!(Smp->Format&STEREO))
      Smp->SizeFac*=2;
   if(!(Smp->Format&BIT16))
      Smp->SizeFac*=2;
   
   Smp->BufLen=BUFSIZE;
   
   return(SUPPORTED);
}

/* Std.format nach Rohdaten konvertieren     */
long RawFromStd(FILE *OutFH,OUT_FORMAT *OutSmp,
                  long DataLen, char *StdBuf)
{
/* Deltapack nicht allgemein blich          */
   OutSmp->Format&=~DELTAPACK;

/* Mulaw wird als signed betrachtet          */
   if(OutSmp->Format&MULAW)
      OutSmp->Format|=SIGNED;
      
/* n„chsten Block konvertieren und speichern */
   return(AllFromStd(OutFH,OutSmp,
                              DataLen,StdBuf));
}
