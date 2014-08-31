/* File name:	PLAYSAMP.C		Revised:	1992.07.26	*/
/* Revised by:	U.R. Andersson	Purified:	1992.07.26	*/
/* Revised by:	U.R. Andersson	Sozoboned:	1990.11.25	*/
/* Ported by:	U.R. Andersson	C port:		1990.11.12	*/

#include	<stdio.h>
#include	<vdi.h>
#include	<aes.h>
#include	<tos.h>
#include	<string.h>
#include	<stdlib.h>

#define	OK		0
#define	ERROR	-1

typedef	struct	sample_def
{	unsigned char	*sam_base;
	long	sam_length;
	short	sam_rate;
} SAM_DEF;

extern	void	cdecl	PLAYSAM(SAM_DEF sample);

int	control[12];
int	intin[128],	intout[128];
int	ptsin[256],	ptsout[12];
int	workin[11] = { 1,1,1,1, 1,1,1,1, 1,1,2 };
int	workout[57];
int	apid,	hand;

char	sndpath[80], sndname[20], sndfid[100];
char	vgbuff[200];
char	erbf[200] = "";
SAM_DEF	sample1;

void	done(int errf)
{	if (erbf[0])
	{	v_clrwk(hand);
		v_gtext(hand,16,16,erbf);
		v_gtext(hand,16,32,"Press any key to return to system!");
		evnt_keybd();
	}
	v_clsvwk(hand);
	appl_exit();
	exit(errf);
}

main(argc, argv)
char	*argv[];
{	/* declarations */
	int	i, j, fd1;
	char	*soundpt=NULL;
	long	soundsz, len;
	short	rate;
/* code start */
	rate = 6;
	apid = appl_init();
	hand = graf_handle(&i, &i, &i, &i);
	v_opnvwk(workin, &hand, workout);
	v_clrwk(hand);
/* ***LOAD SAMPLES*** */
	strcpy(sndpath,"a:\*.S??");
	strcpy(sndname,"");
	*sndpath += Dgetdrv();
	while (1)
	{	graf_mouse(256,0L);
		v_clrwk(hand);
		v_gtext(hand, 16, 16, "Select sound to play back.");
		graf_mouse(257,0L);
		i = fsel_input(sndpath, sndname, &j);
		graf_mouse(256,0L);
		v_clrwk(hand);
		graf_mouse(257,0L);
		if (i == 0)
		{	sprintf(erbf,"ERROR selecting file %s%s",sndpath,sndname);
			done(ERROR);
		}
		if (j == 0) done(OK);
		strcpy(sndfid, sndpath);
		i = strlen(sndfid);
		while (i-- &&  sndfid[i] != ':'  &&  sndfid[i] != '\\')
			; /* dummy */
		strcpy(sndfid+i+1, sndname);
		sprintf(vgbuff, "Loading sound file: %s ...", sndfid);
		v_gtext(hand, 16, 16, vgbuff);
		if ((fd1 = open(sndfid, 0)) < 0)
		{	sprintf(erbf,"ERROR %d opening file %s",fd1,sndfid);
			done(ERROR);
		}
		if ((soundsz = Fseek(0L, fd1, 2)) < 0 || soundsz > 65535L)
		{	sprintf(erbf,"ERROR %ld in sizing file %s",soundsz,fd1);
			done(ERROR);
		}
		Fseek(0L, fd1, 0);
		if (soundpt)  free(soundpt);
		sprintf(vgbuff, "Loading %ld bytes...", soundsz);
		v_gtext(hand, 16, 32, vgbuff);
		if ((soundpt = malloc((unsigned int) soundsz)) == NULL)
		{	sprintf(erbf,"ERROR allocating %ld bytes",soundsz);
			done(ERROR);
		}
		if (soundsz != (len = Fread(fd1, soundsz,soundpt )))
		{	sprintf(erbf,"ERROR %ld reading file %s",len,sndfid);
			done(ERROR);
		}
		close(fd1);
/* ***INTRO*** */
		do
		{	sprintf(vgbuff,"[0][Select next action| |Rate = %dk][Play|Load|Rate]",rate);
			i = form_alert(2, vgbuff);
			switch (i)
			{	/* 1=play 2=load 3=rate */
			case 1:
				sample1.sam_base = (unsigned char *) soundpt;
				sample1.sam_length = soundsz;
				sample1.sam_rate = rate;
				PLAYSAM(sample1);
			case 2:
				break;
			case 3:
				rate = (rate & 0x0F) + 1;
			}
		} while (i != 2);
	} /* ends main loop */
}

/* End of:	PLAYSAMP.C	*/
