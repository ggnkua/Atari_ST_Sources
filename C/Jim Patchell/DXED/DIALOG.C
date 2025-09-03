/*
	These are the routines that are mainly activated by the MENU
	that interact with the user
*/
#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>
/* #include <strings.h>	*/
#include "dx.h"
#include "dxed.h"

/*	global variables	*/

extern int midi_ch;
extern int slidpos[10];
char bulk_buff[4096],per_bulk[4096];
char file_path[128] = "\0";
char old_file[20] = "\0";
int op,op_en;	/*	current operator being edited	*/
char edit[155],pedit[94];
int b_buff_state;	/*	contents of bulk buffer	*/
char temp[128];

extern int mf_play_pb,mf_play_rec;	/*	sequencer selections	*/
extern int mf_pr_prt,mf_pr_bnd,mf_pr_mwh,mf_pr_fct,mf_pr_bth,mf_pr_aft,mf_pr_oth;
extern int mf_md_lfo,mf_md_pev,mf_md_oth;
extern int mf_o_envl,mf_o_freq,mf_o_scal,mf_o_sens,mf_o_opr;	/*operator*/
extern int mf_m_smch,mf_m_gbnk,mf_m_sbnk;	/*	midi stuff	*/
extern int mf_f_sbnk,mf_f_lbnk,mf_f_open,mf_f_new,mf_f_save,mf_f_arng,mf_f_quit;

init_dia()
{
	b_buff_state = EMPTY;
}

/********************************************************************

	Modulation routines

********************************************************************/

do_lfo(vw)
int vw;	/*	virtual workstation handle	*/
{
	/*
		this is where we do lfo parameters
	*/
	OBJECT *box;
	MISC *misc;
	int x,y,w,h,form_result;

	misc = (MISC *)(&edit[126]);
	rsrc_gaddr(0,LFO,&box);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK29,SLIDER29,99,misc->lfo_speed);
	vreset(1,box,TRACK30,SLIDER30,99,misc->lfo_delay);
	vreset(2,box,TRACK31,SLIDER31,99,misc->lfo_p_m_d);
	vreset(3,box,TRACK32,SLIDER32,99,misc->lfo_a_m_d);
	vreset(4,box,TRACK33,SLIDER33,1,misc->lfo_sync);
	vreset(5,box,TRACK34,SLIDER34,5,misc->lfo_wave);
	vreset(6,box,TRACK35,SLIDER35,7,misc->lfo_pms);
	show_pos(box,NUMBER29,BN29,slidpos[0],x,y,w,h);
	show_pos(box,NUMBER30,BN30,slidpos[1],x,y,w,h);
	show_pos(box,NUMBER31,BN31,slidpos[2],x,y,w,h);
	show_pos(box,NUMBER32,BN32,slidpos[3],x,y,w,h);
	show_pos(box,NUMBER33,BN33,slidpos[4],x,y,w,h);
	show_wave(box,NUMBER34,BN34,slidpos[5],x,y,w,h);
	show_pos(box,NUMBER35,BN35,slidpos[6],x,y,w,h);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP29:
			case DN29:
			case SLIDER29:
			case TRACK29:
				do_vslider(0,box,TRACK29,SLIDER29,UP29,DN29,form_result,10);
				show_pos(box,NUMBER29,BN29,slidpos[0],x,y,w,h);
				chg_param(midi_ch,0,1,9,slidpos[0]);
				break;
			case UP30:
			case DN30:
			case SLIDER30:
			case TRACK30:
				do_vslider(1,box,TRACK30,SLIDER30,UP30,DN30,form_result,10);
				show_pos(box,NUMBER30,BN30,slidpos[1],x,y,w,h);
				chg_param(midi_ch,0,1,10,slidpos[1]);
				break;
			case UP31:
			case DN31:
			case SLIDER31:
			case TRACK31:
				do_vslider(2,box,TRACK31,SLIDER31,UP31,DN31,form_result,10);
				show_pos(box,NUMBER31,BN31,slidpos[2],x,y,w,h);
				chg_param(midi_ch,0,1,11,slidpos[2]);
				break;
			case UP32:
			case DN32:
			case SLIDER32:
			case TRACK32:
				do_vslider(3,box,TRACK32,SLIDER32,UP32,DN32,form_result,10);
				show_pos(box,NUMBER32,BN32,slidpos[3],x,y,w,h);
				chg_param(midi_ch,0,1,12,slidpos[3]);
				break;
			case UP33:
			case DN33:
			case SLIDER33:
			case TRACK33:
				do_vslider(4,box,TRACK33,SLIDER33,UP33,DN33,form_result,1);
				show_pos(box,NUMBER33,BN33,slidpos[4],x,y,w,h);
				chg_param(midi_ch,0,1,13,slidpos[4]);
				break;
			case UP34:
			case DN34:
			case SLIDER34:
			case TRACK34:
				do_vslider(5,box,TRACK34,SLIDER34,UP34,DN34,form_result,1);
				show_wave(box,NUMBER34,BN34,slidpos[5],x,y,w,h);
				chg_param(midi_ch,0,1,14,slidpos[5]);
				break;
			case UP35:
			case DN35:
			case SLIDER35:
			case TRACK35:
				do_vslider(6,box,TRACK35,SLIDER35,UP35,DN35,form_result,1);
				show_pos(box,NUMBER35,BN35,slidpos[6],x,y,w,h);
				chg_param(midi_ch,0,1,15,slidpos[6]);
				break;
		}
	}while((form_result != MOD_OK) && (form_result != MOD_CAN));
	if(form_result == MOD_OK)
	{
		misc->lfo_delay = slidpos[1];
		misc->lfo_speed = slidpos[0];
		misc->lfo_p_m_d = slidpos[2];
		misc->lfo_a_m_d = slidpos[3];
		misc->lfo_sync = slidpos[4];
		misc->lfo_wave = slidpos[5];
		misc->lfo_pms = slidpos[6];
	}
	chg_param(midi_ch,0,1,10,misc->lfo_delay);
	chg_param(midi_ch,0,1,9,misc->lfo_speed);
	chg_param(midi_ch,0,1,11,misc->lfo_p_m_d);
	chg_param(midi_ch,0,1,12,misc->lfo_a_m_d);
	chg_param(midi_ch,0,1,13,misc->lfo_sync);
	chg_param(midi_ch,0,1,14,misc->lfo_wave);
	chg_param(midi_ch,0,1,15,misc->lfo_pms);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return;
}

