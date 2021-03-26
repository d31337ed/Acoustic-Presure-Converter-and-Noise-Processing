% Функция, реализующая алгоритмы вычисления уровня шумов в нормированном сигнале в заданном диапазоне частот  

function [levels, f1, f2, Tavg] = noiseLevelCalculator(inputFileName,dataPa,Fs,lowerFreq,upperFreq,Tavg,plotFlag,outputFolder,plotLowFreq,plotUpFreq)

% ВХОДНЫЕ ПАРАМЕТРЫ:
% inputFileName - полный путь к файлу для обработки
% lowerFreq и upperFreq - границы полосы частот для измерения
% Tavg - время усреднения
% plotFlag - когда 1 - строится спектрограмма
% ВЫХОД ФУНКЦИИ:
% levels - уровни шумов во временных окнах длительностью Tavg

% Считывание входного файла и его частоты дискретизации
%[data,Fs] = audioread(inputFileName);
data = dataPa;
outputFileName = strcat(outputFolder,'\','spectrogram_',erase(inputFileName,'.wav'),'.png');

% Построение спектрограммы (при необходимости)
if plotFlag == 'savespec'
    spectrogram(data,rectwin(Fs),0,1:Fs/2,Fs) 
    h = colorbar;
    h.Label.String = 'Уровни шума,  дБ(Па^2/Гц)';
    xlim([plotLowFreq/1000 plotUpFreq/1000])
    title(['Спектрограмма записи ' inputFileName],'Interpreter','none')
    xlabel('Частота, кГц')
    ylabel('Время, минуты')
    print(gcf,outputFileName,'-dpng','-r800'); 
   % saveas(gcf,outputFileName)
end 

% Генерация матрицы спектральной плотности мощности от отсчётов сигнала с длиной окна равной частоте дискретизации (df = 1 Гц, dt = 1c), без
% перекрытия, нормированную на диапазон до половины частоты дискретизации 
[~,f,t,ps] = spectrogram(data,Fs,0, 1:Fs/2 ,Fs);  
ps = ps*2;                                          % Чтобы не терять энергию, домножаем компоненты на 2

% save(replace(outputFileName,'png','mat'),'ps');

if lowerFreq<min(f) || lowerFreq>max(f)
    disp(['Нижняя граница частоты должна быть числом от ', num2str(min(f)),' Гц до ',num2str(max(f)),' Гц'])
    return
end
if upperFreq<min(f) || upperFreq>max(f)
    disp(['Нижняя граница частоты должна быть числом от ', num2str(min(f)),' Гц до ',num2str(max(f)),' Гц'])
    return
end

%  Вычисление дискретов по частотам и времени
df = (max(f) - min(f))/ (length(f)-1);      % Вычисление шага по частоте
% Нахождение ближайших к требуемым дискретам по частоте
freqStart  = find( abs(f-lowerFreq) < df/2);
freqFinish = find( abs(f-upperFreq) < df/2);
f1 = f(freqStart);
f2 = f(freqFinish);

if abs(f-lowerFreq) ~= 0
    disp(['Нижняя граница частоты была скорректирована до ближайшего дискрета пребразования Фурье: ',num2str(f1),' Гц'])
end
if abs(f-upperFreq) ~= 0
    disp(['Верхняя граница частоты была скорректирована до ближайшего дискрета пребразования Фурье: ',num2str(f2),' Гц'])
end

dt = (max(t) - min(t))/ (length(t)-1); % Вычисление шага по частоте

% Проверка и округление (при необходимости) длительности окна. 
% Чтобы оно ложилось на целое число дискретов по времени
if mod(size(ps,2),Tavg) ~= 0
    Tavg = round(Tavg);
    disp(['Время усреднения не укладывается в целое число дискретов, оно было округлено до ',num2str(Tavg),' с'])
end

numOfWindows = floor(size(ps,2)/Tavg); % Число окон
levels = zeros(1,numOfWindows);        % Предопределение массива значений уровня шума


  for k = 1:numOfWindows                                                       % Цикл по всем окнам
    timeStart     = 1 + (k-1)*(Tavg/dt);                                       % Начало текущего окна, в отсчётах
    timeFinish    = k*(Tavg/dt);                                               % Конец текущего окна, в отсчётах
    currentWindow = (ps( freqStart:freqFinish , timeStart:timeFinish ));       % Текущее окно по времени и частоте
    energy        = sum(sum(currentWindow));                                   % Энергия в текущем окне                                    
    power         = energy/(Tavg/dt);                                          % Мощность в текущем окне                             
    levels(k)     = sqrt(power);                                               % Усреднение амплитуды в данном окне
  end
    
end
