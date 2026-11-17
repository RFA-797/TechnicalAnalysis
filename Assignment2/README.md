# BDA400 Assignment 2 — Technical Analysis Using R (Preliminary Stage)

Student: Rania Abdelmoaein

## Files
- `portfolio.txt`: one stock ticker per line (AAPL, MSFT, GOOGL).
- `technical_analysis.R`: package installation, price import, descriptive statistics, display and plots.
- `Assignment2_Report.docx`: setup and verification report (add authentic screenshots).

## Run
1. Install R and RStudio locally as required by the assignment.
2. Open RStudio, choose **Session > Set Working Directory > Choose Directory**, and select the `Assignment2` folder.
3. Open `technical_analysis.R` and click **Source**. Internet access is needed for Yahoo Finance data.
4. Check the console, plot pane and package installation messages. Capture real screenshots.

The analysis uses daily **closing prices** over approximately the preceding year. The moving average is a 20-trading-day simple moving average (SMA). Mode is calculated from closing prices rounded to 2 decimal places; `NA` indicates no repeated value. Price statistics vary with the date of execution and data availability.

## AI assistance
ChatGPT (GPT-6) helped draft the initial R code and report outline on 2026-11-17. The student must execute, verify, correct and document the final results before submission.
