/**
 * Thing
 * Copyright (C) 1994-2012 Arno Welzel, Thomas Binder
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * @copyright  Arno Welzel, Thomas Binder 1994-2012
 * @author     Arno Welzel, Thomas Binder
 * @license    LGPL
 */

/*=========================================================================
  TCMD.H

  Definitionen fÅr "Thing-Protokoll"
=========================================================================*/

#ifndef __TCMD_H
#define __TCMD_H


#define THING_MSG 0x46ff

/* Mit dieser Message werden Kommandos an Thing geschickt bzw. Thing
   schickt mit dieser Message Antworten an die Applikationen.
   Die folgenden Definitionen sind das eigentliche Kommando bzw.
   die Antwort in Wort 3 der AES-Message. Soweit nicht anders
   angegeben, sind die Worte 4-7 bzw. unbenutze Bits davon immer
   auf 0 zu setzen. */

#define AT_ILOAD 0x0001

/* Thing soll die Icons neu laden - wird vom 'Thing Icon Manager'
   verwendet.
   
   Keine Parameter */

#define TI_JOB 0x7fff

/* Internes Kommando von Thing zur Abwicklung von 'Jobs'

   Wort 4: Job-ID
   Wort 5: MagiC */

#define AT_WINICONIFY 0x1000

/* Alice meldet bei Thing ein Fenster als ikonifiziert an. Thing baut
   daraus intern einen Objektbaum fÅr das Fenster und kÅmmert sich
   um Redraws, die Alice an Thing weiterleitet
   
   Wort 4+5: Zeiger auf Programmnamen, ohne Pfad aber mit Extension
   Wort 6:   Fenster-Handle
   Wort 7:   reserviert, 0 */

#define AT_WINUNICONIFY 0x1001

/* Alice meldet ein Fenster wieder ab
   
   Wort 4: Fenster-Handle
   Wort 5-7: reserviert, immer 0 */

#endif
