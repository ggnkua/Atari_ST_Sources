/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.

	module:	PSERIES -- pitch series operations

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

/* user-specified pitch pattern .............................................*/

pfunc_U(seq,arg)
int seq,arg;
{
	register int *noteptr;
	register char *baseptr;
	register int i,nnt;
	register unsigned note;
	int nch;

	baseptr=	pitch1data[arg];
	noteptr= (int*)(baseptr);
	nch = _nchords[seq]= noteptr[P_NCOLS/2] + 1;
	baseptr += P_NTREF;
	noteptr += P_NOTE/2;

	for (i=0; i<nch; i++)
	{
		nnt=0;
		note= *noteptr++;			/* bit field of notes */
		asm { move.l noteptr,-(a7) }
		noteptr= (int*)(_notes[seq][i]);		/* --> array of note #s in chord */
		asm { move.w i,-(a7) }
		for (i=*baseptr++; note&&(i<128); i++,note>>=1)
		{
			asm {
				btst		#0,note
				beq		skip_this
				move.b 	i,(noteptr)+
				addq.w	#1,nnt
			skip_this:
			}
		}
		asm { move.w (a7)+,i		move.l (a7)+,noteptr }
		_nnotes[seq][i]=nnt;
	}
}	/* end pfunc_U() */

/* dummy function, for loops, not called ....................................*/
pfuncdum(seq,arg)
int seq,arg;
{
	;
}	/* end pfuncdum() */

/* generate random ..........................................................*/

