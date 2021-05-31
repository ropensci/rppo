## Resubmission
This is a resubmission. In this version I have:

* updated code to check if a server is responding or not.  Previous versions
* checked for non-200 status messages.  This release checks if server is even 
* responding at all.  Currently the server responding to all API calls has
* completely failed and will be rebuilt by June 7th.  Meanwhile, we are re-releasing
* the R package here so it fails gracefully.

## Test environments
* local OS X install, R 3.5.0
* ubuntu 16.04 (on travis-ci), R 4.0.2

## R CMD check results

0 errors | 0 warnings | 0 notes

## Downstream dependencies
There are currently no downstream dependencies for this package

