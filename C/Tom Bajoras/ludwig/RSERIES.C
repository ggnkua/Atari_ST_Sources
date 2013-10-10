/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.

	module:	RSERIES -- rhythm series operations

******************************************************************************/

overlay "play"

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */
#include <osbind.h>          /* GEMDOS, BIOS, XBIOS  */
#include "ludwig.h"          /* created by RCS       */

/* global variables .........................................................*/

#include "externs.h"

/* user-defined rhythm pattern ..............................................*/

rfunc_U(seq,arg)
int seq,arg;
{
	register int *durptr;
	register int i;
	int nnt;

	durptr= (int*)(rhyth1data[arg]);
	nnt= _nntrsts[seq]= durptr[R_NCOLS/2] + 1;
	durptr += R_DUR/2;

	for (i=0; i<nnt; i++) _duration[seq][i]= 12L * (1 + *durptr++);
	copy_bytes(rhyth1data[arg]+R_NTRST,_nt_or_rst[seq],nnt);
	/* this track's legato factor */
	_legato[seq]=  *(int*)(nonr1data[seq]+N_LEGATO);

}	/* end rfunc_U() */

/* dummy function for loops, not called .....................................*/

rfuncdum(seq,arg)
int seq,arg;
{
	;
}	/* end rfuncdum() */

/* generate random ..........................................................*/

rfunc_R(seq,arg)
int seq,arg;
{
	int *durptr[2],*randiptr;
	char *ntrstptr[2],*randcptr;
	register int i,j;
	int nnt,ntrst;

	/* pointers to randomizer parameters */
	randiptr= (int*)( seq1data[seq] + S_RRAND );
	randcptr= seq1data[seq] + S_RRAND + R_RNSEL;

	/* user groups which we are going to play with */
	ntrstptr[0]=	rhyth1data[arg] + R_NTRST ;
	durptr[0]= (int*)( rhyth1data[arg] + R_DUR ) ;
	i= randiptr[R_RCOPY/2];
	ntrstptr[1]=	rhyth1data[i] + R_NTRST ;
	durptr[1]= (int*)( rhyth1data[i] + R_DUR ) ;

	/* how many note/rests in the result */
	nnt= *(int*)(rhyth1data[arg]+R_NCOLS);
	if (randiptr[R_RNCOL2/2])
	{
		i= random(randiptr[R_RNCOL2/2]);
		switch ( randiptr[R_RNCOL1/2] )
		{
			case 0:	/* up or down */
			if (random(1))
				nnt += i;
			else
				nnt -= i;
			break;
			
			case 1:	/* up */
			nnt += i;
			break;

			case 2:	/* down */
			nnt -= i;
		}
	}
	nnt++;
	if (nnt<1) nnt=1;
	if (nnt>NCHD) nnt=NCHD;
	_nntrsts[seq]= nnt;

	/* build _nt_or_rst[] and _duration[] */
	for (i=0; i<nnt; i++)
	{
		j= randcptr[i];
		if (j==8) j= random(1);
		/* arg 1 duration */
		if ( (j==0) || (j==2) || (j==4) || (j==6) )
			_duration[seq][i]= 12L * (1+durptr[0][i]);
		/* arg 2 duration */
		if ( (j==1) || (j==3) || (j==5) || (j==7) )
			_duration[seq][i]= 12L * (1+durptr[1][i]);
		if ( (j==9) || (j==10) || (j==11) )
			_duration[seq][i]= 12L * (1 + random(31));
		/* note or rest */
		ntrst=0;
		if (j==0) ntrst= ntrstptr[0][i];
		if (j==1) ntrst= ntrstptr[1][i];
		if ( (j==2) || (j==3) || (j==9)  ) ntrst=1;
		if ( (j==6) || (j==7) || (j==11) ) ntrst= random(1);
		_nt_or_rst[seq][i]= ntrst;
	}

	/* order note/rests */
	switch (randiptr[R_RORDER/2])
	{
		/* case 0: left to right */

		case 1:	/* random order, no repeats */
		for (i=1; i<nnt; i++)
			exchntrst(seq,random(nnt-1),random(nnt-1));
		break;

		case 2:	/* right to left */
		rfunc_RV(seq,nnt);
	}
	/* this track's legato factor */
	_legato[seq]=  *(int*)(nonr1data[seq]+N_LEGATO);
}	/* end rfunc_R() */

