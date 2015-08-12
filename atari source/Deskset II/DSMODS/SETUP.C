/****************************************************************************/
/* HISTORY								    */
/*									    */
/* 11/02/89	- do_pwrup()						    */
/*		  When the dress is changed, gltxtattr.font will contain    */
/*		  the UID number of the first font in the dress.	    */
/*									    */
/* 11/06/89	- do_pwrup()						    */
/*		  When ok is clicked, write out the filenames in GOG.DFT    */
/****************************************************************************/
#include	<gemdefs.h>
#include	<obdefs.h>
#include	<osbind.h>
#include	"deskset2.h"
#include	"comp.h"

extern	unsigned	hlq[UNIT4], vlq[UNIT4];
extern	double		hrq[UNIT4], vrq[UNIT4], modf();
extern	struct txtattr	gltxtattr;		/* global text attrib	*/
extern	char		syspath[];		/* boot up  path...	*/
extern	char		widpath[];		/* WID file path...	*/
extern	char		*dpath1;		/* TXT file path...	*/
extern	char		*get_edit();
extern 	unsigned long 	gl_region_ptr;		/* selected text region	*/
extern	unsigned	formval;
extern	int		unit_type, pagetype;	/* Atari setup Vars	*/
extern  int     	attr_flag[];		/* cjg 			*/

static	char	drsex[] = "*.DRS";		/* gdosfname mode 0	*/
static	char	exdex[] = "*.DIC";		/* gdosfname mode 1	*/
static	char	lytex[] = "*.LYT";		/* gdosfname mode 2	*/
static	char	widex[] = "*.WID";		/* gdosfname mode 3	*/
static	char	txtex[]	= "*.TXT";		/* gdosfname mode 4	*/
static	int	deskx, desky, deskw, deskh;

char		fs_iinsel[14];		/* filename from gdosfname()	*/
int		Pval;			/* parmcheck() result value	*/

updATTr()				/* ATARI */
{
     upd_txt_attributes();		/* update one or many regions */
					/* function found in resource */
}


do_hylang()
{
	OBJECT	*hyobj;
	int	button;
	char	svhylg;

	rsrc_gaddr(0,HYLAN,&hyobj);
	set_nor(hyobj,ENG,DAN);
	hyobj[setp.hylg].ob_state = SELECTED;
	svhylg = setp.hylg;

	button = execform(hyobj,0);
	hyobj[button].ob_state = NORMAL;
	if (button == HYLOK && whichSEL(hyobj,&setp.hylg,ENG,DAN)) {
		++setp.hylg;
		if (!ld_lang()) {		/* load Hyp. language	*/
			setp.hylg = svhylg;	/* if error reload old	*/
			ld_lang();
		}
	}
}

do_hypar()
{
	OBJECT	*hyparobj;
	int	button;
	int	i, j, k;
	
	clr_attr_flag();	/* cjg */

	rsrc_gaddr(0,HYPARS,&hyparobj);
	set_int(hyparobj,SUHY ,gltxtattr.nsuchyp);
	set_int(hyparobj,CHBHY,gltxtattr.nbefhyp);
	set_int(hyparobj,CHAHY,gltxtattr.nafthyp);
	set_nor(hyparobj,HMOFF,HMON);
	hyparobj[gltxtattr.hypmd ? HMON:HMOFF].ob_state = SELECTED;

	formval = SUHY;
	dial1(hyparobj);
err:	button = dial2(hyparobj);
	if (button == HYOK) {
		i = get_int(hyparobj,SUHY);
		j = get_int(hyparobj,CHBHY);
		k = get_int(hyparobj,CHAHY);
		if (!ck_hyerr(i,j,k,SUHY,CHBHY,CHAHY)) {
			gltxtattr.hypmd = (hyparobj[HMON].ob_state & SELECTED);
			gltxtattr.nsuchyp = i;
			gltxtattr.nbefhyp = j;
			gltxtattr.nafthyp = k;
		   attr_flag[9]=attr_flag[10]=attr_flag[11]=attr_flag[12]=1; /* CJG*/
		}
		else	goto err;
		updATTr();		/* ATARI */
	}
	dial3();
}

