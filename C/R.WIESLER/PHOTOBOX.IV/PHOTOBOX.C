/*  PHOTOBOX  */
/*  (C) R.WIESLER 1989  */
/* photo_10 */

#include <stdlib.h>

/*#include <time.h>*/

void zufall_1(void);
void zufall_2(void);
void muster(void);

typedef struct {
	unsigned int  was;
	unsigned int  *adresse;										
	unsigned int  h1;
	unsigned int  h2;
	unsigned int  h3;
	unsigned int  h4;
	unsigned int  d1;
	unsigned int  d2;
	unsigned int  d3;
	unsigned int  d4;
	unsigned int  s1;
	unsigned int  s2;
	unsigned int  s3;
	unsigned int  s4;
	unsigned int  w1;
	unsigned int  w2;
	unsigned int  w3;
	unsigned int  w4;
	unsigned int z_hell;										
	unsigned int z_dunkel;										
	unsigned int *schirm;									
	unsigned int zufallszahl;
}*ZEIGER;

ZEIGER adr;

void cdecl photobox(ZEIGER adr)
{
	switch(adr->was)
	{
	case 1: muster();	break;
	case 2: zufall_1();	break;
	case 3: zufall_2();	break;
	}
}

/* zufall_1  */

void zufall_1()
{
	unsigned int wa,wb,c,potenz;											
	unsigned int *k,*l,k1,l1,*retour;										
	register unsigned int i,j,bit;
	int wert_0;
	srand(adr->zufallszahl % 37);																
	for (i=0;i < 400;i++)	 			
		{
		for (j=0;j < 80;j+=2)
			{
			k=(unsigned int *) adr->adresse;							
			adr->adresse+=2;											
			l=k+1;
			wert_0=0;
			potenz=1;
			k1=*k;
			l1=*l;
			for(bit=1;bit<17;bit++)
				{
				wa=k1 & 1;
				wb=l1 & 1;
				c=0;
				if (wa == 1)
					{
					if (wb == 1)
						c=potenz;
					else
						{
						if (rand()<adr->z_hell)
							c=potenz;
						}
					}
				else
					{
					if (wb == 1)
						{
						if (rand()<adr->z_dunkel)
							c=potenz;
						}
					}
				wert_0+=c;
				potenz*=2;
				k1 = k1 >> 1;
				l1 = l1 >> 1;
			}
			
			retour=(unsigned int *)adr->schirm + i*40 + (j/2);		
			*retour=wert_0;											
			}
 		}
}


void zufall_2()
{
	unsigned int wa,wb,c,potenz;											
	unsigned int *k,*l,k1,l1,*retour;										
	register unsigned int i,j,bit;
	int wert_0,mark1,mark2;
	srand(adr->zufallszahl % 37);
	mark1=0;
	mark2=0;
													
	for (i=0;i < 400;i++)	 			
		{
		for (j=0;j < 80;j+=2)
			{
			k=(unsigned int *) adr->adresse;							
			adr->adresse+=2;											
			l=k+1;
			wert_0=0;
			potenz=1;
			k1=*k;
			l1=*l;
			for(bit=1;bit<17;bit++)
				{
				wa=k1 & 1;
				wb=l1 & 1;
				c=0;
				if (wa == 1)
					{
					if (wb == 1)
						c=potenz;
					else
						{
						if (rand()<adr->z_hell)
							{
							if (mark1 == 1)
								{
								c=potenz;
								mark1 = 0;
								}
							else
								mark1 = 1;
							}
						}
					}
				else
					{
					if (wb == 1)
						{
						if (rand()<adr->z_dunkel)
							{
							c=potenz;
							mark2 = 0;
							}
						else
							{
							if (mark2 == 1)
								{
								c=potenz;
								}
							else
								{
								mark2 = 1;
								}																								
							}
						}
					}
				wert_0+=c;
				potenz*=2;
				k1 = k1 >> 1;
				l1 = l1 >> 1;
			}
			
			retour=(unsigned int *)adr->schirm + i*40 + (j/2);		
			*retour=wert_0;										
			}
 		}

}


/* muster  */

void muster()
{
	unsigned int *k,*l,*retour;									
	int wert_0;
	int i,j;													
	int schwarz,weiss,hell,dunkel;								
	int *schirm;												


	for (i=0;i < 400;i++)	 			
		{
		for (j=0;j < 80;j+=2)
			{
			k=(unsigned int *) adr->adresse;							
			adr->adresse+=2;											
			l=k+1;
			schwarz=*k & *l;									
			weiss=  (~ *k) & (~ *l);
			hell=   *l & (~ *k);
			dunkel= *k & (~ *l);
			
			if (i % 4 == 0)										
				{
				dunkel&=adr->d1;
				hell&=adr->h1;
				schwarz&=adr->s1;
				weiss&=adr->w1;
				}
			else
				{
				if (i % 4 == 1)
					{
					dunkel&=adr->d2;
					hell&=adr->h2;
					schwarz&=adr->s2;
					weiss&=adr->w2;
					}
				else
					{
					if (i % 4 == 2)
						{
						dunkel&=adr->d3;
						hell&=adr->h3;
						schwarz&=adr->s3;
						weiss&=adr->w3;
						}		
					else
						{
						dunkel&=adr->d4;
						hell&=adr->h4;
						schwarz&=adr->s4;
						weiss&=adr->w4;
						}
				
					}			
			}
			wert_0=schwarz | weiss;								
			wert_0|=hell;
			wert_0|=dunkel;
			retour=(unsigned int *)adr->schirm + i*40 + (j/2);		
			*retour=wert_0;											
			}
 		}
}


/* alles vorbei */


