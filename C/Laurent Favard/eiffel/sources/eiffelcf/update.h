#ifndef	__UPDATE__
#define	__UPDATE__

extern	void UpdateEiffel( const char *aPath );
extern	void ChangeTable( const char *aPath, unsigned char *table );
extern	int lect_hex(unsigned char *);
extern	int lect_hex1(unsigned char);
extern	void prog_flash(unsigned char *);
extern	long tempo(void);
extern	COOKIE *get_cookie(long id);

#endif
