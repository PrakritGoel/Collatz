#!/bin/bash

# We must build collatz from scratch and compile it.
# Given that new data is only ever appended, we need
# to empty each file every time it is run.
make clean all;
rm -f len_collatz.dat;
rm -f max_collatz.dat;
rm -f freq_collatz.dat;

# The data files for the first two GNU plots must be 
# built using some value which is steadily incremented.
# Consequently, both data files are built under the 
# same for loop.
for (( i=2; i < 10001; i++ ))
do
    # The file into which data is being inputted will
    # contain the collatz sequence for the value of i.
    ./collatz -n $i > tmp_file;

    len=`cat tmp_file | wc -l`;
    echo "$i $len" >> len_collatz.dat;

    # tmp_file is sorted from least to greatest. Then,
    # the last value is stored in the variable max.
    max=`cat tmp_file | sort -nu | tail -1`;
    echo "$i $max" >> max_collatz.dat;
done

# The data file for length frequencies is built using that
# of the sequence lengths in the following way. First, the
# second column (the lengths) is isolated and sorted into
# groupings of equal lengths. Then, the groupings are
# assigned a count value. In order for each set of values
# to be assigned to the correct axis, the two columns are
# switched. After a final numerical sorting, the data are
# appended to the data file for length frequencies.
cat len_collatz.dat | awk '{ print $2 }' | sort | uniq -c | awk '{print $2,$1}' | sort -n >> freq_collatz.dat;

# Here, the first GNU plot is created, depicting the
# lengths of collatz sequences, the starting values
# of which range from 2 to 10,000.
gnuplot <<END
    set terminal pdf
    set output "len_collatz.pdf"
    set title "Collatz Sequence Lengths"
    set xlabel "n"
    set ylabel "length"
    set zeroaxis
    plot "len_collatz.dat" with dots title ""
END

# The second GNU plot depicts the maximum value for
# each collatz sequence created with a starting value
# in the range 2 to 10,000.
gnuplot <<END
    set terminal pdf
    set output "max_collatz.pdf"
    set title "Maximum Collatz Sequence Value"
    set xlabel "n"
    set ylabel "value"
    set yrange [0:100000]					# Here, the vertical axis is manually shortened.
    set zeroaxis
    plot "max_collatz.dat" with dots title ""
END

# The third GNU plot depicts the frequencies of each
# length depicted in the first plot.
gnuplot <<END
    set terminal pdf
    set output "freq_collatz.pdf"
    set title "Collatz Sequence Length Histogram"
    set xlabel "length"
    set ylabel "frequency"
    set xrange [0:225]						# Here, the horizontal axis is manually shortened.
    set zeroaxis
    set style data histogram
    set xtics 0,25,225
    plot "freq_collatz.dat" using 2:xtic(10) notitle
END

rm -f tmp_file
