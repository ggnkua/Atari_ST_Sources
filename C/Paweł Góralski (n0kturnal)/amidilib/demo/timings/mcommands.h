
#ifndef MCOMMANDS_H
#define MCOMMANDS_H

/**  Copyright 2007-2022 Pawel Goralski
    
    This file is part of AMIDILIB.
    See license.txt for licensing information.
*/

#include "rol_ptch.h"
#include "roland.h"
#include "vendors.h"
#include "events.h"

#include "memory/memory.h"
#include <mint/osbind.h>

typedef struct SysEX_t
{
   uint16 size;
   uint8 *data;
} sSysEX_t;

#ifdef IKBD_MIDI_SEND_DIRECT

#define MIDI_SENDBUFFER_SIZE (32*1024)

AM_EXTERN uint8 midiSendBuffer[MIDI_SENDBUFFER_SIZE];  // buffer from which we will send all data from the events once per frame
AM_EXTERN volatile uint16 midiBytesToSend;
AM_EXTERN void flushMidiSendBufferCr(void);
AM_EXTERN void clearMidiOutputBufferCr(void); // clears custom midi output buffer
#else

#define MIDI_SEND_DATA(count,data) amMidiSendData(count-1,data)

// send data to midi port
static AM_INLINE void amMidiSendData(const uint16 count,const uint8 *data)
{
 Midiws(count,data); // use xbios function
 return; 
}

void flushMidiSendBufferCr(void)
{
    if(midiBytesToSend>0)
    {
      amMidiSendData(midiBytesToSend, midiSendBuffer);
    }

    amMemSet(midiSendBuffer,0,MIDI_SENDBUFFER_SIZE);
}

#endif

// sends SysEX message without recalculating the checksum
static AM_INLINE void sendSysEX(const sSysEX_t *pMsg)
{
amTrace("Send SysEx size: %u"NL,pMsg->size);

#ifdef IKBD_MIDI_SEND_DIRECT
 amMemCpy(&midiSendBuffer[midiBytesToSend],pMsg->data,pMsg->size);
 midiBytesToSend+=pMsg->size;

 Supexec(flushMidiSendBufferCr);
#else
    MIDI_SEND_DATA(pMsg->size,pMsg->data);
#endif
}

// 
// sends OMNI OFF MIDI message
// @param channel MIDI channel number 1-16 (0x00-0x0f).
// 
static AM_INLINE void omni_off(const uint8 channel)
{
#ifdef IKBD_MIDI_SEND_DIRECT
  midiSendBuffer[midiBytesToSend++]=EV_CONTROLLER|channel;
  midiSendBuffer[midiBytesToSend++]=C_OMNI_OFF;
  midiSendBuffer[midiBytesToSend++]=0x00;
#else
  const uint8 midi_cmd_buffer[3] = { (EV_CONTROLLER | channel), C_OMNI_OFF, 0x00};
  MIDI_SEND_DATA(3,midi_cmd_buffer);
#endif  
}

/**
 * sends RESET ALL CONTROLLERS MIDI message
 * @param channel MIDI channel number 1-16 (0x00-0x0f).
 */
static AM_INLINE void reset_all_controllers(const uint8 channel)
{
#ifdef IKBD_MIDI_SEND_DIRECT
  midiSendBuffer[midiBytesToSend++]=EV_CONTROLLER|channel;
  midiSendBuffer[midiBytesToSend++]=C_RESET_ALL;
  midiSendBuffer[midiBytesToSend++]=0x00;
#else
  const uint8 midi_cmd_buffer[3] = { (EV_CONTROLLER | channel), C_RESET_ALL, 0x00};
  MIDI_SEND_DATA(3,midi_cmd_buffer);
#endif  
}

// 
// sends PROGRAM CHANGE MIDI message
// @param channel MIDI channel number 1-16 (0x00-0x0f).
// @param programNb program number 1-128 (0x00-0x7F)
// 

static AM_INLINE void program_change(const uint8 channel,const uint8 programNb)
{
#ifdef IKBD_MIDI_SEND_DIRECT
  midiSendBuffer[midiBytesToSend++]=EV_PROGRAM_CHANGE|channel;
  midiSendBuffer[midiBytesToSend++]=programNb;
#else
  const uint8 midi_cmd_buffer[2] = { (EV_PROGRAM_CHANGE | channel), programNb } ;
  MIDI_SEND_DATA(2,midi_cmd_buffer);
#endif  
}