pfunc_R(seq,arg)
int seq,arg;
{
	int *noteptr[2],*randiptr;
	char *baseptr[2],*randcptr,*scale;
	int nch,tonic,octv,ndia;
	register int i,j,nsel;
	char nnt[2],nt[2][16],diatonic[12];
	unsigned mask;

	/* pointers to randomizer parameters */
	randiptr= (int*)( seq1data[seq] + S_PRAND );
	randcptr= seq1data[seq] + S_PRAND + P_RNSEL;

	/* user groups which we are going to play with */
	baseptr[0]=	pitch1data[arg] + P_NTREF ;
	noteptr[0]= (int*)( pitch1data[arg] + P_NOTE ) ;
	i= randiptr[P_RCOPY/2];
	baseptr[1]=	pitch1data[i] + P_NTREF ;
	noteptr[1]= (int*)( pitch1data[i] + P_NOTE ) ;

	/* how many chords in the result */
	nch= *(int*)(pitch1data[arg]+P_NCOLS);
	if (randiptr[P_RNCOL2/2])
	{
		i= random(randiptr[P_RNCOL2/2]);
		switch ( randiptr[P_RNCOL1/2] )
		{
			case 0:	/* up or down */
			if (random(1))
				nch += i;
			else
				nch -= i;
			break;
			
			case 1:	/* up */
			nch += i;
			break;

			case 2:	/* down */
			nch -= i;
		}
	}
	nch++;
	if (nch<1) nch=1;
	if (nch>NCHD) nch=NCHD;
	_nchords[seq]= nch;

	/* build the chords */
	for (i=0; i<nch; i++)
	{
		j= randcptr[i];
		/* build chord from first arg */
		if ( (j==0) || (j==2) || (j==3) || (j==5) || (j==6) )
			nnt[0]= buildchord(nt[0],baseptr[0][i],noteptr[0][i]);
		/* build chord from second arg */
		if ( (j==1) || (j==4) || (j==7) )
			nnt[0]= buildchord(nt[0],baseptr[1][i],noteptr[1][i]);
		/* build chord from second arg for mix */
		if ( (j==2) || (j==5) )
		{
			nnt[1]= buildchord(nt[1],baseptr[1][i],noteptr[1][i]);
			nnt[0]= mixchord(nnt[0],nt[0],nnt[1],nt[1]);
		}
		/* select from */
		nsel=0;
		if ( (j==6) || (j==7) ) nsel=1;
		if ( (j==3) || (j==4) || (j==5) )
			nsel= nnt[0]<2 ? 0 : random(nnt[0]-1)+1;
		if (nsel)
		{
			if (nsel==1)
			{
				nt[0][0]= nt[0][ random(nnt[0]-1) ];
				nnt[0]=1;
			}
			else
			{
				mask= random(0x7fff);
				asm { move.w i,-(a7)		move.w j,-(a7) }
				for (i=j=0; (i<nnt[0])&&(j<nsel)&&mask; i++,mask>>=1)
					if (mask&1) nt[0][j++]= nt[0][i];
				nnt[0]= max(j,1);
				asm { move.w (a7)+,j		move.w (a7)+,i }
			}
		}

		if (j==8)	/* make up something chromatic */
		{
			mask= random(0x7fff);
			nnt[0]= buildchord(nt[0],baseptr[0][i],mask);
		}

		if ( (j==9) || (j==11) )	/* make up something diatonic */
		{
			tonic= nonr1data[seq][N_TONIC];
			scale= nonr1data[seq] + N_SCALE ;
			octv= 12*(baseptr[0][i]/12);
			asm {	move.w i,-(a7)			move.w j,-(a7) }
			for (i=ndia=0; i<12; i++) if (!scale[i]) diatonic[ndia++]=i;
			asm { move.w (a7)+,j			move.w (a7)+,i }
			if (j==11)		/* something monophonic */
			{
				nnt[0]=1;
				nt[0][0]= ndia>1 ? diatonic[random(ndia-1)] + octv + tonic:
										 diatonic[0]+octv;
			}
			else				/* a chord */
			{
				mask= random(0x7f);
				asm { move.w i,-(a7)		move.w j,-(a7) }
				nsel=1;	/* don't allow seconds */
				for (i=j=0; mask&&(j<4)&&(i<ndia); i+=nsel,mask>>=1)
				{
					if (mask&1)
					{
						nt[0][j++]= diatonic[i] + tonic + octv;
						nsel=2;
					}
					else
						nsel=1;
				}

				if (j)
					nnt[0]=j;
				else
				{
					nnt[0]=1;
					nt[0][0]= tonic + octv;
				}
				asm { move.w (a7)+,j		move.w (a7)+,i }
			}
		}

		if (j==10)	/* make up a chromatic monophonic line */
		{
			nnt[0]= 1;
			nt[0][0]= baseptr[0][i] + random(15);
		}

		/* results */
		_nnotes[seq][i]=nnt[0];
		copy_bytes(nt[0],_notes[seq][i],16);
	}

	/* order chords */
	switch (randiptr[P_RORDER/2])
	{
		/* case 0: left to right */

		case 1:	/* random order, no repeats */
		for (i=1; i<nch; i++)
			exchchord(seq,random(nch-1),random(nch-1));
		break;

		case 2:	/* right to left */
		pfunc_RV(seq,nch);
	}	
}	/* end pfunc_R() */

exchchord(seq,i,j)
int seq,i,j;
{
	int n;
	char tempnotes[16];

	n= _nnotes[seq][j];
	_nnotes[seq][j]= _nnotes[seq][i];
	_nnotes[seq][i]= n;
	copy_bytes(_notes[seq][j],tempnotes,16);
	copy_bytes(_notes[seq][i],_notes[seq][j],16);
	copy_bytes(tempnotes,_notes[seq][i],16);
}	/* end exchchord() */

buildchord(notes,ntref,note)	/* returns # notes */
register char *notes;		/* output */
register int ntref;
register unsigned note;
{
	register int nnt=0;

	for (; note&&(ntref<128); ntref++,note>>=1)
	{
		asm {
			btst		#0,note
			beq		skip_bild
			move.b 	ntref,(notes)+
			addq.w	#1,nnt
		skip_bild:
		}
	}
	return(nnt);
}	/* end buildchord */

