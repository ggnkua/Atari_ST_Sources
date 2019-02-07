/*************get and put parameters in resource file*************/

#include "extern.h"

WORD objcstate (objarray,index)

   WORD objarray[][12];
   WORD index;
  {
   return (objarray[index][5]);
  }

void deselobjc (objarray,index)

   WORD objarray[][12];
   WORD index;
  {
   objarray[index][5] &= (~SELECTED);
  }

void selobjc (objarray,index)

   WORD objarray[][12];
   WORD index;
  {
   objarray[index][5] |= SELECTED;
  }

/* check which button in a dialog is selected  */

WORD whichbutton (objaddress,index,nrseq)

   long   objaddress;
   WORD   index,nrseq;
  {
   WORD i,j;
   WORD objcstate();
   
   for (i=0; i <= nrseq; i++)
      {
      j = (objcstate (objaddress,index+i)) & SELECTED;
      if (j != 0 ) return (i);
      }
   return (0);
  }

/* bend pointer in resource to text into string in main program */

strptr (str,objc,index)

   char   *str;
   long   objc[][6];
   WORD   index;
   {
   long  *ptr;
   
   ptr = (long *)objc[index][3];
   *ptr = (long) str; 
   }

/*        remove wildcards from string (filename)      */

void remwild (string)

   char *string;
  {
   WORD i;
   WORD strlen();
   
   for (i=strlen(string); string[i] != '\\' && i>=0; --i);
   string[i+1]='\0';
  }

