/**
 * 
 * TSR portion of HiSoft Bell Sample CPX
 * augmented by J.Rojewski 12/97
 * 
**/

#include <dos.h>
#include <string.h>
#include <cookie.h>
#include <sndbind.h>

typedef struct
{
#define AVR_MAGIC	0x32424954
	long avr_magic;					// '2BIT'
	char avr_name[8];				// sample name
#define AVR_MONO	0
#define AVR_STEREO	-1
	short avr_mode;					// mono/stereo
#define AVR_UNSIGNED	0
#define AVR_SIGNED	-1
	short avr_resolution;			// sample resolution
	short avr_signed;				// signed/unsigned sample
#define AVR_NON_LOOPING	0
#define AVR_LOOPING	-1
	short avr_looping;				// looping sample control
#define AVR_NOTE_NONE	-1
	short avr_midinote;				// assigned midi note
	unsigned long avr_frequency;	// sample frequency
	unsigned long avr_length;		// sample length
	unsigned long avr_loop_first;	// offset of first loop
	unsigned long avr_loop_end;		// offset of end loop
	char avr_reserved[6];			// reserved
	char avr_xname[20];				// sample name extension area
	char avr_user[64];				// user commitable area
} avr_t;

typedef struct
{
#define WAV_MAGIC	0x32424954
	long wav_magic;					// 'RIFF'
	long wav_size;					// sample name
	long wav_wave;					// 'WAVE'
	long wav_fmt;					// 'fmt '
	long wav_unkn1;
	long wav_unkn2;
	long wav_unkn3;
	unsigned long wav_frequency;	// sample frequency
	long wav_unkn4;
	long wav_data;					// 'data'
	unsigned long wav_length;		// sample length
} wav_t;


#define	sndbase	((volatile short *)0xffff8900)

#define	sndbasehi	((volatile short *)0xffff8902)
#define	sndbasemid	((volatile short *)0xffff8904)
#define	sndbaselo	((volatile short *)0xffff8906)

#define	sndendhi	((volatile short *)0xffff890e)
#define	sndendmid	((volatile short *)0xffff8910)
#define	sndendlo	((volatile short *)0xffff8912)

#define	sndmode	((volatile short *)0xffff8920)

struct sound {
	char * buf;
	long length;
	int rate;
	int dynamic;
	int mode;
	int prescale;
} sound;

void snd_wait(void)
{
	while ((*sndbase) & 0xff) ;
}

void snd_kill(void)
{
	*sndbase = 0;
}

void snd_play(void *buf, long length, short rate)
{
	if (buf) {
		snd_kill();
		*sndbasehi = (short)((unsigned long)buf >> 16);
		*sndbasemid = (short)((unsigned long)buf >> 8);
		*sndbaselo = (short)buf;

		buf = (short *)((unsigned long)buf + length);
		*sndendhi = (short)((unsigned long)buf >> 16);
		*sndendmid = (short)((unsigned long)buf >> 8);
		*sndendlo = (short)buf;

		*sndmode = rate;
		*sndbase = 1;			/* start single play mode */
	}
}

long play_sound(void)		/* in Supervisor mode */
{
	snd_play(sound.buf, sound.length, sound.rate);
	return 0;				// to stop warnings appearing
}

long wait_sample(void)		/* in Supervisor mode */
{
	snd_wait();
	return 0;				// to stop warnings appearing
}

int do_avr_file( char *name )
{
	avr_t avr_h;
	int ret=0;
	char *buffer=NULL;
	int fd=(int)Fopen(name,FO_READ);

	if (fd>=0)
	{
		static unsigned short freqs[]={0,12517,25033,50066};
		static unsigned short prescale[]={0,49170,33880,24585,20770,16490,0,12292,0,9834,0,8195};
		int i;

		Fread(fd,sizeof(avr_h),&avr_h);
		sound.length=avr_h.avr_length;
		if (avr_h.avr_mode==AVR_STEREO) sound.mode=0; else sound.mode=2;

		/*
		 * Here we approximate the frequency stored in the header
		 */
		for (i=sizeof(freqs)/sizeof(freqs[0]); i--; )
			if (freqs[i]>=(avr_h.avr_frequency&0xffffff))
				sound.rate=0x80|i;
		for (i=0;i<sizeof(prescale)/sizeof(prescale[0]);i++)
			if (prescale[i]>=(avr_h.avr_frequency&0xffffff))
				sound.prescale=i;
	/*	fprintf( log, "Sample length= %ld, rate= %x, prescale= %d\n", sound.length, sound.rate, sound.prescale ); */

		if ((buffer=malloc(sound.length+10))!=NULL) {
			sound.dynamic=1;
			Fread(fd, sound.length, buffer);
			sound.buf=buffer;
			Fclose(fd);
			ret++;
		} else {
			sound.dynamic=0;
		}
	}
	return(ret);
}

