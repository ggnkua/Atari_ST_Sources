/*
	These are the routines that are mainly activated by the MENU
	that interact with the user
*/
#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <strings.h>
#include "dx.h"
#include "dxed.h"

/*	global variables	*/

int master_tune = 64;
extern int midi_ch;
extern int slidpos[10];
extern char bulk_buff[4096],per_bulk[4096];
extern char file_path[128];
extern char old_file[20];
extern int op,op_en;	/*	current operator being edited	*/
extern char edit[155],pedit[94];
extern int b_buff_state;	/*	contents of bulk buffer	*/
extern char temp[128];

/*
	local global variables
*/
int patch;

play(vw)
int vw;	/*	virtual workstation handle	*/
{
	Playsong();
	return;
}

record(vw)
int vw;
{
	In_loop();
	return;
}


/*********************************************************************

	prformance routines

*********************************************************************/

do_portamento(vw)
int vw;	/*	virtual workstation handle	*/
{
	OBJECT *box;
	int x,y,w,h,form_result;

	rsrc_gaddr(0,PORTAMEN,&box);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK39,SLIDER39,99,pedit[5]);
	vreset(1,box,TRACK54,SLIDER54,1,pedit[6]);
	vreset(2,box,TRACK55,SLIDER55,1,pedit[7]);
	show_pos(box,NUMBER39,BN39,slidpos[0],x,y,w,h);
	show_port(box,PORT_GLS,PORT_B1,slidpos[1],x,y,w,h);
	show_pmode(box,PORT_MD,PORT_B2,slidpos[2],x,y,w,h);
	chg_param(midi_ch,1,0,5,slidpos[0]);
	chg_param(midi_ch,1,0,6,slidpos[1]);
	chg_param(midi_ch,1,0,7,slidpos[2]);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP39:
			case DN39:
			case SLIDER39:
			case TRACK39:
				do_vslider(0,box,TRACK39,SLIDER39,UP39,DN39,form_result,10);
				show_pos(box,NUMBER39,BN39,slidpos[0],x,y,w,h);
				chg_param(midi_ch,1,0,5,slidpos[0]);
				break;
			case UP54:
			case DN54:
			case SLIDER54:
			case TRACK54:
				do_vslider(1,box,TRACK54,SLIDER54,UP54,DN54,form_result,1);
				show_port(box,PORT_GLS,PORT_B1,slidpos[1],x,y,w,h);
				chg_param(midi_ch,1,0,6,slidpos[1]);
				break;
			case UP55:
			case DN55:
			case SLIDER55:
			case TRACK55:
				do_vslider(2,box,TRACK55,SLIDER55,UP55,DN55,form_result,1);
				show_pmode(box,PORT_MD,PORT_B2,slidpos[2],x,y,w,h);
				chg_param(midi_ch,1,0,7,slidpos[2]);
				break;
		}
	}while((form_result != PORT_OK) && (form_result != PORT_CAN));
	if(form_result == PORT_OK)
	{
		pedit[5] = slidpos[0];
		pedit[6] = slidpos[1];
		pedit[7] = slidpos[2];
	}
	chg_param(midi_ch,1,0,5,pedit[5]);
	chg_param(midi_ch,1,0,6,pedit[6]);
	chg_param(midi_ch,1,0,7,pedit[7]);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return;
}

do_bender(vw)
int vw;	/*	virtual workstation handle	*/
{
	OBJECT *box;
	int x,y,w,h,form_result;

	rsrc_gaddr(0,PTCH_BND,&box);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK40,SLIDER40,12,pedit[3]);
	vreset(1,box,TRACK41,SLIDER41,12,pedit[4]);
	show_pos(box,NUMBER40,BN40,slidpos[0],x,y,w,h);
	show_pos(box,NUMBER41,BN41,slidpos[1],x,y,w,h);
	chg_param(midi_ch,1,0,3,slidpos[0]);
	chg_param(midi_ch,1,0,4,slidpos[1]);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP40:
			case DN40:
			case SLIDER40:
			case TRACK40:
				do_vslider(0,box,TRACK40,SLIDER40,UP40,DN40,form_result,1);
				show_pos(box,NUMBER40,BN40,slidpos[0],x,y,w,h);
				chg_param(midi_ch,1,0,3,slidpos[0]);
				break;
			case UP41:
			case DN41:
			case SLIDER41:
			case TRACK41:
				do_vslider(1,box,TRACK41,SLIDER41,UP41,DN41,form_result,1);
				show_pos(box,NUMBER41,BN41,slidpos[1],x,y,w,h);
				chg_param(midi_ch,1,0,4,slidpos[1]);
				break;
		}
	}while((form_result != PB_OK) && (form_result != PB_CAN));
	if(form_result == PB_OK)
	{
		pedit[3] = slidpos[0];
		pedit[4] = slidpos[1];
	}
	chg_param(midi_ch,1,0,3,pedit[3]);
	chg_param(midi_ch,1,0,4,pedit[4]);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return;
}

