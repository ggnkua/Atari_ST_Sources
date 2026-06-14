/************************************************************/
/* Project	: RSCText										*/
/*															*/
/* Use		: Erzeugt aus einer Resourcedatei einen Quell-	*/
/*			  text, der ohne Bearbeitung in Turbo-C einge-	*/
/*			  bunden werden kann. (gem. ANSI-Standard)		*/
/*			  Quellen: (1) Atari ST Profibuch				*/
/*==========================================================*/
/* Author	: Bonsai (Erik Dick)							*/
/* Date 	: 19/08/1989									*/
/*----------------------------------------------------------*/
/* Version			: 1.8									*/
/* Object-Computer	: Atari 1040 STF						*/
/* Compiler 		: Turbo C 1.1							*/
/*		Options 	: -C -G 								*/
/*----------------------------------------------------------*/
/* Copyright: SDI - the Strange Data Invasion				*/
/************************************************************/

#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <vdi.h>

#include "rsctext.h"
#include "rsctext.rsh"

int width_blk;

#define TOS_OLD 0x1300
#define TURBO	0x1400
#define TOS_1_4 0x1500

typedef enum _boolean
{	FALSE,
	TRUE
} boolean;

typedef struct _rshhdr															/* Definiert den Header einer Resource gem. (1) */
{	unsigned int	rsh_vrsn,
					rsh_object,
					rsh_tedinfo,
					rsh_iconblk,
					rsh_bitblk,
					rsh_frstr,
					rsh_string,
					rsh_imdata,
					rsh_frimg,
					rsh_trindex,
					rsh_nobs,
					rsh_ntree,
					rsh_nted,
					rsh_nib,
					rsh_nbb,
					rsh_nstring,
					rsh_nimages,
					rsh_rssize;
} RSHHDR;

typedef struct _apl_par 														/* Dieser Typ nimmt alle Application-Parameter auf		*/
{	int id, 																	/*	-> Application-ID									*/
		phys_handle,															/*	-> Physiaklischer Handle der Arbeitsstation 		*/
		virt_handle,															/*	-> Virtueller Handle der angemeldeten Applikation	*/
		p_wchar,																/*	-> Zeichensatzinformationen 						*/
		p_hchar,
		p_wbox,
		p_hbox,
		work_in[11],															/*	-> Ein- Ausgabefelder fÅr AES-GEM					*/
		work_out[57],
		msg[8]; 																/*	-> Puffer fÅr Nachrichten die der AES-Manager an die*/

	char path[80],
		 name[13];
} apl_par;

enum alert_code
{	API_ERR,
	APE_ERR,
	NABR_ERR,
	FNO_ERR,
	RSNO_ERR,
	TLM_ERR,
	RNF_ERR,
	FSEL_ERR
};

char *alert_msg[] =
{	"[3][|Die Applikation kann sich|nicht sauber anmelden!][Damned!]",
	"[3][|Die Applikation kann sich|nicht sauber abmelden!][Booten !!!]",
	"[3][|Es wurden nicht alle Bytes|gelesen!][Damned!]",
	"[3][|Die Ausgabedatei kann nicht|geîffnet werden!][Damned!]",
	"[3][|Die Resource-Datei konnte|nicht geîffnet werden!][Damned!]",
	"[3][|Zu wenig Speicher!][Damned!]",
	"[3][|Die Resource-Datei ist nicht|zu finden][Damned!]",
	"[3][|Der File-Selektor ist abge-|stÅrzt][Damned!]"
};

/*-----------------------------------------------------------------------------*/
/* Funktion : alert 															 */
/* Aufgabe	: Aufbau einer Alarmbox Åber alert_msg[alert_codes] 				 */
/* Ergebnis : ----- 															 */
/* Parameter: alert_code		| Zeiger auf das einzufÅgende Objekt		   */
/*-----------------------------------------------------------------------------*/

void alert(int alert_code)
{	form_alert(1,alert_msg[alert_code]);
}

/*-----------------------------------------------------------------------------*/
/* Funktion : detect_file														 */
/* Aufgabe	: Hallali, der File-Selektor									   */
/* Ergebnis : TRUE, wenn alles klar; FALSE, wenn Fehler oder ABBRUCH			 */
/* Parameter: *fs_iinpath			| Zeiger auf einen vorselektierten Pfad    */
/*			  *fs_iinsel			| Zeiger auf eine vorselektierte Datei	   */
/*			  *ext					| Zeiger auf die gewÑhlte Extension 		*/
/*			  *fs_ioutsel			| Zeiger auf den gewÑhlten Pfad 		   */
/*-----------------------------------------------------------------------------*/

boolean detect_file(char *fs_iinpath, char *fs_iinsel, char *ext, char *fs_ioutsel, char *headline)
{	int fs_iexbtn, i, lbs_pos;

	fs_ioutsel[0] = '\0';
	strcat(fs_iinpath,ext);
	switch(Sversion())
	{	case TOS_OLD :
		case TURBO	 :	if(!fsel_input(fs_iinpath, fs_iinsel, &fs_iexbtn))
						{	alert(FSEL_ERR);
							return(FALSE);
						}
						break;
		case TOS_1_4 :	if(!fsel_exinput(fs_iinpath, fs_iinsel, &fs_iexbtn, headline))
						{	alert(FSEL_ERR);
							return(FALSE);
						}
	}
	lbs_pos = i = 0;
	while(fs_iinpath[i] != '\0')
		if(fs_iinpath[i++] == '\\')
			lbs_pos = i;
	fs_iinpath[lbs_pos] = '\0';
	if(!fs_iexbtn)
	{	fs_ioutsel[0] = '\0';
		return (FALSE);
	}
	else
	{	strncpy(fs_ioutsel, fs_iinpath,lbs_pos+1);
		strcat(fs_ioutsel,fs_iinsel);
		return (TRUE);
	}
}

