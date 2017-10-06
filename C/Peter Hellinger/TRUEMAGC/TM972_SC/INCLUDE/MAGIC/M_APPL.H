/*
   Modul: M_APPL (Headerdatei)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPAPPL_
#define _MPAPPL_

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

void ApplInit(void);
void ApplTerm(int r_eturn);
void InstallTermproc(int (*proc)(void));
void ApplPath(char *path);
void ApplName(char *name);

void OpenWorkstation(Device dev,int dev_num,int w,int h,BOOLEAN rc,PtrWS wsinfo);
void CloseWorkstation(PtrWS wsinfo);
int AvailableDrivers(Device dev);
void DriverInfo(Device dev,int num,PtrWS wsinfo);

#define MouseOn()          CallMagic(620)
#define MouseArrow()       CallMagic(621)
#define MouseCursor()      CallMagic(622)
#define MouseBusy()        CallMagic(623)
#define MouseFinger()      CallMagic(624)
#define MouseHand()        CallMagic(625)
#define MouseThincross()   CallMagic(626)
#define MouseThickcross()  CallMagic(627)
#define MouseOutline()     CallMagic(628)
#define MouseUser()        CallMagic(629)
#define MouseOff()         CallMagic(630)
#define StoreMouse()       CallMagic(633)
#define RestoreMouse()     CallMagic(634)
#define MouseRotor()       CallMagic(640)
#define FreezeScreen()     CallMagic(638)
#define UnfreezeScreen()   CallMagic(639)
#define LockScreen()       CallMagic(636)
#define UnlockScreen()     CallMagic(637)
#define MousePrinter()     CallMagic(646)

void UserMouse(MFORM *form);
void MouseState(int *form,BOOLEAN *sichtbar);
void SetMouse(int x,int y);
long VqGdos(void);
void MouseOffRect(GRECT *r);
BOOLEAN ScrLocked(void);
int GetHelp(char *cmd);

/* Shutdownmechanismus */

#define ShutdownOK     0
#define ShutdownFailed 1

typedef struct
{
	int why;      /* Grund des Shutdowns   */
	int answer;   /* Antwort des Programms */
	int error;    /* evtl. Fehlercode      */
} ShutdownPara;

typedef ShutdownPara *PtrShutdown;
typedef void (*ShutdownHandler)(PtrShutdown);

BOOLEAN AcceptShutdown(ShutdownHandler handler);
void ApplIcon(CICONBLK *icon);

#endif