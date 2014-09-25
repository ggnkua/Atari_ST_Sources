/*
	programme de r‚solution du d‚mineur	


	liste des diff‚rentes valeurs :

	- hauteur : 8 … 24
	- largeur : 8 … 30
	- nb mines : 10 … (hauteur-1)*(largeur-1)

	- d‚butant :
				8*8 10 mines
	- interm‚diaire :
				16*16 40 mines
	- expert :
				16*30 99 mines

	- options :
			- m‚moriser les records de temps

*/
#include <stdio.h>
#include <stdlib.h>

/* #define N 24	*/		/* taille du damier */
/* #define NMAX 24*24 */		/* nombre de cases maximum */
#define TAILLEX 30		/* largeur du damier */
#define TAILLEY 16		/* hauteur du damier */
#define NB_BOMBES 99	/* nombre de bombes sur le damier */

/* nb cases du damier */
#define TAILLE_MAX (TAILLEX*TAILLEY+TAILLEX*2+TAILLEY+3)

/* tableau contenant les bombes pos‚es par le programme */
char damier[TAILLE_MAX];

/* tableau des coups jou‚s par le joueur */
char jeu[TAILLE_MAX];

/* pile des cases pour recherche r‚cursive */
int pile,stack[TAILLEX*TAILLEY];

int nb_cases_vides,cases_vides[TAILLEX*TAILLEY];

/* liste des prototypes */
void init_damier();
void display_damier();
void init_jeu();
void display_jeu();
int select_depart();
void joue_case(int c);
void remplit(int c);
void push(int c);
void algo1();
void scan(int c);
void jouec(int c);
void placebombe(int c);
void algo2();
void scan2(int c);
void devine(int i);
void solution();
int test_legal(int c);
int test(int c);
void compte(int c);

int coupjoue,modifie;
int nbbombes,nblibres;
int nbcases,liste[TAILLEX*TAILLEY],etat[TAILLEX*TAILLEY];
int nbsol;

/* programme principal */
int main()
{
	int i;

	srand(0);
/*	srand(4); */

	init_damier();			/* tirage des bombes et comptage des cases */
	display_damier();
	init_jeu();				/* initialisation table recherche 1 */
	i=select_depart();		/* on triche un peu en prenant pour case
							    de d‚part une case contenant un 0 */

	joue_case(i);

	algo1();
	if (modifie !=0) display_jeu();

	for(;;)
	{
		modifie = 0;
		algo2();
		if (modifie == 0) break;
		display_jeu();
		algo1();
		if (modifie == 0) break;
		display_jeu();
	}

	printf("fini...\n");
	getchar();
	return 0;
}

void init_damier()
{
	int i,x;

	for (i = 0; i < TAILLE_MAX; i++)  damier[i] = -1;

	for (i = 0; i <= TAILLEX; i++)
	{
		damier[i] = 10;
		damier[(TAILLEX+1)*(TAILLEY+1)+i] = 10;
	}

	for (i = 0; i <= TAILLEY; i++)
	{
		damier[(TAILLEX+1)*i] = 10;
	}

	damier[(TAILLEX+1)*(TAILLEY+1)+TAILLEX+1] = 10;

	/* tirage des bombes */
	
	if (NB_BOMBES > (TAILLEX-1)*(TAILLEY-1))
	{
		printf("Trop de bombes !!!");
	}
	
	for (i = 1; i <= NB_BOMBES; i++)
	{
		do
		{
			x=rand() % TAILLE_MAX;
		}
		while (damier[x] != -1);
		damier[x] = 9;	
	}
	/* comptage des cases */
	for (i = 0; i < TAILLE_MAX; i++)
	{
		if (damier[i] == -1)
		{
			x = 0;
			if (damier[i-TAILLEX-2] == 9) x++;
			if (damier[i-TAILLEX-1] == 9) x++;
			if (damier[i-TAILLEX] == 9) x++;
			if (damier[i-1] == 9) x++;
			if (damier[i+1] == 9) x++;
			if (damier[i+TAILLEX] == 9) x++;
			if (damier[i+TAILLEX+1] == 9) x++;
			if (damier[i+TAILLEX+2] == 9) x++;
			damier[i] = x;
		}
	}
}
void display_damier()
{
	int i,j;
	for (i = 0; i < (TAILLEY+2)*(TAILLEX+1); i += TAILLEX+1)
	{
		for (j = 0; j <= TAILLEX+1; j++)
		{
			printf("%2d",damier[i+j]);
		}
		printf("\n");
	}
	printf("\n");
}

void init_jeu()
{
	int i;

	for (i = 0; i < TAILLE_MAX; i++)  jeu[i] = -1;

	for (i = 0; i <= TAILLEX; i++)
	{
		jeu[i] = 10;
		jeu[(TAILLEX+1)*(TAILLEY+1)+i] = 10;
	}

	for (i = 0; i <= TAILLEY; i++)
	{
		jeu[(TAILLEX+1)*i] = 10;
	}

	jeu[(TAILLEX+1)*(TAILLEY+1)+TAILLEX+1] = 10;

}

