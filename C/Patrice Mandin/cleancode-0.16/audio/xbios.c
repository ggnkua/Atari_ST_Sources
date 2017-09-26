/*
	Atari audio demo, using Xbios

	Copyright (C) 2002	Patrice Mandin

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include <stdio.h>
#include <string.h>

#include <mint/osbind.h>
#include <mint/cookie.h>
#include <mint/falcon.h>
#include <mint/sysvars.h>

#include "param.h"
#include "mfp.h"
#include "mxalloc.h"

#include "mcsn.h"
#include "gsxb.h"
#include "stfa.h"
#include "calib_it.h"

/*--- Defines ---*/

#define SCANCODE_ESC	0x01

/* Master clocks for replay frequencies */
#define MASTERCLOCK_MFP		2457600
#define MASTERCLOCK_STE		8010666		/* Not sure of this one */
#define MASTERCLOCK_TT		16107953	/* Not sure of this one */
#define MASTERCLOCK_FALCON1	25175000
#define MASTERCLOCK_FALCON2	32000000	/* Only usable for DSP56K */
#define MASTERCLOCK_FALCONEXT	-1		/* Clock on DSP56K port, unknown */
#define MASTERCLOCK_MILAN1	22579200	/* Standard clock for 44.1 Khz */
#define MASTERCLOCK_MILAN2	24576000	/* Standard clock for 48 Khz */

/* Master clock predivisors */
#define MASTERPREDIV_MFP1	4
#define MASTERPREDIV_MFP2	10
#define MASTERPREDIV_MFP3	16
#define MASTERPREDIV_MFP4	50
#define MASTERPREDIV_MFP5	64
#define MASTERPREDIV_MFP6	100
#define MASTERPREDIV_MFP7	200
#define MASTERPREDIV_STE	160
#define MASTERPREDIV_TT		320
#define MASTERPREDIV_FALCON	256
#define MASTERPREDIV_MILAN	256

/* Cookies */
#define C_MgSn	0x4d67536eL	/* MagicMac sound driver (Didier Mequignon) */

/* _MCH cookie (values>>16) */
enum {
	MCH_ST=0,
	MCH_STE,
	MCH_TT,
	MCH_F30
};

/* Calibration of external clock */
#define LENGTH_CALIB 441
#define CALIB_FREQ1	44100
#define CALIB_FREQ2	48000

/*--- Types ---*/

typedef struct {
	int prediv;
	int count;
} mfpprediv_t;

/*--- Variables ---*/

unsigned long cookie_mch;
unsigned long cookie_snd;
unsigned long cookie_mcsn;
unsigned long cookie_mgsn;
unsigned long cookie_gsxb;
unsigned long cookie_stfa;

int CalibDone_gsxb;

void (*DisplayInfos)(void);

/*--- Functions prototypes ---*/

void DisplayInfos_SND(void);
void DisplayInfosSTFA(void);
void DisplaySampleFormatsGSXB(void);
void DisplayInfosMilanBlaster(void);
void DisplayInfosGSXB(void);
void DisplayInfosXsound(void);

void CalibInterrupt_gsxb(void);
unsigned long CalibrateExternalClock(int check_dsp);

/*--- Functions ---*/

