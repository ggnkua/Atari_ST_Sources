/* Aufbau der indexierten Datenbank:
	db_path/DBASE.IDX enthÑlt einen Eintrag fÅr jede Nachricht
	im Format INDEXER
	db_path/DBASE.DAT enthÑlt einen Eintrag fÅr jede Nachricht
	im Format INDEXER sowie direkt danach die Nachricht selbst
	
	Ausgenommen sind zu versendende Nachrichten (da diese
	Editierbar sind und die ganze DAT jedesmal umkopiert
	werden mÅûte).
	
	Persînliche zu versendende finden sich nach wie vor im
	db_path/PM-Ordner als *.SND
	ôffentliche sind unter db_path/OM/SEND als *.SND
	
	Nach dem Versenden werden persînliche automatisch
	als *.SNT importiert.
	ôffentliche werden nicht importiert, da sie sowieso
	gelîscht werden, weil der Server sie ja als neue
	îffentliche zurÅckschickt
	
*/

typedef struct
{
	long		magic1;		/* 'IdXm' Zum auffinden des Index */
	long		magic2;		/* 'hGwM' bei einer Reparatur */
	
	ftype		:4 ;	/* File types
										FLD_SND	0 nicht benutzt, wird ignoriert
										FLD_SNT	1
										FLD_NEW	2
										FLD_RED	3
									*/
	flags		:12	;	/* s. flag-defs */

	char		from[66];
	char		to[66];
	char		subj[66];
	uint		ftime;			/* Uhrzeit (GEMDOS-Format) */ 
	uint		fdate;			/* Datum (GEMDOS-Format) */

	long		list_id;	/* Ordner-ID oder Gruppen-ID (=Nummern-Name des Ordners im Dateisystem) oder nix */
	
	char		msg_id[66];
	char		in_reply_to[66];
	char		references[66];
	
	long		db_offset;	/* Offset in der Datenbank */
	long		db_size;		/* LÑnge in Bytes */
}INDEXER;

/* 
	 Achtung, in der Datenbank steht an der Stelle db_offset
	 zunÑchst nochmal genau dieser Header und erst dann die
	 Nachricht. db_size ist die Gesamtgrîûe Header+Nachricht 
*/

/* flag-defs: */
#define FF_ATX	1		/* EnthÑlt Anhang */
#define FF_ANS	2		/* Wurde beantwortet */

#define FF_NON  0		/* Wie ftype=0, wird ignoriert */
#define FF_PM		4		/* Ist PM */
#define FF_OM		8		/* Ist OM */
#define FF_ORD	16	/* Ist geordnet */
#define FF_DEL	32	/* Ist gelîscht */
#define FF_LOCATION (FF_PM|FF_OM|FF_ORD|FF_DEL)	/* Maske */

#define FF_ISOM 64	/* Ist OM (kann auch eingeordnet sein etc.) */

#define FF_ITR	128	/* Ist interessant (soll nicht gelîscht werden) */

void Import_files(int show_win);
void Export_files(int show_win);


#define IDX_FIRST 0
#define IDX_NEXT 	1
#define IDX_LAST  2

INDEXER *Idx_scan(int mode, int location, long f_index, long *fidx);

void	Idx_delete(long index);
void	Idx_ord(long index, long list_id);
void	Idx_kill(long index);
void	Idx_settype(long index, int ftype);
void	Idx_setflag(long index, int flag);
void	Idx_clearflag(long index, int flag);
void	Idx_list_move(int old_loc, long old_id, int new_loc, long new_id);
void	Idx_extract_to(long index, char *path);
void	Idx_detach_to(long index, char *path);
void	Idx_import_file(int location, long list_id, char *path);
int		Idx_load_mail(INDEXER *idx, char *buf);
int		Idx_move_if(int old_loc, int new_loc, uint d_date, void (*guckguck)(void));
void	Idx_clear(void (*guckguck)(void));
int		Check_dbase(void);
