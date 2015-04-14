/********************************************************************/
/*																	*/
/*		Task-Term													*/
/*																	*/
/*		Multitasking-Terminalprogramm								*/
/*																	*/
/*		(c)`88 by M.Bernards										*/
/*		nach Anregung des ST-Magazins								*/
/*																	*/
/********************************************************************/
#include <aes.h>
#include <define.h>
#include <vdi.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <scancode.h>
#include "taskterm.h"

extern	BASPAG	*_BasPag;
extern	int _AccFlag;

long get_timer(void);
void send(char c);

#define NO_WINDOW (-1)

int gl_hchar;
int gl_wchar;
int gl_wbox;
int gl_hbox;	/* system sizes */

int menu_id ;	/* our menu id */

int wi_handle;		/* window handle */
int top_window;
int wmode;			/* vdi-writingmode */
int phys_handle;	/* physical workstation handle */
int handle; 		/* virtual workstation handle */

int fontheight;		/* Fonth”he je nach Aufl”sung */

int xdesk,ydesk,hdesk,wdesk;

int msgbuff[8]; /* event message buffer */
int keycode;	/* keycode returned by event-keyboard */
int mx,my;		/* mouse x and y pos. */
int ret;		/* dummy return variable */

int pxyarray[10];	/* input point array */

int events = MU_MESAG | MU_BUTTON | MU_KEYBD;

IOREC *ior; 	/* Buffer fr rs232 */
IOREC v24buf;	/* alter Buffer */

int work_in[11];	/* Input to GSX parameter array */
int work_out[57];	/* Output from GSX parameter array */

OBJECT *mmain,*menu,*about,*term,*rs232,*sonstige,*nummern,*ftasten;
OBJECT *transfer,*proto,*msgbox;

TEDINFO *ted;		/* globale Tedinfo-Struktur */

int maxc,maxl;		/* max. anzahl zeichen und zeilen im Text */
char text[25][80];	/* screenpuffer */
long *pullbuff; 	/* Puffer fr Menleiste */
long pullen;		/* L„nge des puffers */
int nplanes;		/* anzahl der farbplanes */
char *bx;			/* Puffer */
long bxi;			/* Index im buffer */
char stlin[81];		/* term.-statuszeile */
long otimer;		/* online-timer */

int sx=0;
int sy=0;			/* Cursorposition */
int ysy; 			/* y position fr esc-Y */

int fullw = 0;		/* ganzer schirm */
int esc = 0;		/* Escape-flag */
int wrap;
int nr1,nr2;		/* fr vt100 */
int effects=0;		/* texteffekte */
int was_full;
int f2=0;			/* globales flag fr wind_update */
int lns=23;			/* anzahl der zeilen - 1*/

#define VERSION 0x4d420002

typedef struct {
	long version;
	int baud;
	int flow;
	int ucr;
	int duplex;
	int emu;
	int newline;
	char dial[14];
	char reset[14];
	char connect[14];
	int autom;
	char names[16][20];
	char numbers[16][20];
	char ftasten[10][40];
	int protokoll;
	int blklen;
	int chk;
	int multi;
	int timeout;
	long timer;
	int blen;
} PARAMETER;

PARAMETER para;

char baudtext[16][5];
char fsel_iinsel[13];
char pfadname[64];

int tbuf[512];

int hidden; 	/* current state of cursor */

full_window(void)
{
	dis_mouse(); hide_mouse();
	qmove(pullen,(long *) Logbase(),pullbuff); /* Menleiste retten*/
	wi_handle = wind_create(0, -1, -1, wdesk+2, ydesk+hdesk+2);
	wind_open(wi_handle,-1,-1,wdesk+2,ydesk+hdesk+2);
	v_enter_c(handle);
	fullw=1;
	events = MU_MESAG | MU_BUTTON | MU_KEYBD | MU_TIMER;
	vq_chcells(handle,&maxl,&maxc);
	make_status();
}

close_full(void)
{
	v_exit_c(handle);
	wind_close(wi_handle);
	wind_delete(wi_handle);
	wi_handle=NO_WINDOW;
	qmove(pullen,pullbuff,(long *) Logbase());
	ena_mouse(); show_mouse();
	fullw=0;
	events = MU_MESAG | MU_BUTTON | MU_KEYBD;
}

main(void)
{
int apid;

	apid=appl_init();
	phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
	if (gl_hchar == 16) fontheight=13;
	else fontheight=6;
	wi_handle=NO_WINDOW;
	hidden=FALSE;
	para.version=VERSION;
	if (rsrc_load("taskterm.rsc")) {
		rsrc_gaddr(0,MAIN,&mmain);
		rsrc_gaddr(0,RS232,&rs232);
		rsrc_gaddr(0,MENUBAR,&menu);
		rsrc_gaddr(0,UEBER,&about);
		rsrc_gaddr(0,TERMINAL,&term);
		rsrc_gaddr(0,SONSTIGE,&sonstige);
		rsrc_gaddr(0,NUMMERN,&nummern);
		rsrc_gaddr(0,FTASTEN,&ftasten);
		rsrc_gaddr(0,TRANSFER,&transfer);
		rsrc_gaddr(0,PROTO,&proto);
		rsrc_gaddr(0,MSGBOX,&msgbox);
		if (_AccFlag) menu_id=menu_register(apid,"  Taskterm v1.0 ");
		else {
			open_vwork();
			menu_bar(menu,1);
			graf_mouse(ARROW,0x0L);
		}
	}
	else
		if (!_AccFlag) return(-1);
	fill_baud();fill_para();
	qfill(stlin,80,32);			/* statuszeile l”schen */
	otimer=get_timer();
	nplanes=get_planes();
	pullen=(long)(wdesk/gl_wchar)*ydesk/4*nplanes;
	pullbuff=(long *)Malloc(pullen*4);
	Dgetpath(pfadname,0);strcat(pfadname,"\\");
	set_buffer(TRUE);		/* rs232-ring-buffer */
	load_parameter(FALSE);
	if (para.blen == 0) para.blen=10;
	if (para.blen > 31) para.blen=31;
	bx=(char *)Malloc(para.blen*1024);
	if (bx == 0) {
		bx=(char *)Malloc(1024L);
		para.blen=1;
	}
	qfill(text,2000,32);
	multi();
	set_buffer(FALSE);
}

