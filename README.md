# gostic-effective-r0
Estimating Covid-19 reproduction number with delays and right-truncation

CHTC branch goals:
     A. Split r script into two pieces:
        1. pull the data and prepare the data frame for R0 calculation;
        2. R0 calculation

     B. Write DAGMan:   
     	      JOB PULL
	      JOB CALCULATE
	      POST-SCRIPT CALCULATE summarizeResults

	      PARENT PULL CHILD CALCULATE

        CALCULATE submits a cluster of R0 calculations, one for each county (or geographical unit)

Implementation:
	PULL could be a Vanilla Universe job or it could run in a CALCULATE docker container.
	CALCULATE is Docker Universe job.

