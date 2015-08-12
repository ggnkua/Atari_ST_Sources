#include	"defs.h"
#include	"comp.h"
#include	"cmd.h"
#include 	"osbind.h"

#define		MAXCMD		100		/* # commands in line	*/
#define		MAXCHR		800		/* # char/cmd in line	*/
#define		tsp		119		/* flash pos Thin SPace	*/
#define		nsp		120		/* flash pos eN   SPace	*/
#define		msp		121		/* flash pos eM   SPace	*/

/*
	Externals
*/
extern	char		*realloc();
extern	unsigned char	ptsfpos[256],
			mcsdbl[303];		/* IFont Layout tables	*/
extern	struct slvll	*slv;			/* local GO slave list	*/
extern	int		vpage_size;		/* Vertical Page Size	*/

/* ATARI */
extern  int ptsarray[];

/*
	Locals
*/
static
char		ker, ichfg, fhfg, rvofg;	/* some local flags	*/
static
char		Kapp;				/* Kerning apply flag	*/
static
int		splen;				/* space length holder	*/
static
unsigned	spcnt, ispcnt, ccnt, cmdcnt;	/* various counters	*/
static
unsigned	prepos;				/* PREvious char POS.	*/
static
unsigned	ichcnt, ichwid,			/* Insert CHar. vars	*/
		ichpos[MAXCMD];
static
unsigned	rvopsiz, topval, botval,	/* Reverse Video vars	*/
		pvlsp, pvbot;
static
unsigned long	cmdrec[MAXCMD];			/* tag CoMmanD RECord	*/
static	struct {
	unsigned char	acf;			/* floating accent flag	*/
	unsigned	pos;			/* position in chinln[]	*/
}	chs;					/* CHar. State struct.	*/
static	struct {
	unsigned char	fg;			/* char flag from font	*/
	unsigned char	ch;			/* its flash position	*/
	int		wid;			/* its composed width	*/
}	chinln[MAXCHR];				/* Char. IN LiNe array	*/

/*
	Globals
*/
char		fofg;				/* Flash Only flag	*/
char		cpjm;				/* line justified mode	*/
char		advld, rldld;			/* Accumulative leading	*/
unsigned	disp;				/* Xdisplacement from 0	*/
unsigned char	*utinpt;			/* slave input pointer	*/
struct slvll	*Bslv;				/* Bend slave list ptr	*/
unsigned	init_x;				/* initial X from Atari	*/
unsigned long	init_y;				/* initial Y from Atari	*/
unsigned long	last_y;				/* Bend last Y known	*/
int		TYF_handle;			/* TYsetter file handle	*/
int		TYF_Gx0, TYF_Gy0;		/* Graphics file X0,Y0,	*/
int		TYF_Gx1, TYF_Gy1;		/* Graphics file X1,Y1,	*/
int		TYF_Gtype;			/* Graphics file type,	*/
char		*TYF_Gfile;			/* filename or cmd ptr	*/