multi(void)
{
int event,butt,shift,i;
char chr;

  while (TRUE) {
	event = evnt_multi(events,
			1,2,2,
			0,0,0,0,0,
			0,0,0,0,0,
			msgbuff,(para.timer*20)&0xffff,(para.timer*20)>>16,
			&mx,&my,&butt,&shift,&keycode,&ret);

	wind_up(TRUE);
	wind_get(wi_handle,WF_TOP,&top_window,&ret,&ret,&ret);
	if ((event & MU_TIMER) && (wi_handle == top_window)) {
		if (ior->head != ior->tail)
			aux_in();
		set_otime();
	}
	if (event & MU_MESAG)
	  switch (msgbuff[0]) {

	  case WM_REDRAW:
		if (msgbuff[3] == wi_handle) redraw_all();
		break;

	  case AC_CLOSE:
		if((msgbuff[3] == menu_id)&&(wi_handle != NO_WINDOW)){
		  v_clsvwk(handle);
		  wi_handle = NO_WINDOW;
		}
		break;

	  case WM_CLOSED:
		if(msgbuff[3] == wi_handle){
			close_full();
			v_clsvwk(handle);
		}
		break;

	  case AC_OPEN:
		if (msgbuff[4] == menu_id){
		  if(wi_handle == NO_WINDOW){
			open_vwork();
			full_window();
		  }
		}
		break;

	  case MN_SELECTED:
		switch(msgbuff[4]) {
		case MENUENDE:
			v_clsvwk(handle);
			wind_up(FALSE);
			return(0);
		case ABOUT:
			simple_dialog(about);
			break;
		case MENURS:
			do_rs232();
			break;
		case MENUTERM:
			do_term();
			break;
		case MENUPROT:
			do_proto();
			break;
		case MENUSONS:
			do_sonstige();
			break;
		case MENUVT:
			menu_tnormal(menu,msgbuff[3],1);
			full_window();
			break;
		case MENUSAVE:
			save_parameter();
			break;
		case MENULOAD:
			load_parameter(TRUE);
			break;
		case MENUSEND:
			datei_senden();
			break;
		case MENUEMPF:
			datei_empfangen();
			break;
		}
		menu_tnormal(menu,msgbuff[3],1);
		break;
	  } /* switch (msgbuff[0]) */

	if (event & MU_BUTTON) {
		if (butt & 2) {
			if (fullw) close_full();
			else full_window();
		}
	}

	if(event & MU_KEYBD){
		if (keycode == UNDO) {
			if (fullw) close_full();
			if (_AccFlag) v_clsvwk(handle);
		}
		else {
			if (keycode >= F1 && keycode <= F10) {
				i=0;
				while (para.ftasten[(keycode-F1)>>8][i])
					keypressed((int)(para.ftasten[(keycode-F1)>>8][i++]));
			}
			else keypressed(keycode);
		}
	}
		
	wind_up(FALSE);

  } /* while (TRUE) */

}

keypressed(int key)
{
/*
char bbb[7];
int x,y;

	strcpy(bbb,"      ");
	itoas(sx,2,bbb,1);itoas(sy,2,&bbb[3],1);
	v_gtext(handle,584,13,bbb);

	vq_curaddress(handle,&y,&x);
	strcpy(bbb,"      ");
	itoas(x,2,bbb,1);itoas(y,2,&bbb[3],1);
	v_gtext(handle,584,29,bbb);
*/
	was_full=0;
	if ((Kbshift(-1) & 8) && ((key&255) == 0)) {
		if (fullw) {
			was_full=1;
			close_full();
		}
		switch(key) {
		case ALT_W:
			if ((key=do_wahl()) != ABBRUCH) call_modem(key,0L);
			break;
		case ALT_S:
			datei_senden();
			break;
		case ALT_E:
			datei_empfangen();
			break;
		case ALT_F:
			do_ftaste();
			break;
		case ALT_B:
			do_batch();
			break;
		case ALT_R:
			do_rs232();
			break;
		case ALT_T:
			do_term();
			break;
		case ALT_M:
			do_sonstige();
			break;
		case ALT_P:
			do_proto();
			break;
		case ALT_L:
			bxi=0;
			qfill(bx,(long)para.blen<<10,0);
			break;
		case ALT_D:
			save_parameter();
			break;
		case ALT_A:
			send_ascii();
			break;
		}
		if (!fullw && was_full) full_window();
		return(0);
	}
	if (!fullw) return(0);
	
	if ((esc) && (para.emu != ASCII)) term_emu(key&255);
	else {
		switch (key) {
		case 13:
		case RETURN:
		case ENTER:
			if (para.duplex != VOLL) sx=0;
			ausgabe(13);
			break;
		case CNTRL_RETURN:
		case CNTRL_J:
		case 10:
			if (para.duplex != VOLL) {
				if (sy<lns) sy++;
				else linefeed();
			}
			ausgabe(10);
			break;
		case TAB:
		case 9:
			if (para.duplex != VOLL) {
				sx=((sx+9)&0x78)-1;
			}
			ausgabe(9);
			break;
		case BACKSPACE:
		case 8:
			if (para.duplex != VOLL)
				if (sx>0) sx--;
			ausgabe(8);
			break;
		case ESCAPE:
		case 27:
			if (para.duplex != VOLL) esc=1;
			if (para.duplex != LOKAL) send(27);
			break;
		case CUR_UP:
			if (para.emu == VT52) {
				if (para.duplex != VOLL) esc=1;
				if (para.duplex != LOKAL) send(27);
				term_emu('A');
			}
			if (para.emu == VT100) {
				if (para.duplex != VOLL) {esc='[';nr1=1;}
				if (para.duplex != LOKAL) {
					send(27);
					send('[');
					send('1');
				}
				term_emu('A');
			}
			break;
		case CUR_DOWN:
			if (para.emu == VT52) {
				if (para.duplex != VOLL) esc=1;
				if (para.duplex != LOKAL) send(27);
				term_emu('B');
			}
			if (para.emu == VT100) {
				if (para.duplex != VOLL) {esc='[';nr1=1;}
				if (para.duplex != LOKAL) {
					send(27);
					send('[');
					send('1');
				}
				term_emu('B');
			}
			break;
		case CUR_LEFT:
			if (para.emu == VT52) {
				if (para.duplex != VOLL) esc=1;
				if (para.duplex != LOKAL) send(27);
				term_emu('D');
			}
			if (para.emu == VT100) {
				if (para.duplex != VOLL) {esc='[';nr1=1;}
				if (para.duplex != LOKAL) {
					send(27);
					send('[');
					send('1');
				}
				term_emu('D');
			}
			break;
		case CUR_RIGHT:
			if (para.emu == VT52) {
				if (para.duplex != VOLL) esc=1;
				if (para.duplex != LOKAL) send(27);
				term_emu('C');
			}
			if (para.emu == VT100) {
				if (para.duplex != VOLL) {esc='[';nr1=1;}
				if (para.duplex != LOKAL) {
					send(27);
					send('[');
					send('1');
				}
				term_emu('C');
			}
			break;
		case HOME:
			if (para.emu == VT52) {
				if (para.duplex != VOLL) esc=1;
				if (para.duplex != LOKAL) send(27);
				term_emu('H');
			}
			if (para.emu == VT100) {
				if (para.duplex != VOLL) esc='[';
				if (para.duplex != VOLL) {esc='[';nr1=1;}
				if (para.duplex != LOKAL) {
					send(27);
					send('[');
				}
				term_emu('H');
			}
			break;
		case SHFT_HOME:
			if (para.emu == VT52) {
				if (para.duplex != VOLL) esc=1;
				if (para.duplex != LOKAL) send(27);
				term_emu('E');
			}
			if (para.emu == VT100) {
				if (para.duplex != VOLL) esc=1;
				if (para.duplex != LOKAL) send(27);
				term_emu('c');
			}
			break;
		case HELP:
			if (_AccFlag) {
				was_full=1;
				close_full();
				do_main_dialog();
				if (was_full)full_window();
			}
			break;
		default:
			if (key & 255) {
				ausgabe(key&255);
				if ((para.duplex != VOLL) && ((key&255) > 31)){
					text[sy][sx]=key&255;
					if (sx<79) sx++;
					else {
						if (wrap==1){
							sx=0;
							if (sy<lns) {sy++;Sconout(10);}
							else linefeed();
							Sconout(13);
						}
					}
				}
			}
		}	/* switch */
	}	/* else */
}

