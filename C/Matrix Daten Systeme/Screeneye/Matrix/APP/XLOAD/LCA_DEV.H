extern BOOL GetLCAdnp ( unsigned port ) ;
extern BOOL GetLCAnreset ( unsigned port ) ;
extern BOOL GetLCAninit ( unsigned port ) ;
extern BOOL GetLCAready ( unsigned port ) ;
extern void PutLCAdata ( unsigned port, unsigned char data ) ;

extern void SetLCAreset ( unsigned port ) ;
extern void ClrLCAreset ( unsigned port ) ;
extern void SetLCAreprog ( unsigned port ) ;
extern void ClrLCAreprog ( unsigned port ) ;

extern long DelayLoop ( long n ) ;
