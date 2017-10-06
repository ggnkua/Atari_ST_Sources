
#include "proto.h"
#include <string.h>
#include <time.h>

#ifndef SMALL_NO_XACC_AV

#define ACC_TEXT_WAIT	1000
#define ACC_IMG_WAIT	3000
#define ACC_META_WAIT	3000
#define VA_START_WAIT	2000

int AvServer=-1,Server=-1,_xacc_msgs;
static char *XAccName,*AVName,a_name[9];
static int av_msgs,va_msgs,multi_xacc=FALSE;
static XAcc Xaccs[MAX_XACCS];

static void	store_xacc_id(int*);
static void	store_av_id(int*,int,int);
static void	kill_id(int);

static void	XAccSendId(int);
static void	XAccSendAcc(int);

static int XAccSend(int sendto,int msg0,int msg3,char *msg4,int msg6,int msg7)
{
	if (sendto>=0 && sendto!=ap_id)
	{
		int msg[8];

		msg[0] = msg0;
		msg[1] = ap_id;
		msg[2] = 0;
		msg[3] = msg3;
		*(char **) &msg[4] = msg4;
		msg[6] = msg6;
		msg[7] = msg7;

		if (appl_write(sendto, 16, msg)>0)
			return (TRUE);
		else
			kill_id(sendto);
	}
	return (FALSE);
}

int XAccSendAck(int sendto, int answer)
{
	return (XAccSend(sendto,ACC_ACK,(answer) ? 1 : 0,NULL,0,0));
}

int XAccSendText(int sendto, char *text)
{
	if (XAccSend(sendto, ACC_TEXT, 0, text, 0, 0)==TRUE)
		return (_Wait(sendto,ACC_TEXT_WAIT,XACC_WAIT,NULL));
	return (FALSE);
}

int XAccSendKey(int sendto, int scan, int state)
{
	if (XAccSend(sendto, ACC_KEY, scan, (char *) (((long) state)<<16), 0, 0)==TRUE)
		return (TRUE);
	return (FALSE);
}

int XAccSendMeta(int sendto, int last, char *data, long len)
{
	if (XAccSend(sendto, ACC_META, (last) ? 1: 0, data, (int) (len>>16), (int) len)==TRUE)
		return (_Wait(sendto,ACC_META_WAIT,XACC_WAIT,NULL));
	return (FALSE);
}

int XAccSendImg(int sendto, int last, char *data, long len)
{
	if (XAccSend(sendto, ACC_IMG, (last) ? 1: 0, data, (int) (len>>16), (int) len)==TRUE)
		return (_Wait(sendto,ACC_IMG_WAIT,XACC_WAIT,NULL));
	return (FALSE);
}

static void XAccSendId(int sendto)
{
	XAccSend(sendto, ACC_ID, (XACCVERSION<<8)|XACC_LEVEL, XAccName, menu_id, 0);
}

static void XAccSendAcc(int sendto)
{
	XAccSend(sendto, ACC_ACC, (XACCVERSION<<8)|XACC_LEVEL, XAccName, menu_id, ap_id);
}

void _XAccAvExit(void)
{
	reg XAcc *xacc;
	reg int i;
	int msg[8];

	if (multi_xacc)
	{
		msg[3] = ap_id;

		for (i=0,xacc=Xaccs;i<MAX_XACCS;xacc++,i++)
			if (xacc->id!=ap_id)
			{
				if (multi && (xacc->flag & AV))
					AvSendMsg(xacc->id,AV_EXIT,msg);
				if (xacc->flag & XACC)
					AvSendMsg(xacc->id,ACC_EXIT,msg);
			}
	}
}

static void XAccInformAcc(int *msg)
{
	reg XAcc *xacc;
	reg char *name = *((char **) &msg[4]);
	reg int i;

	for (i=0,xacc=Xaccs;i<MAX_XACCS;xacc++,i++)
		if ((xacc->flag & XACC) && xacc->id!=ap_id)
			XAccSend(xacc->id,ACC_ACC,msg[3],name,msg[6],msg[1]);
}

void XAccBroadCast(int *msg)
{
	int info,dummy;

	if (aes_version>=0x0400 || (appl_xgetinfo(10,&info,&dummy,&dummy,&dummy) && (info & 0xff)>=7))
	{
		msg[1] = ap_id;
		msg[2] = 0;
		shel_write(7,0,0,(char *) msg,NULL);
	}
	else if (search)
	{
		char name[9];
		int next,type,id;

		next = 0;
		name[0] = '\0';
		while (appl_search(next, name, &type, &id))
		{
			if (id!=ap_id && (type & 0x06))
				AvSendMsg(id,msg[0],msg);
			next = 1;
		}
	}
	else
	{
		reg XAcc *xacc;
		reg int i,main_app=FALSE;

		for (i=0,xacc=Xaccs;i<MAX_XACCS;xacc++,i++)
			if (xacc->id>=0 && xacc->id!=ap_id)
			{
				if (xacc->id==0)
					main_app = TRUE;
				AvSendMsg(xacc->id,msg[0],msg);
			}

		if (!main_app && !multi && !_app)
			AvSendMsg(0,msg[0],msg);
	}
}

