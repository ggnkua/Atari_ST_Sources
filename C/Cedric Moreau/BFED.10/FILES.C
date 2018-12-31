/*
	file: files.c
	utility:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
	comments: 
*/

#include <stdio.h>
#include <string.h>

#ifdef __PUREC__ 
#include <aes.h>
#include <tos.h>
#include <vdi.h>
#include <compend.h>
#include <toserr.h>
#else
#include <aesbind.h>
#include <osbind.h>
#include <vdibind.h>
#endif

#include "e:\proging\c\libs\malib\alert.h"
#include "e:\proging\c\libs\malib\fselect.h"

#include "edit.h"
#include "bufman.h"
#include "files.h"
#include "wind.h"

#include "bfed_rsc.h"

/*
	globals vars
*/
char	app_path[PATH_MAX];			/* current application path */

/*
	locals vars
*/
static char	lastpath[PATH_MAX];	/* Last path used */
static char	fs_insel[PATH_MAX];	
static char	fs_inpath[PATH_MAX];

/*
	name: read_file
	utility: 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
int read_file(windowptr	thewin)
{
	int fildes, ret = TRUE;
	linkbufptr	bufptr;

	graf_mouse(BUSY_BEE,0L);

	if ((fildes = open(thewin->title, O_RDWR)) != -1 )
	{
		const long flenr = Fseek(0L, fildes, SEEK_END);        /* get file length */

		Fseek(0L, fildes, SEEK_SET);	/* rewind */

		if (flenr >= 1)
		{
			long red, toread;
		
			for (toread=flenr; toread>0; toread-=BLOCKSIZE)
			{
				long readnow = (toread < BLOCKSIZE) ? toread : BLOCKSIZE;

				bufptr = addmember(thewin);
				if (bufptr)  /* memory available  */
				{		/* read file to ram */
					if( (red = Fread(fildes,readnow,bufptr->block)) > 0 )
					{
						bufptr->inuse = red;
						thewin->flen += red;
					}	  
					else
					{
						graf_mouse(ARROW,0L);
						rsc_alert(READ_ERR);
						ret = FALSE;
						break;
					}
				}
				else	
				{
					graf_mouse(ARROW,0L);
					rsc_alert(NOMEM_2);
					ret = FALSE;
					break;
				}
			}
			close(fildes);

				/* put extra char 00 at end of file  */
			if(thewin->flen > 0)
			{
				if(bufptr->inuse < BLOCKSIZE)
				{
					bufptr->inuse++;
					thewin->flen++;
				}
				else
				{
					bufptr = addmember(thewin); 
					if (!bufptr)  /* if no memory available  */
					{
						graf_mouse(ARROW,0L);
					 	rsc_alert(NOMEM_3);
				 		return FALSE;
					}
					else				
					{
						bufptr->inuse++;
						thewin->flen++;
					}
				}	
		 	}
	  	}
		else
		{
			graf_mouse(ARROW,0L);
			rsc_alert(READ_ERR2);
			return FALSE;
		}
	}
	else
	{
		graf_mouse(ARROW,0L);
		rsc_alert(READ_ERR2);
		return FALSE;
	}
	
	graf_mouse(ARROW,0L);
	return(ret);
}

