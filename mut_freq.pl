#!/usr/bin/perl

use strict;

my $chunks = shift;
my $left = shift;
my $right = shift;

my @tmp;
my @r_array;
my @lefts = (0) x length($left);
my @rights = (0) x length($right);
my @diff;

# finds differences between strings
use Inline C => << 'EOC';
    void find_diff(char* x, char* y) {
        int i;
        Inline_Stack_Vars;
        Inline_Stack_Reset;
        for(i=0; x[i] && y[i]; ++i) {
            if(x[i] != y[i]) {
                Inline_Stack_Push(sv_2mortal(newSViv(i)));
            }
        }
        Inline_Stack_Done;
    }
EOC

open(IN,$chunks);
@tmp = <IN>;
close(IN);

foreach my $record (@tmp) {
	chomp($record);
	@r_array = split(/\t/, $record);
	@diff = &find_diff($left, $r_array[0]);
	for (my $i = 0; $i < scalar(@diff); $i++) {
		$lefts[$diff[$i]]++;
	}
	
	@diff = &find_diff($right, $r_array[2]);
	for (my $i = 0; $i < scalar(@diff); $i++) {
		
		$rights[$diff[$i]]++;
	}
}

print join("\t", split(//,$left))."\n";
print join("\t",@lefts)."\n";
print "\n";
print join("\t", split(//,$right))."\n";
print join("\t",@rights)."\n";
