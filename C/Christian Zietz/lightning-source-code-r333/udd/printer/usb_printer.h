/*
 *  usb_printer.h
 *
 *
 *  Created by Claude Labelle on 18-11-29.
 */

#ifndef usb_printer_h
#define usb_printer_h
/* Printer status */
#define PRINTER_NO_ERROR		0x08L
#define PRINTER_PAPER_EMPTY		0x20L
#define PRINTER_ONLINE			0x10L
/* Job type */
#define TYPE_UNKNOWN 	0
#define TYPE_TEXT		1
#define TYPE_PJL		2
#define TYPE_PCL		3
#define TYPE_PDF		4
#define TYPE_JPG		5
/* Codes */
#define PJL_CODE 		"\x1B%-12345X"
#define PDF_CODE 		"%PDF-"
#define PDF_CODE_EOF	"%%EOF"
#define JPG_CODE		"\xFF\xD8\xFF"
#define JPG_CODE_EOF	"\xFF\xD9"

#endif /* usb_printer_h */
