#!/usr/bin/perl -w
use warnings;
use strict;
use File::Spec;
use Getopt::Long;
use autodie;


print "@ARGV\n";

print @ARGV . "\n";

die "usage categorize inputfile [outputfile]\n\n"
	if @ARGV < 1;

warn "[WARN] Ouput file is not specified. Default output fileaname will be used"
	if @ARGV < 2;

# получить настройки из командной строки
#TODO: использовать Longopts
my $in_fname = shift @ARGV;
my $out_fname = shift @ARGV || "cat_$in_fname";

# файл описания колонок
my $cd_foname = "coldesc.cd";

## порядок с входным данными походу следующий
# почистить данные
# привести к одному таймфрейму(это та ещё задача)
# категоризировать как можно больеше параметров(это значительно пывысит качество работы, но наадо не перестараться, большие категории бесполезны)
# промаркировать целевые данные(пока вникаем...)
# сформировать описание столбцов(форматы обучающей и тестовой выборки должны быть одинаковы)
# тут варианты, но пока пойдём по пути обучение + тест
# сформировать обучающую выбрку
# сформировать тестовую выборку
# загрузить обучающую выбрку в механизм обучения модели
# проверить обученную модель на тестовой выборке

&categorize($in_fname, $out_fname);

&create_column_description($cd_foname);

&create_train_and_test($out_fname);


sub categorize {

	my ($finame, $foname) = @_;

	print "input file: " . $finame . "\n";
	print "output file: " . $foname . "\n"; 

	# по умолчанию разделитель - знак табуляции
	my $sep = "\t";
	print "separator: tab\n";
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
	# 28 полей разделённых ;
	# 
	my $fin;
	my $fout;
	open $fin, "<$finame"
		or die "Can't open $finame: $!";
	open $fout, ">$foname"
		or die "Can't open $foname: $!";
	map { chomp;
		# выбрать данные удовлетворяющие шаблону шаблон надо уточнить!!
		if (m/(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+?);(.+)/g) {
			# получить значение румба	
			my $rumb = $8;
			# установить категорию как неизвестную на всякий случай
			my $rumb_cat = "?";
			#TODO:сделать оциональным! привести числа с плавающей точкой к форматут 0.0 из 0,0
			s/[,]/./gi;
			# заменить разделители ; на $sep(выбранный разделитель, по умолчанию таблуляция \t)
			s/[;]/$sep/gi;
			# отметка целевых значений
			my $label = "0"; # по умолчанию не отмечен
			# категоризировать значение румба
			if (22 <= $rumb && $rumb < 67) {
			# СВ NE - от 22,5° до 67,5°
				$rumb_cat = "NE";
			} elsif (67 <= $rumb && $rumb < 112) {
			# В E - от 67,5° до 112,5°
				$rumb_cat = "E";	
			} elsif (112 <= $rumb && $rumb < 157) {
			# ЮВ SE - от 112,5° до 157,5°
				$rumb_cat = "SE";	
			} elsif (157 <= $rumb && $rumb < 202) {
			# Ю S - от 157,5° до 202,5°
				$rumb_cat = "S";	
			} elsif (202 <= $rumb && $rumb < 247) {
			# ЮЗ SW - от 202,5° до 247,5°
				$rumb_cat = "SW";	
			} elsif (247 <= $rumb && $rumb < 292) {
			# З W - от 247,5° до 292,5°
				$rumb_cat = "W";	
			} elsif (292 <= $rumb && $rumb < 337) {
			# СЗ NW - от 292,5° до 337,5°
				$rumb_cat = "NW";	
				# предположим, что на интересует ветер СевероЗападного направления
				# отметим его,как целевой
				$label = "1";
			} elsif (337 <= $rumb && $rumb < 360) {
			# С N - от 337,5° до 360° 
				$rumb_cat = "N";	
			} elsif (0 <= $rumb && $rumb < 22) { 
			# и от 0° до 22,5°.
				$rumb_cat = "N";	
			} 
			# вывести преобразованную строку	
			print $fout  $label . $sep . $rumb_cat . $sep . $_ . "\n";	
		
		} # eof if
	} <$fin>;

	close $fin
		or die "Can't close $finame:$!";
	close $fout
		or die "Can't close $foname:$!";
} 




sub create_column_description {
	my $cd_foname = shift @_;
	my $fout;
	open $fout, ">$cd_foname"
		or die "Can't open $cd_foname:$!";

	#TODO: тут надо какой-то чтоли алгоритм реаилзовать?
	print $fout "0\tLabel\n";
	print $fout "1\tCateg\tRumb\n";
	print $fout "2\tAuxiliary\n";
	print $fout "3\tAuxiliary\n";
	print $fout "4\tNum\n";
	print $fout "5\tNum\n";
	print $fout "6\tNum\n";
	print $fout "7\tNum\n";
	print $fout "8\tNum\n";
	print $fout "9\tNum\n";
	print $fout "10\tNum\n";
	print $fout "11\tNum\n";
	print $fout "12\tNum\n";
	print $fout "13\tNum\n";
	print $fout "14\tNum\n";
	print $fout "15\tNum\n";
	print $fout "16\tNum\n";
	print $fout "17\tNum\n";
	print $fout "18\tNum\n";
	print $fout "19\tNum\n";
	print $fout "20\tNum\n";
	print $fout "21\tNum\n";
	print $fout "22\tNum\n";
	print $fout "23\tNum\n";
	print $fout "24\tNum\n";
	print $fout "25\tNum\n";
	print $fout "26\tNum\n";
	print $fout "27\tNum\n";
	print $fout "28\tnum\n";

	close $fout
		or die "Can't close $cd_foname:$!";
}




sub create_train_and_test {
	# сформировать обучающую и тестовую выборки 
	# потом надо сделать чере пайпы ct.pl | clt.pl | ... понаделать команд
	# 
	my $cat_finame = shift @_;
	my $train_foname = "train.tsv";
	my $test_foname = "test.tsv";
	my $fin;
	open $fin, "<$cat_finame"
		or die "Can't open $cat_finame:$!";
	my $train_fout;
	open $train_fout, ">$train_foname"
		or die "Can't open $train_foname:$!";
	my $test_fout;
	open $test_fout, ">$test_foname"
		or die "Can't opne $test_foname:$!";
	my $rec_count = 0;
	while (<$fin>) { 
		chomp;	
		$rec_count++;
		my $fout;
		if ($rec_count < 3000) { # в файле 4000 записей log_sep2015.txt 
		# формируем обучающую выборку
			# направляем поток в обучающий файл
			$fout = $train_fout; 
		} else {
		# формируем тестовую выборку
			# направляем поток в тестовый файл
			$fout = $test_fout;
		}
		print $fout "$_\n";
	};
		
	close $test_fout
		or die "Can't close $test_foname:$!";
	close $train_fout
		or die "Can't close $train_foname:$!";
	close $fin
		or die "Can't close $cat_finame:$!";
}
