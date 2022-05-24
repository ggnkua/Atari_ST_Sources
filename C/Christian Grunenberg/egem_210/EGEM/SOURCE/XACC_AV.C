
#include "proto.h"
#include <string.h>
#include <time.h>

#define ACC_TEXT_WAIT	2000
#define ACC_IMG_WAIT	4000
#define ACC_META_WAIT	4000

int AvServer=-1,_xacc_msgs;
static char *XAccName,*AVName,a_name[9];
static int av_msgs,va_msgs,multi_xacc=FALSE;
static XAcc Xaccs[MAX_XACCS];

static void	store_xacc_id(int*);
static void	store_av_id(int*,int,int);
static void	kill_id(int);

static void	XAccSendId(int);
static void	XAccSendAcc(int);
static void XAccSendAccClose(void);
static int XAccWait(int,int);

int appl_search(int ap_smode,char *ap_sname,int *ap_stype,int *ap_sid)
{
	INTIN[0] = ap_smode;
	ADDRIN[0] = ap_sname;
	_aes(0,0x12010301L);

	*ap_stype = INTOUT[1];
	*ap_sid = INTOUT[2];

	return (INTOUT[0]);
}

int AvSendMsg(int sendto,int msg_id,int *msg)
{
	if (sendto>=0)
	{
		msg[0] = msg_id;
		msg[1] = ap_id;
		msg[2] = 0;

		if (appl_write(sendto,16,msg)>0)
			return (TRUE);
		else if (sendto!=ap_id)
			kill_id(sendto);
	}

	return (FALSE);
}

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
		return (XAccWait(sendto,ACC_TEXT_WAIT));
	else
		return (FALSE);
}

int XAccSendKey(int sendto, int scan, int state)
{
	if (XAccSend(sendto, ACC_KEY, scan, (char *) (((long) state)<<16), 0, 0)==TRUE)
		return (TRUE);
	else
		return (FALSE);
}

int XAccSendMeta(int sendto, int last, char *data, long len)
{
	if (XAccSend(sendto, ACC_META, (last) ? 1: 0, data, (int) (len>>16), (int) len)==TRUE)
		return (XAccWait(sendto,ACC_META_WAIT));
	else
		return (FALSE);
}

int XAccSendImg(int sendto, int last, char *data, long len)
{
	if (XAccSend(sendto, ACC_IMG, (last) ? 1: 0, data, (int) (len>>16), (int) len)==TRUE)
		return (XAccWait(sendto,ACC_IMG_WAIT));
	else
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
		if (xacc->flag & XACC)
			XAccSend(xacc->id,ACC_ACC,msg[3],name,msg[6],msg[1]);
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
		char name[10];
		int next,type,id;

		next = 0;
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
		reg int i;

		for (i=0,xacc=Xaccs;i<MAX_XACCS;xacc++,i++)
			if (xacc->id>=0)
				AvSendMsg(xacc->id,msg[0],msg);
	}
}

void *GetMsgBuffer(long size)
{
	if (mint || magx)
		return (Mxalloc(size,0x0023));
	else
		return (Malloc(size));
}

void _XAccSendStartup(char *xacc_name, char *av_name, int Avmsgs,int Vamsgs, int xacc_msgs)
{
	reg char name[10], *buf, *p;
	int xacc_size,av_size;
	int i,next,type,id;

	XAccName = p = xacc_name;

	while (*p++);
	if (!stricmp(p,"XDSC"))
	{
		do
		{
			while (*p++);
		} while (*p++);
	}

	xacc_size = (int) (p - xacc_name);

	strcpy(a_name,"        ");
	AVName = memcpy(a_name,av_name,min((int) strlen(av_name),8));
	av_size = 8+1;

	av_msgs = Avmsgs|MSG_START;
	va_msgs = Vamsgs|MSG_EXIT|MSG_SENDKEY|MSG_ACCWINDOPEN|MSG_PATH_UPDATE;
	_xacc_msgs = xacc_msgs;

	for (i=0;i<MAX_XACCS;i++)
		Xaccs[i].id = -1;

	if ((buf=GetMsgBuffer(xacc_size+av_size))!=NULL)
	{
		XAccName = memcpy(buf, XAccName, xacc_size);
		buf += xacc_size;
		AVName = memcpy(buf, AVName, av_size);
	}

	if (search)
	{
		multi_xacc = TRUE;

		next = 0;
		while (appl_search(next, name, &type, &id))
		{
			if (id!=ap_id && (type & 0x06))
				XAccSendId(id);
			next = 1;
		}
	}

	if (multi)
	{
		id = AppLoaded(getenv("AVSERVER"));
		if (id<0)
			id = AppLoaded("AVSERVER");
		if (id<0)
			id = AppLoaded("GEMINI");

		if (id==ap_id)
			AvServer = -1;
		else
			AvServer = id;
	}
	else if (!_app)
		XAccSendAccClose();
	evnt_timer(250,0);
}