do_wheel(vw)
int vw;	/*	virtual workstation handle	*/
{
	OBJECT *box;
	int x,y,w,h,form_result;

	rsrc_gaddr(0,MOD_WHEL,&box);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK42,SLIDER42,15,pedit[9]);
	vreset(1,box,TRACK43,SLIDER43,7,pedit[10]);
	show_pos(box,NUMBER42,BN42,slidpos[0],x,y,w,h);
	show_pos(box,NUMBER43,BN43,slidpos[1],x,y,w,h);
	show_ass(box,slidpos[1],MW_BOX,MW_EGB,MW_AMPL,MW_PITCH,x,y,w,h);
	chg_param(midi_ch,1,0,9,slidpos[0]);
	chg_param(midi_ch,1,0,10,slidpos[1]);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP42:
			case DN42:
			case SLIDER42:
			case TRACK42:
				do_vslider(0,box,TRACK42,SLIDER42,UP42,DN42,form_result,2);
				show_pos(box,NUMBER42,BN42,slidpos[0],x,y,w,h);
				chg_param(midi_ch,1,0,9,slidpos[0]);
				break;
			case UP43:
			case DN43:
			case SLIDER43:
			case TRACK43:
				do_vslider(1,box,TRACK43,SLIDER43,UP43,DN43,form_result,1);
				show_pos(box,NUMBER43,BN43,slidpos[1],x,y,w,h);
				show_ass(box,slidpos[1],MW_BOX,MW_EGB,MW_AMPL,MW_PITCH,x,y,w,h);
				chg_param(midi_ch,1,0,10,slidpos[1]);
				break;
		}
	}while((form_result != MW_OK) && (form_result != MW_CAN));
	if(form_result == MW_OK)
	{
		pedit[9] = slidpos[0];
		pedit[10] = slidpos[1];
	}
	chg_param(midi_ch,1,0,9,pedit[9]);
	chg_param(midi_ch,1,0,10,pedit[10]);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return;
}

do_foot(vw)
int vw;	/*	virtual workstation handle	*/
{
	OBJECT *box;
	int x,y,w,h,form_result;

	rsrc_gaddr(0,FOOT_CTL,&box);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK44,SLIDER44,15,pedit[11]);
	vreset(1,box,TRACK45,SLIDER45,7,pedit[12]);
	show_pos(box,NUMBER44,BN44,slidpos[0],x,y,w,h);
	show_pos(box,NUMBER45,BN45,slidpos[1],x,y,w,h);
	show_ass(box,slidpos[1],FC_BOX,FC_EGB,FC_AMPL,FC_PITCH,x,y,w,h);
	chg_param(midi_ch,1,0,11,slidpos[0]);
	chg_param(midi_ch,1,0,12,slidpos[1]);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP44:
			case DN44:
			case SLIDER44:
			case TRACK44:
				do_vslider(0,box,TRACK44,SLIDER44,UP44,DN44,form_result,2);
				show_pos(box,NUMBER44,BN44,slidpos[0],x,y,w,h);
				chg_param(midi_ch,1,0,11,slidpos[0]);
				break;
			case UP45:
			case DN45:
			case SLIDER45:
			case TRACK45:
				do_vslider(1,box,TRACK45,SLIDER45,UP45,DN45,form_result,1);
				show_pos(box,NUMBER45,BN45,slidpos[1],x,y,w,h);
				show_ass(box,slidpos[1],FC_BOX,FC_EGB,FC_AMPL,FC_PITCH,x,y,w,h);
				chg_param(midi_ch,1,0,12,slidpos[1]);
				break;
		}
	}while((form_result != FC_OK) && (form_result != FC_CAN));
	if(form_result == FC_OK)
	{
		pedit[11] = slidpos[0];
		pedit[12] = slidpos[1];
	}
	chg_param(midi_ch,1,0,11,pedit[11]);
	chg_param(midi_ch,1,0,12,pedit[12]);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return;
}

