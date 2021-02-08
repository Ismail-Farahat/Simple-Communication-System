%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  COMMNUNICATION SYSTEM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear,clc,close all
%%%%%%%%%%%%%%%%%  TRANSMITTER  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf("===============  TRANSMITTER  =================== \n");
% Read The Audio , Fs and Ns
file_name = input("Please, Enter The Audio Name : ",'s');
[y, Fs] = audioread(file_name);       % Fs: Sampling Frequency
% to cut the signal
fprintf("Please, Enter the duration you want to cut from the audio, \n");
es = input("If you want the entire duration Press 'a', Duration = ", 's');
if es ~= 'a'
    es = str2double(es);
    y = y(1:es*Fs,:);
end
Ns = size(y,1);                     % Samples Number

% Play The Audio
fprintf("AUDIO PLAYING ON: Transmitter \n");
sound(y,Fs);
pause(Ns/Fs) % pausing to have some time between playing audios
fprintf("AUDIO PLAYING OFF: Transmitter \n");

% Generate Time, end time = Ns/Fs
t = linspace(0, Ns/Fs, Ns);

% Plot the audio in Time Domain
plot(t,y);
xlabel('Time (S)');
ylabel('Magnitude');
title("Audio Plot in Time Domain");

% Plot the audio in Frequency Domain
Pvec = linspace(-Fs/2,Fs/2,Ns);     % Frequency values on x-axis
Y = fftshift(fft(y));               % Fourier Transform

figure;                             
plot(Pvec, abs(Y))                  % Plot the Magnatuide
xlabel('Frequency (Hz)');
ylabel('Magnitude Spectrum');
title("Audio Plot (Frequency Magnatuide VS Frequency)");
figure;
plot(Pvec, angle(Y))                % Plot the Phase
xlabel('Frequency (Hz)');
ylabel('Phase Spectrum');
title("Audio Plot (Frequency Phase VS Frequency)");

%%%%%%%%%%%%%%%%%  CHANNEL  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf("===============  CHANNEL  =================== \n");

fprintf("Enter '1' : delta function \n");
fprintf("Enter '2' : exp(-2*pi*5000t)\n");
fprintf("Enter '3' : exp(-2*pi*1000t)\n");
fprintf("Enter '4' : 2 delta(n) + 0.5 delta(n-1) \n");

channel = input("Please, Enter The Channel Impulse Response : ");

if channel == 1
    ch = t==0;                                % delta function
    elseif channel == 2
        ch = exp(-2*pi*5000*t);               % exp(-2*pi*5000t)
        elseif channel == 3
            ch = exp(-2*pi*1000*t);           % exp(-2*pi*1000t)
            elseif channel == 4
                delta_1 = 2 * [1 zeros(1,size(t,2)-1)];
                delta_2 = 0.5 * [zeros(1,size(t,2)/2) 1 zeros(1,size(t,2)/2-1)];
                ch = delta_1 + delta_2;
                % 2 delta(t) + 0.5 delta(t-es)
end