do_pwrup()
{
	OBJECT	*pwobj;
	int	button;
	char	drsbuf[16], dicbuf[16], lytbuf[16];
	char	buf1[100], buf2[100], buf3[100];
	int	*fntptr;
		
	rsrc_gaddr(0,PWFILES,&pwobj);
	set_str(pwobj,DRESS,setp.ftdrs,drsbuf);
	set_str(pwobj,DICT,setp.edict,dicbuf);
	set_str(pwobj,LAYOUT,setp.kblyt,lytbuf);

	do {
	  button = execform(pwobj,0);
	  pwobj[button].ob_state = NORMAL;
	  BWredraw();					/* redraw TW/PW	*/
	  switch (button) {
	  case DRESS:
		if (gdosfname(buf1,0,0))
			strcpy(drsbuf,fs_iinsel);
		break;
	  case DICT:
		if (gdosfname(buf2,1,1))
			strcpy(dicbuf,fs_iinsel);
		break;
	  case LAYOUT:
		if (gdosfname(buf3,2,1))
			strcpy(lytbuf,fs_iinsel);
		break;
	  case PWOK:
		if (strcmp(setp.ftdrs,drsbuf)) {
		  if (Fnt_cmd('L',buf1))	/* load Font dress..	*/
		  {
			strcpy(setp.ftdrs,drsbuf);
			fntptr = ftlib;
			gltxtattr.font = *fntptr;	
		  }
		}
		if (strcmp(setp.edict,dicbuf)) {
		  if (ld_dict(buf2,1))		/* load Dictionary..	*/
			strcpy(setp.edict,dicbuf);
		}
		if (strcmp(setp.kblyt,lytbuf)) {
		  if (ld_lyt(lytbuf) == 2)	/* load Keyboard Layout	*/
			strcpy(setp.kblyt,lytbuf);
		}
		write_GOG();			/* write out new files. */
		break;
	  }
	} while (button != PWOK && button != PWCAN);
}

do_chcomp()
{
	OBJECT	*compobj;
	int	button;
	char	*mcc, sel;

        clr_attr_flag();

	rsrc_gaddr(0,CHARCOMP,&compobj);
	set_nor(compobj,ACCSET1,ACCSET3);
	set_nor(compobj,ACCOFF,ACCON);
	set_nor(compobj,MCCOFF,MCCON);
	set_int(compobj,MCCSETVL,gltxtattr.mcomp / 2);
	compobj[gltxtattr.mcomp ? MCCON:MCCOFF].ob_state = SELECTED;
	compobj[gltxtattr.acomp ? ACCON:ACCOFF].ob_state = SELECTED;
	if (gltxtattr.acomp)
		compobj[gltxtattr.acomp == 1 ? ACCSET1:
			gltxtattr.acomp == 2 ? ACCSET2:
			ACCSET3].ob_state = SELECTED;

	formval = MCCSETVL;
	dial1(compobj);
	button = dial2(compobj);
	if (button == COMPOK) {
		if (compobj[ACCON].ob_state == SELECTED &&
		    whichSEL(compobj,&sel,ACCSET1,ACCSET3)) {
			gltxtattr.acomp = ++sel;
		}
		else	gltxtattr.acomp = 0;
		attr_flag[7] = 1;

		if (compobj[MCCON].ob_state == SELECTED) {
			mcc = get_edit(compobj,MCCSETVL);
			gltxtattr.mcomp = atoi(mcc) * 2;
		}
		else	gltxtattr.mcomp = 0;
		attr_flag[6] = 1;
		updATTr();		/* ATARI */
	}
	dial3();
}


do_wdsp()
{
	OBJECT	*wdspobj;
	int	button, i, j, k;

	clr_attr_flag();

	rsrc_gaddr(0,WORDSPC,&wdspobj);
	set_nor(wdspobj,LSPOFF,LSPON);
	set_int(wdspobj,CPPOS,gltxtattr.plts);
	set_int(wdspobj,CPNEG,gltxtattr.nlts);
	set_int(wdspobj,CPMIN,gltxtattr.minsp);
	set_int(wdspobj,CPPRF,gltxtattr.prfsp);
	set_int(wdspobj,CPMAX,gltxtattr.maxsp);
	wdspobj[gltxtattr.ltsmd ? LSPON:LSPOFF].ob_state = SELECTED;

	formval = CPMIN;
	dial1(wdspobj);
err:	button = dial2(wdspobj);
	if (button == CPOK) {
		gltxtattr.plts = get_int(wdspobj,CPPOS);
		if ((i = get_int(wdspobj,CPNEG)) > 6) {
			formval = CPNEG;
			do_alert(BADINP);
			goto err;
		}
		else	gltxtattr.nlts = i;
		i = get_int(wdspobj,CPMIN);
		j = get_int(wdspobj,CPPRF);
		k = get_int(wdspobj,CPMAX);
		if (!ck_sperr(i,j,k,CPMIN,CPPRF,CPMAX)) {
			gltxtattr.minsp = i;
			gltxtattr.prfsp = j;
			gltxtattr.maxsp = k;
			attr_flag[16] = attr_flag[17] = attr_flag[18] = 1;
		}
		else	goto err;
		gltxtattr.ltsmd = (wdspobj[LSPON].ob_state & SELECTED);
		attr_flag[13] = 1;
		updATTr();		/* ATARI */
	}
	dial3();
}

