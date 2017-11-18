/*
 *		Comparaisons de Tris (Temps Machine)
 *		( Complexit‚s en O(n2), O(n.log2(n)) et O(n) )
 *
 *		Ces tris travaillent sur des r‚els mais rien n'empˆche
 *		de les adapter sur d'autres types.
 *
 *		Essayez de changer le type des ‚l‚ments du tableau et
 *		observez les diff‚rences ... (par exemple, INT et FLOAT)
 *		Pour pouvoir mieux apr‚cier les perfs des tris, il ne faut pas
 *		prendre des types trop simples, sinon les temps de comparaisons
 *		sont inf‚rieurs (type INT par exemple) au temps du passage des
 *		paramŠtres et ‡a ne veut donc rien dire !!!
 *		( D‚sactivez le coprocesseur pour les mˆmes raisons ! )
 * 
 *		Auteur: MelvinTaylor d'aprŠs un cours d'algo ...
 *		UpDate: 07/05/1996
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "gnpa.h"

#ifdef __TOS__
#include <ext.h>
#else
#include <conio.h>		/* Pour nos amis ( ??? ) PCistes ! */
#endif

#define TAILLETAB 640	/* Taille maxi du tableau … trier pour l'exemple */
#define MAXVAL 999		/* Valeur max des ‚l‚ments … trier */
#define NCOL 16			/* Nb de colonnes pour AfficheTableau */

#define TYPE float		/* type des ‚l‚ments du tableau */

static TYPE A[TAILLETAB];	/* Le tableau … trier */

clock_t t1, t2;			/* Pour le chronom‚trage */


/*------------------------------------------------------------------------*/
void AfficheTableau(void)
/*------------------------------------------------------------------------*/
{
	int i, col=1;
	
	for(i=0; i<=TAILLETAB-1; i++, col++)
		{
		printf("%03.0f  ", A[i]);
		
		if(col==NCOL)
			{
			printf("\n");
			col=0;
			}
		}
	
	printf("\n");
	
} /*AfficheTableau*/

/*------------------------------------------------------------------------*/
void Fusion(int g,int m, int d)
/*------------------------------------------------------------------------*/
		/*	g: indice gauche de la partie … trier
			m: milieu du sous-tableau
			d: indice droit de la partie … trier
		*/
{
	static TYPE B[TAILLETAB];	/* pour l'alloc non dynamique */
	int h=g, i=g, j=m+1, cpt;
	
	while(h<=m && j<=d)
	{
		if(A[h]<=A[j])	/* C'est ici que se font les comparaisons */
			B[i]=A[h++];
		else
			B[i]=A[j++];
		i++;
	}
	
	if(h>m)
		for(cpt=i; cpt<=d; cpt++) B[cpt]=A[j-i+cpt];	/* B[i..d]:=A[j..d] */
	else
		for(cpt=i; cpt<=d; cpt++) B[cpt]=A[h-i+cpt];	/* B[i..d]:=A[h..m] */
	
	for(cpt=g; cpt<=d; cpt++) A[cpt]=B[cpt];			/* A[g..d]:=B[g..d] */
	
} /*Fusion*/


/*------------------------------------------------------------------------*/
void Tri_Fusion(int g, int d)
/*------------------------------------------------------------------------*/
		/* g et d sont les bornes du tableau (sous-tableau) … trier */
{
	int m;
	
	if(g<d)	/* Cas d'arrˆt */
		{
		m=(g+d) >> 1;		/* ie  m:=(g+d) div 2 */
		Tri_Fusion(g,m);		/* Tri partie gauche */
		Tri_Fusion(m+1,d);	/* Tri partie droite */
		Fusion(g,m,d);		/* Fusion des deux */
		}
		
} /*Tri_Fusion*/


/*------------------------------------------------------------------------*/
void Fusion2(int g,int m, int d)
/*------------------------------------------------------------------------*/
		/*	g: indice gauche de la partie … trier
			m: milieu du sous-tableau
			d: indice droit de la partie … trier
		*/
{
	TYPE *B;	/* Attention: l'alloc dyn. allonge les temps ! */
	int h=g, i=g, j=m+1, cpt;

	/* Allocation du sous-tableau local */
	B=(TYPE *) malloc(sizeof(TYPE)*(d-g+1));
	
	while(h<=m && j<=d)
	{
		if(A[h]<=A[j])		/* C'est ici que se font les comparaisons */
			B[i-g]=A[h++];	/* virer le '-g' pour l'alloc non dyn. */
		else
			B[i-g]=A[j++];	/* idem pour tous les B[..-g] */
		i++;
	}
	
	if(h>m)
		for(cpt=i; cpt<=d; cpt++) B[cpt-g]=A[j-i+cpt];	/* B[i..d]:=A[j..d] */
	else
		for(cpt=i; cpt<=d; cpt++) B[cpt-g]=A[h-i+cpt];	/* B[i..d]:=A[h..m] */
	
	for(cpt=g; cpt<=d; cpt++) A[cpt]=B[cpt-g];			/* A[g..d]:=B[g..d] */
	
	free(B);	/* Lib‚ration de sous-tableau local */
	
} /*Fusion2*/


