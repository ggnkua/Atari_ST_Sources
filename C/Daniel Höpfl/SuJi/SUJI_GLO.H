#ifndef __DH_SUJI_GLO_H_
#define __DH_SUJI_GLO_H_

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <tos.h>
#include <scancode.h>
#include <vdi.h>
#include <aes.h>

#ifndef FALSE
#define FALSE	0
#define TRUE	(!0)
#endif

#include "SuJi.h"

#include "SuJi_av.h"
#include "SuJi_con.h"
#include "SuJi_DD.h"
#include "SuJi_dia.h"
#include "SuJi_fil.h"
#include "SuJi_inh.h"
#include "SuJi_lis.h"
#include "SuJi_mas.h"
#include "SuJi_opt.h"
#include "SuJi_pfa.h"
#include "SuJi_quo.h"
#include "SuJi_sor.h"
#include "SuJi_vdi.h"
#include "SuJi_win.h"

#include "xdial.h"
#include "dh_dir.h"

extern char versionsnummernstring[];

extern int ap_id;
extern GlobalArray global;

struct CONFIG
{
	GRECT dialog;
	GRECT listwindow;
	int show_size;
	int show_time;
	int show_date;
	int show_flags;
	int show_origin;
	int clipboard_name;
	int clipboard_size;
	int clipboard_time;
	int clipboard_date;
	int clipboard_flags;
	int clipboard_origin;
	int clipboard_origin_name;
};

extern struct CONFIG config;

extern int show_row[6];
extern int max_breite[6];

struct SUCHINFORMATIONEN 
{
	void *search_pfade;
	int zahl_pfade;

	char *maske;
	char *inhalt;
	unsigned int min_date;
	unsigned int max_date;
	unsigned long min_size;
	unsigned long max_size;
	int big_is_small_maske;
	int big_is_small_inhalt;
};

extern struct SUCHINFORMATIONEN suji;

extern char *bubble_string;

extern char *prog_name;

/* Standardvariablen */
extern char *alert;
extern int i,dummy;

extern int searching;

#define BR_FILE	0
#define BR_SIZE	1
#define BR_TIME	2
#define BR_DATE	3
#define BR_ATTR 4
#define BR_PATH	5
#define left_space 6

extern char help_str_liste[];
extern char help_str_dialog[];

extern int there_is_check_and_set;

/* Variablen fÅr die USERDEFs in der Listbox */
extern USERBLK ud_ENTRY1;
extern USERBLK ud_ENTRY2;
extern USERBLK ud_ENTRY3;
extern USERBLK ud_ENTRY4;

extern int home_search( char *filename, char *configpath );


#endif
