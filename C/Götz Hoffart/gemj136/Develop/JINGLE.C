/* JINGLE */
/* hardwarenahes Modul ohne OberflÑchenfunktionalitÑt fÅr GEMJing */
/* (c) und alle Rechte bei Gîtz Hoffart, Rheinstetten */

#define NDEBUG 1
#include <tos.h>
#include <assert.h>
#include <portabn.h>
#include <string.h>
#include <aes.h>
#include <stdio.h>
#include <ext.h>

#include "jinglein.h"

#include "error.h"
#include "SAMROUTS\samrouts.h"
#include "snd.h"
#include "jingle.h"
#include "data.h"

#define Macintosh 1
#define Falcon		2
#define WeirdMac	3

BOOLEAN totalbreak;
BOOLEAN sample_interrupt = FALSE;
extern BOOLEAN quit;

extern BOOLEAN	MultiTOS;
extern BOOLEAN	MagiC;
extern BOOLEAN	MagiCMac;


LOCAL VOID		flip_word (REG BYTE *adr);
LOCAL VOID		flip_long (REG WORD *adr);
LOCAL WORD		main(VOID);
LOCAL WORD		flc_play_sam(NEWDEF *new);
LOCAL LONG		FileLen(CONST BYTE *fname);
LOCAL BOOLEAN	IsThereMxalloc(VOID);
LOCAL VOID		*OwnMalloc(CONST LONG amount, CONST WORD typ);
LOCAL VOID		OwnMfree(CONST VOID *adr);
LOCAL BOOLEAN	Laden(CONST BYTE *fname, BYTE *addr, CONST LONG len);

/* Import aus 16to8.c: */
unsigned char *to_eight(unsigned char *start,unsigned char *end,int unsign);

LOCAL WORD	recognize_format(NEWDEF *new, LONG *adr, LONG len);
LOCAL WORD	detect_hardware(NEWDEF *new);
LOCAL WORD	play_sample(NEWDEF *new);
LOCAL LONG	get_cookiejar(VOID);
LOCAL	VOID	warte(NEWDEF *new);
LOCAL WORD	convert_alaw_linear(NEWDEF* new);
LOCAL WORD	convert_mulaw_linear(NEWDEF *new);

/************************************************************************/

WORD spiele_sample(NEWDEF *new)
{
	BOOLEAN ret;
	WORD spiele_ret;
	LONG len;
	LONG *adr;

	sample_interrupt = FALSE;

	ret = detect_hardware(new);
	if (ret != TRUE)
		return RT_WRONG_HARDWARE;
	
	if (new->file)
	{
		len = FileLen(new->file);
		adr = OwnMalloc(len, MLC_ST_RAM);
	
		if (len == 0)
			return RT_NO_FILE;
		if (adr == NULL)
			return RT_NO_MEM;
	
		if (Laden(new->file, (BYTE*) adr, len) != TRUE)
		{
			OwnMfree(adr);
			return RT_NO_FILE;
		}
	}
	else if (new->memoryplay != NULL)
	{
		adr = (LONG *) new->memoryplay;
		len = new->memoryplay_len;
	}
	else
		return RT_NO_FILE;

	ret = recognize_format(new, adr, len);
	if (ret != TRUE)
	{
		if (new->memoryplay == NULL)
			OwnMfree(adr);
		return ret;
	}

	totalbreak = FALSE;
/* x mal wiederholen mit y Sekunden Pause dazwischen */
	while (0==0)
	{
		spiele_ret = play_sample(new);
		new->repeatrate--;
		if (new->repeatrate == 0)
			break;
		if (totalbreak == TRUE)
			break;
		warte(new);
	}

	if (new->memoryplay == NULL)
		OwnMfree(adr);	
	return spiele_ret;
}

/************************************************************************/

