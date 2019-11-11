/* ==================================================================== */
/*	Serendipity: Main and supporting routines			*/
/* ==================================================================== */

#include	<sys\minimum.h>		/* Give us a nice small program	*/
#include	<osbind.h>		/* Gemdos bindings		*/
#include	<string.h>		/* String handling header	*/

#include	"globals.h"		/* Our own global declarations	*/


/*	This file contains the infamous "main", the initialisation	*/
/*	and program close-down routines, and a number of supporting	*/
/*	utility routines which are called from all over the shop	*/


/* -------------------------------------------------------------------- */
/*	Main program entry point					*/
/* -------------------------------------------------------------------- */

main()
{
	int	x,y;

	initialise();  mode_2(0);  mode_1(15);

	do {	mouse(&x,&y);

		switch (which(x,y)) {

			case -1: be_serious();	break;
			case 2:  trouble();	break;
			case 3:  show_info();	break;
			case 4:  play_game();	break;
			case 5:  choose_game();	break;
			case 6:  global_help();	break;
			case 9:  quit_prog();	break;

			default: inactive();	break;

			}

		} while (!quit_flag);

	close();
}


/* -------------------------------------------------------------------- */
/*	Program initialisation						*/
/* -------------------------------------------------------------------- */

initialise()
{
	static char	a[] =
	"[0][ |>>  SERENDIPITY  <<  | |Low Resolution Only  | ][Dammit!]";
	static char	b[] =
	"  Peter Bailey, November 1990";

	register int	i;
	int		x,fh;
	long		t;
	void		capture_palette();

	appl_init();  Supexec(capture_palette);

	if (Getrez()) { form_alert(1,a); appl_exit(); exit(0); }

	for (i=1; i<10; work_in[i++]=1);  work_in[10]=2;

	handle = graf_handle(&x,&x,&x,&x);

	v_opnvwk(work_in,&handle,work_out);

	v_hide_c(handle);  v_clrwk(handle);  v_show_c(handle,1);

	t = (long) Malloc(10240L+32000L);

	buf = (long *) (((t+4)/4)*4);  buffer = (char *) (buf+2560);

	s_mfdb.address = (long)(buf+32);
	d_mfdb.address = (long)Physbase();
	s_mfdb.width   = d_mfdb.width   = 320;
	s_mfdb.height  = d_mfdb.height  = 200;
	s_mfdb.points  = d_mfdb.points  = 20;
	s_mfdb.format  = d_mfdb.format  = 1;
	s_mfdb.planes  = d_mfdb.planes  = 4;

	fh=(int)Fopen("SRNDPTY.SCR",0); Fread(fh,10240L,buf);  Fclose(fh);
	fh=(int)Fopen("SRNDPTY.SND",0); Fread(fh,594L,&sound); Fclose(fh);

	set_screen();  vst_height(handle,6,&x,&x,&x,&x);  vst_color(handle,14);

	b[0]=189;  v_gtext(handle,44,190,b);
}


/* -------------------------------------------------------------------- */
/*	Grab the load-time palette for end-of-run restoration		*/
/* -------------------------------------------------------------------- */

capture_palette()
{
	register int	*hwp,i;

	hwp = (int *) 0xff8240;  for (i=0; i<16; ++i) old_palette[i] = *hwp++;
}


/* -------------------------------------------------------------------- */
/*	Initialise the screen						*/
/* -------------------------------------------------------------------- */

set_screen()
{
	int	i;

	v_hide_c(handle); Setpalette(palette);

	title();  make_box();  draw_board();  parameters();

	for (i=2; i<10; button(i++)); graf_mouse(0,0L); v_show_c(handle,1);

	fade_up();
}


/* -------------------------------------------------------------------- */
/*	Fade the screen up from black to full technicolour		*/
/* -------------------------------------------------------------------- */

fade_up()
{
	int	*p,i,j,c,r,g,b,rt,gt,bt,f;

	p=(int *)(buf+1);

	do {	f=0;

		for (i=0; i<16; ++i) {

			c=palette[i];  r =c&0x7;  g =(c>>4)&0x7;  b=(c>>8)&0x7;
			c=p[i];        rt=c&0x07; gt=(c>>4)&0x7; bt=(c>>8)&0x7;

			if (r<rt) { ++r; f=1; }
			if (g<gt) { ++g; f=1; }
			if (b<bt) { ++b; f=1; }

			palette[i]=(b<<8)|(g<<4)|r;
			}

		Setpalette(palette);  Vsync();

		for (j=0; j<2000; ++j);

		} while (f);

}


/* -------------------------------------------------------------------- */
/*	Fade the screen down to black					*/
/* -------------------------------------------------------------------- */

