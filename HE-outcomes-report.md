## Plot interpretation:

- We used the datasets from HESA, namely:

- [Table 22](https://www.hesa.ac.uk/data-and-analysis/graduates/table-22), for graduate outcomes per university by type of employment. The types (low/medium/high) of employment outcomes are are by [Standard Occupational Classification (SOC) groups](https://www.hesa.ac.uk/support/documentation/occupational/soc2020). For this table, we specifically used the aggregated charts, available on the website
- [Table 1](https://www.hesa.ac.uk/data-and-analysis/finances/table-1), for expenditure per university

- The reported data are per year, we aggreggated (summed) data per all reporting periods (17/18 - 22/23). 

- We considered a vector of fractions of reported outcomes per types (low-skilled, medium-skilled, high-skilled), run a clustering algorithm (kmeans k = 3) to obtain the following three clusters:

| Cluster | Proportion of low-skilled outcomes | Proportion of medium-skilled outcomes | Proportion of high-skilled outcomes | Number of students reported| Number of HE institutions |
|---------|-------------------------------|-------------------|----------------|---------|-------|
| 1       | 0.05662577 | 0.1008558  | 0.8182708 | 1259105 | 214 |
| 2       | 0.31695275 | 0.3192422 | 0.3194274 | 20545 | 70 |
| 3       | 0.15445474 | 0.2481723 | 0.5891016 | 170485 | 170 |

- We considered Expenditure (as in Table 1), per students with reported employment outcome to take into account size of the institutions. We plotted the outcomes by cluster: proportion of high-skilled outcomes versus the Expenditure per student (on a logarithmic scale). The sizes of the datapoints are proportional to the square-root of the number of students.
- We also plotted High- vs Low-skilled outcomes proportion for all clusters

- Further, we plotted only universities cluster 1 (cluster with >86% reported students): LogExpenditure vs High outcomes,  LogExpenditure vs Low Incomes. 

## Data and Analysis Limitations

- The data we used was self-reported, and only accounted for graduates in employment (thus not covering unemployment and further study). For a more complete picture, it would be needed to incorporata that data as well as taking into account the self-reporting bias

- The data was collected 15 months post graduation and hence does not capture a long-term benefit of higher education. 

- When comparing students outcomes to expenditure, we aggreggated expenditures per year, which does not account for inflation. However, we can see, that for Cluster 1, plotting outcomes vs expenditure per ear year in reporting period, the relationship does not seem to vary a lot (with an exception of a few outliers). For better readability we've included these plots with and without outliers.

- We considered expenditure per student reported, not per student attending that year. This is as we would expect the number of students overal be proportional to the size of the graduating / reported cohort, however it would be good to see the relatationship when the expenditure is scaled by the total number of students. 

- For expenditure, we also considered total expenditure, which includes both research and teaching. It might be insightful to compare with more granular expenditure data

- For some institutions, the data were missing. The analysis also omitted HE providers with small-sample size (<20 reported students in 2017-2023).

## Further questions 

- Ideally, we would obtain more long-term data about graduate outcomes, overcomming some of the above limitations.

- One particular area of interest would be looking into data per subject as well as university. There exist HESA data -- (Table 28)[https://www.hesa.ac.uk/data-and-analysis/graduates/table-28] for outcomes by type of activity 15 months after graduation, however this data does not distinguish between different employment outcomes.

- Demographics and socioeconomic data were not taken into account. Would it be possible to get more granular data about graduate outcomes, and see how well the underlying factor explain the results?

