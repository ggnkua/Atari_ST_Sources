/* ====================================================================
 *		Bindings for the new Atari FALCON 030 computer
 *				TOS 4.2
 * ====================================================================
 *
 * Falcon/030 news call and defines.
 * France (c) Atari 
 * 27 Jully 1994
 * revision, 28/7/94
 * by FunShip
 * Pure-C bindings
 *
 */

#ifndef	__FALCON030__
#define	__FALCON030__	__FALCON030__

/*
  ====================== Video call and defines =======================
*/


#define XSetscreen(log,phy,mode)	(int)xbios(0x05,log,phy,3,mode)

#define Vsetmode(mode)			(int)xbios(0x58,mode)
#define Mon_Type()			(int)xbios(0x59)
#define Vsetsync(mode)			(void)xbios(0x5A,mode)
#define Vgetsize(mode)			(long)xbios(0x5B,mode)
#define VsetRGB(tabl,n,index)		(void)xbios(0x5D,tabl,n,index)
#define VgetRGB(tabl,n,index)		(void)xbios(0x5E,tabl,n,index)



#define NUMCOLS			7

#define VERTFLAG		0x0100
#define STMODES			0x0080
#define OVERSCAN		0x0040
#define PAL			0x0020
#define VGA			0x0010
#define TV			0x0000

#define COL80			0x0008
#define COL40			0

#define NUMCOLS			7
#define BPS16			4
#define BPS8			3
#define BPS4			2
#define BPS2			1
#define BPS1			0

/*
  ====================== Sound call and defines =======================
*/

#define Locksnd()			(long)xbios(0x80)
#define Unlocksnd()			(long)xbios(0x81)
#define Soundcmd(mode,data)		(long)xbios(0x82,mode,data)
#define Setbuffer(reg,beg,end)		(long)xbios(0x83,reg,beg,end)
#define Setmode(mode)			(long)xbios(0x84,mode)
#define Settracks(play,rec)		(long)xbios(0x85,play,rec)
#define Setmontracks(track)		(long)xbios(0x86,track)
#define Setinterrupt(src,cause)		(long)xbios(0x87,src,cause)
#define Buffoper(mode)			(long)xbios(0x88,mode)
#define Dsptristate(dspxmit,dsprec)	(long)xbios(0x89,dspxmit,dsprec)
#define Gpio(mode,data)			(long)xbios(0x8A,mode,data)
#define Devconnect(src,dest,clk,presc,proto)	(long)xbios(0x8B,src,dest,clk,presc,proto)
#define Sndstatus(reset)		(long)xbios(0x8C,reset)
#define Buffptr(pointer)		(long)xbios(0x8D,pointer)

/* locksnd et unlocksnd */
#define SNDLOCKED	129
#define SNDNOLOCK	128

/* Soundcmd */
#define LTATTEN		0
#define RTATTEN		1
#define LTGAIN		2
#define RTGAIN		3
#define ADDERIN		4
#define ADCINPUT	5
#define SETPRESCALE	6

#define ADCIN		1
#define MATIN		2

#define PSGRT		1
#define PSGLT		2
#define MICRO		0

/* Setbuffer */
#define BUFRECORD	1
#define BUFPLAY		0

/* Setmode */
#define STEREO8		0
#define STEREO16	1
#define MONO8		2

/* Setmontracks */
#define TRACK0		0
#define TRACK1		1
#define TRACK2		2
#define TRACK3		3

/* Setinterrupt */
#define ITNONE		0
#define ITENDPLAY	1
#define ITENDREC	2

/* Buffoper */
#define OPER_OFF	0
#define OPER_PLAY	1
#define OPER_PLAY_LOOP	2
#define OPER_REC	4
#define OPER_REC_LOOP	8

/* Devconnect */
#define ADC		3
#define EXTINP		2
#define DSPXMIT		1
#define DMAPLAY		0

