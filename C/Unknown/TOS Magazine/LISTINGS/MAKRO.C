#define XVERSION   "Version 1.xx  vom" __DATE__ "  "  __TIME__
#define FALSE  0
#define TRUE   (!0)

int Schreiben( FILE *fp )
{
return ( fprintf ( fp, XVERSION ) != EOF );
}

int Lesen( FILE *fp )
{
    char temp(sizeof (XVERSION) + 1L);

    if ( fread( temp, sizeof(XVERSION) + 1L, 1L, fp ) == 1L &&
            !strcmp( temp, XVERSION ) )
        return ( TRUE );
    else
        return ( FALSE );
}
