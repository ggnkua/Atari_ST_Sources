/* BO_SOUND.C
 * 
 * originally taken from Boinkout2 sound routines
 * and used in SantaRun et al 
 *
 * Now supports DMA and XBIOS sound functions as well
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "global.h"

long snd_system = 0;  /* This is the soundsystem that exists on the computer */

int sound_sys = ST_SOUND;

/* our global buffer to pass our sounds commands
 * to GEMJing
 */
char *args_buf = NULL;

/* sound playback flag */
/* sound system uses this to determine
 * how to or not to play game sounds
 */
int snd_flag = SND_OFF;

/* temp_snd_flag is used when changing the
 * sound settings via the dialog
 */
int temp_snd_flag = SND_OFF;

/* First the atari sound routines: */

/* the sound string is the yamaha sound chip parameter for the bouncing		*/
/* ball sound. The osound array resets the modified sound chip registers	*/
/* to their old values so that key click sounds will be normal when the		*/
/* program terminates.														*/

char sound[] =	{
	0,0xf0,1,0x0f, 2,0xff, 3,0x0f, 4,0x00, 5,0, 6,0x1f, 7,0xdc,
	8,0x10,9,0x10,10,0x10,11,0x00,12,25,13,0,0xff,0
	};

short appear[] = {
	0x040,0x102,0x242,0x302,0x400,0x500,0x61f,0x7dc,
	0x810,0x910,0xA10,0xB00,0xC15,0xD0f,0xFF00
	};

/* osound restores registers 9 and 10 for normal key click */
char osound[] = { 9, 0, 10, 0, 0xff, 0	};

short magic_bell[] = {
	0x0ff,0x100,0x2fe,0x300,0x400,0x500,0x600,0x7fc,
	0x810,0x910,0xa00,0xb00,0xc20,0xd09,0xff00
	};

short bricksound[] = {
	0x035,0x100,0x234,0x300,0x400,0x500,0x600,0x7fc,
	0x810,0x910,0xa00,0xb00,0xc15,0xd09,0xff00
	};

short permbricksound[] = {
	0x038,0x100,0x237,0x300,0x400,0x500,0x600,0x7fc,
	0x810,0x910,0xa00,0xb00,0xc0b,0xd09,0xff00
	};

short death[] = {
	0x0018,0x0100,0x073e,0x0810,0x0d09,0x8000,0x0b00,0x0c60,
	0x8100,0xce01,0xff00
	};

short lost_ball[] = {
	0x0000,0x0102,0x073e,0x0810,0x0d09,0x8000,0x0b00,0x0c30,
	0x8100,0x1801,0xff00
	};

short psound[] = {
	0x041,0x100,0x240,0x300,0x400,0x500,0x600,0x7fc,
	0x810,0x910,0xa00,0xb00,0xc15,0xd09,0xff00
	};

short bonus[] = {		/* bonus sound effect */
	0x000,0x100,0x200,0x300,0x400,0x500,0x600,0x7FE,
	0x80F,0x900,0xA00,0xB00,0xC00,0xD00,
	0x8040,0x8100,0xfd31,
	0x8040,0x8100,0xfd31,
	0x8040,0x8100,0xfd31,
	0x800,0xFF00
	};

int flute[] =
{
	200, 477, -1, 15, 1, 0, -13797, -1,
	26214, 14, 26214, -1, -16852, 0, 0, 0,
	0, 0, 0, -4, 30423, -29, -18758, 5,
	-22463, 0, 0, 28, 18758, 86, 2926, -11,
	-7397, 10, 21323, -85, -17949, -11, -7397, 50,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0
};


/* sound_init()
 *
 * detection of sound hardware
 * and starting of GEMJing
 */
 
int 
sound_init(void)
{
	snd_system = getcookie( _SND);

	if (snd_system == 3)
		sound_sys = STE_SOUND;
	else if (snd_system > 3)  /* not accurate but should work */
		sound_sys = FLC_SOUND;

	if (getcookie(McSn) > -1)
		sound_sys = FLC_SOUND;

	/* start GEMJing if we can */
	startGEMJing();

 	return 0;
}

