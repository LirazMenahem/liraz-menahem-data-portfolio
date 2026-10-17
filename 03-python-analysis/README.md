# Project 3: Loan Data Analysis with Python

> Project page: [PUT-YOUR-HTML-LINK-HERE](PUT-YOUR-HTML-LINK-HERE)

## Business question
How do a client's credit score and demographics (age, gender, banking type)
relate to the loan terms they receive (principal, interest, monthly payment)?

## Dataset
120 bank loans taken in 2024-2025, 14 original columns
(client details, banking type, credit score, principal, interest, monthly payment, loan dates).
The file is in `data/bank_loan_updated.csv`.

## Process
1. **Cleaning:** converted date columns, converted IDs to text, filled missing values (median for numbers, "Unknown" for city).
2. **Outlier check:** SQL validation with `pandasql` (age, principal, interest, credit score ranges).
3. **Feature engineering:** client age at loan start, loan duration, total payment, credit and age categories, year / month / quarter.
4. **Analysis:** descriptive statistics and group comparisons by banking type, gender, age and credit category.
5. **Visualization:** 6 charts (bar, pie, heatmap, line, count plot, scatter).

## Key findings
- **Credit score does not explain loan terms:** correlation with principal and interest is close to 0.
- **Loan duration drives the monthly payment:** correlation of -0.68. Longer loans mean lower payments.
- **Principal and monthly payment** are positively related (0.48).
- **VIP clients** receive the highest average principal (~13,092 NIS) despite an average credit score of ~680.
- **Women** received a higher average principal than men (~12,008 vs ~10,579 NIS).
- **Younger clients** take shorter loans and carry the highest monthly payments.
- **71 loans** were taken in 2024 versus **49** in 2025.

## Recommendations
- Evaluate clients by a combination of credit score, banking type, age and repayment ability, not by credit score alone.
- Offer longer repayment plans to younger clients to reduce monthly burden.
- Collect additional variables such as income and account history for a more precise analysis.

## Tools
Python · pandas · numpy · matplotlib · seaborn · pandasql

## Files
- `Analyze_Data_with_Python.ipynb` - the full analysis
- `data/bank_loan_updated.csv` - dataset

## How to run
```bash
pip install pandas numpy matplotlib seaborn pandasql
jupyter notebook Analyze_Data_with_Python.ipynb
```

> Note: the notebook text is written in Hebrew.
