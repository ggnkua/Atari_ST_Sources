/*
 * These routines show how to call Mac routines from ATARI code
 * without the use of XCMD modules (which can only be used if you
 * have a Macintosh development system, like CodeWarrior).
 *
 * However, to be able to use Mac functions, you need the
 * programming documention from Apple, like the Inside Mac
 * books, that are also available on CD.
 *
 * Set TABs to 4 */

#include <stddef.h>
#include <string.h>
#include "MGMC_API.H"
#include "MAC_API.H"
#include "SND_DEMO.H"


/*
 * basic sound types, taken from Mac's header file "Sound.h"
 */

#define		myQLength	128

enum {
	squareWaveSynth	= 1,
	waveTableSynth	= 3,
	sampledSynth	= 5
};

enum {
	initMono	= 0x0080
};

enum {
	quietCmd		= 3,
	freqDurationCmd	= 40
};

typedef unsigned long Fixed;
typedef short OSErr;

typedef struct {
	unsigned short		cmd;
	short				param1;
	long				param2;
} SndCommand;

typedef struct {
	Fixed				scStartTime;
	Fixed				scEndTime;
	Fixed				scCurrentTime;
	Boolean				scChannelBusy;
	Boolean				scChannelDisposed;
	Boolean				scChannelPaused;
	Boolean				scUnused;
	unsigned long		scChannelAttributes;
	long				scCPULoad;
} SCStatus;

typedef struct SndChannel	*SndChannelPtr;

typedef void pascal (*SndCallBackProcPtr) (SndChannelPtr chan, SndCommand *cmd);

typedef struct SndChannel {
	SndChannelPtr		nextChan;
	Ptr					firstMod;
	SndCallBackProcPtr	callBack;
	long				userInfo;
	long				wait;
	SndCommand			cmdInProgress;
	short				flags;
	short				qLength;
	short				qHead;
	short				qTail;
	SndCommand			queue[myQLength];
} SndChannel;

/*
 * Mac OS function definitions
 */
extern void TempleMon (void) 0x4AFC;	/* this calls the ATARI debugger when in ATARI mode */extern void MacsBug (void) 0xA9FF;		/* this calls the Mac debugger when in Mac mode */extern OSErr pascal SndNewChannel (SndChannelPtr *chan, short synth, long init, SndCallBackProcPtr userRoutine) 0xA807;extern OSErr pascal SndDisposeChannel (SndChannelPtr chan, Boolean quietNow) 0xA801;
extern OSErr pascal SndDoCommand (SndChannelPtr chan, SndCommand *cmd, Boolean noWait) 0xA803;

/*
 * The ATARI code to call the Mac OS functions follows here...
 */
static void addCommand (SndChannelPtr chan, short cmd, short param1, long param2)
/*
 * In case of cmd == freqDurationCmd:
 *   param1: duration, 2000 == 1 second.
 *   param2: frequency as MIDI value, 60 == middle C, +/-12 == one interval.
 */
{
	SndCommand snd;
	snd.cmd = cmd;
	snd.param1 = param1;
	snd.param2 = param2;
	SndDoCommand (chan, &snd, true);
}

static OSErr gResult;

static void cdecl playAMacSound_sub (void)
/* subroutine of PlayAMacSound, running in Mac mode */
{
	OSErr 				err;
	SndChannelPtr		chan;
	static SndChannel	chanBuf;
	
	/* Here we could invoke the Mac debugger by calling: MacsBug(); */
	
	memset (&chanBuf, 0, sizeof (chanBuf));
	chanBuf.qLength = myQLength;
	chan = &chanBuf;
	err = SndNewChannel (&chan, squareWaveSynth, initMono, (SndCallBackProcPtr)NULL);
	if (!err) {
		/*
		 * now generate two square ware sounds.
		 */
		addCommand (chan, freqDurationCmd, 1000, 60);
		addCommand (chan, freqDurationCmd, 1000, 72);
		addCommand (chan, quietCmd, 0, 0);
		
		/* That's it. Finish now. */
		SndDisposeChannel (chan, false);	/* false: waits until sound has finished playing */
	}
	gResult = err;
}


short PlayAMacSound (void)
/* plays a sound using Mac OS funtions. To be called from ATARI mode */
{
	ExecuteMacFunction (playAMacSound_sub);
	return gResult;}

/* EOF */
