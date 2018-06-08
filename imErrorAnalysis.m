function [SNRdB,avgnoise,peakSourcePower,thresholdMeanPower] = imErrorAnalysis(im,gridax,sigpos,box)
%IMERRORANALYSIS Error analysis of an image to be used in analysis of SRP image

% im - SRP image
% gridax - the gridpoints used to index the SRP image
% sigpos - the xyz coordinate matrix of source positions
% box - size of the box used to delineate noise and source signal

% delta = (gridax{1}(2)-gridax{1}(1));
% AA = gridax{1} > (sigpos(1)+delta);
% BB = gridax{1} < (sigpos(1)-delta);
% CCx = find(AA == BB);
% 
% delta = (gridax{2}(2)-gridax{2}(1));
% AA = gridax{2} > (sigpos(2)+delta);
% BB = gridax{2} < (sigpos(2)-delta);
% CCy = find(AA == BB);
% 
% gridsize = box; % size of region around peak
% % range
% regx = CCx-gridsize:CCx+gridsize;
% regy = CCy-gridsize:CCy+gridsize;
% % doesn't catch boundary problems if max peak is near edge.

% THRESHOLD METHOD
peakVal = max(max(im));
thresh = 0.50*peakVal;
[regx,regy] = find(im>thresh);

% BOX METHOD
% imsourcewindow = zeros(gridsize*2+1);
% for ll = 1:gridsize*2+1
%     for kk = 1:gridsize*2+1
%         imsourcewindow(kk,ll) = im(kk+regx(1)-1,ll+regy(1)-1);
%     end
% end

% PLOT ABOVE THRESHOLD
% pause;
% surf(gridax{1},gridax{2},im.*(im>thresh));
% xlabel('Xaxis meters'); ylabel('Yaxis meters');
% title(['Image above threshold of ', num2str(thresh)]);
% pause;

srpmax = max(im(im>thresh));
srpmean = mean(im(im>thresh));
% [ymax xmax] = find(im == srpmax); % get index of max peak
% locxmax = gridax{1}(xmax); % get coordinate of max peak
% locymax = gridax{2}(ymax);

% peakloc = [ locxmax locymax ];

% if show_plots == 1
%    plot3(locxmax, locymax, max(im(:)) ,'ok', 'MarkerSize', 18,'LineWidth', 2);
% end

% gridsize = box; % size of region around peak
% % range
% regx = xmax-gridsize/2:xmax+gridsize/2;
% regy = ymax-gridsize/2:ymax+gridsize/2;
% doesn't catch boundary problems if max peak is near edge.

xN = length(gridax{1});
yN = length(gridax{2});
imnoise = zeros(xN,yN);
nn = 1;
for ll = 1:xN
    cond1 = length(find(regx ~= ll)) ~= length(regx);
    for kk = 1:yN
        cond2 = length(find(regy ~= kk)) ~= length(regy);
        if ~(cond1 && cond2) % true when ll is in both regions     
            imnoise(kk,ll) = im(kk,ll);
            noisevalues(nn) = im(kk,ll);
            nn = nn + 1;
        end
    end
end

noisevalues(noisevalues<0) = 0; % zero negative noise values
avgnoise = mean(noisevalues);
peakSourcePower = srpmax;
thresholdMeanPower = srpmean;
SNRdB = db(srpmean/avgnoise);
end