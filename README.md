# meteo1
установка не требуется.

первый подход к обработке логи с метеостанции при помощи catboost'а

если ты забрёл сюда случайно, то наврядли что-то поймёшь. это обменник-журнал на базе гита

если интересно попробовать, то файл log_sep2015.txt 
это журнал измерений домашней метеостанцией программы Cumulus, станция WMR200

perl скрипт - то фильт для приведения в надлежащий вид сырого лога

работает как обычно: categorize.pl options

./categorize.pl log_sep2015.txt

для справки ./categorize.pl --help

## порядок с входным данными походу следующий
* почистить данные
* привести к одному таймфрейму(это та ещё задача)
* категоризировать как можно больеше параметров(это значительно пывысит качество работы, но наадо не перестараться, большие категории бесполезны)
* промаркировать целевые данные(пока вникаем...)
* тут варианты, но пока пойдём по пути обучение + тест
* сформировать обучающую выбрку
* сформировать тестовую выборку
* загрузить обучающую выбрку в механизм обучения модели
* проверить обученную модель на тестовой выборке
