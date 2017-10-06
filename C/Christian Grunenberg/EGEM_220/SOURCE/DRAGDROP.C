
#include "proto.h"

#ifndef SMALL_NO_DD
#include <string.h>

#ifdef __MINT_LIB__
#include <mintbind.h>
#endif

#ifndef EACCDN
#define EACCDN -36
#endif

#ifndef SIGPIPE
#define SIGPIPE 13
#endif

#ifndef SIG_IGN
#define SIG_IGN 1L
#endif

#ifdef __MINT_LIB__
#define SIGNAL	long
#else
#define SIGNAL	void *
#endif

static char ourexts[DD_EXTSIZE]="ARGS",pipename[]="U:\\PIPE\\DRAGDROP.AA",*dd_args,*dd_buffer;
static int any_ext;
static long oldpipesig;

int _dd_available;

char *ParseArgs(char *orig)
{
	reg char *p,*q,*arg,c,quote;

	if (orig)
	{
		if (dd_buffer)
			free(dd_buffer);
		dd_buffer = dd_args = strdup(orig);
	}

	if ((p=dd_args)==NULL)
		return (NULL);

	if ((c=*p++)!='\0')
	{
		q = arg = dd_args;
		if (c==0x27 || c==0x22)
			for (quote=c,c=*p++;c!='\0';c=*p++)
			{
				if (c==quote)
				{
					if ((c=*p++)==quote)
						*q++ = quote;
					else
						break;
				}
				else
					*q++ = c;
			}
		else
			for (;c!='\0' && c!=' ';c=*p++)
				*q++ = c;

		*q = '\0';
		while (c==' ')
			c = *p++;

		dd_args = p-1;
	}
	else
	{
		free(dd_buffer);
		dd_buffer = dd_args = arg = NULL;
	}

	return (arg);
}

void SetDragDrop(int any,char *exts)
{
	any_ext = any;
	strupr(strncpy(ourexts,exts,DD_EXTSIZE-1));
}

static int ddcreate(int sendto,int win_id,int msx,int msy,int kstate,char exts[])
{
	reg int fd, msg[8];
	long fd_mask;
	char c;

	pipename[17] = pipename[18] = 'A';

	do
	{
		pipename[18]++;
		if (pipename[18]>'Z')
		{
			pipename[17]++;
			if (pipename[17]>'Z')
				break;
			else
				pipename[18] = 'A';
		}
		fd = (int) Fcreate(pipename, FA_HIDDEN);
	} while (fd==EACCDN);

	if (fd<0)
		return (-2);

	msg[3] = win_id;
	msg[4] = msx;
	msg[5] = msy;
	msg[6] = kstate;
	msg[7] = (pipename[17]<<8)|pipename[18];
	if (AvSendMsg(sendto, AP_DRAGDROP, msg)==FALSE)
	{
		Fclose(fd);
		return (-1);
	}

	fd_mask = 1L<<fd;
	if (Fselect(DD_TIMEOUT,&fd_mask,0L,0L) && fd_mask && Fread(fd,1L,&c)==1 && c==DD_OK && Fread(fd,DD_EXTSIZE,exts)==DD_EXTSIZE)
	{
		oldpipesig = (long) Psignal(SIGPIPE, (SIGNAL) SIG_IGN);
		return (fd);
	}
	else
	{
		Fclose(fd);
		return (-1);
	}
}

static int ddstry(int fd, char *ext, char *name, long size)
{
	int hdrlen,namelen;
	char c;

	namelen = (int) strlen(name)+1;
	hdrlen = namelen+8;

	if (Fwrite(fd,2L,&hdrlen)!=2 || Fwrite(fd,4L,ext)!=4 || Fwrite(fd,4L,&size)!=4 || Fwrite(fd,namelen,name)!=namelen || Fread(fd,1L,&c)!=1)
		return (DD_NAK);
	else
		return (c);
}

static void ddclose(int fd)
{
	Psignal(SIGPIPE, (SIGNAL) oldpipesig);
	Fclose(fd);
}

