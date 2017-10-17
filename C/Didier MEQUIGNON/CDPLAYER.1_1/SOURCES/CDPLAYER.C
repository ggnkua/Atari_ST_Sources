
/* CDPLAYER ‚crit en PURE C */
/* MEQUIGNON Didier Octobre 1996 */
/* G‚re directement les CD-ROM NEC et PIONEER */

#include <cpx.h>
#include <vdi.h>
#include <tos.h>

/* ressource */

#define MENUBOX 0
#define MENUINFO 3
#define MENUCANAL 4
#define MENUCAPA 5
#define MENUBOXVOL 6
#define MENUSVOL 7
#define MENUCMDE 8
#define MENUBTYPE 9
#define MENUSTATUS 10
#define MENUAFFTRACK 11
#define MENULOGO 14
#define MENUBEJECT 15
#define MENUBSTOP 17
#define MENUBPLAY 19
#define MENUBPAUSE 21
#define MENUBREW 23
#define MENUBFF 25
#define MENUTRACK 27
#define MENUBSCAN 28
#define MENUBREPEAT 29
#define MENUBRANDOM 30
#define MENUBTIME 31
#define MENUBSAUVE 32
#define MENUBANNULE 33

#define DMAECR 1
#define DMABECR 2
#define DMABANNULE 3

char *rs_strings[] = {
	"PLAYER AUDIO CD-ROM","","",
	"MEQUIGNON Didier V1.1 Octobre 1996","","",
	"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","","",
	"0","Num‚ro SCSI: _","9",
	"xxxxx Mo","","",
	"- VOL +","","",
	"00000000000000000000",
	"Cmde: ____________________",
	"FFFFFFFFFFFFFFFFFFFF",
	"Lec","","",
	"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx","","",
	"TRACK MN SEC  ALL MN SEC  MN SEC","","",
	"  :  : :","","",
	"01","__","99",
	"SCAN","","",
	"REPEAT","","",
	"RANDOM","","",
	"TIME","","",
	"Sauve",
	"Annule",
	"01234567890123456789012345678901234567890123456789012345678901234567890123456789",
	"________________________________________________________________________________",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"Ecrire",
	"Annuler" };

long rs_frstr[] = {0};

BITBLK rs_bitblk[] = {
	(int *)0L,8,32,0,0,1,
	(int *)1L,2,16,0,0,1,
	(int *)2L,2,16,0,0,1,
	(int *)3L,2,16,0,0,1,
	(int *)4L,2,16,0,0,1,
	(int *)5L,2,16,0,0,1,
	(int *)6L,2,16,0,0,1 };

long rs_frimg[] = {0};
ICONBLK rs_iconblk[] = {0};

TEDINFO rs_tedinfo[] = {
	(char *)0L,(char *)1L,(char *)2L,IBM,0,2,0x1180,0,0,32,1,
	(char *)3L,(char *)4L,(char *)5L,SMALL,0,2,0x1180,0,0,32,1,
	(char *)6L,(char *)7L,(char *)8L,IBM,0,2,0x1180,0,0,31,1,
	(char *)9L,(char *)10L,(char *)11L,IBM,0,0,0x1180,0,0,2,15,
	(char *)12L,(char *)13L,(char *)14L,IBM,0,0,0x1180,0,0,9,1,
	(char *)15L,(char *)16L,(char *)17L,SMALL,0,2,0x1180,0,1,8,1,
	(char *)18L,(char *)19L,(char *)20L,IBM,0,0,0x1180,0,0,21,27,
	(char *)21L,(char *)22L,(char *)23L,SMALL,0,2,0x1180,0,1,4,1,
	(char *)24L,(char *)25L,(char *)26L,SMALL,0,0,0x1180,0,0,41,1,
	(char *)27L,(char *)28L,(char *)29L,SMALL,0,0,0x1600,0,0,33,1,
	(char *)30L,(char *)31L,(char *)32L,IBM,0,0,0x1500,0,0,25,1,
	(char *)33L,(char *)34L,(char *)35L,IBM,0,2,0x1180,0,-1,3,3,
	(char *)36L,(char *)37L,(char *)38L,SMALL,0,2,0x1180,0,-1,5,1,
	(char *)39L,(char *)40L,(char *)41L,SMALL,0,2,0x1180,0,-1,7,1,
	(char *)42L,(char *)43L,(char *)44L,SMALL,0,2,0x1180,0,-1,7,1,
	(char *)45L,(char *)46L,(char *)47L,SMALL,0,2,0x1180,0,-1,5,1,
	(char *)50L,(char *)51L,(char *)52L,IBM,0,0,0x1180,0,0,81,81 };

OBJECT rs_object[] = {
	-1,1,33,G_BOX,FL3DBAK,NORMAL,0x1100L,0,0,32,11,
	2,-1,-1,G_TEXT,FL3DBAK,SELECTED,0L,0,0,32,1,
	3,-1,-1,G_TEXT,FL3DBAK,NORMAL,1L,0,1,32,1,
	4,-1,-1,G_TEXT,FL3DBAK,NORMAL,2L,1,2,30,1,										/* infos CD-ROM */
	5,-1,-1,G_FTEXT,EDITABLE|FL3DBAK,NORMAL,3L,1,3,14,1,							/* no canal SCSI */
	6,-1,-1,G_TEXT,FL3DBAK,NORMAL,4L,23,3,8,1,										/* capacit‚ CD */
	8,7,7,G_BOXTEXT,TOUCHEXIT|FL3DIND|FL3DBAK,SELECTED,5L,25,4,6,1,
 	6,-1,-1,G_BOX,TOUCHEXIT|FL3DIND|FL3DBAK,NORMAL,0x11100L,0,0,1,1,				/* slider volume */
	9,-1,-1,G_FTEXT,HIDETREE|FL3DBAK,NORMAL,6L,1,4,26,1,							/* test commande CD */
	10,-1,-1,G_BOXTEXT,HIDETREE,SHADOWED,7L,28,4,3,1,								/* test type commande */
	11,-1,-1,G_TEXT,HIDETREE|FL3DBAK,NORMAL,8L,1,1,30,1,							/* test octets lecture */
	14,12,13,G_BOX,NONE,NORMAL,0xff10f1L,0,5,24,2,
	13,-1,-1,G_TEXT,FL3DBAK,NORMAL,9L,0,0,24,1,
	11,-1,-1,G_TEXT,NONE,NORMAL,10L,0,1,24,1,										/* infos TRACK */
	15,-1,-1,G_IMAGE,NONE,NORMAL,0L,24,5,8,1,										/* logo CD */
	17,16,16,G_BOX,TOUCHEXIT|FL3DIND|FL3DBAK,NORMAL,0xff1100L,2,8,2,1,				/* eject */
	15,-1,-1,G_IMAGE,TOUCHEXIT,NORMAL,1L,0,0,2,1,
	19,18,18,G_BOX,TOUCHEXIT|FL3DIND|FL3DBAK,SELECTED,0xff1100L,5,8,2,1,			/* stop */
	17,-1,-1,G_IMAGE,TOUCHEXIT,NORMAL,2L,0,0,2,1,
	21,20,20,G_BOX,TOUCHEXIT|FL3DIND|FL3DBAK,NORMAL,0xff1100L,8,8,2,1,				/* play */
	19,-1,-1,G_IMAGE,TOUCHEXIT,NORMAL,3L,0,0,2,1,
	23,22,22,G_BOX,TOUCHEXIT|FL3DIND|FL3DBAK,NORMAL,0xff1100L,11,8,2,1,				/* pause */
	21,-1,-1,G_IMAGE,TOUCHEXIT,NORMAL,4L,0,0,2,1,
	25,24,24,G_BOX,TOUCHEXIT|FL3DIND|FL3DBAK,NORMAL,0xff1100L,14,8,2,1,				/* << */
	23,-1,-1,G_IMAGE,TOUCHEXIT,NORMAL,5L,0,0,2,1,
	27,26,26,G_BOX,TOUCHEXIT|FL3DIND|FL3DBAK,NORMAL,0xff1100L,17,8,2,1,				/* >> */
	25,-1,-1,G_IMAGE,TOUCHEXIT,NORMAL,6L,0,0,2,1,
	28,-1,-1,G_FBOXTEXT,EDITABLE|FL3DBAK,NORMAL,11L,20,8,3,1,						/* track xx */
	29,-1,-1,G_BOXTEXT,TOUCHEXIT|FL3DIND|FL3DBAK,NORMAL,12L,2,9,5,1,				/* scan */
	30,-1,-1,G_BOXTEXT,TOUCHEXIT|FL3DIND|FL3DBAK,NORMAL,13L,8,9,5,1,				/* repeat */
	31,-1,-1,G_BOXTEXT,TOUCHEXIT|FL3DIND|FL3DBAK,NORMAL,14L,14,9,5,1,				/* random */
	32,-1,-1,G_BOXTEXT,TOUCHEXIT|FL3DIND|FL3DBAK,NORMAL,15L,20,9,3,1,				/* time */
	33,-1,-1,G_BUTTON,SELECTABLE|EXIT|FL3DIND|FL3DBAK,NORMAL,48L,25,7,6,1,			/* Sauve */
	0,-1,-1,G_BUTTON,SELECTABLE|EXIT|LASTOB|FL3DIND|FL3DBAK,NORMAL,49L,25,9,6,1,	/* Annule */

	-1,1,3,G_BOX,FL3DBAK,OUTLINED,0x21100L,0,0,82,5,
	2,-1,-1,G_FTEXT,EDITABLE|FL3DBAK,NORMAL,16L,1,1,80,1,							/* octets … ‚crire */
	3,-1,-1,G_BUTTON,SELECTABLE|DEFAULT|EXIT|FL3DIND|FL3DBAK,NORMAL,53L,28,3,8,1,	/* Ecrire */
	0,-1,-1,G_BUTTON,SELECTABLE|EXIT|LASTOB|FL3DIND|FL3DBAK,NORMAL,54L,44,3,8,1 };	/* Annuler */

long rs_trindex[] = {0};
struct foobar {
	int dummy;
	int *image;
	} rs_imdope[] = {0};

