
/**  Copyright 2007-2022 Pawel Goralski
    
    This file is part of AMIDILIB.
    See license.txt for licensing information.
*/

#include <stdlib.h>
#include <ctype.h>

#include "vartypes.h"

#include "core/amprintf.h"
#include "input/ikbd.h"
#include "ym2149.h"

#include <mint/osbind.h>

void printHelpScreen(void)
{
  amPrintf("==============================================="NL);
  amPrintf("/|\\ ym2149 sound output test.."NL);

#if AMIDILIB_USE_LIBC
    amPrintf("build date: %s %s"NL,__DATE__,__TIME__);
#else  
    amPrintf("build date: %s %s nolibc"NL,__DATE__,__TIME__);
#endif

  amPrintf("'[' or ']' - change octave -/+ "NL);
  amPrintf("[q-h] - play note"NL);
  amPrintf("1,2,3 - enable/disable tone for channel A/B/C "NL);
  amPrintf("7,8,9 - enable/disable noise for channel A/B/C "NL);
  amPrintf("',' or '.' - change envelope -/+ "NL);
  amPrintf("';' or ''' - change noise generator period -/+ "NL);
  amPrintf("'z' or 'x' - change channels amplitude -/+ "NL);
  amPrintf("[i] - show this help screen "NL);
  amPrintf("[spacebar] - turn off all sounds "NL);
  amPrintf("[Esc] - quit"NL);
  amPrintf("(c)Nokturnal 2007-22"NL);
  amPrintf("================================================"NL);
}

