## Estimate frequency range estimates for all datasets of a test series
##
## Usage: test_fqband(p_rm)
##
## p_rm ... run mode (see below), optional, default = 'sig', <str>
##
## Run modes:
##   p_rm = 'sig': plot synthetic test signals
##   p_rm = 'syn': plot analysis, synthetic signals
##   p_rm = 'nat': plot analysis, natural signals
##   p_rm = 'ts':  plot dataset analysis results, all datasets from different test series
##   p_rm = 'pow': compare power estimates of time and frequency domain
##
## see also: tool_scale_noise2snr, tool_est_dft_fqband, dsdefs
##
## Copyright 2024 Jakob Harden (jakob.harden@tugraz.at, Graz University of Technology, Graz, Austria)
## This file is part of the PhD thesis of Jakob Harden.
##
function [r_ds] = test_fqband(p_rm)
  
  ## check arguments
  if (nargin < 1)
    p_rm = 'sig';
  endif
  
  ## analysis parameter structure
  ## synthetic signals
  aps.FS = 100; # sampling frequency, Hz
  aps.A0 = 1; # V, default signal amplitude
  aps.Ncy = 3; # number of cycles
  aps.Nzp = aps.FS; # default zero padding length
  aps.FB = [1, 2, 3, 4, 5]; # frequency band, Hz
  aps.DF = 0; # default exponential decay factor
  aps.SNR = 1;  # default signal-to-noise ratio, dB (SNR)
  aps.ZPF = 0; # zero-padding factor, multiple of number of signal samples points
  aps.TPF = 0.93; # power threshold factor, used to estimate frequency band limit
  aps.TFF = 0.75; # frequency threshold factor, used to determine the noise measurement range
  ## natural signals
  sig_sid1 = [1, 24, 48, 72, 96, 144, 288]; # signal id's, selection 1
  sig_sid2 = [7, 74]; # signal id's, selection 2
  sig_sid3 = [5]; # signal id's, selection 3
  aps.nat_FS = 1e7; # sampling frequency, 10 MHz
  aps.nat_FR = [500000, 110000]; # sensor resonance frequency, natural frequency, 500 kHz, 110 kHz
  aps.nat_ZPF = 3; # zero-padding factor, multiple of number of signal samples
  aps.nat_TPF = [0.05, 0.93]; # power threshold factors, used to estimate frequency band limits
  aps.nat_TFF = 0.9; # frequency threshold factor, used to determine the noise measurement range
  aps.nat_ers = 100; # electromagnetic response section length (disturbance caused by pulse excitation)
  aps.nat_sel_tsid = [...
    1,  1,  1,  1, ...
    5,  5,  5, ...
    6,  6,  6]; # selected test series id's
  aps.nat_sel_dsid = [...
    4, 10, 16, 18, ...
    3, 15, 27, ...
    3, 15, 27]; # selected dataset id's
  aps.nat_sel_sids = {...
    sig_sid1, sig_sid1, sig_sid1, sig_sid2, ...
    sig_sid3, sig_sid3, sig_sid3, ...
    sig_sid3, sig_sid3, sig_sid3}; # selected signal id's, one group of ids per data set
  aps.nat_tsid = 0; # test series id
  aps.nat_dsid = 0; # dataset id
  aps.nat_sids = []; # signal id's
  
  ## result directory path
  rpath = './results/test_fqband';
  if (exist(rpath, 'dir') != 7)
    mkdir(rpath);
  endif
  
  ## plot settings
  pss.rpath = rpath;
  pss.lc_x = [1, 1, 1] * 0.5; # gray, line color, signal in noise
  pss.lc_s = [0.654902, 0.027451, 0.254902]; # dark magenta, line color, signal
  pss.lc_pw = [0.1647, 0.3765, 0.6000]; # dark blue, line color, P-wave
  pss.lc_sw = [1.0000, 0.2510, 0.0000]; # dark red, line color, S-wave
  pss.lc_sep = [1, 1, 1] * 0.8; # light gray, line color, separator lines
  pss.bc_pw = [0.1647, 0.3765, 0.6000]; # light blue, fill color, P-wave
  pss.bc_sw = [1.0000, 0.6510, 0.6510]; # light red, fill color, S-wave
  pss.lw_x = 0.5; # linewidth, signal in noise
  pss.lw_s = 2; # linewidth, signal
  pss.lw_pw = 1; # linewidth, P-wave
  pss.lw_sw = 1; # linewidth, S-wave
  pss.lw_sep = 0.5; # linewidth, separator lines
  
  ## Generate/load standard noise (for reproducibility reasons)
  Nmax = 2 * aps.Nzp + aps.FS * aps.Ncy; # max number of samples
  vv_mat = tool_gen_noise(Nmax, 1, 1, pss.rpath); # noise matrix used for Monte-carlo tests
  
  switch (p_rm)
    case 'sig'
      ## plot signal
      for DF = [0, 1, 2, 3, 4]
        aps.DF = DF;
        for SNR = [0, 5, 10, 63]
          aps.SNR = SNR;
          test_fqband_sig(pss, aps, vv_mat);
        endfor
      endfor
    case 'syn'
      ## synthetic signals
      for DF = [0, 1, 2, 3, 4]
        aps.DF = DF;
        for SNR = [0, 5, 10, 63]
          aps.SNR = SNR;
          test_fqband_syn(pss, aps, vv_mat);
        endfor
      endfor
    case 'nat'
      ## natural signal
      for k = 1 #1 : numel(aps.nat_sel_tsid)
        aps.nat_tsid = aps.nat_sel_tsid(k);
        aps.nat_dsid = aps.nat_sel_dsid(k);
        aps.nat_sids = aps.nat_sel_sids{k};
        defs = dsdefs(aps.nat_tsid);
        aps.nat_dsfp = defs.dsl{aps.nat_dsid};
        for j = aps.nat_sids
          aps.nat_sid = j;
          test_fqband_nat(pss, aps);
        endfor
      endfor
    case 'ts'
      ## compute all test series, natural signals
      p_aps.nat_sids = [];
      for k = [1, 3, 4, 5, 6]
        defs = dsdefs(k);
        aps.nat_tsid = k;
        for j = 1 : defs.dsnum
          aps.nat_dsid = j;
          aps.nat_dsfp = defs.dsl{j};
          test_fqband_ts(pss, aps);
        endfor
      endfor
    case 'pow'
      ## compare power estimates, time and frequency domain
      test_fqband_pow();
  endswitch
  
