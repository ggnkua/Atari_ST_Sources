/* main.c    */
#include <aes.h>
#include <vdi.h>
#include <stdio.h>
#include <osbind.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <ieeefp.h>
#include "main.h"
#include "telvt102.h"
#include "tndefs.h"
#include "transprt.h"

/* Definitions... */

#define MAXHOSTNAMELEN  64

/* Enter number of resource trees (menues, forms, etc.) in *.RSC file here  */
#define NUM_TREE   6
/* aha! was 5   */

/* Prototypes...  */

/*
 * void  main(int, char ); void  main(int argc, char *argv[])
 */
void            map_chars(void);
void            gem_init(void);
void            gem_close(void);
void            init_rsrc(void);
void            print_cursor(short);
short           handle_key(int, short, short);
short __stdargs my_button_handler(PARMBLK *);
char           *file_select(char *, char *);
int             read_file(FILE *, int, char *);

/* Externals...    */
extern void    *bzero(void *, size_t);
extern int      stci_d(const char *, int *);
extern int      stcd_i(const char *, int *);

extern void     init_mfdb(void);
extern void     close_mfdb(void);

extern void     init_it(void);
extern void     do_redraw(int handle, GRECT * rect, int scroll);

extern void     init_win(void);
extern void     draw_win(void);
extern void     create_win(const char *);
extern void     close_win(void);
extern void     delete_win(void);
extern void     full_win(WINDOW *);
extern short    do_menu(short);
extern short    dialog(OBJECT *, short);

extern void     do_chg_fnt(void);
extern void     do_rev_bs(void);
extern void     do_key_pad(void);
extern void     do_cur_key(void);
extern void     do_dump_file(void);
extern void     do_transcript(void);
extern void     do_printer(void);
extern void     do_info(void);
extern void     do_jump_scroll(void);
extern void     redraw_page(void);
extern void     do_reset(void);

extern int      init_network(void);
extern int      open_socket(char *, int);
extern int      close_socket(int);
extern int      read_from_socket(int, char *, int);
extern int      send_to_socket(int, char *, int);

extern short    do_string(int, char *);
extern void     blink_it(void);
extern int      initialise(void);
extern int      choose(int);
extern void     pause(short);
extern void     print_string(char *);

/* Globals...    */

/* unsigned long _STACK=8192L; */
unsigned long   _STACK = 16384;
/* unsigned long _STACK=32768L; */
FILE           *fp, *savefp;
char            charmap[255];
/*
 * char fname[9] = "text.dat\n"; char savename[12] = "telvt102.inf";
 */
char            fname[] = "text.dat";
char            save[13] = "telvt.inf";
char            savename[13];
char            buf1[1024];
char            title[32] = " TelVT102 2.03a 1/04/98 ";
USERBLK         my_user_block = {my_button_handler, 0};
/* AES/VDI...  */


short           vdi_handle;
short           work_in[11] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2};
short           work_out[57], extn_out[57];
short           chrwid;
short           chrhgt;
short           font_id;
short           fid, savefid, ptsize, fnum;
char            fontname[35];

short           nchars = 80;
short           nlines = 40;
short           bsb, sb;
char            hostb[80], portb[4];
int             nchb, nlib, fontb, oldfontb, saved, read_from_file, reading =
FALSE,          wait = FALSE;
char            replay_path[128] = "";
FILE           *replay_handle;

/* Flags  */

short           jump = TRUE, newline = TRUE, key_ret = TRUE
,               screen_norm = TRUE, wrap = /* FALSE */ TRUE, dont_size = FALSE;
short           keypad = FALSE, cur_key = FALSE, rev_bs = TRUE, jump_scroll =
TRUE,           smooth_scroll = FALSE, sizeable = FALSE, debug = FALSE
,               mapped = FALSE, remap = FALSE;
short           write_file = FALSE, dump_file = FALSE, print_it = FALSE
,               win_opened = FALSE, absolute = TRUE, graph_on = FALSE, blink_count;
/* Resource... */

OBJECT         *menu_ptr, *about_ptr, *host_ptr, *sizer_ptr, *chooser, *fsize_ptr;


/* MFDB...    */

MFDB            work, screen;

/* Window...    */

WINDOW          win;

/* Program Flow...    */

short           oldx, oldy, oldw, oldh, newx, newy, neww, newh;
short           endmainloop = 0;
short           openn = 0;
short           blockcursor, blinkcursor, blitter;
extern void    *oldlogbase;
short           cursor_dark = FALSE;
long            denom;
short           bps = 0;
/* New window stuff   */
/* typedef  char  (*(TERM_buf[MAX_ROW]))[MAX_COL]; */

/* TERM_buf ascii_buf,  attri_buf; */
/*
char ascii_buf[MAX_ROW][MAX_COL];
char attri_buf[MAX_ROW][MAX_COL];
*/
short           real_row[MAX_ROW], blink[MAX_ROW], doubler[MAX_ROW];
extern GRECT    scrn_rec;

/* typedef char LINE_buf[MAX_COL]; */
LINE_buf       *ascii_buf, *attri_buf, *blink_buf;

/* Procedures...  */

