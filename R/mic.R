# ==================================================================== #
# TITLE                                                                #
# AMR: An R Package for Working with Antimicrobial Resistance Data     #
#                                                                      #
# SOURCE                                                               #
# https://github.com/msberends/AMR                                     #
#                                                                      #
# CITE AS                                                              #
# Berends MS, Luz CF, Friedrich AW, Sinha BNM, Albers CJ, Glasner C    #
# (2022). AMR: An R Package for Working with Antimicrobial Resistance  #
# Data. Journal of Statistical Software, 104(3), 1-31.                 #
# doi:10.18637/jss.v104.i03                                            #
#                                                                      #
# Developed at the University of Groningen and the University Medical  #
# Center Groningen in The Netherlands, in collaboration with many      #
# colleagues from around the world, see our website.                   #
#                                                                      #
# This R package is free software; you can freely use and distribute   #
# it for both personal and commercial purposes under the terms of the  #
# GNU General Public License version 2.0 (GNU GPL-2), as published by  #
# the Free Software Foundation.                                        #
# We created this package for both routine data analysis and academic  #
# research and it was publicly released in the hope that it will be    #
# useful, but it comes WITHOUT ANY WARRANTY OR LIABILITY.              #
#                                                                      #
# Visit our website for the full manual and a complete tutorial about  #
# how to conduct AMR data analysis: https://msberends.github.io/AMR/   #
# ==================================================================== #

# these are allowed MIC values and will become [factor] levels
operators <- c("<", "<=", "", ">=", ">")
valid_mic_levels <- c(
  c(t(vapply(
    FUN.VALUE = character(6), operators,
    function(x) paste0(x, "0.000", c(1:4, 6, 8))
  ))),
  c(t(vapply(
    FUN.VALUE = character(90), operators,
    function(x) paste0(x, "0.00", c(1:9, 11:19, 21:29, 31:39, 41:49, 51:59, 61:69, 71:79, 81:89, 91:99))
  ))),
  unique(c(t(vapply(
    FUN.VALUE = character(106), operators,
    function(x) {
      paste0(x, sort(as.double(paste0(
        "0.0",
        sort(c(1:99, 125, 128, 156, 165, 256, 512, 625))
      ))))
    }
  )))),
  unique(c(t(vapply(
    FUN.VALUE = character(103), operators,
    function(x) {
      paste0(x, sort(as.double(paste0(
        "0.",
        c(1:99, 125, 128, 256, 512)
      ))))
    }
  )))),
  c(t(vapply(
    FUN.VALUE = character(10), operators,
    function(x) paste0(x, sort(c(1:9, 1.5)))
  ))),
  c(t(vapply(
    FUN.VALUE = character(45), operators,
    function(x) paste0(x, c(10:98)[9:98 %% 2 == TRUE])
  ))),
  c(t(vapply(
    FUN.VALUE = character(17), operators,
    function(x) paste0(x, sort(c(2^c(7:11), 192, 80 * c(2:12))))
  )))
)