endfunction


function [r_fc] = test_fqband_fqcen(p_ff, p_pp, p_flim)
  ## Estimate center frequency of frequency band
  ##
  ## p_ff   ... frequency array, [<dbl>]
  ## p_pp   ... PSD magnitude array, [<dbl>]
  ## p_flim ... frequency band limit, <dbl>
  ## r_fc   ... return: frequency band center frequency, weighted average, <dbl>
  
  ## bin index of frequency limit
  klim = find(p_ff >= p_flim, 1, 'first');
  
  ## center frequency, weighted average
  ff = p_ff(1 : klim)(:);
  pp = p_pp(1 : klim)(:);
  r_fc = sum(pp .* ff) / sum(pp);
  
endfunction


function test_fqband_sig(p_ps, p_aps, p_vm)
  ## Plot signal examples
  ##
  ## p_ps  ... plot settings structure, <struct>
  ## p_aps ... analysis parameter structure, <struct>
  ## p_vm  ... standard noise matrix, [[<dbl>]]
  
  ## generate signal
  Ns = p_aps.FS * p_aps.Ncy; # signal length
  ss = zeros(Ns, 1);
  ww0 = linspace(0, 2 * pi, Ns); # angular frequency
  for j = p_aps.FB
    ss_j = transpose(p_aps.A0 * sin(ww0 * j));
    ss = ss .+ ss_j;
  endfor
  ee = transpose(exp(-p_aps.DF * ww0 / (2 * pi))); # exponential decay
  ss = ss .* ee; # signal with exponential decay
  si = sprintf('Low-pass, A_0 = %.1f V, F = [%d, %d, %d, %d, %d] Hz, DF = %d, SNR = %d dB', p_aps.A0, p_aps.FB, p_aps.DF, p_aps.SNR);
  
  ## zero-padding, front and back
  ss_zp = [zeros(p_aps.Nzp, 1); ss; zeros(p_aps.Nzp, 1)]; # zero-padded signal, column
  nn_zp = 1 : length(ss_zp); # zero-padded signal index
  nn_sp = p_aps.Nzp + 1 : p_aps.Nzp + Ns; # signal partition index
  ps = meansq(ss_zp); # signal power
  
  ## noise
  [vv_zp, ~, ~, ~] = tool_scale_noise2snr(ps, p_vm(nn_zp, 1), p_aps.SNR); # scale noise to SNR w.r.t. signal partition => exact SNR
  
  ## generate signal in noise
  xx_zp = ss_zp + vv_zp; # zero-padded signal in noise, column
  
  ## create figure
  fh = figure('name', 'test_fqband, signal', 'position', [100, 100, 800, 800 / 1.62]);
  
  ## create axes
  ah = axes(fh, 'tickdir', 'out');
  
  ## begin plot
  hold(ah, 'on');
  
  ## plot signal curves
  plot(ah, nn_zp, xx_zp, ';x[n];', 'color', p_ps.lc_x, 'linewidth', p_ps.lw_x);
  plot(ah, nn_zp, ss_zp, ';s[n];', 'color', p_ps.lc_s, 'linewidth', p_ps.lw_s);
  
  ## end plot
  hold(ah, 'off');
  
  ## title, labels
  xlabel('Sample index [1]');
  ylabel('Amplitude [V]');
  title(sprintf('Sinusoidal signal in noise\n%s', si));
  legend(ah, 'box', 'off');
  
  ## save figure
  ofn_pfx = sprintf('sig_DF_%d_SNR_%d', p_aps.DF, p_aps.SNR);
  hgsave(fh, fullfile(p_ps.rpath, sprintf('%s.ofig', ofn_pfx)));
  saveas(fh, fullfile(p_ps.rpath, sprintf('%s.png', ofn_pfx)), 'png');
  close(fh);
  
endfunction


