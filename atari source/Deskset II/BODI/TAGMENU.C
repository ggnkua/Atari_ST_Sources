/*****************************************************************************/
/* HISTORY:								     */
/*									     */
/* 11/10/89  -  addtaglist()- Added cpabt = 0;				     */
/*		              Problems resulted in that the routine doesn't  */
/*			      clear the flag if no errors occur, thereby     */
/*			      leaving the old state in the flag.	     */
/*									     */
/* 11/13/89  -  out_tag() - Changes made according to G.O. Graphics to fix   */
/*			    the setsize but with tags.			     */
/*****************************************************************************/
#include	<gemdefs.h>
#include	<obdefs.h>
#include	"deskset2.h"
#include	"tags.h"
#include	"comp.h"

#define		NUMGLOBALS	16	/* number of Global Tags	*/
#define		BLTAG		17	/* beginning Local Tag number	*/

extern	unsigned	formval, last_tag;
extern	char		*malloc();
extern	char		*get_edit();
extern	int		Pval;			/* parmcheck() result	*/
extern	char		fofg, cpjm;		/* Bend local flags...	*/
extern	char		TWaltered;		/* TWindow altered flag	*/

struct	dll_type {
	struct dll_type	*fptr;			/* forward pointer	*/
	struct dll_type *bptr;			/* backward pointer	*/
};					/* struct size = 8 bytes	*/
struct	tagll {				/* TAGs  Linked List structure	*/
	struct dll_type link;		/* forward/backward linkages	*/
	struct txtattr	attr;		/* text ATTRibutes block	*/
} *strtlist = (struct tagll *)0L;	/* pointer to start Tag list	*/

static	OBJECT	*tagobj;		/* local tag dialog box object	*/
static	char	gltagnames[16][14];	/* Global Tag name array	*/
static	char	Gtagpvalid[] = "XXXXXXXXXXXXX";
static	char	Ltagpvalid[] = "999";

do_tag(tagnum,select)
int	tagnum, select;
{
	int	x, y, w, h;
	int	object, objdep, cont, otagn;

	if (select && tagnum == 1) {		/* Global tag selection	*/
		if (G_tag(&tagnum))		/* to Global tag dialog	*/
			select = 2;		/* stay for modificatN	*/
		else	return(tagnum);		/* or just exit...	*/
	}
	rsrc_gaddr(0,TAGMENU,&tagobj);
	set_tagvals(otagn = tagnum,select);
	form_center(tagobj,&x,&y,&w,&h);
	form_dial(0,0,0,36,36,x,y,w,h);
	form_dial(1,0,0,36,36,x,y,w,h);
	cont	= 1;
	object	= 0, objdep = MAX_DEPTH;
	do {
	  objc_draw(tagobj,object,objdep,x,y,w,h);
	  object = form_do(tagobj,formval) & 0x7fff;
	  switch(object) {
	  case MTAG: case TAGLEFT: case TAGRIGHT:
		objdep	= 0;
		if (select != 1) break;
		if (object == MTAG) {
			tagnum = get_int(tagobj,TAGNUM) + NUMGLOBALS;
			if (tagnum == otagn)
				break;
nwtag:			if (tagnum < BLTAG || tagnum > NUMTAG)
				tagnum = BLTAG;
		}
		else
		if (object == TAGLEFT) {
			if (--tagnum < BLTAG)
				tagnum = NUMTAG;
		}
		else {
			if (++tagnum > NUMTAG)
				tagnum = BLTAG;
		}
		set_tagvals(otagn = tagnum,select);
		object = 0, objdep = MAX_DEPTH;
		break;
	  case TAGOK:
		tagobj[TAGOK].ob_state = NORMAL;
		if (select == 1) {
			tagnum = get_int(tagobj,TAGNUM) + NUMGLOBALS;
			if (tagnum != otagn)
				goto nwtag;
		}
		if (!chk_tagvals(tagnum-1))
			cont	= 0;
		else	objdep	= 0;
		break;
	  case TAGCAN:
		tagobj[TAGCAN].ob_state = NORMAL;
		tagnum = cont = 0;
		break;
	  default:
		loc_pos(&object,&objdep,select);
		break;
	  }
	} while (cont);
	form_dial(2,0,0,36,36,x,y,w,h);
	form_dial(3,0,0,36,36,x,y,w,h);
	return(tagnum);
}

