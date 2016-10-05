allSpectData = [];
iLoop = 1;
for iNeuron=1:size(analysisConf.neurons,1) % use testset for correlation analysis
    iEvent = 5;
    eventData = lfpEventData{iNeuron};
    if isempty(eventData)
        disp(['No Bursting (skipping): ',analysisConf.neurons{iNeuron}]);
        continue;
    end
    parts = strsplit(analysisConf.neurons{iNeuron},'_');
    neuronName = strjoin(parts);
    
    h = formatSheet;
    subplot(311);
    spectData = log(squeeze(eventData(iEvent,:,:)));
    imagesc(t,freqList,spectData);
    ylabel('Frequency (Hz)');
    xlabel('Time (s)');
    set(gca, 'YDir', 'normal');
    set(gca,'YScale','log');
    set(gca,'Ytick',round(exp(linspace(log(min(freqList)),log(max(freqList)),5))));
    xlim([-1 1]);
%     ylim([0 100]);
    title({neuronName,eventFieldnames{iEvent}});
    colormap(jet);
    [N,edges] = histcounts(spectData(:),100);
    prctileThresh = prctile(N,25);
    caxisLowerIdx = find(N > prctileThresh,1,'first');
    caxisUpperIdx = find(N > prctileThresh,1,'last');
    caxis([edges(caxisLowerIdx) edges(caxisUpperIdx)]);
    colorbar;

    eventData = burstEventData{iNeuron};

    [zMean,zStd] = helpZscore(eventData.ts,scalogramWindow,histBin);
    [counts,centers] = hist(eventData.tsEvents{iEvent},histBin);
    counts = counts / correctTrialCount(iNeuron);
    zCounts = (counts - zMean)/zStd;

    % plot(centers,smooth(zCounts,smoothZ));
    interpCounts = interp1(linspace(1,length(spectData),length(counts)),smooth(counts,smoothZ),...
        1:length(spectData),'spline');
    subplot(312);
    plot(linspace(-2,2,length(interpCounts)),interpCounts);
    xlim([-1 1]);
    title('z-score');
    colorbar;

    newSpectData = [];
    for ii=1:size(spectData,1)
        % had to normalize values for xcorr to work properly
        [r,lags] = xcorr(spectData(ii,:)-mean(spectData(ii,:)),interpCounts-mean(interpCounts));
        newSpectData(ii,:) = r;
    end

    subplot(313);
    spectData = newSpectData;
    allSpectData(iLoop,:,:) = spectData;
    imagesc(linspace(-scalogramWindow*2,scalogramWindow*2,length(spectData)),freqList,spectData);
    ylabel('Frequency (Hz)');
    xlabel('Time (s)');
    set(gca, 'YDir', 'normal');
    set(gca,'YScale','log');
    set(gca,'Ytick',round(exp(linspace(log(min(freqList)),log(max(freqList)),5))));
    xlim([-2 2]);
%     ylim([0 100]);
    title('Scalogram xcorr');
    colormap(jet);
    [N,edges] = histcounts(spectData(:),100);
    prctileThresh = prctile(N,25);
    caxisLowerIdx = find(N > prctileThresh,1,'first');
    caxisUpperIdx = find(N > prctileThresh,1,'last');
    caxis([edges(caxisLowerIdx) edges(caxisUpperIdx)]);
    colorbar;
    
    saveas(h,fullfile('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp',...
    ['scaloBurstXcorr_',analysisConf.neurons{iNeuron},'.pdf']));
    close(h);
    iLoop = iLoop + 1;
end
h = figure;
imagesc(linspace(-scalogramWindow*2,scalogramWindow*2,length(spectData)),freqList,squeeze(mean(allSpectData,1)));
ylabel('Frequency (Hz)');
xlabel('Time (s)');
set(gca, 'YDir', 'normal');
set(gca,'YScale','log');
set(gca,'Ytick',round(exp(linspace(log(min(freqList)),log(max(freqList)),5))));
xlim([-2 2]);
% ylim([0 80]);
title('Mean xcorr');
colormap(jet);
saveas(h,fullfile('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp',...
    ['scaloBurstXcorrMean_',analysisConf.neurons{iNeuron},'.pdf']));
close(h);