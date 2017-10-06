#include "cltr.h"
#include <ctype.h>
#include <tos.h>
#include <linea.h>			/* just to read line-a-vars */

#include <image.h>

int check_recs(int x,int y,int w,int h,int *x1,int *y1,int *w1,int *h1);
void redraw_play(int *message);
int do_control(int flag);


/*------------------------------------------------------------------------------

	quick-copy: schnelle kopierroutinen (nur standard ST-high artige auflîsungen)

------------------------------------------------------------------------------*/
	/* variable fÅr ass-routinen */

void copy_120(char *dest,char *source,int lines);
void copy_144(char *dest,char *source,int lines);
void copy_168(char *dest,char *source,int lines);
void copy_160(char *dest,char *source,int lines);
void copy_200(char *dest,char *source,int lines);

void (*qcopy)(char *dest,char *source,int lines);
int copy_max,copy_min;
Copy_Out copy_out;

static void vcopy_out(void)
{
int xy[8];
int w;

	if ( copy_min<copy_max ) {
		if ( copy_min+y_off>=screen_h || x_off>=screen_w )
			return;
		if ( copy_max+y_off>=screen_h )
			copy_max=screen_h-y_off-1;
		w=width;
		if ( x_off+width>=screen_w )
			w=screen_w-x_off;

		xy[0]=0;
		xy[1]=copy_min;
		xy[2]=w-1;
		xy[3]=copy_max;
		xy[4]=x_off;
		xy[5]=y_off+copy_min;
		xy[6]=x_off+w-1;
		xy[7]=y_off+copy_max;

		if ( x_off<0 )
			xy[0]-=x_off, xy[4]=0;
		if ( xy[6]>=0 ) {
			Vsync();
			vro_cpyfm(handle,S_ONLY,xy,&buffer,&screen);
		}
		copy_min=buffer_height;
		copy_max=0;
	}
}

static void qcopy_out(void)
{
char *source,*dest;

	if ( copy_min<copy_max ) {
		if ( copy_min+y_off>=screen_h || x_off>=screen_w )
			return;
		if ( x_off+width>=screen_w ) {
			vcopy_out();
			return;
		}
		if ( copy_max+y_off>=screen_h )
			copy_max=screen_h-y_off-1;
		source=(char*)buffer_addr+(long)copy_min*buffer_width;
		dest=(char*)screen_addr+(long)(copy_min+y_off)*screen_width+x_off/8;
		Vsync();
		qcopy(dest,source,copy_max-copy_min);
		copy_min=buffer_height;
		copy_max=0;
	}
}

static void mcopy_out(void)
{
int xy[8];

	if ( copy_min<copy_max ) {
		xy[3]=wind[W_PLAY].handle;
		xy[4]=x_off;
		xy[5]=y_off+copy_min;
		xy[6]=x_off+width-1;
		xy[7]=y_off+copy_max;
		check_recs(0,0,screen_w,screen_h,xy+4,xy+5,xy+6,xy+7);
		redraw_play(xy);
		copy_min=buffer_height;
		copy_max=0;
	}
	do_control(1);
}

static void init_quickcopy(void)
{
	linea_init();
	screen_addr=(long)Logbase();
	screen_width=Linea->v_lin_wr;
}

void init_copy_out(void)
{
int w=game->block_w*game->game_width;

	quick_flag=0;
	if ( !opts.graph && planes==1 ) {
		switch ( w ) {
		  case 120:
		  	qcopy=copy_120;
		  break;
	 	  case 144:
		  	qcopy=copy_144;
		  break;
	 	  case 168:
		  	qcopy=copy_168;
		  break;
	 	  case 160:
		  	qcopy=copy_160;
		  break;
	 	  case 200:
		  	qcopy=copy_200;
		  break;
		  default:
		  	qcopy=0;
		}
		if ( qcopy ) {
			quick_flag=1;
			if ( !screen_addr )
				init_quickcopy();
		}
	}

	if ( opts.multi )
		copy_out=mcopy_out;
	else if ( quick_flag )
		copy_out=qcopy_out;
	else
		copy_out=vcopy_out;

	copy_min=buffer_height;
	copy_max=0;
}