void
main(int argc, char *argv[])
{
	GRECT           act;
	long            r, co;

	short           junk, event, scan, state, msg[8], len = 0;
	char            buff[4096], out[80], *ptr;
	int             s = 0;
	int             i, j, k /* , x */ ;
	char            atxt[80] /* ,txt[80] */ , ntxt[132] = "";
	/* char c; */
	clock_t         time = clock() + (CLOCKS_PER_SEC);
	clock_t         blink_time = clock() + (CLOCKS_PER_SEC);
	clock_t         byte_time = clock() + (CLOCKS_PER_SEC);
	int							eventtime = 50;				
	long            old_byte_time[2];
	old_byte_time[1] = old_byte_time[0] = 0;
	blockcursor = FALSE;
	blinkcursor = TRUE;
	r = MAX_ROW;
	co = MAX_COL;

	strcpy(savename, save);
	if ((ascii_buf = (LINE_buf *) Malloc(3 * MAX_ROW * MAX_COL)) == NULL) {
		form_alert(1, "[1][No ram for terminal buffers! ][Quit]");
		exit(EXIT_FAILURE);
	}
	attri_buf = ascii_buf + MAX_ROW;
	blink_buf = attri_buf + MAX_ROW;

	k = 0;
	for (i = 0; i < MAX_ROW; i++) {
		k = i;

		memset(attri_buf[i], 0, 132 /* MAX_COL */ );
		memset(ascii_buf[i], 0, 132 /* MAX_COL */ );
		memset(blink_buf[i], 0, 132 /* MAX_COL */ );
		memset(ascii_buf[i], 32, (size_t) (nchars + 1));
		real_row[i] = k;
		blink[i] = 0;
		doubler[i] = 0;
	}
	graph_on = FALSE;
	/*
           for (i=win.scrolltop; i < win.scrollbot;i++)
                 {
                 k=real_row[i];
                 sprintf(out,"%2d %2dxyz",k,i);
                 strncpy(&ascii_buf[k][74],out,5);
                 }
        */
	/*
         * win=(WINDOW *)Malloc(sizeof(WINDOW));
         */

	map_chars();
	fp = fopen(fname, "wb");
	fclose(fp);
	if ((savefp = fopen(savename, "r")) == NULL) {
		hostb[0] = '\0';
		strcpy(portb, "23");
		bsb = FALSE;
		sb = FALSE;
		oldfontb = fontb = 52;
		fid = 52;
		savefid = fid;
		ptsize = 8;
		nlines = nlib = 25;
		nchars = nchb = 80;
		/* saved=FALSE; */
		saved = TRUE;
	} else {
		do {
			fgets(ntxt, 80, savefp);
			if ((ptr = strchr(ntxt, '=')) != NULL) {
				ptr++;
				switch (ntxt[0]) {
				case 'H':
					if (argc == 1)
						strcpy(hostb, ptr);
					if ((hostb[strlen(hostb) - 1] < '0') ||
					    (hostb[strlen(hostb) - 1] > 'z'))
						hostb[strlen(hostb) - 1] = 0;
					break;
				case 'P':
					strcpy(portb, (ptr[0] == '\0') ? "23" : ptr);
					if ((portb[strlen(portb) - 1] < '0') ||
					    (portb[strlen(portb) - 1] > 'z'))
						portb[strlen(portb) - 1] = 0;
					break;
				case 'B':
					bsb = atoi(ptr);
					break;
				case 'R':
					sb = atoi(ptr);
					break;
				case 'F':
					fid = atoi(ptr);
					savefid = fid;
					break;
				case 'f':
					strcpy(fontname, ptr);
					break;
				case 'L':
					nlines = nlib = atoi(ptr);
					break;
				case 'S':
					ptsize = atoi(ptr);
					break;
				case 'C':
					nchars = nchb = atoi(ptr);
					break;
				}
			}
		}
		while (!feof(savefp));
		fclose(savefp);
		saved = TRUE;
	}
	gem_init();		/* init_it is in here */
	/* do_menu(fontb); */
	init_mfdb();
	create_win(title);
	init_win();
	win_opened = TRUE;
	saved = FALSE;
	graf_mouse(ARROW, NULL);
	sprintf(out, "");
	wind_set(win.handle, WF_INFO, (short) ((long) out >> 16), (short) (out),
		 NULL, NULL);
	bzero(buff, sizeof(buff));

	do_menu(BlockCurs);
	/*
         * menu_ienable(menu_ptr,BlinkCurs,0);
         */
	menu_ienable(menu_ptr, Echo, 0);
	if (init_network() != TRUE) {
		menu_ienable(menu_ptr, OpenHostO, 0);
		menu_ienable(menu_ptr, CloseC, 0);
	} else {
		menu_ienable(menu_ptr, OpenHostO, 1);
		menu_ienable(menu_ptr, CloseC, 0);
		menu_icheck(menu_ptr, BSDelB, 1);
	}
	menu_ienable(menu_ptr, OpenLocalL, 1);
	win.scrolltop = win.sstop = 1;
	win.scrollbot = win.ssbot = nlines;
	/* do_menu(fontb); */
	/*
         * for (i=0;i<=10000;i++) {for (j=0; j<=900;j++);}
         */
	if (bsb)
		do_rev_bs();	/* double negative! */
	do_rev_bs();
	if (sb)
		do_jump_scroll();
	do_jump_scroll();
	do_info();

	/* stuff for loading from CAB */
	if (argc == 1)
		strcpy(atxt, hostb);
	else {			/* argc=2 */
		sprintf(ntxt, " %d :%s", argc, argv[1]);
		/* now parse ntxt  */
		j = (int) strlen(ntxt);
		for (i = 1; i <= j; i++) {
			if (ntxt[i] == '/')
				break;
		}
		for (k = 0; k <= j - i - 1; k++) {
			atxt[k] = ntxt[k + i + 2];	/* 2'//' in a row for
							 * address   */
			if (atxt[k] == '/') {
				atxt[k] = 0;
				break;
			}
		}
		openn = OPENABLE;
	}

	/*
         * if (argc==1) atxt[0]=0;
         */
	/*
         * if (argc>=2) openn=OPENABLE;
         */
	/* wait=TRUE; */

	for (i = win.scrolltop; i < win.scrollbot; i++) {
		real_row[i] = i;
		/*
	         * k=real_row[i]; sprintf(out,"%2d %2dxyz",k,i);
	         * strncpy(&ascii_buf[k][74],out,5);
	         */
	}

	do {
		event = evnt_multi(MU_MESAG | MU_KEYBD | MU_TIMER,
				   0, 0, 0,
				   0, 0, 0, 0, 0,
				   0, 0, 0, 0, 0,
				   msg,
				    /* 2 */ eventtime, 0,
				 &junk, &junk, &junk, &state, &scan, &junk);

		if (MU_MESAG & event) {
			if (msg[0] == MN_SELECTED	/* & *(OBJECT
			        *)&msg[5]==menu_ptr */ ) {
				wind_update(BEG_UPDATE);
				endmainloop = do_menu(msg[4]);
				menu_tnormal(menu_ptr, msg[3], 1);
				wind_update(END_UPDATE);
			}
			switch (msg[0]) {
			case WM_TOPPED:
				if (win.handle == msg[3]) {
					wind_set(win.handle, WF_TOP, &junk, &junk, &junk, &junk);
				}
				break;

			case WM_CLOSED:
				if (win.handle == msg[3]) {
					endmainloop = TRUE;
					openn = OPEN;
				}
				break;

			case WM_FULLED:
				if (win.handle == msg[3]) {
					full_win(&win);
				}
				break;

			case WM_SIZED:
				if (win.handle == msg[3]) {
					wind_calc(WC_WORK, WINTYPE, msg[4], msg[5], msg[6], msg[7],
						  &win.w_rect.g_x, &win.w_rect.g_y, &win.w_rect.g_w,
						  &win.w_rect.g_h);

					if (win.w_rect.g_w > (nchars * chrwid))
						win.w_rect.g_w = (nchars * chrwid);
					if (win.w_rect.g_h > (nlines * chrhgt))
						win.w_rect.g_h = (nlines * chrhgt);

					wind_calc(WC_BORDER, WINTYPE, win.w_rect.g_x, win.w_rect.g_y,
					     win.w_rect.g_w, win.w_rect.g_h,
						  &win.b_rect.g_x, &win.b_rect.g_y, &win.b_rect.g_w,
						  &win.b_rect.g_h);

					wind_set(win.handle, WF_CXYWH, win.b_rect.g_x, win.b_rect.g_y,
					    win.b_rect.g_w, win.b_rect.g_h);
					wind_set(win.handle, WF_HSLSIZE,
						 (short) (((long) win.w_rect.g_w * 1000) / (nchars *
							 chrwid)), 0, 0, 0);
					wind_set(win.handle, WF_VSLSIZE,
						 (short) (((long) win.w_rect.g_h * 1000) / (nlines *
							 chrhgt)), 0, 0, 0);
					wind_get(win.handle, WF_HSLIDE, &junk, NULL, NULL, NULL);

					win.x_offset = (short) (((long) junk * ((nchars * chrwid) -
					    (long) win.w_rect.g_w)) / 1000);
					wind_get(win.handle, WF_VSLIDE, &junk, NULL, NULL, NULL);

					win.y_offset = (short) (((long) junk * ((nlines * chrhgt) -
					    (long) win.w_rect.g_h)) / 1000);
					init_win();
					do_reset();
				}
				break;

			case WM_MOVED:
				graf_mouse(M_OFF, NULL);

				if (win.handle == msg[3]) {
					wind_set(win.handle, WF_CXYWH, msg[4], msg[5], msg[6], msg[7]);
					win.b_rect.g_x = msg[4];
					win.b_rect.g_y = msg[5];
					win.b_rect.g_w = msg[6];
					win.b_rect.g_h = msg[7];
					wind_calc(WC_WORK, WINTYPE, msg[4], msg[5], msg[6], msg[7],
					   &win.w_rect.g_x, &win.w_rect.g_y,
					  &win.w_rect.g_w, &win.w_rect.g_h);
					init_win();
					do_reset();
				}
				graf_mouse(M_ON, NULL);
				break;

			case WM_REDRAW:
				if (win.handle == msg[3]) {
					act.g_x = msg[4];
					act.g_y = msg[5];
					act.g_w = msg[6];
					act.g_h = msg[7];
					/* do_redraw (win.handle, & act,0); */
					redraw_page();
				}
				break;
			}
		}
		if (MU_KEYBD & event) {

			key_ret = handle_key(s, scan, state);

		}
		if (win.col != win.cursorcol || win.row != win.cursorrow) {
			/*
	                 * if (cursor_dark) { print_cursor(0); }
	                 */
			win.cursorcol = win.col;
			win.cursorrow = win.row;
			/*
	                 * if (cursor_dark) { print_cursor(1); }
	                 */
		}
		if (time < clock()) {
			if (blinkcursor)
				cursor_dark = !cursor_dark;
			else
				cursor_dark = !cursor_dark;
			print_cursor(1);
			time = clock() + CLOCKS_PER_SEC / 3;


			if (blink_time < clock()) {
				short           ib;

				for (ib = 1; (ib < nlines); ib++)
					if (blink[ib] > 0) {
						blink_it();
						ib = nlines + 1;
					}
				blink_time = clock() + CLOCKS_PER_SEC;
			}
		}
		if (openn & OPENABLE) {
			short tok;
			if (argc == 1) {
				strcpy(((TEDINFO *) (host_ptr[Host].ob_spec))->te_ptext, atxt);
				strcpy(((TEDINFO *) (host_ptr[Port].ob_spec))->te_ptext, portb);
				tok = dialog(host_ptr, Host);
/*				if (dialog(host_ptr, Host) == OK) {*/
				if (tok == OK) {
					sprintf(out, "Loading!");
					wind_set(win.handle, WF_INFO, (short) ((long) out >> 16),
						 (short) (out),
						 NULL,
						 NULL);
				} else {
					redraw_page();
					openn = 0;
					sprintf(out, "Aborted!");
					wind_set(win.handle, WF_INFO, (short) ((long) out >> 16),
						 (short) (out),
						 NULL,
						 NULL);
				}
			} else {
				strcpy(((TEDINFO *) (host_ptr[Host].ob_spec))->te_ptext, atxt);
			}
			if (openn & OPENABLE) {
/*				s = open_socket(((TEDINFO *) (host_ptr[Host].ob_spec))->te_ptext,
						atoi(((TEDINFO *) (host_ptr[Port].ob_spec))->te_ptext));*/
	char	*tted;
	int		tnum;
				tted = ((TEDINFO *) (host_ptr[Host].ob_spec))->te_ptext;
				tnum = atoi(((TEDINFO *) (host_ptr[Port].ob_spec))->te_ptext);
				s = open_socket(tted,
						tnum);

				strcpy(hostb, ((TEDINFO *) (host_ptr[Host].ob_spec))->te_ptext);
				openn = OPENING;
				newline = FALSE;
			}
		}
		if (openn & OPENING) {
			size_t          savelen;
			savelen = len;
	readit:
			i = read_from_socket(s, &buff[len], 4096 - len);
			/* if (*buff!=0) */
			if (i != 0) {
				size_t          buflen;
				eventtime = 5;
				buflen = /* (size_t) */ strlen(buff);
				graf_mouse(M_OFF, NULL);
				if (cursor_dark) {
					print_cursor(1);
					cursor_dark = FALSE;
				}
				len = do_string(s, buff);
				strncpy(buff, buff + buflen - (size_t) len, (size_t) len);
				memset(&buff[len], 0, buflen - len);
				graf_mouse(M_ON, NULL);
				byte_time = clock();
			}
			else	{eventtime = 200;}
			denom = (byte_time - old_byte_time[1]);
			if (denom != 0)
				bps = (bps + (short) ((long) i * (long) CLOCKS_PER_SEC / denom)) /
					2;
			old_byte_time[1] = old_byte_time[0];
			old_byte_time[0] = byte_time;

			if (MU_KEYBD & event) {
				switch ((char) scan) {
				case 13:
					out[0] = 13;
					out[1] = 10;
					i = 2;
					break;
				case 8:
					if (rev_bs)
						out[0] = 127;
					else
						out[0] = 8;
					i = 1;
					break;
				case 127:
					if (rev_bs)
						out[0] = 8;
					else
						out[0] = 127;
					i = 1;
					break;
				default:
					out[0] = (char) scan;
					i = 1;
					break;
				}
				if (key_ret) {
					send_to_socket(s, out, i);
					if ((win.col >= nchars - 8) && (win.col < nchars - 4))
						Bconout(2, 7);
				}
				key_ret = TRUE;

			}
		}
		if (openn & CLOSING) {
			close_socket(s);
			openn = 0;
		}
		if (read_from_file)
			if (!reading) {
				if ((NULL != file_select(replay_path, NULL))
				    && ((replay_handle = fopen(replay_path, "rb")) > 0))
					reading = TRUE;
				else {
					read_from_file = FALSE;
					reading = FALSE;
				}
				newline = TRUE;
			}
		if ((read_from_file) && (reading)) {
			register int    ch, i, j;
			int             l, jj, zero = FALSE;
			char            ntxt[80] /* ,ntext[80] */ ;
			k = 0;
			/* do  */
			{
				/* l=256-len; */
				l = 4094 - len;
				if (zero)
					i = 0;
				else
					i = len;
				jj = j = 0;
				buff[i] = 0;

				memset(ntxt, 0, 80);

				do {
					ch = getc(replay_handle);
					if (ch > 0 && j < l /* && ch!=EOF */ ) {
						buff[i++] = (char) ch;
						j++;
					}
					/* else buff[i+1]=0; */
					/*
			                 * ntxt[jj++]=ch; if (jj>40) { for
			                 * (jjj=0;jjj<=40;jjj++)
			                 * ntxt[jjj]=ntxt[jjj+1]; jj--; }
			                 * sprintf(ntext, "%d %d %s
			                 * %d",j,j-i,ntxt,(i));
			                 * wind_set(win.handle, WF_INFO,
			                 * (short)((long)ntext>>16),
			                 * (short)(ntext), NULL, NULL);
			                 * pause();
			                 */
				} while (ch > 0 && j < l && ch != EOF);
				buff[i /* +1 */ ] = 0;
				if (ch == EOF)
					k = EOF;
				/*
		                 * if (ch==EOF) form_alert(1,"[1][end of
		                 * file! ][OK]");
		                 */
				if (ch == 0)
					zero = FALSE /* TRUE */ ;
				else
					zero = FALSE;

				if (*buff != 0) {
					size_t          buflen /* , len1 */ ;
					graf_mouse(M_OFF, NULL);

					buflen = /* (size_t) */ strlen(buff);

					if (cursor_dark)
						print_cursor(1);
					cursor_dark = FALSE;

					len = do_string(s, buff);
					strncpy(buff, buff + buflen - (size_t) len, (size_t) len);
					memset(&buff[len], 0, buflen - len);
					graf_mouse(M_ON, NULL);
					byte_time = clock();
					denom = (byte_time - old_byte_time[1]);
					bps = (bps + (short) ((long) i * (long) CLOCKS_PER_SEC / denom))
						/ 2;
					old_byte_time[1] = old_byte_time[0];
					old_byte_time[0] = byte_time;
				}
			}
			/* while (k!= EOF); */

			if (k == EOF) {
				fclose(replay_handle);
				reading = FALSE;
				read_from_file = FALSE;
				win.col = 1;
			}
		}		/* end if */
	}
	while (endmainloop != TRUE);

	if (openn & OPEN) {
		close_socket(s);
	}
	fclose(fp);
	Mfree(ascii_buf);

	close_socket(s);

	close_win();
	delete_win();

	close_mfdb();
	gem_close();

}