static void AvProtocol(int id)
{
	int msg[8];

	if (id!=ap_id)
	{
		msg[3] = av_msgs;
		msg[4] = msg[5] = 0;
		*(const char **) &msg[6] = AVName;
		AvSendMsg(id,AV_PROTOKOLL,msg);
	}
}

int VaStart(int sendto,char *args)
{
	int msg[8];

	*(char **) &msg[3] = args;
	if (AvSendMsg(sendto,VA_START,msg))
		return (_Wait(sendto,VA_START_WAIT,AV_WAIT,args));
	else
		return (FALSE);
}

void _MultiAv(void)
{
	if (Server<0)
	{
		char shell[9];
		int type,id;

		shell[0] = '\0';
		id = AppLoaded(getenv("AVSERVER"));
		if (id<0)
			id = AppLoaded("AVSERVER");
		if (id<0)
			id = AppLoaded("GEMINI");
		if (id>=0)
			AvServer = id;
		else if (search && !appl_search(2,shell,&type,&id))
			id = -1;
		if (id>=0)
			AvProtocol(Server=id);
	}
}

static void XAccSendAccClose(void)
{
	int i;
	memset(&Xaccs[1],0,sizeof(XAcc)*(MAX_XACCS-1));
	for (i=MAX_XACCS;--i>0;)
		Xaccs[i].id = -1;
	AvServer = -1;
	XAccSendId(Server=0);
	AvProtocol(0);
}

void _XAccSendStartup(char *xacc_name, char *av_name, int Avmsgs,int Vamsgs, int xacc_msgs)
{
	reg XAcc *app;
	reg char name[9], *buf, *p;
	int xacc_size,av_size;
	int i,next,type,id;

	for (i=MAX_XACCS;--i>=0;)
		Xaccs[i].id = -1;

	app = &Xaccs[0];
	app->id = ap_id;
	app->flag = XACC|AV;
	app->version = (XACCVERSION<<8)|XACC_LEVEL;
	app->menu_id = menu_id;
	app->xname = XAccName = p = xacc_name;
	app->xdsc = NULL;

	while (*p++);
	if (!stricmp(p,"XDSC") && p[5]!='\0')
	{
		app->xdsc = p+5;
		do
		{
			while (*p++);
		} while (*p++);
	}

	xacc_size = (int) (p - xacc_name);

	strcpy(a_name,"        ");
	AVName = memcpy(a_name,av_name,min((int) strlen(av_name),8));
	av_size = 8+1;

#ifndef SMALL_NO_DD
	av_msgs = Avmsgs|MSG_START|MSG_AVSTARTED|MSG_AVQUOTE;
	va_msgs = Vamsgs|MSG_EXIT|MSG_SENDKEY|MSG_ACCWINDOPEN|MSG_PATH_UPDATE|MSG_OPENWIND|MSG_XWIND|MSG_VASTARTED|MSG_VAQUOTE;
#else
	av_msgs = Avmsgs|MSG_AVQUOTE;
	va_msgs = Vamsgs|MSG_EXIT|MSG_SENDKEY|MSG_ACCWINDOPEN|MSG_PATH_UPDATE|MSG_VAQUOTE;
#endif

	strcpy(app->name,AVName);
	app->av_msgs = av_msgs;
	app->va_msgs = va_msgs;
	_xacc_msgs = xacc_msgs;

	if (protect && (buf=Mxalloc(xacc_size+av_size,0x0023))!=NULL)
	{
		XAccName = memcpy(buf,XAccName,xacc_size);
		buf += xacc_size;
		AVName = memcpy(buf,AVName,av_size);
	}

	_inform(XACC_AV_CLOSE);

	if (search)
	{
		multi_xacc = TRUE;

		next = 0;
		name[0] = '\0';
		while (appl_search(next,name,&type,&id))
		{
			if (id!=ap_id && (type & 0x06))
				XAccSendId(id);
			next = 1;
		}
	}

	if (multi)
		_MultiAv();
	else if (!_app)
		XAccSendAccClose();
}