static	loc_pos(object,objdep,select)
int	*object, *objdep, select;
{
	int	obj, objst, obj2, obj3;

	*objdep	= 0;				/* redraw single object	*/
	obj	= *object;
	objst	= tagobj[obj].ob_state =	/* toggle object state	*/
		(tst_CHK(obj)) ? NORMAL:CHECKED;
	switch (obj) {
	case PSCMD:
		if (objst)
			set_edit(formval = PTSIZE);
		else {
			dis_edit(PTSIZE);
			goto usedef;
		}
		break;
	case SSCMD:
		if (objst)
			set_edit(formval = SETSZ);
		else {
			dis_edit(SETSZ);
			goto usedef;
		}
		break;
	case FTCMD:
		if (objst)
			set_edit(formval = FTNUM);
		else {
			dis_edit(FTNUM);
			goto usedef;
		}
		break;
	case ALDCMD:
		if (objst) {
			set_edit(formval = ADVLD);
			if (tst_CHK(RLDCMD)) {
				*object = ARLDBOX;
				obj2	= RLDCMD;
				obj3	= REVLD;
	force:			tagobj[obj2].ob_state = NORMAL;
				dis_edit(obj3);
				*objdep	= 1;
			}
		}
		else {
			dis_edit(ADVLD);
			goto usedef;
		}
		break;
	case RLDCMD:
		if (objst) {
			set_edit(formval = REVLD);
			if (tst_CHK(ALDCMD)) {
				*object = ARLDBOX;
				obj2	= ALDCMD;
				obj3	= ADVLD;
				goto force;
			}
		}
		else {
			dis_edit(REVLD);
			goto usedef;
		}
		break;
	case MVRCMD:
		if (objst) {
			set_edit(formval = HORMVR);
			if (tst_CHK(MVLCMD)) {
				*object = RLMVBOX;
				obj2	= MVLCMD;
				obj3	= HORMVL;
				goto force;
			}
		}
		else {
			dis_edit(HORMVR);
			goto usedef;
		}
		break;
	case MVLCMD:
		if (objst) {
			set_edit(formval = HORMVL);
			if (tst_CHK(MVRCMD)) {
				*object = RLMVBOX;
				obj2	= MVRCMD;
				obj3	= HORMVR;
				goto force;
			}
		}
		else {
			dis_edit(HORMVL);
			goto usedef;
		}
		break;
	case AVCCMD:
		*object = AVCCBOX;
		*objdep	= 2;
		if (objst) {
			set_edit(formval = AVCC);
			set_state(AVCON,0);
		}
		else {
			dis_edit(AVCC);
			dis_state(AVCON,2);
			goto usedef;
		}
		break;
	case MCCMD:
		*object = MCCBOX;
		*objdep	= 2;
		if (objst) {
			set_edit(formval = MCC);
			set_state(MCON,0);
		}
		else {
			dis_edit(MCC);
			dis_state(MCON,2);
			goto usedef;
		}
		break;
	case KNCMD:
		*object = KRNBOX;
		*objdep	= 2;
		if (objst)
			set_state(KERNON,0);
		else {
			dis_state(KERNON,2);
			goto usedef;
		}
		break;
	case REVCMD:
		*object = REVBOX;
		*objdep	= 2;
		if (objst)
			set_state(RVON,0);
		else {
			dis_state(RVON,2);
			goto usedef;
		}
		break;
	case JUSTCMD:
		*object = JSTBOX;
		*objdep	= 2;
		if (objst)
			set_jstbx(JUSTMD);
		else {
			dis_state(JUSTMD,4);
			goto usedef;
		}
		break;
	case LSPCMD:
		*object = LSPBOX;
		*objdep	= 2;
		if (objst) {
			set_edit(formval = POSLSPC);
			set_edit(NEGLSP);
			set_state(LSPMDON,0);
		}
		else {
			dis_edit(POSLSPC);
			dis_edit(NEGLSP);
			dis_state(LSPMDON,2);
			goto usedef;
		}
		break;
	case SPCCMD:
		if (objst) {
			set_edit(formval = MINSP);
			set_edit(PRFSP);
			set_edit(MAXSP);
		}
		else {
			dis_edit(MINSP);
			dis_edit(PRFSP);
			dis_edit(MAXSP);
			goto usedef;
		}
		break;
	case INCHCMD:
		if (objst)
			set_edit(formval = INSCH);
		else {
			dis_edit(INSCH);
			goto usedef;
		}
		break;
	case HYCMD:
		*object = HYPBOX;
		*objdep	= 2;
		if (objst) {
			set_edit(formval = SUCHYH);
			set_edit(BEFHYP);
			set_edit(AFTHYP);
			set_state(HYON,0);
		}
		else {
			dis_edit(SUCHYH);
			dis_edit(BEFHYP);
			dis_edit(AFTHYP);
			dis_state(HYON,2);
			goto usedef;
		}
		break;
	usedef:
	default:			/* Flash Only and Flash Off	*/
		formval = select ? TAGNUM:0;
		break;
	}
}

