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

/*
 * thingrsc.h vom 10.07.1998
 *
 * Autor:
 * Thomas Binder
 * (binder@rbg.informatik.th-darmstadt.de)
 *
 * Zweck:
 * Einbinden aller fÅr Thing benîtigten Resource-Indexheader.
 *
 * History:
 * 16.01.1997: - Erstellung
 * 10.07.1998: - Anpassung an Ming und N.Thing
 * 01.03.2010: - Anpassung Pfade an neue Verzeichnis-Struktur
 */

#if defined(_NAES)
#include "nthing\thing.h"
#include "nthing\thingtxt.h"
#elif defined(_MILAN)
#include "ming\thing.h"
#include "ming\thingtxt.h"
#else
#include "..\src\rsrc\thing.h"
#include "..\src\rsrc\thingtxt.h"
#endif
