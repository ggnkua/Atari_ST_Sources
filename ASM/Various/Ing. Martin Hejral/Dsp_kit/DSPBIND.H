/*==================================================================
===== Syst‚mov‚ XBIOS funkce pro obsluhu DSP  =====  15.1.1996 =====
==================================================================*/

/* void Dsp_DoBlock(char *data_in, long size_in, char *data_out, long size_out); */
#define Dsp_DoBlock(a,b,c,d)		(void) xbios( 96,(void*)a,(long)b,(void*)c,(long)d)

/* void Dsp_BlkHandshake(char *data_in, long size_in, char *data_out, long size_out); */
#define Dsp_BlkHandshake(a,b,c,d)	(void) xbios( 97,(void*)a,(long)b,(void*)c,(long)d)

/* void Dsp_BlkUnpacked(long *data_in, long size_in, long *data_out, long size_out); */
#define Dsp_BlkUnpacked(a,b,c,d)	(void) xbios( 98,(void*)a,(long)b,(void*)c,(long)d)

/* void Dsp_InStream(char *data_in, long blk_size, long num_blocks, long *blocks_done); */
#define Dsp_InStream(a,b,c,d)      (void) xbios( 99,(void*)a,(long)b,(long)c,(void*)d)

/* void Dsp_OutStream(char *data_out, long blk_size, long num_blocks, long *blocks_done); */
#define Dsp_OutStream(a,b,c,d)     (void) xbios(100,(void*)a,(long)b,(long)c,(void*)d)

/* void Dsp_IOStream(char *data_in, char *data_out, long blk_insize, long blk_outsize, long num_blocks, long *blocks_done); */
#define Dsp_IOStream(a,b,c,d,e,f)  (void) xbios(101,(void*)a,(void*)b,(long)c,(long)d,(long)e,(void*)f)

/* void Dsp_RemoveInterrupts(int mask); */
#define Dsp_RemoveInterrupts(a) (void) xbios(102,a)

/* int Dsp_GetWordSize(void); */
#define Dsp_GetWordSize()       (int)  xbios(103)

/* int Dsp_Lock(void); */
#define Dsp_Lock()              (int)  xbios(104)

/* void Dsp_Unlock(void); */
#define Dsp_Unlock()            (void) xbios(105)

/* void Dsp_Available(long *xfree, long *yfree); */
#define Dsp_Available(a,b)      (void) xbios(106,(void*)a,(void*)b)

/* int Dsp_Reserve(long xreserve, long yreserve); */
#define Dsp_Reserve(a,b)        (int)  xbios(107,(long)a,(long)b)

/* int Dsp_LoadProg(char *file, int ability, char *buf); */
#define Dsp_LoadProg(a,b,c)     (int)  xbios(108,(void*)a,b,(void*)c)

/* void Dsp_ExecProg(char *code, long codesize, int ability); */
#define Dsp_ExecProg(a,b,c)     (void) xbios(109,(void*)a,(long)b,c)

/* void Dsp_ExecBoot(char *code, long codesize, int ability); */
#define Dsp_ExecBoot(a,b,c)     (void) xbios(110,(void*)a,(long)b,c)

/* long Dsp_LodToBinary(char *file, char *codeptr); */
#define Dsp_LodToBinary(a,b)    (long) xbios(111,(void*)a,(void*)b)

/* int Dsp_RequestUniqueAbility(void); */
#define Dsp_RequestUniqueAbility()          (int)  xbios(113)

/* int Dsp_GetProgAbility(void); */
#define Dsp_GetProgAbility()    (int)  xbios(114)

/* void Dsp_FlushSubroutines(void); */
#define Dsp_FlushSubroutines()  (void) xbios(115)

/* int Dsp_LoadSubroutine(char *ptr, long size, int ability); */
#define Dsp_LoadSubroutine(a,b,c)           (int)  xbios(116,(void*)a,(long)b,c)

/* int Dsp_InqSubrAbility(int ability); */
#define Dsp_InqSubrAbility(a)   (int)  xbios(117,a)

/* int Dsp_RunSubroutine(int handle); */
#define Dsp_RunSubroutine(a)    (int)  xbios(118,a)

/* int Dsp_Hf0(int flag); */
#define Dsp_Hf0(a)              (int)  xbios(119,a)

/* int Dsp_Hf1(int flag); */
#define Dsp_Hf1(a)              (int)  xbios(120,a)

/* int Dsp_Hf2(int flag); */
#define Dsp_Hf2()               (int)  xbios(121)

/* int Dsp_Hf0(int flag); */
#define Dsp_Hf3()               (int)  xbios(122)

/* void Dsp_BlkWords(int *data_in, long size_in, int *data_out, long size_out); */
#define Dsp_BlkWords(a,b,c,d)   (void) xbios(123,(void*)a,(long)b,(void*)c,(long)d)

/* void Dsp_BlkBytes(BYTE *data_in, long size_in, BYTE *data_out, long size_out); */
#define Dsp_BlkBytes(a,b,c,d)   (void) xbios(124,(void*)a,(long)b,(void*)c,(long)d)

/* WORD Dsp_HStat(void); */
#define Dsp_HStat()             (char) xbios(125)

/* void Dsp_SetVectors( void (*receiver)(), long(*transmitter)() ); */
#define Dsp_SetVectors(a,b)     (void) xbios(126,a,b)

/*================================================================*/
