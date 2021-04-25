#include "xdef.h"	/* Definitions of all Items in adventure */
#include "xlang.h"	/* CAT -> C interface macros */
#include "xfuncs.h"	/* Return values of CAT internal functions */
#include "xglobals.h"	/* Global variables */




/******* See globals.txt for details of global variables */

/* Notice that there isn't an '_' at the beginning of each function name. */





void mseoff()
{
   /* up to you! */
}


void mseon()
{
   /* up to you! */
}





/* return number of rooms in adventure */

int roomcnt()
{
   int i=0;
   
   while (rmd[i][0] != -1)
     ++i;
  return (i+1);
}





/* Return number of objects in adventure */

int objcnt()
{
   int i=0;
   while (odet[i][0] != -1)
      ++i;
   return (i+1);
}





/* return number of messages in adventure */

int msgcnt()
{
   int i=0;
   while (strlen(msg[i]))
      ++i;
   return (i+1);
}





/* Reverse a room long description - original? */

int revroom(room)
int room;
{
   char wrk[500]="";
   int i=0, j=0;
   
   i=(strlen(rml[room]))-1;
   while (i>=0)
   {
      wrk[j]=rml[room][i];
      wrk[j+1]='\0';
      ++j;
      --i;
   }
   strcpy(rml[room],wrk);
}





/* If you want to print any free format text in custom C code, you should use
   the 'ftext' function. This function receives a text string, which it prints
   followed by a NEWLINE. Output will be echoed to the printer if script mode
   is switched on. YOU SHOULD NOT USE PRINTF */
   
void freeform()
{
   /* Note here that the CAT logic token LF does NOT have a preceding '@',
      because we are using it directly in our custom C code. */
      
   LF;
    
   ftext("***** ****  ***** *****");
   ftext("*     *   * *     *    ");
   ftext("***   ****  ***   ***  ");
   ftext("*     *   * *     *    ");
   ftext("*     *   * ***** *****");
   
   LF;
   
   ftext("*****  ***  ****  *   *");
   ftext("*     *   * *   * ** **");
   ftext("***   *   * ****  * * *");
   ftext("*     *   * *   * *   *");
   ftext("*      ***  *   * *   *");
}





/* Final example - values are passed in and out. CAT logic is used, and 
   items are referenced directly, by using the identifying prefix */

int roomtest(room,obj1,obj2)
int room, obj1, obj2;
{
   PMSG(M_OKAY);
   PROOMS(room);
   POBJS(obj1);
   POBJS(obj2);
   return OBJRM(obj2);
}

