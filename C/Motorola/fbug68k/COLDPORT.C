#include"textdef.h"

/* ************************************************************** */
/*
This is the initialization routine. The cold start will come here. 
First the duart is initialized, then the register table for the mpu
registers. Next the symbol, followed by the break, table are
initialized. The mainloop is called and the monitor is off and
running.
*/
/* ************************************************************** */

main()
{
extern struct breakelem brtable[];
extern struct symbelem symb[];
extern struct regelem mpu[];
extern int asmhandler;
register int i,j,k,l;


	if (get32(VBRLOC) == 1)
	{
	put32(VBRLOC,0);
	i = 0;
	mpu[i].value = USERPCLOC;
	mpu[i++].name = p_c;
	mpu[i].value = SRSTART;
	mpu[i++].name = s_r;
#if(DEVICE>=68020)
	mpu[i++].name = "=";
#endif
	mpu[i].value = USERUSPLOC;
	mpu[i++].name = usp;
#if(DEVICE<68020)
	mpu[i++].name = "=";
#endif
	mpu[i].value = USERMSPLOC;
	mpu[i++].name = msp;
#if(DEVICE<68020)
	mpu[i].value = USERSSPLOC;
	mpu[i++].name = ssp;
#else
	mpu[i].value = USERISPLOC;
	mpu[i++].name = isp;
#endif
	mpu[i].value = USERVBRLOC;
	mpu[i++].name = vbr;
	j = i;
	mpu[i++].name = cac;
	mpu[i++].name = caa;
	mpu[i++].name = sfc;
	mpu[i++].name = dfc;
	mpu[i++].name = "=";
	mpu[i++].name = d_0;
	mpu[i++].name = d_1;
	mpu[i++].name = d_2;
	mpu[i++].name = d_3;
	mpu[i++].name = d_4;
	mpu[i++].name = d_5;
	mpu[i++].name = d_6;
	mpu[i++].name = d_7;
	mpu[i++].name = "=";
	mpu[i++].name = a_0;
	mpu[i++].name = a_1;
	mpu[i++].name = a_2;
	mpu[i++].name = a_3;
	mpu[i++].name = a_4;
	mpu[i++].name = a_5;
	mpu[i++].name = a_6;
	k=i;
#if(DEVICE<68020)
	mpu[i].value = USERSSPLOC;
#else
	mpu[i].value = USERISPLOC;
#endif
	mpu[i++].name = a_7;
#if(DEVICE==68030)
	mpu[i++].name = "=";
	mpu[i++].name = "=";
	mpu[i].value = 1;
	mpu[i++].name = crp;
	mpu[i++].name = "crpl";
	mpu[i].value = 1;
	mpu[i++].name = srp;
	mpu[i++].name = "srpl";
	mpu[i++].name = "=";
	mpu[i++].name = tc;
	mpu[i++].name = tt_0;
	mpu[i++].name = tt_1;
	mpu[i++].name = mmusr;
#endif
#if(DEVICE==68040)
	mpu[i++].name = "=";
	mpu[i++].name = "=";
	mpu[i].value = 1;
	mpu[i++].name = urp;
	mpu[i++].name = "urpl";
	mpu[i].value = 1;
	mpu[i++].name = srp;
	mpu[i++].name = "srpl";
	mpu[i++].name = tc;
	mpu[i++].name = "=";
	mpu[i++].name = dtt_0;
	mpu[i++].name = dtt_1;
	mpu[i++].name = itt_0;
	mpu[i++].name = itt_1;
	mpu[i++].name = mmusr;
#endif
	l = i;

#if(DEVICE==68040 || COPROCESSOR==TRUE)
	mpu[i++].name = "=";
	mpu[i++].name = "=";
	mpu[i].value = 0;
	mpu[i++].name = "FPCR ";
	mpu[i].value = 0;
	mpu[i++].name = "FPSR ";
	mpu[i].value = 0;
	mpu[i++].name = "FPIAR ";
	l = i;
	mpu[i++].name = "=";
	mpu[i++].name = "FP0  ";
	mpu[i++].name = "fp01 ";
	mpu[i++].name = "fp02 ";
	mpu[i++].name = "FP1  ";
	mpu[i++].name = "fp11 ";
	mpu[i++].name = "fp12 ";
	mpu[i++].name = "FP2  ";
	mpu[i++].name = "fp21 ";
	mpu[i++].name = "fp22 ";
	mpu[i++].name = "FP3  ";
	mpu[i++].name = "fp31 ";
	mpu[i++].name = "fp32 ";
	mpu[i++].name = "FP4  ";
	mpu[i++].name = "fp41 ";
	mpu[i++].name = "fp42 ";
	mpu[i++].name = "FP5  ";
	mpu[i++].name = "fp51 ";
	mpu[i++].name = "fp52 ";
	mpu[i++].name = "FP6  ";
	mpu[i++].name = "fp61 ";
	mpu[i++].name = "fp62 ";
	mpu[i++].name = "FP7  ";
	mpu[i++].name = "fp71 ";
	mpu[i++].name = "fp72 ";
#endif
	mpu[i].name = LASTCMD;

	for(i=j;mpu[i].name != LASTCMD;i++)
		if(i!=k && i!=k+3 && i!=k+5 && i<=l)
			mpu[i].value = 0;


	for (i = 0;ROMSYMB[i] != ENDSTR;i++)
		symb[0].name[i] = ROMSYMB[i];
	symb[0].value = ROMLOC;
	for (i = 1;i < MAXSYMBOL;i++)
	{
		symb[i].name[0] = ENDSTR;
		symb[i].value = 0;
	}

	for (i = 0,j = 0;i < MAXBR;i++)
	{
		brtable[i].count = -1;
		brtable[i].tempcount = 0;
		brtable[i].address = 0; brtable[i].inst1 = 0;
		brtable[i].inst2 = 0;
	}

	for (i = 0x8;i < 0x3fc;i = i + 4)
	{
		put32(USERVBRLOC + i,&asmhandler);
		put32(VBRLOC + i,&asmhandler);
	}

	put8(HOST + CRX,0x30);
	put8(HOST + CRX,0x20);
	put8(HOST + CRX,0x10);
	put8(HOST + CSRX,0xbb);
	put8(HOST + MR1X,0x13);
	put8(HOST + MR2X,0x07);
	put8(HOST + CRX,0x05);
	put8(TERMINAL + CRX,0x30);
	put8(TERMINAL + CRX,0x20);
	put8(TERMINAL + CRX,0x10);
	put8(TERMINAL + IVR,0x0f);
	put8(TERMINAL + IMR,0x00);
	put8(TERMINAL + ACR,0x00);
	put8(TERMINAL + CTUR,0x00);
	put8(TERMINAL + CTLR,0x02);
	put8(TERMINAL + OPCR,0x00);
	put8(TERMINAL + CSRX,0xbb);
	put8(TERMINAL + MR1X,0x13);
	put8(TERMINAL + MR2X,0x07);
	put8(TERMINAL + CRX,0x05);
	}
	print("Copyright Motorola Inc. 1989   All Rights Reserved\n");
	print("Fbug68 Monitor/Debugger Version 1.1 - 9/28/89 \n");
	mainloop();
}

/* *************************************************************** */

