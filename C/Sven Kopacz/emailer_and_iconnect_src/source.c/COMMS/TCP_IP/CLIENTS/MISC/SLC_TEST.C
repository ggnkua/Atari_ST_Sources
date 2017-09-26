#include    <portab.h>
#include <stdlib.h>
#include <stdio.h>
#include <tos.h>
/*#include <mt_aes.h>*/

#include <atarierr.h>
#include    <types.h>
#include <sockerr.h>
#include <sockinit.h>
#include <socket.h>
#include    <sockios.h>
#include <sfcntl.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>


void    main( void )
{
    int         Socket, Ret;
    hostent     *he;
    sockaddr_in Addrin;
    fd_set      Mask; 
    timeval     Tout;

    if(sock_init() < 0)
    {
    	show(1);
    	return;
    }
    
    Socket = socket( AF_INET, SOCK_STREAM, IPPROTO_TCP );
    sfcntl( Socket, F_SETFL, O_NONBLOCK );
    he = gethostbyname( "ftp.camelot.de" );

    Addrin.sin_family = AF_INET;
    Addrin.sin_port = 21;
    Addrin.sin_addr = *(ulong *) he->h_addr;
    Ret = connect( Socket, &Addrin, (int) sizeof( sockaddr_in ));

    printf( "connect() = %i\n", Ret );
    if( Ret != EINPROGRESS )
        return;

    FD_ZERO( &Mask );
    FD_SET( Socket, &Mask );
    Tout.tv_sec=0;
    Tout.tv_usec=0; 
    show(2);
    while((Ret = select( Socket+1, NULL, &Mask, NULL, &Tout )) != 1);
}