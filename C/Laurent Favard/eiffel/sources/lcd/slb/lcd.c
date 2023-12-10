/*
** LCD.C -- 2x16 LCD Control Routines
*/

#include <portab.h>
#include <stddef.h>
#include <tos.h>
#include <ext.h>
#include <string.h>

typedef void *PD;

void cdecl LCD_DefineChar(PD *base, long fn, short nargs, short address, unsigned char *pattern); 
void cdecl LCD_DisplayOff(PD *base, long fn, short nargs);
void cdecl LCD_DisplayOn(PD *base, long fn, short nargs);
void cdecl LCD_Clear(PD *base, long fn, short nargs);
void cdecl LCD_Home(PD *base, long fn, short nargs);
void cdecl LCD_Mode(PD *base, long fn, short nargs, short mode);
void cdecl LCD_Cursor(PD *base, long fn, short nargs, short row, short column);
void cdecl LCD_CursorLeft(PD *base, long fn, short nargs);
void cdecl LCD_CursorRight(PD *base, long fn, short nargs);
void cdecl LCD_CursorOn(PD *base, long fn, short nargs);
void cdecl LCD_CursorOff(PD *base, long fn, short nargs);
void cdecl LCD_ShiftLeft(PD *base, long fn, short nargs);
void cdecl LCD_ShiftRight(PD *base, long fn, short nargs);
void cdecl LCD_DisplayCharacter(PD *base, long fn, short nargs, short a_char);
void cdecl LCD_DisplayString(PD *base, long fn, short nargs, short row, short column, char *string);
void cdecl LCD_DisplayStringCentered(PD *base, long fn, short nargs, short row, char *string);
void cdecl LCD_DisplayScreen(PD *base, long fn, short nargs, char *ptr);
void cdecl LCD_DisplayRow(PD *base, long fn, short nargs, short row, char *string);
void cdecl LCD_WipeOnLR(PD *base, long fn, short nargs, char *ptr);
void cdecl LCD_WipeOnRL(PD *base, long fn, short nargs, char *ptr);
void cdecl LCD_WipeOffLR(PD *base, long fn, short nargs);
void cdecl LCD_WipeOffRL(PD *base, long fn, short nargs);

#pragma warn -par

unsigned char LCD_CHAR_BAR1[] = {0x00,0x10,0x10,0x10,0x10,0x10,0x10,0x00};
unsigned char LCD_CHAR_BAR2[] = {0x00,0x14,0x14,0x14,0x14,0x14,0x14,0x00};
unsigned char LCD_CHAR_BAR3[] = {0x00,0x15,0x15,0x15,0x15,0x15,0x15,0x00};
unsigned char LCD_CHAR_BAR4[] = {0x00,0x04,0x04,0x04,0x04,0x04,0x04,0x00};
unsigned char LCD_CHAR_BAR5[] = {0x00,0x01,0x01,0x01,0x01,0x01,0x01,0x00};
unsigned char LCD_CHAR_BAR6[] = {0x00,0x11,0x11,0x11,0x11,0x11,0x11,0x00};

unsigned char atari_to_lcd[256] = {
	0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,' ',' ',' ',' ',' ',' ',' ',' ',
	' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
	' ','!',0x22,'#','$','%','&',0x27,'(',')','*','+',',','-','.',0x2F,
	'0','1','2','3','4','5','6','7','8','9',':',';','<','=6','>','?',
	'@','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',
	'P','Q','R','S','T','U','V','W','X','Y','Z','[',0x2F,']','^','_',
	'`','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o',
	'p','q','r','s','t','u','v','w','x','y','z','{','|','}','-',' ',
	
	'C','u','e','a',0xE1,'a','a','c','e','e,','e','i','i','i','A','A',
	'E',' ',' ','o',0xEF,'o','u','u','y','O','U','c',' ',' ',0xE2,' ',
	'a','i','o','u',0xEE,'N','a','o',' ',' ',' ',' ',' ',' ',0x7F,0x7E,
	'a','o',' ',' ',' ',' ','A','A','O',' ',0x27,' ',' ',' ',' ',' ',
	' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
	' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',0xF3,
	0xE0,0xE2,' ',0xF7,0xF6,' ',0xE4,' ',' ',0xF2,0xF4,' ',' ',' ',' ',' ',
	' ',' ',' ',' ',' ',' ',0xED,' ',0xDF,0xA5,0xA5,' ',' ',' ',' ',' ' }; 

