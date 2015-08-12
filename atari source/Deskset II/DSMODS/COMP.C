/*****************************************************************************/
/* HISTORY:								     */
/*									     */
/*		bwdct()							     */
/* 11/10/89  -  fwdct()     - Added cpabt = 0;				     */
/*		              Problems resulted in that the routine doesn't  */
/*			      clear the flag if no errors occur, thereby     */
/*			      leaving the old state in the flag.	     */
/*****************************************************************************/
#include	"defs.h"
#include	"comp.h"

#define		DEBUG		0

#define		Fac		4	/* Floating Accent bit mask	*/
#define		MIN_LEFT	10	/* minimum text buffer left	*/

extern  char		*savecptr;

extern	unsigned char	HY_TYPE, fofg;
extern	unsigned	hyph_index;
extern	unsigned char	getfp(), *bwdct(), *prvp1(), *prvp2(), *prvp3(),
			getLch();

/*	Locals		*/
static	unsigned	hypn = 0;	/* hyphenated line counter	*/
	unsigned char	*hyptr[65];

#if	DEBUG == 1
	static	char	hbf[80];
	static	char	*bfp, *hp1, *hp2;
#endif

/*
	Batch Composition & Line Break processor.
	Only called by dotext(). Returns pointer to next text
	if cpabt is 0 or 8 else -1L for all other true values
	of cpabt.
*/
unsigned char	*fend(text,done)
struct textobj	*text;
int		*done;
{
	unsigned char	*cptr;

	cpabt = 0;				/* no error so far...	*/
	if (current_char >= buf_end) {	
		*done = 1;
		return(-1L);
	}					
	cptr		= savecptr;
	buf_ptr[COMP]	= buf_end;
	initfcmp();
	movtotag(&cptr,COMP);
	if (cpabt == -1)			/* reach break depth	*/
		cpabt = 0;			/* is not an error...	*/

	if (!cpabt || cpabt == 8) {		/* no error or hit Rf	*/
		*done = (cptr >= buf_end);
		savecptr = cptr;
		cptr = free_start + (long)(cptr - current_char);
	}
	else {
		CPrewindow(buf_end);
		CPrewindow(text->begtext);
		savecptr = current_char;
		cptr = (unsigned char *)-1L;
		*done = 0;
	}
	return(cptr);
}

/*
	Function to forward batch compose to tagged point of buffer. Set
	cpabt:	8	-- Hit Region Feed
		-1	-- reach defined break depth
	Note:	Above true values except (-1) will be saved in cpabt flag.
*/
movtotag(ptr,tag)
unsigned char	**ptr;
int		tag;
{
	unsigned char	em, rsovsp, c;
	unsigned	hyw;

#if	DEBUG == 1
	printf("\nIn movtotag..");
	printf("\ncp.ll=%d cp.d=%ld cp.ls=%ld",cp.llen,cp.depth,cp.lnsp);
#endif
	while (!cpabt && *ptr < buf_ptr[tag])
	  switch(c = **ptr) {
	  case hrt: case Rf:
		if (fwdct(ptr))
			break;
		hypn	= 0;
		*ptr	+= 3;
		if (c == Rf)
			cpabt = 8;
		else
		if (advdp())
			cpabt = -1;
		break;
	  case cr:
		*ptr	+= 2;
		break;
	  case srt:
		CPrewindow(*ptr);
		*ptr	+= 3;
		if (tagc(*(free_start-2)))
			em = 1;
		else
		if (*(free_start-1) == sHY) {	/* sHY+srt delete sHY	*/
			CPrewindow(free_start-1);
			--cct;
			if (buf_ptr[OVSP] == current_char)
				rsovsp = 1;
			else
			if (buf_ptr[PRFP] == current_char)
				rsovsp = 2;
			else
			if (buf_ptr[NLTP] == current_char)
				rsovsp = 3;
			else	rsovsp = 0;
			em = 2;
		}
		else	em =	*(free_start-1) == DH	||
				*(free_start-1) == '-'	||
				*(free_start-1) == Mdsh	||	/* EM-	*/
				*(free_start-1) == Ndsh		/* EN-	*/
				? 0:1;
		if (current_char > *ptr)	/* delete srt+cr+lf	*/
			free_start	= *ptr;
		else	current_char	= *ptr;
		CPrewindow(current_char);
		if (em == 1) {			/* adding space mode	*/
			*free_start++	= ' ';
			CPrewindow(free_start-1);
		}
		else
		if (em == 2) {			/* removing (-) mode	*/
			hyw = cwffp(HYfp);
			if (cp.kernmd)
				kerning(HYfp,prvp1(free_start-1),&hyw);
			clen += hyw;
			if (rsovsp == 1)
				setbptr(OVSP);
			else
			if (rsovsp == 2)
				setbptr(PRFP);
			else
			if (rsovsp == 3)
				setbptr(NLTP);
		}
		*ptr = current_char;
		break;
	  case sDH:
		**ptr = DH;
	  case QL: case QR: case QC:
	  case DH:
		++(*ptr);
		break;
	  default:
		if (fwdct(ptr))
			break;
		++(*ptr);
		break;
	  }
}

