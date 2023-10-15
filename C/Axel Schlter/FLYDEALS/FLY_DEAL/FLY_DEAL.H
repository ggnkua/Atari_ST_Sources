/*
	FLY-DEAL Version 3.0 fÅr TOS 12.07.1992
	written '92 by Axel SchlÅter

	Flydeal - Prototypen 
*/

#ifndef __FLYDEAL__
#define __FLYDEAL__

/* Strukturdefinition fÅr die Popup-MenÅs */

typedef struct
{
	int object;
	int tastSel;
	OBJECT *tree;
}POPUP;

/* Prototypen fÅr die offiziellen Routinen */

int 	FLY_init(int work_in[],int work_out[]);	/* GEM-Initialisierung */
int		FLY_exit(void);							/* GEM-Abmeldung */

long    *FLY_deal_start(OBJECT *dealog);		/* Dialog vorbereiten */ 
int 	FLY_deal_do(int firsttext,long *Boxadr,int mode);/* Dialog abarbeiten */
int 	FLY_deal_stop(long *memsize);			/* Dialog beenden */

int 	FLY_alert(int DefButt,char Strings[]);	/* Die neue Alertbox */

int  	FLY_bitblt(int x,int y,int x2,int y2,int b,int h,long *addr,long *addr2,int mode);
long  	FLY_countsize(int b,int h);				/* Die Routinen fÅr's Bit-Block-Transfer */

int   	FLY_hndle_popup(OBJECT *dealog,int startObj,int mode,int px,int py,int pobj);
void 	FLY_radio_set(POPUP array[],int anzahl);/* Die Routinen fÅr die Popups */
int 	FLY_test_radio_set(POPUP array[],int which);

void 	FLY_menu_make(OBJECT *menu);	/* Die Routine zum MenÅbearbeiten */

extern int VDI_ID,AES_ID;

#define MAX_OBJECT 80	/* Anzahl maximaler Object in einer Dialogbox */
#define MAX_DIALOG 3	/* Anzahl maximal gleichzeitiger Boxen */

/* Definitionen fÅr die FLY_bitblt - Modes */

#define PIC_TO_MEM 4
#define MEM_TO_PIC 5
#define PIC_TO_PIC 6
#define MEM_TO_MEM 7

/* Definitionen fÅr die Images in FLY_alert */

#define LEER     0
#define ACHTUNG  1
#define FRAGE    2
#define STOP     3

/* Exitmode */

#define RADIOEXIT 0
#define RADIONOEXIT 1

/* Zusatzbytetypen */

#define FLYMOVEBUTT			17
#define FLYBUTTONS			18
#define FLYTEXT				19
#define FLYBOXES            20
#define FLYRADIO            22

/* FunktionsrÅckmeldungen */

#define ERROR               -1
#define ALLES_OK             0

/* Konstanten fÅr die POPUP's */

#define MOUSE    1
#define XYPOS    2
#define CENTER   3

#endif