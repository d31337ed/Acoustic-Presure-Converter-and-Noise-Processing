import numpy as np
import wave
import soundfile as sf
import os
import math
#import getEASDA14header.py
import PySimpleGUI as sg

layout = [
    [sg.Text('Папка с исходными файлами (.wav, отсчёты с рекордера)'), sg.InputText('D:/MATLAB/V_Pa_Converter/src'), sg.FolderBrowse()],
    [sg.Text('Папка, куда положить результат (.wav, Па)                       '), sg.InputText('D:/MATLAB/V_Pa_Converter/res'), sg.FolderBrowse()],
    [sg.Checkbox('Записи сделаны в режиме low power')],
    [sg.Output(size=(84, 10)),sg.Submit('Конвертировать',size=(14,10))]
]
window = sg.Window('Конвертер записей с EA-SDA14 в Паскали', layout)
while True:                             # The Event Loop
    event, values = window.read()
    srcFolder = values[0]
    resFolder = values[1]
    lowPower  = values[2]
    sensdB = -154.5
    os.chdir(srcFolder)
    srcFiles = os.listdir(srcFolder)
    print('Число найденных файлов в папке: ',len(srcFiles))
    resFiles = os.listdir(resFolder)

    for idx,file in enumerate(srcFiles):
        print('В обработке файл №',idx+1,'из ',len(srcFiles))
        wav = wave.open(file, mode="r")
        (nchannels, sampwidth, framerate, nframes, comptype, compname) = wav.getparams()
        content = wav.readframes(nframes)
        samples = np.frombuffer(content,int)
#        nofchannels, channeln, sensitivity, bitpersample, gain1, gain2 = getEASDA14header(file)
        # TODO: вызвать функцию считывания заголовка
 #       print(samples)
        if lowPower:
            # TODO: заменить разрядность, когда научучь считывать заголовки
            volts = (math.sqrt(2)/(2*(2**32-1)))*samples
        else:
            # TODO: заменить коэффициенты усиления, когда научучь считывать заголовки
            volts = (2.5*samples)/(2*(2**32-1))

        sensVPa = (10 ** (sensdB / 20)) * (10 ** 6)
        Pa = volts/sensVPa

        outputFileName = resFolder + '/PA_new_' + file   # Имя выходного файла
        sf.write(outputFileName, Pa, 16000, 'PCM_32')    # Запись выходного файла
    if event in (None, 'Exit', 'Cancel'):
       break
# TODO: уведомление о завершении процесса

