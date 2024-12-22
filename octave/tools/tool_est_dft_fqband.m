## Estimate upper frequency band limit of sinusoidal low-pass signals in noise
##
## Usage: [r_fb, r_ff, r_pp, r_cc, r_pw, r_tf] = tool_est_dft_fqband(p_xx, p_fs, p_zp, p_tp, p_tf)
##
## p_xx ... signal amplitude matrix, each column represents one signal, [[<dbl>]]
## p_fs ... sampling rate, Hz, <dbl>
## p_zp ... zero-padding factor, multiple of signal length, optional, default = 0 (no zero-padding), <dbl>
## p_tp ... signal power threshold factor, multiple of estimate signal power, 0 <= p_tp <= 0.99, optional, default = 0.90, <dbl>
## p_tf ... noise measurement range factor, multiple of number of frequency bins, 0.5 <= p_tf <= 0.9, optional, default = 0.75, <dbl>
## r_fb ... return: frequency band limits w.r.t. the sampling frequency p_pw.Fs, [<dbl>]
## r_ff ... return: frequency array (frequency bins), [<dbl>]
## r_pp ... return: power spectral density matrix, each column represents the periodogram of one signal, [[<dbl>]]
## r_cc ... return: normalized cumulative sum matrix, each column represents the cumulative sum of one periodogram, [[<dbl>]]
## r_pw ... return: estimate signal power matrix [Px, Pv, Ps, SNR], each row represents the power estimates of one signal, [[<dbl>]]
## r_tf ... return: adjusted noise measurement range factor, <dbl>
##
## Algorithm:
##   step 1: estimate power spectral density (PSD)
##   step 2: estimate signal power and frequency band
##     step 2.1: estimate signal power and SNR
##     step 2.2: compute cumulative sum of the PSD
##     step 2.3: determine detection threshold from signal power and power threshold factor
##     step 2.4: estimate frequency band limit by threshold detection using the PSD's cumulative sum (linear interpolation)
##
## Note: Signals with an odd number of samples are truncated by one sample.
##
## Schema (PSD):
##
## magnitude [V^2/Hz]
## ^
## | low-pass signal
## |        /\
## |   /\  /  \
## |  /  \/    \              noise floor
## | /          \vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
## o------------x-----------------------------------x--> frequency bins [k]
## 0            F_lim                               F_nyquist, Nbin
##   |<-fqband->|       |<------ p_tf * Nbin ------>| noise measurement range
##
##
## Schema (cumulative sum of PSD):
##
## magnitude [V^2]
## ^                             ___________________ Px = Ps + Pv
## |          -------------------
## |        _/
## |      _/.... p_tp * Ps
## |    _/ |     Ps = estimate signal power = Px - Pv
## |  _/   |     Pv = estimate noise power
## | /     |     Px = estimate power of signal in noise
## o-------x----------------------------------------x--> frequency bins [k]
##         F_lim                                    F_nyquist, Nbin
##
## see also: tool_est_dft
##
#######################################################################################################################
## LICENSE
##
##    Copyright (C) 2024 Jakob Harden (jakob.harden@tugraz.at, Graz University of Technology, Graz, Austria)
##
##    This program is free software: you can redistribute it and/or modify
##    it under the terms of the GNU Affero General Public License as
##    published by the Free Software Foundation, either version 3 of the
##    License, or (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU Affero General Public License for more details.
##
##    You should have received a copy of the GNU Affero General Public License
##    along with this program.  If not, see <https://www.gnu.org/licenses/>.
##
#######################################################################################################################
## This file is part of the PhD thesis of Jakob Harden.
##
function [r_fb, r_ff, r_pp, r_cc, r_pw, r_tf] = tool_est_dft_fqband(p_xx, p_fs, p_zp, p_tp, p_tf)
  
  ## check arguments
  if (nargin < 5)
    p_tf = [];
  endif
  if (nargin < 4)
    p_tp = [];
  endif
  if (nargin < 3)
    p_zp = [];
  endif
  if (nargin < 2)
    p_fs = [];
  endif
  if (nargin < 1)
    help tool_est_dft_fqband;
    error('Less arguments given!');
  endif
  if isempty(p_tf)
    p_tf = 0.75;
  endif
  if isempty(p_tp)
    p_tp = 0.90;
  endif
  if isempty(p_zp)
    p_zp = 0;
  endif
  if isempty(p_fs)
    p_fs = 1;
  endif
  ## limit noise measurement range factor
  p_tf = min([0.9, max([0.5, p_tf])]);
  ## limit signal power threshold factor
  for j = 1 : numel(p_tp)
    p_tp(j) = min([0.99, max([0, p_tp(j)])]);
  endfor
  
  ## number of signals, number of samples
  [Nsmp, Nsig] = size(p_xx);
  
  ## step 1: estimate power spectral density, unilateral
  zp = floor(p_zp * Nsmp); # zero padding amount, number of samples
  [r_ff, ~, ~, ~, ~, r_pp, enbw] = tool_est_dft(p_xx, p_fs, zp, 'unilateral');
  Nbin = numel(r_ff);
  
  ## step 2: estimate signal power and frequency band
  Lvm = floor(Nbin * p_tf); # noise measurement length (right side of unilateral PSD), initial value
  Lsig = Nbin - Lvm; # signal section length (left side of unilateral PSD), initial value
  r_cc = zeros(Nbin, Nsig); # cumulative sum matrix
  r_pw = zeros(Nsig, 4); # power estimate matrix
  r_fb = zeros(Nsig, numel(p_tp)); # frequency band limit matrix
  r_tf = ones(Nsig, 1) * p_tf; # noise measurement range factor array
  for j = 1 : Nsig
    ## step 2.1: estimate signal power and SNR
    Px = sum(r_pp(:, j)); # power of signal in noise
    Pv = sum(r_pp(Lsig + 1 : end, j)) * Nbin / Lvm; # noise power
    Ps = Px - Pv; # signal power
    SNR = 10 * log10(Ps / Pv); # signal-to-noise ratio
    r_pw(j, 1 : 4) = [Px, Pv, Ps, SNR]; # save power estimates
    ## step 2.2: compute cumulative sum of the PSD
    r_cc(:, j) = cumsum(r_pp(:, j)); # cumulative sum of the PSD
    ## step 2.3: determine detection threshold from signal power and power threshold factor
    tv_det = Ps * p_tp;
    ## step 2.4: estimate frequency band limit by threshold detection using the PSD's cumulative sum
    [~, idxu] = unique(r_cc(:, j), "stable"); # find unique values, necessary for subsequent interpolation
    intp_x = r_cc(:, j)(idxu); # interpolation supports
    intp_y = r_ff(idxu); # interpolation support magnitudes
    fb = interp1(intp_x, intp_y, tv_det, 'linear'); # interpolate frequency band thresholds
    r_fb(j, :) = fb;
    ## adjust noise measurement range factor
    idx_fb = find(r_ff >= fb(end), 1, 'first');
    if not(isempty(idx_fb))
      ## step 2.1: update signal power and SNR estimates
      Lsig1 = min([idx_fb * 2, ceil(0.5 * Nbin)]); # update signal section length
      if (Lsig1 == Lsig)
        ## signal section length did not change, continue with next signal
        continue;
      endif
      Lvm1 = Nbin - Lsig1; # update, noise measurement range length
      r_tf(j) = Lvm1 / Nbin; # update, noise measurement range factor
      Pv1 = sum(r_pp(Lsig1 + 1 : end, j)) * Nbin / Lvm1; # update, noise power
      Ps1 = Px - Pv1; # update, signal power
      SNR1 = 10 * log10(Ps1 / Pv1); # update, signal-to-noise ratio
      r_pw(j, 1 : 4) = [Px, Pv1, Ps1, SNR1]; # save updated power and SNR estimates
      ## step 2.3: update, determine detection threshold from signal power and power threshold factor
      tv_det = Ps1 * p_tp;
      ## step 2.4: update, estimate frequency band limit by threshold detection using the PSD's cumulative sum
      fb = interp1(intp_x, intp_y, tv_det, 'linear'); # interpolate frequency band thresholds
      r_fb(j, :) = fb;
    endif
  endfor
  
endfunction
