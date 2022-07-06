

# summary cross tab - assumes A is a vector containing a frequency type column (e.g. sum of population) 
# and B could be something like a year. Result will show sum of column A by B
# xtab will print in console window
# need to specify which dataset each variable is from.

xtabs(df$A~df$B)

# Possible to add multiple columns to the table 
xtabs(population$pop~population$year+population$hb2019name)

# These two functions can be useful in different ways
xtabs(iris$Sepal.Length ~ iris$Species)
table(iris$Sepal.Length, iris$Species)