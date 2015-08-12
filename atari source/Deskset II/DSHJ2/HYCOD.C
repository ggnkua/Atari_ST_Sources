#define		hibit		0x1b
#define		nibit		0x1d
#define		samec		0x1f
#define		ENGLISH		0

extern char	SAV_RULE, RULE_LD, hyphens[];
extern unsigned	hyph_index;

char *hyprul[]= { "Engrul.rul","Frerul.rul","Itlrul.rul","Sparul.rul",
		  "Prtrul.rul","Gerrul.rul","Dutrul.rul","Norrul.rul",
		  "Finrul.rul","Swerul.rul","Danrul.rul" };

unsigned lang_size[11]= { 531,467,493,389,431,1037,1015,747,369,703,1081 };

unsigned char	ttlngth, inlngth, unitbuf[100], cnvrtbuf[100], rulbuf[1100];
unsigned char	*wrdptr, *codptr, *maptr, *clasptr, hyphct, unitofs, *affx;
char		rulnum;
unsigned	*rulptr, fsize;

rule_hyph(bgnptr,endptr)
unsigned char *bgnptr, *endptr;
{
	unsigned char c, c1, ct, nohyph, *tmptr, *savptr, *jmptr;

	rulnum = hyphct = 0;
	maptr = rulptr = rulbuf;
	clasptr = (maptr + 256);

	for (codptr = bgnptr,ct = 0;codptr <= endptr;++codptr,++ct) {
	  c = *codptr; cnvrtbuf[ct] = *(maptr + c);	/* convert to numbers*/
	}
	cnvrtbuf[ct] = 0;
	if (*(clasptr + 61)) {				/* check for units   */
	  strcpy(unitbuf,cnvrtbuf);
	  jmptr = (clasptr + 61);
	  maptr = wrdptr = unitbuf;
	  ct = 0;
	  while (*wrdptr) {	       /* look for vowel and consonant units */
	    while (*jmptr) {
	      tmptr = (jmptr + 1);
	      while (*tmptr == *wrdptr) {
	        ++tmptr; ++wrdptr;
	      }
	      if (!(*tmptr)) {
	        *maptr++ = *(tmptr + 1);
		while (maptr < wrdptr) {
		  *maptr = 0xff; ++maptr;
		}
		--wrdptr; break;
	      }
	      else {
	        wrdptr = maptr;
	        tmptr = jmptr;
	        jmptr += *tmptr;
	      }
	    }
	    maptr = ++wrdptr;
	    jmptr = (clasptr + 61);
	  }
	}
	maptr = rulbuf;
	maptr += fsize;				/* get beginning of ptr list */
	rulptr = maptr;
	rulptr -= 9;					/* get first pointer */
	affx = maptr = wrdptr = cnvrtbuf;
	for (;;) {
	  ++rulnum;
	  while (!(*rulptr) && rulptr <= (rulbuf + fsize)) {
	    ++rulptr; ++rulnum;
	  }						/* find rule offsets */
	  if (!(*rulptr)) break;			/* no more rules     */
	  if (rulnum == 3 && *(clasptr + 61)) {
	    strcpy(cnvrtbuf,unitbuf); maptr = wrdptr = affx;
	  }
	  else if (rulnum == 2) {
	    maptr = wrdptr = affx;	/* point to end of word for suffix   */
	    while (*wrdptr) ++wrdptr;
	    maptr = --wrdptr;
	  }
	  codptr = (rulbuf + *rulptr);
	  savptr = codptr;
	  while (*wrdptr) {
	    if (*wrdptr == 0xff) { ++wrdptr; continue; }
	    nohyph = 1;
	    codptr = savptr;
	    while (*codptr) {
	      tmptr = codptr;
 	      ttlngth = *tmptr++;			/* get total length  */
	      inlngth = *tmptr++;			/* get input length  */
nxtpass:      if (!(*wrdptr)) {
		if (*tmptr == hibit)
		  goto tst_hibit;
		else break;
	      }
	      if (rulnum == 2 && (wrdptr == cnvrtbuf)) break;
	      if (*wrdptr == 0xff) {			/* character in unit */
	         ++wrdptr; goto nxtpass;
	      }
	      if (*tmptr == samec && *wrdptr == *(wrdptr - 1)) {
	        if (rulnum == 2) --wrdptr;
		else		 ++wrdptr;
	        if (++tmptr == (codptr + inlngth)) {
/*printf("\n\nrule number : %d",nohyph);*/
		  if (sethyph(tmptr) || rulnum < 3) {
		    if (rulnum == 2) {
		      maptr = ++wrdptr; *wrdptr = 0;
		      unitbuf[(wrdptr - cnvrtbuf)] = 0;
		    }
		    else  maptr = --wrdptr;
		    break;
		  }
		  goto nodo;
	        }
		else goto nxtpass;
	      }
	      else if (*tmptr & 0x80) {				/* if V, K   */
	        c = *tmptr;
	        c1 = *(clasptr + *wrdptr);
	        if ((c & c1) == c) {
	          if (rulnum == 2) --wrdptr;
		  else		   ++wrdptr;
		  if (++tmptr == (codptr + inlngth)) {
/*printf("\n\nrule number : %d",nohyph);*/
		    if (sethyph(tmptr) || rulnum < 3) {
		      if (rulnum == 2) {
		        maptr = ++wrdptr; *wrdptr = 0;
		        unitbuf[(wrdptr - cnvrtbuf)] = 0;
		      }
		      else  maptr = --wrdptr;
		      break;
		    }
		    goto nodo;
		  }
		  else goto nxtpass;
		}
		else goto nodo;
	      }
	      else if (*tmptr == hibit) {	/* invoke exception test     */
tst_hibit:      c = *(tmptr + 1);
	        if (rulnum == 2) ++wrdptr;	/* increment for suffix	     */
		else		 --wrdptr;
	        jmptr = wrdptr;
	        while (*jmptr == 0xff) --jmptr;
		if ((c & 0x80))
	          c1 = *(clasptr + *jmptr);
	        else {
	          c1 = *jmptr;
	          if (c1 != c)  c = 0x55;		/* force mismatch    */
	        }
	        if ((c & c1) != c) {
	          if (rulnum == 2) --wrdptr;	/* decrement for suffix      */
		  else		   ++wrdptr;
	          if ((tmptr += 2) == (codptr + inlngth)) {
/*printf("\n\nrule number : %d",nohyph);*/
		    if (sethyph(tmptr) || rulnum < 3) {
		      if (rulnum == 2) {
		        maptr = ++wrdptr; *wrdptr = 0;
		        unitbuf[(wrdptr - cnvrtbuf)] = 0;
		      }
		      else  maptr = --wrdptr;
		      break;
		    }
		    goto nodo;
		  }
	          else goto nxtpass;
		}
		else goto nodo;
	      }
	      else if (*tmptr == nibit) {	/* invoke exception test     */
	        c = *(tmptr + 1);
	        c1 = *wrdptr;
	        if (c1 != c) {
	          if (rulnum == 2 && (wrdptr > cnvrtbuf))
	               --wrdptr;		/* decrement for suffix      */
		  else ++wrdptr;
	          if ((tmptr += 2) == (codptr + inlngth)) {
/*printf("\n\nrule number : %d",nohyph);*/
		    if (sethyph(tmptr) || rulnum < 3) {
		      if (rulnum == 2) {
		        maptr = ++wrdptr; *wrdptr = 0;
		        unitbuf[(wrdptr - cnvrtbuf)] = 0;
		      }
		      else  maptr = --wrdptr;
		      break;
		    }
		    goto nodo;
		  }
	          else goto nxtpass;
		}
		else goto nodo;
	      }
	      else if (*tmptr == *wrdptr) {
	        if (rulnum == 2) --wrdptr;	/* decrement for suffix      */
		else		 ++wrdptr;
	        if (++tmptr == (codptr + inlngth)) {
/*printf("\n\nrule number : %d",nohyph);*/
		  if (sethyph(tmptr) || rulnum < 3) {
		    if (rulnum == 2) {
		      maptr = ++wrdptr; *wrdptr = 0;
		      unitbuf[(wrdptr - cnvrtbuf)] = 0;
		    }
		    else  maptr = --wrdptr;
		    break;
		  }
		  goto nodo;
	        }
		else goto nxtpass;
	      }
	      else {
nodo:	        wrdptr = maptr;
	        codptr += ttlngth;
	        ++nohyph;
	      }
	    }					/* end of while (*codptr)    */
	    if (rulnum < 3) break;
	    wrdptr = ++maptr;
	  }					/* end of while (*wrdptr)    */
	  ++rulptr;
	}						/* end of for (;;)   */
	if (hyph_index > 1) seqhyph();
}

