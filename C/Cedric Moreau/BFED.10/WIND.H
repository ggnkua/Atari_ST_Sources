/*
	file: wind.h
	utility: header file of wind.c
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
	comments: 
*/
#ifndef _WIND_H
#define _WIND_H

#ifdef __PUREC__
#include <aes.h>	/* defs for GRECT */
#include <vdi.h>	/* defs for MFDB */
#include <compend.h>
#else
#include <aesbind.h>
#include <vdibind.h>
#endif

#include <stdio.h>

#define WIDTH_WIN	70

#ifndef TRUE
#define TRUE		1
#define FALSE		0
#endif 

#define max(a,b)	(a>b?a:b)
#define min(a,b)	(a<b?a:b)

#define BLOCKSIZE 4096

typedef struct  _linkbuf 
{
	struct  _linkbuf	*next;
	char			 	block[BLOCKSIZE];
	long				inuse;
} linkbuf;
typedef linkbuf *linkbufptr; 

/*
	Each window will have a grafport so that it is easy to maintain 
	drawing environments accross windows.
*/
typedef struct _grafport 
{
	int		handle;		/*  Virtual workstation handle  					*/
	MFDB	mfdb;		/*  memory definition block for virtual workstation	*/
} grafport;

/*
	Window definition.
*/
typedef struct _windowrec 
{
	struct _windowrec	*next;		/*  Window link						*/
	int					handle;		/* Window Handle					*/
	int					kind;		/* The windows type					*/
	int					fullsize;	/* In full-screen mode				*/
	int					vslidepos;	/* vertical slider position			*/
	char				title[PATH_MAX];	/* Title of window					*/
	char				info[WIDTH_WIN];
/*
	GRECT				box;		/* Window Box dimensions			*/
*/
	GRECT				work;		/* Window content region dimensions	*/
	grafport			graf;		/* Window graphics port definition  */
	int					(*updateproc)(); /* Pointer to update procedure */
	struct _linkbuf		*headptr;
	long				startmark;
	long				endmark;
	int					markson;
	int 				xcur;		/* xpos of cursor on screen			*/
	int					ycur;       /* ypos of cursor on screen			*/
	long				topchar;	/* number of char at top left 		*/
	long				flen;		/* length of file in total			*/
	long				position;	/* position of cursor in file		*/
	char				input[2];	/* input buffer						*/
	int					icount;		/* input buffer end pointer			*/
	int					changed;	/* changed flag */
	int					prot;		/* protected flag */
	OBJECT				*form;		/* Form adress 	*/
	int					icon;		/* iconified window flag */
} windowrec;
typedef windowrec *windowptr;

	/* Globals vars */
extern windowptr	firstwindow;
extern windowptr	thefrontwin;
extern	int		partial;
extern	int		draw_flag;
extern	int		slid_flag;
extern	int		arro_flag;
extern int black_white;
extern int grow_shrink;
extern int info_hexa;

	/* Functions */
extern void window_do(int *message);
extern void window_open(windowptr	thewin);
extern void window_dispose(windowptr	thewin);
extern void window_resources_dispose(windowptr	thewin);
extern void window_put_top(windowptr thewin);
extern windowptr window_new(int thekind);
extern windowptr findwindowptr(int handle);
extern void window_blank(windowptr thewin);
extern void window_rot(void);

extern void window_info(windowptr thewin);
extern void window_title(windowptr thewin);
extern void window_tile(int horiz_verti);
extern void window_init(void);
extern windowptr find_workwind(void);
extern void insertwindowptr(windowptr thewin);
extern void window_iconify(windowptr thewin);
extern void window_uniconify(windowptr thewin);
extern void window_iconify_all(void);

#endif