#' Transform Input to Minimum Inhibitory Concentrations (MIC)
#'
#' This transforms vectors to a new class [`mic`], which treats the input as decimal numbers, while maintaining operators (such as ">=") and only allowing valid MIC values known to the field of (medical) microbiology.
#' @rdname as.mic
#' @param x a [character] or [numeric] vector
#' @param na.rm a [logical] indicating whether missing values should be removed
#' @param ... arguments passed on to methods
#' @details To interpret MIC values as SIR values, use [as.sir()] on MIC values. It supports guidelines from EUCAST (`r min(as.integer(gsub("[^0-9]", "", subset(clinical_breakpoints, guideline %like% "EUCAST")$guideline)))`-`r max(as.integer(gsub("[^0-9]", "", subset(clinical_breakpoints, guideline %like% "EUCAST")$guideline)))`) and CLSI (`r min(as.integer(gsub("[^0-9]", "", subset(clinical_breakpoints, guideline %like% "CLSI")$guideline)))`-`r max(as.integer(gsub("[^0-9]", "", subset(clinical_breakpoints, guideline %like% "CLSI")$guideline)))`).
#'
#' This class for MIC values is a quite a special data type: formally it is an ordered [factor] with valid MIC values as [factor] levels (to make sure only valid MIC values are retained), but for any mathematical operation it acts as decimal numbers:
#'
#' ```
#' x <- random_mic(10)
#' x
#' #> Class 'mic'
#' #>  [1] 16     1      8      8      64     >=128  0.0625 32     32     16
#'
#' is.factor(x)
#' #> [1] TRUE
#'
#' x[1] * 2
#' #> [1] 32
#'
#' median(x)
#' #> [1] 26
#' ```
#'
#' This makes it possible to maintain operators that often come with MIC values, such ">=" and "<=", even when filtering using [numeric] values in data analysis, e.g.:
#'
#' ```
#' x[x > 4]
#' #> Class 'mic'
#' #> [1] 16    8     8     64    >=128 32    32    16
#'
#' df <- data.frame(x, hospital = "A")
#' subset(df, x > 4) # or with dplyr: df %>% filter(x > 4)
#' #>        x hospital
#' #> 1     16        A
#' #> 5     64        A
#' #> 6  >=128        A
#' #> 8     32        A
#' #> 9     32        A
#' #> 10    16        A
#' ```
#'
#' The following [generic functions][groupGeneric()] are implemented for the MIC class: `!`, `!=`, `%%`, `%/%`, `&`, `*`, `+`, `-`, `/`, `<`, `<=`, `==`, `>`, `>=`, `^`, `|`, [abs()], [acos()], [acosh()], [all()], [any()], [asin()], [asinh()], [atan()], [atanh()], [ceiling()], [cos()], [cosh()], [cospi()], [cummax()], [cummin()], [cumprod()], [cumsum()], [digamma()], [exp()], [expm1()], [floor()], [gamma()], [lgamma()], [log()], [log1p()], [log2()], [log10()], [max()], [mean()], [min()], [prod()], [range()], [round()], [sign()], [signif()], [sin()], [sinh()], [sinpi()], [sqrt()], [sum()], [tan()], [tanh()], [tanpi()], [trigamma()] and [trunc()]. Some functions of the `stats` package are also implemented: [median()], [quantile()], [mad()], [IQR()], [fivenum()]. Also, [boxplot.stats()] is supported. Since [sd()] and [var()] are non-generic functions, these could not be extended. Use [mad()] as an alternative, or use e.g. `sd(as.numeric(x))` where `x` is your vector of MIC values.
#'
#' Using [as.double()] or [as.numeric()] on MIC values will remove the operators and return a numeric vector. Do **not** use [as.integer()] on MIC values as by the \R convention on [factor]s, it will return the index of the factor levels (which is often useless for regular users).
#'
#' Use [droplevels()] to drop unused levels. At default, it will return a plain factor. Use `droplevels(..., as.mic = TRUE)` to maintain the `mic` class.
#' @return Ordered [factor] with additional class [`mic`], that in mathematical operations acts as decimal numbers. Bare in mind that the outcome of any mathematical operation on MICs will return a [numeric] value.
#' @aliases mic
#' @export
#' @seealso [as.sir()]
#' @examples
#' mic_data <- as.mic(c(">=32", "1.0", "1", "1.00", 8, "<=0.128", "8", "16", "16"))
#' mic_data
#' is.mic(mic_data)
#'
#' # this can also coerce combined MIC/SIR values:
#' as.mic("<=0.002; S")
#'
#' # mathematical processing treats MICs as numeric values
#' fivenum(mic_data)
#' quantile(mic_data)
#' all(mic_data < 512)
#'
#' # interpret MIC values
#' as.sir(
#'   x = as.mic(2),
#'   mo = as.mo("Streptococcus pneumoniae"),
#'   ab = "AMX",
#'   guideline = "EUCAST"
#' )
#' as.sir(
#'   x = as.mic(c(0.01, 2, 4, 8)),
#'   mo = as.mo("Streptococcus pneumoniae"),
#'   ab = "AMX",
#'   guideline = "EUCAST"
#' )
#'
#' # plot MIC values, see ?plot
#' plot(mic_data)
#' plot(mic_data, mo = "E. coli", ab = "cipro")
#'
#' if (require("ggplot2")) {
#'   autoplot(mic_data, mo = "E. coli", ab = "cipro")
#' }
#' if (require("ggplot2")) {
#'   autoplot(mic_data, mo = "E. coli", ab = "cipro", language = "nl") # Dutch
#' }
#' if (require("ggplot2")) {
#'   autoplot(mic_data, mo = "E. coli", ab = "cipro", language = "uk") # Ukrainian
#' }
as.mic <- function(x, na.rm = FALSE) {
  meet_criteria(x, allow_class = c("mic", "character", "numeric", "integer", "factor"), allow_NA = TRUE)
  meet_criteria(na.rm, allow_class = "logical", has_length = 1)

  if (is.mic(x)) {
    x
  } else {
    if (is.numeric(x)) {
      x <- format(x, scientific = FALSE)
    } else {
      x <- as.character(unlist(x))
    }
    if (isTRUE(na.rm)) {
      x <- x[!is.na(x)]
    }
    x[trimws2(x) == ""] <- NA
    x.bak <- x

    # comma to period
    x <- gsub(",", ".", x, fixed = TRUE)
    # transform Unicode for >= and <=
    x <- gsub("\u2264", "<=", x, fixed = TRUE)
    x <- gsub("\u2265", ">=", x, fixed = TRUE)
    # remove other invalid characters
    x <- gsub("[^a-zA-Z0-9.><= ]+", "", x, perl = TRUE)
    # remove space between operator and number ("<= 0.002" -> "<=0.002")
    x <- gsub("(<|=|>) +", "\\1", x, perl = TRUE)
    # transform => to >= and =< to <=
    x <- gsub("=<", "<=", x, fixed = TRUE)
    x <- gsub("=>", ">=", x, fixed = TRUE)
    # dots without a leading zero must start with 0
    x <- gsub("([^0-9]|^)[.]", "\\10.", x, perl = TRUE)
    # values like "<=0.2560.512" should be 0.512
    x <- gsub(".*[.].*[.]", "0.", x, perl = TRUE)
    # remove ending .0
    x <- gsub("[.]+0$", "", x, perl = TRUE)
    # remove all after last digit
    x <- gsub("[^0-9]+$", "", x, perl = TRUE)
    # keep only one zero before dot
    x <- gsub("0+[.]", "0.", x, perl = TRUE)
    # starting 00 is probably 0.0 if there's no dot yet
    x[x %unlike% "[.]"] <- gsub("^00", "0.0", x[!x %like% "[.]"])
    # remove last zeroes
    x <- gsub("([.].?)0+$", "\\1", x, perl = TRUE)
    x <- gsub("(.*[.])0+$", "\\10", x, perl = TRUE)
    # remove ending .0 again
    x[x %like% "[.]"] <- gsub("0+$", "", x[x %like% "[.]"])
    # never end with dot
    x <- gsub("[.]$", "", x, perl = TRUE)
    # trim it
    x <- trimws2(x)

    ## previously unempty values now empty - should return a warning later on
    x[x.bak != "" & x == ""] <- "invalid"

    na_before <- x[is.na(x) | x == ""] %pm>% length()
    x[!x %in% valid_mic_levels] <- NA
    na_after <- x[is.na(x) | x == ""] %pm>% length()

    if (na_before != na_after) {
      list_missing <- x.bak[is.na(x) & !is.na(x.bak) & x.bak != ""] %pm>%
        unique() %pm>%
        sort() %pm>%
        vector_and(quotes = TRUE)
      cur_col <- get_current_column()
      warning_("in `as.mic()`: ", na_after - na_before, " result",
        ifelse(na_after - na_before > 1, "s", ""),
        ifelse(is.null(cur_col), "", paste0(" in column '", cur_col, "'")),
        " truncated (",
        round(((na_after - na_before) / length(x)) * 100),
        "%) that were invalid MICs: ",
        list_missing,
        call = FALSE
      )
    }

    set_clean_class(factor(x, levels = valid_mic_levels, ordered = TRUE),
      new_class = c("mic", "ordered", "factor")
    )
  }
}

