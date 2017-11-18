
/* OSIF Error handling 			*************************************/
EXTERN WORD errno;			/* error place for assigning	    */
EXTERN WORD __cpmrv;			/* the last BDOS return value (AX)  */
EXTERN WORD _errcpm;			/* place to save __cpmrv	    */
#define RETERR(val,err) {errno=(err);_errcpm=__cpmrv;return(val);}
					/************************************/
