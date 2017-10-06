/**************************************************************************/
/*                                                                        */
/*  NAME:         portab.h                                                */
/*                                                                        */
/*  DATUM:        21.06.89                                                */
/*                                                                        */
/*  VERSION:      2.6                                                     */
/*                                                                        */
/*  BESCHREIBUNG: Deklaration von abstrakten Datentypen, wegen Portabi-   */
/*                litaets-Verbesserung.                                   */
/*                Wenn Symbol TESTTYPES vor dem Includen von portab.h     */
/*                definiert wird, dann steht die Funktion testtypes()     */
/*                zur Verfuegung, sie dient dem Anzeigen der aktuellen    */
/*                Einstellungen und der Compiler-Typen-Groessen.          */
/*                                                                        */
/*  AENDERUNGEN:  CH210688 - Dokumentation.                               */
/*                         - BOOL, STATIC, VOID hinzugefuegt.             */
/*                CH240688 - Konstanten fuer bedingte Compilierung einge- */
/*                           fuegt, an VAX und TNIX angepasst             */
/*                CH270688 - XENIX angepasst                              */
/*                CH300688 - an Megamax angepasst; Typenkontrolle erwei-  */
/*                           tert;                                        */
/*                CH010788 - an MSDOS angepasst.                          */
/*                         - FLOAT und DOUBLE hinzugefuegt.               */
/*                CH110888 - Konstante PORTAB definiert -> #ifdef PORTAB  */
/*                         - NULF hinzugefuegt                            */
/*                         - an gfadstd.h angepasst.                      */
/*                CH020988 - an MSDOS und TURBOC angepasst.               */
/*                CH071088 - zus. INT8 INT16 INT32 fuer machine.h         */
/*                CH141088 - ifndef MSDOS eingebaut                       */
/*                CH101188 - NULF, NULFB, NULFW, NULFL eingebaut          */
/*                         - Anpassung an LaserC                          */
/*                CH111188 - ifdef MEGAMAX, undef MEGAMAX eingefuegt      */
/*                CH221188 - an MWC  angepasst.                           */
/*                CH210189 - an TurboC auf Atari angepasst                */
/*                CH130289 - Anzeige des Speichermodells unter Xenix      */
/*                         - Anpassung an Digital Research Development    */
/*                CH150289 - Sozobon Compiler angepasst, Test geaendert.  */
/*                CH200289 - Anpassung an Minix V1.1.                     */
/*                CH090689 - CPM hinzugefuegt.                            */
/*                CH130689 - ST520 -> GEMDOS, UNIXV, MC68000, ...         */
/*                CH210689 - um VARTYPE erweitert -> union                */
/*                CH220689 - um Funktions-Pointer-Typen erweitert         */
/*                                                                        */
/**************************************************************************/

#ifndef PORTABH
#define PORTABH

#ifdef MSDOS
#undef MSDOS
#endif MSDOS
#ifdef MEGAMAX
#undef MEGAMAX
#endif MEGAMAX

/**************************************************************************/
/*                                                                        */
/*                         E I N S T E L L U N G E N                      */
/*                                                                        */
/**************************************************************************/

#define GEMDOS  1       /* Atari 520ST GEMDOS                             */
#define VMS     0       /* MicroVAX VMS V4.4                              */
#define TNIX    0       /* Tektronix Unix                                 */
#define MSDOS   0       /* Msdos V3.3                                     */
#define XENIX   0       /* Altos Xenix                                    */
#define MINIX   0       /* Atari ST MINIX V1.1                            */
#define CPM     0       /* CP/M 86                                        */
#define UNIXV   0       /* UNIX System V                                  */

#define MC68000 1       /* Motorola 68000                                 */
#define MC68020 0       /* Motorola 68020                                 */
#define I8086   0       /* Intel 8086 / 8088                              */
#define I80286  0       /* Intel 80286                                    */
#define I80386  0       /* Intel 80386                                    */

