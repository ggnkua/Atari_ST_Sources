/*
 * STDSTUFF.H
 *
 * Nasi's Standard Include-Datei.
 */

#ifndef STDSTUFF_H
#define STDSTUFF_H

/*
 * Bei einigen praehistorischen Compilern, die den Datentyp `void'
 * nicht kennen, muss man die folgende Zeile aktivieren.
 */
/* #define void int */

/*
 * Die folgende Zeile ist fuer einige aeltere Compiler, bei denen
 * der Header fuer die Standard-String-Funktionen <strings.h>
 * und nicht <string.h> heisst.
 */
/* #define NO_STRING_H */

/*
 * Zunaechst das Unvermeidliche... Wir setzen voraus, dass <stdio.h>
 * Deklarationen fuer alle Standard-I/O Funktionen enthaelt.
 */
#include <stdio.h>
#ifndef EOF
#define EOF (-1)
#endif
#ifndef NULL
#define NULL (char *)0
#endif

/*
 * ANSI-konforme Compiler haben eine Standard-Include-Datei <stdlib.h>
 * -- oder sollten ($%&/#^!) zumindest eine solche haben -- in der
 * der Datentyp `size_t' definiert wird und Deklarationen von Standard-
 * Funktionen wie malloc(), getenv() stehen.
 */
#ifdef __STDC__
#define FUNC(args) args         /* int f FUNC((int a)) --> int f(int a) */
#define VOID void               /* VOID *p --> void *p */
#include <stdlib.h>             /* Dekl. von malloc() usw. */
#else
#define FUNC(args) ()           /* int f FUNC((int a)) --> int f() */
#undef VOID                     /* fuer Sozobon... */
#define VOID char               /* VOID *p --> char *p */
#define const
#define size_t unsigned
extern void free(), exit();
extern int atoi(), abs(), system();
extern long atol(), labs();
extern char *malloc(), *calloc(), *realloc();
extern char *itoa(), *ltoa(), *ultoa(), *getenv();
#endif

/*
 * Bei Compilern mit <strings.h> statt <string.h> tragen die Standard-
 * String-Funktionen noch altmodische Namen.
 */
#ifdef NO_STRING_H
#include <strings.h>
#define strchr index
#define strrchr rindex
#define memcmp bcmp
#define memcpy(q,p,n) bcopy(p,q,n)
#else
#include <string.h>
#endif

#include <ctype.h>

typedef char bool;
#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE 1
#endif

#endif STDSTUFF_H

