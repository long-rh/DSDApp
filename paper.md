---
title: 'DSDApp: an open-access tool for Definitive Screening Design'
tags:
  - design of experiment
  - definitive screening design
  - R
authors:
  - name: Ryoichiro Hayasaka
    orcid: 0000-0003-1160-3846
    affiliation: 1
  - name: Pablo Cayado
    affiliation: 2
  - name: Jens Hänisch
    affiliation: 1
affiliations:
 - name: Karlsruhe Institute of Technology, Karlsruhe, Germany
   index: 1
 - name: University of Geneva, Department of Quantum Matter Physics, Geneva, Switzerland
   index: 2
date: 2 February 2023
bibliography: paper.bib
---

# Summary
Definitive Screening Design (DSD) is a novel and efficient design of experiment (DOE), discovered by Jones and Nachtsheim in 2011 [Jones:2011]. DSD enables experimenters in various kinds of fields to investigate many parameters (factors) in their system of interest by performing only 2k+α trials (k: the number of the factors, α: typically 1 – 5 extra trials), combining different experimental conditions. By using DSD, experimenters can create second-order models to explain the output value, and optimize the magnitude (level) of the factors based on the models. In case of k=8, for example, an experimenters can evaluate dominant factors among eight factors and optimize the levels of the factors by conducting 17 runs at minimum. Because of this efficient feature, many researchers and engineers prefer to use DSD, especially in the fields where numerous factors are involved, such as material science. However, designing and analysis of DSD usually require commercial software (e.g., JMP, Design-Expert, Minitab) or programming (e.g., R or Python), which hinders DSD from coming into widespread use.

DSDApp, therefore, has been developed to provide an effortless way to employ DSD. This app is an open-access web application available at https://my-first-dsd.shinyapps.io/DSDApp_ver2/. The app relies on R packages “shiny” to provide the form of a web application, “daewr” to prepare definitive screening designs, and “MuMIn” to calculate Akaike information criteria (AIC) when making models. For the model making, DSDApp employs a 2-step regression approach recommended by Jones and Nachtsheim [Jones:2017]. That is, first-order effects are evaluated initially, and then second-order effects, which are related to the significant first-order effects, are selected based on AIC. After making models, optimization of output value(s), i.e. maximization, minimization, and adjusting to the target values, is also possible through converting the output values into so-called desirability function [Montogemry:2019].

DSDApp can be used intuitively by clicking buttons, thereby, experimenters in any kinds of engineering and science can focus more on their projects of interest. The performance of DSDApp has been tested by using simulated data and actual experimental results prepared from different sources of literature[Hayasaka:2020][Rijkaert:2021].


# Acknowledgement
The initial experimental work for developing DSDApp, especially has been conducted at Karlsruhe Institute of Technology (Germany) during the author’s research visit within the program COLABS offered by Tohoku University (Japan). The authors thank the research members at The Institute for Technical Physics and Tohoku University for giving insight into this work.