all_valid_mics <- function(x) {
  if (!inherits(x, c("mic", "character", "factor", "numeric", "integer"))) {
    return(FALSE)
  }
  x_mic <- tryCatch(suppressWarnings(as.mic(x[!is.na(x)])),
    error = function(e) NA
  )
  !any(is.na(x_mic)) && !all(is.na(x))
}

#' @rdname as.mic
#' @details `NA_mic_` is a missing value of the new `mic` class, analogous to e.g. base \R's [`NA_character_`][base::NA].
#' @format NULL
#' @export
NA_mic_ <- set_clean_class(factor(NA, levels = valid_mic_levels, ordered = TRUE),
  new_class = c("mic", "ordered", "factor")
)

#' @rdname as.mic
#' @export
is.mic <- function(x) {
  inherits(x, "mic")
}

#' @method as.double mic
#' @export
#' @noRd
as.double.mic <- function(x, ...) {
  as.double(gsub("[<=>]+", "", as.character(x), perl = TRUE))
}

#' @method as.numeric mic
#' @export
#' @noRd
as.numeric.mic <- function(x, ...) {
  as.numeric(gsub("[<=>]+", "", as.character(x), perl = TRUE))
}

#' @rdname as.mic
#' @method droplevels mic
#' @param as.mic a [logical] to indicate whether the `mic` class should be kept - the default is `FALSE`
#' @export
droplevels.mic <- function(x, as.mic = FALSE, ...) {
  x <- droplevels.factor(x, ...)
  if (as.mic == TRUE) {
    class(x) <- c("mic", "ordered", "factor")
  }
  x
}