unsigned int image_logo[]={
	0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000,
	0x0001,0xc39c,0x8b88,0x7700,
	0x0003,0xe422,0xda54,0x8200,
	0x0003,0xe422,0xdb94,0x8200,
	0x0003,0xe422,0xaa3e,0x8200,
	0x0003,0xe39c,0xaa22,0x7200,
	0x0003,0xe000,0x0000,0x0000,
	0x007f,0xe7c3,0xff07,0xfc00,
	0x00ff,0xe7c7,0xff8f,0xfe00,
	0x01ff,0xe7cf,0xff9f,0xff00,
	0x01ff,0xe7cf,0xff1f,0xff00,
	0x01f3,0xe7cf,0x001e,0x0f00,
	0x01f3,0xe7cf,0x001e,0x0f00,
	0x01f3,0xe7cf,0xfe1e,0x0600,
	0x01f3,0xe7cf,0xff1e,0x0000,
	0x01f3,0xe7c7,0xff9e,0x0000,
	0x01f3,0xe7c3,0xff9e,0x0600,
	0x01f3,0xe7c0,0x079e,0x0f00,
	0x01f3,0xe7c0,0x079e,0x0f00,
	0x01ff,0xe7c7,0xff9f,0xff00,
	0x01ff,0xe7cf,0xff9f,0xff00,
	0x00ff,0xe7cf,0xff0f,0xfe00,
	0x007f,0xc7c7,0xfe07,0xfc00,
	0x0000,0x0000,0x0000,0x0000,
	0x01c9,0xd722,0x044b,0x9300,
	0x012a,0x1252,0x0a4a,0x5480,
	0x012a,0xd252,0x0a4a,0x5480,
	0x012a,0x52fa,0x1f4a,0x5480,
	0x01c9,0xd28b,0x9133,0x9300,
	0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000 };

unsigned int image_eject[]={
	0x0000,0x0000,0x0000,0x0180,0x03c0,0x07e0,0x0ff0,0x1ff8,
	0x3ffc,0x0000,0x0000,0x3ffc,0x3ffc,0x0000,0x0000,0x0000 };

unsigned int image_stop[]={
	0x0000,0x0000,0x0000,0x0000,0x1ff8,0x1ff8,0x1ff8,0x1ff8,
	0x1ff8,0x1ff8,0x1ff8,0x1ff8,0x0000,0x0000,0x0000,0x0000 };

unsigned int image_play[]={
	0x0000,0x0000,0x0000,0x2000,0x3c00,0x3f80,0x3ff0,0x3ffe,
	0x3ffe,0x3ff0,0x3f80,0x3c00,0x2000,0x0000,0x0000,0x0000 };

unsigned int image_pause[]={
	0x0000,0x0000,0x0000,0x1e78,0x1e78,0x1e78,0x1e78,0x1e78,
	0x1e78,0x1e78,0x1e78,0x1e78,0x1e78,0x0000,0x0000,0x0000 };

unsigned int image_rew[]={
	0x0000,0x0000,0x0000,0x0204,0x060c,0x0e1c,0x1e3c,0x3e7c,
	0x3e7c,0x1e3c,0x0e1c,0x060c,0x0204,0x0000,0x0000,0x0000 };

unsigned int image_ff[]={
	0x0000,0x0000,0x0000,0x2040,0x3060,0x3870,0x3c78,0x3e7c,
	0x3e7c,0x3c78,0x3870,0x3060,0x2040,0x0000,0x0000,0x0000 };

#define NUM_STRINGS 55	/* nbre de chaŒnes */
#define NUM_FRSTR 0		/* chaines form_alert */
#define NUM_IMAGES 0
#define NUM_BB 7		/* nbre de BITBLK */
#define NUM_FRIMG 0
#define NUM_IB 0		/* nbre d'ICONBLK */
#define NUM_TI 17		/* nbre de TEDINFO */
#define NUM_OBS 38		/* nbre d'objets */
#define NUM_TREE 2		/* nbre d'arbres */ 

#define TREE1 0
#define TREE2 1

#define soundcmd(a,b) (long)xbios(130,a,b)
#define devconnect(a,b,c,d,e) (long)xbios(139,a,b,c,d,e)
#define LTATTEN 0
#define RTATTEN 1
#define LTGAIN 2
#define RTGAIN 3
#define ADDERIN 4
#define ADCINPUT 5
#define SETPRESCALE 6
#define ID (long)'S_DR'
#define ID_CPX (long)'CD_P'
#define TAILLE_BUFFER 4096L
#define ITEMPS 100L	/* mS */
#define STOP 0
#define PLAY 1
#define PAUSE 2
#define CONTINU 0
#define SCAN 1
#define REPEAT 2
#define RANDOM 3
#define MAX_TRACK 99

typedef struct
{
	long ident;
	union
	{
		long l;
		int i[2];
		char c[4];
	} v;
} COOKIE;

/* prototypes */

int CDECL cpx_call(GRECT *work);
void CDECL cpx_draw(GRECT *clip);
void CDECL cpx_wmove(GRECT *work);
void CDECL cpx_timer(int *event);
void CDECL cpx_key(int kstate,int key,int *event);
void CDECL cpx_button(MRETS *mrets,int nclicks,int *event);
void CDECL cpx_close(int flag);
OBJECT *adr_tree(int no_arbre);
CPXNODE *get_header(long id);
void change_objc(int objc,int state,GRECT *clip);
void aff_objc(int objc,GRECT *clip);
void deplacement_curseur(void);
void attente_fin_clic(void);
void eject_(void);
void stop(void);
void play(void);
void pause(void);
void rew(int nb_clic);
void ff(void);
void scan(void);
void repeat(void);
void rnd(void);
int volume(int choix,int vol);
int cherche_track(int sens);
int playtime(int device,int play,long start_time,int test_unit);
int stop_end_track(int device);
int stop_end_disk(int device);
void ana_erreur(int ret);
int lecture_canal(void);
void test_cd_rom(void);
void aff_status(void);
void aff_track(void);
long debut_track(int track);
long fin_track(int track);
long duree_track(int track);
int calcul_track(void);
void calcul_scan(int track,long *scan_debut,long *scan_fin);
long conv_time(long time);
long conv_bcd_time(long time);
int conv_track(int track);
int conv_bcd_track(int track);
void conv_digit(char *chaine,int valeur);
void conv_int_deci(char *chaine,int valeur);
void conv_hexa(char *chaine,int valeur);
int rnd_track(int track,int init);
void init_codec(int choix);
void raz_timer(void);
long lecture_hz_200(void);
int test_unit_ready(int device);
int restore(int device);
int request_sense(int device);
int mode_sense(int device);
int inquiry(int device);
int send_diagnostic(int device);
long read_capacity(int device,long *nb_sector,long *size_sector);
int play_audio(int device,int play_pause,int start_stack,long start_time);
int stop_audio(int device,int stop_track,long stop_time);
int pause_audio(int device);
int eject(int device);
int inquiry_tracks(int device,int *status,int *play_track,long *time_track,long *play_time,int *all_track,long *all_time,long *tab_time);
void raz_buffer_cmde(void);
extern int Scsi_read(int canal,long long_dma,long long_cmde,unsigned char *buffer_dma,unsigned char *buffer_cmde);
extern int Scsi_write(int canal,long long_dma,long long_cmde,unsigned char *buffer_dma,unsigned char *buffer_cmde);

/* variables globales VDI */

int vdi_handle,work_in[11]={1,1,1,1,1,1,1,1,1,1,2},work_out[57];
int errno;
 
/* variables globales */

XCPB *Xcpb;
GRECT *Work;
CPXNODE *head;
CPXINFO	cpxinfo={cpx_call,cpx_draw,cpx_wmove,cpx_timer,cpx_key,cpx_button,0,0,0,cpx_close};
char *spec_types[]={"Lec","Ecr"};
char *types[]={"  Lecture  ","  Ecriture " };
unsigned char buffer_cmde[10];
unsigned char *buffer_dma;
int ed_objc,new_objc,ed_pos,new_pos;
int type;
int vol;
int etat_lecture;				/* ‚tat PLAY PAUSE ou STOP d‚termin‚ par cpx_timer() */
int mode_lecture;				/* CONTINU SCAN REPEAT ou RANDOM */
int mode_time=0;
long timer,marque=0;
long duree,duree_totale;		/* en 1/100 S |                               */
int total_track;				/*            | => d‚termin‚ dans cpx_timer() */
int mem_track;
long tab_time_track[MAX_TRACK];	/* format BCD MN:SS.XX */
char tab_rnd_track[MAX_TRACK];
CPXINFO* CDECL cpx_init(XCPB *xcpb)

{
	Xcpb=xcpb;
	return(&cpxinfo);
}

int CDECL cpx_call(GRECT *work)

