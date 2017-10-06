
/* PlayIt! (PRG/ACC): (c) 1994/95 C. Grunenberg
 (demonstriert von der Mausposition abh„ngige Objektselektion/Infozeile) */

#include "..\winview\data.h"
#include <time.h>
#include "play_rsc.h"
#include <rsc.h>
#include "play_rsc.c"

#define SIZE	320
#define SWIMIN	64
#define MEM		((((SIZE+15)&(~15))>>3)*SIZE)

void Size(SLINFO*,OBJECT*,int,int,int,int,int);
void Dialog(char*);

DIAINFO *di;
OBJECT *tr;
MFDB image;

char path[MAX_PATH],fi[MAX_PATH],fname[MAX_PATH],info[32],*pl="  PlayIt!",*infotxt[]=
{"","","Neues Spiel","","Bild laden","","Schwierigkeitsgrad","Einfacher","","Anzahl der Vertauschungen","Schwieriger","Raster","Raster kleiner","","Rasterweite","Raster gr”žer","Hilfe anzeigen","Kein Bild geladen"};
int sizes[]={8,16,20,32,40,64,80},orig[MEM>>1],data[MEM>>1],src,dst,size,cnt,last,done,user,color[]={BLACK,WHITE};

SLKEY sz_keys[]={{key(0,'-'),0,SL_UP},{key(0,'+'),0,SL_DOWN}},
cn_keys[]={{key(SCANLEFT,0),0,SL_UP},{key(SCANRIGHT,0),0,SL_DOWN},{key(SCANLEFT,0),K_SHIFT,SL_PG_UP},{key(SCANRIGHT,0),K_SHIFT,SL_PG_DN}};
SLINFO sl_sz={NULL,0,0,SIZEBOX,SIZETXT,24,SIZEDEC,SIZEINC,4,1,7,FAIL,HOR_SLIDER,SL_LINEAR,0,100,Size,&sz_keys[0],2},
sl_cn={NULL,0,0,SWIBOX,SWITXT,24,SWIDEC,SWIINC,40,11,1010-SWIMIN,FAIL,HOR_SLIDER,SL_LOG,0,333,Size,&cn_keys[0],4},*sl_list[]={&sl_sz,&sl_cn,NULL};

char *help=
"_ PlayIt!: |^|"\
"^\xBD""1995 C. Grunenberg, Version "E_GEM_VERSION", "__DATE__"||"\
"New game/Load image:       ALT-N/L|"\
"Smaller/bigger blocksize:  -/+|"\
"Less/more switchs:         (SHIFT-) \x04/\x03:|"\
"Close dialog/Exit program: UNDO/CTRL-Q";

void alert(int ic,char *ti,char *ms)
{
	xalert(1,1,ic,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,ti,ms,NULL);
}

void Size(SLINFO *sl,OBJECT *tr,int po,int pr,int ma,int cr,int pr_cr)
{
	int sli=sl->sl_slider;
	if (sli==SIZETXT)
	{
		po = sizes[po];
		sl_cn.sl_pos = SIZE/po*((SIZE/2)/po)-SWIMIN;
		graf_set_slider(&sl_cn,tr,GRAF_DRAW);
	}
	else
		po += SWIMIN;
	int2str(ob_get_text(tr,sli,0),po,0);
}

int Index(int x,int y)
{
	GRECT rc;
	ob_pos(tr,GRAF,&rc);
	return(rc_inside(x,y,&rc) ? ((y-rc.g_y)/size)*cnt+(x-rc.g_x)/size : -1);
}

void Pos(int i,int *x,int *y,int size)
{
	*x = (i%cnt)*size;
	*y = (i/cnt)*size;
}

void Rect(int i,GRECT *rc)
{
	Pos(i,&rc->g_x,&rc->g_y,size);
	rc->g_x += tr->ob_x+tr[GRAF].ob_x;rc->g_y += tr->ob_y;
	rc->g_w = rc->g_h = size;
}

