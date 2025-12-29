#include <vdi.h>
#include <string.h>
#include <tos.h>

extern void maus_aus(void);
extern void maus_an(void);
extern int _sbytes,_shoehe,_splanes,handle;

void sget(char *buffer)
{
	long len;
	
	len=_sbytes*_shoehe;
	maus_aus();
	memcpy(buffer,Logbase(),len);
	maus_an();
}

void sput(char *buffer)
{
	long len;
	
	len=_sbytes*_shoehe;
	maus_aus();
	memcpy(Logbase(),buffer,len);
	maus_an();
}

void form_to_screen(int x,int y,int w,int h,int mode,int *daten)
{
	int punkt[8];
	static MFDB dest={0L},
					source;
	
	punkt[0]=punkt[1]=0;
	punkt[2]=w;
	punkt[3]=h;
	punkt[4]=x;
	punkt[5]=y;
	punkt[6]=x+w;
	punkt[7]=y+h;
	source.fd_addr=daten;
	source.fd_w=w;
	source.fd_h=h;
	source.fd_wdwidth=(w+15)>>4;
	source.fd_stand=0;
	source.fd_nplanes=_splanes;	
	
	maus_aus();
	vro_cpyfm(handle,mode,punkt,&source,&dest);
	maus_an();
}

void screen_to_form(int x,int y,int w,int h,int *daten)
{
	int punkt[8];
	static MFDB source={0L},
					dest;

	punkt[0]=x;
	punkt[1]=y;
	punkt[2]=x+w;
	punkt[3]=y+h;	
	punkt[4]=punkt[5]=0;
	punkt[6]=w;
	punkt[7]=h;
	dest.fd_addr=daten;
	dest.fd_w=w;
	dest.fd_h=h;
	dest.fd_wdwidth=(w+15)>>4;
	dest.fd_stand=0;
	dest.fd_nplanes=_splanes;	
	
	maus_aus();	
	vro_cpyfm(handle,3,punkt,&source,&dest);
	maus_an();	
}

int *alloc_mem(int w,int h)
{
	long anz;
	
	anz=(long)((w+15)>>4)*(h*2+2);
	anz*=_splanes;
	return (int *)Malloc(anz);
}
