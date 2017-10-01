/* mini.h
*/

#define	P_Term0()		bdos(0x00)
#define C_ConIn()		bdos(0x01)
#define C_ConOut(a)		bdos(0x02,a)
#define C_AuxIn()		bdos(0x03)
#define C_AuxOut(a)		bdos(0x04,a)
#define C_PrnOut(a)		bdos(0x05,a)
#define C_RawIO(a)		bdos(0x06,a)
#define C_RawIn()		bdos(0x07)
#define C_NEcIn()		bdos(0x08)
#define C_ConWS(a)		bdos(0x09,a)
#define	C_ConRS(a)		bdos(0x0A,a)
#define C_ConIS()		bdos(0x0B)
#define	D_SetDrv(a)		bdos(0x0E,a)
#define C_ConOS()		bdos(0x10)
#define C_PrnOS()		bdos(0x11)
#define	C_AuxIS()		bdos(0x12)
#define C_AuxOS()		bdos(0x13)
#define D_GetDrv()		bdos(0x19)
#define F_SetDTA(a)		bdos(0x1A,a)
#define	S_State(a)		bdos(0x20,a)
#define	S_SetVec(a,b)		bdos(0x25,a,b)
#define T_GetDate()		bdos(0x2A)
#define T_SetDate(a)		bdos(0x2B,a)
#define T_GetTime()		bdos(0x2C)
#define T_SetTime(a)		bdos(0x2D,a)
#define F_GetDTA()		bdos(0x2F)
#define S_Version()		bdos(0x30)
#define P_TermRes(a,b)		bdos(0x31,a,b)
#define	S_GetVec(a)		bdos(0x35,a)
#define D_Free(a)		bdos(0x36,a)
#define D_Create(a)		bdos(0x39,a)
#define D_Delete(a)		bdos(0x3A,a)
#define D_SetPath(a)		bdos(0x3B,a)
#define F_Create(a,b)		bdos(0x3C,a,b)
#define F_Open(a,b)		bdos(0x3D,a,b)
#define F_Close(a)		bdos(0x3E,a)
#define F_Read(a,b,c)		bdos(0x3F,a,b,c)
#define F_Write(a,b,c)		bdos(0x40,a,b,c)
#define F_Delete(a)		bdos(0x41,a)
#define F_Seek(a,b,c)		bdos(0x42,a,b,c)
#define F_Attrib(a,b,c)		bdos(0x43,a,b,c)
#define F_IOCtl(a,b,c,d)	bdos(0x44,a,b,c,d)
#define F_Dup(a)		bdos(0x45,a)
#define F_Force(a,b)		bdos(0x46,a,b)
#define D_GetPath(a,b)		bdos(0x47,a,b)
#define M_Alloc(a)		bdos(0x48,a)
#define M_Free(a)		bdos(0x49,a)
#define M_Shrink(a,b)		bdos(0x4A,0,a,b)
#define P_Exec(a,b,c,d)		bdos(0x4B,a,b,c,d)
#define P_Term(a)		bdos(0x4C,a)
#define F_SFirst(a,b)		bdos(0x4E,a,b)
#define F_SNext()		bdos(0x4F)
#define F_Rename(a,b)		bdos(0x56,0,a,b)
#define F_DATime(a,b,c)		bdos(0x57,a,b,c)

#define	BYTE	char
#define	UBYTE	char
#define	WORD	int
#define	UWORD	unsigned int
#define	LONG	long
#define	ULONG	unsigned long
#define	REG	register

extern long bdos(), bios(), strlen();
extern char *strcpy(), *strcat();
