#include <ec_gem.h>
#include "io.h"
#include "ioglobal.h"
#include "anhang.h"
#include "indexer.h"

/* Sortieren */

int dcmp(FLD *e2, FLD *e1)
{
	if(e1->fdate < e2->fdate) return(-1);
	if(e1->fdate == e2->fdate)
	{
		if(e1->ftime < e2->ftime) return(-1);
		return(e1->ftime-e2->ftime);
	}
	return(1);
}
int dmcmp(FLD *e1, FLD *e2)
{
	if(e1->fdate < e2->fdate) return(-1);
	if(e1->fdate == e2->fdate)
	{
		if(e1->ftime < e2->ftime) return(-1);
		return(e1->ftime-e2->ftime);
	}
	return(1);
}
int fcmp(FLD *e1, FLD *e2)
{
	char *s, *d;
	s=e1->from; d=e2->from;
	while(*s)
	{
		if(*s < *d) return(-1);
		if(*s++ > *d++) return(1);
	}
	return(0);
}
int fmcmp(FLD *e2, FLD *e1)
{
	char *s, *d;
	s=e1->from; d=e2->from;
	while(*s)
	{
		if(*s < *d) return(-1);
		if(*s++ > *d++) return(1);
	}
	return(0);
}
int scmp(FLD *e1, FLD *e2)
{
	char *s, *d;
	s=e1->subj; d=e2->subj;
	if(!strnicmp(s, "Re:", 3)) {s+=3; while(*s==' ')++s;}
	if(!strnicmp(d, "Re:", 3)) {d+=3; while(*d==' ')++d;}
	while(*s)
	{
		if(*s < *d) return(-1);
		if(*s++ > *d++) return(1);
	}
	return(0);
}
int smcmp(FLD *e2, FLD *e1)
{
	char *s, *d;
	s=e1->subj; d=e2->subj;
	if(!strnicmp(s, "Re:", 3)) {s+=3; while(*s==' ')++s;}
	if(!strnicmp(d, "Re:", 3)) {d+=3; while(*d==' ')++d;}
	while(*s)
	{
		if(*s < *d) return(-1);
		if(*s++ > *d++) return(1);
	}
	return(0);
}

void mem_list_sel(void)
{
	fld[ios.list_sel].ftype|=128;
}

void unmem_list_sel(void)
{
	long a=-1;
	while(++a < fld_c)
	{
		if(fld[a].ftype & 128)
		{
			fld[a].ftype&=(~128);
			ios.list_sel=a;
			return;
		}
	}
}

void reset_root_index(void)
{
	long	a=0;
	
	while(a < fld_c)
	{	fld[a].root_index=a; ++a;}
}