do_pitch_env(vw)
int vw;	/*	virtual workstation handle	*/
{
	/*
		This is where we do the pitch envelope
	*/
	OBJECT *box;
	MISC *misc;
	int x,y,w,h,form_result;

	misc = (MISC *)(&edit[126]);
	sprintf(temp,"%d",op);
	rsrc_gaddr(0,P_ENVEL,&box);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK21,SLIDER21,99,misc->pr1);
	vreset(1,box,TRACK22,SLIDER22,99,misc->pr2);
	vreset(2,box,TRACK23,SLIDER23,99,misc->pr3);
	vreset(3,box,TRACK24,SLIDER24,99,misc->pr4);
	vreset(4,box,TRACK25,SLIDER25,99,misc->pl1);
	vreset(5,box,TRACK26,SLIDER26,99,misc->pl2);
	vreset(6,box,TRACK27,SLIDER27,99,misc->pl3);
	vreset(7,box,TRACK28,SLIDER28,99,misc->pl4);
	show_pos(box,NUMBER21,BN21,slidpos[0],x,y,w,h);
	show_pos(box,NUMBER22,BN22,slidpos[1],x,y,w,h);
	show_pos(box,NUMBER23,BN23,slidpos[2],x,y,w,h);
	show_pos(box,NUMBER24,BN24,slidpos[3],x,y,w,h);
	show_pos(box,NUMBER25,BN25,slidpos[4],x,y,w,h);
	show_pos(box,NUMBER26,BN26,slidpos[5],x,y,w,h);
	show_pos(box,NUMBER27,BN27,slidpos[6],x,y,w,h);
	show_pos(box,NUMBER28,BN28,slidpos[7],x,y,w,h);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP21:
			case DN21:
			case SLIDER21:
			case TRACK21:
				do_vslider(0,box,TRACK21,SLIDER21,UP21,DN21,form_result,10);
				show_pos(box,NUMBER21,BN21,slidpos[0],x,y,w,h);
				chg_param(midi_ch,0,0,126,slidpos[0]);
				break;
			case UP22:
			case DN22:
			case SLIDER22:
			case TRACK22:
				do_vslider(1,box,TRACK22,SLIDER22,UP22,DN22,form_result,10);
				show_pos(box,NUMBER22,BN22,slidpos[1],x,y,w,h);
				chg_param(midi_ch,0,0,127,slidpos[1]);
				break;
			case UP23:
			case DN23:
			case SLIDER23:
			case TRACK23:
				do_vslider(2,box,TRACK23,SLIDER23,UP23,DN23,form_result,10);
				show_pos(box,NUMBER23,BN23,slidpos[2],x,y,w,h);
				chg_param(midi_ch,0,1,0,slidpos[2]);
				break;
			case UP24:
			case DN24:
			case SLIDER24:
			case TRACK24:
				do_vslider(3,box,TRACK24,SLIDER24,UP24,DN24,form_result,10);
				show_pos(box,NUMBER24,BN24,slidpos[3],x,y,w,h);
				chg_param(midi_ch,0,1,1,slidpos[3]);
				break;
			case UP25:
			case DN25:
			case SLIDER25:
			case TRACK25:
				do_vslider(4,box,TRACK25,SLIDER25,UP25,DN25,form_result,10);
				show_pos(box,NUMBER25,BN25,slidpos[4],x,y,w,h);
				chg_param(midi_ch,0,1,2,slidpos[4]);
				break;
			case UP26:
			case DN26:
			case SLIDER26:
			case TRACK26:
				do_vslider(5,box,TRACK26,SLIDER26,UP26,DN26,form_result,10);
				show_pos(box,NUMBER26,BN26,slidpos[5],x,y,w,h);
				chg_param(midi_ch,0,1,3,slidpos[5]);
				break;
			case UP27:
			case DN27:
			case SLIDER27:
			case TRACK27:
				do_vslider(6,box,TRACK27,SLIDER27,UP27,DN27,form_result,10);
				show_pos(box,NUMBER27,BN27,slidpos[6],x,y,w,h);
				chg_param(midi_ch,0,1,4,slidpos[6]);
				break;
			case UP28:
			case DN28:
			case SLIDER28:
			case TRACK28:
				do_vslider(7,box,TRACK28,SLIDER28,UP28,DN28,form_result,10);
				show_pos(box,NUMBER28,BN28,slidpos[7],x,y,w,h);
				chg_param(midi_ch,0,1,5,slidpos[7]);
				break;
		}
	}while((form_result != PEV_OK) && (form_result != PEV_CAN));
	if(form_result == PEV_OK)
	{
		misc->pr1 = slidpos[0];
		misc->pr2 = slidpos[1];
		misc->pr3 = slidpos[2];
		misc->pr4 = slidpos[3];
		misc->pl1 = slidpos[4];
		misc->pl2 = slidpos[5];
		misc->pl3 = slidpos[6];
		misc->pl4 = slidpos[7];
	}
	chg_param(midi_ch,0,0,126,misc->pr1);
	chg_param(midi_ch,0,0,127,misc->pr2);
	chg_param(midi_ch,0,1,0,misc->pr3);
	chg_param(midi_ch,0,1,1,misc->pr4);
	chg_param(midi_ch,0,1,2,misc->pl1);
	chg_param(midi_ch,0,1,3,misc->pl2);
	chg_param(midi_ch,0,1,4,misc->pl3);
	chg_param(midi_ch,0,1,5,misc->pl4);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return;
}

