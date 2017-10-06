
#include "proto.h"
#include <string.h>
#include <stdio.h>

#ifdef __MINT_LIB__
#include <mintbind.h>
#endif

#define strclr(p)	*p = '\0'

typedef struct
{	unsigned long id;
	unsigned int version;
	struct
	{	unsigned        : 7;
		unsigned pthsav : 1;
		unsigned stdest : 1;
		unsigned        : 1;
		unsigned numsrt : 1;
		unsigned lower  : 1;
		unsigned dclick : 1;
		unsigned hidden : 1;
		unsigned onoff  : 1; 
	} config;
	int	sort,num_ext;
	char *(*ext)[];
	int	num_paths;
	char *(*paths)[];
	int	comm,in_count;
	void *in_ptr;
	int	out_count;
	void *out_ptr;
} SLCT_STR;

static int matchpattern(char *s,char *p)
{
	reg char s_c,p_c,c1 = ']',c2 = '-',reverse;

	while ((p_c=*p++)!='\0')
		switch (p_c)
		{
		case '@':
			if (*s++!=*p++)
				return (FALSE);
			break;
		case '?':
			if (*s++=='\0')
				return (FALSE);
			break;
		case '*':
			if (*s=='\0' || *p=='\0')
				return (*p=='\0');
			for (;*s!='\0' && !matchpattern(s,p);s++);
			return (*s!='\0');
		case '[':
			s_c = *s++;
			if ((reverse=(*p=='^'))!=0)
				p++;
			while ((p_c=*p++)!='\0')
				if (p_c==c1)
					break;
				else if (p_c==c2)
				{
					if (s_c<=*p++ && s_c>=p[-3])
					{
						if (reverse)
							return (FALSE);
						break;
					}
				}
				else if (p_c=='@')
				{
					if (s_c==*p++)
					{
						if (reverse)
							return (FALSE);
						break;
					}
				}
				else if (s_c==p_c && p_c!='|')
				{
					if (reverse)
						return (FALSE);
					break;
				}
			break;
		default:
			if (*s++!=p_c)
				return (FALSE);
		}
	return (*s=='\0');
}

char *strwild(char *string,char *wild)
{
	reg int revers;
	if ((revers=(*string=='^'))!=0)
		string++;
	if (matchpattern(string,wild))
		return (revers ? NULL : string);
	return (revers ? string : NULL);
}

char *strend(reg char *str)
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
	if ((q=strrchr(p,'.'))>p)
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

static int calc_crc(unsigned char *mem,int len)
{
	reg unsigned int crc = 0x1234;
	while (--len>=0)
	{
		crc ^= *mem++;
		crc = (crc>>8)|(crc<<8);
	}
	return ((int) crc);
}

boolean SaveInfoFile(char *file,boolean auto_path,void *info,int len,char *id,int version)
{
	char path[MAX_PATH];
	long handle;
	int err=0,cnt,crc;

	MouseBee();

	if (_app || !auto_path)
		strcpy(path,auto_path ? GetFilename(file) : file);
	else
	{
		long sp=Super(NULL);
		strcpy(path,"X:\\");
		path[0] = (char) (*((int *) 0x446)+'A');
		Super((void *) sp);
		strcat(path,GetFilename(file));
	}

	if ((handle=Fcreate(path,0))>0)
	{
		crc = calc_crc(info,len);
		cnt = (int) strlen(id);
		cnt += cnt & 1;
		if ((int) Fwrite((int) handle,cnt,id)!=cnt || (int) Fwrite((int) handle,2,&crc)!=2 ||
			(int) Fwrite((int) handle,2,&version)!=2 || (int) Fwrite((int) handle,len,info)!=len)
			err++;
		if (Fclose((int) handle)<0)
			err++;
		if (err)
			Fdelete(path);
	#ifndef SMALL_NO_XACC_AV
		drive_changed(GetDrive(path));
	#endif
	}
	else
		err++;

	_inform(MOUSE_INIT);
	return (err ? FALSE : TRUE);
}