/* sound_play()
 *
 * routes call to appropriate driver
 * or does nothing at all if sound is off
 */
 
void
sound_play(SND *p, int track, int mode)
{
	switch (snd_flag)
	{
		case SND_OFF:
			break;
		case SND_CHIP:
			chipsound_play(p->alt_chip);
			break;
		case SND_XBIOS:
			play_avr(p->snd_data, track, mode);
			break;
		case SND_GEMJING:
			playGEMJing(p->snd_data);
			break;	
	}

	return;
}

/* sound_wait()
 *
 * waits til the current sound is done playing
 * does nothing for chip sound
 */

void
sound_wait(void)
{
	switch (snd_flag)
	{
		case SND_OFF:
		case SND_CHIP:
			chipsound_wait();
			break;
		case SND_XBIOS:
			Supexec(wait_sample); 
			break;
		case SND_GEMJING:
			waitGEMJing();
			break;	
	}

	return;
}

/* sound_stop()
 *
 * stops the current sound playing
 * does nothing for chip sound
 */
 
void
sound_stop(void)
{
	switch (snd_flag)
	{
		case SND_OFF:
		case SND_CHIP:
			break;
		case SND_XBIOS:
			stop_sound(); 
			break;
		case SND_GEMJING:
			break;	
	}

	stopGEMJing();

	return;
}

/* sound_exit()
 *
 * Closes anything that we need to close
 */
 
void
sound_exit(void)
{
	switch (snd_flag)
	{
		case SND_OFF:
		case SND_CHIP:
		case SND_XBIOS:
		case SND_GEMJING:
			break;	
	}

	chipsound_exit();
	exitGEMJing();

	return;
}

/* chipsound_play
 *
 * Play a chip sound sound 
 */

int 
chipsound_play(int num)
{
	static void *dosndtab[]={appear, magic_bell, bricksound, permbricksound,
                 death, lost_ball, psound, bonus };

	if(num<=S_BONUS)
		Dosound(dosndtab[num]);
	else
		switch(num)
		{
			case S_SIDE:
				*(sound + 13) = 0x1e;
				Dosound(sound);
				break;
			case S_TOP:
				*(sound + 13) = 0x1d;
				Dosound(sound);
				break;
			case S_BOTTOM:
				*(sound + 13) = 0x1f;
				Dosound(sound);
				break;
		}

	return 0;
}

/* chipsound_wait()
 *
 * just wastes two seconds
 */
void
chipsound_wait(void)
{
	clock_t wait;

	/* wait 2 seconds */
	wait = clock() + (2 * CLK_TCK);
	
    while (clock() < wait) 
		;
}

/* chipsound_exit()
 *
 * resets the sound chip 
 */
 
void
chipsound_exit(void)
{
	Dosound(osound);
}

/* STe Sound routines */

/* snd_wait()
 *
 * low level DMA sound routine to wait for end of playback
 * Must be called in supervisor mode
 */

void 
snd_wait(void)
{
	while((*sndbase)&0xff);
}

/* snd_kill()
 * 
 * low level DMA sound stop routine
 * Must be called in supervisor mode
 */
 
void 
snd_kill(void)
{
	*sndbase=0;
}

/* snd_play()
 *
 * low level DMA sound play routine
 * Must be called in supervisor mode
 */
 
void 
snd_play(short *buf,long length,short rate)
{
	snd_kill();
	*sndbasehi=(short)((unsigned long)buf>>16);
	*sndbasemid=(short)((unsigned long)buf>>8);
	*sndbaselo=(short)buf;

	buf=(short *)((unsigned long)buf+length);
	*sndendhi=(short)((unsigned long)buf>>16);
	*sndendmid=(short)((unsigned long)buf>>8);
	*sndendlo=(short)buf;
	
	*sndmode=0;
	*sndmode=rate;
	*sndbase=1;		/* start single play mode */
}