ausgabe(char c)
{
	if (para.duplex != LOKAL) send(c);
	if (para.duplex != VOLL) {
		if (c<32) Sconout(c);
		else Gconout(c);
	}
}

term_emu(int key)		/* escape wurde gedrckt */
{
	if (para.duplex != VOLL) {
		if (para.emu == VT52) con_vt52(key);
		else {
			if (para.emu == VT100) con_vt100(key);
			else Gconout(key&255);
		}
	}
	send(key);
}

aux_in()
{
int key;

	while (ior->head != ior->tail) {
		key=Cauxin();
		if (esc && (para.emu != ASCII)) {
			if (para.emu==VT52) con_vt52(key&255);
			else con_vt100(key&255);
		}
		else {
			switch (key) {
			case 13:
				sx=0;
				Sconout(13);
				if (para.newline == CRLF) {
					if (sy<lns) {
						sy++;
						Sconout(10);
					}
					else linefeed();
				}
				break;
			case 10:
				if (sy<lns) {
					sy++;
					Sconout(10);
				}
				else linefeed();
				break;
			case 9:
				Sconout(9);
				sx=((sx+9)&0x78)-1;
				break;
			case 8:
				if (sx>0) {sx--;Bconout(2,8);}
				break;
			case 27:
				esc=1;break;
			default:
				if ((key&255) >31) {
					Gconout(key&255);
					text[sy][sx]=key&255;
					if (sx<79) sx++;
					else {
						if (wrap==1){
							sx=0;
							if (sy<lns) {sy++;Sconout(10);}
							else linefeed();
							Sconout(13);
						}
					}
				}
			}	/* switch */
		}	/* else */
	}
}

con_vt52(int key)		/* VT52-Emulation */
{
static int ssx,ssy;	/* fr esc-j , esc-k 	*/

	switch (esc) {
	case 3:
		esc=0; sy=ysy-32; sx=key-32;
		vs_curaddress(handle,sy+1,sx+1);break;
	case 2:
		ysy=key;esc=3;break;
	case 'b':
		Setcolor(0,key&15);
		esc=0;break;
	case 'c':
		Setcolor(1,key&15);
		esc=0;break;
	case 1:
		switch (key) {
		case 'E':
			sx=sy=0;
			cesc('E');
			qfill(text,2000,32);
			esc=0;
			draw_status_line();
			break;
		case 'J':
			v_eeos(handle);
			qfill(&text[sy][sx],2000-80*sy-sx+1,32);
			esc=0;
			draw_status_line();
			break;
		case 'K':
			v_eeol(handle);
			qfill(&text[sy][sx],80-sx+1,32);
			esc=0;
			break;
		case 'd':
			cesc('d');
			qfill(text,80*sy+sx+1,32);
			esc=0;
			break;
		case 'o':
			cesc('o');
			qfill(text[sy],sx+1,32);
			esc=0;
			break;
		case 'I':
			if (sy>0) sy--;
			else {
				qmove(480,text,text[1]);
				qfill(text,80,32);
			}
			cesc('I');esc=0;
			break;
		case 'L':
			qmove((lns-sy)*20,text[sy],text[sy+1]);qfill(text[sy],80,32);
			cesc('L');esc=0;sx=0;
			break;
		case 'M':
			qmove((lns-sy)*20,text[sy+1],text[sy]);
			cesc('M');esc=0;sx=0;qfill(text[lns],80,32);
			break;
		case 'A':
			if (sy > 0) {sy--;cesc('A');}
			esc=0;
			break;
		case 'B':
			if (sy < lns) {sy++;cesc('B');}
			esc=0;
			break;
		case 'D':
			if (sx > 0) {sx--;cesc('D');}
			esc=0;
			break;
		case 'C':
			if (sx < 79) {sx++;cesc('C');}
			esc=0;
			break;
		case 'H':
			sx=sy=0;
			cesc('H');
			esc=0;
			break;
		case 'j':
			cesc('j');
			esc=0;ssx=sx;ssy=sy;break;
		case 'k':
			esc=0;sx=ssx;sy=ssy;cesc('k');
			break;
		case 'v':
			wrap=1;cesc('v');break;
		case 'w':
			wrap=0;cesc('w');break;
		case 'e':
		case 'f':
			cesc(key);esc=0;break;
		case 'q':
			wmode=1;
			vswr_mode(handle,1);break;
		case 'p':
			wmode=4;
			vswr_mode(handle,4);break;
		case 'Y':
			esc=2;break;
		case 'l':
			esc=0;cesc('l');sx=0;qfill(text[sy],80,32);break;
		case 'b':
		case 'c':
			esc=key;break;
		case '<':
			para.emu=VT100;esc=0;
			draw_status_line();
			break;
		default:
			if ((key & 255) >31) {
				Gconout(key&255);
				text[sy][sx]=key&255;
				if (sx<79) sx++;
				else {
					if (wrap==1){
						sx=0;
						if (sy<lns) {sy++;Sconout(10);}
						else linefeed();
						Sconout(13);
					}
				}
			}
			esc=0;
		}	/* switch (key) */
		break;
	}	/* switch (esc) */
}

