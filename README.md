# From Angiography to Algorithms  
**Assessing Consumer Wearables for Cardiac Risk Screening**

This repository contains the paper and statistical analysis evaluating whether **consumer wearable–compatible variables** can support early screening of coronary artery disease (CAD) compared to a full clinical diagnostic model.

---

## Overview
- **Objective:** Assess if non-invasive, wearable-accessible data can provide a statistically adequate first-line screening model for CAD.
- **Method:** Logistic regression using the Cleveland Heart Disease dataset.
- **Models Compared:**
  - **Reduced (Wearable) Model:** age, sex, resting blood pressure, max heart rate (spline), chest pain type, exercise-induced angina
  - **Full Clinical Model:** adds ECG, laboratory, and imaging-based variables

---

## Key Findings
- Wearable-based model achieved **AUC = 0.877**, indicating strong discrimination.
- Full clinical model significantly outperformed it (**AUC = 0.936**, LRT p ≪ 0.001).
- Wearable variables capture substantial risk information but **cannot replace clinical diagnostics**.
- Best suited for **preliminary risk stratification**, not definitive diagnosis.

---

## Methods
- Logistic regression with full diagnostic checks (VIF, Cook’s distance, logit linearity).
- Natural cubic spline applied to maximum heart rate to address nonlinearity.
- Model comparison via Likelihood Ratio Test, AIC, McFadden’s pseudo-R², and ROC/AUC.

---

## Data
- **Source:** UCI Processed Cleveland Heart Disease Dataset  
- **Sample Size:** 297 observations after cleaning  
- **Outcome:** Binary indicator of coronary artery disease

---

## Repository Contents
- `PAPER.pdf` — Full paper including methodology, results, diagnostics, and discussion  
- `heart_disease_logistic_regression.r` — R script containing the full data preprocessing, model fitting, diagnostics, and performance evaluation code

---

## Limitations
- Based on clinical-grade measurements, not raw wearable sensor data
- No cross-validation or external test set
- Dataset reflects a small, clinically referred cohort

---

## Author
**Taher Alabbar**  
December 2025
