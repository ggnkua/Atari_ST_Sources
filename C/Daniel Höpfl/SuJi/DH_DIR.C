#include "dh_dir.h"

void *DHopendir(char *pfad)
{
	long err;
	long *ret;

	err=Dopendir(pfad,0);
	if((err & 0xff000000l)==0xff000000l)
	{
		ret=Malloc(sizeof(DTA)+sizeof(DTA *)+4+strlen(pfad)+4);
		if(ret)
		{
			ret[0]='Fsfi';
			ret[1]=(long) Fgetdta();
			Fsetdta((DTA *)&(ret[2]));
			strcpy((char *) &ret[2+sizeof(DTA)/sizeof(long)],pfad);
			strcat((char *) &ret[2+sizeof(DTA)/sizeof(long)],"*.*");
			err=Fsfirst((char *) &ret[2+sizeof(DTA)/sizeof(long)],0x17);

			if(err)
			{
				Mfree(ret);
				return 0l;
			}

			return (void *)ret;
		}
		else
		{
			return 0l;
		}
	}
	else
	{
		ret=Malloc(4+sizeof(long)+sizeof(DTA)+1024);
		if(ret)
		{
			ret[0]='Dope';
			ret[1]=err;

			return ret;
		}
		else
		{
			Dclosedir(err);

			return 0l;
		}
	}
}

int DHxreaddir(void *handle,DTA **info)
{
	long err=-1;
	DTA *dta;

	if(!handle)
		return -1;

	dta=(DTA *) (&((long *)handle)[2]);
	*info=dta;

	if(((long *)handle)[0]=='Fsfi' || ((long *)handle)[0]=='Fsne')
	{
		Fsetdta(dta);

		err=0l;

		if(((long *)handle)[0]=='Fsfi')
		{
			((long *)handle)[0]='Fsne';
		}
		else
		{
			dta->d_fname[0]='.';
			dta->d_fname[1]='\0';
		}

		while(dta->d_fname[0]=='.' && (dta->d_fname[1]=='\0' || 
			(dta->d_fname[1]=='.' && dta->d_fname[2]=='\0')))
		{
			err=Fsnext();

			if(err)
				dta->d_fname[0]='\0';
		}
	}
	else if(((long *)handle)[0]=='Dope')
	{
		XATTR xattr;
		long xr;

		do {
			err=Dxreaddir(1024,((long *)handle)[1],(char *)(((char *)&((long *)handle)[2])+sizeof(DTA)-18),&xattr,&xr);
			if((err==0 && xr==0) ||
				(err==0 && Fxattr(1,(char *)(((char *)&((long *)handle)[2])+sizeof(DTA)-18),&xattr)==0))
			{
				dta->d_attrib=xattr.attr;
				dta->d_time=xattr.mtime;
				dta->d_date=xattr.mdate;
				dta->d_length=xattr.size;

			}
			else
			{
				dta->d_fname[0]='\0';
				err=-1;
			}
		} while(dta->d_fname[0]=='.' && (dta->d_fname[1]=='\0' || 
			(dta->d_fname[1]=='.' && dta->d_fname[2]=='\0')));
	}

	return (int) err;
}

void DHclosedir(void *handle)
{
	if(!handle)
		return;

	if(((long *)handle)[0]=='Fsfi' || ((long *)handle)[0]=='Fsne')
	{
		Fsetdta((DTA *)((long *)handle)[1]);
		Mfree(handle);

		return;
	}

	if(((long *)handle)[0]=='Dope')
	{
		Dclosedir(((long *)handle)[1]);
		Mfree(handle);

		return;
	}
}