do_other(vw)
int vw;	/*	virtual workstation handle	*/
{
	OBJECT *box;
	MISC *misc;
	int x,y,w,h,form_result,i;
	char name[11],*t;

	misc = (MISC *)(&edit[126]);
	rsrc_gaddr(0,M_OTHER,&box);
	/*
		get voice name
	*/
	t = (char *)(&edit[145]);
	for(i=0;i<10;++i)
		name[i] = t[i];
	name[i] = '\0';
	((TEDINFO *)box[O_VNAME].ob_spec)->te_ptext = name;
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK36,SLIDER36,7,misc->feed_bk);
	vreset(1,box,TRACK37,SLIDER37,31,misc->alg_select);
	vreset(2,box,TRACK38,SLIDER38,48,misc->transpose);
	vreset(3,box,TRACK53,SLIDER53,1,misc->osc_sync);
	show_pos(box,NUMBER36,BN36,slidpos[0],x,y,w,h);
	show_pos(box,NUMBER37,BN37,slidpos[1] + 1,x,y,w,h);
	show_pos(box,NUMBER38,BN38,slidpos[2],x,y,w,h);
	show_ks(box,O_KEYSYN,O_B_KYSN,slidpos[3],x,y,w,h);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP36:
			case DN36:
			case SLIDER36:
			case TRACK36:
				do_vslider(0,box,TRACK36,SLIDER36,UP36,DN36,form_result,1);
				show_pos(box,NUMBER36,BN36,slidpos[0],x,y,w,h);
				chg_param(midi_ch,0,1,7,slidpos[0]);
				break;
			case UP37:
			case DN37:
			case SLIDER37:
			case TRACK37:
				do_vslider(1,box,TRACK37,SLIDER37,UP37,DN37,form_result,4);
				show_pos(box,NUMBER37,BN37,slidpos[1] + 1,x,y,w,h);
				chg_param(midi_ch,0,1,6,slidpos[1]);
				break;
			case UP38:
			case DN38:
			case SLIDER38:
			case TRACK38:
				do_vslider(2,box,TRACK38,SLIDER38,UP38,DN38,form_result,4);
				show_pos(box,NUMBER38,BN38,slidpos[2],x,y,w,h);
				chg_param(midi_ch,0,1,16,slidpos[2]);
				break;
			case UP53:
			case DN53:
			case SLIDER53:
			case TRACK53:
				do_vslider(3,box,TRACK53,SLIDER53,UP53,DN53,form_result,1);
				show_ks(box,O_KEYSYN,O_B_KYSN,slidpos[3],x,y,w,h);
				chg_param(midi_ch,0,1,8,slidpos[3]);
				break;
		}
	}while((form_result != OTH_OK) && (form_result != OTH_CAN));
	if(form_result == OTH_OK)
	{
		misc->feed_bk = slidpos[0];
		misc->alg_select = slidpos[1];
		misc->transpose = slidpos[2];
		misc->osc_sync = slidpos[3];
		for(i=0;i<10;++i)
			t[i] = name[i];	/*	put name in edit buffer	*/
	}
	chg_param(midi_ch,0,1,7,misc->feed_bk);
	chg_param(midi_ch,0,1,6,misc->alg_select);
	chg_param(midi_ch,0,1,16,misc->transpose);
	chg_param(midi_ch,0,1,8,misc->osc_sync);
	for(i=0;i<10;++i)
		chg_param(midi_ch,0,1,17 + i,t[i]);	/*	send name out	*/
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return;
}

