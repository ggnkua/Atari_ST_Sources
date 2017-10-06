/* icqovl.h
* 
* This will be the programming API for the icqovl.
*
* version 0.1
* Dan Ackerman
* aka baldrick@netset.com
*
*/

#ifndef __ICQ_API__H__
#define __ICQ_API__H__

/*--- Macro for prototyping ---*/
#ifdef __PUREC__
#  define ___CDECL cdecl
#else
#  define ___CDECL
#endif

/* Overlay Module name, no path */
#define ICQ_MOD		"ICQ.OVL"

/* unique header identification */
/* Use which ever version you feel more comfortable with,
   or more appropriately which ever version your compiler is 
   more comfortable with
*/
/*#define OVL_MAGIC		0x49635120L  */
#define OVL_MAGIC		"IcQ "

/* header identification length */
#define OVL_HDR_LEN		4


/*--- Module functions used by the client ---*/
typedef struct icq_methods_t
{
  long ___CDECL (*ovl_init)(void);
  char *___CDECL (*ovl_version)(void);
  long ___CDECL (*ovl_free)(void);

} ICQ_METH;

/*--- OVL information ---*/
struct ovl_info_t
{
	char *version;
	char *date;
	char *author;
	char *stack;
};

#endif /* !__ICQ_API__H__ */