static	set_tagvals(num,select)
int	num, select;
{
	unsigned char	**str, fg;

	--num;					/* tag start from 0	*/
	if (num < NUMGLOBALS) {			/* for Global tags...	*/
		*(((TEDINFO *)tagobj[TAGNUM].ob_spec)->te_ptmplt + 3) = '_';
		((TEDINFO *)tagobj[TAGNUM].ob_spec)->te_pvalid = Gtagpvalid;
		set_tedit(tagobj,TAGNUM,&gltagnames[num][0]);
	}
	else {					/* for Local tags...	*/
		*(((TEDINFO *)tagobj[TAGNUM].ob_spec)->te_ptmplt + 3) = 0;
		((TEDINFO *)tagobj[TAGNUM].ob_spec)->te_pvalid = Ltagpvalid;
		set_int(tagobj,TAGNUM,(num - NUMGLOBALS) + 1);
	}
	if (!select) {				/* no selection of tag	*/
		set_hidden(TAGLEFT);
		set_hidden(TAGRIGHT);
		dis_edit(TAGNUM);
		formval = 0;
	}
	else
	if (select == 1) {			/* selecting Local tag	*/
		dis_hidden(TAGLEFT);
		dis_hidden(TAGRIGHT);
		set_edit(formval = TAGNUM);
	}
	else {					/* selecting Global tag	*/
		set_hidden(TAGLEFT);
		set_hidden(TAGRIGHT);
		set_edit(formval = TAGNUM);
	}
	if (Tagarray[num].ptsz) {
		tagobj[PSCMD].ob_state = CHECKED;
		to_mu_pt12(tagobj,Tagarray[num].ptsz,PTSIZE);
	}
	else {
		tagobj[PSCMD].ob_state = NORMAL;
		null_line(PTSIZE);
	}
	if (Tagarray[num].ssiz) {
		tagobj[SSCMD].ob_state = CHECKED;
		to_mu_pt12(tagobj,Tagarray[num].ssiz,SETSZ);
	}
	else {
		tagobj[SSCMD].ob_state = NORMAL;
		null_line(SETSZ);
	}
	if (Tagarray[num].font) {
		tagobj[FTCMD].ob_state = CHECKED;
		to_set_int(Tagarray[num].font,FTNUM);
	}
	else {
		tagobj[FTCMD].ob_state = NORMAL;
		null_line(FTNUM);
	}
	if (Tagarray[num].avld) {
		tagobj[ALDCMD].ob_state = CHECKED;
		to_mu_vlrv(tagobj,(unsigned)Tagarray[num].avld,ADVLD);
	}
	else {
		tagobj[ALDCMD].ob_state = NORMAL;
		null_line(ADVLD);
	}
	if (Tagarray[num].rvld) {
		tagobj[RLDCMD].ob_state = CHECKED;
		to_mu_vlrv(tagobj,(unsigned)Tagarray[num].rvld,REVLD);
	}
	else {
		tagobj[RLDCMD].ob_state = NORMAL;
		null_line(REVLD);
	}
	if (Tagarray[num].hmvr) {
		tagobj[MVRCMD].ob_state = CHECKED;
		to_mu_hlrv(tagobj,Tagarray[num].hmvr,HORMVR);
	}
	else {
		tagobj[MVRCMD].ob_state = NORMAL;
		null_line(HORMVR);
	}
	if (Tagarray[num].hmvl) {
		tagobj[MVLCMD].ob_state = CHECKED;
		to_mu_hlrv(tagobj,Tagarray[num].hmvl,HORMVL);
	}
	else {
		tagobj[MVLCMD].ob_state = NORMAL;
		null_line(HORMVL);	
	}
	if (Tagarray[num].acfg) {
		tagobj[AVCCMD].ob_state = CHECKED;
		fg = Tagarray[num].acomp & 0x0f;
		to_set_int(!fg ? 1:fg,AVCC);
		fg = Tagarray[num].acomp & 0x80;
		set_state(AVCON,fg);
	}
	else {
		tagobj[AVCCMD].ob_state = NORMAL;
		null_line(AVCC);
		dis_state(AVCON,2);
	}
	if (Tagarray[num].mcfg) {
		tagobj[MCCMD].ob_state = CHECKED;
		fg = Tagarray[num].mcomp;
		to_set_int((unsigned)fg / 2,MCC);
		set_state(MCON,fg);
	}
	else {
		tagobj[MCCMD].ob_state = NORMAL;
		null_line(MCC);
		dis_state(MCON,2);
	}
	if (Tagarray[num].krfg) {
		tagobj[KNCMD].ob_state = CHECKED;
		fg = Tagarray[num].kernmd;
		set_state(KERNON,fg);
	}
	else {
		tagobj[KNCMD].ob_state = NORMAL;
		dis_state(KERNON,2);
	}
	if (Tagarray[num].rvfg) {
		tagobj[REVCMD].ob_state = CHECKED;
		fg = Tagarray[num].rvomd;
		set_state(RVON,fg);
	}
	else {
		tagobj[REVCMD].ob_state = NORMAL;
		dis_state(RVON,2);
	}
	if (Tagarray[num].jmfg) {
		tagobj[JUSTCMD].ob_state = CHECKED;
		fg = Tagarray[num].jstmd + JUSTMD;
		set_jstbx(fg);
	}
	else {
		tagobj[JUSTCMD].ob_state = NORMAL;
		dis_state(JUSTMD,4);
	}
	tagobj[FOFG].ob_state	= (Tagarray[num].fonmd) ? CHECKED:NORMAL;
	tagobj[FOFFFG].ob_state = (Tagarray[num].fofmd) ? CHECKED:NORMAL;
	if (Tagarray[num].icfg) {
		tagobj[INCHCMD].ob_state = CHECKED;
		str	= (char **)tagobj[INSCH].ob_spec;
		if (Tagarray[num].icfg & 0x80)	/* flash positN mode	*/
			utoa(*str,Tagarray[num].iCHR,100);
		else {				/* Ascii char. mode	*/
			*(*str)   = Tagarray[num].iCHR;
			*(*str+1) = 0;
		}
		set_edit(INSCH);
	}
	else {
		tagobj[INCHCMD].ob_state = NORMAL;
		null_line(INSCH);
	}
	if (Tagarray[num].ltfg) {
		tagobj[LSPCMD].ob_state = CHECKED;
		fg = Tagarray[num].ltsmd;
		to_set_int(Tagarray[num].plts,POSLSPC);
		to_set_int(Tagarray[num].nlts,NEGLSP);
		set_state(LSPMDON,fg);
	}
	else {
		tagobj[LSPCMD].ob_state = NORMAL;
		null_line(POSLSPC);
		null_line(NEGLSP);
		dis_state(LSPMDON,2);
	}
	if (Tagarray[num].hyfg) {
		tagobj[HYCMD].ob_state = CHECKED;
		fg = Tagarray[num].hypmd;
		to_set_int(Tagarray[num].nsuchyp,SUCHYH);
		to_set_int(Tagarray[num].nbefhyp,BEFHYP);
		to_set_int(Tagarray[num].nafthyp,AFTHYP);
		set_state(HYON,fg);
	}
	else {
		tagobj[HYCMD].ob_state = NORMAL;
		null_line(SUCHYH);
		null_line(BEFHYP);
		null_line(AFTHYP);
		dis_state(HYON,2);
	}
	if (Tagarray[num].spfg) {
		tagobj[SPCCMD].ob_state = CHECKED;
		to_set_int(Tagarray[num].minsp,MINSP);
		to_set_int(Tagarray[num].prfsp,PRFSP);
		to_set_int(Tagarray[num].maxsp,MAXSP);
	}
	else {
		tagobj[SPCCMD].ob_state = NORMAL;
		null_line(MINSP);
		null_line(PRFSP);
		null_line(MAXSP);
	}
}

