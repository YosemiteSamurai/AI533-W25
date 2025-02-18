##############################################################
# Name:        Matthew S. Jones
# Course:      AI 533: Intelligent Agents and Decision Making
# Instructor:  Dr. Sandya Saisubramanian
# Assignment:  Mini-project #1, Part A3 (Policy Iteration)
# Due Date:    10 February 2025

my $gamma = 0.95;
my $epsilon = 0.1;
my $inita = 0;

# Used to round the values to one SD more than epsilon
my $vallen = 0;
if ($epsilon =~ /^\d*\.(\d*)$/) {$vallen = length($1) + 1;}
my $expr = "%.".$vallen."f";

print "Gamma = $gamma\nEpsilon = $epsilon\nInitial A = $inita\n";

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

# x, y, 'V' = max value in (x,y): Initialize to 0
for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {$states{$x}{$y}{'V'} = 0;}}

# x, y, 'A' = action in (x,y): Initialize every action to down
for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {$states{$x}{$y}{'A'} = $inita;}}

# x, y, 'Ap' = better action in (x,y): Initialize every better action to ""
for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {$states{$x}{$y}{'Ap'} = "";}}

&converge();
exit(0);


sub converge {
    
    my $pi_conv = 0;
    my $i = -1;

    # Loop until no more policy updates
    while ($pi_conv == 0) {
        
        # Policy evaluation
        
        $i++;
        my $v_conv = 0;
        my $k = 0; 
        
        # x, y, t = value at t (initialize at t = k = 0)
        for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {$states{$x}{$y}{$k} = 0;}}
        
        # Calculate V, loop until convergence
        while ($v_conv == 0) {
            
            $k++;
            
            for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {
                
                if (($x == 3) && ($y == 3)) {$states{$x}{$y}{$k} = $states{$x}{$y}{'R'};}
                elsif ($states{$x}{$y}{'A'} == 0) {$states{$x}{$y}{$k} = &left($x,$y,$k);}
                elsif ($states{$x}{$y}{'A'} == 1) {$states{$x}{$y}{$k} = &up($x,$y,$k);}
                elsif ($states{$x}{$y}{'A'} == 2) {$states{$x}{$y}{$k} = &right($x,$y,$k);}
                elsif ($states{$x}{$y}{'A'} == 3) {$states{$x}{$y}{$k} = &down($x,$y,$k);}
                    
            }}
            
            $v_conv = &v_conv_check($k);

        }

        for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++)
            {$states{$x}{$y}{'V'} = $states{$x}{$y}{$k};}}
			
		$states{3}{3}{'V'} = $states{3}{3}{'R'};
            
        # Policy improvement
        
        # Loop for each state
        for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {
            
            my @dirval;

            # Loop for each direction    
            for (my $i = 0; $i <= 3; $i++) {
                
                my $v_conv = 0;

                if ($i == 0) {$dirval[$i] = &left($x,$y,$k);}
                elsif ($i == 1) {$dirval[$i] = &up($x,$y,$k);}
                elsif ($i == 2) {$dirval[$i] = &right($x,$y,$k);}
                elsif ($i == 3) {$dirval[$i] = &down($x,$y,$k);}
                if (($x == 3) && ($y == 3)) {$dirval[$i] = $states{$x}{$y}{'R'};}
				
            }

            my $maxval = $states{$x}{$y}{'V'};
            $states{$x}{$y}{'Ap'} = $states{$x}{$y}{'A'};
            
            # Update Ap if the value is larger than the currenv V
            for (my $i2 = 0; $i2 <= 3; $i2++) {

                if ($dirval[$i2] > $maxval) {

                    $states{$x}{$y}{'V'} = $dirval[$i2];
                    $maxval = $states{$x}{$y}{'V'};
                    $states{$x}{$y}{'Ap'} = $i2;
                    
                }
            }
        }}
        
        $pi_conv = &pi_conv_check();

    }

    print "\nConverged at i=$i\n";

    print "Values: ";
    for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {print "$states{$x}{$y}{'V'}";
        if ($x < 3) {print ",";}} if ($y < 3) {print ";";}} print "\n";
        
    print "Policy: ";
    for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {print "$states{$x}{$y}{'A'}";
        if ($x < 3) {print ",";}} if ($y < 3) {print ";";}} print "\n";
        
}

