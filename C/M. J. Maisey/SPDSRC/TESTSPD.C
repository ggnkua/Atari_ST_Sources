#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <mintbind.h>
#include "testspde.h"
#include "testspde.c"

#define FALSE 0
#define TRUE  1

void fix_tree(OBJECT *,int);

int main(int, char*[]);
void handle_message(short[]);
int redraw(int, GRECT*);
void open_window(void);
void redraw_all(void);
short show_othersize(void);
void show_about(void);
void make_fontmenu(void);
void handle_menu(OBJECT*, short);
short show_otherwidth(void);
void handle_dragdrop(short, short);

short int ApId;
short vdihandle, work_in[] = {1,1,1,1,1,1,1,1,1,1,2}, work_out[57],
      numfonts, fontsize, fontwidth, font;
short windowhandle, quit = FALSE;
char menu_title[] = "  Test Speedo";
char **fontnames;
OBJECT *smenufont;

int main(int argc, char *argv[])  {
  char *altNoVDIWork = "[3][Gem is unable to|allocate a workstation.|The program must abort.[ OK ]";
  short msgbuf[8], dum;
  
	ApId = appl_init();
	if (ApId == -1)
		return -1;
	
	if (_AESglobal[0] < 0x0303)  {
		form_alert(1, "[3][Gem v3.3 or above|is required.][ Abort ]");
		appl_exit();
		return -1;
	}
	
	work_in[0] = 2 + Getrez();
	vdihandle = graf_handle(&dum, &dum, &dum, &dum);
	v_opnvwk(work_in, &vdihandle, work_out);
	if (vdihandle == 0)  {
		form_alert(1, altNoVDIWork);
		appl_exit();
		return -1;
	}
	
	numfonts = vst_load_fonts(vdihandle, 0);
	fontsize = 40;
	fontwidth = 100;
	font = 7;
	
	if (_AESglobal[1] == -1)  menu_register(ApId, menu_title);
	
	rsrc_init();
	make_fontmenu();
	menu_bar(MAINMENU, 1);
	menu_icheck(smenufont, font - 1, 1);
	menu_icheck(SIZEMENU, SI_OTHER, 1);
	menu_icheck(WIDTHMENU, WI_100, 1);
		
	open_window();
	
	while (!quit)  {
		evnt_mesag(msgbuf);
		handle_message(msgbuf);
	}
	
	menu_bar(MAINMENU, 0);
	vst_unload_fonts(vdihandle, 0);
	v_clsvwk(vdihandle);
	appl_exit();
	
	return 0;
}


void open_window(void)  {
	GRECT desk;
	
	wind_get(0, WF_PREVXYWH, &desk.g_x, &desk.g_y, &desk.g_w, &desk.g_h);
  windowhandle = wind_create(NAME|CLOSE|MOVE|SIZE, desk.g_x, desk.g_y, desk.g_w, desk.g_h);
  wind_title(windowhandle, "Test");
  wind_info(windowhandle, "");
  wind_open(windowhandle, 100,100,350,200);
}


void handle_message(short msgbuf[])  {
	int (*fptr)(int,GRECT*);
	
	switch(msgbuf[0])  {
	case MN_SELECTED:
    handle_menu((OBJECT *) *((long *) (msgbuf+5)), msgbuf[4]);
    menu_tnormal(MAINMENU, msgbuf[3], 1);
		break;
	case WM_REDRAW:
	  fptr = &redraw;
		wind_redraw(windowhandle, (GRECT *) (msgbuf + 4), fptr);
		break;
	case WM_TOPPED:
		if (msgbuf[3] == windowhandle)
			wind_set(msgbuf[3], WF_TOP, msgbuf[3], 0, 0, 0);
		break;
	case WM_CLOSED:
		if (msgbuf[3] == windowhandle)  {
			wind_close(msgbuf[3]);
			wind_delete(msgbuf[3]);
			quit = TRUE;
		}
		break;
	case WM_MOVED:
		if (msgbuf[3] == windowhandle)
			wind_set(msgbuf[3], WF_CURRXYWH, msgbuf[4], msgbuf[5], msgbuf[6],
			         msgbuf[7]);
		break;
	case WM_SIZED:
		if (msgbuf[3] == windowhandle)  {
			wind_set(msgbuf[3], WF_CURRXYWH, msgbuf[4], msgbuf[5], msgbuf[6],
			         msgbuf[7]);
			redraw_all();
		}
		break;
	case AP_DRAGDROP:
		if (msgbuf[3] == windowhandle)  {
			handle_dragdrop(msgbuf[1], msgbuf[7]);
		}
		break;
	}
}


