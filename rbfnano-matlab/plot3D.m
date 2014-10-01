function g = plot3D(xv,yv,zm,labels)

g = figure;
set(g,'visible','off','colormap',colormap('bone'))

h1 = subplot(1,3,1);


h = surf(xv,yv,zm);
xlabel(labels(1));
ylabel(labels(2));
zlabel(labels(3));

h2 = subplot(1,3,2);
copyobj(h,h2);
view(h2,[0 0])

xlabel(labels(1));
ylabel(labels(2));
zlabel(labels(3));


h3 = subplot(1,3,3);
copyobj(h,h3);
view(h3,[90 0])
xlabel(labels(1));
ylabel(labels(2));
zlabel(labels(3));

set(h1 , 'PlotBoxAspectRatio', [1,1,1])
set(h2 , 'PlotBoxAspectRatio', [1,1,1])
set(h3 , 'PlotBoxAspectRatio', [1,1,1])