/*
	Justification & Slave generation processor.
	Only called by dotext(). Returns pointer to next text
	if cpabt is 0 or 8 else -1L for all other true values
	of cpabt. Set
	cpabt:	0	-- no error
		4	-- line measure too short
		7	-- no memory for tag support
		8	-- Hit Region Feed
*/
unsigned char	*bend(text,done)
struct textobj	*text;
int		*done;
{
	unsigned char	*inptr, c, noerr;

	cpabt = 0;
	if (text->begtext >= free_start) {	/* no text return...	*/
		*done = 1;
		return(-1L);
	}
	else	*done = 0;
	setslvlist(text);			/* setup slave list	*/
	if (cpabt == 7)				/* memory error quit...	*/
		return(-1L);
	initbcomp();				/* initialize Bend vars	*/
	inptr = text->begtext;			/* set text scan pter	*/
	while (!cpabt && inptr < free_start)	/* until end of buffer	*/
	switch(c = *inptr++) {
	case ' ':					/* space band	*/
		Kapp = 0;
		cmpval = avcval = 0;			/* no CComp...	*/
		prepos = ccnt;
		chinln[ccnt].fg = 0;
		chinln[ccnt].ch = SPC;
		splen += (chinln[ccnt++].wid	/* update space length	*/
			  = cwfrw(spbval,0));	/* by min space band... */
		++spcnt;			/* update space counter	*/
		break;
	case hrt:					/* hard return	*/
	case srt:					/* soft return	*/
	case Rf:					/* Region Feed	*/
		if (line_ck())				/* final check	*/
			goto out;			/* error quit..	*/
		inptr += 2;				/* skip cr-lf	*/
		if (c == Rf)				/* Region Feed	*/
			cpabt = 8;			/* Stop now...	*/
		else
		if (dpreset())				/* reach depth?	*/
			goto out;
		break;
	case cr:					/* carr. return	*/
		++inptr;				/* skip over lf	*/
		break;
	case DH:					/* disc. hyphen	*/
	case lf:					/* line feed	*/
		break;					/* ignore them	*/
	case QL:					/* quad left	*/
		Kapp = 0;
		cpjm = AL;
		break;
	case QR:					/* quad right	*/
		Kapp = 0;
		cpjm = AR;
		break;
	case QC:					/* quad center	*/
		Kapp = 0;
		cpjm = AC;
		break;
	case STAG:					/* start TAG	*/
		in_tag(*inptr++,0,1);
		cmpval = avcval = 0;			/* no CComp...	*/
		Kapp = 0;
	        break;
	case ETAG:					/* end	TAG	*/
		out_tag(*inptr++,0,1);
		cmpval = avcval = 0;			/* no CComp...	*/
		Kapp = 0;
	        break;
	case PTAG:					/* PI TAG	*/
		storech(*inptr++);
	        break;
	case sHY: case sDH:				/* soft hyphens	*/
		c = '-'; 
	default:					/* other chars	*/
		bcwidth(c);
		break;
	}
	if (ccnt && !cpabt)			/* if there are chars..	*/
		line_ck();			/* final check on line	*/

out:	funct_comm(SLVEOB,0);			/* place End Of Block	*/
	noerr = (!cpabt || cpabt == 8);
	*done = (noerr && inptr >= free_start);
	if (noerr) {
		last_y = init_y + cdep;		/* save last Y known	*/
		Bslv->bufptr = realloc		/* reallocate slave...	*/
			(Bslv->bufptr,utinpt - Bslv->bufptr);
	}
	return(noerr ? inptr:(unsigned char *)-1L);
}

/*
	Routine to reset some composition parameters for new line
*/
Lreset()
{
	disp	= init_x;
	smsz	= cp.ssiz;
	cpjm	= cp.jstmd;
	ispcnt	= spcnt = ichcnt = cmdcnt = ccnt = cct = 0;
	clen	= splen = ichwid = 0;
	rvopsiz	= 0;
	ichfg	= fhfg = 0;
	chs.acf = 0;
	chs.pos = 0;
	Kapp	= 0;
	cmpval  = avcval = 0;
}

/*
	Routine to intialize all default composition parameters
	on entry to Bend()...
*/
initbcomp()
{
	advld	= rldld = 0;
	pvbot	= pvlsp = 0;
	fofg	= 0;
	spbval  = cp.minsp + cp.prfsp;		/* set space value...	*/
	cdep	= cp.lnsp;			/* set start depth	*/
	rvofg	= cp.rvomd;
	Bslv	= slv;
	utinpt	= Bslv->bufptr;			/* init slave pointer	*/
	Lreset();				/* reset line vars...	*/
	funct_comm(pt_typ,cp.ptsz);			/* setup point,	*/
	funct_comm(s_size,cp.ssiz);			/* set size	*/
	typeface(cp.font);			/* place Font info...	*/
	to_new_y();				/* place move FWD | REV	*/
}

/*
	Routine to return current Char. Comp. value (Auto + Manual)
*/
chcomp()
{
	int	temp = 0;

	if (cp.mcomp) {
		temp += cmpval;
		if (!chs.acf)
			cmpval = cp.mcomp;
	}
	if (cp.acomp) {
		temp += avcval;
		if (!chs.acf)
			avcval = acmp;
	}
	return(temp);
}

/*
	Routine to advance Bend depth
*/
dpreset()
{
	if ((cdep + cp.lnsp) >= cp.depth)	/* break point reached	*/
		return(1);
	else {
		ad_dp();
		Lreset();			/* reset for next line	*/
		return(0);
	}
}

/*
	Function to do final line check (space justification and
	slave generation)
*/
line_ck()
{
	int	erf = 0;

	if (chs.acf) {				/* Faccent only at eol	*/
		++cct;					/* count it...	*/
		clen += chinln[chs.pos].wid;
	}
	if (cct || ichcnt)			/* some chars in line	*/
		erf = just_space(cp.llen-splen-clen);	/* go justify	*/
	else {					/* or some cmds or none	*/
		if (rvofg)			/* check RVO to setup	*/
			set_rev_par();
		if (cmdcnt)			/* if some cmds do them	*/
			funct_call(0,0,0,0);
		if (rvofg)			/* check RVO to close	*/
			rev_video(OFF);
	}
	return(erf);
}

