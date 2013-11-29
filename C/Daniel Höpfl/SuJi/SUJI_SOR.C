#include "SuJi_glo.h"

int sort_by=2;

int tausch(FILE_INFO *a,FILE_INFO *b);

char ___upper_char_string___[256]=
	{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,
	20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,
	40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,
	60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,
	80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,

		/* "a-z" -> "A-Z" */
	65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,
	85,86,87,88,89,90,

	123,124,125,126,127,128,

		/* "" -> "š" */
	154,
	
	130,131,
	
		/* "„" -> "Ž" */
	142,
	
	133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,

		/* "”" -> "™" */
	153,

	149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,
	164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,
	179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,
	194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,
	209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,
	224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,
	239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,
	254,255};

int qsort_compare(FILE_INFO **elem1, FILE_INFO **elem2)
{
	return tausch(*elem1,*elem2);
}

#define MAX_TIEFE_FUER_QSORT	10
#define MAX_ZAHL_DER_ELEMENTE_BIS_BSORT	4

void Qsort(FILE_INFO *feld[],unsigned long anzahl)
{
	static int tiefe=0;

	if(tiefe<MAX_TIEFE_FUER_QSORT && anzahl>MAX_ZAHL_DER_ELEMENTE_BIS_BSORT)
	{
		unsigned long i,last;

		{
			void *x;
		
			x=feld[(anzahl-1)/2];
			feld[(anzahl-1)/2]=feld[0];
			feld[0]=x;
		}

		last=0;
		for(i=1;i<=(anzahl-1);i++)
		{
			if(tausch(feld[i],feld[0])<0)
			{
				void *x;
			
				x=feld[++last];
				feld[last]=feld[i];
				feld[i]=x;
			}
		}

		{
			void *x;
		
			x=feld[last];
			feld[last]=feld[0];
			feld[0]=x;
		}
	
		if(last>1)
			Qsort(feld,last);
		if(anzahl>last+2)
			Qsort(&(feld[last+1]),anzahl-1-last);
	}
	else
	{
		unsigned long i,j;
		int opti=1;

		if(anzahl<=1)
			return ;

		for(i=1;i<anzahl && opti;i++)
		{
			opti=0;
			for(j=anzahl-1;j>=i;j--)
			{
				if(tausch(feld[j],feld[j-1])<0)
				{
					void *help;

					opti=1;

					help=feld[j];
					feld[j]=feld[j-1];
					feld[j-1]=help;
				}
			}
		}
	}
}

void sortiere_neu(int by)
{
	register FILE_INFO *help;
	register FILE_INFO *help2;
	FILE_INFO **hash;

	if(by==sort_by)
		by=-by;

	sort_by=by;

	if(!first_fi.next || !first_fi.next->next)
		return;

	mt_wind_update(BEG_MCTRL,&global);
	set_mouse(BUSYBEE);

	hash=malloc(finfos*sizeof(FILE_INFO *));
	if(hash)
	{ /* Schneller sortieren, aber mit etwas Speicherbedarf. */
		unsigned long ul=0;

		/* Hash-Table fllen */
		help=first_fi.next;
		while(help)
		{
			hash[ul++]=help;
			help=help->next;
		}

			/* Quicksort */
		Qsort(hash,finfos);
/*		qsort(hash,finfos,sizeof(FILE_INFO *),qsort_compare);
*/
		help=&first_fi;
		for(ul=0;ul<finfos;ul++)
		{
			help=help->next=hash[ul];
		}

		help->next=NULL;
		last_fi=help;

		for(ul=finfos-1;ul>0;ul--)
		{
			help=help->prev=hash[ul-1];
		}

		help->prev=NULL;

		free(hash);
	}
	else
	{ /* Langsamer, aber kommt ohne Hilfsspeicher aus: */
		help=first_fi.next;
		while(help)
		{
			help2=last_fi;
			while(help2!=help)
			{
				if(tausch(help2->prev,help2) > 0)
				{
					register FILE_INFO *x,*y;
					register FILE_INFO *lx,*rx;
					register FILE_INFO *ly,*ry;
	
					x=help2->prev;
					y=help2;
	
					lx=x->prev;
					rx=x->next;
					ly=y->prev;
					ry=y->next;
	
					if(x!=ly && y!=rx)
					{
						if(lx)
							lx->next=y;
						if(rx)
							rx->prev=y;
						if(ly)
							ly->next=x;
						if(ry)
							ry->prev=x;
	
						x->next=ry;
						x->prev=ly;
	
						y->next=rx;
						y->prev=lx;
					}
					else
					{
						y->prev=lx;
						if(lx)
							lx->next=y;
	
						x->next=ry;
						if(ry)
							ry->prev=x;
	
						x->prev=y;
						y->next=x;
					}
	
					if(help2==last_fi)
						last_fi=x;
	
					help2=x;
	
					if(help==x)
						help=y;
				}
	
				if(help2)
					help2=help2->prev;
			}
	
			help=help->next;
		}
	}

	get_from_list(0);

	set_mouse(ARROW);
	mt_wind_update(END_MCTRL,&global);
}