fade_down()
{
	int	i,j,c,r,g,b,f;

	do {	f=0;

		for (i=0; i<16; ++i) {

			c=palette[i];  r =c&0x7;  g =(c>>4)&0x7;  b=(c>>8)&0x7;

			if (r) { --r; f=1; }
			if (g) { --g; f=1; }
			if (b) { --b; f=1; }

			palette[i]=(b<<8)|(g<<4)|r;
			}

		Setpalette(palette);  Vsync();

		for (j=0; j<2000; ++j);

		} while (f);

}


/* -------------------------------------------------------------------- */
/*	Draw the initial empty board					*/
/* -------------------------------------------------------------------- */

draw_board()
{
	register int	i,j;

	v_hide_c(handle);

	for (i=0; i<8; ++i) {
		for (j=0; j<8; ++j) {
			sprite(0,BY+15*i,BX+16*j);
			}
		}

	zero_board();  v_show_c(handle,1);
}


/* -------------------------------------------------------------------- */
/*	Draw the selectable pieces					*/
/* -------------------------------------------------------------------- */

draw_pieces()
{
	register int	i;

	for (i=0; i<colours; ++i) sprite(1+i,PY+15*i,PX);
}


/* -------------------------------------------------------------------- */
/*	Remove the selectable pieces from the screen			*/
/* -------------------------------------------------------------------- */

clr_pieces()
{
	register int	i;

	for (i=0; i<colours; ++i) sprite(19,PY+15*i,PX);
}


/* -------------------------------------------------------------------- */
/*	Clear the internal board for a new game				*/
/* -------------------------------------------------------------------- */

zero_board()
{
	int	i,j;

	for (i=0; i<12; ++i) {
		for (j=0; j<12; ++j) {
			board[i][j]=0;
			}
		}

	for (i=0; i<12; ++i) {
		board[i][0]=board[0][i]=board[i][11]=board[11][i]=-1;
		}
}


/* -------------------------------------------------------------------- */
/*	Clear the screen board prettily					*/
/* -------------------------------------------------------------------- */

clear_board()
{
	int	x[64],i,j,p,q,s;

	for (i=0; i<64; ++i) x[i]=i;

	v_hide_c(handle);

	shuffle(x);  whistle();

	for (i=0; i<64; ++i) {
		p=BY+15*(x[i]/8); q=BX+16*(x[i]%8);
		block(16,p,q,16);
		for (s=0; s<200; ++s);
		}

	shuffle(x);

	for (i=0; i<64; ++i) {
		p=BY+15*(x[i]/8); q=BX+16*(x[i]%8);
		for (j=0; j<8; ++j) {
			block(8+j,p,q,16);
			for (s=0; s<200; ++s);
			}
		}

	zero_board();  v_show_c(handle,1);
}


/* -------------------------------------------------------------------- */
/*	Shuffle the squares for pretty random clearing			*/
/* -------------------------------------------------------------------- */

shuffle(x)
	int	x[];
{
	int	i,n,w;

	for (i=0; i<64; ++i) {
		n = ((Random()>>1) & 0xffff) % 64;
		w=x[n]; x[n]=x[i]; x[i]=w;
		}
}


/* -------------------------------------------------------------------- */
/*	Display the game parameters					*/
/* -------------------------------------------------------------------- */

parameters()
{
	static int pxy[] =
		{ IX, IY, IX+92, IY+45, IX, IY, IX+92, IY+45 };

	static char *name[] =
		{ "OPTIMISTIC", "NIHILISTIC" };

	static char *number[] =
		{ "SINGLES", "DOUBLES", "TRIPLES" };

	static char *difficulty[] =
		{ "AMATEUR", "MIDDLING", "SMARTASS" };

	int	z;

	d_mfdb.address = (long) Physbase();

	vro_cpyform(handle,0,pxy,&d_mfdb,&d_mfdb);

	vst_height(handle,6,&z,&z,&z,&z);

	line(0,name[game_mode-1]);
	line(1,number[colours-1]);
	line(2,difficulty[level-1]);
}


/* -------------------------------------------------------------------- */
/*	Display a parameter line					*/
/* -------------------------------------------------------------------- */

line(n,s)
	int	n;
	char	*s;
{
	int	x,y;

	x = IX+(92-strlen(s)*8)/2;  y = IY+13+12*n;

	vst_color(handle,6);  v_gtext(handle,x,y,s);
}


/* -------------------------------------------------------------------- */
/*	Display the title banner					*/
/* -------------------------------------------------------------------- */

title()
{
	static int n[] = { 0, 1, 2, 1, 3, 4, 5, 6, 5, 7, 8 };

	static int p[] = { 0, 28, 53, 78, 103, 128, 153, 164, 189, 200, 225 };

	int	i;

	s_mfdb.address = (long)(buf+32+1280);

	for (i=0; i<11; ++i) { letter(n[i],38+p[i]); }

	s_mfdb.address = (long)(buf+32);
}