zerocpptrs()
{
	buf_ptr[NLTP]	= buf_ptr[OVSP]	=
	buf_ptr[PRFP]	= buf_ptr[PRFS]	= 0L;
}

/*
	Function to handle line ending by
	advancing Depth counter by Line Space
*/
advdp()
{
	int	brk;

	if ((cdep + cp.lnsp) >= cp.depth)
		brk	= 1;
	else {
		brk	= 0;
		cdep	+= cp.lnsp;
		clen	= cp.llen;
		smsz	= cp.ssiz;
		lspc	= 0;
		cct	= 0;
		cmpval	= avcval = 0;
		sflg	= inovs = false;
		zerocpptrs();
	}
	return(brk);
}

ckprefsp(p)
char	*p;
{
	if (*p == ' ' && !buf_ptr[PRFS]) buf_ptr[PRFS] = p;
}

ckrgeptr(p,tag)
char	*p;
int	tag;
{
	if (!buf_ptr[tag]) buf_ptr[tag] = p;
}

/*
	Function to advance line length counter by decreasing it by
	the present character width.
	Returns 1 if width is > Line Length else 0.
*/
advll(cw,p)
int	cw;
char	*p;
{
	unsigned	ccnt;
	int		tlen, rc;

	rc = 0;
	if (!sflg && !inovs) {
	  if (cw > (int)clen) {
		if (cp.jstmd == AJ)
			sflg = 1;
		else	goto ovs;
	  }
	  else	goto chk;
	}
	if (sflg == 1) {
	  tlen = clen + (cwfrw(cp.prfsp,1) * lspc);
	  if (tlen < 0 || cw > tlen) {
		if (cp.ltsmd)
			sflg = 2;
		else {
			sflg = 0;
			goto ovs;
		}
	  }
	  else {
		ckrgeptr(p,PRFP);
		ckprefsp(p);
		goto nor;
	  }
	}
	if (sflg == 2) {
	  ccnt = cct ? cct - 1:0;
	  tlen = clen + (cwfrw(cp.prfsp,1) * lspc) +
			(cwfrw(cp.nlts,1) * ccnt);
	  if (tlen < 0 || cw > tlen) {
		sflg = 0;
		goto ovs;
	  }
	  ckrgeptr(p,NLTP);
	  ckprefsp(p);
	}
	else
chk:	if (inovs || (int)clen < 0)
ovs:		rc = 1; 
nor:	clen -= cw;
	return(rc);
}

/*
	Function to find the present justification status
	after moving backward.
*/
findst()
{
	unsigned	ccnt;
	int		tlen;

	if ((int)clen < 0) {
	  if (cp.jstmd != AJ)
		goto ovs;
	  tlen = clen + (cwfrw(cp.prfsp,1) * lspc);
	  if (tlen >= 0) {
		sflg	= 1;
		inovs	= 0;
	  }
	  else 
	  if (cp.ltsmd) {
		ccnt = cct ? cct - 1:0;
		tlen += cwfrw(cp.nlts,1) * ccnt;
		if (tlen >= 0) {
			sflg	= 2;
			inovs	= 0;
		}
		else	goto ovs;
	  }
	  else {
ovs:		sflg	= 0;
		inovs	= 1;
	  }
	}
	else	sflg = inovs = 0;
}