void
print_cursor(short flag)
{
	short           pxy[8], clip[4], top, junk;

	wind_get(win.handle, WF_TOP, &top, &junk, &junk, &junk);

	if (top == win.handle) {
		clip[0] = win.w_rect.g_x;
		clip[1] = win.w_rect.g_y;
		clip[2] = clip[0] + win.w_rect.g_w - 1;
		clip[3] = clip[1] + win.w_rect.g_h - 1;

		pxy[4] = win.w_rect.g_x + win.cursorcol * chrwid - chrwid + 1;
		pxy[5] = win.w_rect.g_y + win.cursorrow * chrhgt - 1;
		pxy[6] = pxy[4] + chrwid - 1;
		if (blockcursor)
			pxy[7] = pxy[5] - chrhgt + 1;
		else
			pxy[7] = pxy[5] - 1;

		if (flag) {
			vsf_interior(vdi_handle, 1);
			vsf_style(vdi_handle, 8);
			vsf_perimeter(vdi_handle, 0);
			vswr_mode(vdi_handle, MD_XOR);
			v_bar(vdi_handle, &pxy[4]);
			vswr_mode(vdi_handle, MD_REPLACE);
		} else {
			pxy[0] = win.w_rect.g_x + win.cursorcol * chrwid - chrwid;
			pxy[1] = win.w_rect.g_y + win.cursorrow * chrhgt - 1;
			pxy[2] = pxy[0] + chrwid - 1;
			if (blockcursor)
				pxy[3] = pxy[1] - chrhgt + 1;
			else
				pxy[3] = pxy[1] - 1;

		}
	}
}

