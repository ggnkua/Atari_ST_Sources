/*******************************************************************************
	Bitmap view Copyright (c) 1995 by	Christophe BOYANIQUE
													http://www.raceme.org
													tof@raceme.org
********************************************************************************
	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the Free
	Software Foundation; either version 2 of the License, or any later version.
	This program is distributed in the hope that it will be useful, but WITHOUT
	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
	FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
	more details.
	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	59 Temple Place - Suite 330, Boston, MA 02111, USA.
********************************************************************************
	TABULATION: 3 CARACTERES
*******************************************************************************/

#include		"PROTO.H"

/*******************************************************************************
	INTERN VARIABLES
*******************************************************************************/
int cdecl		(*manag_version)(void);
long cdecl		(*manag_malloc)(long *,long *,int,int,long);
long cdecl		(*manag_free)(void);
long cdecl		(*manag_shrink)(long);
long cdecl		(*manag_grow)(int,long);
long cdecl		(*manag_size)(void);
long cdecl		(*blk_malloc)(long *,long *,int,int,long,int);
long cdecl		(*blk_free)(long *,long *,int,int);
long cdecl		(*blk_shrink)(long *,long *,int,int,long,long);
long cdecl		(*blk_grow)(long *,long *,int,int,long,int,long);


/*******************************************************************************
	INTERN FUNCTIONS
*******************************************************************************/
static void	_memUpdate(void);


/*******************************************************************************
	This functions change the Malloc size
*******************************************************************************/
void _pDim(long len)
{
	long	r,d,c,n;
	int	dum;

	if (len==0)
		dum='IN';
	else if (len==-1)
		dum='AX';
	else
		dum=0;
	if (len&1)
		len+=1;

	if (dum=='IN' || (!dum && len<glb.mem.tlen))
	{
		if (glb.mem.tfre>10L*1024L)
		{
			if (dum=='IN')
				r=glb.mem.tlen-glb.mem.tfre+10L*1024L;
			else
				r=len;
			n=(*manag_shrink)(r);
			if (n>0)
				glb.mem.tlen=n;
		}
	}
	else if (dum=='AX' || (!dum && len>glb.mem.tlen))
	{
		if (dum=='AX')
		{
			r=glb.mem.tlen+_freeRam(glb.mem.type);
			d=(r-glb.mem.tlen)/100L;
			for (c=r;c>glb.mem.tlen;c-=d)
			{
				n=(*manag_grow)(MM_NOFILL,c);
				if (n>0)
				{
					glb.mem.tlen=n;
					c=0;
				}
			}
		}
		else
		{
			n=(*manag_grow)(MM_NOFILL,len);
			if (n>0)
				glb.mem.tlen=n;
		}
	}
	glb.mem.free=0;
	_memUpdate();
}


/*******************************************************************************
	This functions allocs a user memory bloc
*******************************************************************************/
int _mAlloc(long len,int cls)
{
	long	ret;
	int	n=-1;
	int	i;

	if (len&1)
		len+=1;

#ifdef FORCE_MALLOC
	for (i=MEM_FIRST;i<glb.opt.Mem_Num;i++)
#else
	for (i=0;i<glb.opt.Mem_Num;i++)
#endif
		if (glb.mem.adr[i]==0 && glb.mem.len[i]==0)
		{
			n=i;
			i=glb.opt.Mem_Num;
		}

	if (n!=-1)
	{
		if (cls)
			ret=(*blk_malloc)(glb.mem.adr,glb.mem.len,n,glb.opt.Mem_Num,len,0);
		else
			ret=(*blk_malloc)(glb.mem.adr,glb.mem.len,n,glb.opt.Mem_Num,len,MM_NOFILL);
sprintf(glb.div.log,"malloc: %02i %09li %09li\n",n,glb.mem.adr[n],glb.mem.len[n]);
_reportLog(LOG_MEM);
		_memUpdate();
		if (ret!=MM_ERROR)
			return n;
	}
	return NO_MEMORY;
}
int _mAllocForce(int in,long len,int cls)
{
	long	ret;

	if (len&1)
		len+=1;

	if (glb.mem.adr[in]==0 && glb.mem.len[in]==0)
	{
		if (cls)
			ret=(*blk_malloc)(glb.mem.adr,glb.mem.len,in,glb.opt.Mem_Num,len,0);
		else
			ret=(*blk_malloc)(glb.mem.adr,glb.mem.len,in,glb.opt.Mem_Num,len,MM_NOFILL);
sprintf(glb.div.log,"mallocForce: %02i %09li %09li\n",in,glb.mem.adr[in],glb.mem.len[in]);
_reportLog(LOG_MEM);
		_memUpdate();
		if (ret!=MM_ERROR)
			return in;
	}
	return NO_MEMORY;
}