/* snd_loop()
 * 
 * low level DMA sound loop routine
 * Must be called in supervisor mode
 */
void 
snd_loop(short *buf,long length,short rate)
{
	snd_kill();
	*sndbasehi=(short)((unsigned long)buf>>16);
	*sndbasemid=(short)((unsigned long)buf>>8);
	*sndbaselo=(short)buf;

	buf=(short *)((unsigned long)buf+length);
	*sndendhi=(short)((unsigned long)buf>>16);
	*sndendmid=(short)((unsigned long)buf>>8);
	*sndendlo=(short)buf;
	
	*sndmode=0;
	*sndmode=rate;
	*sndbase=3;		/* start loop play mode */
}


/* my dma routines */

SAMPLE *loopsnd;
SAMPLE *tempsnd;

/* do_file()
 *
 * process a sample file, extracting the length and sample
 * rate information into p.
 *
 * NOTE!!  Since the same buffer is used by GEMJING calls
 * the sound header is stored as well as the data.
 *
 * This routine is woefully short on error checking and 
 * should be extended.
 */
 
void
do_file(SAMPLE *p)
{
	int fd;
 	AVR_HEAD avr;

	fd=(int)Fopen(p->fname,FO_READ);

	if (fd>=0)
	{
		p->buf_len = Fseek(0,fd,SEEK_END);
		
		/* reset the file buffer position */
		Fseek(0,fd,SEEK_SET);

		Fread(fd,sizeof(avr),&avr);
		p->length=avr.size;
		
		/* place sentinel in buffer */
		p->name[sizeof(avr.name)-1]='\0';	
		strncpy(p->name,avr.name,sizeof(avr.name));

		/* did they hit the sentinel ? */
		if (p->name[sizeof(avr.name)-1]!='\0')	
			strncpy(p->name+sizeof(avr.name),avr.ext,sizeof(avr.ext));

		p->freq = avr.rate;

		p->stereo = avr.mono;
		p->rez = avr.rez;
		p->zero=0;

		if(AES_type == AES_single )
			p->buffer = (char *)Malloc(p->buf_len);
		else
			p->buffer = (char *)Mxalloc(p->buf_len,GLOBAL|2);

		if (!p->buffer)
		{
			form_alert(1,"[3][Not enough memory !|][Damn!]");
			Fclose(fd);

			return;
		}
		else
		{
			/* reset the file buffer position */
			Fseek(0,fd,SEEK_SET);

			Fread(fd, p->buf_len, p->buffer);
			Fclose(fd);

			/* I'm not certain if this is correct but seems to work */
			p->start = p->buffer + (long)sizeof(avr);
			p->end = p->buffer + (p->length/2);
		}

	}
	else
	{
		 form_alert(1,"[3][Couldn't open the file !|][Damn!]"); 
		 p->length = 0;
	}
}

/* play_dma()
 *
 * play the current sample. This routine exists solely as
 * a target for a Supexec() call.
 */
long
play_dma(void)
{
	snd_play(tempsnd->start,tempsnd->length,tempsnd->rate);
	return 0;				/* to stop warnings appearing */
}

/* play_dmaloop()
 *
 * play the current sample as a loop.
 * This routine exists solely as a target for Supexec() call
 */
long
play_dmaloop(void)
{
	snd_loop(loopsnd->start,loopsnd->length,loopsnd->rate);
	return 0;		/* to stop warnings appearing */
}

/* kill_dat_sound()
 *
 * Stops the current sound playback.
 * This routine exists solely as a target for Supexec() call
 */
long 
kill_dat_sound(void)
{
	snd_kill();
	return 0;
}


/* wait_sample()
 *
 * Wait for a sample to stop playing. We only really want
 * this to happen when clicking between items to we don't 
 * try and overlap them. Again this must be called in 
 * Supervisor mode.
 */
 
long
wait_sample(void)
{
	snd_wait(); 
	return 0;				/* to stop warnings appearing */
}

/* release_buffer()
 *
 * check if a buffer is allocated and free it.
 */
 
