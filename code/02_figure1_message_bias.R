# Figure 1: Bias of messages increases with ideological distance between sender
# and receiver. Also reports the bivariate slope cited in the text
# (b = 0.07; t(1774) = 5.2; p. 376).
#
# Input:  data/messages.csv
#         One row per ego-alter-request-candidate.
#         message_dist = |discussant's current judgment - message sent|;
#                        missing if no message was sent
#         distance     = |ego's position - alter's position|
# Output: output/figure1.pdf            as published
#         output/figure1_corrected.pdf  corrected confidence intervals

messages <- read.csv("data/messages.csv")

# Mean bias and 95% CI at each ideological distance ---------------------------
# The published figure used the number of all ego-alter-request-candidate rows
# at each distance as n, including rows with no message. The corrected version
# uses the number of messages actually sent.
bias_summary <- function(n_rows_with_messages_only) {
  out <- aggregate(message_dist ~ distance, data = messages, FUN = mean)
  sd <- aggregate(message_dist ~ distance, data = messages, FUN = sd)$message_dist
  if (n_rows_with_messages_only) {
    n <- aggregate(message_dist ~ distance, data = messages, FUN = length)$message_dist
    df <- n - 1
  } else {
    n <- as.vector(table(messages$distance))
    df <- n
  }
  t <- qt(.975, df)
  out$n <- n
  out$lb <- out$message_dist - t * sd / sqrt(n)
  out$ub <- out$message_dist + t * sd / sqrt(n)
  out
}

bias_published <- bias_summary(n_rows_with_messages_only = FALSE)
bias_corrected <- bias_summary(n_rows_with_messages_only = TRUE)
bias_published
bias_corrected

# Plot ------------------------------------------------------------------------
plot_bias <- function(bias, file) {
  pdf(file, width = 6.5, height = 7)
  par(cex = 1.5, mar = c(4, 4, 1, 1), mgp = c(2, .5, 0))
  plot(
    bias$distance, bias$message_dist,
    type = "n", bty = "l", xaxt = "n", yaxt = "n",
    ylim = range(c(0.4, 1.2, bias$lb, bias$ub)),
    xlab = "Ideological distance between ego and alter",
    ylab = "Average bias\n(distance between belief and message)"
  )
  lines(bias$distance, bias$message_dist, lwd = 2)
  segments(bias$distance, bias$lb, bias$distance, bias$ub, lwd = 2)
  points(bias$distance, bias$message_dist, pch = 19)
  axis(1, at = 0:6, cex.axis = .8)
  axis(2, at = seq(.2, 1.4, .2), cex.axis = .8, las = 1)
  dev.off()
}

dir.create("output", showWarnings = FALSE)
plot_bias(bias_published, "output/figure1.pdf")
plot_bias(bias_corrected, "output/figure1_corrected.pdf")

# In-text: slope of bias on ideological distance ------------------------------
summary(lm(message_dist ~ distance, data = messages))
