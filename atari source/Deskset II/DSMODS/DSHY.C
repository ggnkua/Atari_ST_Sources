#include	"dshy.h"
#include	"comp.h"

extern	unsigned char	*Xdict_srch();

char	RULE_LD, SAV_RULE, DICT_LD;
struct	{				/* Henry Nguyen 6/15/88		*/
	char	hyin;			/* # of char before hyphen	*/
	char	hyut;			/* # of char after  hyphen	*/
}	HY;			/* To avoid conflict with cp struct	*/

/********************************************************/
/*	ENTRY POINT FOR ATARI AUTOMATIC HYPHENATION     */
/********************************************************/
/*
	ON EXIT:

	hyph_index =  Number of hyphenation points found

	HY_TYPE = 1, EM or EN dash found
	HY_TYPE = 2, hard hyphen found
	HY_TYPE = 3, (EM or EN) AND hard hyphen found
	HY_TYPE = 4, DH found
	HY_TYPE = 0, none of above found (logic hyphenation)
*/	
hypchk(sp,ep)
unsigned char *sp, *ep;
{
	unsigned int  *ofsptr, chrcnt, nohcnt;
	unsigned char nohyph, c, ct, *wrkptr, wrd_lngth;

	HY.hyin = cp.nbefhyp;		/* # of char before hyphen	*/
	HY.hyut = cp.nafthyp;		/* # of char after  hyphen	*/
	wrkptr = bgnptr = sp;
	endptr = ep;
	wrkend = wrdbuf;
	ofsptr = hyofs;
	dashct = HY_TYPE = DHfnd = MNdash = 0;
	hypcnt = ct = nohyph = cmd_lngth = 0;
	nohcnt = hyph_index = chrcnt = 0;
	while (wrkptr < endptr && dashct < 65) {
	  c = *wrkptr++;
	  if (tagc(c)) {			/* to be redone...	*/
	    chrcnt += 2; ++wrkptr; continue;
	  }
	  else if (c == DH || c == '-' || c == MDASH || c == NDASH) {
	    cmd_lngth = 0; MNdash = 1; ++nohyph; 	    
	    if (c == DH) {
	      if (hypcnt) {
	        for (ct = 0;ct < hypcnt;++ct) {
		  if (!(hyphens[ct] & 0x80)) hyphens[ct] = 255;
		}
	      }
	      hyphens[hypcnt++] = ((nohcnt - 1) | 0x80);
	      *ofsptr = (chrcnt + 1);
	      DHfnd = 1; HY_TYPE = 4;
	    }
	    else if (!DHfnd) {
		if (c == '-') HY_TYPE |= 2;
		else	      HY_TYPE |= 1;
		hyphens[hypcnt++] = (nohcnt - 1);
		*ofsptr = (chrcnt + 1);
	    }
	    else continue;
	    ++hyph_index; ++chrcnt;
	  }
	  else {
	    if (halpha(c)) {
		++alphact;
		if (c < 0x80) c |= ' ';
	    }
	    else {
		if (!alphact) c = 0;
		else ++nohyph;
	    }
	    *wrkend++ = c; *wrkend = 0;
	    if (MNdash) {
		*ofsptr++ = (chrcnt - cmd_lngth);
		++chrcnt;
		MNdash = 0;
	    }
	    else *ofsptr++ = chrcnt++;
	    ++nohcnt; ++dashct;
	  }
	}
	if (nohyph) {
	  while (!(halpha(*(wrkend - 1)))) {
	    --wrkend; --nohyph;
	  }
	}
	wrd_lngth = (wrkend - wrdbuf);
	--wrkend;
	if (wrd_lngth >= (HY.hyut + HY.hyin)) {
	  if (!nohyph) {
	    if (DICT_LD && (xptr = Xdict_srch(wrdbuf))) {
	      for (c = ct = 0;*xptr;++xptr,++c) {
	        if (*xptr == '-') {
		  hyphens[ct++] = --c; ++hyph_index;
	        }	
	      }
	    }
	    else {
	      if (RULE_LD) rule_hyph(wrdbuf,wrkend);
	    }
	  }
	}
	if (hyph_index) set_ptrs(wrd_lngth,nohyph);
}

set_ptrs(wrd_lngth,nohyph)
unsigned char wrd_lngth, nohyph;
{
	unsigned char ct, **WRK_HYPH_PTR;
	unsigned int  cnt, *ofsptr, *tmptr;

	WRK_HYPH_PTR = hyptr;
	ofsptr = hyofs;
	ct = 0;
	cnt = hyph_index;
	if (!nohyph) {
	  if (wrd_lngth < HY.hyut) {
	    wrd_lngth = HY.hyut;
	    HY.hyin = 0;
	  }
	  else wrd_lngth -= HY.hyut;
	}
	while (cnt) {
	  if (hyphens[ct] == 0xff) {
	    --cnt; --hyph_index; ++ct;
	    continue;
	  }
	  hyphens[ct] &= 0x7f;			/* strip upper bit */
	  if (!HY_TYPE) {
	    if ((hyphens[ct]+1) < HY.hyin ||
	      (hyphens[ct]+1) > wrd_lngth) {
	      --hyph_index; ++ct; --cnt; continue;
	    }
	  }
	  tmptr = hyofs;
	  tmptr += hyphens[ct]+1;
	  *WRK_HYPH_PTR++ = (bgnptr + *tmptr);
	  ++ofsptr; --cnt; ++ct;
	} 
}

/*
	Exception Dictionary loading routine
*/
ldict(file_ID)
unsigned int file_ID;
{
	if (read(file_ID,X_BUF,XDSIZ) < 0)
	     DICT_LD = 0;
	else DICT_LD = 1;
	close(file_ID); return(DICT_LD);
}

unsigned char *Xdict_srch(s)
char *s;
{
	unsigned char *xwrdptr, *jmp_ptr, *srch, *trgt;
	unsigned int *xofsptr;

	xofsptr = &X_BUF[4];
	xofsptr += ((*s & 0x1f) - 1);
	if (*xofsptr) xwrdptr = (X_BUF + *xofsptr);
	else return(NULP);
	while (*xwrdptr == *s) {
	  jmp_ptr = (xwrdptr - 1);
	  for (srch = s,trgt = xwrdptr;*srch;++srch,++trgt) {
	    if (*trgt == '-') --srch;
	    else if (*srch != *trgt) break;
	  }
	  if (!(*srch)) break;
	  if (*trgt > *srch) return(NULP);
	  xwrdptr += (*jmp_ptr + 2);
	}
	if (*xwrdptr == *s && !(*trgt)) return(xwrdptr);
	else return(NULP);
}

/*
	Function to initialize hyphenation parameters
*/
inithyph()
{
	int	i;
	for (i = 0;i < 65;++i)
		hyptr[i] = NULP;
	RULE_LD = SAV_RULE = DICT_LD = 0;
}
