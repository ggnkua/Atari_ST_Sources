/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2001
 *
 *	module: globals.c
 *	description: d‚clarations des variables globales
 */

#include "globals.h"

#define VERSION	0x0110

struct w_version  WinDom = 
#ifdef __PUREC__
			{ VERSION, __DATE__, __TIME__, "Pure C", __PUREC__};
#else
#ifdef __GNUC__
			{ VERSION, __DATE__, __TIME__, "Gnu C", __GNUC__};
#else
#ifdef __SOZOBONX__ 
			{ VERSION, __DATE__, __TIME__, "Sozobon X", __SOZOBONX__};

#endif
#endif
#endif

static CONFIG config = {  
				0,								/* flags */
				72, 72, 						/* icon size */
				WHITE,FIS_SOLID, 8,				/* window background style */
				LTMFLY_COLOR|BLACK,				/* keyshort color */
			 	/* font, size, color, */
				{SYSFONT, 13, BLACK},			/* string */
				{SYSFONT, 13, BLACK},			/* button */
				{SYSFONT, 13, BLACK},			/* exit */
				{SYSFONT, 13, BLACK},			/* title */
				{SYSFONT, 13, DEFVAL},			/* xedit texte */
				{SYSFONT, 13, DEFVAL},			/* xedit label */
				{SYSFONT, 10, DEFVAL}, 8,		/* xlongedit */
				{SYSFONT, 10, DEFVAL}, 8,		/* xtedinfo */
				4,								/* Mono */
				LWHITE,							/* Color */
				3,								/* Menu effect */
				{BLACK, 13, 1},					/* Bubble GEM */
				WHITE, 2, BLACK, 0x100, DEFVAL,	/* Popup */
				CENTER, DEFVAL,
				NAME|MOVER};

APPvar app = {  &config };

WINvar wglb;
EVNTvar evnt = { 0L, 258, 3, 0,
				 0, 0, 0, 0, 0,
				 0, 0, 0, 0, 0,
				 {0,0,0,0,0,0,0,0},
				 0, 0, 0, 0,
				 0, 0 };



int    _res;					/* r‚solution actuelle
								 * 0 - basse, 1 - haute	
								 */

WORD __windowlist[ MAX_WINDOW];	/*  handle fenetre suivante
								 *  0 fenetre ferme ou inexistante
								 *  -1 top fenetre
								 */

WORD __iconlist[ MAX_ICON];		/* position des icones
								 * 0 position libre
								 */

GRECT clip;						/* coordonn‚es de la zone
								 * de masquage.
								 */

short *_AESglobal;				/* Tableau global de l'AES
								 */

/* Utilis‚s pour lier les frames au noyau de windom */
int  (*__calc)( struct _window *, int, INT16 *, INT16 *, INT16 *, INT16 *);
void (*__swgt)( struct _window *, GRECT *, int);
int	 (*__rfrm)( struct _window *, struct _window *);

/* Utilis‚ par les modules Bubble et Appl */
int __bubble_quit = -1;

/* EOF */
