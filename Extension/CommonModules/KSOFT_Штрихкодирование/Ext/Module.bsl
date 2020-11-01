﻿
//Формирует из заданного текста картину указанного формата
//текст - кодируемый текст
//тип - формат штрихкода из поддерживаемых
//ФорматИзображения - формат картинки типа ФорматКартинки.
//ВключитьТекст(булево) - требуется ли рисовать подпись под кодом
//ЦветФона - объект типа Цвет(абсолютный) для задания фона изображения, по умолчанию белый Цвет(255,255,255)
//ЦветКода - объект типа Цвет(абсолютный) для задания цвета изображения, по умолчанию черный Цвет(0,0,0)
//Ширина - ширина результирующей картинки в пикселях
//Высота - высота результирующей картинки в пикселях
//
//Возвращает объект Картинка
Функция ПолучитьКартинкуЛинейногоШК(ТекстШтрихкода, ТипШтрикхода, ШиринаШтрихкода = Неопределено, ВысотаШтрихкода = Неопределено) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ТекстШтрихкода) Тогда
		Возврат Неопределено;
	КонецЕсли;
	ПараметрыКартинки = ПараметрыКартинкиЛинейногоШтрихода(ТекстШтрихкода, ТипШтрикхода, ШиринаШтрихкода, ВысотаШтрихкода);
	Если ПараметрыКартинки = Неопределено Тогда
		Возврат Неопределено;	
	КонецЕсли; 
	
	Попытка
		ДвоичныеДанныеКартинки = Base64Значение(КодироватьБ64(КартинкаВМассивБайтов(ПараметрыКартинки)));
		КартинкаШтрихкода = Новый Картинка(ДвоичныеДанныеКартинки);
		КартинкаШтрихкода = КартинкаШтрихкода.Преобразовать(ФорматКартинки.PNG);
	Исключение
		КартинкаШтрихкода = Неопределено;
	КонецПопытки; 
	Возврат КартинкаШтрихкода;
КонецФункции

Функция КартинкаВМассивБайтов(ДанныеКартинки)
	ОбщийРазмерКартинки = 14 + 40;
	РазмерПалитры = ДанныеКартинки.Палитра.Количество()*4;
	ОбщийРазмерКартинки = ОбщийРазмерКартинки + РазмерПалитры;
	строка = Цел(ДанныеКартинки.Параметры.Ширина/8)+?((ДанныеКартинки.Параметры.Ширина % 8)>0,1,0);
	Если строка%4 >0 тогда
		строка = (Цел(строка/4)+1)*4;
	КонецЕсли;
	ОбщийРазмерКартинки = ОбщийРазмерКартинки + ДанныеКартинки.Параметры.Высота * строка;
	Тело = ЗаписьДанныхПотокВПамяти(ОбщийРазмерКартинки);
	ЗаписьДанныхЗаписатьСимволы(Тело, "BM");
	ЗаписьДанныхЗаписатьЦелое32(Тело, ОбщийРазмерКартинки, "LittleEndian");
	ЗаписьДанныхЗаписатьЦелое32(Тело, 0, "LittleEndian");
	ЗаписьДанныхЗаписатьЦелое32(Тело, 14 + 40 + РазмерПалитры, "LittleEndian");
	ЗаписьДанныхЗаписатьЦелое32(Тело, 40, "LittleEndian");
	ЗаписьДанныхЗаписатьЦелое32(Тело, ДанныеКартинки.Параметры.Ширина, "LittleEndian");
	ЗаписьДанныхЗаписатьЦелое32(Тело, ДанныеКартинки.Параметры.Высота, "LittleEndian");
	ЗаписьДанныхЗаписатьЦелое16(Тело, 1, "LittleEndian");
	ЗаписьДанныхЗаписатьЦелое16(Тело, 1, "LittleEndian");
	
	Для Сч = 1 по 3 цикл
		ЗаписьДанныхЗаписатьЦелое64(Тело, 0, "LittleEndian");
	КонецЦикла;
	
	//Записываем цвет каждого пикселя
	для цв=0 по ДанныеКартинки.Палитра.Количество()-1 Цикл
		ЗаписьДанныхЗаписатьБайт(Тело, ДанныеКартинки.Палитра[цв].Синий);
		ЗаписьДанныхЗаписатьБайт(Тело, ДанныеКартинки.Палитра[цв].Зеленый);
		ЗаписьДанныхЗаписатьБайт(Тело, ДанныеКартинки.Палитра[цв].Красный);
		ЗаписьДанныхЗаписатьБайт(Тело, 0);
	КонецЦикла;
	
	Для Выс = 0 ПО ДанныеКартинки.Параметры.Высота-1 Цикл
		ви = ДанныеКартинки.Параметры.Высота - 1 - Выс;
		шт = 0;
		БайтВСтроке = 0;
		Для Ширина = 0 По ДанныеКартинки.Данные[ви].ВГраница() Цикл
			зн = ДанныеКартинки.Данные[ви][Ширина];
			Если шт = 0 тогда
				байт = 0;
			КонецЕсли;
			шт = шт + 1;
			байт = байт*2 + зн%2;
			если шт = 8 тогда
				шт = 0;
			Иначе
				Продолжить;
			КонецЕсли;
			ЗаписьДанныхЗаписатьБайт(Тело, байт);
			БайтВСтроке = БайтВСтроке+1;	
		КонецЦикла;
		
		Если шт <> 0 тогда
			байт = байт*КэшБайтов()[8-шт];
			БайтВСтроке = БайтВСтроке+1;
			ЗаписьДанныхЗаписатьБайт(Тело, байт);
		КонецЕсли;
		Остаток=(4-БайтВСтроке%4)%4;
		Для Сч = 1 по Остаток цикл
			ЗаписьДанныхЗаписатьБайт(Тело, 0);
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат Тело.Байты;
КонецФункции