void display_jeu()
{
	int i,j;
	for (i = 0; i < (TAILLEY+2)*(TAILLEX+1); i += TAILLEX+1)
	{
		for (j = 0; j <= TAILLEX+1; j++)
		{
			printf("%2d",jeu[i+j]);
		}
		printf("\n");
	}
	printf("\n");
}

int select_depart()
{
	/* s‚lection de la case de d‚part :
		on tire au hasard une des cases contenant la plus petite
		valeur possible */
	int i,j;
	nb_cases_vides = 0;
	j=0;
	do
	{
		for (i = 0; i < TAILLE_MAX; i++)
		{
			if (damier[i] == j)
			{
				cases_vides[nb_cases_vides++]=i;
			}
		}
		j++;
	}
	while (nb_cases_vides==0);
	
	i = rand() % nb_cases_vides;
	return cases_vides[i];
}

void joue_case(int c)
{
	if (jeu[c] != -1)
	{
		printf("bug : case jou‚e d‚ja jou‚e !!\n");
		return;
	}
	if (damier[c] == 9)
	{
		printf("BOUM !\n");
	}
	
	if (damier[c] == 0)
	{
		remplit(c);
	}
	else
	{
		jeu[c] = damier[c];
	}
}

void remplit(int c)
{
	pile=0;
	push(c);

	for (;;)
	{
		if (pile == 0) break;
		c = stack[--pile];
		push(c-TAILLEX-2);
		push(c-TAILLEX-1);
		push(c-TAILLEX);
		push(c-1);
		push(c+1);
		push(c+TAILLEX);
		push(c+TAILLEX+1);
		push(c+TAILLEX+2);
	}
}
void push(int c)
{
	if (damier[c] == 0)
	{
		if (jeu[c] != 0)
		{
			jeu[c] = 0;
			stack[pile++] = c;
		}
	}
	else
	{
		jeu[c] = damier[c];
	}
}


void algo1()
{
	/* algorithme de recherche d'une solution */
	/* 1Šre passe : r‚solution simple avec comptage des cases */
	/* = algorithme mono-passe trŠs simple mais trŠs bete !!! */

	int i;
	modifie = 0;
	for (;;)
	{
		coupjoue = 0;
		for (i = 0; i < TAILLE_MAX; i++)
		{
			if (jeu[i] != 10)
			{
				if (jeu[i] != -1)
				{
					nbbombes = 0;
					nblibres = 0;
					scan(i-TAILLEX-2);
					scan(i-TAILLEX-1);
					scan(i-TAILLEX);
					scan(i-1);
					scan(i+1);
					scan(i+TAILLEX);
					scan(i+TAILLEX+1);
					scan(i+TAILLEX+2);
					if (nbbombes == jeu[i])
					{
						/* toutes les cases autour sont vides !!! */
						jouec(i-TAILLEX-2);
						jouec(i-TAILLEX-1);
						jouec(i-TAILLEX);
						jouec(i-1);
						jouec(i+1);
						jouec(i+TAILLEX);
						jouec(i+TAILLEX+1);
						jouec(i+TAILLEX+2);
					}
					else
					{
						if (nbbombes+nblibres == jeu[i])
						{
							/* toutes les cases autour sont des bombes */
							placebombe(i-TAILLEX-2);
							placebombe(i-TAILLEX-1);
							placebombe(i-TAILLEX);
							placebombe(i-1);
							placebombe(i+1);
							placebombe(i+TAILLEX);
							placebombe(i+TAILLEX+1);
							placebombe(i+TAILLEX+2);
						}
					}
				}	
			}
		}
		if (coupjoue == 0) break;
/*		display_jeu(); */
	}
}

void scan(int c)
{
	switch(jeu[c])
	{
		case -1 :
					nblibres++;
					break;
		case 9 :
					nbbombes++;
					break;
	}
}
void jouec(int c)
{
	if (jeu[c] == -1)
	{
		coupjoue = 1;
		modifie = 1;
		joue_case(c);
	}
}

void placebombe(int c)
{
	if (jeu[c] == -1)
	{
		coupjoue = 1;
		jeu[c] = 9;
		if (damier[c] != 9)
		{
			printf("bug : case bombe mal devin‚e\n");
		}
	}
}