void Copy(MFDB *s,MFDB *d,int m,int sx,int sy,int dx,int dy)
{
	int pxy[8],sz=size-1;
	pxy[0] = sx;pxy[1] = sy;
	pxy[2] = sx+sz;pxy[3] = sy+sz;
	pxy[4] = dx;pxy[5] = dy;
	pxy[6] = dx+sz;pxy[7] = dy+sz;
	vro_cpyfm(x_handle,m,pxy,s,d);
}

void Select(int new)
{
	if (new!=last)
	{
		int x,y;
		if (last>=0)
		{
			Pos(last,&x,&y,size);
			Copy(&image,&image,D_INVERT,x,y,x,y);
		}
		if (new>=0)
		{
			Pos(new,&x,&y,size);
			Copy(&image,&image,D_INVERT,x,y,x,y);
		}
		ob_draw(di,GRAF);
		last = new;
	}
}

void ObInfo(char *txt,int i)
{
	int x,y;
	Pos(i,&x,&y,1);
	int2str(strlcpy(strend(info),txt),x,1);
	int2str(strlcpy(strend(info),","),y,1);
	strcat(info,")");
}

void MakeInfo(int ob,int s,int d)
{
	if (s>=0)
	{
		int2str(strlcpy(info,"Zug: "),user,0);
		ObInfo(", Block (",s);
		if (d>=0)
			ObInfo(" nach (",d);
		else
			strcat(info,"...");
	}
	else if (ob>=0)
	{
		strcpy(info,infotxt[ob]);
		if (info[0])
			strcat(info,"...");
	}
	else
		info[0] = '\0';
	window_info(di->di_win,info);
}

int ObMouse(DIAINFO *di,OBJECT *tr,int obj,int last_ob,int x,int y,GRECT *rc)
{
	int new = (!done || obj<0) ? -1 : Index(x,y);

	if (new!=last || last_ob!=obj)
	{
		MakeInfo(obj,new,-1);
		if (done)
			Select(new);
	}

	if (new>=0)
	{
		MouseFlatHand();
		Rect(new,rc);
		return(DIALOG_MOVEMENT);
	}
	else
		return(DIALOG_OBJECT);
}

void DragMouse(boolean draw,int *pxy,MKSTATE *mk)
{
	if (draw)
	{
		int new;
		if ((new=Index(mk->mx,mk->my))!=dst && new>=0)
			MakeInfo(GRAF,src,dst=new);
		Rect(dst,(GRECT *) pxy);
	}
}

void Switch(int im1,int im2)
{
	MFDB buffer;
	int data[512],sx,sy,dx,dy;

	mfdb(&buffer,data,size,size,1,1);
	Pos(im1,&sx,&sy,size);
	Pos(im2,&dx,&dy,size);
	Copy(&image,&buffer,S_ONLY,sx,sy,0,0);
	Copy(&image,&image,S_ONLY,dx,dy,sx,sy);
	Copy(&buffer,&image,S_ONLY,0,0,dx,dy);
	if (last==im1)
		last = im2;
	else if (last==im2)
		last = im1;
}

void New(int sw)
{
	int i,j;

	last = -1;
	user = 1;
	size = sizes[sl_sz.sl_pos];
	cnt = SIZE/size;

	memcpy(data,orig,MEM);
	MouseUpdate(TRUE);
	ob_draw(di,GRAF);
	if ((done=sw)!=0)
	{
		srand((unsigned) clock());
		for (j=cnt*cnt,i=sl_cn.sl_pos+SWIMIN;--i>=0 || (mouse(NULL,NULL)&1);)
		{
			Switch(rand()%j,rand()%j);
			if ((i&(size>20 ? 3 : 7))==0)
			{
				ob_draw(di,GRAF);
				graf_busy_mouse();
			}
		}
		ob_draw(di,GRAF);
	}
	dialog_mouse(di,ObMouse);
	MouseUpdate(FALSE);
}

