
/* REFERENZ by Mutter FrÇdÇric. MÑrz 1990 */

/* in Turbo-C die Compiler-Option 'Default char is unsigned'
   UNBEDINGT(!) einschalten */

#include <stdio.h>
#include <ctype.h>	/* include isalpha() & isdigit() */
#define  CLS()		printf("%cE",27);
#define  READ_DT 	getc(datei)
#define  FILE_TO_C	(c=getc(datei))
#define  RES_W		sizeof(C_sprache) / sizeof(C_sprache[0])
#define  LF 		0x0A

struct{
	char	*words;
	int 	zaehler;
} C_sprache[]={
	{"auto",0},{"break",0},{"case",0},{"char",0},{"continue",0},
	{"default",0},{"do",0},{"double",0},{"else",0},{"entry",0},
	{"enum",0},{"extern",0},{"float",0},{"for",0},{"goto",0},
	{"if",0},{"int",0},{"long",0},{"register",0},{"return",0},
	{"short",0},{"sizeof",0},{"static",0},{"struct",0},{"switch",0},
	{"typedef",0},{"union",0},{"unsigned",0},{"void",0},{"while",0}
	};

typedef struct biblio{
	char	name[32];
	int 	lg_var;
	int 	cptr_v;
	int 	variable[99];
	int 	cptr_f;
	int 	funktion[99];
	struct	biblio *links;
	struct	biblio *rechts;
} WORDS;
WORDS	*in_tree(),*analyse();

FILE		 *datei;
unsigned int zeile=1;

main()
{
	WORDS *tree;
	FILE  *fopen(),*freopen();
	int   zaehler,auswahl,i,j;
	char  datei_gelesen[14],*datei_geschrieben="LISTING.C";

	CLS();
	puts(" REFERENZ v1.0 fÅr C von Mutter F.");
	puts("(c) MÑrz 1990 TOS-Magazin\033w");
	printf("Name der Datei:");
	scanf("%s",datei_gelesen);
	if( (datei=fopen(datei_gelesen,"r"))==NULL ) {
		printf("Datei %s nicht gefunden!",datei_gelesen);
		exit(1);
	}
	else {
		printf("\n1) Ausgabe Datei.\n2) Ausgabe Bildschirm.\nAuswahl->");
		do
			scanf("%d",&auswahl);
		while( auswahl!=1 && auswahl!=2 );
		printf("\n1) Variablen. \n2) Variablen und Funktionen.\nAuswahl->");
		do
			scanf("%d",&i);
		while( i!=1 && i!=2 );
		if( auswahl==1 ) {
			printf("\nAusgabe Datei: %s",datei_geschrieben);
			freopen(datei_geschrieben,"w",stdout);
		}

		puts("\n==================================="); 
		puts(" REFERENZ v1.0 fÅr C von Mutter F.");
		puts("(c) MÑrz 1990 TOS-Magazin");
		puts("===================================");
/* GrÅûe von Sabine an MaBa & Markus Fritze.
	Brauchen Sie mich als Programmierer in MÅnchen?
	Tel: 089/ 308 27 66 ab 18 Uhr!!
	(ASM 68000 oder C, ist egal)
*/
		printf("\nDateianalyse: %s\n",datei_gelesen);
		puts("=============\n");
		puts("BenÅtzte Variablen:");
		puts("===================");
		tree=analyse();
		zaehler=1;
		print_tree(tree,&zaehler,0);
		draw_line();
		printf("\n\n %d Variablen wurden benÅtzt.\n",--zaehler);
		puts("==============================");
		if( i==2 ) {
			puts("\nBenÅtzte Funktionen:");
			puts("====================");
			zaehler=1;
			print_tree(tree,&zaehler,1);
			draw_line();
			printf("\n\n %d Funktionen wurden benÅtzt.\n",--zaehler);
			puts("===============================");
		}
		printf("\nAnzahl der Zeilen: %d.\n",--zeile);
		puts("==================\n");
		puts("BenÅtzung reservierter Wîrter:");
		puts("==============================");
		for(i=j=0;i<RES_W;i++) {
			if(C_sprache[i].zaehler) {
				printf("  %-8s:%2d	",C_sprache[i].words,C_sprache[i].zaehler);
				if( ++j%5==0 )
					puts(" ");
			}
		}
		puts("\n\nAnalyse beendet.");
		fclose(datei);
		exit(0);
	}
}


/***************/
/* Textanalyse */
/***************/