/********************************************************************

	operator Edit routines

********************************************************************/

do_op_envelope(vw)
int vw;	/*	virtual workstation handle	*/
{
	/*
		this is where we handle the envelope dialog box
	*/
	OBJECT *box;
	OP *opd;
	int x,y,w,h,form_result;

	opd = (OP *)(&edit[(6 - op) * 21]);
	sprintf(temp,"%d",op);
	rsrc_gaddr(0,ENVELOPE,&box);
	strcpy(box[EN_OPNNM].ob_spec,temp);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK0,SLIDER0,99,opd->op_egr1);
	vreset(1,box,TRACK1,SLIDER1,99,opd->op_egr2);
	vreset(2,box,TRACK2,SLIDER2,99,opd->op_egr3);
	vreset(3,box,TRACK3,SLIDER3,99,opd->op_egr4);
	vreset(4,box,TRACK4,SLIDER4,99,opd->op_eg_l1);
	vreset(5,box,TRACK5,SLIDER5,99,opd->op_eg_l2);
	vreset(6,box,TRACK6,SLIDER6,99,opd->op_eg_l3);
	vreset(7,box,TRACK7,SLIDER7,99,opd->op_eg_l4);
	show_pos(box,NUMBER0,BN0,slidpos[0],x,y,w,h);
	show_pos(box,NUMBER1,BN1,slidpos[1],x,y,w,h);
	show_pos(box,NUMBER2,BN2,slidpos[2],x,y,w,h);
	show_pos(box,NUMBER3,BN3,slidpos[3],x,y,w,h);
	show_pos(box,NUMBER4,BN4,slidpos[4],x,y,w,h);
	show_pos(box,NUMBER5,BN5,slidpos[5],x,y,w,h);
	show_pos(box,NUMBER6,BN6,slidpos[6],x,y,w,h);
	show_pos(box,NUMBER7,BN7,slidpos[7],x,y,w,h);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP0:
			case DN0:
			case SLIDER0:
			case TRACK0:
				do_vslider(0,box,TRACK0,SLIDER0,UP0,DN0,form_result,10);
				show_pos(box,NUMBER0,BN0,slidpos[0],x,y,w,h);
				chg_param(midi_ch,0,0,0 + ((6 - op) * 21),slidpos[0]);
				break;
			case UP1:
			case DN1:
			case SLIDER1:
			case TRACK1:
				do_vslider(1,box,TRACK1,SLIDER1,UP1,DN1,form_result,10);
				show_pos(box,NUMBER1,BN1,slidpos[1],x,y,w,h);
				chg_param(midi_ch,0,0,1 + ((6 - op) * 21),slidpos[1]);
				break;
			case UP2:
			case DN2:
			case SLIDER2:
			case TRACK2:
				do_vslider(2,box,TRACK2,SLIDER2,UP2,DN2,form_result,10);
				show_pos(box,NUMBER2,BN2,slidpos[2],x,y,w,h);
				chg_param(midi_ch,0,0,2 + ((6 - op) * 21),slidpos[2]);
				break;
			case UP3:
			case DN3:
			case SLIDER3:
			case TRACK3:
				do_vslider(3,box,TRACK3,SLIDER3,UP3,DN3,form_result,10);
				show_pos(box,NUMBER3,BN3,slidpos[3],x,y,w,h);
				chg_param(midi_ch,0,0,3 + ((6 - op) * 21),slidpos[3]);
				break;
			case UP4:
			case DN4:
			case SLIDER4:
			case TRACK4:
				do_vslider(4,box,TRACK4,SLIDER4,UP4,DN4,form_result,10);
				show_pos(box,NUMBER4,BN4,slidpos[4],x,y,w,h);
				chg_param(midi_ch,0,0,4 + ((6 - op) * 21),slidpos[4]);
				break;
			case UP5:
			case DN5:
			case SLIDER5:
			case TRACK5:
				do_vslider(5,box,TRACK5,SLIDER5,UP5,DN5,form_result,10);
				show_pos(box,NUMBER5,BN5,slidpos[5],x,y,w,h);
				chg_param(midi_ch,0,0,5 + ((6 - op) * 21),slidpos[5]);
				break;
			case UP6:
			case DN6:
			case SLIDER6:
			case TRACK6:
				do_vslider(6,box,TRACK6,SLIDER6,UP6,DN6,form_result,10);
				show_pos(box,NUMBER6,BN6,slidpos[6],x,y,w,h);
				chg_param(midi_ch,0,0,6 + ((6 - op) * 21),slidpos[6]);
				break;
			case UP7:
			case DN7:
			case SLIDER7:
			case TRACK7:
				do_vslider(7,box,TRACK7,SLIDER7,UP7,DN7,form_result,10);
				show_pos(box,NUMBER7,BN7,slidpos[7],x,y,w,h);
				chg_param(midi_ch,0,0,7 + ((6 - op) * 21),slidpos[7]);
				break;
		}
	}while((form_result != ENVEL_OK) && (form_result != ENVELCAN));
	if(form_result == ENVEL_OK)
	{
		opd->op_egr1 = slidpos[0];
		opd->op_egr2 = slidpos[1];
		opd->op_egr3 = slidpos[2];
		opd->op_egr4 = slidpos[3];
		opd->op_eg_l1 = slidpos[4];
		opd->op_eg_l2 = slidpos[5];
		opd->op_eg_l3 = slidpos[6];
		opd->op_eg_l4 = slidpos[7];
	}
	chg_param(midi_ch,0,0,0 + ((6 - op) * 21),opd->op_egr1);
	chg_param(midi_ch,0,0,1 + ((6 - op) * 21),opd->op_egr2);
	chg_param(midi_ch,0,0,2 + ((6 - op) * 21),opd->op_egr3);
	chg_param(midi_ch,0,0,3 + ((6 - op) * 21),opd->op_egr4);
	chg_param(midi_ch,0,0,4 + ((6 - op) * 21),opd->op_eg_l1);
	chg_param(midi_ch,0,0,5 + ((6 - op) * 21),opd->op_eg_l2);
	chg_param(midi_ch,0,0,6 + ((6 - op) * 21),opd->op_eg_l3);
	chg_param(midi_ch,0,0,7 + ((6 - op) * 21),opd->op_eg_l4);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return(0);
}

