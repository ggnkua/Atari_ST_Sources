/*
	SHUTDOWN.CP

	(System herunterfahren und 
	Auflîsungswechsel initiieren)

	Autor:	Thomas KÅnneth
			Friedrich-Neuper-Str. 2b
			90552 Rîthenbach

	V1.0 ab 16.1.1995

	(c) MAXON

	Compiler: Pure C 1.1
	Tabweite: 2

	/* um das Modul Åbersetzen zu kînnen ist
	die Headerdatei CPX.H erforderlich in der
	die fÅr CPXse erforderliche Strukturen
	deklariert werden
*/

#define	EXTERN	extern

/* Headerfiles */
#include "shutdown.rsh"
#include "shutdown.rh"
#include <stddef.h>
#include <cpx.h>
#include <string.h>
#include <tos.h>
#include <vdi.h>
#include <stdlib.h>
#include <stdio.h>

typedef enum { FALSE, TRUE } BOOLEAN;

extern	GEMPARBLK	_GemParBlk;

/* Prototypen */
CPXINFO * cdecl cpx_init(XCPB *Xcpb);
int cdecl cpx_call(GRECT *rect);
int popup(OBJECT *tree,int object,char *entries[],int number_of_entries,int default_entry,GRECT *r);

/* Zeiger auf die XControl-Funktionen */
XCPB 	*xcpb;

/* Zeiger auf unsere Funktionen */
CPXINFO cpxinfo;

/* Feld fÅr PIDs von Prozessen, die
	per Pkill() entfernt werden */
int	pid[50];

/* das Popup mit den Bildschirm-Modi */
char	*scrmodes[] = {
	"  ST-niedrig ",
	"  ST-mittel  ",
	"  ST-hoch    ",
	"  TT-niedrig ",
	"  TT-mittel  ",
	"  TT-hoch    "
} ;

/* soviele EintrÑge hat es */
#define	NUM_SCRMODES	6

/* hier werden die Parameter fÅr shel_write()
	eingetragen */
int	iscr[NUM_SCRMODES] = {0,0,0,0,0,0};
int	isgr[NUM_SCRMODES] = {2,3,4,9,6,8};

int	current_page,	/* welcher Dialog? */
	xc_mint;		/* MiNT-ID XControl */

int popup(OBJECT *tree,int object,char *entries[],int number_of_entries,int default_entry,GRECT *r)
{
	GRECT pos;
	objc_offset(tree,object,&pos.g_x,&pos.g_y);
	pos.g_w=tree[object].ob_width;
	pos.g_h=tree[object].ob_height;
	return ((*xcpb->Popup)(entries,number_of_entries,default_entry,3,&pos,r));
}

CPXINFO *cdecl cpx_init(XCPB *Xcpb)
{
	int	i;
	xcpb = Xcpb;
	if (xcpb->booting)
		return ((CPXINFO *)TRUE);
	else {
		if (!xcpb->SkipRshFix)
			for (i = 0; i < NUM_OBS; i++)
				(xcpb->rsh_obfix)(rs_object,i);
		cpxinfo.cpx_call = cpx_call;
		return (&cpxinfo);
	}
}

/* im Supervisor-Mode ausfÅhren! */
long get_bootdev(void)
{
	return ((long)*((int *)0x446));
}

void kill_procs(int num)
{
	int	i;
	/* Prozesse bitten, sich zu beenden */
	for (i = 0; i < num; i++)
		Pkill(pid[i],SIGTERM);
	/* ein paar Sekunden Zeit lassen */
	Fselect(3000,NULL,NULL,NULL);
	/* jetzt Prozesse abschieûen */
	for (i = 0; i < num; i++)
		Pkill(pid[i],SIGKILL);
}

