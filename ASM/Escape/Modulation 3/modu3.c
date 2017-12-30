/**//**//**//**//**//**//**//**//**//**//**//**//**/
/* DIE SCHEISSE HIER IST MEIN ERSTETES C-DINGENS  */
/* BITTE UM NACHSICHT...                          */
/*                     Fuck it all! Pascal rules! */
/* NO/Escape 06'97                                */
/**//**//**//**//**//**//**//**//**//**//**//**//**/

#include <stdlib.h>
#include <stdio.h>
#include <tos.h>

#define	MUSIC 1


/*** SCREEN OUTPUT ***/
extern 	void 	save_old_res( void *dstadr );
extern 	void 	set_all_vid	( void *srcadr );
extern 	void 	set_scr_adr	( void *scradr );
extern 	void 	set_scp_res	( void *scpdta );
unsigned char scpdata[1000];

/*** FILE FUNCTIONS ***/
long 	load_file( char *filename, void *dstadr );
void 	save_file( char *filename, void *srcadr, long anzbytes);

/*** MOUSE FUNCTIONS ***/
void	setnewmouse( void );
void	setoldmouse( void );

extern	void	vbl_rout1( void );
extern	void	vbl_rout2( void );
extern	void	vbl_rout3( void );
extern	void	vbl_wait( void );
extern	void	memcopy( long anz_long, void *src, void *dst );
extern	void	memclear( long anz_long, void *dst );
extern	long	*evenadr( void *adr );

extern	void	setclipping(long x1,long y1,long x2,long y2);
extern	void	gettrp( long x,long y,long w,long h,void *scradr,void *dst);
extern	void	drawtrp( long x, long y, void *trpdata, void *scradr );
extern	void	copytrp( long x1, long y1, long x2, long y2,
						 long w, long h, void *trp1, void *trp2 );

extern	void	drawshadow(long x1,long y1,long x2,long y2,void *bufadr,void *scradr );
extern	void	clrshadow(long x1,long y1,long x2,long y2,void *bufadr,void *scradr );

extern	void	drawbox(long x1,long y1,long x2,long y2,long color);

extern	void	blendout2( long ypos,void *scradr,void *coltab );
extern	long	darker_color(long color);
extern	void	blend( long par,void *src1,void *src2,void *dest );

extern	void	init_replay( void );
extern	void	deinit_replay( void );
extern	void	play_mod( void *modadr,void *voltab );
extern	void	stop_mod( void );
extern	void	balance( long channel,signed int value );
extern	void	volume( long channel,signed int value );
extern	void	make_surround( long delay );
extern	void	set_interpolation( long on_off );
extern	void	speaker_off( void );
extern	void	speaker_on( void );

extern	void	drawinfocont(long x,long y,long pos,void *trp,void *scradr);
extern	void	drawtext(long x,long y,void *trp,void *txt);
extern	void	drawstring(long x,long y,void *scr,void *str);

extern 	void	basntekk_txt( void );
extern 	void	hardatta_txt( void );
extern 	void	heros_txt( void );
extern 	void	never_txt( void );
extern 	void	newsafe_txt( void );
extern 	void	nobrain_txt( void );
extern 	void	normal_txt( void );
extern 	void	paradise_txt( void );
extern 	void	paretyon_txt( void );
extern 	void	sleeples_txt( void );
extern 	void	smile_txt( void );
extern 	void	sunmon2_txt( void );
extern 	void	where_txt( void );

extern 	int 	light[240][320];

extern	void	background_gfx( void );
extern	void	songicona_gfx( void );
extern	void	songiconb_gfx( void );
extern	void	crediticona_gfx( void );
extern	void	crediticonb_gfx( void );
extern	void	outicona_gfx( void );
extern	void	outiconb_gfx( void );
extern	void	volicona_gfx( void );
extern	void	voliconb_gfx( void );
extern	void	infoicona_gfx( void );
extern	void	infoiconb_gfx( void );
extern	void	greeticona_gfx( void );
extern	void	greeticonb_gfx( void );
extern	void	quiticona_gfx( void );
extern	void	quiticonb_gfx( void );

extern	void	closera_gfx( void );
extern	void	closerb_gfx( void );

extern	void	songwin_gfx( void );
extern	void	song01a_gfx( void );
extern	void	song01b_gfx( void );
extern	void	song02a_gfx( void );
extern	void	song02b_gfx( void );
extern	void	song03a_gfx( void );
extern	void	song03b_gfx( void );
extern	void	song04a_gfx( void );
extern	void	song04b_gfx( void );
extern	void	song05a_gfx( void );
extern	void	song05b_gfx( void );
extern	void	song06a_gfx( void );
extern	void	song06b_gfx( void );
extern	void	song07a_gfx( void );
extern	void	song07b_gfx( void );
extern	void	song08a_gfx( void );
extern	void	song08b_gfx( void );
extern	void	song09a_gfx( void );
extern	void	song09b_gfx( void );
extern	void	song10a_gfx( void );
extern	void	song10b_gfx( void );
extern	void	song11a_gfx( void );
extern	void	song11b_gfx( void );
extern	void	song12a_gfx( void );
extern	void	song12b_gfx( void );
extern	void	song13a_gfx( void );
extern	void	song13b_gfx( void );
extern	void	song14a_gfx( void );
extern	void	song14b_gfx( void );

extern	void	process_gfx( void );

extern	void	infowin_gfx( void );
extern	void	infoline_gfx( void );
extern	void	info_upa_gfx( void );
extern	void	info_upb_gfx( void );
extern	void	info_dna_gfx( void );
extern	void	info_dnb_gfx( void );
extern	void	infocont_gfx( void );

extern	void	ball_gfx( void );
extern	void	interpoa_gfx( void );
extern	void	interpob_gfx( void );
extern	void	outwin_gfx( void );
extern	void	outcont_gfx( void );

extern	void	ball2_gfx( void );
extern	void	speakera_gfx( void );
extern	void	speakerb_gfx( void );
extern	void	volwin_gfx( void );
extern	void	volcont_gfx( void );

extern	void	credwintitle_gfx( void );
extern	void	credwincont_gfx( void );

extern	void	font_gfx( void );

extern	void	range_gfx( void );

extern	void	vga_res( void );
extern	void	rgb_res( void );
extern	void	title_vga_res( void );

extern	void	mcursor( void );

extern 	long 	xtab_data[320];
extern 	long 	ytab_data[480];

extern	void	mousedriver( void );
extern	int	mposx;
extern	int	mposy;
extern	int	mb;
extern	void	show_mouse( void );
extern	void	hide_mouse( void );

