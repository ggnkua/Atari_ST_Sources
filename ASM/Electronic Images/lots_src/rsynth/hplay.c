/* $Id: hplay.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
 */
char *hplay_id = "$Id: hplay.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $";
#ifdef NeXT
/*****************************************************************/
/*****************************************************************/
/***                                                           ***/
/***                                                           ***/
/***    Play out a  file on the NeXT                           ***/
/***                                                           ***/
/***                                                           ***/
/***                B. Stuyts 21-feb-94                        ***/
/***                                                           ***/
/***                                                           ***/
/*****************************************************************/
/*****************************************************************/

#include <sound/sound.h>
#include <stdio.h>
#include <libc.h>
#include "proto.h"
#include "getargs.h"
#include "hplay.h"

#undef DEBUG

#define SAMP_RATE SND_RATE_CODEC
long samp_rate = SAMP_RATE;

SNDSoundStruct *sound;

int 
audio_init(int argc, char *argv[])
{
 int err;
 int rate_set = 0;

#ifdef DEBUG
 int i;

 printf("audio_init: %d\n", argc);
 for (i = 0; i < argc; i++)
  printf("audio_init arg %d = %s\n", i, argv[i]);
#endif

 argc = getargs(argc, argv,
		"r", "%d", &rate_set,
		NULL);

 if (rate_set)
  samp_rate = rate_set;

 err = SNDAlloc(&sound, 1000000, SND_FORMAT_LINEAR_16, samp_rate, 1, 0);
 if (err)
  {
   fprintf(stderr, "audio_init: %s\n", SNDSoundError(err));
   exit(1);
  }

 return argc;
}

void 
audio_play(int n, short *data)
{
 int err;

#ifdef DEBUG
 printf("audio_play: %d words\n", n);
#if 0
 printf("audio_play: sound = %ld\n", sound);
 printf("audio_play: dataLocation = %ld\n", sound->dataLocation);
 printf("audio_play: sum = %ld\n", (char *) sound + sound->dataLocation);
#endif
#endif

 if (n > 0)
  {
   sound->dataSize = n * sizeof(short);
   bcopy(data, (char *) sound + sound->dataLocation, n * sizeof(short));

   err = SNDWait(0);
   if (err)
    {
     fprintf(stderr, "audio_play: %s\n", SNDSoundError(err));
     exit(1);
    }

   err = SNDStartPlaying(sound, 1, 5, 0, 0, 0);
   if (err)
    {
     fprintf(stderr, "audio_play: %s\n", SNDSoundError(err));
     exit(1);
    }
  }
}

void 
audio_term()
{
 int err;

#ifdef DEBUG
 printf("audio_term\n");
#endif

 err = SNDWait(0);
 if (err)
  {
   fprintf(stderr, "audio_play: %s\n", SNDSoundError(err));
   exit(1);
  }

 err = SNDFree(sound);
 if (err)
  {
   fprintf(stderr, "audio_term: %s\n", SNDSoundError(err));
   exit(1);
  }
}

#else


#ifdef linux
/*****************************************************************/
/***                                                           ***/
/***    Play out a file on Linux                               ***/
/***                                                           ***/
/***                H.F. Silverman 1/4/91                      ***/
/***    Modified:   H.F. Silverman 1/16/91 for amax parameter  ***/
/***    Modified:   A. Smith 2/14/91 for 8kHz for klatt synth  ***/
/***    Modified:   Rob W. W. Hooft (hooft@EMBL-Heidelberg.DE) ***/
/***                adapted for linux soundpackage Version 2.0 ***/
/***                                                           ***/
/*****************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <errno.h>
#include <ctype.h>

#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/file.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <sys/signal.h>

#include <sys/ioctl.h>

#include <sys/soundcard.h>
#include "proto.h"
#include "getargs.h"
#include "hplay.h"

#define SAMP_RATE 8000
long samp_rate = SAMP_RATE;

/* Audio Parameters */

static int dev_fd = -1;
 /* file descriptor for audio device */
char *dev_file = "/dev/sbdsp";

static int linear_fd = -1;

static char *linear_file = NULL;

char *prog = "hplay";

static int
audio_open(void)
{
 dev_fd = open(dev_file, O_WRONLY | O_NDELAY);
 if (dev_fd < 0)
  {
   perror(dev_file);
   return 0;
  }
 return 1;
}

int
audio_init(int argc, char *argv[])
{
 int rate_set = 0;
 int use_linear = 0;
 int use_audio = 1;

 prog = argv[0];

 argc = getargs(argc, argv,
		"r", "%d", &rate_set,
		"a", NULL, &use_audio,
		"L", NULL, &use_linear,
		"l", "", &linear_file,
		NULL);

 if (linear_file)
  {
   linear_fd = open(linear_file, O_WRONLY | O_CREAT | O_TRUNC, 0666);
   if (linear_fd < 0)
    perror(linear_file);
  }

 if (use_audio)
  audio_open();

 if (rate_set)
  samp_rate = rate_set;

 if (dev_fd > 0)
  {
   ioctl(dev_fd, SNDCTL_DSP_SPEED, &samp_rate);
   printf("Actual sound rate: %ld\n", samp_rate);
  }

 return argc;
}