void handle_menu(OBJECT *tree, short item)  {
	if (tree == MAINMENU)  {
		switch (item)  {
		case ME_ABOUT:
			show_about();
			break;
		case ME_FONT:
			break;
		case ME_QUIT:
			wind_close(windowhandle);
			wind_delete(windowhandle);
			quit = TRUE;
			break;
		}
	}
	
	if (tree == smenufont)  {
		menu_icheck(smenufont, font - 1, 0);
		font = item + 1;
		redraw_all();
		menu_icheck(smenufont, font - 1, 1);
	}
	
	if (tree == SIZEMENU)  {
		menu_icheck(SIZEMENU, SI_10, 0);
		menu_icheck(SIZEMENU, SI_12, 0);
		menu_icheck(SIZEMENU, SI_18, 0);
		menu_icheck(SIZEMENU, SI_24, 0);
		menu_icheck(SIZEMENU, SI_OTHER, 0);
		switch (item)  {
		case SI_10:
			fontsize = 10;
			menu_icheck(SIZEMENU, SI_10, 1);
			break;
		case SI_12:
			fontsize = 12;
			menu_icheck(SIZEMENU, SI_12, 1);
			break;
		case SI_18:
			fontsize = 18;
			menu_icheck(SIZEMENU, SI_18, 1);
			break;
		case SI_24:
			fontsize = 24;
			menu_icheck(SIZEMENU, SI_24, 1);
			break;
		case SI_OTHER:
			fontsize = show_othersize();
			menu_icheck(SIZEMENU, SI_OTHER, 1);
			break;
		}
		redraw_all();
	}
	
	if (tree == WIDTHMENU)  {
		menu_icheck(WIDTHMENU, WI_50, 0);
		menu_icheck(WIDTHMENU, WI_75, 0);
		menu_icheck(WIDTHMENU, WI_100, 0);
		menu_icheck(WIDTHMENU, WI_150, 0);
		menu_icheck(WIDTHMENU, WI_200, 0);
		menu_icheck(WIDTHMENU, WI_OTHER, 0);
		switch(item)  {
		case WI_50:
			fontwidth = 50;
			menu_icheck(WIDTHMENU, WI_50, 1);
			break;
		case WI_75:
			fontwidth = 75;
			menu_icheck(WIDTHMENU, WI_75, 1);
			break;
		case WI_100:
			fontwidth = 100;
			menu_icheck(WIDTHMENU, WI_100, 1);
			break;
		case WI_150:
			fontwidth = 150;
			menu_icheck(WIDTHMENU, WI_150, 1);
			break;
		case WI_200:
			fontwidth = 200;
			menu_icheck(WIDTHMENU, WI_200, 1);
			break;
		case WI_OTHER:
			fontwidth = show_otherwidth();
			menu_icheck(WIDTHMENU, WI_OTHER, 1);
			break;
		}
		redraw_all();
	}
}