/*
	name: write_file
	utility: 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void write_file(windowptr thewin)
{
	char *string;
	
	rsrc_gaddr(R_STRING, S_SAVEFILE, &string);

	if (getfile(thewin, string))
		 save_file(thewin);
} 

/*
	name: save_file
	utility: 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void save_file(windowptr	thewin)
{
	if (thewin->flen >= 2) 
	{			 
		int fildes;	

		graf_mouse(BUSYBEE, 0L);
			/* delete the dummy byte at end of file	*/	
			/*	the 0 flag in the delete_one call allows for delete last byte	*/
		delete_one(thewin,thewin->flen-1,0);
	
		fildes = open(thewin->title, O_RDONLY);		/* If a same file already exist */
		if (fildes > 0)
		{
			close(fildes);

			graf_mouse(ARROW, 0L);
			if ( rsc_alert(FILE_EXIST) == 2)
				return;
			graf_mouse(BUSYBEE, 0L);

			Fdelete(thewin->title);
		}
		
		fildes = creat(thewin->title, O_RDWR);
		if(fildes != -1)
		{
			linkbufptr amem = thewin->headptr;
			int error=E_OK;

			while (amem && error >= E_OK)
			{
				error = (int)Fwrite(fildes, amem->inuse, amem->block);
			 	if (error < E_OK)
				{
					graf_mouse(ARROW,0L);
					form_error(-31-error);
					graf_mouse(BUSYBEE,0L);
				}
				amem=amem->next;
			}

			close(fildes);
			thewin->changed = FALSE;
	
			/* reinsert the Null byte at end of buffer copy of file	 */
				/* step to the last buffer block in list	*/
			for(amem=thewin->headptr;amem->next;amem=amem->next);
			
			if(amem->inuse < BLOCKSIZE)	/* can put it in an existing block */
			{
				amem->inuse ++;
				*(amem->block + amem->inuse) = (char)0;
	 			thewin->flen ++;
			}
			else
			{
				amem = addmember(thewin); 
				if (!amem)  /* no more memory available  */
				{
					graf_mouse(ARROW, 0L);
					rsc_alert(NO_LASTBYTE);
				}
				else				
				{
					amem->inuse ++;
					*(amem->block + amem->inuse) = (char)0;
					thewin->flen ++;
				}
			}	
		}
		else
		{
			graf_mouse(ARROW,0L);
			rsc_alert(SAVE_ERR);
			return;
		}
		graf_mouse(ARROW, 0L);
	}
	else
	{
		rsc_alert(SAVE_NULL);
	}
}

/*
	name: getfile
	utility: let the user to choose a file name
	comment: 
	parameters: thewin
				string: Name of the fileselector.
	return: 1 with name in thewin->title, 0 with cancel
	date: 1989
	author: Jim Charlton
	modifications:
		jun 1996: C. Moreau: fsel_input become fileselect to use new
		 fsel_exinput(TOS>1.04). Add name.
*/
int getfile(windowptr thewin, char *string)
{
	int fs_button = fsel_autoinput("*.*", fs_insel, fs_inpath, string);
		
	if (fs_button==FSEL_OK)
	{
		strcpy(thewin->title, fs_inpath); /* copy pathname to title */
		wind_set(thewin->handle, WF_NAME, thewin->title, 0, 0);
		return(1);
	}
	else
	  	return(0);
}

/*
	name: delfile
	utility: let the user to choose a file to be deleted
	comment: 
	parameters:
	return: 1 with del, 0 with cancel 
	date: 1989
	author: Jim Charlton
	modifications:
		Jun 1996: C. Moreau: fsel_input become fileselect to use new
		 fsel_exinput(TOS>1.04).
*/
int delfile(void)  
{
	int error;
	int fs_button;
	char *string;
	
	rsrc_gaddr(R_STRING, S_DELFILE, &string);
	fs_button = fsel_autoinput("*.*", fs_insel, fs_inpath, string);

	if (fs_button==FSEL_OK)
	{
		graf_mouse(BUSY_BEE, 0L);
		error = Fdelete(fs_inpath);
		graf_mouse(ARROW, 0L);

		if (error)
			form_error(-31-error);
		else
			return 1;
	}

	return(0);
}

/*
	name: init_files
	utility: initialize vars of files.c module
	comment: 
	parameters: none
	return: none
	date: 10 may 96
	author: C.Moreau
	modifications:
*/
void init_files(void)
{
	char *string;
	
		/* Get Default path for files */
	Dgetpath(lastpath, DEFAULT_DRIVE);
	sprintf(fs_inpath,"%c:%s\\*.*", 'A' + Dgetdrv(), lastpath);

	rsrc_gaddr(R_STRING, S_UNTITLED, &string);
	
	strcpy(fs_insel, string);
}
