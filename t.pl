#!/usr/bin/perl

#my $regex = "AAAAA(.*)BBBBBB";
#my $str =   "AAAAA____BBBBBB";
##$str =~ /$regex/;
#print $-[0]."\t".$+[0]."\n";
#print $-[1]."\t".$+[1]."\n";
#print $-[2]."\t".$+[2]."\n";
#print $-[3]."\t".$+[3]."\n";
#print substr($str, $-[1], $+[1]-$-[1])."\n";

# stole this from the web, don't even understand it very well but it works
#use Inline C => << 'EOC';
    #void find_diffs(char* x, char* y) {
        #int i;
        #Inline_Stack_Vars;
        #Inline_Stack_Reset;
        #for(i=0; x[i] && y[i]; ++i) {
            #if(x[i] != y[i]) {
                #Inline_Stack_Push(sv_2mortal(newSViv(i)));
            #}
        #}
        #Inline_Stack_Done;
    #}
#EOC

#sub find_diff($$) {
	#my @diffs = ();
	#my @s1 = split(//,$_[0]);
	#my @s2 = split(//,$_[1]);
	
	#for (my $i = 0; $i < scalar(@s1); $i++) {
		#if ($s1[$i] ne $s2[$i]) {
			#push(@diffs,$i+1);
		#}
	#}
	#return @diffs;
#}

#my @x = &find_diff('ABCDE', 'CCCCE');
#print scalar(@x);

#my $left = 'AGTACTCGAG';
#my $middle = '([ATCGatcg]{9,11})';
#my $right = 'GCGTCGACCC';

#sub make_regex($$$) {
	#my $left = $_[0];
	#my $middle =$_[1];
	#my $right = $_[2];
	#my @result = ();
	#my $tmp;
	
	#for (my $i = 0; $i < length($left); $i++) {
		#$tmp = $left;
		#substr($tmp, $i,1) = '[ATGCatgc]';
##		print '('.$tmp.')'.$middle.'('.$right.')'."\n";
		#push(@result, '('.$tmp.')'.$middle.'('.$right.')');
	#}
	
	#for (my $i = 0; $i < length($right); $i++) {
		#$tmp = $right;
		#substr($tmp, $i,1) = '[ATGCatgc]';
		#push(@result, '('.$left.')'.$middle.'('.$tmp.')');
	#}
	#return(@result);
#}

#my @reg = make_regex($left, $middle, $right);
#print join("\n", @reg);

#sub findMinValueIndex(@) {
	#my @arr = @_;
	#my $index = 0;
	#my $min = 0;
	#for (my $i = 0; $i < scalar(@arr); $i++) {
		#if ($arr[$i] <= $min) {
			#$min = $arr[$i];
			#$index = $i;
			#}
		#}
		#print $index."\n";
		#return $index;
	#}
	
#sub checkMultipleMins(@) {
	#my @arr = @_;
	#my $index = findMinValueIndex(@arr);
	#my $min = $arr[$index];
	#my $counter = 0;
	#for (my $i = 0; $i < scalar(@arr); $i++) {
		#if ($arr[$i] == $min) {
			#$counter++;
		#}
	#}
	#return $counter;
#}

sub findMinValueIndex(@) {
	my @arr = @_;
	my $index = 0;
	my $min = $arr[0];;
	for (my $i = 0; $i < scalar(@arr); $i++) {
		if ($arr[$i] <= $min) {
			$min = $arr[$i];
			$index = $i;
			}
		}
		return ($min,$index);
	}

# check an array for more than one minimum
sub checkMultipleMins($@) {
	my $min = shift(@_);
	my @arr = @_;
	my $counter = 0;
	for (my $i = 0; $i < scalar(@arr); $i++) {
		if ($arr[$i] == $min) {
			$counter++;
		}
	}
	return $counter;
}


my @a = (1,3,2,2,2,1,1,1,1,2,1,1,1,1,0);
my ($min, $ind) = findMinValueIndex(@a);
print "$min\t$ind\n";
print checkMultipleMins($min, @a)."\n";
