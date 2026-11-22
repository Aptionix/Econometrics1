# Published values are from jvab011.pdf, Tables 3, 5, 6, and 7.
# A tolerance of .00051 compares against the paper's three-decimal rounding.
validate_replication <- function(results) {
  checks <- list()
  compare <- function(section, model, term, statistic, expected, tolerance = .00051) {
    row <- results[[section]][[model]]$tidy
    observed <- row[[statistic]][match(term, row$term)]
    if (length(observed) != 1) observed <- NA_real_
    checks[[length(checks) + 1L]] <<- data.frame(section = section, model = model, term = term,
      statistic = statistic, expected = expected, observed = observed, tolerance = tolerance,
      passed = !is.na(observed) && abs(observed - expected) <= tolerance)
  }
  if ("table3" %in% names(results)) {
    estimates <- list(
      burglary = rbind(c(-.106,-.294,-.285,-.234,-.120,.821,.951,-.069,-.062,-.032,-.064),
                       c(.016,.006,-.013,.116,.180,1.290,1.015,-.006,-.029,.031,-.028)),
      robbery = rbind(c(-1.032,-1.297,-.832,-1.281,-1.336,.727,.693,-.115,-.127,-.116,-.168),
                      c(.129,.228,.288,.144,.189,1.705,2.928,.020,-.002,.018,.027)),
      homicide = rbind(c(-.008,.120,.072,.188,.222,.618,1.053,.026,.064,.000,.044),
                       c(-.049,-.055,-.062,.100,.047,.975,.433,-.005,-.007,.002,-.008)))
    errors <- list(
      burglary = rbind(c(.370,.660,.474,.686,.701,.091,.124,.036,.069,.036,.072),
                       c(.149,.288,.298,.319,.377,.144,.133,.026,.049,.031,.059)),
      robbery = rbind(c(.219,.428,.299,.433,.438,.341,.141,.033,.065,.034,.069),
                      c(.088,.162,.170,.189,.208,.800,.597,.016,.031,.018,.030)),
      homicide = rbind(c(.139,.251,.181,.262,.266,.094,.482,.027,.047,.028,.051),
                       c(.057,.115,.119,.133,.143,.148,.198,.012,.024,.015,.024)))
    n <- c(816,240,240,240,180,816,240,3604,1060,3672,1080)
    for (y in names(estimates)) for (j in 1:11) for (k in 1:2) {
      model <- paste0(y, "_c", j); term <- c("treat_post", "uncertain_post")[k]
      compare("table3", model, term, "estimate", estimates[[y]][k,j])
      compare("table3", model, term, "std.error", errors[[y]][k,j])
      compare("table3", model, term, "nobs", n[j], 0)
    }
  }
  if ("table5" %in% names(results)) {
    estimates <- list(A = c(.340,.347,.821,.406,-.115,.056,1.052,1.078,.609,1.046),
      B = c(-.149,-.148,-.206,-.090,-.049,-.055), C = c(-.302,-.301,-.371,-.170,-.064,-.065,.619,.700,.359,.473),
      D = c(-.098,-.099,-.137), E = c(.879,.890,1.471,.827,-.050,.126,1.168,1.206,.742,1.117))
    errors <- list(A = c(.180,.154,.134,.135,.026,.063,.047,.060,.119,.144),
      B = c(.024,.022,.019,.022,.012,.013), C = c(.051,.046,.041,.039,.014,.016,.149,.171,.129,.140),
      D = c(.024,.023,.019), E = c(.164,.140,.120,.121,.022,.061,.068,.092,.146,.157))
    for (panel in names(estimates)) for (j in seq_along(estimates[[panel]])) {
      id <- paste0(panel, "_c", j)
      compare("table5", id, "postmet", "estimate", estimates[[panel]][j])
      compare("table5", id, "postmet", "std.error", errors[[panel]][j])
      compare("table5", id, "postmet", "nobs", if (j == 3) 3232 else 1616, 0)
    }
  }
  if ("table6" %in% names(results)) {
    estimates <- rbind(c(-.496,-.158,-.130,.030,.214,-.056,-.114,-.045,-.055,-.114),
      c(.632,.606,-.111,1.177,1.040,-.049,-.160,-.106,-.046,-.094),
      c(.772,.688,-.131,1.382,1.146,-.065,-.220,-.141,-.054,-.125),
      c(1.350,1.147,-.117,2.157,1.783,-.034,-.250,-.174,-.068,-.187))
    errors <- rbind(c(.268,.233,.043,.246,.209,.037,.038,.038,.019,.040),
      c(.176,.153,.027,.163,.140,.023,.024,.023,.012,.025),
      c(.165,.141,.026,.151,.129,.021,.021,.021,.011,.023),
      c(.175,.151,.026,.160,.137,.022,.021,.021,.011,.022))
    terms <- c("postmet_jan1830", "postmet_nonjan1830", "postmet_1831", "postmet_1832")
    for (j in 1:10) for (k in 1:4) {
      compare("table6", paste0("c",j), terms[k], "estimate", estimates[k,j])
      compare("table6", paste0("c",j), terms[k], "std.error", errors[k,j])
      compare("table6", paste0("c",j), terms[k], "nobs", 3232, 0)
    }
  }
  if ("table7" %in% names(results)) {
    estimates <- list(log_charges = c(-.024,-.190,.022,-.118,.053,-.079,.066),
      log_violcharges = c(-.031,-.183,-.002,-.129,.034,-.093,.048),
      log_propcharges = c(.017,-.143,.064,-.063,.090,-.028,.101),
      log_othercharges = c(.002,-.181,.027,-.055,.009,-.049,.030))
    errors <- list(log_charges = c(.033,.062,.043,.055,.057,.048,.075),
      log_violcharges = c(.050,.104,.058,.070,.078,.062,.104),
      log_propcharges = c(.042,.065,.050,.066,.060,.057,.083),
      log_othercharges = c(.078,.120,.077,.097,.092,.089,.107))
    ns <- c(log_charges = 1632, log_violcharges = 1431, log_propcharges = 1440, log_othercharges = 1267)
    terms <- c("force_existence_all", "force_eff1500", "force_ineff1500", "force_eff2000", "force_ineff2000", "force_eff2500", "force_ineff2500")
    columns <- c(1,2,2,3,3,4,4)
    for (y in names(estimates)) for (j in 1:7) {
      compare("table7", paste0(y, "_c", columns[j]), terms[j], "estimate", estimates[[y]][j])
      compare("table7", paste0(y, "_c", columns[j]), terms[j], "std.error", errors[[y]][j])
      compare("table7", paste0(y, "_c", columns[j]), terms[j], "nobs", ns[[y]], 0)
    }
  }
  if (!length(checks)) return(data.frame(section = character(), model = character(), term = character(),
    statistic = character(), expected = numeric(), observed = numeric(), tolerance = numeric(), passed = logical()))
  checks <- bind_rows(checks)
  # The paper prints a common N row. Two supplied daily records have missing
  # offence-specific informations/charges (1830-02-10, offices l and u).
  checks$known_difference <- with(checks,
    !passed & statistic == "nobs" & expected - observed == 2 &
      ((section == "table5" & model %in% c("C_c4", "C_c5", "C_c6", "C_c8", "C_c9", "C_c10",
                                          "E_c4", "E_c5", "E_c6", "E_c8", "E_c9", "E_c10")) |
       (section == "table6" & model %in% c("c5", "c6"))))
  checks$known_difference[is.na(checks$known_difference)] <- FALSE
  checks
}
