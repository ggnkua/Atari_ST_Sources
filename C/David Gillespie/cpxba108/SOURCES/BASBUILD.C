#include <tos.h>
#include <aes.h>
#include <portab.h>
#include <string.h>
#include "xcontrol.h"

#define VERS	0x107

CPXHEAD head;
typedef struct PH
{
	int ph_branch;
	long ph_tlen;
	long ph_dlen;
	long ph_blen;
	long ph_slen;
	long ph_res1;
	long ph_prgflags;
	int ph_absflag;
}
PH;

char buffer[60000L];

#define CPXPFAD ""
#define PRGPFAD "D:\\purec\\CPXBASIC.107\\PROG\\"
#define CLIPP	"BASICA00.CPX"

char *cpx[4]=
{
	CPXPFAD"BASIC000.CPX",
	CPXPFAD"BASIC030.CPX",
	CPXPFAD"BASICA00.CPX",
	CPXPFAD"BASICA30.CPX",
};

char *prg[4]=
{
	PRGPFAD"BASIC000.PRG",
	PRGPFAD"BASIC030.PRG",
	PRGPFAD"BASICA00.PRG",
	PRGPFAD"BASICA30.PRG",
};

void out(int i,char *s)
{
	char *form="Lesefehler   : ";
	if(i>0) form="Schreibfehler: ";
	if(i<0) form="bearbeite    : ";
	Cconws(form);Cconws(s);Cconws("\r\n");
}

main()
{
	int fh,i,ret=1;
	long size;
	PH *ph=(PH*)&buffer;
	char *vers;
	long len;
	appl_init();
	graf_mouse(M_OFF,NULL);
	Cconws("\033E");
	for(i=0;i<4;i++)
	{
		fh=(int)Fopen(cpx[i],0);
		if(fh<=0)
		{
			out(0,cpx[i]);
			continue;
		}
		Fread(fh,sizeof(CPXHEAD),&head);
		Fclose(fh);
		break;
	}
	if(i<4)
	{
		head.cpx_version=VERS;
		for(i=0;i<4;i++)
		{
			out(-1,cpx[i]);
			fh=(int)Fopen(prg[i],0);
			if(fh<=0)
			{
				out(0,prg[i]);
				continue;
			}
			size=Fread(fh,60000L,buffer);
			Fclose(fh);
			vers=buffer+ph->ph_tlen;
			len=ph->ph_dlen;
			while(len-->0 &&(
					vers[0]!='v'||
					vers[1]!='X'||
					vers[2]!='.'||
					vers[3]!='y'||
					vers[4]!='z')) vers++;
			if(len>0)
			{
				vers[1]=(VERS>>8)+'0';
				vers[3]=((VERS>>4)&0xf)+'0';
				vers[4]=(VERS&0xf)+'0';
			}
			fh=(int)Fcreate(cpx[i],0);
			if(fh<=0)
			{
				out(1,cpx[i]);
				continue;
			}
			Fwrite(fh,sizeof(head),&head);
			Fwrite(fh,size,buffer);
			Fclose(fh);
			if(i==2)
			{
				out(-1,CLIPP);
				fh=(int)Fcreate(CLIPP,0);
				if(fh<=0)
				{
					out(1,CLIPP);
					continue;
				}
				Fwrite(fh,sizeof(head),&head);
				Fwrite(fh,size,buffer);
				Fclose(fh);
			}
		}
		ret=0;
	}
	graf_mouse(M_ON,NULL);
	appl_exit();
	return ret;
}

