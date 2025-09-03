/*
	Header definitions for the DX-7 and TX-816
*/
#define TRUE 1
#define FALSE 0
#define EOX 0xf7	/*	midi end of transmision	*/
#define MIDI 3
#define CON 2
typedef int BOOLEAN;
/*
	System Exclusive data format
*/
typedef struct
{
	char op_egr1;
	char op_egr2;
	char op_egr3;
	char op_egr4;
	char op_eg_l1;
	char op_eg_l2;
	char op_eg_l3;
	char op_eg_l4;
	char op_kb_bp;	/*	Keyboard level scaling breakpoint	*/
	char op_kb_ld;	/*	Keyboard level scaling left depth	*/
	char op_kb_rd;	/*	Keyboard level scaling right depth	*/
	char op_kb_rc;	/*	Keyboard level scaling right curve	*/
	char op_kb_lc;	/*	Keyboard level scaling left curve	*/
	char op_kb_sc;	/*	Keyboard rate scaling	*/
	char op_ams;	/*	Keyboard Amplitude modulation Sensitivity	*/
	char op_kvs;	/*	key velocity sensitivity	*/
	char op_out_level;
	char op_osc_mode;
	char op_osc_crs;	/*	osc frequency coarse	*/
	char op_osc_f_f;	/*	oscilator frequency fine			*/
	char op_detune;		/*	oscilator detune	*/
} OP;

/*
	Misilaneous voice data
*/

typedef struct
{
	char pr1;	/*	pitch envelope rate 1	*/
	char pr2;	/*	pitch envelope rate 2	*/
	char pr3;	/*	pitch envelope rate 3	*/
	char pr4;	/*	pitch envelope rate 4	*/
	char pl1;	/*	pitch envelope level 1	*/
	char pl2;	/*	pitch envelope levle 2	*/
	char pl3;	/*	pitch envelope level 3	*/
	char pl4;	/*	pitch envelope level 4	*/
	char alg_select;	/*	algorithm select	*/
	char feed_bk;	/*	feedback	*/
	char osc_sync;	/*	oscilator key sync	*/
	char lfo_speed;
	char lfo_delay;
	char lfo_p_m_d;		/*	Lfo pitch modulation depth	*/
	char lfo_a_m_d;		/*	Lfo amplitude modulation depth	*/
	char lfo_sync;		/*	Lfo key sync	*/
	char lfo_wave;
	char lfo_pms;		/*	lfo pitch modulation sensitivity	*/
	char transpose;
	char name;			/*	first character of voice name	*/
	char dummy1,dummy2,dummy3,dummy4,dummy5,dummy6,dummy7;
	char dummy8,dummy9;	/*	pad for rest of name	*/
} MISC;

typedef struct
{
	char *ibuf;		/*	pointer to buffer	*/
	int	ibufsiz;	/*	size of que in bytes	*/
	int ibufhd;		/*	head index of queue	*/
	int ibuftl;		/*	tail index of queue	*/
	int ibuflow;	/*	low water mark		*/
	int ibufhigh;	/*	high water mark		*/
} IOREC;

/*
	this is the typedef for the dialog box text for operator data
*/
typedef struct
{
	char egr1[3];
	char egr2[3];
	char egr3[3];
	char egr4[3];
	char eg_l1[3];
	char eg_l2[3];
	char eg_l3[3];
	char eg_l4[3];
	char kb_bp[5];	/*	Keyboard level scaling breakpoint	*/
	char kb_ld[3];	/*	Keyboard level scaling left depth	*/
	char kb_rd[3];	/*	Keyboard level scaling right depth	*/
	char kb_rc[3];	/*	Keyboard level scaling right curve	*/
	char kb_lc[3];	/*	Keyboard level scaling left curve	*/
	char kb_sc[3];	/*	Keyboard rate scaling	*/
	char ams[3];	/*	Keyboard Amplitude modulation Sensitivity	*/
	char kvs[3];	/*	key velocity sensitivity	*/
	char out_level[3];
	char osc_mode[3];
	char osc_crs[6];	/*	osc frequency coarse	*/
	char osc_f_f[6];	/*	oscilator frequency fine			*/
	char detune[3];
}OPTEXT;

typedef struct
{
	char mpr1[3];	/*	pitch envelope rate 1	*/
	char mpr2[3];	/*	pitch envelope rate 2	*/
	char mpr3[3];	/*	pitch envelope rate 3	*/
	char mpr4[3];	/*	pitch envelope rate 4	*/
	char mpl1[3];	/*	pitch envelope level 1	*/
	char mpl2[3];	/*	pitch envelope levle 2	*/
	char mpl3[3];	/*	pitch envelope level 3	*/
	char mpl4[3];	/*	pitch envelope level 4	*/
	char malg_select[3];	/*	algorithm select	*/
	char mfeed_bk[3];	/*	feedback	*/
	char mosc_sync[4];	/*	oscilator key sync	*/
	char mlfo_speed[3];
	char mlfo_delay[3];
	char mlfo_p_m_d[3];		/*	Lfo pitch modulation depth	*/
	char mlfo_a_m_d[3];		/*	Lfo amplitude modulation depth	*/
	char mlfo_sync[4];		/*	Lfo key sync	*/
	char mlfo_wave[4];
	char mlfo_pms[3];		/*	lfo pitch modulation sensitivity	*/
	char mtranspose[4];
	char mname[11];
}MISCTEXT;

/*
	conditions of bulk edit buffer
*/

#define EMPTY	0
#define	VOICE	1	/*	bulk buffer contains bulk voice	*/
#define	PERFORM	2	/*	bulk buffer contains bulk performance	*/
#define OP1 0x20	/*	masks for operator ON/OFF control	*/
#define OP2 0x10
#define OP3 0x08
#define OP4	0x04
#define	OP5	0x02
#define	OP6	0x01
