/************************************************************************/
/*					Version of Dspbind.h for Lattice v5.0				*/	
/*					Uses #pragma inline code							*/
/*					to get round Atari's inconsistant use of			*/
/*					short int's and other silly things					*/
/*			Copyright 29 March 1993 Dave Malham, Music Technology Group	*/
/*			University of York, England	- with thanks to Martin Atkins	*/
/*			for showing me how to do it!								*/
/************************************************************************/




extern long xbios();

/* DSP XBIOS functions (trap #14) */

short	__sxpsp(int, void *, int, void *);
void	__vxplpl(int, void *,long, void *,long);
void	__vxpllp(int, void *,long,long, void *);
void	__vxpplllp(int,void *,void *,long,long,void *);
void	__vxs(int,int);
short	__sxv(int);
void	__vxv(int);
short	__sxs(int,int);
short	__sxpls(int,void *,long,int);
char 	__cxv(char,int);
void	__vxll(int,long,long);
short	__sxll(int,long,long);
void	__vxpls(int,void *,long,int);
long	__lxpp(int,void *,void *);
void	__vxpp(int,void*,void*);
void	__vxllpp(int,long,long,void*,void*);
short	__sxpp(int,void*,void*);


#pragma inline d0=__sxpsp((short),,(short),)	{register d2,a2; "4e4e";}
#pragma inline 	  __vxplpl((short),,,,)			{register d2,a2; "4e4e";}
#pragma inline 	  __vxpllp((short),,,,)			{register d2,a2; "4e4e";}
#pragma inline 	  __vxpplllp((short),,,,,,)		{register d2,a2; "4e4e";}
#pragma inline 	  __vxs((short),(short))		{register d2,a2; "4e4e";}
#pragma inline d0=__sxv((short))				{register d2,a2; "4e4e";}
#pragma inline 	  __vxv((short))				{register d2,a2; "4e4e";}
#pragma inline d0=__sxs((short),(short))		{register d2,a2; "4e4e";}
#pragma inline d0=__sxpls((short),,,(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__cxv((short))				{register d2,a2; "4e4e";}
#pragma inline 	  __vxll((short),,,)			{register d2,a2; "4e4e";}
#pragma inline d0=__sxll((short),,,)			{register d2,a2; "4e4e";}
#pragma inline 	  __vxpls((short),,,(short))	{register d2,a2; "4e4e";}
#pragma inline 	  __lxpp((short),,,)			{register d2,a2; "4e4e";}
#pragma	inline	  __vxpp((short),,,)			{register d2,a2; "4e4e";}
#pragma	inline	  __vxllpp((short),,,,)			{register d2,a2; "4e4e";}
#pragma	inline d0=__sxpp((short),,,)			{register d2,a2; "4e4e";}


#define	Dsp_DoBlock(a,b,c,d)			__vxplpl(96,a,b,c,d)	/** T **/
#define	Dsp_BlkHandShake(a,b,c,d)		__vxplpl(97,a,b,c,d)
#define Dsp_BlkUnpacked(a,b,c,d)		__vxplpl(98,a,b,c,d)	/** T **/
#define	Dsp_InStream(a,b,c,d)			__vxpllp(99,a,b,c,d)
#define	Dsp_OutStream(a,b,c,d)			__vxpllp(100,a,b,c,d)
#define	Dsp_IOStream(a,b,c,d,e,f)		__vxpplllp(101,a,b,c,d,e,f)
#define	Dsp_RemoveInterrupts(a)			__vxs(102,a)
#define	Dsp_GetWordSize()				__sxv(103)
#define	Dsp_Lock()						__sxv(104)	/** T **/
#define	Dsp_Unlock()					__vxv(105)	/** T **/
#define	Dsp_Available(a,b)				__vxpp(106,a,b)	/** T **/
#define	Dsp_Reserve(a,b)				__sxpp(107,a,b)
#define Dsp_LoadProg(a,b,c)				__sxpsp(108,a,b,c)	/** T **/
#define	Dsp_ExecProg(a,b,c)				__vxpls(109,a,b,c)
#define	Dsp_ExecBoot(a,b,c)				__vxpls(110,a,b,c)
#define	Dsp_LodToBinary(a,b)			__lxpp(111,a,b)
#define	Dsp_TriggerHC(a)				__vxs(112,a)
#define	Dsp_RequestUniqueAbility()		__sxv(113)	/** T **/
#define	Dsp_GetProgAbility()			__sxv(114)	/** T **/
#define	Dsp_FlushSubroutines()			__vxv(115)	/** T **/
#define	Dsp_LoadSubroutine(a,b,c)		__sxpls(116,a,b,c)	/** T **/
#define	Dsp_InqSubrAbility(a)			__sxs(117,a)	/** T **/
#define	Dsp_RunSubroutine(a)			__sxs(118,a)	/** T **/
#define	Dsp_Hf0(a)						__sxs(119,a)	/** T **/
#define	Dsp_Hf1(a)						__sxs(120,a)	/** T **/
#define	Dsp_Hf2()						__sxv(121)
#define	Dsp_Hf3()						__sxv(122)
#define	Dsp_BlkWords(a,b,c,d)			__vxplpl(123,a,b,c,d)
#define	Dsp_BlkBytes(a,b,c,d)			__vxplpl(124,a,b,c,d)
#define	Dsp_HStat()						__cxv(125)
#define Dsp_SetVectors(a,b)				__vxpp(126,a,b)
#define Dsp_MultBlocks(a,b,c,d)			__vxllpp(127,a,b,c,d)
