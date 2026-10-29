# Table 2: Multilevel logistic regression of subjects' selection of discussants,
# by treatment. Also reports the average ideological distance between subjects
# and their chosen discussants (1.3 control vs. 2.4 accuracy; p. 375).
#
# Input:  data/discussant_choices.csv
#         One row per ego-alter-request (ego = participant requesting information).
# Output: output/table2.csv

library(lme4)

dyads <- read.csv("data/discussant_choices.csv")

# Fit models separately by treatment ------------------------------------------
link_formula <- link ~ alterbuyinfo + distance + askbefore + newinfo +
  (1 | period) + (1 | requestnum)

link_control <- glmer(link_formula, data = subset(dyads, accuracy == 0),
                      family = binomial(link = "logit"))
link_accuracy <- glmer(link_formula, data = subset(dyads, accuracy == 1),
                       family = binomial(link = "logit"))

# Coefficients, SEs, and Wald test of equality across treatments ---------------
b0 <- fixef(link_control)
b1 <- fixef(link_accuracy)
se0 <- sqrt(diag(vcov(link_control)))
se1 <- sqrt(diag(vcov(link_accuracy)))
wald <- (b0 - b1)^2 / (se0^2 + se1^2)

table2 <- data.frame(
  term         = names(b0),
  control_est  = round(b0, 2),
  control_se   = round(se0, 3),
  accuracy_est = round(b1, 2),
  accuracy_se  = round(se1, 3),
  wald_p       = round(pchisq(wald, df = 1, lower.tail = FALSE), 2),
  row.names    = NULL
)
table2

# Random-intercept SDs and fit statistics (bottom panel of Table 2).
# "Deviance" in the table is -2 * log-likelihood.
VarCorr(link_control)
VarCorr(link_accuracy)
sapply(list(control = link_control, accuracy = link_accuracy),
       \(m) c(n = nobs(m), AIC = AIC(m), deviance = -2 * as.numeric(logLik(m))))

dir.create("output", showWarnings = FALSE)
write.csv(table2, "output/table2.csv", row.names = FALSE)

# In-text: average ego-alter ideological distance among chosen discussants ----
with(subset(dyads, link == 1), tapply(distance, accuracy, mean))
