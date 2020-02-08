#include <aes.h>
#include <stdio.h>
#include <string.h>
#include <portab.h>
#include <stdlib.h>
#include <ext.h>

/************************Prototypen*****************************/
       void   play_mod( void* );
extern void   PLAY    ( void* );

/************************Ressourcen*****************************/
#if !defined(WHITEBAK)
#define WHITEBAK    0x0040
#endif
#if !defined(DRAW3D)
#define DRAW3D      0x0080
#endif

#define FLAGS9  0x0200
#define FLAGS10 0x0400
#define FLAGS11 0x0800
#define FLAGS12 0x1000
#define FLAGS13 0x2000
#define FLAGS14 0x4000
#define FLAGS15 0x8000
#define STATE8  0x0100
#define STATE9  0x0200
#define STATE10 0x0400
#define STATE11 0x0800
#define STATE12 0x1000
#define STATE13 0x2000
#define STATE14 0x4000
#define STATE15 0x8000

TEDINFO rs_tedinfo[] =
{ "Press space to abort",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 21, 1,
  "000000000000000000000000",
  "",
  "",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 25, 1
};

RSBB0DATA[] =
{ 0x0000, 0x01C0, 0x0000, 0x0000, 
  0x0100, 0x6C00, 0x0000, 0x1D80, 
  0x1200, 0x0000, 0x1101, 0xA100, 
  0x0001, 0xD900, 0x4080, 0x003D, 
  0x5106, 0x8040, 0x0025, 0x5001, 
  0x1E20, 0x003D, 0x501A, 0x1040, 
  0x8021, 0x4004, 0x70A0, 0x4021, 
  0xC069, 0x4120, 0xA020, 0x0011, 
  0x4280, 0x5000, 0x01A7, 0x4480, 
  0xA800, 0x0041, 0x4A00, 0x5400, 
  0x00C1, 0x1200, 0xAA00, 0x0021, 
  0x2800, 0x5500, 0x7C10, 0x4800, 
  0xAA80, 0x0008, 0xA000, 0x5540, 
  0x0F05, 0x2000, 0xAAA0, 0x0042, 
  0x8000, 0x5550, 0x1C40, 0x8000, 
  0xAAB0, 0x2248, 0x0000, 0x5550, 
  0x4348, 0x00FF, 0x2AA0, 0x8748, 
  0x0180, 0x152F, 0x0E40, 0x0100, 
  0x0A50, 0x1C00, 0x0100, 0x07A0, 
  0x3800, 0x0300, 0x0040, 0x7000, 
  0x0600, 0x0040, 0xE000, 0x1C00, 
  0x0021, 0xC00F, 0xF000, 0x0013, 
  0x8038, 0x0000, 0x000F, 0x0060, 
  0x0000, 0x0002, 0x01C0, 0x0000, 
  0x0000, 0x0300, 0x0000, 0x07FC, 
  0x3E00, 0x0000, 0x0C06, 0x6000, 
  0x0000, 0x1803, 0xC000, 0x0000, 
  0x7000, 0x0000, 0x0000, 0xC000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000
};

BITBLK rs_bitblk[] =
{ RSBB0DATA,   6,  40,   0,   0, 0x0001
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 FORM1 ****************************************************/
        -1,        1,        4, G_BOX     ,   /* Object 0  */
  NONE, SHADOWED, (LONG)0x00011100L,
  0x0000, 0x0000, 0x0023, 0x000C,
         2,       -1,       -1, G_TEXT    ,   /* Object 1  */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x0006, 0x0008, 0x000F, 0x0001,
         3,       -1,       -1, G_IMAGE   ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_bitblk[0],
  0x0018, 0x0007, 0x0006, 0x0802,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"ATARI in Concert",
  0x000A, 0x0002, 0x0010, 0x0001,
         0,       -1,       -1, G_TEXT    ,   /* Object 4  */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[1],
  0x0005, 0x0005, 0x0018, 0x0001
};

/*************************************************************/

main()
{
	char  	fs_inpath[128]="*.MOD",
		  	fs_infile[13],
		  	f_name[132]; 
	int   	fs_exbut,pos,f_handle;
	size_t 	f_lof;
	void 	*f_buf;	
	
	
	appl_init();
	for(pos=0;pos<=4;rsrc_obfix(&rs_object[0],pos++));
	
	
	
		do
		{
			strset(fs_infile,0);
			strset(f_name,0);
			fsel_input(fs_inpath,fs_infile,&fs_exbut);
			if( !fs_exbut ) break;
			
			for(pos=0;strpbrk(fs_inpath+pos,"\\");pos++);
			strncpy(f_name,fs_inpath,pos);
			if((f_handle = open( strcat(f_name,fs_infile),O_RDONLY  )) >=0)
			{
				f_lof = lseek(f_handle,0,SEEK_END);
				if( (f_buf = malloc( f_lof ) )>0 )
				{
					lseek(f_handle,0,SEEK_SET);
					read(f_handle,f_buf,f_lof);
					play_mod(f_buf);
					free(f_buf);
				}
				else form_alert(1,"[3][Out of memory!][ Stop ]");
				close(f_handle);
			}
			else form_alert(1,"[3][Could not open file!][ Stop ]");
		}
		while( fs_exbut );

	appl_exit();
	return 0;
}

	
void play_mod( void *f_buf )
{
	int fmx,fmy,fmw,fmh;

	strncpy(rs_object[4].ob_spec.tedinfo->te_ptext,strupr( (char*)f_buf ),24);

	form_center(&rs_object[0],&fmx,&fmy,&fmw,&fmh);
	form_dial(FMD_START,fmx-1,fmy-1,fmw+3,fmh+3,fmx-1,fmy-1,fmw+3,fmh+3);
	objc_draw(&rs_object[0],0,5,fmx-1,fmy-1,fmw+3,fmh+3);
			     			  	
	graf_mouse(M_OFF,0);
	PLAY( f_buf );
	graf_mouse(M_ON,0);
	
	form_dial(FMD_FINISH,fmx-1,fmy-1,fmw+3,fmh+3,fmx-1,fmy-1,fmw+3,fmh+3);
}

