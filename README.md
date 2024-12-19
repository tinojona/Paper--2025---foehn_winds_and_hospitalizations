# The effect of foehn winds on hospitalizations in Switzerland
author: Tino Schneidewind

We cannot supply the data here because we are not authorized to do so. Therefore the provided code does not run on its own but one has to apply for the needed data.

## Data
The data is not part of this repository but can be applied for using the following procedure. The meteorological data was provided by the [Swiss Federal Office for Meteorology and Climatology](https://www.meteoschweiz.admin.ch/#tab=forecast-map) and is accessable through their own distribution platform [IDAweb](https://www.meteoschweiz.admin.ch/service-und-publikationen/service/wetter-und-klimaprodukte/datenportal-fuer-lehre-und-forschung.html). The hospitalization data was provided by the [Swiss Federal Office for Statistics](https://www.bfs.admin.ch/bfs/de/home.html) and the data can be accessed as described on their [webpage](https://www.bfs.admin.ch/bfs/de/home/statistiken/gesundheit/erhebungen/ms.html).

## Data Preparation 
The files processing_foehn.R and processing_temp.R show how the raw meteorological data was processed and then summarized per meteorological station combined with the hospitalization data in processing_hosp.R.
The files calculate_MedStat_centroids.R and MedStat_selection_centroids.R display the methods of centroid calculation and the algorithm of assigning the Medstat regions based on these centroids and different buffer radii to the stations. 

## Analysis 
Here we demonstrate how we determined the different crossbasis for our independent analysis and the interaction analysis. 

## Functions
Here we store all our functions needed for the code to run. Both functions were written by Antonio Gasparrini and accessed through [Antonio Gasparrini's GitHub](https://github.com/gasparrini).

## Findings
In these RMarkdown files, we display how the results were visualized. They are subdivided in the corresponding results sections descriptive statistics, the direct effect of foehn and the interaction analysis.
