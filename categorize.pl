#!/usr/bin/perl -w
use warnings;
use strict;

print "hello perl\n";

print "@ARGV\n";

print @ARGV . "\n";

die "usage categorize inputfile [outputfile]\n\n"
	if @ARGV < 1;

warn "ouput file is not specified. Default output fileaname will be used"
	if @ARGV < 2;

my $input_filename = shift @ARGV;
my $output_filename = shift @ARGV || "cat_$input_filename";

print "in>>" . $input_filename . "\n";
print "out<<" . $output_filename . "\n"; 

# чтобы построить розу ветров, нужно перевести градусы в стороны горизонта следующим образом:
# тут более полно о румбах https://ru.wikipedia.org/wiki/%D0%A0%D1%83%D0%BC%D0%B1
# СВ NE - от 22,5° до 67,5°
# В E - от 67,5° до 112,5°
# ЮВ SE - от 112,5° до 157,5°
# Ю S - от 157,5° до 202,5°
# ЮЗ SW - от 202,5° до 247,5°
# З W - от 247,5° до 292,5°
# СЗ NW - от 292,5° до 337,5°
# С N - от 337,5° до 360° и от 0° до 22,5°.
# 02.09.15;13:57;26,1;45;13,0;2,0;2,5;135;0,0;0,0;995,0;0,0;23,8;47;2,5;26,1;26,1;3;0;0,00;0,00;25,7;646;0,0;135;0,0;0,0
# 25 полей разделённых ;
open FIN, "<$input_filename"
	or die "Can't open $input_filename: $!";
open FOUT, ">$output_filename"
	or die "Can't open $output_filename: $!";
map { chomp;
	# выбрать данные удовлетворяющие шаблону
	if (m/(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+)/g) {
		# категоризировать значение румба
		my $rumb = $8;
		if (22 <= $rumb && $rumb < 67) {
		# СВ NE - от 22,5° до 67,5°
			print FOUT "NE;$_\n";	
		} elsif (67 <= $rumb && $rumb < 112) {
		# В E - от 67,5° до 112,5°
			print FOUT "E;$_\n";	
		} elsif (112 <= $rumb && $rumb < 157) {
		# ЮВ SE - от 112,5° до 157,5°
			print FOUT "SE;$_\n";	
		} elsif (157 <= $rumb && $rumb < 202) {
		# Ю S - от 157,5° до 202,5°
			print FOUT "S;$_\n";	
		} elsif (202 <= $rumb && $rumb < 247) {
		# ЮЗ SW - от 202,5° до 247,5°
			print FOUT "SW;$_\n";	
		} elsif (247 <= $rumb && $rumb < 292) {
		# З W - от 247,5° до 292,5°
			print FOUT "W;$_\n";	
		} elsif (292 <= $rumb && $rumb < 337) {
		# СЗ NW - от 292,5° до 337,5°
			print FOUT "NW;$_\n";	
		} elsif (337 <= $rumb && $rumb < 360) {
		# С N - от 337,5° до 360° 
			print FOUT "N;$_\n";	
		} elsif (0 <= $rumb && $rumb < 22) { 
		# и от 0° до 22,5°.
			print FOUT "N;$_\n";	
		} #else {
			#print FOUT "?;$_\n";
		#}
	} # eof if
} <FIN>;
