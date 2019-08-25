function [States, nstates] = GLMmakestate(dynamic_input, static_input, varargin)
% GLMmakestate makes state functions given the inputs
% [States, nstates] = GLMmakestate(dynamic_input, static_input, varargin)

% Parse inputs
p = inputParser;

% Input options
addOptional(p, 'DynamicOnOffset', 'onset'); % which part of the dynamic 
                                            % data to use
addOptional(p, 'WhichStaticEvent', 'first');    % Which static event to use 
                                                % (first or last)
addOptional(p, 'StaticOnOffset', 'offset'); % which part of the statis 
                                            % data to use
addOptional(p, 'useDynBeforeSta', true); % Use data when dynamic 
                                                % event happens before the statis event
addOptional(p, 'useDynAfterSta', true);  % Use data when dynamic 
                                                % event happens after the statis event

% Unpack if needed
if size(varargin,1) == 1 && size(varargin,2) == 1
    varargin = varargin{:};
end

% Parse
parse(p, varargin{:});
p = p.Results;

% Check input lengths
if length(dynamic_input) ~= length(static_input)
    error('Inputs must have the same lengths.');
end

% Length
L = length(dynamic_input);

% Chains of events
Dyn_chains = chainfinder(dynamic_input > 0);
n_Dyn_chains = size(Dyn_chains, 1);

% Flags for which states to use
states2use = zeros(n_Dyn_chains, 1);

% Chain of events
Sta_chains = chainfinder(static_input > 0);

% Find the right timestamps
% Which static event to use and when to use during event
switch p.WhichStaticEvent
    case 'first'
        switch p.StaticOnOffset
            case 'onset'
                StaticTime = Sta_chains(1, 1);
            case 'offset'
                StaticTime = Sta_chains(1, 1) + Sta_chains(1, 2) - 1;
        end
    case 'last'
        switch p.StaticOnOffset
            case 'onset'
                StaticTime = Sta_chains(end, 1);
            case 'offset'
                StaticTime = Sta_chains(end, 1) + Sta_chains(end, 2) - 1;
        end
end

% When to use during dynamic events
switch p.DynamicOnOffset
    case 'onset'
        DynamicTimes = Dyn_chains(:,1);
    case 'offset'
        DynamicTimes = Dyn_chains(:,1) + Dyn_chains(:,2) - 1;
end

% Initialize states
States = zeros(L, n_Dyn_chains);
nstates = 0;

% Loop through
for i = 1 : n_Dyn_chains
    % Determine if this is a state that should be recorded
    if (DynamicTimes(i) < StaticTime) && p.useDynBeforeSta
        % Make state
        States(DynamicTimes(i) : StaticTime, i) = 1;
        
        % Register state
        nstates = nstates + 1;
        states2use(i) = 1;
    elseif (DynamicTimes(i) > StaticTime) && p.useDynAfterSta
        % Make state
        States(StaticTime : DynamicTimes(i), i) = 1;
        
        % Register state
        nstates = nstates + 1;
        states2use(i) = 1;
    end
end

% Clean up the state data
States = States(:, states2use == 1);

end