#!/bin/bash

cat >> ./report.html << EOF
<!doctype html>
<html lang="en">
    <head>
        <!-- Required meta tags -->
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

        <!-- Bootstrap CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
        
        <!-- Custom CSS -->
        <link rel="stylesheet" href="utils/styles.css">

        <title>Newman Summary Report</title>
    </head>
    <body>
        <div class="container"> <!-- # container -->
            <div class="row"> <!-- # Title div --> 
                <div class="col-md-12 col-lg-12">
                    <h1 class="display-2 mx-auto text-center lg-auto p-3">Newman Run Dashboard</h1>
                </div>
            </div> <!-- # End Title div -->
            <div class="row mb-10"> <!-- # Table div --> 
                <div class="col-md-12 col-lg-12">
                    <table class="table">
                        <thead>
                            <tr>
                            <th scope="col">#</th>
                            <th scope="col">Test</th>
                            <th scope="col">Iterations</th>
                            <th scope="col">Pending</th>
                            <th scope="col">Failed</th>
                            <th scope="col">Ave response</th>
                            <th scope="col">Max response</th>
                            <th scope="col">Min response</th>
                            </tr>
                        </thead>
                        <tbody>
EOF

row_number=0
FILES="./newman/*"
for f in $FILES; do
    test_name=($(jq -r '.run.executions[].item.name' $f))
    iterations=($(jq -r '.run.stats.iterations.total' $f))
    pending=($(jq -r '.run.stats.iterations.pending' $f))
    failed=($(jq -r '.run.stats.assertions.failed' $f))
    responseAverage=`echo "scale=2; ($(jq -r '.run.timings.responseAverage' $f))/1" | bc`
    responseMax=`echo "scale=2; ($(jq -r '.run.timings.responseMax' $f))/1" | bc`
    responseMin=`echo "scale=2; ($(jq -r '.run.timings.responseMin' $f))/1" | bc`
    date=$(jq -r '.run.executions[0].response.header[0].value' $f)

    ((row_number++))

    if [ "$failed" -eq 0 ]; then failed_color=grey; else failed_color=red; fi

cat >> ./report.html << EOF
                            <tr>
                                <th scope="row">${row_number}</th>
                                <td>${test_name}</td>
                                <td>${iterations}</td>
                                <td>${pending}</td>
                                <td class=${failed_color}>${failed}</td>
                                <td>${responseAverage}</td>
                                <td>${responseMax}</td>
                                <td>${responseMin}</td>
                            </tr>
EOF
done
    
cat >> ./report.html << EOF
                        </tbody>
                    </table>
                </div>
            </div> <!-- # End Table div --> 
            <div class="row"> <!-- # Date div -->
                <div class="col-md-12 col-lg-12">
                    <p class="text-right lead green mt-4 mb-4">${date}</p>
                </div>
            </div> <!-- # End Date div -->
            <div class="row">
                <div class="col-1">
                    <h5 class="red underline">#</h5>
                </div>
                <div class="col-4">
                    <h5 class="red underline">Failure</h5>
                </div>
                <div class="col-7">
                    <h5 class="red underline">Detail</h5>
                </div>
            </div>
EOF

no_Of_Failure=0
for f in $FILES; do
failed_test=$(jq -r '.run.failures[].error.test' $f)
failed_error_type=$(jq -r '.run.failures[].error.name' $f)
failed_request_name=$(jq -r '.run.failures[].source.name' $f)
failed_test_message=$(jq '.run.failures[].error.message' $f)
failed_request_method=$(jq -r '.run.failures[].source.request.method' $f)

if [ "$failed_error_type" == "" ]
then
    isDisplayed=hidden;
    padding=-10px
else
    isDisplayed=display
    padding=20px
    ((no_Of_Failure++))
fi

cat >> ./report.html << EOF
            <div id="detail" class="row $isDisplayed">
                <div class="col-1">
                    <p>${no_Of_Failure}.</p>
                </div>
                <div class="col-4">
                    <p>${failed_error_type}</p>
                </div>
                <div class="col-7">
                    <p>${failed_request_name}</p>
                    <p>${failed_test}</p>
                    <p>${failed_request_method}</p>
                    <p class="light italics">${failed_test_message}</p>
                </div>
            </div>
EOF
done

cat >> ./report.html << EOF
        </div>  <!-- # End of container -->
            <!-- jQuery first, then Popper.js, then Bootstrap JS -->
            <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
            <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
            
            <!-- custom Js -->
            <script src="utils/index.js" type="text/javascript"></script>
    </body>
</html>
EOF