Функция СимволЧисло(Текст, НомерСимвола)
	Возврат Число(СимволСтроки(Текст, НомерСимвола));	
КонецФункции

Функция СимволСтроки(Текст, НомерСимвола)
	Возврат Сред(Текст, НомерСимвола, 1);		
КонецФункции

Функция СоответствиеКод39()
	
	КодыСимволов39 = Новый Соответствие;
	КодыСимволов39.Вставить("0", "1113313111");
	КодыСимволов39.Вставить("1", "3113111131");
	КодыСимволов39.Вставить("2", "1133111131");
	КодыСимволов39.Вставить("3", "3133111111");
	КодыСимволов39.Вставить("4", "1113311131");
	КодыСимволов39.Вставить("5", "3113311111");
	КодыСимволов39.Вставить("6", "1133311111");
	КодыСимволов39.Вставить("7", "1113113131");
	КодыСимволов39.Вставить("8", "3113113111");
	КодыСимволов39.Вставить("9", "1133113111");
	КодыСимволов39.Вставить("0", "1113313111");
	КодыСимволов39.Вставить("A", "3111131131");
	КодыСимволов39.Вставить("B", "1131131131");
	КодыСимволов39.Вставить("C", "3131131111");
	КодыСимволов39.Вставить("D", "1111331131");
	КодыСимволов39.Вставить("E", "3111331111");
	КодыСимволов39.Вставить("F", "1131331111");
	КодыСимволов39.Вставить("G", "1111133131");
	КодыСимволов39.Вставить("H", "3111133111");
	КодыСимволов39.Вставить("I", "1131133111");
	КодыСимволов39.Вставить("J", "1111333111");
	КодыСимволов39.Вставить("K", "3111111331");
	КодыСимволов39.Вставить("L", "1131111331");
	КодыСимволов39.Вставить("M", "3131111311");
	КодыСимволов39.Вставить("N", "1111311331");
	КодыСимволов39.Вставить("O", "3111311311");
	КодыСимволов39.Вставить("P", "1131311311");
	КодыСимволов39.Вставить("Q", "1111113331");
	КодыСимволов39.Вставить("R", "3111113311");
	КодыСимволов39.Вставить("S", "1131113311");
	КодыСимволов39.Вставить("T", "1111313311");
	КодыСимволов39.Вставить("U", "3311111131");
	КодыСимволов39.Вставить("V", "1331111131");
	КодыСимволов39.Вставить("W", "3331111111");
	КодыСимволов39.Вставить("X", "1311311131");
	КодыСимволов39.Вставить("Y", "3311311111");
	КодыСимволов39.Вставить("Z", "1331311111");
	КодыСимволов39.Вставить("-", "1311113131");
	КодыСимволов39.Вставить(".", "3311113111");
	КодыСимволов39.Вставить(" ", "1331113111");
	КодыСимволов39.Вставить("*", "1311313111");
	КодыСимволов39.Вставить("$", "1313131111");
	КодыСимволов39.Вставить("/", "1313111311");
	КодыСимволов39.Вставить("+", "1311131311");
	КодыСимволов39.Вставить("%", "1113131311");
	Возврат КодыСимволов39;
	
