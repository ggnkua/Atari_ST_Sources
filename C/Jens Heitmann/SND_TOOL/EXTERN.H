#include <aes.h>
#include <vdi.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <tos.h>								/* TOS-Bindings */
#include <stdio.h>
#include <time.h>
#include <ext.h>

#include "snd_tool.h"
#include "prototyp.h"

#define CLS_DIA 0
#define OPN_DIA 1
#define RDW_DIA 2
#define ACT_DIA 3

#define MAX_BLK 8192
#define MAX_BITS 13

extern long total;
extern char fname[256];										/* Filename */

extern char *o_bytes;										/* Original-Sample 8 Bit */
extern long maxp;

extern int vdi_handle;
extern int work_in[11];							/* Workstationinfo	*/
extern int work_out[57];							/*          "				*/

extern OBJECT *menu_adr;

extern int msg[8];

extern long spd_table[];

extern int sub_tab;
extern int ovsm_prep;
extern int badf_kill;
extern int sink_frq;
extern int flat_frq;
extern int ovsm_typ;		
extern int korr_val;
extern int pck_filt;
extern int bit4_pck;
extern int bitp_pck;
extern int ovsm_ply;
extern int play_spd;
extern int play_mode;
extern unsigned long cpu_type;
extern unsigned long machine;

extern int red_x, red_y, red_w, red_h;

#define PSG 0
#define DMA 1
#define DSP 2

extern char path[127];
extern char file[14];

extern long smp_area[MAX_BLK];						/* Original Sample */
extern long pow_dat[MAX_BLK / 2];				/* Power Spektrum */

extern int r_xy[4];

typedef struct
							{
							char name[20];
							char file[8];
							long pos, len;
							}SEQUENZ;
							
extern SEQUENZ *seq_data;

extern int seq_num;
extern int lst_num;
extern int max_seq;
extern int *play_list;