{
	OBJECT *dma_tree;
	TEDINFO *t_edinfo;
	BITBLK *b_itblk;
	int x,y,m,k;
	register int i,canal;
	if(!(Xcpb->SkipRshFix))
	{
		(*Xcpb->rsh_fix)(NUM_OBS,NUM_FRSTR,NUM_FRIMG,NUM_TREE,rs_object,rs_tedinfo,rs_strings,rs_iconblk,rs_bitblk,rs_frstr,rs_frimg,rs_trindex,rs_imdope);
		b_itblk=rs_object[MENULOGO].ob_spec.bitblk;
		b_itblk->bi_pdata=(int *)image_logo;
		b_itblk=rs_object[MENUBEJECT+1].ob_spec.bitblk;
		b_itblk->bi_pdata=(int *)image_eject;
		b_itblk=rs_object[MENUBSTOP+1].ob_spec.bitblk;
		b_itblk->bi_pdata=(int *)image_stop;
		b_itblk=rs_object[MENUBPLAY+1].ob_spec.bitblk;
		b_itblk->bi_pdata=(int *)image_play;
		b_itblk=rs_object[MENUBPAUSE+1].ob_spec.bitblk;
		b_itblk->bi_pdata=(int *)image_pause;
		b_itblk=rs_object[MENUBREW+1].ob_spec.bitblk;
		b_itblk->bi_pdata=(int *)image_rew;
		b_itblk=rs_object[MENUBFF+1].ob_spec.bitblk;
		b_itblk->bi_pdata=(int *)image_ff;
		rs_object[MENUBOXVOL].ob_y+=4;
		rs_object[MENUBOXVOL].ob_height-=8;
		rs_object[MENUSVOL].ob_height-=8;
		rs_object[MENUBTYPE].ob_y+=6;
		rs_object[MENUBTYPE].ob_height-=4;
		rs_object[MENUBSCAN].ob_y+=8;
		rs_object[MENUBSCAN].ob_height-=4;
		rs_object[MENUBREPEAT].ob_y+=8;
		rs_object[MENUBREPEAT].ob_height-=4;
		rs_object[MENUBRANDOM].ob_y+=8;
		rs_object[MENUBRANDOM].ob_height-=4;
		rs_object[MENUBTIME].ob_y+=8;
		rs_object[MENUBTIME].ob_height-=4;
		rs_object[MENUBSAUVE].ob_y+=8;
		rs_object[MENUBANNULE].ob_y+=4;
	}
	graf_mkstate(&x,&y,&m,&k);
	if(m & 2)	/* touche de droite souris */
	{	/* mode test CD-ROM */
		rs_object[MENUBOXVOL].ob_flags |= HIDETREE;
		rs_object[MENUBOXVOL].ob_flags &= ~TOUCHEXIT;
		rs_object[MENUSVOL].ob_flags |= HIDETREE;
		rs_object[MENUSVOL].ob_flags &= ~TOUCHEXIT;
		rs_object[MENUCMDE].ob_flags &= ~HIDETREE;
		rs_object[MENUCMDE].ob_flags |= EDITABLE;
		rs_object[MENUBTYPE].ob_flags &= ~HIDETREE;
		rs_object[MENUBTYPE].ob_flags |= TOUCHEXIT;
		rs_object[MENUBTYPE].ob_y-=6;
		rs_object[MENUSTATUS].ob_flags &= ~HIDETREE;
	}
	if((vdi_handle=Xcpb->handle)>0)
	{
		v_opnvwk(work_in,&vdi_handle,work_out);
		if(vdi_handle<=0 || (head=get_header(ID_CPX))==0)
			return(0);
	}
	else
		return(0);
	if(work_out[13]<16)	/* nbre de couleurs */
	{
		t_edinfo=(TEDINFO *)rs_object[MENUAFFTRACK+1].ob_spec.tedinfo;
		t_edinfo->te_color=0x1000;
		t_edinfo=(TEDINFO *)rs_object[MENUAFFTRACK+2].ob_spec.tedinfo;
		t_edinfo->te_color=0x1000;
	}
	buffer_dma=(unsigned char *)-1L;
	if((long)Mxalloc(-1,0)!=-32L)
	{
		if((long)Mxalloc(-1,0)>=TAILLE_BUFFER)
			buffer_dma=(unsigned char *)Mxalloc(TAILLE_BUFFER,0);
	}
	else
	{
		if((long)Malloc(-1)>=TAILLE_BUFFER)
			buffer_dma=(unsigned char *)Malloc(TAILLE_BUFFER);
	}
	if((long)buffer_dma<=0)
		return(0);
	rs_object[MENUBOX].ob_x=work->g_x;
	rs_object[MENUBOX].ob_y=work->g_y;
	rs_object[MENUBOX].ob_width=work->g_w;
	rs_object[MENUBOX].ob_height=work->g_h;
	type=0;
	vol=(int)soundcmd(LTGAIN,-1)>>4;
	vol=volume(1,15);
	raz_timer();
	total_track=MAX_TRACK;
	rnd_track(0,1);					/* init tableau flag lecture track al‚atoire */ 
	etat_lecture=STOP;
	mode_lecture=CONTINU;
	duree=duree_totale=0;
	mem_track=total_track=0;
	canal=*((int *)head->cpxhead.buffer);
	if(canal<0 || canal>7)
		canal=0;
	t_edinfo=(TEDINFO *)rs_object[MENUCANAL].ob_spec.tedinfo;
	t_edinfo->te_ptext[0]=(char)canal+'0';
	t_edinfo=(TEDINFO *)rs_object[MENUINFO].ob_spec.tedinfo;
	t_edinfo->te_ptext[0]=0;
	for(i=0;i<5;i++)
	{
		if(!inquiry(canal))			/* infos CD-ROM */
		{
			for(i=0;i<30 && i<buffer_cmde[4]-8 && (t_edinfo->te_ptext[i]=buffer_dma[i+8])!=0;i++);
			t_edinfo->te_ptext[i]=0;
			if(buffer_dma[0]!=5)
				form_alert(1,"[1][Le p‚riph‚rique SCSI|s‚lectionn‚ n'est pas|un CD-ROM][Continuer]");
		}
	}
	t_edinfo=(TEDINFO *)rs_object[MENUCAPA].ob_spec.tedinfo;
	t_edinfo->te_ptext[0]=0;
	t_edinfo=(TEDINFO *)rs_object[MENUSTATUS].ob_spec.tedinfo;
	t_edinfo->te_ptext[0]=0;
	t_edinfo=(TEDINFO *)rs_object[MENUCMDE].ob_spec.tedinfo;
	t_edinfo->te_ptext[0]=0;
	t_edinfo=rs_object[MENUBTYPE].ob_spec.tedinfo;
	t_edinfo->te_ptext=spec_types[type];
	if((dma_tree=adr_tree(TREE2))!=0)
	{
		t_edinfo=(TEDINFO *)dma_tree[DMAECR].ob_spec.tedinfo;
		t_edinfo->te_ptext[0]=0;
	}
	ed_pos=ed_objc=0;
	cpx_draw(work);
	ed_objc=MENUTRACK;
	objc_edit(rs_object,ed_objc,0,&ed_pos,ED_INIT);
	new_objc=ed_objc;
	new_pos=ed_pos;
	Work=work;
	(*Xcpb->Set_Evnt_Mask)(MU_KEYBD|MU_BUTTON|MU_TIMER,0L,0L,ITEMPS);
	return(1);					/* le CPX n'est pas termin‚ */
}

void CDECL cpx_draw(GRECT *clip)

{
	aff_objc(0,clip);
}

void CDECL cpx_wmove(GRECT *work)

{
	rs_object[MENUBOX].ob_x=work->g_x;
	rs_object[MENUBOX].ob_y=work->g_y;
	rs_object[MENUBOX].ob_width=work->g_w;
	rs_object[MENUBOX].ob_height=work->g_h;
}

void CDECL cpx_timer(int *event)

{
	static unsigned char sauve_buffer_cmde[10];
	static int old_status=-1;
	static long old_all_time=-1;
	register TEDINFO *t_edinfo;
	register char *p;
	long nb_sec,taille_sec;
	int status,play_track,all_track;
	long time_track,play_time,all_time,scan_debut,scan_fin;
	register long taille,hz_200,a,b;
	register int i,ret,err,canal;
	if(*event);
	hz_200=Supexec(lecture_hz_200);
	if(timer-hz_200<=0)
	{
		timer+=200;							/* 1 seconde */
		if(timer-hz_200<=0)
			timer=hz_200+200;				/* pas d'appel … cpx_timer > 1 S */
		for(i=0;i<10;sauve_buffer_cmde[i]=buffer_cmde[i],i++);
		canal=lecture_canal();
		if((!inquiry(canal)) && buffer_dma[0]==5)	/* infos CD-ROM */
		{
			ret=inquiry_tracks(canal,&status,&play_track,&time_track,&play_time,&all_track,&all_time,tab_time_track);
			duree=play_time;					/* variables globales */
			duree_totale=all_time;
			total_track=all_track;
			t_edinfo=(TEDINFO *)rs_object[MENUAFFTRACK+2].ob_spec.tedinfo;
			p=t_edinfo->te_ptext;
			conv_digit(&p[1],play_track);
			conv_digit(&p[10],all_track);
			conv_digit(&p[19],(int)(all_time/6000));
			conv_digit(&p[22],(int)((all_time%6000)/100));
			a=time_track/100;
			if(mode_lecture!=RANDOM || status==3)
				b=play_time/100;
			else								/* temps ‚cout‚ */
			{
				b=0;
				for(i=0;i<all_track;i++)
				{
					if(!tab_rnd_track[i])		/* track ‚cout‚e */
						b+=duree_track(i+1);
				}
				b/=100;
				b+=a;
			}
			if(mode_time && status!=3)
			{
				a=(fin_track(play_track)-play_time)/100;
				b=(all_time/100)-b;				/* temps restant */
			}
			conv_digit(&p[4],(int)(a/60));
			conv_digit(&p[7],(int)(a%60));
			conv_digit(&p[13],(int)(b/60));
			conv_digit(&p[16],(int)(b%60));
			switch(status)
			{
			case 0:
				if(etat_lecture!=PLAY)
				{
					change_objc(MENUBSTOP,NORMAL,Work);
					change_objc(MENUBPLAY,SELECTED,Work);
					change_objc(MENUBPAUSE,NORMAL,Work);
					etat_lecture=PLAY;
					init_codec(1);
				}
				break;
			case 1:
			case 2:
				if(etat_lecture!=PAUSE)
				{
					change_objc(MENUBSTOP,NORMAL,Work);
					change_objc(MENUBPLAY,NORMAL,Work);
					change_objc(MENUBPAUSE,SELECTED,Work);
					etat_lecture=PAUSE;
					init_codec(0);
				}
				break;				
			default:
				if(etat_lecture!=STOP)
				{
					if(ret)
						err=ret;
					else
					{
						switch(mode_lecture)
						{
						case SCAN:
							if(mem_track<all_track)
							{
								mem_track++;
								calcul_scan(mem_track,&scan_debut,&scan_fin);
								if((err=play_audio(canal,1,0,scan_debut))==0)
									err=stop_audio(canal,0,scan_fin);
								p[1]='S';					/* affichage track */ 
								p[2]='C';
							}
							else
								err=-1;						/* fin de disque => stop */
							break;
						case REPEAT:
							if((err=play_audio(canal,1,0,debut_track(mem_track)))==0)
							{
							 	if(mem_track<all_track)		/* programme un arrˆt */
									err=stop_audio(canal,0,fin_track(mem_track)-20);
							}
							p[1]='R';						/* affichage track */ 
							p[2]=' ';
							break;
						case RANDOM:
							if((mem_track=rnd_track(mem_track,0))!=0)
							{
								if((err=play_audio(canal,1,0,debut_track(mem_track)))==0)
								{
								 	if(mem_track<all_track)		/* programme un arrˆt */
										err=stop_audio(canal,0,fin_track(mem_track)-20);
								}
								p[1]=p[2]='X';					/* affichage track */
							}
							else
								err=-1;							/* disque totalement ‚cout‚ => stop */
							break;
						default:
							err=-1;
						}
					}
					if(err)
					{
						change_objc(MENUBSTOP,SELECTED,Work);
						change_objc(MENUBPLAY,NORMAL,Work);
						change_objc(MENUBPAUSE,NORMAL,Work);
						change_objc(MENUBSCAN,NORMAL,Work);
						change_objc(MENUBREPEAT,NORMAL,Work);
						change_objc(MENUBRANDOM,NORMAL,Work);
						mode_lecture=CONTINU;
						etat_lecture=STOP;
						init_codec(0);
					}
				}
			}
			aff_objc(MENUAFFTRACK,Work);
			if(ret || status!=old_status || all_time!=old_all_time )
			{
				t_edinfo=(TEDINFO *)rs_object[MENUCAPA].ob_spec.tedinfo;
				if(ret || read_capacity(canal,&nb_sec,&taille_sec))
					t_edinfo->te_ptext[0]=0;
				else
				{
					taille=(nb_sec*taille_sec)/1000000L;
					if(taille>9999)
						taille=9999;
					conv_int_deci(t_edinfo->te_ptext,(int)taille);
				}
				aff_objc(MENUCAPA,Work);
				old_status=status;
				old_all_time=all_time;
			}
		}
		for(i=0;i<10;buffer_cmde[i]=sauve_buffer_cmde[i],i++);
	}
}