sub up { # Returns the expected value of going up
    
    my ($x, $y, $t) = @_;
    
    $uy = $y - 1; if ($uy < 0) {$uy = 0;}
    $lx = $x - 1; if ($lx < 0) {$lx = 0;}
    $rx = $x + 1; if ($rx > 3) {$rx = 3;}
    
    my $val = $states{$x}{$y}{'R'} + $gamma *
        (0.8 * $states{$x}{$uy}{$t-1} + 0.1 * $states{$lx}{$y}{$t-1} + 0.1 * $states{$rx}{$y}{$t-1});

    return sprintf($expr, $val);
    
}

sub right { # Returns the expected value of going right
    
    my ($x, $y, $t) = @_;
    
    $rx = $x + 1; if ($rx > 3) {$rx = 3;}
    $uy = $y - 1; if ($uy < 0) {$uy = 0;}
    $dy = $y + 1; if ($dy > 3) {$dy = 3;}
    
    my $val = $states{$x}{$y}{'R'} + $gamma *
        (0.8 * $states{$rx}{$y}{$t-1} + 0.1 * $states{$x}{$uy}{$t-1} + 0.1 * $states{$x}{$dy}{$t-1});
    
    return sprintf($expr, $val);
    
}

sub down { # Returns the expected value of going down
    
    my ($x, $y, $t) = @_;
    
    $dy = $y + 1; if ($dy > 3) {$dy = 3;}
    $lx = $x - 1; if ($lx < 0) {$lx = 0;}
    $rx = $x + 1; if ($rx > 3) {$rx = 3;}
    
    my $val = $states{$x}{$y}{'R'} + $gamma *
        (0.8 * $states{$x}{$dy}{$t-1} + 0.1 * $states{$lx}{$y}{$t-1} + 0.1 * $states{$rx}{$y}{$t-1});
        
    return sprintf($expr, $val);
    
}

sub left { # Returns the expected value of going left
    
    my ($x, $y, $t) = @_;
    
    $lx = $x - 1; if ($lx < 0) {$lx = 0;}
    $uy = $y - 1; if ($uy < 0) {$uy = 0;}
    $dy = $y + 1; if ($dy > 3) {$dy = 3;}
    
    my $val = $states{$x}{$y}{'R'} + $gamma *
        (0.8 * $states{$lx}{$y}{$t-1} + 0.1 * $states{$x}{$uy}{$t-1} + 0.1 * $states{$x}{$dy}{$t-1});
    
    return sprintf($expr, $val);
    
}

sub v_conv_check { # Determines whether the values have converged to within epsilon
    
    my $time = $_[0];
    my $converged = 1;
    
    for (my $x = 0; $x <= 3; $x++) {for (my $y = 0; $y <= 3; $y++) {
        
        # print "t,V,V-1: $time, $states{$x}{$y}{$time}, $states{$x}{$y}{$time-1}\n";
        if (abs($states{$x}{$y}{$time} - $states{$x}{$y}{$time-1}) > $epsilon) {$converged = 0;}
        
    }}
    
    return $converged;
    
}

sub pi_conv_check { # Determines whether A and Ap are different, updates A
    
    my $converged = 1;
    
    for (my $x = 0; $x <= 3; $x++) {for (my $y = 0; $y <= 3; $y++) {
        
        if ($states{$x}{$y}{'A'} != $states{$x}{$y}{'Ap'}) {
            
            $converged = 0;
            $states{$x}{$y}{'A'} = $states{$x}{$y}{'Ap'};
            
        }
        
        $states{$x}{$y}{'Ap'} = "";
        
    }}
    
    return $converged;
    
}
