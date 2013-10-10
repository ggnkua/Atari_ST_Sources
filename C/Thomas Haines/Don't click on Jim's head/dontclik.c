/*
 * Don't Click Jim's Head
 *  v. 1.0
 */

#include <osbind.h>
#include <vdi.h>
#include <dos.h>
#include <aes.h>
#include <stdio.h>
#include <time.h>
#include <avr.h>

#include "jimshead.h"
#include "jimshead.c"

int falcon;  
int width;
short id;
short aes_handle;
short vdi_handle;

short junk;
short work_in[11] = {1,1,1,1,1,1,1,1,1,1,2};
short work_out[57];
short xyarray[4] = {0,0,2,30};
short max_xyarray[4] = {0,32,639,199};
short status;
short mousex;
short mousey;

short cliparray[] = {0,1,1,1};
short intout[128];
int wh=-1;
short aes_version;
short antishift_variable = 0;

int state;
short key, button, clicks;
short evnt_x, evnt_y;

char dontclik_menu[] = "  Don't Click Jim  ";
char dontclik_title[] = "From that Bastard Dan";
OBJECT *WHICH;

short *sound_buf=NULL;
avr_t avr_h;					// global AVR header for sample loading/saving

long sound_length;
short sound_rate;

/*
 * This is the sample list definition. It consists of a doubly linked
 * list of entries containing the samples which are available in the
 * current sample directory.
 */
struct samp_list
{
	struct samp_list *next;		// next samp_list entry (or NULL)
	struct samp_list *prev;		// previous samp_list entry (or NULL)
	char name[12];			// filename of sample in sample directory
	struct
	{
		long length;			// length of sample
		short rate;				// sample replay 'rate'
		char name[28];			// 28 character name - 0 padded
	} h;						// extracted from file header
	char zero;					// a zero since h.name is not guaranteed
								// null terminated.
};

struct samp_list simple_beep;	// dummy entry for standard bell

struct samp_list *root;			// root of list

struct samp_list *current_sound;	// the current sound
struct samp_list *first;			// pointer to element at top of window

long mxalloc = 0;				// does this GEMDOS know about Mxalloc?

#define	sndbase	((volatile short *)0xffff8900)

#define	sndbasehi	((volatile short *)0xffff8902)
#define	sndbasemid	((volatile short *)0xffff8904)
#define	sndbaselo	((volatile short *)0xffff8906)

#define	sndendhi	((volatile short *)0xffff890e)
#define	sndendmid	((volatile short *)0xffff8910)
#define	sndendlo	((volatile short *)0xffff8912)

#define	sndmode	((volatile short *)0xffff8920)


#define W_TYPE (NAME | MOVER | CLOSER)

void
which_resource(void)
{
	if(aes_version<0x0401)
	{
		if(work_out[1]<391) WHICH = JIMS_HEAD_R_L;
		if (work_out[1]>390) WHICH = JIMS_HEAD_R_H;
	}
	if (aes_version>=0x0401)
	{
		if (work_out[1]<391) WHICH = JIMS_HEAD_M_L;
		if (work_out[1]>390) WHICH = JIMS_HEAD_M_H;
	}
}

int	
new_window(OBJECT *tree, const char *title)
{
	GRECT p;
	
	// compute required size for window given object tree
	wind_calc(WC_BORDER, W_TYPE, PTRS((GRECT *)&WHICH[ROOT].ob_x),
	  &p.g_x, &p.g_y, &p.g_w, &p.g_h);
	  
	wh=wind_create(W_TYPE, ELTS(p));
	if(wh >= 0)
	{
		wind_title(wh, title);
		wind_open(wh, ELTS(p));
	}
	return wh;
}

int
redraw(int wh,GRECT *p)
{
	objc_draw(WHICH,ROOT,MAX_DEPTH,PTRS(p));
	return 1;
}

void
Get_tos_version(void)
{
	falcon = 1;
	aes_version = _AESglobal[0];
	if(aes_version<0x0340) falcon = 0;
}

void snd_wait(void)
{
	while((*sndbase)&0xff);
}

void snd_kill(void)
{
	*sndbase=0;
}

