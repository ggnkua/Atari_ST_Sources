/* Default values for max. transfer length.
 * Optimized to give best XFERRATE performance when reading from a USB stick. 
 * These values assume a stock (non-accelerated) MegaSTE/TT,
 * but users can change them with SETTER.PRG.
 */
 
#ifndef _VTTUSB_XFERLEN_H
#define _VTTUSB_XFERLEN_H

#ifndef __mc68030__
#define VTTUSB_DEF_XFER		(1023)	// MegaSTE
#else
#define VTTUSB_DEF_XFER		(672)	// TT030
#endif

#endif /* _VTTUSB_XFERLEN_H */