void handle_dragdrop(short tapid, short pipeno)  {
	int pipehandle;
	char pipename[128], myfiletypes[32], *msghdr, size;
	
	/* Open pipe to originator */
	sprintf(pipename, "U:\\PIPE\\DRAGDROP.%c%c", *((char *)&pipeno), *((char*)(&pipeno)+1));
	printf("%s\n", pipename);
	pipehandle = Fopen(pipename, 1);
	
	/* Send acceptable data types */
	sprintf(myfiletypes, "ARGS");
	Fwrite(pipehandle, 32, (void *) myfiletypes);
	
	/* Find size of, reserve memory for, and read message header */
	while (Fread(pipehandle, 2, (void *) &size) > 0)  {
		msghdr = (char *) malloc(size);
		Fread(pipehandle, size, (void *) msghdr);
		if (strncmp(msghdr, "ARGS", 4))  {
			form_alert(1, "[1][DRAGDROP successfully|negotiated][Continue]");
		}
		Fputchar(pipehandle, 2, 0);   /* Send DD_EXT */
		free((void *) msghdr);
	}
	Fclose(pipehandle);
}


int redraw(int windowhandle, GRECT *rect)  {
	short pxyarray[4], fontindex, charw, charh, cellw, cellh, dummy, extent[8];
	char fontname[50];
	GRECT workarea;
	
	pxyarray[0] = rect->g_x;
	pxyarray[1] = rect->g_y;
	pxyarray[2] = rect->g_x + rect->g_w - 1;
	pxyarray[3] = rect->g_y + rect->g_h - 1;
	vs_clip(vdihandle, 1, pxyarray);
	
	vsf_color(vdihandle, 0);
	vsf_style(vdihandle, 8);
	vsf_interior(vdihandle, 2);
	vr_recfl(vdihandle, pxyarray);
	fontindex = vqt_name(vdihandle, font, fontname);
	vst_font(vdihandle, fontindex);
	vst_arbpt(vdihandle, fontsize, &charw, &charh, &cellw, &cellh);
	vst_setsize(vdihandle, (int) ((float) fontwidth * (float) fontsize / 100.0), &charw, &charh, &cellw, &cellh);
	vst_alignment(vdihandle, 0, 2, &dummy, &dummy);
	wind_get(windowhandle, WF_WORKXYWH, &workarea.g_x, &workarea.g_y, &workarea.g_w, &workarea.g_h);
	
	vqt_extent(vdihandle, fontname, extent);
	v_ftext(vdihandle, workarea.g_x + workarea.g_w / 2 - extent[4] / 2,
	        workarea.g_y + workarea.g_h / 2 - charh / 2, fontname);

	return 1;
}


short show_otherwidth(void)  {
	short x, y, w, h, ret;
	int newwidth;
	
	sprintf(((TEDINFO *)OTHERWIDTH[OS_TEXT].ob_spec)->te_ptext, "%3d", fontwidth);
	
	form_center(OTHERWIDTH, &x, &y, &w, &h);
	x-=2;
	y-=2;
	w+=4;
	h+=4;
	wind_update(BEG_UPDATE);
	form_dial(FMD_START, x, y, w, h, x, y, w, h);
	
	objc_draw(OTHERWIDTH, 0, 7, x, y, w, h);
	ret = form_do(OTHERWIDTH, 0);
	sscanf(((TEDINFO *)OTHERWIDTH[OS_TEXT].ob_spec)->te_ptext, "%d", &newwidth);
	
	OTHERWIDTH[OS_OK].ob_state &= ~SELECTED;
	OTHERWIDTH[OS_CANCEL].ob_state &= ~SELECTED;
	form_dial(FMD_FINISH, x, y, w, h, x, y, w, h);
	wind_update(END_UPDATE);
	
	if (ret == OS_OK)
		return (short) newwidth;
	else
		return fontwidth;
}


short show_othersize(void)  {
	short x, y, w, h, ret;
	int newsize;
	
	sprintf(((TEDINFO *)OTHERSIZE[OS_TEXT].ob_spec)->te_ptext, "%3d", fontsize);
	
	form_center(OTHERSIZE, &x, &y, &w, &h);
	x-=2;
	y-=2;
	w+=4;
	h+=4;
	wind_update(BEG_UPDATE);
	form_dial(FMD_START, x, y, w, h, x, y, w, h);
	
	objc_draw(OTHERSIZE, 0, 7, x, y, w, h);
	ret = form_do(OTHERSIZE, 0);
	sscanf(((TEDINFO *)OTHERSIZE[OS_TEXT].ob_spec)->te_ptext, "%d", &newsize);
	
	OTHERSIZE[OS_OK].ob_state &= ~SELECTED;
	OTHERSIZE[OS_CANCEL].ob_state &= ~SELECTED;
	form_dial(FMD_FINISH, x, y, w, h, x, y, w, h);
	wind_update(END_UPDATE);
	
	if (ret == OS_OK)
		return (short) newsize;
	else
		return fontsize;
}


