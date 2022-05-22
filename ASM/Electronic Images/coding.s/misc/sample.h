/*------------------------------------------------------------------------------
#
#	Apple Macintosh Developer Technical Support
#
#	MultiFinder-Aware Simple Sample Application
#
#	Sample
#
#	Sample.h	-	Rez and C Include Source
#
#	Copyright © Apple Computer, Inc. 1989-1990
#	All rights reserved.
#
#	Versions:	
#				1.00				08/88
#				1.01				11/88
#				1.02				04/89	MPW 3.1
#				1.03				02/90	MPW 3.2
#
#	Components:
#				Sample.a			Feb.  1, 1990
#				Sample.inc1.a		Feb.  1, 1990
#				SampleMisc.a		Feb.  1, 1990
#				Sample.r			Feb.  1, 1990
#				Sample.h			Feb.  1, 1990
#				Sample.make			Feb.  1, 1990
#
#	Sample is an example application that demonstrates how to
#	initialize the commonly used toolbox managers, operate 
#	successfully under MultiFinder, handle desk accessories, 
#	and create, grow, and zoom windows.
#
#	It does not by any means demonstrate all the techniques 
#	you need for a large application. In particular, Sample 
#	does not cover exception handling, multiple windows/documents, 
#	sophisticated memory management, printing, or undo. All of 
#	these are vital parts of a normal full-sized application.
#
#	This application is an example of the form of a Macintosh 
#	application; it is NOT a template. It is NOT intended to be 
#	used as a foundation for the next world-class, best-selling, 
#	600K application. A stick figure drawing of the human body may 
#	be a good example of the form for a painting, but that does not 
#	mean it should be used as the basis for the next Mona Lisa.
#
#	We recommend that you review this program or TESample before 
#	beginning a new application.
------------------------------------------------------------------------------*/

/*	These #defines correspond to values defined in the Pascal source code.
	Sample.c and Sample.r include this file. */

/*	Determining an application's minimum size to request from MultiFinder depends
	on many things, each of which can be unique to an application's function,
	the anticipated environment, the developer's attitude of what constitutes
	reasonable functionality and performance, etc. Here is a list of some things to
	consider when determining the minimum size (and preferred size) for your
	application. The list is pretty much in order of importance, but by no means
	complete.
	
	1.	What is the minimum size needed to give almost 100 percent assurance
		that the application won't crash because it ran out of memory? This
		includes not only things that you do have direct control over such as
		checking for NIL handles and pointers, but also things that some
		feel are not so much under their control such as QuickDraw and the
		Segment Loader.
		
	2.	What kind of performance can a user expect from the application when
		it is running in the minimum memory configuration? Performance includes
		not only speed in handling data, but also things like how many documents
		can be opened, etc.
		
	3.	What are the typical sizes of scraps [is a boy dog] that a user might
		wish to work with when lauching or switching to your application? If
		the amount of memory is too small, the scrap may get lost [will have
		to be shot]. This can be quite frustrating to the user.
		
	4.	The previous items have concentrated on topics that tend to cause an
		increase in the minimum size to request from MultiFinder. On the flip
		side, however, should be the consideration of what environments the
		application may be running in. There may be a high probability that
		many users with relatively small memory configurations will want to
		avail themselves of your application. Or, many users might want to use it
		while several other, possibly related/complementary applications are
		running. If that is the case, it would be helpful to have a fairly
		small minimum size.
	
	So, what did we decide on Sample? First, Sample has little risk of
	running out of memory once it starts. Second, performance isn't much
	of an issue since it doesn't do much and multiple windows are not
	allowed. Third, there are no edit operations in Sample itself, so we
	just want to provide enough space for a reasonable scrap to survive
	between desk accessory launches. Lastly, Sample should intrude as little
	as possible, so the effort should be towards making it as small as possible.
	We looked at some heap dumps while the application was running under
	various partition sizes. With a size of 23K, there was approximately
	8-9K free, which is a good 'slop' factor in an application like this
	which doesn't do much, but where we'd still like the scrap to survive
	most of the time. */