int main(int argc, char **argv)
{
	unsigned long key_pressed;
	unsigned char scancode;

	unsigned long cookie_dummy;

	PAR_TestRedirect(argc, argv);
	if (output_to_file) {
		PAR_RedirectStdout();
	}

	/*--- Machine type ---*/
	fprintf(output_handle, "_MCH cookie: ");
	if (Getcookie(C__MCH, &cookie_mch) != C_FOUND) {
		fprintf(output_handle, "non present\n");
		cookie_mch = MCH_ST<<16;
	} else {
		fprintf(output_handle, "present\n");
	}

	/*--- Atari audio ---*/
	fprintf(output_handle, "_SND cookie: ");
	if (Getcookie(C__SND, &cookie_snd) != C_FOUND) {
		fprintf(output_handle, "non present\n");
		cookie_snd = SND_PSG;
	} else {
		fprintf(output_handle, "present\n");
	}
	if (cookie_snd & SND_PSG) fprintf(output_handle, " YM2149 soundchip\n");
	if (cookie_snd & SND_8BIT) fprintf(output_handle, " 8 bits DMA\n");
	if (cookie_snd & SND_16BIT) fprintf(output_handle, " Xbios functions\n");
	if (cookie_snd & SND_DSP) fprintf(output_handle, " DSP 56k\n");
	if (cookie_snd & SND_MATRIX) fprintf(output_handle, " 16 bits CODEC, connection matrix\n");
	if (cookie_snd & SND_GSXB) fprintf(output_handle, " GSXB audio\n");

	/*--- Sound Treiber Für Atari ---*/
	/* Available with STFA driver */
	if (Getcookie(C_STFA, &cookie_dummy) == C_FOUND) {
		cookie_stfa = cookie_dummy;
	} else {
		cookie_stfa = 0;
	}
	fprintf(output_handle, "STFA cookie: ");
	if (cookie_stfa) {
		fprintf(output_handle, "present\n");
	} else {
		fprintf(output_handle, "non present\n");
	}

	/*--- MacSound ---*/
	/* Available with MilanBlaster driver */
	/* Available with MacSound driver */
	/* Available with MagicMac sound driver */
	/* Available with Xsound driver */
	if (Getcookie(C_McSn, &cookie_dummy) == C_FOUND) {
		cookie_mcsn = cookie_dummy;
	} else {
		cookie_mcsn = 0;
	}
	fprintf(output_handle, "McSn cookie: ");
	if (cookie_mcsn) {
		fprintf(output_handle, "present\n");
	} else {
		fprintf(output_handle, "non present\n");
	}

	/*--- MagicMac Sound driver ---*/
	/* Available with MagicMac sound driver */
	if (Getcookie(C_MgSn, &cookie_dummy) == C_FOUND) {
		cookie_mgsn = cookie_dummy;
	} else {
		cookie_mgsn = 0;
	}
	fprintf(output_handle, "MgSn cookie: ");
	if (cookie_mgsn) {
		fprintf(output_handle, "present\n");
	} else {
		fprintf(output_handle, "non present\n");
	}

	/*--- GSXB driver ---*/
	/* Available with MagicMac sound driver */
	cookie_gsxb = (Getcookie(C_GSXB, &cookie_dummy) == C_FOUND);
	fprintf(output_handle, "GSXB cookie: ");
	if (cookie_gsxb) {
		fprintf(output_handle, "present\n");
	} else {
		fprintf(output_handle, "non present\n");
	}

	/*--- Select the best audio driver ---*/
	DisplayInfos = DisplayInfos_SND;

	if (cookie_snd & SND_16BIT) {
		if ((cookie_snd & SND_GSXB) && cookie_gsxb) {
			DisplayInfos = DisplayInfosGSXB;
		} else if (cookie_mcsn) {
			DisplayInfos = DisplayInfosMilanBlaster;
		}
	} else {
		if (cookie_stfa) {
			DisplayInfos = DisplayInfosSTFA;
		} else if (cookie_mcsn) {
			DisplayInfos = DisplayInfosXsound;
		}
	}

	DisplayInfos();

	if (!output_to_file) {
		/*--- Wait till ESC key pressed ---*/
		key_pressed = scancode = 0;
		printf("Press ESC to quit\n");
		while (scancode != SCANCODE_ESC) {
			/* Read key pressed, if needed */
			if (Cconis()) {
				key_pressed = Cnecin();
				scancode = (key_pressed >>16) & 0xff;
			}
		}
	} else {
		fclose(output_handle);
	}
}

/* Count 100 interrupts */
void CalibInterrupt_gsxb(void)
{
	/* We are in supervisor mode here */

	CalibDone_gsxb++;
	if (CalibDone_gsxb>=100) {
		CalibDone=1;
	}
}

