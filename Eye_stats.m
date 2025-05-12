%% Script for doing stats on saccade and gaze bias data.
% So run those scripts first.
% by Anna, 04-07-2023
%% Saccade bias data - stats
statcfg.xax = saccade.time;
statcfg.npermutations = 1000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = s;
statcfg.statMethod = 'montecarlo'; %this one also statistically tests the clusters
%statcfg.statMethod = 'analytic'; %this one only finds potential clusters 

ft_size = 26;
timeframe = [701:2201]; %this is 0 to 1500 ms post-cue

data_cond1 = d3(:,1,timeframe);
null_data = zeros(size(data_cond1));

stat = frevede_ftclusterstat1D(statcfg, data_cond1, null_data)

%% Saccade bias data - plot only effect
mask_xxx = double(stat.mask);
mask_xxx(mask_xxx==0) = nan; % nan data that is not part of mark

figure;
hold on
p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,1,:)), 'k', 'se');
p1.LineWidth = 2.5;
sig = plot(saccade.time(timeframe), mask_xxx*-0.01, 'Color', 'k', 'LineWidth', 5); % verticaloffset for positioning of the "significance line"

if sum(stat.mask) == 0
    text(250, -0.05, "no significant clusters found")
end

xlim(xlimtoplot);
ylim([-0.1 0.1]);
plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], ylim, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
ylabel('Saccade bias (ΔHz)');
xlabel('Time (ms)');
hold off