#if (MUSIC==1)
extern	void	basntekk_mod( void );
extern	void	hardatta_mod( void );
extern	void	heros_mod( void );
extern	void	never_mod( void );
extern	void	newsafe_mod( void );
extern	void	nobrain_mod( void );
extern	void	normal_mod( void );
extern	void	paradise_mod( void );
extern	void	paretyon_mod( void );
extern	void	sleeples_mod( void );
extern	void	smile_mod( void );
extern	void	sunmon2_mod( void );
extern	void	where_mod( void );
#endif

extern	void	player( void );

extern	void	ice_depack( void *src,void *dst );
extern	void	noise_depack( void *dta );

extern	void	drawdist(long a,long b,long c,long light,void *scradr);
extern	void	dist_dat( void );
extern	void	distwav1_dat( void );
extern	void	distwav2_dat( void );
extern	void	distwav3_dat( void );
extern	long	distmove[630];

struct window
{
	long	x;
	long	y;
	long	w;
	long	h;
	struct object	*firstobj;
};


struct window desk;
struct window songwin;
struct window infowin;
struct window outwin;
struct window volwin;
struct window credwin;

struct object
{
	long	x;
	long	y;
	long	w;
	long	h;
	long	state;
	void	*gfxa;
	void	*gfxb;
	void	*nextobj;
};

struct object songwincloser;
struct object songwintitle;
struct object song01;
struct object song02;
struct object song04;
struct object song05;
struct object song06;
struct object song07;
struct object song08;
struct object song09;
struct object song10;
struct object song11;
struct object song12;
struct object song13;
struct object song14;

struct object infowincloser;
struct object infowintitle;
struct object infowinline;
struct object infowinup;
struct object infowindown;

struct object outwincloser;
struct object outwintitle;
struct object outwincont;
struct object interpo;
struct object bal1,bal1pos;
struct object bal2,bal2pos;
struct object bal3,bal3pos;
struct object bal4,bal4pos;
struct object surround,surroundpos;

struct object volwincloser;
struct object volwintitle;
struct object volwincont;
struct object speaker;
struct object vol1,vol1pos;
struct object vol2,vol2pos;
struct object vol3,vol3pos;
struct object vol4,vol4pos;

struct object background;
struct object songwinicon;
struct object creditwinicon;
struct object outwinicon;
struct object volwinicon;
struct object infowinicon;
struct object quiticon;
struct object greetingsicon;

struct object credwincloser;
struct object credwintitle;
struct object credwincont;

void	open_window(struct window *win);
void	close_window(struct window *win);
void	move_window(struct window *win);
void	draw_object(long wx,long wy,struct object *obj);
void cdecl draw_window(long winnum,long cx1,long cy1,long cx2,long cy2);
void	redraw_window(long x1,long y1,long x2,long y2);
void 	*find_window(long mx,long my);
void 	top_window(struct window *win);
void 	*find_object(struct window *win,long mx,long my);
void	select_object(struct window *win,struct object *obj);
void	deselect_object(struct window *win,struct object *obj);
long  	get_window_state( struct window *win);
void	set_new_mod(void *mod,void *txt);
void	set_surround( void );
void	set_balance( struct object *obj);
void	set_volume( struct object *obj);
void 	closer_pressed( void );

void	greetings( void );

int	plasmapic[620][320];
signed long plasmapicoffset;

int topwin;

long infopos;
long surpos;

struct window *winlist[10];
int	infobuf[200][88];

long	mapx,mapy;
int	map[480][320];

unsigned int scr1[260][320];
void *scradr;
void *bufadr;

#if (MUSIC==1)
char modbuf[350000];
#endif

int buffer2[240][320];

struct object *actobj;
struct window *actwin;

struct object *acticon;

long oldstack;
long old_vbl;
char oldvregs[1000];

struct object *selected_song;

