/* Copyright 1990 by Antic Publishing Inc. */
#include <stdio.h>
#include <gemext.h>
#include "easy.h"

FILE *fselopen(drive, path, openstatus, filedir, filename) /*****************/

int  drive;         /* Default drive to open file on (A=0,B=1, etc) */
char filedir[];     /* Returns the file directory */
char filename[];    /* String returning the filename */
char path[];        /* Default path and filename of files to be listed */
char openstatus[];  /* String to specify the open status for fopen() */
/*
** This routine is to open a level 2 file using the function fopen()
** and returns the file pointer 'lunit' supplied by that function. This 
** routine supercedes the routine openit().
**
** On the first call to this routine, the pathname is set to the path
** supplied by the calling program (which can contain the wildcard * in
** the filename and extension) but the drive is set to the default
** drive (from which the calling program is being run). On subsequent
** calls to this routine, the value passed in 'path' is compared to 
** the previously passed value. If they are the same, the path supplied
** to fsel_input() is not changed, even though the user may have changed
** the drive, filename or extension. 

** After selecting the file, it is opened by fopen() and the file pointer
** is returned by the routine. If the file can't be opened or if the cancel
** option is chosen, 'lunit' is set to NULL. 

** If the file is successfully opened, the filename and file directory
** are returned after the directory name is converted to lowercase.
*/
{

   static char oldpath[80];
   static char newpath[80];
   char name[13], openname[100], extension[5], buffer[120];

   FILE *lunit;

   short button, length, position;

/* Check to see if 'path' is the same as the previously supplied value.
** On the first call to this routine, 'oldpath' will be filled with
** NULLs. */

   if(strcmp(path, oldpath) NE 0) THEN     /* Not the same */
      strcpy(oldpath, path);
      if(newpath[0] EQ NULL) newpath[0] = 'A' + drive; /*default drive*/
      strcpy(&newpath[1], &path[1]);
   ENDIF

/*   Get the name of the file to open. */
   
   SHOWMOUSE;
   
get_fname:;

   fsel_input(newpath, name, &button);
   if(button EQ NULL) return(NULL);   /* Cancel option chosen */

/*   Construct 'filedir' from 'newpath'. */

   strcpy(filedir, newpath);
   lowercase(filedir);
   filedir[locate("\\", filedir, -strlen(filedir))+1] = NULL;
/*
** If there is no extension on the name, add it, unless it contains a * or ?.
*/
   length = strlen(name);
   position = locate(".", name, 0);
   if(position EQ length) THEN   /* No extension, just "." */
      name[length] = 0;          /* Remove the dot */
      position = -1;
   ENDIF
   if(position EQ -1) THEN       /* No extension, so add it */
      position = locate(".", path, 0);
      strcpy(extension, &path[position]);
      if((locate("*", extension, 0) EQ -1) AND (locate("?", extension,0) EQ -1))
               strcat(name, extension);
   ENDIF
   uppercase(name);
   strcpy(filename, name);

/*   Now try to open the file. */

   strcpy(openname, filedir);
   strcat(openname, name);
/*
** If the file is to be written to, check that it won't be destroying an old
** file. If it will, warn the user and give him the chance to back out.
*/
   if((openstatus[0] EQ 'w') AND fexists(openname)) THEN
      sprintf(buffer, "[2][%s|%s%s.|%s][god NO|I'm macho|Cancel]",
            "This will delete the current  ",
            "version of ", name,
            "Do you want to do this?");
      button = form_alert(1, buffer);
      if(button EQ 3) return(NULL);
      if(button EQ 1) goto get_fname;
   ENDIF
   lunit = fopen(openname, openstatus);
   if(lunit EQ NULL) THEN   /* Unable to open the file */
      button=form_alert(1,"[1][That file can't be opened.][Try again|Cancel]");
      if(button EQ 1) goto get_fname;
   ENDIF

   return(lunit);
}
