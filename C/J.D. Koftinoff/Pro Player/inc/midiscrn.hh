


#ifndef __MIDI_MIDISCRN_HH
#define __MIDI_MIDISCRN_HH

#include "world.h"

#include <MIDI/midi.hh>



#define DISP_TYPE_NONE          (0)
#define DISP_TYPE_D50           (1)
#define DISP_TYPE_MT32          (2)
#define DISP_TYPE_D10           (3)
#define DISP_TYPE_JX8P          (4)
#define DISP_TYPE_DX7           (5)
#define DISP_TYPE_JUNO1         (6)
#define DISP_TYPE_U20           (7)
#define DISP_TYPE_JD800         (8)


class MIDIScrn : public SysEx
{
protected:

	ushort scrn_type, scrn_channel;

		void    d50( ushort chan, char * );
		void    mt32( ushort chan, char * );
		void    d10( ushort chan, char * );
		void    jx8p( ushort chan, char * );
		void    dx7( ushort chan, char * );
		void    u20( ushort chan, char * );
		void    juno1( ushort chan, char * );
		void    jd800( ushort chan, char * );

public:
			MIDIScrn(ushort type, ushort channel );

	virtual void    Set( char *long_text, char *short_text );
	inline  void    Set( char *text )       { Set( text, text ); }
};

#endif

