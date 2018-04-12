

alter session set "_px_trace"=high,all;
select /*+ PARALLEL(20) */ count(*) from TEST_TAB;


alter session set "_px_trace"=[[Verbosity,]area],[[Verbosity,]area],..,[time];

For Verbosity, the possible values are as follows:
        High
        Medium
        Low
For the Area parameter, the possible values are as follows:
        Scheduling
        Execution   
        Granule
        Messaging
        Buffer
        Compilation
        All
        None

For the Time parameter, the only possible value is time.
The following basic example shows how to use this facility with a query you want to analyze:

alter session set "_px_trace"="compilation","execution","messaging";