exchntrst(seq,n1,n2)
int seq,n1,n2;
{
	long templong;
	int ntrst;

	templong= _duration[seq][n1];
	_duration[seq][n1]=	_duration[seq][n2];
	_duration[seq][n2]= templong;

	ntrst= _nt_or_rst[seq][n1];
	_nt_or_rst[seq][n1]= _nt_or_rst[seq][n2];
	_nt_or_rst[seq][n2]= ntrst;

}	/* end exchntrst() */

/* play reverse .............................................................*/

rfunc_RV(seq,arg)
int seq,arg;
{
	char revntrst[NCHD];
	long revdur[NCHD];
	register int i;
	int nnt;

	nnt= _nntrsts[seq];
	if (!arg && nnt) arg= random(nnt-1) + 1;
	nnt= min(arg,nnt);
	for (i=0; i<nnt; i++)
	{
		revntrst[i]= _nt_or_rst[seq][nnt-1-i];
		revdur[i]= _duration[seq][nnt-1-i];
	}
	copy_bytes(revntrst,_nt_or_rst[seq],nnt);
	copy_longs(revdur,_duration[seq],nnt);

}	/* end rfunc_RV() */

/* truncate after ...........................................................*/

rfunc_TA(seq,arg)
int seq,arg;
{
	int nnt;

	nnt= _nntrsts[seq];
	if (!arg && nnt) arg= random(nnt-1) + 1;
	_nntrsts[seq]= min(arg,nnt);

}	/* end rfunc_TA() */

/* truncate before ..........................................................*/

rfunc_TB(seq,arg)
int seq,arg;
{
	int nnt;
	register int i,j;

	nnt= _nntrsts[seq];
	if (!arg) arg= random(nnt);

	for (i=nnt-arg,j=0; i<nnt; i++,j++)
	{
		_nt_or_rst[seq][j]= _nt_or_rst[seq][i];
		_duration[seq][j]= _duration[seq][i];
	}
	_nntrsts[seq]= arg;
}	/* end rfunc_TB() */

/* play even ................................................................*/

rfunc_EV(seq,arg)
int seq,arg;
{
	int nnt;
	register int i,j;

	nnt= _nntrsts[seq];
	if (arg)
	{
		for (i=1,j=0; i<nnt; i+=2,j++)
		{
			_nt_or_rst[seq][j]= _nt_or_rst[seq][i];
			_duration[seq][j]= _duration[seq][i];
		}
		_nntrsts[seq]= j;
	}
	else
		for (i=0; i<nnt; i+=2) _nt_or_rst[seq][i]=0;
}	/* end rfunc_EV() */

/* play odd .................................................................*/

rfunc_OD(seq,arg)
int seq,arg;
{
	int nnt;
	register int i,j;

	nnt= _nntrsts[seq];
	if (arg)
	{
		for (i=2,j=1; i<nnt; i+=2,j++)
		{
			_nt_or_rst[seq][j]= _nt_or_rst[seq][i];
			_duration[seq][j]= _duration[seq][i];
		}
		_nntrsts[seq]= j;
	}
	else
		for (i=1; i<nnt; i+=2) _nt_or_rst[seq][i]=0;
}	/* end rfunc_OD() */

/* no rests .................................................................*/

rfunc_NR(seq,arg)
int seq,arg;
{
	int nnt;
	register int i,j;

	nnt= _nntrsts[seq];
	for (i=j=0; j<nnt; j++)
	{
		if (_nt_or_rst[seq][j])
		{
			_nt_or_rst[seq][i]= _nt_or_rst[seq][j];
			_duration[seq][i]= _duration[seq][j];
			i++;
		}
	}
	_nntrsts[seq]= i ? i : 1;
}	/* end rfunc_NR() */

