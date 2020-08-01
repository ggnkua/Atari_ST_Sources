
/* 
 * UFSEl.h	interface to universal font selector by 
 * 									Michael Th„nitz
 * version 0.91
 */

#define	cdecl

#define FNT_MONO   1

#define UFSEL_DIALOG 0
#define UFSEL_WINDOW 1

int cdecl fontsel_input(int handle, int ncount, int ftype, char *text, int *id, int *size);

typedef struct
{
   unsigned long  id;      /* UFSL ID (UFSL)       */
   unsigned int   version; /* version (BCD-Format) */
   int dialtyp;            /* 0=Dialog, 1=Fenster  */
   int cdecl (*fontsel_init)(void);
   int cdecl (*fontsel_input)(int vdihandle, /* klar */
                              int n_fonts,   /* Gesamtzahl der Fonts */
                              int ftype,     /* 1=nur monospaced, 0=egal */
                              char *text,    /* Benutzerdefinierter Text */
                              int *fretid,   /* eingestellte FontId */
                              int *fretsize  /* eingestellte Fontgr”že */
                              );
   OBJECT *helpbutton;                       /* Typ: BOXTEXT */
   int cdecl (*helpfunc)(void);              /* Benutzerdefinierte Helpfkt. */
   char *examplestr;                         /* Beispielstring */
} UFSL;
