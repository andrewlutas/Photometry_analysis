%% Initialize
clear
% common path
defaultpath = '\\anastasia\data\photometry';


% Loading cell
% Which data files to look at {mouse, date, run}
inputloadingcell_ctrl = {'SZ598', 201217, 1; 'SZ599', 201217, 1;...
    'SZ600', 201217, 1; 'SZ601', 201217, 1; 'SZ601', 201218, 1; 'SZ602', 201217, 1;...
    'SZ603', 201217, 1; 'SZ603', 201217, 1}; 
tcpCheck(inputloadingcell_ctrl, 'checkAmat', true);

inputloadingcell_c21 =...
    {'SZ598', 201220, 1; 'SZ598', 201221, 1; 'SZ598', 201222, 1;...
    'SZ599', 201220, 1; 'SZ599', 201221, 1; 'SZ599', 201222, 1;...
    'SZ600', 201220, 1; 'SZ600', 201221, 1; 'SZ600', 201222, 1;...
    'SZ601', 201220, 1; 'SZ601', 201221, 1; 'SZ601', 201222, 1;...
    'SZ602', 201221, 1; 'SZ602', 201222, 1;...
    'SZ603', 201220, 1; 'SZ603', 201221, 1; 'SZ603', 201222, 1}; 
tcpCheck(inputloadingcell_c21, 'checkAmat', true);
%% Make data struct
% Social
varargin_datastruct = {'loadisosbestic', true, 'defaultpath', defaultpath};
[datastruct_ctrl, n_series_ctrl] = mkdatastruct(inputloadingcell_ctrl, varargin_datastruct);
[datastruct_c21, n_series_c21] = mkdatastruct(inputloadingcell_c21, varargin_datastruct);
%% Time to line
index = 14;
varargin_time2line = {'bhvfield', 'FemInvest', 'minlength', 0.2};
time2line_photometry(datastruct_c21, index, varargin_time2line);

%% Postprocess photometry data
% Inputs
varargin_pp = {'Fs_ds', 50, 'smooth_window', 0, 'zscore_badframes', 1 : 10,...
    'First_point', 1, 'BlankTime', [], 'nozscore', false, 'externalsigma', [],...
    'usedff', true, 'combinedzscore', false};
datastruct_ctrl_pp = ppdatastruct(datastruct_ctrl, varargin_pp);
datastruct_c21_pp = ppdatastruct(datastruct_c21, varargin_pp);

%% Make a sniffing construct
% Input for introm structure
varargin_CloseExamstruct = {'datafield','photometry','bhvfield', 'FemInvest',...
    'norm_length', 10, 'pre_space', 15, 'post_space', 15, 'trim_data', true,...
    'trim_lndata', true, 'diffmean', true, 'premean', true, 'removenantrials', true, 'nantolerance', 0};
CloseExamstruct_ctrl = mkbhvstruct(datastruct_ctrl_pp, varargin_CloseExamstruct);
CloseExamstruct_c21 = mkbhvstruct(datastruct_c21_pp, varargin_CloseExamstruct);
%% Extract data
[bhvmat, eventlabel] = extbhvstruct(CloseExamstruct_c21, ...
    {'useLN', false, 'pretrim', 10, 'posttrim', 10});

%% Visualize sniff-trggered data control
% Input
varargin_viewbhvstruct =...
    {'keepc', {'session', []},...
    'sortc', 'diffmean', 'sortdir', 'descend', 'heatmaprange', [-2 2],...
    'datatoplot', {'data_trim', 'ln_data_trim'},...
    'linefields', {'data_trimind', 'ln_data_trimind'}, 'showX', []};
viewbhvstruct(CloseExamstruct_ctrl, varargin_viewbhvstruct)

%% Visualize sniff-trggered data c21
% Input
varargin_viewbhvstruct =...
    {'keepc', {'session', []},...
    'sortc', 'diffmean', 'sortdir', 'descend', 'heatmaprange', [-2 2],...
    'datatoplot', {'data_trim', 'ln_data_trim'},...
    'linefields', {'data_trimind', 'ln_data_trimind'}, 'showX', []};
viewbhvstruct(CloseExamstruct_c21, varargin_viewbhvstruct)