do_op_freq(vw)
int vw;	/*	virtual workstation handle	*/
{
	/*	we do the frequency thing here	*/
	OBJECT *box;
	OP *opd;
	int x,y,w,h,form_result;

	opd = (OP *)(&edit[(6 - op) * 21]);
	sprintf(temp,"%d",op);
	rsrc_gaddr(0,FREQENCY,&box);
	strcpy(box[FREQ_NUM].ob_spec,temp);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK18,SLIDER18,31,opd->op_osc_crs);
	vreset(1,box,TRACK19,SLIDER19,99,opd->op_osc_f_f);
	vreset(2,box,TRACK20,SLIDER20,14,opd->op_detune);
	vreset(3,box,TRACK17,SLIDER17,1,opd->op_osc_mode);
	show_pos(box,NUMBER18,BN18,slidpos[0],x,y,w,h);
	show_pos(box,NUMBER19,BN19,slidpos[1],x,y,w,h);
	show_pos(box,NUMBER20,BN20,slidpos[2],x,y,w,h);
	show_pos(box,NUMBER17,BN17,slidpos[3],x,y,w,h);
	show_freq(box,FREQ_VAL,FREQ_BOX,slidpos[0],slidpos[1],slidpos[3],
				x,y,w,h);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP18:
			case DN18:
			case SLIDER18:
			case TRACK18:
				do_vslider(0,box,TRACK18,SLIDER18,UP18,DN18,form_result,4);
				show_pos(box,NUMBER18,BN18,slidpos[0],x,y,w,h);
				chg_param(midi_ch,0,0,18 + ((6 - op) * 21),slidpos[0]);
				show_freq(box,FREQ_VAL,FREQ_BOX,slidpos[0],
				slidpos[1],slidpos[3],x,y,w,h);
				break;
			case UP19:
			case DN19:
			case SLIDER19:
			case TRACK19:
				do_vslider(1,box,TRACK19,SLIDER19,UP19,DN19,form_result,10);
				show_pos(box,NUMBER19,BN19,slidpos[1],x,y,w,h);
				chg_param(midi_ch,0,0,19 + ((6 - op) * 21),slidpos[1]);
				show_freq(box,FREQ_VAL,FREQ_BOX,slidpos[0],
				slidpos[1],slidpos[3],x,y,w,h);
				break;
			case UP20:
			case DN20:
			case SLIDER20:
			case TRACK20:
				do_vslider(2,box,TRACK20,SLIDER20,UP20,DN20,form_result,2);
				show_pos(box,NUMBER20,BN20,slidpos[2],x,y,w,h);
				chg_param(midi_ch,0,0,20 + ((6 - op) * 21),slidpos[2]);
				break;
			case UP17:
			case DN17:
			case SLIDER17:
			case TRACK17:
				do_vslider(3,box,TRACK17,SLIDER17,UP17,DN17,form_result,1);
				show_pos(box,NUMBER17,BN17,slidpos[3],x,y,w,h);
				chg_param(midi_ch,0,0,17 + ((6 - op) * 21),slidpos[3]);
				show_freq(box,FREQ_VAL,FREQ_BOX,slidpos[0],
				slidpos[1],slidpos[3],x,y,w,h);
				break;
		}
	}while((form_result != FREQ_XIT) && (form_result != FREQ_CAN));
	if(form_result == FREQ_XIT)
	{
		opd->op_osc_crs = slidpos[0];
		opd->op_osc_f_f = slidpos[1];
		opd->op_detune = slidpos[2];
		opd->op_osc_mode = slidpos[3];
	}
	chg_param(midi_ch,0,0,18 + ((6 - op) * 21),opd->op_osc_crs);
	chg_param(midi_ch,0,0,19 + ((6 - op) * 21),opd->op_osc_f_f);
	chg_param(midi_ch,0,0,20 + ((6 - op) * 21),opd->op_detune);
	chg_param(midi_ch,0,0,17 + ((6 - op) * 21),opd->op_osc_mode);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);

	return;
}

