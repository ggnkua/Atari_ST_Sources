#include <SDL.h>
#include <AntTweakBar.h>
#include <stdio.h>

SDL_Surface* screen;

typedef unsigned int u32;
// ------------------------------------------------------------------------------------------------------

unsigned short* g_pData;
unsigned int* g_pText;

void Init()
{
    FILE* f= fopen ("test1.raw","rb" );

    fseek (f , 0 , SEEK_END);
    int Size = ftell (f);
    rewind (f);

    g_pData = (unsigned short*) malloc( Size );
    fread( g_pData,Size,1,f );
    fclose ( f);


    f= fopen ("texture2.raw","rb" );

    fseek (f , 0 , SEEK_END);
    Size = ftell (f);
    rewind (f);

    g_pText = (unsigned int*) malloc( Size );
    fread( g_pText,Size,1,f );
    fclose ( f);

}

// ------------------------------------------------------------------------------------------------------

u32 getMotorola ( unsigned short* pData )
{
    unsigned char* pTemp = (unsigned char*) pData;
    return (pTemp[0]<<8) | pTemp[1];
}

// ------------------------------------------------------------------------------------------------------

int s=0;
void Render()
{
    unsigned int* pText = g_pText + s;

    unsigned int* pBuffer = (unsigned int*) screen->pixels;
    unsigned short* pData = g_pData;

    u32 offset = getMotorola(pData++);

    do
    {
        unsigned int* pBuffer2 = &pBuffer[offset]; 
        u32 len = getMotorola(pData++);

        for ( ; len!=0; --len )
        {
            *pBuffer2++ = pText[ getMotorola(pData++) ];
        }

        offset = getMotorola(pData++);

    } while ( offset );

    s +=1;
}

// ------------------------------------------------------------------------------------------------------

#undef main

int main(int argc, char **argv)
{

	if ( SDL_Init(SDL_INIT_VIDEO) != 0 ) {
			printf("Unable to initialize SDL: %s\n", SDL_GetError());
			return 1;
	}

	SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 ); // *new*

	screen = SDL_SetVideoMode( 320, 200, 32, SDL_DOUBLEBUF  ); 

    Init ( );

	bool exit = false;
	
	while ( !exit )
	{

		SDL_Event ms_event; 

		if( SDL_PollEvent( &ms_event ) )
		{
				if ( SDL_QUIT == ms_event.type )
				{
						exit = true;
				}
				else if( SDL_KEYDOWN == ms_event.type && SDLK_ESCAPE == ms_event.key.keysym.sym)
				{ 
						exit = true;
				} 
		}

        Render();

        static int ms_oldTick = 0;

	// cap framerate
	    int t = SDL_GetTicks();
	    int delay = (1000/25) - (t - ms_oldTick);

	    if ( delay > 0 )
	    {
		    SDL_Delay( delay );
	    }
	    ms_oldTick = t;

		SDL_Flip( screen );
	}
	
	return 0;
}