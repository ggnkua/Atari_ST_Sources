/*	http.h		*/

#include <time.h>

typedef struct
{
	char content_encoding[256];  /* x-gzip or x-compress */
	long content_length;         /* length of the object */
	char content_type[256];      /* MIME type of the object */
	time_t date;                 /* creation date of the object */
	time_t expires;              /* expiration date of the object */
	time_t last_modified;        /* date the object was last modified */
	char location[256];          /* real location of the document; go here */
	double mime_version;         /* MIME version used for this document;
	                                indicates a MIME compliant message */
	char pragma[256];            /* message for every gateway etc */
	char server[256];            /* server used by the host */
	char www_authenticate[256];  /* authentication challenge */
	char authorization[128];	 /* basic authorization response */
	int  return_code;			 /* return code from HTTP server */ 
} URL_info;

typedef struct
{
	char protocol[10];				/* ftp, http, gopher, news, mailto */
	char server[256];
	int port;
	char URI[512];
} URL_components;

#define      GET_METHOD     1
#define      POST_METHOD    2

