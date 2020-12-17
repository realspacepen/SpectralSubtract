%return noise estimate in FREQUENCY domain
%created:2020-12-15 20:17:04
%author:HJR
%OTA normalization
function MiuK=OTA_Noise_estimator(Fabs_input,N)

%parameter tuning 
M=16;
K=2*M+1;
C=2;
MiuK=zeros(1,N);
OmegaK=zeros(1,2*M+1);
% Yk=zeros(1,2*M+1);




%% generated signals

%Xk
% Env=abs(y);%Envelope of X(k)
Y_start=Fabs_input;
%% start background normalization
Indp_samples=12;
r=1+C*sqrt(4/pi-1)/sqrt(Indp_samples);
for i=1:M+1
    	MiuK(i)=mean(Y_start(1:M+1));
%     MiuK(i)=Y_start(i);
end
for i=N-M:N
    	MiuK(i)=mean(Y_start(1:M+1));
%     MiuK(i)=Y_start(i);
end
 %moving average
%  for i=M+1:N-M
%      for j=i-M:i+M
%          OmegaK(j-i+M+1)=Y_start(j);
%      end
%      X_avg=mean(OmegaK);
%      Ym=median(OmegaK);
% 	 num_zero=0;
% 	 
% 	 for j=1:K
% 		if(OmegaK(j)>=r*Ym)
%         OmegaK(j)=0;
%         num_zero=num_zero+1;
% 		else
%         OmegaK(j)=OmegaK(j);
% 		end
% 	end

%% 序列首尾延拓版
%复数序列可能会有问题
for i=1:N
     for j=i-M:i+M
         if(i>M && i<=N-M)
            OmegaK(j-i+M+1)=Y_start(j);
         end
         if(i<=M)
             if(j<=0)
                 tmp=N+j;
             else
                 tmp=j;
             end
             OmegaK(j-i+M+1)=Y_start(tmp);
         end
         if(i>N-M)
             if(j>N)
                 tmp=j-N;
             else
                 tmp=j;
             end
             OmegaK(j-i+M+1)=Y_start(tmp);
         end
     end
     X_avg=mean(OmegaK);
     Ym=median(OmegaK);
	 num_zero=0;
	 
	 for j=1:K
		if(OmegaK(j)>=r*Ym)
        OmegaK(j)=0;
        num_zero=num_zero+1;
		else
        OmegaK(j)=OmegaK(j);
		end
	end
	     
     MiuK(i)=mean(OmegaK)*K/(K-num_zero);
 end


% for i=1:N
%     if(Y_start(i)<MiuK(i))
%         Env(i)=0;
%     else
%         Env(i)=(Y_start(i)-MiuK(i))/MiuK(i);
%     end
% %     Env(i)=Y_start(i)/MiuK(i);
% end	

%% inverse fft of nomralized envelop X(k)
% for i=1:N
%     X2k(i)=Env(i)*cos(angle(y(i)))+1j*Env(i)*sin(angle(y(i)));
%     
% end
% X2n=ifft(X2k);
% % figure
% % plot(abs(X2k));title('X2k');
% 
% %% stft processing...
% % figure(4)
% subplot(212);
% spectrogram(X2n,hamming(wlen),wlen-1,nfft,fs)
% title('SAXA Normalized Spectrogram'); 
% 	
	

	
	
	
	
	
