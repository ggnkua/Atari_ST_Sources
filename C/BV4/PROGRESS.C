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
	Include intern RSC (progress box)
*******************************************************************************/
#include		"INTERN.RSH"


/*******************************************************************************
	Intern variables
*******************************************************************************/
static int	ha,x,y,w,h;
static int	f1=1,f2=1;


/*******************************************************************************
	Init intern RSC
*******************************************************************************/
void _progOn()
{
	int	i;

	if (glb.div.win)
	{
		if (f2)
		{
			f2=0;
			strcpy( ((TEDINFO *)(glb.rsc.head.trindex[FPRG][FPRG1].ob_spec.tedinfo))->te_ptext,"");
			strcpy( ((TEDINFO *)(glb.rsc.head.trindex[FPRG][FPRG2].ob_spec.tedinfo))->te_ptext,"");
		}
		i=glb.opt.Mouse_Form;
		glb.opt.Mouse_Form=2;
		ha=_winForm(FPRG,PRG_NAME,"",0,0,0,W_MODAL);
		glb.opt.Mouse_Form=i;
		_clearAesBuffer();
	}
	else
	{
		if (f1)
		{
			for (i=0;i<NUM_OBS;i++)
				rsrc_obfix(&rs_object[i],0);
			f1=0;
			strcpy( ((TEDINFO *)(rs_trindex[FPROG][FPROG1].ob_spec.tedinfo))->te_ptext,"");
			strcpy( ((TEDINFO *)(rs_trindex[FPROG][FPROG2].ob_spec.tedinfo))->te_ptext,"");
		}
		strcpy(((TEDINFO *)(rs_object[FPROGT].ob_spec.tedinfo))->te_ptext,PRG_NAME);
		wind_update(BEG_UPDATE);
		form_center(rs_trindex[FPROG],&x,&y,&w,&h);
		x-=4;
		y-=4;
		w+=8;
		h+=8;
		graf_mouse(M_OFF,0);
		form_dial(FMD_START,0,0,0,0,x,y,w,h);
		form_dial(FMD_GROW,x+w/2,y+h/2,0,0,x,y,w,h);
		objc_draw(rs_trindex[FPROG],ROOT,1,x,y,w,h);
		graf_mouse(M_ON,0);
	}
}


/*******************************************************************************
	Progress box update
*******************************************************************************/
void _prog(char *tx1,char *tx2)
{
	int	obx,oby,obw,obh,dum;

	if (glb.div.win)
	{
		if (tx1[0]!='@')
			strncpy( ((TEDINFO *)(glb.rsc.head.trindex[FPRG][FPRG1].ob_spec.tedinfo))->te_ptext,tx1,36L);
		if (tx2[0]!='@')
			strncpy( ((TEDINFO *)(glb.rsc.head.trindex[FPRG][FPRG2].ob_spec.tedinfo))->te_ptext,tx2,36L);
		wind_update(BEG_UPDATE);
		dum=_winFindId(TW_FORM,FPRG,TRUE);
		if (dum!=-1)
		{
			_coord(glb.rsc.head.trindex[FPRG],FPRGF,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(dum,glb.rsc.head.trindex[FPRG],FPRGF,MAX_DEPTH,obx,oby,obw,obh);
		}
		wind_update(END_UPDATE);
	}
	else
	{
		if (tx1[0]!='@')
			strncpy( ((TEDINFO *)(rs_trindex[FPROG][FPROG1].ob_spec.tedinfo))->te_ptext,tx1,36L);
		if (tx2[0]!='@')
			strncpy( ((TEDINFO *)(rs_trindex[FPROG][FPROG2].ob_spec.tedinfo))->te_ptext,tx2,36L);
		graf_mouse(M_OFF,0);
		objc_draw(rs_trindex[FPROG],FPROGF,MAX_DEPTH,x,y,w,h);
		graf_mouse(M_ON,0);
	}
}


/*******************************************************************************
	Exit intern RSC
*******************************************************************************/
void _progOff()
{
	if (glb.div.win)
		_winClose(ha);
	else
	{
		graf_mouse(M_OFF,0);
		form_dial(FMD_SHRINK,x+w/2,y+h/2,0,0,x,y,w,h);
		form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
		graf_mouse(M_ON,0);
		wind_update(END_UPDATE);
	}
}
