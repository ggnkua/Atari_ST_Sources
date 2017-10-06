/* Compile time configuration switches
 */

/*  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/* Tune the compile time settings before you say `make' for the SLB.
 * Nothing bad happens when you don't change anything in this file,
 * just a generic version of the library will be built.
 */

/* ------------------------ User definitions ------------------ */

/* Some AES versions completely trust all the pointers programs pass
 * in the parameter arrays and, when such a pointer is invalid, the
 * AES usually dies in flames then (together with all the system).
 * The library contains several pointer checks against this. If you
 * are sure your AES is robust and these checks are not required,
 * define this below. My advice is to keep this undefined, for safety.
 */
# undef _ROBUST_AES

/* Define this if you are sure your AES has the N.AES-style appl_yield()
 * function, and you want programs to use it. Syield() is used otherwise.
 */
# undef _HAVE_APPL_YIELD

/* Undefine this below if you want to use the library with an AES older
 * than v. 1.40 (TOS 1.04 or something). In that case, all calls to the
 * fsel_exinput() will be redirected to the fsel_input() function. This
 * switch does not have any effect on AES version 1.40 and up.
 */
# define _HAVE_FSEL_EXINPUT

/* This switch, when defined, allows to use the real appl_getinfo()
 * call even on AES versions below 4.0; activating this, when the
 * appl_getinfo() is not supported (e.g. on AES 3.40 of Falcon030) may
 * produce unpleasant results. When your AES is 4.0 or up, this makes
 * no difference.
 * In other words: when this is undefined, and AES is below 4.0, the
 * appl_getinfo() call will be emulated by the library. If you want to
 * avoid emulation, and call the real function instead (e.g. on MagiC),
 * define the switch.
 */
# undef _HAVE_APPL_GETINFO

/* Define this if the AES supports the form_popup() call (e.g. N.AES
 * does, the Atari AES 4.10 does not). It will be emulated otherwise.
 */
# undef _HAVE_FORM_POPUP

/* ------------------------ Hardcore definitions ------------------ */

/* Define this below if you want a debug version of the library
 * (believe me, you don't)
 */
# undef DEBUG

/* Maximum text line length in an alert box.
 */
# define MAX_LINE	25

/* Maximum pid number a process can have.
 */
# define MAX_PID	999

/* Mxalloc() page size on your system.
 */
# define DEF_PAGE_SIZE	8192

/* Minimum Mxalloc() page size on your system.
 */
# define MIN_PAGE_SIZE	1024

/* EOF */