void CDECL cpx_key(int kstate,int key,int *event)

{
	register int i,dial;
	register TEDINFO *t_edinfo;
	if(kstate);
	if(*event);
	if((key & 0xff)==13)
	{
		if(rs_object[MENUCMDE].ob_flags & HIDETREE)
		{
			if(total_track)
			{
				t_edinfo=(TEDINFO *)rs_object[MENUTRACK].ob_spec.tedinfo;
				i=0;
				if(t_edinfo->te_ptext[0]!=0)
				{
					i=t_edinfo->te_ptext[0] & 0xf;
					if(t_edinfo->te_ptext[1]!=0)
					{
						i*=10;
						i+=(t_edinfo->te_ptext[1] & 0xf);
					}
				}
				if(i>total_track)
					i=total_track;
				if(i<1)
					i=1;
				duree=debut_track(i);
				etat_lecture=PAUSE;		/* for‡age pour play() */
				rs_object[MENUBPLAY].ob_state &= ~SELECTED;
				play();
				key=0;					/* touche trait‚e */
			}
		}
		else
			test_cd_rom();				/* mode test */
	}
	dial=form_keybd(rs_object,ed_objc,ed_objc,key,&new_objc,&key);
	if(!key && dial)
	{
		if(new_objc)
		{
			t_edinfo=(TEDINFO *)rs_object[new_objc].ob_spec.tedinfo;
			for(i=0;t_edinfo->te_ptext[i];i++);
			new_pos=i;				/* curseur en fin de champ */
		}
	}
	else
	{
		if(rs_object[ed_objc].ob_flags & EDITABLE)
		{	/* si le formulaire un champ ‚ditable */
			switch(key & 0xff00)
			{
			case 0x6100:			/* undo */
				eject_();
				key=0;				/* touche trait‚e */
				break;
			case 0x7300:			/* ctrl + gauche */
				new_objc=ed_objc;	/* mˆme champ */
				new_pos=0;			/* curseur … gauche */
				key=0;				/* code trait‚ */
				break;
			case 0x7400:			/* ctrl + droite */
				new_objc=ed_objc;	/* mˆme champ */
				key=0;				/* touche trait‚e */
				t_edinfo=(TEDINFO *)rs_object[new_objc].ob_spec.tedinfo;
				for(i=0;t_edinfo->te_ptext[i];i++);
				new_pos=i;			/* curseur en fin de champ */
			}
		}
		switch(key & 0xff)			/* ASCII uniquement */
		{
		case 'O':					/* eject */
		case 'o':
			eject_();
			key=0;					/* touche trait‚e */
			break;
		case 'S':					/* stop */
		case 's':
			stop();
			key=0;					/* touche trait‚e */
			break;
		case 'P':					/* play */
		case 'p':
			play();
			key=0;					/* touche trait‚e */
			break;
		case ' ':					/* pause */
			pause();
			key=0;					/* touche trait‚e */
			break;
		case '-':
			rew(1);					/* << */
			key=0;					/* touche trait‚e */
			break;
		case '+':
			ff();					/* >> */
			key=0;					/* touche trait‚e */
		}
	}
	if(key>0)
	{
		objc_edit(rs_object,ed_objc,key,&ed_pos,ED_CHAR);	/* ‚dite le champ de texte courant */
		new_objc=ed_objc;
		new_pos=ed_pos;
	}
	if(dial)						/* si 0 => new_objc contient l'objet EXIT */
		deplacement_curseur();
	else
	{
		change_objc(new_objc,NORMAL,Work);
		*event=1;					/* fin */
		cpx_close(0);
	}	
}

void CDECL cpx_button(MRETS *mrets,int nclicks,int *event)

{
	GRECT menu;
	register TEDINFO *t_edinfo;
	register int i,j,ret,objc_clic,pos_clic;
	int x,y,m,k,xoff,yoff,attrib[10];
	if((objc_clic=objc_find(rs_object,0,2,mrets->x,mrets->y))>=0)
	{
		if(form_button(rs_object,objc_clic,nclicks,&new_objc))
		{
			if(new_objc>0)
			{
				objc_offset(rs_object,objc_clic,&xoff,&yoff);
				t_edinfo=(TEDINFO *)rs_object[objc_clic].ob_spec.tedinfo;
				vqt_attributes(vdi_handle,attrib);
				/* attrib[8] = largeur du cadre des caractŠres */
				for(i=0;t_edinfo->te_ptmplt[i];i++);	/* longueur chaine masque */
				if((pos_clic=rs_object[objc_clic].ob_width-i*attrib[8])>=0)
				{
					switch(t_edinfo->te_just)
					{
					case TE_RIGHT: 			/* justifi‚ … droite */
						pos_clic=mrets->x-xoff-pos_clic;
						break;
					case TE_CNTR:			/* centr‚ */
						pos_clic=mrets->x-xoff-pos_clic/2;
						break;
					case TE_LEFT:			/* justifi‚ … gauche */
					default:
						pos_clic=mrets->x-xoff;
					}
				}
				else
					pos_clic=mrets->x-xoff;
				new_pos=-1;
				pos_clic/=attrib[8];		/* position caractŠre cliqu‚ */
				j=-1;
				do
				{
					if(t_edinfo->te_ptmplt[++j]=='_')
						new_pos++;
				}
				while(j<i && j<pos_clic);	/* fin si curseur en fin de chaine ou position caractŠre cliqu‚ */
				if(j>=i)
					new_pos=-1;						/* curseur en fin de chaŒne */
				else
				{
					j--;
					while(t_edinfo->te_ptmplt[++j]!='_' && j<i);
					if(j>=i)
						new_pos=-1;					/* curseur en fin de chaŒne */
				}
				for(i=0;t_edinfo->te_ptext[i];i++);	/* longueur chaine texte */
				if(new_pos<0 || i<new_pos)
					new_pos=i;
			}
			deplacement_curseur();
		}
		else
		{
			switch(objc_clic)
			{
			case MENUBOXVOL:
				graf_mkstate(&x,&y,&m,&k);
				objc_offset(rs_object,MENUSVOL,&xoff,&yoff);
				if(x<xoff)
					vol--;
				else
					vol++;
				if(vol<0)
					vol=0;
				if(vol>15)
					vol=15;
				volume(2,vol);
				break;
			case MENUSVOL:
				wind_update(BEG_MCTRL);
				vol=graf_slidebox(rs_object,MENUBOXVOL,MENUSVOL,0);
				wind_update(END_MCTRL);
				vol*=15;
				vol/=1000;
				volume(2,vol);
				break;
			case MENUBTYPE:
				objc_offset(rs_object,MENUBTYPE,&menu.g_x,&menu.g_y);
				menu.g_w=rs_object[MENUBTYPE].ob_width;
				menu.g_h=rs_object[MENUBTYPE].ob_height;
				ret=(*Xcpb->Popup)(types,2,type,IBM,&menu,Work);
				if((ret>=0) && (ret!=type))
				{
					t_edinfo=rs_object[MENUBTYPE].ob_spec.tedinfo;
					t_edinfo->te_ptext=spec_types[ret];
					aff_objc(MENUBTYPE,Work);
					type=ret;
				}
				break;
			case MENUBEJECT:
			case MENUBEJECT+1:
				eject_();
				break;
			case MENUBSTOP:
			case MENUBSTOP+1:
				stop();
				break;
			case MENUBPLAY:
			case MENUBPLAY+1:
				play();
				break;
			case MENUBPAUSE:
			case MENUBPAUSE+1:
				pause();
				break;
			case MENUBREW:
			case MENUBREW+1:
				rew(nclicks);
				break;
			case MENUBFF:
			case MENUBFF+1:
				ff();
				break;
			case MENUBSCAN:
				scan();
				break;
			case MENUBREPEAT:
				repeat();
				break;
			case MENUBRANDOM:
				rnd();
				break;
			case MENUBTIME:
				rs_object[MENUBTIME].ob_state ^= SELECTED;
				aff_objc(MENUBTIME,Work);
				mode_time^=1;
				attente_fin_clic();
				raz_timer();
				break;	
			case MENUBSAUVE:
				change_objc(MENUBSAUVE,NORMAL,Work);
				if((*Xcpb->XGen_Alert)(SAVE_DEFAULTS))
				{
					*((int *)head->cpxhead.buffer)=lecture_canal();
					if(((*Xcpb->Save_Header)(head))==0)
						(*Xcpb->XGen_Alert)(FILE_ERR);
				}
				break;
			case MENUBANNULE:
				change_objc(MENUBANNULE,NORMAL,Work);
				*event=1;	/* fin */
				cpx_close(0);
			}
		}
	}
}

void CDECL cpx_close(int flag)

{
	int x,y,m,k;
	if(flag);
	objc_edit(rs_object,ed_objc,0,&ed_pos,ED_END);
	graf_mkstate(&x,&y,&m,&k);
	if(!(m & 2))	/* touche de droite souris */
	{
		init_codec(0);
		volume(0,0);
	}
	if(etat_lecture==PLAY
	 && (rs_object[MENUBPLAY].ob_state & SELECTED)
	 && mode_lecture!=CONTINU)
		stop_end_disk(lecture_canal());
	if((long)buffer_dma>=0)
		Mfree(buffer_dma); 
	v_clsvwk(vdi_handle);
}

OBJECT *adr_tree(int no_arbre)

{
	register int i,arbre;
	if(!no_arbre)
		return(rs_object);
	for(i=arbre=0;i<NUM_OBS;i++)
	{
		if(rs_object[i].ob_flags & LASTOB)
		{
			arbre++;
			if(arbre==no_arbre)
				return(&rs_object[i+1]);
		}
	}
	return(0L);
}

CPXNODE *get_header(long id)

{
	register CPXNODE *p;
	p=(CPXNODE *)(*Xcpb->Get_Head_Node)();	/* pointeur header 1er CPX */
	do
	{
		if(p->cpxhead.cpx_id==id)
			return(p);
	}
	while(p->vacant && (p=p->next)!=0);		/* plus de headers */
	return(0L);
}

void change_objc(int objc,int state,GRECT *clip)

{
	rs_object[objc].ob_state=state;
	aff_objc(objc,clip);
}

