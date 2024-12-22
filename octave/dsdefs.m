## Dataset definitions
##
## Usage: [r_ds] = dsdefs(p_ti)
##
## p_ti ... test series id, <uint>
## r_ds ... return: dataset definition data structure, <struct_dsdef>
##
## see also: test_fqband
##
## Available dataset types:
##   p_ti = 1: cement paste tests
##   p_ti = 3: air reference tests, shear wave sensor F_resonance = 110 kHz
##   p_ti = 4: cement paste tests, shear wave sensor F_resonance = 110 kHz
##   p_ti = 5: reference tests, air
##   p_ti = 6: reference tests, water
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
function [r_ds] = dsdefs(p_ti)
  
  ## data set paths
  r_ds.dspath = '/home/harden/Documents/tugraz/0_test_series';
  r_ds.dspath1 = fullfile(r_ds.dspath, 'ts1_cem1_paste/oct');
  r_ds.dspath3 = fullfile(r_ds.dspath, 'ts3_ref_fs110khz/oct');
  r_ds.dspath4 = fullfile(r_ds.dspath, 'ts4_cem1_paste_fs110khz/oct');
  r_ds.dspath5 = fullfile(r_ds.dspath, 'ts5_ref_air/oct');
  r_ds.dspath6 = fullfile(r_ds.dspath, 'ts6_ref_water/oct');
  r_ds.dspaths = {r_ds.dspath1, '', r_ds.dspath3, r_ds.dspath4, r_ds.dspath5, r_ds.dspath6};
  
  ## switch dataset type enumerator
  dsp = r_ds.dspaths{p_ti};
  switch (p_ti)
    case 1
      r_ds = hlp_dsl1(dsp);
    case 3
      r_ds = hlp_dsl3(dsp);
    case 4
      r_ds = hlp_dsl4(dsp);
    case 5
      r_ds = hlp_dsl5(dsp);
    case 6
      r_ds = hlp_dsl6(dsp);
    otherwise
      error('Dataset type not available: %d', p_ti);
  endswitch
  
endfunction


function [r_ds] = hlp_dsl1(p_dp)
  ## Setup dataset list 1: cement paste
  ##
  ## p_dp ... dataset directory path, <str>
  ## r_ds ... return: dataset definition data structure, <struct_dsdef>
  
  r_ds.obj = 'dsdefs';
  r_ds.ver = uint16([1, 0]);
  r_ds.des = 'Dataset definition structure';
  
  r_ds.dsdir = p_dp;
  r_ds.dstype = 1;
  r_ds.dstype_str = 'cem1paste';
  r_ds.dsnum = 0;
  
  pl_wc = {'040', '045', '050', '055', '060'}; # water/cement ratio, string
  pl_di_num = [25, 50, 70]; # distance, number, mm
  pl_di = {'25', '50', '70'}; # distance, string, mm
  pl_rp = {'1', '2', '3', '4', '5', '6'}; # repetition, string
  r_ds.dsnum = length(pl_wc) * length(pl_di) * length(pl_rp);
  r_ds.dsl = cell(1, r_ds.dsnum);
  r_ds.dsc = cell(1, r_ds.dsnum);
  r_ds.dsd = zeros(1, r_ds.dsnum);
  cnt = 1;
  for i1 = 1 : length(pl_wc)
    for i2 = 1 : length(pl_di)
      for i3 = 1 : length(pl_rp)
        code = sprintf('ts1_wc%s_d%s_%s', pl_wc{i1}, pl_di{i2}, pl_rp{i3});
        fn = sprintf('%s.oct', code);
        r_ds.dsl{cnt} = fullfile(r_ds.dsdir, fn);
        r_ds.dsc{cnt} = code;
        r_ds.dsd(cnt) = pl_di_num(i2);
        cnt = cnt + 1;
      endfor
    endfor
  endfor
  
endfunction


