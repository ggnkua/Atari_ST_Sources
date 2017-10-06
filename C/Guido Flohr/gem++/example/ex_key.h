#ifndef ex_key_h
#define ex_key_h

#include <gemkfoc.h>

class KeyProcessor : public GEMkeyfocus {
public:
	KeyProcessor(GEMactivity& a);

	virtual GEMfeedback Consume(const GEMevent& ev);

private:
	GEMactivity& act;
};

#endif
