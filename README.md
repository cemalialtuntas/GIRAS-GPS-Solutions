# GIRAS-GPS-Solutions
GIRAS (GNSS-IR Analysis Software) is an open-source MATLAB-based software for GNSS-IR analysis.
Version: 1.0.0

## Overview
GIRAS is an open-source software for GNSS-IR (Global Navigation Satellite System - Interferometric Reflectometry) analysis. It provides tools for file reading, data analysis, and data visualization, developed in MATLAB R2018b.

![image](https://github.com/user-attachments/assets/2172b54d-77a0-4d09-bbd1-33f3c7b365a6)


## Features
- Support for multi-GNSS data (GPS, GLONASS, Galileo, Beidou)
- Compatible with RINEX 2 and RINEX 3 observation files
- Support for both broadcast ephemeris (navigation file) and precise ephemeris (sp3) files
- Comprehensive data visualization and analysis capabilities
- First Fresnel Zone (FFZ) calculation and visualization
- SNR-based reflector height estimation

## Main Modules
GIRAS consists of three main modules and five sub-modules:

### 1. Read & Convert Files
This module reads and processes raw GNSS data:
- Supports RINEX 2 and RINEX 3 observation files
- Reads broadcast or precise ephemeris files
- Saves processed files in MAT format
- Creates SNRMAT files for further analysis

### 2. Pre-analysis
This module provides tools to review the SNRMAT files:

#### 2.1 SNR & dSNR Data
- Visualizes and pre-analyzes SNR data from each satellite
- Customizable options for satellite selection, SNR observation type, units, and angle limits
- Polynomial detrending of SNR data

#### 2.2 Sky View
- Creates sky plots for satellites in the SNRMAT file
- Support for filtering by satellite system
- Highlights selected satellite paths

#### 2.3 FFZ (First Fresnel Zone)
- Generates FFZ graphics and quantities for observed satellites
- Customizable reflector height and satellite elevation angles
- Export as MATLAB plots or Google Earth KML files

### 3. Analysis
This module analyzes SNRMAT files and estimates SNR metrics:

#### 3.1 Make Estimations
- Processes selected SNRMAT files
- Configurable satellite systems, SNR data type, and detrending polynomial degree
- Customizable elevation and azimuth angle ranges
- Adjustable reflector height and precision settings

#### 3.2 Improve Estimations
- Refines analysis results using filtering techniques
- Options for frequency range, elevation angle, background noise conditions
- Median Absolute Deviation (MAD) filtering
- Interactive plotting and data visualization
- Export of refined results

## File Structure
- `/data/` - Contains mandatory files, input and output data
  - `/constants/` - Pre-defined information files
  - `/inp_files/` - Input files (observation, ephemeris)
  - `/mat_files/` - Processed MAT files
- `/FFZ/` - Contains Google Earth FFZ files
- `/functions/` - Contains data reading, analysis, and utility functions
- `/results/` - Contains analysis results
- `/settings/` - Contains settings files

## Mandatory Files
- `satellite_list.mat` - Contains the satellite PRN list
- `wavelengths.mat` - Contains frequency and wavelength information
- Settings files:
  - `ana.mat` - Analysis-1 (make estimations) settings
  - `ana2.mat` - Analysis-2 (improve estimations) settings
  - `pra.mat` - Pre-analysis settings
  - `rcf.mat` - Read & convert files settings

## Quick Start
1. **Read & Convert Files**:
   - Select observation files and ephemeris files
   - Choose between just reading/converting or also creating SNRMAT files
   - Set station position (from RINEX or manually)
   - Click READ & CONVERT

2. **Analysis - Make Estimations**:
   - Select SNRMAT files created in step 1
   - Configure satellite systems, SNR data type, and polynomial degree
   - Set angle limitations and estimation parameters
   - Enter filename and click RUN

3. **Analysis - Improve Estimations**:
   - Select results file from step 2
   - Apply quality filters (elevation angle range, background noise condition)
   - View filtered results and examine plots
   - Save refined results

## Authors
- Cemali ALTUNTAS (cemalialtuntas@gmail.com, cemali@yildiz.edu.tr)
- Nursu TUNALIOGLU (ntunali@yildiz.edu.tr)

Yildiz Technical University, Istanbul, Turkey

## Citation
If you use GIRAS in your research, please cite the following paper:

```
Altuntas, C., & Tunalioglu, N. (2022). GIRAS: an open-source MATLAB-based software for GNSS-IR analysis. GPS Solutions, 26(1), 16.
```
