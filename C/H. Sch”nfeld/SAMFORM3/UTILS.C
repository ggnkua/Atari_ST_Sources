/* UTILS Allgemeine Routinen zur Wandlung    */
/* Modulname:  UTILS.C                       */
/* (c) MAXON Computer 1994                   */
/* Autoren:    H. Schînfeld, B. Spellenberg  */

# include "vlun.h"

/* Lookup-Tabellen fÅr die Wandlung von      */
/* Mu-Law und Deltapack nach 16 Bit          */
static int MuLookUp[256],DeltaLookUp[128];
/* Lookup-Tabelle fÅr die Wandlung nach      */
/* Mu-Law oder Deltapack                     */
static char InvLookUp[32769L];
/* Flags, ob Tabellen schon berechnet wurden */
static int MuLkSet=0,DeltaLkSet=0;
/* Gibt an ob und wie InvLookUp belegt ist   */
static int InvLkSet=0;

/* LÑdt einen Block Sampledaten und konver-  */
/* tiert ihn ins Standardformat (16B/Stereo) */
long AllToStd(FILE *InFH,SAMPLE_SPEC *Smp,
               char *StdBuf, long StdBufLen)
{
/* Anfangsadr. fÅr die zu ladenden Daten     */
   char *InBuf;
/* Ergibt LÑnge im Standardformat            */
   long DataRead,
/* Offset fÅr Dateneginn im Standardformat   */
        DataLen;

/* Einen Datenblock ans Bufferende laden     */
   DataLen=Smp->BufLen;
   InBuf=StdBuf+StdBufLen-DataLen;
   DataRead=fread(InBuf,1,DataLen,InFH);

/* Je nach Input-Format die zugehîrigen      */
/* Wandelfunktionen aufrufen und die eventu- */
/* elle Expansion der Daten in DataRead und  */
/* DataLen nachvollziehen                    */
   if((Smp->Format&MULAW))
   {
      ConvMu_16(InBuf,InBuf-DataLen,DataRead);
      InBuf-=DataLen;
      DataRead*=2;
      DataLen*=2;
   }
   else if(!(Smp->Format&BIT16))
   {
      Conv8_16(InBuf,InBuf-DataLen,DataRead);
      InBuf-=DataLen;
      DataRead*=2;
      DataLen*=2;
   }
   else if(!(Smp->Format&BIGENDIAN))
      ConvIntel(InBuf,DataRead);
   
   if(!(Smp->Format&SIGNED))
      ConvU_S(InBuf,DataRead);

   if(!(Smp->Format&STEREO))
   {
      ConvM_S(InBuf,InBuf-DataLen,DataRead);
      InBuf-=DataLen;
      DataRead*=2;
   }
   return(DataRead);
}

/* Konvertiert den Block im Standardformat   */
/* in das durch OutSmp definierte Format und */
/* speichert ihn ab                          */
long AllFromStd(FILE *OutFH,OUT_FORMAT *OutSmp,
                  long DataLen, char *StdBuf)
{
/* LÑnge der geschriebenen Daten             */
   long DataWrite;

/* Je nach Output-Format die zugehîrigen     */
/* Wandelroutinen aufrufen und DataLen falls */
/* nîtig korrigieren                         */
   if(!(OutSmp->Format&STEREO))
   {
      ConvS_M(StdBuf,DataLen);
      DataLen/=2;
   }

   if(!(OutSmp->Format&SIGNED))
      ConvS_U(StdBuf,DataLen);
   
   if((OutSmp->Format&MULAW))
   {
      Conv16_Mu(StdBuf,DataLen);
      DataLen/=2;
   }
   else if(!(OutSmp->Format&BIT16))
   {
      Conv16_8(StdBuf,DataLen);
      DataLen/=2;
   }
   else if(!(OutSmp->Format&BIGENDIAN))
      ConvIntel(StdBuf,DataLen);
   
   DataWrite=fwrite(StdBuf,1,DataLen,OutFH);
   return(DataWrite);
}

/* Konvertiert 8 Bit Sounddaten nach 16 Bit  */
void Conv8_16(char *InData,char *OutData,
               long Len)
{
   long i;
   int *out=(int *)OutData;
   
   for(i=0;i<Len;i++)
      *(out++)=((int)*(InData++))<<8;
}

/* Konvertiert 16 Bit Mono nach Stereo       */
void ConvM_S(char *InData,char *OutData,long Len)
{
   long i;
   int *out=(int *)OutData, *in=(int *)InData;
   
   for(i=0;i<Len;i+=2)
   {
      *(out++)=*in;
      *(out++)=*(in++);
   }
}