con_vt100(int key)		/* VT100-Emulation */
{
int i;
static int ssx,ssy;

	switch (esc) {
	case 1:
		switch (key){
		case '[':
		case '(':
		case ')':
		case '#':
			esc=key;
			break;
		case 'D':
			if (sy<lns) sy++;
			else linefeed();
			Sconout(10);
			nr1=nr2=esc=0;
			break;
		case 'M':
			if (sy>0) sy--;
			else {
				qmove(480,text,text[1]);
				qfill(text,80,32);
			}
			cesc('I');
			nr1=nr2=esc=0;
			break;
		case 'E':
			if (sy<lns) sy++;
			else linefeed();
			Sconout(13);Sconout(10);
			sx=0;nr1=nr2=esc=0;
			break;
		case 'c':
			cesc('E');nr1=nr2=0;esc=0;
			sx=sy=0;qfill(text,2000,32);
			effects=0;vst_effects(handle,0);
			vswr_mode(handle,1);wmode=1;
			draw_status_line();
			break;
		case 'Z':
			send(27);send('[');
			send('?');send('1');
			send(';');send('2');
			send('c');
			nr1=nr2=0;esc=0;
			break;
		case '7':
			cesc('j');ssx=sx;ssy=sy;
			nr1=nr2=esc=0;
			break;
		case '8':
			cesc('k');sx=ssx;sy=ssy;
			nr1=nr2=esc=0;
			break;
		default:
			if ((key<='9')&&(key>='0'))
				nr1 = 10*nr1 + (key-'0');
			else {nr1=nr2=0;esc=0;}
			break;
		}
		break;
	case '[':
		switch (key){
		case 'f':
		case 'H':			/* Home */
			if (!nr1) nr1++;
			if (!nr2) nr2++;
			sx=nr1-1;sy=nr2-1;
			vs_curaddress(handle,nr2,nr1);
			esc=0;nr1=nr2=0;
			break;
		case 'm':			/* Attr. off */
			switch (nr1) {
			case 0:
				effects=0;
				vswr_mode(handle,1);wmode=1;
				break;
			case 1:
				effects |= 1;				
				break;
			case 5:
				effects |= 2;
				break;
			case 4:
				effects |= 8;
				break;
			case 7:
				vswr_mode(handle,4);wmode=4;
				break;
			}
			vst_effects(handle,effects);
			nr1=nr2=0;esc=0;
			break;
		case 'K':			/* Erase to EOL */
			switch (nr1) {
			case 0:
				v_eeol(handle);
				qfill(&text[sy][sx],80-sx+1,32);
				break;
			case 1:
				cesc('o');
				qfill(text[sy],sx+1,32);
				break;
			case 2:
				qfill(text[sy],80,32);
				cesc('j');cesc('I');cesc('k');esc=0;
				break;
			}
			esc=0;nr1=nr2=0;
			break;
		case 'J':			/* Erase to EOS */
			switch(nr1) {
			case 0:
				v_eeos(handle);
				qfill(&text[sy][sx],2000-80*sy-sx+1,32);
				draw_status_line();
				break;
			case 1:
				cesc('d');
				qfill(text,80*sy+sx+1,32);
				break;
			case 2:
				cesc('j');cesc('E');cesc('k');
				draw_status_line();
				qfill(text,2000,32);
				break;
			}
			esc=0;nr1=nr2=0;
			break;
		case 'A':
			sy -= nr1;
			if (sy < 0) sy=0;
			vs_curaddress(handle,sy+1,sx+1);
			esc=0;nr1=nr2=0;
			break;
		case 'B':
			sy += nr1;
			if (sy > lns) sy=lns;
			vs_curaddress(handle,sy+1,sx+1);
			esc=0;nr1=nr2=0;
			break;
		case 'D':
			sx -= nr1;
			if (sx < 0) sx=0;
			vs_curaddress(handle,sy+1,sx+1);
			esc=0;nr1=nr2=0;
		case 'C':
			sx += nr1;
			if (sx > 79) sx=79;
			vs_curaddress(handle,sy+1,sx+1);
			esc=0;nr1=nr2=0;
		case ';':
			nr2=nr1;nr1=0;
			break;
		case '?':
			esc='?';break;
		case 'q':
			nr1=min(nr1,4);
			if (nr1) stlin[74+nr1]=nr1+'0';
			else memcpy(&stlin[75],"    ",4);
			esc=0;nr1=nr2=0;
			draw_status_line();
			break;
		default:
			if ((key<='9')&&(key>='0'))
				nr1 = 10*nr1 + (key-'0');
			else {nr1=nr2=0;esc=0;}
			break;
		}
		break;
	case '(':
	case ')':
		nr1=nr2=0;esc=0;
		break;
	case '?':
		switch(key) {
		case 'l':
			if (nr1==2) {
				para.emu=VT52;
				draw_status_line();
			}
			if (nr1==5) {
				Setcolor(0,0);
				Setcolor(1,1);
			}
			if (nr1==7) {wrap=0;cesc('w');}
			nr1=nr2=esc=0;
			break;
		case 'h':
			if (nr1==5) {
				Setcolor(0,1);
				Setcolor(1,0);
			}
			if (nr1==7) {wrap=1;cesc('v');}
			nr1=nr2=esc=0;
			break;
		default:
			if ((key<='9')&&(key>='0'))
				nr1 = 10*nr1 + (key-'0');
			else {nr1=nr2=0;esc=0;}
			break;
		}
		break;
	case '#':
		switch(key) {
		case '3':
		case '4':
		case '5':
		case '6':
			break;
		}
		nr1=nr2=0;esc=0;
		break;
	default:
		if ((key & 255) >31) {
			Gconout(key&255);
			text[sy][sx]=key&255;
			if (sx<79) sx++;
			else {
				if (wrap==1){
					sx=0;
					if (sy<lns) {sy++;Sconout(10);}
					else linefeed();
					Sconout(13);
				}
			}
		}
		esc=0;nr1=nr2=0;
		break;
	}
}

