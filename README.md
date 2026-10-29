# Replication files: Accuracy Motivations, Predispositions, and Social Information in Political Discussion Networks

Pietryka, Matthew T. 2016. "Accuracy Motivations, Predispositions, and Social Information in Political Discussion Networks." *Political Psychology* 37(3): 367–386. https://doi.org/10.1111/pops.12255

These files reproduce Tables 2–3 and Figures 1–4 of the article, along with the in-text statistics that accompany them. Table 1 lists item wording and uses no data. They also correct an error in the published Figure 1 confidence intervals and four coding errors in the original data construction, and re-estimate the affected results (see "Correction to Figure 1" and "Coding corrections" below).

## Contents

```
run_all.R                                   runs every script in code/
LICENSE                                     MIT license (code)
CITATION.cff                                citation metadata
code/
  01_table2_discussant_selection.R          Table 2
  02_figure1_message_bias.R                 Figure 1 (published and corrected)
  03_table3_figure2_information_weights.R   Table 3, Figure 2
  04_figure3_judgment_accuracy.R            Figure 3
  05_figure4_correct_voting.R               Figure 4
  06_coding_corrections.R                   Tables 2–3 and Figures 1–2 with corrected coding
data/
  discussant_choices.csv
  messages.csv
  judgments.csv
  votes.csv
```

## Requirements

R 4.1 or later and the lme4 package:

```r
install.packages("lme4")
```

The results below were verified with R 4.3.3 and lme4 1.1-35.1.

## Running the code

Set the working directory to this folder and run

```r
source("run_all.R")
```

Each script in `code/` can also be run on its own, as long as the working directory is this folder. Scripts print estimates to the console and write tables and figures to `output/`, which is created if it does not exist. `run_all.R` also saves `output/sessionInfo.txt`.

## Outputs

| Manuscript | Script | Data | Output file |
|---|---|---|---|
| Table 2 | `01_table2_discussant_selection.R` | `discussant_choices.csv` | `table2.csv` |
| Figure 1 | `02_figure1_message_bias.R` | `messages.csv` | `figure1.pdf`, `figure1_corrected.pdf` |
| Table 3 | `03_table3_figure2_information_weights.R` | `judgments.csv` | `table3.csv` |
| Figure 2A–C | `03_table3_figure2_information_weights.R` | `judgments.csv` | `figure2a.pdf`, `figure2b.pdf`, `figure2c.pdf`, `figure2_legend.pdf` |
| Figure 3 | `04_figure3_judgment_accuracy.R` | `judgments.csv` | `figure3.pdf` |
| Figure 4 | `05_figure4_correct_voting.R` | `votes.csv` | `figure4.pdf` |
| Corrected Tables 2–3, Figures 1–2 | `06_coding_corrections.R` | `discussant_choices.csv`, `judgments.csv`, `messages.csv`, `votes.csv` | `corrections/table2_corrected.csv`, `corrections/table3_corrected.csv`, `corrections/figure1_corrected.pdf`, `corrections/figure2a_corrected.pdf`, `corrections/figure2b_corrected.pdf`, `corrections/figure2c_corrected.pdf` |

Scripts 01–05 reproduce the published results. Script 06 does not change them.

In-text statistics printed to the console:

| Statistic | Page | Script |
|---|---|---|
| Mean ideological distance to chosen discussants (1.3 vs. 2.4) | 375 | `01` |
| Slope of message bias on ideological distance (b = 0.07, t(1774) = 5.2) | 376 | `02` |
| Mean judgment error and Wilcoxon rank-sum test (W = 46,390, p = 0.83) | 380 | `04` |
| Proportion voting correctly and difference-of-proportions test (p = 0.85) | 380 | `05` |

## Correction to Figure 1

The confidence intervals in the published Figure 1 are too narrow. To compute the standard error at each ideological distance, the original code used as n the number of all ego–alter–request–candidate rows at that distance, including rows in which no message was sent, rather than the number of messages. `figure1_corrected.pdf` uses the number of messages. The point estimates are unchanged, as is the regression of message bias on ideological distance reported in the text. Both versions treat messages as independent observations.

| Distance | Mean bias | Published 95% CI | Corrected 95% CI | Messages |
|---|---|---|---|---|
| 0 | 0.48 | 0.45–0.51 | 0.39–0.56 | 340 |
| 1 | 0.53 | 0.51–0.56 | 0.47–0.60 | 528 |
| 2 | 0.56 | 0.53–0.59 | 0.47–0.65 | 366 |
| 3 | 0.72 | 0.68–0.77 | 0.59–0.86 | 250 |
| 4 | 0.88 | 0.82–0.95 | 0.67–1.10 | 146 |
| 5 | 0.73 | 0.65–0.80 | 0.54–0.92 | 114 |
| 6 | 0.91 | 0.69–1.12 | 0.44–1.38 | 32 |