static	chk_tagvals(num)
int	num;
{
	char	**str;
	int	i, j, k;
	struct	STYtag tmptag; 
	
	Tagarray[num].used = 0;
	f_move(&Tagarray[num],&tmptag,sizeof(struct STYtag));
	memset(&Tagarray[num],0,sizeof(struct STYtag));
	if (tst_CHK(PSCMD)) {
		if (tagcheck(PTSIZE,2))
			return(1);
		Tagarray[num].ptsz = Pval;
	}
	if (tst_CHK(SSCMD)) {
		if (tagcheck(SETSZ,2))
			return(1);
		Tagarray[num].ssiz = Pval;
	}
	if (tst_CHK(FTCMD))
		Tagarray[num].font = get_int(tagobj,FTNUM);
	if (tst_CHK(ALDCMD)) {
		if (tagcheck(ADVLD,4))
			return(1);
		Tagarray[num].avld = Pval;
	}
	if (tst_CHK(RLDCMD)) {
		if (tagcheck(REVLD,4))
			return(1);
		Tagarray[num].rvld = Pval;
	}
	if (tst_CHK(MVRCMD)) {
		if (tagcheck(HORMVR,1))
			return(1);
		Tagarray[num].hmvr = Pval;
	}
	if (tst_CHK(MVLCMD)) {
		if (tagcheck(HORMVL,1))
			return(1);
		Tagarray[num].hmvl = Pval;
	}
	if (tst_CHK(AVCCMD)) {
		formval = AVCC;
		i = get_int(tagobj,AVCC);
		if (!i || i > 3)
			goto err;
		if (tst_SEL(AVCON))
			Tagarray[num].acomp = i | 0x80;
		Tagarray[num].acfg = 1;
	}
	if (tst_CHK(MCCMD)) {
		if (tst_SEL(MCON))
		  Tagarray[num].mcomp = get_int(tagobj,MCC) * 2;
		Tagarray[num].mcfg = 1;
	}
	if (tst_CHK(KNCMD)) {
		Tagarray[num].kernmd = tst_SEL(KERNON);
		Tagarray[num].krfg = 1;
	}
	if (tst_CHK(REVCMD)) {
		Tagarray[num].rvomd = tst_SEL(RVON);
		Tagarray[num].rvfg = 1;
	}
	if (tst_CHK(JUSTCMD)) {
		if (tst_SEL(LEFTMD))
			Tagarray[num].jstmd = AL;
		else
		if (tst_SEL(RIGHTMD))
			Tagarray[num].jstmd = AR;
		else
		if (tst_SEL(CENTERMD))
			Tagarray[num].jstmd = AC;
		else	Tagarray[num].jstmd = AJ;
		Tagarray[num].jmfg = 1;
	}
	Tagarray[num].fonmd = tst_CHK(FOFG);
	Tagarray[num].fofmd = tst_CHK(FOFFFG);
	if (tst_CHK(INCHCMD)) {
		str = (char **)tagobj[INSCH].ob_spec;
		formval = INSCH;
		if (strlen(*str) == 1) {	/* Ascii char. mode	*/
			if (	*(*str) != ' '	&&
				getfp(*(*str)) == 0xff	)
				goto err;
			Tagarray[num].iCHR = *(*str);
			Tagarray[num].icfg = 1;
		}
		else {				/* flash positN mode	*/
			if (	!cdigit(*(*str))		||
				!(i = get_int(tagobj,INSCH))	||
				i > 121   )
				goto err;
			Tagarray[num].iCHR = (char)i;
			Tagarray[num].icfg = 0x81;
		}
	}		
	if (tst_CHK(LSPCMD)) {
		formval = NEGLSP;
		i = get_int(tagobj,NEGLSP);
		if (i > 6) {
err:			do_alert(BADINP);
			return(1);
		}
		Tagarray[num].ltsmd= tst_SEL(LSPMDON);
		Tagarray[num].plts = get_int(tagobj,POSLSPC);
		Tagarray[num].nlts = i;
		Tagarray[num].ltfg = 1;
	}
	if (tst_CHK(HYCMD)) {
		i = get_int(tagobj,SUCHYH);
		j = get_int(tagobj,BEFHYP);
		k = get_int(tagobj,AFTHYP);
		if ((Tagarray[num].hypmd = tst_SEL(HYON)) &&
		    ck_hyerr(i,j,k,SUCHYH,BEFHYP,AFTHYP))
			return(1);
		Tagarray[num].nsuchyp = i;
		Tagarray[num].nbefhyp = j;
		Tagarray[num].nafthyp = k;
		Tagarray[num].hyfg = 1;
	}
	if (tst_CHK(SPCCMD)) {
		i = get_int(tagobj,MINSP);
		j = get_int(tagobj,PRFSP);
		k = get_int(tagobj,MAXSP);
		if (ck_sperr(i,j,k,MINSP,PRFSP,MAXSP))
			return(1);
		Tagarray[num].minsp = i;
		Tagarray[num].prfsp = j;
		Tagarray[num].maxsp = k;
		Tagarray[num].spfg = 1;
	}
	if (memcmp(&Tagarray[num],&tmptag,sizeof(struct STYtag)))
		TWaltered = 1;
	memset(&tmptag,0,sizeof(struct STYtag));
	if (memcmp(&Tagarray[num],&tmptag,sizeof(struct STYtag)))
		Tagarray[num].used = 1;
	if (num < NUMGLOBALS) {			/* for Global tags...	*/
	  if (Tagarray[num].used)
		strcpy(&gltagnames[num][0],get_edit(tagobj,TAGNUM));
	  else	gltagnames[num][0] = 0;
	}
	return(0);
}

