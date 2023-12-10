#include <tos.h>
#include <ext.h>
#include <stdio.h>
#include <string.h>
#include "slb.h"
#include "lcd.h"

SLB_EXEC slbexec;
SHARED_LIB slb;

/*
   Define user-defined character dot patterns
*/
unsigned char LCD_CHAR_BAR1[] = {0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10};
unsigned char LCD_CHAR_BAR2[] = {0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18};
unsigned char LCD_CHAR_BAR3[] = {0x1c,0x1c,0x1c,0x1c,0x1c,0x1c,0x1c,0x1c};
unsigned char LCD_CHAR_BAR4[] = {0x1e,0x1e,0x1e,0x1e,0x1e,0x1e,0x1e,0x1e};
unsigned char LCD_CHAR_BAR5[] = {0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f};
unsigned char LCD_CHAR_UP_ARROW[] = {0x1f,0x1b,0x11,0x0a,0x1b,0x1b,0x1b,0x1f};
unsigned char LCD_CHAR_DOWN_ARROW[] = {0x1f,0x1b,0x1b,0x1b,0x0a,0x11,0x1b,0x1f};
unsigned char LCD_CHAR_TRADEMARK_T[] = {0x1f,0x04,0x04,0x04,0x00,0x00,0x00,0x00};
unsigned char LCD_CHAR_TRADEMARK_M[] = {0x11,0x1b,0x15,0x11,0x00,0x00,0x00,0x00};

int main (void)
{
	long err;
	char done=0;
	
	err=Slbopen("lcd.slb",".\\",1L,&slb,&slbexec);
	if(err<0)
		return((int)err);
	/*
	   load user-defined characters into LCD
	*/
	LCD_DefineChar (slb,0,LCD_CHAR_UP_ARROW);
	LCD_DefineChar (slb,1,LCD_CHAR_DOWN_ARROW);
	LCD_DefineChar (slb,2,LCD_CHAR_TRADEMARK_T);
	LCD_DefineChar (slb,3,LCD_CHAR_TRADEMARK_M);
	LCD_DefineChar (slb,4,LCD_CHAR_BAR1);
	LCD_DefineChar (slb,5,LCD_CHAR_BAR2);
	LCD_DefineChar (slb,6,LCD_CHAR_BAR3);
	LCD_DefineChar (slb,7,LCD_CHAR_BAR4);

	printf("\r\n\nLCD Demonstration Program, v1.0");

	while(!done)
	{
		LCD_Clear(slb);
		LCD_DisplayStringCentered(slb,2,"Ready");
		printf("\r\n\n");
		printf("1. Sample Title Screen\r\n");
		printf("2. Sample Menu\r\n");
		printf("3. Sample Marquee\r\n");
		printf("4. Sample Flashing\r\n");
		printf("5. Sample Bar Graph\r\n");
		printf("6. Sample Screen Shift\r\n");
		printf("Esc = Exit\r\n");

		switch(Crawcin())
		{
			/*
			   display sample title screen (with "wipe" effects)
			*/
			case '1':
				{
					char screen[] = " Demonstration  "
					                "    Program     ";
					LCD_DisplayScreen(slb,screen);
					delay(2000);
				}
				{
					char screen[] = "For Eiffel v1.10"
					                "                ";
					LCD_WipeOffLR(slb);
					LCD_WipeOnRL(slb,screen);
					delay(2000);
				}
				break;

			/*
			   display sample menu system
			*/
			case '2':
				{
					char screen1[] = "~Option Num 1   "
					                 " Option Num 2  \1";
					char screen2[] = " Option Num 1  \0"
					                 "~Option Num 2  \1";
					char screen3[] = " Option Num 2  \0"
					                 "~Option Num 3  \1";
					char screen4[] = " Option Num 3  \0"
					                 "~Option Num 4  \1";
					char screen5[] = " Option Num 4  \0"
					                 "~Option Num 5   ";
					char screen=1;
					char exit=0;
					long code;
					printf(" '^' = Up Arrow, 'v' = Down Arrow, or Esc ...\r\n");
					while(!exit)
					{
						switch(screen)
						{
							case 1: LCD_DisplayScreen(slb,screen1); break;
							case 2: LCD_DisplayScreen(slb,screen2); break;
							case 3: LCD_DisplayScreen(slb,screen3); break;
							case 4: LCD_DisplayScreen(slb,screen4); break;
							case 5: LCD_DisplayScreen(slb,screen5); break;
						}
						switch((short)(code=Crawcin()))
						{
							case 27:
								exit=1;
								break;
							case 0:
								if(code==0x500000)
								{
									screen++;
									if(screen>5)
										screen=5;
									break;
								}
								else if(code==0x480000)
								{
									screen--;
									if(screen<1)
										screen=1;
								}
								break;
						}
					}
				}
				break;

			/*
			   display sample "marquee"
			*/
			case '3':
				{
					char screen[] = "                "
					                "Scrolling ...   ";
					char longline[] = "                    This is a very long line of text, scrolling across the screen like a marquee.                    ";
					char i=0;
					LCD_DisplayScreen(slb,screen);
					printf("Press any key to stop ...\n");
					while(!Crawio(255))
					{
						LCD_DisplayRow(slb,1,&longline[i++]);
						if(i>(strlen(longline)-16))
							i=0;
						delay(250);
					}
					Crawcin();
				}
				break;

			/*
			   display sample "flashing"
			*/
			case '4':
				{
					char screen1[] = "  Use flashing  "
					                 "      text      ";
					char screen2[] = "   to attract   "
					                 "    attention   ";
					while(!Crawio(255))
					{
						LCD_DisplayScreen(slb,screen1);
						delay(250);
						LCD_DisplayScreen(slb,screen2);
						delay(250);
					}
					Crawcin();
				}
				break;

			/*
			   display sample "bar graph"
			*/
			case '5':
				{
					char screen[]  = "Sample Bar Graph"
					                 "                ";
					char bars[6] = {' ',0x04,0x05,0x06,0x07,0xff};
					LCD_DisplayScreen(slb,screen);
					printf("Press any key to stop ...\n");
					while(!Crawio(255))
					{
						int i,j;
						for(i=1;i<17;i++)
						{							/* ramp up */
							for(j=1;j<6;j++)
							{
								LCD_Cursor(slb,2,i);
								LCD_DisplayCharacter(slb,bars[j]);
								delay(10);
							}
						}
						for(i=16;i>=1;i--)
						{             /* ramp down */
							for(j=5;j>=1;j--)
							{
								LCD_Cursor(slb,2,i);
								LCD_DisplayCharacter(slb,bars[j-1]);
								delay(10);
							}
						}
					}
					Crawcin();
				}
				break;
				
			/*
			   display sample "shift"
			*/
			case '6':
				{				
					char line[] = "This is screen shift                ";
					char i=0;
					LCD_Clear(slb);
					LCD_Mode(slb,3); /* Increment + Shift */
					LCD_Cursor(slb,1,17);
					i=0;
					while(line[i])
					{
						LCD_DisplayCharacter(slb,line[i++]);
						delay(250);	
					}
					LCD_Mode(slb,2); /* Increment */
				}
				break;
				
			/*
			   display "bye" message and exit
			*/
			case 27:
				LCD_Clear(slb);
				LCD_DisplayStringCentered(slb,1,"Bye Now!");
				done=1;
				break;
		}

	}
	
	err=Slbclose(slb);
	return((int)err);
}