/* Dank an Julian Reschke fÅr den Tip mit Fselect() */
/* Etwas modifiziert auf GEMJing-BedÅrfnisse */
VOID warte(NEWDEF *new)
{
	WORD seconds = new->delayrate;

	while (seconds)
	{
		if (new->no_menu == FALSE)
			evnt_timer(1000, 0);
		else if (Fselect (1000, NULL, NULL, 0L) == EINVFN)
			sleep(1);
		if (Kbshift(-1) == 4+2)
			totalbreak = TRUE;

		seconds--;
	}

	return;
}

/************************************************************************/

LOCAL WORD	detect_hardware(NEWDEF *new)
{
	LONG keks;
	LONG dummy;
	McSnCookie_STRCT *mcsn;

	/* Bit 	0: GI Sound Chip (PSG)
	 * 		1: DMA 8-Bit
	 *			2:	DMA record (XBIOS)
	 *			3: 16-Bit CODEC
	 *			4: DSP
	 */

	new->snd_system = NONE_COMP;

	if (!get_cookie(_SND_COOKIE, &keks))
		keks = 0;

	if (get_cookie(strk_COOKIE, &dummy) == TRUE)
	{
		WORD ret;

		ret = (WORD) cardmagic();
		if (ret & 0x6)
		{
			new->snd_system = ST_H_COMP;
		}
		else
		{
			new->snd_system = ST_W_COMP;
		}
	}
	else if ( (soundcmd(7,-1) >= 0) && (get_cookie(HSN_COOKIE, (LONG*) &dummy) == TRUE) )
	{
		if ((get_cookie(McSn_COOKIE, (LONG*) &mcsn) == TRUE) /* && (get_cookie(Lity_COOKIE, &dummy) == FALSE)*/)
			if (mcsn->vers == 1)
				new->snd_system = HSND_COMP;
	} else if ( (soundcmd(7,-1) >= 0) && (get_cookie(MgPC_COOKIE, (LONG*) &dummy) == TRUE) )
	{
		new->snd_system = HSND_COMP;
	} else if ( (get_cookie(McSn_COOKIE, (LONG*) &mcsn) == TRUE) /*&& (get_cookie(Lity_COOKIE, &dummy) == FALSE*/)
	{
		if (mcsn->vers >= 256)		/* 0x10 lt. Doku */
			new->snd_system = MSND_COMP;
		else if (get_cookie(HSN_COOKIE, &dummy) == TRUE)
			new->snd_system = MSND_COMP;
	}
	else if ( keks >= 8+4 )
		new->snd_system = F030_COMP;
	else if ( keks >= 2 )
		new->snd_system = STE_COMP;
	else if ( (keks >= 1) || (!get_cookie(_SND_COOKIE, &keks)) ) /* Kein Soundcookie gefunden? */
		new->snd_system = ST_COMP; /* dann muû es ein ST sein */
	else
		return RT_WRONG_HARDWARE;

	return TRUE;
}

/************************************************************************/