static	tst_CHK(obj)
int	obj;
{
	return(tagobj[obj].ob_state & CHECKED);
}

static	tst_SEL(obj)
int	obj;
{
	return(tagobj[obj].ob_state & SELECTED);
}

static	set_edit(obj)
int	obj;
{
	tagobj[obj].ob_flags |= EDITABLE;
}

static	dis_edit(obj)
int	obj;
{
	tagobj[obj].ob_flags &= ~EDITABLE;
}

static	set_state(obj,fg)
int	obj, fg;
{
	tagobj[fg ? obj:obj+1].ob_state = SELECTED;
	tagobj[fg ? obj+1:obj].ob_state = NORMAL;
}

static	dis_state(obj,ct)
int	obj, ct;
{
	int	i;
	for (i = 0;i < ct;++i,++obj)
		tagobj[obj].ob_state = DISABLED;
}

static	set_jstbx(fg)
int	fg;
{
	int	i  = JUSTMD;
	while (i < fg)
		tagobj[i++].ob_state = NORMAL;
	tagobj[i++].ob_state = SELECTED;
	while (i <= CENTERMD)
		tagobj[i++].ob_state = NORMAL;
}

static	tagcheck(obj,mode)
int	obj, mode;
{
	return(parmcheck(tagobj,obj,mode,0));
}

