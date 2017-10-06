/********************************************************************/
/*								WATOR_S.C							*/
/*					Simulations-Modul fÅr WATOR.PRG					*/
/*																	*/
/*	R. Geisler  1988							Sprache: Megamax C	*/
/********************************************************************/


#include <osbind.h>
#define XSIZE 75					/*	Maximalgrîûe des Ozeans		*/
#define YSIZE 45
#define EMPTY 32					/*	Codes fÅr Simulation		*/
#define FISH 250
#define SHARK 111
#define TRUE 1						/*	logische Werte				*/
#define FALSE 0


extern struct ocean					/*	Variablen fÅr Simulation...	*/
{	
	unsigned char state;
	char moved;
	int age;
	int starve;
}
pos[XSIZE][YSIZE];
extern int nfish, nshark, fbreed, sbreed, starve, xsize, ysize;


s_setup()							/*	Ozean vorbesetzen			*/
{	
	register int i, x, y;
	for(x=0; x<xsize; x++)
		for(y=0; y<ysize; y++)
			pos[x][y].state=EMPTY;
	for(i=0; i<nfish; i++)			/*	Fische setzen				*/
	{	
		do							/*	unbesetzte Position suchen	*/
		{	
			x=Random()%xsize;
			y=Random()%ysize;
		}
		while(pos[x][y].state!=EMPTY);
		pos[x][y].state=FISH;
		pos[x][y].age=Random()%fbreed;
	}
	for(i=0; i<nshark; i++)			/*	Haie setzen					*/
	{	
		do							/*	unbesetzte Position suchen	*/
		{	
			x=Random()%xsize;
			y=Random()%ysize;
		}
		while(pos[x][y].state!=EMPTY);
		pos[x][y].state=SHARK;
		pos[x][y].age=Random()%sbreed;
		pos[x][y].starve=Random()%starve;
	}
}


s_iterate()							/*	Iteration ausfÅhren			*/
{	
	register int x, y;
	for(x=0; x<xsize; x++)			/*	Flags lîschen				*/
		for(y=0; y<ysize; y++)
				pos[x][y].moved=FALSE;
	for(x=0; x<xsize; x++)			/*	Fische						*/
		for(y=0; y<ysize; y++)
			if(pos[x][y].state==FISH&&!pos[x][y].moved)
			{	
				pos[x][y].age++;
				move(x, y, FISH, fbreed, EMPTY);
			}
	for(x=0; x<xsize; x++)			/*	Haie						*/
		for(y=0; y<ysize; y++)
			if(pos[x][y].state==SHARK&&!pos[x][y].moved)
			{	
				pos[x][y].age++;
				pos[x][y].starve++;
				if(!move(x, y, SHARK, sbreed, FISH))
				{	
					if(pos[x][y].starve>=starve)
						pos[x][y].state=EMPTY;	/*	Hungertod		*/
					else
						move(x, y, SHARK, sbreed, EMPTY);
				}
			}
}


move(x1, y1, kind1, breed, kind2)	/*	Bewegung bzw. Vermehrung	*/
int x1, y1, kind1, breed, kind2;
{	
	register int n=0, r, xd, xi, yd, yi, x2[4], y2[4];
	xd=x1==0?xsize-1:x1-1;			/*	Nachbarkoordinaten			*/
	xi=x1==xsize-1?0:x1+1;
	yd=y1==0?ysize-1:y1-1;
	yi=y1==ysize-1?0:y1+1;
	if(pos[xd][y1].state==kind2)	/*	mîgliche Positionen suchen	*/
	{	
		x2[n]=xd; 
		y2[n++]=y1;	
	}
	if(pos[xi][y1].state==kind2)
	{	
		x2[n]=xi; 
		y2[n++]=y1;
	}
	if(pos[x1][yd].state==kind2)
	{
		x2[n]=x1; 
		y2[n++]=yd;
	}
	if(pos[x1][yi].state==kind2)
	{	
		x2[n]=x1; 
		y2[n++]=yi;
	}
	if(n==0)						/*	keine gefunden				*/
		return FALSE;
	r=Random()%n;					/*	Position auswÑhlen			*/
	if(kind2==FISH)					/*	Fisch fressen				*/
		pos[x1][y1].starve=0;
	pos[x2[r]][y2[r]].state=kind1;	/*	Position besetzen			*/
	pos[x2[r]][y2[r]].starve=pos[x1][y1].starve;
	if(pos[x1][y1].age>=breed)		/*	vermehren					*/
		pos[x2[r]][y2[r]].age=pos[x1][y1].age=Random()%3-1;
	else							/*	bewegen						*/
	{	
		pos[x2[r]][y2[r]].age=pos[x1][y1].age;
		pos[x1][y1].state=EMPTY;
	}
	pos[x2[r]][y2[r]].moved=TRUE;	/*	fertig: Flag setzen			*/
	return TRUE;
}