void
init_rsrc(void)
{
	OBJECT         *tree;
	short           count;

	rsrc_gaddr(R_TREE, MENU, &menu_ptr);
	rsrc_gaddr(R_TREE, ABOUT, &about_ptr);
	rsrc_gaddr(R_TREE, HOST, &host_ptr);
	rsrc_gaddr(R_TREE, FSIZER, &sizer_ptr);
	rsrc_gaddr(R_TREE, CHOOSER, &chooser);
	rsrc_gaddr(R_TREE, FONT_SIZE, &fsize_ptr);

	for (count = 0; count < NUM_TREE; count++) {	/* fixed NUM_TREE!    */
		rsrc_gaddr(R_TREE, count, &tree);
		do {		/* it dies in this loop with changed rsc file    */
			if (tree->ob_type & 0x7f00)
				if ((tree->ob_state & (CROSSED | CHECKED)) == (CROSSED | CHECKED)) {
					tree->ob_type = G_USERDEF;
					tree->ob_spec = /* (long) */ &my_user_block;	/* is this right??? */
					tree->ob_state &= ~(CROSSED | CHECKED);
				}
			tree++;
			/* } while (tree->ob_flags & LASTOB == 0); */
		} while (!(tree->ob_flags & LASTOB));
	}
	count++;
}