void sort_by_date(void)
{
	int of=0;

	if((fld==NULL)||(fld_c==0)) return;
	
	if(fld[0].ftype==FLD_BAK) of=1;	/* Erstes ist '..' und bleibt erstes */
	mem_list_sel();
	if((omenu[MVDATE].ob_state & CHECKED) && (odial[DATSORT].ob_spec.bitblk==getob(AUFSTEIGEND)->ob_spec.bitblk))
	{
		odial[DATSORT].ob_spec.bitblk=getob(ABSTEIGEND)->ob_spec.bitblk;
		qsort(&(fld[of]), fld_c-of, sizeof(FLD), dmcmp);
	}
	else
	{
		odial[DATSORT].ob_spec.bitblk=getob(AUFSTEIGEND)->ob_spec.bitblk;
		qsort(&(fld[of]), fld_c-of, sizeof(FLD), dcmp);
	}
	unmem_list_sel();
	clear_sort_obs();
	if(!fld_bak)	/* Hauptliste wurde umsortiert, Root-Index neu setzen */
		reset_root_index();
	odial[DATSORT].ob_flags&=(~HIDETREE); 
	menu_icheck(omenu, MVDATE, 1); 
}
void sort_by_from(void)
{
	int of=0;

	if((fld==NULL)||(fld_c==0)) return;
	
	if(fld[0].ftype==FLD_BAK) of=1;	/* Erstes ist '..' und bleibt erstes */
	mem_list_sel();
	if((omenu[MVFROM].ob_state & CHECKED) && (odial[ABSSORT].ob_spec.bitblk==getob(AUFSTEIGEND)->ob_spec.bitblk))
	{
		odial[ABSSORT].ob_spec.bitblk=getob(ABSTEIGEND)->ob_spec.bitblk;
		qsort(&(fld[of]), fld_c-of, sizeof(FLD), fmcmp);
	}
	else
	{
		odial[ABSSORT].ob_spec.bitblk=getob(AUFSTEIGEND)->ob_spec.bitblk;
		qsort(&(fld[of]), fld_c-of, sizeof(FLD), fcmp);
	}
	unmem_list_sel();
	clear_sort_obs();
	if(!fld_bak)	/* Hauptliste wurde umsortiert, Root-Index neu setzen */
		reset_root_index();
	odial[ABSSORT].ob_flags&=(~HIDETREE); 
	menu_icheck(omenu, MVFROM, 1);
}
void sort_by_subj(void)
{
	int of=0;
	
	if((fld==NULL)||(fld_c==0)) return;
	
	if(fld[0].ftype==FLD_BAK) of=1;	/* Erstes ist '..' und bleibt erstes */
	mem_list_sel();
	if((omenu[MVSUBJ].ob_state & CHECKED) && (odial[BTRSORT].ob_spec.bitblk==getob(AUFSTEIGEND)->ob_spec.bitblk))
	{
		odial[BTRSORT].ob_spec.bitblk=getob(ABSTEIGEND)->ob_spec.bitblk;
		qsort(&(fld[of]), fld_c-of, sizeof(FLD), smcmp);
	}
	else
	{
		odial[BTRSORT].ob_spec.bitblk=getob(AUFSTEIGEND)->ob_spec.bitblk;
		qsort(&(fld[of]), fld_c-of, sizeof(FLD), scmp);
	}
	unmem_list_sel();
	clear_sort_obs();
	if(!fld_bak)	/* Hauptliste wurde umsortiert, Root-Index neu setzen */
		reset_root_index();
	odial[BTRSORT].ob_flags&=(~HIDETREE); 
	menu_icheck(omenu, MVSUBJ, 1); 
}
void sort_by_sel(void)
{/* Nach aktueller Selektion sortieren. Dazu muž vorher die Richtung
		durch tauschen der Bitmap getoggelt werden, weil die Sortier-
		Funktion diese wieder toggelt */

	if((fld==NULL)||(fld_c==0)) return;
		
	if(omenu[MVSUBJ].ob_state & CHECKED)
	{
		if(odial[BTRSORT].ob_spec.bitblk==getob(AUFSTEIGEND)->ob_spec.bitblk)
			odial[BTRSORT].ob_spec.bitblk=getob(ABSTEIGEND)->ob_spec.bitblk;
		else
			odial[BTRSORT].ob_spec.bitblk=getob(AUFSTEIGEND)->ob_spec.bitblk;
		sort_by_subj();
	}
	else if(omenu[MVFROM].ob_state & CHECKED)
	{
		if(odial[ABSSORT].ob_spec.bitblk==getob(AUFSTEIGEND)->ob_spec.bitblk)
			odial[ABSSORT].ob_spec.bitblk=getob(ABSTEIGEND)->ob_spec.bitblk;
		else
			odial[ABSSORT].ob_spec.bitblk=getob(AUFSTEIGEND)->ob_spec.bitblk;
		sort_by_from();
	}
	else
	{
		if(odial[DATSORT].ob_spec.bitblk==getob(AUFSTEIGEND)->ob_spec.bitblk)
			odial[DATSORT].ob_spec.bitblk=getob(ABSTEIGEND)->ob_spec.bitblk;
		else
			odial[DATSORT].ob_spec.bitblk=getob(AUFSTEIGEND)->ob_spec.bitblk;
		sort_by_date();
	}
}

/* -------------------------------------- */

/* Ausblenden */