int _XAccComm(int *msg)
{
	reg int id = msg[1];

	switch (msg[0])
	{
	case AC_CLOSE:
		if (!_app && !multi)
		{
			XAccSendAccClose();
			_inform(XACC_AV_CLOSE);
		}
		return (FALSE);
	case CH_EXIT:
		kill_id(msg[3]);
		return (FALSE);	
	case ACC_ACC:
		if (multi_xacc)
		{
			if (msg[7]<=0 || id==msg[7])
				store_xacc_id(msg);
		}
		else if (!_app)
		{
			msg[1] = msg[7];
			XAccSendId(msg[1]);
			store_xacc_id(msg);
		}
		break;
	case ACC_ID:
		if (multi_xacc)
			XAccSendAcc(id);
		else if (_app)
		{
			XAccInformAcc(msg);
			XAccSendId(id);
		}
		store_xacc_id(msg);
		break;
	case AV_EXIT:
		kill_id(msg[3]);break;
	case ACC_EXIT:
		kill_id(id);break;
	case AV_PROTOKOLL:
		if (id!=AvServer && id!=Server && id!=ap_id)
		{
			int mbuf[8];
			mbuf[3] = va_msgs;
			mbuf[4] = mbuf[5] = 0;
			*(const char **) &mbuf[6] = AVName;
			AvSendMsg(id,VA_PROTOSTATUS,mbuf);
		}
		store_av_id(msg,msg[3],FAIL);
		break;
	case VA_PROTOSTATUS:
		store_av_id(msg,FAIL,msg[3]);break;
	default:
		return (FALSE);
	}
	return (TRUE);
}

static void store_av_id(int *msg,int av_msgs,int va_msgs)
{
	reg XAcc *xacc=Xaccs;
	reg int id=msg[1],i;

	if (id==ap_id || id<0)
		return;

	for (i=0;i<MAX_XACCS && xacc->id>=0;xacc++,i++)
		if (xacc->id==id)
			break;

	if (i<MAX_XACCS)
	{
		xacc->flag |= AV;
		xacc->id = id;

		strncpy(xacc->name,*((char **) &msg[6]),8);

		if (av_msgs!=FAIL)
			xacc->av_msgs = av_msgs;
		if (va_msgs!=FAIL)
			xacc->va_msgs = va_msgs;

		if (id==Server)
		{
			AvServer = id;
			_AvAllWins();
		}

		_send_msg(xacc,id,XACC_AV_INIT,0,0);
	}
}

static void store_xacc_id(int *msg)
{
	reg XAcc *xacc;
	reg int id=msg[1],i;
	reg char *p,*xdsc,*name;
	reg long size;

	if (id==ap_id || id<0)
		return;

	for (i=0,xacc=Xaccs;i<MAX_XACCS && xacc->id>=0;xacc++,i++)
		if (xacc->id==id)
			break;

	if (i<MAX_XACCS)
	{
		xacc->flag |= XACC;

		xacc->id = id;
		xacc->version = msg[3];
		xacc->menu_id = msg[6];
		xacc->xdsc = xacc->xname = xdsc = NULL;
		if ((name=*((char **) &msg[4]))!=NULL)
		{
			p = name;
			while (*p++);
			if (!strcmp(p,"XDSC") && p[5]!='\0')
				for (xdsc=(p+=5);*p++!='\0';)
					while (*p++);

			if ((xacc->xname=malloc(size=(long) (p-name)))!=NULL)
			{
				memcpy(xacc->xname,name,size);
				if (xdsc)
					xacc->xdsc = xacc->xname+(xdsc-name);
			}
		}
		_send_msg(xacc,id,XACC_AV_INIT,0,0);
	}
}

static void kill_id(int id)
{
	reg XAcc *xacc;
	reg int i;

	if (id==ap_id || id<0)
		return;

	for (i=0,xacc=Xaccs;i<MAX_XACCS;xacc++,i++)
		if (id==xacc->id)
		{
			if (xacc->xname)
				free(xacc->xname);

			memset(xacc,0,sizeof(XAcc));
			xacc->id = -1;

			if (id==AvServer)
			{
				AvServer = Server = -1;
				_AvAllWins();
			}

			_send_msg(NULL,id,XACC_AV_EXIT,0,0);
			break;
		}
}

XAcc *find_xacc_xdsc(int id,char *dsc)
{
	reg XAcc *xacc;
	reg char *xdsc;
	reg int i;

	for (i=0,xacc=Xaccs;i<MAX_XACCS;xacc++,i++)
		if (xacc->id>=0 && (id<0 || xacc->id==id))
		{
			if ((xdsc=xacc->xdsc)!=NULL)
			{
				while (*xdsc!='\0')
				{
					if (!strcmp(xdsc,dsc))
						return (xacc);
					xdsc += strlen(xdsc)+1;
				}
			}

			if (xacc->id==id)
				break;
		}

	return (NULL);
}

static int next=-1;

