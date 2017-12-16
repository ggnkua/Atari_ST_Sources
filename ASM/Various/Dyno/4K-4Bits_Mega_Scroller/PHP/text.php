<?php

$wait = '    ';

$text =

    '     ' .
    'HELLO EVERYBODY!' . $wait .
    'HERE COMES THE 4K 4-BITS MEGA SCROLLER.' . $wait .
    'HEY GUYS! TRY TO BEAT THIS!!!' . $wait .
    'THIS SCREEN WAS RELEASED FOR SILLYVENTURE 2K17.' . $wait .
    'CREDITS FOR THIS SCREEN :' . $wait .
        'CODE AND FONT BY DYNO.' . $wait .
        'MUSIC BY TAO FROM CREAM.' . $wait .
        'BACKGROUND BY SKYWALKER FROM EXO7.' . $wait .
    'THERE IS NO SPACE LEFT FOR THE GREETINGS SO...' . $wait .
    //'GREETINGS...' . $wait .    
    //    'ACF AENIGMATICA AGGRESSION ALIVE AL AVENA ' .
    //    'CPT DBUG DHS DF DMG DUNE EFT ELECTRA EQX ' .
    //    'EXO7 GIANTS HMD HOLOCAUST INVISIBLES LEGACY ' .
    //    'L16 MJJ MSB NEXT NOEX OMEGA OVR OXG PDZ PDX ' .
    //    'PENDRAGONS QX REPS RG SCT1 SMFX STAX STCNX ' .
    //    'STK SUPERIOR SYNC SYNERGY TCB TEX TLB ' .
    //    'TRB TOSCREW TRIO TSCC ULM WAB YMR' . $wait .
    'LET\'S WRAP!!!' . $wait;
    
$numTileX       = 16;
$numTileY       = 16;

$size = $argv[1];

switch($size) {
    case 'small':
        $mapFile    = 'text_map_small.tmx';
        $fontFile   = 'smfont';
        //$stripeFile = 'smstripe';
        //$letterFile = 'smletter';
        //$posFile    = 'smpos';
        break;
    case 'medium':
        $mapFile    = 'text_map_medium.tmx';
        $fontFile   = 'mdfont';
        //$stripeFile = 'mdstripe';
        //$letterFile = 'mdletter';
        //$posFile    = 'mdpos';
        break;
    case 'large':
        $mapFile    = 'text_map_large.tmx';
        $fontFile   = 'lgfont';
        //$stripeFile = 'lgstripe';
        //$letterFile = 'lgletter';
        //$posFile    = 'lgpos';
        break;
}

$textFile    = 'text';

/*==============================================================*/
/* Check that all the characters used are available in the font */
/*==============================================================*/

$allowed_chars = ' !"\'(),-.0123456789:ABCDEFGHIJKLMNOPQRSTUVWXYZ';

$error = array();
for ($c = 0 ; $c < strlen($text) ; $c++) {
    $char = $text[$c];
    if (strpos($allowed_chars, $char) === FALSE) {
        $error[] = (ord($char) < 32) ? 'chr(' . ord($char) . ') ' : $char . ' ';
    }
}
if (! empty($error)) {
    die(PHP_EOL . '[ERROR] Characters from $text not found in the font : ' . implode('', array_unique($error)) . PHP_EOL . PHP_EOL);
}

/*==============*/
/* Load Tilemap */
/*==============*/

$tilemap = file_get_contents(__DIR__ . '/' . $mapFile);

$xml = simplexml_load_string($tilemap);

$width  = $xml->layer['width'];
$height = $xml->layer['height'];
echo 'Map size : ', $width, 'x', $height, PHP_EOL;

/*==================================*/
/* Create an array [width x height] */
/*==================================*/

$i = 0;
$j = 0;
$array = array();

foreach ($xml->layer->data->tile AS $tile) {
    $array[$j][$i++] = (int) $tile['gid'];
    if ($i == $width) {
        $i = 0;
        $j++;
    }
}

/*===========================*/
/* Split for every character */
/*===========================*/

