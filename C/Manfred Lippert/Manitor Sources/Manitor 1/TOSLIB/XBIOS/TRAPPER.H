/*----------------------------------------------------------------------------------------
	trapper.h, part of TOS Linker for CodeWarrior

	Definitions for special Xbios call "Trapper"
	
	31.1.1999 by Manfred Lippert

	last change: 31.1.2000

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#ifndef __TOS_trapper_h_
#define __TOS_trapper_h_

#ifndef __PORTAB__
#include <portab.h>
#endif

#if !TARGET_TOS
	#error Trapper-Lib used in Non-TOS Project
#endif
#if !MC68K
	#error Trapper-Lib used in Non-68K Project
#endif

#include "..\vdi\vdi.h"
#include "..\aes\aes.h"

#pragma	PRAGMA_PACKED_ALIGN

typedef struct {
	int16 version;	/* Hex-Coded, e.g. 0x100 for Version 1.00 */
	int16 reserved[15];
} TrapperInfo;

#pragma	PRAGMA_RESET_ALIGN


extern C_CALL int32 TrapperCheck(TrapperInfo *info);	/* E_OK, if Trapper is installed */


typedef int32 CDECL (*BiosCallFunc)(int16 *para, int16 *call_original, int16 super_called);
typedef int32 CDECL (*BiosReturnFunc)(int32 ret, int16 *para, int16 is_super);

extern C_CALL int32 TrapperInstallBiosCall(int16 opcode, BiosCallFunc func);
extern C_CALL int32 TrapperRemoveBiosCall(int16 opcode, BiosCallFunc func);
extern C_CALL int32 TrapperInstallBiosReturn(int16 opcode, BiosReturnFunc func);
extern C_CALL int32 TrapperRemoveBiosReturn(int16 opcode, BiosReturnFunc func);

typedef int32 CDECL (*XbiosCallFunc)(int16 *para, int16 *call_original, int16 super_called);
typedef int32 CDECL (*XbiosReturnFunc)(int32 ret, int16 *para, int16 is_super);

extern C_CALL int32 TrapperInstallXbiosCall(int16 opcode, XbiosCallFunc func);
extern C_CALL int32 TrapperRemoveXbiosCall(int16 opcode, XbiosCallFunc func);
extern C_CALL int32 TrapperInstallXbiosReturn(int16 opcode, XbiosReturnFunc func);
extern C_CALL int32 TrapperRemoveXbiosReturn(int16 opcode, XbiosReturnFunc func);

typedef int32 CDECL (*GemdosCallFunc)(int16 *para, int16 *call_original, int16 super_called);
typedef int32 CDECL (*GemdosReturnFunc)(int32 ret, int16 *para, int16 is_super);

extern C_CALL int32 TrapperInstallGemdosCall(int16 opcode, GemdosCallFunc func);
extern C_CALL int32 TrapperRemoveGemdosCall(int16 opcode, GemdosCallFunc func);
extern C_CALL int32 TrapperInstallGemdosReturn(int16 opcode, GemdosReturnFunc func);
extern C_CALL int32 TrapperRemoveGemdosReturn(int16 opcode, GemdosReturnFunc func);

typedef void CDECL (*VDICallFunc)(VDIPB *para, int16 *call_original, int16 super_called);
typedef void CDECL (*VDIReturnFunc)(VDIPB *para, int16 is_super);

extern C_CALL int32 TrapperInstallVDICall(int16 opcode, VDICallFunc func);
extern C_CALL int32 TrapperRemoveVDICall(int16 opcode, VDICallFunc func);
extern C_CALL int32 TrapperInstallVDIReturn(int16 opcode, VDIReturnFunc func);
extern C_CALL int32 TrapperRemoveVDIReturn(int16 opcode, VDIReturnFunc func);

typedef void CDECL (*AESCallFunc)(AESPB *para, int16 *call_original, int16 super_called);
typedef void CDECL (*AESReturnFunc)(AESPB *para, int16 is_super);

extern C_CALL int32 TrapperInstallAESCall(int16 opcode, AESCallFunc func);
extern C_CALL int32 TrapperRemoveAESCall(int16 opcode, AESCallFunc func);
extern C_CALL int32 TrapperInstallAESReturn(int16 opcode, AESReturnFunc func);
extern C_CALL int32 TrapperRemoveAESReturn(int16 opcode, AESReturnFunc func);

#endif
