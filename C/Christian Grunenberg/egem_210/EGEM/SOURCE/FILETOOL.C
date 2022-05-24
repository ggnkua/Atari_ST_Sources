
#include "proto.h"
#include <string.h>

#define strclr(p)	*p = '\0'

static char *strend(reg char *str)
{
	while (*str++);
	return (--str);
}

static char *yen2slash(char *p)
{
	reg char *d = p,c,s;

	s = '/';
	while ((c=*d++)!='\0')
		if (c==s)
			d[-1]='\\';

	s = '\\';
	d = p;
	while ((c=*d++)!='\0')
	{
		if (c==s && *d==s)
		{
			d--;
			strcpy(d,d+1);
		}
	}

	return (p);
}

char *GetFilename(char *path)
{
	reg char *p,*q;

	p = q = yen2slash(path);
	while ((q=strpbrk(p,":\\"))!=NULL)
	{
		q++;
		p = q;
	}

	if (!strcmp(p,".") || !strcmp(p,".."))
	{
		p = strend(p);
		*p++ = '\\';
		*p = '\0';
	}
	else if (p>path && p[-1]==':')
	{
		*p++ = '\\';
		*p = '\0';
	}

	return (p);
}

char *GetPath(char *fname)
{
	reg char *file = GetFilename(fname);
	strclr(file);
	return (file);
}

char *GetExtension(char *path)
{
	reg char *p,*q;

	p = GetFilename(path);
	if ((q=strrchr(p,'.'))>=p)
		return (q);
	else
		return (strend(p));
}

int GetDrive(char *path)
{
	if (path[0]!='\0' && path[1]==':')
		return (UpperChar(path[0]) - 'A');
	else
		return (Dgetdrv());
}

char *MakeFullpath(char *dest,char *path,char *file)
{
	reg char *last;

	if (path)
		strcpy(dest,path);
	yen2slash(dest);

	if ((last=strend(dest))>dest && last[-1]!='\\')
	{
		*last++ = '\\';
		strcpy(last,file);
	}
	else
		strcat(dest,file);

	return (dest);
}

int FileSelect(char *title,char *path,char *fname,char *sel,int no_insel)
{
	int button,err;

	if (sel==NULL || *sel=='\0')
		sel = "*.*";

	if (no_insel)
		strclr(fname);

	MakeFullpath(path,NULL,sel);
	if (aes_version>=0x0140 || get_cookie((long) 'FSEL',NULL))
		err = fsel_exinput(path,fname,&button,title);
	else
		err = fsel_input(path,fname,&button);

	_reset_mouse();

	if (err && button)
	{
		GetPath(path);
		return (TRUE);
	}
	else
		return (FALSE);
}

void drive_changed(int drive)
{
	int msg[8];

	if (drive==('U'-'A'))
		drive = -1;

    msg[0] = SH_WDRAW;
    msg[3] = drive;
	XAccBroadCast(msg);
}