void
release_buffer(char *buffer)
{
	if (buffer > 0)
	{
		free(buffer);
		buffer=NULL;
	}
}

/* stop_sound()
 *
 * stop whatever sound is currently playing.
 */
 
void
stop_sound(void)
{
	if (sound_sys == FLC_SOUND)
		buffoper(0);
	else if (sound_sys == STE_SOUND)
		Supexec(kill_dat_sound);
}

/* play_avr()
 *
 * plays a sound buffer in either XBIOS or DMA sound
 */
 
void
play_avr(SAMPLE *p, int track, int mode)
{
	if (sound_sys == FLC_SOUND)
	{
		buffoper(0);

		setmontracks(track);

		if (soundcmd(7,-1) >= 0) 
			soundcmd(7, (short) p->freq); /* ohne feste XBIOS-Frequenzen spielen */
		else
		{
			if (p->freq > 37549L)
				p->rate = STE_50K;
			else if (p->freq <= 37549L && p->freq > 18775)
				p->rate = STE_25K;
			else if (p->freq <= 18775 && p->freq > 9387)
				p->rate = STE_12K;
			else if (p->freq <= 9387)
				p->rate = STE_6K;

			soundcmd(SETPRESCALE,p->rate); 
		}

		if (p->stereo == -1)
		{
			if (p->rez == 8)
				setmode(STEREO8);
			else
				setmode(STEREO16);
		}
		else
			setmode(MONO8);

		setbuffer(0,p->start,p->end);
		settracks(0, 0);
		
		/* I used the following command in my lattice routines		
		 * soundcmd(SETPRESCALE,(0x80|(p->rate + 1))); 
		*/

		devconnect(DMAPLAY,DAC,CLK25M,0,NO_SHAKE);

		buffoper(mode);
	}
	else if (sound_sys == STE_SOUND)
	{
		tempsnd = p;

		if (p->freq > 37549L)
			p->rate = STE_50K;
		else if (p->freq <= 37549L && p->freq > 18775)
			p->rate = STE_25K;
		else if (p->freq <= 18775 && p->freq > 9387)
			p->rate = STE_12K;
		else if (p->freq <= 9387)
			p->rate = STE_6K;

		if (mode == PLAY_ENABLE)
			Supexec(play_dma);
		else
			Supexec(play_dmaloop);
	}
}

/* play_avr_once()
 *
 * not used, but shows how to play an
 * AVR sound file as a one off event
 */
 
void
play_avr_once(char *avr_to_play, int track)
{
	SAMPLE *temp_avr;

	temp_avr=(SAMPLE *)malloc(sizeof(SAMPLE));

	if (temp_avr <= 0)
		goto notmem;

	temp_avr->length=0;

	construct_path(temp_avr->fname,snd_path,avr_to_play);	

	do_file(temp_avr);

	tempsnd = temp_avr;
	
	play_avr(tempsnd, track, PLAY_ENABLE);

	free(temp_avr);
	
	notmem:

	/*notmem is if we can't malloc*/
	;
}

/* load_avr()
 *
 * gets an AVR loaded into a SAMPLE struct for use
 */
SAMPLE *
load_avr(char *avr)
{
	SAMPLE *temp_avr;

	temp_avr=(SAMPLE *)malloc(sizeof(SAMPLE));

	if (temp_avr <= 0)
		return(NULL);

	temp_avr->length=0;

	construct_path(temp_avr->fname,snd_path,avr);	

	do_file(temp_avr);
	
	return(temp_avr);
}

/* free_avr()
 *
 * free's samples memory buffers
 */
 
void
free_avr(SAMPLE *avr)
{
	Mfree(avr->buffer);
	free(avr);
}

/* GemJing Routines */

/*	Variables used to store the state (DON'T MODIFY!)	*/
int quit_gemjing = FALSE;
int gemjing_id,gemjing_pid;
int sample_playing = -1;

