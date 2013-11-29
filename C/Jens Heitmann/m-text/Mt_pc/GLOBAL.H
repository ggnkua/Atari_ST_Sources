#include "extern.h"

#include "mt_menu.h"
#include "mt_keytb.h"

#define TRUE 1
#define FALSE 0

OBJECT 							*menu_adr;								/* Pointer auf MenÅ */
int 								msg[8];										/* Messagebuffer		*/
int									mousex, mousey, mousek;		/* Mousedaten				*/
int									keyst, key, clicks;				/* Keyboard/Clicks	*/

int 								vdi_handle;								/* VDI-Handle 			*/
int 								contrl[12];								/* VDI-Contrl				*/
int 								intin[160];								/* VDI-Intin				*/
int 								intout[40];								/* VDI-Intout				*/
int 								ptsin[20];								/* VDI-Ptsin				*/
int 								ptsout[20];								/* VDI-Ptsout				*/
int 								work_in[11];							/* Workstationinfo	*/
int 								work_out[57];							/*          "				*/

unsigned char 			*txt_start[4];						/* Textadresse				*/
long 								txt_fill = 0;							/* LÑnge aller Texte	*/
long								pic_sub = 0;							/* Bilderabzug				*/
int 	w_handles[4] = {-1, -1, -1, -1};				/* Fensterhandles			*/
int 								txt_first[4];							/* Erste Bearbeitung 	*/
char 								pathes[4][80];						/* Dateiname    			*/
char 								mt_floskel[10][5][40];		/* Floskelspeicher		*/
long 								text_pos[4];							/* Seitenanfang 			*/
long								first_line[4];						/* Zeilennummer Screen*/
long 								cursor_line[4];						/* Cursoroffset				*/
long 								txt_lens[4];							/* TextlÑnge 					*/
char 								txt_infos[4][10][40];			/* Textinfo						*/
char 								txt_bearb[4][11][32];			/* Textbearbeiter 		*/
char 								txt_lineal[4][256];				/* Aktuelles Lineale	*/
char								txt_linpar[4][6];					/* Linealparameter		*/
char  							txt_infol[4][80];					/* Textinfozeile			*/
char 								kopffuss[4][24][26];			/* Kopf-/Fusszeilen		*/
int	 								akt_id = -1;							/* Aktuelle Fensterid	*/
int 								buf_len, old_blen;				/* BufferlÑngen				*/
int 								c_x[4], c_y[4];						/* Cursor-Koordinaten	*/
int 								c_p[4], c_c[4];						/* Cursorpointer/char.*/
long 								line_count[4];						/* ZeilenzÑhler				*/
long								total_lines[4];						/* Gesamtzeilen				*/
char								txt_fonts[4][4][13];			/* Installierte Fonts */
char								tfont_names[4][4][34];		/* Fontnames zu o.		*/
int 								txt_type[4];							/* Filetyp						*/

long 								mtext_mlen;								/* Speichergrîûe			*/
unsigned char 			*mtext_mem;								/* Speicheradresse		*/

int 								ap_id;										/* Programm-Ap-Id			*/
int 								exit_flg = FALSE;					/* wenn TRUE Prog.Ende*/

char 								pic_fpath[80] = "X:\\";		/* Bildpfad						*/
char 								font_path[80] = "X:\\FONTS\\"; /* Fontpfad			*/

int 								old_mx, old_my;						/* Alte Mausposition	*/
int									off_flag = FALSE;					/* True = Maus aus		*/

char 								del_file[65] = "X:\\";		/* Lîschpfad					*/

char								line_buffer[512];					/* Zeilenpuffer				*/
unsigned char				*line_gadr;								/* Zeilenanfang				*/

OBJECT 							*form_adr;								/* Aktueller Dialog		*/
int 								fx, fy, fw, fh;						/* Dialogkoordinaten	*/

unsigned char 			*mem, *img_mem;						/* Imageload-Adr.			*/
FILE 								*img_f;										/* Image-File ID			*/
int 								putx;											/* Bytepointer				*/

int 								rep;											/* Zeilenwiederholung	*/
int 								l_wdth;										/* ZeilenlÑnge				*/
int 								header[8];								/* Image-Header				*/

int 								s_x, s_y, s_p;						/* Zeichenposition		*/
int		 							y_ausr = 1;								/* Y-Ausrichtung			*/
int									fontw = 8, fonth = 16;		/* Fontgrîûe					*/
GRECT 							red_rc;										/* Redrawfeld					*/

int 								akt_sstyle;								/* Aktueller Stil			*/
int									akt_font = 1;							/* Aktueller Font			*/
int									akt_fheight = 13;					/* Aktuelle Fonthîhe	*/
int									cx_add;										/* Cursorschritt			*/
int									chr_hg;										/* Zeichenhîhe				*/

fontform						*fnt_point[4]
										 = {-1, -1, -1, -1};			/* Zeiger auf Fonts		*/

long								scrtchp;

int									wx, wy, ww, wh;						/* Fensterkoordinaten */

short								ruler_flag = TRUE;				/* Lineal an/aus			*/

int kf_anp[12] = {G_LFT_1, G_LFT_2, G_MID_1, G_MID_2, G_RGT_1, G_RGT_2,
									U_LFT_1, U_LFT_2, U_MID_1, U_MID_2, U_RGT_1, U_RGT_2};

char 								f_text[10][30];
int									modus[4] = {1, 1, 1, 1};
int									w_koor[4][4];

struct BMHD bmhd;
