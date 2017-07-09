<?php
# +======================================================================+
# | Big Border Demo - Utility script                                     |
# +======================================================================+
# | Copyright (c) 2017 Frederic Poeydomenge <dyno@aldabase.com>          |
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

$gradient = __DIR__ . '/raster.png';

$source = imagecreatefrompng($gradient);
list($width, $height, $type, $attr) = getimagesize($gradient);

$bin = '';
for ($y = 0 ; $y < $height ; $y++) {
    $index = imagecolorat($source, 0, $y);
    $rgb   = imagecolorsforindex($source, $index);
    $r = round($rgb['red']   * 7 / 255, 0);
    $g = round($rgb['green'] * 7 / 255, 0);
    $b = round($rgb['blue']  * 7 / 255, 0);
    $bin .= pack('n', $r * 0x100 + $g * 0x10 + $b);
}

file_put_contents(__DIR__ . '/RASTER.DAT', $bin);

?>