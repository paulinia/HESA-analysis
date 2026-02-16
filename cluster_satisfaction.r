library(ggplot2)
library(dplyr)
library(cluster)
library(factoextra)
library(readr)
library(ggrepel)
library(RColorBrewer)
# library(tidyverse)
library(readxl)
library(janitor)

# change location / file name as needed
source_path <- "~/Desktop/Programy/HE-funding-group/HESA-analysis/"

clusters <- read_csv(paste(source_path, "ukprn_clusters.csv", sep = '')) %>%
  mutate(
    UKPRN = as.character(UKPRN),
    cluster = as.character(cluster)
  )


years <- c("17-18","18-19","19-20","20-21","21-22","22-23")
questions <- c("My current activity is meaningful", "My current activity fits with my future plans", "I am utilising what I learnt during my studies in my current activity")

cluster_summaries <- list()

for (question in questions) {
  for (yr in years) {
    
    df <- readr::read_csv(paste(source_path, "Table-8/table-8-20", yr, ".csv", sep = ''), skip = 11)
    
    summary_df <- df %>%
      mutate(
        UKPRN = as.character(UKPRN),
        `Answer grouping` = tolower(trimws(`Answer grouping`)),
        Percent = as.numeric(gsub("%", "", Percent))
      ) %>%
      filter(
        UKPRN %in% clusters$UKPRN,
        `Graduate reflection question` == question,
        `Country of provider` == "All",
        `Permanent address` == "All",
        `Activity` == "All",
        `Interim study` == "Include significant interim study"
      ) %>%
      group_by(UKPRN) %>%
      summarise(
        agree = sum(if_else(`Answer grouping` %in% c("agree", "strongly agree"), Percent, 0), na.rm = TRUE),
        disagree = sum(if_else(`Answer grouping` %in% c("disagree", "strongly disagree"), Percent, 0), na.rm = TRUE),
        .groups = "drop"
      ) %>%
      left_join(clusters, by = "UKPRN")
    
      ## weighting by total num of students aggregated, TODO: change per reported a year
      
      per_cluster_summary <- summary_df %>%
        group_by(cluster) %>%
        summarise(
          total_sum = sum(total, na.rm = TRUE),
          average_sum = sum(total * agree / 100, na.rm = TRUE),
          average = 100 * average_sum / total_sum,
          .groups = "drop"
        ) %>%
        mutate(
          year = yr,
          question = question
        ) %>%
        select(year, question, cluster, average)
      cluster_summaries[[length(cluster_summaries) + 1]] <- per_cluster_summary
      
    
      summary_df$logTotal <- log(summary_df$total)
      # filter outliers
      summary_df <- summary_df %>% filter(agree + disagree > 0.001)
    
      png(filename = paste(source_path, question, ": log total vs satisfaction 20", yr, ".png", sep=""), width = dim, height = dim, res = res)
      print(ggplot(summary_df, aes(x = logTotal,
                           y = agree,
                           colour = factor(cluster))) +
              geom_point(alpha = 0.8) +
              labs(
                title = paste0(question, " 20", yr,
                               ": Satisfaction (%) vs Total number of students reported"),
                x = "Log of total number of responses",
                y = "Agree (%)"
              ) +
              theme_minimal() +
              theme(text = element_text(size = 14),
                    legend.position = "right"))
      dev.off()
  }
}

summary_per_cluster <- as.data.frame(bind_rows(cluster_summaries))
print(summary_per_cluster %>% group_by(question, cluster) %>% summarise(average = sum(average) / length(years)))
