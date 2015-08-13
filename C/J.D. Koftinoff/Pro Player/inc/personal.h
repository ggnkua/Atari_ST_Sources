
#ifndef __PERSONAL_H
#define __PERSONAL_H

#define VERSION "V8.2a"


#ifndef HAL_TIPPER
#define HAL_TIPPER 0
#endif

#ifndef DEMO_VERSION
#define DEMO_VERSION 0
#endif

#ifndef DEBUG
#define DEBUG	0
#endif

#ifndef PERSONALIZED
#define	PERSONALIZED	0
#endif

#if DEMO_VERSION

#define TITLE1  "PRO MIDI PLAYER DEMO " VERSION " " __DATE__ "                     "\
		"     By Jeff Koftinoff"
#define TITLE2  "PRO MIDI PLAYER DEMO " VERSION " By Jeff Koftinoff" 

 #if HAL_TIPPER
  #define TITLE3  "PRO MIDI PLAYER DEMO"
 #else
  #define TITLE3  "PRO MIDI PLAYER DEMO By JDK"
 #endif

#else

#define TITLE1  "PRO MIDI PLAYER " VERSION " " __DATE__ "                         "\
		"     By Jeff Koftinoff"
#define TITLE2  "PRO MIDI PLAYER " VERSION " By Jeff Koftinoff" 

 #if HAL_TIPPER
  #define TITLE3  "PRO MIDI PLAYER " VERSION
 #else
  #define TITLE3  "PRO MIDI PLAYER " VERSION " By JDK"
 #endif

#endif

#if PERSONALIZED
#ifndef USER_NUMBER
 #error PERSONALIZED BUT NO USER NUMBER!
#endif

#if  USER_NUMBER==1
 #define USER_NAME "Jeff Koftinoff of Burnaby BC, CANADA"
 #define SHORT_USER_NAME "Jeff Koftinoff"
 #define USER_ID "*J*K*123001EOFFFTJIENFOFFJF"

#elif USER_NUMBER==2
 #define USER_NAME "Hal Tipper of Calgary AB, CANADA"
 #define SHORT_USER_NAME "Hal Tipper"
 #define USER_ID "*H*T*123001AILPHPAELR"


#else
 #error UNKNOWN PERSONALIZED USER ID
#endif

#endif

#endif

