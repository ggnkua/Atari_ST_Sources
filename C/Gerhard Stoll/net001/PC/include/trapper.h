#include <aes.h>
#include <vdi.h>

typedef struct {
	int16 version;	/* Hex-Coded, e.g. 0x100 for Version 1.00 */
	int16 reserved[15];
} TrapperInfo;


extern int32 TrapperCheck(TrapperInfo *info);	/* E_OK, if Trapper is installed */


typedef int32 CDECL (*BiosCallFunc)(int16 *para, int16 *call_original, int16 super_called);
typedef int32 CDECL (*BiosReturnFunc)(int32 ret, int16 *para, int16 is_super);

extern int32 TrapperInstallBiosCall(int16 opcode, BiosCallFunc func);
extern int32 TrapperRemoveBiosCall(int16 opcode, BiosCallFunc func);
extern int32 TrapperInstallBiosReturn(int16 opcode, BiosReturnFunc func);
extern int32 TrapperRemoveBiosReturn(int16 opcode, BiosReturnFunc func);

typedef int32 CDECL (*XbiosCallFunc)(int16 *para, int16 *call_original, int16 super_called);
typedef int32 CDECL (*XbiosReturnFunc)(int32 ret, int16 *para, int16 is_super);

extern int32 TrapperInstallXbiosCall(int16 opcode, XbiosCallFunc func);
extern int32 TrapperRemoveXbiosCall(int16 opcode, XbiosCallFunc func);
extern int32 TrapperInstallXbiosReturn(int16 opcode, XbiosReturnFunc func);
extern int32 TrapperRemoveXbiosReturn(int16 opcode, XbiosReturnFunc func);

typedef int32 CDECL (*GemdosCallFunc)(int16 *para, int16 *call_original, int16 super_called);
typedef int32 CDECL (*GemdosReturnFunc)(int32 ret, int16 *para, int16 is_super);

extern int32 TrapperInstallGemdosCall(int16 opcode, GemdosCallFunc func);
extern int32 TrapperRemoveGemdosCall(int16 opcode, GemdosCallFunc func);
extern int32 TrapperInstallGemdosReturn(int16 opcode, GemdosReturnFunc func);
extern int32 TrapperRemoveGemdosReturn(int16 opcode, GemdosReturnFunc func);

typedef void CDECL (*VDICallFunc)(VDIPB *para, int16 *call_original, int16 super_called);
typedef void CDECL (*VDIReturnFunc)(VDIPB *para, int16 is_super);

extern int32 TrapperInstallVDICall(int16 opcode, VDICallFunc func);
extern int32 TrapperRemoveVDICall(int16 opcode, VDICallFunc func);
extern int32 TrapperInstallVDIReturn(int16 opcode, VDIReturnFunc func);
extern int32 TrapperRemoveVDIReturn(int16 opcode, VDIReturnFunc func);

typedef void CDECL (*AESCallFunc)(AESPB *para, int16 *call_original, int16 super_called);
typedef void CDECL (*AESReturnFunc)(AESPB *para, int16 is_super);

extern int32 TrapperInstallAESCall(int16 opcode, AESCallFunc func);
extern int32 TrapperRemoveAESCall(int16 opcode, AESCallFunc func);
extern int32 TrapperInstallAESReturn(int16 opcode, AESReturnFunc func);
extern int32 TrapperRemoveAESReturn(int16 opcode, AESReturnFunc func);

