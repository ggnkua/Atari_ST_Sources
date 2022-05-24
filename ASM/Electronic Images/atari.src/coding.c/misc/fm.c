#include <conio.h>
 
#define ALMSC_BASE      0x388
#define ALMSC_STATUS    ALMSC_BASE      /* read */
#define ALMSC_ADDR      ALMSC_BASE      /* write */
#define ALMSC_DATA      ALMSC_BASE+1    /* write */
 
void WriteToReg(int addr, int data)
{
    int wait;

    outp(ALMSC_ADDR, addr);
    for(wait=0; wait < 6; wait++)
        inp(ALMSC_STATUS);
    outp(ALMSC_DATA, data);
    for(wait=0; wait < 36; wait++)
        inp(ALMSC_STATUS);
}
 
void FMSound(int freq)
{
    int lookup[7]= {64, 128, 256, 512, 1024, 2048, 6243 };
    int ffreq[7]={0x400, 0x800, 0xC00, 0x1000, 0x1400, 0x1800, 0x1C00 };
    float fudge[7]={ 10.48576, 5.24288, 2.62144, 1.31072,
                    0.65536, 0.32768, 0.16384 };
    int fnum;
    int i;

    if(freq < 1) freq = 1;
    if(freq > 6243) freq = 6243;
    for(i = 0; i < 7; i++) {
        if(freq <= lookup[i])
            break;
    }
    fnum = ffreq[i] | (int)(fudge[i] * freq);
    WriteToReg(0x32, 0x01); /* set modulator's multiple to 1 */
    WriteToReg(0x52, 0x10); /* set modulator's level to about 40 dB */
    WriteToReg(0x72, 0xf0); /* modualtor Attack: Quick, Decay: Long */
    WriteToReg(0x92, 0x77); /* modulator sustain & release: medium */
    WriteToReg(0x35, 0x01); /* set carrier's multiple to 1 */
    WriteToReg(0x55, 0x00); /* set carrier to max. volume (aprox. 47 dB) */
    WriteToReg(0x75, 0xf0); /* carrier attack: quick, decay: long */
    WriteToReg(0x95, 0x77); /* carrier sustain & release: medium */
    WriteToReg(0xa8, fnum & 0xFF);         /* send lo multiplier */
    WriteToReg(0xb8, 0x20 | ((fnum >> 8) & 0xFF));
                            /* Key ON, octave and hi multiplier */
}
 
void main()
{
   FMSound(100);
}