mixchord(n1,ptr1,n2,ptr2) /* returns # notes */
int n1,n2;
register char *ptr1,*ptr2;		/* ptr1 input/output */
{
	register int i,j;
	int note,phase;
	char result[16];

	asm { move.l ptr1,-(a7) }
	for (i=phase=0; (i<16)&&(n1||n2); phase=!phase)
	{
		if (phase)
		{
			if (n1)
			{
				note= *ptr1++;
				for (j=0; j<i; j++) if (note==result[j]) break;
				if (j==i) result[i++]=note;
				n1--;
			}
		}
		else
		{
			if (n2)
			{
				note= *ptr2++;
				for (j=0; j<i; j++) if (note==result[j]) break;
				if (j==i) result[i++]=note;
				n2--;
			}
		}
	}
	asm { move.l (a7)+,ptr1 }
	copy_bytes(result,ptr1,16);
	return(i);
}	/* end mixchord() */

/* diatonic transpose .......................................................*/
 
pfunc_DU(seq,arg)
int seq,arg;
{
	int scale,steps;

	scale= arg/10;
	scale= scale ? scale-1 : random(NSEQ-1) ;
	steps= arg%10;
	if (!steps)	steps= random(8)+1 ;
	if (steps>1) pfunc_DUDD(seq,scale,steps-1);

}	/* end pfunc_DU() */

pfunc_DD(seq,arg)
int seq,arg;
{
	int scale,steps;

	scale= arg/10;
	scale= scale ? scale-1 : random(NSEQ-1) ;
	steps= arg%10;
	if (!steps) steps= random(8)+1;
	if (steps>1) pfunc_DUDD(seq,scale,1-steps);

}	/* end pfunc_DD() */

pfunc_DUDD(seq,sc,steps)
int seq,sc,steps;
{
	int tonic,nch,nnt,note;
	int tone,newtone,degree,newdegree,chroma;
	register char *scale;
	register int i,j;
	char diatonic[12];
	int ndia;

	tonic= nonr1data[sc][N_TONIC];
	scale= nonr1data[sc] + N_SCALE ;

	for (i=j=0; i<12; i++) if (!scale[i]) diatonic[j++]=i;
	ndia=j;
	j= steps;
	if (j<0) j= -j;
	while (j>ndia)
	{
		if (steps>0)
			pfunc_CUCD(seq,12);
		else
			pfunc_CUCD(seq,-12);
		j-=ndia;
	}
	steps= steps<0 ? -j : j;
		
	nch= _nchords[seq];
	for (i=0; i<nch; i++)
	{
		nnt= _nnotes[seq][i];
		for (j=0; j<nnt; j++)
		{
			note= _notes[seq][i][j];
			degree= (note-tonic)%12;
			while (scale[degree])
			{
				if (scale[degree]>0)
					degree++;
				else
					degree--;
			}
			for (tone=0; tone<ndia; tone++) if (degree==diatonic[tone]) break;
			newtone= tone+steps;
			while (newtone<0) newtone+=ndia;
			while (newtone>=ndia) newtone-=ndia;
			newdegree= diatonic[newtone];
			chroma= newdegree-degree;
			if ((steps>0)&&(chroma<0)) chroma+=12;
			if ((steps<0)&&(chroma>0)) chroma-=12;
			note += chroma;
			if (note>127) note-=12;
			if (note<0) note+=12;
			_notes[seq][i][j]= note;
		}
	}			
}	/* end pfunc_DUDD() */

/* force diatonic ...........................................................*/

pfunc_FD(seq,arg)
int seq,arg;
{
	int tonic,nch,nnt,note;
	register int i,j,degree;
	register char *scale;

	arg= arg ? arg-1 : random(NSEQ-1) ;	/* select which scale (0-7) */
	tonic= nonr1data[arg][N_TONIC];	/* 0-11 */
	scale= nonr1data[arg] + N_SCALE ;

	nch= _nchords[seq];
	for (i=0; i<nch; i++)
	{
		nnt= _nnotes[seq][i];
		for (j=0; j<nnt; j++)
		{
			note= _notes[seq][i][j];
			degree= (note-tonic)%12;
			while (scale[degree])
			{
				if (scale[degree]>0)
				{
					degree++;	note++;
				}
				else
				{
					degree--;	note--;
				}
			}
			if (note>127) note-=12;
			if (note<0) note+=12;
			_notes[seq][i][j]= note;
		}
	}			
}	/* end pfunc_FD() */

