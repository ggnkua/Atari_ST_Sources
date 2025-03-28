/* umrechnen von Farbbild (DEGAS) auf Graustufenbild (TIFF) */
/* Aufruf aus GFA-Basic */
/* (c) R.Wiesler */
/* erstellt am 29.7.1990 */

void cdecl rechne1(hilfsbild,bild)				/* Werte umgekehrt lesen !!! */

unsigned char *bild;									/* Zeiger auf Bild */
unsigned char *hilfsbild;							/* Zeiger auf Tiff-Bild */
{
	char farbe[16]  = {0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15};
	int bit;
	long wert, i, j;
	i=j=0;

	while (j<32000)									/* bis ganzes Bild */
	{
		wert=0;
		for(bit=7;bit>=0;)							/* alle Bits testen */
		{
				wert *= 16;								/* 4 Bits weiterschieben */
				wert += farbe[((*(bild+i)&(1<<bit))&&1)*8+((*(bild+i+2)&(1<<bit))&&1)*4+((*(bild+i+4)&(1<<bit))&&1)*2+((*(bild+i+6)&(1<<bit))&&1)];
				bit--;									/* obiges ginge auch eleganter, ist aber auch so sehr schnell */
		}
		*(hilfsbild+ j++)=(wert>>24) & 255;		/* das 1. Byte */
		*(hilfsbild+ j++)=(wert>>16) & 255;		/* das 2. Byte */
		*(hilfsbild+ j++)=(wert>>8) & 255;		/*     3.      */
		*(hilfsbild+ j++)=wert & 255;
		
		wert = 0;
		for(bit=7;bit>=0;)							/* selbiges wie oben */
		{													/* mit der 2. H„lfte */
				wert *= 16;								/* des Wortes */
				wert += farbe[((*(bild+i+1)&(1<<bit))&&1)*8+((*(bild+i+3)&(1<<bit))&&1)*4+((*(bild+i+5)&(1<<bit))&&1)*2+((*(bild+i+7)&(1<<bit))&&1)];  
				bit--; 
		}
		*(hilfsbild+ j++)=(wert>>24) & 255;
		*(hilfsbild+ j++)=(wert>>16) & 255;
		*(hilfsbild+ j++)=(wert>>8) & 255;
		*(hilfsbild+ j++)=wert & 255;
		i +=8;
	}
}

void cdecl rechne2(hilfsbild,bild)				/* Werte umgekehrt lesen !!! */

unsigned char *bild;									/* Zeiger auf Bild */
unsigned char *hilfsbild;							/* Zeiger auf Tiff-Bild */
{
	char farbe2[4] = {0,2,1,3};
	int bit;
	long wert, i, j;
	i=j=0;
	while (j<32000)									/* bis ganzes Bild */
	{
		wert=0;
		for(bit=7;bit>=0;)							/* alle Bits testen */
		{
				wert *= 4;								/* 2 Bits weiterschieben */
				wert += farbe2[((*(bild+i)&(1<<bit))&&1)*2+((*(bild+i+2)&(1<<bit))&&1)];
				bit--;									/* obiges ginge auch eleganter, ist aber auch so sehr schnell */
		}
		*(hilfsbild+ j++)=(wert>>8) & 255;		/* das 1. Byte */
		*(hilfsbild+ j++)=wert & 255;				/* das 2. Byte */
		
		wert = 0;
		for(bit=7;bit>=0;)							
		{												
				wert *= 4;							
				wert += farbe2[((*(bild+i+1)&(1<<bit))&&1)*2+((*(bild+i+3)&(1<<bit))&&1)];
				bit--; 
		}
		*(hilfsbild+ j++)=(wert>>8) & 255;
		*(hilfsbild+ j++)=wert & 255;
		i +=4;
	}
}
/* das war's dann schon */				