#include "SuJi_glo.h"

FILE_INFO *add_to_list(DTA *dta,char *pfad,long *sort_nr)
{
	FILE_INFO *help;
	FILE_INFO *help2;
	register long r_sort_nr;

		/* Hole Speicher fr diesen Datensatz */
	help=malloc(sizeof(FILE_INFO)+strlen(dta->d_fname)+2+strlen(pfad));
	if(!help)
		return 0;

		/* Belege Felder vor */
	help->selected=FALSE;

	help->time=dta->d_time;
	help->date=dta->d_date;
	help->size=dta->d_length;
	help->attrib=dta->d_attrib;
	help->name=(char *)help+sizeof(FILE_INFO);
	help->pfad=(char *)help+sizeof(FILE_INFO)+strlen(dta->d_fname)+1;

	strcpy(help->name,dta->d_fname);
	strcpy(help->pfad,pfad);

		/* Suche Element, hinter dem eingefgt werden muž */
	if(sort_by==1 || sort_by==-1)
	{ /* Anfang/Ende */
		if(sort_by==1)
		{
			r_sort_nr=finfos+1;
			help2=last_fi;
		}
		else
		{
			r_sort_nr=1;
			help2=&first_fi;
		}
	}
	else
	{
		int gefunden=FALSE;

		r_sort_nr=1;
		help2=&first_fi;
		while(help2->next && !gefunden)
		{
			switch(sort_by)
			{
				case 2:
					gefunden=my_strcmp(help->name,help2->next->name) <= 0;
					break;
				case 3:
					gefunden=help->size <= help2->next->size;
					break;
				case 4:
					gefunden=help->time <= help2->next->time;
					break;
				case 5:
					if(help->date != help2->next->date)
						gefunden=help->date <= help2->next->date;
					else
						gefunden=help->time <= help2->next->time;
					break;
				case 6:
					gefunden=help->attrib <= help2->next->attrib;
					break;
				case 7:
					gefunden=my_strcmp(help->pfad,help2->next->pfad) <= 0;
					break;
				case -2:
					gefunden=my_strcmp(help->name,help2->next->name) >= 0;
					break;
				case -3:
					gefunden=help->size >= help2->next->size;
					break;
				case -4:
					gefunden=help->time >= help2->next->time;
					break;
				case -5:
					if(help->date != help2->next->date)
						gefunden=help->date >= help2->next->date;
					else
						gefunden=help->time >= help2->next->time;
					break;
				case -6:
					gefunden=help->attrib >= help2->next->attrib;
					break;
				case -7:
					gefunden=my_strcmp(help->pfad,help2->next->pfad) >= 0;
					break;
			}

			if(!gefunden)
			{
				help2=help2->next;
				r_sort_nr++;
			}
		}

		if(help2->next)
		{
			gefunden=FALSE;
			if(sort_by==3 || sort_by==-3)
				gefunden=help->size == help2->next->size;
			if(sort_by==4 || sort_by==-4)
				gefunden=help->time == help2->next->time;
			if(sort_by==5 || sort_by==-5)
			{
				gefunden=help->date == help2->next->date;
				if(gefunden)
					gefunden=help->time == help2->next->time;
			}
			if(sort_by==6 || sort_by==-6)
				gefunden=help->attrib == help2->next->attrib;
			if(sort_by==7 || sort_by==-7)
				gefunden=strcmp(help->pfad,help2->next->pfad) == 0;
		}

		while(gefunden && help2->next &&
			((sort_by>0 && my_strcmp(help->name,help2->next->name) > 0) ||
			(sort_by<0 && my_strcmp(help->name,help2->next->name) < 0)))
		{
			if(sort_by==3 || sort_by==-3)
				gefunden=help->size == help2->next->size;
			if(sort_by==4 || sort_by==-4)
				gefunden=help->time == help2->next->time;
			if(sort_by==5 || sort_by==-5)
			{
				gefunden=help->date == help2->next->date;
				if(gefunden)
					gefunden=help->time == help2->next->time;
			}
			if(sort_by==6 || sort_by==-6)
				gefunden=help->attrib == help2->next->attrib;
			if(sort_by==7 || sort_by==-7)
				gefunden=my_strcmp(help->pfad,help2->next->pfad) == 0;

			if(gefunden)
			{
				help2=help2->next;
				r_sort_nr++;
			}
		}
	}

		/* Fge ein */
	if(!help2->next)
		last_fi=help;
	else
		help2->next->prev=help;

	help->next=help2->next;
	help->prev=help2;
	help2->next=help;

	finfos++;
	fsize+=(double) help->size;

	help->read_nr=finfos;

	get_from_list(-1);

	full.g_w=full.g_h=-1;

	*sort_nr=r_sort_nr;

	return help;
}

void free_whole_list(void)
{
	FILE_INFO *help;
	FILE_INFO *help2;

	last_fi=&first_fi;

	help=first_fi.next;

	first_fi.next=NULL;

	while(help)
	{
		help2=help->next;

		free(help);

		help=help2;
	}

	fsize=0;
	finfos=0;
	get_from_list(-1);
}

void free_from_list(FILE_INFO *this)
{
	if(this->prev)
		this->prev->next=this->next;
	else
		first_fi.next=this->next;
	if(this->next)
		this->next->prev=this->prev;

	if(this == last_fi)
		last_fi=this->prev;

	finfos--;

	fsize-=this->size;

	free(this);

	get_from_list(-1);
}

FILE_INFO *get_from_list(long nr)
{
	FILE_INFO *help;
	static long last_nr=-1;
	static FILE_INFO *last_one=NULL;

	if(nr<1)
	{
		last_nr=-1;
		return NULL;
	}

	if(nr>finfos)
		return NULL;

	if(last_nr==-1 || !last_one)
	{
		last_nr=nr;

		help=&first_fi;

		while(help && nr)
		{
			help=help->next;
			nr--;
		}
	}
	else
	{
		if(nr>last_nr)
		{
			while(nr>last_nr && last_one)
			{
				last_nr++;
				last_one=last_one->next;
			}
			return last_one;
		}
		else
		{
			while(nr<last_nr && last_one)
			{
				last_nr--;
				last_one=last_one->prev;
			}
			return last_one;
		}
	}

	last_one=help;
	return help;
}
