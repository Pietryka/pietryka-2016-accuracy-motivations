# Figure 4: Correct voting by treatment, with 90% confidence intervals.
# Also reports the proportions and difference-of-proportions test cited in the
# text (76.4% control vs. 77.5% accuracy; p = 0.85; p. 380).
#
# Input:  data/votes.csv
#         One row per participant-election.
#         correctvote = 1 if participant voted for the candidate closest to
#         them; missing if the participant was equally close to both.
# Output: output/figure4.pdf

votes <- read.csv("data/votes.csv") |>
  subset(!is.na(correctvote))

# Proportion correct in each treatment, with 90% CI
correct_control  <- prop.test(sum(votes$correctvote[votes$accuracy == 0]),
                              sum(votes$accuracy == 0), conf.level = 0.9)
correct_accuracy <- prop.test(sum(votes$correctvote[votes$accuracy == 1]),
                              sum(votes$accuracy == 1), conf.level = 0.9)

# Difference in proportions (accuracy - control), with 90% CI.
# prop.test on this table estimates the proportion voting incorrectly in each
# group, so control - accuracy = difference in proportion correct.
diff_test <- prop.test(table(votes$accuracy, votes$correctvote),
                       correct = FALSE, conf.level = 0.9)
diff_test

est <- c(diff_test$estimate[1] - diff_test$estimate[2],
         correct_control$estimate, correct_accuracy$estimate)
ci <- rbind(diff_test$conf.int, correct_control$conf.int, correct_accuracy$conf.int)
est
ci

# Plot ------------------------------------------------------------------------
labels <- c("Difference", "Proportion correct in Control",
            "Proportion correct in Accuracy")
cols <- c("black", "grey66", "grey33")

dir.create("output", showWarnings = FALSE)
pdf("output/figure4.pdf", width = 7, height = 2)
par(mar = c(3, 12, 1, 1), mgp = c(1.5, .5, 0))
plot(1:10, 1:10, type = "n", xaxt = "n", yaxt = "n",
     xlim = c(-.1, .85), ylim = c(0, 4), xlab = "Estimate", ylab = "")
axis(1, at = c(-.1, 0, .4, .8))
abline(v = 0, lty = 2)
segments(ci[, 1], 1:3, ci[, 2], 1:3, col = cols)
points(est, 1:3, pch = c(17, 15, 19), col = cols)
for (i in 1:3) axis(2, at = i, labels = labels[i], las = 1, col.axis = cols[i])
dev.off()