/*------------------------------------------------------------------------*/
void Tri_Fusion2(int g, int d)
/*------------------------------------------------------------------------*/
		/* g et d sont les bornes du tableau (sous-tableau) … trier */
{
	int m;
	
	if(g<d)	/* Cas d'arrˆt */
		{
		m=(g+d) >> 1;		/* ie  m:=(g+d) div 2 */
		Tri_Fusion2(g,m);	/* Tri partie gauche */
		Tri_Fusion2(m+1,d);	/* Tri partie droite */
		Fusion2(g,m,d);		/* Fusion des deux */
		}
		
} /*Tri_Fusion2*/


/*------------------------------------------------------------------------*/
int Partition(int g, int d)
/*------------------------------------------------------------------------*/
{
	TYPE pivot, tmp;
	int i, j;
	
	pivot=A[d]; i=g-1; j=d;
	
	do
		{
		do i++; while( A[i] < pivot );
		do j--; while( A[j] > pivot );
		
		if( i < j )
			{		/* SWAP */
			tmp=A[i]; A[i]=A[j]; A[j]=tmp;
			}
		}
	while( i < j );
	
	tmp=A[i]; A[i]=A[d]; A[d]=tmp;	/* SWAP */
	
	return i;

} /*Partition*/


/*------------------------------------------------------------------------*/
void Tri_Rapide(int i, int j)
/*------------------------------------------------------------------------*/
{
	int s;
	
	if(i<j)
		{
		s=Partition(i,j);
		Tri_Rapide(i,s-1);
		Tri_Rapide(s+1,j);
		}

} /*Tri_Rapide*/


/*------------------------------------------------------------------------*/
void Tri_Insertion(void)
/*------------------------------------------------------------------------*/
{
	int i, j;
	TYPE tmp;
	
	for (i=1 ; i<TAILLETAB ; i++)
		{
		tmp = A[i];
		j = i-1;
		while ( (tmp < A[j]) && j>=0 )
			A[j+1] = A[j--];
		
		A[j+1] = tmp;
		}

} /*Tri_Insertion*/


/*------------------------------------------------------------------------*/
void Tri_Bulle(void)
/*------------------------------------------------------------------------*/
{
	int i, j;
	TYPE tmp;
	
	for (i=0 ; i<TAILLETAB-1 ; i++)
		for (j=1 ; j<TAILLETAB ; j++)
			if (A[j-1] > A[j])
				{	/* SWAP */
				tmp = A[j-1];
				A[j-1] = A[j];
				A[j] = tmp;
				}

} /*Tri_Bulle*/


/*------------------------------------------------------------------------*/
void Tri_Comb(void)	/* Source original dans le magazine Byte,  April 1991 */
/*------------------------------------------------------------------------*/

#define SHRINKFACTOR 1.3		/* Valeur bas‚e sur des statistiques */

{
	int switches, i, j, top, gap;
	TYPE tmp;
	
	gap=TAILLETAB;
	
	do	{
		gap = (int) ((float) gap / SHRINKFACTOR);
		
		switch(gap)
			{
			case  0:	gap=1;
						break;
			case  9:				/* l…, ya rien !! ??? */
			case 10:	gap=11;
						break;
			default:	break;
			}
	
		switches=0;
		top = TAILLETAB - gap;
	
		for(i=0; i<top; ++i)
			{
				j=i+gap;
				if(A[i] > A[j])
					{	/* SWAP */
					tmp=A[i];
					A[i]=A[j];
					A[j]=tmp;
					++switches;
					}
			}
		}
	while(switches || (gap > 1));

} /*Tri_Comb*/


/*------------------------------------------------------------------------*/
void Tri_Shell(void)
/*------------------------------------------------------------------------*/
{
	int i, j, k;
	TYPE tmp;
	
	for (k=TAILLETAB/2; k>0 ; k /= 2)
		for (i=k ; i<TAILLETAB ; i++)
			for (j=i-k ; j>=0 && A[j]>A[j+k] ; j-=k)
				{	/* SWAP */
				tmp = A[j];
				A[j] = A[j+k];
				A[j+k] = tmp;
				}

} /*Tri_Shell*/