function [r_ds] = hlp_dsl3(p_dp)
  ## Setup dataset list 1: cement paste
  ##
  ## p_dp ... dataset directory path, <str>
  ## r_ds ... return: dataset definition data structure, <struct_dsdef>
  
  r_ds.obj = 'dsdefs';
  r_ds.ver = uint16([1, 0]);
  r_ds.des = 'Dataset definition structure';
  
  r_ds.dsdir = p_dp;
  r_ds.dstype = 3;
  r_ds.dstype_str = 'refair110khz';
  r_ds.dsnum = 36;
  
  pl_pw_num = [2.5, 5, 7.5, 10, 12.5, 15]; # pulse width, number, uSec * 10
  pl_pw = {'025', '050', '075', '100', '125', '150'}; # pulse width, number, uSec
  pl_di_num = [0, 20, 50]; # distance, number, mm
  pl_di = {'00', '20', '50'}; # distance, string, mm
  pl_fq_num = [110, 500]; # sensor resonance frequency, Hz
  pl_fq = {'110', '500'}; # sensor resonance frequency, string, Hz
  r_ds.dsl = cell(1, r_ds.dsnum);
  r_ds.dsc = cell(1, r_ds.dsnum);
  r_ds.dsd = zeros(1, r_ds.dsnum);
  cnt = 1;
  for i1 = 1 : length(pl_di)
    for i2 = 1 : length(pl_fq)
      for i3 = 1 : length(pl_pw)
        code = sprintf('ts3_d%s_f%s_w%s', pl_di{i1}, pl_fq{i2}, pl_pw{i3});
        fn = sprintf('%s.oct', code);
        r_ds.dsl{cnt} = fullfile(r_ds.dsdir, fn);
        r_ds.dsc{cnt} = code;
        r_ds.dsd(cnt) = pl_di_num(i1);
        cnt = cnt + 1;
      endfor
    endfor
  endfor
  
endfunction


function [r_ds] = hlp_dsl4(p_dp)
  ## Setup dataset list 1: cement paste
  ##
  ## p_dp ... dataset directory path, <str>
  ## r_ds ... return: dataset definition data structure, <struct_dsdef>
  
  r_ds.obj = 'dsdefs';
  r_ds.ver = uint16([1, 0]);
  r_ds.des = 'Dataset definition structure';
  
  r_ds.dsdir = p_dp;
  r_ds.dstype = 4;
  r_ds.dstype_str = 'cem1paste110khz';
  r_ds.dsnum = 29;
  
  r_ds.dsc{1} = 'ts4_wc040_d25_w100';
  r_ds.dsc{2} = 'ts4_wc040_d50_w025';
  r_ds.dsc{3} = 'ts4_wc040_d50_w075_a';
  r_ds.dsc{4} = 'ts4_wc040_d50_w075';
  r_ds.dsc{5} = 'ts4_wc040_d50_w100';
  r_ds.dsc{6} = 'ts4_wc040_d50_w125';
  r_ds.dsc{7} = 'ts4_wc045_d25_w100';
  r_ds.dsc{8} = 'ts4_wc045_d50_w025';
  r_ds.dsc{9} = 'ts4_wc045_d50_w075_a';
  r_ds.dsc{10} = 'ts4_wc045_d50_w075';
  r_ds.dsc{11} = 'ts4_wc045_d50_w100';
  r_ds.dsc{12} = 'ts4_wc045_d50_w125';
  r_ds.dsc{13} = 'ts4_wc050_d25_w100';
  r_ds.dsc{14} = 'ts4_wc050_d50_w025';
  r_ds.dsc{15} = 'ts4_wc050_d50_w075';
  r_ds.dsc{16} = 'ts4_wc050_d50_w100';
  r_ds.dsc{17} = 'ts4_wc050_d50_w125_a';
  r_ds.dsc{18} = 'ts4_wc050_d50_w125';
  r_ds.dsc{19} = 'ts4_wc055_d25_w100';
  r_ds.dsc{20} = 'ts4_wc055_d50_w025';
  r_ds.dsc{21} = 'ts4_wc055_d50_w075';
  r_ds.dsc{22} = 'ts4_wc055_d50_w100';
  r_ds.dsc{23} = 'ts4_wc055_d50_w125';
  r_ds.dsc{24} = 'ts4_wc060_d25_w100';
  r_ds.dsc{25} = 'ts4_wc060_d50_w025';
  r_ds.dsc{26} = 'ts4_wc060_d50_w075';
  r_ds.dsc{27} = 'ts4_wc060_d50_w100';
  r_ds.dsc{28} = 'ts4_wc060_d50_w125_a';
  r_ds.dsc{29} = 'ts4_wc060_d50_w125';
  
  r_ds.dsd = [ ...
    25, 50, 50, 50, 50, 50, ...
    25, 50, 50, 50, 50, 50, ...
    25, 50, 50, 50, 50, 50, ...
    25, 50, 50, 50, 50, ...
    25, 50, 50, 50, 50, 50];
  
  for j = 1 : r_ds.dsnum
    r_ds.dsl{j} = fullfile(r_ds.dsdir, sprintf('%s.oct', r_ds.dsc{j}));
  endfor
  
