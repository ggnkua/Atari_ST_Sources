/*
 *	(c) Martin Griffiths August 1994.
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <e_gem.h>
#include <string.h>
#include <ext.h>
#include "types.h"

static char curr_songpath[256];  /* Current Song Path */
static char curr_songname[256];  /* Current Song Filename */
static char selected_song[256];		

extern OBJECT *load_form;
extern DIAINFO load_win;
extern char *title;
alloc16 Song;

/*
 *	Allocate memory on a 16 byte boundary.
 */
 
void *malloc16(long l,alloc16 *a)
{		if	(a != NULL)
		{	if ((a->allocd = malloc(l+16)) != NULL)
			{	a->ptr = ((long) (a->allocd)+15) & 0xfffffff0;
				return (a->ptr);
			}
		}
		return NULL;
}

/*
 *	Free a memory block on a 16 byte boundary.
 */

void free16(alloc16 *a)
{	if (a->allocd != NULL)
	{	free(a->allocd);
		a->allocd = NULL;
		a->ptr = NULL;
	}
}

/*
 *    Return the size of a file
 */

long filesize(char *fpath)
{	DTA *cdta=Fgetdta();
	if (Fsfirst(fpath,0) >= 0)
		return ((long) cdta->d_length);
	return -1;
}

/*
 *
 */

Bool Alloc_Read_File(char *name,alloc16 *m)
{	long handle;
	long length = filesize(name);
	if ((handle = Fopen(name,0)) >=0 ) 
	{	malloc16(length,m);
		if (Fread(handle,length,m->ptr) != length)	
		{	Fclose(handle);
			return FALSE;
		}	
		Fclose(handle);
		return TRUE;
	} else
		return FALSE;
}

/*
 *      Select a file,returning the full path.
 *      returns 0 if no error, or 1 if no file selected.  
 */

int select_file(char *rpath,char *cpath,char *filename,char *fmask,char *title)
{	int button;
	if (!strcmp(cpath,""))
		getcwd(cpath,256-1);
	strcpy(strrchr(cpath,(int) '\\')+1,fmask);
	fsel_exinput(cpath,filename,&button,title);
	if ((button != 0) && (strcmp(filename,"")) )
	{	strcpy(rpath,cpath);
		strcpy(strrchr(rpath,(int) '\\')+1,filename);
		return 1;
	}
	return 0;
}

/*
 *   Wait for the mouse button(s) to be released.
 */
 
void wait_buttonup(void)
{	int mx,my,mk,kk;
	do 
	{	graf_mkstate(&mx,&my,&mk,&kk);
	}	while (mk);
}

/*
 *
 */

void free_patch_memory(Patch_Info *this_patch)
{	int i;
	for (i = 0 ; i < 12 ; i++)
		free16(&this_patch->sample_pointer[i]);
	
}

Bool Load_Patch(char *patch_name,Patch_Info *this_patch)
{	long handle;
	unsigned char header[239];
	char p[96];
	long length;
	int	i;
	if ((handle = Fopen(patch_name,0)) >=0 ) 
	{	if (Fread(handle,239,(char *) &header) != 239)
		{	xalert(	1,1,X_ICN_DISC_ERR,NULL,BUTTONS_CENTERED,TRUE,title,
					" Read Error, (Patch File Main Header). "," [Ok ");
			Fclose(handle);
			return FALSE;
		}	
		
		this_patch->Patch_NoSamples = header[198];
		for (i=0 ; i < this_patch->Patch_NoSamples; i++)
		{	
			if (Fread(handle,96,&p[0]) != 96)	
			{	xalert(	1,1,X_ICN_DISC_ERR,NULL,BUTTONS_CENTERED,TRUE,title,
						" Read Error, (Patch Sample Data Header). "," [Ok ");
				Fclose(handle);
				return FALSE;
			}

			length = conv_patch(&p[0]);
			if (malloc16(length+96+16384,&(this_patch->sample_pointer[i])) != NULL)
			{	memcpy(this_patch->sample_pointer[i].ptr,&p[0],96);
				if (Fread(handle,length,((char *) (this_patch->sample_pointer[i].ptr))+96) != length)	
				{	xalert(	1,1,X_ICN_DISC_ERR,NULL,BUTTONS_CENTERED,TRUE,title,
							" Read Error, (Patch Sample Data). "," [Ok ");
					Fclose(handle);
					return FALSE;
				}
			} else
			{	xalert(	1,1,X_ICN_ALERT,NULL,BUTTONS_CENTERED,TRUE,title,
					" Out of Memory, Patch Not Loaded. "," [Ok ");
				Fclose(handle);
				return FALSE;
			}
			InitInstrument(this_patch->sample_pointer[i].ptr);
			
		}			
		Fclose(handle);
		return TRUE;
	} else
	{	xalert(	1,1,X_ICN_DISC_ERR,NULL,BUTTONS_CENTERED,TRUE,title,
				" Could not open Patchfile file (not found?). "," [Ok ");
		return FALSE;
	}
}

void Set_Channels_Used(void)
{	int i;
	for (i=0 ; i < 16 ; i++)	/* fill in channels used dialog */
	{	if (channels_info[i].channel_used)
			SetChannelUsed(i,TRUE);
		else
			SetChannelUsed(i,FALSE);
	}
}

/*
 *
 */