function test_fqband_syn(p_ps, p_aps, p_vm)
  ## Plot analysis, synthetic signals
  ##
  ## p_ps  ... plot settings structure, <struct>
  ## p_aps ... analysis parameter structure, <struct>
  ## p_vm  ... standard noise matrix, [[<dbl>]]
  
  ## generate signal, 3 cycles
  Ns = p_aps.FS * p_aps.Ncy; # signal length
  ss = zeros(Ns, 1);
  nn0 = linspace(0, 2 * pi * p_aps.Ncy, Ns); # angular frequency
  for j = p_aps.FB
    ss_j = transpose(p_aps.A0 * sin(nn0 * j));
    ss = ss .+ ss_j;
  endfor
  ee = transpose(exp(-p_aps.DF * nn0 / (2 * pi))); # exponential decay
  ss = ss .* ee; # signal with exponential decay
  si = sprintf('Low-pass, A_0 = %.1f V, F_{lim} = %d Hz, F_s = %d Hz, DF = %d, SNR = %d dB', p_aps.A0, p_aps.FB(end), p_aps.FS, p_aps.DF, p_aps.SNR);
  
  ## zero-padding, front and back
  ss_zp = [zeros(p_aps.Nzp, 1); ss; zeros(p_aps.Nzp, 1)]; # zero-padded signal, column
  nn_zp = 1 : length(ss_zp); # zero-padded signal index
  nn_sp = p_aps.Nzp + 1 : p_aps.Nzp + Ns; # signal partition index
  ps = meansq(ss_zp); # signal power
  
  ## noise
  [vv_zp, ~, ~, ~] = tool_scale_noise2snr(ps, p_vm(nn_zp, 1), p_aps.SNR); # scale noise to SNR w.r.t. signal partition => exact SNR
  
  ## generate signal in noise
  xx_zp = ss_zp + vv_zp; # zero-padded signal in noise, column
  
  ## estimate frequency band limit
  [fb, ff, psd, cc, pow, tff] = tool_est_dft_fqband(xx_zp, p_aps.FS, p_aps.ZPF, p_aps.TPF, p_aps.TFF);
  thv = pow(3) * p_aps.TPF;
  
  ## estimate average noise magnitude
  Nbin = numel(ff);
  Lvm = floor(Nbin * tff);
  Lsig = Nbin - Lvm;
  avm = mean(psd(Lsig + 1 : end));
  
  ## create figure
  fh = figure('name', 'test_fqband', 'position', [100, 100, 800, 800 / 1.62]);
  
  ## subplot 1, DFT
  sh = subplot(2, 1, 1);
  set(sh, 'tickdir', 'out');
  ## begin plot
  hold(sh, 'on');
  ## plot noise measurement range
  fill(sh, ff([Lsig + 1, end, end, Lsig + 1]), [0, 0, max(psd) / 2, max(psd) / 2], [1, 1, 1] * 0.8, 'edgecolor', 'none');
  text(sh, ff(end), max(psd) / 2, 'noise measurement range', 'horizontalalignment', 'right', 'verticalalignment', 'bottom');
  ## plot power spectrum
  plot(sh, ff, psd, ';PSD;', 'color', p_ps.lc_s, 'linewidth', p_ps.lw_s);
  ## plot frequency band limit
  plot(sh, [1, 1] * fb, ylim(), 'color', 'k', 'handlevisibility', 'off');
  text(sh, fb, ylim()(2), sprintf(' F_{lim} = %.1f Hz', fb), 'horizontalalignment', 'left', 'verticalalignment', 'top');
  ## end plot
  hold(sh, 'off');
  ## title, labels
  xlabel(sh, 'Sample index [1]');
  ylabel(sh, 'Magnitude [V^2/Hz]');
  title(sh, sprintf('Power spectral density (PSD)'));
  legend(sh, 'visible', 'off');
  
  ## subplot 2, CUMSUM
  sh = subplot(2, 1, 2);
  set(sh, 'tickdir', 'out');
  ylim([0, max(cc) * 1.025]);
  ## begin plot
  hold(sh, 'on');
  ## plot cumulative sum
  plot(sh, ff(1 : size(cc, 1)), cc, ';CS(PSD);', 'color', p_ps.lc_s, 'linewidth', p_ps.lw_s);
  ## plot threshold, upper frequency band limit
  plot(sh, ff([1, end]), [1, 1] * thv, 'color', 'k', 'linewidth', 1, 'handlevisibility', 'off');
  text(sh, ff(1), thv, sprintf(' t_P = %.2f', thv), 'horizontalalignment', 'left', 'verticalalignment', 'bottom');
  ## plot frequency band limit
  plot(sh, [1, 1] * fb, ylim(), 'color', 'k', 'handlevisibility', 'off');
  text(sh, fb, ylim()(1), sprintf(' F_{lim} = %.1f Hz', fb), 'horizontalalignment', 'left', 'verticalalignment', 'bottom');
  ## end plot
  hold(sh, 'off');
  ## title, labels
  xlabel(sh, 'Frequency [Hz]');
  ylabel(sh, 'Magnitude [V^2]');
  title(sh, sprintf('Cumulative sum of PSD'));
  legend(sh, 'visible', 'off');
  
  ## main axes
  ah = axes(fh, 'visible', 'off');
  title(ah, sprintf('%s', si));
  
  ## save figure
  ofn_pfx = sprintf('syn_DF_%d_SNR_%d', p_aps.DF, p_aps.SNR);
  hgsave(fh, fullfile(p_ps.rpath, sprintf('%s.ofig', ofn_pfx)));
  saveas(fh, fullfile(p_ps.rpath, sprintf('%s.png', ofn_pfx)), 'png');
  close(fh);
  
