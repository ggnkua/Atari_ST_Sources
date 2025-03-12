<?php
require('../includes/config.php');

$DBTableHits = "highscores_x2r";

date_default_timezone_set("Europe/Paris");

$map_id = str_replace($avant, $apres, $_GET['map_id']); if (strlen($map_id) > 56) { $map_id = substr($map_id, 0, 56); }

if (strlen($map_id) > 0)
{
  $link = mysqli_connect($DBHost, $DBUser, $DBPass, $DBName); mysqli_set_charset($link, "utf8");

  if ($link > 0)
  {
  	$avant = array (";", "\r\n", "\t");
  	$apres = array (",", "\\r\\n", "\\t");

  	$res = mysqli_query($link, "SELECT * FROM $DBTableHits WHERE map_id = '$map_id' ORDER BY score DESC LIMIT 100 ") or die (mysqli_error($link));

    $rank = 1;
  	while($col = mysqli_fetch_array($res))
  	{
  		echo $rank;
  		echo ";";
  		echo str_replace($avant, $apres, $col["score"]);
  		echo ";";
  		echo str_replace($avant, $apres, $col["nickname"]);
  		echo ";";
  		echo str_replace($avant, $apres, $col["location"]);
  		echo ";";
  		echo $col["version"];
  		echo ";";
  		echo date("m-d-Y H:i", strtotime($col["moment"]));
  		echo "\r\n";

  		$rank += 1;
    	}

  	mysqli_free_result($res);

  	mysqli_close($link);
  }
}

?>
