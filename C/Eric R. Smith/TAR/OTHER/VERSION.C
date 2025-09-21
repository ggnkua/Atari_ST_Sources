#ifdef atarist
char version_string[] = "GNU tar version 1.04 (GEMDOS)";
#else
char version_string[] = "GNU tar version 1.04";
#endif
/* Version 1.00:  This file added.  -version option added */

/*		Installed new version of the remote-tape library */
/*		Added -help option */
/*	1.01	Fixed typoes in tar.texinfo */
/*		Fixed a bug in the #define for rmtcreat() */
/*		Fixed the -X option to not call realloc() of 0. */

/*	1.02	Fixed tar.c so 'tar -h' and 'tar -v' don't cause core dump */
/*		Also fixed the 'usage' message to be more up-to-date. */
/*		Fixed diffarch.c so verify should compile without MTIOCTOP
			defined */

/*	1.03	Fixed buffer.c so 'tar tzf NON_EXISTENT_FILE' returns an error
			message instead of hanging forever */

/*		More fixes to tar.texinfo */
/*	1.04	Added functions msg() and msg_perror()  Modified all the
			files to call them.  Also checked that all (I hope)
			calls to msg_perror() have a valid errno value
			(modified anno() to leave errno alone), etc
		Re-fixed the -X option.  This
 		time for sure. . . */	
/*		re-modified the msg stuff.  flushed anno() completely */
/*		Modified the directory stuff so it should work on sysV boxes */
/*		added ftime() to getdate.y */
/*		Fixed un_quote_string() so it won't wedge on \" Also fixed
		\ddd (like \123, etc) */
/*		More fixes to tar.texinfo */
