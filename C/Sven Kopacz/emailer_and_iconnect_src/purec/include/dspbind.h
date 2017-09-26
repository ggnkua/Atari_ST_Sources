/*	Added typecasts, only valid if sizeof(int) == 2 */

/*extern long xbios();*/

struct dspblock
{	int  blocktype;	/* 0 = longs, 1 = signed ints, 2 = unsigned chars */
	long blocksize;
	long blockaddr;
} ;


/* DSP XBIOS functions (trap #14) */

#define Dsp_DoBlock(a,b,c,d)		(void) xbios( 96,(char*)(a),(long)(b),\
													 (char*)(c),(long)(d))
#define Dsp_BlkHandShake(a,b,c,d)   (void) xbios( 97,(char*)(a),(long)(b),\
													 (char*)(c),(long)(d))
#define Dsp_BlkUnpacked(a,b,c,d)	(void) xbios( 98,(long*)(a),(long)(b),\
													 (long*)(c),(long)(d))
#define Dsp_InStream(a,b,c,d)		(void) xbios( 99,(char*)(a),(long)(b),\
													 (long)(c),(long*)(d))
#define Dsp_OutStream(a,b,c,d)		(void) xbios(100,(char*)(a),(long)(b),\
													 (long)(c),(long*)(d))
#define Dsp_IOStream(a,b,c,d,e,f)   (void) xbios(101,(char*)(a),(char*)(b),\
													 (long)(c),(long)(d),\
													 (long)(e),(long*)(f))
#define Dsp_RemoveInterrupts(a) 	(void) xbios(102,(int)(a))
#define Dsp_GetWordSize()			(int)  xbios(103)
#define Dsp_Lock()					(int)  xbios(104)
#define Dsp_Unlock()				(void) xbios(105)
#define Dsp_Available(a,b)			(void) xbios(106,(long*)(a),(long*)(b))
#define Dsp_Reserve(a,b)			(int)  xbios(107,(long)(a),(long)(b))
#define Dsp_LoadProg(a,b,c) 		(int)  xbios(108,(char*)(a),(int)(b),\
													 (char*)c)
#define Dsp_ExecProg(a,b,c) 		(void) xbios(109,(char*)(a),(long)(b),\
													 (int)(c))
#define Dsp_ExecBoot(a,b,c) 		(void) xbios(110,(char*)(a),long)(b),\
													 (int)(c))
#define Dsp_LodToBinary(a,b)		(long) xbios(111,(char*)(a),(char*)(b))
#define Dsp_TriggerHC(a)			(void) xbios(112,(int)(a))
#define Dsp_RequestUniqueAbility()  (int)  xbios(113)
#define Dsp_GetProgAbility()		(int)  xbios(114)
#define Dsp_FlushSubroutines()		(void) xbios(115)
#define Dsp_LoadSubroutine(a,b,c)   (int)  xbios(116,(char*)(a),(long)(b),\
													 (int)(c))
#define Dsp_InqSubrAbility(a)		(int)  xbios(117,(int)(a))
#define Dsp_RunSubroutine(a)		(int)  xbios(118,(int)(a))
#define Dsp_Hf0(a)					(int)  xbios(119,(int)(a))
#define Dsp_Hf1(a)					(int)  xbios(120,(int)(a))
#define Dsp_Hf2()					(int)  xbios(121)
#define Dsp_Hf3()					(int)  xbios(122)
#define Dsp_BlkWords(a,b,c,d)		(void) xbios(123,(int*)(a),(long)(b),\
													 (int*)(c),(long)(d))
#define Dsp_BlkBytes(a,b,c,d)		(void) xbios(124,(unsigned char*)(a),\
													 (long)(b),\
													 (unsigned char*)(c),\
													 (long)(d))
#define Dsp_HStat() 				(char) xbios(125)
#define Dsp_SetVectors(a,b) 		(void) xbios(126,(void (*))(a),\
													 (long (*))(b))
#define Dsp_MultBlocks(a,b,c,d) 	(void) xbios(127,(long)(a),(long)(b),\
													 (struct dspblock*)(c),\
													 (struct dspblock*)(d))
