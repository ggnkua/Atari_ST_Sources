
#ifndef __CFG_TYPE_H
#define __CFG_TYPE_H

#include <cfg.hh>


#define CFG_MAP_VERSION		(long)(0x00000010)
#define	CFG_MAP_CHANNEL		(long)(0x00000100)

#define CFG_PERFORM_VERSION	(long)(0x00000020)

#define CFG_CTRL_CHANNEL	(long)(0x00000110)
#define CFG_CTRL_TYPE		(long)(0x00000111)

#define CFG_DISPLAY_CHANNEL	(long)(0x00000120)
#define CFG_DISPLAY_TYPE	(long)(0x00000121)

#define CFG_MASTER_CHANNEL	(long)(0x00000130)
#define CFG_MASTER_LOCAL	(long)(0x00000131)

#define CFG_LIGHT_CHANNEL	(long)(0x00000140)
#define CFG_LIGHT_TYPE		(long)(0x00000141)

#define CFG_MIDI_THRU		(long)(0x00000150)

#define CFG_AUTO_PLAY		(long)(0x00000160)

#define CFG_INTERNAL_CHANNEL	(long)(0x00000170)
#define CFG_INTERNAL_TYPE	(long)(0x00000171)

#define CFG_WAIT_AFTER_EXCL	(long)(0x00000180)
#define CFG_USE_JOYSTICK	(long)(0x00000190)

#define CFG_LOAD_SINGLE_SONGS	(long)(0x000001a0)

#define CFG_PAUSE_AFTER_LOAD	(long)(0x000001a1)

#define CTRL_TYPE_NONE		(long)(0)
#define CTRL_TYPE_PG1		(long)(1)
#define CTRL_TYPE_PG125		(long)(2)
#define CTRL_TYPE_PORT		(long)(3)
#define CTRL_TYPE_HOLD		(long)(4)
#define CTRL_TYPE_PG		(long)(5)
#define CTRL_TYPE_JOY		(long)(6)


#define DISP_TYPE_NONE		(long)(0)
#define DISP_TYPE_D50		(long)(1)
#define DISP_TYPE_MT32		(long)(2)
#define DISP_TYPE_D10		(long)(3)
#define DISP_TYPE_JX8P		(long)(4)
#define DISP_TYPE_DX7		(long)(5)
#define DISP_TYPE_JUNO1		(long)(6)
#define DISP_TYPE_U20		(long)(7)
#define DISP_TYPE_JD800		(long)(8)


#define CFG_TYPE 	"Perform CFG JDKS"
#define CFG_FILE_NAME	"perform.cfg"

#endif