WORDS *analyse()
{
	WORDS *knoten=NULL;
	char	b,c,puf_char[50];
	int 	j;
	int i=0;
	FILE_TO_C;
	do{
		switch(c) {
		
			/* Verhindert Kommentaranalyse */
			case '/' :	if( FILE_TO_C=='*' ) {
							do {
								while( FILE_TO_C!='/' ) {
								if( c==LF )
									zeile++;
									b=c;
								}
							}while( b!='*' || c!='/' );
						}
						break;
 
			/* Verhindert Analyse zwischen AnfÅhrungszeichen */
			case '"' :	READ_DT;
						while( READ_DT!='"' );
						FILE_TO_C;
						break;

			/* Verhindert Analyse zwischen Apostroph */
			case '\'':	if( READ_DT=='\\' )
							READ_DT;
						READ_DT;
						FILE_TO_C;
						break;
 
			/* Verhindert Analyse von Vor-Compiler-Befehlen */
			case '#' :	do {
							do
								FILE_TO_C;
							while( c!=LF && c!='\\');
							if( c=='\\' ) {
								while( FILE_TO_C!=LF) ;
								zeile++;
								FILE_TO_C;
							}
						}while( c!=LF );
						break;

			/* Zahlen sind keine Wîrter! (Bsp. 0x7F) */
			case '0' :	do
							FILE_TO_C;
						while( isalpha(c) || isdigit(c) );
						break;

			/* ZeilenzÑhler (LF=Line Feed) */ 
			case LF :	zeile++;
						FILE_TO_C;
						break;

			/* Das ist ein Wort oder Zeichen<0x20 (bsp. CTRL-G */
			default :
				if( isalpha(c) || c=='_' ) {
					j=0;
					do {
						puf_char[j++]=c;
						FILE_TO_C;
					}while( isalpha(c) || isdigit(c) || c=='_' );
					puf_char[j]='\0';
					if( j>32 ) {
						printf("Fehler: Das Wort %s ist zu lang.",puf_char);
						exit(1);
					}
					if( compare_words_res(puf_char) )
						knoten=in_tree(knoten,puf_char,zeile,j,c);
				}
				else
					FILE_TO_C;
				break;
		} /* end of switch() */
	}while( c!=0xFF );
	return(knoten);
}


/* Ist es ein Wort aus C? */ 
compare_word_res(word)
char *word;
{
	int i=0;
	do
		if( strcmp(word,C_sprache[i].words)==0 ) {
			C_sprache[i].zaehler++;
			return(0);
		}
	while( i++<RES_W-1 );
	return(1);
}


/* Kein Wort aus C, also Variable (oder Funktion) */
/* Ein Knoten wird angelegt und 
	automatisch eingeordnet (Rekursivfunktion!)   */
WORDS *in_tree(ptr_k,variable,l,lg,c)
WORDS	*ptr_k;
char	*variable,c;
int 	l,lg; 
{
	char *malloc();
	if( ptr_k==NULL ) {
		ptr_k=(WORDS *) malloc(sizeof(WORDS));
		if( ptr_k==NULL) {
			printf("Fehler: Kein Speicherplatz.");
			exit(1);
		}
		strcpy(ptr_k->name,variable);
		ptr_k->lg_var=lg;
		if( c=='(' ) {
			ptr_k->funktion[0]=l;
			ptr_k->cptr_f=1;
		}
		else {
			ptr_k->variable[0]=l; 
			ptr_k->cptr_v=1;
		}
		ptr_k->links = ptr_k->rechts = NULL;
	}
	else
		if( strcmp(variable,ptr_k->name) < 0 )
			ptr_k->links=in_tree(ptr_k->links,variable,l,lg,c);
		else
			if( strcmp(variable,ptr_k->name) > 0 )
				ptr_k->rechts=in_tree(ptr_k->rechts,variable,l,lg,c);
			else
				if( c=='(' )
					ptr_k->funktion[ptr_k->cptr_f++]=l;
				else	
					ptr_k->variable[ptr_k->cptr_v++]=l;
	return(ptr_k);
}


/* Druckt die Knoten rekursiv aus		  */
/* nr ist ein Knotenzaehler 			  */
/* var_fonc = 0 -> Druckt Variablen aus   */
/*			= 1 -> Druckt Funktionen aus  */
print_tree(ptr_k,nr,var_fonc)
WORDS *ptr_k;
int *nr,var_fonc;
{
	if( ptr_k!= NULL) {
		print_tree(ptr_k->links,nr,var_fonc);
		if( var_fonc && ptr_k->cptr_f )
			show_words(ptr_k,ptr_k->cptr_f,&ptr_k->funktion,"()",nr);
		else
			if( !var_fonc && ptr_k->cptr_v)
				show_words(ptr_k,ptr_k->cptr_v,&ptr_k->variable,"  ",nr);
		print_tree(ptr_k->rechts,nr,var_fonc);
	}
}

show_words(ptr_k,var,zeiger,text,nr)
WORDS *ptr_k;
int var, *zeiger,*nr;
char *text;
{
	int i;
	draw_line();
	printf("|%2d| %s%s",(*nr)++,ptr_k->name,text);
	for(i=0;i<72-ptr_k->lg_var;i++)
		printf(" ");
	printf("|\n|%2d|",var);
	i=0;
	while( i<var ) {
		printf("%4d ",*(zeiger++));
		if( ++i%15==0 && i!=var )
			printf("|\n|  |");
	}
	for(i%=15;i<15;i++)
		printf("     ");
	printf("|");
}

draw_line()
{
	int i;
	printf("\n+--+");
	for(i=0;i<75;i++)
		printf("-");
	printf("+\n");
}