/*
	Function to test for short line length
*/
cksll(cw)
int	cw;
{
	return(!cct && cw > (int)clen);
}

/*
	Function to do forward counting on the character at pointer. Set
	cpabt:	0	-- no error
		1	-- char has no flash position
		2	-- double floating accent found
		3	-- double space char found
		4	-- line measure too short
		5	-- line break error (no space)
		6	-- text buffer full
		7	-- no memory for tag support
		-1	-- reach defined break depth
	Note:	Above true values except (-1) will be saved in cpabt flag.
*/
fwdct(nptr)
unsigned char **nptr;
{
	unsigned	i, cw, hyw, hycnt;
	unsigned char	*ptr, *scc, *hyp, *ewp;
	unsigned char	ccfp, hymd, cc;
	char		ishy, nobrk, rshypn, fafg, sp_lts, fnd;

/*	cpabt   = 0;*/
	ptr	= *nptr;
	cw	= 0;
	sp_lts	= 0;
	if (*ptr == STAG)			/* Hit a Start	TAG	*/
		in_tag(*(++*nptr),1,1);
	else
	if (*ptr == ETAG)			/* Hit an End	TAG	*/
		out_tag(*(++*nptr),1,1);
	else
	if (fofg) {				/* validate Flash only	*/
		if (*ptr == sHY || !nofa(ptr,&ccfp))
			goto bdchr;
		else {
			fofg = false;
			goto extst;
		}
	}
	else
	if (*ptr == ' ') {			/* Hit a Spaceband	*/
		if (ptr > current_char) {	/* get prev. char pter	*/
		  ewp = ptr-1;			/* in 2nd partition	*/
		  while (ewp > current_char && tagc(*(ewp-1))) {
			if (ptagc(*(ewp-1))) {
				--ewp;
				break;
			}
			else	ewp -= 2;
		  }
		  if (ewp < current_char)
			goto prvbf;
		}
		else
prvbf:		  ewp = prvp3(free_start-1);	/* or 1st partition	*/
		if (*ewp == ' ') {
			cpabt = 3;		/* double Spaces !	*/
			goto abort;
		}
		cw = cwfrw(spbval,0);
		if (cksll(cw)) {
sllen:			cpabt = 4;		/* short LineLen !	*/
			goto abort;
		}
		if (sflg == 2) {
			sp_lts = 1;
			goto mkbrk;
		}
	}
	else {
	  if (ptr > current_char)		/* get prev. char pter	*/
		scc = prvp2(ptr-1);		/* for Kerning & CComp	*/
	  else	scc = prvp1(free_start-1);
	  if (*ptr == sHY) {			/* Hit a Soft Hyphen	*/
		cw = cwffp(HYfp);
		if (cp.kernmd)
			kerning(HYfp,scc,&cw);
		++cct;
	  }
	  else
	  if (!allend(*ptr)) {			/* not a line ending...	*/
		fafg = gfpfa(&ccfp,ptr);
		if (ccfp == 255) {
bdchr:			cpabt = 1;		/* not valid char !	*/
			goto abort;
		}
		if (fafg && cpch(scc) && gfpfa(&fnd,scc)) {
			cpabt = 2;
			goto abort;		/* double Float Accent!	*/
		}
		if (!fafg) {
			ckcomp(scc);
			if ((cw = cwffp(ccfp)) == -1)
				goto bdchr;
			if (cp.kernmd)
				kerning(ccfp,scc,&cw);
			if (cksll(cw))
				goto sllen;
			++cct;
		}
	  }
	}
exchk:	if (advll(cw,ptr)) {			/* reach or in OVerSet	*/
#if	DEBUG == 1
	printf("\nIn OVS cw=%d ptr=%lx c=%c",cw,ptr,*ptr);
#endif
		if (!inovs) inovs = true;
		if (buf_ptr[OVSP] == 0L) {		/* save 1st OVS ptr  */
			buf_ptr[OVSP] = ptr;
			if (*ptr == ' ' && cp.jstmd != AJ) {
				buf_ptr[PRFP] = ptr;
				++buf_ptr[OVSP];
				goto exfct;
			}
		}
		if (*ptr == sHY && *(ptr+1) == srt)	/* skip sHY + srt... */
			goto exfct;
		if (clen >= 0x8000 && clen <= 0xac78)	/* too OVS force brk */
			goto mkbrk;
		if (*ptr != ' ' && !allend(*ptr))	/* non line break... */
			goto extst;
mkbrk:		if (!nofsp()) {			/* OK... Justify line	*/
#if	DEBUG == 1
  printf("\nB in0: sp_lts=%d bp[PP]?=%d bp[PS]?=%d bp[NP]?=%d",
	sp_lts,(buf_ptr[PRFP] != 0),(buf_ptr[PRFS] != 0),(buf_ptr[NLTP] != 0));
  printf("\nB in1: sflg=%d inovs=%d bp[OV]=%lx *bp[OV]=%c clen=%d cct=%d",
	sflg,inovs,buf_ptr[OVSP],(buf_ptr[OVSP] != 0) ? *buf_ptr[OVSP]:0,
	clen,cct);
#endif
		  inovs	= rshypn = 0;
		  hymd	= hycnt  = 0;
		  nobrk = 0;
		  CPrewindow(scc = ptr);
		  if (sp_lts)
			setbptr(OVSP);
		  else	clen += cw;
		  if (buf_ptr[PRFS])
			goto rmovs;
rebrk:		  hyp = free_start-1;
		  while (hyp > buf_start && !wbrk(hyp))
			hyp = prvp1(hyp) - 1;
		  if (hyp < buf_start)
			hyp = buf_start;
		  cc = getLch(hyp);
		  if (cc == ' ')
			++hyp;
		  else
		  if (cc == cr && getLch(hyp-1) == ' ')
			hyp += 2;
		  else {
			nobrk = 1;
			if (allend(cc))
				hyp += 3;
			else
			if (cc == cr)
				hyp += 2;
			else
			if (cc == lf)
				++hyp;
		  }
		  if (hypn >= cp.nsuchyp || *hyp == DH)
			goto rmovs;
		  CPrewindow(ptr+1);		/* should be OK...	*/
		  hypchk(hyp,ewp=free_start-1);	/* find HY break pts	*/
		  hymd	= HY_TYPE;
		  hycnt = hyph_index;
#if	DEBUG == 1
	hp1 = hyp; hp2 = ewp;
	for (bfp = hbf;hp1 <= hp2;*bfp++ = *hp1++);
	*bfp = 0;
	printf("\nword=%s hycnt=%d hymd=%d *h1=%c succ=%d nobrk=%d",
		hbf,hycnt,hymd,hycnt ? *hyptr[0]:0x7e,hypn,nobrk);
#endif
		  CPrewindow(ewp);		/* should be OK...	*/
rmovs:		  ptr = free_start-1;		/* back out OVS range	*/
#if	DEBUG == 1
	printf("\nBf rmovs.. hyp=%lx *hyp=%c bp[OV]=%lx *bp[OV]=%c",
		ptr,*ptr,buf_ptr[OVSP],*buf_ptr[OVSP]);
#endif
		  while (!cpabt && ptr >= buf_ptr[OVSP])
			ptr = bwdct(ptr);
		  if (cpabt)
			goto abort;
		  hyp = ptr;
#if	DEBUG == 1
	printf("\nAf rmovs.. hyp=%lx *hyp=%c bp[OV]=%lx *bp[OV]=%c",
		hyp,*hyp,buf_ptr[OVSP],*buf_ptr[OVSP]);
#endif
		  if (buf_ptr[PRFS]) {		/* space in Pref range	*/
		    while (!cpabt && ptr > buf_ptr[PRFS])
			ptr = bwdct(ptr);
		    if (cpabt)
			goto abort;
#if	DEBUG == 1
	printf("\nSp Pref... ptr=%lx *ptr=%c cc=%lx *cc=%c",
		ptr,*ptr,current_char,*current_char);
#endif
brksp:		    if (getLch(ptr) == lf) --ptr;
		    CPrewindow(ptr);
		    ptr = current_char;
		    if (*ptr == ' ') {
			CPrewindow(ptr+1);
			--free_start;
		    }
		    else
		    if (*ptr == cr && getLch(free_start-1) == ' ')
			--free_start;
		    else {
			cpabt = 5;		/* no line break !	*/
			goto Equit;
		    }
		    --lspc;
		    clen += cwfrw(spbval,0);
		    if (hypn) rshypn = 1;
		  }
		  else
		  if (!hycnt || (!hymd && !cp.hypmd)) {	/* no HYphenation... */
		    if (sp_lts) {		/* space in -Lts range	*/
ltssp:			scc = ++current_char;
			CPrewindow(scc);
			cw = 0;
			if (hypn) rshypn = 1;
		    }
		    else {
nohyp:			if (*(ptr+1) == lf) ++ptr;
			CPrewindow(ptr+1);
			if (!nobrk) {		/* space in Just range	*/
			  ptr = free_start-1;
			  while (!cpabt && ptr > buf_start && !wbrk(ptr))
				ptr = bwdct(ptr);
#if	DEBUG == 1
	printf("\nSp Just... ptr=%lx *ptr=%c cc=%lx *cc=%c",
		ptr,*ptr,current_char,*current_char);
#endif
			  if (cpabt)
				goto abort;
			  else	goto brksp;
			}
			if (nobrk	== 2		||
			    free_start	== buf_start	||
			    cct		< 2) {
				cpabt = 4;	/* short linelen !	*/
				goto Equit;
			}
#if	DEBUG == 1
	printf("\nDesperate HY..");
#endif
			hyp	= free_start-1;	/* where to rewind...	*/
			ptr	= prvp3(hyp);
			if (ptr > buf_start) {	/* set desperate HY pts	*/
				hyptr[1]= ptr;
				hyptr[0]= prvp3(--ptr);
				hycnt	= 2;
			}
			else {
				hyptr[0]= ptr;
				hycnt	= 1;
			}
			hymd	= 0;
			nobrk	= 2;
			goto brkhy;
		    }
		  }
		  else {
		    while (hycnt && (hyptr[hycnt-1]-1) > hyp)
			--hycnt;
#if	DEBUG == 1
	printf("\nB-0 hycnt=%d hyp=%lx *hyp=%c *hyptr[hycnt-1]=%c",
		hycnt,hyp,*hyp,hycnt ? *hyptr[hycnt-1]:0x7e);
#endif
		    if (!hycnt)
			goto nohyp;
		    if (cp.jstmd == AJ) {
			if (!buf_ptr[NLTP] || buf_ptr[NLTP] > hyp)
				buf_ptr[NLTP] = hyp;
			fnd = 0;
			if (!buf_ptr[PRFP])
				goto nltshy;
			for (i = 0;!fnd && i < hycnt;++i)
			if (hyptr[i] >= buf_ptr[PRFP] &&
			    hyptr[i] < buf_ptr[NLTP])
				fnd = 1;
			if (fnd)
				hycnt = i;
			else {
nltshy:			  for (i = 0;!fnd && i < hycnt;++i)
			  if (hyptr[i] >= buf_ptr[NLTP] &&
			      hyptr[i] <= hyp)
				fnd = 1;
			  if (fnd)
				hycnt = i;
			  else
			  if (sp_lts)
				goto ltssp;
			}
		    }
brkhy:		    for (;;) {
#if	DEBUG == 1
	printf("\nB-1 hycnt=%d *hyp=%c *hyptr[hycnt-1]=%c",
		hycnt,*hyp,hycnt ? *hyptr[hycnt-1]:0x7e);
#endif
			while (!cpabt && hyp >= hyptr[hycnt-1])
				hyp = bwdct(hyp);
			ptr = hyp;
			if (cpabt)
				goto abort;
			if (!(hymd & 3)) {
			  hyw = cwffp(HYfp);
			  if (cp.kernmd)
				kerning(HYfp,prvp1(hyp),&hyw);
			  clen -= hyw;
			}
			findst();
#if	DEBUG == 1
	printf("\nB-2 sflg=%d inovs=%d clen=%d cct=%d lspc=%d *hyp=%c",
		sflg,inovs,clen,cct,lspc,*hyp);
#endif
			if (!inovs) {
			  CPrewindow(hyp+1);		/* should be OK...   */
			  ewp = prvp1(free_start-1);
			  if (hymd & 3) {		/* Hard - or M-,N-.. */
			    if (setp.hylg == 5 &&
				*ewp == '-') {		/* Portuguese Hard - */
				CPrewindow(ewp);	/* bring Hard - down */
				goto inshy;		/* & insert Soft -.. */
			    }
			    else {
				ishy = 0;
				rshypn = 1;
			    }
			  }
			  else
			  if (*ewp == DH) {		/* Disc hyphen found */
				ishy = 1;
				*ewp = sDH;
				clen += hyw;
			  }
			  else {			/* place Soft hyphen */
inshy:				ishy = 1;
				*free_start++ = sHY;
			  }
			  if (ishy) {
				++hypn;
				rshypn = 0;
			  }
			  break;
			}
			else
			if (!(hymd & 3))
				clen += hyw;
			if (!--hycnt) goto nohyp;
		    }
		  }
		  *free_start++ = srt;			/* insert srt/cr/lf  */
		  ckcrlf();
#if	DEBUG == 1
	printf("\nEnd B.. cct=%d\n",cct);
#endif
		  if (rshypn) hypn = 0;
		  if (advdp()) {			/* down line space   */
			cpabt = -1;			/* reach depth stop  */
			goto Equit;
		  }
		  ptr		= current_char;
		  buf_ptr[CPBK] = scc;
		  movtotag(&ptr,CPBK);
		  if (cpabt)
			goto Equit;
		  CPrewindow(buf_ptr[CPBK]);
		  if (inovs) {
			scc	= current_char;
			hymd	= hycnt	= 0;
			rshypn	= sp_lts= 0;
			nobrk	= 0;
#if	DEBUG == 1
	printf("\nStill OVS..Rebreak.. inovs=%d\n",inovs);
#endif
			goto rebrk;
		  }
		  if (!sp_lts) {
			*nptr	= current_char;
			if (nofa(ptr = *nptr,&ccfp))
				++cct;
			goto exchk;
		  }
		  else	*nptr	= current_char-1;
		}
		else {
			clen += cw;
			cpabt = 6;		/* text buffer full !	*/
abort:			if (getLch(ptr) == lf) ++ptr;
			CPrewindow(ptr);
Equit:			*nptr = current_char;
		}
	}
	else
	if (*ptr == ' ')
		++lspc;
	else
extst:	if (ptagc(*ptr))			/* Hit a PI	TAG	*/
		ptr = ++*nptr;
exfct:
#if	DEBUG == 1
  printf("\nFwct sflg=%d inovs=%d clen=%d cw=%d lspc=%d cct=%d ptr=%lx c=%c",
		sflg,inovs,clen,cw,lspc,cct,ptr,*ptr);
#endif
	return(cpabt);				/* return CP state...	*/
}