endfunction


function test_fqband_nat(p_ps, p_aps)
  ## Plot analysis, natural signals
  ##
  ## p_ps  ... plot settings structure, <struct>
  ## p_aps ... analysis parameter structure, <struct>
  
  ## load dataset
  ds = load(p_aps.nat_dsfp, 'dataset').dataset;
  dscode = ds.meta_set.a01.v; # data set code
  ntr = ds.tst.s06.d09.v; # trigger-point index
  nn = transpose(ntr + p_aps.nat_ers : size(ds.tst.s06.d13.v, 1)); # sample index array
  x1 = ds.tst.s06.d13.v(nn, p_aps.nat_sid); # natural signal, P-wave
  x2 = ds.tst.s07.d13.v(nn, p_aps.nat_sid); # natural signal, S-wave
  si = sprintf('Data set %s, SID = %d', strrep(dscode, '_', '\_'), p_aps.nat_sid);
  
  ## estimate frequency band limit
  [fb1, ff, psd1, cc1, pow1, tff1] = tool_est_dft_fqband(x1, p_aps.nat_FS, p_aps.nat_ZPF, p_aps.nat_TPF, p_aps.nat_TFF); # P-wave
  fc1 = test_fqband_fqcen(ff, psd1, fb1(2));
  thv1 = pow1(3) * p_aps.nat_TPF;
  
  [fb2, ff, psd2, cc2, pow2, tff2] = tool_est_dft_fqband(x2, p_aps.nat_FS, p_aps.nat_ZPF, p_aps.nat_TPF, p_aps.nat_TFF); # S-wave
  fc2 = test_fqband_fqcen(ff, psd2, fb2(2));
  thv2 = pow2(3) * p_aps.nat_TPF;
  
  ## convert frequencies from Hz to kHz
  fb1 /= 1e3;
  fb2 /= 1e3;
  ff /= 1e3;
  fc1 /= 1e3;
  fc2 /= 1e3;
  
  ## convert V^2 to mV^2
  psd1 *= 1e6;
  psd2 *= 1e6;
  cc1 *= 1e6;
  cc2 *= 1e6;
  thv1 *= 1e6;
  thv2 *= 1e6;
  
  ## sample index x axis limits
  if (p_aps.nat_sid >= 144)
    lim_nn = [nn(1), nn(1) + floor((nn(end) - nn(1)) / 20)];
  elseif (p_aps.nat_sid >= 96)
    lim_nn = [nn(1), nn(1) + floor((nn(end) - nn(1)) / 10)];
  elseif (p_aps.nat_sid >= 72)
    lim_nn = [nn(1), nn(1) + floor((nn(end) - nn(1)) / 8)];
  elseif (p_aps.nat_sid >= 48)
    lim_nn = [nn(1), nn(1) + floor((nn(end) - nn(1)) / 4)];
  else
    lim_nn = [nn(1), nn(end)];
  endif
  
  ## frequency x axis limits
  fmax1 = fb1(2) * 6;
  fmax2 = fb2(2) * 6;
  lim_ff1 = [0, fmax1];
  lim_ff2 = [0, fmax2];
  
  ## PSD and CumSum y axis limits
  fmax1_kk = find(ff <= fmax1);
  fmax2_kk = find(ff <= fmax2);
  lim_psd1 = [0, max(psd1(fmax1_kk))] * 1.1;
  lim_psd2 = [0, max(psd2(fmax2_kk))] * 1.1;
  lim_cc1 = [0, max(cc1(fmax1_kk))] * 1.1;
  lim_cc2 = [0, max(cc2(fmax2_kk))] * 1.1;
  
  ## create figure
  fh = figure('name', 'test_fqband, natapp', 'position', [100, 100, 800, 800 / 1.62]);
  
  ##---------------------------------------------------------------------------
  ## subplot 1, P-wave signal
  sh = subplot(3, 2, 1);
  set(sh, 'tickdir', 'out', 'fontsize', 9);
  xlim(sh, lim_nn);
  ## begin plot
  hold(sh, 'on');
  ## plot signal
  plot(sh, nn([1, end]), [0, 0], 'linewidth', p_ps.lw_x, 'color', p_ps.lc_x, 'handlevisibility', 'off');
  plot(sh, nn, x1 / max(abs(x1)), ';x_P;', 'color', p_ps.lc_pw, 'linewidth', p_ps.lw_pw);
  ## end plot
  hold(sh, 'off');
  ## title, labels
  xlabel(sh, 'Sample index [1]');
  ylabel(sh, 'Amplitude, norm. [1]');
  title(sh, sprintf('P-wave response'), 'fontweight', 'normal');
  legend(sh, 'visible', 'off');
  
  ##---------------------------------------------------------------------------
  ## subplot 2, S-wave signal
  sh = subplot(3, 2, 2);
  set(sh, 'tickdir', 'out', 'fontsize', 9);
  xlim(sh, lim_nn);
  ## begin plot
  hold(sh, 'on');
  ## plot signal
  plot(sh, nn([1, end]), [0, 0], 'linewidth', p_ps.lw_x, 'color', p_ps.lc_x, 'handlevisibility', 'off');
  plot(sh, nn, x2 / max(abs(x2)), ';x_S;', 'color', p_ps.lc_sw, 'linewidth', p_ps.lw_sw);
  ## end plot
  hold(sh, 'off');
  ## title, labels
  xlabel(sh, 'Sample index [1]');
  #ylabel(sh, 'Amplitude, norm. [1]');
  title(sh, sprintf('S-wave response'), 'fontweight', 'normal');
  legend(sh, 'visible', 'off');
  
  ##---------------------------------------------------------------------------
  ## subplot 3, P-wave power spectral density
  sh = subplot(3, 2, 3);
  set(sh, 'tickdir', 'out', 'fontsize', 9);
  xlim(lim_ff1);
  ylim(lim_psd1);
  ## begin plot
  hold(sh, 'on');
  ## plot power spectrum
  plot(sh, ff, psd1, ';PSD_P;', 'color', p_ps.lc_pw, 'linewidth', p_ps.lw_pw);
  ## plot frequency band limit
  plot(sh, [1, 1] * fb1(2), ylim(), 'color', 'k', 'linewidth', p_ps.lw_sep, 'handlevisibility', 'off');
  text(sh, fb1(2), ylim()(2), sprintf(' F_{lim} = %.1f kHz', fb1(2)), 'horizontalalignment', 'left', 'verticalalignment', 'top', 'fontsize', 9);
  ## plot center frequency
  plot(sh, [1, 1] * fc1, ylim(), 'color', 'k', 'linewidth', p_ps.lw_sep, 'handlevisibility', 'off');
  text(sh, fc1, ylim()(2) * 0.8, sprintf(' F_{cen} = %.1f kHz', fc1), 'horizontalalignment', 'left', 'verticalalignment', 'top', 'fontsize', 9);
  ## end plot
  hold(sh, 'off');
  ## title, labels
  #xlabel(sh, 'Frequency [kHz]');
  ylabel(sh, 'Magnitude [mV^2/Hz]');
  title(sh, sprintf('Power spectral density (PSD)'), 'fontweight', 'normal');
  legend(sh, 'visible', 'off');
  
  ##---------------------------------------------------------------------------
  ## subplot 4, S-wave power spectral density
  sh = subplot(3, 2, 4);
  set(sh, 'tickdir', 'out', 'fontsize', 9);
  xlim(lim_ff2);
  ylim(lim_psd2);
  ## begin plot
  hold(sh, 'on');
  ## plot power spectrum
  plot(sh, ff, psd2, ';PSD_S;', 'color', p_ps.lc_sw, 'linewidth', p_ps.lw_sw);
  ## plot frequency band limit
  plot(sh, [1, 1] * fb2(2), ylim(), 'color', 'k', 'linewidth', p_ps.lw_sep, 'handlevisibility', 'off');
  text(sh, fb2(2), ylim()(2), sprintf(' F_{lim} = %.1f kHz', fb2(2)), 'horizontalalignment', 'left', 'verticalalignment', 'top', 'fontsize', 9);
  ## plot center frequency
  plot(sh, [1, 1] * fc2, ylim(), 'color', 'k', 'linewidth', p_ps.lw_sep, 'handlevisibility', 'off');
  text(sh, fc2, ylim()(2) * 0.8, sprintf(' F_{cen} = %.1f kHz', fc2), 'horizontalalignment', 'left', 'verticalalignment', 'top', 'fontsize', 9);
  ## end plot
  hold(sh, 'off');
  ## title, labels
  #xlabel(sh, 'Frequency [kHz]');
  #ylabel(sh, 'Magnitude [mV^2/Hz]');
  title(sh, sprintf('Power spectral density (PSD)'), 'fontweight', 'normal');
  legend(sh, 'visible', 'off');
  
  ##---------------------------------------------------------------------------
  ## subplot 5, P-wave cumulative sum
  sh = subplot(3, 2, 5);
  set(sh, 'tickdir', 'out', 'fontsize', 9);
  xlim(lim_ff1);
  ylim(lim_cc1);
  ## begin plot
  hold(sh, 'on');
  ## plot cumulative sum
  plot(sh, ff, cc1, ';CS(PSD_P);', 'color', p_ps.lc_pw, 'linewidth', p_ps.lw_pw);
  ## plot threshold, upper frequency band limit
  plot(sh, ff([1, end]), [1, 1] * thv1(2), 'color', 'k', 'linewidth', p_ps.lw_sep, 'handlevisibility', 'off');
  text(sh, lim_ff1(2), thv1(2), sprintf(' t_P = %.2e', thv1(2)), 'horizontalalignment', 'right', 'verticalalignment', 'top', 'fontsize', 9);
  ## plot frequency band limit
  plot(sh, [1, 1] * fb1(2), ylim(), 'color', 'k', 'linewidth', p_ps.lw_sep, 'handlevisibility', 'off');
  text(sh, fb1(2), ylim()(1), sprintf(' F_{lim} = %.1f kHz', fb1(2)), 'horizontalalignment', 'left', 'verticalalignment', 'bottom', 'fontsize', 9);
  ## plot center frequency
  plot(sh, [1, 1] * fc1, ylim(), 'color', 'k', 'linewidth', p_ps.lw_sep, 'handlevisibility', 'off');
  text(sh, fc1, ylim()(2) * 0.4, sprintf(' F_{cen} = %.1f kHz', fc1), 'horizontalalignment', 'left', 'verticalalignment', 'top', 'fontsize', 9);
  ## end plot
  hold(sh, 'off');
  ## title, labels
  xlabel(sh, 'Frequency [kHz]');
  ylabel(sh, 'Magnitude [mV^2]');
  title(sh, sprintf('Cumulative sum of PSD'), 'fontweight', 'normal');
  legend(sh, 'visible', 'off');
  
  ##---------------------------------------------------------------------------
  ## subplot 6, S-wave cumulative sum
  sh = subplot(3, 2, 6);
  set(sh, 'tickdir', 'out', 'fontsize', 9);
  xlim(lim_ff2);
  ylim(lim_cc2);
  ## begin plot
  hold(sh, 'on');
  ## plot cumulative sum
  plot(sh, ff, cc2, ';CS(PSD_S);', 'color', p_ps.lc_sw, 'linewidth', p_ps.lw_sw);
  ## plot threshold, upper frequency band limit
  plot(sh, ff([1, end]), [1, 1] * thv2(2), 'color', 'k', 'linewidth', p_ps.lw_sep, 'handlevisibility', 'off');
  text(sh, lim_ff2(2), thv2(2), sprintf(' t_P = %.2e', thv2(2)), 'horizontalalignment', 'right', 'verticalalignment', 'top', 'fontsize', 9);
  ## plot frequency band limit
  plot(sh, [1, 1] * fb2(2), ylim(), 'color', 'k', 'linewidth', p_ps.lw_sep, 'handlevisibility', 'off');
  text(sh, fb2(2), ylim()(1), sprintf(' F_{lim} = %.1f kHz', fb2(2)), 'horizontalalignment', 'left', 'verticalalignment', 'bottom', 'fontsize', 9);
  ## plot center frequency
  plot(sh, [1, 1] * fc2, ylim(), 'color', 'k', 'linewidth', p_ps.lw_sep, 'handlevisibility', 'off');
  text(sh, fc2, ylim()(2) * 0.4, sprintf(' F_{cen} = %.1f kHz', fc2), 'horizontalalignment', 'left', 'verticalalignment', 'top', 'fontsize', 9);
  ## end plot
  hold(sh, 'off');
  ## title, labels
  xlabel(sh, 'Frequency [kHz]');
  #ylabel(sh, 'Magnitude [mV^2]');
  title(sh, sprintf('Cumulative sum of PSD'), 'fontweight', 'normal');
  legend(sh, 'visible', 'off');
  
  ##---------------------------------------------------------------------------
  ## main axes
  ah = axes(fh, 'visible', 'off');
  title(ah, sprintf('%s', si));
  
  ## save figure
  ofn_pfx = sprintf('nat_DS_%s_SID_%d', dscode, p_aps.nat_sid);
  hgsave(fh, fullfile(p_ps.rpath, sprintf('%s.ofig', ofn_pfx)));
  saveas(fh, fullfile(p_ps.rpath, sprintf('%s.png', ofn_pfx)), 'png');
  close(fh);
  