LOCAL WORD	recognize_format(NEWDEF *new, LONG *adr, LONG len)
{
	LONG *fmt_tag;
	LONG *end = (LONG*) ((LONG)adr + len);

	/* Format feststellen und in ein signed-Sample mit der new-Struktur */
	/* wandeln */

	fmt_tag = (LONG *) adr;

	if (*fmt_tag == DVS_HEAD)		/* wenn Quellformat == DVS-Format */
	{
		DVSMHEAD *dvs;

		dvs = (DVSMHEAD *) adr;

		new->fmt = 2;
		new->adr = (WORD *)adr;
		new->end = (WORD *)((LONG)adr + len);
		new->len = len - dvs->headlen;

		new->sample_start = (WORD *)((LONG) new->adr + dvs->headlen);

		if (dvs->pack != 0)
		{
			OwnMfree(new->adr);
			return(RT_PACKED);
		}

		switch(dvs->freq)
		{
			case DVS8	:	new->frq = 8195L; break;
			case DVS9	:	new->frq = 9833L; break;
			case DVS12	:	new->frq = 12292L; break;
			case DVS16	:	new->frq = 16390L; break;
			case DVS19	:	new->frq = 19668L; break;
			case DVS24	:	new->frq = 24585L; break;
			case DVS32	:	new->frq = 32780L; break;
			case DVS49	:	new->frq = 49170L; break;
			default		:	new->frq = 24585L; 
		}

		new->res = 8;
		new->channels = 2;
		switch (dvs->mode)
		{
/*			case 0: break;*/
			case 1: new->res = 16; break;
			case 2: new->channels = 1; break;
		}
	}
	else 
	if (*fmt_tag == WAV_HEAD)		/* wenn Quellformat == WAV-Format ('RIFF')*/
	{
		LONG *pl = adr;
		SUB_CH *sub_ch;
		LONG data_length;

		pl++;
		flip_long((WORD *) pl);
		new->len = *pl;

		while (*pl != 'WAVE')
		{
			if (pl >= end)
				return RT_WRONG_FILE;
			pl++;
		}

	/* XXX Problem: Tag muû nicht an LONG-aligned Adresse liegen! */
		while (*pl != 'fmt ')
		{
			if (pl >= end)
				return RT_WRONG_FILE;
			pl++;
		}

		if (*pl == 'fmt ')
			pl++;

		sub_ch = (SUB_CH*) pl;

		flip_long((WORD *) &sub_ch->len_sub);
		flip_word((BYTE *) &sub_ch->format);
		flip_word((BYTE *) &sub_ch->modus);
		flip_long((WORD *) &sub_ch->sample_fq);
		flip_long((WORD *) &sub_ch->byte_p_sec);
		flip_word((BYTE *) &sub_ch->byte_p_spl);
		flip_word((BYTE *) &sub_ch->bit_p_spl);

		/* "vorspulen" */
		while (*pl != 'data')
		{
			if (pl >= end)
				return RT_WRONG_FILE;
			pl++;
		}

		pl++;
		new->header_len = (LONG) pl - (LONG) adr;
		flip_long((WORD *) pl);
		data_length = *pl;
		if (data_length > (new->len - new->header_len))
			data_length = new->len - new->header_len;

		new->sample_start = (WORD*) ++pl;

		new->fmt = 1;
		new->adr = (WORD *) adr;

		/* einige Windows-WAVs korrigieren */
		if(sub_ch->len_sub<=1 || sub_ch->len_sub>=256)
			sub_ch->len_sub=16;

		new->end = (WORD *)((LONG)new->sample_start + data_length);

		convert8_sam((BYTE *)new->sample_start, data_length);
		new->frq = sub_ch->sample_fq;
		new->res = sub_ch->bit_p_spl;
		new->channels = sub_ch->modus;
	}
	else 
	if (*fmt_tag == JAVA_HEAD)		/* wenn Quellformat == Java-Format ('RIFF')*/
	{
		/* Texel-Spezialformat: Java Byte-Code */
		my_java_hd *wav;

		wav = (my_java_hd *) adr;
		flip_long((WORD *) &wav->length);
		flip_long((WORD *) &wav->len_sub);
		flip_word((BYTE *) &wav->format);
		flip_word((BYTE *) &wav->modus);
		flip_long((WORD *) &wav->sample_fq);
		flip_long((WORD *) &wav->byte_p_sec);
		flip_word((BYTE *) &wav->byte_p_spl);
		flip_word((BYTE *) &wav->bit_p_spl);
		flip_long((WORD *) &wav->data_length);
		new->fmt = 1;
		new->adr = (WORD *) adr;
		new->len = wav->length;
		if (new->len > len)
			new->len = len;

		new->header_len = sizeof(my_wav_hd);

		if (wav->data_length > (new->len - new->header_len))
			wav->data_length = new->len - new->header_len;
		
		if ((wav->chunk_type != 0x4A415641L) || (wav->len_sub != 16))
		{
			if (new->memoryplay == NULL)
				OwnMfree(adr);
			return(RT_WRONG_CHUNK);
		}

		new->sample_start = (WORD *)((LONG)new->adr + new->header_len);
		new->end = (WORD *)((LONG)new->sample_start + wav->data_length);
		convert8_sam((BYTE *)new->sample_start, wav->data_length);
		new->frq = wav->sample_fq;
		new->res = wav->bit_p_spl;
		new->channels = wav->modus;
	}
	else if (*fmt_tag == SMP_HEAD)		/* SMP '~Å~Å' (Galactic) */
	{
		SMPHEADER *smp;
		
		smp = (SMPHEADER *) adr;

		new->sample_start = (WORD *) ((LONG) adr + smp->header_len);
		new->adr = (WORD *) adr;
		new->end = (WORD *)((LONG)new->adr + smp->sam_len);
		new->len = smp->sam_len;
		new->header_len = smp->header_len;
		new->fmt = 3;

		if (new->len > len)						/* Wenn SamplelÑnge grîûer DateilÑnge */
			new->len = len - smp->header_len;

		new->res = (WORD) smp->res;
		if (new->res != 8)
		{
			if (new->memoryplay == NULL)
				OwnMfree(adr);
			return RT_WRONG_FILE;
		}
		new->frq = smp->frq;
		new->channels = (smp->flags & 0xff) /*+ 1*/;		/* XXX? Thorsten Ottos Samples gingen nur so*/
	}
	else if (*fmt_tag == STEue_HEAD)		/* SMP 'STEÅ' (STE-Play) */
	{
		SMPHEADER *smp;

		smp = (SMPHEADER *) adr;

		new->sample_start = (WORD *) ((LONG) adr + sizeof(SMPHEADER));
		new->adr = (WORD *) adr;
		new->end = (WORD *) ((LONG) new->sample_start + len);
		new->len = smp->sam_len;				/* XXX unbedingt prÅfen wg. inkonsistenter LÑngen (auch Header!) */
		new->res = smp->res;
		if (new->res > 8)
			new->res = 16;
		new->frq = smp->frq;
		new->channels = (smp->flags & 0xff) /*+ 1*/;  /* XXX? */
	}
	else if (*fmt_tag == 'HSND')
	{
		HSN_ALT *hsn;
		WORD offset=0;
		BYTE *dum = (BYTE *) adr;

		hsn = (HSN_ALT*) adr;
		new->adr = (WORD *) ((LONG) hsn + sizeof(HSN_ALT));

		dum += 6;			/* |HSND1.1  ->  HSND1.|1; | = Pointer */
		if (*dum == '1')	/* neues Format hat 42 Bytes grîûere Header */
			offset = 42;

		new->end = (WORD *) ((LONG) hsn + hsn->laenge);
		new->sample_start = (WORD *)((LONG) hsn + sizeof(HSN_ALT) + offset);
		new->len = hsn->laenge;
		new->frq = hsn->frequenz * 10;
		new->channels = 1;
		if (hsn->stereo == TRUE)
			new->channels = 2;

		new->res = hsn->bitsps;
	}
	else if (*fmt_tag == AVR_HEAD)			/* Michtrons AVR-Format */
	{
		AVR_NEWHEADER *avr;
		BYTE *dum = (BYTE *) adr;

		avr = (AVR_NEWHEADER *) adr;

		new->adr = (WORD *) adr;
		new->end = (WORD *) ((LONG) adr + len);
		new->sample_start = (WORD *) ((LONG)adr + sizeof(AVR_NEWHEADER));
		new->len = avr->size;

		new->res = avr->rez;
		if (new->res > 8)
		{
			new->res = 16;
			new->len = new->len << 1;	/* LÑnge verdoppeln, da 16 Bit */
		}
		else
			new->res = 8;

		new->channels = 1;
		if (avr->mono > 0)		/* 0xffff = stereo */
		{
			new->channels = 2;
		}

		if (avr->sign == 0)				/* 0 = unsigned */
		{
			if (new->channels == 1)
				convert8_sam((BYTE *) new->sample_start, new->len);
			else
				convert16_sam((BYTE *)new->sample_start, new->len);
		}

/* hîchstes Byte mit 0 Åberschreiben, da Intel 3-Byte-Zahl */
		dum = (BYTE*) &(avr->rate);
		dum[0] = 0;		
		new->frq = avr->rate;
		if (new->frq < 1000 || new->frq > 60000L)
			new->frq = 11025;
	}
	else if (*fmt_tag == PSION_HEAD)		/* Psion WVE-Format */
	{
		PSION_WVE_HEADER *psion;

		if (strcmp((BYTE*)adr, PSION_COMPLETE_MAGIC) != 0)
			return RT_WRONG_FILE;

		psion = (PSION_WVE_HEADER*) adr;
		new->sample_start = (WORD*)((LONG)adr + PSION_HEADER_LEN);
		new->adr = (WORD*) adr;
		if (psion->num_samples < (len - PSION_HEADER_LEN))
			new->len = psion->num_samples;
		else
			new->len = len - PSION_HEADER_LEN;
		new->end = (WORD*) ((LONG)adr + len);
		new->frq = 8000L;				/* ist bei Psion fest */
		new->channels = 1;			/* ist bei Psion fest */
		new->res = 16;					/* ist bei Psion fest */

		/* Dein Einsatz, Thomas */
		convert_alaw_linear(new);
	}
	else if (*fmt_tag == NeXT_HEAD)		/* NeXT-Format ('.snd')*/
	{
		SNDSoundStruct *snd;

		snd = (SNDSoundStruct *) adr;

		new->len = snd->dataSize;
		new->adr = (WORD *) adr;
		new->end = (WORD *) ((LONG)snd + new->len);

		new->frq = snd->samplingRate;
		new->channels = (BYTE) snd->channelCount;

		if (snd->dataFormat == SND_FORMAT_UNSPECIFIED)
			;
		else if (snd->dataFormat == SND_FORMAT_LINEAR_8)
			new->res = 8;
		else if (snd->dataFormat == SND_FORMAT_LINEAR_16)
			new->res = 16;
		else if (snd->dataFormat == SND_FORMAT_MULAW_8)
		{
			return RT_UNSUPPORTED_AU_SND;
	/*		new->res = 16;
	*		ret = convert_mulaw_linear(new);
	*		if (ret != TRUE)
	*		{
	*			if (new->memoryplay == NULL)
	*				OwnMfree(adr);
	*			return ret;
	*		} */
		}
		else
		{
			new->res = 0;
			if (new->memoryplay == NULL)
				OwnMfree(adr);
			return RT_UNSUPPORTED_AU_SND;
		}
	}
	else
		return RT_WRONG_FILE;

	return TRUE;
}