# will be exported using s3_register() in R/zzz.R
pillar_shaft.mic <- function(x, ...) {
  crude_numbers <- as.double(x)
  operators <- gsub("[^<=>]+", "", as.character(x))
  operators[!is.na(operators) & operators != ""] <- font_silver(operators[!is.na(operators) & operators != ""], collapse = NULL)
  out <- trimws(paste0(operators, trimws(format(crude_numbers))))
  out[is.na(x)] <- font_na(NA)
  # maketrailing zeroes almost invisible
  out[out %like% "[.]"] <- gsub("([.]?0+)$", font_white("\\1"), out[out %like% "[.]"], perl = TRUE)
  create_pillar_column(out, align = "right", width = max(nchar(font_stripstyle(out))))
}

# will be exported using s3_register() in R/zzz.R
type_sum.mic <- function(x, ...) {
  "mic"
}

#' @method print mic
#' @export
#' @noRd
print.mic <- function(x, ...) {
  cat("Class 'mic'",
    ifelse(length(levels(x)) < length(valid_mic_levels), font_red(" with dropped levels"), ""),
    "\n",
    sep = ""
  )
  print(as.character(x), quote = FALSE)
  att <- attributes(x)
  if ("na.action" %in% names(att)) {
    cat(font_silver(paste0("(NA ", class(att$na.action), ": ", paste0(att$na.action, collapse = ", "), ")\n")))
  }
}

#' @method summary mic
#' @export
#' @noRd
summary.mic <- function(object, ...) {
  summary(as.double(object), ...)
}

#' @method as.matrix mic
#' @export
#' @noRd
as.matrix.mic <- function(x, ...) {
  as.matrix(as.double(x), ...)
}

