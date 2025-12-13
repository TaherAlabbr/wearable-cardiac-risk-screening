# ==============================================================================
# Heart Disease Analysis - Logistic Regression Framework
# ==============================================================================

# 1. SETUP & LIBRARY LOADING
# ------------------------------------------------------------------------------
# Load all required libraries for modeling, diagnostics, and visualization.
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, car, broom, pROC, caret, splines)

# 2. DATA LOADING & PREPROCESSING
# ------------------------------------------------------------------------------
# Load the Cleveland dataset and assign column names.
url <- "https://archive.ics.uci.edu/ml/machine-learning-databases/heart-disease/processed.cleveland.data"

col_names <- c("age", "sex", "cp", "trestbps", "chol", "fbs", "restecg", 
               "thalach", "exang", "oldpeak", "slope", "ca", "thal", "num")

heart_data <- read.csv(url, header = FALSE, col.names = col_names, na.strings = "?")

# Remove missing values and prepare variables for modeling.
clean_data <- heart_data %>%
  drop_na() %>%
  mutate(
    target = ifelse(num > 0, 1, 0),          # Binary outcome: disease vs. no disease
    sex     = factor(sex, labels = c("Female", "Male")),
    cp      = as.factor(cp),
    fbs     = as.factor(fbs),
    restecg = as.factor(restecg),
    exang   = as.factor(exang),
    slope   = as.factor(slope),
    thal    = as.factor(thal),
    ca      = as.numeric(ca)
  )

# 3. MODEL SPECIFICATION
# ------------------------------------------------------------------------------
# Reduced Model: only wearable-compatible predictors.
model_reduced <- glm(target ~ age + sex + bs(thalach, df = 3) + trestbps + cp + exang, 
                     data = clean_data, 
                     family = binomial(link = "logit"))

# Full Model: includes all clinical predictors.
model_full <- glm(target ~ age + sex + bs(thalach, df = 3) + trestbps + cp + exang +
                    restecg + oldpeak + slope + chol + fbs + ca + thal, 
                  data = clean_data, 
                  family = binomial(link = "logit"))

# 4. MODEL FIT STATISTICS
# ------------------------------------------------------------------------------
# Compute McFadden’s pseudo-R² for each model.
calc_r2 <- function(model) {
  1 - (model$deviance / model$null.deviance)
}

print(paste("Consumer Model R2:", round(calc_r2(model_reduced), 3)))
print(paste("Clinical Model R2:", round(calc_r2(model_full), 3)))

# Likelihood Ratio Test comparing models.
print(anova(model_reduced, model_full, test = "Chisq"))

# AIC/BIC model comparison.
model_stats <- bind_rows(
  glance(model_reduced) %>% mutate(Model = "Reduced (Consumer)"),
  glance(model_full) %>% mutate(Model = "Full (Clinical)")
) %>% select(Model, AIC, BIC, deviance)

print(model_stats)

# 5. DIAGNOSTICS
# ------------------------------------------------------------------------------
# Multicollinearity check.
print(vif(model_full))

# Cook’s Distance to detect influential observations.
par(mfrow = c(1, 1))
plot(model_reduced, which = 4, sub = "")
abline(h = 4/nrow(clean_data), col = "red", lty = 2)

# Linearity check for continuous predictors.
probabilities <- predict(model_full, type = "response")
probabilities <- pmin(pmax(probabilities, 0.0001), 0.9999)
logits <- log(probabilities / (1 - probabilities))

linearity_data <- clean_data %>%
  select(age, thalach, trestbps, oldpeak) %>%
  mutate(logit = logits) %>%
  pivot_longer(cols = -logit, names_to = "predictors", values_to = "predictor_value")

linearity_plot <- ggplot(linearity_data, aes(x = predictor_value, y = logit)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "loess", color = "blue", se = FALSE) +
  facet_wrap(~ predictors, scales = "free_x") +
  theme_minimal() +
  labs(
    title = "Linearity Assumption Check: Continuous Predictors vs Logit",
    y = "Log-Odds (Logit)",
    x = "Predictor Value"
  )

print(linearity_plot)

# 6. PERFORMANCE METRICS (ROC & CONFUSION MATRIX)
# ------------------------------------------------------------------------------
# ROC curves for discrimination assessment.
prob_reduced <- predict(model_reduced, type = "response")
prob_full <- predict(model_full, type = "response")

roc_reduced <- roc(clean_data$target, prob_reduced, quiet = TRUE)
roc_full <- roc(clean_data$target, prob_full, quiet = TRUE)

plot(roc_full, col = "blue", main = "ROC Comparison: Clinical vs. Consumer")
plot(roc_reduced, col = "red", add = TRUE)
legend("bottomright", legend = c(paste("Clinical AUC:", round(auc(roc_full), 3)), 
                                 paste("Consumer AUC:", round(auc(roc_reduced), 3))),
       col = c("blue", "red"), lty = 1)

# Confusion matrix for the Reduced Model.
predicted_class <- ifelse(prob_reduced > 0.5, 1, 0)
conf_matrix <- confusionMatrix(factor(predicted_class), factor(clean_data$target), positive = "1")

print(conf_matrix$byClass[c("Sensitivity", "Specificity", "Precision", "Recall")])
print(conf_matrix$overall["Accuracy"])

# 7. MODEL INTERPRETATION
# ------------------------------------------------------------------------------
# Extract significant odds ratios for the Reduced Model.
tidy(model_reduced, exponentiate = TRUE, conf.int = TRUE) %>% 
  filter(p.value < 0.05) %>% 
  select(term, estimate, p.value, conf.low, conf.high) %>% 
  print()
