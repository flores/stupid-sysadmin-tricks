# really just a one-liner copied into .sh https://gist.github.com/1174722

function sum_that_shit () { curl -s $* |perl -pi -e 's/div/\n/g' |perl -nl -e 'if ($_ =~ /Request rate: (.+) req/) { $sum+=$1; } elsif ($_ =~ /Errors: total (.+)?\s/) { $errors+=$1; } elsif ($_ =~ /Total: connections (.+)?\s/) { $conns+=$1; } elsif ($_ =~ /title>(.+)?\s&mdash/) { $title=$1; } END  { $success_percent = 100 * ($conns-$errors)/$conns; print "$title\n$sum requests/s\n$conns total connections\n$errors total errors\n$success_percent\% success\n\n"; }'; }


