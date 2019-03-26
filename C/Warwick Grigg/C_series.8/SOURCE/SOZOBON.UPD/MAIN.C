/*
 *	Amendment history:
 *		7 Jan 90 by Warwick Grigg: wrong PRN and AUX devices
 */

#include <osbind.h>
#include <stdio.h>
#include <basepage.h>

extern int	_argc;
extern char	**_argv;
extern char	*_envp;

FILE	_iob[_NFILE] =			/* stream buffers */
	{
/* stdin */	{0, NULL, NULL, (_IOREAD | _IOFBF), 0, 0, '\0'},
/* stdout */	{0, NULL, NULL, (_IOWRT | _IONBF), 1, 0, '\0'},
/* stderr */	{0, NULL, NULL, (_IOWRT | _IONBF), -1, 0, '\0'},
/* stdprn */	{0, NULL, NULL, (_IOWRT | _IONBF), 3, 0, '\0'},
/* stdaux */	{0, NULL, NULL, (_IOREAD | _IOWRT | _IONBF), 2, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'},
		{0, NULL, NULL, 0, 0, 0, '\0'}
	};

_main()
	{
	void exit();
	register FILE *f;
	register int i, rv;

	for(i = 0, f = _iob; i < 5; ++i, ++f)	/* flag device streams */
		if(isatty(f->_file))
			f->_flag |= _IODEV;
	main(_argc, _argv, _envp);		/* if main() returns... */
	exit(EXIT_SUCCESS);			/* ...exit with OK status */
	}

void exit(status)
	int status;
	{
	register int i, f;

	for(i=0; i<_NFILE; ++i)
		{
		f = _iob[i]._flag;
	/*	if((f & (_IOREAD | _IOWRT)) && !(f & _IODEV))	*/
		if(f & (_IOREAD | _IOWRT))
			fclose(&_iob[i]);
		}
	_exit(status);
	}
