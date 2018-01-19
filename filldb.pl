#!/usr/bin/perl
use strict;
use warnings;

use JSON;
use Data::Dumper;
use POSIX qw{strftime};
use utf8;
use Encode;
use DBI;
use DBD::mysql;

# Config
my $min_lap_time = 60; # Minimum laptime in seconds

# DBI CONFIG VARIABLES
my $sqlhost = "localhost";
my $sqldatabase = "pcars";
my $sqluser = "pcars";
my $sqlpw = "password";

sub converttime { 
	my $input = int(shift);
	my $milliseconds = $input % 1000;
	$input = $input / 1000;
	my $seconds = $input % 60;
	$input = $input / 60;
	my $minutes = $input;
	return(sprintf("%d:%02d.%03d", $minutes, $seconds, $milliseconds));
}

sub convertplayersetup {
	my $setupid = shift;
	my $setup;
	my $control_set = 'false';
	my $model_set = 'false';

	my $controler;
	my $aid_drivingline = 'false';
	my $aid_clutch = 'false';
        my $aid_gears = 'false';
        my $aid_dmg = 'false';
        my $aid_stability = 'false';
        my $aid_traction = 'false';
        my $aid_abs = 'false';
        my $aid_braking = 'false';
        my $aid_steering = 'false';
        my $own_setup = 'false';

        # Remove verification
        $setupid = $setupid - 1073741824;

	# Aid: Drivingline
	if ($setupid > 32767) {
		$setupid = $setupid - 32768;
		$aid_drivingline = 'true';
	}

        # Model: Mask
        if (($model_set eq 'false') && ($setupid > 14335)) {
                $setupid = $setupid - 14336;
        }

        # Model: Elite
        if (($model_set eq 'false') && ($setupid > 8191)) {
                $setupid = $setupid - 8192;
        }

        # Model: Pro
        if (($model_set eq 'false') && ($setupid > 6143)) {
                $setupid = $setupid - 6144;
        }

        # Model: Experienced
        if (($model_set eq 'false') && ($setupid > 4095)) {
                $setupid = $setupid - 4096;
        }

        # Model: Normal
        if (($model_set eq 'false') && ($setupid > 2047)) {
                $setupid = $setupid - 2048;
        }

        # Aid: Auto Clutch
        if ($setupid > 1023) {
		$setupid = $setupid - 1024;
		$aid_clutch = 'true';
        }

        # Aid: Auto Gears
        if ($setupid > 511) {
                $setupid = $setupid - 512;
                $aid_gears = 'true';
        }

        # Aid: No Damage
        if ($setupid > 255) {
                $setupid = $setupid - 256;
                $aid_dmg = 'true';
        }

        # Aid: Stability
        if ($setupid > 127) {
                $setupid = $setupid - 128;
                $aid_stability = 'true';
        }

        # Aid: Traction
        if ($setupid > 63) {
                $setupid = $setupid - 64;
                $aid_traction = 'true';
        }

        # Aid: ABS
        if ($setupid > 31) {
                $setupid = $setupid - 32;
                $aid_abs = 'true';
        }

        # Aid: Braking
        if ($setupid > 15) {
                $setupid = $setupid - 16;
                $aid_braking = 'true';
        }

        # Aid: Steering
        if ($setupid > 7) {
                $setupid = $setupid - 8;
                $aid_steering = 'true';
        }

        # Controller: Mask
        if (($control_set eq 'false') && ($setupid > 5)) {
                $setupid = $setupid - 6;
                $controler = 'mask';
        }

        # Controller: Wheel
        if (($control_set eq 'false') && ($setupid > 3)) {
                $setupid = $setupid - 4;
                $controler = 'wheel';
        }

        # Controller: Gamepad
        if (($control_set eq 'false') && ($setupid > 1)) {
                $setupid = $setupid - 2;
                $controler = 'gamepad';
        }

        # Used own Setup
        if ($setupid == 1) {
                $setupid = $setupid - 1;
                $own_setup = 'true';
        }

	if (!$controler) {
		$controler = 'none';
	}

	# Check if remaining flagsize is 0 now
	if ($setupid == 0) {
		return ($controler,$aid_drivingline,$aid_clutch,$aid_gears,$aid_dmg,$aid_stability,$aid_traction,$aid_abs,$aid_braking,$aid_steering,$own_setup);
	}
}

my $dsn = "dbi:mysql:$sqldatabase:localhost:3306";
my $dbh = DBI->connect($dsn, $sqluser, $sqlpw);
my $sth = $dbh->prepare("INSERT INTO results (id, steamid, name, car_id, car_name, car_class, event_time, event_time_converted, lap_time, lap_time_converted, sector_1_time, sector_1_time_converted, sector_2_time, sector_2_time_converted, sector_3_time, sector_3_time_converted, controls, aid_drivingline, aid_clutch, aid_gears, aid_dmg, aid_stability, aid_traction, aid_abs, aid_brakes, aid_steering, own_setup) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? , ?, ?, ?, ?, ?)");