XAcc *find_app(int first)
{
	reg XAcc *xacc;
	reg int i;

	if (first)
		i = 0;
	else if (next<0 || next>=MAX_XACCS)
		return (NULL);
	else
		i = next;

	for (xacc=&Xaccs[i];i<MAX_XACCS;xacc++,i++)
		if (xacc->id>=0)
		{
			next = i+1;
			return (xacc);
		}

	next = -1;
	return (NULL);
}

XAcc *find_id(int id)
{
	reg XAcc *xacc;
	reg int i;

	if (id<0)
		return (NULL);

	for (i=0,xacc=Xaccs;i<MAX_XACCS;xacc++,i++)
		if (xacc->id==id)
			return (xacc);

	return (NULL);
}

int _Wait(int ap_id,int wait,int mode,char *args)
{
	XEVENT event;
	reg int *msg = event.ev_mmgpbuf,exit=FAIL;

	MouseUpdate(TRUE);
	MouseBee();

	memset(&event,0,sizeof(XEVENT));
	event.ev_mflags = MU_MESAG|MU_TIMER;
	event.ev_mtlocount = wait;

	while (exit==FAIL && (Event_Multi(&event) & MU_MESAG))
	{
		switch (msg[0])
		{
		case ACC_ACK:
			if (mode==XACC_WAIT && ap_id==msg[1])
				exit = msg[3]==1 ? TRUE : FALSE;
			break;
		case AV_STARTED:
			if (*(char **) &msg[3]!=args)
				break;
		case AV_ACCWINDOPEN:
			if (mode==AV_WAIT && ap_id==msg[1])
				exit = TRUE;
			break;
	#ifndef SMALL_NO_DD_FSEL
		case FONT_ACK:
			if (mode==FONT_WAIT && (msg[1]==ap_id || (ap_id<0 && msg[3])))
				exit = msg[3] ? TRUE : FALSE;
			break;
	#endif
	#ifndef SMALL_NO_PAULA
		case MP_ACK:
		case MP_NAK:
			if (mode==PAULA_WAIT && msg[1]==ap_id)
				exit = msg[0]==MP_ACK ? TRUE : FALSE;
			break;
	#endif
		case XACC_AV_EXIT:
		case CH_EXIT:
			if (msg[3]!=ap_id)
				break;
		case XACC_AV_CLOSE:
		case AC_OPEN:
		case AC_CLOSE:
		case AP_TERM:
			exit = FALSE;
		}
	}
	MouseUpdate(FALSE);
	return (exit);
}

#ifndef SMALL_NO_PAULA

#define PAULA_TIMER	2000

static int paula;

static int PaulaSendMsg(int msg,int *mbuf)
{
	if ((paula=AppLoaded("PAULA"))>=0 && AvSendMsg(paula,msg,mbuf))
		return (_Wait(paula,PAULA_TIMER,PAULA_WAIT,NULL));
	return (FALSE);
}

int PaulaStop(void)
{
	return (PaulaSendMsg(MP_STOP,NULL));
}

int PaulaShutDown(void)
{
	return (PaulaSendMsg(MP_SHUTDOWN,NULL));
}

int PaulaStart(char *args)
{
	int mbuf[8],exit;

	*(char **) &mbuf[3] = args;
	if ((exit=PaulaSendMsg(MP_START,mbuf))==FAIL && paula>=0)
	{
		mbuf[6] = 1;
		mbuf[7] = 0;
		exit = FALSE;
		if (AvSendMsg(paula,VA_START,mbuf))
			exit = _Wait(paula,VA_START_WAIT,AV_WAIT,args);
	}
	return (exit);
}

#endif
#endif

int AvSendMsg(int sendto,int msg_id,int *msg)
{
	if (sendto>=0)
	{
		int mbuf[8];

		if (msg==NULL)
			msg = mbuf;

		msg[0] = msg_id;
		msg[1] = ap_id;
		msg[2] = 0;

		if (sendto==ap_id)
		{
			_send_puf(FALSE,msg_id,msg);
			return (TRUE);
		}
		else if (appl_write(sendto,16,msg)>0)
			return (TRUE);
	#ifndef SMALL_NO_XACC_AV
		else
			kill_id(sendto);
	#endif
	}
	return (FALSE);
}

int AppLoaded(char *app)
{
	reg char buf[9], *p;
	reg int i,id;

	if (app==NULL)
		return (-1);

	p = GetFilename(app);
	for (i=0;i<8;i++)
		if(*p>' ' && *p!='.')
			buf[i] = *p++;
		else
			buf[i] = ' ';
	buf[8] = '\0';

	id = appl_find(buf);
	if (id==ap_id)
		id = -1;

	return (id);
}

void *GetMsgBuffer(long size)
{
	if (protect)
		return (Mxalloc(size,0x0023));
	else
		return (Malloc(size));
}
