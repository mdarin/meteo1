# meteo1
установка не требуется.

первый подход к обработке логи с метеостации при помощи catboost'а

если ты забрёл сюда случайно, то наврядли что-то поймёшь. это обменник-журнал на базе гита

если интересно попробовать, то файл log_sep2015.txt 
это журнал имерений домашней метеостанцией программы Cumulus, станция WMR200

perl скрипт - то фильт для приведения в надлежащий вид сырого лога

работает как обычно: categorize.pl options

./categorize.pl log_sep2015.txt

для справки ./categorize.pl --help