void LCD_WriteControl(unsigned short data);
void LCD_WriteData(unsigned short data);
void SendIkbdString(short count, char *buffer);
void SendIkbd(short count, char *buffer);

static long open_count = 0 ;

long cdecl LCD_Init(void)
{
	return(0);
}

void cdecl LCD_Exit(void)
{
}

long cdecl LCD_Open(PD *base)
{
	open_count++;
	if(open_count>1)
		return(-1L);
	LCD_Clear(NULL,0,0);
	LCD_CursorOff(NULL,0,0);
	LCD_DefineChar(NULL,0,0,0,LCD_CHAR_BAR1);
	LCD_DefineChar(NULL,0,0,1,LCD_CHAR_BAR2);
	LCD_DefineChar(NULL,0,0,2,LCD_CHAR_BAR3);
	LCD_DefineChar(NULL,0,0,3,LCD_CHAR_BAR4);
	LCD_DefineChar(NULL,0,0,4,LCD_CHAR_BAR5);
	LCD_DefineChar(NULL,0,0,5,LCD_CHAR_BAR6);
	return(0);
}

void cdecl LCD_Close(PD *base)
{
	static unsigned char unlock_lcd[]={0x23,0xFF,0xFF}; 
	if(base);
	open_count--;
	if(open_count==0)
	{
		LCD_Clear(NULL,0,0);
		LCD_CursorOff(NULL,0,0);
		Ikbdws(2,unlock_lcd);
	}
}

void cdecl LCD_DefineChar(PD *base, long fn, short nargs, short address, unsigned char *pattern)
{
	static unsigned char data_lcd[]={0x23,0x08};
	if(address<8)
	{
		LCD_WriteControl(0x40 + (address << 3));
		SendIkbd(1,data_lcd);
		SendIkbd(7,pattern);
	}
}

void cdecl LCD_DisplayOff(PD *base, long fn, short nargs)
{
	LCD_WriteControl(0x08);
}

void cdecl LCD_DisplayOn(PD *base, long fn, short nargs)
{
	LCD_WriteControl(0x0c);
}

void cdecl LCD_Clear(PD *base, long fn, short nargs)
{
	LCD_WriteControl(0x01);
}

void cdecl LCD_Home(PD *base, long fn, short nargs)
{
	LCD_WriteControl(0x02);
}

void cdecl LCD_Mode(PD *base, long fn, short nargs, short mode)
{
/* 0: decrement, 1: increment, 2: decrement & shift, 3: increment & shift */ 
	if(mode<4)
		LCD_WriteControl(0x04+mode);
}

void cdecl LCD_Cursor(PD *base, long fn, short nargs, short row, short column)
{
	if(column>=1 && column<=40)
	{
		switch (row)
		{
			case 1: LCD_WriteControl(0x80 + column - 1); break;
			case 2: LCD_WriteControl(0xc0 + column - 1); break;
			default: break;
		}
	}
}

void cdecl LCD_CursorLeft(PD *base, long fn, short nargs)
{
	LCD_WriteControl(0x10);
}

void cdecl LCD_CursorRight(PD *base, long fn, short nargs)
{
	LCD_WriteControl(0x14);
}

void cdecl LCD_CursorOn(PD *base, long fn, short nargs)
{
	LCD_WriteControl(0x0d);
}

void cdecl LCD_CursorOff(PD *base, long fn, short nargs)
{
	LCD_WriteControl(0x0c);
}

void cdecl LCD_ShiftLeft(PD *base, long fn, short nargs)
{
	LCD_WriteControl(0x18);
}

void cdecl LCD_ShiftRight(PD *base, long fn, short nargs)
{
	LCD_WriteControl(0x1C);
}

void cdecl LCD_DisplayCharacter(PD *base, long fn, short nargs, short a_char)
{
	LCD_WriteData((short)atari_to_lcd[a_char & 0xFF]);
}

void cdecl LCD_DisplayString(PD *base, long fn, short nargs, short row, short column, char *string)
{
	static unsigned char data_lcd[]={0x23,0x00};
	LCD_Cursor(NULL,0,0,row,column);
	data_lcd[1]=(unsigned char)strlen(string);
	if(string[0])
	{
		SendIkbd(1,data_lcd);
		SendIkbdString(data_lcd[1]-1,string);
	}
}