int LoadInfoFile(char *file,boolean auto_path,void *info,int len,int min_len,char *id,int min_version)
{
	char path[MAX_PATH],*mem;
	long handle;
	int err=FAIL,cnt,rd;

	MouseBee();

	strcpy(path,auto_path ? GetFilename(file) : file);
	if ((!auto_path || shel_find(path)) && (handle=Fopen(path,0))>0)
	{
		cnt = (int) strlen(id)+4;
		cnt += cnt & 1;
		if ((mem=malloc(len+=cnt))!=NULL)
		{
			if ((rd=(int) Fread((int) handle,len,mem))>=(min_len+cnt) && rd<=len)
			{
				err = FALSE;
				if (memcmp(mem,id,cnt-4)==0)
				{
					mem += cnt;
					if (calc_crc((unsigned char *) mem,len=rd-cnt)==*(int *) &mem[-4] && *(int *) &mem[-2]>=min_version)
						memcpy(info,mem,err=len);
				}
			}
			free(mem);
		}
		Fclose((int) handle);
	}

	_inform(MOUSE_INIT);
	return (err);
}

int FileSelect(char *title,char *path,char *fname,char *sel,int no_insel,int out,char *outptr[])
{
	static int pconf = FAIL;
	RC_RECT save;
	SLCT_STR *slct;
	WIN *win = NULL;
	int i,button,err,fsel,multi=FALSE,ctrl;
	long sp;

	ctrl = ((fsel=get_cookie(COOKIE_FSEL,(long *) &slct))==FALSE || slct->id!=COOKIE_SELECTRIC || slct->version<0x0200);

	if (ctrl)
		beg_ctrl(FALSE,TRUE,TRUE);
	else
		beg_update(FALSE,FALSE);

	if (!output)
	{
		MouseOff();
		rc_sc_save(&desk,&save);
		MouseOn();

		if (!save.valid)
		{
			end_update(FALSE);
			return (FAIL);
		}
	}
	else
		win = get_top_window();

	if (sel==NULL || *sel=='\0')
		sel = "*.*";

	if (pconf==FAIL)
		pconf = Dpathconf(path,6)!=-32 ? TRUE : FALSE;
	if (!pconf || (!fsel && aes_version<0x0400))
		strupr(sel);
	else
		strlwr(sel);

	if (no_insel)
		strclr(fname);

	MakeFullpath(path,NULL,sel);

	if (out<1 || outptr==NULL)
		out = 1;
	else if (out>1)
	{
		for (i=out;--i>=0;strclr(outptr[i]));

		if (fsel)
		{
			if (mint)
				sp = Super(0l);

			if (slct->id==COOKIE_SELECTRIC && slct->version>=0x102);
			{
				slct->out_count = out;
				slct->out_ptr = outptr;
				slct->comm = 1;
				multi = TRUE;
			}

			if (mint)
				Super((void *) sp);
		}
	}

	MouseArrow();
	if (aes_version>=0x0140 || fsel)
		err = fsel_exinput(path,fname,&button,title);
	else
		err = fsel_input(path,fname,&button);

	if (err && button)
	{
		if (multi)
		{
			if (mint)
				sp = Super(0l);
			out = slct->out_count;
			if (mint)
				Super((void *) sp);
		}
		else
			out = 0;

		GetPath(path);

		if (out<=0)
		{	
			if (outptr)
				outptr[0] = fname;
			out = 1;
		}
	}
	else if (err==0)
		out = FAIL;
	else
		out = FALSE;

	if (_dia_len>0)
	{
		MouseOff();
		rc_sc_restore(desk.g_x,desk.g_y,&save,TRUE);
		MouseOn();
	}

	if (ctrl)
		end_ctrl(TRUE,TRUE);
	else
	{
		end_update(FALSE);
		_inform(MOUSE_INIT);
	}

	if (win)
		_new_top(-1,TRUE);

	return (out);
}

#ifndef SMALL_NO_XACC_AV
void drive_changed(int drive)
{
	int msg[8];

	if (drive==('U'-'A'))
		drive = -1;

    msg[0] = SH_WDRAW;
    msg[3] = (drive<0) ? -1 : drive;
	XAccBroadCast(msg);
}
#endif
