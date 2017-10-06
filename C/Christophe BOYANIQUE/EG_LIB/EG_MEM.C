/******************************************************************************/
/*	"Easy Gem" library Copyright (c)1994 by		Christophe BOYANIQUE				*/
/*																29 Rue R‚publique					*/
/*																37230 FONDETTES					*/
/*																FRANCE								*/
/*						*small* mail at email adress:	cb@spia.freenix.fr				*/
/******************************************************************************/
/*	This program is free software; you can redistribute it and/or modify it		*/
/*	under the terms of the GNU General Public License as published by the Free	*/
/*	Software Foundation; either version 2 of the License, or any later version.*/
/*	This program is distributed in the hope that it will be useful, but WITHOUT*/
/*	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or		*/
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for	*/
/*	more details.																					*/
/*	You should have received a copy of the GNU General Public License along		*/
/*	with this program; if not, write to the Free Software Foundation, Inc.,		*/
/*	675 Mass Ave, Cambridge, MA 02139, USA.												*/
/******************************************************************************/
/*																										*/
/*	FUNCTIONS TO HANDLE MEMORY MANAGEMENT													*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/

#include		"EG_MAIN.H"

/******************************************************************************/
/*	INTERN VARIABLES																				*/
/******************************************************************************/
MEM		mem;


/******************************************************************************/
/*	INTERN FUNCTIONS																				*/
/******************************************************************************/
static	int	Link(void);
static	int	Decale(void);
static	void	Unfrag(void);
static	void	freeMem(void);


/******************************************************************************/
/*	This function allocs a big Malloc bloc and inits the struct						*/
/******************************************************************************/
int _pAlloc(int n,long len)
{
	int		i;
	long		adr;

	if (len&1)
		len+=1;
	adr=(long)_Malloc(len);
	if (adr>0)
	{
		for (i=0;i<MEM_NMB;i++)
		{
			mem.Badr[i]=0;
			mem.Blen[i]=0;
		}
		mem.Badr[0]	=	adr;
		mem.Blen[0]	=	len;

		mem.n			=	n;
		mem.bloc		=	(BLOC *)adr;

		for (i=2;i<n;i++)
		{
			mem.bloc[i].adr	=	0L;
			mem.bloc[i].len	=	0L;
			mem.bloc[i].type	=	MB_IGNORE;
		}

		mem.bloc[0].adr		=	mem.Badr[0];
		mem.bloc[0].len		=	(long)( n * sizeof(BLOC) );
		mem.bloc[0].type		=	MB_NOMOVE;

		mem.bloc[1].adr		=	adr+(long)( n * sizeof(BLOC) );
		mem.bloc[1].len		=	len - (long)( n * sizeof(BLOC) );
		mem.bloc[1].type		=	MB_IGNORE;

		freeMem();
		return OK_MEM;
	}
	return NO_OS_MEM;
}


/******************************************************************************/
/*	This function release all the Malloc blocs...										*/
/******************************************************************************/
void _pFree()
{
	int		i;

	for (i=0;i<MEM_NMB;i++)
		if ( (mem.Blen[i]!=0) && (mem.Badr[i]!=0) )
			_Mfree((void *)mem.Badr[i]);
}


