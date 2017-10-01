/* *** MP_MESAG.H - MOD player mesages *** */

/* VA_START: Activates an accessory. Word 3 + 4 contain a pointer to a
 command string (may also be a NULL pointer!) */
#define VA_START     0x4711

/* MOD_OK: Okay, the previous command has been understood. */
#define MOD_OK       0x4D00

/* MOD_NAK: Not okay, the command was understood but rejected. */
#define MOD_NAK      0x4D01

/* MOD_PLAY: Play the module, MOD_OK or MOD_NAK is replied. */
#define MOD_PLAY     0x4D02

/* MOD_STOP: Stop playing the module. */
#define MOD_STOP     0x4D03

/* MOD_LOAD: Load a module into the buffer, MOD_NAK is replied if
 something went wrong, MOD_OK if it is okay. msgbuf[3]+msgbuf[4]
 are a pointer the the module filename. */
#define MOD_LOAD     0x4D04

/* MOD_CLEAR: Stop module and clear the buffer. */
#define MOD_CLEAR    0x4D05
