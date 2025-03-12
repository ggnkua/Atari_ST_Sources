<?php
require('../includes/config.php');

$DBTableMaps = "maps_x2r";

date_default_timezone_set("Europe/Paris");

$link = mysqli_connect($DBHost, $DBUser, $DBPass, $DBName); mysqli_set_charset($link, "utf8");

if ($link > 0)
{
	$avant = array (";", "\r\n", "\t");
	$apres = array (",", "\\r\\n", "\\t");

	$res = mysqli_query($link, "SELECT * FROM $DBTableMaps ORDER BY name ") or die (mysqli_error($link));

	while($col = mysqli_fetch_array($res))
	{
		echo str_replace($avant, $apres, $col["id"]);
		echo ";";
		echo str_replace($avant, $apres, $col["name"]);
		echo ";";
		echo str_replace($avant, $apres, $col["version"]);
		echo ";";
    echo str_replace($avant, $apres, $col["author"]);
		echo "\r\n";
  	}

	mysqli_free_result($res);

	mysqli_close($link);
}
?>
