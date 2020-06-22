/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <STRING.H>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "getinfo.h"
#include "K_DEFS.H"

/*
	Data table for appl_getinfo
*/

short info_tab[15][4]={
		{0,0,0,0},										/*0*/
		{0,0,0,0},										/*1*/
		{1,16,1,1},										/*2*/
		{0,0,0,0},										/*3*/
		{1,1,1,0},										/*4*/
		{0,0,0,0},										/*5*/
		{0,0,1,0},										/*6*/
		{0,0,0,0},						/* 7 isn't defined at the moment */
		{0,1,0,0},										/*8*/
		{0,0,0,1},										/*9*/
		{0x0401,0,0,0},									/*10*/
		{WF_TOP+WF_OWNER+WF_BOTTOM+WF_ICONIFY+WF_UNICONIFY,0,3,1},	/*11*/
		{WM_UNTOPPED+WM_BOTTOM+WM_ICONIFY+WM_UNICONIFY,0,1,0},		/*12*/
		{1,0,1,0},										/*13*/
		{0,0,0,0}										/*14*/
		};										

/*
	appl_getinfo() handler
*/
unsigned long XA_appl_getinfo(short clnt_pid, AESPB *pb)
{
	unsigned short gi_type=pb->intin[0];

	if ( gi_type>14 )
	{
		pb->intout[0] = 0 ;		/* "error" - unimplemented info type */
		return XAC_DONE ;
	}

	info_tab[0][0]=display.standard_font_height;
 	info_tab[0][1]=display.standard_font_id;
	info_tab[1][0]=display.small_font_height;
	info_tab[1][1]=display.small_font_id;

	pb->intout[0]=1;
	pb->intout[1]=info_tab[gi_type][0];
	pb->intout[2]=info_tab[gi_type][1];
	pb->intout[3]=info_tab[gi_type][2];
	pb->intout[4]=info_tab[gi_type][3];
	
	return XAC_DONE;
}

/*
	appl_find()
*/
unsigned long XA_appl_find(short clnt_pid, AESPB *pb)
{
	unsigned short ex=(unsigned short)((unsigned long)pb->addrin[0]>>16)&0xffff;
	char *name=(char*)pb->addrin[0],*t;
	short f,n;

	if ((ex==0xffff)||(ex==0xfffe))
	{
		pb->intout[0]=(short)(((unsigned long)pb->addrin[0]))&0xffff;	/* In XaAES AES id == MiNT pid*/
		return TRUE;
	}
	
	if (!ex)
	{
		pb->intout[0]=clnt_pid;		/* Return the pid of current process */
		return TRUE;
	}
	
/* Tell application we understand appl_getinfo() */
/* (invented by Martin Osieka for his AES extension WINX; used */
/*	by MagiC 4, too.) */
	if (strcmp(name, "?AGI")==0)
	{
		pb->intout[0]=0 ;		/* OK */
		return TRUE ;
	}

	for(f=0; f<MAX_PID; f++)
	{
		if (clients[f].clnt_pipe_rd)	/* Client active? */
		{
			t=clients[f].proc_name;
			for(n=0; (n<8)&&(name[n]==t[n]); n++);
			if(n==8)
			{
				pb->intout[0]=f;
				return TRUE;
			}
		}
	}
	
	pb->intout[0]=-1;
	return TRUE;
}
