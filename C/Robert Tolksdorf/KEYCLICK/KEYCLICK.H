/****************************************************************
 * Definitionen der Scancodes der Tasten auf dem Zehnerblock
 */
#define KEY_LBRACE	0x63
#define KEY_RBRACE	0x64
#define KEY_SLASH	0x65
#define KEY_STAR	0x66
#define KEY_7		0x67
#define KEY_8		0x68
#define KEY_9		0x69
#define KEY_4		0x6A
#define KEY_5		0x6B
#define KEY_6		0x6C
#define KEY_1		0x6D
#define KEY_2		0x6E
#define KEY_3		0x6F
#define KEY_0		0x70
#define KEY_DOT		0x71
#define KEY_ENTER	0x72
#define KEY_MINUS	0x4A
#define KEY_PLUS	0x4E

/*************************************************
 * Inhalt und Struktur des Cookies
 */
#define COOKIEID		0x52544B43L

typedef struct{
	long	id,	val;
} COOKIE;

/*************************************************
 * Die Struktur, auf die das Wertefeld des 
 * Cookies zeigt.
 */

#define BUFFERSIZE	16
#define WINDOWMAX	8

typedef struct {void	(*init)(void);
				char	scans[BUFFERSIZE];
				int	windex;
				int	rindex;
				int	klickon;
				int	watchalt;
				int	kind[WINDOWMAX];
				int	id[WINDOWMAX];
				int installed;	} KCC;

/* Ende von KEYCLICK.H */

