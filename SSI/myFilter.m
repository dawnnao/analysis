function [t, y] = myFilter(data, fs, lw, uw)
    if (size(data,1) > size(data,2))
        data = data';      % transform into row vector
    end
    P = length(data(:,1)); % number of channels of signal
    N = length(data(1,:)); % length of signal
    if (N < 1024)
        nfft = 2^nextpow2(N);
    else
        nfft = 2^(nextpow2(N)-1);
    end
    k = round(lw*nfft/fs); %?
    m = round((fs/2-uw)*nfft/fs); %?
    for i = 1 : P
        Y = fft(data(i,:),nfft);
        b = zeros(1,k);
        l = zeros(1,m);
        filter1 = [b, ones(1,0.5*nfft-k-m), l, l, ones(1,0.5*nfft-k-m), b];
        Y = Y .* filter1;
        y(i,:) = ifft(Y, nfft);
        sig = real(y(i,:)) ./ abs(real(y(i,:)));
        y(i,:) = sig .* abs(y(i,:));
        %plot(t,out(i,:));
    end
    t = (0:(length(y)-1))*1/fs;
end