/*
	Function to justify extra space in line...
*/
just_space(ex_sp)
int	ex_sp;
{
	int	i, v, val, chct;
	int	minlsp, maxlsp, cw;

	if (ichcnt) {					/* IC cmd(s) ?	*/
	  if (ex_sp < 0)				/* if no space	*/
		for (i = 0;i < ichcnt;++i)		/* find all ICs	*/
			chinln[ichpos[i]-1].fg = 0;	/* to disable..	*/
	  else
	  if (ex_sp <= ichwid) {			/* enough space	*/
		for (i = 0;i < ichcnt;++i) {		/* for all ICs	*/
		  cw = chinln[ichpos[i]].wid;		/* get IC width	*/
		  if (cw <= ex_sp) {			/* space left ?	*/
			ex_sp -= cw;			/* (-) IC width	*/
			ichpos[i] = 1;			/* set min of 1	*/
		  }
		  else	chinln[ichpos[i]-1].fg = 0;	/* or disable..	*/
		}
		ichwid = 0;				/* no IC width	*/
	  }
	}

	if (cpjm != AJ &&			/* Non Justify mode and	*/
	    ex_sp > 0 && !ispcnt && !ichcnt) {	/* extra space found..	*/
	  if (cpjm == AR)				/* quad right	*/
		disp += ex_sp;				/* add to left	*/
	  else
	  if (cpjm == AC)				/* quad center	*/
		disp += (ex_sp / 2);			/* add 1/2 only */
	}

	if (rvofg)				/* check RVO to setup	*/
		set_rev_par();

	if (ex_sp < 0) {			/* Negative space case	*/
	  if (!spcnt)					/* no spaceband	*/
		v = minlsp = 0;				/* no (+) space	*/
	  else {
		v = cwfrw(cp.prfsp,1);			/* get Prf diff	*/
		minlsp = v * spcnt;			/* to (+) space	*/
	  }
	  if ((ex_sp + minlsp) >= 0) {			/* Min|Prf range*/
		ex_sp = ~ex_sp + 1;
		funct_call(-(ex_sp/spcnt),-(ex_sp%spcnt),0,0);
	  }
	  else
	  if (cp.ltsmd && cp.nlts && cct > 1) {		/* LTSpace on	*/
		ex_sp += minlsp;			/* (+) space...	*/
		chct   = cct - 1;
		minlsp = cwfrw(cp.nlts,1) * chct;	/* get LTS diff	*/
		if ((ex_sp + minlsp) >= 0) {		/* -LTS range	*/
		  ex_sp = ~ex_sp + 1;
		  funct_call(-v,0,-(ex_sp/chct),-(ex_sp%chct));
		}
		else	cpabt = 4;			/* line overset	*/
	  }
	  else	cpabt = 4;				/* line overset	*/
	}
	else
	if ((!ispcnt && !ichcnt) ||		/* no ISpace or IChar	*/
	    ( ichcnt && !ichwid)) {		/* or IC being counted	*/
	  if (cpjm == AJ && ex_sp && cct > 1) {	/* Justify & extra Sp	*/
		chct = cct - 1;
		if (cp.plts) {				/* +LTS active	*/
		  val = cwfrw(cp.plts,1);		/* get +LTS to	*/
		  minlsp = val * chct;			/* spread extra	*/
		}
		else
		  val = minlsp = 0;			/* no +LTS...	*/
		if (spcnt) {				/* Spacebands ?	*/
		  v = cwfrw(cp.maxsp,1);		/* get MaxSp to	*/
		  maxlsp = v * spcnt;			/* spread extra	*/
		  if (	!cp.ltsmd ||			/* LTSpace off	*/
			ex_sp <= maxlsp  )		/* extra fit Sp	*/
							/* spread to Sp	*/
			funct_call(ex_sp/spcnt,ex_sp%spcnt,0,0);
		  else {				/* +LTS range	*/
			ex_sp -= maxlsp;		/* take off Sp	*/
			if (ex_sp <= minlsp)		/* extra fit LTS*/
							/* spread to Ch	*/
			  funct_call(v,0,ex_sp/chct,ex_sp%chct);
			else {				/* extra > +LTS	*/
			  ex_sp -= minlsp;
			  funct_call(v+(ex_sp/spcnt),ex_sp%spcnt,val,0);
			}
		  }
		}
		else					/* no space...	*/
		if (cp.ltsmd) {				/* LTSpace on	*/
		  if (ex_sp < ((val *= 3) * chct))	/* extra <+3LTS	*/
			funct_call(0,0,ex_sp/chct,ex_sp%chct);
		  else	funct_call(0,0,val,0);		/* spread +3LTS	*/
			  
		}
		else	funct_call(0,0,0,0);		/* just output	*/
	  }
	  else	funct_call(0,0,0,0);		/* act as Non Justify	*/
	}
	else
	if (ex_sp > 0) {			/* Positive space case	*/
	  if (ichcnt) {				/* there are IC(s)...	*/
		cw	= ex_sp / ichcnt;		/* spread to IC	*/
		val	= ex_sp % ichcnt;		/* extra remain	*/
		ex_sp	= 0;
		for (i = 0;i < ichcnt;++i) {
		  if (val)
			v = 1, --val;			/* use remain	*/
		  else	v = 0;
		  if (	chinln[ichpos[i]].ch == msp ||	/* IC EM Space	*/
			chinln[ichpos[i]].ch == nsp ||	/* IC EN Space	*/
			chinln[ichpos[i]].ch == tsp  )	/* IC TH Space	*/
			chinln[ichpos[i]].wid = cw + v;
		  else {				/* IC normal Ch	*/
			if (chinln[ichpos[i]].wid) {	/* valid width	*/
			  ex_sp += (chinln[ichpos[i]-1].wid =
				 (cw+v)%chinln[ichpos[i]].wid);
			  if (cw)			/* set # of Ch	*/
				ichpos[i]= (cw+v)/chinln[ichpos[i]].wid;
			}
			else { cpabt = 4; goto out; }	/* what ? error	*/
		  }
		}
	  }
	  if (ex_sp) {
		if (ispcnt)				/* spread to IS	*/
			funct_call(ex_sp/ispcnt,ex_sp%ispcnt,0,0);
		else
		if (spcnt)				/* spread to Sp	*/
			funct_call(ex_sp/spcnt,ex_sp%spcnt,0,0);
		else	funct_call(0,0,0,0);		/* all other Ch	*/
	  }
	  else	funct_call(0,0,0,0);			/* just output	*/
	}
	else	funct_call(0,0,0,0);		/* just output slave...	*/

out:	if (rvofg)				/* check RVO to close	*/
		rev_video(OFF);
	return(cpabt);
}