void aff_objc(int objc,GRECT *clip)

{
	register GRECT *rect;
	register int curseur=0;
	wind_update(BEG_UPDATE);
	if(objc==MENUBOX || (!(rs_object[MENUCMDE].ob_flags & HIDETREE) && (objc==MENUCAPA || objc==MENUAFFTRACK)))
	{
		objc_edit(rs_object,ed_objc,0,&ed_pos,ED_END);		/* efface le curseur */
		curseur=1;
	}
	rect=(GRECT *)(*Xcpb->GetFirstRect)(clip);
	while(rect)
	{
		objc_draw(rs_object,objc,2,PTRS(rect));
		rect=(GRECT *)(*Xcpb->GetNextRect)();
	}
	if(curseur)
		objc_edit(rs_object,ed_objc,0,&ed_pos,ED_END);		/* affiche le curseur */
	wind_update(END_UPDATE);
}

void deplacement_curseur(void)

{
	if(new_objc>0 && (ed_objc!=new_objc || ed_pos!=new_pos))
	{
		objc_edit(rs_object,ed_objc,0,&ed_pos,ED_END);		/* efface le curseur */
		ed_pos=new_pos;
		objc_edit(rs_object,new_objc,0,&ed_pos,ED_CHAR);	/* positionne le curseur */
		objc_edit(rs_object,new_objc,0,&ed_pos,ED_END);		/* affiche le curseur */
		ed_objc=new_objc;									/* nouveau champ */
		ed_pos=new_pos;										/* nouvelle position curseur */
	}
}

void attente_fin_clic(void)

{
	int x,y,m,k;
	do
		graf_mkstate(&x,&y,&m,&k);
	while(m);
}

void eject_(void)

{
	register int i;
	change_objc(MENUBEJECT,SELECTED,Work);
	graf_mouse(HOURGLASS,(MFORM*)0);
	for(i=0;i<5 && eject(lecture_canal())!=0;evnt_timer(200,0),i++);
	graf_mouse(ARROW,(MFORM*)0);
	attente_fin_clic();
	change_objc(MENUBEJECT,NORMAL,Work);
	mode_lecture=CONTINU;
	raz_timer();
}

void stop(void)

{
	register int ret,canal;
	if(total_track && etat_lecture!=STOP
	 && !(rs_object[MENUBSTOP].ob_state & SELECTED))
	{
		change_objc(MENUBSTOP,SELECTED,Work);
		change_objc(MENUBPLAY,NORMAL,Work);
		change_objc(MENUBPAUSE,NORMAL,Work);
		change_objc(MENUBSCAN,NORMAL,Work);
		change_objc(MENUBREPEAT,NORMAL,Work);
		change_objc(MENUBRANDOM,NORMAL,Work);
		mode_lecture=CONTINU;
		canal=lecture_canal();
		if((ret=test_unit_ready(canal))==0
		 && (ret=stop_audio(canal,0,0))==0)	/* ou utiliser: restore(canal) plus long !!! */
			init_codec(0);
		ana_erreur(ret);
	}
}

void play(void)

{
	register int ret,canal;
	if(total_track && etat_lecture!=PLAY
	 && !(rs_object[MENUBPLAY].ob_state & SELECTED))
	{
		change_objc(MENUBSTOP,NORMAL,Work);
		change_objc(MENUBPLAY,SELECTED,Work);
		change_objc(MENUBPAUSE,NORMAL,Work);
		canal=lecture_canal();
		if(etat_lecture==STOP)
			duree=debut_track(1);
		if((ret=playtime(canal,1,duree,1))==0)
		{
			init_codec(1);
			aff_track();
		}
		else
		{
			change_objc(MENUBSTOP,SELECTED,Work);
			change_objc(MENUBPLAY,NORMAL,Work);
			ana_erreur(ret);
		}
	}
}

void pause(void)

{
	register int ret,i,tps;
	if(etat_lecture==PLAY
	 && !(rs_object[MENUBPAUSE].ob_state & SELECTED))
	{
		change_objc(MENUBSTOP,NORMAL,Work);
		change_objc(MENUBPLAY,NORMAL,Work);
		change_objc(MENUBPAUSE,SELECTED,Work);
		if(vol)
		{
			tps=250/vol;					/* rampe de vol … 0 de 0,25 seconde */
			for(i=vol-1;i>=0;evnt_timer(tps,0),volume(3,i--));
		}
		if((ret=playtime(lecture_canal(),0,duree,1))==0)
		{
			init_codec(0);
			aff_track();
		}
		else
		{
			change_objc(MENUBSTOP,SELECTED,Work);
			change_objc(MENUBPAUSE,NORMAL,Work);
			ana_erreur(ret);
		}
		for(i=1;i<=vol;evnt_timer(10,0),volume(3,i++));
	}
	else
	{
		if(etat_lecture==PAUSE
		 && (rs_object[MENUBPAUSE].ob_state & SELECTED))
			play();
	}
	attente_fin_clic();
}

void rew(int nb_clic)

{
	int x,y,m,k,event=0;
	register int ret,canal;
	register long pos_duree;
	if(total_track)
	{
		change_objc(MENUBREW,SELECTED,Work);
		evnt_timer(100,0);
		graf_mkstate(&x,&y,&m,&k);
		canal=lecture_canal();
		if(etat_lecture==PLAY && m)
		{
			pos_duree=duree;
			do
			{
				pos_duree-=1000;	/* recule de 10 secondes */
				if(pos_duree<debut_track(1))
					pos_duree=debut_track(1);
				ret=playtime(canal,1,pos_duree,0);
				raz_timer();
				cpx_timer(&event);
				evnt_timer(100,0);
				graf_mkstate(&x,&y,&m,&k);
			}
			while(!ret && m);
		}
		else
		{
			if(nb_clic==2)
				ret=cherche_track(-1);
			else
				ret=cherche_track(0);
			attente_fin_clic();
		}
		change_objc(MENUBREW,NORMAL,Work);
		ana_erreur(ret);
	}
}

void ff(void)

{
	int x,y,m,k,event=0;
	register int ret,canal;
	register long pos_duree;
	if(total_track)
	{
		change_objc(MENUBFF,SELECTED,Work);
		evnt_timer(100,0);
		graf_mkstate(&x,&y,&m,&k);
		canal=lecture_canal();
		if(etat_lecture==PLAY && m)
		{
			pos_duree=duree;
			do
			{
				pos_duree+=1000;	/* avance de 10 secondes */
				if(pos_duree>duree_totale)
					pos_duree=duree_totale;
				ret=playtime(canal,1,pos_duree,0);
				raz_timer();
				cpx_timer(&event);
				evnt_timer(100,0);
				graf_mkstate(&x,&y,&m,&k);
			}
			while(!ret && m);
		}
		else
		{
			ret=cherche_track(1);	
			attente_fin_clic();
		}
		change_objc(MENUBFF,NORMAL,Work);
		ana_erreur(ret);
	}
}

void scan(void)

{
	register int ret,canal;
	if(total_track)
	{
		canal=lecture_canal();
		rs_object[MENUBSCAN].ob_state ^= SELECTED;
		aff_objc(MENUBSCAN,Work);
		if(rs_object[MENUBSCAN].ob_state & SELECTED)
		{
			mode_lecture=SCAN;
			change_objc(MENUBREPEAT,NORMAL,Work);
			change_objc(MENUBRANDOM,NORMAL,Work);
			if(etat_lecture==STOP)
				duree=debut_track(1);
			else
				duree=debut_track(calcul_track());
			if((ret=playtime(canal,1,duree,1))==0)
			{
				init_codec(1);
				aff_track();
			}
			ana_erreur(ret);
		}
		else
		{
			mode_lecture=CONTINU;
			if(etat_lecture==PLAY && (rs_object[MENUBPLAY].ob_state & SELECTED))
				ana_erreur(stop_end_disk(canal));
		}
		attente_fin_clic();
	}
}

void repeat(void)

{
	register int canal;
	if(total_track)
	{
		canal=lecture_canal();
		rs_object[MENUBREPEAT].ob_state ^= SELECTED;
		aff_objc(MENUBREPEAT,Work);
		if(rs_object[MENUBREPEAT].ob_state & SELECTED)
		{
			mode_lecture=REPEAT;
			change_objc(MENUBSCAN,NORMAL,Work);
			change_objc(MENUBRANDOM,NORMAL,Work);
			if(etat_lecture==PLAY && (rs_object[MENUBPLAY].ob_state & SELECTED))
				ana_erreur(stop_end_track(canal));
		}
		else
		{
			mode_lecture=CONTINU;
			if(etat_lecture==PLAY && (rs_object[MENUBPLAY].ob_state & SELECTED))
				ana_erreur(stop_end_disk(canal));
		}
		attente_fin_clic();
	}
}

void rnd(void)

{
	register int ret,canal;
	if(total_track)
	{
		canal=lecture_canal();
		rs_object[MENUBRANDOM].ob_state ^= SELECTED;
		aff_objc(MENUBRANDOM,Work);
		if(rs_object[MENUBRANDOM].ob_state & SELECTED)
		{
			mode_lecture=RANDOM;
			change_objc(MENUBSCAN,NORMAL,Work);
			change_objc(MENUBREPEAT,NORMAL,Work);
			switch(etat_lecture)
			{
				case STOP:
					duree=debut_track(rnd_track(0,1));
					break;
				case PLAY:
					duree=debut_track(rnd_track(calcul_track(),1));
			}
			if((ret=playtime(canal,1,duree,1))==0)
			{
				init_codec(1);
				aff_track();
			}
			ana_erreur(ret);
		}
		else
		{
			mode_lecture=CONTINU;
			if(etat_lecture==PLAY && (rs_object[MENUBPLAY].ob_state & SELECTED))
				ana_erreur(stop_end_disk(canal));
		}
		attente_fin_clic();
	}
}

