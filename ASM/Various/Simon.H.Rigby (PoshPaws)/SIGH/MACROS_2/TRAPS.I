* DIVIDE BY ZERO points to an RTE
* ALL OTHER SYSTEM VECTORS point to handler that dumps processor state
* and attempts to terminate program.

* Line A (1010) vector activates grahic primitives
* Line F (1111) vector is used internally by the AES

* TRAPS
*******
GEMDOS	EQU	1
GEM	EQU	2

LINE_A	EQU	10

BIOS	EQU	13
XBIOS	EQU	14

* all other traps are available for application use!

* VECTOR ADDRESSES FOR 68901 INTERRUPTS
***************************************
PARALLEL	EQU	$100	;DIASBLED
RS232_CD	EQU	$104	;DISABLED
RS232_CTS	EQU	$108	;DISABLED
NONE_1		EQU	$10C	;DISABLED
NONE_2		EQU	$110	;DISABLED
SYSTEM_CLK	EQU	$114
KBD_MIDI	EQU	$118
FDC_HDC		EQU	$11C	;DISABLED
*	may be used by hard disk drivers but must be disabled when 
*	in floppy read/write/format
HSYNC		EQU	$120	;DISABLED
RS232_TX_ERR	EQU	$124
RS232_TX_NXT	EQU	$128
RS232_RX_ERR	EQU	$12C
RS232_RX_NXT	EQU	$130
NONE_3		EQU	$134	;DISABLED
RS232_RING	EQU	$138	;DISABLED
MONITOR_TYPE	EQU	$13C	;DISABLED