/*
	Slave generator and Extra space justificator
	sw	: space width
	ex_spw	: extra space remainder
	cw	: LTS value on character
	ex_chw	: extra LTS remainder
*/
funct_call(sw,ex_spw,cw,ex_chw)
int	sw, ex_spw, cw, ex_chw;
{
	int	i, j, k, l, v;

	i = k = l = 0;					/* zero indexes	*/

	while (i < ccnt && !cpabt) {		/* scan chinln[] for...	*/

	if (chinln[i].ch == IC) {			/* Ins Char cmd	*/
	  if (chinln[i].fg)				/* check valid	*/
	  switch(chinln[++i].ch) {			/* check type	*/
	  case SPC:					/* word space	*/
		disp += (chinln[i].wid + sw);
		if (ex_spw) {				/* space left..	*/
			--ex_spw;
			++disp;
		}
		break;
	  case msp: case nsp: case tsp:			/* fixed spaces	*/
		disp += chinln[i].wid;
		++k;					/* bump ICcount	*/
		break;
	  default:					/* other chars	*/
		if (chinln[i-1].wid && !ispcnt && !spcnt)
		{					/* space left..	*/
			v = chinln[i-1].wid % 2;
	   		chinln[i-1].wid /= 2;
			disp += (chinln[i-1].wid + v);
		}
		for (j = 0;j < ichpos[k];++j)
		if (fhfg) 				/* no flash on	*/
			disp += chinln[i].wid;		/* skip width	*/
		else	long_char_for(chinln[i].ch,chinln[i].wid);
		if (chinln[i-1].wid && !ispcnt && !spcnt)
			disp += chinln[i-1].wid;	/* space left..	*/
		++k;					/* bump ICcount	*/
		break;
	  }
	  else	++i;					/* else skip it	*/
	}
	else
	if (chinln[i].ch == CMDCH) {			/* Tag commands	*/
	  switch(chinln[i].wid) {
	  case 1:					/* point size	*/
		funct_comm(pt_typ,(int)cmdrec[l]);
		break;
	  case 2:					/* set size	*/
		funct_comm(s_size,(int)cmdrec[l]);
		break;
	  case 3:					/* Font		*/
		typeface((int)cmdrec[l]);
		break;
	  case 4:					/* Adv leading	*/
		funct_comm(ver_mov_for,(int)cmdrec[l]);
		break;
	  case 5:					/* Rev leading	*/
		funct_comm(ver_mov_rev,(int)cmdrec[l]);
		break;
	  case 6:					/* Move Right	*/
		disp += (unsigned)cmdrec[l];
		break;
	  case 7:					/* Move Left	*/
		disp -= (unsigned)cmdrec[l];
		break;
	  case 11:					/* Rev. Video	*/
		if (cmdrec[l]) {
			set_rev_par();
			rvofg = ON;
		}
		else	rev_video(rvofg = OFF);
		break;
	  case 14:					/* Flash Only	*/
		fhfg = (char)cmdrec[l];
		break;
	  }
	  ++l;						/* next command	*/
	}
	else
	if (chinln[i].ch == SPC) {			/* word space	*/
	  if (!ispcnt || sw < 0 || ex_spw < 0) {
		if (ex_spw > 0)
		{--ex_spw; ++chinln[i].wid;}
		if (ex_spw < 0)
		{++ex_spw; --chinln[i].wid;}
		disp += (chinln[i].wid + sw);
	  }
	  else	disp += chinln[i].wid;
	}
	else {						/* other chars	*/
	  if (chinln[i].ch == msp ||
	      chinln[i].ch == nsp ||
	      chinln[i].ch == tsp) {			/* fixed spaces	*/
		if (!ispcnt) {
		  if (ex_spw > 0)
		  {--ex_spw; ++chinln[i].wid;}
		  if (ex_spw < 0)
		  {++ex_spw; --chinln[i].wid;}
		}
		disp += chinln[i].wid;
	  }
	  else {					/* all others..	*/
		if (cw || ex_chw) {
		  if (chinln[i].fg & 0x04)		/* accent char	*/
			chinln[i].wid += (cw / 2);
		  else {				/* normal char	*/
			chinln[i].wid += cw;
			if (ex_chw > 0)
			{--ex_chw; ++chinln[i].wid;}
			if (ex_chw < 0)
			{++ex_chw; --chinln[i].wid;}
		  }
		}
		if (fhfg) 				/* no flash on	*/
			disp += chinln[i].wid;		/* skip width	*/
		else	long_char_for(chinln[i].ch,chinln[i].wid);
	  }
	}

	++i;					/* next in chinln[]...	*/
	}					/* end of scan loop...	*/

	if (cp.rvomd && cct)
		pvlsp = (unsigned)cp.lnsp;
	else	pvbot = pvlsp = 0;
	if (setp.omod == 2) {			/* for CG 8200 only	*/
		funct_comm(hor_mov_dir,1);
		funct_comm(hor_pos,0);
		funct_comm(hor_mov_dir,0);
	}
}