КонецФункции

Функция ПолучитьКодШтрихКодаПоИмени(пИмя) Экспорт 
	Если пИмя = "EAN8" Тогда
		Возврат 0;
	ИначеЕсли пИмя = "EAN13" Тогда
		Возврат 1;
	ИначеЕсли пИмя = "CODE39" Тогда
		Возврат 3;
	ИначеЕсли пИмя = "QR" Тогда
		Возврат 16;
	КонецЕсли;
КонецФункции

//Возвращает строку - кодированные по Base64 данные, представленные массивом байт
Функция КодироватьБ64(Байты)
	
	КодыBase64 = КодыBase64();
	
	КоличествоБайтов = Байты.Количество();
	Если НЕ ЗначениеЗаполнено(КоличествоБайтов) тогда
		Возврат "";
	КонецЕсли;
	
	СтрокиBase64 = Новый Массив();
	Для Сч = 0 по Цел(КоличествоБайтов/3)-1 цикл
		СтрокиBase64.Добавить(
		КодыBase64[Цел(Байты[Сч*3]/4)]                                          
		+ КодыBase64[(Байты[Сч*3]%4)*16 + Цел(Байты[Сч*3+1]/16)]
		+ КодыBase64[(Байты[Сч*3+1]%16)*4 + Цел(Байты[Сч*3+2]/64)]
		+ КодыBase64[(Байты[Сч*3+2]%64)]);
	КонецЦикла;
	
	ОстатокБайтов = КоличествоБайтов%3;
	Если ОстатокБайтов > 0 Тогда
		НН = Цел(КоличествоБайтов/3)*3;
		ч1 = Байты[НН];
		ч2 = ?(ОстатокБайтов > 1, Байты[НН+1] ,0);
		СтрокаBase64 = КодыBase64[Цел(ч1/4)] + КодыBase64[(ч1%4)*16 + Цел(ч2/16)];
		Если ОстатокБайтов = 1 тогда
			СтрокаBase64 = СтрокаBase64 + "==";
		Иначе
			СтрокаBase64 = СтрокаBase64 + КодыBase64[(ч2%16)*4] + "=";
		КонецЕсли;
		СтрокиBase64.Добавить(СтрокаBase64);
	КонецЕсли;
	
	КолСтрок = СтрокиBase64.Количество();
	Пока КолСтрок > 1 Цикл
		Для Сч = 0 По Цел(КолСтрок/2)-1 Цикл
			СтрокиBase64[Сч] = СтрокиBase64[Сч*2] + СтрокиBase64[Сч*2 + 1];
		КонецЦикла;
		Если КолСтрок%2 = 1 Тогда
			СтрокиBase64[Цел(КолСтрок/2)] = СтрокиBase64[КолСтрок-1];
		КонецЕсли;
		КолСтрок = Цел(КолСтрок/2) + КолСтрок%2;
	КонецЦикла;	
	
	Возврат СтрокиBase64[0];
	
КонецФункции

Функция КодыBase64()
	
	СтрокаБ64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	КодыBase64 = Новый Массив(64);
	Для Сч = 0 по 63 Цикл
		КодыBase64[Сч] = Сред(СтрокаБ64, Сч + 1, 1); 
	КонецЦикла;
	Возврат КодыBase64;
	
КонецФункции