void
audio_term()
{
 int dummy;

 /* Close audio system  */
 if (dev_fd >= 0)
  {
   ioctl(dev_fd, SNDCTL_DSP_SYNC, &dummy);
   close(dev_fd);
   dev_fd = -1;
  }

 /* Finish linear file */
 if (linear_fd >= 0)
  {
   ftruncate(linear_fd, lseek(linear_fd, 0L, SEEK_CUR));
   close(linear_fd);
   linear_fd = -1;
  }
}

void
audio_play(int n, short *data)
{
 if (n > 0)
  {
   unsigned char *converted = (unsigned char *) malloc(n);
   int i;

   if (converted == NULL)
    {
     fprintf(stderr, "Could not allocate memory for conversion\n");
     exit(3);
    }

   for (i = 0; i < n; i++)
    converted[i] = (data[i] - 32768) / 256;

   if (linear_fd >= 0)
    {
     if (write(linear_fd, converted, n) != n)
      perror("write");
    }

   if (dev_fd >= 0)
    {
     if (write(dev_fd, converted, n) != n)
      perror("write");
    }

   free(converted);
  }
}
#else
#ifdef __sgi
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <errno.h>
#include <ctype.h>

#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/file.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <sys/signal.h>

#include <stropts.h>
#include <sys/ioctl.h>

#define TRUE 1
#define FALSE 0
#include <audio.h>
#include "proto.h"
#include "getargs.h"
#include "hplay.h"

#define SAMP_RATE 11025
long samp_rate = SAMP_RATE;

/* Audio Parameters */

int Verbose = FALSE;
 /* verbose messages */
int Immediate = FALSE;
 /* Should we hang waiting for device ? */

static int async = TRUE;


char *prog = "hplay";
char *Ifile;			  /* current filename */

static ALconfig alconf;
static ALport alprt;

static void audio_catch
PROTO((void))
{
 fprintf(stderr, "signal\n");
}

/* sgi system doesn't need to be opened */
static int audio_open
PROTO((void))
{
 alconf = ALnewconfig();
 ALsetwidth(alconf, AL_SAMPLE_16);
 ALsetchannels(alconf, AL_MONO);
 alprt = ALopenport("speak", "w", alconf);
 if (alprt == NULL)
  {
   fprintf(stderr, "cannot open audio port\n");
   ALfreeconfig(alconf);
   return 1;
  }
 return 0;
}

/* sgi system */
int
audio_init(int argc, char **argv)
{
 audio_open();
 return 0;
}

void
audio_term(void)
{
 /* on sgi systems, wait for port to complete */
 while (ALgetfilled(alprt) != 0)
  {
   sleep(1);
  }
 ALcloseport(alprt);
}


void
audio_play(int n, short *data)
{
 ALwritesamps(alprt, (void *) data, (long) n);
}


#else
/*****************************************************************/
/*****************************************************************/
/***                                                           ***/
/***                                                           ***/
/***    Play out a 20kHz file on the SPARC                     ***/
/***                                                           ***/
/***                                                           ***/
/***                H.F. Silverman 1/4/91                      ***/
/***    Modified:   H.F. Silverman 1/16/91 for amax parameter  ***/
/***    Modified:   A. Smith 2/14/91 for 8kHz for klatt synth  ***/
/***                                                           ***/
/*** Called: hplay(n,volume,amax,a)                            ***/
/***                                                           ***/
/***   int       n      -- No. of 8kHz pts.                    ***/
/***   int    device    -- 0 -> speaker, 1 -> Jack             ***/
/***                                                           ***/
/***                                                           ***/
/*****************************************************************/
/*****************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <errno.h>
#include <ctype.h>

#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/file.h>
#include <sys/filio.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <sys/signal.h>

#include <stropts.h>
#include <sys/ioctl.h>

#include <multimedia/libaudio.h>
#include <multimedia/audio_device.h>
#include <multimedia/ulaw2linear.h>
#include "proto.h"
#include "getargs.h"
#include "hplay.h"

#define SAMP_RATE 8000
long samp_rate = SAMP_RATE;

/* Audio Parameters */

int Verbose = FALSE;
 /* verbose messages */
int Immediate = FALSE;
 /* Should we hang waiting for device ? */

static int async = TRUE;

static Audio_hdr dev_header;
 /* audio header for device */
static int dev_fd = -1;
 /* file descriptor for audio device */
char *dev_file = "/dev/audio";

