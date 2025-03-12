/* SND Routinen zur SND Konvertierung        */
/* Modulname:  SND.C                         */
/* (c) MAXON Computer 1994                   */
/* Autoren:    H. Sch”nfeld, B. Spellenberg  */

# include "vlun.h"
# include "snd.h"

/* Z„hler fr geschriebene Sound-Bytes       */
static long ByteCount=0L;
/* Header fr Input und Export               */
static SNDHEAD SndHead;

/* SND-Headertest-Funktion                   */
int SndTstHead(FILE *InFH, SAMPLE_SPEC *Smp)
{
/* Soundformatbeschreibung initialisieren    */
   memset(Smp,0,sizeof(SAMPLE_SPEC));
/* SND-Header lesen und testen               */
   if(!fread(&SndHead,sizeof(SNDHEAD),1L,InFH))
      return(UNKNOWN);
   if(strncmp(&SndHead.magic,".snd",4))
      return(UNKNOWN);

/* Header auswerten und Formatbeschreibung   */
/* aufbauen                                  */
   Smp->Typ=SNDHEADER;
   Smp->Freq=SndHead.samplingrate;

   switch((int)SndHead.channelcount)
   {
      case 1:                        /* Mono */
         Smp->SizeFac=2;
         break;
      
      case 2:                      /* Stereo */
         Smp->Format|=STEREO;
         Smp->SizeFac=1;
         break;
      
      default:                  /* Unbekannt */
         return(NOT_SUPPORTED);
   }

   switch((int)SndHead.dataformat)
   {
      case SND_FORMAT_MULAW_8:
         Smp->Format|=MULAW|SIGNED;
         Smp->SizeFac*=2;
         break;
      
      case SND_FORMAT_LINEAR_8:
         Smp->Format|=SIGNED;
         Smp->SizeFac*=2;
         break;
      
      case SND_FORMAT_LINEAR_16:
         Smp->Format|=BIGENDIAN|SIGNED|BIT16;
         break;
      
      default:
         return(NOT_SUPPORTED);
   }
   Smp->BufLen=BUFSIZE;

/* Falls Sounddaten nicht nach Header folgen */
/* zum Anfang der Daten seeken               */
   if(SndHead.datalocation-sizeof(SNDHEAD)!=0)
      fseek(InFH,SndHead.datalocation,0);
   return(SUPPORTED);
}

/* Std.format nach SND konvertieren          */
long SndFromStd(FILE *OutFH,OUT_FORMAT *OutSmp,
                     long DataLen, char *StdBuf)
{
   long DataWrite;

/* Deltapack wird von SND nicht untersttzt  */
   OutSmp->Format&=~DELTAPACK;
/* Werte immer vorzeichenbehaftet            */
   OutSmp->Format|=SIGNED;
/* 16Bit Samples immer im Motorolaformat     */
   if(OutSmp->Format&BIT16)
      OutSmp->Format|=BIGENDIAN;

/* n„chsten Block konvertieren und speichern */ 
   DataWrite=AllFromStd(OutFH,OutSmp,
                        DataLen,StdBuf);

/* Bytez„hler entsprechend erh”hen           */
   ByteCount+=DataWrite;
   return(DataWrite);
}

/* SND-Header setzen und schreiben           */
int SndWrtHead(FILE *OutFH,SAMPLE_SPEC *InSmp,
               OUT_FORMAT *OutSmp)
{
   int Fmt;
   
   Fmt=OutSmp->Format;  
   memset(&SndHead,0,sizeof(SNDHEAD));
   strcpy(&SndHead.magic,".snd");
   
   SndHead.datalocation=sizeof(SNDHEAD);
   SndHead.datasize=0;

   if(Fmt&BIT16)
      SndHead.dataformat=SND_FORMAT_LINEAR_16;
   else if(Fmt&MULAW)
      SndHead.dataformat=SND_FORMAT_MULAW_8;
   else
      SndHead.dataformat=SND_FORMAT_LINEAR_8;

   SndHead.samplingrate=InSmp->Freq;

   if(Fmt&STEREO)
      SndHead.channelcount=2;
   else
      SndHead.channelcount=1;

   return(fwrite(&SndHead,sizeof(SNDHEAD),
                                    1,OutFH));
}

/* Fehlende Information in SND-Header        */
/* schreiben                                 */
int SndFinish(FILE *OutFH,OUT_FORMAT *OutSmp)
{
/* Anzahl der geschriebenen Bytes eintragen  */
   SndHead.datasize=ByteCount;
   ByteCount=0;

/* kompletten Header an Fileanfang schreiben */
   fseek(OutFH,0L,0);
   return(fwrite(&SndHead,sizeof(SNDHEAD),
                                    1,OutFH));
}

