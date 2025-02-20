##############################################################
# Name:        Matthew S. Jones
# Course:      AI 533: Intelligent Agents and Decision Making
# Instructor:  Dr. Sandya Saisubramanian
# Assignment:  Mini-project #2
# Due Date:    TBD 2025

use strict;

my $gamma = $ARGV[0];
my $epsilon = 0.1;

# Used to round the values to one SD more than epsilon
my $vallen = 0;
if ($epsilon =~ /^\d*\.(\d*)$/) {$vallen = length($1) + 1;}
my $expr = "%.".$vallen."f";

print "Gamma = $gamma\nEpsilon = $epsilon\n";

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

# x, y, 'A' = action in (x,y)
for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {$states{$x}{$y}{'A'} = "";}}

# x, y, t = value at t
for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {$states{$x}{$y}{0} = 0;}}

# Run with initial values of 0
$t = &converge();
&make_table(0, $t);

# Run $ARG more times with random initial values 
&run_random(0);

exit(0);


sub run_random {

    my $cmax = $_[0];

    my $min = -10;
    my $max = 100;
    
    for (my $c = 1; $c <= $cmax; $c++) {

        # x, y, 'A' = action in (x,y)
        for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {$states{$x}{$y}{'A'} = "";}}

        # x, y, t = value 
        for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++)
            {$states{$x}{$y}{0} = int(rand($max - $min + 1)) + $min;}}

        $t = &converge();
        &make_table($c, $t);
    
    }
}

sub converge {
    
    my $converged = 0;
    my $t = 0;

    # Loop until convergence
    while ($converged == 0) {
    
        $t++;

        for (my $x = 0; $x <= 3; $x++) {for (my $y = 0; $y <= 3; $y++) {

            # Gets the expected value for each direction        
            my $u = &up($x,$y,$t);
            my $r = &right($x,$y,$t);
            my $d = &down($x,$y,$t);
            my $l = &left($x,$y,$t);
            
            # Makes "up" the max by default, then checks the others
            my $max = $u;
            my $a = "1";
            
            if ($l > $max) {$max = $l; $a = "0";}
            if ($d > $max) {$max = $d; $a = "3";}
            if ($r > $max) {$max = $r; $a = "2";}

            # Rounds the number to one SD more than epsilon 
            $states{$x}{$y}{$t} = sprintf($expr, $max);
			
            # Fix the reward value at the terminal state
            if (($x == 3) && ($y == 3)) {$states{$x}{$y}{$t} = $states{$x}{$y}{'R'};}
                
            # Announces a policy change before updating the action at a given state 
            $states{$x}{$y}{'A'} = $a;
            
        }}
    
        $converged = &convergence_check($t);
    
    }

    print "\nConverged at t=$t\n";

    print "V0: ";
    for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {print "$states{$x}{$y}{0}";
        if ($x < 3) {print ",";}} if ($y < 3) {print ";";}} print "\n";
        
    print "V$t: ";
    for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {print "$states{$x}{$y}{$t}";
        if ($x < 3) {print ",";}} if ($y < 3) {print ";";}} print "\n";
        
    print "Policy: ";
    for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {print "$states{$x}{$y}{'A'}";
        if ($x < 3) {print ",";}} if ($y < 3) {print ";";}} print "\n";
        
    return $t;
    
}

sub make_table { # Print convergence table to a file

    my $num = $_[0];
    my $t = $_[1];
    my $file = ">mp1a2_g".$gamma."_v".$num.".csv";
    
    open(OUT,$file);

    print OUT "States,A,R";
    for (my $i = 0; $i <= $t; $i++) {print OUT ",V$i";}
    print OUT "\n";

    for (my $x = 0; $x <= 3; $x++) {for (my $y = 0; $y <= 3; $y++) {
            
        print OUT "\"($x,$y,$states{$x}{$y}{'W'},$states{$x}{$y}{'F'})\",";
        print OUT "$states{$x}{$y}{'A'},$states{$x}{$y}{'R'}";
        
        for (my $i = 0; $i <= $t; $i++) {print OUT ",$states{$x}{$y}{$i}";}
        
        print OUT "\n";
            
    }}

    print OUT "gamma,$gamma\n";
    print OUT "epsilon,$epsilon\n";
    print OUT "Converged,$t\n";

    print OUT "Policy:\n";
    for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {print OUT "$states{$x}{$y}{'A'}";
        if ($x < 3) {print OUT ",";}} print OUT "\n";}
        
    close(OUT);
    
}

sub up { # Returns the expected value of going up
    
    my ($x, $y, $t) = @_;
    
    $uy = $y - 1; if ($uy < 0) {$uy = 0;}
    $lx = $x - 1; if ($lx < 0) {$lx = 0;}
    $rx = $x + 1; if ($rx > 3) {$rx = 3;}
    
    return $states{$x}{$y}{'R'} + $gamma *
        (0.8 * $states{$x}{$uy}{$t-1} + 0.1 * $states{$lx}{$y}{$t-1} + 0.1 * $states{$rx}{$y}{$t-1});

}

sub right { # Returns the expected value of going right
    
    my ($x, $y, $t) = @_;
    
    $rx = $x + 1; if ($rx > 3) {$rx = 3;}
    $uy = $y - 1; if ($uy < 0) {$uy = 0;}
    $dy = $y + 1; if ($dy > 3) {$dy = 3;}
    
    return $states{$x}{$y}{'R'} + $gamma *
        (0.8 * $states{$rx}{$y}{$t-1} + 0.1 * $states{$x}{$uy}{$t-1} + 0.1 * $states{$x}{$dy}{$t-1});
    
}

sub down { # Returns the expected value of going down
    
    my ($x, $y, $t) = @_;
    
    $dy = $y + 1; if ($dy > 3) {$dy = 3;}
    $lx = $x - 1; if ($lx < 0) {$lx = 0;}
    $rx = $x + 1; if ($rx > 3) {$rx = 3;}
    
    return $states{$x}{$y}{'R'} + $gamma *
        (0.8 * $states{$x}{$dy}{$t-1} + 0.1 * $states{$lx}{$y}{$t-1} + 0.1 * $states{$rx}{$y}{$t-1});
    
}

sub left { # Returns the expected value of going left
    
    my ($x, $y, $t) = @_;
    
    $lx = $x - 1; if ($lx < 0) {$lx = 0;}
    $uy = $y - 1; if ($uy < 0) {$uy = 0;}
    $dy = $y + 1; if ($dy > 3) {$dy = 3;}
    
    return $states{$x}{$y}{'R'} + $gamma *
        (0.8 * $states{$lx}{$y}{$t-1} + 0.1 * $states{$x}{$uy}{$t-1} + 0.1 * $states{$x}{$dy}{$t-1});
    
}

sub convergence_check { # Determines whether the values have converged to within epsilon
    
    my $time = $_[0];
    my $converged = 1;
    
    for (my $x = 0; $x <= 3; $x++) {for (my $y = 0; $y <= 3; $y++)
        {if (abs($states{$x}{$y}{$time} - $states{$x}{$y}{$time-1}) > $epsilon) {$converged = 0;}}}
    
    return $converged;
    
}