/*------------------------------------------------------------------------------

	copy-routine zum kopieren der blîcke in den puffer
		drXX_block: kopiere monochrom direkt (blockbreite XX)
		dr_block:   kopiere via vdi

------------------------------------------------------------------------------*/

void xcopy16(void *ziel,void *quelle,int lines);
void xxcopy32(void *ziel,void *quelle,int lines,long maske);

void dr16_block(int x,int y,int col)
{
void *source,*dest;

	x=game->x_pos[x];
	y=game->y_pos[y];
	source=(void*)((char*)game->bloecke.fd_addr+col*2);
	dest=(void*)((char*)buffer.fd_addr+y*buffer_width+x/8);
								/* x immer durch 16 teilbar!!! */
	xcopy16(dest,source,game->bloecke.fd_h-1);

	if ( y<copy_min )
		copy_min=y;
	if ( y+game->block_xh>copy_max )
		copy_max=y+game->block_xh;
}

void dr20_block(int x,int y,int col)
{
void *source,*dest;
static long masks[]={~0xFFFFF000l,~0x0FFFFF00l,~0x00FFFFF0l,~0x000FFFFFl};

	x=game->x_pos[x];
	y=game->y_pos[y];
	source=(void*)((char*)game->xbloecke[(x&15)/4].fd_addr+col*4);
	dest=(void*)((char*)buffer.fd_addr+y*buffer_width+((x/8)&~1));
	xxcopy32(dest,source,game->xbloecke[0].fd_h-1,masks[(x&15)/4]);

	if ( y<copy_min )
		copy_min=y;
	if ( y+game->block_xh>copy_max )
		copy_max=y+game->block_xh;
}

void dr24_block(int x,int y,int col)
{
void *source,*dest;
static long masks[]={~0xFFFFFF00l,~0x00FFFFFFl};

	x=game->x_pos[x];
	y=game->y_pos[y];
	source=(void*)((char*)game->xbloecke[(x&15)/8].fd_addr+col*4);
	dest=(void*)((char*)buffer.fd_addr+y*buffer_width+((x/8)&~1));
	xxcopy32(dest,source,game->xbloecke[0].fd_h-1,masks[(x&15)/8]);

	if ( y<copy_min )
		copy_min=y;
	if ( y+game->block_xh>copy_max )
		copy_max=y+game->block_xh;
}

void dr_block(int x,int y,int col)
{
int xy[8],yy;

	xy[0]=col*game->source_width;
	xy[1]=0;
	xy[2]=xy[0]+game->block_xw;
	xy[3]=game->block_xh;
	xy[4]=game->x_pos[x];
	yy=xy[5]=game->y_pos[y];
	xy[6]=xy[4]+game->block_xw;
	xy[7]=xy[5]+game->block_xh;
	vro_cpyfm(handle,S_ONLY,xy,&game->bloecke,&buffer);
	if ( yy<copy_min )
		copy_min=yy;
	if ( yy+game->block_xh>copy_max )
		copy_max=yy+game->block_xh;
}

/*
	ausgabe eines blockes auf den BILDSCHIRM (kein puffer)
		benutzt fÅr
			preview
			statistik
*/
void dr_vdi(int x,int y,int col,int x_off,int y_off)
{
int xy[8];

	xy[0]=col*game->source_width;	/* blîcke auf wortgrenze verbreitert */
	xy[1]=0;
	xy[2]=xy[0]+game->block_xw;
	xy[3]=game->block_xh;
	xy[4]=game->x_pos[x]+x_off;
	xy[5]=game->y_pos[y]+y_off;
	xy[6]=xy[4]+game->block_xw;
	xy[7]=xy[5]+game->block_xh;
	if ( game->vdi || game->block_w==16 )
		vro_cpyfm(handle,S_ONLY,xy,&game->bloecke,&screen);
	else
		vro_cpyfm(handle,S_ONLY,xy,&game->xbloecke[0],&screen);
}

