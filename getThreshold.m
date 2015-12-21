function threshold = getThreshold(threshGain,data)
%% sliding window
window = 1000; %samples
dt = 750;
threshold = zeros(1,length(data));
for i=window+1:dt:length(data)-window
   threshold(i:i+dt-1) = threshGain .* median((abs(data(i-window:i+window))./0.6745));
end

%set threshold values outside the sliding window
threshold(1:window) = threshold(window+1);
threshold(end-window:end) = threshold(end-window-1);
