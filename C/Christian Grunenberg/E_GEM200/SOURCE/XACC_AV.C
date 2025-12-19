
#include "proto.h"
#include <string.h>
#include <time.h>

int AvServer=-1,_xacc_msgs;
static char *XAccName,*AVName,a_name[9];
static int av_msgs,va_msgs,multi_xacc=FALSE;
static XAcc Xaccs[MAX_XACCS];

static void	store_xacc_id(int*);
static void	store_av_id(int*);
static void	kill_id(int,int);

static void	XAccSendId(int);
static void	XAccSendAcc(int);
static void XAccSendAccClose(void);
static int XAccWait(int);

static void AvProtocol(int);

int appl_search(int ap_smode,char *ap_sname,int *ap_stype,int *ap_sid)
{
	INTIN[0] = ap_smode;
	_GemParBlk.addrin[0] = ap_sname;
	_aes(0,0x12010301L);

	*ap_stype = INTOUT[1];
	*ap_sid = INTOUT[2];

	return (INTOUT[0]);
}

int AvSendMsg(int sendto,int msg_id,int *msg)
{
	if (sendto>=0)
	{
		int err;

		msg[0] = msg_id;
		msg[1] = ap_id;
		msg[2] = 0;

		err = appl_write(sendto,16,msg);

		if (err>0)
			return (TRUE);
		else if (err<0 && sendto!=ap_id)
			kill_id(AV|XACC,sendto);
	}

	return (FALSE);
}

