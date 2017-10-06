
#ifndef FL3DIND
#define FL3DIND  0x0200
#define FL3DBAK  0x0400
#define FL3DACT  0x0600
#endif

#define MGLASSD    0 /* form/dialog */
#define MAINBOX    0 /* BOX: Hauptkasten */
#define TITLE	   1 /* STRING: >Magicfying Glass< (Titel) */
#define BUBOX	   2 /* IBOX: fr die Radiobutttons */
#define BUTEXT	   3 /* STRING: >Vergr”žerung< */
#define FSTRBUT    4 /* BOXTEXT: >2fach< */
#define SCNDRBUT   5 /* BOXTEXT: >4fach< */
#define THRDRBUT   6 /* BOXTEXT: >Mega< */
#define MFCROSSB   7 /* BOX: fr Mausvergr”žerung ankreuzbar */
#define MFTEXT	   8 /* STRING: >Maus mitvergr”žern< */
#define WUCROSSB   9 /* BOX: fr Wind-Update ankreuzbar */
#define WUTEXT	  10 /* STRING: >Wind-Update benutzten */
#define OKBUTTON  11 /* BUTTON: >OK< */

/* Der Dialogbaum: */
OBJECT tree[]={
 -1, TITLE, OKBUTTON, G_BOX, FL3DBAK, OUTLINED, 0x21000L, 1, 1, 32, 14,
 BUBOX, -1, -1, G_STRING, FL3DBAK, NORMAL, (long)"Magicfying Glass", 8, 1, 16, 1,
 MFCROSSB, BUTEXT, THRDRBUT, G_IBOX, FL3DBAK, OUTLINED, 0x1000L, 2, 3, 28, 4,
 FSTRBUT, -1, -1, G_STRING, FL3DBAK, NORMAL, (long)"Vergr”žerung:", 2, 0, 13, 1,
 SCNDRBUT, -1, -1, G_BUTTON, FL3DIND|SELECTABLE|RBUTTON, SELECTED, (long)"2fach", 1, 2, 8, 1,
 THRDRBUT, -1, -1, G_BUTTON, FL3DIND|SELECTABLE|RBUTTON, NORMAL, (long)"4fach", 10, 2, 8, 1,
 BUBOX, -1, -1, G_BUTTON, FL3DIND|SELECTABLE|RBUTTON, NORMAL, (long)"Mega", 19, 2, 8, 1,
 MFTEXT, -1, -1, G_BOX, TOUCHEXIT, SELECTED|CROSSED, 0x110F1L, 3, 8, 2, 1,
 WUCROSSB, -1, -1, G_STRING, FL3DBAK, NORMAL, (long)"Maus mitvergr”žern", 7, 8, 18, 1,
 WUTEXT, -1, -1, G_BOX, TOUCHEXIT, SELECTED|CROSSED, 0x110F1L, 3, 10, 2, 1,
 OKBUTTON, -1, -1, G_STRING, FL3DBAK, NORMAL, (long)"Wind-Update benutzen", 7, 10, 20, 1,
 MAINBOX, -1, -1, G_BUTTON, FL3DACT|LASTOB|EXIT|DEFAULT|SELECTABLE, NORMAL, (long)"Ok", 11, 12, 8, 1
};

unsigned int table[16]={0,3,12,15,48,51,60,63,192,195,204,207,240,243,252,255};
char *dptr="";

int ap_id, menu_id;
int msgbuff[8];
int deskx, desky, deskw, deskh; 		  /* Gr”že des Desktops */
int wi_handle;
int wi_x, wi_y , wi_w, wi_h;			  /* Frs Fenster */
int mausx, mausy;
int dialogx, dialogy, dialogw, dialogh;   /* Fr den Dialog */
int wahl;								  /* Fr Form-Do */

int vhandle;
int work_out[57];						  /* Fr Openvwk */
int x_aufl, y_aufl, planes;
int max_x, max_y;

int xy[8];			 /* Fr Koordinaten */
int xyclip[4];		 /* Fr Clipping */
int rw, rh; 		 /* Fr Breite+H”he aus der Rechtecksliste */

void *pic1addr; 						   /* Variablen fr MFDBs */
MFDB pic1mfdb={0, 0, 0, 0, 0, 0, 1, 1, 1}; /* ger„tespezifisch */
unsigned char *pic2addr;
MFDB pic2mfdb={0, 0, 0, 0, 1, 0, 1, 1, 1}; /* Standard */
unsigned int *pic3addr;
MFDB pic3mfdb={0, 0, 0, 0, 1, 0, 1, 1, 1}; /* Vergr”žertes */
MFDB scrnmfdb={0, 0, 0, 0, 0, 0, 0, 0, 0}; /* Bildschirm */

char mouseflag=0;		/* Mausvergr”žerungsflag */
char w_updateflag=-1;	/* Flag fr Wind-Update */
char blowup=1;			/* Vergr”žerungsstufe 1,2 oder 3 */


extern short _app;		/* ACC oder normales PRG? */