void snd_play(short *buf,long length,short rate)
{
	snd_kill();
	*sndbasehi=(short)((unsigned long)buf>>16);
	*sndbasemid=(short)((unsigned long)buf>>8);
	*sndbaselo=(short)buf;

	buf=(short *)((unsigned long)buf+length);
	*sndendhi=(short)((unsigned long)buf>>16);
	*sndendmid=(short)((unsigned long)buf>>8);
	*sndendlo=(short)buf;
	
	*sndmode=rate;
	*sndbase=1;		/* start single play mode */
}

/*
 * do_file - process a sample file, extracting the length and sample
 * rate information into p.
 *
 * This routine is woefully short on error checking and should be extended.
 */
void
do_file(struct samp_list *p)
{
	int fd=Fopen(p->name,FO_READ);

	if (fd>=0)
	{
		static unsigned short freqs[]={0,12517,25033,50066};
		int i;

		Fread(fd,sizeof(avr_h),&avr_h);
		p->h.length=avr_h.avr_length;
		p->h.name[sizeof(avr_h.avr_name)-1]='\0';		// place sentinel in buffer
		strncpy(p->h.name,avr_h.avr_name,sizeof(avr_h.avr_name));
		if (p->h.name[sizeof(avr_h.avr_name)-1]!='\0')	// did they hit the sentinel ?
			strncpy(p->h.name+sizeof(avr_h.avr_name),avr_h.avr_xname,
			  sizeof(avr_h.avr_xname));

		/*
		 * Here we approximate the frequency stored in the header
		 */
		for (i=sizeof(freqs)/sizeof(freqs[0]); i--; )
			if (freqs[i]>=(avr_h.avr_frequency&0xffffff))
				p->h.rate=0x80|i;

		Fclose(fd);
		p->zero=0;
	}
	else puts("didn't open");
//	else
//		process_err(fd);
}

/*
 * play_sound - play the current sample. This routine exists solely as
 * a target for a Supexec() call.
 */
long
play_sound(void)
{
	snd_play(sound_buf,current_sound->h.length,current_sound->h.rate);
	return 0;				// to stop warnings appearing
}

/*
 * wait_sample - wait for a sample to stop playing. We only really want
 * this to happen when clicking between items to we don't try and overlap
 * them. Again this must be called in Supervisor mode.
 */
long
wait_sample(void)
{
	snd_wait();
	return 0;				// to stop warnings appearing
}

/*
 * release_buffer - check if a buffer is allocated and free it.
 */
void
release_buffer(void)
{
	if (sound_buf)
	{
		Mfree(sound_buf);
		sound_buf=NULL;
	}
}

/*
 * load_sample - load a sample into memory. If sound_buf is not set up
 * we load it into the cookie's buffer.
 */
void
load_sample(const char *s,long length)
{
	int fd=Fopen(s,FO_READ);

	if (fd>=0)
	{
		Fseek(sizeof(avr_t),fd,FSEEK_SET);
		Fread(fd,length,sound_buf); 
		Fclose(fd);
	}
}

/*  sound chunk, this is a chunk of doo out of bell.cpx */
void
sound_works(struct samp_list *p)
{
	//graf_mouse(BUSY_BEE, NULL);

	/*
	 * If the name is empty then we're looking at the standard bell and
	 * don't need to load anything up.
	 */
	if (p->name[0])
	{
		/*
		 * CPXs should not allocate memory, sadly we need it here so we
		 * can preserve the contents of the existing buffer for the
		 * purpose of cancelling. Since we free it immediately
		 * afterwards with no intervening AES calls we should be safe.
		 */
		//printf("                   %d \n ",p->h.length);
		sound_buf =  Malloc(p->h.length);
		if ((long)sound_buf <= 0)
		{
			//need to do something here but I don't know what
			//goto nomem;					// was that a goto !!!
		}
		else
		{
			load_sample(p->name,p->h.length);
		}
	}
	
	/*
	 * Play the sample, then wait for it to finish. The routines which
	 * do this must be called at the Supervisor level as they play with
	 * the hardware.
	 */
	current_sound=p;

	Supexec(play_sound);
	Supexec(wait_sample);

	/*
	 * We must release the memory as quickly as possible so that there
	 * is no danger of it becoming lost as a result of a resolution
	 * change etc.
  */
	release_buffer();
//nomem:
}