/*******************************************************************************
	This function frees a user memory bloc
*******************************************************************************/
void _mFree(int i)
{
	if (i>=0)
	{
		if (glb.mem.adr[i]!=0 && glb.mem.len!=0)
		{
sprintf(glb.div.log,"mfree:  %02i %09li %09li\n",i,glb.mem.adr[i],glb.mem.len[i]);
_reportLog(LOG_MEM);
			(*blk_free)(glb.mem.adr,glb.mem.len,i,glb.opt.Mem_Num);
			_memUpdate();
		}
	}
}


/*******************************************************************************
	This function frees a user bloc with its adress (usefull for the NO_MOVE
	type blocs or for compatibility (see GLC_CICN) )
*******************************************************************************/
void _mSpecFree(long adr)
{
	int	i;

	for (i=0;i<glb.opt.Mem_Num;i++)
		if (glb.mem.adr[i]==adr)
		{
sprintf(glb.div.log,"mfree:  %02i %09li %09li\n",i,glb.mem.adr[i],glb.mem.len[i]);
_reportLog(LOG_MEM);
			(*blk_free)(glb.mem.adr,glb.mem.len,i,glb.opt.Mem_Num);
			i=glb.opt.Mem_Num;
		}
	_memUpdate();
}


/*******************************************************************************
	This function changes a memory bloc size
*******************************************************************************/
long _mDim(int i,long len,int cls,long off)
{
	long	ret=0L;

	if (i>=0)
	{
		if (len&1)
			len+=1;
		ret=glb.mem.len[i];
sprintf(glb.div.log,"mdim:   %02i %09li %09li %09li\n",i,glb.mem.adr[i],glb.mem.len[i],len);
_reportLog(LOG_MEM);
		if (len<ret)
			ret=(*blk_shrink)(glb.mem.adr,glb.mem.len,i,glb.opt.Mem_Num,len,off);
		else if (len>ret)
			ret=(*blk_grow)(glb.mem.adr,glb.mem.len,i,glb.opt.Mem_Num,len,cls,off);
		_memUpdate();
	}
	return ret;
}


long _freeRam(int type)
{
	int		i;
	long		adr[100],len,total=0;

	if (type==TT_ONLY && Sversion()<0x1900)
		return 0L;

	i=0;
	do
	{
		if (Sversion()>=0x1900)
			len=(long)Mxalloc(-1L,type);
		else
			len=(long)Malloc(-1L);

		if (len>0)
		{
			if (Sversion()>=0x1900)
				adr[i]=(long)Mxalloc(len,type);
			else
				adr[i]=(long)Malloc(len);

			if (adr[i]<0)
			{
				adr[i]=0;
				i=100;
			}
			else
				total+=len;
			i+=1;
		}
		adr[i]=0;
	}	while (len>0 && i<100);
	i=0;
	while (adr[i]!=0)
	{
		Mfree((void *)adr[i]);
		adr[i++]=0;
	}
	return total;
}


/*******************************************************************************
	This function update the free mem
*******************************************************************************/
static void _memUpdate()
{
	OBJECT	*tree;
	int		i,obx,oby,obw,obh;

	glb.mem.tfre=(*manag_size)();
	if (glb.mem.tfre!=glb.mem.free && !glb.div.Exit)
	{
		glb.mem.free=glb.mem.tfre;
		updFreeMem();
		_initRSC(FMEM,FMEMSYS);
		_initRSC(FMEM,FMEMLEN);
		_initRSC(FMEM,FMEMFRE);
		wind_update(BEG_UPDATE);
		i=_winFindId(TW_FORM,FMEM,TRUE);
		if (i!=-1)
		{
			tree=glb.rsc.head.trindex[FMEM];
			_coord(tree,FMEMLEN,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(i,tree,FMEMLEN,MAX_DEPTH,obx,oby,obw,obh);
			_coord(tree,FMEMFRE,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(i,tree,FMEMFRE,MAX_DEPTH,obx,oby,obw,obh);
			_coord(tree,FMEMSYS,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(i,tree,FMEMSYS,MAX_DEPTH,obx,oby,obw,obh);
		}
		wind_update(END_UPDATE);
	}
}


/*******************************************************************************
*******************************************************************************/
void *_Malloc(long number,int type)
{
	if (type==TT_ONLY && Sversion()<0x1900)
		return (void *)0;

	if (Sversion()>=0x1900)
		return Mxalloc(number,type);
	else
		return Malloc(number);
}