Функция ПараметрыКартинкиЛинейногоШтрихода(ТекстШтрихкода, ТипШтрикхода, ШиринаШтрихкода, ВысотаШтрихкода)
	
	Если ТипШтрикхода = 0 Тогда
		Тип = "EAN8";
	ИначеЕсли ТипШтрикхода = 1 Тогда
		Тип = "EAN13";
	ИначеЕсли ТипШтрикхода = 3 Тогда 
		Тип = "CODE39";	
	Иначе
		Возврат Неопределено;
	КонецЕсли; 
		
	КодШтрихкода = ПолучитьКодЛинейногоШК(ТекстШтрихкода, тип);
	
	Если НЕ ЗначениеЗаполнено(КодШтрихкода) Тогда
		Возврат Неопределено;		
	КонецЕсли; 
	
	ШиринаЛинии = 1;
	
	ЦветФона = Новый Цвет(255,255,255);
	ЦветКода = Новый Цвет(0,0,0);

	РазмерОтступа = ?(Тип = "EAN13",7,5);//Отступ слева и справа в "линиях"
	ШиринаКода=0; 
	Для Сч = 1 по СтрДлина(КодШтрихкода) Цикл
		ШиринаКода = ШиринаКода + Число(Сред(КодШтрихкода, Сч, 1));
	КонецЦикла;
	
	ШиринаКодаСОтступами = ШиринаКода+2*РазмерОтступа;
	
	ШиринаШтрихкода = Макс((ШиринаКодаСОтступами)*ШиринаЛинии, ШиринаШтрихкода);
	ШиринаЛинии = Цел(ШиринаШтрихкода/ШиринаКодаСОтступами);
	ДопОтступ = Цел(ШиринаШтрихкода%ШиринаКодаСОтступами/2);
	ВысотаШтрихкода = Макс(40, ВысотаШтрихкода);
	
	ПараметрыКартинки = СоздатьКартинку(Новый Структура("Ширина,Высота,ЦветФона",ШиринаШтрихкода, ВысотаШтрихкода,1));
	ПараметрыКартинки.палитра[0] = ЦветКода;
	ПараметрыКартинки.палитра[1] = ЦветФона;
	
	поз = РазмерОтступа * ШиринаЛинии + ДопОтступ;
	Для Сч = 1 по СтрДлина(КодШтрихкода) Цикл
		ШиринаЧислаЛинии = Число(Сред(КодШтрихкода,Сч,1)) * ШиринаЛинии; 
		//Штриход выводится в виде линии, чем больше число, тем толще линия
		Если Сч%2=1 тогда //только нечетные числа
			КартинкаПрямоугольник(ПараметрыКартинки, поз, 0, поз + ШиринаЧислаЛинии - 1, ВысотаШтрихкода, 0, 0);
		КонецЕсли;
		поз = поз + ШиринаЧислаЛинии;
	КонецЦикла;
	
	Возврат ПараметрыКартинки;
	
КонецФункции

Функция СоздатьКартинку(ПараметрыФормирования)	
	
	ЦветФона = 0;
	Если Не ПараметрыФормирования.Свойство("ЦветФона", ЦветФона) тогда
		ЦветФона = 0;
	КонецЕсли;
	ЦветФона = ЦветФона % 2; 
	Палитра = ПолучитьПалитруПоУмолчанию();
	ДанныеКартинки = Новый Массив(ПараметрыФормирования.Высота, ПараметрыФормирования.Ширина);
	Для ВысотаКартинки = 0 По ПараметрыФормирования.Высота-1 цикл
		Для ШиринаКартинки = 0 По ПараметрыФормирования.Ширина-1 цикл
			ДанныеКартинки[ВысотаКартинки][ШиринаКартинки] = ЦветФона;
		КонецЦикла;
	КонецЦикла;
	Возврат Новый Структура("Параметры, Данные, Палитра", ПараметрыФормирования, ДанныеКартинки, Палитра);
	
КонецФункции
	
Процедура КартинкаВертикальнаяЛиния(Картинка, Столбец, Ряд1, Ряд2, Цвет)
	
	Если Столбец < 0 ИЛИ Столбец >= Картинка.Параметры.Ширина Тогда
		Возврат;
	КонецЕсли;
	
	Ряд1 = Мин(Картинка.Параметры.Высота-1, Макс(0, Ряд1));
	Ряд2 = Мин(Картинка.Параметры.Высота-1, Макс(0, Ряд2));
	
	Для Ряд = Ряд1 по Ряд2 цикл
		Картинка.Данные[Ряд][Столбец] = Цвет;
	КонецЦикла;
	
КонецПроцедуры