/*------------------------------------------------------------------------------

	ausgabe-routinen

------------------------------------------------------------------------------*/
void clr_feld(void)
{
	memset((char*)buffer_addr,0,buffer_size);
	redraw_play(0l);
	last_score=0;
}

void inv_feld(void)
{
int *d;
long i;

#if SOUND_LEVEL>0
	do_sound(S_NEWLEVEL);
#endif
	init_wait();
	for ( i=0,d=(int*)buffer_addr; i<buffer_size/2; i++ )
		*d++^=-1;
	redraw_play(0l);
	do_wait(50);
	for ( i=0,d=(int*)buffer_addr; i<buffer_size/2; i++ )
		*d++^=-1;
	redraw_play(0l);
}

/*------------------------------------------------------------------------------

	initialisierung der blîcke aus image-datei

------------------------------------------------------------------------------*/
static int check_blocks(MFDB *blocks)
{
MFDB block;
int blen;
int i,j;
char *b;
int xy[8];

	block=*blocks;
	block.fd_w=blocks->fd_w/16;
	block.fd_wdwidth=block.fd_w/16;
	if ( block.fd_w&15 )
		block.fd_wdwidth++;
	blen=2*block.fd_wdwidth*block.fd_nplanes*block.fd_h;
	block.fd_addr=malloc(blen);
	if ( !block.fd_addr )
		return -1;				/* error */
	memset(block.fd_addr,0,blen);
	xy[4]=0;
	xy[5]=0;
	xy[6]=block.fd_w-1;
	xy[7]=block.fd_h-1;
	for ( i=15; i>=8; i-- ) {
		xy[0]=block.fd_w*i;
		xy[1]=0;
		xy[2]=block.fd_w*i+block.fd_w-1;
		xy[3]=block.fd_h-1;
		vro_cpyfm(handle,S_ONLY,xy,blocks,&block);
		b=block.fd_addr;
		for ( j=0; j<blen; j++ )
			if ( *b++!=0 )
				return i;
	}
	free(block.fd_addr);
	return i;
}

int set_xmfdb(GAME *game,int width,int cnt)
{
int dx,ddx,i,j;
int xy[8];

	dx=width%16;

	for ( i=ddx=0; i<cnt; i++,ddx+=dx ) {
		game->xbloecke[i]=game->bloecke;
		game->xbloecke[i].fd_wdwidth=32;
		game->xbloecke[i].fd_w=32*16;
		game->xbloecke[i].fd_addr=malloc(32*2*game->bloecke.fd_h);
		if ( !game->xbloecke[i].fd_addr )
			return 0;

		memset(game->xbloecke[i].fd_addr,0,32*2*game->bloecke.fd_h);

		for ( j=0; j<16; j++ ) {
			xy[0]=j*game->block_w;
			xy[1]=0;
			xy[2]=xy[0]+game->block_xw;
			xy[3]=game->block_xh;
			xy[4]=j*32+ddx;
			xy[5]=0;
			xy[6]=xy[4]+game->block_xw;
			xy[7]=game->block_xh;
			vro_cpyfm(handle,S_ONLY,xy,&game->bloecke,&game->xbloecke[i]);
		}
	}

	game->source_width=32;
	return 1;
}

