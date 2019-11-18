function [datastruct, n_series] = mkoptostruct(inputloadingcell, varargin)
% mkdatastruct makes a triggered opto structure based on the input data addresses.
% [datastruct, n_series] = mkoptostruct(inputloadingcell, varargin)

% Parse input
p  = inputParser;

addOptional(p, 'defaultpath', '\\anastasia\data\photometry'); % Default photometry path
addOptional(p, 'nozscore', false); % No zscore of data
addOptional(p, 'zscore_firstpt', 50); % First point for zscore

addOptional(p, 'externalsigma', []); % Feed a sigma for zscoring
addOptional(p, 'badtrials', []); % Bad trials to remove (X by 2 matrix of [Session# Sweep#])

addOptional(p, 'zero_baseline', false); % Add a Y-offset to zero the pre-stim baselines
addOptional(p, 'zero_baseline_per_session', true); % Zero baseline once per session (Using median
                                                   % from the first sweep)

% Unpack if needed
if size(varargin,1) == 1 && size(varargin,2) == 1
    varargin = varargin{:};
end

% Parse
parse(p, varargin{:});
p = p.Results;


%% Make actual loading cell
loadingcell = mkloadingcell(inputloadingcell, p.defaultpath);

% data samples
n_series = size(loadingcell, 1);

% Initialize
datastruct = struct('photometry_trig', 0, 'photometry_trigavg', 0, 'opto', 0,... 
    'order', 0, 'rorder', 0, 'Fs', 0, 'nstims', 0, 'window_info', [0 0 0]);
datastruct = repmat(datastruct, [size(loadingcell,1), 1]);

% Load data
for i = 1 : n_series
    % Load photometry things
    loaded = load(fullfile(loadingcell{i,1}, loadingcell{i,6}));
    
    % Load data
    if p.nozscore
        % Load triggered data
        datastruct(i).photometry_trig = loaded.trigmat;
    else
        % Mean and std
        mu = nanmean(loaded.data2use(p.zscore_firstpt:end));
        if isempty(p.externalsigma)
            gamma = nanstd(loaded.data2use(p.zscore_firstpt:end));
        else
            gamma = p.externalsigma;
        end
        
        % Apply zscore
        datastruct(i).photometry_trig = (loaded.trigmat - mu) / gamma;
    end
    
    % Zero baseline
    if p.zero_baseline % Per sweep
        % Baseline vector
        baselinevec = nanmean(datastruct(i).photometry_trig(1 : loaded.prew_f, :), 1);
        
        % Triggered photometry data
        datastruct(i).photometry_trig = datastruct(i).photometry_trig -...
            ones(loaded.l, 1) * baselinevec;
    elseif p.zero_baseline_per_session % Once per session
        % Baseline value
        baselineval = nanmedian(datastruct(i).photometry_trig(1 : loaded.prew_f, 1));
        
        % Triggered photometry data
        datastruct(i).photometry_trig = datastruct(i).photometry_trig -...
            baselineval;
    end
    
    % Remove bad trials 
    if ~isempty(p.badtrials)
        % Current bad trials
        currentbt = p.badtrials(p.badtrials(:,1) == i, 2);
        
        % Remove
        datastruct(i).photometry_trig(:,currentbt) = [];
    end
    
    % Calculate average
    datastruct(i).photometry_trigavg = mean(datastruct(i).photometry_trig, 2);
    
    % Opto trigger
    datastruct(i).opto = loaded.trigmat_avg;
    
    % Order
    datastruct(i).order = 1 : size(datastruct(i).photometry_trig, 2);
    
    % Reverse order
    datastruct(i).rorder = size(datastruct(i).photometry_trig, 2) : -1 : 1;
    
    % Frequency
    datastruct(i).Fs = loaded.freq;
    
    % Load window info
    datastruct(i).window_info = [loaded.prew_f, loaded.postw_f, loaded.l];
    
    % Number of stims
    datastruct(i).nstims = loaded.n_optostims;
end


end