#' @method [ mic
#' @export
#' @noRd
"[.mic" <- function(x, ...) {
  y <- NextMethod()
  attributes(y) <- attributes(x)
  y
}
#' @method [[ mic
#' @export
#' @noRd
"[[.mic" <- function(x, ...) {
  y <- NextMethod()
  attributes(y) <- attributes(x)
  y
}
#' @method [<- mic
#' @export
#' @noRd
"[<-.mic" <- function(i, j, ..., value) {
  value <- as.mic(value)
  y <- NextMethod()
  attributes(y) <- attributes(i)
  y
}
#' @method [[<- mic
#' @export
#' @noRd
"[[<-.mic" <- function(i, j, ..., value) {
  value <- as.mic(value)
  y <- NextMethod()
  attributes(y) <- attributes(i)
  y
}
#' @method c mic
#' @export
#' @noRd
c.mic <- function(...) {
  as.mic(unlist(lapply(list(...), as.character)))
}

#' @method unique mic
#' @export
#' @noRd
unique.mic <- function(x, incomparables = FALSE, ...) {
  y <- NextMethod()
  attributes(y) <- attributes(x)
  y
}

#' @method rep mic
#' @export
#' @noRd
rep.mic <- function(x, ...) {
  y <- NextMethod()
  attributes(y) <- attributes(x)
  y
}

#' @method sort mic
#' @export
#' @noRd
sort.mic <- function(x, decreasing = FALSE, ...) {
  if (decreasing == TRUE) {
    ord <- order(-as.double(x))
  } else {
    ord <- order(as.double(x))
  }
  x[ord]
}

#' @method hist mic
#' @importFrom graphics hist
#' @export
#' @noRd
hist.mic <- function(x, ...) {
  warning_("in `hist()`: use `plot()` or ggplot2's `autoplot()` for optimal plotting of MIC values")
  hist(log2(x))
}

# will be exported using s3_register() in R/zzz.R
get_skimmers.mic <- function(column) {
  skimr::sfl(
    skim_type = "mic",
    p0 = ~ stats::quantile(., probs = 0, na.rm = TRUE, names = FALSE),
    p25 = ~ stats::quantile(., probs = 0.25, na.rm = TRUE, names = FALSE),
    p50 = ~ stats::quantile(., probs = 0.5, na.rm = TRUE, names = FALSE),
    p75 = ~ stats::quantile(., probs = 0.75, na.rm = TRUE, names = FALSE),
    p100 = ~ stats::quantile(., probs = 1, na.rm = TRUE, names = FALSE),
    hist = ~ skimr::inline_hist(log2(stats::na.omit(.)), 5)
  )
}

# Miscellaneous mathematical functions ------------------------------------

#' @method mean mic
#' @export
#' @noRd
mean.mic <- function(x, trim = 0, na.rm = FALSE, ...) {
  mean(as.double(x), trim = trim, na.rm = na.rm, ...)
}

#' @method median mic
#' @importFrom stats median
#' @export
#' @noRd
median.mic <- function(x, na.rm = FALSE, ...) {
  median(as.double(x), na.rm = na.rm, ...)
}

#' @method quantile mic
#' @importFrom stats quantile
#' @export
#' @noRd
quantile.mic <- function(x, probs = seq(0, 1, 0.25), na.rm = FALSE,
                         names = TRUE, type = 7, ...) {
  quantile(as.double(x), probs = probs, na.rm = na.rm, names = names, type = type, ...)
}

# Math (see ?groupGeneric) ----------------------------------------------