/******************************************************************************/
/*	This functions change the Malloc size													*/
/******************************************************************************/
void _pDim(long len)
{
	int		n,i,dum,ind=-1;
	long		adr,sys,used,total;

	Unfrag();
	if (len==0)
		dum='IN';
	else if (len==-1)
		dum='AX';
	else
		dum=0;
	if (len&1)
		len+=1;
	sys=(long)_Malloc(-1L);

	total=0;
	for (i=0;i<MEM_NMB;i++)
	{
		if (mem.Blen[i]>0)
			total+=mem.Blen[i];
		else
		{
			ind=i;
			i=MEM_NMB;
		}
	}

	used=0;
	for (i=0;i<mem.n;i++)
		if (mem.bloc[i].type!=MB_IGNORE)
			used+=mem.bloc[i].len;

	if ( (len>total || dum=='AX') && (ind!=-1) )		/*	Agrandissement	*/
	{
		if (dum=='AX')
			len=total+sys;
		else
			sys=min(sys,len-total);
		if (sys>0)
		{
			adr=mem.Badr[0]+total;
			mem.Badr[ind]=(long)_Malloc(sys);
			if (mem.Badr[ind]==adr)
			{
				mem.Blen[ind]=sys;
				n=NO_MEMORY;
				for (i=0;i<mem.n;i++)
					if ( mem.bloc[i].len == 0 )
					{
						n=i;
						i=mem.n;
					}
				if (n!=NO_MEMORY)
				{
					mem.bloc[n].adr	=	mem.Badr[ind];
					mem.bloc[n].len	=	mem.Blen[ind];
					mem.bloc[n].type	=	MB_IGNORE;
				}
				else
				{
					_Mfree((void *)mem.Badr[ind]);
					mem.Badr[ind]=0;
					mem.Blen[ind]=0;
				}
			}
			else
			{
				_Mfree((void *)mem.Badr[ind]);
				mem.Badr[ind]=0;
				mem.Blen[ind]=0;
			}
		}
	}
	else if ( (len<total && used<len) || (dum=='IN') )		/*	Diminution	*/
	{
		adr=0;
		for (i=0;i<mem.n;i++)
			if (mem.bloc[i].type!=MB_IGNORE)
				adr=max(adr,mem.bloc[i].adr+mem.bloc[i].len);
		if (dum=='IN')
		{
			len=adr-mem.Badr[0]+10L*1024L;
			len+=len%1024L;
			if (len&1)
				len+=1;
		}
		if (adr<mem.Badr[0]+len)
		{
			ind=0;
			for (i=0;i<MEM_NMB;i++)
				if (mem.Blen[i]>0)
					ind=i;
			for (i=ind;i>0;i--)
				if (mem.Badr[i]>=mem.Badr[0]+len)
				{
					_Mfree((void *)mem.Badr[i]);
					mem.Badr[i]=0;
					mem.Blen[i]=0;
				}
				else if ( (mem.Badr[i]<mem.Badr[0]+len) && (mem.Badr[i]+mem.Blen[i]>mem.Badr[0]+len) )
				{
					n=_Mshrink(0,(void *)mem.Badr[i],mem.Badr[0]+len-mem.Badr[i]);
					if (n==0)
						mem.Blen[i]=mem.Badr[0]+len-mem.Badr[i];
				}
			if (mem.Blen[0]>len)
			{
				n=_Mshrink(0,(void *)mem.Badr[0],len);
				if (n==0)
					mem.Blen[0]=len;
			}
			for (i=0;i<mem.n;i++)
			{
				if (mem.bloc[i].adr>adr/*mem.Badr[0]+len*/)
				{
					mem.bloc[i].adr=0;
					mem.bloc[i].len=0;
					mem.bloc[i].type=MB_IGNORE;
				}
				if ( (mem.bloc[i].adr<mem.Badr[0]+len) && (mem.bloc[i].adr+mem.bloc[i].len>mem.Badr[0]+len) )
					mem.bloc[i].len=mem.Badr[0]+len-mem.bloc[i].adr;
			}
		}
	}
	Unfrag();
}