do_scale(vw)
int vw;	/*	virtual workstation handle	*/
{
	/*	THIS IS WHERE WE DO SCALING	*/

	OBJECT *box;
	OP *opd;
	int x,y,w,h,form_result;

	opd = (OP *)(&edit[(6 - op) * 21]);
	sprintf(temp,"%d",op);
	rsrc_gaddr(0,SCALING,&box);
	strcpy(box[SCALE_NM].ob_spec,temp);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK8,SLIDER8,99,opd->op_kb_bp);
	vreset(1,box,TRACK9,SLIDER9,99,opd->op_kb_ld);
	vreset(2,box,TRACK10,SLIDER10,99,opd->op_kb_rd);
	vreset(3,box,TRACK11,SLIDER11,3,opd->op_kb_lc);
	vreset(4,box,TRACK12,SLIDER12,3,opd->op_kb_rc);
	vreset(5,box,TRACK13,SLIDER13,7,opd->op_kb_sc);
	show_bp(box,NUMBER8,BN8,slidpos[0],x,y,w,h);
	show_pos(box,NUMBER9,BN9,slidpos[1],x,y,w,h);
	show_pos(box,NUMBER10,BN10,slidpos[2],x,y,w,h);
	show_crv(box,NUMBER11,BN11,slidpos[3],x,y,w,h);
	show_crv(box,NUMBER12,BN12,slidpos[4],x,y,w,h);
	show_pos(box,NUMBER13,BN13,slidpos[5],x,y,w,h);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP8:
			case DN8:
			case SLIDER8:
			case TRACK8:
				do_vslider(0,box,TRACK8,SLIDER8,UP8,DN8,form_result,10);
				show_bp(box,NUMBER8,BN8,slidpos[0],x,y,w,h);
				chg_param(midi_ch,0,0,8 + ((6 - op) * 21),slidpos[0]);
				break;
			case UP9:
			case DN9:
			case SLIDER9:
			case TRACK9:
				do_vslider(1,box,TRACK9,SLIDER9,UP9,DN9,form_result,10);
				show_pos(box,NUMBER9,BN9,slidpos[1],x,y,w,h);
				chg_param(midi_ch,0,0,9 + ((6 - op) * 21),slidpos[1]);
				break;
			case UP10:
			case DN10:
			case SLIDER10:
			case TRACK10:
				do_vslider(2,box,TRACK10,SLIDER10,UP10,DN10,form_result,10);
				show_pos(box,NUMBER10,BN10,slidpos[2],x,y,w,h);
				chg_param(midi_ch,0,0,10 + ((6 - op) * 21),slidpos[2]);
				break;
			case UP11:
			case DN11:
			case SLIDER11:
			case TRACK11:
				do_vslider(3,box,TRACK11,SLIDER11,UP11,DN11,form_result,10);
				show_crv(box,NUMBER11,BN11,slidpos[3],x,y,w,h);
				chg_param(midi_ch,0,0,11 + ((6 - op) * 21),slidpos[3]);
				break;
			case UP12:
			case DN12:
			case SLIDER12:
			case TRACK12:
				do_vslider(4,box,TRACK12,SLIDER12,UP12,DN12,form_result,10);
				show_crv(box,NUMBER12,BN12,slidpos[4],x,y,w,h);
				chg_param(midi_ch,0,0,12 + ((6 - op) * 21),slidpos[4]);
				break;
			case UP13:
			case DN13:
			case SLIDER13:
			case TRACK13:
				do_vslider(5,box,TRACK13,SLIDER13,UP13,DN13,form_result,10);
				show_pos(box,NUMBER13,BN13,slidpos[5],x,y,w,h);
				chg_param(midi_ch,0,0,13 + ((6 - op) * 21),slidpos[5]);
				break;
		}
	}while((form_result != SCALEXIT) && (form_result != SCALECAN));
	if(form_result == SCALEXIT)
	{
		opd->op_kb_bp = slidpos[0];
		opd->op_kb_ld = slidpos[1];
		opd->op_kb_rd = slidpos[2];
		opd->op_kb_lc = slidpos[3];
		opd->op_kb_rc = slidpos[4];
		opd->op_kb_sc = slidpos[5];
	}
	chg_param(midi_ch,0,0,8 + ((6 - op) * 21),opd->op_kb_bp);
	chg_param(midi_ch,0,0,9 + ((6 - op) * 21),opd->op_kb_ld);
	chg_param(midi_ch,0,0,10 + ((6 - op) * 21),opd->op_kb_rd);
	chg_param(midi_ch,0,0,11 + ((6 - op) * 21),opd->op_kb_lc);
	chg_param(midi_ch,0,0,12 + ((6 - op) * 21),opd->op_kb_rc);
	chg_param(midi_ch,0,0,13 + ((6 - op) * 21),opd->op_kb_sc);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return;
}