/*
	Function to do backward counting on the character at pointer
*/
unsigned char *bwdct(ptr)
unsigned char *ptr;
{
	unsigned	cw;
	unsigned char	ccfp, *pc, *pcp;

/*	cpabt = 0;*/
	pc = prvp1(ptr);
	if (*pc == STAG)			/* Hit a Start	TAG	*/
		out_tag(*ptr,1,0);
	else
	if (*pc == ETAG)			/* Hit an End	TAG	*/
		in_tag(*ptr,1,0);
	else
	if (ptagc(*pc)) {			/* Hit a PI	TAG	*/
		ptr = pc;
		pcp = prvp1(pc-1);
		goto nch;
	}
	else
	if (allend(*ptr))
		cpabt = 5;
	else
	if (!nocp(*ptr)) {
	  pcp = prvp1(pc-1);
	  if (*ptr == sHY) {
		ckcomp(pcp);
		cw = cwffp(HYfp);
		if (cp.kernmd)
			kerning(HYfp,pcp,&cw);
		if (cct) --cct;
	  }
	  else
	  if (*ptr == ' ') {
		cw = cwfrw(spbval,0);
		if (lspc) --lspc;
	  }
	  else
nch:	  if (!gfpfa(&ccfp,ptr)) {
		ckcomp(pcp);
		cw = cwffp(ccfp);
		if (cp.kernmd)
			kerning(ccfp,pcp,&cw);
		if (cct) --cct;
	  }
	  else	cw = 0;
	  clen	+= cw;
	}
#if	DEBUG == 1
	printf("\nBwct sflg=%d inovs=%d clen=%d cw=%d lspc=%d cct=%d p=%lx c=%c",
		sflg,inovs,clen,cw,lspc,cct,ptr,*ptr);
#endif
	return(--pc >= buf_start ? pc : buf_start);
}