unsigned long CalibrateExternalClock(int check_dsp)
{
	char *buffer;
	unsigned long CurSystemTic, LengthTic1, LengthTic2;
	void *oldstack;
	unsigned long masterclock;
	int CalibDonePrev_gsxb;

	fprintf(output_handle, " Calibration of external clock\n");

	if (!Locksnd()) {
		fprintf(output_handle, "  XBIOS audio locked by another program\n");
		return 0;
	}

	if (check_dsp) {
		if ((cookie_snd & SND_DSP)==0) {
			fprintf(output_handle, "  No DSP port on this machine\n");
			Unlocksnd();
			return 0;
		}
	}

	/* Play a sound using external clock, measure its time length */
	buffer = Atari_SysMalloc(LENGTH_CALIB, MX_STRAM);
	if (buffer==NULL) {
		fprintf(output_handle, "  Can not allocate %d bytes in ST-RAM\n", LENGTH_CALIB);
		Unlocksnd();
		return 0;
	}
	memset(buffer, 0, LENGTH_CALIB);

	fprintf(output_handle, "  Buffer length is %d bytes\n", LENGTH_CALIB);
/*
	8 bits mono, 100*441 samples
	44.1 KHz	-> 1000 ms
	48 KHz		-> 918.75 ms
*/
	/* Init audio DMA */
	Buffoper(0);
	Settracks(0,0);
	Setmontracks(0);
	Setmode(MONO8);
	Setbuffer(0, buffer, buffer+LENGTH_CALIB);
	Devconnect(DMAPLAY, DAC, CLKEXT, 1, 1);

	if ((cookie_snd & SND_GSXB) && (cookie_snd & SND_16BIT)) {
		if (cookie_mcsn && !cookie_gsxb) {
			fprintf(output_handle, "  No interrupt possible with MilanBlaster\n");
			Unlocksnd();
			Mfree(buffer);
			return 0;
		}

		CalibDone_gsxb = 0;
		if (NSetinterrupt(2, SI_PLAY, CalibInterrupt_gsxb)<0) {
			fprintf(output_handle, "  Unable to setup interrupt vector\n");
			Unlocksnd();
			Mfree(buffer);
			return 0;
		}
	} else {
		Setinterrupt(SI_TIMERA, SI_PLAY);
		Jdisint(MFP_DMASOUND);
		Xbtimer(XB_TIMERA, 8, 100, CalibInterrupt);
		Jenabint(MFP_DMASOUND);
	}

	CalibDone=0;
	oldstack=(void *)Super(0);
	CurSystemTic=*((volatile long *)_hz_200);
	Super(oldstack);

	/* Play the sample */
	fprintf(output_handle, "  Calibrating (duration: 1 sec)...");fflush(stdout);
	CalibDonePrev_gsxb=0;
	Buffoper(SB_PLA_ENA|SB_PLA_RPT);

	/* Wait till finished */
	while (CalibDone==0) {
		if (CalibDone_gsxb!=CalibDonePrev_gsxb) {
			CalibDonePrev_gsxb=CalibDone_gsxb;
		}
	}

	/* Disable our interrupt */
	Buffoper(0);
	Jdisint(MFP_DMASOUND);
	fprintf(output_handle, "done\n");

	Unlocksnd();
	Mfree(buffer);

	fprintf(output_handle, "  Time: %d ms\n",CalibSystemTic-CurSystemTic);
	fprintf(output_handle, "  Replay frequency: %d Hz\n",(LENGTH_CALIB*1000*100)/(CalibSystemTic-CurSystemTic));
	LengthTic1 = (LENGTH_CALIB*1000*100)/CALIB_FREQ1;
	LengthTic2 = (LENGTH_CALIB*1000*100)/CALIB_FREQ2;

	if (CalibSystemTic-CurSystemTic>((LengthTic2+LengthTic1)>>1)) {
		/* 44.1 KHz */
		masterclock=MASTERCLOCK_MILAN1;
	} else {
		/* 48 KHz */
		masterclock=MASTERCLOCK_MILAN2;
	}

	return masterclock;
}

