
plot([data2use, opto])
figure
hold on
plot(-TrigCfg.prew : 1/freq : TrigCfg.postw, trigmat_avg)
plot(-TrigCfg.prew : 1/freq : TrigCfg.postw, lickmat_avg/max(lickmat_avg)/10)
plot([0 tl], [mean(trigmat_avg), mean(trigmat_avg)], 'LineWidth', 5)

% Plot running
if ~isempty(speedmat_avg)
    ylims = get(gca, 'YLim');
    plot(-TrigCfg.prew : 1/freq : TrigCfg.postw,...
        speedmat_avg / max(speedmat_avg) * ylims(2));
end
clear all