/* chromatic transpose up/down ..............................................*/

pfunc_CU(seq,arg)
int seq,arg;
{
	if (!arg) arg= random(12);
	pfunc_CUCD(seq,arg);
}	/* end pfunc_CU() */

pfunc_CD(seq,arg)
int seq,arg;
{
	if (!arg) arg= random(12);
	pfunc_CUCD(seq,-arg);
}	/* end pfunc_CD() */

pfunc_CUCD(seq,arg)
register int seq;
int arg;
{
	register int i,j,note;
	register char *noteptr,*chordptr;
	int nch;

	chordptr= _notes[seq][0];		/* --> first note in first chord */
	nch= _nchords[seq];
	for (i=0; i<nch; i++,chordptr+=16)
	{
		noteptr= chordptr;
		for (j=_nnotes[seq][i]; j>0; j--)
		{
			note= *noteptr + arg;
			if (note<0) note=0;
			if (note>127) note=127;
			*noteptr++ = note;
		}
	}
}	/* end pfunc_CUCD() */

/* reflect ..................................................................*/

pfunc_RF(seq,arg)
int seq,arg;
{
	int nch;
	register int i,j,x,n;
	char *scale;
	char diatonic[12];

	/* n= chromatic tone to reflect around (0-11) */
	n= arg/10;
	if (n) n--; else n=random(NSEQ-1);		/* scale 0-7 */
	x= arg%10;
	if (x) x--; else x=random(8);				/* tone 0-8 */
	scale= nonr1data[n] + N_SCALE ;
	for (i=j=0; i<12; i++) if (!scale[i]) diatonic[j++]=i;
	n= ( nonr1data[n][N_TONIC] + diatonic[x%j] ) % 12 ;

	nch= _nchords[seq];
	for (i=0; i<nch; i++)
	{
		for (j=0; j<_nnotes[seq][i]; j++)
		{
			x= _notes[seq][i][j];
			x -= 2*( (x%12) - n ) ;
			while (x<0) x+=12;
			while (x>127) x-=12;
			_notes[seq][i][j]=x;
		}
	}
}	/* end pfunc_RF() */ 

/* expand/compress chords ...................................................*/

pfunc_EX(seq,arg)
int seq,arg;
{
	int nch,avg,delta,amt;
	register int i,j,n;

	amt= arg%10;
	if (!amt) amt= random(8)+1;		/* 0 means random 1-9 */
	arg/=10;		/* 0 compress, 1 expand */
	nch= _nchords[seq];
	for (i=0; i<nch; i++)
	{
		n= _nnotes[seq][i];
		if (n>1)
		{
			/* average note in this chord */
			for (j=avg=0; j<n; j++) avg+= _notes[seq][i][j];
			avg/=n;
			for (j=0; j<n; j++)
			{
				asm { move.w n,-(a7) }
				n= _notes[seq][i][j];
				delta=0;
				if (n>avg) delta= -amt;
				if (n<avg) delta=  amt;
				if (arg) delta *= -1;
				if (n<avg) n= min(avg,n+delta);
				if (n>avg) n= max(avg,n+delta);
				if (n<0) n=0;
				if (n>127) n=127;
				_notes[seq][i][j]=n;
				asm { move.w (a7)+,n }
			}	/* end for all notes in chord */
		}	/* end if chord has more than 1 note */
	}	/* end for all chords */
}	/* end pfunc_EX() */ 

/* play only highest and/or lowest of each chord ............................*/

pfunc_HL(seq,arg)
int seq,arg;
{
	switch (arg)
	{
		case 0: low_of(seq); break;
		case 1: high_of(seq); break;
		case 2: highlow_of(seq);
	}
}	/* end pfunc_HL() */

