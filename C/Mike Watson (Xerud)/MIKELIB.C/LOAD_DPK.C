#include	"tos.h"
#include	"dynamic.h"
#include	"load_dpk.h"


int load (char *filename)
{
	DTA *mydta=Fgetdta();
	int handle = Fopen (filename,2);
	int memhandle,newmemhandle;
	long *memp,*newmemp;
	if (handle <0)
		return(-1);
	if ((Fsfirst(filename,0x27))<0)
		return(-1);
	memhandle=AllocMem(mydta->d_length);
	memp=(long *)WhereMem(memhandle);
	if ((Fread (handle,mydta->d_length,memp))<0)
		return(-1);
	Fclose (handle);
	
	if ((*memp=='ICE!') || (*memp=='ATM5'))
	{
		newmemhandle = AllocMem(memp[2]);
		newmemp=(long *)WhereMem(newmemhandle);
		
		if (*memp=='ICE!')
			Depackice(memp,newmemp);
		else
			Depackatm5(memp,newmemp);
			
		FreeMem(memhandle);
		return(newmemhandle);
	}
	
	else
		return(memhandle);
}