---
title: 'DSDApp: an open-access tool for Definitive Screening Design'
tags:
  - design of experiment
  - definitive screening design
  - R
authors:
  - name: Ryoichiro Hayasaka
    orcid: 0000-0003-1160-3846
  - name: Pablo Cayado
    orcid: 0000-0003-3703-6122
    affiliation: 1
affiliations:
 - name: University of Geneva, Department of Quantum Matter Physics, Geneva, Switzerland
   index: 1
date: 2 February 2023
bibliography: paper.bib
---


# Summary
Definitive Screening Design (DSD) is a novel and efficient design of experiment (DOE), developed by Jones and Nachtsheim and reported in 2011 [Jones:2011]. DSD enables experimenters of different fields to investigate many parameters (factors) of their system by performing only 2k+α trials (k: the number of the factors, α: typically, 1 – 5 extra trials) and combining different experimental conditions. By using DSD, experimenters can create second-order models to explain the output value, and optimize the magnitude (level) of the factors based on the models. Figure 1 shows an example of six-factor DSD and test experiment data. An experimenter can evaluate dominant factors among the six factors by conducting only 17 runs, and optimize the levels of the factors based on the second-order model. Due to this efficiency, many researchers and engineers prefer to use DSD, especially in fields where numerous factors are involved such as material sciences. However, the design and analysis of DSD usually require commercial software (e.g., JMP, Design-Expert, Minitab) or programming (e.g., R or Python), which hinders the widespread of DSD.

![Figure1](image/fig1.png)
Figure 1. An example of eight-factor DSD with 17 runs. The factors are A-F, and their levels are changed (-1, 0, +1). Column Y is the simulated experimented data obtained by each run. The second-order model is obtained by 2-step model selection.


# Statement of need
DSDApp has been developed to provide an effortless way to employ DSD. This app is an open-access web application available at https://my-first-dsd.shinyapps.io/DSDApp_ver2/. The app relies on R packages “shiny” to provide the form of a web application, “daewr” to prepare definitive screening designs, and “MuMIn” to calculate Akaike information criteria (AIC) when making models. 
For the construction of the model, DSDApp employs a 2-step regression approach described in [Jones:2017]. In this approach, first-order effects (main effects) are evaluated initially, and then, second-order effects involving the main factors are selected based on AIC with finite correction, as shown in Figure 1. After building the models, the optimization of the output value(s), i.e., maximization, minimization, and adjusting to the target values, is also possible through converting the output values into the so-called desirability function [Montogemry:2019].

DSDApp can be used intuitively by clicking buttons and, therefore, experimenters of any kinds of engineering and science areas can focus more on the results of the analysis than on dealing with the complex DSD analysis. The performance of DSDApp has been tested by using simulated data and actual experimental results prepared from different sources of literature[Hayasaka:2020][Rijkaert:2021].


# Acknowledgement
The initial experimental work for developing DSDApp, especially has been conducted at Karlsruhe Institute of Technology (Germany) during the author’s research visit within the program COLABS offered by Tohoku University (Japan). The authors thank Dr. Jens Hänisch and the research members at The Institute for Technical Physics and Tohoku University for giving insight into this work.