int view_vary(int mask)
{/* Return: 1=Ok, 2=Ok, aber aktuelle Nachricht hat gewechselt
		0=Fehler (leere Liste oder kein Speicher) */
	long	count, a;
	int		sel_set;
		
	if((fld==NULL)||(fld_c==0)) return(0);

	a=count=0;
	while(a < fld_c)
	{
		if(mask & (1<<fld[a].ftype))
			++count;
		++a;
	}
	fld_bak=fld;
	fld_c_bak=fld_c;

	if(count==0)
	{
		fld=NULL; fld_c=0; 
		if(fld_bak==NULL)	return(1);
		return(2); /* Mail muž geladen werden weil leer */
	}

	fld=malloc(count*sizeof(FLD));
	if(fld==NULL)	
	{	fld=fld_bak; fld_bak=NULL; unmem_list_sel(); form_alert(1, gettext(NOMEM)); return(0);}

	fld_c=count;

	a=count=sel_set=0;
	while(a < fld_c_bak)
	{
		if(mask & (1<<fld_bak[a].ftype))
		{
			fld[count]=fld_bak[a];
			fld[count].root_index=a;
			if(a==ios.list_sel) 
			{ 
				ios.list_sel=count; 
				sel_set=1;
			}
			++count;
		}
		++a;
	}

	if(sel_set)
		return(1);
	
	if(fld[0].ftype==FLD_BAK)
		ios.list_sel=1;
	else
		ios.list_sel=0;

	return(2);
}

int view_own(void)
{
	return(view_vary((1<<FLD_SNT)|(1<<FLD_SND)|(1<<FLD_BAK)));
}

int view_snd(void)
{
	return(view_vary((1<<FLD_SND)|(1<<FLD_BAK)));
}

int view_snt(void)
{
	return(view_vary((1<<FLD_SNT)|(1<<FLD_BAK)));
}

int view_rcv(void)
{
	return(view_vary((1<<FLD_NEW)|(1<<FLD_RED)|(1<<FLD_BAK)));
}

int view_red(void)
{
	return(view_vary((1<<FLD_RED)|(1<<FLD_BAK)));
}

int view_new(void)
{
	return(view_vary((1<<FLD_NEW)|(1<<FLD_BAK)));
}

void view_by_sel(void)
{
	int ob;
	
	ob=MVALLE;
	while(ob <= MVNEW)
	{
		if(omenu[ob].ob_state & CHECKED) break;
		++ob;
	}
	
	if(fld_bak)
	{
		if(fld) free(fld);
		fld=fld_bak; fld_bak=NULL;
		fld_c=fld_c_bak; fld_c_bak=0;
	}
	switch(ob)
	{
		case MVALLE: break;
		case MVSNDSNT: view_own(); break;
		case MVSND:	view_snd(); break;
		case MVSNT: view_snt(); break;
		case MVNEWRED: view_rcv(); break;
		case MVRED: view_red(); break;
		case MVNEW: view_new(); break;	
	}
}

/* -------------------------------------- */

/* Men und Buttons anpassen */

void fold_view(void)
{
	int a;
	
	odial[ABSWIDTH].ob_state |= DISABLED;
	odial[BTRWIDTH].ob_state |= DISABLED;
	odial[DATWIDTH].ob_state |= DISABLED;
	odial[ABSSORT].ob_flags |= HIDETREE;
	odial[BTRSORT].ob_flags |= HIDETREE;
	odial[DATSORT].ob_flags |= HIDETREE;
	odial[ORDNEN].ob_state |= DISABLED;
	odial[IORDNEN].ob_state |= DISABLED;
	odial[ANTWORT].ob_state |= DISABLED;
	odial[IANTWORT].ob_state |= DISABLED;
	odial[BEITRAG].ob_state |= DISABLED;
	odial[IBEITRAG].ob_state |= DISABLED;

	odial[ANHANG].ob_flags |= HIDETREE;
	odial[ANZANHANG].ob_flags |= HIDETREE;
	odial[PUT_ADR].ob_flags |= HIDETREE;
	odial[SWAP_IGN_CRLF].ob_flags |= HIDETREE;
	
	odial[ABSENDER].ob_spec.tedinfo->te_ptext="";
	odial[BETREFF].ob_spec.tedinfo->te_ptext="";

	if(anh_win.open) anhang_win();
	
	for(a=MVALLE; a <= MVDATE; ++a)
		menu_ienable(omenu, a, 0);
		
	for(a=MANSWER; a<=MSORT; ++a)
		menu_ienable(omenu, a, 0);

	menu_icheck(omenu, MDELAY, 0);
	menu_icheck(omenu, MINTEREST, 0);

	menu_ienable(omenu, MORDBYFIL, 0);
	menu_ienable(omenu, MINTEREST, 0);
	menu_ienable(omenu, MORGFILE, 0);
	menu_ienable(omenu, MORIGINAL, 0);

	if((fld==NULL)||(fld_c==0))
	{
		odial[LOESCHEN].ob_state |= DISABLED;
		odial[ILOESCHEN].ob_state |= DISABLED;
		menu_ienable(omenu, MKILL, 0);
	}
	else
	{
		odial[LOESCHEN].ob_state &= (~DISABLED);
		odial[ILOESCHEN].ob_state &= (~DISABLED);
		menu_ienable(omenu, MKILL, 1);
	}
}

