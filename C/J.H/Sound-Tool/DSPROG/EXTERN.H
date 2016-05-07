#include <aes.h>
#include <vdi.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <tos.h>								/* TOS-Bindings */
#include <stdio.h>
#include <time.h>
#include <ext.h>

#include "defines.h"
#include "dsprog.h"
#include "structs.h"
#include "prototyp.h"

#define MAX_BLK 8192
#define MAX_BITS 13
#define MAX_ICONS 40

extern int vdi_handle;
extern int work_in[11];							/* Workstationinfo	*/
extern int work_out[57];							/*          "				*/

extern int r_xy[4];

extern OBJECT *menu_adr;

extern int ev_action;
extern int msg[8];
extern int mx, my, mb, ks, kr, br, which;

extern int exclusive_wind;

extern char path[127];
extern char file[14];

extern int flt_ovsm;
extern int flt_bad;
extern int flt_pitch;
extern int flt_slice;

extern int pck_filt;
extern int pck_4plus;
extern int pck_4bit;
extern int pck_alter;

extern int ovsm_typ;

extern int play_dummy;
extern int ply_speed;
extern int play_ovsm;
extern int play_dev;

extern DIALOG *dia_adr[20];

extern SOUND *(*samples);
extern int max_samples;
extern int akt_samples;

extern long *play_seqs;

extern long maxp;
extern unsigned long cpu_type;
extern unsigned long machine;
extern int falcon_flg;

extern int korr_val;
extern int snd_type;

extern int mw_data[5];

extern int pck_tab[17];
extern int last_sample;
extern int flt_active;
extern int statis_active;

extern char *smp_extension;
extern char *pck_extension;
extern char *avr_extension;

extern int chr_wdth, chr_hght;

extern int icon_no[];
extern OBJECT *w_bkg, *ic_src;
