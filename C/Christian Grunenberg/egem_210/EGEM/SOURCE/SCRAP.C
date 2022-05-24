
#include <string.h>
#include <stdio.h>
#include "proto.h"

void _scrp_init(void)
{
	reg char scrap[MAX_PATH],*path;
	reg long handle,len;

	scrp_read(scrap);
	if (scrap[0]=='\0')
	{
		if ((path=getenv("CLIPBOARD"))!=NULL || (path=getenv("CLIPBRD"))!=NULL || (path=getenv("SCRAPDIR"))!=NULL)
			strcpy(scrap,path);
		else
		{
			reg long ssp;

			strcpy(scrap,"X:\\clipbrd");
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
			return;
		}
	}

	scrp_write("");
}

int scrp_path(char *path,char *file)
{
	scrp_read(path);
	if (path[0])
	{
		MakeFullpath(path,NULL,(file) ? file : "");
		return (TRUE);
	}
	else
		return (FALSE);
}

void scrp_clear(int all)
{
	reg char scrap[MAX_PATH];

	if (scrp_path(scrap,(all) ? "*.*" : "scrap.*"))
	{
		reg DTA *old = Fgetdta(), dta;
		reg char fname[MAX_PATH];

		Fsetdta(&dta);
		if (!Fsfirst(scrap,0))
		{
			strcpy(fname,scrap);
			do
			{
				strcpy(GetFilename(fname),dta.d_fname);
				Fdelete(fname);
			}
			while (!Fsnext());
		}
		Fsetdta(old);
	}
}

long scrp_length()
{
	reg long length = 0;
	char scrap[MAX_PATH];

	if (scrp_path(scrap,"scrap.*"))
	{
		reg DTA *old = Fgetdta(), dta;

		Fsetdta(&dta);
		if (!Fsfirst(scrap,0))
			do
				length += dta.d_length;
			while (!Fsnext());
		Fsetdta(old);
	}

	return (length);
}

int	scrp_find(char *extension,char *filename)
{
	int exit = FALSE;
	char scrap[MAX_PATH];

	if (scrp_path(scrap,"scrap.*"))
	{
		reg DTA *old = Fgetdta(), dta;
		reg char path[MAX_PATH],ext_buf[MAX_PATH],*ext,*sep=" ,.";

		Fsetdta(&dta);
		if (!Fsfirst(scrap,-1))
		{
			strcpy(path,scrap);
			*GetFilename(scrap) = '\0';

			ext = strtok(strcpy(ext_buf,extension),sep);
			while (ext!=NULL)
			{
				strcpy(GetExtension(path)+1,ext);
				if (!Fsfirst(path,-1) && (dta.d_attrib & 0x18)==0)	/* (FA_LABEL|FA_DIR) */
				{
					MakeFullpath(filename,scrap,dta.d_fname);
					exit = TRUE;
					break;
				}
				ext = strtok(NULL,sep);
			}
		}
		Fsetdta(old);
	}

	return (exit);
}

void scrp_changed(int format,long best_ext)
{
	XAcc *av;
	char *scrap;
	int msg[8];

	msg[0] = SC_CHANGED;
	msg[3] = format;
	msg[4] = (int) (best_ext>>16);
	msg[5] = (int) best_ext;
	msg[6] = msg[7] = 0;
	XAccBroadCast(msg);

	if ((av=find_id(AvServer))!=NULL && (av->va_msgs & MSG_PATH_UPDATE) && (scrap=GetMsgBuffer(MAX_PATH))!=NULL)
	{
		scrp_path(scrap,NULL);
		*(char **) &msg[3] = scrap;
		AvSendMsg(AvServer,AV_PATH_UPDATE,msg);
		Mfree(scrap);
	}
}