void DisplayInfos_SND(void)
{
	unsigned long masterclock;
	unsigned long masterclock_prediv;
	int i, curfreq;
	
	fprintf(output_handle, "\nStandard driver\n");
	fprintf(output_handle, "Available frequencies:\n");
	curfreq=0;
	switch(cookie_mch>>16) {
		case MCH_STE:
			masterclock = MASTERCLOCK_STE;
			masterclock_prediv = MASTERPREDIV_STE;
			fprintf(output_handle, " Master clock = %d Hz\n ", masterclock);
			for (i=0;i<4;i++) {
				fprintf(output_handle, "%d\t",masterclock/(masterclock_prediv*(1<<i)));
			}
			fprintf(output_handle, "\n");
			break;
		case MCH_TT:
			masterclock = MASTERCLOCK_TT;
			masterclock_prediv = MASTERPREDIV_TT;
			fprintf(output_handle, " Master clock = %d Hz\n ", masterclock);
			for (i=0;i<4;i++) {
				fprintf(output_handle, "%d\t",masterclock/(masterclock_prediv*(1<<i)));
			}
			fprintf(output_handle, "\n");
			break;
		case MCH_F30:
			fprintf(output_handle, " Internal clock 1: %d Hz\n", MASTERCLOCK_FALCON1);
			masterclock = MASTERCLOCK_FALCON1;
			masterclock_prediv = MASTERPREDIV_FALCON;
			for (i=1;i<12;i++) {
				if ((i!=6) && (i!=8) && (i!=10)) {
					if ((curfreq & 3)==0) {
						fprintf(output_handle, "  ");
					}
					fprintf(output_handle, "%d\t",masterclock/(masterclock_prediv*(i+1)));
					if ((curfreq & 3)==3) {
						fprintf(output_handle, "\n");
					}
					curfreq++;
				}
			}

			if (cookie_snd & SND_DSP) {
				fprintf(output_handle, " Internal clock 2: %d Hz\n", MASTERCLOCK_FALCON2);
				fprintf(output_handle, "  Only for DSP56K\n");
			}

			masterclock=CalibrateExternalClock(1);
			if (masterclock>0) {
				fprintf(output_handle, " External clock selected: %d\n", masterclock);
				for (i=1;i<12;i++) {
					if ((i!=6) && (i!=8) && (i!=10)) {
						if ((curfreq & 3)==0) {
							fprintf(output_handle, "  ");
						}
						fprintf(output_handle, "%d\t",masterclock/(masterclock_prediv*(i+1)));
						if ((curfreq & 3)==3) {
							fprintf(output_handle, "\n");
						}
						curfreq++;
					}
				}
			}
			break;
	}

	fprintf(output_handle, "Sample formats:\n");
	fprintf(output_handle, " Signed samples only (-n..+n)\n");
	fprintf(output_handle, " 8 bits, mono and stereo\n");
	if (cookie_snd & SND_16BIT) {
		fprintf(output_handle, " 16 bits, stereo only, big endian only\n");
	}
}

void DisplayInfosSTFA(void)
{
	int i, curfreq;
	unsigned long masterclock;
	unsigned long masterclock_prediv;

	mfpprediv_t freqtables[16]={
		{MASTERPREDIV_MFP4,1},
		{MASTERPREDIV_MFP1,14},
		{MASTERPREDIV_MFP1,19},
		{MASTERPREDIV_MFP3,5},

		{MASTERPREDIV_MFP6,1},
		{MASTERPREDIV_MFP3,7},
		{MASTERPREDIV_MFP1,31},
		{MASTERPREDIV_MFP4,3},

		{MASTERPREDIV_MFP1,41},
		{MASTERPREDIV_MFP1,49},
		{MASTERPREDIV_MFP3,14},
		{MASTERPREDIV_MFP4,5},

		{MASTERPREDIV_MFP6,3},
		{MASTERPREDIV_MFP1,82},
		{MASTERPREDIV_MFP1,98},
		{MASTERPREDIV_MFP1,123}
	};

	fprintf(output_handle, "\nSTFA driver\n");
	fprintf(output_handle, "Available frequencies:\n");
	curfreq=0;
	switch(cookie_mch>>16) {
		case MCH_ST:
			masterclock = MASTERCLOCK_MFP;
			fprintf(output_handle, " Master clock = %d Hz\n", masterclock);
			for (i=0;i<16;i++,curfreq++) {
				if ((curfreq & 3)==0) {
					fprintf(output_handle, " ");
				}
				masterclock_prediv = freqtables[i].prediv;
				fprintf(output_handle, "%d\t",masterclock/(masterclock_prediv*freqtables[i].count));
				if ((curfreq & 3)==3) {
					fprintf(output_handle, "\n");
				}
			}
			fprintf(output_handle, "Sample formats:\n");
			fprintf(output_handle, " Signed (-n..+n) and unsigned samples (0..n)\n");
			fprintf(output_handle, " 8 bits and 16 bits\n");
			fprintf(output_handle, " mono and stereo\n");
			fprintf(output_handle, " big- and little-endian\n");
			break;
		case MCH_STE:
			masterclock = MASTERCLOCK_STE;
			masterclock_prediv = MASTERPREDIV_STE;
			fprintf(output_handle, " Master clock = %d Hz\n ", masterclock);
			for (i=0;i<4;i++,curfreq++) {
				fprintf(output_handle, "%d\t",masterclock/(masterclock_prediv*(1<<i)));
			}
			fprintf(output_handle, "\nSample formats:\n");
			fprintf(output_handle, " Signed samples only (-n..+n)\n");
			fprintf(output_handle, " 8 bits, mono and stereo\n");
			break;
		case MCH_TT:
			masterclock = MASTERCLOCK_TT;
			masterclock_prediv = MASTERPREDIV_TT;
			fprintf(output_handle, " Master clock = %d Hz\n ", masterclock);
			for (i=0;i<4;i++) {
				fprintf(output_handle, "%d\t",masterclock/(masterclock_prediv*(1<<i)));
			}
			fprintf(output_handle, "\nSample formats:\n");
			fprintf(output_handle, " Signed samples only (-n..+n)\n");
			fprintf(output_handle, " 8 bits, mono and stereo\n");
			break;
	}
}