/*-----------------------------------------------------------------------------*/
/* Funktion : open_vwork														*/
/* Aufgabe	: ôffnet eine virtuelle Arbeitsstation							   */
/* Ergebnis : Liefert TRUE wenn Anmeldevorgang geklappt hat, ansonsten FALSE   */
/* Parameter: *ap_parm			| Zeiger auf den Parameterblock der Appli-	   */
/*								| kation									   */
/*-----------------------------------------------------------------------------*/

boolean open_vwork(apl_par *ap_parm)
{	register int i;

	if((ap_parm->id = appl_init()) != -1)										/* -> Wenn das Anmelden der Applikation geklappt hat		*/
	{	for(i = 1; i < 10; ap_parm->work_in[i++] = 0)							/*		-> Initialisiere die globalen AES-Variablen 		*/
			;
		ap_parm->work_in[10] = 2;
		ap_parm->phys_handle = graf_handle(&ap_parm->p_wchar, &ap_parm->p_hchar,/*		-> Ermittle den physik. Handle der Arbeitsstation	*/
											 &ap_parm->p_wbox, &ap_parm->p_hbox);
		ap_parm->work_in[0] = ap_parm->phys_handle = ap_parm->virt_handle;		/*		-> Ermittle den virt. Handle der Anwendung			*/
		v_opnvwk(ap_parm->work_in, &ap_parm->virt_handle, ap_parm->work_out);
		graf_mouse(ARROW,0);

		return(TRUE);															/*		-> Na, klappt doch alles wie geplant				*/
	}
	else
	{	alert(API_ERR); 														/* -> Auweia, die Anwendung kann sich nicht anmelden. Dann	*/
		return(FALSE);															/*		schlage aber krÑftig Alarm							*/
	}
}

/*-----------------------------------------------------------------------------*/
/* Funktion : close_vwork														 */
/* Aufgabe	: Schlieût eine virtuelle Arbeitsstation							*/
/* Ergebnis : ----- 															 */
/* Parameter: *ap_parm			| Zeiger auf den Parameterblock der Appli-	   */
/*								| kation									   */
/*-----------------------------------------------------------------------------*/

void close_vwork(apl_par *ap_parm)
{	v_clsvwk(ap_parm->virt_handle); 											/* -> virtuelle Ausgabestation schlieûen					*/
	if(!appl_exit())															/* -> Anwendung abmelden									*/
	{	alert(APE_ERR);
	}
}

/*-----------------------------------------------------------------------------*/
/* Funktion : objc_init 														*/
/* Aufgabe	: Paût die Objektdarstellung der Auflîsung an						*/
/* Ergebnis : ----- 															 */
/* Parameter: *rs_object		| Zeiger auf das Objektfeld 					 */
/*			  nobs				| Anzahl der zu initialisierenden Objekte		*/
/*-----------------------------------------------------------------------------*/

void objc_init(OBJECT *rs_object,int nobs)
{	register int i;

	for(i = 0; i < nobs; rsrc_obfix(rs_object,i++))
		;
}

/*-----------------------------------------------------------------------------*/
/* Funktion : message														   */
/* Aufgabe	: Teilt dem Benutzer mit, was gerade gemacht wird				   */
/* Ergebnis : ----- 															 */
/* Parameter: *s				| Zeiger auf einen Teil der Mitteilung		   */
/*-----------------------------------------------------------------------------*/

void message(char *s)
{	char temp[41];

	sprintf(temp,"Writing %s ...",s);
	sprintf(TREE[MAINDIAL][MESSAGE].ob_spec.tedinfo->te_ptext,
			"%-40s",temp);
	objc_draw(TREE[MAINDIAL],MESSAGE,MAX_DEPTH,0,0,639,399);
}

/*------------------------------------------------------------------------------*/
/* Funktion : headcom															*/
/* Aufgabe	: Schreibt den einfÅhrenden Kommentar in die Ausgabe-Datei			*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *s1				| Zeiger auf eigentlichen Kommentar 			*/
/*			  nos				| Anzahl der Einheiten pro Block				*/
/*			  *s2				| Zeiger auf die eventuellen Blockdeklaration	*/
/*------------------------------------------------------------------------------*/

void headcom(FILE *o_handle, char *s1, int nos, char *s2)
{	if(nos > 0) 															/* -> Wenn BITBLK/ ICNBLK/ TEDINFO/ OBJECT-Strukturen headcom auf-	*/
	{	message(s1);
		fprintf(o_handle,"\n/****************************************/" 	/*		werden und zwar dann wenn das erste Object in Arbeit ist.	*/
						 "\n/* %-36s */"									/* -> Aktion melden / EinfÅhrenden Kommentar in die Ausgabe-Datei	*/
						 "\n/****************************************/\n\n",s1);/*	  schreiben.												*/
		fprintf(o_handle,"%s",s2);											/*		rufen, dann kommt in nos die Anzahl der zu schreibenden 	*/
	}
}																			/*	  tion (-> s2) in die Ausgabe-Datei geschrieben 				*/

/*------------------------------------------------------------------------------*/
/* Funktion : l_end 															*/
/* Aufgabe	: Ermittelt das Ende einer Zeile bei Blocks & Strukturen			*/
/* Ergebnis : Zeiger auf den String mit dem Zeilenende							*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*			  *obj				| Zeiger auf das aktuell zu bearbeitende Object */
/*------------------------------------------------------------------------------*/

char *l_end(unsigned int par1, unsigned int par2)
{	static char ls[6];
																				/* -> Wenn Blockstrukturen geschrieben werden, muû am Ende der Zeile*/
	return( par1 == par2-1 ? strcpy(ls,"\n};\n") : strcpy(ls,",\n	"));		/*	  immer ein Komma und ein Zeilevorschub stehen, auûer in der	*/
}																				/*	  letzten Zeile, die muû mit einer geschweiften Klammer enden	*/

