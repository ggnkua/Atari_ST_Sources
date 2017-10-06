*** Equates ***************************************************************

* This is the upper bound placed on the double click time (1 second).
* This is to prevent stupid values being passed - really high values
* (even 1 second, actually) are bad since even a single click won't be
* reported until dc_time has expired.

MAX_DC_TIME	equ	200


* The moose data buffer size must be divisible by 16:

MD_BUFFER_SIZE	equ	16*64


* The OS variable for the 200hz timer:

SYSTIMER	equ	$4ba


* The OS variable for the VBI list:

SYSVBI	equ	$456


* The OS variable for the number of entries in the VBI list:

SYSNVBI	equ	$454


*** Moose Data Structures *************************************************

* These structures are the ones that are Fread() from the device. Once
* you have assertained (by Fselect()) that there is information to read,
* you should read 1 word which is the command prefix (eg, MOOSE_BUTTON).
* This tells you what type of structure to read from the device next.

* The structures below don't include the prefix word - it is added by
* Moose at the time of writing the report.


** Moose Button Report Structure ******************************************

* This structure is the MOUSE_DATA structure in XaAES. It is essentially
* identical (in fact, the XaAES structure need not be altered) except that
* it has a prefix word to identify it as a button packet rather than a
* rectangle report etc.


MOOSE_BUTTON		equ	'XB'

		rsreset
MOOSE_BUTTON_X		rs.w	1
MOOSE_BUTTON_Y		rs.w	1
MOOSE_BUTTON_STATE	rs.w	1
MOOSE_BUTTON_COUNT	rs.w	1

MOOSE_BUTTON_LEN	rs.l	0


** Moose Rectangle Event Report Structure *********************************

* This structure is under construction - please wait.


*** Moose Commands ********************************************************

* The first word of each structure is a prefix denoting which command
* will follow. However, the entire command MUST be Fwrite()en as a single
* block, otherwise Moose won't know what you're talking about.


** Moose Rectangle Command Structure **************************************

* This structure is used to tell Moose to add or remove a rectnagle from
* its watch list. This structure is presently unused and is provisional.

* RECT_COM_ENTLV is 0 to watch for entering or 1 to watch for leaving.
* If bit 15 is clear, the rectangle is added to the watch list.
* If bit 15 is set, the rectangle is removed from the watch list.

RECT_COM		equ	'MR'

		rsreset
		rs.w	1	prefix
RECT_COM_ENTLV		rs.w	1
RECT_COM_X		rs.w	1
RECT_COM_Y		rs.w	1
RECT_COM_W		rs.w	1
RECT_COM_H		rs.w	1

RECT_COM_LEN		rs.l	0


** Moose Double Click Time Structure **************************************

* This structure represents an 'alter double click time' packet.

* DCLK_COM_TIME is the number of 200hz clicks for the double click time.
* As an indication, the default dc_time is 40 (0.2 seconds).

DCLK_COM		equ	'MD'

		rsreset
		rs.w	1	prefix
DCLK_COM_TIME		rs.w	1

DCLK_COM_LEN		rs.l	0


** Moose Initialise Command Structure *************************************

* This structure represents the INIT_COM command which must be sent to
* the moose device in order to activate it.

INIT_COM		equ	'MI'

		rsreset
		rs.w	1	prefix
INIT_COM_IKBD		rs.l	1

INIT_COM_LEN		rs.l	0



***************************************************************************