#include "extern.h"

static char edit_path[156];
static char edit_files[4];
static char dest_files[4];
static int dir_filt = 1, dir_ovsm = 0, dir_pack = 0;

/* ------------------
   | Set path field |
   ------------------ */
void set_dirpath(OBJECT *tree, char *p)
{
strcpy(edit_path, p);
*strrchr(edit_path, '\\') = 0;
if (strchr(edit_path, '\\') < strrchr(edit_path, '\\'))
	{
	strcpy(tree[DIR_PATH].ob_spec.free_string, "...");
	strcat(tree[DIR_PATH].ob_spec.free_string, strrchr(edit_path, '\\'));
	}
else
	strcpy(tree[DIR_PATH].ob_spec.free_string, edit_path);
	
strcat(tree[DIR_PATH].ob_spec.free_string, "\\");
strcat(edit_path, "\\");
}

/* -----------------
	 | Execute batch |
	 ----------------- */
void dir_edit(void)
{
OBJECT *edit_paras;
int hndl, ret;

rsrc_gaddr(R_TREE, DIR_EDIT, &edit_paras);

edit_paras[DIR_FILT].ob_state &= ~SELECTED;
edit_paras[DIR_OVSM].ob_state &= ~SELECTED;
edit_paras[DIR_PCK].ob_state &= ~SELECTED;
edit_paras[DIR_FILT].ob_state |= dir_filt;
edit_paras[DIR_OVSM].ob_state |= dir_ovsm;
edit_paras[DIR_PCK].ob_state |= dir_pack;

set_dirpath(edit_paras, path);

hndl = dialog_window(0, edit_paras, OPN_DIA, 0);
do
	{
	ret = dialog_window(hndl, edit_paras, ACT_DIA, 0);
	
	if (ret == SEL_PATH)
		if (select_sample())
			{
			set_dirpath(edit_paras, path);
			redraw_obj(edit_paras, DIR_PATH);
			}
			
	}while(ret != DIR_STRT && ret != DIR_CNC);
	
dialog_window(hndl, edit_paras, CLS_DIA, 0);

if (ret == DIR_STRT)
	{
	dir_filt = edit_paras[DIR_FILT].ob_state & SELECTED;
	dir_ovsm = edit_paras[DIR_OVSM].ob_state & SELECTED;
	dir_pack = edit_paras[DIR_PCK].ob_state & SELECTED;

	strcpy(edit_files, edit_paras[LOAD_TYP].ob_spec.tedinfo->te_ptext);
	strcpy(dest_files, edit_paras[SAVE_TYP].ob_spec.tedinfo->te_ptext);

	start_edit();
	}
}

/* ------------------------
   | Start directory edit |
   ------------------------ */
void start_edit(void)
{
DTA srch;
char find[156];
int s;

Fsetdta(&srch);
strcpy(find, edit_path);
strcat(find, "*.");
strcat(find, edit_files);

s = Fsfirst(find, 0x2F);
while(!s)
	{
	strcpy(fname, edit_path);
	strcat(fname, srch.d_fname);
	strcpy(file, srch.d_fname);
	
	load(0);
	sample_redraw(-1);
	
	if (dir_filt)
		filter();
		
	if (dir_ovsm)
		do_oversam();
		
	if (dir_pack)
		kompakt(0);

	strcpy(strrchr(fname, '.') + 1, dest_files);
	save_file(fname, o_bytes, total);
	
	s = Fsnext();
	}
	
if (o_bytes)
	{
	free(o_bytes);
	total = 0L;
	sample_redraw(-1);
	}
}
