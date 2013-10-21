#include <tos.h>
#include <vdi.h>
#include <aes.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <linea.h>

#include "prototyp.h"

#include "mt_alert.h"
#include "m_text.h"

#define	TRUE						1
#define FALSE						0

#define fontform FONT_HDR
#define rindex strrchr

typedef union 
						{
						struct 
									{
									unsigned day	: 5;
									unsigned month	: 4;
									unsigned year	: 7;
									}part;
						unsigned realdate;
						}dateinfo;

typedef union 
						{
						struct 
									{
									unsigned seconds : 5;
									unsigned minutes : 6;
									unsigned hours	 : 5;
									}part;
						unsigned realtime;
						}timeinfo;

extern OBJECT						*form_adr;
extern OBJECT 					*menu_adr;

extern int							fx, fy, fw, fh;
extern int							mousex, mousey, mousek;
extern int							keyst, key, clicks;

extern char 						del_file[65];

extern int							w_handles[4];
extern int							c_x[4], c_y[4];
extern int							c_p[4], c_c[4];
extern int							akt_id;
extern int						 	buf_len, old_blen;
extern unsigned char		*txt_start[4];
extern char 						txt_infos[4][10][40];
extern char 						txt_bearb[4][11][32];
extern char 						txt_infol[4][80];
extern char 						txt_lineal[4][256];
extern char							txt_linpar[4][6];
extern char 						pathes[4][80];
extern char							txt_fonts[4][4][13];
extern char							tfont_names[4][4][34];
extern int 							txt_first[4];
extern char 						kopffuss[4][24][26];
extern char 						mt_floskel[10][5][40];
extern int 							akt_id;
extern long 						text_pos[4];
extern long							first_line[4];
extern long 						txt_lens[4];
extern long 						cursor_line[4];
extern long 						txt_fill;
extern long							pic_sub;
extern long 						line_count[4];
extern long							total_lines[4];
extern int							txt_type[4];

extern long 						mtext_mlen;
extern unsigned char		*mtext_mem;

extern char							line_buffer[512];
extern unsigned char		*line_gadr;

extern struct BMHD
							{
							int	 	width;
							int 	height;
							int 	xstart;
							int 	ystart;
							char 	planes;
							char 	maskb;
							char 	compress;
							char 	res1;
							int	 	transp;
							char	xaspect;
							char	yaspect;
							int 	swidth;
							int		sheight;
							}bmhd;

extern unsigned char 		*mem, *img_mem;
extern FILE 						*img_f;
extern int 							putx;

extern int 							rep;
extern int 							l_wdth;
extern int 							header[8];

extern char 						pic_fpath[80];
extern char 						font_path[80];

extern int 							s_x, s_y, s_p;
extern int							y_ausr;
extern int 							fontw, fonth;
extern GRECT 						red_rc;

extern int 							vdi_handle;
extern int 							contrl[12];
extern int 							intin[160];
extern int 							intout[40];
extern int 							ptsin[20];
extern int 							ptsout[20];
extern int 							work_in[11];
extern int		 					work_out[57];

extern int 							akt_sstyle;
extern int 							akt_font;
extern int							akt_fheight;

extern int							cx_add;
extern int							chr_hg;

extern int							off_flag;

extern fontform					*fnt_point[4];
extern long							scrtchp;

extern int 							wx, wy, ww, wh;
extern short						ruler_flag;

extern int 							kf_anp[12];
extern int							modus[4];
extern int							w_koor[4][4];
