/********************************/
/*       Patch pour AHDI        */
/********************************/
/*       Par Uwe SEIMET         */
/********************************/
/* Traduit par Olivier JACQUES  */
/********************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>

#define FALSE 0
#define TRUE 1

typedef int boolean;

/* IDE-Parameter, tels qu'ils sont
   fournis par IDENTIFY DRIVE */

typedef struct {
	int flags;
	int cyls;
	int reserved1;
	int heads;
	int bpt;
	int bps;
	int spt;
	int reserved2[3];
	char serial[20];
	int type;
	int size;
	int ecc;
	char firmware[8];
	char model[40];
	int reserved3[82];
	char reserved4[256];
} IDEPARS;


IDEPARS buffer;

int heads, spt, cyls;

char driver[100000l];

int root[512];

/* Prototype des fonctions */

boolean get_idepars(void);
boolean patch(char *filename);
boolean install_root(void);

extern int testide(void);
extern int identify(IDEPARS *buffer);
extern int start[], end[];
extern char idepars[2];

int main()
{
	char input;
	long oldstack = 0;
	int status;

/* Tester le Hardware IDE */

	if (!Super ((void *)1L)) oldstack = Super (0L);
	status = testide();
	if (oldstack) Super ((void *)oldstack);

	if (!status) {
		printf("Pas de carte IDE reconnue !\n");
		return(0);
	}

	if (!get_idepars()) {
		printf("Erreur lors de l'acquisition des paramätres du disque !\n");
		return(0);
	}

/* Driver IDE dÇjÖ installÇ ? */

	if (!Rwabs(8, root, 1, 0, 18)) {
		install_root();
		return(0);
	}

	printf("Patcher AHDI avec ces paramätres ? (o/n)");

	do
		input = getchar();
	while ((input != 'o') && (input != 'n'));

	if (input != 'o') return(0);

	printf("\n\n");

	status = patch("a:\\auto\\ahdi.prg");
	if (!status) {
		printf("Erreur lors du parch d'AHDI.PRG!\n");
		return(0);
	}

	status = patch("a:\\hinstall\\shdriver.raw");
	if (!status) {
		printf("Erreur lors du patch de SHDRIVER.RAW!\n");
		return(0);
	}

	status = patch("a:\\hdx\\hdx.prg");
	if (!status) {
		printf("Erreur lros du patch de HDX.PRG!\n");
		return(0);
	}

	return(0);
} /* main */

boolean get_idepars()
{
	long oldstack = 0;
	int status;
	char dummy[40];

/* Modifier les paramätres du disque */

	if (!Super ((void *)1L)) oldstack = Super (0L);
	status = identify(&buffer);
	if (oldstack) Super ((void *)oldstack);

	if (status) return(FALSE);

	buffer.reserved3[0] = 0;
	printf("Paramätres actuels de l'unitÇ IDE 0:\n\n");
	printf("Disque: %s\n", buffer.model);
	sprintf(dummy, "%d", buffer.heads);
	printf("Tàtes: %s\n", dummy);
	sprintf(dummy, "%d", buffer.spt);
	printf("Secteurs par piste: %s\n", dummy);
	sprintf(dummy, "%d", buffer.cyls);
	printf("Cylindres: %s\n\n\n", dummy);

	printf("Nouveaux paramätres:\n\n");
	printf("Tàtes: ");
	scanf("%d", &heads);
	printf("Secteurs par piste: ");
	scanf("%d", &spt);
	printf("Cylindres: ");
	scanf("%d", &cyls);

	return(TRUE);
} /* get_idepars */

/* Patcher le driver */

boolean patch(filename)
char *filename;
{
	long len;
	int handle;
	char *ident;
	int *dummy;

	printf("Patche %s\n", filename);

	handle = open(filename, O_RDONLY);
	if (handle < 0) return(FALSE);
	len = read(handle, driver, 100000l);
	close (handle);
	if (len < 0) return(FALSE);

/* "CP2024"-sert de point de repäre
   pour la recherche de la sÇquence Ö patcher */

	ident = driver;
	while (TRUE) {
		ident = memchr(ident, 'C', len-(ident-driver));
		if (ident == NULL) return(FALSE);
		if (!strncmp(ident, "CP2024", 6)) break;
		else ident++;
	}

/* Placer les nouveaux paramätres dans le driver */

	dummy = (int *)(ident-74);
	dummy[0] = 0x303c;	/* MOVE #,D0 */
	dummy[1] = cyls;
	dummy[2] = 0x323c;	/* MOVE #,D1 */
	dummy[3] = heads;
	dummy[4] = 0x343c;	/* MOVE #,D2 */
	dummy[5] = spt;
	dummy[6] = 0x4e75;	/* RTS */

	handle = open(filename, O_WRONLY);
	if (handle < 0) return(-1);
	if (write(handle, driver, len) != len) {
		close(handle);
		return(FALSE);
	}
	close (handle);

	return(TRUE);
} /* patch */

/* Installer un nouveau programme Root */

boolean install_root()
{
	char input;
	int len, checksum = 0;
	register int i;

	printf("\n\nDois-je installer un nouveau Rootsecteur ? (o/n)");

	do
		input = getchar();
	while ((input != 'o') && (input != 'n'));

	if (input != 'o') return(TRUE);

/* Enregistre les paramätres pour l'unitÇ IDE 0 */

	idepars[0] = heads;
	idepars[1] = spt;

/* Copier le Rootsecteur */

	len = (int)(end-start);
	for (i=0; i<len; i++) root[i] = start[i];

/* Rendre le Rootsecteur exÇcutable */

	for (i=0; i<255; checksum += root[i++]);
	root[i] = 0x1234-checksum;

/* Ecrire le nouveau Rootsecteur */

	if (Rwabs(9, root, 1, 0, 18)) return(FALSE);

	return(TRUE);
} /* install_root */