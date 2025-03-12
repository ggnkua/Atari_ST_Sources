<?php header('Content-type: text/html; charset=UTF-8'); ?>
<html>
<head>
<title>Atari ST Xenon 2 reloladed online highscores</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>

<body bgcolor="#ffffff" text="#000000" link="#0040B0" vlink="#0040B0" alink="#8888B0">
<center><table cellpadding="5" cellspacing="1" border="1">
<?php
require('../includes/config.php');

$DBTableMaps = "maps_x2r";
$DBTableHits = "highscores_x2r";

date_default_timezone_set("Europe/Paris");

$map_id = str_replace($avant, $apres, $_POST['map_id']); if (strlen($map_id) > 56) { $map_id = substr($map_id, 0, 56); }

$link = mysqli_connect($DBHost, $DBUser, $DBPass, $DBName); mysqli_set_charset($link, "utf8");

if ($link > 0)
{
  echo '<tr><td align="left" colspan="6"><nobr>';
  echo '<FORM METHOD="post" NAME="monformulaire" ACTION="index.php" ACCEPT-CHARSET="utf-8">';
  echo 'Map: <select name="map_id">';

  $res = mysqli_query($link, "SELECT * FROM $DBTableMaps ORDER BY name ASC ") or die (mysqli_error($link));

  while($col = mysqli_fetch_array($res))
  {
    if (strlen($map_id) < 1) { $map_id = $col["id"]; }

    echo '<option value="';
    echo $col["id"];
    echo '"';
    if ($col["id"] === $map_id) { echo ' selected';}
    echo '>';
    echo $col["name"];
    echo ' (';
    echo $col["version"];
    echo ') by ';
    echo $col["author"];
    echo '</option>';
    }
  echo '</select>';
  echo ' &nbsp; ';
  echo '<INPUT TYPE="submit" VALUE="Change">';
  echo "</nobr></td></tr>";

  mysqli_free_result($res);

  mysqli_close($link);
}

?>
<tr>
<th>Rank</th>
<th>Score</th>
<th>Nickname</th>
<th>Location</th>
<th>Version</th>
<th>Date</th>
</tr>
<?php

if (strlen($map_id) > 0)
{
  $link = mysqli_connect($DBHost, $DBUser, $DBPass, $DBName); mysqli_set_charset($link, "utf8");

  if ($link > 0)
  {
  	$res = mysqli_query($link, "SELECT * FROM $DBTableHits WHERE map_id = '$map_id' ORDER BY score DESC LIMIT 100 ") or die (mysql_error($link));

    $rank = 1;
  	while($col = mysqli_fetch_array($res))
  	{
  		echo "<tr><td align=\"right\"><nobr>";
  		echo $rank;
  		echo "</nobr></td><td align=\"right\"><nobr>";
  		echo $col["score"];
  		echo "</nobr></td><td align=\"left\"><nobr>";
  		echo $col["nickname"];
  		echo "</nobr></td><td align=\"left\"><nobr>";
  		echo $col["location"];
  		echo "</nobr></td><td align=\"left\"><nobr>";
  		echo $col["version"];
  		echo "</nobr></td><td align=\"left\"><nobr>";
  		echo date("m-d-Y H:i", strtotime($col["moment"]));
  		echo "</nobr></td></tr>";

  		$rank += 1;
    	}

    mysqli_free_result($res);

    mysqli_close($link);
  }
  else
  {
  	echo "no database connection";
  }
}

?></table></center></body>
</html>