#define DMAREC		1
#define DSPRECV		2
#define EXTOUT		4
#define DAC		8

#define CLK25M		0
#define CLKEXT		1
#define CLK32M		2
#define CLK50K		1
#define CLK33K		2
#define CLK25K		3
#define CLK20K		4
#define CLK16K		5
#define CLK12K		7
#define CLK10K		9
#define CLK8K		11

#define HANDSHAKE	0
#define NOHANDSHAKE	1

#define SND_RESET	1

/*
  ======================= DSP call and defines ========================
*/

#define Dsp_DoBlock(datain,sizein,dataout,sizeout)	(void)xbios(0x60,datain,sizein,dataout,sizeout)
#define Dsp_BlkHandshake(datain,sizein,dataout,sizeout)	(void)xbios(0x61,datain,sizein,dataout,sizeout)
#define Dsp_BlkUnpacked(datain,sizein,dataout,sizeout)	(void)xbios(0x62,datain,sizein,dataout,sizeout)
#define Dsp_InStream(datain,blksize,numblk,blkdone)	(void)xbios(0x63,datain,blksize,numblk,blkdone)
#define Dsp_OuStream(dataout,blksize,numblk,blkdone)	(void)xbios(0x64,dataout,blksize,numblk,blkdone)
#define Dsp_IOStream(a,b,c,d,e,f)			(void)xbios(0x65,a,b,c,d,e,f)
#define Dsp_RemoveInterrupts(mask)			(void)xbios(0x66,mask)
#define	Dsp_GetWordSize()				(void)xbios(0x67)
#define	Dsp_Lock()					(int)xbios(0x68)
#define Dsp_Unlock()					(void)xbios(0x69)
#define Dsp_Available(xavail,yavail)			(void)xbios(0x6A,xavail,yavail)
#define Dsp_Reserve(xreser,yreser)			(void)xbios(0x6B,xreser,yreser)
#define	Dsp_LoadProg(file,ability,buff)			(int)xbios(0x6C,file,ability,buff)
#define Dsp_ExecProg(ptr,codesize,ability)		(void)xbios(0x6D,ptr,codesize,ability)
#define Dsp_ExecBoot(ptr,codesize,ability)		(void)xbios(0x6E,ptr,codesize,ability)
#define Dsp_LodToBinary(file,ptr)			(void)xbios(0x6F,file,ptr)
#define Dsp_TriggerHC(vector)				(void)xbios(0x70,vector)
#define Dsp_RequestUniqueAbility()			(int)xbios(0x71)
#define Dsp_GetProgAbility()				(void)xbios(0x72)
#define Dsp_FlushSubroutines()				(void)xbios(0x73)
#define Dsp_LoadSubroutines(ptr,size,ability)		(void)xbios(0x74,ptr,size,ability)
#define Dsp_InqSubrAbility(ability)			(void)xbios(0x75,ability)
#define Dsp_RunSubroutine(handle)			(void)xbios(0x76,handle)
#define Dsp_HF0(flag)					(void)xbios(0x77,flag)
#define Dsp_HF1(flag)					(void)xbios(0x78
#define Dsp_HF2()					(void)xbios(0x79)
#define Dsp_HF3()					(void)xbios(0x7A)
#define Dsp_BlkWords(din,sin,dout,sout)			(void)xbios(0x7B,din,sin,dout,sout)
#define Dsp_BlkBytes(din,sin,dout,sout)			(void)xbios(0x7C,din,sin,dout,sout)
#define Dsp_HStat()					(void)xbios(0x7D)
#define Dsp_SetVectors(receive,transmit)		(void)xbios(0x7E,receive,transmit)
#define Dsp_MultiBlocks(nsend,nreceive,sblk,rblk)	(void)xbios(0x7F,nsend,nreceive,sblk,rblk)

/*
  ================= End of Falcon's calls & defines ===================
*/

#endif
/*End of File*/