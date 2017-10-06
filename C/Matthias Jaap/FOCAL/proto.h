#ifdef	__STDC__
# define ARG(list) list
#else
# define ARG(list) ()
# define void int
# define EXIT_SUCCESS 0
#endif

int	main ARG((void));
void	builtin ARG((char *cp, double (*fp)()));
void	process ARG((void));
void	ask ARG((void));
void	badline ARG((void));
void	pushcntl ARG((void));
void	popcntl ARG((void));
void	popdo ARG((void));
void	popfor ARG((void));
void	clearfors ARG((struct sym *sp));
void	inject ARG((int c));
int	getline ARG((char *cp, FILE *fp));
void	type ARG((void));
void	save ARG((struct lno *lnop, FILE *fp));
void	erasesyms ARG((void));

double	eval ARG((void));
double	primary ARG((void));
double	term ARG((void));
struct sym	*lookup ARG((char *id, int type, int subs));
struct sym	*getsym ARG((void));

#ifdef FUNCTIONS
double	fsin ARG((double arg));
double	fcos ARG((double arg));
double	fexp ARG((double arg));
double	flog ARG((double arg));
double	fatn ARG((double arg));
double	fsqt ARG((double arg));
double	fabt ARG((double arg));
double	fsgn ARG((double arg));
double	fitr ARG((double arg));
double	fran ARG((double arg));
#endif

void	library ARG((void));
void	catchcc ARG((void));
void	onintr ARG((void));
void	putline ARG((struct line *lp, FILE *fp));
void	getlno ARG((struct lno *lnop, int c));
int	getnum ARG((int c));
struct line	*alocline ARG((char *cp));
void	diag ARG((char *s));
int	getnb ARG((void));
double	drand48 ARG((void));