% Convolution the signal with impulse response in the channel
ch_left =  conv(y(:,1)',ch);        % Left Channel Convolution

% taking the first Ns samples from the convolution result
channel_signal = ch_left';
channel_signal_freq = fftshift(fft(channel_signal));  % Frequency Domain

% update some info before continue
Ns = size(channel_signal,1);
t = linspace(0, Ns/Fs, Ns);
Pvec = linspace(-Fs/2,Fs/2,Ns);     % Frequency values on x-axis

% Plot the audio in Time Domain
figure
plot(t,channel_signal);
xlabel('Time (S)');
ylabel('Magnitude');
title("Audio Plot in Time Domain (Channel)");
% plot the signal in frequency domain
figure;                             % Plot the Magnatuide
plot(Pvec, abs(channel_signal_freq))                  
xlabel('Frequency (Hz)');
ylabel('Magnitude Spectrum');
title("Audio Plot (Frequency Magnatuide VS Frequency) (Channel)");
figure;                             % Plot the Phase
plot(Pvec, angle(channel_signal_freq))                
xlabel('Frequency (Hz)');
ylabel('Phase Spectrum');
title("Audio Plot (Frequency Phase VS Frequency) (Channel)");

% play the audio after passing the channel
fprintf("AUDIO PLAYING ON: Channel Output \n");
sound(channel_signal,Fs)
pause(Ns/Fs) % pausing to have some time between playing audios
fprintf("AUDIO PLAYING OFF: Channel Output \n");

%%%%%%%%%%%%%%%%%  NOISE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf("===============  NOISE  =================== \n");
% get the sigma value from the user
sigma = input("Please, Enter The Value of Sigma = ");

% generate noise (normal dist. with mean = 0 and variance = 1 )
noise = sigma * rand(1,Ns);
% add the noise to the signal (time domain)
noise_signal = channel_signal + noise';  
% noise signal in frequency domain
noise_signal_freq = fftshift(fft(noise_signal));

% plot the signal in time domain
figure;
plot(t,noise_signal)
xlabel('Time (S)');
ylabel('Magnitude');
title("Audio Plot in Time Domain (With Noise)");
% plot the signal in frequency domain
figure;                             % Plot the Magnatuide
plot(Pvec, abs(noise_signal_freq))                  
xlabel('Frequency (Hz)');
ylabel('Magnitude Spectrum');
title("Audio Plot (Frequency Magnatuide VS Frequency) (With Noise)");
figure;                             % Plot the Phase
plot(Pvec, angle(noise_signal_freq))                
xlabel('Frequency (Hz)');
ylabel('Phase Spectrum');
title("Audio Plot (Frequency Phase VS Frequency) (With Noise)");

% play the audio with noise
fprintf("AUDIO PLAYING ON: Signal with Noise \n");
sound(noise_signal,Fs)
pause(Ns/Fs+2) % pausing to have some time between playing audios
fprintf("AUDIO PLAYING OFF: Signal with Noise \n");

%%%%%%%%%%%%%%%%%  Filter  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf("===============  FILTER  =================== \n");
Pvec = linspace(-Fs/2,Fs/2,Ns);             % Frequency values on x-axis
signal_freq = fftshift(fft(noise_signal));  % signal in frequency domian

% number of samples that will be filtered from both sides of the signal
n_filter = floor((Ns/Fs) * (Fs/2 - 3400));         % 3400 Hz
% LOW PASS Filter
lowpass_filter = ones(size(Pvec,2),1);
% to make low pass filter (frequency domain)
lowpass_filter([(1:n_filter) (end-n_filter+1:end)]) = 0;
% to filter the signal to pass only low frequencies (>3400 Hz)
filtered_signal_freq = lowpass_filter .* signal_freq;
% signal in time domian after passing low pass filter
filtered_signal_time = abs(ifft(filtered_signal_freq));

% plot the final signal in time domain
figure;
plot(t, filtered_signal_time)      
xlabel('Time (S)');
ylabel('Magnitude');
title("Audio Plot in Time Domain (After Filter)");
% plot the signal in frequency domain
figure                          % plot the signal magnatuide 
plot(Pvec, abs(filtered_signal_freq))
xlabel('Frequency (Hz)');
ylabel('Magnitude Spectrum');
title("Audio Plot (Frequency Magnitude VS Frequency) (After Filter)");
figure;                         % Plot the Phase
plot(Pvec, angle(filtered_signal_freq))                
xlabel('Frequency (Hz)');
ylabel('Phase Phase');
title("Audio Plot (Frequency Phase VS Frequency) (After Filter)");

% Play the audio after Filter
fprintf("AUDIO PLAYING ON: Signal After Filter \n");
sound(filtered_signal_time,Fs)
pause(Ns/Fs) % pausing to have some time between playing audios
fprintf("AUDIO PLAYING OFF: Signal After Filter \n");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  THE END  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%