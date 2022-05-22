/*
 * 		The Digital Sound Module Installation program.
 *		(version 0.70)
 * 		(c) 1994 Martin Griffiths
 *		December 8th 1994.
 */ 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <e_gem.h>
#include <ext.h>
#include "install.h"
#include "types.h"

char *title = "  T.D.S.M. "VERSION" Installation  ";

static OBJECT *install_tree;
static DIAINFO install_win;
static DIAINFO *ex_info;

static char serial[64];
static char name[64];
static char address[64];
static char city[64];
static char postcode[64];
static char app_path[256];
static char patch_path[256];

static int curr_drive;
static int gemdos_drive;
static char source_path[256];		/* source path */				
static char cfg_path[256];			/* path/name for config */
static char map_path[256];			/* path/name for map */
static char tmp[256];				

#define DEFAULT_APPPATH "\\MIDIPLAY\\"
#define DEFAULT_PATPATH "\\GM2.SET\\"

void ExitExample(int all)
{	close_all_dialogs();
	if (all)
	{	
		close_rsc(0);
		exit(0);
	}
}

void validate_path(char *s)
{	if (s[strlen(s)-1] != '\\')
		strcat(s,"\\");
}

Bool copy_file(char *name,char *path)
{	long handle,l;
	alloc16 m;
	strcpy(tmp,source_path);
	strcat(tmp,name);
	l = filesize(tmp);
	/*fprintf(stdout,"\n%s %ld -> ",tmp,l);*/
	if ((handle = Fopen(tmp,FO_READ)) >=0 ) 
	{	if (malloc16(l,&m) == NULL)
		{	xalert(1,1,X_ICN_ERROR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title," Out of Memory! "," [Exit ");
			ExitExample(1);
		}
		if (Fread(handle,l,m.ptr) != l)	
		{	Fclose(handle);
			return FALSE;
		}	
		Fclose(handle);
	} else
	{	xalert(1,1,X_ICN_ERROR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title," Open File Failed (Disk Error?) "," [Exit ");
		return FALSE;
	}

	strcpy(tmp,path);
	strcat(tmp,name);
	/*fprintf(stdout,"%s \n",tmp);*/
	
	if ((handle = Fcreate(tmp,0)) >=0 ) 
	{	
		if (Fwrite(handle,l,m.ptr) != l)
		{	Fclose(handle);
			return FALSE;
		}
		Fclose(handle);
	} else
		return FALSE;
			
	free16(&m);
}

Bool Do_Install(void)
{		int i;
		graf_mouse(BUSYBEE,NULL);
		if ((strlen(app_path) < 2) || (strlen(patch_path) <2))
		{
			graf_mouse(ARROW,NULL);
			return FALSE;
		}
		validate_path(app_path);		
		validate_path(patch_path);		
		
		for (i = 0 ; i < NO_INSTRUMENT ; i++)
		{
			strcpy(tmp,&gm_instrument_fnames[i][0]);
			strcpy(&gm_instrument_fnames[i][0],patch_path);
			strcat(&gm_instrument_fnames[i][0],tmp);
		}
		for (i = 0 ; i < NO_PERCUSSION ; i++)
		{	strcpy(tmp,&gm_percussion_fnames[i][0]);
			strcpy(&gm_percussion_fnames[i][0],patch_path);
			strcat(&gm_percussion_fnames[i][0],tmp);		
		}
		strcpy(map_path,app_path);
		strcat(map_path,MAP_NAME);
		if (do_save_map(map_path) == FALSE)
		{	graf_mouse(ARROW,NULL);
			xalert(1,1,X_ICN_ERROR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title," Failed to create Default MAP! "," [Exit ");
			return FALSE;
		}
		strcpy(cfg_path,app_path);
		strcat(cfg_path,CFG_NAME);
		Set_Default_Cfg();
		if (do_save_cfg(cfg_path) == FALSE)
		{	graf_mouse(ARROW,NULL);
			xalert(1,1,X_ICN_ERROR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title," Failed to create Default CFG! "," [Exit ");
			return FALSE;
		}
		
		copy_file("MIDIPLAY.PRG",app_path);
		copy_file("MIDIPLAY.RSC",app_path);
		copy_file("MIDI_ENG.LOD",app_path);
		copy_file("VOL_CONV.DAT",app_path);
		
		graf_mouse(ARROW,NULL);
		return TRUE;
}


