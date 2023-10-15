/*
** DSP Process
**
** (C test version...)
**
*/

#include <sndbind.h>
#include <dspbind.h>

#define freq (1)                       /* 49170 Hz */

int main(void)
{
long tmp,xfree,yfree;                   /* assumed : sizeof(int)=2 */
int abilitycode,tmp16;
char buffer[3200];                      /* Buffer area for DSP_LoadProg */
tmp=locksnd();
if (tmp!=1)                            /* Locksnd failed! */
      {
       printf("Sound system is locked!\n");
       printf("Continue anyway? ");
       scanf("%s",buffer);
       if (buffer[0]!='y' && buffer[0]!='Y')
           return(-1);
      }

tmp=Dsp_Lock();
if (tmp!=0)                            /* DSP_Lock failed! */
      {
       printf("DSP is locked!\n");
       printf("Continue anyway? ");
       scanf("%s",buffer);
       if (buffer[0]!='y' && buffer[0]!='Y')
          {
           unlocksnd();
           return(-1);
          }
      }
      
setmode(1); /* Mic input is 16-bit stereo, so output should be as well... */

soundcmd(4,2);                 /* ADDERIN to Matrix only */
soundcmd(5,0);                 /* ADC IN to microphone   */

dsptristate(1,1);              /* Ensure DSP is not tristated.    */

Dsp_Available(&xfree,&yfree);  /* Anyone know how to free this??? */

tmp16=Dsp_Reserve(xfree,yfree);/* Be selfish... reserve the lot!  */
if (tmp16!=0)
      {
       printf("Unable to allocate DSP memory...");
       unlocksnd();
       Dsp_Unlock();
       return(-1);
      }

abilitycode=Dsp_RequestUniqueAbility();

tmp16=Dsp_LoadProg("PROCESS.LOD",abilitycode,buffer);
if (tmp16!=0)                  /* DSP_LoadProg has failed! */
      {
       printf("Failed to load PROCESS.LOD into the DSP!\n");
       unlocksnd();
       Dsp_Unlock();
       return(-1);
      }

devconnect(3,2,0,freq,1);      /* ADC -> DSP, no handshake */
devconnect(1,8,0,freq,1);      /* DSP -> DAC, no handshake */



/* Its processing... */

printf("Processing audio with the DSP...\n");
printf("Press <ENTER> to stop. \n");
scanf("&s",buffer);

sndstatus(1);                  /* Reset the sound subsystem... */
unlocksnd();
Dsp_Unlock();

return(0);
}
