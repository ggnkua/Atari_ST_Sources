/* EC_GEM */
/* Funktionen zur vereinfachten GEM-Steuerung */

#if !defined( __EC_GEM )
#define __EC_GEM


#if     !defined( __STDLIB )
#include <stdlib.h>
#endif

#if     !defined( __STDIO )
#include <stdio.h>
#endif

#if     !defined( __STRING )
#include <string.h>
#endif

#if 		!defined( __TOS )
#include <tos.h>
#endif

#if     !defined( __AES__ )
#include <aes.h>
#endif

#if     !defined( __VDI__ )
#include <vdi.h>
#endif

#if !defined( __VT52 )
#include <screen.h>
#endif

typedef struct
{
	long id, val;
}COOKIE;

typedef struct
{
	char	xb_magic[4];										/* Kennung */
	char	xb_id[4];												/* ID des PRGs */
	long	xb_oldvec;											/* Alter Vektor */
}XBRA;

typedef struct {
   long		id;      	/* ID des Schoners */
   int	  version; 	/* Version des XSSI-Protokolls (0x100) */
   int  	save_stat; /* Mitteilung, ob gerade geschont wird. 0=nein */
   int	  prg_stat;  /* Status des Programms:
                              0= normal schonen,
                              1= niemals schonen bzw sofort aufh”ren,
                             -1= sofort schonen.                          */
} INFOXSSI;

extern	_app;

int		pwchar, phchar, pwbox, phbox;
int		ap_id, me_id, ap_type, handle;
int		work_in[11], work_out[57], pbuf[8];

/* Start-up Funktionen */
#define	NO		0
#define	AUTO	1
#define	ACC		2
#define	PRG		4
#define	TOS		8
#define	ANY	 15

void		e_start_as(int	how, char	*ap_name);
void		e_quit(void);

/* Cookie-Funktionen */
#define	C_NEVER	0
#define	C_ALWAYS 1
#define	C_FULL 2
#define	C_LAST 3

long		inst_cjar(long n);
int			make_cookie(long cid, long cval, int jarmode, long n);
int			find_cookie(long cid, long *cval);
int			search_cookie(long n, long *cid, long *cval);
int			kill_cookie(long cid);

/* XBRA-Funktionen */
int		vector(int offset, long xbid, int del);

/* Ausgabe-Funktionen */
void show(int zahl);
void showxy(int x, int y, int zahl);

/* Screen saver Funktionen */
int		scrsvr(void);

#endif