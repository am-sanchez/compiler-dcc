#!/bin/bash

cmake . && make
testOutFileName="testOutput.txt"
failedTests=
for file in samples/*.frag; do
    compFileName=$(basename -- "${file}")
    compFileName="samples/${compFileName%.*}.out"
    echo "${compFileName}"
    $(./dcc < "${file}" > "${testOutFileName}")

    if cmp "${compFileName}" "${testOutFileName}"; then
        printf 'The file "%s" is the same as "%s"\n' "${compFileName}" "${testOutFileName}"
        echo PASS::"${file}"
    else
        printf 'The file "%s" is different from "%s"\n' "${compFileName}" "${testOutFileName}"
        echo FAIL::"${file}"
        failedTests="${failedTests} ${file}"
    fi
    $(rm "${testOutFileName}")
done
echo "Failed Tests: ${failedTests}"