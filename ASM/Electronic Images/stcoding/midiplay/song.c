/*
 *	(c) Martin Griffiths August 1994.
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <e_gem.h>
#include <ext.h>
#include "midiplay.h"
#include "types.h"
	
extern OBJECT *load_form;
extern DIAINFO load_win;
extern char *title;
alloc16 Song;
Bool Song_Loaded;

int Patches_Loaded;
unsigned char Insts_Used_In_Song[128];
unsigned char Percs_Used_In_Song[128];
unsigned char Insts_Used_In_SongOLD[128];
unsigned char Percs_Used_In_SongOLD[128];
unsigned char Insts_Used[128];
unsigned char Percs_Used[128];

void Update_Main_Info_Bar()
{	extern OBJECT *instlist_tree;
	extern DIAINFO instlist_win;
	static	char info_text[80];
	sprintf	(info_text," Patches Resident : %03d.   Memory Free : %05ld Kb ",Patches_Loaded,coreleft()/1024l);
	(&instlist_tree[PLAYERINFO])->ob_spec.tedinfo->te_ptext=info_text;
	if (instlist_win.di_flag>CLOSED)
		ob_draw_chg(&instlist_win,PLAYERINFO,NULL,0);
}


	
void Init_InstPerc_Lists(void)
{	
	int i;
	for (i = 0 ; i < NO_INSTRUMENT ; i++)
	{	Insts_Used_In_Song[i] = FALSE;
		Percs_Used_In_Song[i] = FALSE;
		Insts_Used_In_SongOLD[i] = FALSE;
		Percs_Used_In_SongOLD[i] = FALSE;
		Insts_Used[i] = FALSE;
		Percs_Used[i] = FALSE;
	}
}	

void InitSongPatchList(void)
{	int i;
	for (i=0 ; i < NO_INSTRUMENT ; i++)
	{		Insts_Used_In_SongOLD[i] = Insts_Used_In_Song[i];
			Percs_Used_In_SongOLD[i] = Percs_Used_In_Song[i];
			Insts_Used_In_Song[i] = 0;
			Percs_Used_In_Song[i] = 0;
	}
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
 *
 */

void FreePatch(Patch_Info *this_patch)
{	if (this_patch->sample_pointer.allocd != NULL)
	{	free16(&(this_patch->sample_pointer));
		Patches_Loaded--;
	}
}

void FreeUnusedPatches(void)
{	int i;
	for (i = 0 ; i < NO_INSTRUMENT ; i++)
	{		if ((Insts_Used_In_SongOLD[i] !=0) && (Insts_Used_In_Song[0] == 0))
				FreePatch(&PatchLIST[i]);
	}
}

/*
 *
 */

Bool Load_Patch(char *patch_name,Patch_Info *this_patch)
{	long handle,length = filesize(patch_name);
	if ((handle = Fopen(patch_name,0)) >=0 ) 
	{
		if (malloc16(length,&(this_patch->sample_pointer)) != NULL)
		{	if (Fread(handle,length,this_patch->sample_pointer.ptr) != length)	
			{	xalert(	1,1,X_ICN_DISC_ERR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
					" Read Error, (Patch Sample Data). "," [Ok ");
				Fclose(handle);
				return FALSE;
			}
			Fclose(handle);
			Patches_Loaded++;
			return TRUE;
		} else
		{	xalert(	1,1,X_ICN_ALERT,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
					" Out of Memory, Patch Not Loaded. "," [Ok ");
			Fclose(handle);
			return FALSE;
		}			
	} else
	{	xalert(	1,1,X_ICN_DISC_ERR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
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
		{
			if (UsedList[i])
			{	
				this_len = filesize(fname[i]);
				if (this_len !=-1)
					total_length += this_len;
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
			if (PatchLIST[i].sample_pointer.allocd == NULL)
				Load_Patch(fname[i],&PatchLIST[i]);
			
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


void LoadDefListPatches(void)
{	int i;
	char this_used_inst[NO_INSTRUMENT];
	char this_used_perc[NO_INSTRUMENT];
	for (i = 0 ; i < NO_INSTRUMENT ; i++)
	{	this_used_inst[i] = 0;
		this_used_perc[i] = 0;
	}	

	for (i = 0 ; i < 16 ; i++)
	{	this_used_inst[def_channel_list[i]] = -1;
	}
	Do_Load_Patches(&this_used_inst[0],&gm_instrument_fnames[0][0],NO_INSTRUMENT);
}

/*
 *
 */
 
Bool load_song(char *name)
{	long handle,len;
	if ((handle = Fopen(name,0)) >=0 ) 
	{	
		free16(&Song);
		len = filesize(name);
		if (malloc16(len,&Song) != NULL)
		{	if (Fread(handle,len,Song.ptr) == len)	
			{	Fclose(handle);
				return TRUE;
			}
			xalert(	1,1,X_ICN_DISC_ERR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
					" Load Error, Midi file not loaded. "," [Ok ");
			return FALSE;
		}
		xalert(	1,1,X_ICN_ALERT,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
				" Not enough memory to load midi file. "," [Ok ");
		return FALSE;
	}
	xalert(	1,1,X_ICN_DISC_ERR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
			" Could not open midi file (not found?). "," [Ok ");
	return FALSE;
}



Bool go_load_song(void)
{
	StopMusic();
	if (select_file(selected_song,curr_songpath,curr_songname,"*.MID","Load .MID file"))
	{		graf_mouse(BUSYBEE,NULL);
			load_song(selected_song);
			Update_Main_Info_Bar();
			graf_mouse(ARROW,NULL);
			switch (CheckInitMidiFile(Song.ptr))
			{	case 0:	
						InitSongPatchList();
						resetmidichans();
						ScanMidiFile();
						FreeUnusedPatches();
						Set_Channels_Used();
						Redraw_DefList();
						ResetMidiTracks();
						if (Do_Load_Patches(&Insts_Used_In_Song[0],&gm_instrument_fnames[0][0],NO_INSTRUMENT) == TRUE)
						{	Song_Loaded = TRUE;
							set_player_status_filename(curr_songname);
							set_player_status(STOPPED);
							return TRUE;
						} 
						break;
				case 1:	xalert(	1,1,X_ICN_ALERT,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
						" The file you selected is not a Standard Midi File. "," [Ooops ");
						break;
				case 2:	xalert(	1,1,X_ICN_ALERT,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
						" Sorry, only Standard Midi File Types 0 and 1 are supported, |"
						" - the midi file you selected is not one of these types. "," [Ok ");
						break;
			}
			free16(&Song);
			Song_Loaded = FALSE;
			set_player_status(NOSONG);
	}
	return FALSE;

}