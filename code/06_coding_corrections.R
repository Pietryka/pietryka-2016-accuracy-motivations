# Coding corrections: re-estimates Table 2, Table 3, Figure 1, and Figure 2
# with corrected versions of four variables (see "Coding corrections" in the
# README). Scripts 01-05 reproduce the published results; this script does not
# change them.
#
#   buyinfo_raw            replaces buyinfo           (Table 3, Figure 2)
#   prior_ztree            replaces prior             (Table 3, Figure 2)
#   message_dist_corrected replaces message_dist      (Figure 1)
#   newinfo_corrected      replaces newinfo           (Table 2)
#
# Input:  data/discussant_choices.csv, data/judgments.csv, data/messages.csv
# Output: output/corrections/table2_corrected.csv
#         output/corrections/table3_corrected.csv
#         output/corrections/figure1_corrected.pdf
#         output/corrections/figure2a_corrected.pdf, figure2b_corrected.pdf,
#         figure2c_corrected.pdf

library(lme4)

out <- "output/corrections"
dir.create(out, showWarnings = FALSE, recursive = TRUE)

# Coefficients by treatment with Wald test of equality ------------------------
compare_treatments <- function(m0, m1) {
  b0 <- fixef(m0)
  b1 <- fixef(m1)
  se0 <- sqrt(diag(vcov(m0)))
  se1 <- sqrt(diag(vcov(m1)))
  data.frame(
    term         = names(b0),
    control_est  = round(b0, 2),
    control_se   = round(se0, 3),
    accuracy_est = round(b1, 2),
    accuracy_se  = round(se1, 3),
    wald_p       = round(pchisq((b0 - b1)^2 / (se0^2 + se1^2), 1, lower.tail = FALSE), 2),
    row.names    = NULL
  )
}

# Table 2 with corrected newinfo ----------------------------------------------
dyads <- read.csv("data/discussant_choices.csv")
link_formula <- link ~ alterbuyinfo + distance + askbefore + newinfo_corrected +
  (1 | period) + (1 | requestnum)
link_control  <- glmer(link_formula, data = subset(dyads, accuracy == 0), family = binomial)
link_accuracy <- glmer(link_formula, data = subset(dyads, accuracy == 1), family = binomial)

table2_corrected <- compare_treatments(link_control, link_accuracy)
table2_corrected
write.csv(table2_corrected, file.path(out, "table2_corrected.csv"), row.names = FALSE)

# Table 3 with raw purchase count and z-Tree prior ----------------------------
judgments <- read.csv("data/judgments.csv")
judgment_formula <- guess7 ~ prior_ztree * buyinfo_raw + socmn * buyinfo_raw +
  candB * buyinfo_raw + (1 | subjectid) + (1 | period)
lm_control  <- lmer(judgment_formula, data = subset(judgments, accuracy == 0))
lm_accuracy <- lmer(judgment_formula, data = subset(judgments, accuracy == 1))

table3_corrected <- compare_treatments(lm_control, lm_accuracy)
table3_corrected
write.csv(table3_corrected, file.path(out, "table3_corrected.csv"), row.names = FALSE)

# Figure 2 with expertise 0-4 -------------------------------------------------
marginal_effect <- function(model, x, xz, z = 0:4) {
  b <- fixef(model)
  v <- as.matrix(vcov(model))
  est <- b[x] + b[xz] * z
  se <- sqrt(v[x, x] + z^2 * v[xz, xz] + 2 * z * v[x, xz])
  crit <- qt(.975, nobs(model) - length(b) - 2)
  data.frame(z = z, est = est, se = se, lb = est - crit * se, ub = est + crit * se)
}

