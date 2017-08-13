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
#include <windows.h>
/*---------------------------------------------------------------------------------*/
#include "datatypes.h"
#include "filestuff.h"
#include "display.h"

#include "gfx_load.h"
/*---------------------------------------------------------------------------------*/
int Window_Update() ;
/*---------------------------------------------------------------------------------*/

char bmp_fname[512] = "td1-bj_1_320x200x256.bmp";

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

int Init_Effect()
{
	load_bmp(bmp_fname);

	return 0;
}


int	Main_Effect()
{

	return 0;
}


int waitkey()
{
	return getch();
}


u32 read32_LE(u8 *ptr)
{
	u32 value = ptr[3]<<24 | ptr[2]<<16 | ptr[1]<<8 | ptr[0];
	return value;
}

u16 read16_LE(u8 *ptr)
{
	u32 value = ptr[1]<<8 | ptr[0];
	return value;
}

int get_yes_no()
{
	int i;
	printf(" (y/*) ?");
	i = waitkey();
	printf("\n\n");
	if( (i=='Y') || (i=='y') )	return 1;
	else						return 0;
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


//	Init_Effect();


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

		//Fill_Test_RGB();//
		
		Main_Effect();
		
		Window_Update();
	}
	while( (msg.message!=WM_QUIT) );
	return 0;
}
/*---------------------------------------------------------------------------------*/

#define TEST

/*---------------------------------------------------------------------------------*/
int main(int argc, char **argv)
{

	hInstance = GetModuleHandle(NULL);

//	printf("\nhInstance:\t\t0x%X",hInstance);

//	printf("\nargc: %i\n",argc);

#ifndef TEST
	if(argc<2)
	{
		printf("\nMISSING INPUTFILE!!");
		waitkey();
		return -1;
	}
	strcpy(bmp_fname, argv[1]);
#endif


	load_bmp(bmp_fname);


	WinMain___(hInstance,NULL,NULL,SW_SHOWDEFAULT);



	printf("\n\nWinCallback successfully closed.\n\n");
	// wait_key();
	return 0;
}
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/