/* * * * * * * * * * MAIN FUNCTION * * * * * * * * * * */
void main( ) 
{

	/* Supervisormode */
	oldstack=Super(NULL);

	/* Screenadresse festlegen */
	scradr=evenadr(&scr1);

	/* Plasma Init */
	plasmapicoffset=0;
	for (mapy=0;mapy<480;mapy++) {
		for (mapx=0;mapx<320;mapx++) {
			map[mapy][mapx]=2*((int)xtab_data[mapx]+(int)ytab_data[mapy]);
		}
	}
	mapx=0;mapy=0;

	/* Window Init */
	desk.x=0;
	desk.y=0;
	desk.w=320-64;
	desk.h=240;
	desk.firstobj=&background;
	
	songwin.x=10;
	songwin.y=50;
	songwin.w=101;
	songwin.h=129;
	songwin.firstobj=&songwincloser;
	
	infowin.x=120;
	infowin.y=20;
	infowin.w=98;
	infowin.h=50;
	infowin.firstobj=&infowincloser;
	
	outwin.x=100;
	outwin.y=100;
	outwin.w=102;
	outwin.h=90;
	outwin.firstobj=&outwincloser;

	volwin.x=80;
	volwin.y=110;
	volwin.w=60;
	volwin.h=117;
	volwin.firstobj=&volwincloser;
	
	credwin.x=30;
	credwin.y=30;
	credwin.w=160;
	credwin.h=99;
	credwin.firstobj=&credwincloser;
	
	/* Object Initialisierung */
	songwincloser.x=0;songwincloser.y=0;
	songwincloser.w=10;songwincloser.h=10;
	songwincloser.state=0;
	songwincloser.gfxa=&closera_gfx;songwincloser.gfxb=&closerb_gfx;
	songwincloser.nextobj=&songwintitle;
	
	songwintitle.x=10;songwintitle.y=0;
	songwintitle.w=90;songwintitle.h=10;
	songwintitle.state=0;
	songwintitle.gfxa=&songwin_gfx;songwintitle.gfxb=&songwin_gfx;
	songwintitle.nextobj=&song01;

	song01.x=0;song01.y=10+0*9;song01.w=100;song01.h=9;
	song01.state=1;song01.nextobj=&song02;
	song01.gfxa=song01a_gfx;song01.gfxb=song01b_gfx;

	song02.x=0;song02.y=10+1*9;song02.w=100;song02.h=9;
	song02.state=0;song02.nextobj=&song04;
	song02.gfxa=song02a_gfx;song02.gfxb=song02b_gfx;

	song04.x=0;song04.y=10+2*9;song04.w=100;song04.h=9;
	song04.state=0;song04.nextobj=&song05;
	song04.gfxa=song04a_gfx;song04.gfxb=song04b_gfx;

	song05.x=0;song05.y=10+3*9;song05.w=100;song05.h=9;
	song05.state=0;song05.nextobj=&song06;
	song05.gfxa=song05a_gfx;song05.gfxb=song05b_gfx;

	song06.x=0;song06.y=10+4*9;song06.w=100;song06.h=9;
	song06.state=0;song06.nextobj=&song07;
	song06.gfxa=song06a_gfx;song06.gfxb=song06b_gfx;

	song07.x=0;song07.y=10+5*9;song07.w=100;song07.h=9;
	song07.state=0;song07.nextobj=&song08;
	song07.gfxa=song07a_gfx;song07.gfxb=song07b_gfx;

	song08.x=0;song08.y=10+6*9;song08.w=100;song08.h=9;
	song08.state=0;song08.nextobj=&song09;
	song08.gfxa=song08a_gfx;song08.gfxb=song08b_gfx;

	song09.x=0;song09.y=10+7*9;song09.w=100;song09.h=9;
	song09.state=0;song09.nextobj=&song10;
	song09.gfxa=song09a_gfx;song09.gfxb=song09b_gfx;

	song10.x=0;song10.y=10+8*9;song10.w=100;song10.h=9;
	song10.state=0;song10.nextobj=&song11;
	song10.gfxa=song10a_gfx;song10.gfxb=song10b_gfx;

	song11.x=0;song11.y=10+9*9;song11.w=100;song11.h=9;
	song11.state=0;song11.nextobj=&song12;
	song11.gfxa=song11a_gfx;song11.gfxb=song11b_gfx;

	song12.x=0;song12.y=10+10*9;song12.w=100;song12.h=9;
	song12.state=0;song12.nextobj=&song13;
	song12.gfxa=song12a_gfx;song12.gfxb=song12b_gfx;

	song13.x=0;song13.y=10+11*9;song13.w=100;song13.h=9;
	song13.state=0;song13.nextobj=&song14;
	song13.gfxa=song13a_gfx;song13.gfxb=song13b_gfx;

	song14.x=0;song14.y=10+12*9;song14.w=100;song14.h=9;
	song14.state=0;song14.nextobj=NULL;
	song14.gfxa=song14a_gfx;song14.gfxb=song14b_gfx;

	infowincloser.x=0;infowincloser.y=0;
	infowincloser.w=10;infowincloser.h=10;
	infowincloser.state=0;
	infowincloser.gfxa=&closera_gfx;infowincloser.gfxb=&closerb_gfx;
	infowincloser.nextobj=&infowintitle;
	
	infowintitle.x=10;infowintitle.y=0;
	infowintitle.w=90;infowintitle.h=10;
	infowintitle.state=0;
	infowintitle.gfxa=&infowin_gfx;infowintitle.gfxb=&infowin_gfx;
	infowintitle.nextobj=&infowinline;

	infowinline.x=0;infowinline.y=47;
	infowinline.w=100;infowinline.h=3;
	infowinline.state=0;
	infowinline.gfxa=&infoline_gfx;infowinline.gfxb=&infoline_gfx;
	infowinline.nextobj=&infowinup;

	infowinup.x=88;infowinup.y=10;
	infowinup.w=10;infowinup.h=19;
	infowinup.state=0;
	infowinup.gfxa=&info_upa_gfx;infowinup.gfxb=&info_upb_gfx;
	infowinup.nextobj=&infowindown;

	infowindown.x=88;infowindown.y=10+19;
	infowindown.w=10;infowindown.h=20;
	infowindown.state=0;
	infowindown.gfxa=&info_dna_gfx;infowindown.gfxb=&info_dnb_gfx;
	infowindown.nextobj=NULL;

	outwincloser.x=0;outwincloser.y=0;
	outwincloser.w=10;outwincloser.h=10;
	outwincloser.state=0;
	outwincloser.gfxa=&closera_gfx;outwincloser.gfxb=&closerb_gfx;
	outwincloser.nextobj=&outwintitle;

	outwintitle.x=10;outwintitle.y=0;
	outwintitle.w=92;outwintitle.h=10;
	outwintitle.state=0;
	outwintitle.gfxa=&outwin_gfx;outwintitle.gfxb=&outwin_gfx;
	outwintitle.nextobj=&outwincont;

	outwincont.x=00;outwincont.y=10;
	outwincont.w=102;outwincont.h=93;
	outwincont.state=0;
	outwincont.gfxa=&outcont_gfx;outwincont.gfxb=&outcont_gfx;
	outwincont.nextobj=&interpo;
	
	interpo.x=5;interpo.y=75;
	interpo.w=94;interpo.h=10;
	interpo.state=0;
	interpo.gfxa=&interpoa_gfx;interpo.gfxb=&interpob_gfx;
	interpo.nextobj=&surround;

	surround.x=22;surround.y=63;
	surround.w=64+3;surround.h=5;
	surround.state=0;
	surround.gfxa=NULL;surround.gfxb=NULL;
	surround.nextobj=&surroundpos;

	surroundpos.x=22;surroundpos.y=63;
	surroundpos.w=-5;surroundpos.h=-5;
	surroundpos.state=0;
	surroundpos.gfxa=&ball_gfx;surroundpos.gfxb=ball_gfx;
	surroundpos.nextobj=&bal1;

	bal1.x=22;bal1.y=20;
	bal1.w=64+3;bal1.h=5;
	bal1.state=0;
	bal1.gfxa=NULL;bal1.gfxb=NULL;
	bal1.nextobj=&bal1pos;
	
	bal1pos.x=22;bal1pos.y=20;
	bal1pos.w=-5;bal1pos.h=-5;
	bal1pos.state=0;
	bal1pos.gfxa=&ball_gfx;bal1pos.gfxb=&ball_gfx;
	bal1pos.nextobj=&bal2;

	bal2.x=22;bal2.y=28;
	bal2.w=64+3;bal2.h=5;
	bal2.state=0;
	bal2.gfxa=NULL;bal2.gfxb=NULL;
	bal2.nextobj=&bal2pos;
	
	bal2pos.x=22+64;bal2pos.y=28;
	bal2pos.w=-5;bal2pos.h=-5;
	bal2pos.state=0;
	bal2pos.gfxa=&ball_gfx;bal2pos.gfxb=&ball_gfx;
	bal2pos.nextobj=&bal3;

	bal3.x=22;bal3.y=36;
	bal3.w=64+3;bal3.h=5;
	bal3.state=0;
	bal3.gfxa=NULL;bal3.gfxb=NULL;
	bal3.nextobj=&bal3pos;
	
	bal3pos.x=22+64;bal3pos.y=36;
	bal3pos.w=-5;bal3pos.h=-5;
	bal3pos.state=0;
	bal3pos.gfxa=&ball_gfx;bal3pos.gfxb=&ball_gfx;
	bal3pos.nextobj=&bal4;

	bal4.x=22;bal4.y=44;
	bal4.w=64+3;bal4.h=5;
	bal4.state=0;
	bal4.gfxa=NULL;bal4.gfxb=NULL;
	bal4.nextobj=&bal4pos;
	
	bal4pos.x=22;bal4pos.y=44;
	bal4pos.w=-5;bal4pos.h=-5;
	bal4pos.state=0;
	bal4pos.gfxa=&ball_gfx;bal4pos.gfxb=&ball_gfx;
	bal4pos.nextobj=NULL;

	volwincloser.x=0;volwincloser.y=0;
	volwincloser.w=10;volwincloser.h=10;
	volwincloser.state=0;
	volwincloser.gfxa=&closera_gfx;volwincloser.gfxb=&closerb_gfx;
	volwincloser.nextobj=&volwintitle;

	volwintitle.x=10;volwintitle.y=0;
	volwintitle.w=49;volwintitle.h=10;
	volwintitle.state=0;
	volwintitle.gfxa=&volwin_gfx;volwintitle.gfxb=&volwin_gfx;
	volwintitle.nextobj=&volwincont;

	volwincont.x=00;volwincont.y=10;
	volwincont.w=60;volwincont.h=107;
	volwincont.state=0;
	volwincont.gfxa=&volcont_gfx;volwincont.gfxb=&volcont_gfx;
	volwincont.nextobj=&speaker;
	
	speaker.x=5;speaker.y=103;
	speaker.w=84;speaker.h=10;
	speaker.state=0;
	speaker.gfxa=&speakera_gfx;speaker.gfxb=&speakerb_gfx;
	speaker.nextobj=&vol1;

	vol1.x=14;vol1.y=27;
	vol1.w=5;vol1.h=60+3;
	vol1.state=0;
	vol1.gfxa=NULL;vol1.gfxb=NULL;
	vol1.nextobj=&vol1pos;
	
	vol1pos.x=14;vol1pos.y=27;
	vol1pos.w=-5;vol1pos.h=-5;
	vol1pos.state=0;
	vol1pos.gfxa=&ball2_gfx;vol1pos.gfxb=&ball2_gfx;
	vol1pos.nextobj=&vol2;

	vol2.x=23;vol2.y=27;
	vol2.w=5;vol2.h=60+3;
	vol2.state=0;
	vol2.gfxa=NULL;vol2.gfxb=NULL;
	vol2.nextobj=&vol2pos;
	
	vol2pos.x=23;vol2pos.y=27;
	vol2pos.w=-5;vol2pos.h=-5;
	vol2pos.state=0;
	vol2pos.gfxa=&ball2_gfx;vol2pos.gfxb=&ball2_gfx;
	vol2pos.nextobj=&vol3;

	vol3.x=32;vol3.y=27;
	vol3.w=5;vol3.h=60+3;
	vol3.state=0;
	vol3.gfxa=NULL;vol3.gfxb=NULL;
	vol3.nextobj=&vol3pos;
	
	vol3pos.x=32;vol3pos.y=27;
	vol3pos.w=-5;vol3pos.h=-5;
	vol3pos.state=0;
	vol3pos.gfxa=&ball2_gfx;vol3pos.gfxb=&ball2_gfx;
	vol3pos.nextobj=&vol4;

	vol4.x=41;vol4.y=27;
	vol4.w=5;vol4.h=60+3;
	vol4.state=0;
	vol4.gfxa=NULL;vol4.gfxb=NULL;
	vol4.nextobj=&vol4pos;
	
	vol4pos.x=41;vol4pos.y=27;
	vol4pos.w=-5;vol4pos.h=-5;
	vol4pos.state=0;
	vol4pos.gfxa=&ball2_gfx;vol4pos.gfxb=&ball2_gfx;
	vol4pos.nextobj=NULL;

	background.x=0;background.y=0;
	background.w=320-64;background.h=240;
	background.state=0;
	background.gfxa=&background_gfx;background.gfxb=&background_gfx;
	background.nextobj=&songwinicon;

	songwinicon.x=10;songwinicon.y=216;
	songwinicon.w=16;songwinicon.h=16;
	songwinicon.state=0;
	songwinicon.gfxa=&songicona_gfx;songwinicon.gfxb=&songiconb_gfx;
	songwinicon.nextobj=&creditwinicon;

	creditwinicon.x=90;creditwinicon.y=216;
	creditwinicon.w=16;creditwinicon.h=16;
	creditwinicon.state=0;
	creditwinicon.gfxa=&crediticona_gfx;creditwinicon.gfxb=&crediticonb_gfx;
	creditwinicon.nextobj=&outwinicon;

	outwinicon.x=50;outwinicon.y=216;
	outwinicon.w=16;outwinicon.h=16;
	outwinicon.state=0;
	outwinicon.gfxa=&outicona_gfx;outwinicon.gfxb=&outiconb_gfx;
	outwinicon.nextobj=&volwinicon;

	volwinicon.x=70;volwinicon.y=216;
	volwinicon.w=16;volwinicon.h=16;
	volwinicon.state=0;
	volwinicon.gfxa=&volicona_gfx;volwinicon.gfxb=&voliconb_gfx;
	volwinicon.nextobj=&infowinicon;

	infowinicon.x=30;infowinicon.y=216;
	infowinicon.w=16;infowinicon.h=16;
	infowinicon.state=0;
	infowinicon.gfxa=&infoicona_gfx;infowinicon.gfxb=&infoiconb_gfx;
	infowinicon.nextobj=&greetingsicon;

	greetingsicon.x=110;greetingsicon.y=216;
	greetingsicon.w=16;greetingsicon.h=16;
	greetingsicon.state=0;
	greetingsicon.gfxa=&greeticona_gfx;greetingsicon.gfxb=&greeticonb_gfx;
	greetingsicon.nextobj=&quiticon;

	quiticon.x=230;quiticon.y=216;
	quiticon.w=16;quiticon.h=16;
	quiticon.state=0;
	quiticon.gfxa=&quiticona_gfx;quiticon.gfxb=&quiticonb_gfx;
	quiticon.nextobj=NULL;

	credwincloser.x=0;credwincloser.y=0;
	credwincloser.w=10;credwincloser.h=10;
	credwincloser.state=0;
	credwincloser.gfxa=&closera_gfx;credwincloser.gfxb=&closerb_gfx;
	credwincloser.nextobj=&credwintitle;

	credwintitle.x=10;credwintitle.y=0;
	credwintitle.w=150;credwintitle.h=10;
	credwintitle.state=0;
	credwintitle.gfxa=&credwintitle_gfx;credwintitle.gfxb=&credwintitle_gfx;
	credwintitle.nextobj=&credwincont;

	credwincont.x=0;credwincont.y=10;
	credwincont.w=160;credwincont.h=90;
	credwincont.state=0;
	credwincont.gfxa=&credwincont_gfx;credwincont.gfxb=&credwincont_gfx;
	credwincont.nextobj=NULL;

	
	infopos=0;
	surpos=0;
	
	winlist[0]=NULL;		/* topwindow */
	winlist[1]=NULL;
	winlist[2]=NULL;
	winlist[3]=NULL;
	winlist[4]=NULL;

	balance(0,-63);
	balance(0,63);
	balance(0,63);
	balance(0,-63);

	selected_song=&song01;

	while (Cconis()==-1) Cconin();

	memcopy(160*240,&light,&plasmapic[279][0]);

	memcopy(197*44+2,&infocont_gfx,&infobuf);
	drawtext(3,1,&infobuf,&basntekk_txt);


	/* Das orginal Plasmabild wird nicht mehr ben”tigt */
	/* Speicher wird fr Screenbuffer verwendet */
	bufadr=&light;

	/* Speaker ausschalten */
	Ongibit(0x40);

	/* alte Konfiguration sichern */
	save_old_res(&oldvregs);
	old_vbl=*(long *)0x70;

	init_replay();

#if (MUSIC==1)	
	ice_depack(&basntekk_mod,&modbuf);
	play_mod( &modbuf,NULL );
#endif

	/* VBL Initialisierung */
	*(long *)0x70=(long)&vbl_rout1;

	setclipping(0,0,320-64,240);

	/* Desktop("-Fenster") ”ffnen */
	open_window(&desk);

	/* Mausinitialisierung */
	setnewmouse();	

	/* Videoinitialisierung */
	vbl_wait();
	set_scr_adr(scradr);
	if (mon_type()==2) set_scp_res(&vga_res);
	else set_scp_res(&rgb_res);

	acticon=NULL;

	/* Mainloop */
	while ((mb!=1) | (actobj!=&quiticon))
	{

		/* Ermitteln des Fensters unter der Maus */
		actwin=find_window(mposx,mposy);

		/* Wenn Maus ber Hintergrund, dann Icons reindrcken usw. */
		if (actwin==&desk) {
			actobj=find_object(&desk,mposx,mposy);
			if (actobj!=acticon) deselect_object(actwin,acticon);
			if ((actobj==&songwinicon) | (actobj==&creditwinicon) | 
				(actobj==&outwinicon) | (actobj==&volwinicon) |
				(actobj==&infowinicon) | (actobj==&greetingsicon) |
				(actobj==&quiticon)) {
				select_object(actwin,actobj);
				acticon=actobj;
			};
		} else {
			deselect_object(&desk,acticon);
			acticon=NULL;
		};

		/* Aktionen bei gedrckter linker Maustaste */
		if (mb==1) {

			/* Wenn angeklicktes Fenster nicht vorn -> Fenster vorholen */
			if ((actwin!=winlist[0]) && (actwin!=NULL) && (actwin!=&desk)) top_window(actwin);

			if (actwin==&desk) {
				actobj=find_object(&desk,mposx,mposy);
				if (actobj==&songwinicon) open_window(&songwin);
				if (actobj==&infowinicon) open_window(&infowin);
				if (actobj==&outwinicon) open_window(&outwin);
				if (actobj==&volwinicon) open_window(&volwin);
				if (actobj==&creditwinicon) open_window(&credwin);
				if (actobj==&greetingsicon) greetings();
			};
			
			if (actwin==&songwin) {
				actobj=find_object(&songwin,mposx,mposy);
				if (actobj==&songwincloser) closer_pressed();
				if (actobj==&songwintitle) move_window(&songwin);
#if MUSIC==1
				if (actobj!=selected_song) {
					if (actobj==&song01) set_new_mod(&basntekk_mod,&basntekk_txt);
					if (actobj==&song02) set_new_mod(&paretyon_mod,&paretyon_txt);
					if (actobj==&song04) set_new_mod(&hardatta_mod,&hardatta_txt);
					if (actobj==&song05) set_new_mod(&heros_mod,&heros_txt);
					if (actobj==&song06) set_new_mod(&normal_mod,&normal_txt);
					if (actobj==&song07) set_new_mod(&never_mod,&never_txt);
					if (actobj==&song08) set_new_mod(&nobrain_mod,&nobrain_txt);
					if (actobj==&song09) set_new_mod(&paradise_mod,&paradise_txt);
					if (actobj==&song10) set_new_mod(&sleeples_mod,&sleeples_txt);
					if (actobj==&song11) set_new_mod(&smile_mod,&smile_txt);
					if (actobj==&song12) set_new_mod(&sunmon2_mod,&sunmon2_txt);
					if (actobj==&song13) set_new_mod(&newsafe_mod,&newsafe_txt);
					if (actobj==&song14) set_new_mod(&where_mod,&where_txt);
				};
#endif
			};


			if (actwin==&infowin) {
				actobj=find_object(&infowin,mposx,mposy);
				if (actobj==&infowincloser) closer_pressed();
				if (actobj==&infowintitle) {
					move_window(&infowin);
					hide_mouse();
					drawinfocont(infowin.x,infowin.y+10,infopos,&infobuf,scradr);
					drawinfocont(infowin.x,infowin.y+10,infopos,&infobuf,bufadr);
					show_mouse();
				}
				if (actobj==&infowinup) {
					select_object(&infowin,&infowinup);
					while ((mb==1) && (find_object(&infowin,mposx,mposy)==&infowinup)) {
						infopos--;
						if (infopos<0) infopos=0;
						vbl_wait();
						drawinfocont(infowin.x,infowin.y+10,infopos,&infobuf,scradr);
					};
					deselect_object(&infowin,&infowinup);
					hide_mouse();
					drawinfocont(infowin.x,infowin.y+10,infopos,&infobuf,bufadr);
					show_mouse();
				}
				if (actobj==&infowindown) {
					select_object(&infowin,&infowindown);
					while ((mb==1) && (find_object(&infowin,mposx,mposy)==&infowindown)) {
						infopos++;
						if (infopos>160) infopos=160;
						vbl_wait();
						drawinfocont(infowin.x,infowin.y+10,infopos,&infobuf,scradr);
					};
					deselect_object(&infowin,&infowindown);
					hide_mouse();
					drawinfocont(infowin.x,infowin.y+10,infopos,&infobuf,bufadr);
					show_mouse();
				};
			};

			if (actwin==&outwin) {
				actobj=find_object(&outwin,mposx,mposy);
				if (actobj==&outwincloser) closer_pressed();
				if (actobj==&outwintitle) move_window(&outwin);
				if (actobj==&interpo) {
					if (interpo.state==0) select_object(actwin,actobj);
					else deselect_object(actwin,actobj);
					set_interpolation(interpo.state);
					while ((mb==1) && actobj==find_object(&outwin,mposx,mposy));
				};
				if (actobj==&surround) set_surround();
				if (actobj==&bal1) set_balance(&bal1);
				if (actobj==&bal2) set_balance(&bal2);
				if (actobj==&bal3) set_balance(&bal3);
				if (actobj==&bal4) set_balance(&bal4);
			};

			if (actwin==&volwin) {
				actobj=find_object(&volwin,mposx,mposy);
				if (actobj==&volwincloser) closer_pressed();
				if (actobj==&volwintitle) move_window(&volwin);
				if (actobj==&speaker) {
					if (speaker.state==0) {
						select_object(actwin,actobj);
						Offgibit(32);
					} else {
						deselect_object(actwin,actobj);
						Ongibit(0x40);
					};
					while ((mb==1) && actobj==find_object(&volwin,mposx,mposy));
				};
				if (actobj==&vol1) set_volume(&vol1);
				if (actobj==&vol2) set_volume(&vol2);
				if (actobj==&vol3) set_volume(&vol3);
				if (actobj==&vol4) set_volume(&vol4);
			};

			if (actwin==&credwin) {
				actobj=find_object(&credwin,mposx,mposy);
				if (actobj==&credwincloser) closer_pressed();
				if (actobj==&credwintitle) move_window(&credwin);
			};
		};
	};

	hide_mouse();
	
#if (MUSIC==1)
	stop_mod();
#endif
	deinit_replay();

	/* VBL Deinit */
	*(long *)0x70=(long)old_vbl;
	
	/* Videodeinitialisierung */
	Vsync();
	set_all_vid(&oldvregs);
	set_scr_adr(Logbase());

	/* Mausdeinitialisierung */
	hide_mouse();
	setoldmouse();

	/* Usermode */
	Super(&oldstack);

	exit(0);
}
/* * * * * * * * * * * * * * * * * * * * * * * * * * * */







