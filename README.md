# Frequency band estimation for sinusoidal low-pass signals in noise

## Abstract

Classic signal analysis usually begins with collecting information about the properties of the signal to the greatest extent possible. This information is the basis for the sensible selection of analysis methods and their parameterization.
For sinusoidal signals, the frequency band of the signal is one of these fundamental signal properties. Estimating the frequency band can be a challenge, especially for signals with a small signal-to-noise ratio.
This work proposes a fully automated method for easily, quickly, and stably estimating the frequency band of low-pass signals. The estimation is based on the discrete Fourier transform and threshold detection. Due to the complete automation, special attention is paid to the method's stability.
The performance of the method is tested here using synthetic and natural signals. The preliminary results show that the automated estimation and visual detection deliver comparable results for the upper frequency band limit.

> [!NOTE]
> The entire content of this script collection was conceived, implemented and tested by Jakob Harden using the scientific numerical programming language of GNU Octave 6.2.0.


## Table of contents

- [License](#license)
- [Prerequisites](#prerequisites)
- [Directory and file structure](#directory-and-file-structure)
- [Installation instructions](#installation-instructions)
- [Usage instructions](#usage-instructions)
- [Help and Documentation](#help-and-documentation)
- [Related data sources](#related-data-sources)
- [Related software](#related-software)
- [Revision and release history](#revision-and-release-history)


## License

Copyright 2024 Jakob Harden (jakob.harden@tugraz.at, Graz University of Technology, Graz, Austria)

This file is part of the PhD thesis of Jakob Harden.

All GNU Octave function files (\*.m) are licensed under the *GNU Affero General Public Licence v3.0*. See also licence information file "LICENSE".

All other files are licensed under the *Creative Commons Attribution 4.0* licence. See also licence information: [Licence deed](https://creativecommons.org/licenses/by/4.0/deed.en)


## Prerequisites

To be able to use the scripts, GNU Octave 6.2.0 (or a higher version) need to to be installed.
GNU Octave is available via the package management system on many Linux distributions. Windows users have to download the Windows version of GNU Octave and to install the software manually.

[GNU Octave download](https://octave.org/download)


To compile the LaTeX documents in this repository a TeXlive installation is required. The TeXlive package is available via the package management system on many Linux distributions. Windows users have to download the Windows version of TeXlive and to install the software manually.

[TeXlive download](https://www.tug.org/texlive/windows.html)

> [!TIP]
> **TeXStudio** is a convinient and powerful solution to edit TeX files!


## Directory and file structure

GNU Octave script files (\*.m) are written in the scientific programming language of GNU Octave 6.2.0. LaTeX files (\*.tex) are written with compliance to TeXlive version 2020.20210202-3. Text files are generally encoded in UTF-8.

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
├── README.html   
└── README.md   
```

- **fqband** ... main program directory
  - LICENSE ... AGPLv3 licence information file
  - README.md ... this file, information about the program
  - README.html ... html version of this file
- **fqband/latex/test\_fqband** ... directory, LaTeX documents, presentation slides (CC BY-4.0)
  - adaptthemePresRIP.tex ... file, LaTeX beamer class configuration
  - biblio.bib ... file, bibliography
  - main.tex ... file, main LaTeX document, presentation source code
- **fqband/published** ... directory, published documents, archives (AGPLv3, CC BY-4.0)
- **fqband/octave** ... directory, GNU Octave script files and analysis results (AGPLv3)
  - dsdefs.m ... function file, dataset definitions, natural signals (ultrasonic pulse transmission tests)
  - init.m ... function file, initialization script, load packages, add subdirectories to path environment variable
  - test_fqband.m ... function file, main script, frequency band analsis tests
- **fqband/octave/tools** ... directory, tool scripts (AGPLv3)
  - tool\_est\_dft\_fqband.m ... function file, frequency band estimation for low-pass signals
  - tool\_est\_dft.m ... function file, discrete Fourier transformation, PSD
  - tool\_gen\_noise.m ... function file, generate standard noise data for reproducible analysis results
  - tool\_scale\_noise2snr.m ... function file, scale noise data w.r.t. signal power and signal-to-noise ratio
- **fqband/octave/results/test\_fqband** ... directory, analysis results (CC BY-4.0)


## Installation instructions

1. Download datasets (see references below) and move them to a directory of your choice. e.g. **/home/acme/science/data**
2. Copy the program directory **fqband** to a location of your choice. e.g. **/home/acme/science/fqband**.   
3. Open GNU Octave.   
4. Make the program directory the working directory. e.g. **/home/acme/science/fqband**.   


## Usage instructions

1. Set dataset path variable *r_ds.dspath* in function file *dsdefs.m* to data directory. e.g. r_ds.dspath = '/home/acme/science/data';   
2. Open GNU Octave.   
3. Initialize program.   
4. Run script files.   


### Initialize program (command line interface)

The *init* command initializes the program. The initialization must be run once before executing all the other functions. The command is adding the subdirectories included in the main program directory to the 'path' environment variable. Furthermore, *init* is loading additional GNU Octave packages require for the program execution.

```
    octave: >> init;   
```


### Execute function file (command line interface)

```
    octave: >> test_fqband('sig'); # plot synthetic test signals    
    octave: >> test_fqband('syn'); # analyse/plot synthetic signals   
    octave: >> test_fqband('nat'); # analyse/plot selected natural signals   
    octave: >> test_fqband('ts'); # analyse/plot test-series datasets   
    octave: >> test_fqband('pow'); # DFT-based signal power estimation   
```

> [!NOTE]
> To reproduce all analysis results shown in the presentation in **fqband/latex/test_fqband**, run the the first four commands from above.


## Help and Documentation

All function files contain an adequate function description and instructions on how to use the functions. This documentation can be displayed in the GNU Octave command line interface by entering the following command:

```
    octave: >> help function_file_name;   
```


## Related data sources

Datasets whos content can be analyzed and plotted with this scripts are made available at the repository of Graz University of Technology under an open license (Creative Commons, CC BY 4.0). The data records enlisted below contain the raw data, the compiled datasets and a technical description of the record content.


### Data records

- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 1, Cement Paste at Early Stages". Graz University of Technology. [doi: 10.3217/bhs4g-m3z76](https://doi.org/10.3217/bhs4g-m3z76)   
- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 3, Reference Tests on Air". Graz University of Technology. [doi: 10.3217/ph0jm-8ax76](https://doi.org/10.3217/ph0jm-8ax76)   
- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 4, Cement Paste at Early Stages". Graz University of Technology. [doi: 10.3217/f62md-kep36](https://doi.org/10.3217/f62md-kep36)   
- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 5, Reference Tests on Air". Graz University of Technology. [doi: 10.3217/bjkrj-pg829](https://doi.org/10.3217/bjkrj-pg829)   
- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 6, Reference Tests on Water". Graz University of Technology. [doi: 10.3217/hn7we-q7z09](https://doi.org/10.3217/hn7we-q7z09)   
- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 7, Reference Tests on Aluminium Cylinder". Graz University of Technology. [doi: 10.3217/azh6e-rvy75](https://doi.org/10.3217/azh6e-rvy75)   


## Related software

### Dataset Compiler, version 1.1:

The referenced datasets are compiled from raw data using a dataset compilation tool implemented in the programming language of GNU Octave 6.2.0. To understand the structure of the datasets, it is a good idea to look at the soure code of that tool. Therefore, it was made publicly available under the MIT license at the repository of Graz University of Technology.

- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Data set compiler (1.1)". Graz University of Technology. [doi: 10.3217/6qg3m-af058](https://doi.org/10.3217/6qg3m-af058)

> [!NOTE]
> *Dataset Compiler* is also available on **github**. [Dataset Compiler](https://github.com/jakobharden/phd_dataset_compiler)


### Dataset Exporter, version 1.0:

*Dataset Exporter* is implemented in the programming language of GNU Octave 6.2.0 and allows for exporting data contained in the datasets. The main features of that script collection cover the export of substructures to variables and the serialization to the CSV format, the JSON structure format and TeX code. It is also made publicly available under the MIT licence at the repository of Graz University of Technology.

- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Dataset Exporter (1.0)". Graz University of Technology. [doi: 10.3217/9adsn-8dv64](https://doi.org/10.3217/9adsn-8dv64)

> [!NOTE]
> *Dataset Exporter* is also available on **github**. [Dataset Exporter](https://github.com/jakobharden/phd_dataset_exporter)


### Dataset Viewer, version 1.0:

*Dataset Viewer* is implemented in the programming language of GNU Octave 6.2.0 and allows for plotting measurement data contained in the datasets. The main features of that script collection cover 2D plots, 3D plots and rendering MP4 video files from the measurement data contained in the datasets. It is also made publicly available under the MIT licence at the repository of Graz University of Technology.

- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Dataset Viewer (1.0)". Graz University of Technology. [doi: 10.3217/c1ccn-8m982](https://doi.org/10.3217/c1ccn-8m982)

> [!NOTE]
> *Dataset Viewer* is also available on **github**. [Dataset Viewer](https://github.com/jakobharden/phd_dataset_viewer)


## Revision and release history

### 2024-11-30, version 1.0

- published/released version 1.0, by Jakob Harden   
- url: [Repository of Graz University of Technology](xxxxxxxx)   
- doi: xxxxxxxxx   
