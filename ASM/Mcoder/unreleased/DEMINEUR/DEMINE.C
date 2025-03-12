/*
	programme de r‚solution du d‚mineur	
*/
#include <stdio.h>
#include <stdlib.h>

#define N 8			/* taille du damier */
#define NB_BOMBES 11	/* nombre de bombes sur le damier */

#define TAILLE_MAX (N*N+N*3+3) /* taille maximum du damier=20*20 */
char damier[TAILLE_MAX];	/* tableau contenant les bombes pos‚es
							    par le programme */
char jeu[TAILLE_MAX];		/* tableau des coups jou‚s par le joueur */
char tableau[TAILLE_MAX];	/* tableau recherche intelligente */
int pile,stack[N*N];		/* pile des cases pour recherche r‚cursive */
int nb_cases_vides,cases_vides[N*N];

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
void simplifie();
void inck(int i);
void simple(int c);
void display_tab();
void algo2();
void scan2(int c);
void devine(int i);
void solution();
int test_legal(int c);
int test(int c);
void compte(int c);

int coupjoue;
int nbbombes,nblibres;
int nbcases,liste[N*N],etat[N*N];
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
/*	display_jeu(); */
	do
	{
		algo1();
		display_jeu();
		simplifie();
/*	display_tab(); */

		algo2();
		display_jeu();
	}
	while (coupjoue !=0);
	printf("fini...\n");
	getchar();
	return 0;
}

void init_damier()
{
	int i,x;

	for (i = 0; i < TAILLE_MAX; i++)  damier[i] = -1;

	for (i = 0; i <= N; i++)
	{
		damier[i] = 10;
		damier[(N+1)*(N+1)+i] = 10;
		damier[(N+1)*i] = 10;
	}
	damier[(N+1)*(N+1)+N+1] = 10;

	/* tirage des bombes */
	
	if (NB_BOMBES > N*N)
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
			if (damier[i-N-2] == 9) x++;
			if (damier[i-N-1] == 9) x++;
			if (damier[i-N] == 9) x++;
			if (damier[i-1] == 9) x++;
			if (damier[i+1] == 9) x++;
			if (damier[i+N] == 9) x++;
			if (damier[i+N+1] == 9) x++;
			if (damier[i+N+2] == 9) x++;
			damier[i] = x;
		}
	}
}
void display_damier()
{
	int i,j;
	for (i = 0; i < (N+2)*(N+1); i += N+1)
	{
		for (j = 0; j <= N+1; j++)
		{
			printf("%3d",damier[i+j]);
		}
		printf("\n");
	}
	printf("\n");
}

