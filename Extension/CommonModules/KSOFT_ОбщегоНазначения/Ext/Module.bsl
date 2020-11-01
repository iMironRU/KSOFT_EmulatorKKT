﻿Процедура СохранитьВременноеЗначениеОборудования(ИмяПараметра, ЗначениеПараметра) Экспорт 
	ХранилищеОбщихНастроек.Сохранить("KSOFT_ЭмуляторККТ_54_ФЗ", ИмяПараметра + "_" + ИдентификаторКлиента(), ЗначениеПараметра);	
КонецПроцедуры
 
Функция ПолучитьВременноеЗначениеОборудования(ИмяПараметра) Экспорт
	Возврат ХранилищеОбщихНастроек.Загрузить("KSOFT_ЭмуляторККТ_54_ФЗ", ИмяПараметра + "_" + ИдентификаторКлиента());
КонецФункции

Функция ККТ_СтрШаблон(Знач ШаблонСтроки,
	Знач Параметр1, Знач Параметр2 = Неопределено, Знач Параметр3 = Неопределено,
	Знач Параметр4 = Неопределено, Знач Параметр5 = Неопределено, Знач Параметр6 = Неопределено,
	Знач Параметр7 = Неопределено, Знач Параметр8 = Неопределено, Знач Параметр9 = Неопределено) Экспорт
		
	ШаблонСтроки = СтрЗаменить(ШаблонСтроки, "%1", Параметр1);
	ШаблонСтроки = СтрЗаменить(ШаблонСтроки, "%2", Параметр2);
	ШаблонСтроки = СтрЗаменить(ШаблонСтроки, "%3", Параметр3);
	ШаблонСтроки = СтрЗаменить(ШаблонСтроки, "%4", Параметр4);
	ШаблонСтроки = СтрЗаменить(ШаблонСтроки, "%5", Параметр5);
	ШаблонСтроки = СтрЗаменить(ШаблонСтроки, "%6", Параметр6);
	ШаблонСтроки = СтрЗаменить(ШаблонСтроки, "%7", Параметр7);
	ШаблонСтроки = СтрЗаменить(ШаблонСтроки, "%8", Параметр8);
	ШаблонСтроки = СтрЗаменить(ШаблонСтроки, "%9", Параметр9);
	Возврат ШаблонСтроки;
	
КонецФункции

Функция ККТ_СтрСоединить(МассивСтрок, пРазделитель) Экспорт
	ИтоговаяСтрока = "";
	Для Каждого СтрокаТекста Из МассивСтрок Цикл
		Если ПустаяСтрока(ИтоговаяСтрока) Тогда
			ИтоговаяСтрока = СтрокаТекста;
		Иначе
			ИтоговаяСтрока = Строка(ИтоговаяСтрока) + пРазделитель + СтрокаТекста;
		КонецЕсли; 	
	КонецЦикла; 
	Возврат ИтоговаяСтрока;
КонецФункции

Функция ПараметрСуществуетИНЕРавенЗначению(пПараметры, пИмяПараметры, пЗначение) Экспорт
	Возврат пПараметры.Свойство(пИмяПараметры) И НЕ пПараметры [пИмяПараметры] = пЗначение; 	
КонецФункции

Функция ПараметрСуществуетИРавенЗначению(пПараметры, пИмяПараметры, пЗначение) Экспорт
	Возврат пПараметры.Свойство(пИмяПараметры) И пПараметры [пИмяПараметры] = пЗначение; 	
КонецФункции

Функция ПараметрСуществуетИЗаполнен(пПараметры, пИмяПараметры) Экспорт
	Если ТипЗнч(пПараметры) <> Тип("Структура") Тогда
		Возврат Ложь;
	КонецЕсли; 
	
	Возврат пПараметры.Свойство(пИмяПараметры) И 
		ЗначениеЗаполнено(пПараметры [пИмяПараметры]);
КонецФункции

Функция ККТ_СтрЗаканчиваетсяНа(пСтрока, КонецСтроки) Экспорт
	Возврат СокрЛП(КонецСтроки) = Прав(СокрЛП(пСтрока), СтрДлина(СокрЛП(КонецСтроки)))	