static	null_line(obj)
int	obj;
{
	char	**str;

	dis_edit(obj);
	str	= (char **)tagobj[obj].ob_spec;
	*(*str)	= 0;
}

static	to_set_int(val,obj)
int	val, obj;
{
	set_edit(obj);
	set_int(tagobj,obj,val);
}

to_mu_pt12(dialog,val,obj)
OBJECT	*dialog;
int	val, obj;
{
	char	**str;

	dialog[obj].ob_flags |= EDITABLE;
	str = (char **)dialog[obj].ob_spec;
	mu_pt12(val,*str);
}

to_mu_vlrv(dialog,val,obj)
OBJECT	*dialog;
int	val, obj;
{
	char	**str;

	dialog[obj].ob_flags |= EDITABLE;
	str = (char **)dialog[obj].ob_spec;
	mu_vlrv(val,*str);
}

to_mu_hlrv(dialog,val,obj)
OBJECT	*dialog;
int	val, obj;
{
	char	**str;

	dialog[obj].ob_flags |= EDITABLE;
	str = (char **)dialog[obj].ob_spec;
	mu_hlrv(val,*str);
}

static	TmoveY(cmd,val)
int		cmd;
unsigned long	val;
{
	in_cmmd(cmd,val <= cp.lnsp ? val:cp.lnsp);
}

in_tag(num,front,forward)
int	num, front, forward;
{
	struct tagll	*tagptr;

	if (addtaglist())
		return;
	tagptr = (struct tagll *)strtlist->link.bptr;
	f_move(&cp,&tagptr->attr,sizeof(cp));	/* save current cp	*/
	if (Tagarray[num].ptsz || Tagarray[num].ssiz) {
		if (Tagarray[num].ptsz) {
			cp.ptsz = Tagarray[num].ptsz;
			if (!front) in_cmmd(1,(long)cp.ptsz);
		}
		if (Tagarray[num].ssiz) {
			cp.ssiz = Tagarray[num].ssiz;
			if (!front) in_cmmd(2,(long)cp.ssiz);
		}
		else	cp.ssiz = cp.ptsz;
		if (cp.ssiz < smsz || !cct)
			smsz = cp.ssiz;
		ldacmp();
	}
	if (Tagarray[num].font) {
		if (ckfont(Tagarray[num].font)) {
		  cp.font = Tagarray[num].font;
		  if (!front) {
			loadrval();
			in_cmmd(3,(long)cp.font);
		  }
		}
	}
	if (!front && Tagarray[num].avld)
		TmoveY(4,Tagarray[num].avld);
	if (!front && Tagarray[num].rvld)
		TmoveY(5,Tagarray[num].rvld);
/*?*/	if (forward && Tagarray[num].hmvr) {
		if (!front) {
			if (Tagarray[num].hmvr+clen <= cp.llen) {
				in_cmmd(6,(long)Tagarray[num].hmvr);
				clen += Tagarray[num].hmvr;
			}
		}
		else {
			if (Tagarray[num].hmvr <= clen)
				clen -= Tagarray[num].hmvr;
		}
	}
/*?*/	if (forward && Tagarray[num].hmvl) {
		if (!front) {
			if (Tagarray[num].hmvl <= clen) {
				in_cmmd(7,(long)Tagarray[num].hmvl);
				clen -= Tagarray[num].hmvl;
			}
		}
		else {
			if (Tagarray[num].hmvl <= cp.llen-clen)
				clen += Tagarray[num].hmvl;
		}
	}
	if (Tagarray[num].acfg) {
		if (Tagarray[num].acomp & 0x80)
			cp.acomp = Tagarray[num].acomp & 0x0f;
		else	cp.acomp = 0;
		ldacmp();
	}
	if (Tagarray[num].mcfg)
		cp.mcomp = Tagarray[num].mcomp;
	if (Tagarray[num].krfg)
		cp.kernmd = Tagarray[num].kernmd;
	if (Tagarray[num].rvfg) {
		cp.rvomd = Tagarray[num].rvomd;
		if (!front)
			in_cmmd(11,(long)cp.rvomd);
	}
	if (Tagarray[num].jmfg) {
		cp.jstmd = Tagarray[num].jstmd;
		if (!front) cpjm = cp.jstmd;
	}
	if (forward && Tagarray[num].fonmd)
		fofg = 1;
	if (!front && Tagarray[num].fofmd)
		in_cmmd(14,1L);
	if (Tagarray[num].pifg)
		cp.psimd = Tagarray[num].psimd;
	if (!front && Tagarray[num].icfg)
		IC_cmd(Tagarray[num].iCHR,Tagarray[num].icfg & 0x80);
	if (Tagarray[num].ltfg) {
		cp.ltsmd= Tagarray[num].ltsmd;
		cp.plts = Tagarray[num].plts;
		cp.nlts = Tagarray[num].nlts;
	}
	if (Tagarray[num].hyfg) {
		cp.hypmd   = Tagarray[num].hypmd;
		cp.nsuchyp = Tagarray[num].nsuchyp;
		cp.nbefhyp = Tagarray[num].nbefhyp;
		cp.nafthyp = Tagarray[num].nafthyp;
	}
	if (Tagarray[num].spfg) {
		cp.minsp = Tagarray[num].minsp;
		cp.prfsp = Tagarray[num].prfsp;
		cp.maxsp = Tagarray[num].maxsp;
		spbval	 = cp.minsp + cp.prfsp;	/* set space value	*/
	}
}

