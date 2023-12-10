/*
** LCD.H -- 2x16 LCD Routines
*/

#ifndef __LCD_H
#define __LCD_H

#define LCD_DefineChar(slb,address,pattern) (void)(*slbexec)((SHARED_LIB)slb,0L,3,(short)address,(unsigned char *)pattern) 
#define LCD_DisplayOff(slb) (void)(*slbexec)((SHARED_LIB)slb,1L,0); 
#define LCD_DisplayOn(slb) (void)(*slbexec)((SHARED_LIB)slb,2L,0); 
#define LCD_Clear(slb) (void)(*slbexec)((SHARED_LIB)slb,3L,0); 
#define LCD_Home(slb) (void)(*slbexec)((SHARED_LIB)slb,4L,0); 
#define LCD_Mode(slb,mode) (void)(*slbexec)((SHARED_LIB)slb,5L,1,(short)mode); 
#define LCD_Cursor(slb,row,column) (void)(*slbexec)((SHARED_LIB)slb,6L,2,(short)row,(short)column); 
#define LCD_CursorLeft(slb) (void)(*slbexec)((SHARED_LIB)slb,7L,0); 
#define LCD_CursorRight(slb) (void)(*slbexec)((SHARED_LIB)slb,8L,0); 
#define LCD_CursorOn(slb) (void)(*slbexec)((SHARED_LIB)slb,9L,0); 
#define LCD_CursorOff(slb) (void)(*slbexec)((SHARED_LIB)slb,10L,0); 
#define LCD_ShiftLeft(slb) (void)(*slbexec)((SHARED_LIB)slb,11L,0); 
#define LCD_ShiftRight(slb) (void)(*slbexec)((SHARED_LIB)slb,12L,0); 
#define LCD_DisplayCharacter(slb,a_char) (void)(*slbexec)((SHARED_LIB)slb,13L,1,(short)a_char); 
#define LCD_DisplayString(slb,row,column,string) (void)(*slbexec)((SHARED_LIB)slb,14L,4,(short)row,(short)column,(unsigned char *)string) 
#define LCD_DisplayStringCentered(slb,row,string) (void)(*slbexec)((SHARED_LIB)slb,15L,3,(short)row,(unsigned char *)string) 
#define LCD_DisplayScreen(slb,ptr) (void)(*slbexec)((SHARED_LIB)slb,16L,2,(char *)ptr); 
#define LCD_DisplayRow(slb,row,string) (void)(*slbexec)((SHARED_LIB)slb,17L,3,(short)row,(unsigned char *)string) 
#define LCD_WipeOnLR(slb,ptr) (void)(*slbexec)((SHARED_LIB)slb,18L,2,(unsigned char *)ptr) 
#define LCD_WipeOnRL(slb,ptr) (void)(*slbexec)((SHARED_LIB)slb,19L,2,(unsigned char *)ptr) 
#define LCD_WipeOffLR(slb) (void)(*slbexec)((SHARED_LIB)slb,20L,0); 
#define LCD_WipeOffRL(slb) (void)(*slbexec)((SHARED_LIB)slb,21L,0); 

#endif