/* -------------------------------------------------------------------- */
/*	Display one letter of the title banner				*/
/* -------------------------------------------------------------------- */

letter(n,x)
{
	int	pxy[8];

	pxy[2]=(pxy[0]=32*n)+31;  pxy[1]=0;  pxy[3]=31;
	pxy[6]=(pxy[4]=x)+31;     pxy[5]=0;  pxy[7]=31;

	vro_cpyform(handle,3,pxy,&s_mfdb,&d_mfdb);
}


/* -------------------------------------------------------------------- */
/*	Display the parameter box					*/
/* -------------------------------------------------------------------- */

make_box()
{
	register int	r,i;

	r=16;

	for (i=1; i<6; ++i) {
		block(1,TY,TX+16*i,r);  block(6,TY+45,TX+16*i,r);
		}

	for (i=1; i<3; ++i) {
		block(3,TY+15*i,TX,r);  block(4,TY+15*i,TX+92,r);
		}

	block(0,TY,TX,r);     block(2,TY,TX+92,r);
	block(5,TY+45,TX,r);  block(7,TY+45,TX+92,r);
}


/* -------------------------------------------------------------------- */
/*	Program close-down - Restore palette etc			*/
/* -------------------------------------------------------------------- */

close()
{
	fade_down();  v_hide_c(handle);  v_clrwk(handle);  v_clsvwk(handle);

	Setpalette(old_palette);  appl_exit();
}


/* -------------------------------------------------------------------- */
/*	Display one button						*/
/* -------------------------------------------------------------------- */

button(n)
	int	n;
{
	int	x,y,i;

	i = n-2;  n = 4*n;  x = frame[n];  y = frame[n+1];

	v_hide_c(handle);  sprite(9,y,x);

	if (strlen(b_text[i])>4) {
		sprite(10,y,x+16); sprite(10,y,x+32);
		sprite(10,y,x+48); sprite(11,y,x+54);
	} else {
		sprite(11,y,x+16);
		}

	set_text(0);  text(i,0);  v_show_c(handle,1);
}


/* -------------------------------------------------------------------- */
/*	Display the text on a button					*/
/* -------------------------------------------------------------------- */

text(i,c)
{
	int	b,w,z,d,x,y;
	char	*t;

	d = (i+2)*4;  x = frame[d];  y = frame[d+1];

	if ((d=strlen(t=b_text[i]))>4) b=68; else b=32;

	d = (b-d*6)/2+1;  v_gtext(handle,x+d,y+9,t);
}


/* -------------------------------------------------------------------- */
/*	Set vdi text parameters						*/
/* -------------------------------------------------------------------- */

set_text(c)
{
	int	z;

	vst_height(handle,4,&z,&z,&z,&z);  vswr_mode(handle,2);
	vst_color(handle,c);
}


/* -------------------------------------------------------------------- */
/*	Set button colours for pre-game					*/
/* -------------------------------------------------------------------- */

mode_1(f)
{
	static   int	bn[] = { 0, 1, 2, 3, 4, 7 };
	register int	i;

	v_hide_c(handle);

	set_text(f);  for (i=0; i<6; ++i) text(bn[i],f);

	v_show_c(handle,1);
}


/* -------------------------------------------------------------------- */
/*	Set button colours for during game				*/
/* -------------------------------------------------------------------- */

mode_2(f)
{
	static   int	bn[] = { 4, 5, 6, 7 };
	register int	i;

	v_hide_c(handle);

	set_text(f);  for (i=0; i<4; ++i) text(bn[i],f);

	v_show_c(handle,1);
}


/* -------------------------------------------------------------------- */
/*	Place a piece at the specified position				*/
/* -------------------------------------------------------------------- */

display(i,j,f)
{
	int	p,q,r,s;

	click();  p = BY+15*i;  q = BX+16*j;

	for (r=8; r>0; --r) { block(7+r,p,q,16); for (s=0; s<1000; ++s); }
	for (r=0; r<8; ++r) { block(8+r,p,q,16); for (s=0; s<1000; ++s); }

	sprite(f+3,p,q);
}


/* -------------------------------------------------------------------- */
/*	Display a sprite from row zero					*/
/* -------------------------------------------------------------------- */

sprite(f,y,x)
{
	block(f,y,x,0);
}


/* -------------------------------------------------------------------- */
/*	Display a sprite from the specifed row				*/
/* -------------------------------------------------------------------- */

block(f,y,x,r)
{
	int	pxy[8];

	v_hide_c(handle);

	pxy[1]=r; pxy[2]=(pxy[0]=f*16)+15; pxy[3]=r+14;

	pxy[7]=(pxy[5]=y)+14; pxy[6]=(pxy[4]=x)+15;

	s_mfdb.address = (long) (buf+32);
	d_mfdb.address = (long) Physbase();

	vro_cpyform(handle,3,pxy,&s_mfdb,&d_mfdb);

	v_show_c(handle,1);
}