void DisplaySampleFormatsGSXB(void)
{
	unsigned long formats, sign;
	
	fprintf(output_handle, "Available sample formats:\n");
	formats=Sndstatus(SND_QUERYFORMATS);

	if (formats & SND_FORMAT8) {
		fprintf(output_handle, " 8 bits");
		sign=Sndstatus(SND_QUERY8BIT);
		if (sign & SND_FORMATSIGNED) {
			fprintf(output_handle, ", signed");
		}		
		if (sign & SND_FORMATUNSIGNED) {
			fprintf(output_handle, ", unsigned");
		}		
		fprintf(output_handle, ", mono and stereo\n");
	}

	if (formats & SND_FORMAT16) {
		fprintf(output_handle, " 16 bits");
		sign=Sndstatus(SND_QUERY16BIT);
		if (sign & SND_FORMATSIGNED) {
			fprintf(output_handle, ", signed");
		}		
		if (sign & SND_FORMATUNSIGNED) {
			fprintf(output_handle, ", unsigned");
		}		
		if (sign & SND_FORMATBIGENDIAN) {
			fprintf(output_handle, ", big-endian");
		}		
		if (sign & SND_FORMATLITTLEENDIAN) {
			fprintf(output_handle, ", little-endian");
		}		
		fprintf(output_handle, ", mono and stereo\n");
	}

	/* No need to query for 24 and 32 bits formats */
}

void DisplayInfosMilanBlaster(void)
{
	int i, curfreq;
	unsigned long masterclock;
	unsigned long masterclock_prediv;
	cookie_mcsn_t *cookie;

	fprintf(output_handle, "\nMacSound/MilanBlaster driver\n\n");

	cookie = (cookie_mcsn_t *)cookie_mcsn;
	if (cookie!=NULL) {
		fprintf(output_handle, "MacSound cookie:\n");
		if (cookie->pint) {
			fprintf(output_handle, " Interrupt at end of replay\n");
		}
		fprintf(output_handle, " External clock: %d Hz\n",cookie->res1);
		fprintf(output_handle, " Current replay frequency: %d\n\n",Soundcmd(SETSMPFREQ, 0));
	}

	fprintf(output_handle, "Available frequencies:\n");
	switch(Gpio(1,0) & 1) {
		case 0:
			masterclock = MASTERCLOCK_MILAN1;
			masterclock_prediv = MASTERPREDIV_MILAN;
			break;
		case 1:
			masterclock = MASTERCLOCK_MILAN2;
			masterclock_prediv = MASTERPREDIV_MILAN;
			break;
	}

	fprintf(output_handle, " Master clock = %d Hz\n", masterclock);
	curfreq=0;
	for (i=1;i<12;i++) {
		if ((i!=6) && (i!=8) && (i!=10)) {
			if ((curfreq & 3)==0) {
				fprintf(output_handle, " ");
			}
			fprintf(output_handle, "%d\t",masterclock/(masterclock_prediv*(i+1)));
			if ((curfreq & 3)==3) {
				fprintf(output_handle, "\n");
			}
			curfreq++;
		}
	}
	fprintf(output_handle, "\n");
/*
	masterclock=CalibrateExternalClock(0);
	if (masterclock>0) {
		fprintf(output_handle, " Master clock found: %d\n", masterclock);
	}
*/
	DisplaySampleFormatsGSXB();
}