endfunction


function test_fqband_ts(p_ps, p_aps)
  ## Plot analysis, test series datasets
  ##
  ## p_ps  ... plot settings structure, <struct>
  ## p_aps ... analysis parameter structure, <struct>
  
  ## load dataset
  ds = load(p_aps.nat_dsfp, 'dataset').dataset;
  dscode = ds.meta_set.a01.v; # data set code
  ntr = ds.tst.s06.d09.v; # trigger-point index
  nn = transpose(ntr + p_aps.nat_ers : size(ds.tst.s06.d13.v, 1)); # sample index array
  jj = transpose(1 : size(ds.tst.s06.d13.v, 2)); # signal index array
  x1 = ds.tst.s06.d13.v(nn, :); # natural signal, P-wave
  x2 = ds.tst.s07.d13.v(nn, :); # natural signal, S-wave
  si = sprintf('data set %s', strrep(dscode, '_', '\_'));
  
  ## status message
  printf('Test series analysis: dataset = %s\n', dscode);
  
  ## estimate frequency band limit
  [fb1, ff1, pp1, ~, ~, ~] = tool_est_dft_fqband(x1, p_aps.nat_FS, p_aps.nat_ZPF, p_aps.nat_TPF, p_aps.nat_TFF); # P-wave
  [fb2, ff2, pp2, ~, ~, ~] = tool_est_dft_fqband(x2, p_aps.nat_FS, p_aps.nat_ZPF, p_aps.nat_TPF, p_aps.nat_TFF); # S-wave
  
  ## frequency band center frequencies
  fc1 = zeros(size(fb1, 1), 1);
  fc2 = fc1;
  for j = 1 : size(fb1, 1)
    fc1(j) = test_fqband_fqcen(ff1, pp1(:, j), fb1(j, 2));
    fc2(j) = test_fqband_fqcen(ff2, pp2(:, j), fb2(j, 2));
  endfor
  
  ## convert frequencies from Hz to kHz
  ff1 /= 1e3;
  ff2 /= 1e3;
  fb1 /= 1e3;
  fb2 /= 1e3;
  fc1 /= 1e3;
  fc2 /= 1e3;
  Fnat = p_aps.nat_FR / 1e3; # natural frequency of sensor
  
  ## maximum frequency
  fmax = max([max(fb1), max(fb2), Fnat]);
  
  ## create figure
  fh = figure('name', 'test_fqband, natserapp', 'position', [100, 100, 800, 800 / 1.62]);
  
  ## create axes
  ah = axes(fh, 'tickdir', 'out');
  xlim([jj(1), jj(end)]);
  ylim([0, fmax * 1.1]);
  
  ## begin plot
  hold(ah, 'on');
  
  ## plot limit and center frequency, P-wave
  plot(ah, jj, fc1, ';F_{P,cen};', 'color', p_ps.lc_pw, 'linewidth', 2);
  plot(ah, jj, fb1(:, 2), ';F_{P,lim};', 'color', p_ps.lc_pw, 'linewidth', p_ps.lw_pw);
  
  ## plot limit and center frequency, S-wave
  plot(ah, jj, fc2, ';F_{S,cen};', 'color', p_ps.lc_sw, 'linewidth', 2);
  plot(ah, jj, fb2(:, 2), ';F_{S,lim};', 'color', p_ps.lc_sw, 'linewidth', p_ps.lw_sw);
  
  ## plot time steps (one index step equals 5 Minutes)
  if ((p_aps.nat_tsid == 1) || (p_aps.nat_tsid == 4))
    mat_scale = [1, 24, 48, 96, 144, 288];
    for j = mat_scale
      if (j == mat_scale(end))
        halign = 'right';
        pre_space = '';
        post_space = ' ';
      else
        halign = 'left';
        pre_space = ' ';
        post_space = '';
      endif
      hrs = floor((j / 12)); # convert signal index to hours
      plot(ah, [1, 1] * j, ylim(), 'color', p_ps.lc_sep, 'linewidth', p_ps.lw_sep,'handlevisibility', 'off');
      text(ah, j, ylim()(2), sprintf('%s%d h%s', pre_space, hrs, post_space), 'horizontalalignment', halign, 'verticalalignment', 'top');
    endfor
  endif
  
  ## plot sensor resonance frequency, natural frequency
  if (p_aps.nat_tsid == 4)
    plot(ah, [jj(1), jj(end)], [1, 1] * Fnat(1), '--', 'color', p_ps.lc_pw, 'linewidth', 1, 'handlevisibility', 'off');
    text(ah, jj(1), Fnat(1), ' F_{nat} (channel 1)', 'horizontalalignment', 'left', 'verticalalignment', 'bottom');
    plot(ah, [jj(1), jj(end)], [1, 1] * Fnat(2), '--', 'color', p_ps.lc_sw, 'linewidth', 1, 'handlevisibility', 'off');
    text(ah, jj(1), Fnat(2), ' F_{nat} (channel 2)', 'horizontalalignment', 'left', 'verticalalignment', 'bottom');
  else
    plot(ah, [jj(1), jj(end)], [1, 1] * Fnat(1), '--', 'color', p_ps.lc_s, 'linewidth', 1, 'handlevisibility', 'off');
    text(ah, jj(1), Fnat(1), ' F_{nat} (channel 1 and 2)', 'horizontalalignment', 'left', 'verticalalignment', 'bottom');
  endif
  
  ## end plot
  hold(ah, 'off');
  
  ## title, labels
  xlabel(ah, 'Signal index [1]');
  ylabel(ah, 'Frequency [kHz]');
  title(ah, sprintf('Frequency band limits - %s', si));
  legend(ah, 'box', 'off', 'location', 'southoutside', 'orientation', 'horizontal');
  
  ## save figure
  ofn_pfx = sprintf('ts_DS_%s', dscode);
  hgsave(fh, fullfile(p_ps.rpath, sprintf('%s.ofig', ofn_pfx)));
  saveas(fh, fullfile(p_ps.rpath, sprintf('%s.png', ofn_pfx)), 'png');
  close(fh);
  