int term_procs(void)
{
	char	*filename = "x:\\shutdown.inf",
			*buf;
	long	error,
			flen,
			i;
	int		fd,
			count = -1;
	/* MiNT Cookie suchen */
	if ((xcpb->getcookie)('MiNT',NULL) != 0) {
		/* Bootlaufwerk ermitteln und eintragen */
		filename[0] = 65 + (char)Supexec(get_bootdev);
		/* versuchen, Datei zu îffnen */
		error = Fopen(filename,FO_READ);
		if (error >= 0) {
			fd = (int)error;
			/* LÑnge der Datei ermitteln */
			flen = Fseek(0,fd,2);
			/* Speicher reservieren und einlesen */
			Fseek(0,fd,0);
			buf = Malloc(flen + 1);
			if (buf != NULL) {
				buf[flen] = '\0';
				if (Fread(fd,flen,buf) == flen) {
					i = 0;
					count = 0;
					while (i <= (flen - 8)) {
						buf[i + 8] = '\0';
						/* nach dieser Anwendung suchen */
						pid[count] = appl_find(&(buf[i]));
						if (pid[count] >= 0) {
							/* die MiNT-PID ermitteln */
							pid[count] = appl_find((void *)(0xfffe0000L | (long)pid[count]));
							if (pid[count] != -1) {
								count += 1;
								if (count == 50)
									break;
							}
						}
						i += 10;
					}
				}
				Mfree(buf);
			}
			Fclose(fd);
		}
	}
	return (count);
}

BOOLEAN ini_shutdown(int doex,int isgr,int iscr)
{
	BOOLEAN	success = TRUE,
			first = TRUE;
try_again:
	if (shel_write(doex,isgr,iscr,NULL,NULL) == 0) {
		if (first != FALSE) {
			first = FALSE;
			if (term_procs() != FALSE)
				goto try_again;
		}
		success = FALSE;
	}
	return (success);
}

int cdecl cpx_call(GRECT *rect)
{
	int		old = -1,
			result,
			xcid,
			num_procs,
			new_rez,
			mbuf[8];
	BOOLEAN	abbruch = FALSE;
	OBJECT *tree;
	/* die Hauptseite zeigen */
	current_page = MAIN_PAGE;
	appl_init();
	/* nur ab AES4 weitermachen */
	if (_GemParBlk.global[0] >= 0x400) {
		xcid = appl_find("XCONTROL");
		/* MiNT-ID XControl */
		xc_mint = appl_find((void *)(0xfffe0000L | (long)xcid));
		/* ggf. den Kill-Button deaktivieren */
		num_procs = term_procs();
		if (num_procs > 0)
			rs_trindex[SHUT_ERROR][BT_ED_KILL].ob_state &= ~DISABLED;
		else
			rs_trindex[SHUT_ERROR][BT_ED_KILL].ob_state |= DISABLED;
		while (abbruch == FALSE) {
			if (old != current_page) {
				tree = rs_trindex[current_page];
				tree[0].ob_x = rect->g_x;
				tree[0].ob_y = rect->g_y;
				objc_draw(tree,ROOT,MAX_DEPTH,rect->g_x,rect->g_y,rect->g_w,rect->g_h);
				old = current_page;
			}
			result = (xcpb->Xform_do)(tree,0,mbuf);
			if (result == -1)
				switch (mbuf[0]) {
					case AC_CLOSE:
					case WM_CLOSED:
						abbruch = TRUE;
						break;
				}
			else {
				result &= 0x7fff;	/* Doppelklick ignorieren */
				objc_change(tree,result,0,rect->g_x,rect->g_y,rect->g_w,rect->g_h,
							tree[result].ob_state & ~SELECTED,TRUE);
				switch (current_page) {
					case SHUT_DO:
						if (result == BT_DOSHUT_OK) {
							if (ini_shutdown(4,2,0) == FALSE)
								current_page = SHUT_ERROR;
							else
								abbruch = TRUE;
						}
						else
							current_page = MAIN_PAGE;
						break;
					case SHUT_ERROR:
						if (result == BT_ED_KILL)
							kill_procs(num_procs);
						current_page = MAIN_PAGE;
						break;
					case MAIN_PAGE:
						if (result == BT_MP_SHUTDOWN)
							current_page = SHUT_DO;
						else
							if (result == BT_MP_CANCEL)
								abbruch = TRUE;
							else
								if (result == PU_MP_SELRES) {
									new_rez = popup(tree,PU_MP_SELRES,scrmodes,NUM_SCRMODES,-1,rect);
									if (new_rez != -1)
										if (ini_shutdown(5,isgr[new_rez],iscr[new_rez]) == FALSE)
											current_page = SHUT_ERROR;
										else {
											mbuf[0] = AP_TERM;
											mbuf[1] = _GemParBlk.global[2];
											mbuf[2] = 0;
											mbuf[5] = AP_RESCHG;
											appl_write(xcid,16,mbuf);
											Pkill(xc_mint,SIGTERM);
											abbruch = TRUE;
										}
								}
						break;
				}
			}
		}
	}
	appl_exit();
	return (0);
}
