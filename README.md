# Frequency band estimation for sinusoidal low-pass signals in noise


## Abstract

Classic signal analysis usually begins with collecting information about the properties of the signal to the greatest extent possible. This information is the basis for the sensible selection of analysis methods and their parameterization.
For sinusoidal signals, the frequency band of the signal is one of these fundamental signal properties. Estimating the frequency band can be a challenge, especially for signals with a small signal-to-noise ratio.
This work proposes a fully automated method for easily, quickly, and stably estimating the frequency band of low-pass signals. The estimation is based on the discrete Fourier transform and threshold detection. Due to the complete automation, special attention is paid to the method's stability.
The performance of the method is tested here using synthetic and natural signals. The preliminary results show that the automated estimation and visual detection deliver comparable results for the upper frequency band limit.


## Table of contents

- License
- Prerequisites
- Directory and file structure
- Installation instructions
- Usage instructions
- Help
- Related data sources
- Related software
- Revision and release history


## Licence

Copyright 2024 Jakob Harden (jakob.harden@tugraz.at, Graz University of Technology, Graz, Austria)
This file is part of the PhD thesis of Jakob Harden.

All GNU Octave function files (*.m) are published under the *GNU Affero General Public Licence v3.0*. See also licence information file "LICENSE".

All other files are published under the *Creative Commons Attribution 4.0* licence. See also licence information: [Licence deed](https://creativecommons.org/licenses/by/4.0/deed.en)


## Prerequisites

To be able to use the scripts, GNU Octave 6.2.0 (or a higher version) need to to be installed.
GNU Octave is available via the package management system on many Linux distributions. Windows users have to download the Windows version of GNU Octave and to install the software manually.

[GNU Octave download](https://octave.org/download)


To compile the LaTeX documents in this repository a TeXlive installation is required. The TeXlive package is available via the package management system on many Linux distributions. Windows users have to download the Windows version of TeXlive and to install the software manually.

[TeXlive download](https://www.tug.org/texlive/windows.html)


## Directory and file structure

All GNU Octave script files (*.m) are UTF-8 encoded plain text files written in the scientific programming language of GNU Octave 6.2.0. All LaTeX files (*.tex) are UTF-8 encoded plain text files.

```
fqband/
├── latex
│   └── test_fqband
│       ├── adaptthemePresRIP.tex
│       ├── biblio.bib
│       └── main.tex
├── LICENSE
├── octave
│   ├── dsdefs.m
│   ├── init.m
│   ├── results
│   │   └── test_fqband
│   ├── test_fqband.m
│   └── tools
│       ├── tool_est_dft_fqband.m
│       ├── tool_est_dft.m
│       ├── tool_gen_noise.m
│       └── tool_scale_noise2snr.m
├── published
└── README.md

```

- **est_fqband/latex/test\_fqband** ... LaTeX documents, presentation slides (CC BY-4.0)
  - adaptthemePresRIP.tex ... LaTeX beamer class configuration
  - biblio.bib ... bibliography
  - main.tex ... main document, presentation source code
- **est_fqband/published** ... published documents, archives
- **est_fqband/octave** ... GNU Octave script files and analysis results
  - dsdefs.m ... dataset definitions, natural signals (ultrasonic pulse transmission tests)
  - init.m ... initialization script, load packages, add subdirectories to path environment variable
  - test_fqband.m ... main script file, frequency band analsis tests
- **est_fqband/octave/tools** ... tool scripts (AGPLv3)
  - tool\_est\_dft\_fqband.m ... frequency band estimation for low-pass signals
  - tool\_est\_dft.m ... discrete Fourier transformation, PSD
  - tool\_gen\_noise.m ... generate standard noise data for testing purposes
  - tool\_scale\_noise2snr.m ... scale noise data w.r.t. signal power and signal-to-noise ratio
- **est_fqband/octave/results/test\_fqband** ... analysis results (CC BY-4.0)


## Installation instructions

1. Copy the program directory to a location of your choice. e.g. **working_directory**.   
2. Open GNU Octave.   
3. Change the working directory to the program directory. e.g. **working_directory**.   


## Usage instructions

1. Adjust path settings in function file: dsdefs.m.   
2. Open GNU Octave.   
3. Initialize program.   
4. Run script files.


### Initialize program on the command line interface

The 'init' command initializes the program. Initialization has to done once before executing all the other functions. The command is adding the subdirectories included in the main program directory to the 'path' environment variable. Furthermore, 'init' is loading required GNU Octave packages.

```
    octave: >> init;   
```


### Execute function file on the command line interface

```
    octave: >> test_fqband('sig'); # plot synthetic test signals    
    octave: >> test_fqband('syn'); # analyse/plot synthetic signals   
    octave: >> test_fqband('nat'); # analyse/plot selected natural signals   
    octave: >> test_fqband('ts'); # analyse/plot test-series datasets   
    octave: >> test_fqband('pow'); # DFT-based signal power estimation   
```

Note: To reproduce all analysis results for the presentation in the *latex* directory run the the first four commands from above.


## Help

All function files contain an adequate function description and instructions on how to use the functions. This documentation can be displayed in the GNU Octave command line interface by entering the following command:

```
    octave: >> help function_file_name;   
```


## Related data sources

Datasets whos content can be plotted with this scripts are made available at the repository of Graz University of Technology under an open license (Creative Commons, CC BY 4.0). The data records enlisted below contain the raw data, the compiled datasets and a technical description of the record content.


### Data records

- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 1, Cement Paste at Early Stages". Graz University of Technology. [doi: 10.3217/bhs4g-m3z76](https://doi.org/10.3217/bhs4g-m3z76)   
- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 3, Reference Tests on Air". Graz University of Technology. [doi: 10.3217/ph0jm-8ax76](https://doi.org/10.3217/ph0jm-8ax76)   
- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 4, Cement Paste at Early Stages". Graz University of Technology. [doi: 10.3217/f62md-kep36](https://doi.org/10.3217/f62md-kep36)   
- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 5, Reference Tests on Air". Graz University of Technology. [doi: 10.3217/bjkrj-pg829](https://doi.org/10.3217/bjkrj-pg829)   
- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 6, Reference Tests on Water". Graz University of Technology. [doi: 10.3217/hn7we-q7z09](https://doi.org/10.3217/hn7we-q7z09)   
- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 7, Reference Tests on Aluminium Cylinder". Graz University of Technology. [doi: 10.3217/azh6e-rvy75](https://doi.org/10.3217/azh6e-rvy75)   


## Related software

The referenced datasets are compiled from raw data using a dataset compilation tool implemented in the programming language of GNU Octave 6.2.0 ("Dataset Compiler, version 1.1") . To understand the structure of the datasets, it is a good idea to look at the soure code of that tool. Therefore, it was made publicly available under the MIT license at the repository of Graz University of Technology.

Another tool, implemented in the programming language of GNU Octave 6.2.0, allows for exporting data contained in the datasets ("Dataset Exporter, version 1.0"). The main features of that script collection cover the export of substructures to variables and the serialization to the CSV format, the JSON structure format and TeX code. It is also made publicly available under the MIT licence at the repository of Graz University of Technology.


### Dataset Compiler, version 1.1:

- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Data set compiler (1.1)". Graz University of Technology. [doi: 10.3217/6qg3m-af058](https://doi.org/10.3217/6qg3m-af058)


### Dataset Exporter, version 1.0:

- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Dataset Exporter (1.0)". Graz University of Technology. [doi: 10.3217/9adsn-8dv64](https://doi.org/10.3217/9adsn-8dv64)


## Revision and release history

### 2024-11-30, version 1.0

- published/released version 1.0, by Jakob Harden   
- url: [Repository of Graz University of Technology](xxxxxxxx)   
- doi: xxxxxxxxx   