do_rs232(void)
{
int redraw=0;
int x,y,w,h,ret;

	form_center(rs232,&x,&y,&w,&h);
	form_dial(0,0,0,0,0,x,y,w,h);
	do {
		objc_draw(rs232,redraw,3,x,y,w,h);
		ret=form_do(rs232,0);
		rs232[ret].ob_state=NORMAL;
		switch (ret) {
		case BAUDLEFT:
			if (para.baud < 15) para.baud++;
			strncpy(rs232[BAUDTEXT].ob_spec,baudtext[para.baud],5);
			redraw=BAUDRATE;
			break;
		case BAUDRIGT:
			if (para.baud > 0) para.baud--;
			strncpy(rs232[BAUDTEXT].ob_spec,baudtext[para.baud],5);
			redraw=BAUDRATE;
			break;
		}
	} while (ret != SETENDE);
	form_dial(3,0,0,0,0,x,y,w,h);
	para.ucr = 0x80;para.flow=0;
	if (rs232[XONXOFF].ob_state & SELECTED) para.flow |= 1;
	if (rs232[RTSCTS].ob_state & SELECTED) para.flow |= 2;
	if ((rs232[KEINE].ob_state & SELECTED) == 0) {
		para.ucr |= 4;
		if (rs232[GERADE].ob_state & SELECTED) para.ucr |= 2;
	}
	if (rs232[STOP1].ob_state & SELECTED) para.ucr |= 8;
	if (rs232[STOP15].ob_state & SELECTED) para.ucr |= 16;
	if (rs232[STOP2].ob_state & SELECTED) para.ucr |= 24;
	if (rs232[DATA5].ob_state & SELECTED) para.ucr |= 96;
	if (rs232[DATA6].ob_state & SELECTED) para.ucr |= 64;
	if (rs232[DATA7].ob_state & SELECTED) para.ucr |= 32;
	Rsconf(para.baud,para.flow,para.ucr,-1,-1,-1);
}

do_main_dialog()
{
int flag,ret;
	flag=0;
	do {
		switch(simple_dialog(mmain)) {
		case TASKTERM:
			simple_dialog(about);
			break;
		case SETRS232:
			do_rs232();
			break;
		case SETTERM:
			do_term();
			break;
		case PROTOKOL:
			do_proto();
			break;
		case SETOTHER:
			flag=do_sonstige();
			break;
		case SENDEN:
			datei_senden();
			break;
		case EMPFANG:
			datei_empfangen();
			break;
		case ENDE:
			flag=1;
			break;
		}
	 } while (flag==0);
}

do_term(void)
{
int x,y,w,h,ret;
	
	term[para.duplex].ob_state=SELECTED;
	term[para.emu].ob_state=SELECTED;
	term[para.newline].ob_state=SELECTED;
	form_center(term,&x,&y,&w,&h);
	form_dial(0,0,0,0,0,x,y,w,h);
	objc_draw(term,0,8,x,y,w,h);
	ret=form_do(term,0);
	term[ret].ob_state=NORMAL;
	form_dial(3,0,0,0,0,x,y,w,h);
	if (term[VOLL].ob_state & SELECTED) para.duplex=VOLL;
	if (term[HALB].ob_state & SELECTED) para.duplex=HALB;
	if (term[LOKAL].ob_state & SELECTED) para.duplex=LOKAL;
	if (term[ASCII].ob_state & SELECTED) para.emu=ASCII;
	if (term[VT52].ob_state & SELECTED) para.emu=VT52;
	if (term[VT100].ob_state & SELECTED) para.emu=VT100;
	if (term[CR].ob_state & SELECTED) para.newline=CR;
	if (term[CRLF].ob_state & SELECTED) para.newline=CRLF;
}

do_proto(void)
{
int x,y,w,h,ret;

	ted=(TEDINFO *)proto[PRIO].ob_spec;
	itoa(para.timer,ted->te_ptext,10);

	if (_AccFlag) proto[para.multi].ob_state = SELECTED;
	else {
		proto[MULTIJA].ob_state=DISABLED;
		proto[MULTINE].ob_state=SELECTED;
	}
	form_center(proto,&x,&y,&w,&h);
	form_dial(0,0,0,0,0,x,y,w,h);
	while(1) {
		proto[para.chk].ob_state = SELECTED;
		ted=(TEDINFO *)proto[BLOCKLEN].ob_spec;
		itoa(para.blklen,ted->te_ptext,10);
		ted=(TEDINFO *)proto[TIMEOUT].ob_spec;
		itoa(para.timeout,ted->te_ptext,10);
		if (para.blklen == 128)  proto[PXMODEM].ob_state |= SELECTED;
		if (para.blklen == 1024) proto[PYMODEM].ob_state |= SELECTED;
		objc_draw(proto,0,8,x,y,w,h);
		ret=form_do(proto,BLOCKLEN);
		if (ret == PAUSGANG) {
			proto[ret].ob_state=NORMAL;
			ted=(TEDINFO *)proto[BLOCKLEN].ob_spec;
			para.blklen=atoi(ted->te_ptext);
			ted=(TEDINFO *)proto[TIMEOUT].ob_spec;
			para.timeout=atoi(ted->te_ptext);
			break;
		}
		else para.protokoll=ret;
		if (ret == PXMODEM) {
			para.blklen=128;
			para.chk=CHKSUM;
			proto[CRC].ob_state=NORMAL;
		}
		if (ret == PYMODEM) {
			para.blklen=1024;
			para.chk=CRC;
			proto[CHKSUM].ob_state=NORMAL;
		}
	}
	form_dial(3,0,0,0,0,x,y,w,h);
	ted=(TEDINFO *)proto[PRIO].ob_spec;
	para.timer=(long)atoi(ted->te_ptext);
	if (proto[CHKSUM].ob_state & SELECTED) para.chk=CHKSUM;
	else para.chk=CRC;
	if (proto[MULTIJA].ob_state & SELECTED) para.multi=MULTIJA;
	else para.multi=MULTINE;
	if (para.blklen > 1024) para.blklen=1024;
}

