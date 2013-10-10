int vdi_handle;
int work_in[11];							/* Workstationinfo	*/
int work_out[57];							/*          "				*/

int r_xy[4];

OBJECT *menu_adr;

int ev_action = MU_MESAG|MU_BUTTON|MU_KEYBD;
int msg[8];
int mx, my, mb, ks, kr, br, which;

char path[127];
char file[14];

int exclusive_wind = 0;

int flt_ovsm = 1;
int flt_bad = 0;
int flt_pitch = 0;
int flt_slice = 0;

int pck_filt = 0;
int pck_4plus = 1;
int pck_4bit = 1;
int pck_alter = 0;

int ovsm_typ = 1;

int play_dummy;
int ply_speed = 1;
int play_ovsm = 1;
int play_dev = 0;

DIALOG *dia_adr[20] = {NULL, NULL, NULL, NULL, NULL,
											 NULL, NULL, NULL, NULL, NULL,
											 NULL, NULL, NULL, NULL, NULL,
											 NULL, NULL, NULL, NULL, NULL};

SOUND *(*samples);
int max_samples = 0;
int akt_samples = 0;

long *play_seqs;

long maxp;

unsigned long cpu_type = 68000L;
unsigned long machine;
int falcon_flg = 0;

int korr_val = 31;
int snd_type = -1;

int mw_data[] = {40, 20, 20, 6, 6};

int pck_tab[17] = {-128, -64, -32, -16, -8, -4, -2, -1,
											0,	 1, 	2,	 4,  8, 16, 32, 64, 128};

int last_sample = -1;
int flt_active = -1;
int statis_active = 0;

char *smp_extension;
char *pck_extension;
char *avr_extension;

int chr_wdth, chr_hght;

int icon_no[MAX_ICONS] = {I1, I2, I3, I4, I5, I6, I7, I8, I9, I10,
													I11, I12, I13, I14, I15, I16, I17, I18, I19, I20,
													I21, I22, I23, I24, I25, I26, I27, I28, I29, I30,
													I31, I32, I33, I34, I35, I36, I37, I38, I39, I40};

OBJECT *w_bkg, *ic_src;
