/*
	These routines generate played scales in the background
	to please(?) the ear
*/
#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>
/* #include <string.h>	*/
#include "dx.h"
#include "dxed.h"
#include <stdio.h>

#define NOTE_C	0
#define NOTE_CS	NOTE_C+1
#define	NOTE_D	NOTE_C+2
#define	NOTE_DS	NOTE_C+3
#define	NOTE_E	NOTE_C+4
#define	NOTE_F	NOTE_C+5
#define	NOTE_FS	NOTE_C+6
#define	NOTE_G	NOTE_C+7
#define	NOTE_GS	NOTE_C+8
#define	NOTE_A	NOTE_C+9
#define	NOTE_AS	NOTE_C+10
#define	NOTE_B	NOTE_C+11

#define COUNT_Q_ON 18
#define COUNT_Q_OFF	6

#define MyApp	0	/*	My application	*/
#define	Control	7	/*	divide by 200 prescale	*/
#define	Data	0
#define OFF		0
/*
	global variables
*/

int tempo = 200;
int velocity;
int num_of_octaves;
int start_note;
long oldvector;
int scale_map[12];
int note_pallet[140];	/*	notes to play each time thru	*/
int note_count,max_count;
int ticks;
int play_f = FALSE;	/*	play flag	*/
int count_flag = TRUE;	/*	count flag to keep track of note cycle	*/
static char midi_string[10];

extern int dispatcher();
extern int ticker();
extern int slidpos[10];
extern int midi_ch;	/*	midi channel	*/