void
gem_init(void)
{
	short           j, junk;
	char            s[32];
	appl_init();

	/* init_it(); */

	if (!rsrc_load("TELVT102.RSC")) {
		form_alert(1, "[1][Error Loading Resource! ][Quit]");
		exit(EXIT_FAILURE);
	}
	init_rsrc();
	/* do_menu(fontb); *//* try putting it here   */

	vdi_handle = graf_handle(&junk, &junk, &junk, &junk);
	for (junk = 0; junk < 10; junk++)
		work_in[junk] = 1;
	work_in[10] = 2;
	v_opnvwk(work_in, &vdi_handle, work_out);
	vq_extnd(vdi_handle, 1, extn_out);
	vst_alignment(vdi_handle, 0, 5, &junk, &junk);

	do_menu(99);		/* try putting it here   */

	if (vq_gdos()) {
		j = vst_load_fonts(vdi_handle, 0);
		font_id = vqt_name(vdi_handle, 1, s);
		/*
	         * win.font_no = 45; win.gfont_no = 53; win.font_size = 8;
	         * win.gfont_size = 8;
	         */
		/* menu_icheck(menu_ptr, fontb , 1);      */

		vst_font(vdi_handle, win.font_no);
		vst_point(vdi_handle, win.font_size, &junk, &junk, &chrwid, &chrhgt);
	} else {
		form_alert(1, "[1][Use some form of GDOS!][Quit]");
		exit(EXIT_FAILURE);
	}
	vst_point(vdi_handle, win.font_size, &junk, &junk, &chrwid, &chrhgt);
	menu_bar(menu_ptr, 1);

	win.row = 1;
	win.col = 1;
}