int main(void) 
{
  turnOffKeyclick();
  printHelpScreen();

	const uint8 noteBaseArray[]={24,36,48,60,72,84,96,108};
  uint8 noteId=0;
  
  sYmChannelData ymRegisters[3];
  
  bool bQuitFlag=FALSE;
  uint16 input=0;
  
  uint8 currentBaseIdx=0;

  uint8 currentEnvIdx=0;
  uint8 noisegenPeriod=15;
  uint8 channelAmp=15; 
  ymRegisters[YM_CHN_A].amp=channelAmp;
  ymRegisters[YM_CHN_B].amp=channelAmp;
  ymRegisters[YM_CHN_C].amp=channelAmp;
  
  ymRegisters[YM_CHN_A].noiseEnable=0;
  ymRegisters[YM_CHN_B].noiseEnable=0;
  ymRegisters[YM_CHN_C].noiseEnable=0;
  
  ymRegisters[YM_CHN_A].toneEnable=1;
  ymRegisters[YM_CHN_B].toneEnable=1;
  ymRegisters[YM_CHN_C].toneEnable=1;
  
  uint8 noteBase=noteBaseArray[currentBaseIdx];
  uint8 currentEnvelope=getEnvelopeId(currentEnvIdx);
  
  while(bQuitFlag!=TRUE)
  {
    input=(uint16)Crawcin();

    if(input!=0)
    {
  
    	switch(toupper((uint8)input))
    	{
				case 0x1b:
				{
					bQuitFlag=TRUE;
				} break;
				
				case ' ':
				{
					ymSoundOff();
				} break;
				
				case '1':
				{
					if(ymRegisters[YM_CHN_A].toneEnable)
					{
						ymRegisters[YM_CHN_A].toneEnable=0;
						amPrintf("[Channel A] tone OFF"NL);
					}
					else
					{
						ymRegisters[YM_CHN_A].toneEnable=1;
						amPrintf("[Channel A] tone ON"NL);
					}
				
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				
				} break;
				case '2':
				{
					if(ymRegisters[YM_CHN_B].toneEnable)
					{
				  	ymRegisters[YM_CHN_B].toneEnable=0;
				  	amPrintf("[Channel B] tone OFF"NL);
					}
					else
					{
				  	ymRegisters[YM_CHN_B].toneEnable=1;
				  	amPrintf("[Channel B] tone ON"NL);
					}
				
					setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				
				}	break;
				case '3':
				{
					if(ymRegisters[YM_CHN_C].toneEnable)
					{
				    ymRegisters[YM_CHN_C].toneEnable=0;
				    amPrintf("[Channel C] tone OFF"NL);
				  }
				  else
				  {
				    ymRegisters[YM_CHN_C].toneEnable=1;
				    amPrintf("[Channel C] tone ON"NL);
				 }
				 
				 setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);

				} break;
				
				case '7':
				{
				  if(ymRegisters[YM_CHN_A].noiseEnable)
				  {
				    ymRegisters[YM_CHN_A].noiseEnable=0;
				    amPrintf("[Channel A] noise OFF"NL);
				  }
				  else
				  {
				    ymRegisters[YM_CHN_A].noiseEnable=1;
				    amPrintf("[Channel A] noise ON"NL);
				  }
				  
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				 
				} break;

				case '8':
				{
				  if(ymRegisters[YM_CHN_B].noiseEnable)
				  {
				    ymRegisters[YM_CHN_B].noiseEnable=0;
				    amPrintf("[Channel B] noise OFF"NL);
				  }
				  else
				  {
				    ymRegisters[YM_CHN_B].noiseEnable=1;
				    amPrintf("[Channel B] noise ON"NL);
				  }
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				 
				} break;
				
				case '9':
				{
					if(ymRegisters[YM_CHN_C].noiseEnable)
					{
				    ymRegisters[YM_CHN_C].noiseEnable=0;
				    amPrintf("[Channel C] noise OFF"NL);
				  }
				  else
				  {
				    ymRegisters[YM_CHN_C].noiseEnable=1;
				    amPrintf("[Channel C] noise ON"NL);
				  }

				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				} break;
				
				case '[':
				{
				  if(currentBaseIdx!=0)
				  {
				    currentBaseIdx--;
				    amPrintf("Changed octave to: %d"NL,currentBaseIdx+1);
				    noteId-=12;
				 
				    setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				  }
				} break;

				case ']':
				{
				
					if(currentBaseIdx!=7)
					{
				    currentBaseIdx++;
				    amPrintf("Changed octave to: %d"NL,currentBaseIdx+1);
				    noteId+=12;
				    
				    setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				  }
				} break;

				case ',':
				{
				  if(currentEnvIdx!=0)
				  {
				    currentEnvIdx--;
				    amPrintf("Changed envelope to: %d"NL,currentEnvIdx);
				    
				    setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				  }
				
				} break;

				case '.':
				{
					if(currentEnvIdx!=7)
					{
				   currentEnvIdx++;
				   amPrintf("Changed envelope to: %d"NL,currentEnvIdx);
				   setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				  }
				} break;

				case ';':
				{
				 if(noisegenPeriod!=0)
				 {
				  	noisegenPeriod--;
				   	amPrintf("Changed noise generator period to: %d"NL,noisegenPeriod);
				    setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				 }
				} break;

				case '\'':
				{
					if(noisegenPeriod!=31)
					{
				  	noisegenPeriod++;
				   	amPrintf("Changed noise generator period to: %d"NL,noisegenPeriod);
				   	setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				 	}
				} break;
				
				case 'Z':
				{
				  if(channelAmp!=0)
				  {
				    channelAmp--;
				    amPrintf("Changed channel amplitude to: %d"NL,channelAmp);
				    ymRegisters[YM_CHN_A].amp=channelAmp;
				    ymRegisters[YM_CHN_B].amp=channelAmp;
				    ymRegisters[YM_CHN_C].amp=channelAmp;
				    
				    setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				  }
				} break;
				
				case 'X':
				{
				  if(channelAmp!=16)
				  {
				     channelAmp++;
				     amPrintf("Changed channel amplitude to: %d"NL,channelAmp);
				     ymRegisters[YM_CHN_A].amp=channelAmp;
				     ymRegisters[YM_CHN_B].amp=channelAmp;
				     ymRegisters[YM_CHN_C].amp=channelAmp;
				
				     setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				  }
				} break;

				case 'I':
				{
				  printHelpScreen();
				} break;

				case 'Q':
				{
				  noteId=noteBaseArray[currentBaseIdx]+0;
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				}	break;
				
				case 'A':
				{
				  noteId=noteBaseArray[currentBaseIdx]+1;
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				}	break;
				
				case 'W':
				{
				  noteId=noteBaseArray[currentBaseIdx]+2;
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				}	break;
				
				case 'S':
				{
				  noteId=noteBaseArray[currentBaseIdx]+3;
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				} break;
				
				case 'E':
				{
				  noteId=noteBaseArray[currentBaseIdx]+4;
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				} break;
				
				case 'D':
				{
				  noteId=noteBaseArray[currentBaseIdx]+5;
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				}	break;  
				
				case 'R':
				{
				  noteId=noteBaseArray[currentBaseIdx]+6;
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				} break;
				
				case 'F':
				{
				  noteId=noteBaseArray[currentBaseIdx]+7;
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				} break;
				
				case 'T':
				{
				  noteId=noteBaseArray[currentBaseIdx]+8;
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				} break;  
				
				case 'G':
				{
				  noteId=noteBaseArray[currentBaseIdx]+9;
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				}	break;
				
				case 'Y':
				{
				  noteId=noteBaseArray[currentBaseIdx]+10;
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				} break;
				
				case 'H':
				{
				  noteId=noteBaseArray[currentBaseIdx]+11;
				  setYm2149(ymRegisters,noteId,currentEnvIdx, noisegenPeriod);
				} break;
    	} // switch
    
  	} // end if
  }
  
  //turn off sound output 
  ymSoundOff();
  amPrintf("Program terminated..."NL);

return 0;
}
