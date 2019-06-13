function [fig_Bpwr, fig_Rast] = wc_plotBetaBursts_M1_matrixInput(ecog_betaBurst_raster,ecog_betaPwr,ecog_betaMed, bad, lfp,filename)

% set some variables about drawing things nicely
set(0,'units','pixels');
pixSS = get(0,'screensize');
ctxC = [0.94 0.66 0.02];
bgC = [0.29 0.62 0.96];

% get number of all good channels
ecogNum=setdiff([1:28],bad);
% lfpNum=1:length(lfp.contact);
lfpNum=0;

%% PLOT BETA RASTER OF BETA BURSTS
figHt = 25*(length(ecogNum)+length(lfpNum))+100; % Set figure height based on number of thresh
figPos = pixSS(4)-(0.2*pixSS(4)+figHt); % Set position based on figure size
fig_Rast= figure('Position',[600,figPos,500,figHt]); % Make new figure

hold on; % Plot all data on same axes 

channelLabels = cell(0);
for i = 1:length(ecogNum) % plot the ecog channels
    j=ecogNum(i);
%     step=1/ecog.FsB(j);
    step=1/220;
	train = ecog_betaBurst_raster(j,:); 
	allTimes = [0:step:length(train)*step-step]; % make timestamps
	bTimes = allTimes(logical(train)); % Grab the timestamps when a burst happened
	times = ones(1,numel(bTimes)); % Generate dummy values so plot will look like a raster
	times = times*i; % Transform dummy values so each threshold gets its own line
	plot(bTimes,times,'bs','markersize',1.5,'markerfacecolor',ctxC,'markeredgecolor',ctxC)
    channelLabels = [channelLabels, sprintf('ECoG %d',j)];
end

% for i = 1:length(lfpNum) % plot the lfp channels
%     j=lfpNum(i);
%     step=1/lfp.FsB(j);
% 	train = lfp.contact(j).burst; 
% 	allTimes = [0:step:length(train)*step-step]; % make timestamps
% 	bTimes = allTimes(logical(train)); % Grab the timestamps when a spike happened
% 	times = ones(1,numel(bTimes)); % Generate dummy values so plot will look like a raster
% 	times = times*i+length(ecogNum); % Transform dummy values so each threshold gets its own line
% 	plot(bTimes,times,'bs','markersize',1.5,'markerfacecolor',bgC,'markeredgecolor',bgC)
%     channelLabels = [channelLabels, sprintf('LFP %d',j)]; 
% end
hold off



% Set labels and titles for graph
set(gca,'ylim',[0.5 length(ecogNum)+length(lfpNum)+0.5]); % Scale the y axis
set(gca,'ytick',[1:length(ecogNum)+length(lfpNum)]); % Set the y axis tick marks
set(gca,'YTickLabel',channelLabels); % Set the y axis tick labels
ylabel('Channel'); % Set the y axis label

set(gca,'xlim',[allTimes(1)-1 allTimes(numel(allTimes))+1]); % Scale the x axis
xlabel('Time (s)'); % Set the x axis label

title(['Beta Burst Raster ' filename],'FontWeight','bold','FontSize',12); % Set the plot title
%set(gcf,'name','Beta Burst Raster','numbertitle','off')  % Set the title of the figure window
saveas(gcf,[filename '_betaBurstRaster'],'fig');

%% PLOT BETA POWER OVER THE WHOLE RECORDING
fig_Bpwr = figure('Position',[600,figPos,500,figHt]); % Make new figure
hold on; % Plot all data on same axes 

ampScale=10e-6; % set this to 1/ roughly the amplitude beta power on ecog channels
for i = 1:length(ecogNum) % plot the ecog channels
    j=ecogNum(i);
%     step=1/ecog.FsB(j);
    step=1/220;
	trace = ampScale*ecog_betaPwr(j,:); 
	time = [0:step:length(trace)*step-step]; % make timestamps
    % want to put the traces so their median power values are evenly spaced & labels are by medians
    shift = i - ampScale*ecog_betaMed(j);
	p = plot(time,trace+shift);
    plot(time, ones(size(time))*ampScale*ecog_betaMed(j)+shift,'Color',get(p,'Color'),'LineStyle','--');
end

% ampScale=10e-5; % set this to 1/ roughly the amplitude beta power on lfp channels
% for i = 1:length(lfpNum) % plot the lfp channels
%     j=lfpNum(i);
%     step=1/lfp.FsB(j);
%     trace = ampScale*lfp.contact(j).betaPwr;
%     time = [0:step:length(trace)*step-step]; % make timestamps
%     % want to put the traces so their median power values are evenly spaced & labels are by medians
%     shift = (i+length(ecogNum)) - ampScale*lfp.contact(j).medB;
% 	p = plot(time,trace+shift);
%     plot(time, ones(size(time))*ampScale*lfp.contact(j).medB+shift,'Color',get(p,'Color'),'LineStyle','--');
% end
hold off



% Set labels and titles for graph
set(gca,'ylim',[0 length(ecogNum)+length(lfpNum)+1]); % Scale the y axis
set(gca,'ytick',[1:length(ecogNum)+length(lfpNum)]); % Set the y axis tick marks
set(gca,'YTickLabel',channelLabels); % Set the y axis tick labels
ylabel('Channel'); % Set the y axis label

set(gca,'xlim',[allTimes(1) allTimes(end)]); % Scale the x axis
xlabel('Time (s)'); % Set the x axis label

title(['Beta Power ' filename],'FontWeight','bold','FontSize',12); % Set the plot title
%set(gcf,'name','Beta Burst Raster','numbertitle','off')  % Set the title of the figure window
saveas(gcf,[filename '_betaPower'],'fig');
end