static Audio_hdr ulaw_header;
 /* audio header for file */
static int ulaw_fd = -1;
 /* file descriptor for .au ulaw file */
static char *ulaw_file = NULL;

static int linear_fd = -1;

#ifdef AUDIO_DEV_AMD
static int dev_kind = AUDIO_DEV_AMD;
#endif
 /* file descriptor for 16 bit linear file */
static char *linear_file = NULL;

char *prog = "hplay";
char *Ifile;			  /* current filename */

static void audio_catch
PROTO((void))
{
 fprintf(stderr, "signal\n");
}

static int audio_open
PROTO((void))
{
 /* Try it quickly, first */
 dev_fd = open(dev_file, O_WRONLY | O_NDELAY);
 if ((dev_fd < 0) && (errno == EBUSY))
  {
   if (Immediate)
    {
     fprintf(stderr, "%s: %s is busy\n", prog, dev_file);
     return 0;
    }
   if (Verbose)
    {
     fprintf(stderr, "%s: waiting for %s...", prog, dev_file);
     (void) fflush(stderr);
    }

   /* Now hang until it's open */

   dev_fd = open(dev_file, O_WRONLY);
   if (Verbose)
    fprintf(stderr, "%s\n", (dev_fd < 0) ? "" : "open");
  }
 if (dev_fd < 0)
  {
   fprintf(stderr, "%s: error opening ", prog);
   perror(dev_file);
   return 0;
  }
 else
  {
#ifdef AUDIO_DEV_AMD
   /* Get the device output encoding configuration */
   if (ioctl(dev_fd, AUDIO_GETDEV, &dev_kind))
    {
     /* Old releases of SunOs don't support the ioctl,
        but can only be run on old machines which have AMD device...
      */
     dev_kind = AUDIO_DEV_AMD;
    }
#endif
   if (audio_get_play_config(dev_fd, &dev_header) != AUDIO_SUCCESS)
    {
     fprintf(stderr, "%s: %s is not an audio device\n", prog, dev_file);
     close(dev_fd);
     dev_fd = -1;
     return 0;
    }
  }
 return 1;
}

int
audio_init(argc, argv)
int argc;
char *argv[];
{
 int rate_set = 0;
 int use_linear = 0;
 int use_audio = 1;
 double gain = -1.0;
 int headphone = 2;
 int speaker = 2;

 prog = argv[0];

 argc = getargs(argc, argv,
		"g", "%lg", &gain,
		"r", "%d", &rate_set,
		"h", NULL, &headphone,
		"s", NULL, &speaker,
		"a", NULL, &use_audio,
		"L", NULL, &use_linear,
		"u", "", &ulaw_file,
		"l", "", &linear_file,
		NULL);

 if (ulaw_file)
  {
   if (strcmp(ulaw_file, "-") == 0)
    {
     ulaw_fd = 1;		  /* stdout */
    }
   else
    {
     ulaw_fd = open(ulaw_file, O_WRONLY | O_CREAT | O_TRUNC, 0666);
     if (ulaw_fd < 0)
      perror(ulaw_file);
    }
  }

 if (linear_file)
  {
   if (strcmp(linear_file, "-") == 0)
    {
     linear_fd = 1 /* stdout */ ;
    }
   else
    {
     linear_fd = open(linear_file, O_WRONLY | O_CREAT | O_TRUNC, 0666);
     if (linear_fd < 0)
      perror(linear_file);
    }
  }

 if (rate_set)
  {
   samp_rate = rate_set;
  }

 if (use_audio && audio_open())
  {
   if (!rate_set)
    samp_rate = dev_header.sample_rate;

   if (rate_set || use_linear)
    {
     dev_header.sample_rate = samp_rate;
     if (samp_rate > 8000 || use_linear)
      {
       dev_header.encoding = AUDIO_ENCODING_LINEAR;
       dev_header.bytes_per_unit = 2;
      }
     if (audio_set_play_config(dev_fd, &dev_header) != AUDIO_SUCCESS)
      {
       fprintf(stderr, "%s : %s cannot accept sample rate of %ldHz\n",
	       prog, dev_file, samp_rate);
       close(dev_fd);
       dev_fd = -1;
      }
    }
  }
 if (dev_fd >= 0)
  {
   int myport = 0;
   if (gain >= 0.0)
    {
     int err = audio_set_play_gain(dev_fd, &gain);
     if (err != AUDIO_SUCCESS)
      {
       fprintf(stderr, "%s: could not set output volume for %s\n", prog, dev_file);
      }
    }

   if (headphone != 2)
    {
     if (headphone)
      myport |= AUDIO_HEADPHONE;
     else
      myport &= ~AUDIO_HEADPHONE;
    }

   if (speaker != 2)
    {
     if (speaker)
      myport |= AUDIO_SPEAKER;
     else
      myport &= ~AUDIO_SPEAKER;
    }

   if (myport != 0)
    audio_set_play_port(dev_fd, &myport);

   if (async)
    {
     int flag = 1;
     /* May need to use streams calls to send a SIGPOLL when write
        buffer is no longer full and use non-blocking writes, and
        manipluate our own buffer of unwritten data.

        However, at present just use FIOASYNC which means write
        returns as soon as it can queue the data (I think).
      */
     signal(SIGIO, audio_catch);
     ioctl(dev_fd, FIOASYNC, &flag);
    }
  }
 if (ulaw_fd >= 0)
  {
   ulaw_header.sample_rate = samp_rate;
   if (samp_rate > 8000)
    {
     ulaw_header.encoding = AUDIO_ENCODING_LINEAR;
     ulaw_header.bytes_per_unit = 2;
    }
   else
    {
     ulaw_header.encoding = AUDIO_ENCODING_ULAW;
     ulaw_header.bytes_per_unit = 1;
    }
   ulaw_header.samples_per_unit = 1;
   ulaw_header.channels = 1;
   ulaw_header.data_size = AUDIO_UNKNOWN_SIZE;

   /* Write header - note that data_size is unknown at this stage,
      so we set it to AUDIO_UNKNOWN_SIZE (AFEB);
      if all goes well we will lseek back and do this again
      in audio_term()
    */
   audio_write_filehdr(ulaw_fd, &ulaw_header, NULL, 0);

   /* reset the header info, so we can simply add to it */
   ulaw_header.data_size = 0;
  }
 return argc;
}

