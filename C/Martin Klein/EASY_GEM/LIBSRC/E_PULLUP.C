#include <easy_gem.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include <string.h>

extern int handle,_sbreite,_shoehe;


int pop_up(int x,int y,int taste,char *text)
{
	int b,h,t,tx,ty,my,onr,nr,dum;
	int tx2,len,anz=0,max=0;
	int *buff;
	char *tex2;
	
	tex2=text;
	while(*tex2)
	{
		len=(int)strlen(tex2);
		if(len>max) max=len;
		tex2+=(long)len+1;
		anz++;
	}
	b=max*8+10;
	h=(anz*16)+7;
	if(x+b>=_sbreite) x=_sbreite-1-b;
	if(y+h>=_shoehe) y=_shoehe-1-h;
	tx=x+5;
	ty=y+17;
	
	buff=alloc_mem(b,h);
	screen_to_form(x,y,b,h,buff);
	deffill(1,0,0);
	pbox(x,y,x+b,y+h);
	box(x+1,y+1,x+b-1,y+h-1);
	box(x+3,y+3,x+b-3,y+h-3);
	maus_aus();
	for(t=0;t<anz;t++)
	{
		len=(int)strlen(text);
		v_gtext(handle,tx+((max-len)<<2),ty,text);
		text+=(long)len+1;
		ty+=16;
	}
	maus_an();
	nr=onr=-1;
	vswr_mode(handle,3);
	deffill(1,1,0);
	tx2=tx+(max<<3)+1;
	if (!taste)
		while(maus_get(&dum,&dum)!=0);
	while(maus_get(&dum,&my)==taste)
	{
		if(my>y+4 && my<y+(anz<<4)+4)
			nr=(my-y-4)/16;
		else 
			nr=-1;
		if(onr!=nr)
		{
			if(onr!=-1)
				pbox(tx-1,y+(onr<<4)+19,tx2,(onr<<4)+y+4);
			if(nr!=-1)
				pbox(tx-1,y+(nr<<4)+19,tx2,(nr<<4)+y+4);
			onr=nr;
		}
	}
	if (!taste)
		while(maus_get(&dum,&dum)!=0);
	form_to_screen(x,y,b,h,3,buff);
	Mfree(buff);
	vswr_mode(handle,1);
	return nr+1;
}
