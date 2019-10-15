/* Demo der qsort-Funktion von Turbo-C/Pure-C */
/* (C) Frank Mathy, TOS                       */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ext.h>

#define ELEMENTE 5

struct satz
	{
	char text[20];
	int wert;
	};

int strvergleich(struct satz *e1,struct satz *e2)
	{
	return(strcmp(e1->text,e2->text));
	}

int numvergleich(struct satz *e1,struct satz *e2)
	{
	return(e1->wert - e2->wert);
	}

void main(void)
	{
	struct satz saetze[ELEMENTE];
	int x,y;
	srand((unsigned)clock());
	for(y=0;y<ELEMENTE;y++)
		{
		for(x=0;x<19;x++)
			if((x<3)||(rand()%6)) saetze[y].text[x]='A'+rand()%26;
			else saetze[y].text[x]=' ';
		saetze[y].text[19]=0;
		saetze[y].wert=rand();
		}
	printf("Unsortierte Textliste:\n\n");
	for(y=0; y<ELEMENTE; y++)
		printf("%s     %d\n",saetze[y].text,saetze[y].wert);
	
	qsort(&saetze[0],ELEMENTE,sizeof(struct satz),strvergleich);
	
	printf("\nNach Text sortierte Textliste:\n\n");
	for(y=0; y<ELEMENTE; y++)
		printf("%s     %d\n",saetze[y].text,saetze[y].wert);
	
	qsort(&saetze[0],ELEMENTE,sizeof(struct satz),numvergleich);

	printf("\nNach Wert sortierte Textliste:\n\n");
	for(y=0; y<ELEMENTE; y++)
		printf("%s     %d\n",saetze[y].text,saetze[y].wert);
	}
