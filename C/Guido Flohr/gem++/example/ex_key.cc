#include "ex_key.h"
#include <scancode.h>
#include <geme.h>

KeyProcessor::KeyProcessor(GEMactivity& a) :
	GEMkeyfocus(a),
	act(a)
{
}

GEMfeedback KeyProcessor::Consume(const GEMevent& ev)
{
	if (ev.Meta()&K_ALT) {
		switch (ev.Key()>>8) {
		 case KEY_Q:
			return EndInteraction;
		}
	}
	return GEMkeyfocus::Consume(ev);
}
