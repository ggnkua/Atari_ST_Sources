/* text.h - ezscore plus - craig dickson 880318 - copyright 1988 hybrid arts */

#define  SYS6X6   0
#define  SYS8X8   1
#define  SYS8X16  2
#define  CUS6X6   3
#define  CUS8X8   4
#define  CUS8X16  5
#define  CUS24X24 6

#define  MYLFONT  CUS24X24
#define  MYSFONT  CUS8X8
#define  MYTFONT  CUS6X6

#define  SPLITCHAR   '\003'

extern char *language[];		/* in tom's globals.h */

#define PRTSEC			language[101]
#define NEXT_SHEET 	language[102]
#define NO_PRINTER 	language[103]
#define BAD_MEASOFF 	language[104]
#define BAD_MISTAKE 	language[105]
#define BAD_PAGEOFF 	language[106]
#define BAD_PM 		language[107]
#define BAD_SM 		language[108]
#define BAD_SP 		language[109]
#define BAD_SPM 		language[110]
#define BAD_SYSCOUNT language[111]
#define TOO_LONG1 	language[112]
#define TOO_LONG2 	language[113]

/* EOF */
