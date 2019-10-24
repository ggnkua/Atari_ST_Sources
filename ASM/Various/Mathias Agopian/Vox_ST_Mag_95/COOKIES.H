
typedef struct
{
	long ident;
	union
	{
		long l;
		int i[2];
		char c[4];
	}v;
}COOKIE;

COOKIE *fcookie(void);
COOKIE *ncookie(COOKIE *p);
COOKIE *get_cookie(long id);
int add_cookie(COOKIE *cook);
static COOKIE *create_cookie_jar(int n);

