/* ---------------------------------------------------------------------- */
/*    Window Manager Header File 													  */
/*																								  */
/*      written by Boris Sander                                           */
/*																								  */
/* Copyright (c) 1992 by ICP - Innovativ Computer-Presse GmbH & Co. KG    */
/* ---------------------------------------------------------------------- */
#define min(a,b) ((a) < (b) ? (a) : (b))
#define max(a,b) ((a) > (b) ? (a) : (b))

#define DATA_WINDOW  0    /* Fenster-Typen */
#define DIAL_WINDOW  1
#define PANEL_WINDOW 2
#define MODAL        4
#define UNMODAL		 0
			/* Falls kein anderes Fenster getoppt werden darf */
#define CLOSED       8

#define ALIGN_X   0		  /* Flags fÅr PANEL_WINDOW */
#define ALIGN_Y   1		  /* Gibt an, ob Panel in x- oder y-Richtung an-  */
						  /* geglichen wird */

/* Flags fÅr Sliderverwaltung */
#define PAGE_UP 0
#define PAGE_DN 1
#define ROW_UP  2
#define ROW_DN  3
#define PAGE_LF 4
#define PAGE_RT 5
#define CLMN_LF 6
#define CLMN_RT 7
#define H_SLIDE 8
#define V_SLIDE 9

/* Zugriff auf den Objektbaum eines Dialogfensters */							   							  
#define ObjTree(a) a->dialog->tree

enum _bool
{
	FALSE,
	TRUE
};

typedef enum _bool boolean;

struct BUTTON_LIST
{
	OBJECT *tree;                  /* Objektbaumadresse */
	int obj_index;				   /* Nr. des Buttons */
	int mb;                        /* Status der Maustaste */
	int ks;						   /* Status der Tastatur */
	void (*action)(void);		  /* Zeiger auf Funktion */
	boolean redraw;				 /* Redraw-Flag */
	struct BUTTON_LIST *next;	 /* Zeiger auf nÑchste Struktur */
};

struct KEY_LIST
{
	int code;          		/* Scan-Code der Taste */
	void (*action)(void);	/* Zeiger auf Funktion */
	struct KEY_LIST *next;	/* Zeiger auf nÑchste Struktur */
};

struct MSG_LIST
{
	int event;  			/* Nr. des Ereignisses */
	void (*action)(int *);	/* Zeiger auf Funktion */
	struct MSG_LIST *next;	/* Zeiger auf nÑchste Struktur */
}; 


struct MENU_LIST
{
	int title;				 /* Nr. des MenÅtitels 				*/
	int item;				 /* Nr. des MenÅeintrags 			*/
	int menu_flag;			 /* nur fÅr interne Verwaltung !		
							    (siehe menu_all_change)*/
	int scan_code;			 /* Scan-Code f. Tastatur-Shortcut  */
	void (*action)(void);	 /* Zeiger auf Funktion 			*/
	struct MENU_LIST *next;	 /* Zeiger auf nÑchste Struktur 	*/
};

struct dial
{
	OBJECT *tree;     /* Objektbaumadresse */
	int start_obj;	  /* Nr. des ersten Edit-Feldes */
	int edit_obj;	  /* reserv. */
	int next_obj;	  /*    "    */
	int idx;		  /*    "    */
	int align;		  /*    "    */
	boolean cont;     /*    "    */
	boolean topped;   /*    "    */
	struct BUTTON_LIST *button_start; /* Button-Aktions-Liste */
	void (*release)(int obj_index, int obj_state); /* Auswertungsfunktion */
};
 
struct slide_def
{
	int x_elements;  /* Spalten */
	int y_elements;  /* Zeilen  */
	int x_size;		 /* Spaltengrîûe */
	int y_size;      /* Zeilengrîûe  */
	int x_offset;    /* akt. x-Pos. */
	int y_offset;	 /* akt. y-Pos. */
	int x_cursor;	 /* Speicher f. Cursorverwaltung */
	int y_cursor;    /*              "               */
};




struct WINDOW 
{
	int w_handle;             /* AES-Window-Handle */
	char name[80], info[80];  /* Titel, Infozeile */
	int flags;				  /* AES-Fensterelemente */
	int type;				  /* Windowtyp */
	int min_w, min_h;         /* Minimale Breite/Hîhe */
	boolean fulled;           /* Flag fÅr volle Grîûe */
	GRECT workarea;			  /* Arbeitsbereich des Fensters */
	GRECT actual_position;	  /* Auûenmaûe des Fensters */
	struct dial *dialog;	  /* Zeiger auf Dialogstruktur */
	struct slide_def *slider; /* Zeiger auf Sliderstruktur */
	void (*draw_code)(struct WINDOW *win); /* Zeichenfunktion */
	void (*slide_code)(struct WINDOW *win, int message); /* Sliderfunktion */
  		/* Funktion bei Klick innerhalb der ArbeitsflÑche eines Fensters */
	void (*button_code)(struct WINDOW *win, int mx, int my, int mb, int ks);
		/* Funktion zur Verarbeitung von druckbaren Zeichen */
	void (*key_code)(struct WINDOW *win, char ascii);
	void (*wtop_code)(struct WINDOW *win); /* erste Reaktion,nach toppen
			des Fensers z.B.- PaletteÑnderung */							
	int  (*close_code)(struct WINDOW *win);/* Zeiger auf Funktion
       	   vor Schlieûen des Fensters (fÅr eigene Freigaben usw.)*/	  
	struct WINDOW *next;   /* Zeiger auf nÑchste Fensterstruktur */
};