do_sensitiv(vw)
int vw;	/*	virtual workstation handle	*/
{
	/*	this is where we handle the modulation sensitivity	*/
	OBJECT *box;
	OP *opd;
	int x,y,w,h,form_result;

	opd = (OP *)(&edit[(6 - op) * 21]);
	sprintf(temp,"%d",op);
	rsrc_gaddr(0,SENSITIV,&box);
	strcpy(box[SENS_NUM].ob_spec,temp);
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,TRACK14,SLIDER14,3,opd->op_ams);
	vreset(1,box,TRACK15,SLIDER15,7,opd->op_kvs);
	vreset(2,box,TRACK16,SLIDER16,99,opd->op_out_level);
	show_pos(box,NUMBER14,BN14,slidpos[0],x,y,w,h);
	show_pos(box,NUMBER15,BN15,slidpos[1],x,y,w,h);
	show_pos(box,NUMBER16,BN16,slidpos[2],x,y,w,h);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case UP14:
			case DN14:
			case SLIDER14:
			case TRACK14:
				do_vslider(0,box,TRACK14,SLIDER14,UP14,DN14,form_result,1);
				show_pos(box,NUMBER14,BN14,slidpos[0],x,y,w,h);
				chg_param(midi_ch,0,0,14 + ((6 - op) * 21),slidpos[0]);
				break;
			case UP15:
			case DN15:
			case SLIDER15:
			case TRACK15:
				do_vslider(1,box,TRACK15,SLIDER15,UP15,DN15,form_result,1);
				show_pos(box,NUMBER15,BN15,slidpos[1],x,y,w,h);
				chg_param(midi_ch,0,0,15 + ((6 - op) * 21),slidpos[1]);
				break;
			case UP16:
			case DN16:
			case SLIDER16:
			case TRACK16:
				do_vslider(2,box,TRACK16,SLIDER16,UP16,DN16,form_result,10);
				show_pos(box,NUMBER16,BN16,slidpos[2],x,y,w,h);
				chg_param(midi_ch,0,0,16 + ((6 - op) * 21),slidpos[2]);
				break;
		}
	}while((form_result != SEN_XIT) && (form_result != SEN_CAN));
	if(form_result == SEN_XIT)
	{
		opd->op_ams = slidpos[0];
		opd->op_kvs = slidpos[1];
		opd->op_out_level = slidpos[2];
	}
	chg_param(midi_ch,0,0,14 + ((6 - op) * 21),opd->op_ams);
	chg_param(midi_ch,0,0,15 + ((6 - op) * 21),opd->op_kvs);
	chg_param(midi_ch,0,0,16 + ((6 - op) * 21),opd->op_out_level);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return;
}

