/* scores.c */

#include "header.h"

#ifndef VMS
#ifndef unix
#define cuserid(x) ""
#endif
#endif

extern long Sc;

int tri[40];

#define HALLNAME "qbert.hll"

char username[9];

typedef struct
		{
			char username[9];
			unsigned char parts[3];
		}
		player;

player hall[40];

#define HALL(a,b) hall[a].parts[b]
#define SCORE(i) HALL(i,0)*65536L+HALL(i,1)*256L+(long)HALL(i,2)



void create_podium()
{
	int i;

	for(i=0;i<40;i++)
	{
		hall[i].username[0]=hall[i].username[0]=0;
		hall[i].parts[0]=hall[i].parts[0]=0;
		hall[i].parts[1]=hall[i].parts[1]=0;
		hall[i].parts[2]=hall[i].parts[2]=0;
	}

	bmake(HALLNAME,hall,(long)sizeof(hall));
}



void podium()
{
	int i,j,n,ok,t,k;
	char s[40];

	cls();

	setcolor(15);
	afftext(160-3*8,8,"podium");
	afftext(160-3*8,16,"qbert!");

	if (!bexist(HALLNAME)) create_podium();

	while(bload(HALLNAME,hall,0L,(long)sizeof(hall))) waitdelay(1000);

	for(i=0;i<40;i++)
		tri[i]=i;
		
	ok=0;
	while(!ok)
	{
		ok=1;
		for(i=0;i<39;i++)
		if (SCORE(tri[i])<SCORE(tri[i+1]))
		{
			ok=0;
			t=tri[i];
			tri[i]=tri[i+1];
			tri[i+1]=t;
		}
	}


	for(j=0;j<2;j++)
		for(i=0;i<20;i++)
		{
			n=tri[i+j*20];
			if (hall[n].username[0])
			{
				sprintf(s," %s  %07ld0",hall[n].username,SCORE(n));
				for(k=0;s[k];k++) if (s[k]=='_') s[k]=' ';
				afftext(j*8*20,(4+i)*8,s);
			}
		}

	swap();

	while(!keyhit()) waitdelay(500);
	empty();
}



void save_hall()
{
	int numero,i;
	unsigned long min;

	if (!bexist(HALLNAME)) create_podium();

	while(bload(HALLNAME,hall,0L,(long)sizeof(hall))) waitdelay(1000);

	numero= -1;
	for(i=0;i<40;i++)
		if (!strcmp(hall[i].username,username)) numero=i;

	if (numero!= -1)
	{
		if (Sc<=SCORE(numero)) numero= -1;
	}
	else
	{
		min=Sc;
		for(i=0;i<40;i++)
			if (SCORE(i)<min)
			{
				min=SCORE(i);
				numero=i;
			}
	}

	if (numero!= -1)
	{
		sprintf(hall[numero].username,username);
		hall[numero].parts[0]=(unsigned char)(Sc/65536L);
		hall[numero].parts[1]=(unsigned char)((Sc%65536L)/256L);
		hall[numero].parts[2]=(unsigned char)(Sc%256L);
		while(bsave(HALLNAME,&hall[numero],numero*(long)sizeof(player),
			(long)sizeof(player))) waitdelay(1000);
	}


}



void get_username()
{
	int i;
	char r;
	char s[80];

	sprintf(username,"        ");
	sprintf(s,cuserid(0));

	if (s[0])	
	{
		i=0;
		while((s[i])&&(i<8))
		{
			username[i]=s[i];
			i++;
		}
	}
	else
	{
		i=0;
		r=0;
		while(r!=13)
		{
			cls();
			setcolor(15);
			afftext(160-6*8,100-4,"nom:");
			afftext(160-2*8,100-4,username);
			affchar(160-2*8+8*i,100-4,'_');
			swap();
			
			while(!kbhit()) waitdelay(100);
			r=getch();
			if ((r==8)&&(i))
				username[--i]=' ';
			else
				if ((r>=' ')&&(i<8))
					username[i++]=r;			
		}
	
	}

}


