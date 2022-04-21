/* Defines un Structs fÅr DigiTape Module */
/* letzte énderung 1.7.93 */

#define DTM_VERSION 'DTM1'

/*-------------------------------------------------------------------- 
Messages an die Module Åber:
procedure( int module_action,		siehe folgende Defines
					 Glob_globals *glob,	Zeiger auf System-Globals
					 int x,
					 int y,
					 int param		MOD_INIT: TRUE=Aufnahme von Master eingestellt
				 )
Return FALSE wenn das Modul die Message nicht selbst verarbeitet
----------------------------------------------------------------------*/

#define MOD_RSC_INIT 				1		/* beim Modulladen */
#define MOD_INIT						2		/* beim Moduleinklinken
																	 param: TRUE wenn Rec. von Mastermodul
																	 				eingestellt */
#define MOD_DRAW						3		/* vor Modulmalen */

#define MOD_LOAD_DSP				4		/* DSP soll geladen werden
																	 x: DSP-Eingangsvariable (bei mono)
																	 y: Ausgangsvariable (bei mono)
																	 param: Adresse von Puffer (Echo etc.)*/
#define MOD_CLR_MEMORY			5		/* DSP-Puffer sollen gelîscht werden */

#define MOD_LBUTTONDOWN			6		/* Linke Maustaste down
																	 x, y: Mausposition */
#define MOD_MOUSEMOVE				7		/* Maus hat sich mit Taste unten bewegt
																	 x, y: Mausposition */
#define MOD_LBUTTONUP				8		/* Linke Maustaste losgelassen */
#define MOD_OUT_VOLS				9		/* Regler-Einstellungen an DSP melden */

#define MOD_SLIDER_MOVED 	 10		/* Regler wurde verÑndert:
																	 x: Regler-Nummer (-2: Vol, -1: Pan )
																	 y: Position 0 bis 255 */
#define MOD_BUTTON_CHANGED 11		/* Knopf wurde verÑndert
																	 x: Object-Index */
#define MOD_DEL_EFFECT		 12		/* nicht fÅr externe Module */

#define MOD_GET_VERSION		999		/* Versionsnummer soll returned werden */


/* Bits fÅr 'type' in Module_info */
#define STEREO_IN  2
#define STEREO_OUT 1

/* Modulbeschreibung */
typedef struct
{
	int type;

	int x6, x8, x15, xbuff_size; /* DSP-Speicherbedarf */
	int y6, y8, y15, ybuff_size;

	char *mcomment;  /* Kommentar, erscheint in Auswahlmenu */
} Module_info;

/* Objektindices des Resource */
typedef struct
{
	int tree_index;
	int titel_index;	/* Index der Unterschrift */
	int solo_index;
	int eject_index;
	int mute_index;
	int vol_parent;  /* Feld, auf dem sich Volume-Regler bewegt */
	int vol_slider;	 /* Regler. Immer vertikal! */
	int pan_parent;  /* immer horizontal */
	int pan_slider;
} Rsc_info;


typedef struct
{
	int bitplanes;
	int nr_effekte;

	long	Hz; /* aktuell eingestellte Freq. */
	long	tape_Hz;
	long	reserve[4];	/* Platz fuer Erweiterungen */

	void	*track_info; /* Zeiger auf Array */
	void	*free[7];

	void (*_dtm_init)( Module_info *dtm_info,
										 void *rsc, Rsc_info *rsc_info);
	int		(*_dtm_init_poti)(void *vglob, int potinr, int type,
													int parent, int slider, int value);

	int		(*_mrsc_load)(void *rsc_hdr);
	long	*(*_log_tab_entry)( int wert );
	long	(*_get_rsc_pegel)( int f_size, int s_size, int s_posi,
													long max, int vertikal );
	void (*_set_line_volume)( int button, int vol, int line_nr );
	void (*_set_line_panorama)( int button, int pan, int line_nr );

	int  (*_DialogState)(HDIALOG hdialog, int item, int set, int maske);
	int  (*_DialogFlags)(HDIALOG hdialog, int item, int set, int maske);
	int  (*_DialogPrintf)(HDIALOG hdialog, int item, char *format, ...);

	void (*_draw_object)( OBJECT *obj, int item );
	int  (*_object_find)( OBJECT *baum, int anf_obj, int tiefe, int x, int y );

	void (*_dm_setvar)(int memtype, int var, long *value, int size);
	int  (*_dm_defvar)(int typ, int adrsize, int size);
	int  cdecl (*_dm_load)(void *modul, ...);
	void (*_dsp_setblock)( int memtyp, int adr, long wert, int size);
} System_globals;

typedef struct
{
	int line_nr; /* 0-7: Tracks, 8-15: Effekte */
	int slot_nr;
	OBJECT *object_ptr;
	HDIALOG hdialog;

	System_globals *sys;
	Module_info *mhinfo;

	int	track_nr;  /* fuer Track-Module */
	int	track_nr2; /* 2. Kanal bei Stereo */
	char leer[50];
} Modul_header;

/* Defines fÅr Poti.type */
#define H_POTI 0
#define V_POTI 1

typedef struct
{
	char type;
	char activ;
	int  parent_index;
	int  slider_index;
	unsigned char position;
	unsigned char obj_position;
} Poti;

#define POTI_ZAHL 12
typedef struct
{
	char l_butt; 		/* schaltet Ausgang */
	char solo_butt; /* Solo-Tastenzustand */
	int  in_left;		/* Input links DSP-Variable */
	int  in_right;  /* Input rechts DSP-Variable */
	int  out_left;	/* Output links  DSP-Variable */
	int  out_right;	/* Output rechts DSP-Variable */
	Poti vol_poti;
	Poti pan_poti;
	Poti potis[POTI_ZAHL];
} Modul_globals;
