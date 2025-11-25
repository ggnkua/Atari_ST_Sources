/*
 * Some nice XBIOS dosound() effects in C.
 * Original ones from GFA expert v.2,
 * conversion by Eero Tamminen 1994
 *
 * These can be used by including this and osbind.h headers
 * headers and calling 'Dosound((void *)sound)' xbios function.
 *
 * Dosound() function uses interrupts so it doesn't stop the
 * program execution. Some of the sounds are continuos and don't
 * stop. You can stop them by issuing a new sound (eg. the system
 * keyclick ;-).
 */

typedef unsigned char BYTE;

#define BEGIN   0x80
#define CHANNEL 0x81
#define PAUSE   0x82     /* followed by time in 1/50 seconds */
#define TERMI   0xFF     /* Sound        */
#define NATE    0x00     /*   terminator */

enum REGS { R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14 };

/* 14 parameters for the registers 0-13 and */
/* tone variations: channel, start, +/-step, end */

static BYTE snd_Plink[] = {
       R1,200, R2,0, R3,201, R4,0, R5,100, R6,0, R7,0,
       R8,248, R9,16, R10,16, R11,16, R12,0, R13,20, R14,0,
       TERMI,NATE };

static BYTE snd_Bumb[] = {
       R1,2, R2,15, R3,2, R4,15, R5,0, R6,0, R7,0,
       R8,252, R9,16, R10,16, R11,0, R12,20, R13,20, R14,10,
       BEGIN,240, CHANNEL,1,-16,0,
       PAUSE,10,
       R1,2, R2,15, R3,2, R4,15, R5,0, R6,0, R7,0,
       R8,252, R9,0, R10,0, R11,0, R12,20, R13,20, R14,10,
       TERMI,NATE };

static BYTE snd_Klink[] = {
       R1,64, R2,0, R3,120, R4,0, R5,0, R6,0, R7,0,
       R8,252, R9,16, R10,16, R11,0, R12,20, R13,20, R14,0,
       TERMI,NATE };

static BYTE snd_Ding[] = {
       R1,1, R2,5, R3,0, R4,5, R5,2, R6,5, R7,0,
       R8,248, R9,16, R10,16, R11,16, R12,0, R13,20, R14,1,
       TERMI,NATE };

static BYTE snd_Pox[] = {
       R1,0, R2,0, R3,0, R4,0, R5,0, R6,0, R7,15,
       R8,199, R9,16, R10,16, R11,16, R12,0, R13,16, R14,0,
       PAUSE,25,
       R1,0, R2,0, R3,0, R4,0, R5,0, R6,0, R7,15,
       R8,199, R9,0, R10,0, R11,0, R12,0, R13,16, R14,0,
       TERMI,NATE };

static BYTE snd_Pieuw[] = {
       R1,1, R2,0, R3,0, R4,0, R5,0, R6,0, R7,0,
       R8,254, R9,16, R10,0, R11,0, R12,0, R13,35, R14,1,
       BEGIN,50, CHANNEL,0,1,100,
       TERMI,NATE };

/* EOF */