/*
	Routine to setup Typeface info
*/
typeface(ftn)
int	ftn;
{
	if (ckfont(ftn)) {			/* set font pointer	*/
		loadrval();			/* load Rev Video vals	*/
		funct_comm(ty_face,ftn,pftpt+2);/* place font # command	*/
	}
}

/*
	Function to get flash position, store it then
	calculate its width.
*/
bcwidth(c)
unsigned char	c;
{
	unsigned char	fp;
	unsigned	i;

	if (c == TSP)				/* all fixed spaces...	*/
		fp = tsp;
	else
	if (c == NSP)
		fp = nsp;
	else
	if (c == MSP)
		fp = msp;
	else	fp = ptsfpos[c];		/* get flash position	*/
	if (fp == 254) {			/* if doublet case...	*/
		for (i = 0;
		     i < 303 && mcsdbl[i] != c;	/* find it in table...	*/
		     i += 3);
		if (i >= 303) {			/* no match error...	*/
			chs.acf = 0;
			return;
		}
		if (!storech(mcsdbl[i+1]))	/* do floating accent	*/
			return;
		fp = mcsdbl[i+2];		/* then normal char.	*/
	}
	storech(fp);
}

/*
	Routine to store flash position and calculate its width.
*/
storech(fp)
unsigned char	fp;
{
	if (fp > msp || !width(fp))
		return(chs.acf = 0);
	else	return(1);
}