/*** INITIALISATION ***/

void *old_mdriver;

/* MŽUSEKACKE */
void setnewmouse( void )
{

KBDVBASE *kbd_vecs;
	kbd_vecs=Kbdvbase();
	old_mdriver=kbd_vecs->kb_mousevec;
	kbd_vecs->kb_mousevec=&mousedriver;
};


void setoldmouse( void )
{
KBDVBASE *kbd_vecs;
	kbd_vecs=Kbdvbase();
	kbd_vecs->kb_mousevec=old_mdriver;
};


/*** FUNCTIONS ***/

long load_file( char *filename, void *dstadr)
{
	int fhandle;
	long size;
	
	fhandle=Fopen(filename,0);
	size=Fread(fhandle,1000000,dstadr);
	printf("loaded %s: %li Bytes \n",filename,size);
	Fclose(fhandle);

	return size;
};


void save_file( char *filename, void *srcadr, long anzbytes)
{
	int fhandle;
	long size;
	
	fhandle=Fcreate(filename,0);
	Fwrite(fhandle,anzbytes,srcadr);
	Fclose(fhandle);

};


long min(long u,long v)
{
	if (u>v) return v;
	else return u;
};

long max(long u,long v)
{
	if (u<v) return v;
	else return u;
};



void cdecl	draw_window(long winnum,long cx1,long cy1,long cx2,long cy2)
{
struct 	window *win;
long	sx1,sy1,sx2,sy2;
struct 	object *obj;

/*	drawbox(cx1,cy1,cx2,cy2,123*(cx1+cx2+cy1+cy2));Cconin();*/

	win=winlist[winnum];
	
	if (win!=NULL) {

		/* Schnittfl„che zwischen Fenster und redraw-area berechnen */
		sx1=max(cx1,win->x);
		sy1=max(cy1,win->y);
		sx2=min(cx2,win->x+win->w);
		sy2=min(cy2,win->y+win->h);

		/* Wenn Bereiche sich schneiden ... Schnittbereich zeichnen */
		if ((sx1<sx2) && (sy1<sy2)) {
			setclipping(sx1,sy1,sx2,sy2);
/*			drawbox(sx1,sy1,sx2,sy2,123*(sx1+sx2+sy1+sy2));Cconin();*/
			obj=win->firstobj;
			do {
				if (obj->state==0)
					drawtrp(win->x+obj->x,win->y+obj->y,
							obj->gfxa,bufadr);
				else 
					drawtrp(win->x+obj->x,win->y+obj->y,
							obj->gfxb,bufadr);
				obj=obj->nextobj;
			} while (obj!=NULL);		

			if (win==&infowin) drawinfocont(win->x,win->y+10,infopos,&infobuf,bufadr);
		
			/* Restliche Fl„chen verzweigen */
			if (sx1>cx1) draw_window(winnum+1,cx1,max(cy1,sy1),sx1,min(cy2,sy2));
			if (sy1>cy1) draw_window(winnum+1,cx1,cy1,cx2,sy1);
			if (sx2<cx2) draw_window(winnum+1,sx2,max(cy1,sy1),cx2,min(cy2,sy2));
			if (sy2<cy2) draw_window(winnum+1,cx1,sy2,cx2,cy2);

		} else {
			draw_window(winnum+1,cx1,cy1,cx2,cy2);
		};
	
	} else {
		/*setclipping(cx1,cy1,cx2,cy2);
		clrshadow(cx1,cy1,cx2,cy2,&backgrnd,bufadr);*/
	};
};