/* -------------------------------------------------------------------- */
/*	The quit button was clicked					*/
/* -------------------------------------------------------------------- */

quit_prog()
{
static char a[] = "[0][ |You really want to stop?  | ][Definitely|Maybe not]";

	int	butt;

	butt = form_alert(0,a);

	if (butt==1)
		quit_flag=1;
	else
		say("INDECISIVE PILLOCK");
}


/* -------------------------------------------------------------------- */
/*	Clicked nowhere in particular					*/
/* -------------------------------------------------------------------- */

be_serious()  {  say("CLICK SOMEWHERE USEFUL, IDIOT");  clang_1(); }


/* -------------------------------------------------------------------- */
/*	Clicked on an inactive or inapplicable object			*/
/* -------------------------------------------------------------------- */

inactive()  {  say("CLICKING THERE WON'T HELP, PRAWN-BRAIN");  clang_1();  }


/* -------------------------------------------------------------------- */
/*	Set game parameters						*/
/* -------------------------------------------------------------------- */

choose_game()
{
static char a1[] =
"[0][    Choose your game, Sir  | |(1) Sudden death by lightning  |\
(2) Protracted attrition  | ][1|2]";

static char a2[] =
"[0][Scoring Philosophy  | |  (1) Optimistic |  (2) Nihilistic | ][1|2]";

static char a3[] =
"[0][       Playing Pieces  | |(1) Red only  (2) Red and blue   |\
(3) Red, blue and green  | ][1|2|3]";

static char a4[] =
"[0][  Expertise Level (be bold)  | |(1) Rather Dim (2) Averageish  |\
(3) Insufferable smartass  | ][1|2|3]";

	game_type = form_alert(0,a1);
	game_mode = form_alert(0,a2);
	colours   = form_alert(0,a3);
	level     = form_alert(0,a4);

	depth = ((level==1) ? 0 : 1);  span = ((level==3) ? 3 : 2);

	frame[7] = 15*colours;

	if (game_mode==1) value = value_1; else value = value_2;

	parameters();  say("OK, HOTSHOT");
}


/* -------------------------------------------------------------------- */
/*	Figure out what object was clicked				*/
/* -------------------------------------------------------------------- */

which(x,y)
	register int	x,y;
{
	register int	i,j;

	for (i=0; i<Frames; ++i) {
		j=i*4;
		if (x>frame[j] && x<(frame[j]+frame[j+2])) {
			if (y>frame[j+1] && y<(frame[j+1]+frame[j+3])) {
				return i;
				}
			}
		}

	return -1;
}


/* -------------------------------------------------------------------- */
/*	Display a message at the bottom of the screen			*/
/* -------------------------------------------------------------------- */

say(s)
	char	*s;
{
	static int pxy[] = { 0, 180, 319, 199, 0, 180, 319, 199 };
	int	x,z,w;

	v_hide_c(handle);

	d_mfdb.address = (long) Physbase();

	vro_cpyform(handle,0,pxy,&d_mfdb,&d_mfdb);

	vst_height(handle,6,&z,&z,&w,&z);  x=(320-strlen(s)*w)/2;

	vst_color(handle,6); v_gtext(handle,x,190,s); v_show_c(handle,1);
}


/* -------------------------------------------------------------------- */
/*	Save the screen during help					*/
/* -------------------------------------------------------------------- */

get_screen()
{
	static int pxy[] = { 0, 32, 319, 180, 0, 32, 319, 180 };

	s_mfdb.address = (long) Physbase();
	d_mfdb.address = (long) buffer;

	vro_cpyform(handle,3,pxy,&s_mfdb,&d_mfdb);
	vro_cpyform(handle,0,pxy,&s_mfdb,&s_mfdb);
}


/* -------------------------------------------------------------------- */
/*	Restore the screen after help					*/
/* -------------------------------------------------------------------- */

put_screen()
{
	static int pxy[] = { 0, 32, 319, 180, 0, 32, 319, 180 };

	s_mfdb.address = (long) buffer;
	d_mfdb.address = (long) Physbase();

	vro_cpyform(handle,3,pxy,&s_mfdb,&d_mfdb);
}


/* -------------------------------------------------------------------- */
/*	Clear the screen ready for help					*/
/* -------------------------------------------------------------------- */

clr_screen()
{
	static int pxy[] = { 0, 32, 319, 199, 0, 32, 319, 199 };

	d_mfdb.address = (long) Physbase();

	vro_cpyform(handle,0,pxy,&d_mfdb,&d_mfdb);
}