void avr( char *filename )
{
	long value=0;

	if (getcookie(_SND, &value) &&	/* must have an _SND cookie */
	  (value & 2)) {			/* DMA sound must be available */
		if (do_avr_file( filename )) {
			if (value & 4) {
				if (Locksnd()==1) {
					Devconnect( DMAPLAY, DAC, CLK25M, sound.prescale, NO_SHAKE );
					Setbuffer( PLAY, sound.buf, sound.buf + sound.length );
					Setmode( sound.mode );
					Buffoper( PLAY_ENABLE );
					Supexec(wait_sample);
					Unlocksnd();
				}
			} else {
				Supexec(play_sound);
				Supexec(wait_sample);
			}
			if (sound.dynamic==1) { free( sound.buf ); sound.dynamic=0; }
		}
	}
}

int do_wav_file( char *name )
{
	wav_t wav_h;
	int ret=0;
	unsigned long freq,c;
	char *buffer=NULL;
	int fd=(int)Fopen(name,FO_READ);

	if (fd>=0)
	{
		static unsigned short freqs[]={0,12517,25033,50066};
		static unsigned short prescale[]={0,49170,33880,24585,20770,16490,0,12292,0,9834,0,8195};
		int i;

		Fread(fd,sizeof(wav_h),&wav_h);
		if (wav_h.wav_fmt!=0x666d7420) { return(ret); }	/* 'fmt '*/

		swab(&wav_h.wav_length,&wav_h.wav_length,4);
		sound.length=wav_h.wav_length>>16;
		swab(&wav_h.wav_frequency,&freq,4);
		freq=freq>>16;
	/*	if (avr_h.avr_mode==AVR_STEREO) sound.mode=0; else sound.mode=2; */
		sound.mode=2;

		/*
		 * Here we approximate the frequency stored in the header
		 */
		for (i=sizeof(freqs)/sizeof(freqs[0]); i--; )
			if (freqs[i]>=(freq&0xffffff))
				sound.rate=0x80|i;
		for (i=0;i<sizeof(prescale)/sizeof(prescale[0]);i++)
			if (prescale[i]>=(freq&0xffffff))
				sound.prescale=i;
	/*	fprintf( log, "WAV Sample length= %ld, rate= %x, prescale= %d\n", sound.length, sound.rate, sound.prescale ); */

		if ((buffer=malloc(sound.length+10))!=NULL) {
			sound.dynamic=1;
			Fread(fd, sound.length, buffer);
			sound.buf=buffer;
			Fclose(fd);
			for (c=0;c<sound.length;c++) { /* invert bits */
				buffer[c]+=128;
			}
			ret++;
		} else {
			sound.dynamic=0;
		}
	}
	return(ret);
}


void wav( char *filename )
{
	long value=0;

	if (getcookie(_SND, &value) &&	/* must have an _SND cookie */
	  (value & 2)) {			/* DMA sound must be available */
		if (do_wav_file( filename )) {
			if (value & 4) {
				if (Locksnd()==1) {
					Devconnect( DMAPLAY, DAC, CLK25M, sound.prescale, NO_SHAKE );
					Setbuffer( PLAY, sound.buf, sound.buf + sound.length );
					Setmode( sound.mode );
					Buffoper( PLAY_ENABLE );
					Supexec(wait_sample);
					Unlocksnd();
				}
			} else {
				Supexec(play_sound);
				Supexec(wait_sample);
			}
			if (sound.dynamic==1) { free( sound.buf ); sound.dynamic=0; }
		}
	}
}


/* end of AVR.C */

