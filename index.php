<?php 

$dbcfg = include('config.php');
$con=mysqli_connect($dbcfg['hostname'],$dbcfg['username'],$dbcfg['password'],$dbcfg['database']);
if (mysqli_connect_errno())
{
echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

if ($_POST['showreal'] == "true") {
	$result = mysqli_query($con,"SELECT * FROM results WHERE aid_drivingline = 'false' AND aid_clutch = 'false' AND aid_gears = 'false' AND aid_brakes = 'false'  AND aid_steering = 'false' AND aid_dmg = 'false' ORDER BY lap_time;");
} else {
	$result = mysqli_query($con,"SELECT * FROM results res JOIN ( SELECT steamid, car_id, MIN(lap_time) AS min_lap_time FROM results GROUP BY steamid, car_id ) grouped_res ON res.steamid = grouped_res.steamid AND res.car_id = grouped_res.car_id AND res.lap_time = grouped_res.min_lap_time");
}

echo '<head>
<link rel=\'stylesheet\' type=\'text/css\' href=\'css/pcars-stats.css\'>
<script src=\'js/list.min.js\'    type=\'text/javascript\'></script>
</head>
<body>';

echo '<div id="results">
<table><tr>
<button class="sort" data-sort="name">Name</button>
<button class="sort" data-sort="car">Car</button>
<button class="sort" data-sort="carclass">Class</button>
<button class="sort" data-sort="laptime">Lap Time</button>
<button class="sort" data-sort="sector1">Sector 1</button>
<button class="sort" data-sort="sector2">Sector 2</button>
<button class="sort" data-sort="sector3">Sector 3</button>
<button class="sort" data-sort="date">Date</button>
</tr>';

echo '<tr>';
if ($_POST['showreal'] == "true") {
echo '<form action="index.php" method="post">
    <input type="hidden" name="showreal" value="false" />
    <input type="submit" name="submit" value="All Driving Aids" />
</form>';
} else {
echo '<form action="index.php" method="post">
    <input type="hidden" name="showreal" value="true" />
    <input type="submit" name="submit" value="Real Driving Aids" />
</form>';
}

echo '<input class="search" placeholder="Filter" />

</tr>
</table>';

echo '<table><tbody class="list"><tr class=\'top\'><td>Name</td><td>Car</td><td>Class</td><td>Lap Time</td><td>Sector 1</td><td>Sector 2</td><td>Sector 3</td><td>Date</td><td>Controls</td><td>Setup</td><td>Aids</td></tr>';

while($row = mysqli_fetch_array($result))
{
echo "<tr>";
echo "<td class='name'><a href=\"https://steamcommunity.com/profiles/" . $row['steamid'] . "\">" . $row['name'] . "</td>";
echo "<td class='car'>" . $row['car_name'] . "</td>";
echo "<td class='carclass'>" . $row['car_class'] . "</td>";
echo "<td class='laptime'>" . $row['lap_time_converted'] . "</td>";
echo "<td class='sector1'>" . $row['sector_1_time_converted'] . "</td>";
echo "<td class='sector2'>" . $row['sector_2_time_converted'] . "</td>";
echo "<td class='sector3'>" . $row['sector_3_time_converted'] . "</td>";
echo "<td class='date'>" . $row['event_time_converted'] . "</td>";

echo "<td class='controls'>";
if ($row['controls'] == "wheel") {
        echo '<img src="img/wheel.png" alt="Wheel" height="24" width="24">';
} else if ($row['controls'] == "gamepad") {
        echo '<img src="img/gamepad.png" alt="Gamepad" height="24" width="24">';
}
echo "</td>";

echo "<td class='own_setup'>";
if ($row['own_setup'] == "true") {
        echo '<img src="img/checkmark.png" alt="Own Setup" height="24" width="24">';
}
echo "</td>";

echo "<td>";
if ($row['aid_drivingline'] == "true") {
	echo '<img src="img/road.png" alt="Driving Line" height="24" width="24">';
}

if ($row['aid_clutch'] == "true") {
        echo '<img src="img/clutch.png" alt="Auto Clutch" height="24" width="24">';
}

if ($row['aid_gears'] == "true") {
        echo '<img src="img/gears.png" alt="" height="24" width="24">';
}

if ($row['aid_brakes'] == "true") {
        echo '<img src="img/brakes.png" alt="Braking" height="24" width="24">';
}

if ($row['aid_steering'] == "true") {
        echo '<img src="img/steering.png" alt="Steering" height="24" width="24">';
}

if ($row['aid_dmg'] == "true") {
        echo '<img src="img/damage.png" alt="No DMG" height="24" width="24">';
}

if ($row['aid_stability'] == "true") {
        echo '<img src="img/stability.png" alt="Stability Control" height="24" width="24">';
}

if ($row['aid_traction'] == "true") {
        echo '<img src="img/traction.png" alt="Traction Control" height="24" width="24">';
}

if ($row['aid_abs'] == "true") {
        echo '<img src="img/abs.png" alt="ABS" height="24" width="24">';
}

echo "</td>";


echo "</tr>";
}
echo '</tbody>
</table>
</div>

<div id="show"></div>

<script>
var options = { valueNames: [ \'name\', \'car\', \'carclass\', \'laptime\', \'sector1\', \'sector2\', \'sector3\', \'date\' ] };
var resultsList = new List(\'results\', options);
</script>';

echo '<script>
var myImage = document.getElementsByTagName("img");
var text = document.getElementById("show");

for (var i = 0; i < myImage.length; i++) {
    myImage[i].addEventListener(\'click\',show);
}

function show(){
    var myAlt = this.alt;
    text.innerHTML = myAlt;
}
</script>';

mysqli_close($con);

?>

