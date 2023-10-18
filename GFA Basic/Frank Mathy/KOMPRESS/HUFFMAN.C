/*	Huffman-Code Demonstration		*/
/*	Von Frank Mathy (C) 1991		*/
/*	FÅr die Zeitschrift TOS 05/91	*/


#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <string.h>
#include <math.h>
#include <ctype.h>

unsigned zeichenzahl;			/* Zahl der Zeichen		*/
unsigned listengroesse;			/* Grîûe der Liste		*/
unsigned long datenumfang;		/* Umfang der Daten		*/
unsigned long 	speicherohne,
				speichermit;	/* Speicherbedarf Daten	*/

struct satz
	{
	unsigned long haeufigkeit; 	/* Absolute HÑufigkeit	*/
	unsigned zugehoerigkeit;	/* Zugehîrige Zeichen	*/
	} element[16];

double p[16];					/* Wahrscheinlichkeiten	*/
double bitsohne,bitsmit;		/* ZeichenlÑngen		*/
unsigned bitsohneint;			/* Ganzzahlwert			*/

char codewort[16][80];			/* Codeworte			*/

unsigned bit(unsigned bitnr)	/* Wert mit Bit bitnr	*/
	{
	return(1 << bitnr);
	}

void vorbereitungen(void)
	{
	unsigned wort;

	for(wort=0; wort<16; wort++)
		codewort[wort][0]=0;		/* Zeichenkette lîschen	*/
	printf("\x1b");
	printf("EHuffman-Codierung von Frank Mathy fÅr die TOS\n");
	printf("---------------------------------------------\n");
	do	{
		printf("\nWieviele zu codierende Zeichen (2-16) ? ");
		scanf("%u",&zeichenzahl);
		} while((zeichenzahl<2)||(zeichenzahl>16));
	listengroesse=zeichenzahl;		/* Listengrîûe setzen	*/
	for(wort=0; wort<zeichenzahl; wort++)
		{
		printf("Absolute HÑufigkeit Zeichen %u (>=1) : ",wort);
		scanf("%lu",&element[wort].haeufigkeit);
		element[wort].zugehoerigkeit=bit(wort);
		}
	
	datenumfang=0;
	for(wort=0; wort<zeichenzahl; wort++)
		datenumfang+=element[wort].haeufigkeit;
	for(wort=0; wort<zeichenzahl; wort++)
		p[wort]=(double) element[wort].haeufigkeit / (double) datenumfang;
	}

int vergleich(struct satz *s1,struct satz *s2)
/* Vergleich zweier DatensÑtze */
	{
	if(s1->haeufigkeit == s2->haeufigkeit) return(0);
	else	if(s1->haeufigkeit < s2->haeufigkeit) return(1);
			else return(-1);
	}

void reduktion(void)
/* Eine Reduktion durchfÅhren	*/
	{
	unsigned zeichen;
	char help[80];
	
	/* Sortieren der Tabelle	*/
	qsort(&element[0],listengroesse,sizeof(struct satz),vergleich);

	/* Den letzten zwei Zeichen 0 und 1 zuordnen	*/
	for(zeichen=0; zeichen<zeichenzahl; zeichen++)
		{
		if(element[listengroesse-2].zugehoerigkeit&bit(zeichen))
			{
			strcpy(help,"0");
			strcat(help,codewort[zeichen]);
			strcpy(codewort[zeichen],help);
			}
		if(element[listengroesse-1].zugehoerigkeit&bit(zeichen))
			{
			strcpy(help,"1");
			strcat(help,codewort[zeichen]);
			strcpy(codewort[zeichen],help);
			}
		}
	if(listengroesse>2)		/* Wenn mehr als zwei Zeichen in Liste	*/
		{
		/* Letzte Zeichen zu einem zusammenfassen	*/
		element[listengroesse-2].haeufigkeit += element[listengroesse-1].haeufigkeit;
		element[listengroesse-2].zugehoerigkeit |= element[listengroesse-1].zugehoerigkeit;
		}
	listengroesse--;
	}

void huffman(void)
/* Huffman-Codierung ausfÅhren	*/
	{
	do	reduktion();		/* Reduzieren, bis Listengrîûe 1	*/
		while(listengroesse>1);
	}

void statistik(void)
/* Einige Statistikwerte berechnen	*/
	{
	unsigned wort;
	bitsohne=log(zeichenzahl)/log(2);	/* Grîûe ohne Huffman	*/
	bitsohneint=(int) ceil(bitsohne);	/* TatsÑchliche Bitz.	*/
	bitsmit=0;
	for(wort=0; wort<zeichenzahl; wort++)
		bitsmit+=p[wort]*(double) strlen(codewort[wort]);
	
	speicherohne=(unsigned long) bitsohneint * datenumfang;
	speichermit=(unsigned long) (bitsmit * (double) datenumfang);
	}

void ausgabe(void)
/* Den Huffman-Code und charakteristische Werte ausgeben	*/
	{
	unsigned wort;
	printf("\x1b");
	printf("E Xn\t P(Xn)\t  LÑnge\t Codierung\n");
	printf(" -------------------------------\n");
	for(wort=0; wort<zeichenzahl; wort++)
		printf("%2u\t%.3lf\t%2ld\t%s\n",wort,p[wort],strlen(codewort[wort]),codewort[wort]);
	printf("\nZeichengrîûe ohne Huffman: %.3lf bit ---> %u bit\n",bitsohne,bitsohneint);
	printf("Durchschnittl. Zeichengrîûe mit Huffman: %.3lf bit\n",bitsmit);
	printf("Speicherbedarf ohne Huffman: %lu bit\n",speicherohne);
	printf("Speicherbedarf mit  Huffman: %lu bit\n",speichermit);
	}

void main(void)
/* Hauptprogramm	*/
	{
	char eingabe;
	do	{
		vorbereitungen();
		huffman();
		statistik();
		ausgabe();
		do	{
			printf("\nNochmal (j/n) ? ");
			scanf("%1s",&eingabe);
			} while((tolower(eingabe)!='j')&&(tolower(eingabe)!='n'));
		} while(tolower(eingabe)=='j');
	}
