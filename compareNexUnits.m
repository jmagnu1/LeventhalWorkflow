function compareNexUnits(sessionConf)

color1 = [145/255 205/255 114/255];
color2 = [180/255 20/255 20/255];

leventhalPaths = buildLeventhalPaths(sessionConf);

nexFiles = dir(fullfile(leventhalPaths.processed,'*.sev.nex'));
nexFiles = natsort({nexFiles.name});
nexFileIds = listdlg('PromptString','Select units to compare:',...
                'SelectionMode','multiple','ListSize',[400 200],...
                'ListString',nexFiles);

spikeTimes = cell(length(nexFileIds),2);
totalUnits = 1;
chUnits = 1;

aveWaveforms = {};

for ii=1:length(nexFileIds)
    filename = nexFiles{nexFileIds(ii)};
    nexfile = fullfile(leventhalPaths.processed,filename);
    sevfile = fullfile(leventhalPaths.channels,filename(1:end-4)); %should just have a .nex appended

    idx = regexp(filename,'data_');
    chName = filename(idx+5:end-8);
    
    [nvar, names, ~] = nex_info(nexfile);
    for jj=1:nvar
        varname = deblank(names(jj,:));
        [~, ts] = nex_ts(nexfile, varname);
        spikeTimes{totalUnits,1} = ts;
        spikeTimes{totalUnits,2} = [chName,'-',num2str(chUnits)];
        
        [meanWaveform, upperStd, lowerStd, ch, windowSize] = aveWaveform(ts,sevfile);
        aveWaveforms{totalUnits,1} = meanWaveform;
        aveWaveforms{totalUnits,2} = upperStd;
        aveWaveforms{totalUnits,3} = lowerStd;
%         plotAveWaveform(meanWaveform, upperStd, lowerStd, ch, windowSize);
        
        totalUnits = totalUnits + 1;
        chUnits = chUnits + 1;
    end
    chUnits = 1;
end

% figure('position',[100 100 800 300]);
% plotSpikeRaster(spikeTimes(:,1),'PlotType','vertline');
% xlim([0 1]);
% set(gca,'Ytick',[0:length(spikeTimes)]);
% title('Unit Raster');

h1 = figure('position',[0 0 800 800]);
h2 = figure('position',[0 0 800 800]);

curPlot = 1;
for ii=1:length(spikeTimes)
    
    for jj=1:length(spikeTimes)
        if ii > jj
            curPlot = curPlot + 1;
            continue;
        end
    
        figure(h1);
        subplot(length(spikeTimes),length(spikeTimes),curPlot);
        offsets = crosscorrelogram(spikeTimes{ii,1},spikeTimes{jj,1},[-0.005 0.005]);
        [counts,centers] = hist(offsets,100);
        if ii == jj
            facecolor = color2;
        else
            facecolor = color1;
        end
        bar(centers*1000,counts,'LineStyle','none','FaceColor',facecolor); %to ms
        title([spikeTimes{ii,2},' : ',spikeTimes{jj,2}]);
        set(gca,'yscale','log');
        ylim([0 max(counts)]);
        set(gca,'Ytick',[0 max(counts)]);
        xlabel('time (ms)');
        ylabel('log bin');
        
        figure(h2);
        subplot(length(spikeTimes),length(spikeTimes),curPlot);
        hold on
        grid on
        t = linspace(-windowSize/2*1000, windowSize/2*1000, length(aveWaveforms{ii,1})); %to ms
        
        fill([t fliplr(t)], [aveWaveforms{jj,2} fliplr(aveWaveforms{jj,3})], color2, 'edgeColor', color2);
        alpha(.25);
        plot(t, aveWaveforms{jj,1}, 'color', color2, 'lineWidth', 2);
        
        fill([t fliplr(t)], [aveWaveforms{ii,2} fliplr(aveWaveforms{ii,3})], color1, 'edgeColor', color1);
        alpha(.25);
        plot(t, aveWaveforms{ii,1}, 'color', color1, 'lineWidth', 2);
        
        xlabel('time (ms)');
        xlim([-1 2]);
        ylabel('uV');
        title([spikeTimes{ii,2},' : ',spikeTimes{jj,2}]);

        
        curPlot = curPlot + 1;
    end
end

disp('end');