void show_about(void)  {
	short x, y, w, h;
	
	form_center(ABOUT, &x, &y, &w, &h);
	x-=2;
	y-=2;
	w+=4;
	h+=4;
	wind_update(BEG_UPDATE);
	form_dial(FMD_START, x, y, w, h, x, y, w, h);
	
	objc_draw(ABOUT, 0, 7, x, y, w, h);
	form_do(ABOUT, 0);
	
	ABOUT[AB_OK].ob_state &= ~SELECTED;
	form_dial(FMD_FINISH, x, y, w, h, x, y, w, h);
	wind_update(END_UPDATE);
}


void redraw_all(void)  {
	GRECT desk;

	wind_get(0, WF_PREVXYWH, &desk.g_x, &desk.g_y, &desk.g_w, &desk.g_h);
	wind_redraw(windowhandle, &desk, &redraw);
}


void make_fontmenu(void)  {
	int n;
	char temp[50];
	MENU submenu;
	
	/* Allocate space for font names and object tree */
	fontnames = (char **) malloc(numfonts * sizeof(char *));
	smenufont = (OBJECT *) malloc((numfonts + 1) * sizeof(OBJECT));
	
	/* Build object tree for submenu */
	smenufont[ROOT].ob_next = -1;
	smenufont[ROOT].ob_head = 1;
	smenufont[ROOT].ob_tail = numfonts-1;
	smenufont[ROOT].ob_type = G_BOX;
	smenufont[ROOT].ob_flags = 0x0;
	smenufont[ROOT].ob_state = 0x0;
	smenufont[ROOT].ob_spec = (void *)0xff1100;
	smenufont[ROOT].ob_x = 4;
	smenufont[ROOT].ob_y = 0;
	smenufont[ROOT].ob_width = 27;
	smenufont[ROOT].ob_height = numfonts - 1;
	
	for (n = 2; n <= numfonts; n++)  {
	  vqt_name(vdihandle, n, temp);
		fontnames[n - 1] = (char *) malloc(28);
		sprintf(fontnames[n-1], "  %-23s  ", temp);
		smenufont[n-1].ob_next = n;
		smenufont[n-1].ob_head = -1;
		smenufont[n-1].ob_tail = -1;
		smenufont[n-1].ob_type = G_STRING;
		smenufont[n-1].ob_flags = 0x0;
		smenufont[n-1].ob_state = 0x0;
		smenufont[n-1].ob_spec = (void *)fontnames[n - 1];
		smenufont[n-1].ob_x = 0;
		smenufont[n-1].ob_y = n - 2;
		smenufont[n-1].ob_width = 27;
		smenufont[n-1].ob_height = 1;
	}
	smenufont[numfonts-1].ob_next = ROOT;
	smenufont[numfonts-1].ob_flags = LASTOB;
	fix_tree(smenufont, numfonts);
	
	/* Attach submenu to main menu */
	submenu.mn_tree = smenufont;
	submenu.mn_menu = 0;
	submenu.mn_item = 1;
	submenu.mn_scroll = 1;
	submenu.mn_keystate = 0;
	menu_attach(1, MAINMENU, ME_FONT, &submenu);

	/* Attach size submenu */
	submenu.mn_tree = SIZEMENU;
	menu_attach(1, MAINMENU, ME_SIZE, &submenu);
	
	/* Attach width submenu */
	submenu.mn_tree = WIDTHMENU;
	menu_attach(1, MAINMENU, ME_WIDTH, &submenu);
}