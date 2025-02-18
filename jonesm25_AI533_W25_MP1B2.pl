##############################################################
# Name:        Matthew S. Jones
# Course:      AI 533: Intelligent Agents and Decision Making
# Instructor:  Dr. Sandya Saisubramanian
# Assignment:  Mini-project #1, Part B2 (DAGGER Implementation)
# Due Date:    10 February 2025

my $gamma = 0.95;
my $total_repeats = $ARGV[0]; # first command line argument
my $N = $ARGV[1]; # second command line argument

my $file = ">mp1b2_g".$gamma."_N".$N.".txt";
open(OUT,$file);

print "Gamma = $gamma\nN = $N\n\n";
print OUT "Gamma = $gamma\nN = $N\n\n";

my %states;

# Optimum Policy: 3,3,2,3;3,2,2,3;3,3,2,3;2,2,2,0
# x, y, 'OP' = optimum policy action in (x,y): Initialize action to the policy from A2
for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {$states{$x}{$y}{'OP'} = 3;}}
$states{2}{0}{'OP'} = 2;
$states{2}{1}{'OP'} = 2;
$states{2}{2}{'OP'} = 2;
$states{2}{3}{'OP'} = 2;
$states{1}{1}{'OP'} = 2;
$states{1}{3}{'OP'} = 2;
$states{0}{3}{'OP'} = 2;
$states{3}{3}{'OP'} = 0;

print "Optimal Policy: ";
for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {print "$states{$x}{$y}{'OP'}";
    if ($x < 3) {print ",";}} if ($y < 3) {print ";";}} print "\n";

print OUT "Optimal Policy: ";
for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {print OUT "$states{$x}{$y}{'OP'}";
    if ($x < 3) {print OUT ",";}} if ($y < 3) {print OUT ";";}} print OUT "\n";

my $repeats = 1;
my $matches = 0;

while ($repeats <= $total_repeats) {
    
    # x, y, 'A' = action in (x,y): Initialize action to a random policy
    for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++)
        {$states{$x}{$y}{'A'} = int(rand(3));}}

    # x, y, 'D' = optimal A in (x,y): Initialize D to blank
    for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {$states{$x}{$y}{'D'} = "";}}

    my %traj;

    my $x = 0; # start at x = 0
    my $y = 0; # start at y = 0
      my $fail = 0;

    for (my $i = 0; $i <= $N; $i++) {

        # Create a trajectory based on A (initially random)
        
        my $goal = 0;
        my $actions = 0;

        while (($goal == 0) && ($fail == 0)) {
        
            # Assigns D to the OP for that state
            $states{$x}{$y}{'D'} = $states{$x}{$y}{'OP'};

            ($x, $y) = &take_action($x, $y, $states{$x}{$y}{'A'});

            if (($x == 3) && ($y == 3)) {$goal = 1;}
        
            $actions++;
            # Will bail after 1k actions, assuming it won't reach the goal
            if ($actions > 1000) {$fail = 1;}

        }
    
        if ($fail == 1) {last;}
        
        # Assigns D to the OP for that state
        $states{$x}{$y}{'D'} = $states{$x}{$y}{'OP'};
    
        # Create an entirely new policy based on 'D'

        my $sum = 0;
        my $count = 0;
        
        for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {
        
            # If the trajectory encountered that state and learned the optimal policy
            # action there, then make that the new policy for the next trajectory
            if ($states{$x}{$y}{'D'} ne "") {
            
                $states{$x}{$y}{'A'} = $states{$x}{$y}{'D'};
            
                $sum = $sum + $states{$x}{$y}{'A'};
                $count++;
            
            }
        
            # otherwise, assign it to blank
            else {$states{$x}{$y}{'A'} = "";}
        
        }}
    
        for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {
        
            # If the policy wasn't defined in the previous action,
            # assign it the average of what *was* assigned
            if ($states{$x}{$y}{'A'} eq "") {$states{$x}{$y}{'A'} = int($sum / $count);}
        
        }}
        
    }

    # If the run doesn't fail (due to an invalid random initial policy), record the results
    if ($fail == 0) {

        print "Predicted Policy $repeats: ";
        for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {print "$states{$x}{$y}{'A'}";
           if ($x < 3) {print ",";}} if ($y < 3) {print ";";}} print "\n";

        print OUT "Predicted Policy $repeats: ";
        for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {print OUT "$states{$x}{$y}{'A'}";
           if ($x < 3) {print OUT ",";}} if ($y < 3) {print OUT ";";}} print OUT "\n";

        for (my $y = 0; $y <= 3; $y++) {for (my $x = 0; $x <= 3; $x++) {
        
            if (($x == 3) && ($y == 3)) {} # Do nothing because the action at (3,3) is irrelevant
            elsif ($states{$x}{$y}{'A'} eq $states{$x}{$y}{'OP'}) {$matches ++;}
        
        }}        

        $repeats++;
        
    }
}

# Calculate the overall accuracy
my $accuracy = sprintf("%.2f", ($matches/(15 * $total_repeats)) * 100);
print "Accuracy = $accuracy%\n";
print OUT "Accuracy = $accuracy%\n";

close(OUT);

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
