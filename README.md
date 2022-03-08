# DUEDARE
**DUEDARE**: Dense Urban Environment Dosimetry for Actionable Information and Recording Exposure

Code to accompany (unpublished) paper: Decoding Physical and Cognitive Impacts of Particulate Matter Concentrations at Ultra-fine Scales. This work uses an ultra-fine, holistic environmental and biometric sensing paradigm to generate empirical particulate matter models estimated by biometric variables. 

Scripts are written using MATLAB R2021b. Additionally, this work is built on top of the biometrics research library BM3: https://github.com/mi3nts/BM3. All relevant functions from BM3 are explicitly included in this repository.

## Overview
This analysis includes 66 different empirical models for a variety particulate matter concentrations estimated from biometric recordings. These 66 models are separated into 3 cohorts which vary by the predictor and target variables included.
- **Cohort 1**: BM-9_PM-6_Trials-7_TP-90_withEEG
  -  9 biometric predictors
  -  6 PM targets
- **Cohort 2**: BM-9_PM-6_Trials-7_TP-90
  - 9 non-EEG biometric predictors
  - 6 PM targets
- **Cohort 3**: BM-9_PM-54_Trials-7_TP-90
  - 9 non-EEG biometric predictors
  - 54 PM targets

#### Variable Descriptions
- **9 biometric predictor variables**: body temperature, GSR, HRV, the 3D spatial distance between left and right pupil centers, delta band (1 -- 3 Hz) power densities for the FC6, T8, Oz, and PO7 electrodes, as well as alpha band (8 -- 12 Hz) power density for the FC6 electrode.
- **9 non-EEG biometric predictor variables**: body temperature, GSR, HR, HRV, RR, SpO2, average pupil diameter, difference between left and right pupil diameters, and the 3D spatial distance between left and right pupil centers
- **6 PM targets**: PM_1, PM_2.5, PM_4, PM_10, PM_Total, particle count density (dCn)
- **54 PM targets**: 54 different PM size bins ranging of 0.18 -- 10 microns

## Quickstart
Training data for this study is included in the present repository. To reproduce summary plots from the manuscript, follow the instructions below. Note: these plots are 

1. Navigate to **DUEDARE/BM3/codes/study** subdirectory
2. Run the following scripts: trainModels_withEEG_6sizeBins.m, trainModels_withoutEEG_6sizeBins.m, and trainModels_withoutEEG_54sizeBins.m
3. Run plotSummaries.m script

To generate evaluation plots for all 66 models, run the following scripts: plotModels_withEEG_6sizeBins.m, plotModels_withoutEEG_6sizeBins.m, and plotModels_withoutEEG_54sizeBins.m

To reproduce plot of model accuracy against particle size across 45 different size bins, run the following script: plotAccuracy_BinSize.m 

## Citation

If you find value in this software and would like to cite it, please use the following citation: 

`Talebi S., et al. DUEDARE. 2022. https://github.com/mi3nts/DUEDARE`

__Bibtex__:
```
@misc{DUEDARE,
authors={Shawhin Talebi, David J. Lary, Lakitha O. H. Wijeratne, Bharana Fernando, Tatiana Lary, Matthew D. Lary, John Sadler, Arjun Sridhar, John Waczak, Adam Aker & Yichao Zhang},
title={DUEDARE},
howpublished={https://github.com/mi3nts/DUEDARE}
year={2022}
}
```
## Data Availablility
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6326357.svg)](https://doi.org/10.5281/zenodo.6326357)
