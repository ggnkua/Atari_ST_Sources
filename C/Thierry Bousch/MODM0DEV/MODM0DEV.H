/*
 * modm0dev.h: public definitions to use the /dev/ttyd0 and /dev/cua0
 * devices. Edit them to suit your needs.
 */

#ifndef _modem0_dev_h
#define _modem0_dev_h
 
/*
 * Device-specific ioctl's, NOT officially attributed. If you change these
 * ones, change them in stty.c too.
 */
#define NON_OFFICIAL_IOCTLS

#ifdef NON_OFFICIAL_IOCTLS
#define TIOCGHUPCL	(('T'<< 8) | 98)
#define TIOCSHUPCL	(('T'<< 8) | 99)
#define TIOCGSOFTCAR	(('T'<< 8) | 100)
#define TIOCSSOFTCAR	(('T'<< 8) | 101)
#endif

/*
 * Names of the devices, from Sun's manpage. The dial-in device is
 * sometimes named `ttyS0' instead of `ttyd0'.
 */

#define MDM_DEVNAME	"U:\\dev\\ttyd0"
#define CUA_DEVNAME	"U:\\dev\\cua0"

/*
 * Name of the daemon, name of the device where error messages should be
 * printed (unused in the syslog version).
 */

#define D_NAME		"ttyd0d"
#define LOGFILE		"U:\\dev\\console"

/*
 * If SECURE_OPEN is defined, only root will be able to open these devices.
 * This is probably a good idea since MiNT does not check (yet) device
 * ownership.
 *
 * Defining NDEBUG will create a driver without debugging information at
 * all, thus faster and smaller. Since we're in test phase, we want
 * debugging.
 */
 
#define SECURE_OPEN
/*#define NDEBUG*/

/*
 * Default settings are: 19200 bps, eight-bit chars, no parity, one
 * stop bit, rts/cts enabled, hardware carrier control, and
 * hangup on close.
 */

#define INITIAL_SPEED	19200
#define INITIAL_FLAGS	(TF_8BIT | TF_1STOP | T_RTSCTS)
#define INITIAL_SOFTCAR	0
#define INITIAL_HUPCL	1

/*
 * Buffers for reception and transmission. The buffer sizes are arbitrary
 * long ints; they don't need to be equal, nor powers of two, they might
 * even be odd numbers. Don't set them too low, 1024L is probably
 * the very minimum.
 */

#define RX_BUF_LENGTH	6144L
#define TX_BUF_LENGTH	6144L

#endif	/* _modem0_dev_h */