do_breath(vw)
int vw;	/*	virtual workstation handle	*/
{
	OBJECT *box;
	int x,y,w,h,form_result;

	rsrc_gaddr(0,BREATH,&box);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK48,SLIDER48,15,pedit[15]);
	vreset(1,box,TRACK49,SLIDER49,7,pedit[16]);
	show_pos(box,NUMBER48,BN48,slidpos[0],x,y,w,h);
	show_pos(box,NUMBER49,BN49,slidpos[1],x,y,w,h);
	show_ass(box,slidpos[1],BT_BOX,BT_EGB,BT_AMPL,BT_PITCH,x,y,w,h);
	chg_param(midi_ch,1,0,15,slidpos[0]);
	chg_param(midi_ch,1,0,16,slidpos[1]);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP48:
			case DN48:
			case SLIDER48:
			case TRACK48:
				do_vslider(0,box,TRACK48,SLIDER48,UP48,DN48,form_result,2);
				show_pos(box,NUMBER48,BN48,slidpos[0],x,y,w,h);
				chg_param(midi_ch,1,0,15,slidpos[0]);
				break;
			case UP49:
			case DN49:
			case SLIDER49:
			case TRACK49:
				do_vslider(1,box,TRACK49,SLIDER49,UP49,DN49,form_result,1);
				show_pos(box,NUMBER49,BN49,slidpos[1],x,y,w,h);
				show_ass(box,slidpos[1],BT_BOX,BT_EGB,BT_AMPL,BT_PITCH,x,y,w,h);
				chg_param(midi_ch,1,0,16,slidpos[1]);
				break;
		}
	}while((form_result != BT_OK) && (form_result != BT_CAN));
	if(form_result == BT_OK)
	{
		pedit[15] = slidpos[0];
		pedit[16] = slidpos[1];
	}
	chg_param(midi_ch,1,0,15,pedit[15]);
	chg_param(midi_ch,1,0,16,pedit[16]);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return;
}
do_after(vw)
int vw;
{
	OBJECT *box;
	int x,y,w,h,form_result;

	rsrc_gaddr(0,AFTR_TCH,&box);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK46,SLIDER46,15,pedit[13]);
	vreset(1,box,TRACK47,SLIDER47,7,pedit[14]);
	show_pos(box,NUMBER46,BN46,slidpos[0],x,y,w,h);
	show_pos(box,NUMBER47,BN47,slidpos[1],x,y,w,h);
	show_ass(box,slidpos[1],AT_BOX,AT_EGB,AT_AMPL,AT_PITCH,x,y,w,h);
	chg_param(midi_ch,1,0,13,slidpos[0]);
	chg_param(midi_ch,1,0,14,slidpos[1]);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP46:
			case DN46:
			case SLIDER46:
			case TRACK46:
				do_vslider(0,box,TRACK46,SLIDER46,UP46,DN46,form_result,2);
				show_pos(box,NUMBER46,BN46,slidpos[0],x,y,w,h);
				chg_param(midi_ch,1,0,13,slidpos[0]);
				break;
			case UP47:
			case DN47:
			case SLIDER47:
			case TRACK47:
				do_vslider(1,box,TRACK47,SLIDER47,UP47,DN47,form_result,1);
				show_pos(box,NUMBER47,BN47,slidpos[1],x,y,w,h);
				show_ass(box,slidpos[1],AT_BOX,AT_EGB,AT_AMPL,AT_PITCH,x,y,w,h);
				chg_param(midi_ch,1,0,14,slidpos[1]);
				break;
		}
	}while((form_result != AT_OK) && (form_result != AT_CAN));
	if(form_result == AT_OK)
	{
		pedit[13] = slidpos[0];
		pedit[14] = slidpos[1];
	}
	chg_param(midi_ch,1,0,13,pedit[13]);
	chg_param(midi_ch,1,0,14,pedit[14]);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
}