void
audio_term()
{
 /* Close audio system  */
 if (dev_fd >= 0)
  {
   audio_drain(dev_fd, FALSE);
   close(dev_fd);
   dev_fd = -1;
   if (async)
    signal(SIGPOLL, SIG_DFL);
  }

 /* Finish ulaw file */
 if (ulaw_fd >= 0)
  {
   off_t here = lseek(ulaw_fd, 0L, SEEK_CUR);
   if (here >= 0)
    {
     /* can seek this file - truncate it */
     ftruncate(ulaw_fd, here);

     /* Now go back and overwite header with actual size */
     if (lseek(ulaw_fd, 0L, SEEK_SET) == 0)
      {
       audio_write_filehdr(ulaw_fd, &ulaw_header, NULL, 0);
      }
    }
   close(ulaw_fd);
   ulaw_fd = -1;
  }

 /* Finish linear file */
 if (linear_fd >= 0)
  {
   ftruncate(linear_fd, lseek(linear_fd, 0L, SEEK_CUR));
   close(linear_fd);
   linear_fd = -1;
  }
}

void
audio_play(n, data)
int n;
short *data;
{
 if (n > 0)
  {
   if (linear_fd >= 0)
    {
     unsigned size = n * sizeof(short);
     if (write(linear_fd, data, n * sizeof(short)) != size)
            perror("write");
    }

   if (dev_fd >= 0 && dev_header.encoding == AUDIO_ENCODING_LINEAR)
    {
     unsigned size = n * sizeof(short);
     if (write(dev_fd, data, n * sizeof(short)) != size)
            perror("write");
    }

   if (ulaw_fd >= 0 && ulaw_header.encoding == AUDIO_ENCODING_LINEAR)
    {
     unsigned size = n * sizeof(short);
     if (write(ulaw_fd, data, n * sizeof(short)) != size)
            perror("write");
     else
      ulaw_header.data_size += size;
    }

   if ((dev_fd >= 0 && dev_header.encoding == AUDIO_ENCODING_ULAW) ||
       (ulaw_fd >= 0 && ulaw_header.encoding == AUDIO_ENCODING_ULAW))
    {
     unsigned char *plabuf = (unsigned char *) malloc(n);
     if (plabuf)
      {
       int w;
       unsigned char *p = plabuf;
       unsigned char *e = p + n;
       while (p < e)
	{
	 *p++ = audio_s2u(*data++);
	}
       if (dev_fd >= 0 && dev_header.encoding == AUDIO_ENCODING_ULAW)
	{
	 if ((w = write(dev_fd, plabuf, n)) != n)
	  {
	   if (w == -1)
	    perror("audio");
	   else
	    {
	     fprintf(stderr, "Writing %u, only wrote %u\n", n, w);
	    }
	   abort();
	  }
	}
       if (ulaw_fd >= 0 && ulaw_header.encoding == AUDIO_ENCODING_ULAW)
	{
	 if (write(ulaw_fd, plabuf, n) != n)
	  perror(ulaw_file);
	 else
	  ulaw_header.data_size += n;
	}
       free(plabuf);
      }
     else
      {
       fprintf(stderr, "%s : No memory for ulaw data\n", prog);
      }
    }
  }
}
#endif
#endif
#endif
