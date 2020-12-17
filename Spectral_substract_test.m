%Spectral Substract Algorithm
%created: 2020-12-13 20:30:28
%Author: HJR
clc 
clear all
close all
[y_two,Fs]=audioread('Eng1234567.wav');

y=y_two(:,2);%single sound channel
% y=y_two;
N=length(y);     %Length of input signal
wlen=256;
N_overlap=128;
Nbr_frame=floor(N/wlen);
Yk_angle=zeros(Nbr_frame,wlen);
nfft=1024;
x_win=zeros(Nbr_frame,wlen);%all frame data
x_single=zeros(1,wlen);%single frame data
% spectrogram(y(1:2400),hamming(wlen),wlen-1,nfft,Fs,'yaxis')
% title('Spectrogram'); 


%% Noise Estimate using nonspeech section
    x_single=y(1:2560);
    h=hamming(length(x_single));
    yn=h.*x_single;
    Yk=abs(fft(yn));
    Miuk=OTA_Noise_estimator(Yk,length(Yk));
    Miuk_win=Miuk(1:10:end);
    Miuk_max=max(Miuk_win);
    
%% Data segemented and windowed
%8kHz,0.125ms,segmented in to 10~30ms,Length of
%Frame=256,Period=32ms,overlapping length =128
Yk_org=[];
for i=1:Nbr_frame
    x_win(i,:)=y(((i-1)*128+1):((i-1)*128+256));%Current Frame
    x_single=x_win(i,:);
    h=hamming(wlen);
    yn=h'.*x_single;
    Yk=abs(fft(yn));
    Yk_angle(i,:)=angle(fft(yn));
    for j=1:wlen    % Subtract Bias
       tmp=Yk(j)-Miuk_win(j);
        if(tmp<0)
            s(i,j)=0;%Half-wave Rectify
        else
            s(i,j)=tmp;
        end
    end
    Yk_org=[Yk_org Yk];
end
stem(Yk_org,'.');hold on;
%% residual removal using three adjacent frames
% for i=1:Nbr_frame
%     for j=1:wlen
%         if(i>3&&i<Nbr_frame-3)
%             if(s(i,j)<Miuk_max)
%                 s(i,j)=min([s(i-1,j),s(i,j),s(i+1,j)]);
%             else
%                 s(i,j)=s(i,j);
%             end
%         end
%     end
% end
s_mod=[];
%% addtional signal attenuation during nonspeech activity
%To detect the presence of speech activity in each frame
for i=1:Nbr_frame
    T=0;
    for j=1:wlen
        T=T+abs(s(i,j)/Miuk_win(j))/(2*pi);
    end
    if(20*log10(T)<=-12)
        %classified as no speech activity in this frame
        s(i,:)=s(i,:)*(10^(-1.5));% s is still a magnitude sequence
    end
    s_mod=[s_mod s(i,:)];
end
stem(s_mod,'.');legend('org','mod');hold off
y_win=zeros(1,wlen);
yn_out=[];
%% Final:IFFT
for i=1:Nbr_frame
%     for j=1:wlen
    Yk2=abs(s(i,:)).*cos(Yk_angle(i,:))+1j*abs(s(i,:)).*sin(Yk_angle(i,:));
    y_win(i,:)=ifft(Yk2);
    yn_out=[yn_out y_win(i,:)];
end
% plot(yn_out);title('Y(n)');

figure
subplot(211);spectrogram(y,hamming(wlen),wlen-1,nfft,Fs,'yaxis');title('Original');
subplot(212);
spectrogram(yn_out,hamming(wlen),wlen-1,nfft,Fs,'yaxis')
title('Spectrogram'); 
    
        




