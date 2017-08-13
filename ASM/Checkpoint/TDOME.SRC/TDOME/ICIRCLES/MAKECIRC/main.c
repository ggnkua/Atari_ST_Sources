/*---------------------------------------------------------------------------------*/
/*

	main.c


	Some general Windows template code.

	Still a bit buggy, but it's ok for the purpose.

	Uses int main() startup, therefore it's a standard console program.
	WinMain___( ... ) starts the Windows platform specific procedure.
	The message polling could/should be thread-based (if that works...) so
	that the console could be still used.

	


	(w)'2003 Defjam/Checkpoint..http://checkpoint.atari.org

 */
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/
#include <stdio.h>
#include <conio.h>
#include <math.h>
#include <windows.h>
/*---------------------------------------------------------------------------------*/
#include "datatypes.h"
#include "filestuff.h"
#include "display.h"
/*---------------------------------------------------------------------------------*/
int Window_Update() ;
/*---------------------------------------------------------------------------------*/


/*
char gfx_name[]="installation.bmp";
int NUM_BLOCKS = 9;
char outname[]="0_INST.GFX";
*/

/*
char gfx_name[]="Kuenstlerbund.bmp";
int NUM_BLOCKS = 4;
char outname[]="0_KB.GFX";
*/

/*
char gfx_name[]="ort.bmp";
int NUM_BLOCKS = 5;
char outname[]="0_ORT.GFX";
*/

/*
char gfx_name[]="performance.bmp";
int NUM_BLOCKS = 11;
char outname[]="0_PERF.GFX";
*/

/*
char gfx_name[]="10years.bmp";
int NUM_BLOCKS = 2;
char outname[]="0_10Y.GFX";
*/

char gfx_name[]="checkpoint.bmp";
int NUM_BLOCKS = 3;
char outname[]="0_CHECK.GFX";


int gfx_x;
int gfx_y;


u8 *gfx_buffer;

u8 gfx[YW][XW];

u32 coltable[256];

u8 *output;
u8 *optr;

/*---------------------------------------------------------------------------------*/
/* the header file(s) of the effect/routine to test */
//#include "perln256.h"

/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/
/*
	Windows specific globals.
 */
HINSTANCE hInstance;
HDC hDC;
#define WND_CLASSNAME "bmp convert"
char wtitle[] = WND_CLASSNAME;
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/

#define CIRC_X (320+320)
#define CIRC_Y (200+200)
#define CSIZE 12

int display_circle()
{
	int x,y,i,r;
	int xq,yq;
	int c;
	int bitsleft = 8;
	int bits = 0;
	u8 *optr;

	optr = output;

	for(i=0;i<256;i++)	coltable[i] = 0x00FFFFFF;
	coltable[0] = 0;

	for(y=0;y<CIRC_Y;y++)
	{
		for(x=0;x<CIRC_X;x++)
		{
			xq = (x-CIRC_X/2)*(x-CIRC_X/2);
			yq = (y-CIRC_Y/2)*(y-CIRC_Y/2);
			r  = sqrt(xq+yq);

			c = r; //&0x08;
			c = c - ((c/CSIZE)*CSIZE);

			if(c>(CSIZE/2))
			{
				rgbBuffer[y][x] =    0x00ffffff;
				c = 0xff;
			}
			else
			{
				rgbBuffer[y][x] =     0x00000000;
				c = 0x00;
			}
			
			bits=bits<<1;
			if(c) bits++;

			bitsleft--;
			if(bitsleft==0)
			{
				*optr++=bits;
				bitsleft=8;
				bits=0;
			}
		}
	}

	save_file("FSINTERF.GFX",output,optr-output);

	Window_Update();
	return 0;
}


int Init_Effect()
{
	//Perln256__Init();
	return 0;
}

int	Main_Effect()
{ 
	//Perln256__Main();
	return 0;
}


int waitkey()
{
	return getch();
}

u32 read_LE(u8 *ptr)
{
	u32 value = ptr[3]<<24 | ptr[2]<<16 | ptr[1]<<8 | ptr[0];
	return value;
}


