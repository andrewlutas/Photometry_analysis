function filt = mkfilt(varargin)
% MKFILT makes filter objects (with design parameters)
%
% currently only makes minimum-order FIR filters using firpm
%
% b/c we want linear phase, and don't care too much about filter length,
% we're using Equiripple Bandpass filter designed using the FIRPM
% function.
%
% Modified from m-file generated by fdatool (MATLAB(R) 7.0.1 and the Signal
% Processing Toolbox 6.2.1.
%
% args:
%  'filtopt' filter options structure created by mkfiltopt
%
% filt structure:
%  name: theta, e.g.
%  Fs: sampling frequency
%  filttype: 'highpass'/'lowpass'/'bandpass'/'bandstop'
%  F: design frequencies
%  atten_db/ripp_db: arguments
%  dfilt: discrete filter object we designed


% all 'minimum order'
%
% all 'single' arithmetic

% All frequency values are in Hz.

filt = struct(...
    'type', 'filt', ...
    ...
    'filtopt', [],...
    ...
    'A',[],...
    'dev', [],...
    'dfilt', [],...
        ...
    'template', [],...
    'cache_hit', false,...
    'cache', []);
    
filt = obj_reparse(filt, varargin);

% check filtopt arguments using mkfiltopt
% filt.filtopt = mkfiltopt('template', filt.filtopt);

if isempty(filt.filtopt.Fs),
  error('sampling frequency ''Fs'' must be provided');
end

newfilt = obj_cachesearch(filt);

if newfilt.cache_hit,
  newfilt.filtopt.name = filt.filtopt.name;
  filt = obj_cleanup(newfilt);
  return;
end

%%%% No cache hit, design filter

disp(['designing filter: ''' filt.filtopt.name '''...']);

switch filt.filtopt.filttype
 case 'coeffs',
   fB = filt.filtopt.coeffs;
    
 case 'gausswin',
  
  if ~isempty(filt.filtopt.length_t),
    % find the nearest odd window-length
    winlength_samp = 1 + 2 * (round(filt.filtopt.length_t * filt.filtopt.Fs / 2));
    fB = gausswin(winlength_samp);
    % normalize the filter magnitude
    fB = fB/sum(fB);
  elseif ~isempty(filt.filtopt.sd_t),
    fB = gausswinsd(filt.filtopt.sd_t, filt.filtopt.Fs);
  else
    error('for filttype gausswin must provide ''length_t'' or ''sd_t''');
  end

 case 'rectwin',
  if ~isempty(filt.filtopt.length_t),
    % find the nearest odd window-length
    winlength_samp = 1+ 2 * (round(filt.filtopt.length_t * filt.filtopt.Fs / 2));
    fB = rectwin(winlength_samp);
    % normalize the filter magnitude
    fB = fB/sum(fB);
  else
    error('for filttype rectwin must provide ''length_t''');
  end

 case 'hatwin',
  if ~isempty(filt.filtopt.sd_t),
    fB = hatwindow(filt.filtopt.sd_t * filt.filtopt.Fs, 4);
    % normalize the filter magnitude
    %fB = fB/sum(fB);
  else
    error('for filttype hatwin must provide ''sd_t''');
  end

  
 otherwise

  %%%%%%%%%%%
  % design it!

  % calculate 'deviation' for stop/pass-bands
  Dstop = db2num(filt.filtopt.atten_db);
  Dpass = (db2num(filt.filtopt.ripp_db) -1) / (db2num(filt.filtopt.ripp_db) +1);

  switch filt.filtopt.filttype,
   case 'highpass'
    filt.dev = [Dstop Dpass];
    filt.A = [0 1];
   case 'lowpass'
    filt.dev = [Dpass Dstop];
    filt.A = [1 0];
   case 'bandpass'
    filt.dev = [Dstop Dpass Dstop];
    filt.A = [0 1 0];
   case 'bandstop'
    filt.dev = [Dpass Dstop Dpass];
    filt.A = [1 0 1];
  end

  try

    % Calculate the order from the parameters using FIRPMORD.
    [N, Fo, Ao, W] = firpmord(filt.filtopt.F, filt.A, filt.dev, filt.filtopt.Fs);

    % we only want even-ordered (type I) FIR filters, so that group delay
    % is an integer # of samples. We just add 1 to odd-order filters
    if mod(N,2),
      N = N +1;
    end
    
    % Calculate the coefficients using FIRPM function.
    fB  = firpm(N, Fo, Ao, W);
    
    
  catch
    error(['Problem creating filter ''' filt.filtopt.name ''': ' lasterr]);
  end
  
end

% make filter
filt.dfilt = dfilt.dffir(fB);

% set filter arithmetic to requested value
filt.dfilt.Arithmetic = filt.filtopt.datatype;