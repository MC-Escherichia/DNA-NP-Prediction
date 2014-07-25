    load data
    load cluster

    figure


    netl = load('net');
    net = netl.net;

    %    A = sim(net,data');
    %A = A'
    A = [];
    for Rs = 0.1:0.1:1;
        for Rl = 0.1:0.1:1
            for Rn = 1:0.1:2
                disp([Rs,Rl,Rn]);
                A(end+1,:) = net([Rs,Rl,Rn]');
            end
        end
    end
%%

    A = A

[h,hg,htick]=terplot;
%-- Plot the data ...
hter=ternaryc(A(:,1),A(:,2),A(:,3));
%-- ... and modify the symbol:
set(hter,'marker','o','markerfacecolor','none','markersize',4)
hlabels=terlabel('AlB2','Cr3Si','CsCl');