/* drop .....................................................................*/

rfunc_DR(seq,arg)
int seq,arg;
{
	int nnt;
	register int i;

	nnt= _nntrsts[seq];
	if (nnt<2) return;
	arg= arg ? arg-1 : random(nnt-1) ;
	if (arg<nnt)
	{
		for (i=arg+1; i<nnt; i++)
		{
			_nt_or_rst[seq][i-1]= _nt_or_rst[seq][i] ;
			_duration[seq][i-1]= _duration[seq][i] ;
		}
		_nntrsts[seq]--;
	}
}	/* end rfunc_DR() */

/* substitute rest ..........................................................*/

rfunc_SR(seq,arg)
int seq,arg;
{
	int nnt;

	nnt= _nntrsts[seq];
	if (!nnt) return;
	arg= arg ? arg-1 : random(nnt-1) ;
	if (arg<nnt) _nt_or_rst[seq][arg]=0;
}	/* end rfunc_SR() */

/* exchange .................................................................*/

rfunc_X(seq,arg)
int seq,arg;
{
	register int i,j,n;
	int nnt;
	register long nn;

	nnt= _nntrsts[seq];
	for (i=0; i<nnt-1;)
	{
		n= _nt_or_rst[seq][i];
		j= i+1;

		if (arg)
		{
			if (!n) { i++; continue; }
			while ( !_nt_or_rst[seq][j] && (j<nnt) ) j++;
			if (j==nnt) break;
		}

		_nt_or_rst[seq][i]= _nt_or_rst[seq][j];
		_nt_or_rst[seq][j]= n;

		nn= _duration[seq][i];
		_duration[seq][i]= _duration[seq][j];
		_duration[seq][j]= nn;

		i= j+1;
	}
}	/* end rfunc_X() */

/* again ....................................................................*/

rfunc_A(seq,arg) 
int seq,arg;
{
	register int i,nnt;
	int new_n;

	if (!arg) arg= random(3)+1;
	new_n= nnt= _nntrsts[seq];
	while ( arg*nnt > NCHD ) arg--;
	for (i=1; i<arg; i++)
	{
		copy_bytes(_nt_or_rst[seq],&_nt_or_rst[seq][new_n],nnt);
		copy_longs(_duration[seq],&_duration[seq][new_n],nnt);
		new_n += nnt;
	}
	_nntrsts[seq]=new_n;	
}	/* end rfunc_A() */

/* split ....................................................................*/

rfunc_SP(seq,arg)
int seq,arg;
{
	register int i,nnt;

	if (!arg) arg= random(7)+1;

	nnt= _nntrsts[seq];
	for (i=0; i<nnt; i++)
		_duration[seq][i] = max( _duration[seq][i]/arg , 12L );

	rfunc_EC(seq,arg);
}	/* end rfunc_SP() */

/* echo .....................................................................*/

rfunc_EC(seq,arg)
int seq,arg;
{
	int nnt;
	register char *ntptr;
	register long *durptr;
	char tempnt[NCHD];
	long tempdur[NCHD];
	register int i,j;

	if (!arg) arg= random(31);
	nnt= _nntrsts[seq];
	while ( arg*nnt > NCHD ) arg--;

	ntptr= tempnt;
	durptr= tempdur;
	for (i=0; i<nnt; i++)
	{
		for (j=0; j<arg; j++)
		{
			*ntptr++ = _nt_or_rst[seq][i];
			*durptr++ = _duration[seq][i];
		}
	}
	nnt *= arg;
	copy_bytes(tempnt,_nt_or_rst[seq],nnt);
	copy_longs(tempdur,_duration[seq],nnt);
	_nntrsts[seq]= nnt;
}	/* end rfunc_EC() */

/* mix ......................................................................*/

rfunc_M(seq,arg) 
int seq,arg;
{
	int nnt;
	register int i;
	
	nnt= _nntrsts[seq];
	for (i=1; i<nnt; i+=2)
	{
		_duration[seq][i-1] += _duration[seq][i] ;
		_nt_or_rst[seq][i-1] |= _nt_or_rst[seq][i] ;
	}
	rfunc_OD(seq,1);
}	/* end rfunc_M() */

