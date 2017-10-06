/*
   Modul: M_SYS (Headerdatei)
   
   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach
   
   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden
   
   Alle Rechte beim Autor
*/

#ifndef _MPSYS_
#define _MPSYS_

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

#if defined(__MINT__) || defined(__GNUC__)
#include <sysvars.h>
#include <basepage.h>
BASEPAGE *BasepagePtr(void);
OSHEADER *SysHeader(void);
#else
#if !defined(__MINT__) && defined(SOZOBON)
BASEPAGE *BasepagePtr(void);
OSHEADER *SysHeader(void);
#else 
#if !defined(__MINT__) && defined(__TURBOC__)
BASPAG *BasepagePtr(void);
SYSHDR *SysHeader(void);
#endif
#endif
#endif

int BootDevice(void);
BOOLEAN Accessory(void);
int TosVersion(void);
int TosDate(void);
PtrVDIESC Vdiesc(void);
void UseDeadkeys(BOOLEAN doit);
void MapNumblock(BOOLEAN doit);
void ScantoKey(int scan,int chr,BITSET status,tKey *key,char *ch);
tKey UpperCase(tKey lower);
tKey LowerCase(tKey upper);
void KeyToScan(tKey key,int *scan,BITSET *kbshift);
char KeyToChar(tKey key);
tKey CharToKey(char ch);
void SetDeadKeys(DeadKeys keys);
void InitKeymap(char *map);
void SetKeymap(char *map);
void ResetKeymap(void);
PtrConfig ConfigPtr(void);
void SetConfigflag(long flag,BOOLEAN doset);
BOOLEAN InConfig(long flag);
void SetDefaultkey(tFKeys name,tKey val);
tKey DefaultKey(tFKeys name);
void GetDeads(BITSET *keys);
void SetDeads(BITSET keys);
void MagicVersion(int *version,int *revision);
void InitMagic(void);
void ProgName(void *name);

void callgem(int call,void *blk);
void *LineA(void);
void CallMagic(int func);
int AESCALL(int op,int c1,int c2,int c3,int c4);
int GetCookie(long cookie,long *value);

char *Fsearch(char *slist);
void MagicVerString(char *version);
void CopyrightOff(void);
void CopyrightOn(void);
void SetEmergencyProc(EmergencyProc ep);
void VisualScreen(GRECT *r);

#endif