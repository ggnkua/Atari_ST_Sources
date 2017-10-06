/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997
 *
 *	module: options.h
 *	description: les options de compilation de la libraire
 */

/*
 *	WINDOMDEBUG   : ‚crit dans le fichier log diverses infos
 */

/* #define WINDOMDEBUG */

/*
 *	GFORM      1  : WinDom gŠre les click bouton des
 *					formulaire avant de retourner le
 *					message WM_FORM
 *             0  : WinDom se contente de retourner
 *					directement le message
 */

#define GFORM 1

/*
 * Mettre USE_MGEMLIB … 1 si vous utilisez MGEMLIB PL39 ou +
 * Mettre USE_GEMLIB  … 1 si vous utilisez MGEMLIB PL40 ou +
 * Si aucune de ces constantes n'est d‚finie, "global.h" d‚finira
 * USE_MGEMLIB si le compilo est GCC ou SOZOBONX.
 */

/* #define USE_MGEMLIB 1 */
/* #define USE_GEMLIB  1 */

/* taille des tableaux __windowlist et __iconlist */

#define MAX_WINDOW	100
#define MAX_ICON 	100

/* taille de buffers */
#define FILE_SIZE	255		/* nom fichier */
#define LINE_SIZE	150		/* longueur ligne pour fget() */
#define PIPE_SIZE	256		/* taille du pipeline GEM */

/* Seuil pour la r‚allocation des objets XEDIT */
#define XEDIT_REALLOC 128
