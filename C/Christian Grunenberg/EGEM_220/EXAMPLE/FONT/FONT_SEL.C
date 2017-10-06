
/* FontSelector (PRG/ACC), (c) 1994/95 by C. Grunenberg */

#include <e_gem.h>
#include <stdio.h>
#include <string.h>

void cdecl info(void);

FONTSEL fsel={NULL,NULL,NULL,NULL,0,NORMAL,FS_GADGETS_COLOR|FS_GADGETS_EFFECT|FS_GADGETS_INVERS,FS_FNT_ALL,FAIL,FAIL,
			 {FALSE,TRUE},{TRUE,DIA_LASTPOS,FALSE,TRUE,TRUE,FS_ACT_NONE},NULL,info,0,0,0,BLACK,0,0,0,NULL,-1,-1};

int img[]={
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0xFFFF, 0xFFFE, 
0x8000, 0x0003, 0x807F, 0xC403, 0x801E, 0x2003, 0x801E, 0x2403, 
0x801F, 0xC003, 0x803F, 0x0403, 0x803F, 0x0003, 0x8067, 0x8543, 
0x8067, 0x8003, 0x80CB, 0xC043, 0x80C3, 0xC003, 0x8189, 0xE043, 
0x8181, 0xE003, 0xABFF, 0xF553, 0x83FF, 0xF003, 0x8608, 0x7803, 
0x8600, 0x7803, 0x8C08, 0x3C03, 0xCC00, 0x3CFF, 0xB808, 0x1F47, 
0xBC00, 0x3F4E, 0xFF08, 0xFFDC, 0x8000, 0x0078, 0xFFFF, 0xFFF0, 
0x7FFF, 0xFFE0, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000};

BITBLK blk={img,4,32,0,0,1};
OBJECT icon_tree={-1,-1,-1,G_IMAGE,LASTOB,NORMAL,(long) &blk,0,0,2,1};

char *entry="  FontSelector\0XDSC\0""1Fontselector\0XFontSelect\0",*info_file="font_sel.inf";

void SaveInfo(void)
{
	int	info[8];
	UpdateFsel(FALSE,FALSE);
	memcpy(info,&fsel.id,14);
	info[7] = *(int *) &fsel.options;
	SaveInfoFile(info_file,TRUE,info,16,entry+2,0x0100);
}

void cdecl info(void)
{
	if (xalert(2,2,X_ICN_INFO,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,"Information","Drag&Drop-FontSelector|^>Version "E_GEM_VERSION", "__DATE__"|^|> \xBD""1995 C. Grunenberg"," [Save |[Ok")==0)
		SaveInfo();
}

void Exit(void)
{
	close_all_dialogs();
	if (_app)
		exit_gem(TRUE,0);
}

int Init(XEVENT *ev,int avail)
{
	return((MU_MESAG|MU_KEYBD)&avail);
}

int Event(XEVENT *ev)
{
	int wi=ev->ev_mwich,*msg=ev->ev_mmgpbuf;

	if (wi&MU_MESAG)
		switch (msg[0])
		{
		case FONT_SELECT:
			UpdateFsel(TRUE,FALSE);
			fsel.app = msg[1];
			fsel.win = msg[3];
			if (msg[4]>=0)
				fsel.id = msg[4];
			if (msg[5]>0)
				fsel.size = msg[5];
			if (msg[6]>=WHITE)
				fsel.color = msg[6];
			if (msg[7]>=0)
				fsel.effect = msg[7];
		case AC_OPEN:
			if (FontSelect(FSEL_DRAG,&fsel)==FS_SET)
			{
				WIN *win=FSelDialog->di_win;
				WindowHandler(W_UNICONIFY,win,NULL);
				window_top(win);
			}
			break;
		case AC_CLOSE:
		case AP_TERM:
			Exit();break;
		default:
			wi ^= MU_MESAG;
		}

	if ((wi&MU_KEYBD) && (ev->ev_mmokstate&K_CTRL))
		switch (scan_2_ascii(ev->ev_mkreturn,K_CTRL))
		{
		case 'Q':
			Exit();break;
		case 'S':
			SaveInfo();break;
		default:
			wi ^= MU_KEYBD;
		}
	else
		wi &= ~MU_KEYBD;

	return(wi);
}

void main()
{
	if (init_gem(NULL,entry,entry+2,"FONT_SEL",0,0,0)==TRUE)
	{
		int info[8];

		rsrc_calc(iconified=&icon_tree,NO_SCALING,8,16);

		fsel.id = ibm_font_id;
		fsel.options.action = _app ? FS_ACT_BACK : FS_ACT_CLOSE;
		fsel.options.preview = gr_ch<16 ? FALSE : TRUE;

		if (LoadInfoFile(info_file,TRUE,info,16,16,entry+2,0x0100)>0)
		{
			memcpy(&fsel.id,info,14);
			*(int *) &fsel.options = info[7];
		}

		dial_options(TRUE,TRUE,TRUE,RETURN_DEFAULT,AES_BACK,FALSE,KEY_ALWAYS,TRUE,FALSE,0);
		Event_Handler(Init,Event);

		if (_app)
			FontSelect(FSEL_DRAG,&fsel);
		else
			Event_Multi(NULL);
	}
	exit_gem(TRUE,0);
}