/******************************************************************************/
/*	This functions allocs a user memory bloc												*/
/******************************************************************************/
int _mAlloc(long len,int type,int cls)
{
	int		m,n,i;

	m=NO_MEMORY;
	n=NO_MEMORY;
	if (len&1)
		len+=1;

	for (i=0;i<mem.n;i++)
		if ( (mem.bloc[i].type==MB_IGNORE) && (mem.bloc[i].len>=len) )
		{
			n=i;
			i=mem.n;
		}

	if (n==NO_MEMORY)
	{
		Unfrag();
		for (i=0;i<mem.n;i++)
		{
			if ( (mem.bloc[i].type==MB_IGNORE) && (mem.bloc[i].len>=len) )
			{
				n=i;
				i=mem.n;
			}
		}
	}

	if (n!=NO_MEMORY)
	{
		for (i=0;i<mem.n;i++)
			if ( mem.bloc[i].len == 0 )
			{
				m=i;
				i=mem.n;
			}
		if (m!=NO_MEMORY)
		{
			mem.bloc[m].adr	=	mem.bloc[n].adr+len;
			mem.bloc[m].len	=	mem.bloc[n].len-len;
			mem.bloc[m].type	=	mem.bloc[n].type;
			mem.bloc[n].len	=	len;
			mem.bloc[n].type	=	type;
			if (cls)
				_cls(mem.bloc[n].adr,mem.bloc[n].len);
		}
		else
			n=NO_MEMORY;
	}

	freeMem();
	return n;
}


/******************************************************************************/
/*	This function frees a user memory bloc													*/
/******************************************************************************/
void _mFree(int index)
{
	if ( (mem.bloc[index].len!=0) && (mem.bloc[index].type!=MB_IGNORE) )
	{
		mem.bloc[index].type=MB_IGNORE;
		if (!glb.Exit)
			Unfrag();
	}
}


/******************************************************************************/
/*	This function frees a user bloc with its adress (usefull for the NO_MOVE	*/
/*	type blocs or for compatibility (see GLC_CICN) )									*/
/******************************************************************************/
void _mSpecFree(long adr)
{
	int		i;

	for (i=0;i<mem.n;i++)
		if ( (mem.bloc[i].type!=MB_IGNORE) && (mem.bloc[i].adr==adr) )
			_mFree(i);
}

/******************************************************************************/
/*																										*/
/*	THIS FUNCTIONS UNFRAG THE MEMORY															*/
/*																										*/
/******************************************************************************/

/******************************************************************************/
/*	This function searches two following free blocs and unite them					*/
/******************************************************************************/
static int Link()
{
	int		i,j;
	int		nmb=0;

	for (i=0;i<mem.n;i++)
		if ( ( mem.bloc[i].type == MB_IGNORE ) && ( mem.bloc[i].len != 0 ) )
			for (j=0;j<mem.n;j++)
				if ( (i!=j) && (mem.bloc[j].type==MB_IGNORE) && (mem.bloc[j].len!=0) && (mem.bloc[j].adr==mem.bloc[i].adr+mem.bloc[i].len) )
				{
					mem.bloc[i].len+=mem.bloc[j].len;
					mem.bloc[j].adr=0;
					mem.bloc[j].len=0;
					mem.bloc[j].type=MB_IGNORE;
					i=mem.n;
					j=mem.n;
					nmb+=1;
				}
	return nmb;
}


/******************************************************************************/
/*	This functions displaces blocs to the begin of memory								*/
/*		Bloc to displace:	i																		*/
/*		Free bloc:			j																		*/
/******************************************************************************/
static int Decale()
{
	int		i,j;
	int		nmb=0;
	long		src,dst,len;

	for (i=0;i<mem.n;i++)
		if ( ( mem.bloc[i].type == MB_IGNORE ) && ( mem.bloc[i].len != 0 ) )
			for (j=0;j<mem.n;j++)
			{
				if ( mem.bloc[j].adr == mem.bloc[i].adr + mem.bloc[i].len)
					if ( ( mem.bloc[j].len != 0 ) && ( mem.bloc[j].type != MB_NOMOVE) )
						if (i!=j)
						{
							src=mem.bloc[j].adr;
							dst=mem.bloc[i].adr;
							len=mem.bloc[j].len;
							_bmove(src,dst,len);
							mem.bloc[j].adr=mem.bloc[i].adr;
							mem.bloc[i].adr+=mem.bloc[j].len;
							nmb+=1;
							i=mem.n;
							j=mem.n;
						}
			}
	return nmb;
}


