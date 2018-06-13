% Script to plot the some SNR results
N = 8;
snrdb = zeros(3,N);

load('snrdba0.mat','snrdbarray');
snrdb(1,:) = snrdbarray;
load('snrdba90.mat','snrdbarray');
snrdb(2,:) = snrdbarray;
load('snrdbaRand.mat','snrdbarray','snrdbavg');
snrdb(3,:) = snrdbarray;
snrdbA = snrdbavg;

style = {'r-','g-.','k--'};
figure(3);
ww = 1:N;
for ii = 1:3
    plot(ww,snrdb(ii,:),style{ii});
    hold on;
end
plot(ww,ones(1,N)*snrdbA,'b-','LineWidth',2);
hold off;
xlabel('time-window index');
ylabel('SNR (decibels)');
legend('pitch = 0 deg.','pitch = 90 deg.','random angles','averaged image');
title('SNR dB behavior for iterative source time-windows');