/* scores.c */

/*********************************************/
/* you just keep on pushing my luck over the */
/*           BOULDER        DASH             */
/*                                           */
/*     Jeroen Houttuin, ETH Zurich, 1990     */
/*********************************************/

#include "header.h"
#include "bldrdash.h"

#define HALLNAME "bldrdash.hll"

#define AGEMAX 250

#ifndef VMS
#ifndef unix
#define cuserid(x) ""
#endif
#endif

typedef struct
		{
			char username[9];
			unsigned char level;
			unsigned char saved;
			unsigned char age;
		}
		player;

player hall[60];
char username[9];
int tri[60];
int numero= -1;
int classe=0;


void inclev()
{
	if (classe)
	if ((hall[numero].level>levelnum)||(keymap['0']))
	levelnum++;
}


void create_podium()
{
	int i;

	for(i=0;i<60;i++)
	{
		hall[i].saved=hall[i].level=hall[i].username[0]=0;
		hall[i].age=AGEMAX;
	}

	bmake(HALLNAME,hall,(long)sizeof(hall));

}



void classement()
{
	int i,ok,t,min;

	classe=0;

	if (!bexist(HALLNAME)) create_podium();

	while(bload(HALLNAME,hall,0L,(long)sizeof(hall))) waitdelay(1000);

	numero= -1;
	for(i=0;i<60;i++)
		if (!strcmp(hall[i].username,username)) numero=i;
		
	if (numero!= -1) classe=1;

	if (classe) hall[numero].age=0;

	if (!classe)
	{
		min=MAXTABLEAUX+10;
		numero= -1;
		for(i=0;i<60;i++)
			if (((int)hall[i].level<min)&&
				((int)hall[i].age>=AGEMAX))
			{
				min=(int)hall[i].level;
				numero=i;
			}
			
		if (numero== -1)
		{		
			if (!bload(HALLNAME,hall,0L,
				(long)sizeof(hall)))
			{

				for(i=0;i<60;i++)
					if ((int)hall[i].age<AGEMAX)
						hall[i].age++;

				bmake(HALLNAME,hall,(long)sizeof(hall));
			}

			min=MAXTABLEAUX+10;
			numero= -1;
			for(i=0;i<60;i++)
				if (((int)hall[i].level<min)&&
					((int)hall[i].age>=AGEMAX))
				{
					min=(int)hall[i].level;
					numero=i;
				}

		}

		
		if (numero!= -1)
		{
			classe=1;
			sprintf(hall[numero].username,username);
			hall[numero].level=levelnum;
			hall[numero].age=hall[numero].saved=0;
			while(bsave(HALLNAME,&hall[numero],numero*(long)sizeof(player),
				(long)sizeof(player))) waitdelay(1000);
		}
	}	

	for(i=0;i<60;i++)
		tri[i]=i;
		
	ok=0;
	while(!ok)
	{
		ok=1;
		for(i=0;i<59;i++)
		if (hall[tri[i]].level<hall[tri[i+1]].level)
		{
			ok=0;
			t=tri[i];
			tri[i]=tri[i+1];
			tri[i+1]=t;
		}
	}

}



void podium()
{
	int i,j,k,n;
	char s[40];

	setcolor(15);
	afftext(160-3*8,8,"podium");
	afftext(160-6*8-4,16,"boulder dash!");

	classement();

	for(j=0;j<3;j++)
		for(i=0;i<20;i++)
		{
			n=tri[i+j*20];
			if (hall[n].username[0])
			{
				if ((int)hall[n].level>=MAXTABLEAUX)
					sprintf(s," %s win",hall[n].username);
				else
					sprintf(s," %s %d",hall[n].username,hall[n].level);
				for(k=0;s[k];k++) if (s[k]=='_') s[k]=' ';
				afftext(j*8*13,(4+i)*8,s);
			}
		}

}



void save_hall()
{
	classement();

	if ((classe)&&(levelnum>(int)hall[numero].level))
	{
		hall[numero].level=(unsigned char)(levelnum);
		while(bsave(HALLNAME,&hall[numero],numero*(long)sizeof(player),
			(long)sizeof(player))) waitdelay(1000);
	}
}


void get_username()
{
	int i;
	char r;
	char s[80];

	hide();

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

	cls();
	swap();
	cls();
	save_hall();
	if (classe) levelnum=(int)hall[numero].level;
}