void init_drive_map(void)
{	int i;
	unsigned long map = Drvmap();
	for (i = 0 ; i < 14 ; i++)
	{	ob_undostate(install_tree,i+I_C,SELECTED);
		if (map & (1 << i+2))
			ob_undostate(install_tree,i+I_C,DISABLED);
		else
			ob_dostate(install_tree,i+I_C,DISABLED);
	}
	for (i = 0 ; i < 14 ; i++)
	{	if (map & (1 << i+2))
		{	ob_dostate(install_tree,i+I_C,SELECTED);
			curr_drive = i;
			break;
		}
	}
}

void create_default_paths(void)
{		char drive[] = " :";
		drive[0] = 'C' + curr_drive;
		app_path[0]='\0';
		patch_path[0]='\0';
		strcat(app_path,drive);
		strcat(patch_path,drive);
		strcat(app_path,DEFAULT_APPPATH);
		strcat(patch_path,DEFAULT_PATPATH);
}


void init_resource(void)
{
	rsrc_gaddr(0,INSTALL,&install_tree);
	fix_objects(install_tree,NO_SCALING,8,16 );
}


int InitMsg(XEVENT *evt,int events_available)
{
	reg int flags = 0;
	return (flags & events_available);
}

int Messag(XEVENT *event)
{
	reg int ev = event->ev_mwich,*msg = event->ev_mmgpbuf;
	reg int used = 0;
	return (used);
}

/*
 *     Main... 
 */

void main()
{	int ext,double_click;
	DIAINFO *ex_info = &install_win;
	getcwd(source_path, 255);
	validate_path(source_path);		
	switch (open_rsc("install.rsc","",
	                 "",
	                 "",0,0,0))
	{
		case FAIL:
			form_alert(1, "[3][Resource-File not found|or not enough memory!][Cancel]");
			break;
		case FALSE:
			form_alert(1, "[3][Couldn't open|workstation!][Cancel]");
			break;
		case TRUE:
		{
			if (_app)
			{	wind_update(BEG_UPDATE);
				init_resource();
				Event_Handler(InitMsg,Messag);
			    dial_colors(7,(colors>=16) ? WHITE : WHITE,GREEN,RED,MAGENTA,BLUE,CYAN,RED);
				dial_options(TRUE,TRUE,FALSE,TRUE,FAIL,TRUE,FALSE,FALSE,TRUE);
				title_options(FALSE,BLACK,FALSE);
				wind_update(END_UPDATE);

				init_drive_map();
				create_default_paths();
			
				(&install_tree[SERIAL])->ob_spec.tedinfo->te_ptext=serial;
				(&install_tree[NAME])->ob_spec.tedinfo->te_ptext=name;
				(&install_tree[ADDRESS])->ob_spec.tedinfo->te_ptext=address;
				(&install_tree[CITY])->ob_spec.tedinfo->te_ptext=city;
				(&install_tree[POSTCODE])->ob_spec.tedinfo->te_ptext=postcode;
				(&install_tree[APPPATH])->ob_spec.tedinfo->te_ptext=app_path;
				(&install_tree[PATCHPATH])->ob_spec.tedinfo->te_ptext=patch_path;
				
				if (open_dialog(install_tree,&install_win,NULL,NULL,NULL,FALSE,FALSE,FLY_DIAL,0,NULL)==FALSE)
				{	xalert(1,1,X_ICN_ERROR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,"Fatal error - Couldn't open Install Window!"," [Exit ");
					ExitExample(0);
				}	
				while (1)
				{	ext = X_Form_Do(&ex_info);
					ext ^= (double_click = ext & 0x8000);
					switch (ext)
					{	case DOABORT:
						{
							ExitExample(1);
							break;
						}
						case DOINSTALL:
						{	if (Do_Install() == TRUE)
							{	xalert(1,1,X_ICN_INFO,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title," Installation Successful! ","[Exit");
								ExitExample(1);
							}
							break;
						}
					
						case I_C:
						case I_D:
						case I_E:
						case I_F:
						case I_G:
						case I_H:
						case I_I:
						case I_J:
						case I_K:
						case I_L:
						case I_M:
						case I_N:
						case I_O:
						case I_P:
						{	
							ob_undostate(ex_info->di_tree,curr_drive+I_C,SELECTED);
							ob_dostate(ex_info->di_tree,ext,SELECTED);
							ob_draw_chg(ex_info,curr_drive+I_C,NULL,FAIL,FALSE);
							ob_draw_chg(ex_info,ext,NULL,FAIL,FALSE);
							curr_drive = ext - I_C;
							create_default_paths();
							ob_draw_chg(ex_info,APPPATH,NULL,FAIL,FALSE);
							ob_draw_chg(ex_info,PATCHPATH,NULL,FAIL,FALSE);
							wait_buttonup();

							break;
						}
					}
				}
				ExitExample(1);
			}
		}
	}
}