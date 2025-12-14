/*          SAMPLER.TOS

          EENVOUDIGE SAMPLER



          (c) Jos van Roosmalen


          Datum: 12 mei 1993
          UPDATED: 28 juni 1993 Error find!
          Compiler: PURE C


    Met dank aan: W.F. Kilwinger

                                           */


#include <stdio.h>
#include <tos.h>
#include <ext.h>
#include <stdlib.h>
#include <string.h>
#include <sndbind.h>   /* Zie listing 3 */
#include <aes.h>

long leng;

long sample(int freq, int mode, int track, int sec);
int speel(char *buffer,int freq,int mode,int track);

void main()
{
 int sec,mode,track,freq,error;
 long buffer;
 
 /* Copyright melding */

 printf("Sound Sampler voor de Falcon030\n");
 printf("(c) Jos van Roosmalen 11/5/1993\n\n");
 
 printf("Hoeveel seconden samplen? ");

 scanf("%d",&sec);
 
 printf("\nMet welke freq samplen? 1 = 50 , 2 = 25  , 3 = 8 KHZ ");

 scanf("%d",&freq);

 printf("\nMet welke kwaliteit samplen? 0 = 8 bit st, 1 = 16 bt st, 2 = 8 bt mono ");

 scanf("%d",&mode);

 printf("\nTrack mode?  0 = 1 track, 1 = 2 tracks, 2 = 3 tracks, 3 = 4 tracks ");
 
 scanf("%d",&track);

 printf("\nDruk op een toets om met samplen te beginnen.....");

 getch();

 if (freq == 1)
  freq = CLK50K;
 if (freq == 2)
  freq = CLK25K;
 if (freq == 3)
  freq = CLK8K;

 printf("\n\n Bezig met opnemen.......");
 
  buffer =  sample(freq,mode,track,sec);

 if (buffer == -1L)
 {
  printf("\n\n\n Soundsystem gesloten, of niet voldoende vrij geheugen. Druk op een toets");
  getch();
  gemdos(0);
 }
 printf("\n\n Klaar met opnemen.......\n");

 printf("\nDruk op een toets om het weer af te spelen.....");

 getch();

 error = speel((char *) buffer,freq,mode,track);

 if (error == -1)
 {
  printf("\n\n\n Soundsystem gesloten. Druk op een toets");
  getch();
  gemdos(0);
 }
 printf("\n\n Dat was het.....");

 getch();
}


/*********************************
 *  BIBLIOTHEEK VOOR SAMPLING.   *
 *                               *
 * freq -> sample rate:          *
 *                               *
 *          1 = 50 KHZ           *
 *          2 = 33 KHZ           *
 *          3 = 25 KHZ           *
 *          4 = 20 KHZ           *
 *          5 = 16 KHZ           *
 *          7 = 12 KHZ           *
 *          9 = 10 KHZ           *
 *         11 =  8 KHZ           *
 *                               *
 * mode -> kwaliteit:            *
 *                               *
 *      0 = 8 bit stereo         *
 *      1 = 16 bit stereo        *
 *      2 = 8 bit mono           *
 *                               *
 * track -> track mode:          *
 *                               *
 *      0 = 1 track              *
 *      1 = 2 tracks             *
 *      2 = 3 tracks             *
 *      3 = 4 tracks             *
 *                               *
 * sec: Aantal te samplen sec    *
 *                               *
 * Teruggave:                    *
 *                               *
 *    -1L = niet genoeg          *
 *           geheugen            *
 *         anders pointer        *
 *         naar buffer           *
 *                               *
 ********************************* */