do_just()
{
	OBJECT	*justobj;
	int	button;
	char	sel;

	clr_attr_flag();

	rsrc_gaddr(0,JUSTIFI,&justobj);
	set_nor(justobj,AUTOJUST,AUTOCTR);
	justobj[gltxtattr.jstmd+AUTOJUST].ob_state = SELECTED;

	button = execform(justobj,0);
	justobj[button].ob_state = NORMAL;
	if (button == JUSTOK && whichSEL(justobj,&sel,AUTOJUST,AUTOCTR))
	{
		gltxtattr.jstmd = sel;
		attr_flag[21] = 1;
		updATTr();		/* ATARI */
	}
}

ck_hyerr(i,j,k,v1,v2,v3)
int	i, j, k, v1, v2, v3;
{
	if (!i) {
	  	formval = v1;
err:		do_alert(BADINP);
		return(1);
	}
	else
	if (j < 2) {
	  	formval = v2;
		goto err;
	}
	else
	if (k < 2) {
	  	formval = v3;
		goto err;
	}
	return(0);
}

ck_sperr(i,j,k,v1,v2,v3)
int	i, j, k, v1, v2, v3;
{
	if ((i + j) > 99) {
		formval = v1;
err:		do_alert(BADINP);
		return(1);
	}
	else
	if ((i + k) > 99) {
		formval = v2;
		goto err;
	}
	else
	if (j > k) {
		formval = v3;
		goto err;
	}
	return(0);
}

/*
	Routine to copy a source digit string "s" to a target one "t"
	while counting the number of digit.
	Return updated source pointer.
*/
static	char	*gNstr(s,t,ndig)
char	*s, *t, *ndig;
{
	*ndig = 0;
	while (cdigit(*s))
	{ *t++ = *s++; ++(*ndig); }
	*t = 0;
	return(s);
}

/*
	Input string conversion and Value check
	cmd	1 - X value
		2 - Point/Set size
		3 - Y value
		4 - LineSpace
	nflag = 0 - don't allow negative numbers.
		1 - Allow negative numbers.
*/
checkValue(input,cmd,nflag)
char	*input;
int	cmd;
int	nflag;
{
	char		bfdot[8], afdot[8], ldig, rdig;
	unsigned	lnum, rnum, maxx, maxy, maxls;
	int		erf = 0;
	double		dval, intg;
	int flag;

	flag = 0;
	if (*input) {
		if((*input == '-')&& nflag)
		{
		     input++;
		     flag = 1;
		}

		input = gNstr(input,bfdot,&ldig);
		if (ldig > 4)
			goto err;
	}
	else	goto err;
	if (*input == '.') {
		input = gNstr(++input,afdot,&rdig);
		if (rdig > 2)
			goto err;
	}
	else	afdot[0] = rdig = 0;
	if (*input)
		goto err;
	lnum = atoi(bfdot);
	rnum = atoi(afdot);
	if (cmd != 2 && !unit_type && rdig == 1)
		rnum *= 10;
	getmax(&maxx,&maxy,&maxls);
	switch (cmd) {
	case 1:					/* all line measures	*/
		if (rnum >= hlq[unit_type])
			goto err;
		dval =	(double)lnum *		/* convert XXX. first	*/
			(double)hlq[unit_type] * hrq[unit_type];
		if (rnum > 0)			/* convert .XX to add	*/
			dval += ((double)rnum * hrq[unit_type]);
		dval = modf(dval,&intg);	/* get mod. to adjust	*/
		lnum = (unsigned)intg;		/* get integral part	*/
		if (dval >= 0.5)
			++lnum;
		if (lnum > maxx)		/* validate new value	*/
err:			erf = 1;
		else	Pval = lnum;
		break;
	case 2:					/* all point sizes	*/
		if (!lnum			/* no zero on XXX.	*/
			||
		   (rnum != 0 && rnum != 5)	/* .X is only 0 or 5	*/
			||
		   (setp.omod == 2 &&		/* special for CG 8200:	*/
		    lnum >= 36 && rnum))	/* 36-72 pt in 1pt inc	*/
			goto err;
		lnum = pt12(lnum,rnum);		/* compute 8th pt value	*/
		if (ptszck(lnum))		/* validate new value	*/
			goto err;
		else	Pval = lnum;
		break;
	case 3:					/* all depth measures	*/
	case 4:					/* all LineSpaces	*/
		if (rnum >= vlq[unit_type])	/* .XX within range	*/
			goto err;
		dval =	(double)lnum *		/* convert XXX. first	*/
			(double)vlq[unit_type] * vrq[unit_type];
		if (rnum > 0)			/* convert .XX to add	*/
			dval += ((double)rnum * vrq[unit_type]);
		dval = modf(dval,&intg);	/* get mod. to adjust	*/
		lnum = (unsigned)intg;		/* get integral part	*/
		if (dval >= 0.5)
			++lnum;
		if (cmd == 3) {
		  if (lnum > maxy)		/* validate new depth	*/
			goto err;
		}
		else {
		  if (lnum > maxls)		/* validate LineSpace	*/
			goto err;
		}
		Pval = lnum;
		break;
	}
	if(flag && nflag)
	   Pval = -Pval;
	return(erf);
}

