##############################################################
# Name:        Matthew S. Jones
# Course:      AI 533: Intelligent Agents and Decision Making
# Instructor:  Dr. Sandya Saisubramanian
# Assignment:  Mini-project #2
# Due Date:    10 March 2025

my $implementation = $ARGV[0];

if ($implentation eq "S") {print "Implementation: Part A1, SARSA\n\n";}
elsif ($implentation eq "Ql") {print "Implementation: Part A2, Q-learning\n\n";}
elsif ($implentation eq "Sl") {print "Implementation: Part A3, SARSA(lambda)\n\n";}
elsif ($implentation eq "AC") {print "Implementation: Part B1, Actor-Critic\n\n";}
else {die "Invalid argument! Must be S, Ql, Sl, or AC.";}

my $gamma = 0.95;  # the discount factor
my $alpha = 0.5;   # the learning rate
my $epsilon = 0.4; # the exploration probability

print "Hyperparameters:\nGamma = $gamma\nAlpha = $alpha\nEpsilon = $epsilon\n\n";

# Define grid size, start state, and terminal state
my $max_x = 3;
my $max_y = 3;
my $start_x = 0;
my $start_y = 0;
my $terminal_x = 3;
my $terminal_y = 3;

my %states;
my %qvalues;

# Initialize states / rewards to default values
for (my $y = 0; $y <= $max_y; $y++) {for (my $x = 0; $x <= $max_x; $x++) {$states{$x}{$y}{'R'} = -1;}}

# Initialize fire states / rewards
for (my $y = 0; $y <= $max_y; $y++) {for (my $x = 0; $x <= $max_x; $x++) {$states{$x}{$y}{'F'} = 0;}}
$states{1}{0}{'F'} = 1;
$states{1}{0}{'R'} = -10;
$states{2}{0}{'F'} = 1;
$states{2}{0}{'R'} = -10;

# Initialize water states / rewards
for (my $y = 0; $y <= $max_y; $y++) {for (my $x = 0; $x <= $max_x; $x++) {$states{$x}{$y}{'W'} = 0;}}
$states{1}{2}{'W'} = 1;
$states{1}{2}{'R'} = -5;
$states{2}{2}{'W'} = 1;
$states{2}{2}{'R'} = -5;

# Initialize terminal states / rewards
for (my $y = 0; $y <= $max_y; $y++) {for (my $x = 0; $x <= $max_x; $x++) {$states{$x}{$y}{'T'} = 0;}}
$states{$terminal_x}{$terminal_y}{'T'} = 1;
$states{$terminal_x}{$terminal_y}{'R'} = 100;

# Initialize Q-values to zero
for (my $x = 0; $x <= $max_x; $x++) {for (my $y = 0; $y <= $max_y; $y++)
    {for (my $a = 0; $a <= 3; $a++) {$qvalues{$x}{$y}{$a} = 0;}}}

my $converged = 0;

while ($converged == 0) {
	
    my $x = $start_x;
    my $y = $start_y;
    my $at_terminal_state = 0;
    my $t = 0;

    while ($at_terminal_state == 0) {
	
        ($x, $y) = &take_action($x, $y, $states{$x}{$y}{'A'});
   
        if (($x == $terminal_x) && ($y == $terminal_y)) {$at_terminal_state = 1;}

    }
	
	$converged = &check_for_convergence();
	
}

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
    $rx = $x + 1; if ($rx > $max_x) {$rx = $max_x;}
    
    if ($rand_num > 0.9) {return ($lx, $y);}
    elsif ($rand_num > 0.8) {return ($rx, $y);}
    else {return ($x, $uy);}

}

sub right { # Returns the next state when going right
    
    my ($x, $y, $rand_num) = @_;
    
    $rx = $x + 1; if ($rx > $max_x) {$rx = $max_x;}
    $uy = $y - 1; if ($uy < 0) {$uy = 0;}
    $dy = $y + 1; if ($dy > $max_y) {$dy = $max_y;}
    
    if ($rand_num > 0.9) {return ($x, $dy);}
    elsif ($rand_num > 0.8) {return ($x, $uy);}
    else {return ($rx, $y);}

}

sub down { # Returns the next state when going down
    
    my ($x, $y, $rand_num) = @_;
    
    $dy = $y + 1; if ($dy > $max_y) {$dy = $max_y;}
    $lx = $x - 1; if ($lx < 0) {$lx = 0;}
    $rx = $x + 1; if ($rx > $max_x) {$rx = $max_x;}
    
    if ($rand_num > 0.9) {return ($rx, $y);}
    elsif ($rand_num > 0.8) {return ($lx, $y);}
    else {return ($x, $dy);}

}

sub left { # Returns the next state when going left
    
    my ($x, $y, $rand_num) = @_;
    
    $lx = $x - 1; if ($lx < 0) {$lx = 0;}
    $uy = $y - 1; if ($uy < 0) {$uy = 0;}
    $dy = $y + 1; if ($dy > $max_y) {$dy = $max_y;}
    
    if ($rand_num > 0.9) {return ($x, $dy);}
    elsif ($rand_num > 0.8) {return ($x, $uy);}
    else {return ($lx, $y);}

}