wbrk(ccp)
unsigned char	*ccp;
{
	unsigned char	pc, cc = getLch(ccp);
	return(	(cc == ' ')	||
		(cc == cr	&&
		((pc = getLch(ccp-1)) == ' ' || allend(pc))) );
}

cpch(ptr)
unsigned char	*ptr;
{
	unsigned char	ch = *ptr;
	return( ptagc	(ch)	||		/* is  a PI TAG or	*/
		(!ctagc	(ch)	&&		/* [not a TAG marker	*/
		ch	!= ' '	&&		/* not a spaceband	*/
		!nocp	(ch)	&&		/* is  a comp. char	*/
		!allend	(ch)) );		/* not a line ending]	*/
}

nofa(ptr,cfp)
unsigned char	*ptr, *cfp;
{
	return(cpch(ptr) && !gfpfa(cfp,ptr));
}

kerning(rfp,lptr,valp)
unsigned char	rfp, *lptr;		/* rfp:right fp, lptr -> left c	*/
int		*valp;			/* valp -> value to (-) kerning */
{
	int		kv;
	unsigned char	lfp;

	if (nofa(lptr,&lfp)) {			/* check left char...	*/
		getkerval(lfp,0);
		getkerval(rfp,1);
		kv = cmpknval();
		if (kv >= *valp)
			*valp = 0;
		else	*valp -= kv;
	}
}

