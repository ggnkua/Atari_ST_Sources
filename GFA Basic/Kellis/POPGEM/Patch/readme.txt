GokMasE's additional patches to PopGEM (2nd patch package)
==========================================================


*	CTRL+A will now select (or deselect) all emails to be deleted!

*	In the subject popup menu, emails marked to be deleted will have a
	"d" in front of them. Furthermore, also the sender will be specified
	in this popup now!
   
*	If one or more emails was marked to be deleted, you could not
	select "retrieve all" anymore. Fixed now.

*	If STiK wasn't found, PopGEM could crash at launch time. Fixed.

*	Updating the number of remaining emails on server after deleting 1 or more.

*	Now "subject:" field will read "Header not retrieved"
	if header is not yet downloaded from server.
	
*	Now "subject:" field will read "Email deleted"
	was removed from server when disconnecting.
		
*	The CICONs using 256 colour palette were mapped to the original
	Falcon palette which is rarely used these days. Changed to NVDI palette.
   
*	Cured some display problems occuring under MagiC, when 3d objects were
	turned off on systems with 16 or more colours.
		
*	New entry ("Never") in popup for setting time between check for new
	email. Earlier, the time setting was disabled by cancelling the popup.
	This new approach seems more logical to me.

*	PopGEM can now load the user data from a separate file (popgem.inf)
	
*	Clicking on the INFO icon will now open up a (modal) dialog allowing
	you to enter your POP-server data. These are saved to popgem.inf
	
============================================================================	
Now, I want to take the opportunity to point out that there is a new
tool for maintaining your inbox, based on the original PopGEM sources.
This program called "Meg", is coded by Rajah Loneh, and has a user friendly
GUI from which you can set up your account data. Well worth a look.

So why more patches for PopGEM, you ask? Well, the answer is simple:
-Just for fun! While taking a backseat from other projects I was poking
around in the PopGEM sources and found stuff I could improve. So I did.

Enjoy.


Joakim H”gberg

www.ataricq.org