#define LATTICE 0       /* LatticeC V3.04                                 */
#define SYSCOMP 0       /* Systemcompiler                                 */
#define MEGAMAX 0       /* MegamaxC V1.0                                  */
#define LASERC  1       /* Megamax Laser C V1.0                           */
#define MSC     0       /* Microsoft C                                    */
#define TURBOC  0       /* Borland Turbo-C                                */
#define MWC     0       /* Mark Williams C V3.0                           */
#define DR      0       /* Digital Research Development                   */
#define SC      0       /* Sozobon Compiler                               */

#define SMALLM  0       /* 8086 SmallModel                                */
#define MIDDLEM 0       /* 8086 MiddleModel                               */
#define LARGEM  0       /* 8086 LargeModell                               */

/**************************************************************************/
/*                                                                        */
/*                            A T A R I   S T                             */
/*                                                                        */
/**************************************************************************/

#if GEMDOS & LATTICE
typedef char           BYTE;     /* signed 8 bit integer */
typedef unsigned char  UBYTE;    /* unsigned 8 bit int   */
typedef short          WORD;     /* signed 16 bit int    */
typedef unsigned short UWORD;    /* unsigned 16 bit int  */
typedef long           LONG;     /* signed 32 bit int    */
typedef unsigned long  ULONG;    /* unsigned 32 bit int  */
typedef float          FLOAT;
typedef double         DOUBLE;
typedef void           VOID;
typedef UWORD          BOOL;

#define STATIC         static
#define REGISTER       register
#endif GEMDOS & LATTICE

#if GEMDOS & MWC
typedef char           BYTE;     /* signed 8 bit integer */
typedef unsigned char  UBYTE;    /* unsigned 8 bit int   */
typedef short          WORD;     /* signed 16 bit int    */
typedef unsigned short UWORD;    /* unsigned 16 bit int  */
typedef long           LONG;     /* signed 32 bit int    */
typedef unsigned long  ULONG;    /* unsigned 32 bit int  */
typedef float          FLOAT;
typedef double         DOUBLE;
typedef void           VOID;
typedef UWORD          BOOL;

#define STATIC         static
#define REGISTER       register
#endif GEMDOS & MWC

#if GEMDOS & SC
typedef char           BYTE;     /* signed 8 bit integer */
typedef unsigned char  UBYTE;    /* unsigned 8 bit int   */
typedef short          WORD;     /* signed 16 bit int    */
typedef unsigned short UWORD;    /* unsigned 16 bit int  */
typedef long           LONG;     /* signed 32 bit int    */
typedef unsigned long  ULONG;    /* unsigned 32 bit int  */
typedef float          FLOAT;
typedef double         DOUBLE;   /* double und float identisch!!! */
typedef void           VOID;
typedef UWORD          BOOL;

#define STATIC         static
#define REGISTER       register
#endif GEMDOS & SC

#if GEMDOS & TURBOC
typedef char           BYTE;     /* signed 8 bit integer */
typedef unsigned char  UBYTE;    /* unsigned 8 bit int   */
typedef int            WORD;     /* signed 16 bit int    */
typedef unsigned int   UWORD;    /* unsigned 16 bit int  */
typedef long           LONG;     /* signed 32 bit int    */
typedef unsigned long  ULONG;    /* unsigned 32 bit int  */
typedef float          FLOAT;
typedef double         DOUBLE;
typedef void           VOID;
typedef UWORD          BOOL;

#define STATIC         static
#define REGISTER       register
#endif GEMDOS & TURBOC

#if (GEMDOS & MEGAMAX) | (GEMDOS & LASERC)
typedef char           BYTE;     /* signed 8 bit integer */
typedef unsigned char  UBYTE;    /* unsigned 8 bit int   */
typedef int            WORD;     /* signed 16 bit int    */
typedef unsigned int   UWORD;    /* unsigned 16 bit int  */
typedef long           LONG;     /* signed 32 bit int    */
typedef unsigned long  ULONG;    /* unsigned 32 bit int  */
typedef UWORD          BOOL;
typedef float          FLOAT;
typedef double         DOUBLE;