Процедура КартинкаГоризонтальнаяЛиния(Картинка, Столбец1, Столбец2, Ряд, Цвет)
	
	Если Ряд < 0 ИЛИ Ряд >= Картинка.Параметры.Высота Тогда
		Возврат;
	КонецЕсли;
	
	Столбец1 = Мин(Картинка.Параметры.Ширина-1, Макс(0, Столбец1));
	Столбец2 = Мин(Картинка.Параметры.Ширина-1, Макс(0, Столбец2));
	
	Для Столбец = Столбец1 ПО Столбец2 цикл
		Картинка.Данные[Ряд][Столбец] = Цвет;
	КонецЦикла;
	
КонецПроцедуры

Процедура КартинкаПрямоугольник(ПараметрыКартинки, Знач Столбец1, Знач Ряд1, Знач Столбец2, Знач Ряд2, Знач ЦветГраницы, Знач ЦветФона = Неопределено)
	
	Если Столбец1 > Столбец2 тогда
		ПоменятьМестамиЗначения(Столбец1, Столбец2);
	КонецЕсли;
	
	Если Ряд1 > Ряд2 тогда
		ПоменятьМестамиЗначения(Ряд1, Ряд2);
	КонецЕсли;
	
	Если ЦветФона = ЦветГраницы тогда
		Для Сч = Ряд1 По Ряд2 Цикл
			КартинкаГоризонтальнаяЛиния(ПараметрыКартинки, Столбец1, Столбец2, Сч, ЦветФона);
		КонецЦикла;
	Иначе
		КартинкаГоризонтальнаяЛиния(ПараметрыКартинки, Столбец1, Столбец2, Ряд1, ЦветГраницы);
		КартинкаГоризонтальнаяЛиния(ПараметрыКартинки, Столбец1, Столбец2, Ряд2, ЦветГраницы);
		КартинкаВертикальнаяЛиния(ПараметрыКартинки, Столбец1, Ряд1, Ряд2, ЦветГраницы);
		КартинкаВертикальнаяЛиния(ПараметрыКартинки, Столбец2, Ряд1, Ряд2, ЦветГраницы);
		Если ЦветФона <> Неопределено И (Столбец2 > Столбец1 + 1) И (Ряд2 > Ряд1 + 1) тогда
			КартинкаПрямоугольник(ПараметрыКартинки, Столбец1 + 1, Ряд1 + 1, Столбец2 - 1, Ряд2 - 1, ЦветФона, ЦветФона);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура ПоменятьМестамиЗначения(Переменная1, Переменная2)
	ВременнаяПеременная = Переменная1;
	Переменная1 		= Переменная2;
	Переменная2 		= ВременнаяПеременная;
КонецПроцедуры
 
Функция ПолучитьПалитруПоУмолчанию()
	Палитра = Новый Массив(2);
	Палитра[0] = Новый Цвет(0,0,0); //БЕЛЫЙ
	Палитра[1] = Новый Цвет(255,255,255); //ЧЕРНЫЙ
	Возврат Палитра;
КонецФункции

Функция ПолучитьКодЛинейногоШК(Знач ТекстШтрихкода, ТипШтрикхода)
	Если ТипШтрикхода = "CODE39" тогда
		Возврат Штрихкод_CODE39(ТекстШтрихкода);
	ИначеЕсли ТипШтрикхода = "EAN8" тогда
		Возврат Штрихкод_EAN8(ТекстШтрихкода);
	ИначеЕсли ТипШтрикхода = "EAN13" тогда
		Возврат Штрихкод_EAN13(ТекстШтрихкода);
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции

Функция Штрихкод_CODE39(ТекстШтрихкода)
	
	СимволыКод39 = СоответствиеКод39();
	
	ИтоговаяСтрока = "";
	Для Сч = 1 ПО СтрДлина(ТекстШтрихкода) Цикл
		Код39 = СимволыКод39[ВРег(СимволСтроки(ТекстШтрихкода, Сч))];
		Если Код39 = Неопределено Тогда
			Возврат "";
		КонецЕсли;
		ИтоговаяСтрока = ИтоговаяСтрока + Код39;
	КонецЦикла;
	
	Возврат СимволыКод39["*"] + ИтоговаяСтрока + СимволыКод39["*"];
	
КонецФункции