/************************************************************************/

LOCAL WORD convert_alaw_linear(NEWDEF* new)
{
	WORD *dest;

	/* Grîûe verdoppeln. Es entstehen aus den 8-Bit-Werten zwar nur
		12-Bit-Werte, aber die sind so schlecht zu verwalten. Daher 16-Bit. */
	new->len = new->len << 1;
	dest = OwnMalloc(new->len, MLC_ST_RAM);
	if (dest == NULL)
		return RT_NO_MEM;
	memset(dest, 0, new->len);		/* auf 0 setzen */

/*	Hier fehlt der Code, da die mir vorliegenden Tabellen nicht stimmen :-/ */	

	return 0;	
}

/************************************************************************/

LOCAL WORD	play_sample(NEWDEF *new)
{
	WORD ret;
	ULONG frq;

	if (new->sample_start == NULL)
		return RT_WRONG_FILE;

	if (new->snd_system == HSND_COMP || new->snd_system == MSND_COMP ||
		new->snd_system == F030_COMP || new->snd_system == ST_H_COMP ||
		new->snd_system == ST_W_COMP) 
			ret = flc_play_sam(new);
	else if (new->snd_system == STE_COMP)
	{
		BYTE mode;

		if (new->res == 16)
		{
			new->len = (LONG)	to_eight((unsigned char*) new->sample_start,
									(unsigned char*)((LONG)new->sample_start + new->len),
									TRUE);
			new->len -= (LONG) new->sample_start;
		}

		if (new->channels == 2)
			mode = 0;
		else
			mode = 1;
		frq = 1;

		if (new->frq > 37549L)
			frq = 3;
		else if (new->frq <= 37549L && new->frq > 18775)
			frq = 2;
		else if (new->frq <= 18775 && new->frq > 9387)
			frq = 1;
		else if (new->frq <= 9387)
			frq = 0;

		ste_play_sam((BYTE *)new->sample_start, new->len, (BYTE)frq, mode);

		/* warte auf Abbruchbedingung */
		do
		{
			if (sample_interrupt == TRUE)
				break;
			if (Kbshift(-1) == 4+2)
			{
				totalbreak = TRUE;
				break;
			}

			/* bis CTRL-SHIFT oder Sample-Ende erreicht */
		} while (ste_ready_sam() == FALSE);

		ste_stop_sam();
		ret = TRUE;
	}
	else if (new->snd_system == ST_COMP)
	{
		frq = 614400L / new->frq;
		if (new->res == 16)
		{
			new->len = (LONG)	to_eight((unsigned char*) new->sample_start,
									(unsigned char*)((LONG)new->sample_start + new->len),
									TRUE);
			new->len -= (LONG) new->sample_start;
		}
		play_init();

		play_sam((BYTE*) new->sample_start, new->len, (WORD)frq);

		/* warte auf Abbruchbedingung */
		do
		{
			/* bis CTRL-SHIFT oder Sample-Ende erreicht */
			if (sample_interrupt == TRUE)
				break;
			if (Kbshift(-1) == 4+2)
			{
				totalbreak = TRUE;
				break;
			}
		} while (sam_flag & 1);

		stop_sam(); play_exit();
		ret = TRUE;
	}
	else
		ret = RT_SND_ERR;

	return(ret);
}