#define VOID
#define STATIC
#define REGISTER       register
#endif (GEMDOS & MEGAMAX) | (GEMDOS & LASERC)

#if GEMDOS & DR
typedef char           BYTE;     /* signed 8 bit integer */
typedef char           UBYTE;    /* unsigned gibts nicht */
typedef short          WORD;     /* signed 16 bit int    */
typedef unsigned short UWORD;    /* unsigned 16 bit int  */
typedef long           LONG;     /* signed 32 bit int    */
typedef long           ULONG;    /* unsigned long gibts nicht  */
typedef float          FLOAT;
typedef double         DOUBLE;
#define VOID
typedef UWORD          BOOL;

#define STATIC         static
#define REGISTER       register
#endif GEMDOS & DR

/**************************************************************************/
/*                                                                        */
/*                              M I N I X                                 */
/*                                                                        */
/**************************************************************************/

#if MINIX & SYSCOMP
typedef char           BYTE;     /* signed 8 bit integer */
typedef unsigned char  UBYTE;    /* unsigned 8 bit int   */
typedef short          WORD;     /* signed 16 bit int    */
typedef unsigned short UWORD;    /* unsigned 16 bit int  */
typedef long           LONG;     /* signed 32 bit int    */
typedef unsigned long  ULONG;    /* unsigned 32 bit int  */
typedef float          FLOAT;
typedef double         DOUBLE;
typedef void           VOID;
typedef UWORD          BOOL;

#define STATIC         static
#define REGISTER       register
#endif XENIX & SYSCOMP

/**************************************************************************/
/*                                                                        */
/*                              M S D O S                                 */
/*                                                                        */
/**************************************************************************/

#if MSDOS & MSC
typedef char           BYTE;     /* signed 8 bit integer */
typedef unsigned char  UBYTE;    /* unsigned 8 bit int   */
typedef short          WORD;     /* signed 16 bit int    */
typedef unsigned short UWORD;    /* unsigned 16 bit int  */
typedef long           LONG;     /* signed 32 bit int    */
typedef unsigned long  ULONG;    /* unsigned 32 bit int  */
typedef UWORD          BOOL;
typedef float          FLOAT;
typedef double         DOUBLE;

#define VOID           WORD
#define STATIC         static
#define REGISTER       register
#endif MSDOS & MSC

#if MSDOS & TURBOC
typedef char           BYTE;     /* signed 8 bit integer */
typedef unsigned char  UBYTE;    /* unsigned 8 bit int   */
typedef short          WORD;     /* signed 16 bit int    */
typedef unsigned short UWORD;    /* unsigned 16 bit int  */
typedef long           LONG;     /* signed 32 bit int    */
typedef unsigned long  ULONG;    /* unsigned 32 bit int  */
typedef float          FLOAT;
typedef double         DOUBLE;
typedef void           VOID;
typedef UWORD          BOOL;

#define STATIC         static
#define REGISTER       register
#endif MSDOS & TURBOC

/**************************************************************************/
/*                                                                        */
/*                                V M S                                   */
/*                                                                        */
/**************************************************************************/

#if VMS & SYSCOMP
typedef char           BYTE;     /* signed 8 bit integer */
typedef unsigned char  UBYTE;    /* unsigned 8 bit int   */
typedef short          WORD;     /* signed 16 bit int    */
typedef unsigned short UWORD;    /* unsigned 16 bit int  */
typedef long           LONG;     /* signed 32 bit int    */
typedef unsigned long  ULONG;    /* unsigned 32 bit int  */
typedef UWORD          BOOL;
typedef float          FLOAT;
typedef double         DOUBLE;

#define VOID           void
#define STATIC         static
#define REGISTER       register
#endif VMS & SYSCOMP

/**************************************************************************/
/*                                                                        */
/*                                T N I X                                 */
/*                                                                        */
/**************************************************************************/

