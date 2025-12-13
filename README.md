From Angiography to Algorithms

Assessing Consumer Wearables for Cardiac Risk Screening

This repository contains the paper and analysis for a statistical study evaluating whether consumer wearable–compatible variables can support early screening of coronary artery disease (CAD), compared against a full clinical diagnostic model.

Overview

Goal: Test if non-invasive, wearable-accessible data can provide a statistically adequate first-line screening model for CAD.

Approach: Logistic regression using the Cleveland Heart Disease dataset.

Comparison:

Reduced (Wearable) Model: age, sex, resting blood pressure, max heart rate (spline), chest pain type, exercise-induced angina

Full Clinical Model: adds ECG, lab, and imaging-based variables

Key Findings

Wearable-based model achieved AUC = 0.877, showing strong discrimination.

Full clinical model significantly outperformed it (AUC = 0.936, LRT p ≪ 0.001).

Wearable variables capture substantial risk signal but cannot replace clinical diagnostics.

Best use case: preliminary risk stratification, not definitive diagnosis.

Methods

Logistic regression with diagnostic checks (VIF, Cook’s distance, logit linearity).

Natural cubic spline applied to maximum heart rate to handle nonlinearity.

Model comparison via LRT, AIC, McFadden’s pseudo-R², ROC/AUC.

Data

Source: UCI Processed Cleveland Heart Disease Dataset

Sample size: 297 observations after cleaning

Outcome: Binary indicator of coronary artery disease

Files

PAPER.pdf — Full paper with methodology, results, diagnostics, and discussion

Appendix A (in paper) — Complete R code used for analysis and figures

Notes

Results are based on clinical-grade measurements, not raw wearable data.

No external validation or cross-validation was performed.

Findings should not be interpreted as medical advice.

Author

Taher Alabbar
December 2025