void init_jeu()
{
	int i;

	for (i = 0; i < TAILLE_MAX; i++)  jeu[i] = -1;

	for (i = 0; i <= N; i++)
	{
		jeu[i] = 10;
		jeu[(N+1)*(N+1)+i] = 10;
		jeu[(N+1)*i] = 10;
	}
	jeu[(N+1)*(N+1)+N+1] = 10;
}
void display_jeu()
{
	int i,j;
	for (i = 0; i < (N+2)*(N+1); i += N+1)
	{
		for (j = 0; j <= N+1; j++)
		{
			printf("%3d",jeu[i+j]);
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
		push(c-N-2);
		push(c-N-1);
		push(c-N);
		push(c-1);
		push(c+1);
		push(c+N);
		push(c+N+1);
		push(c+N+2);
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
	for (;;)
	{
		coupjoue=0;
		for (i = 0; i < TAILLE_MAX; i++)
		{
			if (jeu[i] != 10)
			{
				if (jeu[i] != -1)
				{
					nbbombes=0;
					nblibres=0;
					scan(i-N-2);
					scan(i-N-1);
					scan(i-N);
					scan(i-1);
					scan(i+1);
					scan(i+N);
					scan(i+N+1);
					scan(i+N+2);
					if (nbbombes == jeu[i])
					{
						/* toutes les cases autour sont vides !!! */
						jouec(i-N-2);
						jouec(i-N-1);
						jouec(i-N);
						jouec(i-1);
						jouec(i+1);
						jouec(i+N);
						jouec(i+N+1);
						jouec(i+N+2);
					}
					else
					{
						if (nbbombes+nblibres == jeu[i])
						{
							/* toutes les cases autour sont des bombes */
							placebombe(i-N-2);
							placebombe(i-N-1);
							placebombe(i-N);
							placebombe(i-1);
							placebombe(i+1);
							placebombe(i+N);
							placebombe(i+N+1);
							placebombe(i+N+2);
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
		coupjoue=1;
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


void simplifie()
{
	int i;
	for (i = 0; i < TAILLE_MAX; i++)
	{
		tableau[i] = jeu[i];
	}
	for (i = 0; i < TAILLE_MAX; i++)
	{
		/* recherche des bombes entour‚es pour simplification */
		if (tableau[i] == 9)
		{
			nblibres = 0;
			inck(tableau[i-N-2]);
			inck(tableau[i-N-1]);
			inck(tableau[i-N]);
			inck(tableau[i-1]);
			inck(tableau[i+1]);
			inck(tableau[i+N]);
			inck(tableau[i+N+1]);
			inck(tableau[i+N+2]);
			if (nblibres == 8)
			{
				nbbombes = 0;
				simple(i-N-2);
				simple(i-N-1);
				simple(i-N);
				simple(i-1);
				simple(i+1);
				simple(i+N);
				simple(i+N+1);
				simple(i+N+2);
				tableau[i] = nbbombes;
			}
		}
	}
}
void inck(int i)
{
	switch(i)
	{
		case -1:
					break;
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
		case 9:
		case 10:
					nblibres++;
					break;
		default:
					printf("bug -> valeur inattendue autour d'une bombe\n");
					break;
	}
}
void simple(int c)
{
	switch(tableau[c])
	{
		case 10:
					break;
		case 9:
					nbbombes++;
					break;
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
					--tableau[c];
					break;
		default:
					printf("Encore une drole de valeur dans une case...\n");
					break;
	}
}
void display_tab()
{
	int i,j;
	for (i = 0; i < (N+2)*(N+1); i += N+1)
	{
		for (j = 0; j <= N+1; j++)
		{
			printf("%3d",tableau[i+j]);
		}
		printf("\n");
	}
	printf("\n");
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
			scan2(i-N-2);
			scan2(i-N-1);
			scan2(i-N);
			scan2(i-1);
			scan2(i+1);
			scan2(i+N);
			scan2(i+N+1);
			scan2(i+N+2);
			if ((nblibres != 0) && (nblibres != 8))
			{
				etat[nbcases] = 0;
				liste[nbcases++] = i;
			}
		}
	}

	coupjoue=0;
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
	if (test(c-N-2) != 0) return 1;
	if (test(c-N-1) != 0) return 1;
	if (test(c-N) != 0) return 1;
	if (test(c-1) != 0) return 1;
	if (test(c+1) != 0) return 1;
	if (test(c+N) != 0) return 1;
	if (test(c+N+1) != 0) return 1;
	if (test(c+N+2) != 0) return 1;

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
					if (jeu[c-N-2] == 0) return 1;
					if (jeu[c-N-1] == 0) return 1;
					if (jeu[c-N] == 0) return 1;
					if (jeu[c-1] == 0) return 1;
					if (jeu[c+1] == 0) return 1;
					if (jeu[c+N] == 0) return 1;
					if (jeu[c+N+1] == 0) return 1;
					if (jeu[c+N+2] == 0) return 1;
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
					compte(c-N-2);
					compte(c-N-1);
					compte(c-N);
					compte(c-1);
					compte(c+1);
					compte(c+N);
					compte(c+N+1);
					compte(c+N+2);

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