void	redraw_window(long x1,long y1,long x2,long y2)
{
long i;
struct 	object *obj;
long dx1,dy1,dx2,dy2;
long wx1,wy1,wx2,wy2;

	setclipping(x1,y1,x2,y2);

	draw_window(0,x1,y1,x2,y2);

	/* Grafikdaten von Buffer auf Screen kopieren */
	setclipping(0,0,320-64,240);
	clrshadow(x1,y1,x2,y2,bufadr,scradr);
};


void	open_window(struct window *win)
{
long i;
	if (get_window_state(win)==0) {
		for (i=8;i>=0;i--) winlist[i+1]=winlist[i];
		winlist[0]=win;
		hide_mouse();
		redraw_window(win->x,win->y,win->x+win->w,win->y+win->h);
		show_mouse();
	} else top_window(win);
};


void	close_window(struct window *win)
{
long i;
long pos;

	if (get_window_state(win)==1) {
		/* Position des Fensters in winlist bestimmen */
		for (pos=0;winlist[pos]!=win;pos++);

		/* Liste aktualisieren */	
		for (i=pos;i<8;i++) {
			winlist[i]=winlist[i+1];
		};
		
		/* Fl„che des ehemaligen Fensters neuzeichnen */
		hide_mouse();
		redraw_window(win->x,win->y,win->x+win->w,win->y+win->h);
		show_mouse();
	};
};


