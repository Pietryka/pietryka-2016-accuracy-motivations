# Figure 3: Accuracy of final judgments by treatment. Also reports the mean
# judgment error and Wilcoxon rank-sum test cited in the text
# (0.89 control vs. 0.91 accuracy; W = 46,390; p = 0.83; p. 380).
#
# Input:  data/judgments.csv
#         guessdist = |final judgment - candidate's true position|
# Output: output/figure3.pdf

judgments <- read.csv("data/judgments.csv")

# Distribution of judgment error by treatment (rows: control, accuracy)
error_prop <- prop.table(table(judgments$accuracy, judgments$guessdist), 1)
error_prop

# In-text: mean error and Wilcoxon rank-sum test
tapply(judgments$guessdist, judgments$accuracy, mean)
error_test <- wilcox.test(guessdist ~ accuracy, data = judgments)
error_test

# Plot ------------------------------------------------------------------------
dir.create("output", showWarnings = FALSE)
pdf("output/figure3.pdf", width = 6, height = 6)
par(mar = c(5, 5, 1, 1))
bars <- barplot(
  error_prop,
  beside = TRUE, xaxt = "n", yaxt = "n", ylim = c(0, .5),
  col = c("grey66", "grey33"),
  xlab = "Distance = |final judgment - true position|",
  ylab = "Proportion of judgments",
  cex.lab = 1.6
)
axis(1, at = bars[1, ] + .5, labels = 0:4, cex.axis = 1.3)
axis(2, at = c(0, .2, .4), cex.axis = 1.3, las = 1)
text(12.5, .45, labels = paste(" p =", round(error_test$p.value, 2)), cex = 1.6)
text(1.1, .02, labels = "Control", srt = 90, cex = 1.5, adj = c(0, 1))
text(2.1, .02, labels = "Accuracy treatment", srt = 90, cex = 1.5, adj = c(0, 1),
     col = "white")
box()
dev.off()
