/*---------------------------------------------------------------------------------*/
/*

	main.cpp


	Some general Windows template code.

	Still a bit buggy, but it's ok for the purpose.

	Uses int main() startup, therefore it's a standard console program.
	WinMain___( ... ) starts the Windows platform specific procedure.
	The message polling could/should be thread-based (if that works...) so
	that the console could be still used.

	


	(w)'2003/2013 Defjam/Checkpoint..http://checkpoint.atari.org

 */
//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
#include <stdio.h>
#include <conio.h>
#include <math.h>
#include <windows.h>
#include <time.h>
//---------------------------------------------------------------------------------
#include "datatypes.h"
#include "main.h"
#include "filestuff.h"
#include "display.h"

#include "bresenham_line.h"
#include "test_effect.h"


#include "tri_map_fixed.h"


#include "bmp_convert.h" 

#include "obj_reader.h"



//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
//	Windows specific globals.
HINSTANCE hInstance;
HDC hDC;
#define WND_CLASSNAME "Windows_template"
char wtitle[] = WND_CLASSNAME;
//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------


int display_mode = RENDER_TEXMAPPED;

char bmp_tc_256x256_fname[] = "trntbl_TC.bmp";
// "THDTEX_truecolor.bmp";	// 256x256x24

char obj_fname[512] = "turntable_base.obj";
//"turntable.obj";





char obj_fname_list[32][512] = {
	"turntable_arm.obj",
	"turntable_base2.obj",
	"turntable_base.obj",
	"turntable_record.obj",
	0
};

char save_fname_list[32][512] = {
	"ARM.ST3",
	"BASE2.ST3",
	"BASE.ST3",
	"LABEL.ST3",
	0
};

int sel_obj_ok;

void select_obj_file()
{
	int num,sel,selok;
	int fsize;

	sel_obj_ok = 0;

	printf("\n\nI have the following OBJs in my list:\n");

	for(num=0;num<32;num++)
	{
		if( obj_fname_list[num][0] == 0) break;		
		printf("%i - %s\n",1+num, obj_fname_list[num]);
	}
	
	do
	{
		sel = getch();
		sel = sel-'0';
		selok = 1;
		if(sel<1)	selok = 0;
		if(sel>num)	selok = 0;
		if(selok==0) printf("\nInvalid input!!");
	}while(selok==0);

	//printf("\n\n%i",sel);
	//getch();

	sel--;

	strcpy(obj_fname, obj_fname_list[sel] );

	strcpy(st_output_fname, save_fname_list[sel] );


	fsize = get_filesize(obj_fname);
	if(fsize!=-1) sel_obj_ok = 1;
}


void select_display_mode()
{
	printf("\n\nSelect display-mode\n");
	printf("1 - RENDER_TEXMAPPED\n");
	printf("2 - RENDER_FLAT_LIGHT\n");
	printf("3 - RENDER_LINES_HIDDEN\n");
	printf("4 - RENDER_LINES\n");
	printf("other - RENDER_TEXMAPPED\n");

	display_mode = getch();
	display_mode = display_mode - '0';
}

char bmp_fname[]= "tex_girl_exocet.bmp";

int bmp_src_size;

u8 bmp_buffer[8*65536];
u8 buffer[8*65536];

u8 texture0[tex_y][tex_x];


u32 texture_tc_256x256[256*256];


void bmp_to_tc(u8 *bmp_ptr,u32 *tc_ptr)
{
  u32 rgb[256];
  int r,g,b;
  char cr,cg,cb;
  unsigned short int c1,c2;

  int i,xp,yp;

  u32 *tc_ptr_temp;
  unsigned char *bmp_ptr_temp;
  unsigned char chunky;

  tc_ptr_temp=tc_ptr;

  bmp_ptr+=54;		// skip header

  bmp_ptr+=(255*256*3);

  for(yp=0;yp<256;yp++)
  {
    bmp_ptr_temp=bmp_ptr;

    for(xp=0;xp<256;xp++)
     {
         r=bmp_ptr_temp[2];
    	 g=bmp_ptr_temp[1];
     	 b=bmp_ptr_temp[0];
		rgb[0]=r*65536+g*256+b;
		bmp_ptr_temp+=3;
		*tc_ptr_temp++=rgb[0];
     }
     bmp_ptr-=(256*3);	// next line
   }
}

void texture_init()
{
	load_file( bmp_tc_256x256_fname, (u8*)&buffer);

	bmp_to_tc( buffer, texture_tc_256x256); //truecolor
}


int colclip(int c)
{
	if(c<0)c=0;
	if(c>255)c=255;
	return c;
}