void	move_window(struct window *win)
{
long dx,dy;
long mx,my,omx,omy;
long x1,y1,x2,y2;
long ox1,oy1,ox2,oy2;
long owx1,owy1;
long owx2,owy2;

	hide_mouse();
/*	drawtrp(windows[winnum].x,windows[winnum].y,
			windows[winnum].buf,bufadr);*/

	mx=(long)mposx;
	my=(long)mposy;
	x1=win->x;
	y1=win->y;
	x2=win->x+win->w;
	y2=win->y+win->h;
	owx1=x1;owy1=y1;owx2=x2;owy2=y2;

	drawshadow(x1,y1,x2,y2,bufadr,scradr);

	while (mb==1){
		omx=mx;
		omy=my;
		ox1=x1;
		oy1=y1;
		ox2=x2;
		oy2=y2;
		mx=(long)mposx;
		my=(long)mposy;
		dx=mx-omx;
		dy=my-omy;
		if ((y1+dy)<0) dy=-y1;
		x1=x1+dx;
		x2=x2+dx;
		y1=y1+dy;
		y2=y2+dy;

		if ((x1<ox2) && (x2>ox1) && (y1<oy2) && (y2>oy1)) {

			if (dx>0) {
				clrshadow(ox1,oy1,x1,oy2,bufadr,scradr);
				drawshadow(ox2,y1,x2,y2,bufadr,scradr);
			};
			if (dx<0) {
				clrshadow(x2,oy1,ox2,oy2,bufadr,scradr);
				drawshadow(x1,y1,ox1,oy2,bufadr,scradr);
			};
			if (dy>0) {
				clrshadow(ox1,oy1,ox2,y1,bufadr,scradr);
				drawshadow(x1,oy2,x2,y2,bufadr,scradr);
			};
			if (dy<0) {
				clrshadow(x1,y2,ox2,oy2,bufadr,scradr);
				drawshadow(x1,y1,x2,oy1,bufadr,scradr);
			};
		} else {
			clrshadow(ox1,oy1,ox2,oy2,bufadr,scradr);
			drawshadow(x1,y1,x2,y2,bufadr,scradr);
		};
	};
	win->x=x1;
	win->y=y1;
	hide_mouse();
	if ((x1<owx2) && (x2>owx1) && (y1<owy2) && (y2>owy1)) {
		redraw_window(min(owx1,x1),min(owy1,y1),max(owx2,x2),max(owy2,y2));
	} else {
		redraw_window(owx1,owy1,owx2,owy2);
		redraw_window(x1,y1,x2,y2);
	};
	show_mouse();
};