КонецФункции

Функция ПолучитьТипОС()
	ДанныеСистемы = Новый СистемнаяИнформация;
	Попытка
		Если ДанныеСистемы.ТипПлатформы = Вычислить("ТипПлатформы.Linux_x86") 
			ИЛИ ДанныеСистемы.ТипПлатформы = Вычислить("ТипПлатформы.Linux_x86_64") Тогда
			Возврат "LINUX";
		КонецЕсли;
	Исключение
	КонецПопытки;
	Возврат "WINDOWS";
КонецФункции

Функция ПоддержкаФункционалаПлатформой1С() Экспорт 
	ПоддержкаФункционалаПлатформой1С = ПолучитьВременноеЗначениеОборудования("ПоддержкаФункционалаПлатформой1С");
	Если ПоддержкаФункционалаПлатформой1С = Неопределено Тогда
		ПоддержкаФункционалаПлатформой1С = Новый Структура;
		ВерсияПлатформыЧисло = ВерсияПлатформыВЧисло();
		ПоддержкаФункционалаПлатформой1С.Вставить("ПоддержкаJSON", ВерсияПлатформыЧисло > 80300600000); //8.3.6
		ПоддержкаФункционалаПлатформой1С.Вставить("HTTPСоединениеНовогоФормата", ВерсияПлатформыЧисло > 80201800000); //8.2.18 Поддержка Таймаут
		ПоддержкаФункционалаПлатформой1С.Вставить("МожноИспользоватьCOM", ПолучитьТипОС() = "WINDOWS");
		СохранитьВременноеЗначениеОборудования("ПоддержкаФункционалаПлатформой1С", ПоддержкаФункционалаПлатформой1С);
	КонецЕсли; 
	
	Возврат ПоддержкаФункционалаПлатформой1С;
КонецФункции

Функция ВерсияПлатформыВЧисло()
	ПоляВерсии = ККТ_СтрРазделить(ВерсияПлатформы(), ".");  
	Возврат Число(ПоляВерсии[0]) * 100 * 1000 * 100000 + Число(ПоляВерсии[1]) * 1000 * 100000 + Число(ПоляВерсии[2])*100000 + Число(ПоляВерсии[3]);		
КонецФункции

Функция ВерсияПлатформы()
	Попытка
		лСИ = Вычислить("Новый СистемнаяИнформация");
		Возврат лСИ.ВерсияПриложения;
	Исключение
		Возврат "8.0.0.000";
	КонецПопытки;
КонецФункции

Функция ККТ_СтрРазделить(Знач пСтрока, Знач пРазделитель = ",", пВключатьПустые = Истина) Экспорт
	
	лМассив = Новый Массив;
	лНесколькоСтрок = СтрЗаменить(пСтрока, пРазделитель, Символы.ПС);
	Для Сч = 1 По СтрЧислоСтрок(лНесколькоСтрок) Цикл
		лСтрока = СтрПолучитьСтроку(лНесколькоСтрок, Сч);
		Если ПустаяСтрока(лСтрока) И НЕ пВключатьПустые Тогда
			Продолжить;
		КонецЕсли; 
		лМассив.Добавить(лСтрока);
	КонецЦикла; 
	Возврат лМассив;
	
КонецФункции 

Функция ККТ_СтруктураЗаполнена(ДанныеСтруктуры) Экспорт
	Если ДанныеСтруктуры = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли; 
	Для Каждого ЭлементСтруктуры Из ДанныеСтруктуры Цикл
		Если ЗначениеЗаполнено(ЭлементСтруктуры.Значение) Тогда
			Возврат Истина;			
		КонецЕсли; 
	КонецЦикла; 
	Возврат Ложь
КонецФункции
 
Функция ИдентификаторКлиента()
	СИ = Новый СистемнаяИнформация;
	Возврат СтрЗаменить(Строка(СИ.ИдентификаторКлиента), "-", "");
КонецФункции
 