plot_marginal_effect <- function(x, xz, xlab, file) {
  me0 <- marginal_effect(lm_control, x, xz)
  me1 <- marginal_effect(lm_accuracy, x, xz)
  wald_p <- pchisq((me0$est - me1$est)^2 / (me0$se^2 + me1$se^2), 1, lower.tail = FALSE)
  print(data.frame(expertise = me0$z, control = round(me0$est, 2),
                   accuracy = round(me1$est, 2), wald_p = round(wald_p, 2)))

  y <- seq_along(me0$z)
  xlim <- range(c(0, me0$lb, me1$lb, me0$ub, me1$ub)) * 1.02
  pdf(file, width = 9, height = 8)
  par(mar = c(5, 7, 1, 7))
  plot(1:10, 1:10, type = "n", xaxt = "n", yaxt = "n",
       ylim = c(0, length(y) + 1), xlim = xlim,
       xlab = xlab, ylab = "Expertise\n(Amount of private info purchased)",
       mgp = c(3, 1, 0), cex.lab = 1.7)
  abline(h = y, lty = "dotted", col = "grey")
  abline(v = 0, lty = 2)
  segments(me0$lb, y + .05, me0$ub, y + .05, col = "grey66", lwd = 3)
  segments(me1$lb, y - .05, me1$ub, y - .05, col = "grey33", lwd = 3)
  points(me0$est, y + .05, pch = 15, col = "grey66", cex = 1.5)
  points(me1$est, y - .05, pch = 19, col = "grey33", cex = 1.5)
  axis(1, at = pretty(xlim), cex.axis = 1.5)
  axis(2, at = y, labels = me0$z, cex.axis = 1.5)
  mtext("Wald test \np-value", side = 4, at = length(y) + 1, line = 4,
        las = 1, font = 2, adj = .5, cex = 1.6)
  mtext(round(wald_p, 2), side = 4, at = y, las = 1, line = 3, cex = 1.6)
  dev.off()
}

plot_marginal_effect("prior_ztree", "prior_ztree:buyinfo_raw",
                     "Marginal effect of prior", file.path(out, "figure2a_corrected.pdf"))
plot_marginal_effect("socmn", "buyinfo_raw:socmn",
                     "Marginal effect of mean social message", file.path(out, "figure2b_corrected.pdf"))
plot_marginal_effect("candB", "buyinfo_raw:candB",
                     "Marginal effect of Candidate B dummy", file.path(out, "figure2c_corrected.pdf"))

# Figure 1 with corrected message bias and corrected confidence intervals ------
messages <- read.csv("data/messages.csv")
bias <- aggregate(message_dist_corrected ~ distance, data = messages, FUN = mean)
sd <- aggregate(message_dist_corrected ~ distance, data = messages, FUN = sd)[, 2]
n <- aggregate(message_dist_corrected ~ distance, data = messages, FUN = length)[, 2]
bias$lb <- bias[, 2] - qt(.975, n - 1) * sd / sqrt(n)
bias$ub <- bias[, 2] + qt(.975, n - 1) * sd / sqrt(n)
bias

pdf(file.path(out, "figure1_corrected.pdf"), width = 6.5, height = 7)
par(cex = 1.5, mar = c(4, 4, 1, 1), mgp = c(2, .5, 0))
plot(bias$distance, bias[, 2], type = "n", bty = "l", xaxt = "n", yaxt = "n",
     ylim = range(c(0.2, 1.4, bias$lb, bias$ub)),
     xlab = "Ideological distance between ego and alter",
     ylab = "Average bias\n(distance between belief and message)")
lines(bias$distance, bias[, 2], lwd = 2)
segments(bias$distance, bias$lb, bias$distance, bias$ub, lwd = 2)
points(bias$distance, bias[, 2], pch = 19)
axis(1, at = 0:6, cex.axis = .8)
axis(2, at = seq(.2, 1.4, .2), cex.axis = .8, las = 1)
dev.off()

summary(lm(message_dist_corrected ~ distance, data = messages))

# Private information purchase by treatment, raw count (cf. p. 374) -----------
votes <- read.csv("data/votes.csv")
t.test(buyinfo_raw ~ accuracy, data = votes, var.equal = TRUE)