int volume(int choix,int vol)
/* choix 2:modification 1:init 0:r‚init */
/*       3:modification sans affichage */
{
	static flag_codec=0;
	static int codec[2];
	long valeur;
	if((*Xcpb->get_cookie)('_SND',&valeur))
	{
		switch(choix)
		{
		case 0:									/* r‚initialisation */
			if(flag_codec && valeur>=4)			/* FALCON */
			{
				soundcmd(LTGAIN,codec[0]);		/* volume entr‚e gauche */
				soundcmd(RTGAIN,codec[1]);		/* volume entr‚e droite */
				flag_codec=0;
			}
			break;
		case 1:									/* initialisation */	
			if(!flag_codec)
			{
				if(valeur>=4)					/* FALCON */
				{
					codec[0]=(int)soundcmd(LTGAIN,-1);
					codec[1]=(int)soundcmd(RTGAIN,-1);
					flag_codec=1;
					vol=codec[0]>>4;
				}
				rs_object[MENUSVOL].ob_x=(rs_object[MENUBOXVOL].ob_width-rs_object[MENUSVOL].ob_width)*vol/15;
			}
			break;
		default:								/* modification */
			if(flag_codec)
			{
				if(choix==2)
				{
					rs_object[MENUSVOL].ob_x=(rs_object[MENUBOXVOL].ob_width-rs_object[MENUSVOL].ob_width)*vol/15;
					aff_objc(MENUBOXVOL,Work);
				}
				if(valeur>=4)					/* FALCON */
				{
					soundcmd(LTGAIN,vol<<4);	/* volume entr‚e gauche */
					soundcmd(RTGAIN,vol<<4);	/* volume entr‚e droite */
				}
			}
		}
	}
	return(vol);
}

int cherche_track(int sens)

{
	int event=0;
	register int i,ret=0,find_track,play_track;
	raz_timer();
	cpx_timer(&event);								/* actualise les infos sur le disque */
	play_track=calcul_track();
	if(total_track)
	{
		if(sens>0)
			find_track=play_track+1;
		else
		{
			if(!sens && etat_lecture==PLAY
			 && duree-debut_track(play_track)>150)
				find_track=play_track;				/* lecture d‚but de piste en cours */
			else
				find_track=play_track-1;
		}
		if(find_track<1)
			find_track=1;
		if(find_track>total_track)
			find_track=total_track;
		duree=debut_track(find_track)+20;
		i=0;
		if(etat_lecture==PLAY)
			i=1;
		ret=playtime(lecture_canal(),i,duree,0);	/* lecture/pause d‚but de piste demand‚e */
		raz_timer();
		cpx_timer(&event);
	}
	return(ret);
}

int playtime(int device,int play_pause,long start_time,int test_unit)

{
	long start_scan,end_scan;
	register int i,track,ret=2;
	for(track=0;track<total_track && debut_track(track+1)<=start_time;track++);
	if(play_pause && mode_lecture==SCAN)
	{
		calcul_scan(track,&start_scan,&end_scan);
		if(start_time<start_scan || start_time>end_scan)
			start_time=start_scan;
	}
	for(i=0;i<5 && ret==2;i++)
	{ 
		ret=0;
		if(test_unit)
			ret=test_unit_ready(device);
		if(!ret)
			ret=play_audio(device,play_pause,0,start_time);
		if(ret==2)
		{
			graf_mouse(HOURGLASS,(MFORM*)0);
			evnt_timer(1000,0);
		}
	}
	if(!ret && play_pause)
	{
		switch(mode_lecture)
		{
		case SCAN:
			mem_track=track;		/* m‚morise pour cpx_timer SCAN */
			calcul_scan(track,&start_scan,&end_scan);
			ret=stop_audio(device,0,end_scan);
			break;
		case REPEAT:
		case RANDOM:
			mem_track=track;		/* m‚morise pour cpx_timer REPEAT & RANDOM */
			if(track<total_track)	/* programme un arrˆt */
				ret=stop_audio(device,0,fin_track(track)-20);
		}
	}
	graf_mouse(ARROW,(MFORM*)0);
	return(ret);
}

int stop_end_track(int device)

{
	register int track,ret=0;
	track=calcul_track();
	mem_track=track;				/* m‚morise pour cpx_timer REPEAT & RANDOM */
	if(track<total_track)			/* programme un arrˆt */
		ret=stop_audio(device,0,fin_track(track)-20);
	return(ret);
}

int stop_end_disk(int device)

{
	return(stop_audio(device,-1,0));
}

void ana_erreur(int ret)

{
	static char message1[]="[1][Le CD-ROM ne r‚pond pas|(cable SCSI non connect‚|au mauvais num‚ro)| |Commande $00112233445566778899][Annuler]";
	static char message2[]="[1][Le CD-ROM n'est pas prˆt|(disque absent ou inconnu)| |Commande $00112233445566778899][Annuler]";
	static char message3[]="[1][Erreur -00000| |Commande $00112233445566778899][Annuler]";
	register int i;
	switch(ret)
	{
	case 0:
		break;
	case -1:
		for(i=0;i<10;conv_hexa(&message1[84+i*2],(int)buffer_cmde[i]),i++);
		form_alert(1,message1);
		break;
	case 2:
		for(i=0;i<10;conv_hexa(&message2[68+i*2],(int)buffer_cmde[i]),i++);
		form_alert(1,message2);
		break;
	default:
		message3[11]=' ';
		if(ret<0)
		{
			ret=-ret;
			message3[11]='-';
		}
		conv_int_deci(&message3[12],ret);
		for(i=0;i<10;conv_hexa(&message3[30+i*2],(int)buffer_cmde[i]),i++);
		form_alert(1,message3);
	}
}

int lecture_canal(void)

{
	register int canal;
	TEDINFO *t_edinfo;
	t_edinfo=(TEDINFO *)rs_object[MENUCANAL].ob_spec.tedinfo;
	canal=(int)t_edinfo->te_ptext[0] & 0xf;
	if(canal>7)
	{
		canal=0;
		t_edinfo->te_ptext[0]='0';
		aff_objc(MENUCANAL,Work);
	}
	return(canal);
}

void test_cd_rom(void)

{
	GRECT work;
	TEDINFO *t_edinfo;
	OBJECT *dma_tree;
	register char *p;
	register void *sauve_ssp;
	register int i,j,err,ret,canal,long_cmde,long_dma;
	canal=lecture_canal();
	t_edinfo=(TEDINFO *)rs_object[MENUCMDE].ob_spec.tedinfo;
	p=t_edinfo->te_ptext;
	for(err=i=0;i<t_edinfo->te_txtlen-1 && p[i];i++)
	{
		if(!((p[i]>='0' && p[i]<='9') || (p[i]>='A' && p[i]<='F')))
			err=1;
	}
	if(err || (i!=12 && i!=20))
		Cconout(7);
	else
	{
		raz_buffer_cmde();
		long_cmde=i>>1;
		for(i=j=0;j<long_cmde;i+=2,j++)
		{
			if(p[i]>='0' && p[i]<='9')
				buffer_cmde[j]=(p[i] & 0xf)<<4;
			else
				buffer_cmde[j]=(p[i]-'A'+10)<<4;
			if(p[i+1]>='0' && p[i+1]<='9')
				buffer_cmde[j]+=(p[i+1] & 0xf);
			else
				buffer_cmde[j]+=(p[i+1]-'A'+10);
		}
		if(!type)
		{
			t_edinfo=(TEDINFO *)rs_object[MENUSTATUS].ob_spec.tedinfo;
			for(i=0;i<(t_edinfo->te_txtlen-1)/2;buffer_dma[i++]=0);
			sauve_ssp=(void *)Super(0L);
			ret=Scsi_read(canal,(int)buffer_cmde[4],long_cmde,buffer_dma,buffer_cmde);
			Super(sauve_ssp);
			if(ret==2)
				ret=request_sense(canal);
			aff_status();
		}
		else
		{
			if((dma_tree=adr_tree(TREE2))!=0)
			{
				wind_get(0,WF_WORKXYWH,ELTS(&work));
				wind_update(BEG_UPDATE);
				form_center(dma_tree,ELTS(&work));
				form_dial(FMD_START,0,0,0,0,ELTS(work));
				objc_draw(dma_tree,0,2,ELTS(work));
				i=form_do(dma_tree,DMAECR);
				form_dial(FMD_FINISH,0,0,0,0,ELTS(work));
				wind_update(END_UPDATE);
				dma_tree[DMABECR].ob_state &= ~SELECTED;
				dma_tree[DMABANNULE].ob_state &= ~SELECTED;
				if(i==DMABECR)
				{
					t_edinfo=(TEDINFO *)dma_tree[DMAECR].ob_spec.tedinfo;
					p=t_edinfo->te_ptext;
					for(i=0;i<(t_edinfo->te_txtlen-1)/2;buffer_dma[i++]=0);
					for(err=i=0;i<t_edinfo->te_txtlen-1 && p[i];i++)
					{
						if(!((p[i]>='0' && p[i]<='9') || (p[i]>='A' && p[i]<='F')))
							err=1;
					}
					if(err || (i & 1) || i<2)
						Cconout(7);
					else
					{
						long_dma=i>>1;
						for(i=j=0;j<long_dma;i+=2,j++)
						{
							if(p[i]>='0' && p[i]<='9')
								buffer_dma[j]=(p[i] & 0xf)<<4;
							else
								buffer_dma[j]=(p[i]-'A'+10)<<4;
							if(p[i+1]>='0' && p[i+1]<='9')
								buffer_dma[j]+=(p[i+1] & 0xf);
							else
								buffer_dma[j]+=(p[i+1]-'A'+10);
						}
						sauve_ssp=(void *)Super(0L);
						ret=Scsi_write(canal,long_dma,long_cmde,buffer_dma,buffer_cmde);
						Super(sauve_ssp);
						if(ret==2)
							ret=request_sense(canal);
						aff_status();
					}
				}
			}
		}
		ana_erreur(ret);
	}
}

void aff_status(void)

{
	TEDINFO *t_edinfo;
	int x,y,m,k;
	register char *p;
	register int i,j;
	t_edinfo=(TEDINFO *)rs_object[MENUSTATUS].ob_spec.tedinfo;
	p=t_edinfo->te_ptext;
	j=0;
	graf_mkstate(&x,&y,&m,&k);
	if(m & 2)	/* touche de droite */
		j=(t_edinfo->te_txtlen-1)/2;
	for(i=0;i<(t_edinfo->te_txtlen-1)/2 && j<buffer_cmde[4];conv_hexa(p,(int)buffer_dma[j++]),i++,p+=2);
	*p=0;
	aff_objc(MENUSTATUS,Work);
}

void aff_track(void)

{
	int event=0;
	evnt_timer(500,0);	/* tempo car qqfois le d‚but de piste est d‚clar‚ … la fin de la pr‚c‚dente ?? */
	raz_timer();
	cpx_timer(&event);	/* affichage forc‚ */
}

long debut_track(int track)

{
	if(!track || track>total_track)
		return(0);
	return(tab_time_track[track-1]);
}

long fin_track(int track)

{
	if(track<total_track)
		return(tab_time_track[track]);
	return(duree_totale);
}

long duree_track(int track)

{
	register long duree;
	if(!track)
		return(0);
	else
	{
		duree=-tab_time_track[track-1];
		if(track<total_track)
			duree+=tab_time_track[track];
		else
			duree+=duree_totale;
	}
	return(duree);
}

