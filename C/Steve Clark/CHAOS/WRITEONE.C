/* Copyright 1990 by Antic Publishing, Inc. */
#include <gemext.h>
#include <stdio.h>
#include "easy.h"

extern short nverts, percent, workarea[4];
   
extern double xvert[25], yvert[25];
   
writeone()

/*
** Routine to save the parameters of the current figure to a file. The user
** chooses the name, but the extension should be .KS1 for low-rez figures,
** .KS2 for medium-rez figures, and .KS3 for high-rez figures.
*/
{
   short i, x, y, w, h, drive;

   char path[80], filedir[80], filename[15];
   
   FILE *lunit, *fselopen();
   
  
   x = workarea[0];
   y = workarea[1];
   w = workarea[2] - workarea[0] + 1 + 2;   /* The 2 is a bugfix for */
   h = workarea[3] - workarea[1] + 1 + 2;   /* SAVERAST() and PUTRAST() */
/*
** Start by getting the path, then add the filetype to open.
*/
   drive = gemdos(0x19);
   path[0] = 'a' + drive;
   path[1] = ':';
   gemdos(0x47, &path[2], 0);
   if(workarea[2] EQ 639) THEN
      if(workarea[3] EQ 399) strcat(path, "\\*.KS3");    /* High-rez */
      else strcat(path, "\\*.KS2");                      /* Medium-rez */
   ELSE strcat(path, "\\*.KS1");                         /* Low-rez */
/*
** Open the file.
*/
   lunit = fselopen(drive, path, "w", filedir, filename);
   if(lunit EQ NULL) return(NULL);   /* Cancel option chosen */
/*
** Write out the data.
*/
   fprintf(lunit, "%3d\n", nverts);
   fprintf(lunit, "%3d\n", percent);
   for(i=0; i LT nverts; ++i) DO
      fprintf(lunit, "%4d%4d\n", (short)xvert[i], (short)yvert[i]);
   ENDDO
   fclose(lunit);
}

readone()

/*
** Routine to read from a file the parameters to generate a figure. The file
** was created and written by WRITEONE().
*/
{
   short i, x, y, w, h, drive;

   char path[80], filedir[80], filename[15];
   
   FILE *lunit, *fselopen();

   extern double proportion;   
  
   x = workarea[0];
   y = workarea[1];
   w = workarea[2] - workarea[0] + 1 + 2;   /* The 2 is a bugfix for */
   h = workarea[3] - workarea[1] + 1 + 2;   /* SAVERAST() and PUTRAST() */
/*
** Start by getting the path, then add the filetype to open.
*/
   drive = gemdos(0x19);
   path[0] = 'a' + drive;
   path[1] = ':';
   gemdos(0x47, &path[2], 0);
   if(workarea[2] EQ 639) THEN
      if(workarea[3] EQ 399) strcat(path, "\\*.KS3");    /* High-rez */
      else strcat(path, "\\*.KS2");                      /* Medium-rez */
   ELSE strcat(path, "\\*.KS1");                         /* Low-rez */
/*
** Open the file.
*/
   lunit = fselopen(drive, path, "r", filedir, filename);
   if(lunit EQ NULL) return(NULL);   /* Cancel option chosen */
/*
** Write out the data.
*/
   fscanf(lunit, "%3d", &nverts);
   fscanf(lunit, "%3d", &percent);
   proportion = (double)percent / 100.0;
   for(i=0; i LT nverts; ++i) DO
      fscanf(lunit, "%4d%4d", &x, &y);
      xvert[i] = (double) x;
      yvert[i] = (double) y;
   ENDDO
}
