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
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/
#include <stdio.h>
#include <conio.h>
#include <windows.h>
/*---------------------------------------------------------------------------------*/
#include "datatypes.h"
#include "main.h"
#include "filestuff.h"
#include "display.h"

#include "test_effect.h"
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/
//	Windows specific globals.
HINSTANCE hInstance;
HDC hDC;
#define WND_CLASSNAME "Windows_template"
char wtitle[] = WND_CLASSNAME;
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/

char bmp_fname[512]= "WRAZ_3.bmp";

char bmp_rasters_fname[512]= "rasters_2.bmp";


char st_rasters_fname[512] = "WRAZ.RAZ";



int bmp_src_size;

u8 bmp_buffer[4*65536];

u8 texture0[tex_y][tex_x];


u32 raster0[512];
u32 raster1[512];


u8 st_rasters[200*2*2];



void w32(u8 *p, u16 v)
{
	*p++=(v>>8);
	*p++=v;
}



void display_bmp()
{
	int x,y;
	u8  c;
	u32 color;
	u8  *p=bmp_buffer;
	p+=1078;	// skip header & colortable
	for(y=0;y<tex_y;y++)
	{
		for(x=0;x<tex_x;x++)
		{
			c = *(p+(tex_y-1-y)*tex_x + x);

			//chunkyBuffer[y][x]=c;
			color = colortable[c];

			if(c==14) color = raster0[y];
			if(c==15) color = raster1[y];
			
			rgbBuffer[y][x] = color;
		}
	}
}


int pc2st(int c)
{
	if(c<0)   c=0;
	if(c>255) c=255;

	c = (c*8)/255;
	if(c>7) c=7;
	return c;
}

u16 color2st(u32 color)
{
	int r,g,b;
	u16 col_st;

	r = (color>>16)&255;
	g = (color>>8)&255;
	b = (color)&255;

	r = pc2st(r);
	g = pc2st(g);
	b = pc2st(b);

	col_st = (r<<8)|(g<<4)|b;
	return col_st;
}


void get_rasters()
{
	int x,y,yy;
	u8  c;
	u32 color;
	u16 col_st;
	u8  *p=bmp_buffer;
	p+=1078;	// skip header & colortable

	u8 *out = st_rasters; 


	int timer_b_lines_fix = -2;


	for(yy=0;yy<tex_y;yy++)
	{
		// top
		y = yy;
		y = y+4;
		y+= timer_b_lines_fix;

		x = 0;
		c = *(p+(tex_y-1-y)*tex_x + x);
		color = colortable[c];
		col_st = color2st(color);
		w32(out, col_st); out+=2;
		raster0[yy] = color;


		// bottom
		y = yy;
		y = y-2-3;
		y+= timer_b_lines_fix;

		x = 24;
		c = *(p+(tex_y-1-y)*tex_x + x);
		color = colortable[c];
		col_st = color2st(color);
		w32(out, col_st); out+=2;
		raster1[yy] = color;
	}

	save_file(st_rasters_fname, st_rasters, sizeof(st_rasters) );

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
	// init rasters
	bmp_src_size = load_file(bmp_rasters_fname,bmp_buffer);
	get_bmp_colors();
	get_rasters();


	// init gfx
	bmp_src_size = load_file(bmp_fname,bmp_buffer);
	get_bmp_colors();
	bmp_to_texture();

	display_bmp();
	
	init_test_effect();

	return 0;
}

int	Main_Effect()
{ 
	do_test_effect();

//	chunky_to_rgb();
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
	int width = XW;
	int height= YW;
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
		0,  0, 0,  height, rgbBuffer, (BITMAPINFO *) &bmInfoHdr,
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
						XW+64, YW+64,
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

	printf("\nhInstance:\t\t0x%X",hInstance);

	WinMain___(hInstance,NULL,NULL,SW_SHOWDEFAULT);


	printf("\n\nWinCallback successfully closed.\n\n");
	// wait_key();
	return 0;
}
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/