/************************************************************************/

LOCAL WORD flc_play_sam(NEWDEF* new)
{
	LONG		curadder, curadc;
	WORD		prescale;
	DMAPOS	pos;
	BOOLEAN	loop_exit = FALSE, first_flag;

	if (locksnd() != 1)			/* sperre Soundsystem */
		return(RT_LOCKED);

	if (sndstatus(0))				/* CODEC-Reset, wenn Fehler */
		sndstatus(1);

	curadder = soundcmd(ADDERIN, INQUIRE);
	curadc = soundcmd(ADCINPUT, INQUIRE);
	soundcmd(ADCINPUT, 0);

	setmontracks(0);	/* Lautsprecher = erste Spur */

	if (((soundcmd(7,-1) >= 0) && (new->snd_system == HSND_COMP)) || new->snd_system == ST_W_COMP)	/* wenn WeirdMac oder StarTrack-Karte mit Clockmodul */
	{
		soundcmd(7, (WORD) new->frq); /* ohne feste XBIOS-Frequenzen spielen */
	}
	else
	if (new->snd_system == ST_H_COMP)
	{
		REG LONG f = new->frq;

		if (f > 46050L)
			prescale = 3;
		else if (f <= 46050L && f > 38587L)
			prescale = 2;
		else if (f <= 38587L && f > 32537L)
			prescale = 11;
		else if (f <= 32537L && f > 28000)
			prescale = 1;
		else if (f <= 28000 && f > 23025)
			prescale = 10;
		else if (f <= 23025 && f > 19293)
			prescale = 9;
		else if (f <= 19293 && f > 16268)
			prescale = 8;
		else if (f <= 16268 && f > 14000)
			prescale = 7;
		else if (f <= 14000 && f > 11512)
			prescale = 6;
		else if (f <= 11512 && f > 9487)
			prescale = 5;
		else
			prescale = 4;
	}
	else
	{
		if (new->frq > 40975L)
			prescale = 1;
		else if (new->frq < 40975L && new->frq > 28682)
			prescale = 2;
		else if (new->frq <= 28682 && new->frq > 22126)
			prescale = 3;
		else if (new->frq <= 22126 && new->frq > 18029)
			prescale = 4;
		else if (new->frq <= 18029 && new->frq > 14341)
			prescale =  5;
		else if (new->frq <= 14341 && new->frq > 11000)
			prescale = 7;
		else if (new->frq <= 11000 && new->frq > 9014)
			prescale = 9;
		else
			prescale = 11;
	}

	if (new->channels == 2)
	{
		if (new->res == 8)
			setmode(STEREO8);
		else if (new->res == 16)
			setmode(STEREO16);
	}
	else if (new->channels == 1)
	{
		if (new->res == 8)
			setmode(MONO8);
	}

	setbuffer(0, new->sample_start, new->end);			/* setze DMA Abspielpuffer */
	settracks(0, 0);						/* eine Wiedergabespur */

	devconnect(DMAPLAY, DAC, CLK25M, prescale, NO_SHAKE);

	buffoper(PLAY_ENABLE);
	first_flag = TRUE;

	/* Zwei Behandlungen, da sich MSND.PRG auf'm Mac anders als der Falcon verhÑlt */
	/* Interrupt-Geschichten fÅhrten bei mir auf dem Falcon nur zum Interrupt-Tod,
		kann aber auch an meinem gepatchten TOS gelegen haben. Jetzt ist er platt
		und ich kann es nicht mehr testen. Daher das kranke System des Pointer-
		Abpassens. */

	if (new->snd_system == F030_COMP || soundcmd(7,-1)>=0) /* XX */
	{
		do
		{
			buffptr((LONG *) &pos);
			if (first_flag == TRUE)
			    first_flag = FALSE;
			if ((first_flag == FALSE) && (pos.playbufptr == (LONG)new->sample_start))
			    loop_exit = TRUE;
			if (pos.playbufptr >= (LONG)new->end)
			    loop_exit = TRUE;
			if (sample_interrupt == TRUE)
				break;
			if (Kbshift(-1) == 4+2)
			{
				totalbreak = TRUE;
				break;
			}
			Syield();
		}
		while ( loop_exit != TRUE );
	}
	else if (new->snd_system == MSND_COMP)
	{
		do
		{
			buffptr((LONG *) &pos);
			if (sample_interrupt == TRUE)
				break;
			if (Kbshift(-1) == 4+2)
			{
				totalbreak = TRUE;
				break;
			}
			Syield();
		} while (pos.playbufptr != (LONG) new->end);
	}

	buffoper(0);	/* setze die Ursprungsdaten ... */

	soundcmd(ADDERIN, (WORD) curadder);
	soundcmd(ADCINPUT, (WORD) curadc);

	unlocksnd();
	return (TRUE);
}