high_of(seq)
int seq;
{
	int nch,n;
	register int i,j,high;

	nch= _nchords[seq];
	for (i=0; i<nch; i++)
	{
		high= -1;
		n= _nnotes[seq][i];
		if (!n) continue;
		_nnotes[seq][i]=1;
		for (j=0; j<n; j++)
			high= max(high,_notes[seq][i][j]);
		_notes[seq][i][0]=high;
	}
}	/* end high_of() */

low_of(seq)
int seq;
{
	int nch,n;
	register int i,j,low;

	nch= _nchords[seq];
	for (i=0; i<nch; i++)
	{
		low= 128;
		n= _nnotes[seq][i];
		if (!n) continue;
		_nnotes[seq][i]=1;
		for (j=0; j<n; j++)
			low= min(low,_notes[seq][i][j]);
		_notes[seq][i][0]=low;
	}
}	/* end low_of() */

highlow_of(seq)
int seq;
{
	int nch,n;
	register int i,j,low,high;

	nch= _nchords[seq];
	for (i=0; i<nch; i++)
	{
		low= 128;
		high= -1;
		n= _nnotes[seq][i];
		if (n<2) continue;
		_nnotes[seq][i]=2;
		for (j=0; j<n; j++)
		{
			low= min(low,_notes[seq][i][j]);
			high= max(high,_notes[seq][i][j]);
		}
		_notes[seq][i][0]=low;
		_notes[seq][i][1]=high;
	}
}	/* end highlow_of() */

/* accompany melody .........................................................*/

pfunc_AC(seq,arg)
int seq,arg;
{
	register int i,j,high,cnt;
	int scale,n,nch,ndia,oct;
	char diatonic[12];
	char *scaleptr;

	scale= arg/10;											/* scale 0-7 */
	scale= scale ? scale-1 : random(NSEQ-1) ;
	scaleptr= nonr1data[scale] + N_SCALE ;
	j= nonr1data[scale][N_TONIC];
	for (i=ndia=0; i<12; i++)
		if (!scaleptr[i])
			diatonic[ndia++]= (i+j)%12;
	if (ndia<3) return;	/* 0-, 1-, or 2-note scale: too weird */

	arg %= 10;				/* how often to accompany */
	cnt=0;

	nch= _nchords[seq];
	for (i=0; i<nch; i++)
	{
		if (cnt)
			cnt--;
		else
		{
			cnt= arg ? arg-1 : random(4) ;
			if ( n=_nnotes[seq][i] )
			{
				/* find highest note in chord */
				high= -1;
				for (j=0; j<n; j++) high= max(high,_notes[seq][i][j]);
				n= high%12;		/* chromatic tone, 0-11 */
				/* is this note in the scale? */
				for (j=0; j<ndia; j++) if (n==diatonic[j]) break;
				if (j<ndia)
				{
					/* put 1 or 2 notes below it */
					_nnotes[seq][i]=1;
					_notes[seq][i][0]=high;
					asm { move.w cnt,-(a7) }
					for (cnt=2; cnt<=4; cnt+=2)
					{
						oct= 12*(high/12);
						n= j+cnt;
						if (n>=ndia) { n-=ndia; oct+=12; }
						n= diatonic[n] + oct ;
						while (n>high) n-=12;
						while (n<(high-11)) n+=12;
						if ((n>=0)&&(n<=127)&&(n!=high))
						{
							_notes[seq][i][cnt/2]=n;
							_nnotes[seq][i]++;
						}
						if (ndia<5) break;
					}
					asm { move.w (a7)+,cnt }
				}
			}
		}
	}
}	/* end pfunc_AC() */

/* play reverse .............................................................*/

