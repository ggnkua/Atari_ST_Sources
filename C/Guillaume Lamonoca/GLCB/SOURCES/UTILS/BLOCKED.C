/* blocked.c : editeur de bloc graphique */

#include <stdio.h>
#include "header.h"


int LX=16;
int LY=16;
int tab[32][32];
int quit=0;
int lcolor=15;
int rcolor=0;
int m=0;
int sl=0;

unsigned int pal[16];

typedef void *bloc;

bloc backup;

char filename[15];

char username[9]="blocfile";

void get_username()
{
	int i;
	char r;

	{
		i=0;
		while(username[i]) i++;
		r=0;
		while(r!=13)
		{
			cls();
			setcolor(15);
			if (sl)
				afftext(160-9*8,100-4,"charge:");
            else
				afftext(160-8*8,100-4,"sauve:");
			afftext(160-2*8,100-4,username);
			affchar(160-2*8+8*i,100-4,'_');
			swap();
			
			while(!kbhit()) waitdelay(100);
			r=getch();
			if ((r==8)&&(i))
				username[--i]=0;
			else
				if ((r>' ')&&(i<8))
					username[i++]=r;			
		}
	
	}

	sprintf(filename,"%s.c",username);

}




void load()
{
	int i,j,v;
	FILE *fp;
	char c;

    sl=1;
	get_username();

	if (bexist(filename))
	{
		fp=fopen(filename,"r");

		if (fp)
		{
			v=0;
			while ((fscanf(fp,"%d",&v))==0)
				fscanf(fp,"%c",&c);

			if (v==16)
			{

				for(i=0;i<16;i++)
					while ((fscanf(fp,"0x%x",&pal[i]))==0)
						fscanf(fp,"%c",&c);

				while ((fscanf(fp,"%d",&LY))==0)
					fscanf(fp,"%c",&c);

				while ((fscanf(fp,"%d",&LX))==0)
					fscanf(fp,"%c",&c);

				if ((LY>0)&&(LX>0)&&(LY<33)&&(LX<33))
				{
					for(i=0;i<LY;i++)
					{
						while ((fscanf(fp,"\"%c",&c))==0)
							fscanf(fp,"%c",&c);

						for(j=0;j<LX;j++)
						{
							if (j) fscanf(fp,"%c",&c);
							if (c<'A')
								c-='0';
							else
								if (c<'a')
									c-='A'-10;
								else
									c-='a'-10;
							tab[i][j]=((unsigned int)c)&15;
						}

						while ((fscanf(fp,"\"%c",&c))==0)
							fscanf(fp,"%c",&c);
					}
				}
				else
				{
					LX=16;
					LY=16;
				}

			}

			fclose(fp);
		}
	}	
}


void save()
{
	int i,j;
	FILE *fp;

    sl=0;
	get_username();

	fp=fopen(filename,"w");

	if (fp)
	{
		fprintf(fp,"unsigned int gamepal[16]=\n{\n\t");
		for(i=0;i<3;i++)
		{
			for(j=0;j<4;j++)
				fprintf(fp,"0x%04x,",pal[i*4+j]);
			fprintf(fp,"\n\t");
		}
		for(j=0;j<3;j++)
			fprintf(fp,"0x%04x,",pal[3*4+j]);
		fprintf(fp,"0x%04x\n};\n\nchar *%s[%d]=  /* %d en largeur */\n{\n\t\"",pal[15],username,LY,LX);
		for(i=0;i<LY;i++)
		{
			for(j=0;j<LX;j++)
				fprintf(fp,"%x",tab[i][j]);
			if (i==LY-1) fprintf(fp,"\"\n};\n");
			else fprintf(fp,"\",\n\t\"");
		}
		fclose(fp);
	}
}



void getbackup()
{
	getbloc(&backup,0,0,320,200);
}

void putbackup()
{
	putbloc(&backup,0,0);
}



void putpalette()
{
	int i,j,c;
	char s[10];

	for(i=0;i<LY;i++)
		for(j=0;j<LX;j++)
		{
			c=tab[i][j];
			pbox(2+j*6,2+i*6,5,5,c);
			plot(208+j,16+i,c);
		}

	if (!m)
	for(i=0;i<16;i++)
	{
		m=1;
		pbox(220,64+i*8,20,8,i);
		pbox(240,64+i*8,80,8,0);
		sprintf(s,"%04x",pal[i]);
		setcolor(15);
		for(j=0;j<4;j++) affchar(240+j*20+6,64+i*8,s[j]);
	}
	pbox(220,64-8,60,8,0);
	setcolor(15);
	sprintf(s,"%02d",LX);
	afftext(240+2,64-8,s);
	sprintf(s,"%02d",LY);
	afftext(280+2,64-8,s);
	affchar(260+6,64-8,'x');

	setcolor(15);
	affchar(208,64+8*rcolor,'d');
	affchar(200,64+8*lcolor,'g');

	afftext(320-6*8,0,"sauver");
	afftext(320-7*8,8,"charger");
	afftext(320-7*8,16,"effacer");
	afftext(320-7*8,24,"quitter");

}