endfunction


function [r_ds] = hlp_dsl5(p_dp)
  ## Setup dataset list 4: air
  ##
  ## p_dp ... dataset directory path, <str>
  ## r_ds ... return: dataset definition data structure, <struct_dsdef>
  
  r_ds.obj = 'dsdefs';
  r_ds.ver = uint16([1, 0]);
  r_ds.des = 'Dataset definition structure';
  
  r_ds.dsdir = p_dp;
  r_ds.dstype = 5;
  r_ds.dstype_str = 'air';
  r_ds.dsnum = 0;
  
  pl_di_num = [25, 50, 70, 90]; # distance, number, mm
  pl_di = {'25', '50', '70', '90'}; # distance, string, mm
  pl_bs = {'16', '24', '33', '50'}; # block size, recording length, kilo-samples
  pl_pv = {'400', '600', '800'}; # pulse voltage, V
  r_ds.dsnum = length(pl_di) * length(pl_bs) * length(pl_pv);
  r_ds.dsl = cell(1, r_ds.dsnum);
  r_ds.dsc = cell(1, r_ds.dsnum);
  r_ds.dsd = zeros(1, r_ds.dsnum);
  cnt = 1;
  for i1 = 1 : length(pl_di);
    for i2 = 1 : length(pl_bs);
      for i3 = 1 : length(pl_pv);
        code = sprintf('ts5_d%s_b%s_v%s', pl_di{i1}, pl_bs{i2}, pl_pv{i3});
        fn = sprintf('%s.oct', code);
        r_ds.dsl{cnt} = fullfile(r_ds.dsdir, fn);
        r_ds.dsc{cnt} = code;
        r_ds.dsd(cnt) = pl_di_num(i1);
        cnt = cnt + 1;
      endfor
    endfor
  endfor
  
endfunction


function [r_ds] = hlp_dsl6(p_dp)
  ## Setup dataset list 5: water
  ##
  ## p_dp ... dataset directory path, <str>
  ## r_ds ... return: dataset definition data structure, <struct_dsdef>
  
  r_ds.obj = 'dsdefs';
  r_ds.ver = uint16([1, 0]);
  r_ds.des = 'Dataset definition structure';
  
  r_ds.dsdir = p_dp;
  r_ds.dstype = 6;
  r_ds.dstype_str = 'water';
  r_ds.dsnum = 0;
  
  pl_di_num = [25, 50, 70, 90]; # distance, number, mm
  pl_di = {'25', '50', '70', '90'}; # distance, string, mm
  pl_bs = {'16', '24', '33', '50'}; # block size, recording length, kilo-samples
  pl_pv = {'400', '600', '800'}; # pulse voltage, V
  r_ds.dsnum = length(pl_di) * length(pl_bs) * length(pl_pv);
  r_ds.dsl = cell(1, r_ds.dsnum);
  r_ds.dsc = cell(1, r_ds.dsnum);
  r_ds.dsd = zeros(1, r_ds.dsnum);
  cnt = 1;
  for i1 = 1 : length(pl_di);
    for i2 = 1 : length(pl_bs);
      for i3 = 1 : length(pl_pv);
        if (i1 == 4)
          code = sprintf('ts6_d%s_b%s_v%s_2', pl_di{i1}, pl_bs{i2}, pl_pv{i3});
        else
          code = sprintf('ts6_d%s_b%s_v%s', pl_di{i1}, pl_bs{i2}, pl_pv{i3});
        endif
        fn = sprintf('%s.oct', code);
        r_ds.dsl{cnt} = fullfile(r_ds.dsdir, fn);
        r_ds.dsc{cnt} = code;
        r_ds.dsd(cnt) = pl_di_num(i1);
        cnt = cnt + 1;
      endfor
    endfor
  endfor
  
endfunction