do_pother(vw)
int vw;	/*	virtual workstation handle	*/
{
	OBJECT *box;
	int x,y,w,h,form_result;

	rsrc_gaddr(0,P_OTHER,&box);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK50,SLIDER50,127,master_tune);
	vreset(1,box,TRACK51,SLIDER51,7,pedit[26]);
	vreset(2,box,TRACK52,SLIDER52,1,pedit[2]);
	show_pos3(box,NUMBER50,BN50,slidpos[0],x,y,w,h);
	show_pos(box,NUMBER51,BN51,slidpos[1],x,y,w,h);
	show_ppoly(box,PO_POLY,PO_POLYB,slidpos[2],x,y,w,h);
	chg_param(midi_ch,1,0,64,slidpos[0]);
	chg_param(midi_ch,1,0,26,slidpos[1]);
	chg_param(midi_ch,1,0,2,slidpos[2]);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP50:
			case DN50:
			case SLIDER50:
			case TRACK50:
				do_vslider(0,box,TRACK50,SLIDER50,UP50,DN50,form_result,10);
				show_pos3(box,NUMBER50,BN50,slidpos[0],x,y,w,h);
				chg_param(midi_ch,1,0,64,slidpos[0]);
				break;
			case UP51:
			case DN51:
			case SLIDER51:
			case TRACK51:
				do_vslider(1,box,TRACK51,SLIDER51,UP51,DN51,form_result,1);
				show_pos(box,NUMBER51,BN51,slidpos[1],x,y,w,h);
				chg_param(midi_ch,1,0,26,slidpos[1]);
				break;
			case UP52:
			case DN52:
			case SLIDER52:
			case TRACK52:
				do_vslider(2,box,TRACK52,SLIDER52,UP52,DN52,form_result,1);
				show_ppoly(box,PO_POLY,PO_POLYB,slidpos[2],x,y,w,h);
				chg_param(midi_ch,1,0,2,slidpos[2]);
				break;
		}
	}while((form_result != PO_OK) && (form_result != PO_CAN));
	if(form_result == PO_OK)
	{
		master_tune = slidpos[0];
		pedit[26] = slidpos[1];
		pedit[2] = slidpos[2];
	}
	chg_param(midi_ch,1,0,64,slidpos[0]);
	chg_param(midi_ch,1,0,26,slidpos[1]);
	chg_param(midi_ch,1,0,2,slidpos[2]);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return;
}

show_ass(dia,val,box_index,egbias,ampl,pitch,x,y,w,h)
OBJECT *dia;
int val,box_index,egbias,ampl,pitch,x,y,w,h;
{
	if(val & 0x01)	/*	check for pitch assign	*/
		dia[pitch].ob_state = NORMAL;
	else
		dia[pitch].ob_state = DISABLED;
	if(val & 0x02)	/*	check for amplitude assign	*/
		dia[ampl].ob_state = NORMAL;
	else
		dia[ampl].ob_state = DISABLED;
	if(val & 0x04)	/*	check for EG BIAS	*/
		dia[egbias].ob_state = NORMAL;
	else
		dia[egbias].ob_state = DISABLED;
	objc_draw(dia,box_index,1,x,y,w,h);
}

/*********************************************************************

	Midi routines

*********************************************************************/

set_midi_ch(vw)
int vw;	/*	virtual workstation handle	*/
{
	OBJECT *box;
	int result;

	rsrc_gaddr(R_TREE,SET_MIDI,&box);
	result = do_dialog(box,0);
	box[result].ob_state = NORMAL;
	switch(result)
	{
		case CH_1: midi_ch = 0; break;
		case CH_2: midi_ch = 1; break;
		case CH_3: midi_ch = 2; break;
		case CH_4: midi_ch = 3; break;
		case CH_5: midi_ch = 4; break;
		case CH_6: midi_ch = 5; break;
		case CH_7: midi_ch = 6; break;
		case CH_8: midi_ch = 7; break;
		case CH_9: midi_ch = 8; break;
		case CH_10: midi_ch = 9; break;
		case CH_11: midi_ch = 10; break;
		case CH_12: midi_ch = 11; break;
		case CH_13: midi_ch = 12; break;
		case CH_14: midi_ch = 13; break;
		case CH_15: midi_ch = 14; break;
		case CH_16: midi_ch = 15; break;
	}
	return(0);
}


send_bank(vw)
int vw;	/*	virtual workstation handle	*/
{
	bulk_send(bulk_buff,midi_ch,9);	/* voice data	*/
	form_alert(1,"[1][Send Performance][OK]");
	bulk_send(per_bulk,midi_ch,2);	/*	performance data	*/
	return;
}

/********************************************************************

	file handling routines

********************************************************************/

