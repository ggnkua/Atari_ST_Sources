#include	<portab.h>
#include	<aes.h>
#include	<vdi.h>
#include	<tos.h>
#include	<ctype.h>
#include 	<string.h>
#include	"strings.h"
#include	"dpk.h"

#ifdef		FALCON030
#include	"ndp_030.rh"
#include	"ndp_030.h"
#endif

#ifdef		STSTETT
#include	"ndp_st.rh"
#include	"ndp_st.h"
#endif

/*
****************************************************************************
** MACRO DEFINITIONS
****************************************************************************
*/
#define	ISDATA(a)	(*(long *)file_start==(long)a)
#define	ISDATA2(a)	(*(int *)file_start==(int)a)
#define	ISPROG(a,b)	(*(long*)((char *)file_start+a)==b)
#define	ISPROG2(a,b)	(*(int*)((char *)file_start+a)==b)

extern	char	filespec[80];
extern	long	*file_pointer;
extern	long	file_length;
extern	long	*depacked_pointer;
extern	long	depacked_length;

int	do_dial(OBJECT *tree);

int	depack(char *fname)
{
/*
** Determine the last 4 bytes of the file
*/
	long	last_long;
	register	char	*le_end;
	char	*temp;
	register long	*file_start=file_pointer;
	le_end=((char *)file_start+file_length);
	temp=(char *)&last_long;
	temp[0]=le_end[-4];
	temp[1]=le_end[-3];
	temp[2]=le_end[-2];
	temp[3]=le_end[-1];
/*
** 4PAK progfile 
*/
	if	ISPROG(58,0x4e714ef9l)
	{
		rs_object[FINFO1].ob_spec.free_string=_4pak[0];
		rs_object[FINFO2].ob_spec.free_string=_4pak[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_pointer=Malloc(*(long *)((char *)file_start+62));
		if (!depacked_pointer)
			return(-1);
		memset(depacked_pointer,0,*(long *)((char *)file_start+62));
		depacked_length=f4pak_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
****************************************************************************
** A U T O M A T I O N   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Automation 2.3/4 datafile
*/
	if	(ISDATA('LSD!')
	||	ISDATA('LSD$')
	||	ISDATA('AUTM'))
	{
		rs_object[FINFO1].ob_spec.free_string=aut_2_3r[0];
		rs_object[FINFO2].ob_spec.free_string=aut_2_3r[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+4);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		auto_dat(file_start,depacked_pointer);
		return(1);
	}		
/*
** Automation chunked datafile
*/
	if	ISDATA('LSDC')
	{
		rs_object[FINFO1].ob_spec.free_string=aut_chnk2[0];
		rs_object[FINFO2].ob_spec.free_string=aut_chnk2[1];
		rs_object[FINFO3].ob_spec.free_string=aut_chnk2[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+4);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		auto_chunk(file_start,depacked_pointer);
		return(1);
	}		
/*
** Automation 5.01 datafile
*/
	if	ISDATA('AU5!')
	{
		rs_object[FINFO1].ob_spec.free_string=aut_5_01[0];
		rs_object[FINFO2].ob_spec.free_string=aut_5_01[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+8);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		ice2_3_4_data(file_start,depacked_pointer);
		return(1);
	}		
/*
** Automation 5.01 chunked datafile
*/
	if	ISDATA('AU5C')
	{
		rs_object[FINFO1].ob_spec.free_string=aut_chnk[0];
		rs_object[FINFO2].ob_spec.free_string=aut_chnk[1];
		rs_object[FINFO3].ob_spec.free_string=aut_chnk[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+4);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		auto_chunk2(file_start,depacked_pointer);
		return(1);
	}		
/*
** Automation 2.3r progfile
*/
	if	ISPROG(482,0x2e337200l)
	{
		rs_object[FINFO1].ob_spec.free_string=aut_2_3r[0];
		rs_object[FINFO2].ob_spec.free_string=aut_2_3r[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+826);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		auto2_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** Automation 2.51 progfile
*/
	if	(ISPROG(482,0x2e353100l)
	||	ISPROG(482,0x2e357200l))
	{
		rs_object[FINFO1].ob_spec.free_string=aut_2_51[0];
		rs_object[FINFO2].ob_spec.free_string=aut_2_51[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+826);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		auto2_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** Automation 5.01 progfile
*/
	if	ISPROG(836,'AU5!')
	{
		rs_object[FINFO1].ob_spec.free_string=aut_5_01[0];
		rs_object[FINFO2].ob_spec.free_string=aut_5_01[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+844);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		auto501_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
****************************************************************************
** A T O M   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Is it ATOM v3.1/3.3/Thunder Datafiles
*/
	if	ISDATA('ATOM')
	{
		int butt;
		rs_trindex[ATOM_CLASH][ATOM_FNAME].ob_spec.free_string=fname;
		butt=do_dial(rs_trindex[ATOM_CLASH]);
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		switch	(butt)
		{
			case	V3_1_BUTT:
			{
				rs_object[FINFO1].ob_spec.free_string=atom_3_1[0];
				rs_object[FINFO2].ob_spec.free_string=atom_3_1[1];
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				depacked_length=*(long *)((char *)file_start+4);
				depacked_pointer=Malloc(depacked_length);
				if (!depacked_pointer)
					return(-1);
				a31_data(file_start,depacked_pointer);
				return(1);
			}
			case	V3_3_BUTT:
			{
				rs_object[FINFO1].ob_spec.free_string=atom_3_3[0];
				rs_object[FINFO2].ob_spec.free_string=atom_3_3[1];	
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				depacked_length=*(long *)((char *)file_start+4);
				depacked_pointer=Malloc(depacked_length);
				if (!depacked_pointer)
					return(-1);
				a33_data(file_start,depacked_pointer);
				return(1);
			}
			case	THUN_BUTT1:
			{
				rs_object[FINFO1].ob_spec.free_string=thun_1[0];
				rs_object[FINFO2].ob_spec.free_string=thun_1[1];	
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				depacked_length=*(long *)((char *)file_start+4);
				depacked_pointer=Malloc(depacked_length);
				if (!depacked_pointer)
					return(-1);
				thun1_data(file_start,depacked_pointer);
				return(1);
			}
			case	THUN_BUTT11:
			{
				rs_object[FINFO1].ob_spec.free_string=thun_1_1[0];
				rs_object[FINFO2].ob_spec.free_string=thun_1_1[1];	
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				depacked_length=*(long *)((char *)file_start+4);
				depacked_pointer=Malloc(depacked_length);
				if (!depacked_pointer)
					return(-1);
				thun2_data(file_start,depacked_pointer);
				return(1);
			}
			case	THUN_BUTT2:
			{
				rs_object[FINFO1].ob_spec.free_string=thun_2[0];
				rs_object[FINFO2].ob_spec.free_string=thun_2[1];	
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				depacked_length=*(long *)((char *)file_start+4);
				depacked_pointer=Malloc(depacked_length);
				if (!depacked_pointer)
					return(-1);
				thun2_data(file_start,depacked_pointer);
				return(1);
			}
			case	PISS_OFF_ATOM:
			{
				rs_object[FINFO1].ob_spec.free_string=scared[0];
				rs_object[FINFO2].ob_spec.free_string=blank;
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				return(0);			
			}
		}
		return(1);
	}		
/*
** Atom v3.5 Datafile
*/
	if	ISDATA('ATM5')
	{
		rs_object[FINFO1].ob_spec.free_string=atom_3_5[0];
		rs_object[FINFO2].ob_spec.free_string=atom_3_5[1];
		rs_object[FINFO3].ob_spec.free_string=atom_3_5[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+4);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		a35_data(file_start,depacked_pointer);
		return(1);
	}		
/*
** Atom v3.1 Program File
*/
	if	ISPROG(516,'ATOM')
	{
		rs_object[FINFO1].ob_spec.free_string=atom_3_1[0];
		rs_object[FINFO2].ob_spec.free_string=atom_3_1[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+538);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		a31_prog(file_start,(long *)((char *)depacked_pointer+depacked_length));
		return(1);
	}	
/*
** Atom v3.3 Program File
*/
	if	ISPROG(538,'ATOM')
	{
		rs_object[FINFO1].ob_spec.free_string=atom_3_3[0];
		rs_object[FINFO2].ob_spec.free_string=atom_3_3[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+568);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		a33_prog(file_start,(long *)((char *)depacked_pointer+depacked_length));
		return(1);
	}		
/*
** Atom v3.3 Program File - BMT
*/
	if	ISPROG(564,'/BMT')
	{
		rs_object[FINFO1].ob_spec.free_string=bmt_3_3[0];
		rs_object[FINFO2].ob_spec.free_string=bmt_3_3[1];
		rs_object[FINFO3].ob_spec.free_string=bmt_3_3[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+568);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		bmt_prog(file_start,(long *)((char *)depacked_pointer+depacked_length));
		return(1);
	}		
/*
** Atom v3.5 Program File
*/
	if	(ISPROG(336,0x1b3250f0l)
	||	ISPROG(634,'3.5 '))
	{
		rs_object[FINFO1].ob_spec.free_string=atom_3_5[0];
		rs_object[FINFO2].ob_spec.free_string=atom_3_5[1];
		rs_object[FINFO3].ob_spec.free_string=atom_3_5[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+656);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		a35_prog(file_start,(long *)((char *)depacked_pointer+depacked_length));
		return(1);
	}		
/*
** BRAS progfile 
*/
	if	ISPROG(30,'BRAS')
	{
		rs_object[FINFO1].ob_spec.free_string=bapack[0];
		rs_object[FINFO2].ob_spec.free_string=bapack[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+40);
		depacked_length+=28;
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		memset(depacked_pointer,0,depacked_length);
		bras_prog(file_start,depacked_pointer,le_end-4);
		return(1);
	}		
/*
****************************************************************************
** BYTEKILLER  O P T I O N S
****************************************************************************
*/
/*
** Bytekiller v2 progfile
*/
	if	ISPROG(72,0x0007fd00l)
	{
		rs_object[FINFO1].ob_spec.free_string=bkill_2[0];
		rs_object[FINFO2].ob_spec.free_string=bkill_2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+430);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		bkill2_prog(file_start,depacked_pointer);
		return(1);
	}	
/*
** Bytekiller v3 progfile
*/
	if	ISPROG(72,0x224a7053l)
	{
		rs_object[FINFO1].ob_spec.free_string=bkill_3[0];
		rs_object[FINFO2].ob_spec.free_string=bkill_3[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+420);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		bkill3_prog(file_start,depacked_pointer);
		return(1);
	}
/*
** Bytekiller progfile - Russ Payne
*/
	if	ISPROG(28,0x487a00aal)
	{
		rs_object[FINFO1].ob_spec.free_string=rpbkill[0];
		rs_object[FINFO2].ob_spec.free_string=rpbkill[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+454);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		bkillrp_prog(file_start,depacked_pointer);
		return(1);
	}
/*
** Bytekiller datafile - JPM
*/
	if (last_long == 'JPM!')
	{
		rs_object[FINFO1].ob_spec.free_string=bkill_jpm[0];
		rs_object[FINFO2].ob_spec.free_string=bkill_jpm[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-8];
		temp[1]=le_end[-7];
		temp[2]=le_end[-6];
		temp[3]=le_end[-5];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		bkilljpm_data(le_end,depacked_pointer);
		return(1);
	}
/*
** Bytekiller progfile - JPM
*/
	if	ISPROG(190,0x4efa0020l)
	{
		rs_object[FINFO1].ob_spec.free_string=bkill_jpm[0];
		rs_object[FINFO2].ob_spec.free_string=bkill_jpm[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-12];
		temp[1]=le_end[-11];
		temp[2]=le_end[-10];
		temp[3]=le_end[-9];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		bkilljpm_prog(file_start,depacked_pointer,(char *)le_end-8);
		return(1);
	}
/*
****************************************************************************
** DC SQUISH  P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** DC squish v1 progfile
*/
	if	ISPROG(40,'Squi')
	{
		if	ISPROG2(58,'10')
		{
			rs_object[FINFO1].ob_spec.free_string=dcs_1_0[0];
			rs_object[FINFO2].ob_spec.free_string=dcs_1_0[1];
			rs_object[FINFO3].ob_spec.free_string=blank;
			rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
			depacked_length=*(long *)((char *)file_start+30);
			depacked_pointer=Malloc(depacked_length);
			if (!depacked_pointer)
				return(-1);
			squish1_prog(file_start,depacked_pointer,file_length);
			return(1);
		}		
/*
** DC squish v1.2 progfile
*/
		if	ISPROG2(58,'12')
		{
			rs_object[FINFO1].ob_spec.free_string=dcs_1_2[0];
			rs_object[FINFO2].ob_spec.free_string=dcs_1_2[1];
			rs_object[FINFO3].ob_spec.free_string=blank;
			rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
			depacked_length=*(long *)((char *)file_start+30);
			depacked_pointer=Malloc(depacked_length);
			if (!depacked_pointer)
				return(-1);
			squish1_24_prog(file_start,depacked_pointer);
			return(1);
		}		
/*
** DC squish v1.4 progfile
*/
		if	ISPROG2(58,'14')
		{
			rs_object[FINFO1].ob_spec.free_string=dcs_1_4[0];
			rs_object[FINFO2].ob_spec.free_string=dcs_1_4[1];
			rs_object[FINFO3].ob_spec.free_string=blank;
			rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
			depacked_length=*(long *)((char *)file_start+30);
			depacked_pointer=Malloc(depacked_length);
			if (!depacked_pointer)
				return(-1);
			squish1_24_prog(file_start,depacked_pointer);
			return(1);
		}		
/*
** DC squish v2 progfile
*/
		if	ISPROG2(58,'21')
		{
			rs_object[FINFO1].ob_spec.free_string=dcs_2_0[0];
			rs_object[FINFO2].ob_spec.free_string=dcs_2_0[1];
			rs_object[FINFO3].ob_spec.free_string=blank;
			rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
			depacked_length=*(long *)((char *)file_start+30);
			depacked_pointer=Malloc(depacked_length);
			if (!depacked_pointer)
				return(-1);
			squish2_prog(file_start,depacked_pointer);
			return(1);
		}		
	}
/*
****************************************************************************
** G O L L U M   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Non huffmans
*/
	if	ISPROG(192,0x42401018l)
	{
		rs_object[FINFO1].ob_spec.free_string=gollum[0];
		rs_object[FINFO2].ob_spec.free_string=blank;
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+144);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		gol_prog(file_start,depacked_pointer);
		return(1);
	}	
/*
** huffmans
*/
	if	ISPROG(192,0x22572c7al)
	{
		rs_object[FINFO1].ob_spec.free_string=gollum_h[0];
		rs_object[FINFO2].ob_spec.free_string=gollum_h[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+144);
		depacked_pointer=Malloc(depacked_length+1000);
		if (!depacked_pointer)
			return(-1);
		memcpy(depacked_pointer,file_start,file_length);
		golh_prog(depacked_pointer,file_length);
		(char *)depacked_pointer+=698;
		return(1);
	}		
/*
****************************************************************************
** G R E M L I N   P A C K E R   O P T I O N S
****************************************************************************
*/
	if	(last_long == 'GUS*')
	{
		rs_object[FINFO1].ob_spec.free_string=gremlin[0];
		rs_object[FINFO2].ob_spec.free_string=gremlin[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-12];
		temp[1]=le_end[-11];
		temp[2]=le_end[-10];
		temp[3]=le_end[-9];

		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		gremlin_data(le_end,depacked_pointer);
		return(1);
	}		
/*
****************************************************************************
** H A P P Y   P A C K E R   O P T I O N S
****************************************************************************
*/
	if	ISPROG(52,'EASY')
	{
		rs_object[FINFO1].ob_spec.free_string=happy[0];
		rs_object[FINFO2].ob_spec.free_string=happy[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+1430);
		depacked_pointer=Malloc(depacked_length+1000);
		if (!depacked_pointer)
			return(-1);
		memcpy(depacked_pointer,file_start,file_length);
		happy_prog(depacked_pointer);
		(char *)depacked_pointer+=2200;
		return(1);
	}		
/*
****************************************************************************
** I C E   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Is it Ice 1.1 data File
*/
	if (last_long == 'Ice!')
	{
		rs_object[FINFO1].ob_spec.free_string=ice_1_1[0];
		rs_object[FINFO2].ob_spec.free_string=ice_1_1[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-8];
		temp[1]=le_end[-7];
		temp[2]=le_end[-6];
		temp[3]=le_end[-5];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		ice1_1_data(file_start,depacked_pointer,file_length);
		return(1);
	}
/*
** Is it Ice 2.0 2.2 Data File
*/
	if	ISDATA('Ice!')
	{
		int butt;
		rs_trindex[PACK_ICE_CLASH][ICE_FNAME].ob_spec.free_string=fname;
		butt=do_dial(rs_trindex[PACK_ICE_CLASH]);
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		switch	(butt)
		{
			case	V2_BUTT:
			{
				rs_object[FINFO1].ob_spec.free_string=ice_2_0[0];
				rs_object[FINFO2].ob_spec.free_string=ice_2_0[1];
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				depacked_length=*(long *)((char *)file_start+8);
				depacked_pointer=Malloc(depacked_length);
				if (!depacked_pointer)
					return(-1);
				ice2_0_data(file_start,depacked_pointer);
				return(1);
			}
			case	V2_2_BUTT:
			{
				rs_object[FINFO1].ob_spec.free_string=ice_2_2[0];
				rs_object[FINFO2].ob_spec.free_string=ice_2_2[1];	
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				depacked_length=*(long *)((char *)file_start+8);
				depacked_pointer=Malloc(depacked_length);
				if (!depacked_pointer)
					return(-1);
				ice2_2_data(file_start,depacked_pointer);
				return(1);
			}
			case	ICE_PISS_OFF:
			{
				rs_object[FINFO1].ob_spec.free_string=scared[0];
				rs_object[FINFO2].ob_spec.free_string=blank;
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				return(0);			
			}
		}
	}		
/*
** Ice v2.3/4 Data File
*/
	if	ISDATA('ICE!')
	{
		rs_object[FINFO1].ob_spec.free_string=ice_2_3_4[0];
		rs_object[FINFO2].ob_spec.free_string=ice_2_3_4[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+8);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		ice2_3_4_data(file_start,depacked_pointer);
		return(1);
	}		
/*
** Ice 1.1 Program File
*/
	if	ISPROG(70,0x610000a0l)
	{
		char	*temp;
		char	*temp2;
		rs_object[FINFO1].ob_spec.free_string=ice_1_1[0];
		rs_object[FINFO2].ob_spec.free_string=ice_1_1[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)(28+(char *)file_start);
		temp=temp+(*(long *)((char *)temp+34));
		temp=temp-4;
		temp2=(char *)&depacked_length;
		temp2[0]=temp[0];
		temp2[1]=temp[1];
		temp2[2]=temp[2];
		temp2[3]=temp[3];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		ice1_1_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** Ice 2.0 Program File
*/
	if	ISPROG2(54,0x2e3c)
	{
		rs_object[FINFO1].ob_spec.free_string=ice_2_0[0];
		rs_object[FINFO2].ob_spec.free_string=ice_2_0[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+56);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		ice2_0_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** Ice 2.2 Program File
*/
	if	ISPROG(452,'Ice!')
	{
		rs_object[FINFO1].ob_spec.free_string=ice_2_2[0];
		rs_object[FINFO2].ob_spec.free_string=ice_2_2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+54);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		ice2_2_3_4_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** Ice 2.3 Program File
*/
	if	ISPROG(448,'ICE!')
	{
		rs_object[FINFO1].ob_spec.free_string=ice_2_3[0];
		rs_object[FINFO2].ob_spec.free_string=ice_2_3[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+54);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		ice2_2_3_4_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** Ice 2.4 Program File
*/
	if	ISPROG(442,'ICE!')
	{
		rs_object[FINFO1].ob_spec.free_string=ice_2_4[0];
		rs_object[FINFO2].ob_spec.free_string=ice_2_4[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+54);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		ice2_2_3_4_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** Superior Program File
*/
	if	ISPROG(28,0x41fa0220l)
	{
		rs_object[FINFO1].ob_spec.free_string=sup[0];
		rs_object[FINFO2].ob_spec.free_string=sup[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+574);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		sup_prog(file_start,(long *)((char *)depacked_pointer+depacked_length));
		return(1);
	}		

/*
****************************************************************************
** I M P   P A C K E R   O P T I O N S
****************************************************************************
*/
	if ISDATA('IMP!')
	{
		rs_object[FINFO1].ob_spec.free_string=imp[0];
		rs_object[FINFO2].ob_spec.free_string=blank;
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+4);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		imp_data(file_start,depacked_pointer);
		return(1);
	}
/*
****************************************************************************
** I V O R Y   D R A G O N    P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Is it Ivory Dragon data File
*/
	if (last_long == 'PAWN')
	{
		rs_object[FINFO1].ob_spec.free_string=idrag[0];
		rs_object[FINFO2].ob_spec.free_string=idrag[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-8];
		temp[1]=le_end[-7];
		temp[2]=le_end[-6];
		temp[3]=le_end[-5];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		idrag_data((char *)le_end-4,depacked_pointer);
		return(1);
	}
/*
** Is it Ivory Dragon prog File
*/
	if ISPROG(96,0x610000b2l)
	{
		rs_object[FINFO1].ob_spec.free_string=idrag[0];
		rs_object[FINFO2].ob_spec.free_string=idrag[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-4];
		temp[1]=le_end[-3];
		temp[2]=le_end[-2];
		temp[3]=le_end[-1];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		idrag_data((char *)le_end,depacked_pointer);
		return(1);
	}
/*
****************************************************************************
** F I R E   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Is it Fire 1.0 data File
*/
	if (last_long == 'Fire')
	{
		rs_object[FINFO1].ob_spec.free_string=fire_1[0];
		rs_object[FINFO2].ob_spec.free_string=fire_1[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-8];
		temp[1]=le_end[-7];
		temp[2]=le_end[-6];
		temp[3]=le_end[-5];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		fir1_data(file_start,depacked_pointer,file_length);
		return(1);
	}
/*
** Fire v2.0 Data File
*/
	if	ISDATA('FIRE')
	{
		rs_object[FINFO1].ob_spec.free_string=fire_2[0];
		rs_object[FINFO2].ob_spec.free_string=fire_2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+8);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		fir2_data(file_start,depacked_pointer);
		return(1);
	}		
/*
** Fire v1.0 Program File
*/
	if	ISPROG(36,'ire ')
	{
		char	*temp;
		char	*temp2;
		rs_object[FINFO1].ob_spec.free_string=fire_1[0];
		rs_object[FINFO2].ob_spec.free_string=fire_1[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)(28+(char *)file_start);
		temp=temp+(*(long *)((char *)temp+34));
		temp=temp-4;
		temp2=(char *)&depacked_length;
		temp2[0]=temp[0];
		temp2[1]=temp[1];
		temp2[2]=temp[2];
		temp2[3]=temp[3];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		fir1_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** Fire v2.0 Program File
*/
	if	ISPROG(36,'ire!')
	{
		rs_object[FINFO1].ob_spec.free_string=fire_2[0];
		rs_object[FINFO2].ob_spec.free_string=fire_2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+56);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		fir2_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
****************************************************************************
** J  P A C K E R   O P T I O N S
****************************************************************************
*/
	if	ISPROG(576,'cker')
	{
		rs_object[FINFO1].ob_spec.free_string=jpak[0];
		rs_object[FINFO2].ob_spec.free_string=jpak[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+580);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		jpak_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
****************************************************************************
** J A M   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Jam LZH datafile
*/
	if	ISDATA('LZH!')
	{
		rs_object[FINFO1].ob_spec.free_string=jam_3_4_lzh[0];
		rs_object[FINFO2].ob_spec.free_string=jam_3_4_lzh[1];
		rs_object[FINFO3].ob_spec.free_string=jam_3_4_lzh[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+4);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		jam_lzh_data(file_start,depacked_pointer);
		return(1);
	}		
/*
** Jam LZW datafile
*/
	if	ISDATA('LZW!')
	{
		rs_object[FINFO1].ob_spec.free_string=jam_4_lzw[0];
		rs_object[FINFO2].ob_spec.free_string=jam_4_lzw[1];
		rs_object[FINFO3].ob_spec.free_string=jam_4_lzw[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+4);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		jam_lzw_data(file_start,depacked_pointer);
		return(1);
	}		
/*
** Jam 1 progfile
*/
	if	(ISPROG(672,'JAM ')
	||	ISPROG(674,'JAM ')
	||	ISPROG(706,'JAM '))
	{
		rs_object[FINFO1].ob_spec.free_string=jam_1[0];
		rs_object[FINFO2].ob_spec.free_string=jam_1[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-8];
		temp[1]=le_end[-7];
		temp[2]=le_end[-6];
		temp[3]=le_end[-5];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		jam1_prog(file_start,depacked_pointer,file_length);
		return(1);
	}		
/*
** V2 JAM3 progfile
*/
	if	ISPROG(1170,'LSD!')
	{
		rs_object[FINFO1].ob_spec.free_string=jam_3_v2[0];
		rs_object[FINFO2].ob_spec.free_string=jam_3_v2[1];
		rs_object[FINFO3].ob_spec.free_string=jam_3_v2[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+1174);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		auto_dat((char *)file_start+1170,depacked_pointer);
		return(1);
	}		
/*
** LZH JAM3 progfile
*/
	if	ISPROG(1170,'LZH!')
	{
		rs_object[FINFO1].ob_spec.free_string=jam_3_lzh[0];
		rs_object[FINFO2].ob_spec.free_string=jam_3_lzh[1];
		rs_object[FINFO3].ob_spec.free_string=jam_3_lzh[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+1174);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		jam3_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** V2 JAM4 progfile
*/
	if	ISPROG(758,'LSD!')
	{
		rs_object[FINFO1].ob_spec.free_string=jam_4_v2[0];
		rs_object[FINFO2].ob_spec.free_string=jam_4_v2[1];
		rs_object[FINFO3].ob_spec.free_string=jam_4_v2[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+762);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		jam4_v2_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** LZH JAM4 progfile
*/
	if	ISPROG(1194,'LZH!')
	{
		rs_object[FINFO1].ob_spec.free_string=jam_4_lzh[0];
		rs_object[FINFO2].ob_spec.free_string=jam_4_lzh[1];
		rs_object[FINFO3].ob_spec.free_string=jam_4_lzh[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+1198);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		jam4_lzh_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** LZW JAM4 progfile
*/
	if	ISPROG(544,'LZW!')
	{
		rs_object[FINFO1].ob_spec.free_string=jam_4_lzw[0];
		rs_object[FINFO2].ob_spec.free_string=jam_4_lzw[1];
		rs_object[FINFO3].ob_spec.free_string=jam_4_lzw[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+548);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		jam4_lzw_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** ICE JAM4 progfile
*/
	if	ISPROG(712,'Ice!')
	{
		rs_object[FINFO1].ob_spec.free_string=jam_4_ice[0];
		rs_object[FINFO2].ob_spec.free_string=jam_4_ice[1];
		rs_object[FINFO3].ob_spec.free_string=jam_4_ice[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+720);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		jam4_ice_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
****************************************************************************
** J E K   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Is it jek data File
*/
	if (last_long == 'JEK!')
	{
		rs_object[FINFO1].ob_spec.free_string=jek_1_2d[0];
		rs_object[FINFO2].ob_spec.free_string=jek_1_2d[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-8];
		temp[1]=le_end[-7];
		temp[2]=le_end[-6];
		temp[3]=le_end[-5];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		lsdjek_data(le_end-4,depacked_pointer);
		return(1);
	}
/*
** JEK 1.2d progfile
*/
	if	ISPROG(638,'JEK ')
	{
		rs_object[FINFO1].ob_spec.free_string=jek_1_2d[0];
		rs_object[FINFO2].ob_spec.free_string=jek_1_2d[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-8];
		temp[1]=le_end[-7];
		temp[2]=le_end[-6];
		temp[3]=le_end[-5];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		lsd1_2_prog(file_start,depacked_pointer,file_length);
		return(1);
	}		
/*
** JEK 1.3d progfile
*/
	if	ISPROG(646,'JEK ')
	{
		rs_object[FINFO1].ob_spec.free_string=jek_1_3d[0];
		rs_object[FINFO2].ob_spec.free_string=jek_1_3d[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-8];
		temp[1]=le_end[-7];
		temp[2]=le_end[-6];
		temp[3]=le_end[-5];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		lsd1_2_prog(file_start,depacked_pointer,file_length);
		return(1);
	}		
/*
****************************************************************************
** L E  C R U N C H   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Le Crunch datafile
*/
	if	ISDATA('LeCr')
	{
		rs_object[FINFO1].ob_spec.free_string=LeCr[0];
		rs_object[FINFO2].ob_spec.free_string=blank;
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=(*(long *)((char *)file_start+8)+32);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		lecr_data(file_start,depacked_pointer);
		return(1);
	}		
/*
****************************************************************************
** L S D   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Is it lsd data File
*/
	if ((last_long == 'END!')
	|| (last_long == 'LSD!'))
	{
		rs_object[FINFO1].ob_spec.free_string=lsd_1_2[0];
		rs_object[FINFO2].ob_spec.free_string=lsd_1_2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-8];
		temp[1]=le_end[-7];
		temp[2]=le_end[-6];
		temp[3]=le_end[-5];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		lsdjek_data(le_end-4,depacked_pointer);
		return(1);
	}
/*
** LSD progfile
*/
	if	(ISPROG(638,'PLEA')
	||	ISPROG(638,'PACK')
	||	ISPROG(650,'1.2 '))
	{
		rs_object[FINFO1].ob_spec.free_string=lsd_1_2[0];
		rs_object[FINFO2].ob_spec.free_string=lsd_1_2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-8];
		temp[1]=le_end[-7];
		temp[2]=le_end[-6];
		temp[3]=le_end[-5];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		lsd1_2_prog(file_start,depacked_pointer,file_length);
		return(1);
	}		
/*
****************************************************************************
** M P A C K   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Type 1 progfile
*/
	if	ISPROG(230,0x4ac04440l)
	{
		char	*buffer;
		rs_object[FINFO1].ob_spec.free_string=mpack[0];
		rs_object[FINFO2].ob_spec.free_string=mpack[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+600);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		buffer=Malloc(10000);
		if (!buffer)
			return(-1);
		mcode1_prog(file_start,depacked_pointer,buffer);
		Mfree(buffer);
		return(1);
	}		
/*
** Type 2 progfile
*/
	if	ISPROG(228,0x4ac04440l)
	{
		char	*buffer;
		rs_object[FINFO1].ob_spec.free_string=mpack[0];
		rs_object[FINFO2].ob_spec.free_string=mpack[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+316);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		buffer=Malloc(10000);
		if (!buffer)
			return(-1);
		mcode2_prog(file_start,depacked_pointer,buffer);
		Mfree(buffer);
		return(1);
	}		
/*
** Type 3 progfile
*/
	if	ISPROG(230,0x7800284al)
	{
		char	*buffer;
		rs_object[FINFO1].ob_spec.free_string=mpack[0];
		rs_object[FINFO2].ob_spec.free_string=mpack[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+448);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		buffer=Malloc(10000);
		if (!buffer)
			return(-1);
		mcode3_prog(file_start,depacked_pointer,buffer);
		Mfree(buffer);
		return(1);
	}		
/*
****************************************************************************
** P A   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** PA progfile
*/
	if	ISPROG(102,0x425d51cfl)
	{
		rs_object[FINFO1].ob_spec.free_string=pa[0];
		rs_object[FINFO2].ob_spec.free_string=pa[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_pointer=Malloc(file_length*3);
		if (!depacked_pointer)
			return(-1);
		depacked_length=pa_prog(file_start,depacked_pointer);		
		return(1);
	}		
/*
****************************************************************************
** P F X   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Pfx v1.13
*/
	if	ISPROG(422,'-lz5')
	{
		rs_object[FINFO1].ob_spec.free_string=pfx[0];
		rs_object[FINFO2].ob_spec.free_string=pfx[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=pfxget_length((char *)file_start+420);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		pfx_prog((char *)file_start+420,depacked_pointer);		
		return(1);
	}		
/*
** Pfx v1.13/6/6d progfile
*/
	if	ISPROG(564,'-lz5')
	{
		rs_object[FINFO1].ob_spec.free_string=pfx[0];
		rs_object[FINFO2].ob_spec.free_string=pfx[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=pfxget_length((char *)file_start+562);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		pfx_prog((char *)file_start+562,depacked_pointer);		
		return(1);
	}		
/*
** Pfx v1.8/2.1 progfile
*/
	if	ISPROG(586,'-lz5')
	{
		rs_object[FINFO1].ob_spec.free_string=pfx[0];
		rs_object[FINFO2].ob_spec.free_string=pfx[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=pfxget_length((char *)file_start+584);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		pfx_prog((char *)file_start+584,depacked_pointer);		
		return(1);
	}		
/*
** Pfx v2.1 progfile with anti virus
*/
	if	ISPROG(1052,'-lz5')
	{
		rs_object[FINFO1].ob_spec.free_string=pfx[0];
		rs_object[FINFO2].ob_spec.free_string=pfx[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=pfxget_length((char *)file_start+1050);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		pfx_prog((char *)file_start+1050,depacked_pointer);		
		return(1);
	}		
/*
****************************************************************************
** P O M P E Y   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** V1.5 progfile
*/
	if	ISPROG(158,0x00847604l)
	{
		rs_object[FINFO1].ob_spec.free_string=pomp_1_5[0];
		rs_object[FINFO2].ob_spec.free_string=pomp_1_5[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-12];
		temp[1]=le_end[-11];
		temp[2]=le_end[-10];
		temp[3]=le_end[-9];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		pomp1_5_prog(file_start,depacked_pointer,(char *)le_end-4);
		return(1);
	}		
/*
** V1.9 progfile
*/
	if	ISPROG(158,0x60000084l)
	{
		rs_object[FINFO1].ob_spec.free_string=pomp_1_9[0];
		rs_object[FINFO2].ob_spec.free_string=pomp_1_9[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-14];
		temp[1]=le_end[-13];
		temp[2]=le_end[-12];
		temp[3]=le_end[-11];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		pomp1_9_prog(file_start,depacked_pointer,(char *)le_end-6);
		return(1);
	}		
/*
** V1.9 progfile - variation 1
*/
	if	ISPROG(158,0x340460f0l)
	{
		rs_object[FINFO1].ob_spec.free_string=pomp_1_9[0];
		rs_object[FINFO2].ob_spec.free_string=pomp_1_9[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-12];
		temp[1]=le_end[-11];
		temp[2]=le_end[-10];
		temp[3]=le_end[-9];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		pomp1_9_prog1(file_start,depacked_pointer,(char *)le_end-4);
		return(1);
	}		
/*
** V1.9 progfile - variation 2
*/
	if	ISPROG(158,0x3f3c000al)
	{
		rs_object[FINFO1].ob_spec.free_string=pomp_1_9[0];
		rs_object[FINFO2].ob_spec.free_string=pomp_1_9[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-12];
		temp[1]=le_end[-11];
		temp[2]=le_end[-10];
		temp[3]=le_end[-9];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		pomp1_9_prog2(file_start,depacked_pointer,(char *)le_end-4);
		return(1);
	}		
/*
** V2.3 progfile
*/
	if	ISPROG(158,0x76046022l)
	{
		rs_object[FINFO1].ob_spec.free_string=pomp_2_3[0];
		rs_object[FINFO2].ob_spec.free_string=pomp_2_3[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-12];
		temp[1]=le_end[-11];
		temp[2]=le_end[-10];
		temp[3]=le_end[-9];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		pomp2_3_prog(file_start,depacked_pointer,(char *)le_end-4);
		return(1);
	}		
/*
** V2.6 progfile
*/
	if	ISPROG(158,0x65647201l)
	{
		rs_object[FINFO1].ob_spec.free_string=pomp_2_6[0];
		rs_object[FINFO2].ob_spec.free_string=pomp_2_6[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-12];
		temp[1]=le_end[-11];
		temp[2]=le_end[-10];
		temp[3]=le_end[-9];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		pomp2_6_prog(file_start,depacked_pointer,(char *)le_end-4);
		return(1);
	}		
/*
** V3.0 progfile
*/
	if	ISPROG(158,0x60e67205l)
	{
		rs_object[FINFO1].ob_spec.free_string=pomp_3_0[0];
		rs_object[FINFO2].ob_spec.free_string=pomp_3_0[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-12];
		temp[1]=le_end[-11];
		temp[2]=le_end[-10];
		temp[3]=le_end[-9];
		depacked_length=(depacked_length & 0x00ffffffl);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		pomp3_0_prog(file_start,depacked_pointer,(char *)le_end-4);
		return(1);
	}		
/*
** Pompey datafile
*/
	if	(last_long=='POPI'
	||	 last_long=='PUFF')
	{
		int butt;
		rs_trindex[POMPEY_CLASH][POMPEY_FNAME].ob_spec.free_string=fname;
		butt=do_dial(rs_trindex[POMPEY_CLASH]);
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		switch	(butt)
		{
			case	V1_5_BUTT:
			{
				rs_object[FINFO1].ob_spec.free_string=pomp_1_5[0];
				rs_object[FINFO2].ob_spec.free_string=pomp_1_5[1];
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				temp=(char *)&depacked_length;
				temp[0]=le_end[-8];
				temp[1]=le_end[-7];
				temp[2]=le_end[-6];
				temp[3]=le_end[-5];
				depacked_pointer=Malloc(depacked_length);
				if (!depacked_pointer)
					return(-1);
				pomp1_5_data((char *)le_end-4,depacked_pointer);
				return(1);
			}
			case	V1_9_BUTT:
			{
				rs_object[FINFO1].ob_spec.free_string=pomp_1_9[0];
				rs_object[FINFO2].ob_spec.free_string=pomp_1_9[1];
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				temp=(char *)&depacked_length;
				temp[0]=le_end[-8];
				temp[1]=le_end[-7];
				temp[2]=le_end[-6];
				temp[3]=le_end[-5];
				depacked_pointer=Malloc(depacked_length);
				if (!depacked_pointer)
					return(-1);
				pomp1_9_data((char *)le_end-4,depacked_pointer);
				return(1);
			}
			case	POMPEY_PISS_OFF:
			{
				rs_object[FINFO1].ob_spec.free_string=scared[0];
				rs_object[FINFO2].ob_spec.free_string=blank;
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				return(0);			
			}
		}
	}
/*
****************************************************************************
** P O W E R   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Power v2 datafile
*/
	if	ISDATA('PP20')
	{
		rs_object[FINFO1].ob_spec.free_string=ppack2[0];
		rs_object[FINFO2].ob_spec.free_string=ppack2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=ppget_length(le_end);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		pp2_data(le_end,depacked_pointer,file_start+1);		
		return(1);
	}		
/*
****************************************************************************
** Q P A K   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** QPAK2 datafile
*/
	if	ISPROG(4,'2-JM')
	{
		rs_object[FINFO1].ob_spec.free_string=qpack_2[0];
		rs_object[FINFO2].ob_spec.free_string=qpack_2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+16);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		qp2_data(file_start,depacked_pointer);
		return(1);
	}		
/*
** QPAK2 progfile
*/
	if	ISPROG(52,'2-JM')
	{
		rs_object[FINFO1].ob_spec.free_string=qpack_2[0];
		rs_object[FINFO2].ob_spec.free_string=qpack_2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+64);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		qp2_data((char *)file_start+48,depacked_pointer);
		return(1);
	}		
/*
****************************************************************************
** R N C   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** RNC1 datafile
*/
	if	ISDATA(0X524E4301L)
	{
		int butt;
		rs_trindex[RNC_CLASH][RNC_FNAME].ob_spec.free_string=fname;
		butt=do_dial(rs_trindex[RNC_CLASH]);
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		switch	(butt)
		{
			case	TYPE1_BUTT:
			{
				rs_object[FINFO1].ob_spec.free_string=rnc1[0];
				rs_object[FINFO2].ob_spec.free_string=rnc1[1];
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				depacked_length=*(long *)((char *)file_start+4);
				depacked_pointer=Malloc(depacked_length);
				if (!depacked_pointer)
					return(-1);
				rnc1_data1(file_start,depacked_pointer);
				return(1);
			}
			case	TYPE2_BUTT:
			{
				rs_object[FINFO1].ob_spec.free_string=rnc1[0];
				rs_object[FINFO2].ob_spec.free_string=rnc1[1];
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				depacked_length=*(long *)((char *)file_start+4);
				depacked_pointer=Malloc(depacked_length);
				if (!depacked_pointer)
					return(-1);
				rnc1_data2(file_start,depacked_pointer);
				return(1);
			}
			case	RNC_BYE:
			{
				rs_object[FINFO1].ob_spec.free_string=scared[0];
				rs_object[FINFO2].ob_spec.free_string=blank;
				rs_object[FINFO3].ob_spec.free_string=blank;
				rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
				return(0);			
			}
		}
	}
/*
** RNC2 datafile
*/
	if	ISDATA(0x524e4302l)
	{
		rs_object[FINFO1].ob_spec.free_string=rnc2[0];
		rs_object[FINFO2].ob_spec.free_string=rnc2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+4);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		rnc2_data(file_start,depacked_pointer);
		return(1);
	}		
/*
** RNC copylock progfile
*/
	if	ISPROG(146,0x0c54601al)
	{
		rs_object[FINFO1].ob_spec.free_string=rncc[0];
		rs_object[FINFO2].ob_spec.free_string=rncc[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+1366);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		rncc_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** RNC2 progfile
*/
	if	ISPROG(642,0x524e4302l)
	{
		rs_object[FINFO1].ob_spec.free_string=rnc2[0];
		rs_object[FINFO2].ob_spec.free_string=rnc2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=(*(long *)((char *)file_start+646)+28);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		rnc2_prog(file_start,depacked_pointer);
		return(1);
	}		

/*
****************************************************************************
** S E N T R Y   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Sentry 2.05 datafile
*/
	if	(last_long == 'Snt2')
	{
		rs_object[FINFO1].ob_spec.free_string=sent_2_05[0];
		rs_object[FINFO2].ob_spec.free_string=sent_2_05[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-5];
		temp[1]=le_end[-6];
		temp[2]=le_end[-7];
		temp[3]=le_end[-8];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		sent2_5_data(file_start,depacked_pointer,file_length);
		return(1);
	}		
/*
** Sentry 2.05 progfile
*/
	if	ISPROG(522,'2.05')
	{
		rs_object[FINFO1].ob_spec.free_string=sent_2_05[0];
		rs_object[FINFO2].ob_spec.free_string=sent_2_05[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+258);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		sent2_5_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** Sentry 2.11 progfile
*/
	if	ISPROG(526,'2.11')
	{
		rs_object[FINFO1].ob_spec.free_string=sent_2_11[0];
		rs_object[FINFO2].ob_spec.free_string=sent_2_11[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+268);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		sent2_11_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
****************************************************************************
** S P E E D P A C K E R   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Speed2 datafile
*/
	if	ISDATA('SP20')
	{
		rs_object[FINFO1].ob_spec.free_string=speed_2[0];
		rs_object[FINFO2].ob_spec.free_string=speed_2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+12);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		speed2_data(file_start,depacked_pointer);
		return(1);
	}		
/*
** Speed3 datafile
*/
	if	ISDATA('SPv3')
	{
		rs_object[FINFO1].ob_spec.free_string=speed_3[0];
		rs_object[FINFO2].ob_spec.free_string=speed_3[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+12);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		memcpy(depacked_pointer,file_start,file_length);
		speed3_data(depacked_pointer);
		return(1);
	}		
/*
** Speed2 progfile
*/
	if	ISPROG(542,'SP20')
	{
		rs_object[FINFO1].ob_spec.free_string=speed_2[0];
		rs_object[FINFO2].ob_spec.free_string=speed_2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+554);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		speed2_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** Speed3 progfile
*/
	if	ISPROG(28,0x4e417633l)
	{
		rs_object[FINFO1].ob_spec.free_string=speed_3[0];
		rs_object[FINFO2].ob_spec.free_string=speed_3[1];
		rs_object[FINFO3].ob_spec.free_string=speed_3[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=(*(long *)((char *)file_start+40))+14;
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		memcpy(depacked_pointer,file_start,file_length);
		speed3_prog((char *)depacked_pointer+28);
		return(1);
	}		
	if	ISPROG(1816,'SPv3')
	{
		rs_object[FINFO1].ob_spec.free_string=speed_3[0];
		rs_object[FINFO2].ob_spec.free_string=speed_3[1];
		rs_object[FINFO3].ob_spec.free_string=speed_3[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+1828);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		memcpy(depacked_pointer,(char *)file_start+1816,*(long *)((char *)file_start+1824));
		speed3_data(depacked_pointer);
		return(1);
	}		
	if	ISPROG(30,'SPv3')
	{
		rs_object[FINFO1].ob_spec.free_string=speed_3[0];
		rs_object[FINFO2].ob_spec.free_string=speed_3[1];
		rs_object[FINFO3].ob_spec.free_string=speed_3[2];
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=(*(long *)((char *)file_start+954)+14);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		memcpy((char *)depacked_pointer+28,(char *)file_start+942,(*(long *)((char *)file_start+950)));
		speed3_2_prog((char *)depacked_pointer+28);
		return(1);
	}		
/*
****************************************************************************
** S T O S   P A C K E R   O P T I O N S
****************************************************************************
*/
	if	ISPROG(68,0x0007fd00l)
	{
		rs_object[FINFO1].ob_spec.free_string=stos[0];
		rs_object[FINFO2].ob_spec.free_string=blank;
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-4];
		temp[1]=le_end[-3];
		temp[2]=le_end[-2];
		temp[3]=le_end[-1];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		stos_prog(le_end,depacked_pointer);
		return(1);
	}		
/*
****************************************************************************
** T H U N D E R   P A C K E R   O P T I O N S
****************************************************************************
*/
/*
** Thunder V1 progfile
*/
	if	ISPROG(422,'ATOM')
	{
		rs_object[FINFO1].ob_spec.free_string=thun_1[0];
		rs_object[FINFO2].ob_spec.free_string=thun_1[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+426);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		thun1_prog(file_start,depacked_pointer);
		return(1);
	}		
/*
** Thunder V1.1 progfile
*/
	if	ISPROG(480,'ATOM')
	{
		rs_object[FINFO1].ob_spec.free_string=thun_1_1[0];
		rs_object[FINFO2].ob_spec.free_string=thun_1_1[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+484);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		thun2_data((char *)file_start+480,depacked_pointer);
		return(1);
	}		
/*
** Thunder V2 progfile
*/
	if	ISPROG(452,'ATOM')
	{
		rs_object[FINFO1].ob_spec.free_string=thun_2[0];
		rs_object[FINFO2].ob_spec.free_string=thun_2[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+456);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		thun2_data((char *)file_start+452,depacked_pointer);
		return(1);
	}		
/*
****************************************************************************
** U N K N O W N   P A C K E R   O P T I O N S
****************************************************************************
*/
	if	ISPROG(118,0x4e714e71l)
	{
		rs_object[FINFO1].ob_spec.free_string=unknown_1[0];
		rs_object[FINFO2].ob_spec.free_string=unknown_1[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+250);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		unknown_prog2(le_end,depacked_pointer,file_start);
		return(1);
	}		
	if	(ISPROG(442,'****')&&ISDATA2(0x601a))
	{
		rs_object[FINFO1].ob_spec.free_string=unknown_1[0];
		rs_object[FINFO2].ob_spec.free_string=unknown_1[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+450);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		unknown_prog3(file_start,depacked_pointer);
		return(1);
	}		
	if	ISPROG(572,0x4e5a2c1fl)
	{
		rs_object[FINFO1].ob_spec.free_string=unknown_1[0];
		rs_object[FINFO2].ob_spec.free_string=unknown_1[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		depacked_length=*(long *)((char *)file_start+600);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		unknown_prog4(file_start,depacked_pointer);
		return(1);
	}		
	if	ISPROG(522,0x44fc0010l)
	{
		rs_object[FINFO1].ob_spec.free_string=unknown_1[0];
		rs_object[FINFO2].ob_spec.free_string=unknown_1[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		temp=(char *)&depacked_length;
		temp[0]=le_end[-8];
		temp[1]=le_end[-7];
		temp[2]=le_end[-6];
		temp[3]=le_end[-5];
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		unknown_prog5((char *)le_end-4,depacked_pointer,file_start);
		return(1);
	}		
/*
****************************************************************************
** VIC2   P A C K E R   O P T I O N S
****************************************************************************
*/
	if	ISDATA('Vic2')
	{
		rs_object[FINFO1].ob_spec.free_string=vic2[0];
		rs_object[FINFO2].ob_spec.free_string=blank;
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=*(long *)((char *)file_start+4);
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		vic2_data(file_start,depacked_pointer);
		return(1);
	}		
/*
** Degas Elite datafile
*/
	if	(ISDATA2(0x8000)
	||	ISDATA2(0x8001)
	||	ISDATA2(0x8002))
	{
		rs_object[FINFO1].ob_spec.free_string=degas_e[0];
		rs_object[FINFO2].ob_spec.free_string=degas_e[1];
		rs_object[FINFO3].ob_spec.free_string=blank;
		rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		depacked_length=32066;
		depacked_pointer=Malloc(depacked_length);
		if (!depacked_pointer)
			return(-1);
		deg_data(file_start,depacked_pointer);
		return(1);
	}		
/*
****************************************************************************
** IF NOT PACKED THEN PROCESS ACCORDINALLY
****************************************************************************
*/
/*
** Program options
*/			
	if (*(int *)file_start==0x601a)
	{
		char	*temp;
/*
** Determine if the file may be packed
** Check for presence of relocation table.
*/
		temp=(char *)file_start;
		temp=temp+(*(long*)((char *)file_start+2));
		temp=temp+(*(long*)((char *)file_start+6));
		temp=temp+0x32;
/*
** Possibly packed
*/
		if (!(*(long *)temp) && (file_length > 500)) 
		{
			rs_object[FINFO1].ob_spec.free_string=prog_pp[0];
			rs_object[FINFO2].ob_spec.free_string=prog_pp[1];
			rs_object[FINFO3].ob_spec.free_string=blank;
			rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		}
		else
/*
** Definately not packed
*/
		{				
			rs_object[FINFO1].ob_spec.free_string=prog_np[0];
			rs_object[FINFO2].ob_spec.free_string=prog_np[1];
			rs_object[FINFO3].ob_spec.free_string=blank;
			rs_object[MENU_FTYPE].ob_spec.free_string=exec_info;
		}													
	}
	else
/*
** Datafile options
*/			
	{
		char	*temp;
		int		count=0;
/*
** IFF file
*/
		if	ISDATA('FORM')
		{
			rs_object[FINFO1].ob_spec.free_string=iff[0];
			rs_object[FINFO2].ob_spec.free_string=iff[1];
			rs_object[FINFO3].ob_spec.free_string=blank;
			rs_object[MENU_FTYPE].ob_spec.free_string=pic_info;
			return(0);
		}		
/*
** NEO object file
*/
		if	ISDATA('NEOO')
		{
			rs_object[FINFO1].ob_spec.free_string=neo_obj[0];
			rs_object[FINFO2].ob_spec.free_string=neo_obj[1];
			rs_object[FINFO3].ob_spec.free_string=blank;
			rs_object[MENU_FTYPE].ob_spec.free_string=pic_info;
			return(0);
		}		
/*
** LHARC object file
*/
		if	(ISPROG(2,'-lh1')
		||	ISPROG(2,'-lh5'))
		{
			rs_object[FINFO1].ob_spec.free_string=lharc[0];
			rs_object[FINFO2].ob_spec.free_string=lharc[1];
			rs_object[FINFO3].ob_spec.free_string=blank;
			rs_object[MENU_FTYPE].ob_spec.free_string=arc_info;
			return(0);
		}		
/*
** ZOO file
*/
		if	ISDATA('ZOO ')
		{
			rs_object[FINFO1].ob_spec.free_string=zoo[0];
			rs_object[FINFO2].ob_spec.free_string=zoo[1];
			rs_object[FINFO3].ob_spec.free_string=blank;
			rs_object[MENU_FTYPE].ob_spec.free_string=arc_info;
			return(0);
		}		
/*
** ZIP file
*/
		if	ISDATA2('PK')
		{
			rs_object[FINFO1].ob_spec.free_string=zip[0];
			rs_object[FINFO2].ob_spec.free_string=zip[1];
			rs_object[FINFO3].ob_spec.free_string=blank;
			rs_object[MENU_FTYPE].ob_spec.free_string=arc_info;
			return(0);
		}		
/*
** Determine if the file might be packed
*/
/*
** Check that the first 4 chars are printable chars 
** and that the next 4 are not. Indicates that the file
** may be packed.
*/
		temp=(char *)file_start;
		do
		{
		}
		while(isprint(temp[count])&&(++count!=8));							
/*
** Definately not packed 
*/
		if (count!=3)
		{
			rs_object[FINFO1].ob_spec.free_string=dat_np[0];
			rs_object[FINFO2].ob_spec.free_string=dat_np[1];
			rs_object[FINFO3].ob_spec.free_string=blank;
			rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		}
		else
		{
/*
** Possibly packed 
*/
			dat_pp[1][15]=temp[0];
			dat_pp[1][16]=temp[1];
			dat_pp[1][17]=temp[2];
			dat_pp[1][18]=temp[3];
			rs_object[FINFO1].ob_spec.free_string=dat_pp[0];
			rs_object[FINFO2].ob_spec.free_string=dat_pp[1];
			rs_object[FINFO3].ob_spec.free_string=blank;
			rs_object[MENU_FTYPE].ob_spec.free_string=data_info;
		}
	}
	return(0);
}