void Exit(void)
{
	close_all_dialogs();
	di = NULL;
	if (_app)
		exit_gem(TRUE,0);
}

int Init(XEVENT *e,int avail)
{
	return((MU_MESAG|MU_KEYBD)&avail);
}

int Event(XEVENT *ev)
{
	int wi=ev->ev_mwich,sc=ev->ev_mkreturn,st=ev->ev_mmokstate;
	if (wi&MU_MESAG)
		switch(ev->ev_mmgpbuf[0])
		{
		case AC_OPEN:
			Dialog(NULL);break;
		case AC_CLOSE:
		case AP_TERM:
			Exit();break;
		default:
			wi ^= MU_MESAG;
		}
	if ((wi&MU_KEYBD) && ((sc>>8)==SCANUNDO || ((st&K_CTRL) && scan_2_ascii(sc,st)=='Q')))
		Exit();
	else
		wi &= ~MU_KEYBD;
	return(wi);
}

#include "..\winview\decode.c"

void Load(char *fi)
{
	MFDB img;
	int wi,hei,i,pxy[8];
	char buffer[256],info[256];
	IMG *hdr;
	byte *sta,*buf=NULL,*mem=NULL;
	long hd,len;

	if ((hd=Fopen(fi,0))>0 && Fread((int) hd,256,buffer)>0)
	{
		window_info(di->di_win,strcat(strcat(strcpy(info,"Lade und entpacke "),GetFilename(fi)),"..."));

		len = Fseek(0l,(int) hd,SEEK_END);
		Fseek(0l,(int) hd,SEEK_SET);
		hdr = (IMG *) buffer;
		i = hdr->headlength;
		mfdb(&img,NULL,wi=hdr->width,hei=hdr->height,1,1);

		if (len>sizeof(IMG) && i>=8 && hdr->nplanes==1 && hdr->version>=0 && wi>=80 && hei>=80 && (len>>1)>i &&
			(buf=malloc(len))!=NULL && (mem=malloc(mfdb_size(&img)+1024))!=NULL && Fread((int) hd,len,buf)==len)
		{
			XEVENT ev;
			int ox=-1,oy=-1,w=min(SIZE,wi)-1,h=min(SIZE,hei)-1;

			sta = (byte *) &buf[hdr->headlength<<1];
			decode_img(sta,sta+len,(byte *) (img.fd_addr=mem),wi,hei,img.fd_wdwidth<<1,hdr->patlen);

			beg_ctrl(FALSE,FALSE,TRUE);
			Event_Handler(0l,0l);
			MouseOutlineCross();
			window_info(di->di_win,"Ausschnitt ausw„hlen...");

			ev.ev_mflags = MU_M1|MU_BUTTON1;
			mouse(&ev.ev_mm1x,&ev.ev_mm1y);
			ev.ev_mm1flags = ev.ev_mm1width = ev.ev_mm1height = ev.ev_mb1mask = ev.ev_mb1state = ev.ev_mb1clicks = 1;
			*(long *) &ev.ev_mmox = *(long *) &ev.ev_mm1x;

			pxy[0] = pxy[1] = 0;
			pxy[4] = (SIZE-1-(pxy[6]=w))>>1;
			pxy[5] = (SIZE-1-(pxy[7]=h))>>1;

			do
			{
				pxy[2] = (pxy[0]=max(min(pxy[0]+(ev.ev_mmox-ev.ev_mm1x)*2,wi-SIZE),0))+w;
				pxy[3] = (pxy[1]=max(min(pxy[1]+(ev.ev_mmoy-ev.ev_mm1y)*2,hei-SIZE),0))+h;
				if (pxy[0]!=ox || pxy[1]!=oy)
				{
					memset(data,0x5555,MEM);
					vro_cpyfm(x_handle,S_ONLY,pxy,&img,&image);
					ob_draw(di,GRAF);
					ox = pxy[0];oy = pxy[1];
				}
				*(long *) &ev.ev_mm1x = *(long *) &ev.ev_mmox;
			} while ((wi>SIZE || hei>SIZE) && (Event_Multi(&ev)&MU_BUTTON1)==0);

			Event_Handler(Init,Event);
			end_ctrl(FALSE,TRUE);
			memcpy(orig,data,MEM);
			ob_disable(di,tr,NEW,FALSE,TRUE);
			infotxt[GRAF] = "Kein Spiel";
			New(FALSE);
		}
		else
			alert(X_ICN_DISC_ERR,NULL,"Couldn't read file!|(only monochrome images|bigger than 80x80 pixel)");
		if (mem)
			free(mem);
		if (buf)
			free(buf);
		Fclose((int) hd);
	}
}