## Coding corrections

The published article states that participants could buy up to three pieces of private information. The z-Tree program allowed up to four (up to two at the 25-ECU price), and participants bought four in 61 of 306 participant-elections. The code that built the analysis datasets handled the fourth piece inconsistently and contained one unrelated error. The corrected variables are included alongside the originals in `data/`, and `06_coding_corrections.R` re-estimates the affected results.

| Variable | Original coding | Corrected variable | Affects |
|---|---|---|---|
| Pieces of private information purchased | Purchases of four recoded to three | `buyinfo_raw` (0–4) | Table 3, Figure 2, p. 374 |
| Prior judgment | For participants who bought four pieces, the judgment after the third piece | `prior_ztree`: the prior recorded by z-Tree, i.e., the judgment after the last piece purchased | Table 3, Figure 2 |
| Message bias | For first-round messages from participants who bought four pieces, measured against the sender's judgment after the third piece | `message_dist_corrected`: measured against the sender's judgment after the last piece purchased | Figure 1 |
| Number of new topics | Counted the ego's topics not held by the alter, and set to 0 whenever the alter bought fewer than three pieces | `newinfo_corrected`: number of the alter's topics (up to four) on which the ego received no private information | Table 2 |

The alter's expertise in Table 2 (`alterbuyinfo`) was not recoded and already ranges from 0 to 4, matching what participants saw when choosing discussants.

None of the article's substantive conclusions change. Bold indicates p < .05, one-tailed, as in the article.

**Table 2.** Accuracy-treatment participants still place more weight on discussant expertise and are more willing to choose discussants with divergent preferences, and the number of new topics still has little association with discussant choice.

| | Control, published | Control, corrected | Accuracy, published | Accuracy, corrected | Wald p, published | Wald p, corrected |
|---|---|---|---|---|---|---|
| Alter's expertise | **0.64** | **0.55** | **0.94** | **0.85** | .00 | .00 |
| Ideological distance | −0.08 | −0.08 | 0.04 | 0.04 | .04 | .04 |
| Previously requested | **−3.40** | **−3.41** | **−3.75** | **−3.75** | .57 | .58 |
| Number of new topics | −0.02 | 0.10 | −0.07 | 0.04 | .60 | .51 |

**Table 3.**

| | Control, published | Control, corrected | Accuracy, published | Accuracy, corrected | Wald p, published | Wald p, corrected |
|---|---|---|---|---|---|---|
| Expertise | 0.03 | −0.10 | **0.32** | **0.20** | .29 | .14 |
| Prior | **0.17** | 0.10 | 0.07 | **0.10** | .33 | .97 |
| Mean social message | **0.71** | **0.68** | **1.12** | **1.04** | .02 | .02 |
| Candidate B | **0.45** | **0.64** | −0.22 | −0.17 | .03 | .00 |
| Expertise × Prior | 0.07 | **0.12** | **0.10** | **0.08** | .52 | .45 |
| Expertise × Mean social message | −0.08 | −0.07 | **−0.21** | **−0.15** | .11 | .22 |
| Expertise × Candidate B | 0.04 | −0.05 | **0.15** | 0.10 | .44 | .20 |

The interaction between expertise and the prior is now statistically significant in both treatments, not only the accuracy treatment (p. 379).

**Figure 2.** With purchases of four pieces restored, the figure has a fifth row for expertise = 4.

- Private information: no significant difference between treatments at any level of expertise (Wald p = .97, .58, .13, .08, .15 for 0–4 pieces).
- Social information: accuracy-treatment participants place more weight on social messages than control participants who bought 0, 1, or 2 pieces (p = .02, .01, .01). The article reports this difference for participants who bought fewer than two.
- Public information: control participants place more weight on the Candidate B base rate than accuracy-treatment participants who bought 0–3 pieces (p = .00, .00, .00, .03). The article reports this difference for fewer than three.

**Figure 1.** Measured against the sender's judgment after the last piece of private information, average bias is lower at every distance (0.40, 0.47, 0.52, 0.66, 0.75, 0.54, 0.81 for distances 0–6). It still increases with ideological distance (b = 0.06; t(1774) = 4.5). The corrected figure also uses the corrected confidence intervals described above.

**Information purchase (p. 374).** With the raw count, participants bought 2.06 pieces in the control and 2.14 in the accuracy treatment (t(304) = −0.54, p = .59). The article reports 1.88 and 1.92 with purchases of four recoded to three.

Figures 3 and 4 and the tests of judgment accuracy and correct voting do not use these variables and are unaffected.

## Data

