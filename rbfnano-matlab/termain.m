% Main file for ternary plot
close all;clear all
warning off MATLAB:griddata:DuplicateDataPoints
% Load the data for limestone
%   File format: 1. column: solid volume fraction
%                2. column: water volume fraction
%                3. column: gas volume fraction
%                4. column: effective dielectric permittivity
%   The data matrix is called A
%   To obtain the velocities (in m/ns): v=0.29./sqrt(A(:,4));
%
load limestone
% Add the 'corner' values (looks better in the surface plot)
l=length(A);
A(l+1,:)=[1 0 0 6];
A(l+2,:)=[0 1 0 30];
A(l+3,:)=[0 0 1 1];
% ... and the GPR velocity
v=0.29./sqrt(A(:,4));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  EXAMPLE CODE FOR THE PSEUDO COLOR PLOT
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% igure;
%  Plot the data
%  First set the colormap (can't be done afterwards)
% olormap(jet)
% hg,htick,hcb]=tersurf(A(:,1),A(:,2),A(:,3),v);
%  Add the labels
% labels=terlabel('Limestone','Water','Air');
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The following modifications are not serious, just to illustrate how to
%  use the handles:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --  Change the color of the grid lines
% et(hg(:,3),'color','m')
% et(hg(:,2),'color','c')
% et(hg(:,1),'color','y')
%
% --  Modify the labels
% et(hlabels,'fontsize',12)
% et(hlabels(3),'color','m')
% et(hlabels(2),'color','c')
% et(hlabels(1),'color','y')
% --  Modify the tick labels
% et(htick(:,1),'color','y','linewidth',3)
% et(htick(:,2),'color','c','linewidth',3)
% et(htick(:,3),'color','m','linewidth',3)
%
% --  Change the colorbar
% et(hcb,'xcolor','w','ycolor','w')
% --  Modify the figure color
% et(gcf,'color',[0 0 0.3])
% -- Change some defaults
% et(gcf,'paperpositionmode','auto','inverthardcopy','off')
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% %  EXAMPLE CODE FOR THE CONTOUR PLOT
% %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% igure
%  Plot the ternary axis system
% h,hg,htick]=terplot;
%  Plot the data
%  First set the colormap (can't be done afterwards)
% olormap(jet)
% hcont,ccont,hcb]=tercontour(A(:,1),A(:,2),A(:,3),v,linspace(min(v),max(v),10));
% label(ccont,hcont);
% et(hcont,'linewidth',2)
%  Add the labels
% labels=terlabel('Limestone','Water','Air');
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The following modifications are not serious, just to illustrate how to
%  use the handles:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --  Change the color of the grid lines
% et(hg(:,3),'color','m')
% et(hg(:,2),'color','c')
% et(hg(:,1),'color','y')
%
% --  Modify the labels
% et(hlabels,'fontsize',12)
% et(hlabels(3),'color','m')
% et(hlabels(2),'color','c')
% et(hlabels(1),'color','y')
% --  Modify the tick labels
% et(htick(:,1),'color','y','linewidth',3)
% et(htick(:,2),'color','c','linewidth',3)
% et(htick(:,3),'color','m','linewidth',3)
% --  Change the color of the patch
% et(h,'facecolor',[0.7 0.7 0.7],'edgecolor','w')
% --  Change the colorbar
% et(hcb,'xcolor','w','ycolor','w')
% --  Modify the figure color
% et(gcf,'color',[0 0 0.3])
% -- Change some defaults
% et(gcf,'paperpositionmode','auto','inverthardcopy','off')
%
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% %  EXAMPLE CODE FOR THE COLOR TERNARY PLOT
% %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% igure
%  Plot the ternary axis system
% h,hg,htick]=terplot;
%  Plot the data
%  First set the colormap (can't be done afterwards)
% olormap(jet)
% hd,hcb]=ternaryc(A(:,1),A(:,2),A(:,3),v,'o');
%  Add the labels
% labels=terlabel('Limestone','Water','Air');
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The following modifications are not serious, just to illustrate how to
%  use the handles:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --  Change the color of the grid lines
% et(hg(:,3),'color','m')
% et(hg(:,2),'color','c')
% et(hg(:,1),'color','y')
% --  Change the marker size
% et(hd,'markersize',3)
% --  Modify the labels
% et(hlabels,'fontsize',12)
% et(hlabels(3),'color','m')
% et(hlabels(2),'color','c')
% et(hlabels(1),'color','y')
% --  Modify the tick labels
% et(htick(:,1),'color','y','linewidth',3)
% et(htick(:,2),'color','c','linewidth',3)
% et(htick(:,3),'color','m','linewidth',3)
% --  Change the color of the patch
% et(h,'facecolor',[0.7 0.7 0.7],'edgecolor','w')
% --  Change the colorbar
% et(hcb,'xcolor','w','ycolor','w')
% --  Modify the figure color
% et(gcf,'color',[0 0 0.3])
% -- Change some defaults
% et(gcf,'paperpositionmode','auto','inverthardcopy','off')
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Lastly, an example showing the "constant data option" of
%  ternaryc().
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
%-- Plot the axis system
[h,hg,htick]=terplot;
%-- Plot the data ...
hter=ternaryc(A(:,1),A(:,2),A(:,3));
%-- ... and modify the symbol:
set(hter,'marker','o','markerfacecolor','none','markersize',4)
hlabels=terlabel('C1','C2','C3');