#if TNIX & SYSCOMP
typedef char           BYTE;     /* signed 8 bit integer */
typedef BYTE           UBYTE;    /* unsigned 8 bit int   */
typedef int            WORD;     /* signed 16 bit int    */
typedef unsigned int   UWORD;    /* unsigned 16 bit int  */
typedef long           LONG;     /* signed 32 bit int    */
typedef LONG           ULONG;    /* unsigned 32 bit int  */
typedef UWORD          BOOL;
typedef float          FLOAT;
typedef double         DOUBLE;

#define VOID           /* void */
#define STATIC         static
#define REGISTER       register
#endif TNIX & SYSCOMP

/**************************************************************************/
/*                                                                        */
/*                                X E N I X                               */
/*                                                                        */
/**************************************************************************/

#if XENIX & SYSCOMP & (SMALLM | MIDDLEM | LARGEM) 
typedef char           BYTE;     /* signed 8 bit integer */
typedef BYTE           UBYTE;    /* unsigned 8 bit int   */
typedef int            WORD;     /* signed 16 bit int    */
typedef unsigned int   UWORD;    /* unsigned 16 bit int  */
typedef long           LONG;     /* signed 32 bit int    */
typedef LONG           ULONG;    /* unsigned 32 bit int  */
typedef UWORD          BOOL;
typedef float          FLOAT;
typedef double         DOUBLE;

#define VOID           /* void */
#define STATIC         static
#define REGISTER       register
#endif XENIX & SYSCOMP & (SMALLM | MIDDLEM | LARGEM)

/**************************************************************************/
/*                                                                        */
/*                  S T A N D A R D - D E F I N I T I O N E N             */
/*                                                                        */
/**************************************************************************/

#ifdef TRUE
#undef TRUE
#endif TRUE

#ifdef FALSE
#undef FALSE
#endif FALSE

#define TRUE          (1)
#define FALSE         (0)
#define OK            (0)
#define ERROR         (-1)

#define NULP          ((BYTE *) 0)
#define NULFB         ((BOOL (*) ()) 0)
#define NULFW         ((WORD (*) ()) 0)
#define NULFL         ((LONG (*) ()) 0)
#define NULFF         ((FLOAT (*) ()) 0)
#define NULFD         ((DOUBLE (*) ()) 0)
#define NULFS         ((BYTE * (*) ()) 0)

#define NULF          NULFS

 /* Anpassung an gfadstd.h */

typedef BYTE          CHAR;
typedef BYTE          *STRING;       /* oder (BYTE *) STRING; */
typedef BYTE          *STR;
typedef WORD          INT;
typedef UWORD         UINT;

 /* Anpassung an machine.h (Vorgaenger von portab.h) */

typedef BYTE          INT8;
typedef UBYTE         UINT8;
typedef WORD          INT16;
typedef UWORD         UINT16;
typedef LONG          INT32;
typedef ULONG         UINT32;

typedef union _vartype
{
   BYTE    chr;
   WORD    wrd;
   FLOAT   flt;
   LONG    lng;
   ULONG   ulng;
   DOUBLE  dbl;
   STR    *str;
} VARTYPE;

/**************************************************************************/
/*                                                                        */
/*               Z E I G E R   A U F   F U N K T I O N E N                */
/*                                                                        */
/**************************************************************************/

typedef WORD (*PFWORD) ();          /* Ptr a. Func mit Ret = WORD         */
typedef WORD *(*PFPWORD) ();        /* Ptr a. Func mit Ret = Ptr auf WORD */
typedef WORD (*(*PFPFWORD)()) ();   /* " " "  Ret = Ptr auf Func WORD     */
typedef WORD *(*(*PFPFPWORD)()) (); /* " " " Ret = Ptr auf Func Ptr WORD  */
typedef BOOL (*PFBOOL) ();
typedef STR  (*PFSTR) ();

/**************************************************************************/
/*                                                                        */
/*  NAME:         VOID testtypes ()                                       */
/*                                                                        */
/*  DATUM:        13.02.89                                                */
/*                                                                        */
/*  BESCHREIBUNG: Gibt die aktuellen Einstellungen der internen und der   */
/*                Compiler-Datentypen aus.                                */
/*                                                                        */
/**************************************************************************/