/* invert ...................................................................*/

rfunc_I(seq,arg)
int seq,arg;
{
	int nnt;
	register int i;

	nnt= _nntrsts[seq];
	if (!arg) arg= random(nnt);
	arg= min(arg,nnt);

	for (i=0; i<arg; i++) _nt_or_rst[seq][i]= !_nt_or_rst[seq][i] ;

}	/* end rfunc_I() */

/* divide/multiply ..........................................................*/

rfunc_DM(seq,arg)
int seq,arg;
{
	int which;
	register int i;
	register long templong;

	which= arg/10;		/* 0 divide, 1 multiply */
	arg %= 10;			/* amount: 1-9, 0 random 1-9 */
	if (!arg) arg= 1+random(8);

	for (i= _nntrsts[seq]-1; i>=0; i--)
	{
		templong= _duration[seq][i];
		_duration[seq][i] = which ? min( 384L , templong*arg ) :
											 max( 12L, templong/arg   ) ;
	}
}	/* end rfunc_DM() */

/* durate ...................................................................*/

rfunc_DU(seq,arg)
int seq,arg;
{
	if (!arg) arg= 1+random(31);		/* # 32nds 1-31 */
	arg*=12;									/* # ticks */
	set_longs(_duration[seq],NCHD,(long)arg);
}	/* end rfunc_DU() */

/* change all to notes or rests .............................................*/

rfunc_RN(seq,arg)
int seq,arg;
{
	set_bytes(_nt_or_rst[seq],NCHD,arg);		/* arg= 1 notes, 0 rests */
}	/* end rfunc_RN() */

/* legato/staccato ..........................................................*/

rfunc_LS(seq,arg)
int seq,arg;
{
	if (!arg) arg= 1+random(98);
	_legato[seq]=arg;
}	/* end rfunc_LS() */

/* pad beyond # beats .......................................................*/

rfunc_PD(seq,arg)
int seq,arg;
{
	long arg_tot,dur_tot;
	int nnt;
	register int i;

	nnt= _nntrsts[seq];
	dur_tot= 0L;
	for (i=0; i<nnt; i++) dur_tot += _duration[seq][i];

	if (!arg) arg= random(31)+1;
	arg_tot= 96L*arg;

	if (arg_tot==dur_tot) return;
	if (arg_tot>dur_tot)
		forceticks(seq,arg_tot);
	else
	{
		for (i=nnt-1; (dur_tot>arg_tot)&&(i>=0); i-- )
		{
			dur_tot -= _duration[seq][i];
			_nt_or_rst[seq][i]=0;
		}
		if (!i) i=1;
		_duration[seq][i-1] += arg_tot-dur_tot;		
	}

}	/* end rfunc_PD() */

/* rotate ...................................................................*/

rfunc_RT(seq,arg)
int seq,arg;
{
	int amt,nnt;
	register int i;
	char tempnt[NCHD];
	long tempdur[NCHD];

	amt= arg%10;
	if (!amt) amt= 1+random(8);		/* amount= 1-9 */
	if (!(arg/10)) amt= -amt;			/* 0= left,1= right */

	nnt= _nntrsts[seq];
	if (nnt>1)
	{
		rotatebytes(_nt_or_rst[seq],tempnt,amt,nnt);
		rotatelongs(_duration[seq],tempdur,amt,nnt);
		copy_bytes(tempnt,_nt_or_rst[seq],nnt);
		copy_longs(tempdur,_duration[seq],nnt);
	}
}	/* end rfunc_RT() */

rotatebytes(from,to,r,n)
register char *from,*to;
int r,n;
{
	register int i,j;

	for (i=0; i<n; i++)
	{
		j= i+r;
		while (j<0) j+=n;
		while (j>=n) j-=n;
		to[j]= *from++;
	}
}	/* end rotatebytes() */

