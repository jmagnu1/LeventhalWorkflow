    Data = randn(1000,1); %just making up some junk data
   binWidth = 0.7; %This is the bin width
   binCtrs = -3:0.7:3; %Bin centers, depends on your data
   n=length(Data);
   counts = hist(Data,binCtrs);
   prob = counts / (n * binWidth);
   %H = bar(binCtrs,prob,'hist');
   %set(H,'facecolor',[0.5 0.5 0.5]);
   % get the N(0,1) pdf on a finer grid
  % hold on;
  % x = -3:.1:3;
   %y = normpdf(x,0,1); %requires Statistics toolbox
   plot(x,y,'k','linewidth',2)