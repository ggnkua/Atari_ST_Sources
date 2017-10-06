	/************************************************\
	*						*
	*    astat.h -	Retrofit <sys/stat.h>		*
	*		for the Atari ST machines	*
	*						*
	*    J.R. Bammi					*
	*						*
	\************************************************/

#define time_t	long

struct    stat
{
    char    st_sp1[21];	/* Junk        */
    char    st_mode;	/* File attributes */
    time_t  st_mod;	/* Mod time, we use the date & time as 1 long */
    long    st_size;	/* File size       */
    char    st_sp2[14];	/* File name       */
};
