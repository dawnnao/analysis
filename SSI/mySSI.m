function [F,D,shape] = mySSI(data, fs, I, xlim, ylim)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input:
%       data - measured data
%       fs - sampling frequency
%       I - i value of Hankle matrix
%       xlim - x range in stablization diagram
%       ylim - y range in stablization diagram
% Output:
%       F - frequency
%       D - damping ratio
%       shape - mode shape
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [d1,d2]=size(data);
    if(d1>d2)
        data=data';
    end
    Y=data;
    p=size(Y,1);            % number of sensors
    T1=myToeplitz(Y,I,p);   % form Toeplitz matrix T1(1:I)
    T2=myToeplitz(Y,I+1,p); % form Toeplitz matrix T1(1:I+1)
    T2=T2(p+1:end,p+1:end); % form Toeplitz matrix T1(2:I+1)

    [U,S,V] = svd(T1);  % operate SVD for T1
    N=I;                % the Max order number in stablization diagram
    for(n=0:fix(N/2))
        U1=U(:,1:2*n);
        S1=S(1:2*n,1:2*n);
        V1=V(:,1:2*n);
        Oi=U1*sqrt(S1);               % compute observable matrix Oi
        Fi=sqrt(S1)*V1.';             % compute inversal controllable matrix Fi. Note that ".'" is transpose if V1 is complex matrix, rather than conjugate transpose.
        C=Oi(1:p,1:2*n);              % compute observation matrix C
        A=pinv(Oi)*T2*pinv(Fi);       % compute system matrix A
        [psi,D]=eig(A);               % EVD for A
        D=diag(D);                    % compute eigen vector
        F1=abs(log(D))*fs/(2*pi);     % compute frequencies
        %D1=sqrt(1./(((imag(log(D'))./real(log(D'))).^2)+1));
        D1=-real(log(D))./sqrt(real(log(D)).^2+imag(log(D)).^2); % compute damping ratio
        shape1=C*psi;                 % compute mode shape
        plot(F1,ones(size(F1))*2*n,'*','Color',[0.07843 0.1686 0.549]) % plot stablization diagram
        axis([xlim,ylim])
        xlabel('Frequency (Hz)')
        ylabel('Order')
        hold on
        pause(0.1)
    end

    %% delete replicate modals
    [F,D,shape]=myDeleteModalParameter(F1,D1,shape1);
end

function [T]=myToeplitz(Y,c,p)
    J=fix(length(Y(1,:))-2*c);
    Han=[];
    for i=1:2*c
       Han=[Han;Y(:,i:J+i)]; % form Hankel matrix
    end
    Han=Han/sqrt(J);
    Yp=Han(1:p*c,:);
    Yf=Han(p*c+1:2*c*p,:);
    T=Yf*Yp';
end

function [F,D,shape]=myDeleteModalParameter(F1,D1,shape1)
    [F2,I]=sort(F1);
    F=[];
    D=[];
    shape=[];
    m=0;
    for k=1:length(F1)-1
        if F2(k)~=F2(k+1)
            continue
        end
        m=m+1;
        l=I(k);
        F(m)=F1(l);
        D(m)=D1(l);
        shape(:,m)=abs(shape1(:,l));
    end
end