/************************************************************************/

LONG FileLen(CONST BYTE *fname)
{
	LONG back;
	WORD handle;
	LONG flen = 0;
	XATTR xattr;

	xattr.size = 0;

	back = Fxattr(0, (BYTE *)fname, (XATTR*) &xattr);
	if (back == -32L)		/* wenn es Fxattr nicht gibt */
	{
		back = Fopen(fname, FO_READ);
		if (back < 0) return(FALSE);
	
		handle = (WORD) back;
	
		flen = Fseek(0, handle, 2);		/* ans Dateiende springen */
	
		if (Fclose(handle) != 0) return(FALSE);
	
		return flen;
	}
	else
		return xattr.size;
}

/************************************************************************/

LOCAL BOOLEAN IsThereMxalloc(VOID)
{
	LONG dum = (LONG)Mxalloc(-1,0);
	if (dum == -32L)
		return(FALSE);
	else
		return(TRUE);
}

/************************************************************************/

LOCAL BOOLEAN IsThereFastRAM(VOID)
{
	VOID *dum;
	if (IsThereMxalloc() == TRUE)
	{
		dum = Mxalloc(64, 1);	/* 64 Bytes alt. RAM holen */
		if (dum != NULL)			/* da? */
		{
			Mfree(dum);
			return(TRUE);
		} else
			return(FALSE);
	} else
		return(FALSE);	/* FAST-RAM ist vielleicht da, aber kein Mxalloc */
}

