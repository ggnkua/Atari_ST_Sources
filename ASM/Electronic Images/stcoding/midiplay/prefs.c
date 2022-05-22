/*
 * 	The Digital Sound Module.
 * 	(c) 1994 Martin Griffithis
 */ 

#include <stdio.h>
#include <e_gem.h>
#include "types.h"

Bool AutoLoadMapFlag = FALSE;
Bool AutoTestPatchFlag = FALSE;
Bool HQModeFlag = TRUE;
channel channels_info[16]; 
Bool FilterFlag[16];
unsigned char def_channel_list[16];
unsigned char def_channel_type[16];
VIEWING Current_View;
int viewinst_selected;
int viewperc_selected;
int selected_channel;
unsigned long master_vol;
unsigned long master_bal;
char curr_songpath[256];  /* Current Song Path */
char curr_songname[256];  /* Current Song Filename */
char selected_song[256];
static char curr_cfgpath[256];  /* Current Song Path */
static char curr_cfgname[256];  /* Current Song Filename */
static char selected_cfg[256];		

void Init_Channel_List(void)
{
	int i;
	for (i = 0 ; i < 16 ; i++)
	{	def_channel_list[i]=0;
		def_channel_type[i]= INSTRUMENT_CHANNEL;
	}
	def_channel_type[9] = PERCUSSION_CHANNEL;
}


void Set_Default_Cfg(void)
{		int i;
		HQModeFlag = TRUE;
		AutoLoadMapFlag = TRUE;
		AutoTestPatchFlag = TRUE;
		selected_channel = 0;
		viewinst_selected = 0;
		viewperc_selected = 0;
		master_vol = 128;
		master_bal = 64;
		Current_View = INSTRUMENT;
		Init_Channel_List();		
		for (i = 0 ; i < 16; i ++)
		{
			FilterFlag[i] = FALSE;
			channels_info[i].channel_volume = 100;
			channels_info[i].channel_bend = 64;
			channels_info[i].channel_pan = 64;
			channels_info[i].channel_used = 0;
			channels_info[i].channel_inst = 0;
			channels_info[i].noteon_ef = 0;
			channels_info[i].polypres_ef = 0;
			channels_info[i].controller_ef = 0;
			channels_info[i].progchange_ef = 0;
			channels_info[i].aftertouch_ef = 0;
			channels_info[i].pitchbend_ef =0 ;
		}
			FilterFlag[9] = TRUE;
}



void cfgfile_is_bad(void)
{
	xalert(1,1,X_ICN_DISC_ERR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
	" This does not seem to be a Config file, |"
	" Either the file may have become corrupted,    |"
	" OR you have selected the wrong file. "," [Ok ");
}

/*
 *
 */

Bool do_load_cfg(char *name)
{	long handle;
	reg int i,c;
	if ((handle = Fopen(name,FO_READ)) >=0 ) 
	{	long ID;
		Fread(handle,sizeof(long),&ID);
		if (ID != 0x12345678)
		{	cfgfile_is_bad();
			return FALSE;
		}	
		Fread(handle,sizeof(Bool),&HQModeFlag);
		Fread(handle,sizeof(Bool),&AutoLoadMapFlag);
		Fread(handle,sizeof(Bool),&AutoTestPatchFlag);
		Set_HQ_Mode(HQModeFlag);
		Set_AutoLoadMap(AutoLoadMapFlag);
		Set_AutoTestPatch(AutoTestPatchFlag);
		Fread(handle,sizeof(int),&selected_channel);
		Fread(handle,sizeof(int),&viewinst_selected);
		Fread(handle,sizeof(int),&viewperc_selected);
		Fread(handle,sizeof(long),&master_vol);
		Fread(handle,sizeof(long),&master_bal);
		init_mastervol(master_vol);
		init_masterbal(master_bal);

		Fread(handle,sizeof(VIEWING),&Current_View);		
		Fread(handle,sizeof(Bool)*16,&FilterFlag[0]);
		Fread(handle,sizeof(unsigned char)*16,&def_channel_list[0]);
		Fread(handle,sizeof(unsigned char)*16,&def_channel_type[0]);
		for (i = 0 ; i < 16; i ++)
		{	SetChannelFilterFlag(i,FilterFlag[i]);
			Set_InstOrPerc(i,def_channel_type[i]);
		}
		for (i = 0 ; i < 16; i ++)
		{
			Fread(handle,sizeof(short),&channels_info[i].channel_volume);
			Fread(handle,sizeof(short),&channels_info[i].channel_bend);
			Fread(handle,sizeof(short),&channels_info[i].channel_pan);
			Fread(handle,sizeof(unsigned char),&channels_info[i].channel_used);
			Fread(handle,sizeof(unsigned char),&channels_info[i].channel_inst);
			Fread(handle,sizeof(unsigned char),&channels_info[i].noteon_ef);
			Fread(handle,sizeof(unsigned char),&channels_info[i].polypres_ef);
			Fread(handle,sizeof(unsigned char),&channels_info[i].controller_ef);
			Fread(handle,sizeof(unsigned char),&channels_info[i].progchange_ef);
			Fread(handle,sizeof(unsigned char),&channels_info[i].aftertouch_ef);
			Fread(handle,sizeof(unsigned char),&channels_info[i].pitchbend_ef);
		}
		
		Fclose(handle);
	
		return TRUE;
	} else
	{	xalert(	1,1,X_ICN_DISC_ERR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
				" Could not Open CFG file for Reading. "," [Ok ");
		return FALSE;
	}
}

