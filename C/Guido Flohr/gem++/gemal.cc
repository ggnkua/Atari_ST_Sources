/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemal.h"
#include "gemr.h"
#include <aesbind.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>

GEMalert::GEMalert(const GEMrsc& in, int RSCindex) :
	text(in.String(RSCindex)),
	local(false)
{
}

GEMalert::GEMalert(const char* lines, const char* buttons, int icon) :
	text(new char[256]),
	local(true)
{
	// I REALLY don't like non-RSCfile GEM stuff...
	text=new char[256];
	sprintf(text,"[%d][%s][%s]",icon,lines,buttons);
}

GEMalert::~GEMalert()
{
	if (local) delete text;
}

int GEMalert::Alert(int defbutt=-1)
{
	// Number of buttons, n = 1 + (number of '|' after final '[').
	int i, n;
	
	for (i=0; text[i]; i++);
	for (n=1; text[i]!='['; i--) if (text[i]=='|') n++;

	if (defbutt<0) {
		// -toomany becomes leftmost
		if (-defbutt>n) defbutt=1;
		else defbutt=n+1+defbutt;
	} else {
		// +toomany becomes rightmost
		if (defbutt>n) defbutt=n;
	}

	return form_alert(defbutt,text);
}

int GEMalert::Alertf(int defbutt, ...)
{
    va_list ap;

  va_start(ap, defbutt);
	char buf[256];
  vsprintf(buf, text, ap);

	// Temporarily swap "buf" for "text" member, and use normal Alert() method
	char* tmp=text;
	text=buf;
	int result=Alert(defbutt);
	text=tmp;
    va_end(ap);

	return result;
}
