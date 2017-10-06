#ifndef FALSE
	#define FALSE	0
	#define TRUE	(!FALSE)
#endif

/****************************************************************/
/* Typendefinitionen:											*/
/****************************************************************/
typedef unsigned int INTELWD; 		/* Integer im Intel-Format	*/
typedef unsigned long INTELLG;		/* Langwort im Intel-Format */


/****************************************************************/
/* Ein Directoryeintrag:										*/
/****************************************************************/
typedef struct{
	char name[11];		/* Dateinmae		*/
	char attr;			/* Attribut			*/
	int resvd[5];		/* reserviert		*/
	INTELWD gemtime;	/* GEMDOS-Uhrzeit	*/
	INTELWD gemdat;		/* GEMDOS-Datum		*/
	INTELWD stclus;		/* Startcluster		*/
	INTELLG fl;			/* Dateil„nge		*/
}DIR;


/****************************************************************/
/* Ein Laufwerksinfo:											*/
/****************************************************************/
typedef struct{
	int files;		/* Dateien */
	int subdir;		/* Unterverzeichnisse */
	int badclus;	/* defekte Cluster */
	int orphan;		/* verwaiste Cluster */
}DRIVE;


/****************************************************************/
/* Funktionsprototypen:											*/
/****************************************************************/
void bpb_info( BPB *p );
void load_fat( int drive, BPB *p, INTELWD *fat );
void save_fat( int drive, BPB *p, INTELWD *fat );

void trace_root( BPB *p, INTELWD *fat, DRIVE *d, int drive );
void trace_fil( INTELWD *fat, int start );
void tr_subdir( BPB *p, INTELWD *fat, unsigned int start, DRIVE *d,
				int drive );
				
unsigned int mot( INTELWD x );
unsigned long lmot( INTELLG x );
long peek( long x );