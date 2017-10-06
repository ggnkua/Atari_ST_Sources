#define ___MAIN_C___

#include <tos.h>
#include "glo.h"
#include "tokstr.h"
#include "xcontrol.h"

/********************************************************************/
#define MESSAGE -1
#define DTR		(1<<4)

/********************************************************************/
EXTERN VOID _FreeAll		( VOID								);
GLOBAL CPX_INFO *CDECL cpx_init( XCPB *Xcpb						);
GLOBAL WORD CDECL cpx_call 	( GRECT *work						);
GLOBAL VOID CDECL cpx_draw 	( GRECT *clip						);
GLOBAL VOID CDECL cpx_wmove	( GRECT *work						);
GLOBAL VOID CDECL cpx_timer	( WORD *evnt						);
GLOBAL VOID CDECL cpx_key	( WORD kstate, WORD key, WORD *evnt );
GLOBAL VOID CDECL cpx_close	( WORD flag							);
GLOBAL VOID CDECL cpx_button(MRETS *mrets,WORD nclicks,WORD *event);
GLOBAL VOID CDECL cpx_mouse1(MRETS *mrets,WORD *event);
GLOBAL VOID CDECL cpx_mouse2(MRETS *mrets,WORD *event);
GLOBAL VOID do_draw(void);

/********************************************************************/
extern  int interactive;
extern	char charscreen[22][32];

LOCAL	XCPB	*cpx;
GLOBAL	MFDB	ScreenMFDB;
GLOBAL	WORD	errno;
GLOBAL	WORD	pxy[10];
work_in[12],
work_out[57],
vdihandle,
phys_vdihandle;

static mask=MU_KEYBD|MU_TIMER|MU_M2;
static MOBLK m1={1,0,0,8,176};
/* ACHTUNG: die x,y,w,h-Komponenten von m2 und xywh sind identisch! */
extern MOBLK m2;
extern	GRECT	xywh;

LOCAL CPX_INFO cpxinfo =
{	
		cpx_call,
	    cpx_draw,
	    cpx_wmove,
	    cpx_timer,
	    cpx_key,
	    cpx_button,
	    cpx_mouse1,
	    cpx_mouse2,
	    NULL,
	    cpx_close
};

GLOBAL char *cpx_buffer;	/* residenter CPX-Buffer */
/********************************************************************/
GLOBAL CPX_INFO *CDECL cpx_init( XCPB *Xcpb )
{
#ifdef TT_VERS
	long cpu,fpu;
	int erg;
#endif
	if(Xcpb!=NULL) cpx=Xcpb;

#ifdef TT_VERS
/* Ich hoffe einfach mal, daž hier kein TT-Code erzeugt wird */
	erg=cpx->getcookie('_CPU',&cpu);
	erg|=cpx->getcookie('_FPU',&fpu);
	if(erg||cpu<20||!(fpu&0x000EFFFFL))
	{
		form_alert(1,"[3][ Auf diesem Rechner ist die n”tige|"
					   " CPU oder FPU nicht vorhanden!][ BYE ]");
		return 0;
	}
#endif

	cpx_buffer=cpx->Get_Buffer();
	if(cpx->booting)
	{
		*cpx_buffer=0xBC;
		cpx_buffer[1]=Dgetdrv();
		Dgetpath(cpx_buffer+2,0);
	}
	Ongibit(DTR);

	return &cpxinfo;
}

static void SetMask(GRECT *grect)
{
	m1.m_x=grect->g_x;
	m1.m_y=xywh.g_y;
	(cpx->Set_Evnt_Mask)(mask,&m1,&m2,20);
}

GLOBAL WORD CDECL cpx_call( GRECT *work )
{
	int i,*wk=work_in;
	
	ScreenMFDB.fd_addr=NULL;

	*wk++=vdihandle=phys_vdihandle=cpx->handle;
	for(i=9;i>0;i--) *wk++=0;
	*wk=2;
	v_opnvwk( work_in, &vdihandle, work_out);	/* Bildschirm ”ffnen! */
	if(vdihandle==0)
	{	
		form_alert(1,"[3][Das VDI will kein CPX-BASIC ...][ Tja ]");
		return FALSE;
	}

	xywh.g_x=work->g_x;
	xywh.g_y=work->g_y;

	StartBASIC();

	do_draw();

	SetMask(work);
	return TRUE;
}

GLOBAL VOID CDECL cpx_draw( GRECT *clip )
{
	static GRECT *cp, cl;
	static WORD color_index[2]={
		BLACK,WHITE	};

	v_hide_c(vdihandle);
	cl=*clip;
	cp=(cpx->GetFirstRect)(&cl);
	while( cp!=NULL )
	{
		cl=*cp;
		pxy[0]=cl.g_x - xywh.g_x;
		pxy[1]=cl.g_y - xywh.g_y;
		pxy[2]=cl.g_w + pxy[0] - 1;
		pxy[3]=cl.g_h + pxy[1] - 1;

		pxy[4]=cl.g_x;
		pxy[5]=cl.g_y;
		pxy[6]=cl.g_x + cl.g_w - 1;
		pxy[7]=cl.g_y + cl.g_h - 1;

		vrt_cpyfm(vdihandle, MD_REPLACE, pxy, &cpx_mfdb, &ScreenMFDB, color_index);

		cp=(cpx->GetNextRect)();
	}
	v_show_c(vdihandle,1);
	DirtyScreen=FALSE;
}

GLOBAL VOID do_draw(void)
{
	cpx_draw(&xywh);
}

GLOBAL VOID CDECL cpx_wmove( GRECT *work )
{
	xywh.g_x=work->g_x;
	xywh.g_y=work->g_y;
}