void make_lightmap()
{
	int r,g,b, color;
	int i,xp,yp;
	
	double xx,yy;
	double l;

	u32 *tc_ptr_temp;

	tc_ptr_temp = texture_tc_256x256;

	for(yp=0;yp<256;yp++)
	{
	    for(xp=0;xp<256;xp++)
		{
			xx = xp-128;
			yy = yp-128;

			//l = 64+256 - 0.75f*(xx*xx+yy*yy);

			l = xx*xx+yy*yy;

			// l = 444 - 0.5f*l;

			l = 260 - 0.25f*l - 0.05f*sqrt(l) + 0.001f*l;

			///l = 256 - 1.25f*(xx*xx+yy*yy);

			r = l+42;
			g = l;
			b = l;
			r=colclip(r);
			g=colclip(g);
			b=colclip(b);

			color = (r<<16)|(g<<8)|b;

			rgbBuffer[yp][xp] = color;

			*tc_ptr_temp++= color;
		}
	}
}


void display_bmp()
{
	int x,y;
	u8  c;
	u8  *p=bmp_buffer;
	p+=1078;	// skip header & colortable
	for(y=0;y<tex_y;y++)
	{
		for(x=0;x<tex_x;x++)
		{
			c = *(p+(tex_y-1-y)*tex_x + x);
			chunkyBuffer[y][x]=c;
		}
	}
}

void bmp_to_texture()
{
	int x,y;
	u8  c;
	u8  *p=bmp_buffer;
	p+=1078;	// skip header & colortable
	for(y=0;y<tex_y;y++)
	{
		for(x=0;x<tex_x;x++)
		{
			c = *(p+(tex_y-1-y)*tex_x + x);
			texture0[y][x]=c;
		}
	}
}


void get_bmp_colors()
{
	u32 r,g,b;
	int i;
	u8  *p=bmp_buffer;
	p+=54;		// skip header
	for(i=0;i<256;i++)
	{
		b=*p++;
		g=*p++;
		r=*p++;
		p++;
		colortable[i] = (r<<16) | (g<<8) | b;
	}
}


int Init_Effect()
{
/*
	bmp_src_size = load_file(bmp_fname,bmp_buffer);
	get_bmp_colors();
	bmp_to_texture();
//display_bmp();
*/

	convert_bmp();


	texture_init();

	clip_2d_init(0,XW-1, 0,YW-1);

	init_test_effect();

//	make_lightmap();

	return 0;
}


void display_texture_tc_test()
{
	int xp,yp;
	for(yp=0;yp<YW;yp++)
	{
		for(xp=0;xp<XW;xp++)
		{
			rgbBuffer[yp][xp] = texture_tc_256x256[(yp&255)*256 + (xp&255) ];
		}
	}
}

void set_window(int xw, int yw,u32 color)
{
	int xp,yp;
	for(yp=0;yp<yw;yp++)
	{
		for(xp=0;xp<xw;xp++)
		{
			rgbBuffer[yp][xp] = color;
		}
	}	
}

void copy_rgbBuffer_160x100()
{
	int xp,yp, x,y;
	u32 c;
	for(yp=0;yp<100;yp++)
	{
		for(xp=0;xp<160;xp++)
		{
			x = xp*4;
			y = yp*4;
			c = rgbBuffer[yp][xp];

			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			x-=4; y++;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			x-=4; y++;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			x-=4; y++;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
		}
	}
}

void copy_rgbBuffer_160x100_over()
{
	int over = 0;
	int xp,yp, x,y;
	u32 c;
	for(yp=0;yp<(100+over);yp++)
	{
		for(xp=0;xp<(160+over);xp++)
		{
			x = xp*4;
			y = yp*4;
			c = rgbBuffer[yp+(YW-100-over)/2][xp+(XW-160-over)/2];

			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			x-=4; y++;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			x-=4; y++;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			x-=4; y++;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
			rgbBuffer_display[y][x++] = c;
		}
	}
}

void copy_rgbBuffer()
{
	memcpy(rgbBuffer_display, rgbBuffer, sizeof(rgbBuffer) );
}

int	Main_Effect()
{ 
	//---------------------------
	clock_t t;
	int rout_cpu;
	int rout_cpu_max=0;
	int sync_to_cpu_time = 20;
	//---------------------------
	t = clock();
	//---------------------------

//do_test_effect();
//chunky_to_rgb();

//	clear_rgbBuffer(0x00330011);

	set_window(160,100, 0x402060);
		
	do_test_effect();

//	copy_rgbBuffer_160x100_over();

	copy_rgbBuffer_160x100();
//copy_rgbBuffer();


	rout_cpu = 0;
	while(rout_cpu < sync_to_cpu_time)	// sync to <sync_to_cpu_time>
	{
		rout_cpu = clock() - t;
	}


	if(rout_cpu>rout_cpu_max)
	{
		rout_cpu_max = rout_cpu;
		// printf("\n%i",rout_cpu);
	}

	return 0;
}


int wait_key()
{
	return getch();
}

