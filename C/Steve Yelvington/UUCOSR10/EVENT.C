#include <stdio.h>
#include <obdefs.h>
#include <gemdefs.h>
#include "keycodes.h"

#include "uucoder.h" 

extern OBJECT *menubar;

#ifndef PATHSIZ
#define PATHSIZ	128
#endif

#define ding()	putch(0x07)

char filename[PATHSIZ];

extern int split;
extern int fileln;

/*
 * function: sho_dialog(index)
 * returns:  index of object used to exit a form
 * description: Find an object in the resource tree based on index.
 *         Center it, draw it, interact with it, clean up, return. 
 */

int sho_dialog(index)
	int index;
	{
	OBJECT *tree;
	int x,y,w,h,ret;
	rsrc_gaddr(R_TREE,index,&tree);
	form_center(tree, &x, &y, &w, &h);
	form_dial(FMD_START,1,1,1,1,x,y,w,h);
	form_dial(FMD_GROW,1,1,1,1,x,y,w,h);
	objc_draw(tree, 0, 20, x, y, w, h);
	ret = form_do(tree,-1);
	form_dial(FMD_SHRINK,1,1,1,1,x,y,w,h);
	form_dial(FMD_FINISH,1,1,1,1,x,y,w,h);
	tree[ret].ob_state = NORMAL;
	return ret;
	}



/*
 * function: disp_process
 * returns:  nothing 
 * description: Draw a progress report box on the screen. The companion
 *              routine erase_process() does the cleanup.
 *
 */

void disp_process(filename)
	char *filename;
	{
	int x,y,w,h,ret;
	OBJECT *tree;
	char *p;
	rsrc_gaddr(R_TREE,PROCESS,&tree);
	/* find the base filename and copy it into the TEDINFO */
	for (p = filename + strlen(filename);p > filename;p--)
		{
		if (*p == ':') break;
		if (*p == '\\') break;
		}
	p++;
	strcpy(((TEDINFO *)tree[WORKFILE].ob_spec)->te_ptext,p);
	form_center(tree, &x, &y, &w, &h);
	form_dial(FMD_START,1,1,1,1,x,y,w,h);
	form_dial(FMD_GROW,1,1,1,1,x,y,w,h);
	objc_draw(tree, 0, 20, x, y, w, h);
	}

/*
 * function: erase_process
 * returns:  void
 * description: Erase the process report from the screen.
 *
 */
void erase_process()
	{
	int x,y,w,h;
	OBJECT *tree;
	rsrc_gaddr(R_TREE,PROCESS,&tree);
	form_center(tree, &x, &y, &w, &h);
	form_dial(FMD_SHRINK,1,1,1,1,x,y,w,h);
	form_dial(FMD_FINISH,1,1,1,1,x,y,w,h);
	}


/*
 * function: evalmessage()
 * returns:  void
 * description: handles AES message events; this is a separate function
 *              to avoid cluttering up main_event.
 *
 */

void evalmessage(msg_buf)
	WORD msg_buf[];
	{
	register int i;
	if (msg_buf[0] != MN_SELECTED)
		{
		ding();
		return();
		}
	menu_tnormal(menubar,msg_buf[3],TRUE);
	menu_tnormal(menubar,msg_buf[4],TRUE);
	switch(msg_buf[4])
		{
		case ABOUT:
			show_about();
			break;
		case DECODE:
			if (fsel("UUDecode a file","*.U??","",filename))
				{
				decode(filename);
				erase_process();
				}
			break;
		case ENCODE:
			if (fsel("UUEncode a file","*.*","",filename))
				{
				encode(filename);
				erase_process();
				}
			break;
		case CODEHELP:
			sho_dialog(HELPCODE,-1);	
			break;
		case CFGHELP:
			sho_dialog(HELPCFG,-1);	
			break;
		case QUIT:
			quit();
			break;
		case MAX5K:
		case MAX10K:
		case MAX32K:
		case MAX60K:
		case MAX100K:
			split = TRUE;
			for (i=MAX5K; i<=MAX100K;i++)
				menu_ichek(menubar,i,FALSE);
			menu_ichek(menubar,msg_buf[4],TRUE);
			switch(msg_buf[4])
				{
				case MAX5K:
					/* 62 char per line */
					fileln = 5*(1024/62);
					break;
				case MAX10K:
					fileln = 10*(1024/62);
					break;
				case MAX32K:
					fileln = 32*(1024/62);
					break;
				case MAX60K:
					fileln = 60*(1024/62);
					break;
				case MAX100K:
					fileln = 100*(1024/62);
					break;
				default:
					break;
				}
			break;
		default:
			break;
		}
	}


/*
 * function: evalkeybd(keycode)
 * returns:  void
 * description: handle an AES keyboard event
 *
 */

void evalkeybd(keycode)
	unsigned int keycode;
	{
	switch (keycode)
		{
		case ALT_D:
			if (fsel("UUDecode a file","*.U??","",filename))
				{
				decode(filename);
				erase_process();
				}
			break;
		case ALT_E:
			if (fsel("UUEncode a file","*.*","",filename))
				{
				encode(filename);
				erase_process();
				}
			break;
		case ALT_H:
		case KEY_HELP:
			sho_dialog(HELPCODE,-1);	
			break;
		case ALT_X:
		case ALT_Q:
			quit();
		default:
			ding();
			break;
		}
	}



/*
 * function: main_event
 * returns:  void
 * description: the primary event loop for the application
 *
 */

void main_event()
	{
	WORD	mevx,mevy,butstate,mevbut,keystate,keycode,mbreturn,
		msg_buf[8],event;
	butstate=1;
	for(;;)	/* forever */
		{
		/* the event loop */
		filename[0] = '\0';
		event = evnt_multi(MU_KEYBD|MU_MESAG,
			0,
			0,
			butstate,
			0,
			0,0,0,0,
			0,
			0,0,0,0,
			msg_buf,
			0,0,
			&mevx,&mevy,
			&mevbut,
			&keystate,
			&keycode,
			&mbreturn);

		switch (event)
			{
			case MU_MESAG:
				evalmessage(msg_buf);
				break;
			case MU_KEYBD:
				evalkeybd(keycode);
				break;
			default:
				ding();
				break; /* do nothing */
			}
		} 
	}