/*------------------------------------------------------------------------*/
void Tri_Substitution(void)
/*------------------------------------------------------------------------*/
{
	int i, j, n, cpt=0;
	static int B[MAXVAL+1];
	
	for(i=0; i<=MAXVAL; i++)	/* initialisations */
		B[i]=0;
		
	for(i=0; i<TAILLETAB; i++)
		B[ (int) A[i] ]+=1;		/* nb d'occurences incr‚ment‚ */
	
	for(i=0; i<=MAXVAL; i++)
		if( (n=B[i]) > 0 )
			for(j=0; j<n; j++)
				A[cpt++]=(TYPE) i;
}


/*------------------------------------------------------------------------*/
void CopieTAB(TYPE *Tab_A, TYPE *Tab_B)
/*------------------------------------------------------------------------*/
		/* copie la tableau a dans le tableau b */
{
	int i;
	
	for(i=0; i<TAILLETAB; i++)
		Tab_B[i]=Tab_A[i];
		
} /*CopieTAB*/


/*------------------------------------------------------------------------*/
void AfficheTemps(void)
/*------------------------------------------------------------------------*/
{
	int a, b, c;
	long d;

	d = (((t2-t1)*1000) / CLK_TCK);	/* Temps en milliŠmes de secondes */

	a=(int) (d / 1000 / 60);		/* Minutes   */
	b=(int) (d/1000 - a*60);		/* Secondes  */
	c=(int) (d - (d/1000)*1000);	/* MilliŠmes */

	printf("Tableau tri‚ en %d\'%02d\"%03d (t1=%ld, t2=%ld, d=%ld).\n\n", a, b, c, t1, t2, d);

} /*AfficheTemps*/


/*------------------------------------------------------------------------*/
int main(void)
/*------------------------------------------------------------------------*/
{
	int i, AffOK;
	char c;
	static TYPE TMP[TAILLETAB];	/* Pour conserver le tableau non tri‚ */
	
	printf("\nComparaison de tris sur un tableau de %d r‚els:\n\n",TAILLETAB);
	printf("Affichage des tableaux tri‚s (o/n) ? "); c=getche();
	AffOK=(toupper(c) == 'O');
	
	printf("\nCr‚ation al‚atoire du tableau ...\n");

	Randomize();
	printf("\nTri sur un tableau: non tri‚ [1], tri‚ d‚croissant [2], tri‚ croissant [3]: ");
	c=getche(); printf("\n\n");
	
	switch(c)
		{
		case '1':	for(i=0; i<TAILLETAB; i++)
						TMP[i]=A[i]=(TYPE) Random(MAXVAL);	/* au hasard */
					break;
		case '2':	for(i=0; i<TAILLETAB; i++)
						TMP[i]=A[i]=(TYPE) (TAILLETAB - i);	/* tri‚ d‚croissant */
					break;
		case '3':	for(i=0; i<TAILLETAB; i++)
						TMP[i]=A[i]=(TYPE) (i+1);			/* tri‚ croissant */
					break;
		}
		
		
	if(AffOK)
		{
		printf("\nTableau non tri‚:\n");
		AfficheTableau();
		}
	
	printf("\nTri Fusion (statique):\n");
	t1=clock();
	Tri_Fusion(0,TAILLETAB-1);
	t2=clock();
	AfficheTemps();
	if(AffOK) AfficheTableau();
		
	CopieTAB(TMP,A);

	printf("\nTri Fusion (dynamique):\n");
	t1=clock();
	Tri_Fusion2(0,TAILLETAB-1);
	t2=clock();
	AfficheTemps();
	if(AffOK) AfficheTableau();
		
	CopieTAB(TMP,A);

	printf("\nTri Rapide (QuickSort):\n");
	t1=clock();
	Tri_Rapide(0,TAILLETAB-1);
	t2=clock();
	AfficheTemps();
	if(AffOK) AfficheTableau();
	
	CopieTAB(TMP,A);

	printf("\nTri … Bulles:\n");
	t1=clock();
	Tri_Bulle();
	t2=clock();
	AfficheTemps();
	if(AffOK) AfficheTableau();

	CopieTAB(TMP,A);
	
	printf("\nTri par Insertion:\n");
	t1=clock();
	Tri_Insertion();
	t2=clock();
	AfficheTemps();
	if(AffOK) AfficheTableau();
	
	CopieTAB(TMP,A);

	printf("\nTri par Substitution:\n");
	t1=clock();
	Tri_Substitution();
	t2=clock();
	AfficheTemps();
	if(AffOK) AfficheTableau();

	CopieTAB(TMP,A);
	
	printf("\nTri Comb (CombSort):\n");
	t1=clock();
	Tri_Comb();
	t2=clock();
	AfficheTemps();
	if(AffOK) AfficheTableau();
	
	CopieTAB(TMP,A);
	
	printf("\nTri par Shell:\n");
	t1=clock();
	Tri_Shell();
	t2=clock();
	AfficheTemps();
	if(AffOK) AfficheTableau();
	

	printf("\n\nTaper une touche ..."); getch();
	
	return 0;
}
