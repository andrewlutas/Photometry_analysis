%% Initialize
clear
% common path
defaultpath = '\\anastasia\data\photometry';


% Loading cell
% Which data files to look at {mouse, date, run}
inputloadingcell_social = {'SZ51', 190410, 1; 'SZ51', 190410, 2;...
    'SZ52', 190411, 1; 'SZ52', 190411, 2; 'SZ51', 190417, 1; 'SZ51', 190417, 2;...
    'SZ52', 190417, 1; 'SZ52', 190417, 3; 'SZ51', 190419, 1; 'SZ52', 190419, 1;...
    'SZ52', 190523, 1; 'SZ52', 190525, 1; 'SZ52', 190525, 2; 'SZ129', 190703, 1;...
    'SZ129', 190703, 2; 'SZ131', 190703, 2; ...
    'SZ132', 190703, 2; 'SZ133', 190703, 1; 'SZ133', 190703, 2; 'SZ129', 190707, 1;...
    'SZ129', 190707, 2; 'SZ131', 190707, 1; 'SZ131', 190707, 2; 'SZ131', 190707, 1;...
    'SZ51', 190604, 1; 'SZ52', 190604, 1; 'SZ133', 190709, 2; 'SZ132', 190720, 2}; 
tcpCheck(inputloadingcell_social, 'checkAmat', true);

%% Make data struct
% Social
varargin_datastruct = {'loadisosbestic', false, 'defaultpath', defaultpath};
[datastruct_social, n_series_social] = mkdatastruct(inputloadingcell_social, varargin_datastruct);

%% Time to line
index = 11;
varargin_time2line = {'bhvfield', 'CloseExam', 'minlength', 0.2};
time2line_photometry(datastruct_social, index, varargin_time2line);

%% Postprocess photometry data
% Inputs
varargin_pp = {'Fs_ds', 50, 'smooth_window', 0, 'zscore_badframes', 1 : 10,...
    'First_point', 1, 'BlankTime', [], 'nozscore', false, 'externalsigma', [],...
    'usedff', false, 'combinedzscore', false};
datastruct_social_405_pp = ppdatastruct(datastruct_social, varargin_pp);

%% Make a sniffing construct
% Input for introm structure
varargin_CloseExamstruct = {'datafield','photometry','bhvfield', 'CloseExam',...
    'norm_length', 10, 'pre_space', 10, 'post_space', 10, 'trim_data', true,...
    'trim_lndata', true, 'diffmean', true, 'premean', true, 'removenantrials', true, 'nantolerance', 0};
CloseExamstruct = mkbhvstruct(datastruct_social_405_pp, varargin_CloseExamstruct);

%% Extract data
[bhvmat, eventlabel] = extbhvstruct(CloseExamstruct, ...
    {'useLN', true, 'pretrim', 3, 'posttrim', 3});

%% Visualize sniff-trggered data
% Input
varargin_viewbhvstruct =...
    {'keepc', {'session', []},...
    'sortc', 'diffmean', 'sortdir', 'descend', 'heatmaprange', [-2 2],...
    'datatoplot', {'data_trim', 'ln_data_trim'},...
    'linefields', {'data_trimind', 'ln_data_trimind'}, 'showX', []};
viewbhvstruct(CloseExamstruct, varargin_viewbhvstruct)
