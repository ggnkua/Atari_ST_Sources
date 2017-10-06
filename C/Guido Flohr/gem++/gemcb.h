/////////////////////////////////////////////////////////////////////////////
//
//  GEMclipboard
//
//  Encapsulation of the GEM clipboard protocol.
//
//  This file is Copyright 1994 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef gemcb_h
#define gemcb_h

// Protocol:
//
//  The GEM clipboard uses the 3-character extension of the file to
//  indicate the data type of the file (eg. IMG=GEM Image).
//
//  Simple case:  Application only supports one data type.
//
//    Writing (Cut, Copy):
//
//        GEMclipboard clip;
//        clip.Clear();
//        WriteYourDataTo(clip.FilenameToWrite(extension);
//
//    Reading (Paste):
//
//        GEMclipboard clip;
//        const char* filename=clip.FilenameToRead(extension);
//        if (filename) {
//            ReadYourDataFrom(filename);
//        }
//
//    The reading method can also be used for detecting if files
//    are available for reading.
//
//
//  Second case:  Application supports many data types.
//
//    Writing (Cut, Copy):
//
//        GEMclipboard clip;
//        clip.Clear();
//        for (extension = each extension you know how to write) {
//            WriteYourDataTo(clip.FilenameToWrite(extension);
//        }
//
//    Reading (Paste):
//
//        GEMclipboard clip;
//        for (extension = each extension you know how to read) {
//            const char* filename=clip.FilenameToRead(extension);
//            if (filename) {
//                ReadYourDataFrom(filename);
//                break;
//            }
//        }

class GEMclipboard {
public:
	GEMclipboard();
	~GEMclipboard();

	void Clear();
	const char* FilenameToWrite(const char* extension);
	const char* FilenameToRead(const char* extension);

private:
	char* filename;
};

#endif
