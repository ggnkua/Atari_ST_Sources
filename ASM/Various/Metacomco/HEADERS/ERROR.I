**************************************************************************
*                                                                        *
*                               ERROR.I                                  *
*                                                                        *
* This file contains the system (BIOS, XBIOS and GEMDOS) error codes.    *
* See the Error Messages appendix for further details.                   *
*                                                                        *
**************************************************************************

* BIOS and XBIOS error codes

E_OK            EQU 0
ERROR           EQU -1
EDRVNR          EQU -2
EUNCMD          EQU -3
E_CRC           EQU -4
EBADRQ          EQU -5
E_SEEK          EQU -6
EMEDIA          EQU -7
ESECNF          EQU -8
EPAPER          EQU -9
EWRITF          EQU -10
EREADF          EQU -11
* Unused            -12
EWRPRO          EQU -13
E_CHNG          EQU -14
EUNDEV          EQU -15
EBADSF          EQU -16
EOTHER          EQU -17

* GEMDOS error codes

EINVFN          EQU -32
EFILNF          EQU -33
EPTHNF          EQU -34
ENHNDL          EQU -35
EACCDN          EQU -36
EIHNDL          EQU -37
ENSMEM          EQU -39
EIMBA           EQU -40
EDRIVE          EQU -46
ENMFIL          EQU -49
ERANGE          EQU -64
EINTRN          EQU -65
EPLFMT          EQU -66
EGSBF           EQU -67

* End of ERROR.I