void Dialog(char *file)
{
	GRECT drag,bound;
	int x,y;

	if (di)
		window_top(di->di_win);
	else if ((di=open_dialog(tr,pl+2,NULL,NULL,DIA_LASTPOS,FALSE,WIN_DIAL|WD_INFO|SMALL_FRAME,0,sl_list,NULL))!=NULL)
	{
		window_info(di->di_win,info);
		dialog_mouse(di,ObMouse);

		if (file)
		{
			Event_Timer(0,0,TRUE);
			Load(file);
		}

		while ((x=XFormObject(NULL,NULL))>=0)
		{
			ob_select(di,tr,x,FALSE,TRUE);
			switch (x)
			{
			case HELP:
				alert(X_ICN_INFO,NULL,help);break;
			case LOAD:
				if (FileSelect(infotxt[LOAD],path,fi,"*.img",FALSE,0,NULL)>0)
					Load(MakeFullpath(fname,path,fi));
				break;
			case NEW:
				New(TRUE);break;
			case GRAF:
				if (done && mouse(&x,&y))
				{
					dst = -1;
					Rect(src=Index(x,y),&drag);
					ob_pos(tr,GRAF,&bound);
					graf_rt_dragbox(FALSE,&drag,&bound,&x,&y,DragMouse);
					if (dst>=0 && src!=dst)
					{
						Switch(src,dst);
						user++;
						ob_draw(di,GRAF);
					}
				}
			}
		}
		Exit();
	}
}

int cdecl Draw(PARMBLK *pb)
{
	GRECT work=*(GRECT *) &pb->pb_x;
	int pxy[8];
	if (rc_intersect((GRECT *) &pb->pb_xc,&work))
	{
		rc_grect_to_array(&work,&pxy[4]);
		work.g_x -= pb->pb_x;work.g_y -= pb->pb_y;
		rc_grect_to_array(&work,pxy);
		vrt_cpyfm(x_handle,MD_REPLACE,pxy,&image,screen,color);
	}
	return(0);
}

USERBLK drawblk={Draw,0l};

void main(int argc,char *argv[])
{
	if (init_gem(NULL,pl,pl+2,"PLAY_IT",0,0,0)==TRUE)
	{
		rsrc_init(NUM_TREE,NUM_OBS,NUM_FRSTR,NUM_FRIMG,STATIC_SCALING,rs_strings,rs_frstr,rs_bitblk,
				  rs_frimg,rs_iconblk,rs_tedinfo,rs_object,(OBJECT **) rs_trindex,(RS_IMDOPE *) rs_imdope,8,16);
		tr = (OBJECT *) rs_trindex[TREE];
		iconified = (OBJECT *) rs_trindex[ICON];
		tr[GRAF].ob_type = G_USERDEF;
		tr[GRAF].ob_spec.userblk = &drawblk;

		mfdb(&image,data,SIZE,SIZE,1,1);
		Event_Handler(Init,Event);

		if (_app)
			Dialog(argc>1 ? argv[1] : "play_it.img");
		Event_Multi(NULL);
	}
	exit(-1);
}