void
gem_close(void)
{
	vst_font(vdi_handle, font_id);
	vst_unload_fonts(vdi_handle, 0);
	menu_bar(menu_ptr, 0);
	v_clsvwk(vdi_handle);
	rsrc_free();
	appl_exit();
}

/*------------------------------*/
/* handle_key    */
/*------------------------------*/

short
handle_key(int s, short scan, short state)
{
#define ESC 27
	/*
         * handle key from console...
         */

	/*
         * unsigned char  buf[512]; int  len;
         */
	char            out[8];
	short			/* i, junk, curskey=FALSE; short
				 * curskey=TRUE; */
	/*
* short ret;
*/
	/*
* state 0x0   all up 0x1  rt sh dn 0x2   lft sh dn 0x4  cntl
* dn 0x8   alt dn
*/
	                ret = TRUE;
	switch ((char) state) {
	case 0x0:
		switch (scan) {

			/* cursor keys... */

		case 0x4800:	/* up arrow */
			if (cur_key) {
				send_to_socket(s, "\033OA", 3);
			} else {
				send_to_socket(s, "\033[A", 3);
			}
			ret = FALSE;
			break;
		case 0x5000:	/* down arrow */
			if (cur_key) {
				send_to_socket(s, "\033OB", 3);
			} else {
				send_to_socket(s, "\033[B", 3);
			}
			ret = FALSE;
			break;
		case 0x4d00:	/* right arrow */
			if (cur_key) {
				send_to_socket(s, "\033OC", 3);
			} else {
				send_to_socket(s, "\033[C", 3);
			}
			ret = FALSE;
			break;
		case 0x4b00:	/* left arrow */
			if (cur_key) {
				send_to_socket(s, "\033OD", 3);
			} else {
				send_to_socket(s, "\033[D", 3);
			}
			ret = FALSE;
			break;

			/* keypad keys... */

		case 0x7030:	/* 0 */
			if (keypad) {
				send_to_socket(s, "\033Op", 3);
			} else {
				send_to_socket(s, "0", 1);
			}
			ret = FALSE;
			break;
		case 0x6d31:	/* 1 */
			if (keypad) {
				send_to_socket(s, "\033Oq", 3);
			} else {
				send_to_socket(s, "1", 1);
			}
			ret = FALSE;
			break;
		case 0x6e32:	/* 2 */
			if (keypad) {
				send_to_socket(s, "\033Or", 3);
			} else {
				send_to_socket(s, "2", 1);
			}
			ret = FALSE;
			break;
		case 0x6f33:	/* 3 */
			if (keypad) {
				send_to_socket(s, "\033Os", 3);
			} else {
				send_to_socket(s, "3", 1);
			}
			ret = FALSE;
			break;
		case 0x6a34:	/* 4 */
			if (keypad) {
				send_to_socket(s, "\033Ot", 3);
			} else {
				send_to_socket(s, "4", 1);
			}
			ret = FALSE;
			break;
		case 0x6b35:	/* 5 */
			if (keypad) {
				send_to_socket(s, "\033Ou", 3);
			} else {
				send_to_socket(s, "5", 1);
			}
			ret = FALSE;
			break;
		case 0x6c36:	/* 6 */
			if (keypad) {
				send_to_socket(s, "\033Ov", 3);
			} else {
				send_to_socket(s, "6", 1);
			}
			ret = FALSE;
			break;
		case 0x6737:	/* 7 */
			if (keypad) {
				send_to_socket(s, "\033Ow", 3);
			} else {
				send_to_socket(s, "7", 1);
			}
			ret = FALSE;
			break;
		case 0x6838:	/* 8 */
			if (keypad) {
				send_to_socket(s, "\033Ox", 3);
			} else {
				send_to_socket(s, "8", 1);
			}
			ret = FALSE;
			break;
		case 0x6939:	/* 9 */
			if (keypad) {
				send_to_socket(s, "\033Oy", 3);
			} else {
				send_to_socket(s, "9", 1);
			}
			ret = FALSE;
			break;
		case 0x4a2d:	/* - */
			if (keypad) {
				send_to_socket(s, "\033Om", 3);
			} else {
				send_to_socket(s, "-", 1);
			}
			ret = FALSE;
			break;
		case 0x720d:	/* enter */
			if (keypad) {
				send_to_socket(s, "\033OM", 3);
			} else {
				send_to_socket(s, "\015", 1);
			}
			ret = FALSE;
			break;
		case 0x712e:	/* . */
			if (keypad) {
				send_to_socket(s, "\033On", 3);
			} else {
				send_to_socket(s, ".", 1);
			}
			ret = FALSE;
			break;
		case 0x4e2b:	/* + */
			if (keypad) {
				send_to_socket(s, "\033Ol", 3);
			} else {
				send_to_socket(s, "+", 1);
			}
			ret = FALSE;
			break;
		case 0x6328:	/* ( */
			if (keypad) {
				send_to_socket(s, "\033OP", 3);
			} else {
				send_to_socket(s, "(", 1);
			}
			ret = FALSE;
			break;
		case 0x6429:	/* ) */
			if (keypad) {
				send_to_socket(s, "\033OQ", 3);
			} else {
				send_to_socket(s, ")", 1);
			}
			ret = FALSE;
			break;
		case 0x652f:	/* / */
			if (keypad) {
				send_to_socket(s, "\033OR", 3);
			} else {
				send_to_socket(s, "/", 1);
			}
			ret = FALSE;
			break;
		case 0x662a:	/* * */
			if (keypad) {
				send_to_socket(s, "\033OS", 3);
			} else {
				send_to_socket(s, "*", 1);
			}
			ret = FALSE;
			break;

		case 0x5200:	/* Insert  Now Prev. Page */
			{
				send_to_socket(s, "\033[5~", 4);
			}
			ret = FALSE;
			break;

		case 0x4700:	/* Clr/Home  Now Next Page */
			{
				send_to_socket(s, "\033[6~", 4);
			}
			ret = FALSE;
			break;

			/* keys we track for control... */

		case 0x6200:	/* HELP */
			break;
		default:
			if (openn & OPEN) {
				form_alert(1, "[1][We got to end of noshift! ][OK]");
				out[0] = (char) scan;
				out[1] = 0;
				send_to_socket(s, out, 1);
			}
		}
		break;

	case 0x8:		/* alt dn */
		switch (scan) {
		case 0x01000:	/* alt-q (quit) */
			endmainloop = TRUE;
			ret = FALSE;
			break;

		case 0x1300:	/* alt-r (reset)   */
			do_reset();
			ret = FALSE;
			break;

		case 0x1400:	/* alt-t (transcript toggle)   */
			do_transcript();
			ret = FALSE;
			break;

		case 0x1800:	/* alt-o* OPEN HOST */
			openn = OPENABLE;
			ret = FALSE;
			break;

		case 0x1900:	/* alt-p printer */
			do_printer();
			ret = FALSE;
			break;

		case 0x1E00:	/* alt-a curskey */
			do_cur_key();
			ret = FALSE;
			break;

		case 0x1f00:	/* alt-s set line/char OPEN HOST */
			do_menu(LineCharS);
			ret = FALSE;
			break;

		case 0x2000:	/* alt-d (debug toggle)  */
			debug = !debug;
			ret = FALSE;
			break;

		case 0x2100:	/* alt-f (file dump toggle)    */
			do_dump_file();
			ret = FALSE;
			break;

		case 0x2400:	/* alt-j fastscroll */
			do_jump_scroll();
			ret = FALSE;
			break;

		case 0x2500:	/* alt-k keypad */
			do_key_pad();
			ret = FALSE;
			break;

		case 0x2600:	/* alt-l OPEN local */
			read_from_file = TRUE;
			ret = FALSE;
			break;

		case 0x2E00:	/* alt-c (close) */
			if (reading) {
				fclose(replay_handle);
				reading = FALSE;
				read_from_file = FALSE;
				win.row = win.scrollbot;
				win.col = 1;
			} else
				openn |= CLOSING;
			ret = FALSE;
			break;

		case 0x3000:	/* alt-b (interchange bs/del)  */
			do_rev_bs();
			ret = FALSE;
			break;

		case 0x3100:	/* alt-n choose new font    */
			do_menu(FontIDN);
			savefid = fid;
			ret = FALSE;
			break;
			/*
	                 * choose(i); /*fid=i;
	                 */

			win.font_no = fid;
			/*
	                   sprintf(out,"r:%2d c:%2d sc:%2d:%2d ch %dx%d font %d"
	                         ,win.row,win.col, win.scrolltop,win.scrollbot
	                         ,chrwid,chrhgt, win.font_no);
	                   wind_set(win.handle, WF_INFO, (short)((long)out>>16), (short)(out),
	                            NULL, NULL);
	                */
			if (fid != 0) {
				vst_font(vdi_handle, win.font_no);
				vst_point(vdi_handle, win.font_size, &junk, &junk, &chrwid,
					  &chrhgt);
			}
			ret = FALSE;
			break;
			*/

		}
		break;
	default:
		if (openn & OPEN) {
			form_alert(1, "[1][We got to end! ][OK]");
			out[0] = (char) scan;
			out[1] = 0;
			send_to_socket(s, out, 1);
		}
		/* break; */
	}
	return (ret);
}