void DisplayInfosGSXB(void)
{
	int i, curfreq;
	unsigned long masterclock;
	unsigned long masterclock_prediv;
	cookie_mcsn_t *cookie;

	fprintf(output_handle, "\nGSXB driver\n\n");

	masterclock = MASTERCLOCK_MILAN1;
	masterclock_prediv = MASTERPREDIV_MILAN;

	cookie = (cookie_mcsn_t *) cookie_mcsn;
	if (cookie!=NULL) {
		fprintf(output_handle, "MacSound cookie:\n");
		if (cookie->pint) {
			fprintf(output_handle, " Interrupt at end of replay\n");
		}
		fprintf(output_handle, " External clock: %d Hz\n",cookie->res1);
		if (cookie->res1 != 0) {
			masterclock = cookie->res1;
		}
		fprintf(output_handle, " Current replay frequency: %d\n\n",Soundcmd(SETSMPFREQ, 0));
	}

	fprintf(output_handle, "GSXB current replay frequency: %d\n",Soundcmd(SETRATE, -1));
	fprintf(output_handle, "Available frequencies:\n");
	fprintf(output_handle, " Master clock = %d Hz\n", masterclock);

	curfreq=0;
	for (i=1;i<12;i++) {
		if ((i!=6) && (i!=8) && (i!=10)) {
			if ((curfreq & 3)==0) {
				fprintf(output_handle, " ");
			}
			fprintf(output_handle, "%d\t",masterclock/(masterclock_prediv*(i+1)));
			if ((curfreq & 3)==3) {
				fprintf(output_handle, "\n");
			}
			curfreq++;
		}
	}
	fprintf(output_handle, "\n");
/*
	masterclock=CalibrateExternalClock(0);
	if (masterclock>0) {
		fprintf(output_handle, " Master clock found: %d\n", masterclock);
	}
*/
	DisplaySampleFormatsGSXB();
}

void DisplayInfosXsound(void)
{
	int i, curfreq;
	unsigned long masterclock;
	unsigned long masterclock_prediv;

	mfpprediv_t freqtables[15]={
		{MASTERPREDIV_MFP4,1},
		{MASTERPREDIV_MFP1,19},
		{MASTERPREDIV_MFP6,1},

		{MASTERPREDIV_MFP1,31},
		{MASTERPREDIV_MFP1,38},
		{MASTERPREDIV_MFP1,44},

		{MASTERPREDIV_MFP1,50},
		{MASTERPREDIV_MFP1,56},
		{MASTERPREDIV_MFP1,63},

		{MASTERPREDIV_MFP1,69},
		{MASTERPREDIV_MFP1,75},
		{MASTERPREDIV_MFP1,81},

		{MASTERPREDIV_MFP1,86},
		{MASTERPREDIV_MFP1,92},
		{MASTERPREDIV_MFP1,99},
	};

	fprintf(output_handle, "\nX-Sound driver\n");
	fprintf(output_handle, "Available frequencies:\n");
	curfreq=0;
	switch(cookie_mch>>16) {
		case MCH_ST:
			masterclock = MASTERCLOCK_MFP;
			fprintf(output_handle, " Master clock = %d Hz\n", masterclock);
			for (i=0;i<15;i++,curfreq++) {
				if ((curfreq & 3)==0) {
					fprintf(output_handle, " ");
				}
				masterclock_prediv = freqtables[i].prediv;
				fprintf(output_handle, "%d\t",masterclock/(masterclock_prediv*freqtables[i].count));
				if ((curfreq & 3)==3) {
					fprintf(output_handle, "\n");
				}
			}
			fprintf(output_handle, "\nSample formats:\n");
			fprintf(output_handle, " Signed samples only (-n..+n)\n");
			fprintf(output_handle, " 8 bits, mono and stereo\n");
			fprintf(output_handle, " 16 bits, stereo only, big endian only\n");
			break;
		case MCH_STE:
			masterclock = MASTERCLOCK_STE;
			masterclock_prediv = MASTERPREDIV_STE;
			fprintf(output_handle, " Master clock = %d Hz\n ", masterclock);
			for (i=0;i<4;i++,curfreq++) {
				fprintf(output_handle, "%d\t",masterclock/(masterclock_prediv*(1<<i)));
			}
			fprintf(output_handle, "\nSample formats:\n");
			fprintf(output_handle, " Signed samples only (-n..+n)\n");
			fprintf(output_handle, " 8 bits, mono and stereo\n");
			break;
		case MCH_TT:
			masterclock = MASTERCLOCK_TT;
			masterclock_prediv = MASTERPREDIV_TT;
			fprintf(output_handle, " Master clock = %d Hz\n ", masterclock);
			for (i=0;i<4;i++) {
				fprintf(output_handle, "%d\t",masterclock/(masterclock_prediv*(1<<i)));
			}
			fprintf(output_handle, "\nSample formats:\n");
			fprintf(output_handle, " Signed samples only (-n..+n)\n");
			fprintf(output_handle, " 8 bits, mono and stereo\n");
			break;
	}
}