/*
	Routine to calculate Bend character width.
*/
width(fp)
unsigned char	fp;
{
	int		cw, aw, kerval;
	unsigned char	rw, *p;

	p = pftpt + 49 + (unsigned)fp * 2;	/* offset to get width	*/
	if ((rw = *p) != 0xff) {
	  cw = cwfrw(rw,0);
	  if (chs.acf) {
		chs.acf = 0;
		cw -= chcomp();
		if (cw < 0) cw = 0;
		kerval = bkerning(fp,1);
		if (kerval)
			subchwid(prepos,kerval);
		prepos = ccnt;
		aw = chinln[chs.pos].wid;
		if (cw < aw) cw = aw;		/* Ch Width < Accent W	*/
		clen += (cw - aw);
		chinln[ccnt   ].ch  = chinln[chs.pos].ch;
		chinln[chs.pos].ch  = fp;	/* swap accent to 2nd	*/
		chinln[chs.pos].wid = (cw - aw) / 2;
		chinln[ccnt   ].wid = cw - chinln[chs.pos].wid;
		Kapp = 1;
		++cct;
		++ccnt;
	  }
	  else {
		chinln[ccnt].fg = *(p + 1);
		chs.acf = chinln[ccnt].fg & 0x04;	/* accent bit ?	*/
		chs.pos = ccnt;
		cw -= chcomp();
		if (cw < 0) cw = 0;
		kerval = bkerning(fp,0);
		if (fofg) {				/* flash only..	*/
		  chinln[ccnt].wid = 0; 
		  if (!chs.acf)
			fofg = 0;
		}
		else {
		  if (!chs.acf) {
		    if (kerval) {
			clen -= kerval;
			chinln[prepos].wid -= kerval;
			if (chinln[prepos].wid < 0)
				chinln[prepos].wid = 0;
		    }
		  }
		  chinln[ccnt].wid = cw;
		  if (!ichfg) {
		    if (!chs.acf) {
			++cct;
			prepos = ccnt;
			Kapp = 1;
		    }
		    clen += chinln[ccnt].wid;
		  }
		  else {
		    ichwid += cw;
		    if (!chs.acf)
			ichfg = 0;
		  }
		}
		chinln[ccnt++].ch= fp;
	  }
	  if (cp.rvomd && cp.ptsz > rvopsiz)
		rvopsiz = cp.ptsz;
	  return(1);
	}
	else
	  return(0);
}

char	bgetkerval(fp,mode)
unsigned char	fp;
int		mode;
{
	unsigned char	*ptr, v;
	char		min = 127;
	unsigned	i, found;

	if (!txkn)				/* no sector kerning	*/
		return(0);
	ptr = pftpt + 289 + ((unsigned)fp * 4);
	if (!Kapp)
		ker = 0;
	else
	if (!mode)
		ker ^= 1;
	for (i = 0;i < 4;++i,++ptr) {
	  if (mode) {
	    if (kern[ker].rval[i] > (v = *ptr & 0x0f))
		kern[ker].rval[i] = v;
	    if (kern[ker].lval[i] > (v = *ptr >> 4))
		kern[ker].lval[i] = v;
	  }
	  else {
		kern[ker].rval[i] = *ptr & 0x0f;
		kern[ker].lval[i] = *ptr >> 4;
	  }
	}
	if (Kapp)
	for (i = 0;i < 4;++i) {
	  if (ker) {
	    kern[0].rval[i] += kern[1].lval[i];
	    if (min > kern[0].rval[i])
		min = kern[0].rval[i];
	  }
	  else {
	    kern[1].rval[i] += kern[0].lval[i];
	    if (min > kern[1].rval[i])
		min = kern[1].rval[i];
	  }
	}
	else	return(0);
	if (kpval)				/* if kern pair exist	*/
	for (	ptr = kpptr, i = found = 0;
		i < kpval && !found;
		++i, ptr += 3	)
	if (chinln[prepos].ch == *ptr && fp == *(ptr+1)) {
		found = 1;
		min += *(ptr+2);
	}
	return(min);
}

bkerning(fp,mode)
unsigned char	fp;
int		mode;
{
	char	kval;

	if (!cp.kernmd)
		return(0);
	kval = bgetkerval(fp,mode);
	if (kval) {
	  if (kval < 0) {
		kval = ~kval + 1;
		return(0 - cwfrw(kval,0));
	  }
	  else	return(cwfrw(kval,0));
	}
	else	return(0);
}