void list_view(void)
{
	int a;
	
	odial[ABSWIDTH].ob_state &= (~DISABLED);
	odial[BTRWIDTH].ob_state &= (~DISABLED);
	odial[DATWIDTH].ob_state &= (~DISABLED);
	if(omenu[MVFROM].ob_state & CHECKED)
		odial[ABSSORT].ob_flags &= (~HIDETREE);
	else if(omenu[MVSUBJ].ob_state & CHECKED)
		odial[BTRSORT].ob_flags &= (~HIDETREE);
	else if(omenu[MVDATE].ob_state & CHECKED)
		odial[DATSORT].ob_flags &= (~HIDETREE);

	odial[ORDNEN].ob_state &= (~DISABLED);
	odial[IORDNEN].ob_state &= (~DISABLED);
	odial[ANTWORT].ob_state &= (~DISABLED);
	odial[IANTWORT].ob_state &= (~DISABLED);
	odial[BEITRAG].ob_state &= (~DISABLED);
	odial[IBEITRAG].ob_state &= (~DISABLED);

	for(a=MVALLE; a <= MVDATE; ++a)
	{
		if(omenu[a].ob_spec.free_string[0]==' ')
			menu_ienable(omenu, a, 1);
	}

	for(a=MANSWER; a<=MSORT; ++a)
	{
		if(omenu[a].ob_spec.free_string[0]==' ')
			menu_ienable(omenu, a, 1);
	}
	menu_ienable(omenu, MORDBYFIL, 1);
	if(db_mode)
		menu_ienable(omenu, MINTEREST, 1);
	else
		menu_ienable(omenu, MINTEREST, 0);
	menu_ienable(omenu, MORGFILE, 1);
	menu_ienable(omenu, MORIGINAL, 1);
}

void pm_list_view(void)
{
	menu_ienable(omenu, MCOMMENT, 0);
	odial[BEITRAG].ob_state |= DISABLED;
	odial[IBEITRAG].ob_state |= DISABLED;
}

void om_list_view(void)
{
	menu_ienable(omenu, MCOMMENT, 1);
	odial[BEITRAG].ob_state &= (~DISABLED);
	odial[IBEITRAG].ob_state &= (~DISABLED);
}

void snd_list_view(void)
{
	menu_ienable(omenu, MCOMMENT, 0);
	odial[BEITRAG].ob_state |= DISABLED;
	odial[IBEITRAG].ob_state |= DISABLED;
	menu_ienable(omenu, MANSWER, 0);
	odial[ANTWORT].ob_state |= DISABLED;
	odial[IANTWORT].ob_state |= DISABLED;
	odial[ORDNEN].ob_state &= (~DISABLED);
	odial[IORDNEN].ob_state &= (~DISABLED);
	odial[LOESCHEN].ob_state &= (~DISABLED);
	odial[ILOESCHEN].ob_state &= (~DISABLED);
	menu_ienable(omenu, MEDIT, 1);
	menu_ienable(omenu, MNOCHMAL, 1);
	menu_ienable(omenu, MJETZT, 1);
	menu_ienable(omenu, MWEITER, 1);
	menu_ienable(omenu, MSORT, 1);
	menu_ienable(omenu, MORDBYFIL, 1);
	menu_ienable(omenu, MKILL, 1);
	menu_ienable(omenu, MORGFILE, 1);
	menu_ienable(omenu, MORIGINAL, 1);
}