short           __stdargs
my_button_handler(parameter)
	PARMBLK        *parameter;

{
	short           clip[4], pxy[4], pos_x, pos_y, radius;

	clip[0] = parameter->pb_xc;
	clip[2] = clip[0] + parameter->pb_wc - 1;
	clip[1] = parameter->pb_yc;
	clip[3] = clip[1] + parameter->pb_hc - 1;
	vs_clip(vdi_handle, 1, clip);

	radius = (parameter->pb_w + parameter->pb_h) / 6;
	pos_x = parameter->pb_x + parameter->pb_w / 2;
	pos_y = parameter->pb_y + parameter->pb_h / 2;

	vsf_interior(vdi_handle, FIS_HOLLOW);

	if (parameter->pb_tree[parameter->pb_obj].ob_flags & RBUTTON) {
		v_circle(vdi_handle, pos_x, pos_y, radius);

		if (parameter->pb_currstate & SELECTED) {
			vsf_interior(vdi_handle, FIS_SOLID);
			v_circle(vdi_handle, pos_x, pos_y, radius / 2);
		}
	} else {
		pxy[0] = pos_x - radius;
		pxy[2] = pos_x + radius;
		pxy[1] = pos_y - radius;
		pxy[3] = pos_y + radius;
		v_bar(vdi_handle, pxy);

		if (parameter->pb_currstate & SELECTED) {
			pxy[0] += 2;
			pxy[1] += 2;
			pxy[2] -= 2;
			pxy[3] -= 2;
			v_pline(vdi_handle, 2, pxy);
			radius = pxy[1];
			pxy[1] = pxy[3];
			pxy[3] = radius;
			v_pline(vdi_handle, 2, pxy);
		}
	}

	vs_clip(vdi_handle, 0, clip);

	return (parameter->pb_currstate & ~SELECTED);
}