#include "thomas.h"

int
main(void)
{
	GRECT full;
	struct samp_list *p;
  int len;
  byte far *modbuf,music=0;
  void *stack;	
  
	p=(struct samp_list *)malloc(sizeof(struct samp_list));
	id = appl_init();
	aes_handle = graf_handle(&junk,&junk,&junk,&junk);
	vdi_handle = aes_handle;

	Get_tos_version();
	
	if (aes_version >= 0x0400)		/* check for MultiTOS*/
	{
		menu_register(id, dontclik_menu); /* if it is make the name pretty*/
	}
  else graf_mouse(0,NULL);

	v_opnvwk(work_in,&vdi_handle,work_out);

	rsrc_init();

	//vq_extnd(vdi_handle, 1, intout);
	
	wind_get(DESK, WF_WXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);

	which_resource();

	rc_constrain(&full, (GRECT *)&WHICH[ROOT].ob_x);

	//form_alert(1,"[2][Good so far][ok]");

	wh = new_window(WHICH, dontclik_title);
  stack=Super(0);
  mod_init();
  Super(stack);
  modbuf=(char *)load_ice("croak.mod",&len);
	for(;;)
	{
		short msg[8], junk;
		int whichone,which_obj;
		
		whichone = evnt_multi(MU_TIMER | MU_MESAG | MU_BUTTON,
		  0, 0, 0,			// mouses
		  0, 0, 0, 0, 0,	// rectangle 1
		  0, 0, 0, 0, 0,	// rectangle 2
		  msg,				// message buffer
		  2000, 0,			// respond every 2s
		  &junk, &junk, &button, &junk, &junk, &junk);

		if (whichone & MU_BUTTON)
		{
			if ( button == 1 )
			{
				vq_mouse(vdi_handle,&status,&mousex,&mousey);
				which_obj = objc_find(WHICH,0,2,mousex,mousey);
		 		if ( which_obj == 1)
    		{
    		  if(music)
    		  {
	          music=0;
			      objc_change(WHICH,PLAY_MOD,0,0,0,768,480,music,1);
    		    stack=Super(0);
         	  mod_play(music,modbuf);
            Super(stack);
          }
					strcpy(p->name,"QUIT_IT.AVR");	// fill in entry
					//root->prev=p;		// and link into list
					p->prev=NULL;
					p->next=root;
					root=p;
					do_file(p);
					sound_works(p);
				} 
				else if(which_obj==PLAY_MOD)
			  {
	        music^=1;
			    objc_change(WHICH,PLAY_MOD,0,0,0,768,480,music,1);
	        stack=Super(0);
         	mod_play(music,modbuf);
          Super(stack);
          delay(500);
			  }
			}
		}
		
		if (whichone & MU_MESAG)
			switch (msg[0]) 
			{
				case WM_TOPPED:
					wind_set(msg[3], WF_TOP, msg[3]);
					break;

				case WM_CLOSED:
					wind_close(wh);
					wind_delete(wh);
					wh = -1;
					break;

				case WM_REDRAW:
					wind_redraw(msg[3], (GRECT *)&msg[4], redraw);
					break;

				case WM_MOVED:
					wind_set(wh, WF_CXYWH, PTRS((GRECT *)&msg[4]));
					wind_calc(WC_WORK, W_TYPE, PTRS((GRECT *)&msg[4]),
					  &WHICH[ROOT].ob_x,
					  &WHICH[ROOT].ob_y,
					  &WHICH[ROOT].ob_width,
					  &WHICH[ROOT].ob_height);
					break;
			}
		if(wh<0) break;
	}
	if(music)
	{
	  stack=Super(0);
    mod_play(0,modbuf);
    Super(stack);
  }
	free(modbuf);
	appl_exit();
	return 0;
}

/*
void
Wait_a_sec(void)
{
	
	//  Need to wait for a second here
	// Set a variable to the time
	// while variable = time  ' wait

	int mytime;
				
	mytime = clock()+20;
	
	do
	{
	 //  just sitting here burning the milliseconds  ;)
	} while (clock() < mytime);

}
*/