
/**/
/*     These are the codes for communication with the Dialer   */
/*        (c) 1996  Peter Rottengatter                         */
/**/

#define  IP_DIALER_PORT     'IP'

#define  BASE_NUM           'IP'
#define  IP_DIAL_REQUEST    (BASE_NUM + 0)
#define  IP_DIAL_HANGUP     (BASE_NUM + 1)
#define  IP_DIAL_DONE       (BASE_NUM + 2)
#define  IP_DIAL_ERROR      (BASE_NUM + 3)

#define  IP_DIAL_OK         -1
#define  IP_IN_PROGRESS     1
#define  IP_IS_CONNECTED    2
#define  IP_SCR_NOT_FOUND   3
#define  IP_PORT_LOCKED     4
#define  IP_MAX_EXCEEDED    5
#define  IP_FATAL_PROBLEM   6
#define  IP_USER_ABORT      7
#define  IP_OPEN_FAILED     8
