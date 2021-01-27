/* Copyright (c) 1990 - present by H. Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* % is where AHCC leaves the text cursor */
	/* No tabs, we leave that to the autoindent switch */
	"(%)",
	"{\\n}\\n",
	"if (%)\\n;\\n",
	"if (%)\\n;\\nelse\\n;\\n",
	"if (%)\\n{\\n}\\n",
	"if (%)\\n{\\n}\\nelse\\n{\\n}\\n",
	"if (%)\\n{\\nothw\\n}\\n",
	"while (%)\\n;\\n",
	"while (%)\\n{\\n}\\n",
#if FOR_A
	" := ",
#else
	" = ",
#endif
	"do\\n;\\nwhile (%);\\n",
	"do\\n{\\n}\\nwhile (%);\\n",
	"for (%; ; )\\n;\\n",
	"for (%; ; )\\n{\\n}\\n",
	"void %();\\n",
	"void %()\\n{\\n}\\n",
	"#if %\\n#endif\\n",
	"#if %\\n#else\\n#endif\\n",
	"case: %\\nbreak;\\n",
	"switch (%)\\n{\\ncase:\\nbreak;\\ndefault:\\n}\\n",