do_sonstige(void)
{
int x,y,w,h,ret,i;

	ted=(TEDINFO *)sonstige[MODIAL].ob_spec;
	strcpy(ted->te_ptext,para.dial);
	ted=(TEDINFO *)sonstige[MORESET].ob_spec;
	strcpy(ted->te_ptext,para.reset);
	ted=(TEDINFO *)sonstige[MOCONNEC].ob_spec;
	strcpy(ted->te_ptext,para.connect);
	ted=(TEDINFO *)sonstige[PGROESSE].ob_spec;
	itoa(para.blen,ted->te_ptext,10);

	sonstige[para.autom].ob_state=SELECTED;

	form_center(sonstige,&x,&y,&w,&h);
	form_dial(0,0,0,0,0,x,y,w,h);
	objc_draw(sonstige,0,8,x,y,w,h);
	ret=form_do(sonstige,MODIAL);
	form_dial(3,0,0,0,0,x,y,w,h);

	sonstige[ret].ob_state=NORMAL;
	if (sonstige[BAUDAUTO].ob_state & SELECTED) para.autom=BAUDAUTO;
	else para.autom=BAUDMAN;
	ted=(TEDINFO *)sonstige[MODIAL].ob_spec;
	strcpy(para.dial,ted->te_ptext);
	ted=(TEDINFO *)sonstige[MORESET].ob_spec;
	strcpy(para.reset,ted->te_ptext);
	ted=(TEDINFO *)sonstige[MOCONNEC].ob_spec;
	strcpy(para.connect,ted->te_ptext);
	ted=(TEDINFO *)sonstige[PGROESSE].ob_spec;
	i=atoi(ted->te_ptext);
	if (i>31) i=31;
	if (i < para.blen) Mshrink(0,bx,i<<10);
	if (i > para.blen)
		if (!_AccFlag) {
			Mfree(bx);
			bx=(char *)Malloc(i<<10);
		}
	para.blen=i;
	switch (ret) {
	case DODIAL:
		if ((ret=do_wahl()) != ABBRUCH) call_modem(ret,0L);
		return(-1);
		break;
	case DOFTASTE:
		do_ftaste();
		break;
	case DOBATCH:
		do_batch();
		break;
	case SICHERN:
		save_parameter();
		break;
	case LADEN:
		load_parameter(TRUE);
		break;
	case PLOESCH:
		bxi=0;
		qfill(bx,(long)para.blen<<10,0);
		break;
	}	
	return(0);
}

int do_wahl(void)
{
int ret,i,x,y,w,h;

	for(i=NAME1;i<=NAME16;i++) {
		ted = (TEDINFO *) nummern[i].ob_spec;
		strcpy(ted->te_ptext,para.names[i-NAME1]);
	}
	for(i=NUMMER1;i<=NUMMER16;i++) {
		ted = (TEDINFO *) nummern[i].ob_spec;
		strcpy(ted->te_ptext,para.numbers[i-NUMMER1]);
	}
	form_center(nummern,&x,&y,&w,&h);
	form_dial(0,0,0,0,0,x,y,w,h);
	objc_draw(nummern,0,8,x,y,w,h);
	ret=form_do(nummern,NAME1);
	nummern[ret].ob_state=NORMAL;
	for(i=NAME1;i<=NAME16;i++) {
		ted = (TEDINFO *) nummern[i].ob_spec;
		strcpy(para.names[i-NAME1],ted->te_ptext);
	}
	for(i=NUMMER1;i<=NUMMER16;i++) {
		ted = (TEDINFO *) nummern[i].ob_spec;
		strcpy(para.numbers[i-NUMMER1],ted->te_ptext);
	}
	form_dial(3,0,0,0,0,x,y,w,h);
	return(ret);
}

do_ftaste(void)
{
int i,ret,x,y,w,h;

	for(i=FT1;i<=FT10;i++) {
		ted=(TEDINFO *)ftasten[i].ob_spec;
		strcpy(ted->te_ptext,para.ftasten[i-FT1]);
	}
	form_center(ftasten,&x,&y,&w,&h);
	form_dial(0,0,0,0,0,x,y,w,h);
	objc_draw(ftasten,0,8,x,y,w,h);
	ret=form_do(ftasten,FT1);
	ftasten[ret].ob_state=NORMAL;
	for(i=FT1;i<=FT10;i++) {
		ted=(TEDINFO *)ftasten[i].ob_spec;
		strcpy(para.ftasten[i-FT1],ted->te_ptext);
	}
	form_dial(3,0,0,0,0,x,y,w,h);
}

call_modem(int nr,char *num)
{
int i,x,y,w,h;
char c,num2[20],*b;
long timer;

	ted=(TEDINFO *)msgbox[BOXTEXT].ob_spec;
	strcpy(ted->te_ptext,"Modem Reset");
	form_center(msgbox,&x,&y,&w,&h);
	form_dial(0,0,0,0,0,x,y,w,h);
	objc_draw(msgbox,0,3,x,y,w,h);
	i=0;
	ior->head=ior->tail;
	while(para.reset[i])
		send(para.reset[i++]);
	if (i) evnt_timer(2000,0);
	strcpy(ted->te_ptext,"W„hle ");
	if (nr == -1) strcpy(ted->te_ptext+6,num);
	else strcpy(ted->te_ptext+6,para.names[nr-N1]);
	objc_draw(msgbox,BOXTEXT,3,x,y,w,h);
	ior->head=ior->tail;
	i=0;
	while(para.dial[i])
		send(para.dial[i++]);
	i=0;
	if (nr == -1) strcpy(num2,num);
	else strcpy(num2,para.numbers[nr-N1]);
	while(num2[i])
		send(num2[i++]);
	send(13);
	i=0;
	timer=get_timer();
	while (i < strlen(para.connect)) {
		c=0;
		if (ior->tail != ior->head) {
			c=Cauxin();
			if (c == para.connect[i]) i++;
			else i=0;
		}
		if (((get_timer()-timer)/200 >= 45) || Cconis()) {
			if (Cconis()) send(Crawcin());
			else send(13);
			form_dial(3,0,0,0,0,x,y,w,h);
			return(-1);
		}
	}
	otimer=get_timer();	/* jetzt sind wir online */
	qfill(stlin,20,32);
	if (nr == -1) memcpy(&stlin[1],num,strlen(num));
	else memcpy(&stlin[1],para.names[nr-N1],strlen(para.names[nr-N1]));

	if (para.autom == BAUDAUTO) {
		strcpy(ted->te_ptext,"Baudrate einstellen");
		objc_draw(msgbox,BOXTEXT,3,x,y,w,h);
		timer=get_timer();
		while ((get_timer()-timer) < (para.baud+1)*32);
		if (ior->tail != ior->head){
			b=(char *)ior->buf;
			para.baud=9;
			if (!strncmp(b+ior->head+2,"1200",4))
				para.baud=7;
			if (!strncmp(b+ior->head+2,"2400",4))
				para.baud=4;
			if (!strncmp(b+ior->head+2,"4800",4))
				para.baud=2;
			if (!strncmp(b+ior->head+2,"9600",4))
				para.baud=1;
			set_rs232();
		}
	}
	form_dial(3,0,0,0,0,x,y,w,h);
	return(0);
}

