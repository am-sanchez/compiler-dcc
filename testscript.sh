#!/bin/bash

cmake . && make
testOutFileName="testOutput.txt"
for file in samples/*.frag; do
    compFileName=$(basename -- "${file}")
    compFileName="samples/${compFileName%.*}.out"
    echo "${compFileName}"
    $(./dcc < "${compFileName}" > "${testOutFileName}")

    if cmp -s "${compFileName}" "${testOutFileName}"; then
        printf 'The file "%s" is the same as "%s"\n' "${compFileName}" "${testOutFileName}"
        echo PASS::"${file}"
    else
        printf 'The file "%s" is different from "%s"\n' "${compFileName}" "${testOutFileName}"
        echo FAIL::"${file}"
    fi
    $(rm "${testOutFileName}")
done