do_scales(vw)
int vw;	/*	virtual workstation handle	*/
{
	OBJECT *box;
	int x,y,w,h,form_result,i;
	static int nt_tab1[12] = {
		SCL_C,SCL_CS,SCL_D,SCL_DS,SCL_E,SCL_F,SCL_FS,SCL_G,
		SCL_GS,SCL_A,SCL_AS,SCL_B };

	static int nt_tab2[12] = {
			NOTE_C,NOTE_CS,NOTE_D,NOTE_DS,NOTE_E,NOTE_F,NOTE_FS,NOTE_G,
			NOTE_GS,NOTE_A,NOTE_AS,NOTE_B };
	int st_note;
	int nm_octaves;
	int map[12];
	int old_tempo;
	int Set_Tempo();

	old_tempo = tempo;
	rsrc_gaddr(R_TREE,SCALES,&box);
	/*
		get voice name
	*/
	for(i=0;i< 12;++i)	/*	initialize note selectors	*/
	{
		if(scale_map[i])
			box[nt_tab1[i]].ob_state |= SELECTED;
		else
			box[nt_tab1[i]].ob_state &= ~SELECTED;
		map[i] = scale_map[i];
	}
	box[SCLSTPMS].ob_flags |= HIDETREE;
	graf_mouse(0,0L);
	v_show_c(vw,0);
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
		/*
			init sliders to current settings
		*/
	vreset(0,box,SCL_TK0,SCL_SL0,127,velocity);
	vreset(1,box,SCL_TK1,SCL_SL1,185,tempo - 70);
	show_pos3(box,SCL_NM0,SCL_BN0,slidpos[0],x,y,w,h);
	show_pos3(box,SCL_NM1,SCL_BN1,15360 / (slidpos[1] + 70),x,y,w,h);
	st_note = start_note;
	nm_octaves = num_of_octaves;
	show_pos(box,SCL_NONM,SCL_NOBN,nm_octaves+1,x,y,w,h);
	show_bp(box,SCL_SNNM,SCL_SNBN,st_note,x,y,w,h);
	do
	{
		form_result = form_do(box,0) & 0x7fff;
		switch(form_result)
		{
			case SCL_UP0:	/*	slider handlers	*/
			case SCL_DN0:
			case SCL_TK0:
			case SCL_SL0:
				do_vslider(0,box,SCL_TK0,SCL_SL0,SCL_UP0,SCL_DN0,form_result,10);
				show_pos3(box,SCL_NM0,SCL_BN0,slidpos[0],x,y,w,h);
				velocity = slidpos[0];
				break;
			case SCL_UP1:	/*	tempo	*/
			case SCL_DN1:
			case SCL_TK1:
			case SCL_SL1:
				do_vslider(1,box,SCL_TK1,SCL_SL1,SCL_UP1,SCL_DN1,form_result,20);
				show_pos3(box,SCL_NM1,SCL_BN1,15360 /(slidpos[1] + 70),x,y,w,h);
				tempo = slidpos[1] + 70;
				if(play_f)
				{
					Supexec(Set_Tempo);
				}
				break;
			case SCL_SNUP:
				if(!play_f)
				{
					++st_note;
					if(st_note == 128)
						st_note = 127;
					show_bp(box,SCL_SNNM,SCL_SNBN,st_note,x,y,w,h);
				}
				break;
			case SCL_SNDN:
				if(!play_f)
				{
					--st_note;
					if(st_note < 0)
						st_note = 0;
					show_bp(box,SCL_SNNM,SCL_SNBN,st_note,x,y,w,h);
				}
				break;
			case SCL_NOUP:
				if(!play_f)
				{
					++nm_octaves;
					if(nm_octaves > 8)
						nm_octaves = 8;
					show_pos(box,SCL_NONM,SCL_NOBN,nm_octaves+1,x,y,w,h);
				}
				break;
			case SCL_NODN:
				if(!play_f)
				{
					--nm_octaves;
					if(nm_octaves < 0)
						nm_octaves = 0;
					show_pos(box,SCL_NONM,SCL_NOBN,nm_octaves+1,x,y,w,h);
				}
				break;
			case SCL_C:
			case SCL_CS:
			case SCL_D:
			case SCL_DS:
			case SCL_E:
			case SCL_F:
			case SCL_FS:
			case SCL_G:
			case SCL_GS:
			case SCL_A:
			case SCL_AS:
			case SCL_B:
				if(!play_f)
				{
					i = find_note(form_result,nt_tab1);
					map[i] ^= TRUE;	/*	complement bit	*/
				}
				break;
			case SCLPLAY:
				if(box[SCLPLAY].ob_state & SELECTED)
				{
					if(setup_notes(map,nm_octaves,st_note,nt_tab2) == 0)
					{
						box[SCLSTPMS].ob_flags &= ~HIDETREE;
						objc_draw(box,SCLSTPMS,1,x,y,w,h);
						Supexec(Set_Tempo);
						note_count = 0;
						play_f = TRUE;
						set_terminate();		/*	start timer	*/
						ticks = 20;
						set_timer();
						pms(vw);		/*	the rest of this kluge	*/
						play_f = FALSE;
						unset_timer();
						unset_terminate(); /*	kill timer	*/
						objc_change(box,SCLPLAY,0,x,y,w,h,NORMAL,FALSE);
						box[SCLSTPMS].ob_flags |= HIDETREE;
						objc_draw(box,0,2,x,y,w,h);
					}
					else
					{
						objc_change(box,SCLPLAY,0,x,y,w,h,NORMAL,TRUE);
					}
				}
				else
				{
					play_f = FALSE;
					unset_timer();
					unset_terminate(); /*	kill timer	*/
				}
				break;
		}
	}while((form_result != SCLOK) && (form_result != SCLCAN));
	if(form_result == SCLOK)
	{
		start_note = st_note;	/*	save new values	*/
		num_of_octaves = nm_octaves;
		tempo = slidpos[1] + 70;
		if(tempo < 70)
			tempo = 70;
		if(tempo > 255)
			tempo = 255;
		velocity = slidpos[0];
		for(i=0;i<12;++i)
			scale_map[i] = map[i];
	}
	else if(form_result == SCLCAN)
	{
		tempo = old_tempo;
	}
	box[form_result].ob_state = NORMAL;
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
	return;
}