redraw_all(void)
{
int i;
char b;

	cesc('E');cesc('f');
	vst_effects(handle,0);
	for (i=0;i<lns+1;i++) {
		b=text[i+1][0];text[i+1][0]=0;
		v_gtext(handle,0,(i+1)*gl_hchar-3,text[i]);
		text[i+1][0]=b;
	}
	vst_effects(handle,effects);
	draw_status_line();
	vs_curaddress(handle,sy+1,sx+1);
	cesc('e');
}

save_parameter(void)
{
int hd;
char komplett[80];
long len;

  hd=form_alert(1,"[0][Was m”chten sie sichern ?][Parameter|Puffer|Abbruch]");
  if (hd==1) {
	if (fsel("*.SET",komplett,"Parameter sichern") == 1) {
		hd=Fcreate(komplett,0);
		if (hd > 0) {
			Fwrite(hd,sizeof(PARAMETER),&para);
			Fclose(hd);
		}
	}
  }
  if (hd==2) {
	if (fsel("*.*",komplett,"Puffer sichern") == 1) {
		hd=Fcreate(komplett,0);
		if (hd > 0) {
			len=0;
			while (len < (long)para.blen<<10)
				if (bx[len++] == 0) break;
			Fwrite(hd,len-1,bx);
			Fclose(hd);
		}
	}
  }
}

int fsel(const char *mask, char *buf,const char *ueberschrift)
{
char *dummy;
int len,button,fnd;

	fnd=FALSE;
	if (Sversion() >= 0x1500)
		fsel_exinput(strcat(pfadname,mask),fsel_iinsel,ueberschrift,&button);
	else	
		fsel_input(strcat(pfadname,mask),fsel_iinsel,&button);
	for(len = strlen(pfadname)-1;len >= 0;len--) {
		if (pfadname[len] == 0x5c) {
			fnd=TRUE;
			break;
		}
	}
	if (fnd == FALSE) len=strlen(pfadname);
	else len++;
	strncpy(buf,pfadname,len);buf[len]=0;
	strcat(buf,fsel_iinsel);
	pfadname[len]=0;
	return(button);
}

load_parameter(int flag)
{
int hd;
char komplett[80];

	if (flag == TRUE) {
		if (fsel("*.set",komplett,"Parameter laden") == 0)
		return(0);
	}
	else strcpy(komplett,"TASKTERM.SET");
	hd=Fopen(komplett,0);
	if (hd > 0) {
		Fread(hd,sizeof(PARAMETER),&para);
		Fclose(hd);
		if (para.version == VERSION) set_rs232();
		else fill_para();
	}
	else form_alert(1,"[1][Parameterdatei|nicht gefunden][Abbruch]");
}

set_rs232(void)
{
	Rsconf(para.baud,para.flow,para.ucr,-1,-1,-1);
	strncpy(rs232[BAUDTEXT].ob_spec,baudtext[para.baud],5);
	if (para.flow & 1) rs232[XONXOFF].ob_state=SELECTED;
	else rs232[XONXOFF].ob_state=NORMAL;
	if (para.flow & 2) rs232[RTSCTS].ob_state=SELECTED;
	else rs232[RTSCTS].ob_state=NORMAL;
	if ((para.ucr & 96) == 96) rs232[DATA5].ob_state=SELECTED;
	else rs232[DATA5].ob_state=NORMAL;
	if ((para.ucr & 96) == 64) rs232[DATA6].ob_state=SELECTED;
	else rs232[DATA6].ob_state=NORMAL;
	if ((para.ucr & 96) == 32) rs232[DATA7].ob_state=SELECTED;
	else rs232[DATA7].ob_state=NORMAL;
	if ((para.ucr & 96) == 0) rs232[DATA8].ob_state=SELECTED;
	else rs232[DATA8].ob_state=NORMAL;
	if ((para.ucr & 24) == 24) rs232[STOP2].ob_state=SELECTED;
	else rs232[STOP2].ob_state=NORMAL;
	if ((para.ucr & 24) == 16) rs232[STOP15].ob_state=SELECTED;
	else rs232[STOP15].ob_state=NORMAL;
	if ((para.ucr & 24) == 8) rs232[STOP1].ob_state=SELECTED;
	else rs232[STOP1].ob_state=NORMAL;
	if ((para.ucr & 4) == 0) rs232[KEINE].ob_state=SELECTED;
	else {
		rs232[KEINE].ob_state=NORMAL;
		if (para.ucr & 2) {
			rs232[GERADE].ob_state=SELECTED;
			rs232[UNGERADE].ob_state=NORMAL;
		}
		else {
			rs232[UNGERADE].ob_state=SELECTED;
			rs232[GERADE].ob_state=NORMAL;
		}
	}
}

open_vwork(void)
{
int i;
	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	handle=phys_handle;
	v_opnvwk(work_in,&handle,work_out);
}

int simple_dialog(OBJECT *tree)
{
int x,y,w,h,ret;
	
	form_center(tree,&x,&y,&w,&h);
	form_dial(0,0,0,0,0,x,y,w,h);
	objc_draw(tree,0,8,x,y,w,h);
	ret=form_do(tree,0);
	tree[ret].ob_state=NORMAL;
	form_dial(3,0,0,0,0,x,y,w,h);
	return(ret);
}

int (* savmot)();

int move()
{
}

dis_mouse(void)
{
	vex_motv(handle,move,&savmot);
}

ena_mouse(void)
{
	vex_motv(handle,savmot,&savmot);
}

hide_mouse(void)
{
	if(! hidden){
		graf_mouse(M_OFF,0x0L);
		hidden=TRUE;
	}
}