/*------------------------------------------------------------------------------*/
/* Funktion : get_tstr															*/
/* Aufgabe	: Ermittelt die Adresse der Teilbereiche einer TEDINFO-Struktur 	*/
/* Ergebnis : Adresse des Teilbereichs der Struktur 							*/
/* Parameter: *rh				| Zeiger auf den Resource-header				*/
/*			  *ted				| Zeiger auf die aktuelle TEDINFO-Struktur		*/
/*			  part				| Zu ermittelnder Teilbereich					*/
/*------------------------------------------------------------------------------*/

char *get_tstr(RSHHDR *rh, TEDINFO *ted, const char part)
{	switch(part)
	{	case 's' :	return( (char *) ((long) rh + (long) ted->te_ptext) );		/* Adresse des Strings mit te_ptext */
		case 'v' :	return( (char *) ((long) rh + (long) ted->te_pvalid) ); 	/* Adresse des Strings mit te_ptmplt*/
		case 't' :	return( (char *) ((long) rh + (long) ted->te_ptmplt) ); 	/* Adresse des Strings mit te_pvalid*/
		default  :	return(""); 												/*	   wird zurÅckgegeben			*/
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : tedlen															*/
/* Aufgabe	: Ermittelt die max. Breite des String eine TEDINFO-Struktur		*/
/* Ergebnis : Eben die besagte Breite											*/
/* Parameter: *rh				| Zeiger auf den Resource-header				*/
/*			  *ted				| Zeiger auf die aktuelle TEDINFO-Struktur		*/
/*------------------------------------------------------------------------------*/

unsigned long tedlen(RSHHDR *rh, TEDINFO *ted)
{	return(strlen(get_tstr(rh, ted,'s')) > strlen(get_tstr(rh, ted,'v')) ?
			strlen(get_tstr(rh, ted,'s'))+1 :
			strlen(get_tstr(rh, ted,'v'))+1 );
}

/*------------------------------------------------------------------------------*/
/* Funktion : wr_tedstrings 													*/
/* Aufgabe	: Schreibt die TEDINFO-Strings in die Output-Datei					*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*------------------------------------------------------------------------------*/

void wr_tedstrings(FILE *o_handle, RSHHDR *rh)
{	unsigned long tedn;
	TEDINFO *tedp;

	headcom(o_handle, "TEDINFO-Strings", rh->rsh_nted, ""); 					/* -> Heading-comment schreiben 								*/
	tedp = (TEDINFO *) ((long)rh + rh->rsh_tedinfo);
	for(tedn = 0; tedn < rh->rsh_nted; tedn++)
	{	fprintf(o_handle,"char TED%lu_s[%lu] = \"%s\";\n",						/* -> Deklaration von TEDINFO.te_ptext in die Ausgabe-Datei 	*/
						 tedn,
						 tedlen(rh, tedp),
						 get_tstr(rh, tedp,'s'));
		fprintf(o_handle,"#define TED%lu_t \"%s\"\n",							/* -> PrÑ-Prozessor Definition von TEDINFO.te_pvalid in die Aus-*/
						 tedn,													/*	  gabe-Datei												*/
						 get_tstr(rh, tedp,'t'));
		fprintf(o_handle,"#define TED%lu_v \"%s\"\n",							/* -> PrÑ-Prozessor Definition von TEDINFO.te_ptmplt in die Aus-*/
						 tedn,													/*	  gabe-Datei												*/
						 get_tstr(rh, tedp,'v'));
		tedp++;
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : get_istr															*/
/* Aufgabe	: Ermittelt die Adresse des Strings der aktuellen ICONBLK-Struktur	*/
/* Ergebnis : Adresse des Teilbereichs der Struktur 							*/
/* Parameter: *rh				| Zeiger auf den Resource-header				*/
/*			  *iblk 			| Zeiger auf die aktuelle ICONBLK-Struktur		*/
/*------------------------------------------------------------------------------*/

char *get_istr(RSHHDR *rh, ICONBLK *iblk)
{	return( (char *) ((long) rh + (long) iblk->ib_ptext) ); 					/* -> Adresse von ICONBLK.ib_text zurÅckgeben	*/
}

/*------------------------------------------------------------------------------*/
/* Funktion : wr_icnstrings 													*/
/* Aufgabe	: Schreibt die ICONBLK-Strings in die Output-Datei					*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*------------------------------------------------------------------------------*/

void wr_icnstrings(FILE *o_handle, RSHHDR *rh)
{	unsigned long ibn;
	ICONBLK *ibp;

	headcom(o_handle, "ICONBLK-Strings", rh->rsh_nib, "");						/* -> Heading-comment schreiben 								*/
	ibp = (ICONBLK *) ((long)rh + rh->rsh_iconblk);
	for(ibn = 0; ibn < rh->rsh_nib; ibn++)
	{	fprintf(o_handle,"char ICNSTR%lu[%lu] = \"%s\";\n", 							/* -> PrÑ-Prozessor Definition von ICONBLK.ib_pext in die Aus-	*/
						 ibn,													/*	  gabe-Datei												*/
						 strlen(get_istr(rh, ibp)) + 1,
						 get_istr(rh, ibp));
		ibp = (ICONBLK *) ((long) ibp + sizeof(ICONBLK) - 2);
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : wr_frstrings														*/
/* Aufgabe	: Schreibt die free-Strings in die Output-Datei 					*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*------------------------------------------------------------------------------*/

void wr_frstrings(FILE *o_handle, RSHHDR *rh)
{	unsigned long objn;
	unsigned long frstrn;
	OBJECT *objp;

	headcom(o_handle, "Free-Strings", rh->rsh_nobs, "");									/* -> Heading-comment schreiben 	*/
	frstrn = 0;
	objp = (OBJECT *) ((long) rh + rh->rsh_object);
	for(objn = 0; objn < rh->rsh_nobs; objn++)
	{	switch(objp->ob_type)
		{	case	G_BUTTON	:												/* -> Nur wenn der Typ in dieser Liste steht wird die Aktion	*/
			case	G_STRING	:												/*	  ausgefÅhrt												*/
			case	G_TITLE 	:	fprintf(o_handle,"#define FSTR%lu \"%s\"\n",/* -> PrÑ-Prozessor Definition von ICONBLK.ib_pext in die Aus-	*/
											frstrn++,								/*	  gabe-Datei												*/
											(char *) ((long) rh + (long) objp->ob_spec.free_string));
									break;
			default 			:	;
		}
		objp++;
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : wr_pblk															*/
/* Aufgabe	: Schreibt einen Datenblock in die Output-Datei (Bitblocks, Iconmas-*/
/*			  ken und Iconimages												*/
/* Ergebnis : Gibt die Anzahl der geschriebenen Longs zurÅck					*/
/* Parameter: rh				| Zeiger auf den Output-Stream					*/
/*			  pdata 			| Zeiger auf den auszugebenden Datenblock		*/
/*			  wb				| Breite des Datenblockes						*/
/*			  hl				| Hîhe des Datenblockes 						*/
/*------------------------------------------------------------------------------*/

void wr_pblk(FILE *o_handle, int *pdata, int wb, int hl)
{	unsigned int i, k, pos, bytes;

	pos = 1;
	bytes = (hl * wb);
	for(i=0; i < hl; i++)														/* -> öber die gesamte Hîhe des Blockes laufen				*/
		for(k=0; k < wb; k++)
			if((pos == wb) || (pos % width_blk == 0))
			{	fprintf(o_handle,"%-#6x%s", 										/*	Letzte Blockeinheit (16-Bit) schreiben + variables Zei- */
						*pdata++,													/*	  lenende												*/
						l_end((i*wb)+k, bytes));
				pos = 1;
			}
			else
			{	fprintf(o_handle,"%-#6x, ",*pdata++);							/*		Jeweils eine Blockeinheit (16-Bit) schreiben		*/
				pos++;
			}
}

/*------------------------------------------------------------------------------*/
/* Funktion : bblk_wb_hl														*/
/* Aufgabe	: Ermitelt die Breite, die Hîhe und die Adresse des Bitblockes der	*/
/*			  aktuellen BITBLK-Struktur 										*/
/* Ergebnis : Adresse des Bitblocks 											*/
/* Parameter: *rh				| Zeiger auf den Resource-header				*/
/*			  *bitblk			| Zeiger auf die aktuelle BITBLK-Struktur		*/
/*			  *wb				| Zeiger auf Var. fÅr die Bitblock-Breite		*/
/*			  *hl				| Zeiger auf Var. fÅr die Bitblock-Hîhe 		*/
/*------------------------------------------------------------------------------*/

int *bblk_wb_hl(RSHHDR *rh, BITBLK *bitblk, int *wb, int *hl)
{	*wb = bitblk->bi_wb / 2;													/* -> Hier wird die Hîhe ermittelt						*/
	*hl = bitblk->bi_hl;														/* -> Hier wird die Breite ermittelt					*/
	return( (int *) ((long) rh + (long) bitblk->bi_pdata) );					/* Berechnung der Adresse des Datenblockes */
}

/*------------------------------------------------------------------------------*/
/* Funktion : wr_bitblks														*/
/* Aufgabe	: Schreibt die Bitblocks in die Output-Datei						*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*------------------------------------------------------------------------------*/

void wr_bitblks(FILE *o_handle, RSHHDR *rh)
{	 unsigned long bbn;
	 BITBLK *bbp;
	 int wb, hl, i, k;
	 int *pdata;

	headcom(o_handle, "Bitblocks", rh->rsh_nbb, "");							/* -> Heading-comment schreiben 							 */
	bbp = (BITBLK *) ((long)rh + rh->rsh_bitblk);
	for(bbn = 0; bbn < rh->rsh_nbb; bbn++)
	{	fprintf(o_handle,"\nint IMAGE%lu[] =\n{ ",bbn); 						/*		-> Blockdeklaration schreiben							*/
		pdata = bblk_wb_hl(rh, bbp, &wb, &hl);									/*		-> Alle Werte berechnen um den Bitblock zu schreiben	*/
		wr_pblk(o_handle, pdata, wb, hl);										/*		-> Bitblock schreiben mit den berechneten Werten		*/
		bbp++;
	}
}


/*------------------------------------------------------------------------------*/
/* Funktion : icn_wb_hl 														*/
/* Aufgabe	: Ermittelt die Breite, die Hîhe und die Adresse der Maske oder des */
/*			  Images der aktuellen ICONBLK-Struktur 							*/
/* Ergebnis : Adresse des entsprechenden Datenblockes							*/
/* Parameter: *rh				| Zeiger auf den Resource-header				*/
/*			  *iconblk			| Zeiger auf die aktuelle ICONBLK-Struktur		*/
/*			  *wb				| Zeiger auf Var. fÅr die Datenblock-Breite 	*/
/*			  *hl				| Zeiger auf Var. fÅr die Datenblock-Hîhe		*/
/*			  part				| Iconmaske oder Iconimage ?					*/
/*------------------------------------------------------------------------------*/

int *icn_wb_hl(RSHHDR *rh, ICONBLK *iconblk, int *wb, int *hl, const char part)
{	*wb = iconblk->ib_wicon / 16;												/* -> Berechne die Hîhe des Datenblockes					*/
	*hl = iconblk->ib_hicon;													/* -> Berechne die Breite des Datenblockes					*/
	switch(part)
	{	case 'm' :	return( (int *) ((long) rh + (long) iconblk->ib_pmask) ); /* Berechne die Adresse der Iconmaske */
		case 'i' :	return( (int *) ((long) rh + (long) iconblk->ib_pdata) ); /* Berechne die Adresse des Iconimages	*/
		default  :	return (0);
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : wr_iconblocks 													*/
/* Aufgabe	: Schreibt die Iconblocks in die Output-Datei						*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*------------------------------------------------------------------------------*/

void wr_iconblocks(FILE *o_handle, RSHHDR *rh)
{	unsigned long ibn;
	ICONBLK *ibp;
	int wb, hl, i, k;
	int *p_mdata;

	ibp = (ICONBLK *) ((long)rh + rh->rsh_iconblk);
	headcom(o_handle, "Iconblocks", rh->rsh_nib, "");							/* -> Heading comment schreiben 			 */
	for(ibn = 0; ibn < rh->rsh_nib; ibn++)
	{	fprintf(o_handle,"\nint ICN%lu_M []=\n{ ",ibn); 						/*		Deklaration des Iconmasken-Blockes schreiben	*/
		p_mdata = icn_wb_hl(rh, ibp, &wb, &hl, 'm');							/* Breite, Hîhe und Adresse des Maskenblockes berechnen */
		wr_pblk(o_handle, p_mdata, wb, hl); 									/* Block schreiben										*/
		fprintf(o_handle,"\nint ICN%lu_I []=\n{ ",ibn); 						/*		Deklaration des Iconimage-Blockes schreiben 	*/
		p_mdata = icn_wb_hl(rh, ibp, &wb, &hl, 'i');							/* Breite, Hîhe und Adresse des Imageblockes berechnen	*/
		wr_pblk(o_handle, p_mdata, wb, hl); 									/* Block schreiben										*/
		ibp = (ICONBLK *) ((long) ibp + sizeof(ICONBLK) -2);
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : bitblk_str														*/
/* Aufgabe	: Schreibt die BITBLK-Strukturen in die Output-Datei				*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*			  *obj				| Zeiger auf das aktuell zu bearbeitende Objekt */
/*------------------------------------------------------------------------------*/

void bitblk_str(FILE *o_handle, RSHHDR *rh)
{	unsigned long bbn;
	BITBLK	*bbp;

	headcom(o_handle, "BITBLK-structures", rh->rsh_nbb, 						/* -> Heading-comment schreiben 					*/
					  "\nBITBLK rs_bitblk[] =\n{	");
	bbp = (BITBLK *) ((long) rh + rh->rsh_bitblk);								/* -> Adresse der BITBLK-Struktur berechnen 		*/
	for(bbn = 0; bbn < rh->rsh_nbb; bbn++)
	{	fprintf(o_handle,"IMAGE%lu, %-#6x, %-#6x, %-#6x, %-#6x, %-#6x%s",		/* -> Schreibe die komplette Datenstruktur in die	*/
				bbn,															/*		Ausgabe-Datei								*/
				bbp->bi_wb,
				bbp->bi_hl,
				bbp->bi_x,
				bbp->bi_y,
				bbp->bi_color,
				l_end(bbn, rh->rsh_nbb));
		bbp++;
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : iconblk_str														*/
/* Aufgabe	: Schreibt die ICONBLK-Strukturen in die Output-Datei				*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*------------------------------------------------------------------------------*/

void iconblk_str(FILE *o_handle, RSHHDR *rh)
{	unsigned long ibn;
	ICONBLK *ibp;

	headcom(o_handle, "ICONBLK-structures", rh->rsh_nib,						/* -> Heading-comment schreiben 					*/
					  "\nICONBLK rs_iconblk[] =\n{	");
	ibp = (ICONBLK *) ((long) rh + rh->rsh_iconblk);							/* -> Adresse der ICONBLK-Struktur berechnen		*/
	for(ibn = 0; ibn < rh->rsh_nib; ibn++)
	{	fprintf(o_handle,"ICN%lu_M, ICN%lu_I, ICNSTR%lu, "						/* -> Schreibe die komplette ICONBLK-Struktur in die*/
						 "%-#6x, %-#6x, %-#6x, %-#6x, %-#6x, %-#6x,"			/*	  Ausgabe-Datei 								*/
						 "%-#6x, %-#6x, %-#6x, %-#6x, %-#6x, %-#6x%s",
				ibn,
				ibn,
				ibn,
				ibp->ib_char,
				ibp->ib_xchar,
				ibp->ib_ychar,
				ibp->ib_xicon,
				ibp->ib_yicon,
				ibp->ib_wicon,
				ibp->ib_hicon,
				ibp->ib_xtext,
				ibp->ib_ytext,
				ibp->ib_wtext,
				ibp->ib_htext,
				ibp->ib_resvd,
				l_end(ibn, rh->rsh_nib));
		ibp = (ICONBLK *) ((long) ibp + sizeof(ICONBLK) -2);
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : tefont															*/
/* Aufgabe	: Ermittelt den verwendeten Fonttyp 	(gem. Turbo-C <aes.h> ) 	*/
/* Ergebnis : Zeiger auf den String mit dem Font_typ							*/
/* Parameter: font				| Font als unsigned int 						*/
/*------------------------------------------------------------------------------*/

char *tefont(unsigned int font) 												/* -> Da gibt's nun wirklich nicht zu kommentieren			*/
{	static char ls[20];

	switch(font)
	{	case IBM		:	return ("IBM");
		case SMALL		:	return ("SMALL");
		default 		:	sprintf(ls,"%-#6x",font);
							return (ls);
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : tejust															*/
/* Aufgabe	: Ermittelt Ausrichtung des TEDINFO-Strings (gem. Turbo-C <aes.h> ) */
/* Ergebnis : Zeiger auf den String mit der Ausrichtung 						*/
/* Parameter: type				| Typ des Objektes als unsigned int 			*/
/*------------------------------------------------------------------------------*/

char *tejust(unsigned int justification)										/* -> Das hier bedarf ja wohl auch keiner ErlÑuterung			*/
{	switch(justification)
	{	case TE_LEFT	:	return ("TE_LEFT");
		case TE_RIGHT	:	return ("TE_RIGHT");
		case TE_CNTR	:	return ("TE_CNTR");
		default 		:	return ("NULL");
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : tedinfo_str														*/
/* Aufgabe	: Schreibt die TEDINFO-Strukturen in die Output-Datei				*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*------------------------------------------------------------------------------*/

void tedinfo_str(FILE *o_handle, RSHHDR *rh)
{	unsigned long tedn;
	TEDINFO *tedp;

	headcom(o_handle, "TEDINFO-structures", rh->rsh_nted,						/* -> Heading-commment schreiben					*/
					  "\nTEDINFO rs_tedinfo[] =\n{	");
	tedp = (TEDINFO *) ((long) rh + rh->rsh_tedinfo);								/* -> Adresse der TEDINFO-Struktur ermitteln		*/
	for(tedn = 0; tedn < rh->rsh_nted; tedn++)
	{	fprintf(o_handle,"TED%lu_s, TED%lu_t, TED%lu_v, "						/* -> Die komplette TEDINFO-Struktur in die Ausgabe-*/
						 "%-#6s, %-#6x, %-#6s, %-#6x, %-#6x,"					/*	  Datei schreiben								*/
						 "%-#6x, %-#6lx, %-#6x%s",
				tedn,
				tedn,
				tedn,
				tefont(tedp->te_font),
				tedp->te_junk1,
				tejust(tedp->te_just),
				tedp->te_color,
				tedp->te_junk2,
				tedp->te_thickness,
				tedlen(rh, tedp),
				tedp->te_tmplen,
				l_end(tedn, rh->rsh_nted));
		tedp++;
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : ob_type															*/
/* Aufgabe	: Ermittelt den Typ einer Objekt-Struktur (gem. Turbo-C <aes.h> )	*/
/* Ergebnis : Zeiger auf den String mit dem Objekt-Typ							*/
/* Parameter: type				| Typ des Objektes als unsigned int 			*/
/*------------------------------------------------------------------------------*/

char *obtype(unsigned int type) 												/* -> Das scheint mir fÅr einen weiteren Kommentar auch zu klar */
{	static char ls[20];

	switch(type)
	{	case G_BOX		:	return ("G_BOX");
		case G_TEXT 	:	return ("G_TEXT");
		case G_BOXTEXT	:	return ("G_BOXTEXT");
		case G_IMAGE	:	return ("G_IMAGE");
		case G_USERDEF	:	return ("G_USERDEF");
		case G_IBOX 	:	return ("G_IBOX");
		case G_BUTTON	:	return ("G_BUTTON");
		case G_BOXCHAR	:	return ("G_BOXCHAR");
		case G_STRING	:	return ("G_STRING");
		case G_FTEXT	:	return ("G_FTEXT");
		case G_FBOXTEXT :	return ("G_FBOXTEXT");
		case G_ICON 	:	return ("G_ICON");
		case G_TITLE	:	return ("G_TITLE");
		default 		:	sprintf(ls,"%-#8x",type);
							return (ls);
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : ob_flags															*/
/* Aufgabe	: Ermittelt die Flags einer Objekt-Struktur (gem. Turbo-C <aes.h> ) */
/* Ergebnis : Zeiger auf den String mit den Objekt-Flags						*/
/* Parameter: flags 			| Flags des Objektes als unsigned int			*/
/*------------------------------------------------------------------------------*/

char *obflags(unsigned int flags)												/* -> Was soll ich hierzu bloû sagen							*/
{	static char ls[20];

	switch(flags)
	{	case NONE		:	return ("NONE");
		case SELECTABLE :	return ("SELECTABLE");
		case DEFAULT	:	return ("DEFAULT");
		case EXIT		:	return ("EXIT");
		case EDITABLE	:	return ("EDITABLE");
		case RBUTTON	:	return ("RBUTTON");
		case LASTOB 	:	return ("LASTOB");
		case TOUCHEXIT	:	return ("TOUCHEXIT");
		case HIDETREE	:	return ("HIDETREE");
		case INDIRECT	:	return ("INDIRECT");
		default 		:	sprintf(ls,"%-#6x",flags);
							return (ls);
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : ob_state															*/
/* Aufgabe	: Ermittelt den Status einer Objekt-Struktur (gem. Turbo-C <aes.h> )*/
/* Ergebnis : Zeiger auf den String mit dem Objekt-Status						*/
/* Parameter: state 			| Status des Objektes als unsigned int			*/
/*------------------------------------------------------------------------------*/

char *obstate(unsigned int state)												/* -> Langsam gehen mir die dummen SprÅche aus	*/
{	static char ls[20];

	switch(state)
	{	case NORMAL 	:	return ("NORMAL");
		case SELECTED	:	return ("SELECTED");
		case CROSSED	:	return ("CROSSED");
		case CHECKED	:	return ("CHECKED");
		case DISABLED	:	return ("DISABLED");
		case OUTLINED	:	return ("OUTLINED");
		case SHADOWED	:	return ("SHADOWED");
		default 		:	sprintf(ls,"%-#6x",state);
							return(ls);
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : ob_spec															*/
/* Aufgabe	: Ermittelt den OBSPEC-Teil einer Objekt-Struktur in AbhÑngigkeit	*/
/*			  vom Objekt-Typ (gem. Turbo-C	<aes.h> )							*/
/* Ergebnis : Zeiger auf den String mit der OBSPEC-Struktur 					*/
/* Parameter: type				| Objekt-Typ									*/
/*			  spec				| Obspec-Struktur als long						*/
/*			  objn				| Wenn hier 0 ankommt mÅssen einige Variblen	*/
/*								| initialisiert werden							*/
/*------------------------------------------------------------------------------*/

char *obspec(unsigned int type, long spec, int objn)
{	static char ls[40];
	static unsigned long bbn, ibn, tedn, strn;

	if(objn == 0)
		bbn = ibn = tedn = strn = 0;
	switch(type)																/* -> Auch hier bleibt mir nichts zu sagen, ist ja bloû ein groûes "switch" */
	{	case G_IMAGE	: sprintf(ls,"(long) &rs_bitblk[%lu]",bbn++); break;
		case G_ICON 	: sprintf(ls,"(long) &rs_iconblk[%lu]",ibn++); break;
		case G_TEXT 	:
		case G_BOXTEXT	:
		case G_FTEXT	:
		case G_FBOXTEXT : sprintf(ls,"(long) &rs_tedinfo[%lu]",tedn++); break;
		case G_BUTTON	:
		case G_STRING	:
		case G_TITLE	: sprintf(ls,"(long) FSTR%lu",strn++); break;
		default 		: sprintf(ls,"%#22lXL",spec);
							break;
	}
	return(ls);
}

/*------------------------------------------------------------------------------*/
/* Funktion : object_str														*/
/* Aufgabe	: Schreibt die OBJECT-Strukturen in die Output-Datei				*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*------------------------------------------------------------------------------*/

void object_str(FILE *o_handle, RSHHDR *rh)
{	unsigned long objn;
	OBJECT *objp;

	headcom(o_handle, "OBJECT-tree", rh->rsh_nobs,								/* Heading-commment schreiben									   */
					  "\nOBJECT rs_object[] =\n{	");
	objp = (OBJECT *) ((long) rh + rh->rsh_object);
	for(objn = 0; objn < rh->rsh_nobs; objn++)
	{	fprintf(o_handle,"%#6d, %#6d, %#6d, %-10s, %-10s, %-8s, %-23s, %#6d, %#6d, %#6d, %#6d%s", /* -> Die komplette OBJECT-Struktur schreiben 		*/
					objp->ob_next,
					objp->ob_head,
					objp->ob_tail,
					obtype(objp->ob_type),
					obflags(objp->ob_flags),
					obstate(objp->ob_state),
					obspec(objp->ob_type, objp->ob_spec.index, objn),
					objp->ob_x,
					objp->ob_y,
					objp->ob_width,
					objp->ob_height,
					l_end(objn, rh->rsh_nobs));
		objp++;
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : wr_frimg															*/
/* Aufgabe	: Schreibt die freien Bilder										*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*------------------------------------------------------------------------------*/

void wr_frimg(FILE *o_handle, RSHHDR *rh)
{	BITBLK *fbbp;
	int *pdata,wb, hl;
	unsigned long fbbn;

	fbbp = (BITBLK *) ((long) rh + (long) rh->rsh_frimg);						/* -> Adresse des Baumindex berechnen		*/
	headcom(o_handle, "Free Images", rh->rsh_nimages, "");									/* Heading-commment schreiben				*/
	for(fbbn = 0; fbbn < rh->rsh_nimages; fbbn++)
	{	fprintf(o_handle,"\nint FRIMAGE%lu[]",fbbn);
		pdata = bblk_wb_hl(rh, fbbp, &wb, &hl); 								/*		-> Alle Werte berechnen um den Bitblock zu schreiben	*/
		wr_pblk(o_handle, pdata, wb, hl);										/*			Bitblock schreiben mit den berechneten Werten		*/
		fbbp++;
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : frimg_str 														*/
/* Aufgabe	: Schreibt die Bitblock-Strukturen der Free Images					*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*------------------------------------------------------------------------------*/

void frimg_str(FILE *o_handle, RSHHDR *rh)
{	BITBLK *fbbp;
	unsigned long fbbn;

	fbbp = (BITBLK *) ((long) rh + rh->rsh_frimg);								/* -> Adresse des Baumindex berechnen						*/
	headcom(o_handle, "BITBLOCK's of Free Images", rh->rsh_nimages, 				/* Heading-commment schreiben			  */
					  "\nBITBLK rs_frimg[] =\n{ ");
	for(fbbn = 0; fbbn < rh->rsh_nimages; fbbn++)
	{	fprintf(o_handle,"FREEIMAGE%lu, %-#6x, %-#6x, %-#6x, %-#6x, %-#6x%s",	/* -> Schreibe die komplette Datenstruktur in die	*/
						fbbn,													/*	  Ausgabe-Datei 								*/
						fbbp->bi_wb,
						fbbp->bi_hl,
						fbbp->bi_x,
						fbbp->bi_y,
						fbbp->bi_color,
						l_end(fbbn,rh->rsh_nimages));
		fbbp++;
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : wr_alert															*/
/* Aufgabe	: Schreibt das Feld mit den Adressen der einzelnen BÑume			*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*------------------------------------------------------------------------------*/

void wr_alert(FILE *o_handle, RSHHDR *rh)
{	char *strp;
	unsigned long strn;

	strp = (char *) ((long) rh + rh->rsh_string);								/* -> Adresse des Baumindex berechnen	  */
	headcom(o_handle, "Alert-Boxes", rh->rsh_nstring,								/* Heading-commment schreiben				*/
					  "\nchar *alert_msg[] =\n{ ");
	for(strn = 0; strn < rh->rsh_nstring; strn++)
	{	fprintf(o_handle,"\"%s\"%s",strp,
		l_end(strn, rh->rsh_nstring));
		strp = (char *)((long)strp + (strlen(strp) + 1));
	}
}

/*------------------------------------------------------------------------------*/
/* Funktion : wr_trindex														*/
/* Aufgabe	: Schreibt das Feld mit den Adressen der einzelnen BÑume			*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*------------------------------------------------------------------------------*/

void wr_trindex(FILE *o_handle, RSHHDR *rh)
{	OBJECT **trindex;
	unsigned long treen;

	trindex = (void *) ((long) rh + (long) rh->rsh_trindex);					/* -> Adresse des Baumindex berechnen	  */
	headcom(o_handle, "TREE-Index", rh->rsh_ntree,"\nOBJECT *TREE[] =\n{	"); /* Heading-commment schreiben				*/
	for(treen = 0; treen < rh->rsh_ntree; treen++)
	{	fprintf(o_handle,"(OBJECT *) &rs_object[%lu]%s",						/*		Berechne die Einsprungstelle in die OBJECT-Struktur-	*/
			((unsigned long)*trindex											/*		tabelle 												*/
				 - (unsigned long) rh->rsh_object)
				 / sizeof(OBJECT),
			l_end(treen, rh->rsh_ntree));
		trindex++;
	}

	fprintf(o_handle,"\n#define NUM_STRINGS %u",rh->rsh_nstring);
	fprintf(o_handle,"\n#define NUM_IMAGES %u",rh->rsh_nimages);
	fprintf(o_handle,"\n#define NUM_BB %u",rh->rsh_nbb);
	fprintf(o_handle,"\n#define NUM_IB %u",rh->rsh_nib);
	fprintf(o_handle,"\n#define NUM_TI %u",rh->rsh_nted);
	fprintf(o_handle,"\n#define NUM_OBS %u",rh->rsh_nobs);
	fprintf(o_handle,"\n#define NUM_TREE %u",rh->rsh_ntree);
}

/*------------------------------------------------------------------------------*/
/* Funktion : make_include														*/
/* Aufgabe	: Aufruf aller Teilebereiche der Konvertierung						*/
/* Ergebnis : ----- 															*/
/* Parameter: *o_handle 		| Zeiger auf den Output-Stream					*/
/*			  *rh				| Zeiger auf den Resource-header				*/
/*------------------------------------------------------------------------------*/

void make_include(FILE *o_handle, RSHHDR *rh)
{	wr_tedstrings(o_handle,rh);
	wr_icnstrings(o_handle,rh);
	wr_frstrings(o_handle,rh);
	wr_bitblks(o_handle,rh);
	wr_iconblocks(o_handle,rh);
	bitblk_str(o_handle,rh);
	iconblk_str(o_handle,rh);
	tedinfo_str(o_handle,rh);
	object_str(o_handle,rh);
	wr_frimg(o_handle,rh);
	frimg_str(o_handle,rh);
	wr_alert(o_handle,rh);
	wr_trindex(o_handle, rh);													/* -> Das Schreiben des Tree-Index lÑuft nicht nach Schema "f"		*/
}


/********************************************************************************/
/*	Das Hauptprogramm															*/
/********************************************************************************/

main()
{	apl_par rsctext;
	RSHHDR *rh;
	FILE *s_handle, *d_handle;
	GRECT main, info;
	char h_path[100];
	DTA os_dta;
	int exbtn1 = -1, exbtn2;

	rsctext.name[0] = '\0'; 															/* -> Erstinitialisierung der Variablen fÅr den Fileselektor*/
	strcpy(rsctext.path,"X:");															/*		Kein File vorselektiert 							*/
	rsctext.path[0] = Dgetdrv() + 'A';													/*		Aktuelles Laufwerk Åbernehmen						*/
	Dgetpath(h_path,0);
	strcat(rsctext.path,h_path);														/*		Aktuellen Pfad dazukopieren 						*/
	strcat(rsctext.path,"\\");															/*		Den Pfad mit einem Backslash abschlieûen			*/

	if(open_vwork(&rsctext))
	{	objc_init(rs_object,NUM_OBS);
		form_center(TREE[MAINDIAL],&main.g_x,&main.g_y,&main.g_w,&main.g_h);
		form_center(TREE[PROGINFO],&info.g_x,&info.g_y,&info.g_w,&info.g_h);
		form_dial(FMD_START,0,0,0,0,main.g_x,main.g_y,main.g_w,main.g_h);
		objc_draw(TREE[MAINDIAL],ROOT,MAX_DEPTH,0,0,639,399);
		while((exbtn1 != CANCEL))
		{	exbtn1 = form_do(TREE[MAINDIAL],RESOURCE);
			switch(exbtn1)
			{	case RSCSELEC : detect_file(rsctext.path,rsctext.name,"*.RSC",
											TREE[MAINDIAL][RESOURCE].ob_spec.tedinfo->te_ptext,
											"Choose Resource-File!");
								break;
				case ACSSELEC : detect_file(rsctext.path,rsctext.name,"*.RSH",
											TREE[MAINDIAL][CSOURCE].ob_spec.tedinfo->te_ptext,
											"Choose ANSI-C-File!");
								break;
				case SDIINFO :	form_dial(FMD_START,0,0,0,0,info.g_x,info.g_y,info.g_w,info.g_h);
								objc_draw(TREE[PROGINFO],ROOT,MAX_DEPTH,0,0,639,399);
								exbtn2 = form_do(TREE[PROGINFO],-1);
								form_dial(FMD_FINISH,0,0,0,0,info.g_x,info.g_y,info.g_w,info.g_h);
								objc_change(TREE[PROGINFO],exbtn2,0,0,0,639,399,NORMAL,0);
								break;
				case CONVERT :	graf_mouse(M_OFF,0);
								sscanf(TREE[MAINDIAL][WIDTH].ob_spec.tedinfo->te_ptext,"%3d",&width_blk);
								Fsetdta(&os_dta);
								if(Fsfirst(TREE[MAINDIAL][RESOURCE].ob_spec.tedinfo->te_ptext,0) == 0)
									if((rh = malloc(os_dta.d_length)) != NULL)
									{	if((s_handle = fopen(TREE[MAINDIAL][RESOURCE].ob_spec.tedinfo->te_ptext,"rb")) != NULL)
										{	if((d_handle = fopen(TREE[MAINDIAL][CSOURCE].ob_spec.tedinfo->te_ptext,"w")) != NULL)
												if(fread(rh, os_dta.d_length, 1, s_handle) == 1)
													{	make_include(d_handle, rh);
														fclose(d_handle);
													}
												else	alert(NABR_ERR);
											else	alert(FNO_ERR);
											fclose(s_handle);
										}
										else	alert(RSNO_ERR);
									}
									else	alert(TLM_ERR);
								else	alert(RNF_ERR);
								sprintf(TREE[MAINDIAL][MESSAGE].ob_spec.tedinfo->te_ptext,
										"%-40s",&"None!");
								graf_mouse(M_ON,0);
								break;
			}
			objc_change(TREE[MAINDIAL],exbtn1,0,0,0,639,399,NORMAL,1);
			if(exbtn1 != CANCEL)
				objc_draw(TREE[MAINDIAL],ROOT,MAX_DEPTH,0,0,639,399);
		}
		form_dial(FMD_FINISH,0,0,0,0,main.g_x,main.g_y,main.g_w,main.g_h);
	}
	close_vwork(&rsctext);
	return(0);
}

