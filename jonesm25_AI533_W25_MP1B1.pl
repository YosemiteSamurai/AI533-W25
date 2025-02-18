##############################################################
# Name:        Matthew S. Jones
# Course:      AI 533: Intelligent Agents and Decision Making
# Instructor:  Dr. Sandya Saisubramanian
# Assignment:  Mini-project #1, Part B1 (Policy Simulation)
# Due Date:    10 February 2025

my $gamma = 0.95;

print "Gamma = $gamma\n";

my %states;

# x, y, 'R' = reward
for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {$states{$x}{$y}{'R'} = -1;}}
$states{1}{0}{'R'} = -10;
$states{2}{0}{'R'} = -10;
$states{1}{2}{'R'} = -5;
$states{2}{2}{'R'} = -5;
$states{3}{3}{'R'} = 100;

# x, y, 'F' = fire
for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {$states{$x}{$y}{'F'} = 0;}}
$states{1}{0}{'F'} = 1;
$states{2}{0}{'F'} = 1;

# x, y, 'W' = water
for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {$states{$x}{$y}{'W'} = 0;}}
$states{1}{2}{'W'} = 1;
$states{2}{2}{'W'} = 1;

# Optimum Policy: 3,3,2,3;3,2,2,3;3,3,2,3;2,2,2,0
# x, y, 'OP' = optimum policy action in (x,y): Initialize action to the policy from A2
for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {$states{$x}{$y}{'A'} = 3;}}
$states{2}{0}{'A'} = 2;
$states{2}{1}{'A'} = 2;
$states{2}{2}{'A'} = 2;
$states{2}{3}{'A'} = 2;
$states{1}{1}{'A'} = 2;
$states{1}{3}{'A'} = 2;
$states{0}{3}{'A'} = 2;
$states{3}{3}{'A'} = 0;

print "Optimum Policy: ";
for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {print "$states{$x}{$y}{'A'}";
    if ($x < 3) {print ",";}} if ($y < 3) {print ";";}} print "\n\n";

my $x = 0;
my $y = 0;

my %traj;
my $t = 0;
my $done = 0;

while ($done == 0) {
	
    # print "$t\n";

    $traj{$t}{'x'} = $x;
    $traj{$t}{'y'} = $y;
    $traj{$t}{'A'} = $states{$x}{$y}{'A'};
    $traj{$t}{'R'} = sprintf("%.2f", ($gamma**$t)*$states{$x}{$y}{'R'});

    ($x, $y) = &take_action($x, $y, $states{$x}{$y}{'A'});

    $t++;
   
    if (($x == 3) && ($y == 3)) {$done = 1;}

}

$traj{$t}{'x'} = $x;
$traj{$t}{'y'} = $y;
$traj{$t}{'A'} = $states{$x}{$y}{'A'};
$traj{$t}{'R'} = sprintf("%.2f", ($gamma**$t)*$states{$x}{$y}{'R'});

foreach my $t (sort {$a <=> $b} keys %traj)
    {print "t=$t: ($traj{$t}{'x'},$traj{$t}{'y'},$traj{$t}{'A'},$traj{$t}{'R'})\n";}

exit(0);


sub take_action { # returns the next state for a given state/action pair
    
    my ($x, $y, $a) = @_;
    my ($xp, $yp); # (x',y')
    
    $rand_num = rand(1); # random number between 0 and 1
    
    if ($a == 0) {($xp, $yp) = &left($x, $y, $rand_num);}
    elsif ($a == 1) {($xp, $yp) = &up($x, $y, $rand_num);}
    elsif ($a == 2) {($xp, $yp) = &right($x, $y, $rand_num);}
    elsif ($a == 3) {($xp, $yp) = &down($x, $y, $rand_num);}
    
    return ($xp, $yp);
    
}

sub up { # Returns the next state when going up
    
    my ($x, $y, $rand_num) = @_;
    
    $uy = $y - 1; if ($uy < 0) {$uy = 0;}
    $lx = $x - 1; if ($lx < 0) {$lx = 0;}
    $rx = $x + 1; if ($rx > 3) {$rx = 3;}
    
    if ($rand_num > 0.9) {return ($lx, $y);}
    elsif ($rand_num > 0.8) {return ($rx, $y);}
    else {return ($x, $uy);}

}

sub right { # Returns the next state when going right
    
    my ($x, $y, $rand_num) = @_;
    
    $rx = $x + 1; if ($rx > 3) {$rx = 3;}
    $uy = $y - 1; if ($uy < 0) {$uy = 0;}
    $dy = $y + 1; if ($dy > 3) {$dy = 3;}
    
    if ($rand_num > 0.9) {return ($x, $dy);}
    elsif ($rand_num > 0.8) {return ($x, $uy);}
    else {return ($rx, $y);}

}

sub down { # Returns the next state when going down
    
    my ($x, $y, $rand_num) = @_;
    
    $dy = $y + 1; if ($dy > 3) {$dy = 3;}
    $lx = $x - 1; if ($lx < 0) {$lx = 0;}
    $rx = $x + 1; if ($rx > 3) {$rx = 3;}
    
    if ($rand_num > 0.9) {return ($rx, $y);}
    elsif ($rand_num > 0.8) {return ($lx, $y);}
    else {return ($x, $dy);}

}

sub left { # Returns the next state when going left
    
    my ($x, $y, $rand_num) = @_;
    
    $lx = $x - 1; if ($lx < 0) {$lx = 0;}
    $uy = $y - 1; if ($uy < 0) {$uy = 0;}
    $dy = $y + 1; if ($dy > 3) {$dy = 3;}
    
    if ($rand_num > 0.9) {return ($x, $dy);}
    elsif ($rand_num > 0.8) {return ($x, $uy);}
    else {return ($lx, $y);}

}