do_operator(vw)
int vw;	/*	virtual workstation handle	*/
{
	/*
		this function controls the operators
	*/
	OBJECT *box;
	int x,y,w,h,form_result,op_ent,flag;

	flag = FALSE;	/*	initial setting of flag	*/
	op_ent = op_en;
	rsrc_gaddr(R_TREE,OPERATOR,&box);
	if( op_ent & OP1 )
		box[OPR_1_ON].ob_state = SELECTED;
	else
		box[OPR_1_ON].ob_state = NORMAL;
	if( op_ent & OP2 )
		box[OPR_2_ON].ob_state = SELECTED;
	else
		box[OPR_2_ON].ob_state = NORMAL;
	if( op_ent & OP3 )
		box[OPR_3_ON].ob_state = SELECTED;
	else
		box[OPR_3_ON].ob_state = NORMAL;
	if( op_ent & OP4 )
		box[OPR_4_ON].ob_state = SELECTED;
	else
		box[OPR_4_ON].ob_state = NORMAL;
	if( op_ent & OP5 )
		box[OPR_5_ON].ob_state = SELECTED;
	else
		box[OPR_5_ON].ob_state = NORMAL;
	if( op_ent & OP6 )
		box[OPR_6_ON].ob_state = SELECTED;
	else
		box[OPR_6_ON].ob_state = NORMAL;
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,3,x,y,w,h);
	do
	{
		form_result = form_do(box,0);
		switch(form_result)
		{
			case OPR_OP1:
				op = 1;
				objc_change(box,OPR_OP1,0,x,y,w,h,SELECTED,TRUE);
				objc_change(box,OPR_OP2,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP3,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP4,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP5,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP6,0,x,y,w,h,NORMAL,TRUE);
				flag = TRUE;
				break;
			case OPR_OP2:
				op = 2;
				objc_change(box,OPR_OP1,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP2,0,x,y,w,h,SELECTED,TRUE);
				objc_change(box,OPR_OP3,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP4,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP5,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP6,0,x,y,w,h,NORMAL,TRUE);
				flag = TRUE;
				break;
			case OPR_OP3:
				op = 3;
				objc_change(box,OPR_OP1,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP2,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP3,0,x,y,w,h,SELECTED,TRUE);
				objc_change(box,OPR_OP4,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP5,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP6,0,x,y,w,h,NORMAL,TRUE);
				flag = TRUE;
				break;
			case OPR_OP4:
				op = 4;
				objc_change(box,OPR_OP1,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP2,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP3,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP4,0,x,y,w,h,SELECTED,TRUE);
				objc_change(box,OPR_OP5,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP6,0,x,y,w,h,NORMAL,TRUE);
				flag = TRUE;
				break;
			case OPR_OP5:
				op = 5;
				objc_change(box,OPR_OP1,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP2,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP3,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP4,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP5,0,x,y,w,h,SELECTED,TRUE);
				objc_change(box,OPR_OP6,0,x,y,w,h,NORMAL,TRUE);
				flag = TRUE;
				break;
			case OPR_OP6:
				op = 6;
				objc_change(box,OPR_OP1,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP2,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP3,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP4,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP5,0,x,y,w,h,NORMAL,TRUE);
				objc_change(box,OPR_OP6,0,x,y,w,h,SELECTED,TRUE);
				flag = TRUE;
				break;
			case OPR_1_ON:
				op_ent ^= OP1;	/*	complement bit	*/
				if(op_ent & OP1)
					objc_change(box,form_result,0,x,y,w,h,SELECTED,TRUE);
				else
					objc_change(box,form_result,0,x,y,w,h,NORMAL,TRUE);
				chg_param(midi_ch,0,1,27,op_ent);
				break;
			case OPR_2_ON:
				op_ent ^= OP2;	/*	complement bit	*/
				if(op_ent & OP2)
					objc_change(box,form_result,0,x,y,w,h,SELECTED,TRUE);
				else
					objc_change(box,form_result,0,x,y,w,h,NORMAL,TRUE);
				chg_param(midi_ch,0,1,27,op_ent);
				break;
			case OPR_3_ON:
				op_ent ^= OP3;	/*	complement bit	*/
				if(op_ent & OP3)
					objc_change(box,form_result,0,x,y,w,h,SELECTED,TRUE);
				else
					objc_change(box,form_result,0,x,y,w,h,NORMAL,TRUE);
				chg_param(midi_ch,0,1,27,op_ent);
				break;
			case OPR_4_ON:
				op_ent ^= OP4;	/*	complement bit	*/
				if(op_ent & OP4)
					objc_change(box,form_result,0,x,y,w,h,SELECTED,TRUE);
				else
					objc_change(box,form_result,0,x,y,w,h,NORMAL,TRUE);
				chg_param(midi_ch,0,1,27,op_ent);
				break;
			case OPR_5_ON:
				op_ent ^= OP5;	/*	complement bit	*/
				if(op_ent & OP5)
					objc_change(box,form_result,0,x,y,w,h,SELECTED,TRUE);
				else
					objc_change(box,form_result,0,x,y,w,h,NORMAL,TRUE);
				chg_param(midi_ch,0,1,27,op_ent);
				break;
			case OPR_6_ON:
				op_ent ^= OP6;	/*	complement bit	*/
				if(op_ent & OP6)
					objc_change(box,form_result,0,x,y,w,h,SELECTED,TRUE);
				else
					objc_change(box,form_result,0,x,y,w,h,NORMAL,TRUE);
				chg_param(midi_ch,0,1,27,op_ent);
				break;
		}
	}while((form_result != OPR_OK) && (form_result != OPR_CAN));
	if( form_result == OPR_OK)
		op_en = op_ent;
	chg_param(midi_ch,0,1,27,op_en);
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	if(flag)
	{
		mf_o_freq = TRUE;
		mf_o_envl = TRUE;
		mf_o_scal = TRUE;
		mf_o_sens = TRUE;
		menu_update();	/*	disable certain things in menu bar	*/
	}
	return;
}

