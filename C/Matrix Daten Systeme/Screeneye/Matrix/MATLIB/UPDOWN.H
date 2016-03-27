
# define UPDOWN_DOWN	1
# define UPDOWN_VALUE	2
# define UPDOWN_UP		3

# define UPDOWN(o)		case o+UPDOWN_DOWN: case o+UPDOWN_VALUE: case o+UPDOWN_UP
# define FORMmaxLen 16

typedef struct
{
	OBJECT	*tree ;
	int		box ;
	int		*value ;
	char	format[FORMmaxLen] ;
} UP_DOWN_VALUE ;

extern void update_updown ( UP_DOWN_VALUE *updown, int val ) ;
extern void init_updown ( UP_DOWN_VALUE *updown, OBJECT *t, int b, int *pv, char *f ) ;
extern void click_updown ( UP_DOWN_VALUE *updown, int clickobj ) ;