ckcomp(lcp)
unsigned char	*lcp;
{
	int	tst;

	if (!cp.mcomp && !cp.acomp)
		return;
	tst = cpch(lcp);
	if (cp.mcomp)
		cmpval = tst ? cp.mcomp:0;
	if (cp.acomp)
		avcval = tst ? acmp:0;
}

gfpfa(fp,cp)
unsigned char	*fp, *cp;
{
	if (ptagc(*cp))
		*fp = *(++cp);
	else	*fp = getfp(*cp);
	if (*fp != 255)
		return(getfd(50,*fp) & Fac);
	else	return(0);
}

ckcrlf()
{
	if (*current_char != cr) {
		addcrlf();
		CPrewindow(current_char);
	}
	else	CPrewindow(current_char + 2);
}

/*
	Function to test text buffer limit. Returns true/false
*/
nofsp()
{
	return(free_start >= current_char - MIN_LEFT);
}

/*
	Function to intialize all composition parameters for Fend.
*/
initfcmp()
{
	cdep	= cp.lnsp;			/* set start depth	*/
	clen	= cp.llen;			/* set LineLen counter	*/
	smsz	= cp.ssiz;			/* set smallest SetSize	*/
	spbval	= cp.minsp + cp.prfsp;		/* set space value	*/
	HYfp	= getfp('-');
	cmpval	= avcval = 0;
	ckfont(cp.font);			/* set startup font	*/
	sflg	= inovs = false;
	lspc	= cct	= 0;
	zerocpptrs();
}

unsigned char	*prvp1(ptr)
unsigned char	*ptr;
{
	if (ptr > buf_start && tagc(*(ptr-1)))
		--ptr;
	return(ptr);
}

unsigned char	*prvp2(ptr)
unsigned char	*ptr;
{
	if (ptr > current_char && tagc(*(ptr-1)))
		--ptr;
	return(ptr);
}

static
unsigned char	*prvp3(ptr)
unsigned char	*ptr;
{
	while (ptr > buf_start && tagc(*(ptr-1))) {
		if (ptagc(*(ptr-1))) {
			--ptr;
			break;
		}
		else	ptr -= 2;
	}
	if (ptr < buf_start)
		ptr = buf_start;
	return(ptr);
}

unsigned char	getLch(ptr)
unsigned char	*ptr;
{
	ptr = prvp1(ptr);
	return(*ptr);
}
