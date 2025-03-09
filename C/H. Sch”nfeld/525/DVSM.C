/* DVSM Routinen zur DVSM Konvertierung      */
/* Modulname:  DVSM.C                        */
/* (c) MAXON Computer 1994                   */
/* Autoren:    H. Schînfeld, B. Spellenberg  */

# include "vlun.h"
# include "dvsm.h"

/* Header fÅr Im- und Export                 */
static   DVSMHEAD DvsHead;
/* Tabelle aller DVSM-Festfrequenzen         */
static   long DvsFreqTab[]=
         {  ACT_CLK8K ,ACT_CLK10K,ACT_CLK12K,
            ACT_CLK16K,ACT_CLK20K,ACT_CLK25K,
            ACT_CLK33K,ACT_CLK50K
         };
/* Zugehîrige Falcon-DMA-Matrix Vorteiler    */
static   int DvsDivTab[]=
         {  CLK8K,CLK10K,CLK12K,CLK16K,
            CLK20K,CLK25K,CLK33K,CLK50K
         };
         
/* DVSM-Headertest-Funktion                  */
int DvsTstHead(FILE *InFH, SAMPLE_SPEC *Smp)
{
   long FilePos;     /* Akt. Pos. im Header  */
   DVSMCOOKIE Cookie;/* Dummy zum Lesen der  */
                     /* DSVM Cookies         */
   int ClockFlag;    /* Wert des CLCK Cookies*/
   int Clock;        /* DMA-Matrix-Takt      */
   
   memset(Smp,0,sizeof(SAMPLE_SPEC));

   if(!fread(&DvsHead,sizeof(DVSMHEAD),1L,InFH))
      return(UNKNOWN);
   if(strcmp(&DvsHead.magic,"DVSM"))
      return(UNKNOWN);
   Smp->Typ=DVSMHEADER;

/* Beliebige Frequenz oder DVSM-Festfrequenz?*/
   if(DvsHead.freq>256)
      Smp->Freq=DvsHead.freq;
   else
      Smp->Freq=DvsFreqTab[DvsHead.freq];

   switch(DvsHead.mode)
   {
      case 0:
         Smp->Format=STEREO|SIGNED;
         Smp->SizeFac=2;
      break;
      
      case 1:
         Smp->Format=STEREO|BIT16|BIGENDIAN
                     |SIGNED;
         Smp->SizeFac=1;
      break;

      case 2:
         Smp->Format=SIGNED;
         Smp->SizeFac=4;
      break;
      
      default:
         return(NOT_SUPPORTED);
   }
   
   switch(DvsHead.pack)
   {
      case 0:                 /* Ungepackt   */
         Smp->BufLen=BUFSIZE;
      break;
      
      case 2:                 /* Deltapack   */
         Smp->BufLen=DvsHead.blocklen-2;
         Smp->Format=STEREO|DELTAPACK|SIGNED;
         Smp->SizeFac=2;
      break;
      
      default: /* Weitere Formate in Vorber. */
         return(NOT_SUPPORTED);
   }

/* Eventuell folgende Cookies lesen          */
   FilePos=sizeof(DVSMHEAD);
   while(FilePos<DvsHead.headlen)
   {
      fread(&Cookie,sizeof(Cookie),1L,InFH); 
/* Falls CLCK-Cookie, dann auswerten         */
      if(!strncmp(&Cookie.Name,"CLCK",4))
      {
/* Cookie-Daten lesen                        */
         fread(&ClockFlag,2L,1L,InFH);
/* Nur gÅltig wenn Festfrequenz im Header    */
         if((DvsHead.freq<=256) & ClockFlag)
         {
            if(ClockFlag==1)     /* CD Takt  */
               Clock=22579200L;
            else
               Clock=24576000L;  /* DAT Takt */
/* Eff. Frequenz aus Clock&Vorteiler berech. */
            Smp->Freq=0.5+Clock/256.0/
               (DvsDivTab[DvsHead.freq]+1);
         }
         break;
      }
      else
/* Sonst Cookie-Daten skippen                */
         fseek(InFH,Cookie.Len-sizeof(Cookie),1);
      FilePos+=Cookie.Len;
   }

/* An Sounddaten-Anfang seeken               */
   fseek(InFH,DvsHead.headlen,0);
   
   return(SUPPORTED);
}

