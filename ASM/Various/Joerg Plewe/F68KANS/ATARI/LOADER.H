/*
 * definitions of the system interface SI
 */
 
typedef void cdecl SI_func();
typedef void* cdecl SI_funcarr; 
 
typedef struct { 
	char		SI_id[4]; 
 	SI_funcarr	SI_fa;
 	} SI_group;

typedef struct 
{
	long registers[16];	/* to be filled by F68K */
 	void *data;		/* A3 */
	void *code;		/* A5 */
	void *datastack;	/* A6 */
	void *retstack;  	/* A7 */
	void *TIBptr; 
	long codelen;
	long datalen;
	SI_group *si;
} FORTHPARAS; 

typedef void cdecl FUNC(FORTHPARAS*);
 