int calcul_track(void)

{
	register int i;
	for(i=0;i<total_track && tab_time_track[i]<=duree+20;i++);
	return(i);
}

void calcul_scan(int track,long *scan_debut,long *scan_fin)

{
	register long debut;
	mem_track=track;					/* m‚morise pour cpx_timer SCAN */
	debut=debut_track(track);
	if(duree_track(track)>=7050)		/* 70 S */
	{
		*scan_debut=debut+6020;
		*scan_fin=debut+7050;			/* 10 S d'‚coute */
	}
	else
	{
		*scan_debut=debut;
		if(duree_track(track)>=1050)
			*scan_fin=debut+1050;		/* 10 S d'‚coute */
		else
			*scan_fin=debut+duree_track(track);
	}
}

long conv_time(long time)
/* conversion MM SS XX format BCD en centiŠmes de secondes */
{
	return((time & 0xf)+((time>>4) & 0xf)*10L
	 +((time>>8) & 0xf)*100L+((time>>12) & 0xf)*1000L
	 +((time>>16) & 0xf)*6000L+((time>>20) & 0xf)*60000L);
}

int conv_track(int track)
/* conversion format BCD en d‚cimal */
{
	return((track & 0xf)+((track>>4) & 0xf)*10);
}

long conv_bcd_time(long time)

{
	register long minutes,secondes,centiemes;
	minutes=time/6000;
	secondes=(time%6000)/100;
	centiemes=time%100;
	return((centiemes%10)+((centiemes/10)<<4)+((secondes%10)<<8)+((secondes/10)<<12)+((minutes%10)<<16)+((minutes/10)<<20));
}

int conv_bcd_track(int track)

{
	return((track%10)+((track/10)<<4));
}

void conv_digit(char *chaine,int valeur)

{
	if(valeur>99)
		chaine[0]=chaine[1]='?';
	else
	{
		chaine[0]=(char)(valeur/10+16);
		chaine[1]=(char)(valeur%10+16);
	}
}

void conv_int_deci(char *chaine,int valeur)

{
	register int i;
	for(i=4;i>=0;i--)
	{
		chaine[i]=(char)(valeur%10)+'0';
		valeur/=10;
	}
	for(i=0;i<4 && chaine[i]=='0';chaine[i++]=' ');
}

void conv_hexa(char *chaine,int valeur)

{
	*chaine=(char)(valeur>>4);
	if(*chaine<10)
		*chaine+='0';
	else
		*chaine+=('A'-10);
	chaine++;
	*chaine=(char)(valeur & 0xf);
	if(*chaine<10)
		*chaine+='0';
	else
		*chaine+=('A'-10);
}

int rnd_track(int track,int init)

{
	register int i;
	if(init)
	{
		for(i=0;i<total_track;tab_rnd_track[i++]=1);
		track=-1;
	}
	else
	{
		if(track)
			tab_rnd_track[track-1]=0;
	}
	for(i=0;i<total_track && !tab_rnd_track[i];i++);
	if(i<total_track)
	{
		do
			i=(((int)Random() & 255)*total_track)>>8;
		while(i==track-1 || !tab_rnd_track[i]);
		return(i+1);				/* track … ‚couter */
	}
	return(0);						/* disque ‚cout‚ totalement */
}

void init_codec(int choix)
/* choix 1:init 0:r‚init */
{
	static int flag_codec=0;
	static int autorisation=0;
	static int input;
	long valeur;
	register int i,tps,vol;
	if((*Xcpb->get_cookie)('_SND',&valeur)
	 && valeur>=4)								/* FALCON */
	{
		if(!flag_codec && choix)				/* initialisation */
		{
			input=(int)soundcmd(ADCINPUT,-1); 
			if(input)
			{
				vol=(int)soundcmd(LTGAIN,-1)>>4;/* volume entr‚e gauche */
				for(i=vol-1;i>=0;i--)			/* ‚vite un clac */
				{
					evnt_timer(10,0);
					soundcmd(LTGAIN,i<<4);		/* volume entr‚e gauche */
					soundcmd(RTGAIN,i<<4);		/* volume entr‚e droite */
				}
			}
			if(soundcmd(ADDERIN,-1)!=3)
				soundcmd(ADDERIN,3);			/* DAC sur ADC et matrice */
			if(input)
			{
				soundcmd(ADCINPUT,0);			/* ADC sur entr‚e micro */
				autorisation=1;
			}
			if(soundcmd(SETPRESCALE,-1)!=3)
				soundcmd(SETPRESCALE,3); 		/* 50 KHz STE */
			devconnect(0,8,0,0,1);				/* restitution DMA STE */
			if(input && vol)
			{
				tps=250/vol;					/* rampe de 0 … vol de 0,25 seconde */
				for(i=1;i<=vol;i++)
				{
					evnt_timer(tps,0);
					soundcmd(LTGAIN,i<<4);		/* volume entr‚e gauche */
					soundcmd(RTGAIN,i<<4);		/* volume entr‚e droite */
				}
			}
			flag_codec=1;
		}
		if(flag_codec && !choix)				/* r‚initialisation */
		{
			if(autorisation)
				soundcmd(ADCINPUT,input);
			flag_codec=0;
		}
	}
}

void raz_timer(void)

{
	timer=Supexec(lecture_hz_200);
}

long lecture_hz_200(void)

{
	return(*(long *)0x4BA);
}

int test_unit_ready(int device)

{
	register void *sauve_ssp;
	register int ret;
	raz_buffer_cmde();
	sauve_ssp=(void *)Super(0L);
	ret=Scsi_read(device,0,6,buffer_dma,buffer_cmde);
	Super(sauve_ssp);
	return(ret);
}

int restore(int device)

{
	register void *sauve_ssp;
	register int ret;
	raz_buffer_cmde();
	buffer_cmde[0]=1;
	sauve_ssp=(void *)Super(0L);
	ret=Scsi_read(device,0,6,buffer_dma,buffer_cmde);
	Super(sauve_ssp);
	return(ret);
}

int request_sense(int device)	/* retourne erreur derniŠre commande */

{
	static unsigned char buffer_dma[32];
	register void *sauve_ssp;
	register int ret;
	raz_buffer_cmde();
	buffer_cmde[0]=3;
	buffer_cmde[4]=32;
	sauve_ssp=(void *)Super(0L);
	ret=Scsi_read(device,32,6,buffer_dma,buffer_cmde);
	Super(sauve_ssp);
	if(!ret)
	{
		if((ret=(int)buffer_dma[0] & 0x7f)==0x70)
			return((int)buffer_dma[12] & 0x7f);
	}
	return(ret);		
}

int inquiry(int device)			/* renseignements sur le lecteur CD-ROM */

{
	register void *sauve_ssp;
	register int ret;
	raz_buffer_cmde();
	buffer_cmde[0]=0x12;
	buffer_cmde[4]=32;
	sauve_ssp=(void *)Super(0L);
	ret=Scsi_read(device,32,6,buffer_dma,buffer_cmde);
	marque=*((long *)&buffer_dma[8]);
	Super(sauve_ssp);
	return(ret);
}

int mode_sense(int device)

{
	register void *sauve_ssp;
	register int ret;
	raz_buffer_cmde();
	buffer_cmde[0]=0x1a;
	buffer_cmde[4]=16;
	sauve_ssp=(void *)Super(0L);
	ret=Scsi_read(device,16,6,buffer_dma,buffer_cmde);
	Super(sauve_ssp);
	return(ret);
}

int send_diagnostic(int device)

{
	register void *sauve_ssp;
	register int ret;
	raz_buffer_cmde();
	buffer_cmde[0]=0x1d;
	sauve_ssp=(void *)Super(0L);
	ret=Scsi_read(device,0,6,buffer_dma,buffer_cmde);
	Super(sauve_ssp);
	return(ret);
}

long read_capacity(int device,long *nb_sector,long *size_sector)

{
	register void *sauve_ssp;
	register long ret;
	raz_buffer_cmde();
	buffer_cmde[0]=0x25;
	sauve_ssp=(void *)Super(0L);
	ret=(long)Scsi_read(device,8,10,buffer_dma,buffer_cmde);
	Super(sauve_ssp);
	*nb_sector=*(long *)buffer_dma;
	*size_sector=*((long *)&buffer_dma[4]);
	return(ret);
}

/* commandes audio CD-ROM NEC 210 de 0xd8 … 0xdf */
/* (… partir de 0x40 sur un TOSHIBA, SONY, ou PIONNER) */

int play_audio(int device,int play_pause,int start_track,long start_time)

{
	register void *sauve_ssp;
	register int ret;
	raz_buffer_cmde();
	sauve_ssp=(void *)Super(0L);
	if(marque=='NEC ')
	{
		buffer_cmde[0]=0xd8;
		buffer_cmde[1]=(unsigned char)play_pause;			/* 1:play 0:pause */
		if(start_track)
		{
			buffer_cmde[2]=(unsigned char)conv_bcd_track(start_track);
			buffer_cmde[9]=0x80;							/* mode track */
		}
		else
		{
			start_time=conv_bcd_time(start_time);
			if((start_time & 0xffL)>0x74L)				/* bug CD-ROM NEC 210 entre 75 et 99 ??? */
				start_time=conv_bcd_time(conv_time(start_time & 0xffff00L)+100);
			buffer_cmde[2]=(unsigned char)(start_time>>16);
			buffer_cmde[3]=(unsigned char)(start_time>>8);
			buffer_cmde[4]=(unsigned char)start_time;	/* format BCD MN:SS.XX */
			buffer_cmde[9]=0x40;						/* mode time */
		}
	}
	else
	{
		if(start_track)
		{
			buffer_cmde[0]=0x48;
			buffer_cmde[4]=(unsigned char)start_track;
			buffer_cmde[7]=0xff;							/* stop track */
			buffer_cmde[5]=1;								/* d‚but index */
			buffer_cmde[8]=0x63;							/* fin index */
		}
		else
		{
			buffer_cmde[0]=0x47;
			buffer_cmde[3]=(unsigned char)(start_time/6000L);			/* minutes */
			buffer_cmde[4]=(unsigned char)((start_time%6000L)/100L);	/* secondes */
			buffer_cmde[5]=(unsigned char)(start_time%100L);			/* centiŠmes */
			buffer_cmde[6]=buffer_cmde[7]=buffer_cmde[8]=0xff;			/* stop_time */
		}
		if(!play_pause)
		{
			if((ret=Scsi_read(device,0,10,buffer_dma,buffer_cmde))==0)
			{
				raz_buffer_cmde();
				buffer_cmde[0]=0x4b;	/* pause on/off en buffer_cmde[8] */
			}
			else
			{
				Super(sauve_ssp);
				return(ret);
			}
		}
	}
	ret=Scsi_read(device,0,10,buffer_dma,buffer_cmde);
	Super(sauve_ssp);
	return(ret);
}