/* DVSM nach Std.format konvertieren         */
long DvsToStd(FILE *InFH,SAMPLE_SPEC *Smp,
               char *StdBuf, long StdBufLen)
{
/* Anfangsadr. fÅr die zu ladenden Daten     */
   char *InBuf;
/* Ergibt LÑnge im Standardformat            */
   long DataRead,
/* Offset fÅr Dateneginn im Standardformat   */
        DataLen;

/* Falls Daten im Deltapack, dann            */ 
   if(Smp->Format&DELTAPACK)
   {
/* Block+2 StÅtzpunkte ans Bufferende laden  */
      DataLen=Smp->BufLen+2;
      InBuf=StdBuf+StdBufLen-DataLen;
      DataRead=fread(InBuf,1,DataLen,InFH);
      
      if(!DataRead)
         return(0);  /* Datenende erreicht   */
      else
      {              /* Daten wandeln        */
         ConvD_Std(InBuf,StdBuf,DataRead);
/* DatenlÑnge im Std.format zurÅckgeben      */
         return((DataRead-2)*2);
      }
   }
   else
/* Allround-Wandelfunktion aufrufen          */
      return(AllToStd(InFH,Smp,
               StdBuf,StdBufLen));
}

/* Std.format nach DVSM konvertieren         */
long DvsFromStd(FILE *OutFH,OUT_FORMAT *OutSmp,
                  long DataLen, char *StdBuf)
{
   long DataWrite;

/* Mu-Law und unsigned nicht erlaubt, 16 Bit */
/* nur Stereo und Bigendian                  */
   OutSmp->Format&=~MULAW;
   OutSmp->Format|=SIGNED;
   if(OutSmp->Format&BIT16)
      OutSmp->Format|=BIGENDIAN|STEREO;

/* Falls Deltapack gewÅnscht...              */
   if(OutSmp->Format&DELTAPACK)
   {
/* Daten konvertieren, mit 2 StÅtzstellen    */
      ConvStd_D(StdBuf,DataLen); /* schreiben*/
      DataLen=DataLen/2+2;
      DataWrite=fwrite(StdBuf,1,DataLen,OutFH);
   }
   else
/* Allround-Wandelfunktion aufrufen          */
      DataWrite=AllFromStd(OutFH,OutSmp,
                           DataLen,StdBuf);
   return(DataWrite);
}

/* DVSM-Header setzen und schreiben          */
int DvsWrtHead(FILE *OutFH,SAMPLE_SPEC *InSmp,
               OUT_FORMAT *OutSmp)
{
   int Fmt, i;
/* Hilfsvar. zur Berechnung der Frequenz     */
   float tmp1,tmp2=1000000.0;
   
   Fmt=OutSmp->Format;  
   memset(&DvsHead,0,sizeof(DVSMHEAD));
   
   strcpy(&DvsHead.magic,"DVSM");

/* Es werden keine Cookies geschrieben       */
   DvsHead.headlen=(int)sizeof(DVSMHEAD);

   if(Fmt&BIT16)
      DvsHead.mode=1;
   else if(Fmt&STEREO)
      DvsHead.mode=0;
   else
      DvsHead.mode=2;
      
   DvsHead.blocklen=1;
      
   if(Fmt&DELTAPACK)
   {
      DvsHead.mode=1;
      DvsHead.pack=2;
      DvsHead.blocklen=InSmp->BufLen;
/* BlocklÑnge korrigieren                    */
      if(!(InSmp->Format&STEREO))
         DvsHead.blocklen*=2;
      if(InSmp->Format&BIT16)
         DvsHead.blocklen/=2;
/* StÅtzpunkte dazuzÑhlen                    */
      DvsHead.blocklen+=2;
   }

/* NÑheste DVSM-Festfrequenz suchen          */
   for (i = 0; i < 8; i++) {
      tmp1 = ((float)abs(InSmp->Freq
               -DvsFreqTab[i]))/DvsFreqTab[i];
      if (tmp1 < tmp2) {
         tmp2 = tmp1;
         DvsHead.freq = i;
      }
   }

   return(fwrite(&DvsHead,sizeof(DVSMHEAD),
                                       1,OutFH));
}

            