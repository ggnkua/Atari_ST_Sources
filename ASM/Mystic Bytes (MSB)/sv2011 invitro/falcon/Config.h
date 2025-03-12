// DemoSys congig file

#include <Types.h>

#define FRAMES_PER_SECOND 20

#if	defined(BUILD_WIN_SDL)

// -----------------------------------------------------------------------------------
// PC

#include "Core\CoreWinSdl.h"
#include "FrameBuffer\FrameBuffer_WinSDL.h"

typedef DemoSys::FrameBufferImplementationWinSDL FrameBufferImplementation;
typedef DemoSys::CoreImplementationWinSDL CoreImplementation;

#elif defined(BUILD_FALCON060) || defined(BUILD_FALCON030)

// -----------------------------------------------------------------------------------
// atari falcon

#include "CoreFalcon030.h"
#include "FrameBuffer/FrameBuffer_Falcon030.h"

typedef DemoSys::FrameBufferImplementationFalcon030 FrameBufferImplementation;
typedef DemoSys::CoreImplementationFalcon030 CoreImplementation;

#elif defined(BUILD_AMIGA060)
// -----------------------------------------------------------------------------------
// amiga

#else
#error Unknown build target!
#endif