/******************************************************************************/
/*	This function call Link() or Decale()													*/
/******************************************************************************/
static void Unfrag()
{

	int		r1=0,r2=0;

	do
	{
		_mousework();
		r1=Link();
		_mousework();
		r2=Decale();
	}	while ( (r1!=0) || (r2!=0) );
	freeMem();
	graf_mouse(ARROW,0);
}


/******************************************************************************/
/*	This function changes a memory bloc size												*/
/******************************************************************************/
int _mDim(int ind,long len,int cls)
{
	int		i,m=NO_MEMORY;

	Unfrag();
	if (len&1)
		len+=1;
	if (len>mem.bloc[ind].len)
	{
		for (i=0;i<mem.n;i++)
			if ( (mem.bloc[i].adr==mem.bloc[ind].adr+mem.bloc[ind].len) && (mem.bloc[i].type==MB_IGNORE) && (mem.bloc[ind].len+mem.bloc[i].len>=len) )
			{
				m=i;
				i=mem.n;
			}
		if (m!=NO_MEMORY)
		{
			if (cls)
				_cls(mem.bloc[m].adr,len-mem.bloc[ind].len);
			mem.bloc[m].len	-=	len-mem.bloc[ind].len;
			mem.bloc[m].adr	+=	len-mem.bloc[ind].len;
			mem.bloc[ind].len	+=	len-mem.bloc[ind].len;
			Unfrag();
			return ind;
		}
		else if (mem.bloc[ind].type==MB_NORM)
		{
			m=_mAlloc(len,MB_NOMOVE,cls);
			if (m!=NO_MEMORY)
			{
				if (cls)
					_cls(mem.bloc[m].adr+mem.bloc[ind].len,len-mem.bloc[ind].len);
				_bmove(mem.bloc[ind].adr,mem.bloc[m].adr,mem.bloc[ind].len);
				_mFree(ind);
				freeMem();
				return m;
			}
		}
	}
	else if (len<mem.bloc[ind].len)
	{
		for (i=0;i<mem.n;i++)
			if ( mem.bloc[i].len == 0 )
			{
				m=i;
				i=mem.n;
			}
		if (m!=NO_MEMORY)
		{
			mem.bloc[m].adr	=	mem.bloc[ind].adr+len;
			mem.bloc[m].len	=	mem.bloc[ind].len-len;
			mem.bloc[ind].len	=	len;
			Unfrag();
			return ind;
		}
	}
	return NO_MEMORY;
}


/******************************************************************************/
/*	This function calculates free & used memory											*/
/******************************************************************************/
static void freeMem()
{
	int		i;

	mem.mfre=0;
	for (i=0;i<mem.n;i++)
		if ( (mem.bloc[i].type==MB_IGNORE) && (mem.bloc[i].len!=0) )
			mem.mfre=max(mem.mfre,mem.bloc[i].len);

	mem.tlen=0;
	for (i=0;i<MEM_NMB;i++)
		mem.tlen+=mem.Blen[i];

	mem.tfre=mem.tlen;
	for (i=0;i<mem.n;i++)
		if (mem.bloc[i].type!=MB_IGNORE)
			mem.tfre-=mem.bloc[i].len;
}
long _freeSys()
{
	int		i;
	long		adr[100],len,total=0;

	i=0;
	do
	{
		len=(long)_Malloc(-1L);
		if (len>0)
		{
			adr[i]=(long)_Malloc(len);
			if (adr[i]<0)
			{
				adr[i]=0;
				i=100;
			}
			else
				total+=len;
			i+=1;
		}
	}	while (len>0 && i<100);
	i=0;
	while (adr[i]!=0)
		_Mfree((void *)adr[i++]);
	return total;
}