out_tag(num,front,forward)
int	num, front, forward;
{
	struct txtattr	*attr;
	struct tagll	*tagptr;

	if (!strtlist)
		return;
	tagptr	= (struct tagll *)strtlist->link.bptr;
	attr	= &tagptr->attr;
	if (Tagarray[num].ptsz || Tagarray[num].ssiz) {
		if (Tagarray[num].ptsz) {
			cp.ptsz = attr->ptsz;
			if (!front) in_cmmd(1,(long)cp.ptsz);
		}
/*									Changes made CJG 11/13/89
		if (!front && cp.ssiz != attr->ssiz)			according to G.O. Graphics
			in_cmmd(2,(long)attr->ssiz);			This is the old code
		cp.ssiz = attr->ssiz;
		if (cp.ssiz < smsz || !cct)
*/
		if( Tagarray[num].ssiz || cp.ssiz != attr->ssiz)	/* and this is the new code */
		{
		   cp.ssiz = attr->ssiz;
		   if (!front)	in_cmmd(2,(long)attr->ssiz);
		}
		else
		   cp.ssiz = cp.ptsz;
		if (cp.ssiz < smsz || !cct)
			smsz = cp.ssiz;
		ldacmp();
	}
	if (Tagarray[num].font) {
		if (ckfont(attr->font)) {
		  cp.font = attr->font;
		  if (!front) {
			loadrval();
			in_cmmd(3,(long)cp.font);
		  }
		}
	}
	if (!front && Tagarray[num].avld)
		TmoveY(5,Tagarray[num].avld);
	if (!front && Tagarray[num].rvld)
		TmoveY(4,Tagarray[num].rvld);
/*?*/	if (front && !forward && Tagarray[num].hmvr) {
		if (Tagarray[num].hmvr <= cp.llen-clen)
			clen += Tagarray[num].hmvr;
	}
/*?*/	if (front && !forward && Tagarray[num].hmvl) {
		if (Tagarray[num].hmvl <= clen)
			clen -= Tagarray[num].hmvl;
	}
	if (Tagarray[num].acfg) {
		cp.acomp = attr->acomp;
		ldacmp();
	}
	if (Tagarray[num].mcfg)
		cp.mcomp = attr->mcomp;
	if (Tagarray[num].krfg)
		cp.kernmd = attr->kernmd;
	if (Tagarray[num].rvfg) {
		cp.rvomd = attr->rvomd;
		if (!front)
			in_cmmd(11,(long)cp.rvomd);
	}
	if (Tagarray[num].jmfg) {
		cp.jstmd = attr->jstmd;
		if (!front) cpjm = cp.jstmd;
	}
	if (!front && Tagarray[num].fofmd)
		in_cmmd(14,0L);
	if (Tagarray[num].pifg)
		cp.psimd = attr->psimd;
	if (Tagarray[num].ltfg) {
		cp.ltsmd= attr->ltsmd;
		cp.plts = attr->plts;
		cp.nlts = attr->nlts;
	}
	if (Tagarray[num].hyfg) {
		cp.hypmd   = attr->hypmd;
		cp.nsuchyp = attr->nsuchyp;
		cp.nbefhyp = attr->nbefhyp;
		cp.nafthyp = attr->nafthyp;
	}
	if (Tagarray[num].spfg) {
		cp.minsp = attr->minsp;
		cp.prfsp = attr->prfsp;
		cp.maxsp = attr->maxsp;
		spbval	 = cp.minsp + cp.prfsp;	/* set space value	*/
	}
	deltaglist();
}