/* getGemjingPid()
 *
 *	Function tries to find the gemjing process ID.
 * This is needed to send GEMJing the "stop" signal.
 * (see stopSample())
 */
void getGemjingPid(void)
{
	long ret,dirhandle;

	evnt_timer(200,0);
	ret=Dopendir("U:\\PROC",1);
	if(ret>=0)
	{
		char filename[32];

		dirhandle=ret;
		
		do
		{
			ret=Dreaddir(32,dirhandle,filename);
			if(ret == E_OK)
			{
				if(strnicmp(filename, "GEMJING.",8) == 0)
					gemjing_pid=atoi(filename+8);
			}
		}while(ret == E_OK);
		
		Dclosedir(dirhandle);
	}
}

/* startGEMJing()
 *
 * Finds and starts GemJing
 */

void
startGEMJing(void)
{
	int i;

	if(AES_type == AES_single )
		return;
	
	/*	Start GEMjing	*/
	gemjing_id = appl_find("GEMJING ");
	if(gemjing_id < 0)
	{
		char *path;

		/*	search for environment variable	*/
		shel_envrn(&path, "GEMJINGPATH=");

		if(path && *path)
		{
			char *args="\2-p";
			
			/*	Start gemjing in background (=no menubar)	*/
			if(AES_type == AES_MagiC)
				shel_write(1, 1, 100, path, args);
			else 
				shel_write(0, 1, 1, path, args);			

			for(i=0;i<10;i++)
			{
				#ifdef _GEMLIB_H_
					evnt_timer(100);
				#else
					evnt_timer(100,0);
				#endif

				gemjing_id = appl_find("GEMJING ");
				if(gemjing_id >= 0)
					break;
			}

			quit_gemjing=TRUE;
		}
		else
			gemjing_id=-1;
	}
	
	getGemjingPid();
	
	/* set up our arg_buf so that we can send commands */
	args_buf = (char *) Mxalloc(250,ALLOCMODE);
}

/* exitGEMJing()
 *
 * Tell GEMJing to quit.
 */
 
void
exitGEMJing(void)
{
	/*	If we started gemjing "manually" we'll quit it also	*/
	if(quit_gemjing)
	{
		int msg[8]={AP_TERM,-1,0,0,0,AP_TERM,0,0};

		msg[2]=app_id;
		
		appl_write(gemjing_id,16,msg);
		
		Mfree(args_buf);
	}
}


/* playGEMJing()
 *
 * Send GEMJing command to start playing sample.
 */
int
playGEMJing(SAMPLE *p)
{
	int msg[8];
	char args[60];

	if(!p->buffer)					/*	not loaded?	*/
		return TRUE;
	
	if(gemjing_id<0)							/* no gemjing?	*/
		return TRUE;

	if (sample_playing > 0)
		stopGEMJing();

	/*	prepare string which is sent via VA_START	*/		
	sprintf(args,"-m%ld,%ld",p->buffer,p->length);

	strcpy(args_buf,args);

	msg[0]=VA_START;
	msg[1]=app_id;
	msg[2]=0;
	msg[3]=(int)(((long)args_buf >> 16) & 0x0000ffffL);
	msg[4]=(int)(((long)args_buf) & 0x0000ffffL);
	msg[5]=0;
	msg[6]=0;
	msg[7]=0;

	if(appl_write(gemjing_id, 16, msg))
		sample_playing += 1;

/*	printf("Playing: %s with %s\n",p->fname,args_buf);
*/
	return FALSE;
}


/* stopGEMJing()
 *
 * Send GEMJing a signal to stop current sample replay.
 */
 
void 
stopGEMJing(void)
{
	if(gemjing_pid>0)
	{
		Pkill(gemjing_pid,SIGUSR1);

		#ifdef _GEMLIB_H_
			evnt_timer(100);
		#else
			evnt_timer(100,0);
		#endif
	}
}

/* waitGEMJing() 
 *
 * Wait for GEMJing to tell us it's done with a sound
 */
void
waitGEMJing(void)
{
	while (sample_playing > 0)
		full_multi();
}
