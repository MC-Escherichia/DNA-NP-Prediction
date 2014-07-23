function y = plot_ternary()


    load data
    load cluster

    figure
    y = plot_ternary1(data.train_data,data.train_y,1)
end

function a = plot_ternary1(data,y,shape)

     load nets
     rbq.pop();
     rbq.pop();
     rbq.pop();
     rbq.pop();
     rbq.pop();

    [a net] =  rbq.pop()

A = sim(net,data');
A = A'



[h,hg,htick]=terplot;
%-- Plot the data ...
hter=ternaryc(A(:,1),A(:,2),A(:,3));
%-- ... and modify the symbol:
set(hter,'marker','o','markerfacecolor','none','markersize',4)
hlabels=terlabel('C1','C2','C3');


end