show_mouse(void)
{
	if(hidden){
		graf_mouse(M_ON,0x0L);
		hidden=FALSE;
	}
}

fill_baud(void)
{
	strcpy(baudtext[0],"19200");
	strcpy(baudtext[1],"9600");
	strcpy(baudtext[2],"4800");
	strcpy(baudtext[3],"3600");
	strcpy(baudtext[4],"2400");
	strcpy(baudtext[5],"2000");
	strcpy(baudtext[6],"1800");
	strcpy(baudtext[7],"1200");
	strcpy(baudtext[8],"600");
	strcpy(baudtext[9],"300");
	strcpy(baudtext[10],"200");
	strcpy(baudtext[11],"150");
	strcpy(baudtext[12],"134");
	strcpy(baudtext[13],"110");
	strcpy(baudtext[14],"75");
	strcpy(baudtext[15],"50");
}

fill_para()
{
	para.version=VERSION;
	para.emu=VT52;
	para.newline=CR;
	para.duplex=VOLL;
	para.protokoll=PXMODEM;
	para.chk=CHKSUM;
	para.multi=MULTIJA;
	para.autom=BAUDMAN;
}

set_buffer(int flag)
{
	if (flag) {
		ior=Iorec(0);
		v24buf = *ior;
		ior->buf = Malloc(32000);
		ior->head = ior->tail = 0;
		ior->bufsize=32000;
	} else *ior = v24buf;
}

cesc(char c)
{
	Bconout(2,27);Bconout(2,c);
}

Sconout(char c)
{
	Bconout(2,c);
	bx[bxi++]=c;if(bxi>(long)para.blen<<10)bxi=0;
}

Gconout(char c)
{
int s;
	s=(c<<8);
	Bconout(5,' ');
	v_gtext(handle,sx*gl_wchar,(sy+1)*gl_hchar-3,&s);
	bx[bxi++]=c;if(bxi>(long)para.blen<<10)bxi=0;
}

wind_up(int flag)
{
	if (f2 != flag) {
		wind_update(flag);
		f2=flag;
	}
}

linefeed(void)
{
MFDB src,dst;

	if (sy<lns) sy++;
	else {
		bx[bxi++]=10;if(bxi>(long)para.blen<<10)bxi=0;
		qmove(480,text[1],text[0]);
		qfill(text[lns],80,32);
		if (maxl > (lns+1)) {
			cesc('f');
			src.fd_addr   =dst.fd_addr   = Logbase();
			src.fd_w      =dst.fd_w      = wdesk;
			src.fd_h      =dst.fd_h      = ydesk+hdesk;
			src.fd_stand  =dst.fd_stand  = 0;
			src.fd_wdwidth=dst.fd_wdwidth= wdesk>>4;
			src.fd_nplanes=dst.fd_nplanes= nplanes;

			pxyarray[0] = pxyarray[4] = 0;
			pxyarray[1] = gl_hchar;
			pxyarray[5] = 0;
			pxyarray[2] = pxyarray[6] = 80*gl_wchar;
			pxyarray[3] = (lns+1)*gl_hchar;
			pxyarray[7] = lns*gl_hchar;

			vro_cpyfm(handle,3,pxyarray,&src,&dst);

			pxyarray[0]=pxyarray[4]=0;
			pxyarray[1]=pxyarray[5]=lns*gl_hchar;
			pxyarray[2]=pxyarray[6]=80*gl_wchar;
			pxyarray[3]=pxyarray[7]=(lns+1)*gl_hchar;
			vro_cpyfm(handle,0,pxyarray,&src,&dst);

			vs_curaddress(handle,lns+1,sx+1);
			cesc('e');
		}
	}
}

/* macht aus sekunden einen string hh.mm.ss */

char *sec_to_dstr(long seconds, char *s)
{
	s[2]=s[5]=':';
	itoas(seconds/3600,s,2,1);
	seconds %= 3600;
	itoas(seconds/60,&s[3],2,1);
	seconds %= 60;
	itoas(seconds,&s[6],2,1);
	return(s);
}

make_status_line(void)
{
	sec_to_dstr((get_timer()-otimer)/200,&stlin[21]);
	memcpy(&stlin[42],"     ",5);
	memcpy(&stlin[42],baudtext[para.baud],strlen(baudtext[para.baud]));
	stlin[47]=' ';
	if (para.protokoll == PXMODEM) memcpy(&stlin[48],"XMODEM",6);
	else memcpy(&stlin[48],"YMODEM",6);
	if (para.chk == CHKSUM) memcpy(&stlin[55],"CHK",3);
	else memcpy(&stlin[55],"CRC",3);
	if (para.emu==VT52 ) memcpy(&stlin[59],"VT52 ",5);
	if (para.emu==VT100) memcpy(&stlin[59],"VT100",5);
	if (para.emu==ASCII) memcpy(&stlin[59],"ASCII",5);
}

gett(char *s)
{
time_t t;

	time(&t);
	memcpy(s,ctime(&t)+11,5);
	s[0] &= 31;
	s[1] &= 31;
	s[3] &= 31;
	s[4] &= 31;
}

set_otime(void)
{
char t[20];
int d;
	vst_height(handle,6,&d,&d,&d,&d);
	vst_effects(handle,0);vswr_mode(handle,1);
	qfill(t,20,32);
	sec_to_dstr((get_timer()-otimer)/200,t);
	d=100-(100*bxi)/(para.blen<<10);		/* % free in buffer */
	gett(&t[9]);itoas(d,&t[15],3,1);t[18]='%';t[20]=0;
	v_gtext(handle,21*gl_wchar,25*gl_hchar-3,t);
	vst_height(handle,fontheight,&d,&d,&d,&d);
	vst_effects(handle,effects);vswr_mode(handle,wmode);
}

draw_line(void)
{
	if (gl_hchar < 16) return;
	pxyarray[0]=0;pxyarray[2]=80*gl_wchar;
	pxyarray[1]=pxyarray[3]=(lns+1)*gl_hchar+4;
	v_pline(handle,2,pxyarray);
}

draw_status_line(void)
{
int i;
	make_status_line();
	draw_line();
	vst_effects(handle,0);vswr_mode(handle,1);
	vst_height(handle,6,&i,&i,&i,&i);
	v_gtext(handle,0,25*gl_hchar-3,stlin);
	vst_height(handle,fontheight,&i,&i,&i,&i);
	vst_effects(handle,effects);vswr_mode(handle,wmode);
}