static int XAccSend(int sendto,int msg0,int msg3,char *msg4,int msg6,int msg7)
{
	if (sendto>=0 && sendto!=ap_id)
	{
		int msg[8],err;

		msg[0] = msg0;
		msg[1] = ap_id;
		msg[2] = 0;
		msg[3] = msg3;
		*(char **) &msg[4] = msg4;
		msg[6] = msg6;
		msg[7] = msg7;

		err = appl_write(sendto, 16, msg);

		if (err>0)
			return (TRUE);
		else if (err<0)
			kill_id(AV|XACC,sendto);
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
		return (XAccWait(2000));
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
		return (XAccWait(5000));
	else
		return (FALSE);
}

int XAccSendImg(int sendto, int last, char *data, long len)
{
	if (XAccSend(sendto, ACC_IMG, (last) ? 1: 0, data, (int) (len>>16), (int) len)==TRUE)
		return (XAccWait(5000));
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
			if (xacc->flag & AV)
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

static void XAccSendAccClose(void)
{
	if (!_app && !multi_xacc)
	{
		kill_id(AV|XACC,0);
		AvServer = -1;
		XAccSendId(0);
		AvProtocol(0);
	}
}

int AppLoaded(char *app)
{
	reg char buf[9], *p, *q;
	reg int i,id;

	if (app==NULL)
		return (-1);

	p = q = app;
	while ((q=strpbrk(p,":\\/"))!=NULL)
	{
		q++;
		p = q;
	}

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
	reg XAcc *xacc;
	reg char name[10];
	reg int i;
	int next,type,id;
	int dummy,search;

	if (aes_version>=0x0400 || magx || (appl_xgetinfo(4,&dummy,&dummy,&search,&dummy) && search>0))
	{
		next = 0;
		while (appl_search(next, name, &type, &id))
		{
			if (id!=ap_id && (type & 0x06))
				AvSendMsg(id,msg[0],msg);
			next = 1;
		}
	}
	else
		for (i=0,xacc=Xaccs;i<MAX_XACCS;xacc++,i++)
			if (xacc->id>=0)
				AvSendMsg(xacc->id,msg[0],msg);
}

void _XAccSendStartup(char *xacc_name, char *av_name, int Avmsgs,int Vamsgs, int xacc_msgs)
{
	reg char name[10], *buf, *p;
	int xacc_size,av_size;
	int i,next,type,id,dummy,search;

	XAccName = p = xacc_name;

	while (*p++);
	if (!stricmp(p,"XDSC"))
	{
		do
		{
			while (*p++);
		} while (*p);
	}

	xacc_size = (int) (p - xacc_name);

	strcpy(a_name,"        ");
	AVName = memcpy(a_name,av_name,min((int) strlen(av_name),8));
	av_size = 8+1;

	av_msgs = Avmsgs;
	va_msgs = Vamsgs|MSG_EXIT|MSG_SENDKEY|MSG_ACCWINDOPEN;
	_xacc_msgs = xacc_msgs;

	for (i=0;i<MAX_XACCS;i++)
		Xaccs[i].id = -1;

	if (mint)
	{
		buf = Mxalloc(xacc_size+av_size, 0x0023);
		if (buf!=NULL)
		{
			XAccName = memcpy(buf, XAccName, xacc_size);
			buf += xacc_size;
			AVName = memcpy(buf, AVName, av_size);
		}
	}

	if (aes_version>=0x0400 || magx || (appl_xgetinfo(4,&dummy,&dummy,&search,&dummy) && search>0))
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

	id = AppLoaded(getenv("AVSERVER"));
	if (id<0)
		id = appl_find("AVSERVER");
	if (id<0)
		id = appl_find("GEMINI  ");
	if (id<0)
		id = appl_find("VENUS   ");

	if (id==ap_id)
		AvServer = -1;
	else
		AvServer = id;

	if (!_app & !multi_xacc)
		XAccSendAccClose();
	else if (AvServer>=0)
		AvProtocol(AvServer);
}

static int XAccWait(int wait)
{
	XEVENT event;
	reg int *msg = event.ev_mmgpbuf;

	event.ev_mflags = MU_MESAG|MU_TIMER;
	event.ev_mthicount = 0;
	event.ev_mtlocount = wait;
	event.ev_mtlast = 0;

	while (Event_Multi(&event)==MU_MESAG)
	{
		switch (msg[0])
		{
		case ACC_ACK:
			return((msg[3]==1) ? TRUE : FALSE);
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

int _XAccComm(int *msg)
{
	switch (msg[0])
	{
	case AC_CLOSE:
		XAccSendAccClose();
		return (FALSE);
	case ACC_ACC:
		if (multi_xacc)
		{
			if (msg[7]<=0 || msg[1]==msg[7])
			{
				AvProtoStatus(msg[1]);
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
			XAccSendAcc(msg[1]);
			AvProtoStatus(msg[1]);
		}
		else if (_app)
		{
			XAccInformAcc(msg);
			XAccSendId(msg[1]);
		}
		store_xacc_id(msg);
		break;
	case AV_EXIT:
		kill_id(AV|XACC,msg[3]);
		break;
	case ACC_EXIT:
		kill_id(XACC,msg[1]);
		break;
	case AV_PROTOKOLL:
		AvProtoStatus(msg[1]);
	case VA_PROTOSTATUS:
		store_av_id(msg);
		break;
	default:
		return (FALSE);
	}

	return (TRUE);
}

static void store_av_id(int *msg)
{
	reg XAcc *xacc=Xaccs;
	reg int id=msg[1],i;

	if (id==ap_id || id<0)
		return;

	if (id==0 && !_app && !multi_xacc)
		AvServer = 0;

	for (i=0;i<MAX_XACCS && xacc->id>=0;xacc++,i++)
		if (xacc->id==id)
			break;;

	if (i<MAX_XACCS)
	{
		xacc->flag |= AV;

		xacc->id = id;
		strncpy(xacc->name,*((char **) &msg[6]),8);

		_send_msg(xacc,id,XACC_AV_INIT);
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

		_send_msg(xacc,id,XACC_AV_INIT);
	}
}

static void kill_id(int flag,int id)
{
	reg XAcc *xacc;
	reg int i;

	if (id<0)
		return;

	for (i=0,xacc=Xaccs;i<MAX_XACCS;xacc++,i++)
		if (id==xacc->id)
		{
			xacc->flag &= ~flag;
			if (id==AvServer && (xacc->flag & AV)==0)
				AvServer = -1;

			if (xacc->flag==0)
			{
				memset(xacc,0,sizeof(XAcc));
				xacc->id = -1;
			}
			else if (flag==AV)
				xacc->name[0] = '\0';
			else
			{
				xacc->xname = xacc->xdsc = NULL;
				xacc->version = xacc->menu_id = 0;
			}

			_send_msg(xacc,id,XACC_AV_EXIT);
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