Participants were 54 undergraduates at the University of California, Davis, playing in six sessions of nine. Half the sessions received the accuracy incentive. Each session played about six elections. The experiment was programmed in z-Tree. The files in `data/` contain the variables used in the article's analyses, drawn from the original analysis datasets, and the corrected variables, rebuilt from the z-Tree session output. Missing values are blank.

**Identifiers** (all files)

| Variable | Description |
|---|---|
| `group` | Session (1–6) |
| `period` | Election number within session |
| `subject` | Participant number within session (1–9) |
| `subjectid` | Unique participant identifier (`group` × 10 + `subject`) |
| `accuracy` | 1 = accuracy treatment, 0 = control |

**`discussant_choices.csv`** — one row per participant (ego) × potential discussant (alter) × request; 7,344 rows. Used for Table 2.

| Variable | Description |
|---|---|
| `requestnum` | Request for social information (1–3) |
| `alternum` | Alter's participant number within session |
| `link` | 1 if ego requested information from this alter |
| `ideal` | Ego's ideological position (0–6) |
| `alterideal` | Alter's ideological position (0–6) |
| `distance` | Ideological distance between ego and alter, \|`ideal` − `alterideal`\| |
| `alterbuyinfo` | Pieces of private information the alter purchased, as recorded by z-Tree (0–4) |
| `askbefore` | 1 if ego previously requested information from this alter in the election |
| `newinfo` | Number of new topics as used in the article (see "Coding corrections") |
| `newinfo_corrected` | Number of the alter's topics on which ego received no private information |

**`messages.csv`** — one row per ego × alter × request × candidate; 14,688 rows. Used for Figure 1.

| Variable | Description |
|---|---|
| `requestnum`, `alternum`, `link`, `distance` | As in `discussant_choices.csv` |
| `candidate` | 1 = Candidate A, 2 = Candidate B |
| `message_dist` | Bias of the message ego sent to the alter: \|ego's current judgment − message sent\|, as used in the article. Missing if no message was sent. |
| `message_dist_corrected` | As `message_dist`, with first-round messages measured against ego's judgment after the last piece of private information purchased |

**`judgments.csv`** — one row per participant × election × candidate; 612 rows. Used for Table 3 and Figures 2–3.

| Variable | Description |
|---|---|
| `candB` | 1 if the judgment concerns Candidate B |
| `buyinfo` | Pieces of private information the participant purchased, with purchases of four recoded to three, as used in the article |
| `buyinfo_raw` | Pieces of private information the participant purchased (0–4) |
| `prior` | Judgment of the candidate's position before social information, as used in the article |
| `prior_ztree` | Judgment of the candidate's position after the last piece of private information purchased, as recorded by z-Tree |
| `socmn` | Mean social message received about the candidate in the election |
| `guess7` | Final judgment of the candidate's position (0–6) |
| `candpos` | Candidate's true position (0–6) |
| `guessdist` | Judgment error, \|`guess7` − `candpos`\| |

**`votes.csv`** — one row per participant × election; 306 rows. Used for Figure 4.

| Variable | Description |
|---|---|
| `cost` | Price per piece of private information, in ECUs (0, 5, or 25) |
| `ideal` | Participant's ideological position (0–6) |
| `canda`, `candb` | True positions of Candidates A and B (0–6) |
| `buyinfo` | Pieces of private information purchased, with purchases of four recoded to three, as used in the article |
| `buyinfo_raw` | Pieces of private information purchased (0–4) |
| `correctvote` | 1 if the participant voted for the candidate closer to their position, 0 if not. Missing if the participant was equally close to both candidates. |

## Notes

- The "Deviance" row is −2 × log-likelihood in Table 2 and the ML deviance of the REML fit in Table 3. Current versions of lme4 define `deviance()` differently, so the scripts compute these directly.
- In Table 2, lme4 issues a convergence warning for the control-group model (max|grad| = 0.0027, tolerance 0.002). The estimates match those reported in the article.
- Figure 2 was published as three panels assembled in the manuscript. The scripts write each panel and the legend to separate files. Panel C shows the effect of public information; its heading in the published figure reads "Social Info."

## License

The code is released under the MIT License (see `LICENSE`). The data in `data/` are released under the [Creative Commons Attribution 4.0 International License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/). The data are anonymous and contain no demographic information. When using these files, please cite the article above.

## AI assistance

The replication package was prepared with Claude (Anthropic; Claude Opus 5.5) in October 2026. Claude rewrote the original analysis scripts for portability and clarity, removed unused code, reduced the datasets to the variables used, and drafted this README. Claude also identified the error in the Figure 1 confidence intervals and the coding errors described in "Coding corrections," by comparing the original data-construction code with the z-Tree program and session output, and wrote the code that rebuilds the corrected variables. I reviewed all code and documentation and confirmed that scripts 01–05 reproduce the published estimates. I am responsible for the contents of this package.