Функция Штрихкод_EAN8(ТекстШтрихкода)
		
	Если СтрДлина(ТекстШтрихкода)=8 тогда
		ТекстШтрихкода = Лев(ТекстШтрихкода,7);
	ИначеЕсли СтрДлина(ТекстШтрихкода)<>7 тогда
		//Данные штрикхода не подходят под этот тип
		Возврат "";
	КонецЕсли;
	
	КодыEAN8 = КодыEAN8();

	КонтрольныйСимвол = 0;
	
	ЛеваяЧасть = "";
	Для ПозицияЭлемента = 1 по 4 цикл
		СимволШтрихкода = СимволЧисло(ТекстШтрихкода, ПозицияЭлемента);
		КонтрольныйСимвол = КонтрольныйСимвол + СимволШтрихкода*((ПозицияЭлемента%2)*2+1);
		ЛеваяЧасть = ЛеваяЧасть + КодыEAN8[СимволШтрихкода];
	КонецЦикла;
	
	ПраваяЧасть = "";
	Для ПозицияЭлемента = 5 по 7 цикл
		СимволШтрихкода = СимволЧисло(ТекстШтрихкода, ПозицияЭлемента);
		КонтрольныйСимвол = КонтрольныйСимвол + СимволШтрихкода*((ПозицияЭлемента%2)*2+1);
		ПраваяЧасть = ПраваяЧасть + КодыEAN8[СимволШтрихкода];
	КонецЦикла;
	КонтрольныйСимвол = (10 - КонтрольныйСимвол %10)%10;
	
	Возврат KSOFT_ОбщегоНазначения.ККТ_СтрШаблон("111%111111%2%3111", ЛеваяЧасть, ПраваяЧасть, КодыEAN8[КонтрольныйСимвол]);
	
КонецФункции

Функция Штрихкод_EAN13(ТекстШтрихкода)
	
	Если СтрДлина(ТекстШтрихкода) = 13 тогда
		ТекстШтрихкода = Лев(ТекстШтрихкода,12);
	ИначеЕсли СтрДлина(ТекстШтрихкода)<> 12 тогда
		Возврат "";
	КонецЕсли;
	
	КодыEAN8 = КодыEAN8();
	КодыEAN13 = КодыEAN13();
	
	КонтрольныйСимвол = СимволЧисло(ТекстШтрихкода,1);
	КодEAN13 = КодыEAN13[КонтрольныйСимвол];
	
	ЛеваяЧасть = "";
	Для ПозицияЭлемента = 2 по 7 цикл
		СимволШтрихкода = СимволЧисло(ТекстШтрихкода, ПозицияЭлемента);
		КонтрольныйСимвол = КонтрольныйСимвол + СимволШтрихкода*(((ПозицияЭлемента+1)%2)*2+1);
		КодEAN8 = КодыEAN8[СимволШтрихкода];
		ПредыдущийСимвол = Сред(КодEAN13, ПозицияЭлемента - 1, 1);
		ЛеваяЧасть = ЛеваяЧасть + ?(ПредыдущийСимвол = "0", КодEAN8, СтрокаВОбратномПорядке(КодEAN8));
	КонецЦикла;
	
	ПраваяЧасть = "";
	Для ПозицияЭлемента = 8 по 12 цикл
		СимволШтрихкода = Число(Сред(ТекстШтрихкода, ПозицияЭлемента, 1));
		КонтрольныйСимвол = КонтрольныйСимвол + СимволШтрихкода * (((ПозицияЭлемента+1)%2)*2+1);
		ПраваяЧасть = ПраваяЧасть + КодыEAN8[СимволШтрихкода];
	КонецЦикла;
	КонтрольныйСимвол = (10 - КонтрольныйСимвол%10)%10;
	
	Возврат KSOFT_ОбщегоНазначения.ККТ_СтрШаблон("111%111111%2%3111", ЛеваяЧасть, ПраваяЧасть, КодыEAN8[КонтрольныйСимвол]);
	
КонецФункции

Функция СтрокаВОбратномПорядке(Знач ДанныеСтроки)
	
	РезультирующаяСтрока = "";
	КоличествоСимволов = СтрДлина(ДанныеСтроки);
	Для Сч = 0 ПО КоличествоСимволов - 1 Цикл
		РезультирующаяСтрока = РезультирующаяСтрока + СимволСтроки(ДанныеСтроки, КоличествоСимволов - Сч);
	КонецЦикла;
	
	Возврат РезультирующаяСтрока;
	