pfunc_RV(seq,arg)
int seq,arg;
{
	char revnn[NCHD];
	char revnotes[NCHD][16];
	register int i;
	int nch;

	nch= _nchords[seq];
	if (!arg && nch) arg= random(nch-1) + 1;
	nch= min(arg,nch);
	for (i=0; i<nch; i++)
	{
		revnn[i]= _nnotes[seq][nch-1-i];
		copy_bytes(_notes[seq][nch-1-i],revnotes[i],revnn[i]);
	}
	copy_bytes(revnn,_nnotes[seq],nch);
	for (i=0; i<nch; i++)
		copy_bytes(revnotes[i],_notes[seq][i],revnn[i]);

}	/* end pfunc_RV() */

/* play only the first nn chords ............................................*/

pfunc_TA(seq,arg)
register int seq,arg;
{
	int nch;

	nch= _nchords[seq];
	if (!arg && nch) arg= random(nch-1) + 1;
	arg= min(arg,nch);
	for (; arg<nch; arg++)
	{
		_nchords[seq]--;
		_nnotes[seq][arg]=0;
	}
}	/* end pfunc_TA() */

/* play only the last nn chords .............................................*/

pfunc_TB(seq,arg)
int seq,arg;
{
	int nch;
	register int i,j;

	nch= _nchords[seq];
	if (!arg) arg= random(nch);

	for (i=nch-arg,j=0; i<nch; i++,j++)
	{
		_nnotes[seq][j]= _nnotes[seq][i];
		copy_bytes(_notes[seq][i],_notes[seq][j],16);
	}
	_nchords[seq]= arg;
}	/* end pfunc_TB() */

/* play only even or odd chords .............................................*/

pfunc_EO(seq,arg)
register int seq;
int arg;
{
	register int i,nch;

	nch= _nchords[seq];
	for (i=(arg>0); i<nch; i+=2) _nnotes[seq][i]=0;
}	/* end pfunc_EO() */

/* insert a scale tone between chords .......................................*/

pfunc_WM(seq,arg)
int seq,arg;
{
	register int i,nch,cnt;
	int n,new_nch,x,oct;
	char new_nn[NCHD],new_notes[NCHD][16];
	char *scale;
	char diatonic[12];

	if (x= arg/10)
	{
		x--;	/* 0-8 */
		scale= nonr1data[seq] + N_SCALE ;
		for (i=cnt=0; i<12; i++) if (!scale[i]) diatonic[cnt++]=i;
		x= ( nonr1data[seq][N_TONIC] + diatonic[x%cnt] ) % 12 ;
	}
	else
		x= -1;		/* means rest */
	arg %= 10;			/* how often to insert, 0 means randomly */

	nch= _nchords[seq];
	new_nch=0;
	cnt= arg ? arg : random(4)+1;
	oct= 0x3c;		/* default middle octave for inserted note */
	for (i=0; (i<nch)&&(new_nch<32); new_nch++)
	{
		if (cnt)
		{
			new_nn[new_nch]= _nnotes[seq][i];
			copy_bytes(_notes[seq][i++],new_notes[new_nch],16);
			cnt--;
		}
		else		/* time to insert */
		{
			if (x>=0)
			{
				/* octave for inserted note = average octave of previous chord */
				if ( n = new_nn[new_nch-1] )
				{
					asm { move.w i,-(a7) }
					for (oct=i=0; i<n; i++) oct += 12*(new_notes[new_nch-1][i]/12);
					oct= 12 * ( (oct/n) / 12 );
					asm { move.w (a7)+,i }
				}
				while ( (oct+x) > 127 ) oct-=12;
				while ( (oct+x) < 0   ) oct+=12;
				new_notes[new_nch][0]= oct+x;
				new_nn[new_nch]= 1;
			}
			else
				new_nn[new_nch]=0;
			cnt= arg ? arg : random(4)+1;
		}
	}

	copy_bytes(new_nn,_nnotes[seq],NCHD);
	for (i=0; i<new_nch; i++) copy_bytes(new_notes[i],_notes[seq][i],16);
	_nchords[seq]= new_nch;

}	/* end pfunc_WM() */

/* no rests .................................................................*/