#' @method abs mic
#' @export
#' @noRd
abs.mic <- function(x) {
  abs(as.double(x))
}
#' @method sign mic
#' @export
#' @noRd
sign.mic <- function(x) {
  sign(as.double(x))
}
#' @method sqrt mic
#' @export
#' @noRd
sqrt.mic <- function(x) {
  sqrt(as.double(x))
}
#' @method floor mic
#' @export
#' @noRd
floor.mic <- function(x) {
  floor(as.double(x))
}
#' @method ceiling mic
#' @export
#' @noRd
ceiling.mic <- function(x) {
  ceiling(as.double(x))
}
#' @method trunc mic
#' @export
#' @noRd
trunc.mic <- function(x, ...) {
  trunc(as.double(x), ...)
}
#' @method round mic
#' @export
#' @noRd
round.mic <- function(x, digits = 0) {
  round(as.double(x), digits = digits)
}
#' @method signif mic
#' @export
#' @noRd
signif.mic <- function(x, digits = 6) {
  signif(as.double(x), digits = digits)
}
#' @method exp mic
#' @export
#' @noRd
exp.mic <- function(x) {
  exp(as.double(x))
}
#' @method log mic
#' @export
#' @noRd
log.mic <- function(x, base = exp(1)) {
  log(as.double(x), base = base)
}
#' @method log10 mic
#' @export
#' @noRd
log10.mic <- function(x) {
  log10(as.double(x))
}
#' @method log2 mic
#' @export
#' @noRd
log2.mic <- function(x) {
  log2(as.double(x))
}
#' @method expm1 mic
#' @export
#' @noRd
expm1.mic <- function(x) {
  expm1(as.double(x))
}
#' @method log1p mic
#' @export
#' @noRd
log1p.mic <- function(x) {
  log1p(as.double(x))
}
#' @method cos mic
#' @export
#' @noRd
cos.mic <- function(x) {
  cos(as.double(x))
}
#' @method sin mic
#' @export
#' @noRd
sin.mic <- function(x) {
  sin(as.double(x))
}
#' @method tan mic
#' @export
#' @noRd
tan.mic <- function(x) {
  tan(as.double(x))
}
#' @method cospi mic
#' @export
#' @noRd
cospi.mic <- function(x) {
  cospi(as.double(x))
}
#' @method sinpi mic
#' @export
#' @noRd
sinpi.mic <- function(x) {
  sinpi(as.double(x))
}
#' @method tanpi mic
#' @export
#' @noRd
tanpi.mic <- function(x) {
  tanpi(as.double(x))
}
#' @method acos mic
#' @export
#' @noRd
acos.mic <- function(x) {
  acos(as.double(x))
}
#' @method asin mic
#' @export
#' @noRd
asin.mic <- function(x) {
  asin(as.double(x))
}
#' @method atan mic
#' @export
#' @noRd
atan.mic <- function(x) {
  atan(as.double(x))
}
#' @method cosh mic
#' @export
#' @noRd
cosh.mic <- function(x) {
  cosh(as.double(x))
}
#' @method sinh mic
#' @export
#' @noRd
sinh.mic <- function(x) {
  sinh(as.double(x))
}
#' @method tanh mic
#' @export
#' @noRd
tanh.mic <- function(x) {
  tanh(as.double(x))
}
#' @method acosh mic
#' @export
#' @noRd
acosh.mic <- function(x) {
  acosh(as.double(x))
}
#' @method asinh mic
#' @export
#' @noRd
asinh.mic <- function(x) {
  asinh(as.double(x))
}
#' @method atanh mic
#' @export
#' @noRd
atanh.mic <- function(x) {
  atanh(as.double(x))
}
#' @method lgamma mic
#' @export
#' @noRd
lgamma.mic <- function(x) {
  lgamma(as.double(x))
}
#' @method gamma mic
#' @export
#' @noRd
gamma.mic <- function(x) {
  gamma(as.double(x))
}
#' @method digamma mic
#' @export
#' @noRd
digamma.mic <- function(x) {
  digamma(as.double(x))
}
#' @method trigamma mic
#' @export
#' @noRd
trigamma.mic <- function(x) {
  trigamma(as.double(x))
}
#' @method cumsum mic
#' @export
#' @noRd
cumsum.mic <- function(x) {
  cumsum(as.double(x))
}
#' @method cumprod mic
#' @export
#' @noRd
cumprod.mic <- function(x) {
  cumprod(as.double(x))
}
#' @method cummax mic
#' @export
#' @noRd
cummax.mic <- function(x) {
  cummax(as.double(x))
}
#' @method cummin mic
#' @export
#' @noRd
cummin.mic <- function(x) {
  cummin(as.double(x))
}

# Ops (see ?groupGeneric) -----------------------------------------------