void cdecl LCD_DisplayStringCentered(PD *base, long fn, short nargs, short row, char *string)
{
	static char buf[16];
	short len,i;
	len=(short)strlen(string);
	if(len<=16)
	{
		/* if the string is less than one line, center it ... */
		for(i=0;i<16;buf[i++]=' ');
		for(i=0;i<len;buf[((16-len)>>1)+i]=string[i],i++);
		LCD_DisplayRow(NULL,0,0,row,buf);		
	}
	else
	{
		/* if the string is more than one line, display first 16 characters */
		LCD_DisplayRow(NULL,0,0,row,string);
	}
}

void cdecl LCD_DisplayScreen(PD *base, long fn, short nargs, char *ptr)
{
	LCD_DisplayRow(NULL,0,0,1,ptr+ 0);
	LCD_DisplayRow(NULL,0,0,2,ptr+16);
}

void cdecl LCD_DisplayRow(PD *base, long fn, short nargs, short row, char *string)
{
	static unsigned char data_lcd[]={0x23,16};
	LCD_Cursor(NULL,0,0,row,1);
	SendIkbd(1,data_lcd);
	SendIkbdString(15,string);
}

void cdecl LCD_WipeOnLR(PD *base, long fn, short nargs, char *ptr)
{
	/* "wipe" on new screen */
	short i;
	for(i=0;i<16;i++)
	{
		LCD_Cursor(NULL,0,0,1,i+1);
		LCD_DisplayCharacter(NULL,0,0,*(ptr+ 0+i));
		LCD_Cursor(NULL,0,0,2,i+1);
		LCD_DisplayCharacter(NULL,0,0,*(ptr+16+i));
	}
}

void cdecl LCD_WipeOnRL(PD *base, long fn, short nargs, char *ptr)
{
	/* "wipe" on new screen */
	short i;
	for(i=16;i>0;i--)
	{
		LCD_Cursor(NULL,0,0,1,i);
		LCD_DisplayCharacter(NULL,0,0,*(ptr+ 0+i-1));
		LCD_Cursor(NULL,0,0,2,i);
		LCD_DisplayCharacter(NULL,0,0,*(ptr+16+i-1));
	}
}

void cdecl LCD_WipeOffLR(PD *base, long fn, short nargs)
{
	/* "wipe" off old screen (left to right) */
	short i;
	for(i=1;i<16;i++)
	{
		#define BLOCK 0xff
		LCD_Cursor(NULL,0,0,1,i);
		LCD_DisplayCharacter(NULL,0,0,BLOCK);
		LCD_Cursor(NULL,0,0,2,i);
		LCD_DisplayCharacter(NULL,0,0,BLOCK);
	}
}

void cdecl LCD_WipeOffRL(PD *base, long fn, short nargs)
{
	/* "wipe" off old screen (right to left) */
	short i;
	for(i=16;i>0;i--)
	{
		#define BLOCK 0xff
		LCD_Cursor(NULL,0,0,1,i);
		LCD_DisplayCharacter(NULL,0,0,BLOCK);
		LCD_Cursor(NULL,0,0,2,i);
		LCD_DisplayCharacter(NULL,0,0,BLOCK);
	}
}

static void LCD_WriteControl(unsigned short data)
{
	static unsigned char cmd_lcd[]={0x23,0x00,0x00}; 
	cmd_lcd[2]=(unsigned char)data;
	if(data==0x01)	/* clear display */
	{
		Ikbdws(2,cmd_lcd);
		delay(10);	/* 10ms delay */
	}
	else if(data==0x02)	/* home */
	{
		Ikbdws(2,cmd_lcd);
		delay(1);	/* 1ms delay */
	}
	else
		SendIkbd(2,cmd_lcd);
}

void LCD_WriteData(unsigned short data)
{
	static unsigned char data_lcd[]={0x23,0x01,0x00};
	data_lcd[2]=(unsigned char)data;
	SendIkbd(2,data_lcd);
}

void SendIkbdString(short count, char *buffer)
{
	while(count>=0)
	{
		/* IKBD interrupt buffered by a TSR program inside the AUTO folder */
		Bconout(4,(int)atari_to_lcd[((int)*buffer++) & 0xFF]);
		count--;
	}
}

void SendIkbd(short count, char *buffer)
{
	while(count>=0)
	{
		/* IKBD interrupt buffered by a TSR program inside the AUTO folder */
		Bconout(4,*buffer++);
		count--;
	}
}