pfunc_NR(seq,arg)
int seq,arg;
{
	int nch;
	register int i,j;

	nch= _nchords[seq];
	for (i=j=0; j<nch; j++)
	{
		if (_nnotes[seq][j])
		{
			_nnotes[seq][i]= _nnotes[seq][j];
			copy_bytes(_notes[seq][j],_notes[seq][i],16);
			i++;
		}
	}
	_nchords[seq]= i ? i : 1;
}	/* end pfunc_NR() */

/* harmonize above ..........................................................*/

pfunc_HA(seq,arg)
int seq,arg;
{
	harmonize(seq,arg,1);
}	/* end pfunc_HA() */

/* harmonize below ..........................................................*/

pfunc_HB(seq,arg)
int seq,arg;
{
	harmonize(seq,arg,0);
}	/* end pfunc_HB() */

harmonize(seq,arg,dir)
int seq,arg,dir;		/* dir= 1 for above, 0 for below */
{
	register int i,j,n;
	int save_nchd;
	char save_nn[NCHD];
	char save_notes[NCHD][16];

	/* save pattern */
	save_nchd= _nchords[seq];
	copy_bytes(_nnotes[seq],save_nn,save_nchd);
	copy_bytes(_notes[seq][0],save_notes,16*save_nchd);

	/* strip off all but lowest or highest note in each chord,
		and then diatonic transpose that note */
	if (dir)
	{
		high_of(seq);
		pfunc_DU(seq,arg);
	}
	else
	{
		low_of(seq);
		pfunc_DD(seq,arg);
	}

	/* merge with saved pattern */
	for (i=0; i<save_nchd; i++)
	{
		for (j=n=_nnotes[seq][i]; j<16; j++)		/* _nnotes[seq][i] is 0 or 1 */
			_notes[seq][i][j]= save_notes[i][j-n];
		_nnotes[seq][i]= min(16,n+save_nn[i]);
	}
}	/* end harmonize() */

/* exchange .................................................................*/

pfunc_X(seq,arg)
register int seq;
int arg;
{
	register int i,j,n;
	int nch;
	char tempnotes[16];

	nch= _nchords[seq];
	for (i=0; i<nch-1;)
	{
		n= _nnotes[seq][i];
		j= i+1;

		if (arg)
		{
			if (!n) { i++; continue; }
			while ( !_nnotes[seq][j] && (j<nch) ) j++;
			if (j==nch) break;
		}

		_nnotes[seq][i]= _nnotes[seq][j];
		_nnotes[seq][j]= n;
		copy_bytes(_notes[seq][i],tempnotes,16);
		copy_bytes(_notes[seq][j],_notes[seq][i],16);
		copy_bytes(tempnotes,_notes[seq][j],16);
		i= j+1;
	}
}	/* end pfunc_X() */ 

/* again ....................................................................*/

pfunc_A(seq,arg)
register int seq,arg;
{
	register int i,nch;
	int new_n;

	if (!arg) arg= random(4);
	new_n= nch= _nchords[seq];
	while ( arg*nch > NCHD ) arg--;
	for (i=1; i<arg; i++)
	{
		copy_bytes(_nnotes[seq],&_nnotes[seq][new_n],nch);
		copy_bytes(_notes[seq][0],_notes[seq][new_n],16*nch);
		new_n += nch;
	}
	_nchords[seq]=new_n;	
}	/* end pfunc_A() */

/* echo .....................................................................*/

pfunc_EC(seq,arg)
register int seq,arg;
{
	int nch;
	register char *nnptr,*noteptr;
	char tempnn[NCHD],tempnotes[16*NCHD];
	register int i,j;

	if (!arg) arg= random(NCHD-1);
	nch= _nchords[seq];
	while ( arg*nch > NCHD ) arg--;

	nnptr= tempnn;
	noteptr= tempnotes;
	for (i=0; i<nch; i++)
	{
		for (j=0; j<arg; j++)
		{
			*nnptr++ = _nnotes[seq][i];
			copy_bytes(_notes[seq][i],noteptr,16);
			noteptr+=16;
		}
	}
	nch *= arg;
	copy_bytes(tempnn,_nnotes[seq],nch);
	copy_bytes(tempnotes,_notes[seq][0],16*nch);
	_nchords[seq]= nch;
}	/* end pfunc_EC() */