endfunction


function test_fqband_pow()
  ## Compare power estimates in time and frequency domain
  
  ##---------------------------------------------------------------------------
  ## signal
  A = 1;
  Nsmp = 100;
  nn = linspace(0, 2 * pi, Nsmp + 1);
  ss = transpose(A * sin(nn))(1:end-1);
  vv = randn(Nsmp, 1);
  xx = ss + vv;
  
  ##---------------------------------------------------------------------------
  ## time domain
  Ps_t = meansq(ss);
  Pv_t = meansq(vv);
  Px_t = meansq(xx);
  Px1_t = Ps_t + Pv_t;
  printf('Time domain power estimates\n');
  printf('  Ps = %.8f, Pv = %.8f, Px = %.8f, Px1 = Ps + Pv = %.8f\n', Ps_t, Pv_t, Px_t, Px1_t);
  
  ##---------------------------------------------------------------------------
  ## frequency domain, without zero padding
  [FF, ~, AS1, PS1, LSD1, PSD1, ENBW] = tool_est_dft(ss, Nsmp, 0, 'unilateral');
  Ps_f = sum(PSD1);
  [FF, ~, AS2, PS2, LSD2, PSD2, ENBW] = tool_est_dft(vv, Nsmp, 0, 'unilateral');
  Pv_f = sum(PSD2);
  [FF, ~, AS3, PS3, LSD3, PSD3, ENBW] = tool_est_dft(xx, Nsmp, 0, 'unilateral');
  Px_f = sum(PSD3);
  Px1_f = Ps_f + Pv_f;
  printf('Frequency domain power estimates, no zero-padding, sum(PSD)\n');
  printf('  N = %d, Nfft = %d, ENBW = %.4f\n', Nsmp, Nsmp * 4, ENBW);
  printf('  Ps = %.8f, Pv = %.8f, Px = %.8f, Px1 = Ps + Pv = %.8f\n', Ps_f, Pv_f, Px_f, Px1_f);
  
  figure();
  subplot(2, 2, 1);
  hold on;
  plot(FF, AS1, ';s;');
  plot(FF, AS2, ';v;');
  plot(FF, AS3, ';x;');
  hold off;
  xlabel('Frequency [Hz]');
  ylabel('Amplitude [V]');
  title('Amplitude spectrum (AS)');
  legend('box', 'off');
  subplot(2, 2, 2);
  hold on;
  plot(FF, PS1, ';s;');
  plot(FF, PS2, ';v;');
  plot(FF, PS3, ';x;');
  hold off;
  xlabel('Frequency [Hz]');
  ylabel('Power [V^2]');
  title('Power spectrum (PS)');
  legend('box', 'off');
  subplot(2, 2, 3);
  hold on;
  plot(FF, LSD1, ';s;');
  plot(FF, LSD2, ';v;');
  plot(FF, LSD3, ';x;');
  hold off;
  xlabel('Frequency [Hz]');
  ylabel('Amplitude [V/Hz]');
  title('Linear spectral density (LSD)');
  legend('box', 'off');
  subplot(2, 2, 4);
  hold on;
  plot(FF, PSD1, ';s;');
  plot(FF, PSD2, ';v;');
  plot(FF, PSD3, ';x;');
  hold off;
  xlabel('Frequency [Hz]');
  ylabel('Power [V^2/Hz]');
  title('Power spectral density (PSD)');
  legend('box', 'off');
  
  ##---------------------------------------------------------------------------
  ## frequency domain, with zero padding
  [FF, ~, AS1, PS1, LSD1, PSD1, ENBW] = tool_est_dft(ss, Nsmp, Nsmp * 3, 'unilateral');
  Ps_f = sum(PSD1);
  [FF, ~, AS2, PS2, LSD2, PSD2, ENBW] = tool_est_dft(vv, Nsmp, Nsmp * 3, 'unilateral');
  Pv_f = sum(PSD2);
  [FF, ~, AS3, PS3, LSD3, PSD3, ENBW] = tool_est_dft(xx, Nsmp, Nsmp * 3, 'unilateral');
  Px_f = sum(PSD3);
  Px1_f = Ps_f + Pv_f;
  printf('Frequency domain power estimates, zero-padding, sum(PSD)\n');
  printf('  N = %d, Nfft = %d, ENBW = %.4f\n', Nsmp, Nsmp * 4, ENBW);
  printf('  Ps = %.8f, Pv = %.8f, Px = %.8f, Px1 = Ps + Pv = %.8f\n', Ps_f, Pv_f, Px_f, Px1_f);
  
  figure();
  subplot(2, 2, 1);
  hold on;
  plot(FF, AS1, ';s;');
  plot(FF, AS2, ';v;');
  plot(FF, AS3, ';x;');
  hold off;
  xlabel('Frequency [Hz]');
  ylabel('Amplitude [V]');
  title('Amplitude spectrum (AS)');
  legend('box', 'off');
  subplot(2, 2, 2);
  hold on;
  plot(FF, PS1, ';s;');
  plot(FF, PS2, ';v;');
  plot(FF, PS3, ';x;');
  hold off;
  xlabel('Frequency [Hz]');
  ylabel('Power [V^2]');
  title('Power spectrum (PS)');
  legend('box', 'off');
  subplot(2, 2, 3);
  hold on;
  plot(FF, LSD1, ';s;');
  plot(FF, LSD2, ';v;');
  plot(FF, LSD3, ';x;');
  hold off;
  xlabel('Frequency [Hz]');
  ylabel('Amplitude [V/Hz]');
  title('Linear spectral density (LSD)');
  legend('box', 'off');
  subplot(2, 2, 4);
  hold on;
  plot(FF, PSD1, ';s;');
  plot(FF, PSD2, ';v;');
  plot(FF, PSD3, ';x;');
  hold off;
  xlabel('Frequency [Hz]');
  ylabel('Power [V^2/Hz]');
  title('Power spectral density (PSD)');
  legend('box', 'off');
  
endfunction

