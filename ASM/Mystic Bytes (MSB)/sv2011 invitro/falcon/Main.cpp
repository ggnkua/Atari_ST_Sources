//--------------------------------------------------------------------------------------------
//
//		Main
//
//--------------------------------------------------------------------------------------------

#include <Config.h>
#include <Core.h>
#include <Factory.h>
#include <FrameBuffer.h>

#include <vector>

#include <3rd_party/Falcon_MP2/mp2.h>
#include <mint/osbind.h>
#include <mint/falcon.h>
#include <MicroThread.h>

#include <Archive.inl>
#include <File.h>

#include <Fx/FxBase.h>
#include <Fx/LogoFlash.h>
#include <Fx/StillImage.h>
#include <Fx/OffsetScroll.h>
#include <Fx/HwScroll.h>

//--------------------------------------------------------------------------------------------

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

//--------------------------------------------------------------------------------------------
TimeLine g_timeLine[128];
typedef std::vector<FxBase*> FxTable;
FxTable g_fxQueue;
volatile s32 g_currentFx = 0;
volatile bool g_exit = false;

class FxThread : public ThreadBase
{
	int Run	( ) 
	{ 		
		*((volatile long*)0x4BA) = 0;
		int prev_time = 0 ;
		int curr_timer = prev_time ;
		u32 curMilis = 0;
		u32	curTimelinePos = 0;
	
		g_currentFx = 0;
		g_exit = false;
		
		UpdateInfo updateInfo;
	
		while ( 1 )
		{
			curr_timer = *((volatile long*)0x4BA) ;
				
			int dt = ( curr_timer - prev_time ) * 5 ;   // delta time in miliseconds
						
			if ( dt < 25 )
			{
				continue;
			}
			
			curMilis += dt;
			
			// perere update info values
		
			updateInfo.m_dt = dt;
			updateInfo.m_currentMilis+=dt;
			updateInfo.m_signal = cmdIdle;

			while( g_timeLine[ curTimelinePos ].m_ms <  curMilis )
			{
				updateInfo.m_signal = g_timeLine[ curTimelinePos ].m_signal;
				
				curTimelinePos ++;
				
				if (  updateInfo.m_signal == cmdEnd )
				{
					g_exit = true;
				}
				else if (  updateInfo.m_signal == cmdNext )
				{
					g_currentFx++;
					
					if ( g_currentFx <  g_fxQueue.size() )
					{
						g_fxQueue[g_currentFx]->Start ( );
					}
				}
				
			}

			if ( g_currentFx <  g_fxQueue.size() )
			{
				g_fxQueue[g_currentFx]->Render( );
				g_fxQueue[g_currentFx]->Update( &updateInfo );
			}

			DemoSys::FrameBufferInterface::postProcessBuffers();
			DemoSys::FrameBufferInterface::flipBuffers(false);
			
			prev_time = curr_timer; 
		}
		return 0; 
	} 
};



//------------------------------------------------------------------------------------------------

void rapidxml::parse_error_handler(const char *what, void *where)
{
	printf("parsing error\r\n");
}

void InitQueue ( FxTable& fxQueue, Node& node )
{
	Node screen = node.FindNode( "Screen" );
	
	do
	{		
		const char* pClassName = NULL;
		screen.r( "Class", pClassName );
		FxBase* pClass = (FxBase*)Factory::instance().Create( pClassName);
		printf ( "class: %s, 0x%x\r\n", pClassName, pClass );
		assert (  pClass != 0 );
		pClass->Serialise( screen );
		fxQueue.push_back( pClass );	
		
	}while ( screen.NextSibling() );

}

//--------------------------------------------------------------------------------------------

int main(int argc, char **argv)
{
	DemoSys::CoreInterface::init();
    DemoSys::FrameBufferInterface::initFrameBuffer(DemoSys::FrameBufferInterface::kbufsize_320x200_8);	
	
	
	// Serialise the config
	
	u32	configSize;
	char* pConfig = (char*) LoadFile( "config.xml",&configSize);
	pConfig[ configSize ] = 0;
			
	Archive arch ( pConfig );
	
	Node conf = arch.FindNode( "Config" );
	Node queue = conf.FindNode( "Queue" );
	
	const char* pMusicFile = NULL;
	conf.r( "Music", pMusicFile );
	printf ( "val: %s\r\n", pMusicFile );
	
	InitQueue ( g_fxQueue, queue );
	
	Node timeline = conf.FindNode( "Timeline" );
	timeline.rlist( "Event", g_timeLine );

	//return 0;
	
	ThreadSheduler::Create( );	
	
	g_fxQueue[0]->Init ( );
	g_fxQueue[0]->Start ( );
	
	MP2Init("data\\music.mp2");	
	MP2StartAudio();

	FxThread* pThread = new FxThread();
	ThreadSheduler::AddThread ( pThread, 0x8000, 10, false );
	
	volatile s32 currentFx = g_currentFx;
    
	do 
	{	
		if ( currentFx == g_currentFx )
		{
			if ( currentFx - 1 < (s32)g_fxQueue.size() )
			{
				if ( currentFx -1 >= 0 )
				{
					delete ( g_fxQueue[currentFx - 1] );
				}
				
				currentFx++;
				
				if ( currentFx < g_fxQueue.size() )
				{
					g_fxQueue[currentFx]->Init();
				}
			}
			else
			{
				break;								// we're done
			}
		}
		//printf("g_currentFx: %d\r\n",g_currentFx );
		MP2Feed();    
	}
	while( DemoSys::CoreInterface::loop() && !g_exit );
	
	printf("Shutting down.\r\n");
	
	MP2StopAudio();
	
	ThreadSheduler::Destroy( );	
    DemoSys::FrameBufferInterface::shutdownFrameBuffer();
	DemoSys::CoreInterface::shutdown();
	
    return 0;
}
// ------------------------------------------------------------------------------------------------------------------