Bool load_cfg(void)
{	Bool ret = FALSE;
	if (select_file(selected_cfg,curr_cfgpath,curr_cfgname,"*.CFG","Load .CFG file"))
	{	graf_mouse(BUSYBEE,NULL);
		ret = do_load_cfg(selected_cfg);
		graf_mouse(ARROW,NULL);
	}
	return ret;
}

/*
 *
 */
 
Bool do_save_cfg(char *name)
{	reg int i,c;
	long handle;
	if ((handle = Fcreate(name,0)) >=0 ) 
	{	long ID = 0x12345678;
		Fwrite(handle,sizeof(long),&ID);
		Fwrite(handle,sizeof(Bool),&HQModeFlag);
		Fwrite(handle,sizeof(Bool),&AutoLoadMapFlag);
		Fwrite(handle,sizeof(Bool),&AutoTestPatchFlag);		
		Fwrite(handle,sizeof(int),&selected_channel);
		Fwrite(handle,sizeof(int),&viewinst_selected);
		Fwrite(handle,sizeof(int),&viewperc_selected);		
		Fwrite(handle,sizeof(long),&master_vol);
		Fwrite(handle,sizeof(long),&master_bal);		
		Fwrite(handle,sizeof(VIEWING),&Current_View);		
		Fwrite(handle,sizeof(Bool)*16,&FilterFlag[0]);
		Fwrite(handle,sizeof(unsigned char)*16,&def_channel_list[0]);
		Fwrite(handle,sizeof(unsigned char)*16,&def_channel_type[0]);
		for (i = 0 ; i < 16; i ++)
		{
			Fwrite(handle,sizeof(short),&channels_info[i].channel_volume);
			Fwrite(handle,sizeof(short),&channels_info[i].channel_bend);
			Fwrite(handle,sizeof(short),&channels_info[i].channel_pan);
			Fwrite(handle,sizeof(unsigned char),&channels_info[i].channel_used);
			Fwrite(handle,sizeof(unsigned char),&channels_info[i].channel_inst);
			Fwrite(handle,sizeof(unsigned char),&channels_info[i].noteon_ef);
			Fwrite(handle,sizeof(unsigned char),&channels_info[i].polypres_ef);
			Fwrite(handle,sizeof(unsigned char),&channels_info[i].controller_ef);
			Fwrite(handle,sizeof(unsigned char),&channels_info[i].progchange_ef);
			Fwrite(handle,sizeof(unsigned char),&channels_info[i].aftertouch_ef);
			Fwrite(handle,sizeof(unsigned char),&channels_info[i].pitchbend_ef);
		}
		
		Fclose(handle);
		return TRUE;
	} else
	{	xalert(	1,1,X_ICN_DISC_ERR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
				" Could not Open CFG file for Writing. "," [Ok ");
		return FALSE;
	}
}

void save_cfg(void)
{	Bool ret = FALSE;
	if (select_file(selected_cfg,curr_cfgpath,curr_cfgname,"*.CFG","Save .CFG file"))
	{	graf_mouse(BUSYBEE,NULL);
		ret = do_save_cfg(selected_cfg);
		graf_mouse(ARROW,NULL);
	}
	return ret;
}