function coords = clickyCoordinates(channelMapImage,channelNumbers,targetCenter,siteDiameter)
    % returned as [channel, AP, ML]
    disp('Click +AP -ML corner, then -AP +ML corner...');
    figure;
    im = imread(channelMapImage);
    imshow(im);
    [xs_corners,ys_corners] = ginput(2);

    coords = [];

    rectangle('Position',[xs_corners(1) ys_corners(1) xs_corners(2)-xs_corners(1) ys_corners(2)-ys_corners(1)],'LineWidth',2,'LineStyle','--');

    for iChannel = 1:numel(channelNumbers)
        disp(['Click channel ',num2str(channelNumbers(iChannel))]);
        [xs,ys] = ginput(1);
        xsys_mm = makeCoord([xs_corners,ys_corners],[xs,ys],targetCenter,siteDiameter);
        text(xs,ys,[num2str(xsys_mm(2),'%.2f'),', ',num2str(xsys_mm(1),'%.2f')],'Color','red');
        coords(iChannel,:) = [channelNumbers(iChannel) flip(xsys_mm)];
    end
end

function xsys_mm = makeCoord(corners,xsys,targetCenter,siteDiameter)
% corners = [xs,ys];
    center = mean(corners);
    meanPx = mean(diff(corners));
    px2mm = siteDiameter / meanPx;
    
    xsysRel = (xsys - center) .* [1 -1];
    xsys_mm = round((xsysRel * px2mm) + flip(targetCenter),2);
end