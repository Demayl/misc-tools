
# Basic script to brute force jolla security code. Currently it tries about 3k numbers in a minute
# Control manualy start, end and worker jobs
JOBS=10;

try_it() {
    STEP=$1;
    MAX=$2;
    END=100000000;
    SHIFT=0; # Change to previous tested $END
    MSHIFT=0;     # If you stopped script somewhere, enter value that single tread has computed
    PART=$((($END-$SHIFT) / $MAX));
    START=$(($STEP * $PART - $PART + $SHIFT + $MSHIFT));
    END=$(($START + $PART));
    sleep $STEP;
    echo "Get from $START to $END; PART $PART, STEP $STEP, MAX $MAX";
#    exit;
    for (( i=START; i<=END; i++ )); do
        i=$(printf '%05d' "$i"); # we can have leading zeroes
        /usr/lib/qt5/plugins/devicelock/encpartition --check-code $i;
        [ $? -eq 0 ] &&  echo "Found $i - $?" | tee -a end.txt && exit;
        [ $(($i % 1000)) -eq 0 ] &&  echo "/usr/lib/qt5/plugins/devicelock/encpartition --check-code $i" && [ -f "end.txt" ] && echo "Pass found! Exit" && exit;
    done;
    echo "Done from $START to $END"
}

for (( i=1; i<=JOBS; i++ )); do
    try_it $i $JOBS &
done;