/************************************************************************/

VOID *OwnMalloc(CONST LONG amount, CONST WORD typ)
{
	if (IsThereMxalloc() == TRUE)
	{
		/* unter MagiCMac ist es egal, ob ST- oder TT-RAM angefordert wird */
		if (MagiCMac == TRUE)
			return(Mxalloc(amount, MLC_TTST_RAM));
		return(Mxalloc(amount, typ));
	}
	else 
		return(Malloc(amount));
}

/************************************************************************/

VOID OwnMfree(CONST VOID *adr)
{
	Mfree(adr);
}

/************************************************************************/

LOCAL BOOLEAN Laden(CONST BYTE *fname, BYTE *addr, CONST LONG len)
{
	LONG		handle;
	BOOLEAN	back;
	WORD		h;
	
	handle = Fopen(fname, FO_READ);
	if (handle < 0)
		return(FALSE);
	h = (WORD)handle;
	if (Fread(h, len, addr) != len)
		back = FALSE;
	else
		back = TRUE;
	Fclose(h);
	return(back);
} /* laden */

/************************************************************************/

LOCAL VOID flip_word (REG BYTE *adr)
{
  REG BYTE c;

  c       = adr [0];
  adr [0] = adr [1];
  adr [1] = c;
} /* flip_word */

/************************************************************************/

