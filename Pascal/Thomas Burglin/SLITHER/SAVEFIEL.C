/*************************save fields *******************************/

#include "extern.h"

WORD savefield(field,at,level,number)    

   unsigned char field[30][5][38];
   int     at,level,number;

   {

   WORD  i, j, k, x;
   FILE *data,*fopen();
   WORD button;

   screensave ();
   i = fsel_input(workpath,filename,&button);
   screenrestore ();
   if (i == 0)
      {
      form_alert(1,"[3][FILE ERROR][  OK  ]");
      return (0);
      }
   if (button == 0) return (0);

   strcpy (filepath,workpath);
   remwild (filepath);
   strcat (filepath,filename);
   graf_mouse(BUSYBEE,1);

   data = fopen (filepath,"w");
   fprintf (data," %d %d\n",at,number);
      
   for (i = level-1; i < level+number-1; i++)
      {
     	for (k = 0; k < 38; k++)
         {
         for (j = 0; j < 5; j++)
       		{ 
       	   fprintf (data," %d",field[i][j][k]);
       	   }
         fprintf (data,"\n");
         }
      }   
   j = fclose (data);
   graf_mouse (ARROW,1);

   return (1);
   }


