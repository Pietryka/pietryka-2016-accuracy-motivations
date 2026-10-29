# Table 3: Multilevel linear regression of participants' final judgments of
#          candidate positions on information received, by treatment.
# Figure 2: Marginal effect of (A) private, (B) social, and (C) public
#          information on updated judgment, by expertise and treatment.
#          Computed from the Table 3 models.
#
# Input:  data/judgments.csv
#         One row per participant-election-candidate.
#         guess7  = final judgment of candidate's position
#         prior   = judgment before receiving social information
#         socmn   = mean social message received in the election
#         candB   = 1 if the judgment is about Candidate B
#         buyinfo = pieces of private information purchased (expertise, 0-3)
# Output: output/table3.csv
#         output/figure2a.pdf, figure2b.pdf, figure2c.pdf, figure2_legend.pdf

library(lme4)

judgments <- read.csv("data/judgments.csv")

# Table 3 ---------------------------------------------------------------------
judgment_formula <- guess7 ~ prior * buyinfo + socmn * buyinfo + candB * buyinfo +
  (1 | subjectid) + (1 | period)

lm_control  <- lmer(judgment_formula, data = subset(judgments, accuracy == 0))
lm_accuracy <- lmer(judgment_formula, data = subset(judgments, accuracy == 1))

b0 <- fixef(lm_control)
b1 <- fixef(lm_accuracy)
se0 <- sqrt(diag(vcov(lm_control)))
se1 <- sqrt(diag(vcov(lm_accuracy)))
wald <- (b0 - b1)^2 / (se0^2 + se1^2)

table3 <- data.frame(
  term         = names(b0),
  control_est  = round(b0, 2),
  control_se   = round(se0, 3),
  accuracy_est = round(b1, 2),
  accuracy_se  = round(se1, 3),
  wald_p       = round(pchisq(wald, df = 1, lower.tail = FALSE), 2),
  row.names    = NULL
)
table3

# Random-intercept SDs and fit statistics (bottom panel of Table 3).
# Models are fit by REML; "Deviance" in the table is the ML deviance.
VarCorr(lm_control)
VarCorr(lm_accuracy)
sapply(list(control = lm_control, accuracy = lm_accuracy),
       \(m) c(n = nobs(m), AIC = AIC(m), deviance = deviance(m, REML = FALSE)))

dir.create("output", showWarnings = FALSE)
write.csv(table3, "output/table3.csv", row.names = FALSE)

# Figure 2 --------------------------------------------------------------------

# Marginal effect of `x` at each level of expertise (buyinfo = 0-3), with 95% CI.
# Degrees of freedom: n minus 8 fixed effects minus 2 random-intercept terms.
marginal_effect <- function(model, x, xz, z = 0:3) {
  b <- fixef(model)
  v <- as.matrix(vcov(model))
  est <- b[x] + b[xz] * z
  se <- sqrt(v[x, x] + z^2 * v[xz, xz] + 2 * z * v[x, xz])
  crit <- qt(.975, nobs(model) - length(b) - 2)
  data.frame(z = z, est = est, se = se, lb = est - crit * se, ub = est + crit * se)
}

col_control  <- "grey66"
col_accuracy <- "grey33"
labsize <- 1.7

# Draws one panel and returns its x-limits (reused for the legend)
plot_marginal_effect <- function(x, xz, xlab, xticks, file, xlim_min = NULL) {
  me0 <- marginal_effect(lm_control, x, xz)
  me1 <- marginal_effect(lm_accuracy, x, xz)
  wald_p <- pchisq((me0$est - me1$est)^2 / (me0$se^2 + me1$se^2),
                   df = 1, lower.tail = FALSE)
  print(data.frame(expertise = me0$z, control = me0$est, accuracy = me1$est,
                   wald_p = round(wald_p, 2)))

  xlim <- c(min(c(me0$lb, me1$lb)), max(c(me0$ub, me1$ub))) * 1.02
  if (!is.null(xlim_min)) xlim[1] <- xlim_min
  y <- seq_along(me0$z)
  offset <- .05

  pdf(file, width = 9, height = 7)
  par(mar = c(5, 7, 1, 7))
  plot(1:10, 1:10, type = "n", xaxt = "n", yaxt = "n",
       ylim = c(0, length(y) + 1), xlim = xlim,
       xlab = xlab, ylab = "Expertise\n(Amount of private info purchased)",
       mgp = c(3, 1, 0), cex.lab = labsize)
  abline(h = y, lty = "dotted", col = "grey")
  abline(v = 0, lty = 2)
  segments(me0$lb, y + offset, me0$ub, y + offset, col = col_control, lwd = 3)
  segments(me1$lb, y - offset, me1$ub, y - offset, col = col_accuracy, lwd = 3)
  points(me0$est, y + offset, pch = 15, col = col_control, cex = 1.5)
  points(me1$est, y - offset, pch = 19, col = col_accuracy, cex = 1.5)
  axis(1, at = xticks, cex.axis = labsize - .2)
  axis(2, at = y, labels = me0$z, cex.axis = labsize - .2)
  mtext("Wald test \np-value", side = 4, at = length(y) + 1, line = 4,
        las = 1, font = 2, adj = .5, cex = 1.6)
  mtext(round(wald_p, 2), side = 4, at = y, las = 1, line = 3, cex = 1.6)
  dev.off()

  invisible(xlim)
}

# Panel A: private information (prior)
plot_marginal_effect("prior", "prior:buyinfo",
                     xlab = "Marginal effect of prior",
                     xticks = seq(-1, .5, .5), file = "output/figure2a.pdf")

# Panel B: social information (mean social message)
plot_marginal_effect("socmn", "buyinfo:socmn",
                     xlab = "Marginal effect of mean social message",
                     xticks = seq(0, 1.2, .4), file = "output/figure2b.pdf",
                     xlim_min = 0)

# Panel C: public information (Candidate B indicator)
xlim_c <- plot_marginal_effect("candB", "buyinfo:candB",
                               xlab = "Marginal effect of Candidate B dummy",
                               xticks = seq(-1, .5, .5), file = "output/figure2c.pdf")

# Legend
pdf("output/figure2_legend.pdf", width = 9, height = 1.1)
par(mar = c(0, 0, 0, 0))
plot(1:10, 1:10, type = "n", xaxt = "n", yaxt = "n", bty = "n",
     xlab = "", ylab = "", ylim = c(0, 5), xlim = xlim_c)
points(-.05, 2.9, pch = 15, col = col_control, cex = 3)
points(-.05, 1.4, pch = 19, col = col_accuracy, cex = 3)
text(0, 2.5, "Control", cex = labsize, col = col_control, adj = c(0, 0))
text(0, 1, "Accuracy treatment", cex = labsize, col = col_accuracy, adj = c(0, 0))
dev.off()