subchwid(pos,val)
int	pos, val;
{
	if (chinln[pos].fg & 0x04) {			/* accent bit ?	*/
		chinln[pos-1].wid -= (val / 2);
		chinln[pos  ].wid -= (val - (val / 2));
	}
	else	chinln[pos].wid -= val;
	if (chinln[pos].wid < 0)
		chinln[pos].wid = 0;
	clen -= val;
}

loadrval()
{
	union {
		unsigned char	arr[6];
		unsigned	val[3];
	} rvo;
	f_move(pftpt + 45,rvo.arr,6);
	topval = rvo.val[2] - rvo.val[0];	/* rvo top window value	*/
	botval = rvo.val[1] - rvo.val[2];	/* rvo bot window value	*/
}

ad_dp()
{
	cdep += cp.lnsp;				/* add LSpace	*/
	funct_comm(ver_mov_for,(unsigned)cp.lnsp);	/* move down	*/
}

rev_video(mode)
int	mode;
{
	funct_comm(hor_pos,disp);
	funct_comm(rev_typ,mode);
}

set_rev_par()
{
	unsigned long	temp1, temp2;

	if (rvopsiz) {
	  temp1 = ((long)rvopsiz * (long)topval * 3L) / 2084L;
	  temp2 = ((long)rvopsiz * (long)botval * 3L) / 2084L;
	  if ((temp1 + (long)pvbot) <= (long)pvlsp) {
		temp1 = (long)pvlsp - (long)pvbot;
		temp2 = ((long)pvlsp / 2L) - (long)temp2;
	  }
	  funct_comm(rev_wind_top,(unsigned)temp1);
	  funct_comm(rev_wind_bot,(unsigned)temp2);
	  pvbot = (unsigned)temp2;
	}
	else {
	  funct_comm(rev_wind_top,0);
	  funct_comm(rev_wind_bot,0);
	}
	rev_video(ON);
}

static	to_new_y()
{
	unsigned long	new_y;

	new_y = init_y + cp.lnsp;
	if (new_y > last_y)
		funct_comm(ver_mov_for,
			(unsigned)(new_y - last_y));	/* move forward	*/
	else
	if (new_y < last_y)
		funct_comm(ver_mov_rev,
			(unsigned)(last_y - new_y));	/* move bckward	*/
}

in_cmmd(funct,arg)
int		funct;
unsigned long	arg;
{
	chinln[ccnt  ].fg	= 0;
	chinln[ccnt  ].ch	= CMDCH;	/* store Tag command	*/
	chinln[ccnt++].wid	= funct;	/* store functN type	*/
	cmdrec[cmdcnt++]	= arg;		/* store Tag argument	*/
}

IC_cmd(ch,fpmode)
unsigned char	ch, fpmode;
{
	chinln[ccnt].fg  = 1;
	chinln[ccnt].ch  = IC;			/* store IC command	*/
	chinln[ccnt].wid = 0;			/* no width for IC cmd	*/
	if (!fpmode && ch == ' ') {
		++ccnt;
		++ispcnt;
		chinln[ccnt].ch  = SPC;		/* store SPC (space)	*/
		chinln[ccnt++].wid = 0;		/* no width for IC cmd	*/
	}
	else {
		ichpos[ichcnt++] = ++ccnt;	/* pos to be inserted	*/
		cmpval = avcval = 0;		/* no CComp for IChar	*/
		ichfg = 1;			/* set IC flag before	*/
		if (fpmode)
			storech(ch);
		else	bcwidth(ch);		/* setting up ch width	*/
	}
}

static	BEfct0()
{
	int	i;

	i = setp.omod;
	i <<= 8;
	i += get_pgtype();
	funct_comm(st_take,i);			/* place Start of Take	*/
	funct_comm(USRPGN,1);			/* place Start Page #	*/
	funct_comm(SLVEOB,0);			/* place End Of Block	*/
	last_y = 0L;
}

static	BEfct1()
{
	funct_comm(SLVEOD,0);			/* place End Of Data	*/
}

static	BEfct2()
{
	if (last_y > 0)				/* move to top page	*/
		funct_comm(ver_mov_rev,(unsigned)last_y);
	funct_comm(SLVEOB,0);			/* place End Of Block	*/
	last_y = 0L;
}

static	BEfct3()
{
	funct_comm(next_pg,0);			/* use GOG next page	*/
	funct_comm(SLVEOB,0);			/* place End Of Block	*/
	last_y = 0L;
}

static	BEfct4()				/* For graphics mode 5	*/
{
	funct_comm(graphic,TYF_Gtype);		/* insert VP command	*/
	funct_comm(SLVEOB,0);			/* place End Of Block	*/
}