void algo2()
{
	/* recherche exhaustive quand tout est bloqu‚ */
	/* travailler avec JEU */
	
	int i;
	nbcases = 0;
	for (i = 0; i < TAILLE_MAX; i++)
	{
		if (jeu[i] == -1)
		{
			/* on dresse une liste des cases … d‚terminer */
			nblibres=0;
			scan2(i-TAILLEX-2);
			scan2(i-TAILLEX-1);
			scan2(i-TAILLEX);
			scan2(i-1);
			scan2(i+1);
			scan2(i+TAILLEX);
			scan2(i+TAILLEX+1);
			scan2(i+TAILLEX+2);
			if ((nblibres != 0) && (nblibres != 8))
			{
				etat[nbcases] = 0;
				liste[nbcases++] = i;
			}
		}
	}

	nbsol = 0;	
	if (nbcases != 0)
	{
		devine(0);
		printf("%d solutions\n",nbsol);
		for (i = 0; i < nbcases; i++)
		{
			switch (etat[i])
			{
				case 1:
						placebombe(liste[i]);	/* c'est une bombe */
						break;
				case 2:
						jouec(liste[i]);		/* c'est une case vide */
						break;
				case 3:
						/* on ne peut pas deviner */
/*						jeu[liste[i]] = 12; */
/*						printf("moi y'en a pas savoir\n"); */
						break;
				default:
						printf("Y'a comme un bug...\n");
			}
		}
	}
}

void scan2(int c)
{
	switch(jeu[c])
	{
		case 0:
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
					nblibres++;
					break;
		case 9:
		case -1:
		case 10:
					break;
		default:
					printf("What a shit...\n");
					break;
	}
}

void devine(int iteration)
{
	int c;
	if (iteration == nbcases)
	{
		solution();
		return;
	}

	c = liste[iteration];
	if (jeu[c] == -1)
	{
		/* vide ? -> on met une bombe */
		jeu[c] = 9;
		if (test_legal(c) == 0)
		{
			devine(iteration+1);
		}
	}
	if (jeu[c] == 9)
	{
		/* bombe ? -> on met une case vide */
		jeu[c] = 11;
		if (test_legal(c) == 0)
		{
			devine(iteration+1);
		}
	}
	/* ni l'un ni l'autre -> on revient en arriŠre */
	jeu[c] = -1;
}

void solution()
{
	/* m‚moriser ‚tat des cases pour solution correcte */
	int i;
	nbsol++;
/*	printf("Solution %d\n",nbsol);*/
	for (i = 0; i < nbcases; i++)
	{
		switch(jeu[liste[i]])
		{
			case 9:
					etat[i] |= 1;
					break;
			case 11:
					etat[i] |= 2;
					break;
			default:
					printf("Onga bonga\n");
		}
	}
/*	display_jeu(); */
}

int test_legal(int c)
{
	if (test(c) != 0) return 1;
	if (test(c-TAILLEX-2) != 0) return 1;
	if (test(c-TAILLEX-1) != 0) return 1;
	if (test(c-TAILLEX) != 0) return 1;
	if (test(c-1) != 0) return 1;
	if (test(c+1) != 0) return 1;
	if (test(c+TAILLEX) != 0) return 1;
	if (test(c+TAILLEX+1) != 0) return 1;
	if (test(c+TAILLEX+2) != 0) return 1;

	return 0;
}

int test(int c)
{
	switch(jeu[c])
	{
		case -1:
		case 10:
		case 11:
					/* on ne peut tester la l‚galit‚ */
					return 0;
		case 9:
					/* la l‚galit‚ est test‚e en v‚rifiant qu'aucune
					    des cases autour ne contient de 0 */
/*
		SI C'EST LE CAS IL S'AGIT D'UN BUG !!!!
*/
					if (jeu[c-TAILLEX-2] == 0) return 1;
					if (jeu[c-TAILLEX-1] == 0) return 1;
					if (jeu[c-TAILLEX] == 0) return 1;
					if (jeu[c-1] == 0) return 1;
					if (jeu[c+1] == 0) return 1;
					if (jeu[c+TAILLEX] == 0) return 1;
					if (jeu[c+TAILLEX+1] == 0) return 1;
					if (jeu[c+TAILLEX+2] == 0) return 1;
					return 0;
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
					/* la l‚galit‚ est test‚e en comptant le nombre
					    de bombes autour de la case */
					nbbombes = 0;
					nblibres = 0;
					compte(c-TAILLEX-2);
					compte(c-TAILLEX-1);
					compte(c-TAILLEX);
					compte(c-1);
					compte(c+1);
					compte(c+TAILLEX);
					compte(c+TAILLEX+1);
					compte(c+TAILLEX+2);

					if (nbbombes > jeu[c]) return 1;
					if (nblibres+nbbombes == 8)
					{
						if (nbbombes!=jeu[c]) return 1;
					}
					return 0;
		default:
					printf("C'est quoi cette fausse valeur ???\n");
					return 55;
	}
}
void compte(int c)
{
	switch (jeu[c])
	{
		case 9:
				nbbombes++;
				break;
		case 0:
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
		case 10:
		case 11:
				nblibres++;
				break;
		case -1:
				break;
	}
}
