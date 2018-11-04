#!/bin/bash
php image.php
convert -delay 25 -scale 200% test*.png sprite.gif

