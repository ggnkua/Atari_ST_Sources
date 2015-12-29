<?php
# +======================================================================+
# | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
# +----------------------------------------------------------------------+
# | Main configuration for the parallax distorter                        |
# +======================================================================+
# | Copyright (c) 2015 Frederic Poeydomenge <dyno@aldabase.com>          |
# +----------------------------------------------------------------------+
# | This program is free software: you can redistribute it and/or modify |
# | it under the terms of the GNU General Public License as published by |
# | the Free Software Foundation, either version 3 of the License, or    |
# | (at your option) any later version.                                  |
# |                                                                      |
# | This program is distributed in the hope that it will be useful,      |
# | but WITHOUT ANY WARRANTY; without even the implied warranty of       |
# | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the         |
# | GNU General Public License for more details.                         |
# |                                                                      |
# | You should have received a copy of the GNU General Public License    |
# | along with this program. If not, see <http://www.gnu.org/licenses/>. |
# +======================================================================+

$soundTable = array(
    211 => 15,
    137 => 14,
     86 => 13,
     61 => 12,
     40 => 11,
     29 => 10,
     20 =>  9,
     15 =>  8,
     10 =>  7,
      7 =>  6,
      5 =>  5,
      4 =>  4,
      3 =>  3,
      2 =>  2,
      1 =>  1
);

$mapTile        = 'tile.png';
$numTileX       = 3;
$numTileY       = 6;
$tileMapWidth   = 6;
$tileMapHeight  = 6;
$widthTile      = 16;
$heightTile     = 6;

$idxColor = array(
    -1 => '808080',
     0 => '000000',
     9 => '888888',
    10 => 'AAAAAA',
    11 => 'CCCCCC',
    12 => 'EEEEEE',
    13 => '88AAFF',
    14 => '4466CC',
    15 => '0022AA',
);

$spc = '     ';

/*============*/
/* INTRO Text */
/*============*/

$textIntro =

'            ' .
'ONCE UPON A TIME, THERE WAS A SCREEN CALLED <THE PARALLAX DISTORTER> BY ULM.      ' .
'25 YEARS LATER,  FOR STNICCC 2015,  DYNO MOVES ONTO THE NEXT LEVEL !' . $spc;

/*===========*/
/* DEMO Text */
/*===========*/

$textDemo =

$spc . $spc . $spc .

'WOW ! ONE OF THE GREATEST PLEASURE IN LIFE, IS DOING WHAT PEOPLE SAID COULDN\'T BE DONE !' . $spc .

'DYNO PROUDLY PRESENTS HIS FIRST DEMO-SCREEN SINCE 1995.' . $spc .

'ANOTHER PARALLAX DISTORTER WILL YOU SAY ? YES ! BUT A VERY BIG ONE, DON\'T YOU THINK SO ? ' .
'THIS SCREEN INCLUDES A 36 PIXEL FONT, AND A SAMPLE PLAYING AT 8.3 KHZ ON 3 REGISTERS.' . $spc .

'THE CREDITS FOR THIS SCREEN : '.
'CODE AND SAMPLE BY DYNO, ' .
'ORIGINAL FONT BY OXAR, ' .
'BACKGROUND BY AGENT-T CREAM, ' .
'INTRO MUSIC BY DMA-SC SECTOR ONE.' . $spc .

'AND NOW, SOME GREETING : FIRST, I WANT TO CONGRATULATE THE EDITORIAL STAFF OF ' .
'ST NEWS FOR THEIR GREAT ORGANIZATION OF THIS HISTORIC EVENT, HERE IN GOUDA. ' .
'MEGA-GREETINGS TO ALL THE PEOPLE WHO ARE ATTENDING THE DEMOPARTY, GUYS YOU ROCK ! ' .
'LAST BUT NOT LEAST, I\'D LIKE TO SEND A SPECIAL DEDICATION TO ULM THAT PRODUCED A DEMO ' .
'THAT ROCKED ME DURING MY TEENAGE YEARS.' . $spc .

'THIS DEMO WAS CODED ON HATARI EMULATOR, TESTED ON MY 520 STF+STE, BUT I WAS NOT ABLE TO TEST IT ' .
'INTENSIVELY ON LOT OF COMPUTERS, SORRY IF IT DOESN\'T RUN ON YOURS.' . $spc .

'IF YOU ASK YOURSELF IF SOMETHING IS PRECALCULATED IN THIS DEMO, OR FOR MORE INFORMATION, ' .
'PLEASE HAVE A LOOK AT THE OPEN-SOURCE CODE RELEASED WITH THE DEMO !' . $spc .

'REMEMBER THAT NOTHING IS IMPOSSIBLE TO THE ONE WHO DARES TO DREAM !' . $spc .

'IT\'S NOW TIME TO WRAP !' . $spc .

'DYNO, 19-12-2015' . $spc;

?>