КонецФункции

Функция КодыEAN8()
	
	КодыEAN8 = Новый Массив(10);
	КодыEAN8[0] = "3211";
	КодыEAN8[1] = "2221";
	КодыEAN8[2] = "2122";
	КодыEAN8[3] = "1411";
	КодыEAN8[4] = "1132";
	КодыEAN8[5] = "1231";
	КодыEAN8[6] = "1114";
	КодыEAN8[7] = "1312";
	КодыEAN8[8] = "1213";
	КодыEAN8[9] = "3112";
	Возврат КодыEAN8;	
	
КонецФункции

Функция КодыEAN13()
	
	КодыEAN13 = Новый Массив(10);
	КодыEAN13[0] = "000000";
	КодыEAN13[1] = "001011";
	КодыEAN13[2] = "001101";
	КодыEAN13[3] = "001110";
	КодыEAN13[4] = "010011";
	КодыEAN13[5] = "011001";
	КодыEAN13[6] = "011100";
	КодыEAN13[7] = "010101";
	КодыEAN13[8] = "010110";
	КодыEAN13[9] = "011010";
	Возврат КодыEAN13;	
	
КонецФункции

Функция КэшБайтов() 
	КэшБайтов = KSOFT_ОбщегоНазначения.ПолучитьВременноеЗначениеОборудования("КэшБайтов");
	Если КэшБайтов <> Неопределено Тогда
		Возврат КэшБайтов;
	КонецЕсли; 
	
	КэшБайтов = Новый Соответствие;	
	Для Сч = 0 По 64 Цикл
		КэшБайтов.Вставить(Сч, Pow(2, Сч));
	КонецЦикла; 
	KSOFT_ОбщегоНазначения.СохранитьВременноеЗначениеОборудования("КэшБайтов", КэшБайтов);
	Возврат КэшБайтов;
КонецФункции

Процедура ЗаписьДанныхЗаписатьБайт(Тело, ЧислоДоПреобразованияВБайты)
	ЗаписатьБайтыВПотокИСдвинутьПозицию(Тело, МассивБайтовПоЧислу(ЧислоДоПреобразованияВБайты, 1));
КонецПроцедуры

Процедура ЗаписатьБайтыВПотокИСдвинутьПозицию(Тело, Байты)
	Для Сч = 0 По Байты.Количество() - 1  Цикл
		Если Тело.ТекущаяПозиция > Тело.Байты.Количество() - 1 Тогда
			Тело.Байты.Добавить(0);
		КонецЕсли; 
		Тело.Байты[Тело.ТекущаяПозиция] = Байты[Сч]; //копируем массив чисел "байты" в хранилище байтов ("тело")  
		Тело.ТекущаяПозиция = Тело.ТекущаяПозиция + 1;//Сдвигаем позицию виртуального курсора
	КонецЦикла; 
КонецПроцедуры

Функция ЗаписьДанныхПотокВПамяти(Размер = 0)
	Если ЗначениеЗаполнено(Размер) Тогда
		Возврат Новый Структура("ТекущаяПозиция, Байты, Размер", 0, Новый Массив(Размер), 0);
	Иначе
		Возврат Новый Структура("ТекущаяПозиция, Байты, Размер", 0, Новый Массив(), 0);
	КонецЕсли; 	
КонецФункции

Функция МассивБайтовПоЧислу(ЧислоДоПреобразованияВБайты, КоличествоБайт, Направление = "BigEndian")
	
	Если НЕ ЗначениеЗаполнено(КоличествоБайт) Тогда
		Возврат Новый Массив;
	КонецЕсли; 
	
	КэшБайтов = КэшБайтов();
	БайтыЧисла = Новый Массив(КоличествоБайт);
	БайтыЧисла[0] = ЧислоДоПреобразованияВБайты % КэшБайтов[8]; //Первый байт остаток от деления	
	Для Сч = 1 По КоличествоБайт - 2 Цикл
		БайтыЧисла[Сч] = Цел((ЧислоДоПреобразованияВБайты % КэшБайтов[8*(Сч + 1)]) / КэшБайтов[8*Сч]);
	КонецЦикла; 
	
	Если КоличествоБайт > 1 Тогда
		БайтыЧисла[КоличествоБайт - 1] = Цел(ЧислоДоПреобразованияВБайты/ КэшБайтов [8*(КоличествоБайт-1)]) % КэшБайтов[8];	
	КонецЕсли; 
	
	Если Направление = "BigEndian" Тогда //Обратный порядок байтов
		БайтыЧислаОбратныйПорядок = Новый Массив(КоличествоБайт);
		Для Сч = 1 По КоличествоБайт Цикл
			БайтыЧислаОбратныйПорядок[Сч - 1] = БайтыЧисла [КоличествоБайт - Сч];  
		КонецЦикла;
		Возврат БайтыЧислаОбратныйПорядок;
	КонецЕсли; 
	
	Возврат БайтыЧисла;
