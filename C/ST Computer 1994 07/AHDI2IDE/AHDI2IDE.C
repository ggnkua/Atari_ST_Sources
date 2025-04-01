#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>


#define FALSE 0
#define TRUE 1


typedef int boolean;


/* IDE-Parameter, wie sie von
   IDENTIFY DRIVE geliefert werden */

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


/* Funktions-Prototypen */

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

/* Auf IDE-Hardware prÅfen */

	if (!Super ((void *)1L)) oldstack = Super (0L);
	status = testide();
	if (oldstack) Super ((void *)oldstack);

	if (!status) {
		printf("Keine IDE-Hardware vorhanden!\n");
		return(0);
	}

	if (!get_idepars()) {
		printf("Fehler beim Holen der Plattenparameter!\n");
		return(0);
	}

/* IDE-Treiber bereits installiert? */

	if (!Rwabs(8, root, 1, 0, 18)) {
		install_root();
		return(0);
	}

	printf("AHDI mit diesen Parametern patchen? (j/n)");

	do
		input = getchar();
	while ((input != 'j') && (input != 'n'));

	if (input != 'j') return(0);

	printf("\n\n");

	status = patch("a:\\auto\\ahdi.prg");
	if (!status) {
		printf("Fehler beim Patchen vom AHDI.PRG!\n");
		return(0);
	}

	status = patch("a:\\hinstall\\shdriver.raw");
	if (!status) {
		printf("Fehler beim Patchen vom SHDRIVER.RAW!\n");
		return(0);
	}

	status = patch("a:\\hdx\\hdx.prg");
	if (!status) {
		printf("Fehler beim Patchen vom HDX.PRG!\n");
		return(0);
	}

	return(0);
} /* main */



boolean get_idepars()
{
	long oldstack = 0;
	int status;
	char dummy[40];

/* Plattenparameter holen */

	if (!Super ((void *)1L)) oldstack = Super (0L);
	status = identify(&buffer);
	if (oldstack) Super ((void *)oldstack);

	if (status) return(FALSE);

	buffer.reserved3[0] = 0;
	printf("Aktuelle Parameter von IDE-Einheit 0:\n\n");
	printf("Platte: %s\n", buffer.model);
	sprintf(dummy, "%d", buffer.heads);
	printf("Kîpfe: %s\n", dummy);
	sprintf(dummy, "%d", buffer.spt);
	printf("Sektoren pro Spur: %s\n", dummy);
	sprintf(dummy, "%d", buffer.cyls);
	printf("Zylinder: %s\n\n\n", dummy);

	printf("Neue Parameter:\n\n");
	printf("Kîpfe: ");
	scanf("%d", &heads);
	printf("Sektoren pro Spur: ");
	scanf("%d", &spt);
	printf("Zylinder: ");
	scanf("%d", &cyls);

	return(TRUE);
} /* get_idepars */



/* Treiberdatei patchen */

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

/* "CP2024"-Kennung dient als Anhaltspunkt
   fÅr das Auffinden der zu patchenden Sequenz */

	ident = driver;
	while (TRUE) {
		ident = memchr(ident, 'C', len-(ident-driver));
		if (ident == NULL) return(FALSE);
		if (!strncmp(ident, "CP2024", 6)) break;
		else ident++;
	}

/* Neue Parameter in Treiber eintragen */

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



/* Neues Rootprogramm installieren */

boolean install_root()
{
	char input;
	int len, checksum = 0;
	register int i;

	printf("\n\nSoll ein neuer Rootsektor installiert werden? (j/n)");

	do
		input = getchar();
	while ((input != 'j') && (input != 'n'));

	if (input != 'j') return(TRUE);

/* Parameter fÅr IDE-Einheit 0 eintragen */

	idepars[0] = heads;
	idepars[1] = spt;

/* Rootprogramm kopieren */

	len = (int)(end-start);
	for (i=0; i<len; i++) root[i] = start[i];

/* Rootsektor ausfÅhrbar machen */

	for (i=0; i<255; checksum += root[i++]);
	root[i] = 0x1234-checksum;

/* Neuen Rootsektor zurÅckschreiben */

	if (Rwabs(9, root, 1, 0, 18)) return(FALSE);

	return(TRUE);
} /* install_root */