GLOBAL VOID CDECL cpx_timer( WORD *evnt )
{	
	extern int fptime;
	extern void DATAfclose(int);
	if(fptime>0)
	{
		fptime--;
		DATAfclose(0);
	}
	if(DirtyScreen)		/* Bild muss neu gezeichnet werden	*/
	{	
		do_draw();
	}
	if(ContBASIC()=='STOP')		/* Das BASIC ausfhren ...	*/
	{	
		cpx_close(0);
		*evnt=1;
	}
}


LOCAL void DoString(char *str)
{
	while(*str)
	{
		KeyBuffer[woff++]=*str++;
		if(woff>=KB_SIZE) woff=0;
	}
}

enum {string,fselbas,fseltxt,space,nothing};

LOCAL char *extensions[]=
{
	" '",
	" FSEL$ '*.BAS'",
	" FSEL$ '*.TXT'",
	" ",
	""
};

LOCAL void CopyKey(int what,int extra)
{
	DoString(tok_strings[what]);
	DoString(extensions[extra]);
}

#pragma warn -par
GLOBAL VOID CDECL cpx_key( WORD kstate, WORD key, WORD *evnt )
{
	extern char ctrl;
	int i,x;
	char **str,*s;
	
	if(key==0x6200)
	{
		/* Help */
		Putchar('\n');
		str=tok_strings;
		x=0;
		for(i=0;i<NUM_TOKS;i++,str++)
		{
#define ENDM 32
			s=*str;
			if(x+(int)strlen(s)>=ENDM)
			{
				if(x<ENDM) Putchar('\n');
				x=0;
			}
			x+=Printf("%s ",s);
		}
		key='\r';
	}
	if(kstate&4) /* ctrl pressed */
	{
		kstate&=3; /* shift - Tasten */
		key&=0xff00;
		if(!kstate&&key==0x2e00)
		{
			/* Ctrl-C */
			/* CTRL-C und CTRL-Q flag setzen */
			*((int*)&ctrl)=-1;
			return;
		}
		if(interactive)
		{
			x=space;
			switch(key)
			{
				case 0x3000:
					/* Ctrl-B */
					i=tokgosub;
					break;
				case 0x2e00:
					/* Ctrl-C mit Shift */
					i=tokcont;
					x=nothing;
					break;
				case 0x2000:
					/* Ctrl-D */
					i=tokdata;
					break;
				case 0x1200:
					/* Ctrl-E */
					i=tokrun;
					x=kstate?fselbas:string;
					break;
				case 0x2100:
					/* Ctrl-F */
					i=tokfor;
					if(kstate)
					{
						i=tokfopen;
						x=fseltxt;
					}
					break;
				case 0x2200:
					/* Ctrl-G */
					i=tokgoto;
					break;
				case 0x1700:
					/* Ctrl-I */
					i=tokif;
					break;
				case 0x2600:
					/* Ctrl-L */
					i=toklist;
					break;
				case 0x3200:
					/* Ctrl-M */
					i=tokmerge;
					x=kstate?fselbas:string;
					break;
				case 0x3100:
					/* Ctrl-N */
					i=toknext;
					break;
				case 0x1800:
					/* Ctrl-O */
					i=tokload;
					x=kstate?fselbas:string;
					break;
				case 0x1000:
					/* Ctrl-Q */
					i=tokbye;
					x=nothing;
					break;
				case 0x1300:
					/* Ctrl-R */
					i=tokreturn;
					x=nothing;
					break;
				case 0x1f00:
					/* Ctrl-S */
					i=toksave;
					x=kstate?fselbas:string;
					break;
				case 0x1400:
					/* Ctrl-T */
					i=tokthen;
					break;
			}
			CopyKey(i,x);
		}
		else /* not interactive */
		{
			switch(key)
			{
				case 0x1f00:
					/* Ctrl-S */
					ctrlsq=0;
					return;
				case 0x1000:
					/* Ctrl-Q */
					ctrlsq=-1;
					return;
			}
		}
	}
	else /* ctrl not pressed */
	{
		KeyBuffer[woff++]=key;
		if(woff>=KB_SIZE) woff=0;
	}
}

GLOBAL VOID CDECL cpx_close( WORD flag )
{
	extern void DATAfclose(int);
	DATAfclose(1);
	_FreeAll();
	v_clsvwk( vdihandle );
}


#pragma warn -par
GLOBAL VOID CDECL cpx_mouse2(MRETS *mrets,WORD *event)
{
	mask=MU_KEYBD|MU_TIMER|MU_M2;
	if(m2.m_out==0)
	{
		mask|=MU_M1;
		m2.m_out=1;
	}
	else
	{
		m2.m_out=0;
	}
	SetMask(&xywh);
}

static int buttons,cury;

GLOBAL VOID CDECL cpx_mouse1(MRETS *mrets,WORD *event)
{
	int curx=(mrets->x-xywh.g_x)>>3,ch;
	
	if(buttons&&(buttons=mrets->buttons)!=0)
	{
		if(curx>=0&&curx<=31&&cury>=0&&cury<=21)
		{
			if((ch=charscreen[cury][curx])!=0)
			{
				KeyBuffer[woff++]=ch;
				if(woff>=KB_SIZE) woff=0;
			}
			cpx_timer(event);
		}
	}
	mrets->x=(curx<<3)+xywh.g_x;
	SetMask((GRECT*)&mrets->x);
}

GLOBAL VOID CDECL cpx_button(MRETS *mrets,WORD nclicks,WORD *event)
{
	if(buttons==0)
	{
		buttons=1;
		cury=(mrets->y-xywh.g_y)>>3;
		cpx_mouse1(mrets,event);
	}
	if(nclicks>1)
	{
		KeyBuffer[woff++]='\r';
		if(woff>=KB_SIZE) woff=0;
	}
}

#pragma warn +par