// sends CONTROL CHANGE MIDI message
// @param controller specifies which controller to use, full list is in EVENTS.H (from midi specification)
// and additional for XMIDI are in XMIDI.H. Value can be 0-127 (0x00-0x7F)
// @param channel MIDI channel number 1-16 (0x00-0x0f).
// @param value value sent to given controller 0-127 (0x00-0x7F)

static AM_INLINE void control_change(const uint8 controller,const uint8 channel,const uint8 value1,const uint8 value2)
{
#ifdef IKBD_MIDI_SEND_DIRECT
  midiSendBuffer[midiBytesToSend++]=EV_CONTROLLER|channel;
  midiSendBuffer[midiBytesToSend++]=controller;
  midiSendBuffer[midiBytesToSend++]=value1;
  midiSendBuffer[midiBytesToSend++]=value2;
#else
  const uint8 midi_cmd_buffer[4] = { (EV_CONTROLLER | channel), controller, value1, value2 };
  MIDI_SEND_DATA(4,midi_cmd_buffer);
#endif 
}


//  sends NOTE ON MIDI message (key pressed)
// 
//  @param channel MIDI channel number 1-16 (0x00-0x0f).
//  @param note specifies which note to play 0-127 (0x00-0x7F)
//  @param velocity with what velocity 0-127 (0x00-0x7F)
 
static AM_INLINE void note_on (const uint8 channel,const uint8 note, const uint8 velocity)
{
#ifdef IKBD_MIDI_SEND_DIRECT
  midiSendBuffer[midiBytesToSend++]=EV_NOTE_ON|channel;
  midiSendBuffer[midiBytesToSend++]=note;
  midiSendBuffer[midiBytesToSend++]=velocity;
#else
  const uint8 midi_cmd_buffer[3] = { (EV_NOTE_ON | channel), note, velocity };
  MIDI_SEND_DATA(3,midi_cmd_buffer);
#endif
}

// sends ALL NOTES OFF MIDI message
// @param channel MIDI channel number 1-16 (0x00-0x0f).
static AM_INLINE void all_notes_off(const uint8 channel)
{
#ifdef IKBD_MIDI_SEND_DIRECT
  midiSendBuffer[midiBytesToSend++]=EV_CONTROLLER|channel;
  midiSendBuffer[midiBytesToSend++]=C_ALL_NOTES_OFF;
  midiSendBuffer[midiBytesToSend++]=0x00;
#else
  const uint8 midi_cmd_buffer[3]= { (EV_CONTROLLER | channel), C_ALL_NOTES_OFF, 0x00 };
  MIDI_SEND_DATA(3,midi_cmd_buffer);
#endif  
}

// Silents midi channels (n to n-1) - useful when we have for example hanging notes.
// @param numChannels - number of channel

static AM_INLINE void allNotesOff(const uint16 numChannels)
{
  for(uint16 iCounter=0;iCounter<numChannels;++iCounter)
  {
    all_notes_off(iCounter);
  }
}

#include "../src/common/roland/r_static.h"

void  amMidiDeviceCm500AllPartsOn(void)
{
 sendSysEX(&arCM500AllPartsOn);
}

void  amMidiDeviceCm500AllPartsOff(void)
{
  sendSysEX(&arCM500AllPartsOff);
}

void amMidiDeviceEnableGm(const Bool bEnable)
{
    if(bEnable==TRUE)
    {
    	sendSysEX(&arEnableGM);
    }
    else
    {
    	sendSysEX(&arDisableGM);
    }
}

void amMidiDeviceEnableGs(void)
{
    sendSysEX(&gs_Reset);
}


// Official Roland patch, sets MT32 timbres to be GM compatible
void amMidiDevicePatchMt32toGm(const Bool bStandardGMDrumset)
{
    for (uint16 i=0;i<MAX_MT32_PATCH;++i)
    {
        sendSysEX(&mt32_gm[i]);
    }

    if(bStandardGMDrumset==TRUE)
    {
      // standard drumset
      sendSysEX(&mt32_stnd[0]);
      sendSysEX(&mt32_stnd[1]);
    }
    else
    {
      // orchestral
      sendSysEX(&mt32_orch[0]);
      sendSysEX(&mt32_orch[1]);
    }

    // patch CM32L(n)sfx parts for gm
    sendSysEX(&cm32_sfx[0]);
    sendSysEX(&cm32_sfx[1]);
}

void amMidiDeviceMt32Reset(void)
{
 sendSysEX(&mt32_Reset);
}

#endif