int init_image(GAME *game,char *name,int _argc,char **_argv)
{
char fname[256],xname[32],*h;
MFDB pic;
int i;

	game->vdi=-1;

		/* name nach kleinbuchstaben wandeln */
	strcpy(xname,game->name);
	for ( h=xname; *h!=0; h++ )
		*h=tolower(*h);

	sprintf(fname,"%s.IMG\\%s",xname,name);
	for ( i=1; i<_argc; i++ ) {
		h=strrchr(_argv[i],'\\');
		if ( !h )
			h=_argv[i];
		else
			h++;
		if ( tolower(*h)==*xname ) {
			strcpy(fname,_argv[i]);
			break;
		}
	}

	if ( load_img(fname,&pic)==IMG_OK ) {
		if ( transform_img(&pic,planes,handle)==TRFM_OK ) {
			game->bloecke=pic;
			game->bloecke.fd_stand=0;

			game->block_w=game->bloecke.fd_w/16;
			game->block_h=game->bloecke.fd_h;
			game->block_xw=game->block_w-1;
			game->block_xh=game->block_h-1;
			game->last_flash=check_blocks(&game->bloecke);
			if ( game->last_flash<0 ) {
				free(game->bloecke.fd_addr);
				return 0;
			}
			game->vdi=1;

			game->source_width=game->block_w;
			game->dr_block=dr_block;

			if ( planes==1 && (game->block_w==16 || game->block_w==20 || game->block_w==24) ) {
				if ( game->block_w==16 ) {
					game->vdi=0;
					game->dr_block=dr16_block;
				}
				else if ( game->block_w==20 ) {
					if ( set_xmfdb(game,20,4) ) {
						game->vdi=0;
						game->dr_block=dr20_block;
					}
				}
				else if ( game->block_w==24 ) {
					if ( set_xmfdb(game,24,2) ) {
						game->vdi=0;
						game->dr_block=dr24_block;
					}
				}
			}

			for ( i=0; i<game->game_width; i++ )
				game->x_pos[i+1]=i*game->block_w;
			for ( i=0; i<game->game_height; i++ )
				game->y_pos[i+game->game_firstline]=i*game->block_h;

			return 1;
		}
	}
	if ( pic.fd_addr )
		free(pic.fd_addr);
	return 0;
}

static long fsel;

static int fsel_check(void)
{
long get_cookie(long cookie);

	if( !fsel )
		fsel=get_cookie('FSEL');
	return fsel ? 1 : 0;
}

void change_stones(void)
{
char soll_path[128],path[128],name[32],*h;
int but,i;
int reopen_window(void);

	path[0]=Dgetdrv()+'A';
	path[1]=':';
	Dgetpath(path+2,0);
	strcat(path,"\\");
	strcat(path,game->name);
	strcat(path,".IMG");
	strcpy(soll_path,path);
	strcat(path,"\\*.IMG");

	if ( fsel_check() || _GemParBlk.global[0]!=0x200 && _GemParBlk.global[0]>=0x130 )
		fsel_exinput(path, name, &but, " select stones ");
	else
		fsel_input(path, name, &but);

	h=strrchr(path,'\\');
	if ( h )
		*h=0;

	if ( stricmp(path,soll_path) ) {
		wind_update(BEG_UPDATE);
		i=form_alert(1,"[1][ | stones-file must be | in subdir to coltris... | ][  Copy  |Abort]");
		wind_update(END_UPDATE);
		if ( i==1 ) {
			int read,write;
			long len;
			char *puffer=malloc(4096);
			if ( !puffer ) {
				wind_update(BEG_UPDATE);
				form_error(8);
				wind_update(END_UPDATE);
			}
			else {
 				strcat(soll_path,"\\");
 				strcat(soll_path,name);
 				strcat(path,"\\");
 				strcat(path,name);
 				read=Fopen(path,0);
				if ( read<0 )
					return;
 				write=Fcreate(soll_path,0);
				if ( write<0 )
					{ Fclose(read); return; }
				do {
	 				len=Fread(read,4096l,puffer);
	 				Fwrite(write,len,puffer);
				} while ( len==4096l );
				Fclose(read);
				Fclose(write);
				free(puffer);
			}
		}
		else
			return;
	}

	if ( but ) {
	  GAME temp;

		temp=*game;
		temp.bloecke.fd_addr=0l;
		for ( i=0; i<4; i++ )
			temp.xbloecke[i].fd_addr=0l;

		if ( init_image(&temp,name,0,0l) ) {
			strcpy(opts.stone_file[opts.play_mode][planes_nr],name);
			free(game->bloecke.fd_addr);
			for ( i=0; i<4; i++ )
				if ( game->xbloecke[i].fd_addr )
					free(game->xbloecke[i].fd_addr);

			*game=temp;
			if ( !reopen_window() )
				do_exit(5);
		}
		else {
			wind_update(BEG_UPDATE);
			form_alert(1,"[1][ | Error | | loading new stones... | ][ Ok ]");
			wind_update(END_UPDATE);
		}
	}
}