static	addtaglist()
{
	struct	tagll	*ntag;

	cpabt = 0;
	if (!(ntag = (struct tagll *)malloc(sizeof(struct tagll))))
		cpabt = 7;			/* get new list member	*/
	else {
		if (strtlist == (struct tagll *)0L) {
			strtlist = ntag;
			zero_list(&ntag->link);
		}
		else	link_before(&strtlist->link,&ntag->link);
	}
	return(cpabt);
}

static	deltaglist()
{
	struct	tagll	*lptr;

	if (!strtlist)
		return;
	lptr = (struct tagll *)strtlist->link.bptr;
	link_remove(&lptr->link);
	free(lptr);
	if (lptr == strtlist)
		strtlist = (struct tagll *)0L;
}

clear_tags()
{
	last_tag = BLTAG;		/* reset Last used Local Tag	*/
	memset(&Tagarray[0],0,sizeof(Tagarray));
	memset(&gltagnames[0][0],0,sizeof(gltagnames));
}

write_tags()
{
	int	i;
	char	yflag = 1;
	char	nflag = 0;

	for (i = 0;i < NUMTAG;++i) {
	  if (Tagarray[i].used) {
	    if (!dwrite(&yflag,1) ||
		!dwrite(&Tagarray[i],sizeof(struct STYtag)))
		return(0);
	    if (i < NUMGLOBALS && !dwrite(&gltagnames[i][0],14))
		return(0);
	  }
	  else
	  if (!dwrite(&nflag,1))
		return(0);
	}
	return(1);
}

read_tags()
{
	int	i;
	char	uflag, ltagfree;

	for (ltagfree = 0,i = 0;i < NUMTAG;++i) {
	  if (!dread(&uflag,1))
		return(0);
	  if (uflag) {
		if (!dread(&Tagarray[i],sizeof(struct STYtag)))
			return(0);
		if (i < NUMGLOBALS && !dread(&gltagnames[i][0],14))
			return(0);
	  }
	  else
	  if (!ltagfree && i >= NUMGLOBALS) {
		ltagfree = 1;
		last_tag = i + 1;	/* set next free Local Tag	*/
	  }
	}
	return(1);
}

static	set_hidden(obj)
int	obj;
{
	tagobj[obj].ob_flags |= HIDETREE;
}

static	dis_hidden(obj)
int	obj;
{
	tagobj[obj].ob_flags &= ~HIDETREE;
}

static	G_tag(tagnum)
int	*tagnum;
{
	int		i, button, ret;
	unsigned char	sel;

	rsrc_gaddr(0,GLOBTAG,&tagobj);
	for (i = 0;i < NUMGLOBALS;++i)
		tagobj[i + GTAG1].ob_spec = (long)&gltagnames[i][0];
	button = execform(tagobj,0);
	tagobj[button].ob_state = NORMAL;
	switch(button) {
	case GTAGOK:
	case GTAGMOD:
		if (whichSEL(tagobj,&sel,GTAG1,GTAG16)) {
			*tagnum = (unsigned)sel + 1;
			if (gltagnames[sel][0])
				ret = (button == GTAGMOD) ? 1:0;
			else	ret = 1;
			break;
		}
	case GTAGNOK:
		*tagnum = ret = 0;
		break;
	}
	if (ret) BWredraw();			/* redraw T/P Windows	*/
	return(ret);
}

pi_tag(fpos)
int	*fpos;
{
	int	button, mod, nwfp;

	rsrc_gaddr(0,PICMD,&tagobj);
	to_set_int(*fpos,PINUM);
	button = execform(tagobj,0);
	tagobj[button].ob_state = NORMAL;
	switch(button) {
	case PIOK:
		if ((nwfp = get_int(tagobj,PINUM)) != *fpos) {
		  if (nwfp >= 1 && nwfp <= 118) {
			*fpos = nwfp;
			mod = 1;
			break;
		  }
		  else	do_alert(BADINP);
		}
	case PINOK:
		mod = 0;
		break;
	}
	if (mod) BWredraw();			/* redraw T/P Windows	*/
	return(mod);
}



int_mu_vlrv(dialog,val,obj)
OBJECT	*dialog;
int	val, obj;
{
	long *str1;
	char str[8];

	dialog[obj].ob_flags |= EDITABLE;
	imu_vlrv(val,str);
	str1 = dialog[obj].ob_spec;
	strcpy(*str1,str);
}



int_mu_hlrv(dialog,val,obj)
OBJECT	*dialog;
int	val, obj;
{
	char str[8];
	long *str1;

	dialog[obj].ob_flags |= EDITABLE;
	imu_hlrv(val,str);
	str1 = dialog[obj].ob_spec;
	strcpy(*str1,str);
}