void initeditor()
{

	getpalette(pal);

	cls();	

    m=0;
	dbox(1,1,LX*6+1,LY*6+1,15);

	putpalette();
		
	getbackup();
	swap();
	putbackup();
}


void do_click(k,x,y)
int k,x,y;
{
	char s[10];
	int c,i,j;

	if (k==3) k=1;

	if (x>200)
	{
		x=(x-200)/20;
		y/=8;
		if (y==0)
		{
			save();
			initeditor();
        }
		else
		if (y==1)
		{
			load();
			setpalette(pal);
			initeditor();
		}
		else
		if (y==2)
		{
			for(i=0;i<32;i++)
				for(j=0;j<32;j++)
					tab[i][j]=0;
			initeditor();
		}
		else
		if (y==3) quit=1;
		else
		if ((y==7)&&((x==2)||(x==4)))
		{
			dbox(1,1,LX*6+1,LY*6+1,0);
			if ((x==2)&&(k==2)&&(LX<32)) LX++;
			if ((x==4)&&(k==2)&&(LY<32)) LY++;
			if ((x==2)&&(k==1)&&(LX>1)) LX--;
			if ((x==4)&&(k==1)&&(LY>1)) LY--;
			pbox(240,64-8,60,8,0);
			setcolor(15);
			sprintf(s,"%02d",LX);
			afftext(240+2,64-8,s);
			sprintf(s,"%02d",LY);
			afftext(280+2,64-8,s);
			affchar(260+6,64-8,'x');
			dbox(1,1,LX*6+1,LY*6+1,15);
			getbackup();
			swap();
			putbackup();
		}
		if ((y>7)&&(y<24)&&(x))
		{
			y-=8;
			pbox(208,64+8*rcolor,8,8,0);
			pbox(200,64+8*lcolor,8,8,0);

			switch(x)
			{
				case 1:
				if (k==1)
					lcolor=y;
				else
					rcolor=y;
				break;

				case 2:
				if (k==2)
					pal[y]=(pal[y]&0xfff)+((((pal[y]>>12)+10)%9)<<12);
				else
					pal[y]=(pal[y]&0xfff)+((((pal[y]>>12)+8)%9)<<12);
				break;					

				case 3:
				if (k==2)
					pal[y]=(pal[y]&0xf0ff)+(((((pal[y]>>8)&15)+17)%16)<<8);
				else
					pal[y]=(pal[y]&0xf0ff)+(((((pal[y]>>8)&15)+15)%16)<<8);
				break;

				case 4:
				if (k==2)
					pal[y]=(pal[y]&0xff0f)+(((((pal[y]>>4)&15)+17)%16)<<4);
				else
					pal[y]=(pal[y]&0xff0f)+(((((pal[y]>>4)&15)+15)%16)<<4);
				break;					

				case 5:
				if (k==2)
					pal[y]=(pal[y]&0xfff0)+(((((pal[y])&15)+17)%16));
				else
					pal[y]=(pal[y]&0xfff0)+(((((pal[y])&15)+15)%16));
				break;


			}					

			setpalette(pal);

			pbox(220,64+y*8,20,8,y);
			pbox(240,64+y*8,80,8,0);
			sprintf(s,"%04x",pal[y]);
			setcolor(15);
			for(j=0;j<4;j++) affchar(240+j*20+6,64+y*8,s[j]);

			setcolor(15);
			affchar(208,64+8*rcolor,'d');
			affchar(200,64+8*lcolor,'g');


			if (x>=2) putpalette();

			getbackup();
			swap();
			putbackup();
		}
	}
	else
	{
		x=(x-2)/6;
		y=(y-2)/6;
		if ((x>=0)&&(y>=0)&&(x<LX)&&(y<LY))
		{
			if (k==1) tab[y][x]=lcolor;
			if (k==2) tab[y][x]=rcolor;
			c=tab[y][x];
			pbox(2+x*6,2+y*6,5,5,c);
			plot(208+x,16+y,c);
			swap();
			pbox(2+x*6,2+y*6,5,5,c);
			plot(208+x,16+y,c);
		}
	}

}



int main()
{
	int k,x,i,j;

	if (initsystem())
	{
		initbloc(&backup);
		for(i=0;i<32;i++)
			for(j=0;j<32;j++)
				tab[i][j]=0;

		getpalette(pal);

		initeditor();

		while(!quit)
		{
			while(!getmouse()) waitdelay(200);

			if (msek<3) do_click(msek,msex,msey);

			while((k=mousek)&&((x=mousex)<200))
            {
				do_click(k,x,mousey);
				buthit();
            }
		}

		freebloc(&backup);
		killsystem();
	}

	return 0;
}