void 	*find_window(long mx,long my)
{
struct window *result;
long i;
	result=NULL;
	
	/* das Ende der winlist ermitteln */
	for (i=0;winlist[i]!=NULL;i++);
	i--;
	
	for (;i>=0;i--) {
	
		if ( (mx>=winlist[i]->x) && (mx<=winlist[i]->x+winlist[i]->w) &&
			 (my>=winlist[i]->y) && (my<=winlist[i]->y+winlist[i]->h)) {
			result=winlist[i];	 
		};
	};
	return result;
};




void top_window(struct window *win)
{
long x1,y1,x2,y2;
long oldpos;
long i;

	/* Vordergrundfenster niemals toppen */
	if (win!=winlist[0]) {

		/* alte Position des getoppten Fensters in winlist */
		for (oldpos=0;winlist[oldpos]!=win;oldpos++);

		/* alle Fenster vor oldpos nach hinten verschieben */
		for (i=oldpos;i>0;i--) {
			winlist[i]=winlist[i-1];		
		};

		/* getopptes Fenster an vorderster Pos. eintragen */
		winlist[0]=win;
		
		hide_mouse();
		redraw_window(win->x,win->y,win->x+win->w,win->y+win->h);
		show_mouse();
	};
	
};


long  get_window_state( struct window *win)
{
long i,result;
	result=0;
	for (i=0;winlist[i]!=NULL;i++) {
		if (winlist[i]==win) result=1;
	};
	return result;
};


void *find_object(struct window *win,long mx,long my)
{
struct 	object *obj;
struct	object *result;

	obj=win->firstobj;

	result=NULL;

	mx-=win->x;
	my-=win->y;

	do {
		if ((obj->x<=mx) && (obj->y<=my) && 
			((obj->x+obj->w)>=mx) && ((obj->y+obj->h)>=my)) 
			result=obj;
		obj=obj->nextobj;
	} while (obj!=NULL);		
	return result;
}

void	select_object(struct window *win,struct object *obj)
{
	if (obj->state==0) {
		obj->state=1;
		hide_mouse();
		/*drawtrp(win->x+obj->x,win->y+obj->y,
				obj->gfxb,scradr);
		drawtrp(win->x+obj->x,win->y+obj->y,
				obj->gfxb,bufadr);*/
		redraw_window(win->x+obj->x,win->y+obj->y,win->x+obj->x+obj->w,win->y+obj->y+obj->h);
		show_mouse();
	};
};

void	deselect_object(struct window *win,struct object *obj)
{
	if (obj->state==1) {
		obj->state=0;
		hide_mouse();
		/*drawtrp(win->x+obj->x,win->y+obj->y,
				obj->gfxa,scradr);
		drawtrp(win->x+obj->x,win->y+obj->y,
				obj->gfxa,bufadr);*/
		redraw_window(win->x+obj->x,win->y+obj->y,win->x+obj->x+obj->w,win->y+obj->y+obj->h);
		show_mouse();
	};
};


void	set_new_mod(void *mod,void *txt)
{
	deselect_object(&songwin,selected_song);
	select_object(&songwin,actobj);
	selected_song=actobj;

	hide_mouse();
	*(long *)0x70=(long)&vbl_rout3;

	memcopy(197*44+2,&infocont_gfx,&infobuf);
	drawtext(3,1,&infobuf,txt);
mod=mod;
#if (MUSIC==1)
	stop_mod();
	ice_depack(mod,&modbuf);
	if (
		(mod!=&never_mod) && 
		(mod!=&sunmon2_mod) &&
		(mod!=&basntekk_mod) &&
		(mod!=&sleeples_mod) &&
		(mod!=&paradise_mod) &&
		(mod!=&heros_mod)
		) noise_depack(&modbuf);
	play_mod(&modbuf,NULL);
#endif

	*(long *)0x70=(long)&vbl_rout1;
	clrshadow(100,100,100+90,100+18,bufadr,scradr);
	
	hide_mouse();
	redraw_window(infowin.x,infowin.y,infowin.x+infowin.w,infowin.y+infowin.h);
	show_mouse();
};

/*
void	set_new_info(void *txt)
{
};
*/