do_open(vw)
int vw;	/*	virtual workstation handle	*/
{
	OBJECT *box;
	int result,fd,index,i;
	char in_file[128],tempy[128],*ptr;
	static char name[11] = "";
	extern int midi_ch;
	int per_flag;

	rsrc_gaddr(R_TREE,SEL_FUNC,&box);
	result = do_dialog(box,0);
	box[result].ob_state = NORMAL;
	switch(result)
	{
		case E_FBULK:
			if(get_file(tempy) == 0)
				return;
			join_fname(in_file,file_path,tempy);
			if((fd = Fopen(in_file,0)) < 0)
			{
				form_alert(1,"[3][Cannot open file][OK]");
				return(0);
			}
			Fread(fd,4096L,bulk_buff);
			Fclose(fd);
			/*
				get the performance file, if present
			*/
			ptr = (char *)(rindex(in_file,'.'));
			++ptr;
			*ptr = '\0';
			strcat(in_file,"per");	/*	create name of performance	*/
			if((fd = Fopen(in_file,0)) < 0)
			{
				for(i=0;i<32;++i)
				{
					new_perf(&bulk_buff[i*128],&per_bulk[i*64],i,"          ");
					new_perf(&bulk_buff[i*128],&per_bulk[(i*64) + 2048],i,"          ");
					fix_perf(&bulk_buff[i*128],&per_bulk[i*64],i);
					fix_perf(&bulk_buff[i*128],&per_bulk[(i * 64) + 2048],i);
				}
			}
			else	/*	fix up the inited performance buffer	*/
			{
				Fread(fd,4096L,per_bulk);
				Fclose(fd);
			}
			if((index = voice_sel(in_file,bulk_buff,vw)) >= 0)
			{
				patch = index;
				bulk2ed(&bulk_buff[index * 128],edit);	/* move into edit buffer	*/
				pblk2ped(&per_bulk[index * 64],pedit);
				change_patch(midi_ch,patch);
				edit_send(midi_ch,edit);
				perf_send(midi_ch,pedit);
			}
			break;
		case E_DXBULK:
			send_cmd(midi_ch,9);
			if(get_ed(bulk_buff) == 0)	/*	get data	*/
			{
				form_alert(1,"[3][Error in midi][OK]");
				return;
			}
			else
			{
				send_cmd(midi_ch,2);	/*	get bulk performance	*/
				get_ed(per_bulk);	/*	get data, DX-7 won't send this	*/
				if((index = voice_sel("DX-BULK",bulk_buff,vw)) >= 0)
				{
					patch = index;
					change_patch(midi_ch,patch);
					bulk2ed(&bulk_buff[index * 128],edit);	/* move to edit buffer	*/
					pblk2ped(&per_bulk[index * 64],pedit);
				}
			}
			break;
		case E_NEWVOI:
			ed_voice(vw,1);
			init_voice(edit,pedit,patch);	/*	init the edit buffer	*/
			change_patch(midi_ch,patch);
			break;
	}
	return;
}

do_new(vw)
int vw;	/*	virtual workstation handle	*/
{
	int i;

	for(i=0;i<32;++i)
	{
		new_voice(&bulk_buff[i * 128],&per_bulk[i*64],i,"New Voice ");
	}
	ed_voice(vw,1);
	change_patch(midi_ch,patch);
	bulk2ed(&bulk_buff[patch * 128],edit);
	pblk2ped(&per_bulk[patch * 64],pedit);
}

save_bank(vw)
int vw;	/*	virtual workstation handle	*/
{
	/*
		this saves a bank of data from the synthesizer to disk
	*/
	char in_file[128],temp_f[128];
	int fd;
	extern int midi_ch;
	OBJECT *box;
	int result;
	char *ptr;

	if(get_file(temp_f)==0)	/*	get file name	*/
		return;
	join_fname(in_file,file_path,temp_f);
	rsrc_gaddr(R_TREE,SAVE_SEL,&box);
	result = do_dialog(box,0);
	box[result].ob_state = NORMAL;
	switch(result)
	{
		case SS_DX:		/*	get data from DX	*/
			send_cmd(midi_ch,9);	/*	Get voice bulk data from ch 9	*/
			if(get_ed(bulk_buff) == 0)	/*	get data	*/
			{
				form_alert(1,"[1][Error in midi][OK]");
			}
			else
			{
				fd = Fcreate(in_file,0);
				Fwrite(fd,4096L,bulk_buff);	/*	write data	*/
				Fclose(fd);
			}
			send_cmd(midi_ch,2);
			if(get_ed(bulk_buff) > 0)	/*	if not there, don't do it*/
			{
				ptr = rindex(in_file,'.');
				*ptr = '\0';
				strcat(in_file,".per");
				fd=Fcreate(in_file,0);
				Fwrite(fd,4096L,per_bulk);
				Fclose(fd);
			}
			b_buff_state = VOICE;	/*	indicate contents of bulk buffer	*/
			break;
		case SS_BUFF:
			fd = Fcreate(in_file,0);
			Fwrite(fd,4096L,bulk_buff);	/*	write data	*/
			Fclose(fd);
			ptr = rindex(in_file,'.');
			*ptr = '\0';
			strcat(in_file,".per");
			fd=Fcreate(in_file,0);
			Fwrite(fd,4096L,per_bulk);
			Fclose(fd);
			break;
		case SS_CAN:
			return;
			break;
	}
}


