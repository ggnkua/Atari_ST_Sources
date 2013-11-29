#include "SuJi_glo.h"

int unterpfade(const char *a,const char *b)
{
	if(!strcmp(a,b))	/* genau gleich */
		return 1;

	if(strstr(a,b)==a)
	{ /* a ist Unterpfad zu b */
		return 2;
	}

	if(strstr(b,a)==b)
	{ /* b ist Unterpfad zu a */
		return 3;
	}

	return 0;
}

unsigned int remove_double_paths(void **pfade)
{
	struct pfadkette *help;
	struct pfadkette *help2;
	int removed=0;

	if(!pfade)
		return 0;

	help=*pfade;

	if(!help->next)
		return 0;

	while(help && help->next)
	{
		help2=help->next;

		while(help2 && help)
		{
			i=unterpfade(help->pfad,help2->pfad);

			if(i)
			{ /* einen entfernen */
				struct pfadkette *help3;

				if(i==1 || i==3)
				{ /* Pfade gleich oder help2 Unterpfad => help2 entfernen*/
						/* Vorg„nger von help2 nach help3 */
					help3=(struct pfadkette *)pfade;
					while(help3->next!=help2)
						help3=help3->next;
	
						/* help2 aus der Kette nehmen */
					help3->next=help2->next;
					free(help2);
	
						/* mitz„hlen */
					removed++;
	
						/* "weiterschalten" */
					help2=help3->next;
				}
				else
				{ /* help ist Unterpfad von help2 => help entfernen, */
				  /* help2 an seine Stelle*/
						/* Vorg„nger von help2 nach help3 */
					help3=(struct pfadkette *)pfade;
					while(help3->next!=help2)
						help3=help3->next;
	
						/* help2 aus der Kette nehmen */
					help3->next=help2->next;

						/* Vorg„nger von help nach help3 */
					help3=(struct pfadkette *)pfade;
					while(help3->next!=help)
						help3=help3->next;

						/* help aus der Kette nehmen, dafr */
						/* help2 einketten, dabei gleich */
						/* "weiterschalten" */
					help3->next=help2;
					help3=help2->next;
					help2->next=help->next;
					help2=help3;
					help3=help->next;
					free(help);
					help=help3;

						/* mitz„hlen */
					removed++;
				}
			}
			else
				help2=help2->next;
		}

		if(help)
			help=help->next;
	}

	return removed;
}

int get_max_breite_pfade(void *pfade)
{
	int breite;
	struct pfadkette *help;

	breite=0;

	help=(struct pfadkette *)pfade;
	while(help)
	{
		register int i;

		i=(int) strlen(help->pfad);
		if(i>breite)
			breite=i;

		help=help->next;
	}

	return breite;
}

void free_pfade(void *search_pfade)
{
	struct pfadkette *help,*help2;

	help=(struct pfadkette *)search_pfade;
	while(help)
	{
		help2=help->next;
		free(help);

		help=help2;
	}
}

char *get_pfad(void *pfade,int i)
{
	struct pfadkette *help;

	help=pfade;
	while(i-- && help)
		help=help->next;

	if(help)
		return help->pfad;

	return NULL;
}

