library(ggplot2)
library(dplyr)
library(cluster)
library(factoextra)
library(readr)
library(ggrepel)
library(RColorBrewer)

# change location / file name as needed
source_path <- "~/Desktop/Programy/HE-funding-group/HESA-analysis"

outcome_and_expenditure_with_students <- read_csv(paste(source_path, "aggregate_outcomes_and_expenditure_by_university_with_known_outcomes.csv", sep=''))
outcome_and_expenditure_with_students <- outcome_and_expenditure_with_students[outcome_and_expenditure_with_students$`HE Provider` != "Total", ]

# load data per year, rename names of csv tables as needed
for (x in 17:22) {
  file_name <- sprintf("22/chart-%d-%d.csv", x, x + 1)
  file_path <- file.path(source_path, file_name)
  df <- read.csv(file_path, skip = 15, header = TRUE)
  assign(paste0("chart_", x, "_", x + 1), df)
}

for (x in 17:22) {
  file_name <- sprintf("expenditure/dt031-table-1-%d.csv", x)
  file_path <- file.path(source_path, file_name)
  df <- read.csv(file_path, skip = 16, header = TRUE)
  assign(paste0("expenditure_", x), df)
}

just_skills = cbind(
  outcome_and_expenditure_with_students$`HE Provider`,
  outcome_and_expenditure_with_students$`Total high skilled`/outcome_and_expenditure_with_students$Total,
  outcome_and_expenditure_with_students$`Total medium skilled`/outcome_and_expenditure_with_students$Total,
  outcome_and_expenditure_with_students$`Total low skilled`/outcome_and_expenditure_with_students$Total)

cols <- c("Low", "Medium", "High")
colnames(just_skills) <- c("HE Provider", "High", "Medium", "Low")

set.seed(4581487)
clusters_skills <- kmeans(x = just_skills[, cols], centers = 3)
original_with_clusters <- as.data.frame(just_skills)
original_with_clusters$UKPRN <- outcome_and_expenditure_with_students$UKPRN
original_with_clusters$Cluster <- clusters_skills$cluster
original_with_clusters$ExpenditurePerStudentPerStudent <- outcome_and_expenditure_with_students$`Total expenditure` / outcome_and_expenditure_with_students$Total
original_with_clusters$LogExpenditurePerStudent <- log(original_with_clusters$`ExpenditurePerStudent`)
original_with_clusters[, cols] <- lapply(original_with_clusters[, cols], as.numeric)
original_with_clusters$Total <- outcome_and_expenditure_with_students$Total

output_table <- data.frame(
  UKPRN = original_with_clusters$UKPRN,
  cluster = original_with_clusters$Cluster,
  total = original_with_clusters$Total
)

write.csv(output_table, "ukprn_clusters.csv", row.names = FALSE)

# dimension of the png plots
dim <- 1000
res <- 100

# change descriptions/names as needed
png(filename = paste(source_path, "plots/Clusters in LogExpenditure vs High-skilled.png", sep=""), width = dim, height = dim, res = res)
ggplot(original_with_clusters, aes(x = LogExpenditurePerStudent, y = High, color = factor(Cluster), size = Total)) +
  geom_point(alpha = 0.8) + 
  scale_size_continuous(range = c(2, 10), trans = "sqrt", name = "Total students") +
  labs(
    title = "Clusters in Log Expenditure per student vs High-skilled employment",
    x = "LogExpenditure per student reported",
    y = "High-skilled",
    color = "Cluster",
    size = "Total"
  ) +
  theme_minimal() +
  theme(
    text = element_text(size = 14),
    legend.position = "right"
  )
dev.off()

png(filename = paste(source_path, "plots/Clusters in High vs Low skilled space.png", sep=""), width = dim, height = dim, res = res)
ggplot(original_with_clusters, aes(x = High, y = Low, color = factor(Cluster), size = Total)) +
  geom_point(alpha = 0.8) + 
  scale_size_continuous(range = c(2, 10), trans = "sqrt", name = "Total students") +
  labs(
    title = "Clusters in High- vs Low-skilled employment",
    x = "Proportion of high-skilled outcomes",
    y = "Proportion of low-skilled outcomes",
    color = "Cluster",
    size = "Total"
  ) +
  theme_minimal() +
  theme(
    text = element_text(size = 14),
    legend.position = "right"
  )
dev.off()

cluster1.only <- original_with_clusters[original_with_clusters$Cluster ==1, ]