char           *
file_select(char *path_p, char *mask_p)
{
	char            fs_name[16];
	short           fs_retv, fs_exbt, fs_drive;
	char           *tempsp;

	if ((path_p == NULL) || (*path_p == 0)) {	/* default no path given */
		fs_drive = Dgetdrv();
		strcpy(path_p, "A:");	/* prepare path start */
		*path_p += (char) fs_drive;	/* fix default folder */
		Dgetpath(path_p + 3, fs_drive + 1);
	} else {
		tempsp = strrchr(path_p, '\\');	/* find filename */
		if (tempsp == NULL)
			return NULL;	/* error, no \\ found */
		strcpy(fs_name, tempsp + 1);	/* copy name */
		tempsp[1] = 0;	/* cut it from path */
	}
	if (path_p[strlen(path_p) - 1] != '\\')	/* path end <> \\ */
		strcat(path_p, "\\");	/* add it */

	if ((mask_p == NULL) || (*mask_p == 0))
		strcat(path_p, "*.*");	/* use *.* as a mask */
	else
		strcat(path_p, mask_p);	/* use given mask */

	fs_retv = fsel_input(path_p, fs_name, &fs_exbt);	/* call GEM */

	tempsp = strrchr(path_p, '\\');	/* find mask start in path */
	if (tempsp == NULL)
		return NULL;	/* return error */
	tempsp[1] = 0;		/* cut out mask */
	strcat(path_p, fs_name);/* add filename to path */

	if (fs_retv < 0 || fs_exbt == 0 || *fs_name == 0)
		return NULL;

	return path_p;
}

int
read_file(FILE * handle, int len, char *str)
{
	register int    c;
	int             i = 0;
	/* long count; */

	str[i] = 0;
	do {
		c = fgetc(handle);
		if (c > 0 && i < len /* && c!=EOF */ )
			str[i++] = (char) c;
		else
			str[i] = 0;
	}
	while (c > 0);
	if (c == EOF)
		return (EOF);
	return (i);
}

void
map_chars(void)
{
	int             i;

	for (i = 0; i <= 255; i++) {
		charmap[i] = i;
	}
	charmap[97] = 177;

	charmap[102] = 248;
	charmap[103] = 241;

	charmap[106] = 217;
	charmap[107] = 191;
	charmap[108] = 218;
	charmap[109] = 192;
	charmap[110] = 197;

	charmap[111] = 255;
	charmap[112] = 255;
	charmap[113] = 196;
	charmap[114] = 196;
	charmap[115] = 95;

	charmap[116] = 195;
	charmap[117] = 180;
	charmap[118] = 193;
	charmap[119] = 194;
	charmap[120] = 179;
	charmap[121] = 243;
	charmap[122] = 242;
	charmap[123] = 227;
	charmap[124] = 216;
	charmap[125] = 156;
	charmap[126] = 249;
}
e