static	BEfct5()				/* For other gr. modes	*/
{
	int	fbuff[5];

	funct_comm(graphic,TYF_Gtype);		/* insert VP command	*/
	fbuff[0] = strlen(TYF_Gfile) + 11;	/* place count	*/
	fbuff[1] = TYF_Gx0;			/* place x0	*/
	fbuff[2] = TYF_Gy0;			/* place y0	*/
	fbuff[3] = TYF_Gx1 - TYF_Gx0 + 1;	/* place Width	*/
	fbuff[4] = TYF_Gy1 - TYF_Gy0 + 1;	/* place Height	*/
	movcmds(fbuff,10);
	movcmds(TYF_Gfile,fbuff[0] - 10);	/* place filename	*/
	funct_comm(SLVEOB,0);			/* place End Of Block	*/
}

static	ins_slave(fct)
int	(*fct)();
{
	struct textobj	temp;

	temp.slvlist = (struct slvll *)0;
	setslvlist(&temp);
	if (cpabt)
		return(0);
	Bslv	= slv;
	utinpt	= Bslv->bufptr;			/* init slave pointer	*/

	(*fct)();				/* do slave function	*/

	if (cpabt)
		return(0);
	else	return(writeslv(temp.slvlist));
}

Start_TYF()
{
	return(ins_slave(BEfct0));
}

End_TYF()
{
	return(ins_slave(BEfct1));
}

topPge_TYF()
{
	return(ins_slave(BEfct2));
}

newPge_TYF()
{
	return(ins_slave(BEfct3));
}

insGR_TYF(op,count,glgrattr)
int	op, count;
int	glgrattr[];
{
	int	fbuff[7];

	if (TYF_Gtype == 5) {			/* For graphics mode 5	*/
	  if (!ins_slave(BEfct4))		/* insert VP command	*/
		return(0);
	  fbuff[0] = 36 + (4 * count);	/* count  + x0 + y0 + width +	*/
	  				/* height + op + pts count +	*/
					/* glgrattr + points		*/
	  fbuff[1] = TYF_Gx0;			/* place x0	*/
	  fbuff[2] = TYF_Gy0;			/* place y0	*/
	  fbuff[3] = TYF_Gx1 - TYF_Gx0 + 1;	/* place Width	*/
	  fbuff[4] = TYF_Gy1 - TYF_Gy0 + 1;	/* place Height	*/
	  fbuff[5] = op;			/* place opcode	*/
	  fbuff[6] = count;
	  Fwrite(TYF_handle,14L,fbuff);
	  Fwrite(TYF_handle,22L,glgrattr);
	  Fwrite(TYF_handle,(long)(4L*(long)count),ptsarray);
	  return(1);
	}
	else	return(ins_slave(BEfct5));
}

writeslv(slvlist)
struct	slvll	*slvlist;
{
	struct	slvll	*slvptr = slvlist;
	int		cnt, retc = 1;

	if (slvptr != (struct slvll *)0L) {
	  for (;;) {
		cnt = countslaveB(slvptr->bufptr);
		if (cnt && write(TYF_handle,slvptr->bufptr,cnt) != cnt)
		{	retc = 0; break;	}
		if (slvptr->fptr == (struct slvll *)0L)
			break;
		else	slvptr = slvptr->fptr;
	  }
	  freeslvlist(slvlist);
	}
	return(retc);
}

/*
*/
countslaveB(sptr)
unsigned char	*sptr;
{
	unsigned char	command, *eptr;
	unsigned	code, brk, cmd_len, cnt;

	brk = cnt = 0;
	eptr = sptr + UTSIZE;
	do {
	  code = get_argument(sptr);	/* get encoded word	*/
	  if (!(code & 0xFF00))		/* check if NULL cmd	*/
		cmd_len = 1;
	  else	cmd_len = 3;
	  if ((code & 0x8080) == 0x8080) {
	    command = *sptr & 0x7f;
	    switch (command) {
	    case (SLVEOD):			/* end of data	*/
		brk = 1;	break;
	    case (SLVEOB):			/* end of block	*/
		brk = 2;	break;
	    case (ty_face):			/* font command	*/
		cmd_len = 9;	break;
	    case (graphic):			/* VP command	*/
		if (*(sptr+2) < 5)
		  cmd_len += get_argument(sptr+3);
		break;
	    }
	  }
	  sptr += cmd_len;
	  if (brk != 2)
		cnt += cmd_len;
	} while (!brk && sptr < eptr);
	return(cnt);
}