sethyph(tmptr)
unsigned char *tmptr;
{
	unsigned char rc, ct, *savptr;

	savptr = wrdptr;
	if (rulnum != 2) { 
	  --savptr; affx = wrdptr;
	}
	rc = 0;
	if (*tmptr & 0x10) rc = 1;
	if (*tmptr & 0x80)
	  ct = (savptr - cnvrtbuf) - (*tmptr & 0x07);
	else
	  ct = (savptr - cnvrtbuf) + *tmptr;
	while (cnvrtbuf[ct + 1] == 0xff) --ct;	/* this is a band aid */
	hyphens[hyphct++] = ct;
	++hyph_index;
	return(rc);
}

llang(rule_number)
unsigned char rule_number;
{
	unsigned char path[100];
	unsigned tab_ID;

	RULE_LD = rule_number;
	if (!findfile(hyprul[(RULE_LD-1)],path)) {
	  RULE_LD = SAV_RULE; return(1);
	}
	if ((tab_ID = open(path,0)) == -1) {
	  RULE_LD = SAV_RULE; return(1);
	}
	if ((read(tab_ID,rulbuf,1100)) == -1) {
	  close(tab_ID); SAV_RULE = RULE_LD = 1; return(1);
	}
	fsize = lang_size[RULE_LD-1]; fsize += 1;
	close(tab_ID);
	SAV_RULE = RULE_LD;
	return(0);
}

seqhyph()
{
	char tmphyp[120], wrkct, ct, hyct;

	for (ct = 0;ct < hyph_index;++ct)
	  tmphyp[ct] = hyphens[ct];
	for (ct = 0,hyct = 0;ct < hyph_index && hyct < 64;++hyct) {
	  wrkct = 0;
	  while (wrkct < hyph_index) {
	    if (tmphyp[wrkct] == hyct) {
	      hyphens[ct++] = hyct; break;
	    }
	    ++wrkct;
	  }
	}
	hyph_index = ct;
}

/*
	Routine to check if character "c" is a hyphenation alphabet.
	True returns 1 else 0.
*/
halpha(c)
unsigned char	c;
{
	return(	(c >= 'A' && c <= 'Z')||(c >= 'a' && c <= 'z')||
		(c >= 128 && c <= 154)||(c >= 160 && c <= 167)||
		(c >= 176 && c <= 184)||(c == 158) );
}
