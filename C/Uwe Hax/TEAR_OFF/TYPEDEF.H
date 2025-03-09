#define TRUE 1
#define FALSE 0
#define NIL -1
#define EOS    '\0'
#define NULL ((VOID *)0L)
#define DESKTOP 0
#define MAX_TEAROFF 10
#define LEFT_BUTTON  1
#define RIGHT_BUTTON  2

#define NO_MEMORY	"[3][Nicht genug Speicher!][  OK  ]"
#define NOT_IMPLEMENTED		"[1][Dieser MenÅpunkt ist noch|nicht implementiert!][  OK  ]"
#define NO_WINDOW	"[1][Es steht kein weiteres|Fenster mehr zur VerfÅgung!][  OK  ]"

#define Min(a,b)				((a)<(b) ? (a) : (b))
#define Max(a,b)				((a)>(b) ? (a) : (b))

typedef struct
{
  WORD whandle;
  OBJECT *tree;
  BYTE title[20];
} TEAROFF;
