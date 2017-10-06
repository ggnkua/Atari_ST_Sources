/////////////////////////////////////////////////////////////////////////////
//
//  example
//
//  This file demonstrates many of the features of the gem++ library.
//
/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992 by Warwick W. Allison,
//  and is freely distributable providing no charge is made.
//
/////////////////////////////////////////////////////////////////////////////

// Include the headers of the GEM++ features used here.
//
#include <gemap.h>
#include <gema.h>
#include <gemr.h>
#include <gemal.h>
#include <gemrt.h>

// Include the top-level demonstration classes.
#include "ex_menu.h"
#include "ex_key.h"

// Include RSC-file indices.
#include <example.h>

main()
{
	// Before we do ANYTHING with GEM, we must declare a GEMapplication.
	GEMapplication example;

	// Next, we declare a GEMrsc, which we then use to create other objects.
	GEMrsc rsc("example.rsc",8,16); // (This uses the GEM++ rsc loader)
	// GEMrsc rsc("example.rsc"); // (This uses the std GEM rsc loader)

	if (!rsc) {
		// If the GEMrsc file cannot be created, we have to resort to a
		// GEMalert constructed from strings rather than from the GEMrsc.
		GEMalert dammit("Could not load \"example.rsc\".","Quit");
		dammit.Alert();
	} else {
		// But if everything goes fine, we create a GEMactivity, and
		// our own Menu and Desktop (see definitions above) in that
		// GEMactivity.

		GEMactivity activity;

		Menu menu(activity,rsc);

		KeyProcessor keyproc(activity);

		GEMrectangletracker tracker(activity);

		// Then, conduct the GEMactivity - returns when all done.
		activity.Do();
	}
}