/* invert chords ............................................................*/

pfunc_I(seq,arg)
int seq,arg;
{
	int nch,nnt,note;
	int min_j,max_j;
	int minnt,maxnt;
	register int i,j;

	nch= _nchords[seq];
	for (i=0; i<nch; i++)
	{
		nnt= _nnotes[seq][i];
		if (nnt<2) continue;
		minnt= 128;
		maxnt= -1;
		for (j=0; j<nnt; j++)
		{
			note= _notes[seq][i][j];
			if (note<minnt)
			{
				minnt=note;
				min_j=j;
			}
			if (note>maxnt)
			{
				maxnt=note;
				max_j=j;
			}
		}
		if (arg)
		{
			minnt+=12;
			if (minnt<128) _notes[seq][i][min_j]=minnt;
		}
		else
		{
			maxnt-=12;
			if (maxnt>=0) _notes[seq][i][max_j]=maxnt;
		}
	}
}	/* end pfunc_I() */ 

/* mix ......................................................................*/

pfunc_M(seq,arg)
int seq,arg;
{
	int nch;
	register int i,n1,n2,j;
	int note;
	
	nch= _nchords[seq];

	for (i=1; i<nch; i+=2)
	{
		n1= _nnotes[seq][i-1];
		n2= _nnotes[seq][i]-1;
		while ( (n1<16) && (n2>=0) )
		{
			note= _notes[seq][i][n2--];
			for (j=0; j<n1; j++)
				if (_notes[seq][i-1][j]==note) break;
			if (j==n1) _notes[seq][i-1][n1++]=note;
		}
		_nnotes[seq][i-1]= n1;
	}

	for (i=2,j=1; i<nch; i+=2,j++)
	{
		_nnotes[seq][j]= _nnotes[seq][i];
		copy_bytes(_notes[seq][i],_notes[seq][j],16);
	}
	_nchords[seq]= j;

}	/* end pfunc_M() */ 

/* drop .....................................................................*/

pfunc_DR(seq,arg)
int seq,arg;
{
	int nch;
	register int i;

	nch= _nchords[seq];
	if (nch<2) return;
	arg= arg ? arg-1 : random(nch-1) ;
	if (arg<nch)
	{
		for (i=arg+1; i<nch; i++)
		{
			_nnotes[seq][i-1]= _nnotes[seq][i] ;
			copy_bytes(_notes[seq][i],_notes[seq][i-1],16);
		}
		_nchords[seq]--;
	}

}	/* end pfunc_DR() */

/* substitute rest for ......................................................*/

pfunc_SR(seq,arg)
int seq,arg;
{
	int nch;

	nch= _nchords[seq];
	if (!nch) return;
	arg= arg ? arg-1 : random(nch-1) ;
	if (arg<nch) _nnotes[seq][arg]=0;

}	/* end pfunc_SR() */

/* un-chord .................................................................*/

pfunc_UC(seq,arg)
int seq,arg;
{
	int nch;
	register int i,j,nnt;
	char notes[NCHD];

	nch= _nchords[seq];
	if (!arg && nch) arg= random(nch-1) + 1;
	arg= min(arg,nch);

	for (i=j=0; (i<arg)&&(j<NCHD); i++)
	{
		nnt= _nnotes[seq][i];
		for (--nnt; (nnt>=0)&&(j<NCHD); nnt--)
			notes[j++]= _notes[seq][i][nnt];
	}
	for (i=0; i<j; i++)
	{
		_notes[seq][i][0]=notes[i];
		_nnotes[seq][i]=1;
	}
	_nchords[seq]= max(nch,j);
}	/* end pfunc_UC() */

/* EOF pseries.c */