/* Konvertiert einen Block vorzeichenloser   */
/* 16 Bit Daten nach vorzeichenbehaftet      */
void ConvU_S(char *InData,long Len)
{
   long i;
   int *ptr=(int *)InData;
   
   for(i=0;i<Len;i+=2)
      *(ptr++)=(int)(*ptr-32768L);
}

/* Konvertiert 16 Bit Sounddaten nach 8 Bit  */
void Conv16_8(char *Buf,long Len)
{
   int *in=(int *)Buf;
   long i;
   
   for(i=0;i<Len;i+=2)
      *(Buf++)=(char)(*(in++)>>8);
}

/* Konvertiert 16 Bit Stereo nach Mono       */
void ConvS_M(char *Buf,long Len)
{
   int *in=(int *)Buf, *out=(int *)Buf;
   long i;
   
   for(i=0;i<Len;i+=4,in+=2)
      *(out++)=(int)((((long)in[0])+in[1])/2);
}

/* Konvertiert einen Block vorzeichenbehaf-  */
/* teter 16 Bit Daten nach vorzeichenlos     */
void ConvS_U(char *Buf,long Len)
{
   long i;
   int *ptr=(int *)Buf;
   
   for(i=0;i<Len;i+=2)
      *(ptr++)=(int)(*ptr+32768L);
}

/* Konvertiert 16 Bit bigendian nach         */
/* littleendian und umgekehrt                */
void ConvIntel(char *InData,long Len)
{
   long i;
   int *ptr=(int *)InData;
   
   for(i=0;i<Len;i+=2,InData+=2)
      *(ptr++)=InData[0]+((int)InData[1]<<8);
}

/* Konvertiert einen Block 8 Bit Mu-Law      */
/* nach 16 Bit (linear)                      */
void ConvMu_16(char *InData,char *OutData,
               long Len)
{
   long i;
   int *out=(int *)OutData;

/* Falls Mu-Law Lookup-Wandeltabelle noch    */
/* nicht berechnet, diese berechnen          */
   if(MuLkSet!=MULAW)
   {
      SetMu();
      MuLkSet=MULAW;
   }

/* Daten Åber Lookup-Tabelle wandeln         */
   for(i=0;i<Len;i++)
      *(out++)=MuLookUp[*(unsigned char *)
                     (InData++)];
}

/* Konvertiert einen Block 16 Bit linear     */
/* nach 8 Bit Mu-Law                         */
void Conv16_Mu(char *Buf,long Len)
{
   int *in=(int *)Buf;
   long i;

/* Falls inverse Lookup-Wandeltabelle nicht  */
/* mit Mu-Law Daten belegt, diese berechnen  */
   if(InvLkSet!=MULAW)
   {
      SetInvMu();
      InvLkSet=MULAW;
   }

/* Daten Åber Lookup-Tabelle wandeln         */
/* Negative Werte liegen im Bereich zwischen */
/* 127 bis 0, positive zwischen 255 und 128  */
   for(i=0;i<Len;i+=2)
      if(*in<0)
         *(Buf++)=InvLookUp[-*(in++)];
      else
         *(Buf++)=InvLookUp[*(in++)]+128;
}

/* Berechnet Lookup-Tabelle zur Wandlung von */
/* 8 Bit Mu-Law nach 16 Bit linear           */
void SetMu(void)
{
   unsigned int i;
   float u = 255.0, mp = 32767.0, l1pu;

   l1pu = log(1+u);
   for (i = 0; i <= 127; i++)
      MuLookUp[i]=-(exp(l1pu*(127-i)/127.0)-1)
                     /u*mp;
   for (i = 128; i < 256; i++)
      MuLookUp[i]=(exp(l1pu*(255-i)/127.0)-1)
                     /u*mp;
}

/* Berechnet Lookup-Tabelle zur Wandlung von */
/* 16 Bit linear nach Mu-Law                 */
void SetInvMu(void)
{
   long i, li=32768, mi, j;
   float u = 255.0, mp = 32767.0, l1pu;

   l1pu = log(1+u);
   for (i = 0; i <= 127; i++) {
      mi = (exp(l1pu*(127-i)/127.0)-1)/u*mp;
      for (j = li; j >= mi; j--)
         InvLookUp[j] = i;
      li = mi-1;
   }
   for (j = li; j >= 0; j--)
      InvLookUp[j] = 127;
}