void	greetings( void )
{
long a,b,c,d;
long lcnt;


	hide_mouse();
	drawstring(5,0,&buffer2,"M O D U L A T I O N   -");
	drawstring(160,0,&buffer2,"V O L U M E   3");
	drawstring(5,20,&buffer2,"GREETINGS:");
	drawstring(4,24,&buffer2,"ffffffffffffffffffffffffffffffffffffffff");
	a=30;b=10;
	drawstring(b,a+=8,&buffer2,"ANTJE");
	drawstring(b,a+=8,&buffer2,"AVENA");
	drawstring(b,a+=8,&buffer2,"CHECKPOINT");
	drawstring(b,a+=8,&buffer2,"CREAM");
	drawstring(b,a+=8,&buffer2,"CRUOR");
	drawstring(b,a+=8,&buffer2,"DALE, PAMELA");
	drawstring(b,a+=8,&buffer2,"FIRESOFT");
	drawstring(b,a+=8,&buffer2,"IMPULSE");
	drawstring(b,a+=8,&buffer2,"JENS SYCKOR");
	drawstring(b,a+=8,&buffer2,"JURI");
	drawstring(b,a+=8,&buffer2,"GAG 16");
	drawstring(b,a+=8,&buffer2,"HOLGER SCHULZ");
	drawstring(b,a+=8,&buffer2,"HOLGER WEETS");
	a=30;b=140;
	drawstring(b,a+=8,&buffer2,"MAGGIE-TEAM");
	drawstring(b,a+=8,&buffer2,"NEWBEAT");
	drawstring(b,a+=8,&buffer2,"REFLEX");
	drawstring(b,a+=8,&buffer2,"ROBBY");
	drawstring(b,a+=8,&buffer2,"SEBASTIAN HENNIG");
	drawstring(b,a+=8,&buffer2,"SENTRY");
	drawstring(b,a+=8,&buffer2,"SHIFTER");
	drawstring(b,a+=8,&buffer2,"STAX");
	drawstring(b,a+=8,&buffer2,"TCE");
	drawstring(b,a+=8,&buffer2,"THERAPY");
	drawstring(b,a+=8,&buffer2,"TNB");
	drawstring(b,a+=8,&buffer2,"TOS-CREW");
	drawstring(b,a+=8,&buffer2,"TSCC");

	b=30;a+=6;
	drawstring(b,a+=8,&buffer2,"...AND THE LOST SOULS OF");
	drawstring(b,a+=8,&buffer2,"   ABSENCE,INTER...");
	
	drawstring(5,170,&buffer2,"GO AWAY!");
	drawstring(4,174,&buffer2,"fffffffffffffffffffffffffffffffffffffff");
	b=10;a=180;
	drawstring(10,a+=8,&buffer2,"DELTA LABS MEDIA");
	drawstring(10,a+=8,&buffer2,"COMPUTER UND SOFTWARE GMBH");

	drawstring(146,226,&buffer2,"fffffffffffffffff");
	drawstring(146,230,&buffer2,"(C)1997 BY ESCAPE");
	drawstring(146-12,234,&buffer2,"  fffffffffffffffff");

	/* Ausblenden */
	for (a=0;a<310;a++) {
		blend(a,bufadr,&buffer2,scradr);
		if (a<200) plasmapicoffset=-a*640;
	};
	
	*(long *)0x70=(long)&vbl_rout2;
	hide_mouse();
	
	a=0;
	b=10;
	c=20;
	lcnt=433;
	plasmapicoffset=(signed long)-640*(signed long)140;

	while (mb!=1) {
		if (plasmapicoffset<0) plasmapicoffset+=2*640;
	
		a++;if (a>=314) a-=314;
		b--;if (b<=0) b+=565;
		c+=3;if (c>=188) c-=188;
		lcnt++;if (lcnt>=628) lcnt-=628;
		drawdist(a,b,c,lcnt,scradr);
	};

	/* Ausblenden */
	for (d=0;(distmove[lcnt]+plasmapicoffset)>-100000;d++) {
		plasmapicoffset-=4*640;

		a++;if (a>=314) a-=314;
		b--;if (b<=0) b+=565;
		c+=3;if (c>=188) c-=188;
		lcnt++;
		if (lcnt>=628) lcnt-=628;
		drawdist(a,b,c,lcnt,scradr);
	};
	
	vbl_wait();
	*(long *)0x70=(long	)&vbl_rout1;

	plasmapicoffset=-200*640;
	for (a=0;a<310;a++) {
		blend(a,&buffer2,bufadr,scradr);
		if (a<200) plasmapicoffset=(a-200)*640;
	};
	plasmapicoffset=0;
	show_mouse();
};


void	set_surround( void )
{
long x;
	hide_mouse();
	while (mb==1) {
		x=mposx-1-actwin->x;
		if (x<surround.x) x=surround.x;
		if (x>surround.x+surround.w-3) x=surround.x+surround.w-3;
		surroundpos.x=x;
		redraw_window(actwin->x+surround.x,actwin->y+surround.y,
			actwin->x+surround.x+surround.w+5,
			actwin->y+surround.y+surround.h);
		surpos=x-surround.x;
		vbl_wait();
		make_surround(surpos*50);
	}
	show_mouse();
};

void	set_balance( struct object *obj )
{
long x;
struct object *slider;
long pos;

	slider=obj->nextobj;

	hide_mouse();
	while (mb==1) {
		x=mposx-1-actwin->x;
		if (x<obj->x) x=obj->x;
		if (x>obj->x+obj->w-3) x=obj->x+obj->w-3;
		slider->x=x;
		redraw_window(actwin->x+obj->x,actwin->y+obj->y,
			actwin->x+obj->x+obj->w+5,
			actwin->y+obj->y+obj->h);
		pos=x-surround.x;
		vbl_wait();
		if (obj==&bal1) balance(0,(int)pos*2-63);
		if (obj==&bal2) balance(1,(int)pos*2-63);
		if (obj==&bal3) balance(2,(int)pos*2-63);
		if (obj==&bal4) balance(3,(int)pos*2-63);
	}
	show_mouse();
};

void	set_volume( struct object *obj )
{
long y;
struct object *slider;
long pos;

	slider=obj->nextobj;

	hide_mouse();
	while (mb==1) {
		y=mposy-1-actwin->y;
		if (y<obj->y) y=obj->y;
		if (y>obj->y+obj->h-3) y=obj->y+obj->h-3;
		slider->y=y;
		redraw_window(actwin->x+obj->x,actwin->y+obj->y,
			actwin->x+obj->x+obj->w,
			actwin->y+obj->y+obj->h+5);
		pos=y-vol1.y;
		vbl_wait();
		if (obj==&vol1) volume(0,(int)(60-pos)*511);
		if (obj==&vol2) volume(1,(int)(60-pos)*511);
		if (obj==&vol3) volume(2,(int)(60-pos)*511);
		if (obj==&vol4)	volume(3,(int)(60-pos)*511);
	}
	show_mouse();
};


void closer_pressed( void )
{
	while (mb==1) {
		if ((find_object(actwin,mposx,mposy)==actobj) && (actobj->state==0)) select_object(actwin,actobj);
		if ((find_object(actwin,mposx,mposy)!=actobj) && (actobj->state==1)) deselect_object(actwin,actobj);
	};
	deselect_object(actwin,actobj);
	if (find_object(actwin,mposx,mposy)==actobj) close_window(actwin);
};



/* C is shit, life suxx! */