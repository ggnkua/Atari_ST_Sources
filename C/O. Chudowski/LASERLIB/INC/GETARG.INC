/**************************************************************************/
/*                                                                        */
/*  NAME:         getarg.inc                                              */
/*                                                                        */
/*  DATUM:        11.06.89                                                */
/*                                                                        */
/*  BESCHREIBUNG: Include-File fuer getarg.c.                             */
/*                                                                        */
/**************************************************************************/

#ifndef GETARGINC
#define GETARGINC
#include <portab.h>

#define IARG      1     /* Integer (WORD)      */
#define BARG      2     /* Boolescher (BOOL)   */
#define CARG      3     /* Character (BYTE)    */
#define SARG      4     /* String (BYTE *)     */
#define PARG      5     /* Funktion (*WORD) () */
#define NARG      6     /* Filename (BYTE *)   */
#define LARG      7     /* Long Integer (LONG) */
#define DARG      8     /* Double (DOUBLE)     */

typedef struct
{ 
   BYTE  arg_arg;      /* Options-Argument-Zeichen  */
   BYTE  arg_type;     /* Typ des Options-Arguments */
   WORD *arg_varaddr;  /* Adresse der Variablen     */
   BYTE *arg_errmsg;   /* Fehlermeldungstext        */
} 
ARG;

#define TABSIZE(t) (sizeof (t) / sizeof (ARG))

#define GAEXIT   0x1   /* Flag fuer Programmabbruch, wenn falsche Option */
#define GABREAK  0x2   /* Flag fuer Prozedurabbruch, wenn falsche Option */
#define GAUSAGE  0x4   /* Flag fuer Anzeige des usage, wenn falsche Option */
#define GANOCASE 0x8   /* Flag fuer Vernachlaessigung von Gross/Kleinschrift */

extern BOOL getarg();

#define GetArg(c,v,t)  (getarg (c, v, t, TABSIZE(t), (GAEXIT|GAUSAGE), "", -1))

#endif GETARGINC

