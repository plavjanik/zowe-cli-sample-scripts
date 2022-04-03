#!/bin/bash
#
# This program and the accompanying materials are made available and may be used, at your option, under either: #
# * Eclipse Public License v2.0, available at https://www.eclipse.org/legal/epl-v20.html, OR #
# * Apache License, version 2.0, available at http://www.apache.org/licenses/LICENSE-2.0 #
#                                                                                       #
# SPDX-License-Identifier: EPL-2.0 OR Apache-2.0                                        #
#                                                                                       #
# Copyright Contributors to the Zowe Project.                                           #
#                                                                                       #
#


#
# This program and the accompanying materials are made available under the terms of the #
# Eclipse Public License v2.0 which accompanies this distribution, and is available at  #
# https://www.eclipse.org/legal/epl-v20.html                                            #
#                                                                                       #
# SPDX-License-Identifier: EPL-2.0                                                      #
#                                                                                       #
# Copyright Contributors to the Zowe Project.                                           #
#


#submit our job
jobid=$(bright zos-jobs submit data-set "solsu01.mimpds.cntl(iefbr14)" --rff jobid --rft string)

echo "Submitted our job, JOB ID is $jobid"

#wait for it to go to output
status="UNKNOWN"
while [[ "$status" != "OUTPUT" ]]; do
    echo "Checking status of job $jobid"
    status=$(bright zos-jobs view job-status-by-jobid "$jobid" --rff status --rft string)
    echo "Current status is $status"
    sleep 5s
done;

echo "Job completed in OUTPUT status. Final result of job: "
bright zos-jobs view job-status-by-jobid "$jobid"

# get a list of all of the spool files for our job now that it's in output 
spool_ids=$(bright zos-jobs list spool-files-by-jobid "$jobid" --rff id --rft table)

# save each spool ID to a custom file name 
while read -r id; do
    bright zos-jobs view spool-file-by-id "$jobid" "$id" > ./${jobid}_spool_${id}.txt
    echo "Saved spool DD to ./${jobid}_spool_${id}.txt"
done <<< "$spool_ids"
