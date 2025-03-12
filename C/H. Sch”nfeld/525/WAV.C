/* WAV Routinen zur WAV Konvertierung        */
/* Modulname:  WAV.C                         */
/* (c) MAXON Computer 1994                   */
/* Autoren:    H. Sch”nfeld, B. Spellenberg  */

# include "vlun.h"
# include "wav.h"

/* Z„hler fr geschriebene Sound-Bytes       */
static   long ByteCount=0L;
/* Sound-'Header'                            */
static   FORMATCHUNK WavHead;
/* File-Header des RIFF-Formats              */
static   struct
         {
            char        Riff[4];
            long        GesLen;
            char        Wave[4];
            CHUNK       FmtChk;
            FORMATCHUNK Format;
            CHUNK       DtaChk;
         } RiffHead;

/* WAV-Headertest-Funktion                   */          
int WavTstHead(FILE *InFH, SAMPLE_SPEC *Smp)
{
   CHUNK Chunk;      /*Dummy zu Chunk-Lesen  */
   char  Str[5]="";  /*Name des Chunks       */

   memset(Smp,0,sizeof(SAMPLE_SPEC));
   
   if(!fread(&Chunk,sizeof(CHUNK),1L,InFH))
      return(UNKNOWN);

/* Testen ob RIFF-Format                     */ 
   if(strncmp(Chunk.name,"RIFF",4))
      return(UNKNOWN);

/* WAVE-Format muž gleich folgen             */
   fread(Str,4,1L,InFH);
   if(strncmp(Str,"WAVE",4))
      return(NOT_SUPPORTED);

/* Chunk mit Sounddaten-Beschreibung suchen  */
   if(!SearchChunk("fmt ",InFH))
      return(NOT_SUPPORTED);

/* Format-Chunk lesen und auswerten          */ 
   fread(&WavHead,sizeof(FORMATCHUNK),1L,InFH);
/* Inhalt des Chunk nach Motorola-Format     */
   ConvFmtChunk(&WavHead);
   
   if(WavHead.format!=WAVE_FORMAT_PCM)
      return(NOT_SUPPORTED);
   
   Smp->Typ=WAVHEADER;
   Smp->SizeFac=1;
   switch (WavHead.channels)
   {
      case 1:
         Smp->Format=0;
         Smp->SizeFac*=2;
         break;
      
      case 2:
         Smp->Format=STEREO;
         break;
      
      default:
         return(NOT_SUPPORTED);
   }
      
   Smp->Freq=WavHead.frequency;
   
   if(WavHead.bps>8)
      Smp->Format|=BIT16|SIGNED;
   else
      Smp->SizeFac*=2;

/* Data-Chunk suchen                         */
   if(!(Smp->DataLen=SearchChunk("data",InFH)))
      return(NOT_SUPPORTED);

   Smp->BufLen=BUFSIZE;
   return(SUPPORTED);
}

/* WAV nach Std.format konvertieren          */
long WavToStd(FILE *InFH,SAMPLE_SPEC *Smp,
               char *StdBuf, long StdBufLen)
{
   long DataRead;
   
   DataRead=AllToStd(InFH,Smp,
            StdBuf,StdBufLen);

/* Am Ende des Datenchunks mit dem Lesen     */
/* aufh”ren                                  */ 
   DataRead/=Smp->SizeFac;
   if(DataRead>Smp->DataLen)
      DataRead=Smp->DataLen;
   
   Smp->DataLen-=DataRead;
   
   return(DataRead*Smp->SizeFac);
}

/* Std.format nach WAV konvertieren          */
long WavFromStd(FILE *OutFH,OUT_FORMAT *OutSmp,
                  long DataLen, char *StdBuf)
{
   long DataWrite;

/* Kein Mu-Law, deltapack, 8bit-signed und   */
/* bigendian erlaubt                         */
   OutSmp->Format&=~(DELTAPACK|MULAW|
                     BIGENDIAN|SIGNED);
/* 16 Bit nur signed                         */
   if(OutSmp->Format&BIT16)
      OutSmp->Format|=SIGNED;
   
   DataWrite=AllFromStd(OutFH,OutSmp,
                        DataLen,StdBuf);
   ByteCount+=DataWrite;
   
   return(DataWrite);
}

/* WAV-Header setzen und schreiben           */
int WavWrtHead(FILE *OutFH,SAMPLE_SPEC *InSmp,
               OUT_FORMAT *OutSmp)
{
   int Fmt;
   long temp;
   
   Fmt=OutSmp->Format;  
   memset(&RiffHead,0,sizeof(RiffHead));

/* Riff, Wave, Format und Data-Chunks auf-   */
/* bauen und speichern                       */
   strncpy(&RiffHead.Riff,"RIFF",4);
   strncpy(&RiffHead.Wave,"WAVE",4);
   strncpy(&RiffHead.FmtChk.name,"fmt ",4);
   strncpy(&RiffHead.DtaChk.name,"data",4);

   temp=sizeof(FORMATCHUNK);
/* L„nge des Chunks im Intel-Format          */
   RiffHead.FmtChk.len=i_long(temp);
   RiffHead.Format.format=WAVE_FORMAT_PCM;

   RiffHead.Format.frequency=InSmp->Freq;

   RiffHead.Format.average=InSmp->Freq;
   RiffHead.Format.align=1;
   RiffHead.Format.bps=8;
   RiffHead.Format.channels=1;
   
   if(Fmt&STEREO)
   {
      RiffHead.Format.average*=2;
      RiffHead.Format.align*=2;
      RiffHead.Format.channels=2;
   }
   if(Fmt&BIT16)
   {
      RiffHead.Format.average*=2;
      RiffHead.Format.align*=2;
      RiffHead.Format.bps*=2;
   }

/* S„mtliche Werte im Chunk nach Intel-      */
/* Format wandeln                            */
   ConvFmtChunk(&RiffHead.Format);
   return(fwrite(&RiffHead,sizeof(RiffHead),
                                       1,OutFH));
}

/* Fehlende Information in WAV-Header        */
/* schreiben                                 */
int WavFinish(FILE *OutFH,OUT_FORMAT *OutSmp)
{
   long temp;

/* L„nge der Daten                           */ 
   RiffHead.DtaChk.len=i_long(ByteCount);
/* Filel„nge minus RIFF-Chunk-L„nge          */
   temp=ByteCount+sizeof(RiffHead)-8;
   RiffHead.GesLen=i_long(temp);
   ByteCount=0;
   
   fseek(OutFH,0L,0);
   return(fwrite(&RiffHead,sizeof(RiffHead),
                                       1,OutFH));
}

/* Alle Chunks skippen, bis der in ChunkName */
/* angegebene vorliegt                       */
long SearchChunk(char *ChunkName, FILE *InFH)
{
   CHUNK Chunk;
   
   while (fread(&Chunk,sizeof(CHUNK),1L,InFH))
   {
      if (!strncmp(Chunk.name,ChunkName,4))
         return(i_long(Chunk.len));
      
      fseek(InFH,i_long(Chunk.len),SEEK_CUR);
   }
   
   return 0;
}

/* Fmt-Chunk-Inhalt nach Intel wandeln und   */
/* zurck                                    */
void ConvFmtChunk (FORMATCHUNK *Chunk)
{
   Chunk->format = i_int (Chunk->format);
   Chunk->channels = i_int (Chunk->channels);
   Chunk->frequency = i_long (Chunk->frequency);
   Chunk->average = i_long (Chunk->average);
   Chunk->align = i_int (Chunk->align);
   Chunk->bps = i_int (Chunk->bps);
}