parmcheck(dialog,obj,mode,nflag)
OBJECT	*dialog;
int	obj, mode;
int 	nflag;
{
	char	**str;

	formval = obj;
	str	= (char **)dialog[obj].ob_spec;
	if (checkValue(*str,mode,nflag)) {
		do_alert(BADINP);
		return(1);
	}
	else	return(0);
}

/*
	Range check for point and set size
	Value can be in 1/2 point increment and is stored in 1/8 point.
	CG 8000, 8400, ep308 :	4 to 72 point
	CG 8600 :		4 to 127.5 point
	CG 8200 :		5 to 72 point	(from 36 to 72 only in
						1 point increment)
	Atari Laser :		5 to 144 point
*/
ptszck(sz)
int	sz;
{
	if (setp.omod == 0)				/* TY 8600..	*/
		return(sz < 32 || sz > 1020);
	else
	if (setp.omod == 2)				/* TY 8200..	*/
		return(sz < 40 || sz > 576);
	else
	if (setp.omod == 5)				/* Laser...	*/
		return(sz < 40 || sz > 1152);
	else	return(sz < 32 || sz > 576);	/* TY 8000, 8400, EP308 */
}

whichSEL(obj,item,st,ct)
OBJECT	*obj;
char	*item;
int	st, ct;
{
	int	i;

	for (i = st;i <= ct && !(obj[i].ob_state & SELECTED);++i);
	if (i <= ct) {
		*item = i - st;
		return(1);
	}
	else	return(0);
}

set_nor(obj,st,ct)
OBJECT	*obj;
int	st, ct;
{
	int	i;

	for (i = st;i <= ct;++i)
		obj[i].ob_state = NORMAL;
}

do_alert(msgno)
int	msgno;
{
	char	*ptr;

	rsrc_gaddr(R_STRING,msgno,&ptr);
	return(form_alert(1,ptr));
}

set_str(tree,index,source,target)
OBJECT	*tree;
int	index;
char	*source;
char	*target;
{
	strcpy(target,source);
	tree[index].ob_spec = (long)target;
}

/********************************/
/*	Use file selector	*/
/*	to get input file	*/
/********************************/
gdosfname(filename,spec,check)
char	*filename;
int	spec, check;
{
	int	fs_iexbutton, ret;
	char	*path, *fspec;

/*	Note:	filename large enough to hold
		system path and user selection !	*/
	switch(spec) {
	case 0:	path	= syspath;
		fspec	= drsex;
		break;
	case 1:	path	= syspath;
		fspec	= exdex;
		break;
	case 2:	path	= syspath;
		fspec	= lytex;
		break;
	case 3:	path	= widpath;
		fspec	= widex;
		break;
	case 4:	path	= dpath1;
		fspec	= txtex;
		break;
	}
	strcpy(filename,path);
	strcat(filename,fspec);
	fs_iinsel[0] = 0;
	if (fsel_input(filename,fs_iinsel,&fs_iexbutton) &&
	    fs_iexbutton && fs_iinsel[0]) {
		strunc(fs_iinsel);
		strcat(fs_iinsel,fspec+1);
		filetopath(filename);
		strcat(filename,fs_iinsel);
		if (check) {
			if (!(ret = (!access(filename,0)))) {
				BWredraw();		/* redraw TW/PW	*/
				setnfd(fs_iinsel,1);
			}
		}
		else	ret = 1;
	}
	else	ret = 0;
	BWredraw();					/* redraw TW/PW	*/
	return(ret);
}

dial1(dialog)
OBJECT	*dialog;
{
	form_center(dialog,&deskx,&desky,&deskw,&deskh);
	form_dial(0,0,0,0,0,deskx,desky,deskw,deskh);
	form_dial(1,0,0,0,0,deskx,desky,deskw,deskh);
}

dial2(dialog)
OBJECT	*dialog;
{
	int	exit_obj;

	objc_draw(dialog,0,10,deskx,desky,deskw,deskh);
	exit_obj = form_do(dialog,formval);
	dialog[exit_obj].ob_state = NORMAL;
	return(exit_obj);
}

dial3()
{
	form_dial(2,0,0,0,0,deskx,desky,deskw,deskh);
	form_dial(3,0,0,0,0,deskx,desky,deskw,deskh);
}

filetopath(filename)
char	*filename;
{
	int	i;
	char	c;

	i = strlen(filename);
	while (i && ((c = filename[i-1]) != '\\' && c != ':'))
		--i;
	filename[i] = 0;
}

get_pgtype()
{
	return(pagetype - PA4);
}