/*---------------------------------------------------------------------------------*/
int load_gfx(char *fname)
{
	int x,y,i;
	int lsize;
	u8 *ptr;
	lsize = get_filesize(fname);

	gfx_buffer=malloc(lsize+1024);
	load_file(fname,gfx_buffer);

	gfx_x = read_LE( 0x12 + gfx_buffer);
	gfx_y = read_LE( 0x16 + gfx_buffer);

	for(i=0;i<256;i++)	coltable[i] = 0x00FFFFFF;
	coltable[0] = 0;

	for(y=0;y<gfx_y;y++)
	{
		for(x=0;x<gfx_x;x++)
		{
			ptr = gfx_buffer + 1078 + x + (gfx_y-1-y)*gfx_x;
			gfx[y][x] = 0xff - (*ptr);
			//rgbBuffer[y][x] = coltable[ *ptr ];
		}
	}

	printf("\n%i",lsize);
	//waitkey();

	return 0;
}


int skip_empty_lines(int ystart)
{
	int x,y,ys;

	for(y=ystart;y<gfx_y;y++)
	{
		for(x=0;x<gfx_x;x++)
		{
			if (gfx[y][x])
			{
				ys = y;
				y = gfx_y;
				break;
			}
		}
	}
	printf("\n\nys: %i",ys);
	//waitkey();
	return ys;
}

int get_end_lines(int ystart)
{
	int x,y,ys,empty_count;

	for(y=ystart;y<gfx_y;y++)
	{
		empty_count = 0;
		for(x=0;x<gfx_x;x++)
		{
			if (gfx[y][x] ==0) empty_count++;
		}
		if(empty_count==gfx_x)
		{
			ys = y;
			break;
		}
	}
	printf("\n\nyend: %i",ys);
	//waitkey();
	return ys;
}

int get_x_max(int y_start,int y_end)
{
	int x,y,xmax,hit;

	hit = 0;
	for(x=gfx_x-1;x>=0;x--)
	{
		for(y=y_start;y<y_end;y++)
		{
			if (gfx[y][x] !=0)
			{
				xmax = x;
				y=y_end;
				hit = 1;
			}
		}
		if(hit) break;
	}
	xmax++;

	printf("\nxmax: %i",xmax);

	x = xmax &15;		// align to 16'er boundary
	if(x==0);
	else xmax+=16-x;

	printf("\nxmax: %i",xmax);
	//waitkey();
	return xmax;
}


void write16_be(int val)
{
	*optr++=val>>8;
	*optr++=val&255;
}

int output_bitplane(int x_max,int y_start,int y_end)
{
	int x,y,c,size;
	int bitsleft = 8;
	int bits = 0;

	optr = output;
	write16_be(x_max);
	write16_be(y_end-y_start);

	for(y=y_start;y<y_end;y++)
	{
		for(x=0;x<x_max;x++)
		{
			bits=bits<<1;
			c = gfx[y][x];
			if(c) bits++;

			bitsleft--;
			if(bitsleft==0)
			{
				*optr++=bits;
				bitsleft=8;
				bits=0;
			}
		}
	}
	size = optr-output;
	printf("\nsize: %i",size);

	save_file(outname,output,size);

	printf("\n%s\n",outname);

	outname[0]++;
	if(outname[0] == ('9'+1) ) outname[0]='A';

	return 0;
}



int analyse_block()
{
	int x,y,i;
	int y_start,y_end;
	int x_max;
	int blocks;
	u8 c;

	y_start = 0;

	for(blocks=0;blocks<NUM_BLOCKS;blocks++)
	{
		y_start = skip_empty_lines(y_start);
		y_end	= get_end_lines(y_start);

		x_max = get_x_max(y_start,y_end);

		output_bitplane(x_max,y_start,y_end);

		for(y=y_start;y<y_end;y++)
		{
			for(x=0;x<x_max;x++)
			{
				c = gfx[y][x];
				if(c) rgbBuffer[y][x] =    0x00ffffff;
				else rgbBuffer[y][x] =     0x00000000;
			}
		}
		Window_Update();
		//waitkey();
		y_start=y_end+1;
	}

	return 0;
}


/*---------------------------------------------------------------------------------*/


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

	output = malloc(2*65536);
	//analyse_block();

	display_circle();

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

		//Fill_Test_RGB();//Main_Effect();
		Window_Update();
	}
	while( (msg.message!=WM_QUIT) );
	return 0;
}
/*---------------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------------*/
int main()
{
	load_gfx(gfx_name);


	hInstance = GetModuleHandle(NULL);

	printf("\nhInstance:\t\t0x%X",hInstance);

	WinMain___(hInstance,NULL,NULL,SW_SHOWDEFAULT);

	/*
	add_message_queue("\nbla1");
	add_message_queue("\nbla2");
	display_message_queue();
	*/


	printf("\n\nWinCallback successfully closed.\n\n");
	// wait_key();
	return 0;
}
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/