# Read vehicles json
my $vehiclejsonstring;
{
  local $/;
  open my $fh, "<", "vehicles.json";
  $vehiclejsonstring = <$fh>;
  close $fh;
}
my $vehiclejsonhash = decode_json($vehiclejsonstring);
my @vehicles = @{ $vehiclejsonhash->{'response'}->{'list'} };

# Read stats json
my $jsonstring;
{
  local $/;
  open my $fh, "<", "sms_stats_data.json";
  $jsonstring = <$fh>;
  close $fh;
}

# Remove first two lines and EOF
$jsonstring =~ s/^\/\/ Persistent data for addon 'sms_stats', addon version 2.0//g;
$jsonstring =~ s/\/\/ Automatically maintained by the addon, do not edit!//g;
$jsonstring =~ s/\/\/ EOF \/\///g;

# Remove Unicode
$jsonstring =~ s/[^[:ascii:]]//g;

# Remove empty/broken events and results arrays
$jsonstring =~ s/"events" : \{\},//g;
$jsonstring =~ s/"results" : \{\},//g;

# Encode UTF8
my $octets = encode("utf8", $jsonstring, Encode::FB_DEFAULT);
my $utf8string = decode("utf8", $octets, Encode::FB_DEFAULT);

# Decode JSON to Hash
my $jsonhash = decode_json($utf8string);

# Define a few things...
my $stats = $jsonhash->{'stats'};
my $servername = $jsonhash->{'stats'}->{'server'}->{'name'};
my $serveruptime = int($jsonhash->{'stats'}->{'server'}->{'uptime'} / 60 / 60);
my $totalserveruptime = int($jsonhash->{'stats'}->{'server'}->{'total_uptime'} / 60 / 60);
my @history = @{ $jsonhash->{'stats'}->{'history'} };
my $id = 0;

# Venture thru the History
foreach my $f ( @history ) {
	if (!$f->{'stages'}->{'practice1'}) { next; } # Whoops! We only track practice for now!
	my @members = $f->{'members'};
	if (!$f->{'stages'}->{'practice1'}->{'events'}) { next; } # No events during that session...
	my @events = @{ $f->{'stages'}->{'practice1'}->{'events'} };

	# Look for LapTime events
	foreach my $e (@events) {
		if ($e->{'event_name'} eq 'Lap') { # We have a Lap
			my $starttime = $e->{'time'};
			my $starttime_converted = scalar localtime($starttime);
			my @attributes = $e->{'attributes'};

			foreach my $a (@attributes) {
				if ($a->{'CountThisLapTimes'} == 1) { # And we count it!
					# More defines here
					$id++;
					my $steamID;
					my $carID;
					my $carname;
					my $carclass;
					my $flags;
					my $racer_name = $e->{'name'};
					my $lap_time_converted = &converttime($a->{'LapTime'});
					my $lap_time = $a->{'LapTime'};
					my $sector_1_time_converted = &converttime($a->{'Sector1Time'});
					my $sector_1_time = $a->{'Sector1Time'};
					my $sector_2_time_converted = &converttime($a->{'Sector2Time'});
                                        my $sector_2_time = $a->{'Sector1Time'};
					my $sector_3_time_converted = &converttime($a->{'Sector3Time'});
                                        my $sector_3_time = $a->{'Sector1Time'};
					my $refID = $e->{'refid'};

					# Drop obvious cheaters
					if ($lap_time < ($min_lap_time * 1000)) { next; }

					# Read from @members and get carID
					foreach my $m (@members) {
						$steamID = $m->{"$refID"}->{'steamid'};
						$carID = $m->{"$refID"}->{'setup'}->{'VehicleId'};
						$flags = $m->{"$refID"}->{'setup'}->{'RaceStatFlags'};
					}

					# Check carID against @vehicles
					foreach my $c (@vehicles) {
						if ($carID == $c->{id}) {
							$carname = $c->{'name'};
							$carclass = $c->{'class'};
						}
					}

					# Get the players setup
					my ($controler,$aid_drivingline,$aid_clutch,$aid_gears,$aid_dmg,$aid_stability,$aid_traction,$aid_abs,$aid_braking,$aid_steering,$own_setup) = &convertplayersetup($flags);

					$sth->execute($id, $steamID, $racer_name, $carID, $carname, $carclass, $starttime, $starttime_converted, $lap_time, $lap_time_converted, $sector_1_time, $sector_1_time_converted, $sector_2_time, $sector_2_time_converted, $sector_3_time, $sector_3_time_converted, $controler, $aid_drivingline, $aid_clutch, $aid_gears, $aid_dmg, $aid_stability, $aid_traction, $aid_abs, $aid_braking, $aid_steering, $own_setup);
				}
			}
		}
	}
}

