/* Definitionen usw. fÅr DTE 2 */

#define PICBREITE 12
#define PICHOEHE 4

#define MAX_SCHUESSE 50
#define MAX_LEVEL 20
#define MAX_MONSTER 20
#define MAX_EXPLOSIONEN 20

#define SPIELBREITE 320
#define SPIELHOEHE 320

typedef struct
{
	char leben;
	int punkte;
	int pos;
	int neues_leben;
} SPIELER;

typedef struct
{
	char art;
	int x;
	int y;
	int xpl;
	int ypl;
} SCHUSS;

typedef struct
{
	char art;
	char stufe;
	int x;
	int y;
	int xpl;
	int ypl;
	char richtung;
} MONSTER;

typedef struct
{
	int anz_monster;
	MONSTER monster[MAX_MONSTER];
} LEVEL_MONSTER;

typedef struct
{
	char art;
	int x;
	int y;
} EXPLOSION;