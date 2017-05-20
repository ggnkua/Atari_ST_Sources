/* HEADER cookie jar */

typedef struct
	{
	long	ident;
	union
		{
		void *pt;			/* if used as a pointer 	*/
		long l;				/* if used as a long word 	*/
		int	 i[2];			/* if used as two integers	*/
		char c[4];			/* if used as 4 characters	*/
		}v;
	}COOKIE;

extern	COOKIE	*get_cookie(long);
extern	int		add_cookie(COOKIE *);
extern	int		remove_cookie(long);
