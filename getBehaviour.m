clear all
close all
clc

%% set parameters and loops
display_percentage_ok = 0;
plot_individuals = 0;
plot_averages = 1;

pp2do = [1:5];
p = 0;

[bar_size, bright_colours, colours, light_colours, SOA_colours, dark_colours, subplot_size, labels, percentageok, overall_dt, overall_error] = setBehaviourParam(pp2do);

for pp = pp2do
    p = p+1;
    ppnum(p) = pp;
    figure_nr = 1;
    
    param = getSubjParam(pp);
    disp(['getting data from ', param.subjName]);
    
    %% load actual behavioural data
    behdata = readtable(param.log);

    %% check percentage oktrials
    % select trials with reasonable decision times
    oktrials = abs(zscore(behdata.idle_reaction_time_in_ms))<=3; 
    percentageok(p) = mean(oktrials)*100;
  
    % display percentage unbroken trials
    if display_percentage_ok
        fprintf('%s has %.2f%% unbroken trials\n\n', param.subjName, percentageok(p,1))
    end
    %% basic data checks, each pp in own subplot
    if plot_individuals
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(behdata.response_time_in_ms, 50);
        title(['response time - pp ', num2str(pp2do(p))]);
        xlim([0 2010]);
        ylim([0 150]);
        
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(behdata.idle_reaction_time_in_ms,50);
        title(['decision time - pp ', num2str(pp2do(p))]);
        xlim([0 2000]);
        ylim([0 150]);
        
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(behdata.duration_offset,50);       
        title(['duration offset - pp ', num2str(pp2do(p))]);
        xlim([-500 500]);
        ylim([0 150]);
        
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(behdata.duration_diff_abs,50);     
        title(['abs duration offset - pp ', num2str(pp2do(p))]);
        xlim([0 100]);
        ylim([0 150]);
    end

    
    %% trial selections
    left_trials = ismember(behdata.target_position, {'left'});
    right_trials = ismember(behdata.target_position, {'right'});

    first_target_trials = behdata.target_item == 1;
    second_target_trials = behdata.target_item == 2;

    premature_trials = ismember(behdata.premature_pressed, {'True'});
    
    %% extract data of interest
    overall_dt(p,1) = mean(behdata.idle_reaction_time_in_ms(oktrials), "omitnan");
    overall_abs_error(p,1) = mean(behdata.duration_diff_abs(oktrials), "omitnan");
    overall_error(p,1) = mean(behdata.duration_offset(oktrials), "omitnan");
    
    labels = {'first', 'second'};

    % get reaction time as function of order
    dt_order(p,1) = mean(behdata.idle_reaction_time_in_ms(first_target_trials&oktrials), "omitnan");
    dt_order(p,2) = mean(behdata.idle_reaction_time_in_ms(second_target_trials&oktrials), "omitnan");
    
    % get error as function of order
    error_order(p,1) = mean(behdata.duration_diff_abs(first_target_trials&oktrials), "omitnan");
    error_order(p,2) = mean(behdata.duration_diff_abs(second_target_trials&oktrials), "omitnan");

    %% get behavioural effect as function of target duration
    % bin stimulus durations
    target_duration_bins = 500:100:1500;
    i = 0;
    for target_duration = target_duration_bins
        i = i + 1;
        trial_sel = behdata.target_duration < target_duration+50 & behdata.target_duration > target_duration-50;

        dt_durations(p,i) = mean(behdata.idle_reaction_time_in_ms(trial_sel&oktrials), "omitnan");
        rt_durations(p,i) = mean(behdata.response_time_in_ms(trial_sel&oktrials), "omitnan");
        error_durations(p,i) = mean(behdata.duration_offset(trial_sel&oktrials), "omitnan");
    end
    
end

if plot_averages
 %% check performance
    figure; 
    subplot(4,1,1);
    bar(ppnum, overall_dt(:,1));
    title('overall decision time');
    ylim([0 900]);
    xlabel('pp #');

    subplot(4,1,2);
    bar(ppnum, overall_error(:,1));
    title('overall error');
    xlabel('pp #');

    subplot(4,1,3);
    hold on
    bar(ppnum, overall_abs_error(:,1));
    plot([0, max(ppnum)], [250 250]);
    title('overall abs error');
    xlabel('pp #');

    subplot(4,1,4);
    bar(ppnum, percentageok);
    title('percentage ok trials');
    ylim([90 100]);
    xlabel('pp #');

    %% effect of target order on behaviour
    figure(figure_nr);
    figure_nr = figure_nr+1;
    bar(mean(dt_order, 1));
    xticklabels(labels)
    ylabel('Decision time (ms)');

    figure(figure_nr);
    figure_nr = figure_nr+1;
    bar(mean(error_order, 1));
    xticklabels(labels)
    ylabel('Reproduction error (ms)');

    %% effect of target duration on behaviour
    figure(figure_nr);
    figure_nr = figure_nr+1;
    bar(mean(dt_durations, 1));
    xticklabels(target_duration_bins);
    xlabel('Bin centre for target durations (ms)');
    ylabel('Decision time (ms)');
    
    figure(figure_nr);
    figure_nr = figure_nr+1;
    bar(mean(rt_durations, 1));
    xticklabels(target_duration_bins);
    xlabel('Bin centre for target durations (ms)');
    ylabel('Reproduced duration (ms)');

    figure(figure_nr);
    figure_nr = figure_nr+1;
    hold on
    plot([500:100:1500], rt_durations');
    plot([500:100:1500], [500:100:1500]);
    xticklabels(target_duration_bins);
    xlabel('Bin centre for target durations (ms)');
    ylabel('Reproduced duration (ms)');
    legend({'p1', 'p2', 'p3', 'p4', 'p5', 'ideal pp'});

    figure(figure_nr);
    figure_nr = figure_nr+1;
    bar(mean(error_durations, 1));
    xticklabels(target_duration_bins);
    xlabel('Bin centre for target durations (ms)');
    ylabel('Reproduction error (ms)');

    figure(figure_nr);
    figure_nr = figure_nr+1;
    hold on
    bar([1:2], [mean(mean(rt_durations(:,1:4))), mean(mean(rt_durations(:,6:11)))]);
    plot([1:2], [mean(rt_durations(:,1:4),2), mean(rt_durations(:,6:11),2)]);
    xticklabels({"Short", "Long"});
    xlabel("Item condition");
    ylabel("Reproduction time (ms)");


end
