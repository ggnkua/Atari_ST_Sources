#ifndef Dialog_first
#define Dialog_first

/*---- Prototyping ----*/
OBJECT* DialogInit( int );
int     DialogDo( OBJECT* );
void    DialogSetItem( OBJECT*, int, bool );
bool    DialogGetItem( OBJECT*, int );

#endif Dialog_first 