struct A_CNTRL
{
	int    ap_id;          /* Application Identifikationsnummer           */
	int    vdi_handle;     /* virtueller Bildschirmhandle                 */
	int    gl_wchar;       /* Zeichenbreite								  */
	int    gl_hchar;	   /* Zeichenhîhe                                 */
	int    gl_wbox;		   /* Zeichenboxbreite                            */
	int    gl_hbox;        /* Zeichenboxhîhe                              */
	int    w_handle;       /* Aktives Fenster           				  */
	OBJECT *menu;          /* MenÅ der Applikation                        */
	struct WINDOW *modal;  /* falls modales Fenster aktiviert			  */
	GRECT  workarea;       /* ArbeitsflÑche des Desktops                  */
	int    multi_flags;    /* Aktionen, die ausgewertet werden			  */
	int    mb_clicks;      /* Anzahl Mausklicks, die erfolgen kînnen      */
	int    mb_mask;		   /* Maustasten, die Ereignis auslîsen           */
	int    mb_state; 	   /* Maustasten gedrÅckt = 1, nicht gedrÅckt = 0 */

	int    m1_flag;		   /* Parameter fÅr MU_M1 						  */
	GRECT  m1;
	void   (*m1_code)(void); 
	int    m2_flag;        /* Parameter fÅr MU_M2								  */
    GRECT  m2;
    void   (*m2_code)(void);

    int    mt_locount;     /* Parameter fÅr MU_TIMER                      */
    int    mt_hicount;
	void   (*time_code)(void);
	void   (*button_code)(int m_x, int m_y, int mb_state, int k_state);
	int    quit;           /* Flag fÅr Programmende                       */
};

/* Prototypen der User-Funktionen --------------------------------------- */
boolean init_powergem(char *rsc_name, int menu_index);
boolean init_desktop(int desk);
void exit_powergem(void);							
struct A_CNTRL *get_app_cntrl(void);
MFDB *get_screen(void);		/* zusÑtzlich eingefÅgte Routine */
int get_handle(void);

struct WINDOW *create_window(GRECT *max, GRECT *real, int min_w, int min_h,
							 int flags, int type,
							 void (*draw_code)(struct WINDOW *win),
							 void (*slide_code)(struct WINDOW *win,
							       int message),
							 void (*button_code)(struct WINDOW *win, int mx,
											     int my, int mb, int ks),
							 void (*key_code)(struct WINDOW *win,
									  		  char ascii),
  						     void (*wtop_code)(struct WINDOW *win),
							 int(*close_code)(struct WINDOW *win));

struct WINDOW *create_pwindow(int obj_name, GRECT *max, GRECT *real, 
							  int min_w, int min_h, int flags,int modal,int align,
							  void (*draw_code)(struct WINDOW *win),
							  void (*slide_code)(struct WINDOW *win,
							                 	 int message),
							  void (*button_code)(struct WINDOW *win, int mx,
												  int my, int mb, int ks),
							  void (*key_code)(struct WINDOW *win,
											   char ascii),
						  	  void (*wtop_code)(struct WINDOW *win),
							  void (*release)(int obj_index, int obj_state));

struct WINDOW *create_dial(int obj_name, int start_obj, int wi_flags,int modal,
						   void (*slide_code)(struct WINDOW *win, 
					              		      int message),
						   void (*button_code)(struct WINDOW *win, int mx,
											   int my, int mb, int ks),
						   void (*key_code)(struct WINDOW *win,
										    char ascii),
						   
       				  	   void (*wtop_code)(struct WINDOW *win),
						   void (*release)(int obj_index, int obj_state));

void open_window(struct WINDOW *win, char *name, char *info);
struct WINDOW *get_winfh(int wh);
struct WINDOW *get_winfn(char *name);
struct WINDOW *get_lastwin(int typ); 
void untop_win(void);

void break_dial(void);
void break_win(struct WINDOW *win);

void set_text(struct WINDOW *win, int obj_index, char *buf, 
											int length, boolean redraw);
void select_btn(struct WINDOW *win, int obj_index, boolean redraw);
void unselect_btn(struct WINDOW *win, int obj_index, boolean redraw);
boolean get_objstate(struct WINDOW *win, int obj_index);
boolean init_slider(struct WINDOW *win, int x_elements, int y_elements,
					int x_size, int y_size); 
void set_mousepos(int x,int y);
void set_y_slider(struct WINDOW *win,int new_y_offset);
					  /* Neue x-Sliderposition setzen und updaten */
void set_x_slider(struct WINDOW *win,int new_x_offset);
					 /* Neue y-Sliderposition setzen und updaten */

int get_y_slider(struct WINDOW *win);/* y-Sliderpostion erfragen */
int get_x_slider(struct WINDOW *win);/* x-Sliderpostion erfragen */
void get_workarea(struct WINDOW *win, GRECT *rc);
void get_winpos(struct WINDOW *win, GRECT *rc);
void add_row(struct WINDOW *win, int count);
void add_column(struct WINDOW *win, int count);

void watch_r1(int flag, GRECT *rc, void (*code)(void ));
void watch_r2(int flag, GRECT *rc, void (*code)(void ));
void watch_timer(int low, int high, void (*code)(void));
void watch_events(int flags, int clicks, int mask, int state);
void multi(void);

void set_button_fnc(void (*button_code)(int m_x, int m_y, int mb_state, 
						                int k_state));
void button_action(struct WINDOW *win, int obj_index, void (*action)(void),
				   boolean redraw);
void key_action(int code, void (*action)(void));
void menu_action(int title, int item, int scan_code, 
				 void (*action)(void));
void msg_action(int event, void (*action)(int *));
void blank(struct WINDOW *, int x, int y, int w, int h);
