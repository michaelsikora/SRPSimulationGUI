temp = figure;
temp.Visible = 'on';
%  Plot SRP image
%imagesc(gridax{1},gridax{2}, im, [0, max(max(im))]);
surf(gridax{1},gridax{2}, im);
colormap(jet); colorbar; axis('xy');
axis([froom(1,1)-.25, froom(1,2)+.25, froom(2,1)-.25, froom(2,2)+.25]);
hold on;
%  Mark coherenet noise positions
% plot(sigposn(1,:),sigposn(2,:),'xb','MarkerSize', 18,'LineWidth', 2);  %  Coherent noise
%  Mark actual target positions  
plot3(sigpos(1,:),sigpos(2,:),ones(length(sigpos(2,:)))*1,'ok', 'MarkerSize', 18,'LineWidth', 2);
%  Mark microphone positions
%plot(mposperim(1,:),mposperim(2,:),'sr','MarkerSize', 12);
plot3(mposplat(1,:),mposplat(2,:),mposplat(3,:),'sr','MarkerSize', 12);


axis('tight');
%  Number them
%for kn=1:length(mposperim(1,:))
%    text(mposperim(1,kn),mposperim(2,kn), int2str(kn), 'HorizontalAlignment', 'center')
%end
for iii = 1:mjs_platnum % Label Platform numbers
    mjs_loc = mjs_platform(iii).getCenter();
    text(mjs_loc(1),mjs_loc(2)+0.5,mjs_loc(3), ['Pl', int2str(iii)], 'HorizontalAlignment', 'center');
end

for kn=1:length(mposplat(1,:)) % Label microphones
    text(mposplat(1,kn),mposplat(2,kn),mposplat(3,kn), int2str(kn), 'HorizontalAlignment', 'center');
end

%  Draw Room walls
plot([vn(1,:), vn(1,1)],[vn(2,:), vn(2,1)],'k--')
% Label Plot
xlabel('Xaxis Meters')
ylabel('Yaxis Meters')
title({['SRP image (Mics at squares,'],[' Target in circle, Noise sources at Xs']} )
hold off
% %  Plot signal array
% figure(fno+1)
% offset = zeros(1,micnum); % Initialize offset vector
% for km=1:micnum
%     %plot offset
%     offset(km) = max(abs(sigoutpera([sst:sed],km))) + .1*std(sigoutpera([sst:sed],km));
% end
% fixoff = max(offset);
% offt = 0;
% for km=1:micnum
%     offt = fixoff +offt;
%     plot((sst:sed)/fs,sigoutpera(sst:sed,km)+offt)
%     hold on
% end
% hold off
% set(gca,'ytick',[])
% xlabel('Seconds')
% title('Array Signals, Mic 1 is on the bottom')
% figure(fno)

            % Grid plot of Platform Orientations
%             figure(10);
%             plotOrder = [3,4,2,1]; % Order Counterclockwise
%             for pp = 1:mjs_platnum 
%                 pr = radii(1)*1.1; % plot-radius/box-width;
%                 [X,Y,Z] = mjs_platform(pp).getMics(); % Platform pp
%                 subplot(2,2,plotOrder(pp)), scatter3(X,Y,Z); hold on;
%                 currOrientation = mjs_platform(pp).getOrient('QUATERNION');
%                 xyzbasis = [1 0 0; 0 1 0; 0 0 1].*radii(1); % define a reference frame
%                 rotbasis = zeros(size(xyzbasis));
%                 coordLabel = ['X*';'Y*';'Z*'];
%                 for rr = 1:3 % Rotate and plot reference frame by platform orientation
%                     rotbasis(rr,:) = quatRotateDup(currOrientation,xyzbasis(rr,:));      
%                     quiver3(mjs_pcs(pp,1),mjs_pcs(pp,2),mjs_pcs(pp,3),...
%                     rotbasis(rr,1),rotbasis(rr,2),rotbasis(rr,3),'->g');  
%                     text(rotbasis(rr,1)*1.2+mjs_pcs(pp,1),...
%                         rotbasis(rr,2)*1.2+mjs_pcs(pp,2),...
%                         rotbasis(rr,3)*1.2+mjs_pcs(pp,3),...
%                         coordLabel(rr,:),'HorizontalAlignment','center');
%                 end
%                 title({['Orientation of Platform ', num2str(pp)]});
%                 xlabel('xaxis'); ylabel('yaxis'); zlabel('zaxis');
%                 xlim([-pr pr]+mjs_pcs(pp,1));
%                 ylim([-pr pr]+mjs_pcs(pp,2));
%                 zlim([-pr pr]+mjs_pcs(pp,3)); 
%                 hold off;
%             end