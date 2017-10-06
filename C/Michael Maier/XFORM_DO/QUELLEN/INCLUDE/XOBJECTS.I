* -------------------------------------------------- *
*
*               XFORMDO.LIB Version 1.2
*
*          geschrieben von Michael Maier 1991
*
* -------------------------------------------------- *

* -------------------------------------------------- *
* Headerdatei: XOBJECTS.I
* Version: 1.0
* Datum: 14.9.1991
* -------------------------------------------------- *

CHECKBOX        EQU     1
HEADER          EQU     2
RADIO           EQU     3
UNDERLINE       EQU     4
HOTKEY          EQU     5
CHKHOTKEY       EQU     6
RBHOTKEY        EQU     7
INDHOTKEY       EQU     8
FLYDIAL         EQU     9
TXTDEFAULT      EQU    10

G_HOTKEY        EQU     $0100|G_USERDEF
G_IND           EQU     $0200|G_USERDEF
G_RB            EQU     $0300|G_USERDEF
G_CHK           EQU     $0400|G_USERDEF
G_FLY           EQU     $0500|G_USERDEF