int analyse_parameter(int argc,char *argv[],void **search_pfade)
{
	int zahl_der_pfade;
	int i,ARGV;
	char *arg;
	struct pfadkette *help;

	ARGV=0;
	if(getenv("ARGV"))
		ARGV=1;

	for(i=0;i<argc-1-ARGV;i++)
	{
		if(argv[i+1-ARGV][0]=='\'')
		{
			int von,nach;

			von=1;
			nach=0;
			do {
				if(argv[i+1-ARGV][von]=='\'')
					von++;

				argv[i+1-ARGV][nach]=argv[i+1-ARGV][von];
				nach++;
			} while(argv[i+1-ARGV][von++]);
		}
	}

	zahl_der_pfade=0;
	for(i=0;i<argc-1-ARGV;i++)
	{
		arg=argv[i+1-ARGV];

		if(arg[0]=='-')
		{
			if(arg[1]=='D')
			{
				int i;

				i=2;
				while(arg[i]!='\0')
				{
					zahl_der_pfade++;
					i++;
				}
			}
			else if(arg[1]=='P')
			{
				zahl_der_pfade++;
			}
		}
		else
		{
			zahl_der_pfade++;
		}
	}

	if(zahl_der_pfade==0)
	{
		int j;
		char *dm;
		char lwks[]="_______________________";

		dm=getenv("DRIVEMAP");
		if(!dm || !strlen(dm))
		{
			long lwk;

			dm=lwks;

			lwk=Dsetdrv(Dgetdrv());

			if(lwk & 0x03effffcl)	/* Gibt es ein Laufwerk aužer a,b und u? */
				lwk&=0x03effffcl;	/* ... dann a,b und u ausblenden */

			j=0;
			i=0;
			do {
				if(lwk & 1)
				{
					lwks[j++]=i+'A';
				}
				i++;
				lwk/=2;
			} while(lwk);
			lwks[j]='\0';
		}

		zahl_der_pfade=(int) strlen(dm);

		help=(struct pfadkette *)search_pfade;
		help->next=NULL;

		for(i=0;i<zahl_der_pfade;i++)
		{
			help->next=malloc(sizeof(struct pfadkette)+3);
			if(help->next)
			{
				help=help->next;

				help->next=NULL;
				help->selected=0;
				help->pfad[0]=dm[i];
				help->pfad[1]=':';
				help->pfad[2]='\\';
				help->pfad[3]='\0';
			}
			else
			{
				free_pfade(*search_pfade);
				return -1;
			}
		}

		return zahl_der_pfade;
	}

	help=(struct pfadkette *)search_pfade;
	help->next=NULL;

	zahl_der_pfade=0;
	for(i=0;i<argc-1-ARGV;i++)
	{
		arg=argv[i+1-ARGV];

		if(arg[0]=='-')
		{
			if(arg[1]=='D')
			{
				int j;

				j=2;
				while(arg[j]!='\0')
				{
					help->next=malloc(sizeof(struct pfadkette)+3);
					if(help->next)
					{
						help=help->next;

						help->next=NULL;
						help->selected=0;
						help->pfad[0]=arg[j];
						help->pfad[1]=':';
						help->pfad[2]='\\';
						help->pfad[3]='\0';
						j++;
						zahl_der_pfade++;
					}
					else
					{
						free_pfade(*search_pfade);
						return -1;
					}
				}
			}
			else if(arg[1]=='P')
			{
					/* Struct + String + ggf. '\\' */
				help->next=malloc(sizeof(struct pfadkette)+
							strlen(&arg[2])+
							(arg[strlen(arg)-1]!='\\'));
				if(help->next)
				{
					help=help->next;

					help->next=NULL;
					help->selected=0;

					strcpy(help->pfad,&arg[2]);
					if(help->pfad[strlen(help->pfad)-1]!='\\')
						strcat(help->pfad,"\\");

					zahl_der_pfade++;
				}
				else
				{
					free_pfade(*search_pfade);
					return -1;
				}
			}
		}
		else
		{
				/* Struct + String + ggf. '\\' */
			help->next=malloc(sizeof(struct pfadkette)+
						strlen(arg)+
						(arg[strlen(arg)-1]!='\\'));
			if(help->next)
			{
				help=help->next;

				help->next=NULL;
				help->selected=0;

				strcpy(help->pfad,arg);
				if(help->pfad[strlen(help->pfad)-1]!='\\')
				{ /* Unter Umst„nden wurde eine Datei bergeben */
					long j;

						/* Hinten ein '\\' anh„ngen */
					strcat(help->pfad,"\\");

					for(j=strlen(help->pfad)-2;j>=0;j--)
					{
						if(help->pfad[j]=='\\')
						{
							help->pfad[j+1]='\0';
							j=-1;
						}
					}
				}

				zahl_der_pfade++;
			}
			else
			{
				free_pfade(*search_pfade);
				return -1;
			}
		}
	}

	/* doppelte Pfade entfernen */
	zahl_der_pfade-=remove_double_paths(&suji.search_pfade);

	return zahl_der_pfade;
}

