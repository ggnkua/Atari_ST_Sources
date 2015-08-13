/*	ply_defs.h										By Jeff Koftinoff
**	v1.0
**
**
*/



#include "perform.h"
#include "jk_keys.h"
#include "jk_term.h"
#include "clocks.h"

typedef struct {
    char manu_id, device, model,
         *buffer;
    long msg_len, max_len, dev_addr;
                        /* message length, buffer length, address on device */
} EXCL;

typedef enum {
	ComNone,
	ComHelp,
	ComAutoPlay,
	ComPlay,
	ComStop,
	ComPause,
	ComSkip,
	ComBackup,
	ComSelect,
	ComUnhang,
	ComReload,
	ComNewSet,
	ComExit,
	ComTempoUp,
	ComTempoDown,
	ComTextSet
} CommandType;

typedef struct {
	CommandType	type;
	int		value;
} Command;


#include "ply_io.h"
#include "disk.h"
#include "play_s1.h"
#include "ply_main.h"
#include "playmidi.h"
#include "clocks.h"
#include "msgin.h"
#include "joystick.h"
#include "protect1.h"
#include "protect.h"


#define K_ABORT         (long)0x1e0001      /* ctrl A   */
#define K_UNHANG        (long)0x160015      /* ctrl U   */
#define K_PAUSE         (long)0x190010      /* ctrl P   */
#define K_EXIT          (long)0x220007      /* ctrl G   */
#define K_RELOAD        (long)0x26000c      /* ctrl L   */
#define K_PLAY          (long)0x390020      /* spacebar */
#define K_AUTO			(long)0x1c000d		/* Return	*/

#define STAT_COLOR      2       /* color for status line        */
#define HIGH_COLOR      1       /* color for highlights         */
#define TEXT_COLOR      3       /* color for normal text        */
#define BACK_COLOR      0       /* color for background         */


