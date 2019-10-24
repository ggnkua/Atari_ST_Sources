#define	nbspl	ACT_CLK16K*2L
#define PRESCALE	CLK16K
#define	Npoints	400
#define	DefMaxMots	16

typedef struct
{
	int nmots;
	int nmaxmots;
	int hcar;
	int first;
	int selected;
	char **ptrmots;
}LISTE_MOTS;
