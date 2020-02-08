/*=============================================================
*
*	cli : MATRIX - Command Line Interpreter (System Commands)
*	---------------------------------------------------------
*
*	File :		syscom.h
*
*	Date :		25.11.91
*	Version :	
*	Company :	MATRIX Daten Systeme GmbH
*				Talstr. 16
*				7155 Oppenweiler
*
*===============================================================*/


extern int		last_error ;
extern unsigned key_code ;
extern char 	last_include[80] ;

extern int command_loop ( int arg_count, char *arg_value[] ) ;
extern void syscom_init ( void ) ;
