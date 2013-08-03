
/* OSIF Error handling 			*************************************/
EXTERN int errno;			/* error place for assigning	    */
EXTERN WORD __cpmrv;			/* the last BDOS return value (AX)  */
EXTERN int _errcpm;			/* place to save __cpmrv	    */
#define RETERR(val,err) {errno=(err);_errcpm=__cpmrv;return(val);}
					/************************************/
