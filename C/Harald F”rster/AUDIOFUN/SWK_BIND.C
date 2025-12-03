/******************************************************************************/
/*                                                                            */
/*                                SWK_BIND.C                                  */
/*                                ----------                                  */
/*                                                                            */
/*                       Binding fÅr SOUNDWORKER V1.0                         */
/*                                                                            */
/*                            Sprache: Sozobon C                              */
/*                                                                            */
/******************************************************************************/

#ifndef ERRNO_H
#include <errno.h>
#endif

#ifndef STDIO_H
#include <stdio.h>
#endif

#ifndef STRING_H
#include <string.h>
#endif

#ifndef OSBIND_H
#include <osbind.h>
#endif



/******************************************************************************/
/*                                                                            */
/*   Wird das AUDIOFUN-File zum Programm gelinkt, muû folgende Struktur als   */
/*    extern deklariert werden. Die Funktion SWK_LOAD kann dann entfallen.    */
/*                                                                            */
/******************************************************************************/

/* extern */ struct
{
   char id[18];
   int in_out[3];
   int time[3];
   void *execute[3];
   int last;
   int ret_0;
   int ret_1;
   long swk_on;
   long swk_off;
   long joy_on;
   long joy_off;
   int swk_prog[2480];
} swk;



/******************************************************************************/
/*                                                                            */
/*                                   SWK_LOAD                                 */
/*                                                                            */
/*                  Eingabe: char *filename                                   */
/*                                                                            */
/*                  Ausgabe:    TRUE -> Erfolgreich geladen                   */
/*                             FALSE -> falsche Datei                         */
/*                           negativ -> Fehler                                */
/*                                                                            */
/******************************************************************************/

int swk_load(filename)
char *filename;
{
   register FILE *filepoin;
   register int size, lret, errnum;

   size = sizeof(swk) / sizeof(int);

   filepoin = fopen(filename, "r");

   if(!filepoin)
      errnum = errno;
   else
   {
      lret = fread(&swk, sizeof(int), size, filepoin);
      errnum = errno;
      fclose(filepoin);

      if(lret != size)
      {
         if(errnum >= 0)
            errnum = ENSMEM;
      }
      else
      {
         if(!strcmp(swk.id, "SOUNDWORKER V1.0"))
            errnum = TRUE;
         else
            errnum = FALSE;
      }
   }
   return(errnum);
}



/******************************************************************************/
/*                                                                            */
/*                                   SWK_START                                */
/*                                                                            */
/******************************************************************************/

void swk_start()
{
   Supexec(&swk.swk_on);
}



/******************************************************************************/
/*                                                                            */
/*                                   SWK_STOP                                 */
/*                                                                            */
/******************************************************************************/

void swk_stop()
{
   Supexec(&swk.swk_off);
}



/******************************************************************************/
/*                                                                            */
/*                                   SWK_PLAY                                 */
/*                                                                            */
/*       Eingabe: channel ->     0 ... 2                                      */
/*                   part -> +/- 1 ... 8 startet den Kanal                    */
/*                                       sonst  stummschalten                 */
/*                                                                            */
/******************************************************************************/

void swk_play(channel, part)
int channel, part;
{
   if((channel >= 0) && (channel <= 2))
      swk.in_out[channel] = part;
}



/******************************************************************************/
/*                                                                            */
/*                                   SWK_TILL                                 */
/*                                                                            */
/*        Eingabe: channel -> 0 ... 2                                         */
/*                    last -> Anzahl der zu spielenden Tîne                   */
/*                                                                            */
/******************************************************************************/

void swk_till(channel, last)
int channel, last;
{
   if((channel >= 0) && (channel <= 2))
      swk.time[channel] = last;
}



/******************************************************************************/
/*                                                                            */
/*                                   SWK_EXEC                                 */
/*                                                                            */
/*     Eingabe: channel -> 0 ... 2                                            */
/*                begin -> Taktnummer zum Starten der Routine                 */
/*              routine -> Startadresse der Routine                           */
/*                                                                            */
/******************************************************************************/

void swk_exec(channel, begin, routine)
int channel, begin;
void *routine;
{
   if((channel >= 0) && (channel <= 2))
   {
      swk.time[channel] = begin;
      swk.execute[channel] = routine;
   }
}



/******************************************************************************/
/*                                                                            */
/*                                   SWK_TIME                                 */
/*                                                                            */
/*          Eingabe: channel -> 0 ... 2                                       */
/*                                                                            */
/*          Ausgabe: momentan gespielter Takt oder Null, wenn stumm           */
/*                                                                            */
/******************************************************************************/

int swk_time(channel)
int channel;
{
   if((channel >= 0) && (channel <= 2))
      return(swk.in_out[channel] & 0x00FF);
}



/******************************************************************************/
/*                                                                            */
/*                                   SWK_PART                                 */
/*                                                                            */
/*         Eingabe: channel -> 0 ... 2                                        */
/*                                                                            */
/*         Ausgabe: momentan gespielter Part oder Null, wenn stumm            */
/*                                                                            */
/******************************************************************************/

int swk_part(channel)
int channel;
{
   if((channel >= 0) && (channel <= 2))
      return(swk.in_out[channel] >> 8);
}



/******************************************************************************/
/*                                                                            */
/*                                   JOY_START                                */
/*                                                                            */
/******************************************************************************/

void joy_start()
{
   Supexec(&swk.joy_on);
}



/******************************************************************************/
/*                                                                            */
/*                                   JOY_STOP                                 */
/*                                                                            */
/******************************************************************************/

void joy_stop()
{
   Supexec(&swk.joy_off);
}



/******************************************************************************/
/*                                                                            */
/*                                 JOY_LAST                                   */
/*                                                                            */
/******************************************************************************/

int joy_last()
{
   return(swk.last);
}



/******************************************************************************/
/*                                                                            */
/*                                   JOY_0                                    */
/*                                                                            */
/******************************************************************************/

int joy_0()
{
   return(swk.ret_0);
}




/******************************************************************************/
/*                                                                            */
/*                                   JOY_1                                    */
/*                                                                            */
/******************************************************************************/

int joy_1()
{
   return(swk.ret_1);
}





/* EOF */