png(filename = paste(source_path, "plots/LogExpenditure vs high-skilled outcomes in for cluster 1.png", sep=""), width = dim, height = dim, res = res)
ggplot(cluster1.only, aes(x = LogExpenditurePerStudent, y = High, size = Total)) +
  geom_point(color = brewer.pal(3, "Set1")[1], alpha = 0.8) + 
  #geom_text_repel(aes(label = `HE Provider`), 
  #                size = 3,           # font size of labels
  #                max.overlaps = 15)  # adjust as needed
  scale_size_continuous(range = c(2, 10), trans = "sqrt", name = "Total students students reported") +
  labs(
    title = "Cluster 1: proportion of high-skilled vs log-expenditure",
    y = "High-skilled",
    x = "LogExpenditure per student reported",
    size = "Total students reported"
  ) +
  theme_minimal() +
  theme(
    text = element_text(size = 14),
    legend.position = "right"
  )

dev.off()


png(filename = paste(source_path, "plots/LogExpenditure vs low-skilled outcomes in for cluster 1.png", sep=""), width = dim, height = dim, res = res)
ggplot(cluster1.only, aes(x = LogExpenditurePerStudent, y = Low, size = Total)) +
  geom_point(color = brewer.pal(3, "Set1")[1], alpha = 0.8) + 
  #geom_text_repel(aes(label = `HE Provider`), 
  #                size = 3,           # font size of labels
  #                max.overlaps = 15)  # adjust as needed
  scale_size_continuous(range = c(2, 10), trans = "sqrt", name = "Total students students reported") +
  labs(
    title = "Cluster 1: proportion of low-skilled outcomes vs log-expenditure",
    y = "Proportion of low-skilled outcomes",
    x = "LogExpenditure per student reported",
    size = "Total students reported"
  ) +
  theme_minimal() +
  theme(
    text = element_text(size = 14),
    legend.position = "right"
  )
dev.off()

cluster1.ukprn <- cluster1.only$UKPRN

for (year in 17:22) {
  exp_name   <- paste0("expenditure_", year)
  chart_name <- paste0("chart_", year, "_", year + 1)
  exp_df   <- get(exp_name)
  chart_df <- get(chart_name)
  
  exp_filtered   <- exp_df[exp_df$UKPRN %in% cluster1.ukprn, ]
  chart_filtered <- chart_df[chart_df$UKPRN %in% cluster1.ukprn, ]
  
  df <- exp_filtered %>%
    inner_join(chart_filtered, by = "UKPRN")
  df$Total = as.numeric(gsub(",","",df$Total))
  df$Total.expenditure = as.numeric(gsub(",","",df$Total.expenditure))
  df$Total.high.skilled = as.numeric(gsub(",","",df$Total.high.skilled))
  
  df$LogExpenditurePerStudent <-
    log(df$Total.expenditure / df$Total)
  
  df$HighSkilledProportion <-
    df$Total.high.skilled / df$Total
  
  # Draw plot
  png(filename = paste(source_path, "plots/LogExpenditure vs high-skilled outcomes in 20", year, "-20", year + 1, ".png", sep=""), width = dim, height = dim, res = res)
  print(ggplot(df, aes(x = LogExpenditurePerStudent,
                 y = HighSkilledProportion,
                 size = Total)) +
    geom_point(color = brewer.pal(3, "Set1")[1], alpha = 0.8) +
    scale_size_continuous(range = c(2, 10),
                          trans = "sqrt",
                          name = "Total students reported") +
    labs(
      title = paste0(year, "/", year + 1,
                     ": Cluster 1: proportion of high-skilled outcomes vs log-expenditure"),
      x = "LogExpenditure per student reported",
      y = "Proportion of high-skilled outcomes"
    ) +
    theme_minimal() +
    theme(text = element_text(size = 14),
          legend.position = "right"))
  dev.off()
  
  # filter outliers
  df <- df %>% filter(HighSkilledProportion > 0.6)
  png(filename = paste(source_path, "plots/LogExpenditure vs high-skilled outcomes in 20", year, "-20", year + 1, " without outliers", sep=""), width = dim, height = dim, res = res)
  print(ggplot(df, aes(x = LogExpenditurePerStudent,
                       y = HighSkilledProportion,
                       size = Total)) +
          geom_point(color = brewer.pal(3, "Set1")[1], alpha = 0.8) +
          scale_size_continuous(range = c(2, 10),
                                trans = "sqrt",
                                name = "Total students reported") +
          labs(
            title = paste0(year, "/", year + 1,
                           ": Cluster 1: proportion of high-skilled outcomes vs log-expenditure"),
            x = "LogExpenditure per student reported",
            y = "Proportion of high-skilled outcomes"
          ) +
          theme_minimal() +
          theme(text = element_text(size = 14),
                legend.position = "right"))
  dev.off()
} 