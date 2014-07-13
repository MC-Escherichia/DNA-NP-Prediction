%% Wondering some things about the parameter space in the model?

%% What does it look like in 3-D?

Rs = 0.05:0.05:1;
Rn = 0.25:0.25:4;
Rl = Rn;
f = @(a) arrayfun(@(x) min([a/x,1]),  Rs);

[X Y Z1] = meshgrid(Rs,Rn,f(1));
[X Y Z2] = meshgrid(Rs,Rn,f(2));
[X Y Z3] = meshgrid(Rs,Rn,f(3));

flip = @(X) 1./X;

% XYZ = [X(:);Y(:);Z(:)];
hold on
scatter3(X(:)+0.02,Y(:)+0.02,Z3(:),3.*ones(size(X(:))),[0 0 1],'filled');

scatter3(X(:)-0.02,Y(:)-0.02,Z2(:),3.*ones(size(X(:))),[0 1 0],'filled');

scatter3(X(:),Y(:),Z1(:),3.*ones(size(X(:))),[1 0 0],'filled');
%%

thinum = @(Rn,F) 1./sqrt(Rn/F);



%%
thix3 = arrayfun(thinum,Y(:),Z3(:));
thix2 = arrayfun(thinum,Y(:),Z2(:));
thix1 = arrayfun(thinum,Y(:),Z1(:));


plot(thix3,X(:),'r.',thix2,X(:),'g.',thix1,X(:),'b.')
