<?php

require("../includes/config.php");

$DBTableMaps = "maps_x2r";
$DBTableHits = "highscores_x2r";

date_default_timezone_set("Europe/Paris");

$avant = array ("'");
$apres = array (" ");

$score = intval($_POST['score']);
$key = intval($_POST['key']);
$nickname = str_replace($avant, $apres, $_POST['nickname']); if (strlen($nickname) > 56) { $nickname = substr($nickname, 0, 56); }
$location = str_replace($avant, $apres, $_POST['location']); if (strlen($location) > 56) { $location = substr($location, 0, 56); }
$version = str_replace($avant, $apres, $_POST['version']); if (strlen($version) > 56) { $version = substr($version, 0, 56); }
$map_id = str_replace($avant, $apres, $_POST['map_id']); if (strlen($map_id) > 56) { $map_id = substr($map_id, 0, 56); }
$map_name = str_replace($avant, $apres, $_POST['map_name']); if (strlen($map_name) > 56) { $map_name = substr($map_name, 0, 56); }
$map_author = str_replace($avant, $apres, $_POST['map_author']); if (strlen($map_author) > 56) { $map_author = substr($map_author, 0, 56); }
$map_version = str_replace($avant, $apres, $_POST['map_version']); if (strlen($map_version) > 56) { $map_version = substr($map_version, 0, 56); }
$magic = $_POST['magic'];

if (($magic === "xenon2gem") && (strlen($nickname) > 0) && ($score > 0) && (strlen($map_id) > 0))
{
	$link = mysqli_connect($DBHost, $DBUser, $DBPass, $DBName); mysqli_set_charset($link, "utf8");

	if ($link > 0)
	{
		$res = mysqli_query($link, "SELECT id FROM $DBTableMaps WHERE id = '$map_id' ") or die (mysqli_error($link));

		$nombre = mysqli_num_rows($res);

		mysqli_free_result($res);

		if ($nombre == 1)
	  {
	    $exe = mysqli_query($link, "UPDATE $DBTableMaps SET name = '$map_name', version = '$map_version', author = '$map_author' WHERE id = '$map_id' ") or die (mysqli_error($link));
	  }
	  else if ($nombre == 0)
	  {
	    $exe = mysqli_query($link, "INSERT INTO $DBTableMaps (id, name, version, author) VALUES ('$map_id', '$map_name', '$map_version', '$map_author') ") or die (mysqli_error($link));
		}

		if ($exe)
		{
			$res = mysqli_query($link, "SELECT clef FROM $DBTableHits WHERE nickname = '$nickname' AND clef = $key AND map_id = '$map_id' ") or die (mysqli_error($link));

			$nombre = mysqli_num_rows($res);

			mysqli_free_result($res);

		  if ($nombre == 1)
		  {
		    $exe = mysqli_query($link, "UPDATE $DBTableHits SET score = $score, location = '$location', version = '$version' WHERE nickname = '$nickname' AND clef = $key AND map_id = '$map_id' AND score < $score ") or die (mysqli_error($link));
		  }
		  else if ($nombre == 0)
		  {
		    $exe = mysqli_query($link, "INSERT INTO $DBTableHits (score, nickname, location, version, clef, map_id) VALUES ($score, '$nickname', '$location', '$version', $key, '$map_id') ") or die (mysqli_error($link));
			}

			if ($exe) { echo "OK"; } else { echo "UNCHANGED"; }
		}
		else
		{
			echo "FAILED";
		}

		mysqli_close($link);
	}
	else
	{
		echo "FAILED";
	}
}
else
{
	echo "FAILED";
}
echo "\r\n";
?>