Bool Do_Load_Patches(char *UsedList,char fname[][FNAME_LEN],int n)
{	char patchfname[FNAME_LEN];
	int x,y,w,h,i;
	long this_len,curr_length =0, total_length = 0;
	int progress_total_width = (&load_form[LOADPROGRESSBK])->ob_width;
	OBJECT *prog_obj = &load_form[LOADPROGRESSBAR];
	{	Bool are_some = FALSE;
		for (i=0 ; i < n ; i++)
		{	if (UsedList[i])
			{	
				this_len = filesize(fname[i]);
				if (this_len !=-1)
				{	free_patch_memory(&PatchLIST[i]);
					total_length += this_len;
				}
				are_some = TRUE;
			}
		}
		if (are_some == FALSE)
			return TRUE;
	}

	prog_obj->ob_width = 0;
	(&load_form[LOADINGPTCHRNAME])->ob_spec.tedinfo->te_ptext = "";
	(&load_form[LOADINGPTCHFNAME])->ob_spec.tedinfo->te_ptext = "";
	(&load_form[LOADING_OKBUT])->ob_state |= DISABLED;

	wind_update(BEG_UPDATE);
	form_center(load_form,&x,&y,&w,&h);
	form_dial(0,0,0,0,0,x,y,w,h);
	form_dial(1,0,0,0,0,x,y,w,h);
	objc_draw(load_form,0,MAX_DEPTH,x,y,w,h);
	wind_update(END_UPDATE);

	
	for (i=0 ; i < n ; i++)
	{	if (UsedList[i])
		{	
			(&load_form[LOADINGPTCHRNAME])->ob_spec.tedinfo->te_ptext = gm_instrument[i];
			strcpy(patchfname,strrchr(fname[i],(int) '\\')+1);
			(&load_form[LOADINGPTCHFNAME])->ob_spec.tedinfo->te_ptext = patchfname;

			wind_update(BEG_UPDATE);
			objc_draw(load_form,LOADINGPTCHRNAME,MAX_DEPTH,x,y,w,h);
			objc_draw(load_form,LOADINGPTCHFNAME,MAX_DEPTH,x,y,w,h);
			wind_update(END_UPDATE);

			if (Load_Patch(fname[i],&PatchLIST[i]) == TRUE)
				Patches_Loaded++;
			this_len=filesize(fname[i]);
			if (this_len !=-1)
					curr_length += this_len;

			{	prog_obj->ob_width = (progress_total_width*curr_length)/total_length;
				if (prog_obj->ob_width > progress_total_width)
					prog_obj->ob_width = progress_total_width;
				Vsync();
				wind_update(BEG_UPDATE);
				objc_draw(load_form,LOADPROGRESSBAR,1,x,y,w,h);
				wind_update(END_UPDATE);
			}
		}
	}
	
	Update_Main_Info_Bar();

	wind_update(BEG_UPDATE);
	form_dial(2,0,0,0,0,x,y,w,h);
	form_dial(3,0,0,0,0,x,y,w,h);
	wind_update(END_UPDATE);
	return TRUE;

}

/*
 *
 */
 
Bool load_song(char *name)
{	long handle;
	if ((handle = Fopen(name,0)) >=0 ) 
	{	free16(&Song);
		Song.len = filesize(name);
		if (malloc16(Song.len,&Song) != NULL)
		{	if (Fread(handle,Song.len,Song.ptr) == Song.len)	
			{	Fclose(handle);
				return TRUE;
			}
			xalert(	1,1,X_ICN_DISC_ERR,NULL,BUTTONS_CENTERED,TRUE,title,
					" Load Error, Midi file not loaded. "," [Ok ");
			return FALSE;
		}
		xalert(	1,1,X_ICN_ALERT,NULL,BUTTONS_CENTERED,TRUE,title,
				" Not enough memory to load midi file. "," [Ok ");
		return FALSE;
	}
	xalert(	1,1,X_ICN_DISC_ERR,NULL,BUTTONS_CENTERED,TRUE,title,
			" Could not open midi file (not found?). "," [Ok ");
	return FALSE;
}

extern char Insts_Used_In_Song[NO_INSTRUMENT];
extern char Percs_Used_In_Song[NO_INSTRUMENT];


Bool go_load_song(void)
{
	if (select_file(selected_song,curr_songpath,curr_songname,"*.MID","Load .MID file"))
	{		graf_mouse(BUSYBEE,NULL);
			load_song(selected_song);
			Update_Main_Info_Bar();
			graf_mouse(ARROW,NULL);
			switch (CheckInitMidiFile(Song.ptr))
			{	case 0:	
						resetmidichans();
						ClearSongPatchesUsed();
						ScanMidiFile();
						Set_Channels_Used();
						set_player_status_filename(curr_songname);
						set_player_status(STOPPED);
						Do_Load_Patches(&Insts_Used_In_Song[0],&gm_instrument_fnames[0][0],NO_INSTRUMENT);
						return TRUE;
				case 1:	xalert(	1,1,X_ICN_ALERT,NULL,BUTTONS_CENTERED,TRUE,title,
						" The file you selected is not a Standard Midi File. "," [Ooops ");
						break;
				case 2:	xalert(	1,1,X_ICN_ALERT,NULL,BUTTONS_CENTERED,TRUE,title,
						" Sorry, only Standard Midi File Types 0 and 1 are supported, |"
						" - the midi file you selected is not one of these types. "," [Ok ");
						break;
			}
			free16(&Song);
	}
	return FALSE;

}