int tausch(FILE_INFO *a,FILE_INFO *b)
{
	if(!b || !a || a==b)
		return 0;

	if(sort_by>2 || sort_by<-2)
	{
		if(((sort_by==3 || sort_by==-3) && a->size == b->size) ||
			((sort_by==4 || sort_by==-4) && a->time == b->time) ||
			((sort_by==5 || sort_by==-5) && a->date == b->date && a->time==b->time) ||
			((sort_by==6 || sort_by==-6) && a->attrib == b->attrib) ||
			((sort_by==7 || sort_by==-7) && my_strcmp(a->pfad,b->pfad) == 0))
		{
			return sort_by*my_strcmp(a->name,b->name);
		}
	}

	if(sort_by==1)
	{ /* Lesereihenfolge */
		if(a->read_nr > b->read_nr)
			return 1;
		else if(a->read_nr == b->read_nr)
			return 0;

		return -1;
	}
	if(sort_by==2)
	{ /* Name */
		return my_strcmp(a->name,b->name);
	}
	if(sort_by==3)
	{ /* Gr”že */
		if(a->size > b->size)
			return 1;
		else if(a->size == b->size)
			return 0;
		return -1;
	}
	if(sort_by==4)
	{ /* Zeit */
		if(a->time > b->time)
			return 1;
		if(a->time == b->time)
			return 0;
		return -1;
	}
	if(sort_by==5)
	{ /* Datum */
		if(a->date > b->date)
			return 1;
		if(a->date == b->date)
		{ /* Untersortierung nach Zeit */
			if(a->time > b->time)
				return 1;
			if(a->time == b->time)
				return 0;
			return -1;
		}
		return -1;
	}
	if(sort_by==6)
	{ /* Attribut */
		if(a->attrib > b->attrib)
			return 1;
		if(a->attrib == b->attrib)
			return 0;
		return -1;
	}
	if(sort_by==7)
	{ /* Ursprung */
		return my_strcmp(a->pfad,b->pfad);
	}


	if(sort_by==-1)
	{ /* Lesereihenfolge */
		if(b->read_nr > a->read_nr)
			return 1;
		else if(b->read_nr == a->read_nr)
			return 0;

		return -1;
	}
	if(sort_by==-2)
	{ /* Name */
		return my_strcmp(b->name,a->name);
	}
	if(sort_by==-3)
	{ /* Gr”že */
		if(b->size > a->size)
			return 1;
		else if(b->size == a->size)
			return 0;
		return -1;
	}
	if(sort_by==-4)
	{ /* Zeit */
		if(b->time > a->time)
			return 1;
		if(b->time == a->time)
			return 0;
		return -1;
	}
	if(sort_by==-5)
	{ /* Datum */
		if(b->date > a->date)
			return 1;
		if(b->date == a->date)
		{
			if(b->time > a->time)
				return 1;
			if(b->time == a->time)
				return 0;
			return -1;
		}
		return -1;
	}
	if(sort_by==-6)
	{ /* Attribut */
		if(b->attrib > a->attrib)
			return 1;
		if(b->attrib == a->attrib)
			return 0;
		return -1;
	}
	if(sort_by==-7)
	{ /* Ursprung */
		return my_strcmp(b->pfad,a->pfad);
	}

	return 0;
}

int my_strcmp(char *a,char *b)
{
	register char ca,cb;

	do {
		ca=uprchar(*a++);
		cb=uprchar(*b++);

		if(ca!=cb)
		{
			if(ca<cb)
				return -1;
			return 1;
		}
	} while(*a || *b);

	return 0;
}
