plotheight = 8.5;
plotwidth  = 11;
subplotsx  = 2;
subplotsy  = 2;
leftedge   = 1;
rightedge  = 1;
topedge    = 1;
bottomedge = 1;
spacex     = .5;
spacey     = .5;
fontsize   = 16;

% screensize = get( groot, 'Screensize' );
% hfig.Position          = [1 1 , screensize(3:4)*0.9];
hfig                   = figure; 
hfig.PaperPositionMode = 'manual'; 
hfig.PaperOrientation  = 'landscape';
hfig.PaperUnits        = 'inches';
hfig.PaperSize         = [plotwidth plotheight]; 
hfig.PaperPosition     = [0 0 plotwidth plotheight]; 
set(gca,'FontSize',fontsize); 

sub_pos    = subplot_pos(plotwidth,plotheight,leftedge,rightedge,bottomedge,topedge,subplotsx,subplotsy,spacex,spacey);


subplot('Position',sub_pos{3}); % this is plot 1
plot([1 2 3],[2 3 4]);

subplot('Position',sub_pos{4}); % this is plot 2
plot([1 2 3],[2 3 4]);

subplot('Position',sub_pos{1}); % this is plot 3
plot([1 2 3],[2 3 4]);

subplot('Position',sub_pos{2}); % this is plot 4
plot([1 2 3],[2 3 4]);