КонецФункции

Процедура ЗаписьДанныхЗаписатьЦелое64(Тело, ЗначениеЧисла, пПорядокБайтов = "BigEndian")
	ЗаписатьБайтыВПотокИСдвинутьПозицию(Тело, МассивБайтовПоЧислу(ЗначениеЧисла, 8, пПорядокБайтов));
КонецПроцедуры

Процедура ЗаписьДанныхЗаписатьЦелое32(Тело, ЧислоДоПреобразованияВБайты, пПорядокБайтов = "BigEndian")
	ЗаписатьБайтыВПотокИСдвинутьПозицию(Тело, МассивБайтовПоЧислу(ЧислоДоПреобразованияВБайты, 4, пПорядокБайтов));
КонецПроцедуры

Процедура ЗаписьДанныхЗаписатьЦелое16(Тело, ЧислоДоПреобразованияВБайты, пПорядокБайтов = "BigEndian")
	ЗаписатьБайтыВПотокИСдвинутьПозицию(Тело, МассивБайтовПоЧислу(ЧислоДоПреобразованияВБайты, 2, пПорядокБайтов));
КонецПроцедуры

Процедура ЗаписьДанныхЗаписатьСимволы(Тело, Символы, Кодировка = "ASCII")
	КоличествоСимволов = СтрДлина(Символы);
	Если НЕ ЗначениеЗаполнено(КоличествоСимволов) Тогда
		Возврат;
	КонецЕсли; 
	Если Кодировка = "ASCII" Тогда //Каждый символ это 1 байт, значение символа получается командой кодсимвола
		БайтыСимволов = Новый Массив(КоличествоСимволов);
		Для Сч = 1 По КоличествоСимволов Цикл
			БайтыСимволов [Сч - 1] = МассивБайтовПоЧислу(КодСимвола(Символы, Сч), 1)[0];
		КонецЦикла; 
		ЗаписатьБайтыВПотокИСдвинутьПозицию(Тело, БайтыСимволов);
	КонецЕсли; 
КонецПроцедуры

// Функция выполняет подключение внешней компоненты и ее первоначальную настройку.
// Возвращаемое значение: НЕОПРЕДЕЛЕНО - компоненту не удалось загрузить.
Функция ПолучитьКартинкуQrКода(пШтрихкод, пШирина)
	Попытка
		Возврат Новый Картинка(УправлениеПечатью.ДанныеQRКода(пШтрихкод, 3, пШирина));
	Исключение
	КонецПопытки;
	Возврат Неопределено;
КонецФункции

// Функция выполняет формирование изображения штрихкода.
// Параметры: 
//   ПараметрыШтрихкода 
// Возвращаемое значение: 
//   Картинка - Картинка со сформированным штрихкодом или НЕОПРЕДЕЛЕНО.
Функция ПолучитьКартинкуШтрихкода(ПараметрыШтрихкода) Экспорт	
	Если ПараметрыШтрихкода.ТипКода <> 16 Тогда
		 Возврат KSOFT_Штрихкодирование.ПолучитьКартинкуЛинейногоШК(ПараметрыШтрихкода.Штрихкод, ПараметрыШтрихкода.ТипКода, ПараметрыШтрихкода.Ширина, ПараметрыШтрихкода.Высота);
	Иначе	 
		 Возврат ПолучитьКартинкуQrКода(ПараметрыШтрихкода.Штрихкод, ПараметрыШтрихкода.Ширина);
	КонецЕсли; 
КонецФункции	