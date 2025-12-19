
#include <string.h>
#include <stdio.h>
#include "proto.h"

int	scrp_init(char *path)
{
	reg char scrap[256];
	reg long handle,len;

	scrp_read(scrap);
	if (scrap[0]=='\0')
	{
		if (path)
			strcpy(scrap,path);
		else if ((path = getenv("CLIPBRD"))!=NULL || (path = getenv("SCRAPDIR"))!=NULL)
			strcpy(scrap,path);
		else
		{
			reg long ssp;

			strcpy(scrap,"X:\\CLIPBRD");
			ssp = Super(NULL);
			*scrap = (char) (*((int *) 0x446)+65);
			Super((void *) ssp);
		}
	}

	if ((len = strlen(scrap))>0)
	{
		len--;
		if (scrap[len]=='\\')
			scrap[len]='\0';
	
		handle = Dcreate(scrap);
		if (handle>=0 || handle==-36)
		{
			scrp_write(strcat(scrap,"\\"));
			return(TRUE);
		}
	}

	scrp_write("");
	return(FALSE);
}

void scrp_clear(int all)
{
	reg char scrap[256];
	
	scrp_read(scrap);
	if (scrap[0]!='\0')
	{
		reg DTA *dta=Fgetdta();
		reg char xpath[256],xname[256];

		_strmfp(xpath,scrap,(all) ? "*.*" : "SCRAP.*");
		if (!Fsfirst(xpath,0))
			do
			{
				_strmfp(xname,scrap,dta->d_fname);
				remove(xname);
			}
			while (!Fsnext());
		scrp_changed(SCF_INDEF,0l);
	}
}

long	scrp_length()
{
	reg char scrap[256];
	
	scrp_read(scrap);
	if (scrap[0]!='\0')
	{
		reg DTA *dta=Fgetdta();
		reg char xpath[256];

		_strmfp(xpath,scrap,"SCRAP.*");
		if (!Fsfirst(xpath,0))
		{
			reg long length = 0;
			do
				length += dta->d_length;
			while (!Fsnext());
			return (length);
		}
	}

	return (0);
}

int	scrp_find(char *extension,char *filename)
{
	reg char scrap[256];
	
	scrp_read(scrap);
	if (scrap[0]!='\0')
	{
		reg DTA  *dta=Fgetdta();
		reg char xpath[256];
		reg int  c = 0;

		strcat(_strmfp(xpath,scrap,"SCRAP."),extension);
		if(!Fsfirst(xpath,0))
		{
			c++;
			_strmfp(filename,scrap,dta->d_fname);
			while (!Fsnext()) c++;
			return (c);
		}
	}
	return (0);
}

void scrp_changed(int format,long best_ext)
{
	int msg[8];

    msg[0] = SC_CHANGED;
    msg[3] = format;
    msg[4] = (int) (best_ext>>16);
    msg[5] = (int) best_ext;
    msg[6] = msg[7] = 0;
	XAccBroadCast(msg);
}

char *_strmfp(char *dest,char *path,char *file)
{
	reg char *last;
	reg int len;

	if (path)
		strcpy(dest,path);

	if ((len = (int) strlen(dest))>0)
	{
		last = dest + len - 1;
		if (*last!='\\')
		{
			*++last = '\\';
			*++last = '\0';
		}
	}

	return(strcat(dest,file));
}