is_greater <- function(el) {
  el %like_case% ">[0-9]"
}
is_lower <- function(el) {
  el %like_case% "<[0-9]"
}

#' @method + mic
#' @export
#' @noRd
`+.mic` <- function(e1, e2) {
  as.double(e1) + as.double(e2)
}

#' @method - mic
#' @export
#' @noRd
`-.mic` <- function(e1, e2) {
  as.double(e1) - as.double(e2)
}

#' @method * mic
#' @export
#' @noRd
`*.mic` <- function(e1, e2) {
  as.double(e1) * as.double(e2)
}

#' @method / mic
#' @export
#' @noRd
`/.mic` <- function(e1, e2) {
  as.double(e1) / as.double(e2)
}

#' @method ^ mic
#' @export
#' @noRd
`^.mic` <- function(e1, e2) {
  as.double(e1)^as.double(e2)
}

#' @method %% mic
#' @export
#' @noRd
`%%.mic` <- function(e1, e2) {
  as.double(e1) %% as.double(e2)
}

#' @method %/% mic
#' @export
#' @noRd
`%/%.mic` <- function(e1, e2) {
  as.double(e1) %/% as.double(e2)
}

#' @method & mic
#' @export
#' @noRd
`&.mic` <- function(e1, e2) {
  as.double(e1) & as.double(e2)
}

#' @method | mic
#' @export
#' @noRd
`|.mic` <- function(e1, e2) {
  as.double(e1) | as.double(e2)
}

#' @method ! mic
#' @export
#' @noRd
`!.mic` <- function(x) {
  !as.double(x)
}

#' @method == mic
#' @export
#' @noRd
`==.mic` <- function(e1, e2) {
  as.double(e1) == as.double(e2)
}

#' @method != mic
#' @export
#' @noRd
`!=.mic` <- function(e1, e2) {
  as.double(e1) != as.double(e2)
}

#' @method < mic
#' @export
#' @noRd
`<.mic` <- function(e1, e2) {
  as.double(e1) < as.double(e2)
}

#' @method <= mic
#' @export
#' @noRd
`<=.mic` <- function(e1, e2) {
  as.double(e1) <= as.double(e2)
}

#' @method >= mic
#' @export
#' @noRd
`>=.mic` <- function(e1, e2) {
  as.double(e1) >= as.double(e2)
}

#' @method > mic
#' @export
#' @noRd
`>.mic` <- function(e1, e2) {
  as.double(e1) > as.double(e2)
  # doesn't work...
  # nolint start
  # as.double(e1) > as.double(e2) |
  #   (as.double(e1) == as.double(e2) & is_lower(e2) & !is_lower(e1)) |
  #   (as.double(e1) == as.double(e2) & is_greater(e1) & !is_greater(e2))
  # nolint end
}

# Summary (see ?groupGeneric) -------------------------------------------

#' @method all mic
#' @export
#' @noRd
all.mic <- function(..., na.rm = FALSE) {
  all(as.double(c(...)), na.rm = na.rm)
}
#' @method any mic
#' @export
#' @noRd
any.mic <- function(..., na.rm = FALSE) {
  any(as.double(c(...)), na.rm = na.rm)
}
#' @method sum mic
#' @export
#' @noRd
sum.mic <- function(..., na.rm = FALSE) {
  sum(as.double(c(...)), na.rm = na.rm)
}
#' @method prod mic
#' @export
#' @noRd
prod.mic <- function(..., na.rm = FALSE) {
  prod(as.double(c(...)), na.rm = na.rm)
}
#' @method min mic
#' @export
#' @noRd
min.mic <- function(..., na.rm = FALSE) {
  min(as.double(c(...)), na.rm = na.rm)
}
#' @method max mic
#' @export
#' @noRd
max.mic <- function(..., na.rm = FALSE) {
  max(as.double(c(...)), na.rm = na.rm)
}
#' @method range mic
#' @export
#' @noRd
range.mic <- function(..., na.rm = FALSE) {
  range(as.double(c(...)), na.rm = na.rm)
}
