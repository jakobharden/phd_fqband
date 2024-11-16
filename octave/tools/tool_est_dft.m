## Estimate discrete Fourier transform for real valued signals (rectangular window)
##
## Usage: [r_ff, r_dft, r_as, r_ps, r_nb] = tool_est_dft(p_xx, p_fs, p_zp)
##
## p_xx   ... signal amplitude matrix, each column represents one signal, [<dbl>] or [[<dbl>]]
## p_fs   ... sample rate in Hz, optional, default = 2 <uint>
## p_zp   ... zero padding length, number of samples, optional, default = 0 (no zero padding), <dbl>
## p_rn   ... range, 'unilateral' or 'bilateral', optional, default = 'unilateral', <str>
## r_fb   ... return: frequencies, [<dbl>]
## r_dft  ... return: discrete Fourier transform (DFT), [<dbl>] or [[<dbl>]]
## r_as   ... return: amplitude (RMS) spectrum (AS), [<dbl>] or [[<dbl>]]
## r_ps   ... return: power spectrum (PS), [<dbl>] or [[<dbl>]]
## r_lsd  ... return: linear spectral density (LSD), [<dbl>] or [[<dbl>]]
## r_psd  ... return: power spectral density (PSD), [<dbl>] or [[<dbl>]]
## r_enbw ... return: equivalent noise band width, <dbl>
##
## see also: fft, fftshift
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
function [r_ff, r_dft, r_as, r_ps, r_lsd, r_psd, r_enbw] = tool_est_dft(p_xx, p_fs, p_zp, p_rn)
  
  ## check arguments
  if (nargin < 4)
    p_rn = [];
  endif
  if (nargin < 3)
    p_zp = [];
  endif
  if (nargin < 2)
    p_fs = [];
  endif
  if (nargin < 1)
    help tool_est_dft;
    error('Less arguments given!');
  endif
  if isempty(p_rn)
    p_rn = 'unilateral';
  endif
  if isempty(p_zp)
    p_zp = 0;
  endif
  if isempty(p_fs)
    p_fs = 2;
  endif
  
  ## init return values
  r_ff = [];
  r_dft = [];
  r_as = [];
  r_ps = [];
  
  ## number of samples and signals
  [Nsmp, Nsig] = size(p_xx);
  
  ## zero padding, FFT points
  if (p_zp > 0)
    ## zero padding
    zz = zeros(p_zp, Nsig);
    p_xx = [p_xx; zz];
    Nfft = Nsmp + p_zp;
    enbw = Nfft / Nsmp;
  else
    ## no zero padding
    Nfft = Nsmp;
    enbw = Nfft / Nsmp;
  endif
  
  ## frequency array, bilateral
  ff2 = [-(ceil((Nfft - 1) / 2) : -1 : 1), 0, (1 : floor((Nfft - 1) / 2))] * (p_fs / Nfft);
  
  ## estimate DFT, bilateral
  dft2 = fftshift(1 / Nsmp * fft(p_xx), 1);
  
  ## unilateral representation of the DFT
  if (mod(Nfft, 2) == 1)
    ## odd number of FFT points
    ul_idx0 = (Nfft - 1) / 2 + 1; # unilateral zero bin index
    soff = 1; # scaling offset, bilateral -> unilateral, skip DC-bin (k = 0), because that value is unique in the bilateral DFT
  else
    ## even number of FFT points
    ul_idx0 = Nfft / 2 + 1; # unilateral zero bin index
    soff = 0; # scaling offset, bilateral -> unilateral, scale all magnitudes, because all of them appear twise in the bilateral DFT
  endif
  
  ## select range
  switch (lower(p_rn))
    case {'bilateral', 'bi', 'b', 'full', 'f', 'twosided', 'two'}
      ## bilateral estimates
      ## return frequency array
      r_ff = ff2;
      ## return DFT, complex valued
      if isargout(2)
        r_dft = dft2;
      endif
      ## return amplitude (RMS) spectrum
      if isargout(3)
        r_as = abs(dft2);
      endif
      ## return power spectrum
      if isargout(4)
        r_ps = abs(dft2).^2;
      endif
      ## return linear spectral density
      if isargout(5)
        r_lsd = abs(dft2).^2 / enbw;
      endif
      ## return power spectral density
      if isargout(6)
        r_psd = abs(dft2).^2 / enbw;
      endif
    otherwise
      ## unilateral estimates
      ## return frequency array
      r_ff = ff2(ul_idx0 : end);
      ## return DFT, complex valued
      if isargout(2)
        r_dft = dft2(ul_idx0 : end, :);
        r_dft(1 + soff : end - soff, :) *= 2;
      endif
      ## return amplitude (RMS) spectrum
      if isargout(3)
        r_as = abs(dft2(ul_idx0 : end, :));
        r_as(1 + soff : end - soff, :) *= 2;
      endif
      ## return power spectrum
      if isargout(4)
        r_ps = abs(dft2(ul_idx0 : end, :)).^2;
        r_ps(1 + soff : end - soff, :) *= 2;
      endif
      ## return linear spectral density
      if isargout(5)
        r_lsd = abs(dft2(ul_idx0 : end, :)) / enbw;
        r_lsd(1 + soff : end - soff, :) *= 2;
      endif
      ## return power spectral density
      if isargout(6)
        r_psd = abs(dft2(ul_idx0 : end, :)).^2 / enbw;
        r_psd(1 + soff : end - soff, :) *= 2;
      endif
  endswitch
  
  ## return equivalent noise bandwidth
  if isargout(7)
    r_enbw = enbw;
  endif
  
endfunction