arrange_bank(vw)
int vw;	/*	virtual workstation handle	*/
{
	arrange(vw,bulk_buff,per_bulk);
	bulk2ed(&bulk_buff[patch * 128],edit);
	pblk2ped(&per_bulk[patch * 64],pedit);
	edit_send(midi_ch,edit);
}

get_file(file)
char file[];
{
	char in_file[128],in_path[128];
	int drive;
	int exit;

	in_file[0] = '\0';
	if (strlen(file_path) == 0)
	{
		drive = Dgetdrv();
		sprintf(in_path,"%c:\\",drive + 'A');
		Dgetpath(temp,drive);
		strcat(in_path,temp);
		strcat(in_path,"*.VCE");
	}
	else
	{
		strcpy(in_path,file_path);
	}
	if (strlen(old_file) == 0)
		in_file[0] = '\0';
	else
		strcpy(in_file,old_file);
	do
	{
		fsel_input(in_path,in_file,&exit);
		if(exit == 0)
			return(0);
		if(exit == 1)
		{
			strcpy(file_path,in_path);
			strcpy(old_file,in_file);
			break;
		}
	}while(1);
	strcpy(file,in_file);
	return(1);
}

init_voice(buff,p_buff,p)
char *buff,*p_buff;
int p;
{
	char temp[128],p_temp[64];

	new_voice(temp,p_temp,p,"New Voice ");	/*	init voice in bulk buffer	*/
	bulk2ed(temp,buff);
	pblk2ped(p_temp,p_buff);
}	

join_fname(out,path,in)
char out[],path[],in[];
{
	char *ptr;

	strcpy(out,path);
	ptr = (char *)(rindex(out,'\\'));
	++ptr;
	*ptr = '\0';
	strcat(out,in);
}

/*
		edit buffer control routines
*/

ed_voice(vw,mode)
int vw,mode;
{

	/*
		select a voice by patch number
	*/
	OBJECT *box;
	int x,y,w,h,form_result;
	char *ptr;

	if(patch > 32 || patch < 0)
	{
		form_alert(1,"[3][Something is wrong | with patch # | notify author][Golly]");
		patch = 0;
	}
	rsrc_gaddr(0,PATCHSEL,&box);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,PS_TRACK,PS_SLIDE,31,patch);
	show_pos(box,PS_NUM,PS_BN,slidpos[0],x,y,w,h);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case PS_UP:
			case PS_DN:
			case PS_SLIDE:
			case PS_TRACK:
				do_vslider(0,box,PS_TRACK,PS_SLIDE,PS_UP,PS_DN,form_result,10);
				show_pos(box,PS_NUM,PS_BN,slidpos[0],x,y,w,h);
				break;
		}
	}while((form_result != PS_OK) && (form_result != PS_CAN));
	if((form_result == PS_OK) && mode)
	{
		ed2bulk(&bulk_buff[patch * 128],edit);	/* move edit buffer	 into bulk */
		ped2pblk(&per_bulk[patch * 64],pedit);
		patch = slidpos[0];
		change_patch(midi_ch,patch);
		bulk2ed(&bulk_buff[patch * 128],edit);	/* move into edit buffer	*/
		pblk2ped(&per_bulk[patch * 64],pedit);
		edit_send(midi_ch,edit);
		perf_send(midi_ch,pedit);
	}
	else if ((form_result == PS_OK) && !mode)
	{
		patch = slidpos[0];
		change_patch(midi_ch,patch);
	}
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return;
}

save_ed(vw)
int vw;
{	
	ed2bulk(&bulk_buff[patch * 128],edit);	/* move edit buffer	 into bulk */
	ped2pblk(&per_bulk[patch * 64],pedit);
}