static int XAccWait(int ap_id,int wait)
{
	XEVENT event;
	reg int *msg = event.ev_mmgpbuf;

	memset(&event,0,sizeof(XEVENT));
	event.ev_mflags = MU_MESAG|MU_TIMER;
	event.ev_mtlocount = wait;

	while (Event_Multi(&event)==MU_MESAG)
	{
		switch (msg[0])
		{
		case ACC_ACK:
			if (ap_id==msg[1])
				return((msg[3]==1) ? TRUE : FALSE);
			break;
		case AC_OPEN:
		case AC_CLOSE:
			if (_app)
				break;
		case AP_TERM:
			return (FALSE);
		}
	}

	return(FALSE);
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

static void AvProtoStatus(int id)
{
	int msg[8];

	if (id!=AvServer && id!=ap_id)
	{
		msg[3] = va_msgs;
		msg[4] = msg[5] = 0;
		*(const char **) &msg[6] = AVName;
		AvSendMsg(id,VA_PROTOSTATUS,msg);
	}
}

static void XAccSendAccClose(void)
{
	kill_id(0);
	AvServer = -1;
	XAccSendId(0);
	AvProtocol(0);
}

int _XAccComm(int *msg)
{
	reg int id = msg[1];

	switch (msg[0])
	{
	case AC_CLOSE:
		if (!_app && !multi)
			XAccSendAccClose();
		return (FALSE);
	case ACC_ACC:
		if (multi_xacc)
		{
			if (msg[7]<=0 || id==msg[7])
			{
				if (multi)
				{
					AvProtocol(id);
					AvProtoStatus(id);
				}
				store_xacc_id(msg);
			}
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
		{
			XAccSendAcc(id);
			if (multi)
			{
				AvProtocol(id);
				AvProtoStatus(id);
			}
		}
		else if (_app)
		{
			XAccInformAcc(msg);
			XAccSendId(id);
		}
		store_xacc_id(msg);
		break;
	case AV_EXIT:
		kill_id(msg[3]);
		break;
	case ACC_EXIT:
		kill_id(id);
		break;
	case CH_EXIT:
		kill_id(msg[3]);
		return (FALSE);
	case AV_PROTOKOLL:
		AvProtoStatus(id);
		store_av_id(msg,msg[3],FAIL);
		break;
	case VA_PROTOSTATUS:
		store_av_id(msg,FAIL,msg[3]);
		break;
	default:
		return (FALSE);
	}

	return (TRUE);
}

static void store_av_id(int *msg,int av_msgs,int va_msgs)
{
	reg XAcc *xacc=Xaccs;
	reg int id=msg[1],i;
	char shell[9];
	int type,sh_id;

	if (id==ap_id || id<0)
		return;

	for (i=0;i<MAX_XACCS && xacc->id>=0;xacc++,i++)
		if (xacc->id==id)
			break;

	if (i<MAX_XACCS)
	{
		if (id==0 && !_app && !multi)
			AvServer = 0;
		else if (AvServer<0 && search && multi)
			if (appl_search(2,shell,&type,&sh_id) && sh_id==id)
				AvServer = id;

		xacc->flag |= AV;
		xacc->id = id;

		strncpy(xacc->name,*((char **) &msg[6]),8);

		if (av_msgs!=FAIL)
			xacc->av_msgs = av_msgs;
		if (va_msgs!=FAIL)
			xacc->va_msgs = va_msgs;

		_send_msg(xacc,id,XACC_AV_INIT,0,0);
	}
}

static void store_xacc_id(int *msg)
{
	reg XAcc *xacc;
	reg int id=msg[1],i;
	reg char *xdsc;

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
		xacc->xname = *((char **) &msg[4]);
		xacc->xdsc = NULL;
		if (xacc->xname!=NULL)
		{
			xdsc = xacc->xname + strlen(xacc->xname)+1;
			if (!strcmp(xdsc,"XDSC"))
				xacc->xdsc = xdsc+5;
		}

		_send_msg(xacc,id,XACC_AV_INIT,0,0);
	}
}

static void kill_id(int id)
{
	reg XAcc *xacc;
	reg int i;

	if (id<0)
		return;

	for (i=0,xacc=Xaccs;i<MAX_XACCS;xacc++,i++)
		if (id==xacc->id)
		{
			memset(xacc,0,sizeof(XAcc));
			xacc->id = -1;

			if (id==AvServer)
				AvServer = -1;

			_send_msg(xacc,id,XACC_AV_EXIT,0,0);
			return;
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