long sample(int freq,int mode,int track,int sec)
{
 int teller;
 long like[7];
 char *buffer;
 char *end;
 long close;
 long bytes;
 
 /* Benodigde bytes uitrekenen */

  if (freq == CLK50K)
  bytes = (long) ACT_CLK50K * 4 * sec; 
 if (freq == CLK33K)
  bytes = (long) ACT_CLK33K * 4 * sec;
 if (freq == CLK25K)
  bytes = (long) ACT_CLK25K * 4 * sec;
 if (freq == CLK20K)
  bytes = (long) ACT_CLK20K * 4 * sec;
 if (freq == CLK16K)
  bytes = (long) ACT_CLK16K * 4 * sec;
 if (freq == CLK12K)
  bytes = (long)ACT_CLK12K * 4 * sec;
 if (freq ==  CLK10K)
  bytes = (long) ACT_CLK10K * 4 * sec;
 if (freq == CLK8K)
  bytes = (long) ACT_CLK8K * 4 * sec;

 /* kijken of wij gebruik kunnen maken
    van Codec */

 close = locksnd();

 /* Local naar globaal */

 leng = bytes;
 
 /* Geheugen (proberen te) reserveren */
 


 buffer = (char *) malloc(bytes);

 
 /* Als er geen geheugen meer is */
 /* Of we niet in het systeem kunnen */
 
 
 if (buffer == 0L || close < 0L)
  return -1L; /* Dan -1 retorneren */
 else
 {    /* Anders */

  /* Oude instellingen bewaren */

  for (teller = 0 ; teller < 7 ; teller ++)
   like[teller] = soundcmd(teller,-1);
 
  /* Reset Codec */

  sndstatus(1);

  /* Oude instellingen terug */

  soundcmd(LTATTEN,like[LTATTEN]);
  soundcmd(RTATTEN,like[RTATTEN]);
  soundcmd(LTGAIN, like[LTGAIN]);
  soundcmd(RTGAIN, like[RTGAIN]);
  soundcmd(ADDERIN,0x01);
  soundcmd(ADCINPUT,0x00);

  /* Gebied vullen */

  memset(buffer,0xAA,bytes + 1000);

  /* Buffereinde bepalen */

  end = &buffer[bytes];

  /* Tracks vastleggen */

  settracks(track,track);

  setmontrack(0);
  
  /* Telefoonverbinding maken */

  devconnect(ADC,DMAREC,CLK_25M,freq,1);
  

  /* Fifo legen als moet */

  if (buffoper(-1) & 0x04)
  buffoper(0);

  /* Geheugengebied als Sample geheugen vastleggen */

  setbuffer(1, (long) buffer, (long) end);
 
  /* kwaliteit instellen */

  setmode(mode);
 
  /* Hinderlijke klik niet meenemen */

  for (teller = 1; teller < 32000; teller++);

  /* En opnemen maar */

  buffoper(4);

  do
  {
   if(kbhit()) /* Stop als er op een toets wordt gedrukt */
   break;
  }
  while ((buffoper(-1L) &0x4) != 0); /* Net zolang totdat buffer vol is */

  buffoper(0);   /* Zeker van zijn samplen is gestopt */

  sndstatus(1);  /* Reset codec */

   /* oude instellingen terug */

  for (teller = 0 ; teller < 7 ; teller++)
   soundcmd(teller,like[teller]);

  unlocksnd();  /* Weer vrij */
 
  return (long) buffer;
 }
}
/*********************************
 *  BIBLIOTHEEK VOOR SAMPLING.   *
 *                               *
 * buffer -> pointernaar buffer  *
 *          waar sample staat    *
 *                               *
 * freq -> sample rate:          *
 *                               *
 *          1 = 50 KHZ           *
 *          2 = 33 KHZ           *
 *          3 = 25 KHZ           *
 *          4 = 20 KHZ           *
 *          5 = 16 KHZ           *
 *          7 = 12 KHZ           *
 *          9 = 10 KHZ           *
 *         11 =  8 KHZ           *
 *                               *
 * mode -> kwaliteit:            *
 *                               *
 *      0 = 8 bit stereo         *
 *      1 = 16 bit stereo        *
 *      2 = 8 bit mono           *
 *                               *
 * track -> track mode:          *
 *                               *
 *      0 = 1 track              *
 *      1 = 2 tracks             *
 *      2 = 3 tracks             *
 *      3 = 4 tracks             *
 *                               *
 *                               *
 * Teruggave:                    *
 *                               *
 *    -1 = Geen toegang          *
 *     0 = OK                    *
 *                               *
 *                               *
 ********************************* */  
int speel(char *buffer,int freq,int mode,int track)
{
 int teller;
 char *end;
 long like[7];

 /* kijken of we wel kunnen gaan spelen */

 if(locksnd() < 0L)
 {
  return -1;    /* Nee, gaat niet! */
 }
 else
 {
  /* Instellingen redden */

  for (teller = 0 ; teller < 7 ; teller++)
   like[teller] = soundcmd(teller,-1);

  soundcmd(ADDERIN,0x2);

  /* DSP van matrix gooien */

  dsptristate(0,0);

  /* Tracks setten */

  settracks(track,track);
  setmontrack(0);

  /* Telefoonverbinding maken */

  devconnect(DMAPLAY,DAC,CLK_25M,freq,1);

  /* Einde sample bepalen */

  end =  &buffer[leng];
 
  /* Adressen setten */

  setbuffer(0, (long) buffer, (long) end);
  
  /* Kwaliteit van sampler door spelen */
  setmode(mode);
 
  /* Kom maar op met de herrie */

  buffoper(1);

  do
  {
   if (kbhit())    /* Stoppen als er op een toets is gedrukt... */
    break;
  }
  while ((buffoper(-1L) & 0x1) != 0);  /* of als de sample is afgelopen */
  buffoper(0);   /* Er zeker van zijn dat de sample is gestopt */

  /* Codec resetten */

  sndstatus(1); 

  /* Instellingen weer saven */

  for (teller = 0 ; teller < 7 ;  teller++)
   soundcmd(teller,like[teller]);

  /* Weer vrij */
  unlocksnd();
   
  /* Geen fout opgetreden */

  return 0;
 }
}
