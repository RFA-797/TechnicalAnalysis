# BDA400 Assignment 2 - Technical Analysis (Preliminary Stage)
# Student: Rania Abdelmoaein
# AI assistance: ChatGPT (GPT-6) helped draft this example script.
# Verify installation, downloaded prices, calculations and plots in RStudio.

required_packages <- c("quantmod", "TTR")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace,
                                              logical(1), quietly = TRUE)]
if (length(missing_packages)) install.packages(missing_packages, repos = "https://cloud.r-project.org")
library(quantmod)
library(TTR)

# Run from the folder containing portfolio.txt, or set this path explicitly.
portfolio_file <- "portfolio.txt"

read_portfolio <- function(path = portfolio_file) {
  if (!file.exists(path)) stop("portfolio.txt not found. Set the working directory to Assignment2.")
  symbols <- unique(toupper(trimws(readLines(path, warn = FALSE))))
  symbols <- symbols[nzchar(symbols) & !grepl("^#", symbols)]
  if (!length(symbols)) stop("portfolio.txt contains no stock symbols")
  symbols
}

load_stock_data <- function(path = portfolio_file, from = Sys.Date() - 365,
                            to = Sys.Date()) {
  symbols <- read_portfolio(path)
  result <- list()
  for (symbol in symbols) {
    message("Downloading ", symbol, " from Yahoo Finance...")
    xt <- tryCatch(quantmod::getSymbols(symbol, src = "yahoo", from = from,
                                        to = to, auto.assign = FALSE),
                   error = function(e) { warning(symbol, ": ", conditionMessage(e)); NULL })
    if (is.null(xt) || NROW(xt) == 0) next
    data <- data.frame(Date = as.Date(zoo::index(xt)), zoo::coredata(xt),
                       check.names = FALSE)
    names(data) <- c("Date", "Open", "High", "Low", "Close", "Volume", "Adjusted")
    data <- data[order(data$Date), , drop = FALSE]
    result[[symbol]] <- data
  }
  if (!length(result)) stop("No stock prices downloaded. Check internet, symbols and Yahoo access.")
  result
}

# A mode for rounded daily closing prices. Continuous data may have multiple modes.
price_mode <- function(x, digits = 2) {
  x <- round(x[is.finite(x)], digits)
  if (!length(x)) return(NA_real_)
  freq <- table(x)
  if (max(freq) == 1) return(NA_real_) # no repeated value
  as.numeric(names(freq)[which.max(freq)])
}

calculate_statistics <- function(data, symbol, window = 20) {
  stopifnot(is.data.frame(data), "Close" %in% names(data))
  prices <- as.numeric(data$Close)
  valid <- prices[is.finite(prices)]
  if (!length(valid)) stop("No valid closing prices for ", symbol)
  ma <- TTR::SMA(prices, n = window)
  data$SMA20 <- ma
  stats <- data.frame(Symbol = symbol, Observations = length(valid),
                      Mean = mean(valid), Mode = price_mode(valid),
                      Median = median(valid), Std_Dev = sd(valid),
                      Latest_Close = tail(valid, 1),
                      Latest_SMA20 = if (length(valid) >= window) tail(ma, 1) else NA_real_)
  list(data = data, summary = stats)
}

display_stock_data <- function(data, symbol) {
  cat("\n=====", symbol, "Latest observations =====\n")
  print(utils::tail(data, 6), row.names = FALSE)
}

display_statistics <- function(stats) {
  cat("\n===== Closing-price statistics =====\n")
  print(stats, row.names = FALSE, digits = 4)
  cat("Mode uses prices rounded to 2 decimals; NA means no repeated price.\n")
}

plot_stock_data <- function(data, symbol) {
  plot(data$Date, data$Close, type = "l", col = "steelblue", lwd = 2,
       main = paste(symbol, "Closing Price and 20-day Moving Average"),
       xlab = "Date", ylab = "Price (USD)")
  lines(data$Date, data$SMA20, col = "firebrick", lwd = 2)
  legend("topleft", legend = c("Close", "20-day SMA"),
         col = c("steelblue", "firebrick"), lty = 1, lwd = 2, bty = "n")
}

run_analysis <- function(path = portfolio_file) {
  stocks <- load_stock_data(path)
  analyses <- lapply(names(stocks), function(sym) calculate_statistics(stocks[[sym]], sym))
  names(analyses) <- names(stocks)
  all_stats <- do.call(rbind, lapply(analyses, function(x) x$summary))
  rownames(all_stats) <- NULL
  for (sym in names(analyses)) {
    display_stock_data(analyses[[sym]]$data, sym)
    plot_stock_data(analyses[[sym]]$data, sym)
  }
  display_statistics(all_stats)
  invisible(list(analyses = analyses, statistics = all_stats))
}

# In RStudio: set the working directory to Assignment2, then click Source.
results <- run_analysis()