$empty = array(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
$whole_font = array(
    ' ' => array($empty, $empty, $empty, $empty, $empty, $empty, $empty, $empty)
);
for ($y = 0 ; $y < ($height / $numTileY) ; $y++) {
    for ($x = 0 ; $x < ($width / $numTileX) ; $x++) {
        $ascii = $y * ($width / $numTileX) + $x + 32;
        for ($i = 0 ; $i < $numTileX ; $i++) {
            $zero = 0;
            $tmp = array();
            for ($j = 0 ; $j < $numTileY ; $j++) {
                $val = $array[$y * $numTileY + $j][$x * $numTileX + $i];
                $zero += $val;
                $tmp[$j] = $val;
            }
            if ($zero > 0) {
                $whole_font[chr($ascii)][] = $tmp;
            }
        }
        if (count(@$whole_font[chr($ascii)]) > 0) {
            $c = count($whole_font[chr($ascii)]);
            $whole_font[chr($ascii)][$c - 1][15] += 128;
        }
    }
}

/*======================================*/
/* Store in font only needed characters */
/*======================================*/

$font = array();
for ($c = 0 ; $c < strlen($text) ; $c++) {
    $char = $text[$c];
    if (ord($char) >= 32) {
        $font[$char] = $whole_font[$char];
    }
}

/*========================*/
/* Stats for used STRIPES */
/*========================*/

if ($size == 'medium') {

    $statsStripes = array();
    foreach ($whole_font AS $char => $array) {
        foreach ($array AS $stripe) {
            $index = implode('-', $stripe);
            @$statsStripes[$index]++;
        }
    }

    $stats = array();
    $im = imagecreatetruecolor(2560, 1536);
    imagesavealpha($im, TRUE);
    imagefill($im, 0, 0, imagecolorallocatealpha($im, 0, 0, 0, 127));
    foreach ($whole_font AS $char => $array) {
        $pos_x = (ord($char) - 32) % 10;
        $pos_y = floor((ord($char) - 32) / 10);
        $w = 0;
        foreach ($array AS $stripe) {
            $index = implode('-', $stripe);
            if (3 <= $statsStripes[$index]) {
                @$stats[0]++;
                $color = imagecolorallocatealpha($im,   0, 255, 0, 64); // green
            } elseif (2 <= $statsStripes[$index]) {
                @$stats[1]++;
                $color = imagecolorallocatealpha($im, 255, 255, 0, 64); // orange
            } else {
                @$stats[2]++;
                $color = imagecolorallocatealpha($im, 255,   0, 0, 64); // red
            }
            $x1 = $pos_x * 256 + $w * 16;
            $y1 = $pos_y * 256;
            imagefilledrectangle ($im, $x1, $y1, $x1 + 16, $y1 + 16*16, $color);
            $w++;
        }
    }
    $color = imagecolorallocatealpha($im, 0, 0, 255, 0); // blue
    for ($c = 0 ; $c < strlen($text) ; $c++) {
        $char = $text[$c];
        $pos_x = (ord($char) - 32) % 10;
        $pos_y = floor((ord($char) - 32) / 10);
        $x1 = $pos_x * 256;
        $y1 = $pos_y * 256;
        for ($t = 0 ; $t < 2 ; $t++) { // thickness
            imagerectangle($im, $x1 + $t, $y1 + $t, $x1 + 256 - $t, $y1 + 256 - $t, $color);
        }
        imageline($im, $x1, $y1, $x1 + 256, $y1 + 256, $color);
        imageline($im, $x1 + 256, $y1, $x1, $y1 + 256, $color);
    }
    imagepng($im, __DIR__ . '/text_mask_medium.png');

    //echo 'Stats : ' . $stats[0] . ' good, ', $stats[1], ' intermediary, ', $stats[2], ' bad', PHP_EOL;

}

/*=======================*/
/* Compute STRIPES index */
/*=======================*/

$c = 0;
$stripesIdx = array();

foreach ($font AS $char => $array) {
    foreach ($array AS $stripe) {
        $index = implode('-', $stripe);
        if (! isset($stripesIdx[$index])) {
            $stripesIdx[$index] = $c++;
        }
    }
}

/*==========================================*/
/* Write xxSTRIPE.BIN and xxSTRIPE.JS files */
/*==========================================*/

$current = 0;
$bin = '';
$js = 'var stripe = [' . PHP_EOL;

foreach ($stripesIdx AS $index => $c) {
    if ($c != $current++) {
        die(PHP_EOL . '[ERROR] Stripe[' . $c . '] not well ordered' . PHP_EOL . PHP_EOL);
    }
    $values = explode('-', $index);
    if (count($values) != 16) {
        die(PHP_EOL . '[ERROR] Stripe[' . $c . '] does not contain 16 values (' . count($index) . ')' . PHP_EOL . PHP_EOL);
    }
    $js .= '  [';
    $sep = '';
    foreach ($values AS $value) {
        $bin .= pack('C', $value);
        $js .= $sep . substr('  ' . $value, -2);
        $sep = ',';
    }
    $js .= '],' . PHP_EOL;
}
$js .= '];' . PHP_EOL;

//file_put_contents(__DIR__ . '/../INC/' . strtoupper($stripeFile) . '.BIN', $bin);
//echo
//    'Written ' . strtoupper($stripeFile) . '.BIN, ',
//    count($stripesIdx), ' stripes, size=', (count($stripesIdx) * 16), PHP_EOL;
//file_put_contents(__DIR__ . '/../INC/' . strtolower($stripeFile) . '.js', $js);

/*=================*/
/* Compute STRIPES */
/*=================*/

$stripes = array();

foreach ($font AS $char => $array) {
    $stripes[$char] = array();
    if (! empty($array)) {
        foreach ($array AS $stripe) {
            $index = implode('-', $stripe);
            $stripe_id = $stripesIdx[$index];
            $stripes[$char][] = $stripe_id;
        }
    }
}

ksort($stripes);

/*==========================================*/
/* Write xxLETTER.BIN and xxLETTER.JS files */
/*==========================================*/

$posarray = array();
$pos = 0;
$bin = '';
$js = 'var letter = [' . PHP_EOL;
$cnt = 0;

for ($ascii = ord(' ') ; $ascii <= ord('Z') ; $ascii++) {
    $tmp = isset($stripes[chr($ascii)]) ? $stripes[chr($ascii)] : array();
    if (! empty($tmp)) {
        $posarray[] = $pos;
        $pos += count($tmp) + 1;
        $js .= '  /*' . chr($ascii) . '*/ ';
        foreach ($tmp AS $value) {
            $bin .= pack('C', $value);
            $js .= $value . ',';
            $cnt++;
        }
        $value = -1;
        $bin .= pack('C', $value);
        $js .= $value . ',';
        $js .= PHP_EOL;
        $cnt++;
    } else {
        $posarray[] = -1;
    }
}

$js .= '];' . PHP_EOL;

if (strlen($bin) % 2) {
    $bin .= chr(0);
}

//file_put_contents(__DIR__ . '/../INC/' . strtoupper($letterFile) . '.BIN', $bin);
//echo 'Written ' . strtoupper($letterFile) . '.BIN, ', $cnt, ' elements, size=', strlen($bin), PHP_EOL;
//file_put_contents(__DIR__ . '/../INC/' . strtolower($letterFile) . '.js', $js);

/*====================================*/
/* Write xxPOS.BIN and xxPOS.JS files */
/*====================================*/

$bin = '';
$js = 'var position = [' . PHP_EOL;
$ascii = 32;
foreach ($posarray AS $pos) {
    $bin .= pack('n', $pos);
    $js .= '  /*' . chr($ascii++) . '*/ ' . $pos . ',' . PHP_EOL;
}
$js .= '];' . PHP_EOL;

//file_put_contents(__DIR__ . '/../INC/' . strtoupper($posFile) . '.BIN', $bin);
//echo 'Written ' . strtoupper($posFile) . '.BIN, ', count($posarray), ' elements, size=', strlen($bin), PHP_EOL;
//file_put_contents(__DIR__ . '/../INC/' . strtolower($posFile) . '.js', $js);

/*==================================*/
/* Write TEXT.BIN and TEXT.JS files */
/*==================================*/

$js = 'var text = "' . str_replace(chr(10), '\n', $text) . '";' . PHP_EOL;
file_put_contents(__DIR__ . '/../INC/' . strtolower($textFile) . '.js', $js);

$text .= chr(0);
if (strlen($text) % 2) {
    $text .= chr(0);
}

for ($i = 0 ; $i < strlen($text) ; $i++) {
    if (ord($text[$i]) == 0) {
        $text[$i] = chr(0xFF);
    } else {
        $text[$i] = chr(ord($text[$i]) - 32);
    }
}

file_put_contents(__DIR__ . '/../INC/' . strtoupper($textFile) . '.BIN', $text);
echo 'Written ' . strtoupper($textFile) . '.BIN, size=', strlen($text), PHP_EOL;

/*======================================*/
/* Write xxFONT.BIN and xxFONT.JS files */
/*======================================*/

$bin = '';
$js = 'var font = [' . PHP_EOL;

for ($c = ord(' ') ; $c <= ord('Z') ; $c++) {

    $tmp = array_fill(0, 16*16, -1);
    if (isset($font[chr($c)])) {
        $current = 0;
        foreach ($font[chr($c)] AS $line) {
            foreach ($line AS $col) {
                $tmp[$current++] = $col;
            }
        }
    }

    $js .= '// CHR(' . $c . ')= ' . chr($c) . PHP_EOL;
    foreach ($tmp AS $char) {
        $js .= $char . ',';
        $bin .= pack('C', $char);
    }
    $js .= PHP_EOL;

}

$js .= '];' . PHP_EOL;

file_put_contents(__DIR__ . '/../INC/' . strtoupper($fontFile) . '.BIN', $bin);
echo 'Written ' . strtoupper($fontFile) . '.BIN, size=', strlen($bin), PHP_EOL;
file_put_contents(__DIR__ . '/../INC/' . strtolower($fontFile) . '.js', $js);

?>