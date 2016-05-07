#include "extern.h"

static char option_file[MAXPATH];
extern long spd_table[5];

extern DIALOG playopt_dia;
extern DIALOG mboard_dia;

/* ------------------------
   | Load option settings |
   ------------------------ */
void load_options(void)
{
long f_handle;

strcpy(option_file, path);
strcpy(strchr(option_file, '.') - 1, "DSPROG.OPT");

f_handle = Fopen(option_file, FO_READ);
if (f_handle > 0)
	{
	Fread((int)f_handle, 2L, &flt_ovsm);
	Fread((int)f_handle, 2L, &flt_bad);
	Fread((int)f_handle, 2L, &flt_pitch);
	Fread((int)f_handle, 2L, &flt_slice);

	Fread((int)f_handle, 2L, &pck_filt);
	Fread((int)f_handle, 2L, &pck_4plus);
	Fread((int)f_handle, 2L, &pck_4bit);
	Fread((int)f_handle, 2L, &pck_alter);

	Fread((int)f_handle, 2L, &ovsm_typ);

	Fread((int)f_handle, 2L, &ply_speed);
	Fread((int)f_handle, 2L, &play_ovsm);
	Fread((int)f_handle, 2L, &play_dev);

	Fread((int)f_handle, 4L, &spd_table[4]);
	Fread((int)f_handle, sizeof(mw_data), mw_data);

	Fread((int)f_handle, 4L, smp_extension);
	Fread((int)f_handle, 4L, pck_extension);
	Fread((int)f_handle, 4L, avr_extension);
	
	Fclose((int)f_handle);
	
	ltoa(spd_table[4], playopt_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt, 10);
	strcat(playopt_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt, " KHz");
	
	strcpy(mboard_dia.tree[MBMANU].ob_spec.tedinfo->te_ptmplt,
				 playopt_dia.tree[MBMANU].ob_spec.tedinfo->te_ptmplt);
	}
}

/* ------------------------
   | Save option settings |
   ------------------------ */
void save_options(void)
{
long f_handle;

f_handle = Fcreate(option_file, 0);
if (f_handle > 0)
	{
	Fwrite((int)f_handle, 2L, &flt_ovsm);
	Fwrite((int)f_handle, 2L, &flt_bad);
	Fwrite((int)f_handle, 2L, &flt_pitch);
	Fwrite((int)f_handle, 2L, &flt_slice);

	Fwrite((int)f_handle, 2L, &pck_filt);
	Fwrite((int)f_handle, 2L, &pck_4plus);
	Fwrite((int)f_handle, 2L, &pck_4bit);
	Fwrite((int)f_handle, 2L, &pck_alter);

	Fwrite((int)f_handle, 2L, &ovsm_typ);

	Fwrite((int)f_handle, 2L, &ply_speed);
	Fwrite((int)f_handle, 2L, &play_ovsm);
	Fwrite((int)f_handle, 2L, &play_dev);

	Fwrite((int)f_handle, 4L, &spd_table[4]);
	Fwrite((int)f_handle, sizeof(mw_data), mw_data);
	
	Fwrite((int)f_handle, 4L, smp_extension);
	Fwrite((int)f_handle, 4L, pck_extension);
	Fwrite((int)f_handle, 4L, avr_extension);
	
	Fclose((int)f_handle);
	}
}