int change_a_path(struct SUCHINFORMATIONEN *suji,struct pfadkette *this)
{
	char pfad[1024];
	char file[1024];

	file[0]='\0';
	strcpy(pfad,this->pfad);
	strcat(pfad,"*");

	mt_rsrc_gaddr(5,CHA_PATH_TITEL,&alert,&global);

	if(!fsel(pfad,file,&i,alert,&global))
	{ /* fsel_(ex)input-Fehler */
		return 2;
	}

	if(i) /* OK geklickt? */
	{
		char *no_mask;
		struct pfadkette *help;
		int markiere=0;

		no_mask=&pfad[strlen(pfad)];
		while(no_mask>pfad && *no_mask!='\\')
			no_mask--;
		if(*no_mask=='\\')
			no_mask[1]='\0';

		help=malloc(sizeof(struct pfadkette)+strlen(pfad));
		if(help)
		{
			struct pfadkette *help2;

			help2=(struct pfadkette *)&(suji->search_pfade);

			while(help2->next != this)
			{
				help2=help2->next;
			}

			help2->next=help;
			help->next=this->next;
			help->selected=1;

			strcpy(help->pfad,pfad);

			free(this);

			help2=suji->search_pfade;
			while(help && help2)
			{
				i=unterpfade(help->pfad,help2->pfad);
				
				if(i && (help!=help2 || i!=1))
				{ /* einen entfernen */
					struct pfadkette *help3;
				
					if(i==1 || i==2)
					{ /* Pfade gleich oder help Unterpfad => help entfernen */
							/* Vorg„nger von help nach help3 */
						help3=(struct pfadkette *)&(suji->search_pfade);
						while(help3->next!=help)
							help3=help3->next;
				
							/* help aus der Kette nehmen */
						help3->next=help->next;
						free(help);
				
							/* mitz„hlen */
						suji->zahl_pfade--;
				
						help3=suji->search_pfade;
						while(help3!=help2)
						{
							markiere++;
							help3=help3->next;
						}

						Cconout(7);

							/* help ist weg -> aufh”ren */
						help=NULL;
					}
					else
					{ /* help2 ist Unterpfad von help => help2 entfernen, */
					  /* help an seine Stelle*/
							/* Vorg„nger von help nach help3 */
						help3=(struct pfadkette *)&(suji->search_pfade);
						while(help3->next!=help)
							help3=help3->next;
				
							/* help aus der Kette nehmen */
						help3->next=help->next;
				
							/* Vorg„nger von help2 nach help3 */
						help3=(struct pfadkette *)&(suji->search_pfade);
						while(help3->next!=help2)
							help3=help3->next;
				
							/* help2 aus der Kette nehmen, dafr */
							/* help einketten, dabei gleich */
							/* "weiterschalten" */
						help3->next=help;
						help->next=help2->next;
						free(help2);
						help2=help;

							/* mitz„hlen */
						suji->zahl_pfade--;
					}
				}
				else
					help2=help2->next;
			}
	
			if(help)
			{
				help2=suji->search_pfade;
				while(help2!=help)
				{
					markiere++;
					help2=help2->next;
				}
			}
	
			help2=suji->search_pfade;
			while(help2 && markiere)
			{
				markiere--;
				help2=help2->next;
			}
	
			if(help2)
				help2->selected=1;
			
		}
		else
		{ /* Speichermangel */
			return 1;
		}
	}

	return 0;
}