/* Konvertiert einen Block 8 Bit Deltapack   */
/* (Stereo) nach 16 Bit (linear)             */ 
void ConvD_Std(char *InData,char *OutData,
               long Len)
{
   long i;
   int *out=(int *)OutData, l0, r0;

/* Falls Deltapack Lookup-Wandeltabelle noch */
/* nicht berechnet, diese berechnen          */ 
   if(DeltaLkSet!=DELTAPACK)
   {
      SetDelta();
      DeltaLkSet=DELTAPACK;
   }

/* StÅtzpunkte auslesen                      */
   *(out++)=l0 = *(int *)InData;
   *(out++)=r0 = *(int *)(InData+2);
   InData += 4;

/* Differenzwerte Åber Lookup-Tabelle um-    */
/* rechnen und zu bisherigen addieren        */
   for(i=4;i<Len;i+=2)
   {
      if(*InData<0)
         *(out++)=l0-=DeltaLookUp[-*(InData++)];
      else
         *(out++)=l0+=DeltaLookUp[+*(InData++)];
      if(*InData<0)
         *(out++)=r0-=DeltaLookUp[-*(InData++)];
      else
         *(out++)=r0+=DeltaLookUp[+*(InData++)];
   }
}

/* Konvertiert einen Block 16 Bit (linear)   */
/* nach 8 Bit Deltapack (Stereo)             */
void ConvStd_D(char *Buf,long Len)
{
   int *in=(int *)Buf,l0,r0,tmp;
   long i;

/* Falls Deltapack Lookup-Wandeltabellen     */
/* noch nicht berechnet, diese berechnen     */
   if(InvLkSet!=DELTAPACK)
   {
      SetInvDelta();
      InvLkSet=DELTAPACK;
   }
   if(DeltaLkSet!=DELTAPACK)
   {
      SetDelta();
      DeltaLkSet=DELTAPACK;
   }

/* StÅtzwerte belassen                       */ 
   l0=*(in++);
   r0=*(in++);
   Buf+=4;

/* Daten packen                              */
   for(i=4;i<Len;i+=4)
   {
/* Linker Kanal, Differenz berechnen         */
      tmp = l0;
      l0 = (*in)-l0;
/* Differenz nÑhern und gleich wieder        */
/* entpacken                                 */
      if(l0<0)
         l0=tmp-DeltaLookUp[-(*(Buf++)=
                           -InvLookUp[-l0])];
      else
         l0=tmp+DeltaLookUp[*(Buf++)=
                           InvLookUp[l0]];

/* Durch NÑherung erzeugten Overflow         */
/* korrigieren                               */
      if (((l0^*(in++))&0x8000)&&(abs(l0)>20000))
      {
         if(l0<0)
            l0=tmp-DeltaLookUp[-(*(Buf++)=
                     -InvLookUp[DeltaLookUp[1-
                                 *(--Buf)]])];
         else
            l0=tmp+DeltaLookUp[*(Buf++)=
                     InvLookUp[DeltaLookUp[1+
                                 *(--Buf)]]];
      }

/* Rechter Kanal                             */
      tmp = r0;
      r0 = (*in)-r0;
      if(r0<0)
         r0=tmp-DeltaLookUp[-(*(Buf++)=
                           -InvLookUp[-r0])];
      else
         r0=tmp+DeltaLookUp[*(Buf++)=
                              InvLookUp[r0]];

      if (((r0^*(in++))&0x8000)&&(abs(r0)>20000))
      {
         if(r0<0)
            r0=tmp-DeltaLookUp[-(*(Buf++)=
                     -InvLookUp[DeltaLookUp[1-
                                 *(--Buf)]])];
         else
            r0=tmp+DeltaLookUp[*(Buf++)=
                     InvLookUp[DeltaLookUp[1+
                                 *(--Buf)]]];
      }
   }
}

/* Berechnet Lookup-Tabelle zur Wandlung von */
/* 16 Bit linear nach 8 Bit Deltapack        */
void SetDelta(void)
{
   int i;

   DeltaLookUp[0]=0;
   for (i=1;i<128;i++)
      DeltaLookUp[i]=(int)pow(1.084618362,
                                    (double)i);
}

/* Berechnet Lookup-Tabelle zur Wandlung von */
/* 8 Bit Deltapack nach 16 Bit linear        */
void SetInvDelta(void)
{
   int i;
   int val;
   
   memset(InvLookUp,127,32768L);
   InvLookUp[0]=0;
   for (i=1;i<128;i++)
   {
      val=(int)pow(1.084618362,(double)i);
      memset(&InvLookUp[val],i,32768L-val);
   }
}

