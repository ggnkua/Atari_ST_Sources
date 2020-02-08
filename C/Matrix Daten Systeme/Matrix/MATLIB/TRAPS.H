/* traps.h(s) / 19.3.91 / MATRIX / WA	*/

extern void enable_irq ( unsigned oldsr ) ;
extern unsigned disable_irq ( void ) ;

extern PROC **get_excv_base ( void ) ;

extern void break_point(void) ;
extern void inst_buserr(void) ;
extern void remove_buserr(void) ;

extern void wr_byte ( void *addr, int val ) ;
extern int  rd_byte ( void *addr ) ;

extern bool berr_flag ;

extern long cache0 ( void ) ;
extern long cache1 ( void ) ;
extern long cpu_reset ( void ) ;