int stop_audio(int device,int stop_track,long stop_time)

{
	register void *sauve_ssp;
	register int ret;
	raz_buffer_cmde();
	sauve_ssp=(void *)Super(0L);
	if(marque=='NEC ')
	{
		buffer_cmde[0]=0xd9;
		buffer_cmde[1]=3;	/* channel 0:rien 1:mono gauche 2:mono droite 3:st‚r‚o 4:inchang‚ */
		if(stop_track)
		{
			if(stop_track!=-1)								/* mode stop annul‚ */
				buffer_cmde[2]=(unsigned char)conv_bcd_track(stop_track);
			buffer_cmde[9]=0x80;							/* mode track */
		}
		else
		{
			if(stop_time)
			{
				stop_time=conv_bcd_time(stop_time);
				if((stop_time & 0xffL)>0x74L)				/* bug CD-ROM NEC 210 entre 75 et 99 ??? */
					stop_time=conv_bcd_time(conv_time(stop_time & 0xffff00L)+100);
				buffer_cmde[2]=(unsigned char)(stop_time>>16);
				buffer_cmde[3]=(unsigned char)(stop_time>>8);
				buffer_cmde[4]=(unsigned char)stop_time;	/* format BCD MN:SS.XX */
				buffer_cmde[9]=0x40;						/* mode time */
			}
		}													/* 0: arrˆt imm‚diat */
	}
	else
	{
		buffer_cmde[0]=0x42;								/* infos piste en cours */
		buffer_cmde[1]=2;
		buffer_cmde[2]=0x40;
		buffer_cmde[3]=1;
		buffer_cmde[8]=48;
		if((ret=Scsi_read(device,48,10,buffer_dma,buffer_cmde))==0)
		{	
			raz_buffer_cmde();
			if(stop_track)
			{
				if(stop_track!=-1)							/* mode stop annul‚ */
				{
					buffer_cmde[0]=0x48;
					buffer_cmde[4]=buffer_dma[6];			/* start track = track courant */
					buffer_cmde[7]=(unsigned char)stop_track;
					buffer_cmde[5]=1;						/* d‚but index */
					buffer_cmde[8]=0x63;					/* fin index */
				}
				else
				{
					buffer_cmde[0]=0x47;
					buffer_cmde[3]=buffer_dma[9];			/* minutes courantes */
					buffer_cmde[4]=buffer_dma[10];			/* secondes courantes */
					buffer_cmde[5]=buffer_dma[11];			/* centiŠmes courants */
					buffer_cmde[6]=buffer_cmde[7]=buffer_cmde[8]=0xff;		/* stop infini */
				}
			}
			else
			{
				if(stop_time)
				{
					buffer_cmde[0]=0x47;
					buffer_cmde[3]=buffer_dma[9];			/* minutes courantes */
					buffer_cmde[4]=buffer_dma[10];			/* secondes courantes */
					buffer_cmde[5]=buffer_dma[11];			/* centiŠmes courants */
					buffer_cmde[6]=(unsigned char)(stop_time/6000L);			/* minutes */
					buffer_cmde[7]=(unsigned char)((stop_time%6000L)/100L);		/* secondes */
					buffer_cmde[8]=(unsigned char)(stop_time%100L);				/* centiŠmes */
				}
				else
					buffer_cmde[0]=0x4e;					/* arrˆt imm‚diat */
			}
		}
		else
		{
			Super(sauve_ssp);
			return(ret);
		}
	}
	ret=Scsi_read(device,0,10,buffer_dma,buffer_cmde);
	Super(sauve_ssp);
	return(ret);
}

int pause_audio(int device)

{
	register void *sauve_ssp;
	register int ret;
	raz_buffer_cmde();
	if(marque=='NEC ')
		buffer_cmde[0]=0xda;
	else
		buffer_cmde[0]=0x4b;	/* pause on/off en buffer_cmde[8] */
	sauve_ssp=(void *)Super(0L);
	ret=Scsi_read(device,0,10,buffer_dma,buffer_cmde);
	Super(sauve_ssp);
	return(ret);
}

int eject(int device)		

{
	register void *sauve_ssp;
	register int ret;
	raz_buffer_cmde();
	sauve_ssp=(void *)Super(0L);
	if(marque=='NEC ')
	{
		buffer_cmde[0]=0xdc;
		ret=Scsi_read(device,0,10,buffer_dma,buffer_cmde);
	}
	else
	{
		buffer_cmde[0]=0x1b;
		buffer_cmde[1]=1;
		buffer_cmde[4]=2;
		ret=Scsi_read(device,0,6,buffer_dma,buffer_cmde);
	}
	Super(sauve_ssp);
	return(ret);
}

int inquiry_tracks(int device,int *status,int *play_track,long *time_track,long *play_time,int *all_track,long *all_time,long *tab_time)

{
	static int nb_track=0,old_status=-1;
	static long tps_total=0;
	static long tab_tps[MAX_TRACK];
	register void *sauve_ssp;
	register int i,j,ret;
	raz_buffer_cmde();
	sauve_ssp=(void *)Super(0L);
	if(marque=='NEC ')
	{
		buffer_cmde[0]=0xdd;											/* infos track en cours */
		buffer_cmde[1]=10;
		ret=Scsi_read(device,10,10,buffer_dma,buffer_cmde);				/* buffer_dma[0]: */
		*status=(int)buffer_dma[0];										/* 0:lecture 1:pause 2:pause lecture 3:aprŠs restore ou stop */
		if(!ret && *status<3)						
		{
			*play_track=conv_track((int)buffer_dma[2]);								/* track en cours format BCD */
			*time_track=conv_time((((long)buffer_dma[4])<<16)+(((long)buffer_dma[5])<<8)+(long)buffer_dma[6]);	/* dur‚e track en cours format BCD MN:SS.XX */
			*play_time=conv_time((((long)buffer_dma[7])<<16)+(((long)buffer_dma[8])<<8)+(long)buffer_dma[9]);	/* dur‚e ‚cout‚e format BCD MN:SS.XX */
		}
		else
		{
			*play_track=0;
			*time_track=*play_time=0;
			if(ret)
			{
				nb_track=0;
				tps_total=0;
				for(i=0;i<MAX_TRACK;tab_tps[i++]=0);
				*status=3;												/* stop */
				old_status=-1;
			}
		}
		if(!ret && *status!=old_status)									/* changement d'‚tat play/pause/stop */
		{
			raz_buffer_cmde();
			buffer_cmde[0]=0xde;										/* infos tracks total */
			buffer_cmde[4]=8;
			if((ret=Scsi_read(device,8,10,buffer_dma,buffer_cmde))==0)
			{
				nb_track=conv_track((int)buffer_dma[1]);							/* nbre track format BCD */
				j=conv_track((int)buffer_dma[0]);						/* track de d‚part format BCD */
				buffer_cmde[1]=1;
				if((ret=Scsi_read(device,8,10,buffer_dma,buffer_cmde))==0)
				{
					tps_total=conv_time((((long)buffer_dma[0])<<16)+(((long)buffer_dma[1])<<8)+(long)buffer_dma[2]);	/* dur‚e totale format BCD MN:SS.XX */
					if(old_status==-1)									/* ancien status: erreur */
					{
						buffer_cmde[1]=2;								/* info dur‚e position tracks au format BCD MN:S.XX */
						i=0;											/* en cas de changement de disque */
						do
						{
							buffer_cmde[2]=(unsigned char)((j%10)+((j/10)<<4));		/* track => format BCD */
							if((ret=Scsi_read(device,8,10,buffer_dma,buffer_cmde))==0)
								tab_tps[i++]=conv_time((((long)buffer_dma[0])<<16)+(((long)buffer_dma[1])<<8)+(long)buffer_dma[2]);
							j++;
						}
						while(!ret && j<=nb_track);
					}
				}
			}
			old_status=*status;
		}
	}
	else
	{
		buffer_cmde[0]=0x42;
		buffer_cmde[1]=2;
		buffer_cmde[2]=0x40;
		buffer_cmde[3]=1;
		buffer_cmde[8]=48;
		ret=Scsi_read(device,48,10,buffer_dma,buffer_cmde);	
		switch(*status=(int)buffer_dma[1])
		{
		case 0x11: *status=0; break;									/* lecture */
		case 0x15: *status=3; break;									/* stop */
		default: *status=1;												/* pause */
		}
		if(!ret && *status<3)						
		{
			*play_track=(int)buffer_dma[6];								/* track en cours */
			*play_time=(((long)buffer_dma[9])*6000L)+(((long)buffer_dma[10])*100L)+(long)buffer_dma[11];	/* dur‚e ‚cout‚e en centiŠmes de S */
			*time_track=(((long)buffer_dma[13])*6000L)+(((long)buffer_dma[14])*100L)+(long)buffer_dma[15];	/* dur‚e track en cours en centiŠmes de S */
		}
		else
		{
			*play_track=0;
			*time_track=*play_time=0;
			if(ret)
			{
				nb_track=0;
				tps_total=0;
				for(i=0;i<MAX_TRACK;tab_tps[i++]=0);
				*status=3;												/* stop */
				old_status=-1;
			}
		}
		if(!ret && *status!=old_status)									/* changement d'‚tat play/pause/stop */
		{
			buffer_cmde[0]=0x43;										/* infos dur‚es tracks */
			buffer_cmde[1]=2;
			buffer_cmde[7]=3;
			buffer_cmde[8]=0x24;
			if((ret=Scsi_read(device,0x324,10,buffer_dma,buffer_cmde))==0)
			{
				nb_track=(int)buffer_dma[3];
				for(i=0,j=(int)buffer_dma[2];j<=nb_track;i++,j++)
					tab_tps[i]=(((long)buffer_dma[i*8+9])*6000L)+(((long)buffer_dma[i*8+10])*100L)+(long)buffer_dma[i*8+11];		
				tps_total=(((long)buffer_dma[i*8+9])*6000L)+(((long)buffer_dma[i*8+10])*100L)+(long)buffer_dma[i*8+11];
			}
			old_status=*status;
		}
	}
	*all_track=nb_track;
	*all_time=tps_total;
	for(i=0;i<nb_track;tab_time[i]=tab_tps[i],i++);
	Super(sauve_ssp);
	return(ret);
}

void raz_buffer_cmde(void)

{
	register int i;
	for(i=0;i<10;buffer_cmde[i++]=0);
}