rotatelongs(from,to,r,n)
register long *from,*to;
int r,n;
{
	register int i,j;

	for (i=0; i<n; i++)
	{
		j= i+r;
		while (j<0) j+=n;
		while (j>=n) j-=n;
		to[j]= *from++;
	}
}	/* end rotatelongs() */

/* warp rhythm ..............................................................*/

rfunc_WR(seq,arg)
int seq,arg;
{
	register int i;
	register long templong;

	if (arg/10)		/* half measure swing */
	{
		swing_it(seq,arg%10,arg/10,2);
		return;
	}
	
	if (!arg) arg= 1+random(8);	/* amount 1-9 */
	arg*=2;								/* # ticks */

	for (i= _nntrsts[seq]-1; i>=0; i--)
	{
		templong= _duration[seq][i] + (random(1) ? random(arg) : -random(arg)) ;
		templong= min(384L,templong);
		templong= max(1L , templong);
		_duration[seq][i]= templong;
	}
}	/* end rfunc_WR() */

/* force # of beats .........................................................*/

rfunc_B(seq,arg) 
int seq,arg;
{
	if (!arg) arg= random(31)+1;
	forceticks(seq,96L*arg);
}	/* end rfunc_B() */

forceticks(seq,arg_tot)
int seq;
long arg_tot;
{
	int nnt;
	long dur_tot;
	register int i;

	nnt= _nntrsts[seq];
	dur_tot= 0L;
	for (i=0; i<nnt; i++) dur_tot += _duration[seq][i];
	i= arg_tot/dur_tot;
	if (i>1)
	{
		i= min(i,4);
		rfunc_A(seq,i);
		nnt= _nntrsts[seq];
		dur_tot= 0L;
		for (i=0; i<nnt; i++) dur_tot += _duration[seq][i];
	}
	while (dur_tot>arg_tot) dur_tot -= _duration[seq][--nnt];
	if (!nnt) nnt=1;
	_duration[seq][nnt-1] += arg_tot-dur_tot;		
	_nntrsts[seq]= nnt;

}	/* end forceticks() */

/* randomly drop ............................................................*/

rfunc_RD(seq,arg)
int seq,arg;
{
	if (!arg) arg= random(30)+1;
	arg= min(arg,_nntrsts[seq]-1);
	if (!arg) return;

	for ( ; arg>0; arg--) rfunc_DR(seq,0);

}	/* end rfunc_RD() */

/* random order .............................................................*/

rfunc_RO(seq,arg)
int seq,arg;
{
	int nnt;
	register int i;

	nnt= _nntrsts[seq];
	for (i=1; i<nnt; i++)
		exchntrst(seq,random(nnt-1),random(nnt-1));

}	/* end rfunc_RO() */

/* full measure swing .......................................................*/

rfunc_SW(seq,arg)
int seq,arg;
{
	int i,q;

	i= arg%10;
	if (!i) i= 1+random(8);
	swing_it(seq,i,arg/10,1);
}	/* end rfunc_SW() */

swing_it(seq,percent,q,div)
int seq;
int percent;	/* 1-9 */
int q;			/* 0 , 1-9 */
int div;			/* 1-2 */
{
	int nnt;
	static int qvals[9]= { 384, 192, 288, 96, 144, 24, 36, 48, 72 } ;
	register int i;
	register long t;
	long dur1,dur2,totaldur;

	i= 10*percent;								/* swing percent 10-90 */
	if (!q) q= 1+random(8);
	q= 2*qvals[q-1];							/* # ticks in swung pair */
	dur1= (i*q)/100;							/* how swung pair is divided */
	dur2= q-dur1;

	nnt= _nntrsts[seq]-1;
	for (i=0,totaldur=0L; i<nnt; totaldur += _duration[seq][i++]) ;
	totaldur /= div;

	for (i=0,t=0L; (i<nnt)&&(t<=totaldur); t += _duration[seq][i++])
		if ( !(t%q) && ( (_duration[seq][i]+_duration[seq][i+1]) == q ) )
		{
			_duration[seq][i]= dur1;
			_duration[seq][i+1]= dur2;
		}

}	/* end swing_it() */

/* EOF rseries.c */
