#!/bin/bash

cmake . && make
testOutFileName="testOutput.txt"
failedTests=

echo
echo "=== dcc SCANNER TEST ==="
echo
echo "Comparing output of ./dcc samples/*.frag against expected output within samples/*.out..."
echo
for file in samples/*.frag; do
    compFileName=$(basename -- "${file}")
    compFileName="samples/${compFileName%.*}.out"

    $(./dcc < "${file}" &> "${testOutFileName}")

    if cmp -s "${compFileName}" "${testOutFileName}"; then
        echo PASS::"${file}"
    else
        echo
        echo FAIL::"${file}"
        printf 'The file "%s" is different from scanner output of ./dcc %s\n\n' "${compFileName}" "${file}"
        echo "===== SCANNER OUTPUT =====":
        cat "${testOutFileName}"
        echo "===== END SCANNER OUTPUT =====":
        echo
        echo "===== EXPECTED OUTPUT =====":
        cat "${compFileName}"
        echo "===== END EXPECTED OUTPUT =====":
        echo
        failedTests="${failedTests} ${file}"
    fi
    $(rm "${testOutFileName}")
done
echo
if [[ "${failedTests}" != "" ]]; then
    printf '=========== TEST FAILURES ============\nFailed Tests:\n'
    for testName in ${failedTests}; do
        echo "  ${testName}"
    done
    printf '======================================'
else
    echo "All dcc Scanner Tests PASS!"
fi
echo
echo "=== END dcc SCANNER TEST ==="

if [[ "${failedTests}" != "" ]]; then
    exit 1;
fi