#ifdef TESTTYPES
VOID testtypes ()
{
   printf ("            -----------------------------------------\n");
   printf ("            Test der abstrakten Datentypen (portab.h)\n");
   printf ("            -----------------------------------------\n");
   printf ("\ninterne Systemkonfiguration:\n");
   printf ("----------------------------\n\n");
#if VMS
   printf ("System: VMS  ");
#endif VMS
#if GEMDOS
   printf ("System: GEMDOS  ");
#endif GEMDOS
#if MSDOS
   printf ("System: MSDOS  ");
#endif MSDOS
#if TNIX
   printf ("System: TNIX  ");
#endif TNIX
#if XENIX
   printf ("System: XENIX  ");
#endif XENIX
#if MINIX
   printf ("System: MINIX  ");
#endif MINIX

#if XENIX | MSDOS
#if SMALLM
   printf ("Model: SMALL  ");
#endif SMALLM
#if MIDDLEM
   printf ("Model: MIDDLEM  ");
#endif MIDDLEM
#if LARGEM
   printf ("Model: LARGEM  ");
#endif LARGEM
#endif XENIX | MSDOS

#if LATTICE
   printf ("Compiler: LATTICE\n");
#endif LATTICE
#if MWC
   printf ("Compiler: MWC\n");
#endif MWC
#if MSC
   printf ("Compiler: MSC\n");
#endif MSC
#if MEGAMAX
   printf ("Compiler: MEGAMAX\n");
#endif MEGAMAX
#if LASERC
   printf ("Compiler: LASERC\n");
#endif LASERC
#if SYSCOMP
   printf ("Compiler: SYSCOMP\n");
#endif SYSCOMP
#if TURBOC
   printf ("Compiler: TURBOC\n");
#endif TURBOC
#if DR
   printf ("Compiler: DR\n");
#endif DR
#if SC
   printf ("Compiler: SC\n");
#endif SC

   printf ("\nGroesse der internen Datentypen:\n");
   printf ("--------------------------------\n\n");
   printf ("char:   %d      CHAR:   %d    %s\n",
           (unsigned int) sizeof (char), (unsigned int) sizeof (CHAR),
           ((unsigned int) sizeof (char) != (unsigned int) sizeof (CHAR) ?
           "!!! Achtung Typen unterschiedliche Groesse !!!" : ""));
   printf ("short:  %d\n", (unsigned int) sizeof (short));
   printf ("long:   %d      LONG:   %d    %s\n",
           (unsigned int) sizeof (long), (unsigned int) sizeof (LONG),
           ((unsigned int) sizeof (long) != (unsigned int) sizeof (LONG) ?
           "!!! Achtung Typen unterschiedliche Groesse !!!" : ""));
   printf ("int:    %d      WORD:   %d    %s\n",
           (unsigned int) sizeof (int), (unsigned int) sizeof (WORD),
           ((unsigned int) sizeof (int) != (unsigned int) sizeof (WORD) ?
           "!!! Achtung Typen unterschiedliche Groesse !!!" : ""));
   printf ("float:  %d      FLOAT:  %d    %s\n",
           (unsigned int) sizeof (float), (unsigned int) sizeof (FLOAT),
           ((unsigned int) sizeof (float) != (unsigned int) sizeof (FLOAT) ?
           "!!! Achtung Typen unterschiedliche Groesse !!!" : ""));
   printf ("double: %d      DOUBLE: %d    %s\n",
           (unsigned int) sizeof (double), (unsigned int) sizeof (DOUBLE),
           ((unsigned int) sizeof (double) != (unsigned int) sizeof (DOUBLE) ?
           "!!! Achtung Typen unterschiedliche Groesse !!!" : ""));
   printf ("               UBYTE:  %d\n", (unsigned int) sizeof (UBYTE));
   printf ("               UWORD:  %d\n", (unsigned int) sizeof (UWORD));
   printf ("               ULONG:  %d\n", (unsigned int) sizeof (ULONG));
}
#endif TESTTYPE
#endif PORTABH

