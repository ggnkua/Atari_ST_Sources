/*************************************************************************/
/*   savercnf.c - Program to modify SAVER.PRG screen saver time value.   */
/*                                                                       */
/*   Mark A. Abreu   8/19/89     GEnie: M.ABREU                          */
/*                                                                       */
/*   This program reads SAVER.PRG and modifies the timer value in the    */
/*   executable program.                                                 */
/*                                                                       */
/*   WARNING:  This program only works with the version of SAVER.PRG     */
/*             I tested it on.  This will probably NOT work with         */
/*             future versions of SAVER.PRG                              */
/*                                                                       */
/*   Created using SOZOBON C                                             */
/*                                                                       */
/*************************************************************************/

/*  Global include files  */

#include <osbind.h>
#include <stdio.h>
#include <errno.h>
#include <portab.h>

#define TIMEPOS 886L     /*  location of timer in SAVER.PRG  */
#define MINTIME 1        /*  minimum time in minutes         */
#define MAXTIME 9        /*  maximum time in minutes         */

main()
{
WORD istat;              /*  status word  */
WORD fh;                 /*  file handle  */
WORD otimmili;           /*  old timmer millisecond value  */
WORD oldmins;            /*  old time in minutes  */
WORD ntimmili;           /*  new timer millisecond value  */
WORD newmins;            /*  new time in minutes  */
LONG lstat;              /*  status long word  */
LONG charcntr;           /*  bytes read counter  */

/*
  Open the file.
*/

   istat = Fopen("saver.prg",2);
   if (istat <= 0)
   {
      switch (istat)
      {
         case EFILNF:
              printf ("\r\nSAVER.PRG not found.  This configuration program");
              printf ("\r\nand SAVER.PRG must be in the same directory.");
              break;
         case EACCDN:
              printf ("\r\nSAVER.PRG could not be opened for WRITE access.");
              printf ("\r\nCheck to see if SAVER.PRG is set READ-ONLY.");
              break;
         default:
              printf ("\r\nOpen failure on SAVER.PRG, status = %d",istat);
              break;
      }
      waitcr ("\r\nPress <Return> ");
      Pterm(0);
   }

   printf ("\r\nSAVER.PRG found and opened....");
   
   fh = istat;   /*  if status was positive then it's the file handle  */

   lstat = Fseek (TIMEPOS,fh,0);            /*  position to timer location */
   charcntr = Fread (fh,2L,&otimmili);      /*  read timer value  */
   oldmins = otimmili / 60 / 60;            /*  convert to minutes  */
   printf ("\r\nScreen Saver time currently is %d minutes",oldmins);
   printf ("\r\nEnter new value [%d to %d minutes]: ",MINTIME,MAXTIME);
   scanf ("%1d",&newmins);                  /*  get new value  */
   
/*  make sure new value is within range  */

   if (newmins >= MINTIME && newmins <= MAXTIME)
   {
      ntimmili = newmins * 60 * 60;       /*  convert to milliseconds  */
      lstat = Fseek (TIMEPOS,fh,0);       /*  position to timer location  */
      lstat = Fwrite (fh,2L,&ntimmili);   /*  write timer value  */
      if (lstat < 0)
      {
         printf ("\r\nWrite failure on SAVER.PRG, status = %ld",lstat);
         waitcr ("  Press <Return> ");
      }
   }
   else
   {
      printf ("\r\nInvalid entry.  SAVER.PRG unchanged.");
      waitcr ("\r\nPress <Return> ");
   }
      
/*
  Close the file.
*/

  istat = Fclose (fh);
  if (istat != 0)
  {
     printf ("\r\nCLOSE failure on SAVER.PRG, status = %d",istat);
     waitcr ("   Press <Return> ");
  }

  Pterm(0);

}
