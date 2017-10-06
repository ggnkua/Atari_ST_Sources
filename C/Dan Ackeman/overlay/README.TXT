ICQ.OVL & ICQ.CLIENT
Dan Ackeman aka baldrick@netset.com
March 29, 2000

	Originally I was writting these for a specific project.  Hence
the names, but along the way I discovered it was hard to find any 
decent small quick examples of how to handle an Overlay (OVL) module.
So looking over some examples that Guy Harrison (Swampdog) sent, I
tried to trim it down to a small clean example.  I've made some
modifications to his method, just to get things the way I like them.
It doesn't really do much, but I think enough is there to get someone started
if they would like to do this themselves.

   Really we are heading to the point that the Shared Libraries
of MiNT & Magic (and via the freeware CD Rom driver) are where we
should be heading.  However there are times when that is not
what the programmer wants.  Not all machines have enough RAM and 
drive space to run an extensive system supporting shared libraries.
So there are times and applications where an OVL file is still a 
viable option for use.

	I've set this example up to have the client do the 2 Pexecs (3 & 4).
You don't have to do this.  If you decide you don't want to use this
method, you can get by with just a Pexec(4).  However you will want
to remove the appl_init and appl_exit calls from the OVL.  You will
also need to look at the Basepage information from the ovl and do 
a Mshrink on it, or else you will discover your machine does not have
as much memory as it used to.

	Some extra informational notes on the archive:
	
	1. I used PureC to compile this milelage on other compilers may
			vary.
			
	2. The icqovl.h files for the client and ovl are slightly different.
		Don't mix the 2 unless you know what you are doing.  I could have
		made one, but got lazy in the end.  There is some stuff needed
		by the client that the OVL does not need and some stuff from
		the OVL that the client does need.  So I have 2 .h files.
		
	3. Code for the OVL is in the root directory of the archive.
	   Code for the test client is in the client directory of the archive.
	   
	   I hope I didn't forget anything.  Have fun and I hope you find
this useful.

	Dan Ackerman