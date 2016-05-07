long total;
char fname[256];									/* Filename */

char *o_bytes = 0;								/* Original-Sample 8 Bit */
long maxp;

int vdi_handle;
int work_in[11];							/* Workstationinfo	*/
int work_out[57];							/*          "				*/

OBJECT *menu_adr;

int msg[8];

long spd_table[] = {6250, 12500, 25000, 50000L, 10000L};

int sub_tab = 0;
int ovsm_prep = 1;
int badf_kill = 1;
int sink_frq = 0;
int flat_frq = 0;
int ovsm_typ = 3;		
int korr_val = 31;
int pck_filt = 0;
int bit4_pck = 1;
int bitp_pck = 1;
int ovsm_ply = 1;
int play_spd = 1;
int play_mode = PSG;
unsigned long cpu_type = 68000L;
unsigned long machine = 0L;

char path[127];
char file[14];

long smp_area[MAX_BLK];						/* Original Sample */
long pow_dat[MAX_BLK / 2];				/* Power Spektrum */

int r_xy[4];

SEQUENZ *seq_data = NULL;
int *play_list = NULL;

int seq_num = 0;
int lst_num = 0;
int max_seq;
