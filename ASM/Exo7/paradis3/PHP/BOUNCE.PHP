<?php
# +======================================================================+
# | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
# +----------------------------------------------------------------------+
# | Generate bounce values for scroller and background                   |
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

define('MAXLEN', 180);

$bounceFront = array();
$bounceBackg = array();
for ($i = 0 ; $i < MAXLEN ; $i += 4.2) {
    $angle = deg2rad($i);
    $bounceFront[] = floor(abs(18.1 * sin($angle)));
    $bounceBackg[] = floor(abs(30.1 * sin($angle)));
}

$txt = $bin = '';
$c = 0;
foreach ($bounceFront AS $item) {
    $value = $item * 230;
    $txt .= "\t" . 'dc.w ' . $value . "\t" . '; ' . $item . "\r\n";
    $bin .= pack('n', $value);
}

file_put_contents(__DIR__ . '/../INC/BOUNCESC.S', $txt);
file_put_contents(__DIR__ . '/../INC/BOUNCESC.BIN', $bin);

$txt = $bin = '';
$c = 0;
foreach ($bounceBackg AS $item) {
    $value = $item * 32;
    $txt .= "\t" . 'dc.w ' . $value . "\t" . '; ' . $item . "\r\n";
    $bin .= pack('n', $value);
}

file_put_contents(__DIR__ . '/../INC/BOUNCEBG.S', $txt);
file_put_contents(__DIR__ . '/../INC/BOUNCEBG.BIN', $bin);

?>