static int ddrtry(int fd, char *name, char *whichext, long *size)
{
	int hdrlen,i;
	char buf[80];

	if (Fread(fd,2L,&hdrlen)!=2 || hdrlen<9)
		return (-1);

	if (Fread(fd,4L,whichext)!=4)
		return (-1);

	whichext[4] = 0;
	if (Fread(fd,4L,size)!=4)
		return (-1);

	hdrlen -= 8;
	i = min(hdrlen,DD_NAMEMAX);
	if (Fread(fd,i,name)!=i)
		return (-1);

	hdrlen -= i;
	while (hdrlen>80)
	{
		Fread(fd,80L,buf);
		hdrlen -= 80;
	}

	if (hdrlen>0)
		Fread(fd,hdrlen,buf);

	return (0);
}

static int ddreply(int fd, int ack)
{
	char c = ack;

	if (Fwrite(fd,1L,&c)!=1)
	{
		ddclose(fd);
		return (-1);
	}
	else
		return (0);
}

void _rec_ddmsg(int *msg)
{
	DRAG_DROP dd;
	char outbuf[DD_EXTSIZE+1],txtname[DD_NAMEMAX],ext[5],*mem;
	int fd;

	if (strlen(ourexts)<4)
		return;

	dd.dd_originator = msg[1];
	dd.dd_type = MINT_DRAG;
	dd.dd_win = get_window(msg[3]);

	*(long *) &dd.dd_mx = *(long *) &msg[4];
	dd.dd_kstate = msg[6];

	mem = (char *) &msg[7];
	pipename[17] = *mem++;
	pipename[18] = *mem;

	if ((fd=(int) Fopen(pipename,2))<0)
		return;

	outbuf[0] = DD_OK;
	strncpy(outbuf+1,ourexts,DD_EXTSIZE);

	oldpipesig = (long) Psignal(SIGPIPE,(SIGNAL) SIG_IGN);
	if (Fwrite(fd,DD_EXTSIZE+1,outbuf)!=DD_EXTSIZE+1)
	{
		ddclose(fd);
		return;
	}

	for(;;)
	{
		if (ddrtry(fd,txtname,ext,&dd.dd_size))
		{
			ddclose(fd);
			return;
		}
		else
		{
			ext[4] = '\0';
			memcpy(dd.dd_ext,ext,4);
			strupr(ext);
		}

		if (any_ext || strstr(ourexts,ext))
		{
			if ((mem=malloc(dd.dd_size+1))==NULL)
			{
				if (ddreply(fd, DD_LEN))
					return;
				continue;
			}

			if (ddreply(fd,DD_OK))
			{
				free(mem);
				return;
			}

			if (Fread(fd,dd.dd_size,mem)!=dd.dd_size)
			{
				free(mem);
				ddclose(fd);
				return;
			}

			mem[dd.dd_size] = 0;
			ddclose(fd);

			if (!strncmp(ext,"ARGS",4))
			{
				dd.dd_args = *mem=='\0' ? NULL : mem;
				dd.dd_ext[0] = '\0';
				dd.dd_mem = NULL;
				dd.dd_size = 0;
			}
			else
			{
				dd.dd_args = NULL;
				dd.dd_mem = mem;
			}

			dd.dd_name = txtname;
			_send_msg(&dd,0,OBJC_DRAGGED,0,0);

			free(mem);
			return;
		}
		else if (ddreply(fd, DD_EXT))
			return;
	}
}

int SendDragDrop(int msx,int msy,int kstate,char *name,char *sp_ext,long size,char *data)
{
	int fd,sendto,win_id,dummy;
	char recexts[DD_EXTSIZE],exts[5];

	if (!_dd_available)
		return (NO_DD);

	memcpy(exts,sp_ext,4);
	exts[4] = '\0';
	strupr(exts);

	if (!owner || (win_id=wind_find(msx,msy))<=0 || !wind_xget(win_id,WF_OWNER,&sendto,&dummy,&dummy,&dummy) || sendto==ap_id)
		return (NO_RECEIVER);

	MouseBee();
	_inform(MOUSE_INIT);

	switch (fd=ddcreate(sendto,win_id,msx,msy,kstate,recexts))
	{
	case -2:
		return (NO_DD);
	case -1:
		return (DD_NAK);
	}

	if ((dummy=ddstry(fd,exts,name,size))!=DD_OK)
	{
		ddclose(fd);
		return (dummy);
	}

	dummy = (Fwrite(fd,size,data)==size);
	ddclose(fd);

	return ((dummy) ? DD_OK : DD_LEN);
}

#endif