/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/
void Fill_Test_RGB()
{
	static u32 cyc=0;
	int x,y;
	for(y=0;y<YW;y++)
	{
		for(x=0;x<XW;x++)
		{
			rgbBuffer[y][x] = x+y+cyc;
		}
	}
	cyc++;
}
/*---------------------------------------------------------------------------------*/
void Fill_Test_CHUNKY()
{
	static u8 cyc=0;
	int x,y;
	for(y=0;y<YW;y++)
	{
		for(x=0;x<XW;x++)
		{
			chunkyBuffer[y][x] = x+y+cyc;
		}
	}
	cyc++;
}
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/


			   


/*---------------------------------------------------------------------------------*/
int Window_Update() 
{
	static int WU_Sem=0;

	BITMAPINFOHEADER	bmInfoHdr;
	int width = XW_D;
	int height= YW_D;
	int xStart= 0;
	int yStart= 0;

	if(WU_Sem) return -1;
	WU_Sem++;

	/*----- Display device independent bitmap -----*/
	bmInfoHdr.biSize	=	sizeof (BITMAPINFOHEADER);
	bmInfoHdr.biWidth	=   width;
	bmInfoHdr.biHeight	=	-height;		// Negative --> correct display!
	bmInfoHdr.biPlanes	=	1;
	bmInfoHdr.biBitCount=	32;
	bmInfoHdr.biCompression		= 0;
	bmInfoHdr.biSizeImage		= 0;
	bmInfoHdr.biXPelsPerMeter	= 0;
	bmInfoHdr.biYPelsPerMeter	= 0;
	bmInfoHdr.biClrUsed			= 0;
	bmInfoHdr.biClrImportant	= 0;

	SetDIBitsToDevice (hDC, xStart, yStart, width, height,
		0,  0, 0,  height, rgbBuffer_display, (BITMAPINFO *) &bmInfoHdr,
		DIB_RGB_COLORS);

	WU_Sem--;
	return 0;
}
/*---------------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------------*/
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	long return_code=0;
	WPARAM command;

	switch (message)
	{
	case WM_CREATE:
		break;

	case WM_PAINT:
		Window_Update();
		break;

	case WM_COMMAND:
		command = wParam;
		break;

	case WM_DESTROY:
		PostQuitMessage(0);
		return_code = 0;
		return return_code;
		break;

	default:
		break;
	}

	return_code = DefWindowProc(hWnd, message, wParam, lParam);
	return return_code;
}
/*---------------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------------*/
int WinMain___(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)
{
	WNDCLASSEX	wc;
    HWND		hwnd;
	MSG	 msg;
	BOOL bGotMsg;

	/* fill WNDCLASSEX structure */
	wc.cbSize		= sizeof(WNDCLASSEX);
	wc.style		= CS_HREDRAW | CS_VREDRAW;
	wc.lpfnWndProc	= (WNDPROC)WndProc;
	wc.cbClsExtra	= 0;
	wc.cbWndExtra	= 0;
	wc.hInstance	= hInstance;
	wc.hIcon		= NULL;

	wc.hCursor		= CopyCursor(LoadCursor(NULL, IDC_ARROW));
	wc.hbrBackground= (HBRUSH)(COLOR_WINDOW+1);
	wc.lpszMenuName	= NULL;
	wc.lpszClassName= WND_CLASSNAME;
	wc.hIconSm		= NULL;
	RegisterClassEx(&wc);
	
	hwnd = CreateWindow(WND_CLASSNAME, wtitle, WS_OVERLAPPEDWINDOW,
						CW_USEDEFAULT,CW_USEDEFAULT,
						XW_D+64, YW_D+64,
						NULL, NULL, hInstance, NULL);

	ShowWindow	( hwnd, SW_SHOWNORMAL );
	UpdateWindow( hwnd );

	
	hDC=GetDC(hwnd);			// Display Context



	Init_Effect();



	/* message loop */
	do
	{
		bGotMsg = PeekMessage(&msg, NULL, 0, 0, 0);
		if(bGotMsg)
		{
			GetMessage( &msg,NULL,0,0 );
			TranslateMessage( &msg );
			DispatchMessage	( &msg );
		}

		Main_Effect();
		Window_Update();
	}
	while( (msg.message!=WM_QUIT) );
	return 0;
}
/*---------------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------------*/
int main()
{

	hInstance = GetModuleHandle(NULL);

//	printf("\nhInstance:\t\t0x%X",hInstance);


	printf("\nWavefront OBJ reader & converter");
	printf("\n(w)2014 lsl/checkpoint\n\n");


	select_obj_file();
	if(sel_obj_ok == 0) return -1;


	select_display_mode();


//	_3ds_load_main();


	WinMain___(hInstance,NULL,NULL,SW_SHOWDEFAULT);


	printf("\n\nWinCallback successfully closed.\n\n");
	// wait_key();
	return 0;
}
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/