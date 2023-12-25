#ifndef TIM_TEST_SAMPLE_SEQ_H_
#define TIM_TEST_SAMPLE_SEQ_H_

/** Copyright 2007-2022 Pawel Goralski
    
    This file is part of AMIDILIB.
    See license.txt for licensing information.
*/

#include "vartypes.h"

typedef struct
{
  uint32 delta;
  uint8 note;	              // 0-127 range
  uint8 dummy;
} sEvent; 

typedef struct
{
  Bool bIsActive;
  uint8 volume;
  uint8 dummy;
} sTrackState; 

typedef struct
{
  sTrackState state;
  uint32 timeElapsedInt;
  sEvent *seqPtr;
  uint32 seqPosIdx;	        // song position
} sTrack;

typedef struct
{
  uint32 upqn;	            // quaternote duration in us, 500us default
  uint32 ppqn;	            // pulses per quater note
  uint32 bpm;  	            // beats per minute (60 000 000 / mpqn), 120 bpm default
  uint32 timeElapsedFrac;   // sequence elapsed time
  uint32 timeStep; 	        // sequence elapsed time
  sTrack tracks[3];	        // one per ym channel
  uint16 state;	            // current state playing/paused/stopped
  uint16 playMode;          // play in loop, play once etc..
} sCurrentSequenceState;

sEvent *getTestSequenceChannel(const uint8 chNb);

typedef enum
{
 S_PLAY_LOOP=0,
 S_PLAY_ONCE=1,
 PS_PAUSED=2,
 PS_PLAYING=3,
 PS_STOPPED=4
} ePlayModeStates;

#endif
