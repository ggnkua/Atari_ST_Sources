/* Actions to be Taken with Control Characters */

#define   NUL  '\0' /* to be ignored in all cases */
#define   SOH  '\001'    /* No Function */
#define   STX  '\002'    /* No Function */
#define   ETX  '\003'    /* No Function */
#define   EOT  '\004'    /* No Function */
#define   ENQ  '\005'    /* Generates Answer Back Message */
#define   ACK  '\006'    /* No Function */
#define   BEL  '\007'    /* Beep */
#define   BS   '\010'    /* Back Space */
#define   HT   '\011'    /* Horizontal Tab */
#define   LF   '\012'    /* Line Feed */
#define   VT   '\013'    /* Vertical Tab (as LF) */
#define   FF   '\014'    /* Form Feed (as LF) */
#define   CR   '\015'    /* Carriage Return */
#define   SO   '\016'    /* Shift Out */
#define   SI   '\017'    /* Shift In */
#define   DLE  '\020'    /* No Function */
#define   DC1  '\021'    /* XON */
#define   XON  '\021'    /* XON */
#define   DC2  '\022'    /* No Function */
#define   DC3  '\023'    /* XOFF */
#define   XOFF '\023'    /* XOFF */
#define   DC4  '\024'    /* No Function */
#define   NAK  '\025'    /* No Function */
#define   SYN  '\026'
#define   ETB  '\027'    /* No Function */
#define   CAN  '\030'    /* Cancel Escape Sequence */
#define   EM   '\031'    /* No Function */
#define   SUB  '\032'    /* Cancel Escape Sequence */
#define   ESC  '\033'    /* Escape to Sequence */
#define   FS   '\034'    /* Change to Graphics */
#define   GS   '\035'    /* Change to Graphics */
#define   RS   '\036'    /* Change to Graphics */
#define   US   '\037'    /* Change to Graphics */
#define   DEL  '\0177'   /* Ignored when received, may not be used
                            as a time fill character */

