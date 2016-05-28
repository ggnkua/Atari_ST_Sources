typedef enum {
	HF_ASK=-1,
	HF_CLR=0,
	HF_SET=1
} HF_ENUM;

/* DSP XBIOS functions (trap #14) */
void	DspDoBlock(char *data_in,long size_in,char *data_out,long size_out);
void	DspBlkHandShake(char *data_in,long size_in,char *data_out,long size_out);
void	DspBlkUnpacked(char *data_in,long size_in,char *data_out,long size_out);
void	DspInStream(char *data_in,long block_size,long num_blocks,long *blocks_done);
void	DspOutStream(char *data_in,long block_size,long num_blocks,long *blocks_done);
void	DspIOStream(char *data_in,char *data_out,long block_insize,long block_outsize,long num_blocks,long *blocks_done);
void	DspRemoveInterrupts(short mask);
short	DspGetWordSize(void);
short	DspLock(void);
void	DspUnlock(void);
void	DspAvailable(long *xavailable,long *yavailable);
short	DspReserve(short xreserve,short yreserve);
void	DspLoadProg(char *file,short ability);
void	DspExecProg(char *codeptr,long codesize,short ability);
void	DspExecBoot(char *codeptr,long codesize,short ability);
long	DspLodToBinary(char *file,char *ptr);
void	DspTriggerHC(short vector);
short	DspRequestUniqueAbility(void);
short	DspGetProgAbility(void);
void	DspFlushSubroutines(void);
short	DspLoadSubroutine(char *ptr,long size,short ability);
short	DspInqSubrAbility(short ability);
short	DspRunSubroutine(short handle);
short	DspHf0(HF_ENUM);
short	DspHf1(HF_ENUM);
short	DspHf2(void);
short	DspHf3(void);
char	DspHStat(void);
void	DspBlkWords(long *data_in,long size_in,long *data_out,long size_out);
void	DspBlkBytes(long *data_in,long size_in,long *data_out,long size_out);
void	DspSetVectors(void(*receiver)(long),long(*transmitter)(void));
/* + */
short	IsDspDrv(void);	/* Is the DSP driver installed */
short	DspOutStat(void);	/* bit0=word pending, bit1=Hf2, bit2=Hf3 */
short	DspInStat(void);	/* bit0=can receive, bit1=Hf2, bit2=Hf3 */

