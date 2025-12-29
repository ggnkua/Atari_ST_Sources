This version of ClustalV for Atari ST was compiled with the Pure C Compiler
Version 1.0. The code contains debug information and is not speed optimized.
On my MegaSTE (16 MHz, Cache on) the program needs 40 sec to align the both
sequences contained in the file proteins.tst (start with "clustalv proteins.tst").

The source code was obtained via anonymous ftp from ftp.embl-heidelberg.de.
The program was compiled with
	#define MSDOS 1	 		/* Turbo C for PC's */
and there was made a small change to the source which corrects an apparent
bug: line 1782 was changed from
		fprintf(clusout,"                %s\n\n",temp);
to
		fprintf(clusout,"               %s\n\n",temp);
which removes a space. This results in asterisks (*) marking exact alignment
and dots (.) marking conservative replacements. The modified source code is
contained in the distribution.

Pure C is copyrighted by Pure Software, Germany and distibuted (in Germany)
by Application Systems under a license from Borland GmbH.

DISCLAIMER:

The program included in this archive has not been extensively tested.
Since the source code has been modified only marginally I assume that
there is no change in its behaviour. Nevertheless, neither I nor the
original authors undertake liability for any direct or indirect damage,
including, but not restricted to, material or financial damage, caused
by the use of this program or its unsuitability for a specific purpose.
Everybody is using the program on his/her own risk.

This program may be distributed freely as long as there are no costs for
the customer. Distribution on PD disks and commercial mailbox systems
is not allowed.

--Cornelius Krasel (krasel@alf.biochem.mpg.de).