pms(vw)
int vw;
{
	int dummy,mousedown;

	do
	{
		if(ticks < 0)
		{
			if(count_flag)
			{
				count_flag = FALSE;
				ticks = COUNT_Q_ON;	/*	RESET counter	*/
				midi_string[0] = (char)(0x90 | midi_ch);
				midi_string[1] = (char)note_pallet[note_count];
				midi_string[2] = (char)velocity;
				Midiws(2,midi_string);	/*	write midi port	*/
			}
			else
			{
				count_flag = TRUE;
				ticks = COUNT_Q_OFF;	/*	RESET counter	*/
				midi_string[0] = (char)0x90 | midi_ch;
				midi_string[1] = (char)note_pallet[note_count++];
				midi_string[2] = (char)0;
				Midiws(2,midi_string);	/*	write midi port	*/
				if(note_count >= max_count)
					note_count = 0;
			}
		}
		vq_mouse(vw,&mousedown,&dummy,&dummy);
	}while(!(mousedown & 0x02));
	midi_string[0] = (char)0x90 | midi_ch;
	midi_string[1] = (char)note_pallet[note_count++];
	midi_string[2] = (char)0;
	Midiws(2,midi_string);	/*	write midi port	*/
}

/*
	timer routines:
	This routine is called by the interrupt handler to increment the 
	local tick counter.
*/
ticker()
{
	ticks--;
}


/*
	My terminate application function.
*/
terminate()
{
	/*
		Clear 68901 timer interrupt
	*/
	unset_timer();

	/*
		Restore the old process terminate vector
	*/
	Setexc(0x0102, oldvector);
}

/*
	Get the old terminate application vector and setup
	the local terminate function.
*/
set_terminate()
{
	long user_stack = Super(0L);

	oldvector = Setexc(0x0102, -1L);
	Setexc(0x0102, terminate);

	Super(user_stack);
}


unset_terminate()
{
	/*
		Restore the old process terminate vector
	*/
	Supexec(Setexc(0x0102, oldvector));
}


/* 
	This is the interrupt dispatcher routine.
*/
asm {
dispatcher:
			movem.l	D0-D7/A0-A5,-(A7)	/*	push reg on stack	*/
			jsr		ticker				/* our function			*/
			movem.l	(A7)+,D0-D7/A0-A5	/*	pop reg from stack	*/
			bclr.b	#5,0xfffa0f 		/* Tell MFP the interrupt has been serviced	*/
			rte		 					/* return from exception*/
}


/*
	This function is callled by the main() function to set up the
	application terminate function and the 68901 function timer.
*/
set_timer()
{
	/*
		Tell the timer chip to call the dispatcher routine for the interrupt.
	*/
	Xbtimer(MyApp, Control, tempo, dispatcher);
}


/*
	Turn off the timer and reset the terminate vector.
*/
unset_timer()
{
	/*
		Turn off the application timer.
	*/
	Xbtimer(MyApp, OFF, OFF, NULL);
}

Set_Tempo()
{
	char *mfp;

	mfp = (char *)0xfffa1f;
	*mfp = tempo;
}

init_scales()
{
	register int i;

	for(i=0;i<12;++i)
		scale_map[i] = FALSE;
	num_of_octaves = 0;
	start_note = NOTE_C;
}

find_note(n,tab)
int n,tab[];
{
	register int i;

	for(i=0;i<12;++i)
		if(tab[i] == n)
			return(i);
	return(-1);
}

setup_notes(map,o,s,notes)
int map[],o,s,notes[];
{
	/*
	 *	Set up the notes in the note buffer
	*/

	register int i,j;
	int count = 0;
	int index;
	int s_oct,old;
	char temp[80];

	index = s % 12;	/*	get starting index into note table	*/
	s_oct = s / 12;	/*	starting octave	*/
	for(i=0;i < 12;++i)
		if(map[i])
			++count;	/*	find out how many notes there is	*/
	for(i = 0; i < (o * count);++i)
	{
		note_pallet[i] = notes[index] + (s_oct * 12);
		old = index;
		if((index = find_next_index(index,map)) < old)
		{
			++s_oct;	/*	we have crossed octave land	*/
		}
		if(index < 0)
		{
			form_alert(1,"[2][Error!!!|You must specify at least one|note man!][OK]");
			return(-1);
		}
	}
	note_pallet[i] = -1;
	max_count = o * count;
	return(0);
}

find_next_index(i,map)
int i,map[];
{
	register int j;

	for(j=i+1;j < 12 ;++j)	/*	find next index	*/
		if(map[j])
			return(j);
	for(j=0;j<i;++j)
		if(map[j])
			return(j);
	return(-1);
}