void rcv_list_view(void)
{
	menu_ienable(omenu, MCOMMENT, 1);
	odial[BEITRAG].ob_state &= (~DISABLED);
	odial[IBEITRAG].ob_state &= (~DISABLED);
	menu_ienable(omenu, MANSWER, 1);
	odial[ANTWORT].ob_state &= (~DISABLED);
	odial[IANTWORT].ob_state &= (~DISABLED);
	odial[ORDNEN].ob_state &= (~DISABLED);
	odial[IORDNEN].ob_state &= (~DISABLED);
	odial[LOESCHEN].ob_state &= (~DISABLED);
	odial[ILOESCHEN].ob_state &= (~DISABLED);
	menu_ienable(omenu, MEDIT, 0);
	menu_ienable(omenu, MNOCHMAL, 0);
	menu_ienable(omenu, MJETZT, 0);
	menu_ienable(omenu, MWEITER, 1);
	menu_ienable(omenu, MSORT, 1);
	menu_ienable(omenu, MDELAY, 0);
	menu_icheck(omenu, MDELAY, 0);
	menu_ienable(omenu, MORDBYFIL, 1);
	menu_ienable(omenu, MKILL, 1);
	menu_ienable(omenu, MORGFILE, 1);
	menu_ienable(omenu, MORIGINAL, 1);
}

void non_list_view(void)
{
	menu_ienable(omenu, MCOMMENT, 0);
	odial[BEITRAG].ob_state |= DISABLED;
	odial[IBEITRAG].ob_state |= DISABLED;
	menu_ienable(omenu, MANSWER, 0);
	odial[ANTWORT].ob_state |= DISABLED;
	odial[IANTWORT].ob_state |= DISABLED;
	odial[ORDNEN].ob_state |= DISABLED;
	odial[IORDNEN].ob_state |= DISABLED;
	odial[LOESCHEN].ob_state |= DISABLED;
	odial[ILOESCHEN].ob_state |= DISABLED;
	menu_ienable(omenu, MEDIT, 0);
	menu_ienable(omenu, MNOCHMAL, 0);
	menu_ienable(omenu, MJETZT, 0);
	menu_ienable(omenu, MWEITER, 0);
	menu_ienable(omenu, MSORT, 0);
	menu_ienable(omenu, MDELAY, 0);
	menu_icheck(omenu, MDELAY, 0);
	menu_ienable(omenu, MORDBYFIL, 0);
	menu_ienable(omenu, MKILL, 0);
	menu_ienable(omenu, MINTEREST, 0);
	menu_icheck(omenu, MINTEREST, 0);
	menu_ienable(omenu, MORGFILE, 0);
	menu_ienable(omenu, MORIGINAL, 0);
}

void act_mail_list_view(void)
{
	if(ios.list_sel < 0)
	{
		non_list_view();
		return;
	}
	if(db_mode)
	{
		menu_ienable(omenu, MINTEREST, 1);
		if(fld[ios.list_sel].fspec.finfo.flags & FF_ITR)
			menu_icheck(omenu, MINTEREST, 1);
		else
			menu_icheck(omenu, MINTEREST, 0);
	}
	if(fld[ios.list_sel].ftype <= FLD_SNT)
	{
		snd_list_view();
		if(fld[ios.list_sel].ftype == FLD_SND)
		{
			menu_icheck(omenu, MINTEREST, 0);
			menu_ienable(omenu, MNOCHMAL, 0);
			menu_ienable(omenu, MINTEREST, 0);
			menu_ienable(omenu, MDELAY, 1);
			if(fld[ios.list_sel].loc_flags & LF_DELAYED)
			{
				menu_ienable(omenu, MJETZT, 0);
				menu_icheck(omenu, MDELAY, 1);
			}
			else
				menu_icheck(omenu, MDELAY, 0);
		}
		else
		{
			menu_ienable(omenu, MJETZT, 0);
			menu_ienable(omenu, MEDIT, 0);
			menu_ienable(omenu, MDELAY, 0);
			menu_icheck(omenu, MDELAY, 0);
		}
		return;
	}
	rcv_list_view();
	switch(ios.list)
	{
		case 0: /* PM */
		case 2:	/* ORD */
		case 3: /* DEL */
			pm_list_view();
		break;
		case 1:	/* OM */
			om_list_view();
		break;
	}
	return;
}