int add_a_new_path(struct SUCHINFORMATIONEN *suji, char *this)
{
	char pfad[1024]="C:\\";
	char file[1024];

	file[0]='\0';

	mt_rsrc_gaddr(5,ADD_PATH_TITEL,&alert,&global);

	if(!this)
	{
		if(!fsel(pfad,file,&i,alert,&global))
		{ /* fsel_(ex)input-Fehler */
			return 2;
		}
	}
	else
	{
		if(strlen(this)>1023)
			this[1024]='\0';

		strcpy(pfad,this);
		i=1;	/* "OK" */
	}

	if(i) /* OK geklickt? */
	{
		char *no_mask;
		struct pfadkette *help;
		int markiere=0;

		no_mask=&pfad[strlen(pfad)];
		while(no_mask>pfad && *no_mask!='\\')
			no_mask--;
		if(*no_mask=='\\')
			no_mask[1]='\0';

		help=malloc(sizeof(struct pfadkette)+strlen(pfad));
		if(help)
		{
			struct pfadkette *help2;

			help2=(struct pfadkette *)&(suji->search_pfade);

			while(help2->next)
			{
				help2=help2->next;

				help2->selected=0;
			}

			help2->next=help;

			help->next=NULL;
			help->selected=1;

			strcpy(help->pfad,pfad);

			suji->zahl_pfade++;

			help2=suji->search_pfade;
			while(help && help2)
			{
				i=unterpfade(help->pfad,help2->pfad);
				
				if(i && (help!=help2 || i!=1))
				{ /* einen entfernen */
					struct pfadkette *help3;
				
					if(i==1 || i==2)
					{ /* Pfade gleich oder help Unterpfad => help entfernen */
							/* Vorg„nger von help nach help3 */
						help3=(struct pfadkette *)&(suji->search_pfade);
						while(help3->next!=help)
							help3=help3->next;
				
							/* help aus der Kette nehmen */
						help3->next=help->next;
						free(help);
				
							/* mitz„hlen */
						suji->zahl_pfade--;
				
						help3=suji->search_pfade;
						while(help3!=help2)
						{
							markiere++;
							help3=help3->next;
						}

						Cconout(7);

							/* help ist weg -> aufh”ren */
						help=NULL;
					}
					else
					{ /* help2 ist Unterpfad von help => help2 entfernen, */
					  /* help an seine Stelle*/
							/* Vorg„nger von help nach help3 */
						help3=(struct pfadkette *)&(suji->search_pfade);
						while(help3->next!=help)
							help3=help3->next;
				
							/* help aus der Kette nehmen */
						help3->next=help->next;
				
							/* Vorg„nger von help2 nach help3 */
						help3=(struct pfadkette *)&(suji->search_pfade);
						while(help3->next!=help2)
							help3=help3->next;
				
							/* help2 aus der Kette nehmen, dafr */
							/* help einketten, dabei gleich */
							/* "weiterschalten" */
						help3->next=help;
						help->next=help2->next;
						free(help2);
						help2=help;

							/* mitz„hlen */
						suji->zahl_pfade--;
					}
				}
				else
					help2=help2->next;
			}
	
			if(help)
			{
				help2=suji->search_pfade;
				while(help2!=help)
				{
					markiere++;
					help2=help2->next;
				}
			}
	
			help2=suji->search_pfade;
			while(help2 && markiere)
			{
				markiere--;
				help2=help2->next;
			}
	
			if(help2)
				help2->selected=1;
		}
		else
		{ /* Speichermangel */
			return 1;
		}
	}

	return 0;
}

int count_deselected(void *pfade)
{
	struct pfadkette *help;
	int deselektierte=0;

	help=(struct pfadkette *)pfade;
	while(help)
	{
		if(help->selected==0)
			deselektierte++;

		help=help->next;
	}

	return deselektierte;
}

int count_selected(void *pfade)
{
	struct pfadkette *help;
	int selektierte=0;

	help=(struct pfadkette *)pfade;
	while(help)
	{
		if(help->selected)
			selektierte++;

		help=help->next;
	}

	return selektierte;
}

int remove_selected_paths(struct SUCHINFORMATIONEN *suji)
{
	struct pfadkette *help,*help2;
	int deselektierte;

	deselektierte=count_deselected(suji->search_pfade);

	if(!deselektierte)
	{
		return 1;
	}
	else
	{
		help2=(struct pfadkette *)&(suji->search_pfade);
		help=suji->search_pfade;
		while(help)
		{
			if(help->selected)
			{
				help2->next=help->next;
				free(help);
				suji->zahl_pfade--;
			}
			else
			{
				help2=help;
			}
			help=help2->next;
		}
	}

	return 0;
}
