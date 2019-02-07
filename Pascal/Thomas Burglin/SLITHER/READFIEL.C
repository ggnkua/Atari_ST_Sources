/*************************read file *******************************/

#include "extern.h"

WORD readfield (field,level,number)         /* read file from disk */

   unsigned char field[30][5][38];
   WORD      *level, *number;

   {

   WORD  i, j, k, x;
   FILE *data,*fopen();
   WORD button;

   filename[0]='\0';
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

   data = fopen (filepath,"r");
   if (data == NULL)
      {
      form_alert(1,"[3][FILE ERROR][  OK  ]");
      return (0);
      }
   fscanf (data,"%d",level);
   fscanf (data,"%d",number);
   
   if (*level < 1) *level = 1;
   if (*level > 30) *level = 30;
   if (*level + *number > 31) *number = 31 - *level;
   for (i = *level; i < *level + *number; i++)
      {
     	for (k = 0; k < 38; k++)
         {
         for (j = 0; j < 5; j++)
       		{ 
       	   fscanf (data,"%d",&x);
            if (x > 255) x = 255;
            field[i-1][j][k] = x;
       	   }
         }
      }   
   j = fclose (data);
   graf_mouse (ARROW,1);

   return (1);
   }