#define kMinSize	23				/* application's minimum size (in K) */

/*	We made the preferred size bigger than the minimum size by 12K, so that
	there would be even more room for the scrap, FKEYs, etc. */

#define kPrefSize	35				/* application's preferred size (in K) */

#define	rMenuBar	128				/* application's menu bar */
#define	rAboutAlert	128				/* about alert */
#define	rUserAlert	129				/* error user alert */
#define	rWindow		128				/* application's window */
#define rStopRect	128				/* rectangle for Stop light */
#define rGoRect		129				/* rectangle for Go light */

/* kSysEnvironsVersion is passed to SysEnvirons to tell it which version of the
   SysEnvRec we understand. */

#define	kSysEnvironsVersion		1

/* kOSEvent is the event number of the suspend/resume and mouse-moved events sent
   by MultiFinder. Once we determine that an event is an osEvent, we look at the
   high byte of the message sent to determine which kind it is. To differentiate
   suspend and resume events we check the resumeMask bit. */

#define	kOSEvent				app4Evt	/* event used by MultiFinder */
#define	kSuspendResumeMessage	1		/* high byte of suspend/resume event message */
#define	kResumeMask				1		/* bit of message field for resume vs. suspend */
#define	kMouseMovedMessage		0xFA	/* high byte of mouse-moved event message */
#define	kNoEvents				0		/* no events mask */

/* The following constants are used to identify menus and their items. The menu IDs
   have an "m" prefix and the item numbers within each menu have an "i" prefix. */

#define	mApple					128		/* Apple menu */
#define	iAbout					1

#define	mFile					129		/* File menu */
#define	iNew					1
#define	iClose					4
#define	iQuit					12

#define	mEdit					130		/* Edit menu */
#define	iUndo					1
#define	iCut					3
#define	iCopy					4
#define	iPaste					5
#define	iClear					6

#define	mLight					131		/* Light menu */
#define	iStop					1
#define	iGo						2

/*	1.01 - kTopLeft - This is for positioning the Disk Initialization dialogs. */

#define kDITop					0x0050
#define kDILeft					0x0070

/*	1.01 - kMinHeap - This is the minimum result from the following
	equation:
		
		ORD(GetApplLimit) - ORD(ApplicZone)
		
	for the application to run. It will insure that enough memory will
	be around for reasonable-sized scraps, FKEYs, etc. to exist with the
	application, and still give the application some 'breathing room'.
	To derive this number, we ran under a MultiFinder partition that was
	our requested minimum size, as given in the 'SIZE' resource. */
	 
#define kMinHeap				21 * 1024
	
/*	1.01 - kMinSpace - This is the minimum result from PurgeSpace, when called
	at initialization time, for the application to run. This number acts
	as a double-check to insure that there really is enough memory for the
	application to run, including what has been taken up already by
	pre-loaded resources, the scrap, code, and other sundry memory blocks. */
	 
#define kMinSpace				8 * 1024

/* kExtremeNeg and kExtremePos are used to set up wide open rectangles and regions. */

#define kExtremeNeg				-32768
#define kExtremePos				32767 - 1 /* required to address an old region bug */

/* these #defines are used to set enable/disable flags of a menu */

#define AllItems	0b1111111111111111111111111111111	/* 31 flags */
#define NoItems		0b0000000000000000000000000000000
#define MenuItem1	0b0000000000000000000000000000001
#define MenuItem2	0b0000000000000000000000000000010
#define MenuItem3	0b0000000000000000000000000000100
#define MenuItem4	0b0000000000000000000000000001000
#define MenuItem5	0b0000000000000000000000000010000
#define MenuItem6	0b0000000000000000000000000100000
#define MenuItem7	0b0000000000000000000000001000000
#define MenuItem8	0b0000000000000000000000010000000
#define MenuItem9	0b0000000000000000000000100000000
#define MenuItem10	0b0000000000000000000001000000000
#define MenuItem11	0b0000000000000000000010000000000
#define MenuItem12	0b0000000000000000000100000000000