LOCAL VOID flip_long (REG WORD *adr)
{
  REG WORD i;

  i       = adr [0];
  adr [0] = adr [1];
  adr [1] = i;

  flip_word ((BYTE *)&adr [0]);
  flip_word ((BYTE *)&adr [1]);
} /* flip_long */

/************************************************************************/

/** Profibuch v. Jankowski/Rabich/Reschke	**/
/** 10. Auflage, S. 74 							**/
/** verÑndert: Supexec(), 1999-02-14		**/
/** verÑndert: Setexc(), 1999-04-06			**/
WORD get_cookie(CONST LONG cookie, LONG *value)
{
	/* Zeiger auf Cookie Jar holen */
	LONG *cookiejar = (LONG *) Setexc(0x5A0/4, (void (*)())-1);

	/* Cookiejar Åberhaupt vorhanden ? */
	if (cookiejar == NULL)
		return(FALSE);

	do
	{
		/* Cookie gefunden ? */
		if (cookiejar[0] == cookie)
		{
			/* nur eintragen, wenn "value" kein Nullpointer */
			if (value)
				*value = cookiejar[1];
			return(TRUE);
		}
		else
		{
			/* nÑchsten Cookie nehmen */
			cookiejar = &(cookiejar[2]);
		}
	} while (cookiejar[-2]); /* Nullcookie? */
	return (FALSE);
}

/************************************************************************/
VOID	handle_SIGUSR1(VOID)
{
	sample_interrupt = TRUE;
	totalbreak = TRUE;
}

/************************************************************************/
VOID	handle_SIGTERM(VOID)
{
	sample_interrupt = TRUE;
	totalbreak = TRUE;
	quit = TRUE;
}

/************************************************************************/
WORD convert_mulaw_linear(NEWDEF *new)
{
	/* 8 Bit u-law nach 16 Bit linear Wandlung */
	/* XXX: funktioniert leider nicht, nochmal angucken */

	REG BYTE *look_index;
	WORD *expanded;

	expanded = OwnMalloc(new->len * 2, MLC_ST_RAM);	/* neuen Speicherblock holen */

	if (expanded == NULL)
		return RT_NO_MEM;

	look_index = (BYTE *) new->adr;					/* XXX */
	while ((LONG)look_index < (LONG) new->end)
	{
		*expanded = lookup[*look_index];
		expanded++;
		look_index++;
	}

	OwnMfree(new->adr);	/* alten Speicherblock freigeben, fÅhrt leider zur Zersplitterung */

	new->sample_start = new->adr = expanded;
	new->end = (WORD *)((LONG) expanded + new->len *2);
	new->len = new->len * 2;

	return TRUE;
}
