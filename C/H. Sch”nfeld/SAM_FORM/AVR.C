/* AVR Routinen zur AVR Konvertierung        */
/* Modulname:  AVR.C                         */
/* (c) MAXON Computer 1994                   */
/* Autoren:    H. Schînfeld, B. Spellenberg  */

# include "vlun.h"
# include "avr.h"

/* ZÑhler fÅr geschriebene Sound-Bytes       */
static long ByteCount=0L;
/* Header fÅr Input und Export               */
static AVRHEAD AvrHead;

/* AVR-Headertest-Funktion                   */
int AvrTstHead(FILE *InFH, SAMPLE_SPEC *Smp)
{
/* Soundformatbeschreibung initialisieren    */
   memset(Smp,0,sizeof(SAMPLE_SPEC));

/* AVR-Header lesen und testen               */
   if(!fread(&AvrHead,sizeof(AVRHEAD),1L,InFH))
      return(UNKNOWN);
   if(strncmp(&AvrHead.magic,"2BIT",4))
      return(UNKNOWN);

/* Header auswerten und Formatbeschreibung   */
/* aufbauen                                  */
   Smp->Typ=AVRHEADER;
   Smp->Freq=0xFFFFFFL&AvrHead.speed;
   Smp->SizeFac=1;

   if(AvrHead.mode==-1)
      Smp->Format|=STEREO;
   else
      Smp->SizeFac*=2;

   if(AvrHead.resolution==16)
      Smp->Format|=BIT16|BIGENDIAN;
   else if(AvrHead.resolution==8)
      Smp->SizeFac*=2;
   else
      return(NOT_SUPPORTED);

   if(AvrHead.sign==-1)
      Smp->Format|=SIGNED;

   Smp->BufLen=BUFSIZE;
      
   return(SUPPORTED);
}

/* Std.format nach AVR konvertieren          */
long AvrFromStd(FILE *OutFH,OUT_FORMAT *OutSmp,
                  long DataLen, char *StdBuf)
{
   long DataWrite;
   
/* Mu-law und Deltapack werden von AVR nicht */
/* unterstÅtzt                               */
   OutSmp->Format&=~(MULAW|DELTAPACK);

/* 16Bit Samples immer im Motorolaformat     */
   if(OutSmp->Format&BIT16)
      OutSmp->Format|=BIGENDIAN;
   
/* nÑchsten Block konvertieren und speichern */
   DataWrite=AllFromStd(OutFH,OutSmp,
                        DataLen,StdBuf);

/* BytezÑhler entsprechend erhîhen           */
   ByteCount+=DataWrite;
   
   return(DataWrite);
}

/* AVR-Header setzen und schreiben           */
int AvrWrtHead(FILE *OutFH,SAMPLE_SPEC *InSmp,
               OUT_FORMAT *OutSmp)
{
   int Fmt;

   Fmt=OutSmp->Format;  
   memset(&AvrHead,0,sizeof(AVRHEAD));
   
   strcpy(&AvrHead.magic,"2BIT");
   
   AvrHead.mode=(Fmt&STEREO)?0xffff:0;
   AvrHead.resolution=(Fmt&BIT16)?16:8;
   AvrHead.sign=(Fmt&SIGNED)?0xffff:0;
   AvrHead.speed=0xFF000000L|InSmp->Freq;
   AvrHead.note=0xffff;
   
   return(fwrite(&AvrHead,sizeof(AVRHEAD),
                                    1,OutFH));
}

/* Fehlende Information in AVR-Header        */
/* schreiben                                 */
int AvrFinish(FILE *OutFH,OUT_FORMAT *OutSmp)
{
   
/* Anzahl der Samplepunkte bestimmen         */
   AvrHead.len=ByteCount;
   if(OutSmp->Format&BIT16)
      AvrHead.len/=2;
   AvrHead.end_loop=AvrHead.len;

/* BytezÑhler fÅr evtl. neue Wandlung        */
/* zurÅcksetzen                              */
   ByteCount=0;

/* kompletten Header an Fileanfang schreiben */
   fseek(OutFH,0L,0);
   return(fwrite(&AvrHead,sizeof(AVRHEAD),
                                       1,OutFH));
}